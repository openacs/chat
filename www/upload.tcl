ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,optional,notnull
    folder_id:integer,optional,notnull
    upload_file:trim,optional
    return_url:optional
    chat_id:optional
    upload_file.tmpfile:tmpfile,optional
    content_body:optional
    {title ""}
    {lock_title_p 0}
    {name ""}

} -properties {
    folder_id:onevalue    
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
} -validate {
    file_id_or_folder_id {
	if {[exists_and_not_null file_id] && ![exists_and_not_null folder_id]} {
	    set folder_id [db_string get_folder_id "select parent_id as folder_id from cr_items where item_id=:file_id;" -default ""]
	}
	if {![fs_folder_p $folder_id]} {
	    ad_complain "The specified parent folder is not valid."
	}
    }
    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes "1000000"
	if { $n_bytes > $max_bytes } {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	}
    }
}

set title ""
set description ""

set user_id [ad_conn user_id]
#set package_id [ad_conn package_id]


db_1row room_info {	
        	select distinct apm.package_id as package_id
        	from apm_packages as apm
        	where apm.package_key = 'file-storage'
        	and apm.instance_name = 'User Folders'
	}	
	
# check for write permission on the folder or item

permission::require_permission \
    -object_id $folder_id \
    -party_id $user_id \
    -privilege "write"

if {![ad_form_new_p -key file_id]} {
    permission::require_permission \
	-object_id $file_id \
	-party_id $user_id \
	-privilege "write"
    set context [fs_context_bar_list -final "[_ file-storage.Add_Revision]" $folder_id]
    
} else {
    set context [fs_context_bar_list -final "[_ file-storage.Add_File]" $folder_id]
}

ad_form -html { enctype multipart/form-data } -export { folder_id lock_title_p name } -form {
    file_id:key
    {upload_file:file {label \#file-storage.Upload_a_file\#} {html "size 30"}}
}

if {[parameter::get -parameter AllowTextEdit -default 0]} {
    if {[ad_form_new_p -key file_id]} { 
            
        # To allow the creation of files
        ad_form -extend -form {
            {content_body:richtext(richtext),optional 
                {label "Create a file"} 
                {html "rows 20 cols 70" } 
                {htmlarea_p 1}
            }
        }
    } else {
        # To make content editable
        set revision_id [content::item::get_live_revision -item_id $file_id]
        set mime_type [db_string get_mime_type "select mime_type from cr_revisions where revision_id = :revision_id"]
        if { [string equal $mime_type "text/html"] } {
            ad_form -extend -form {
                {edit_content:richtext(richtext),optional 
                    {label "Content"} 
                    {html "rows 20 cols 70" } 
                    {htmlarea_p 1}
                }
                {mime_type:text(hidden) 
                    {value $mime_type}
                }
            }
        }
    }
}

if {[exists_and_not_null return_url]} {
    ad_form -extend -form {
	{return_url:text(hidden) {value $return_url}}
    }
}

if {[exists_and_not_null chat_id]} {
    ad_form -extend -form {
	{chat_id:text(hidden) {value $chat_id}}
    }
}

if {$lock_title_p} {
    ad_form -extend -form {
	{title:text(hidden) {value $title}}
    }
} else {
    ad_form -extend -form {
	{title:text {label \#file-storage.Title\#} {html {size 30}} }
    }
}

ad_form -extend -form {
    {description:text(textarea) {label \#file-storage.Description\#} {html "rows 5 cols 35"}}
    
}


ad_form -extend -form {} -select_query_name {get_file} -new_data {
    
    set upload_files [list [template::util::file::get_property filename $upload_file]]
    set upload_tmpfiles [list [template::util::file::get_property tmp_filename $upload_file]]

    set mime_type ""
    if { [empty_string_p [lindex $upload_files 0]]} {
        if {[parameter::get -parameter AllowTextEdit -default 0] && [empty_string_p [template::util::richtext::get_property html_value $content_body]] } {
            ad_return_complaint 1 "You have to upload a file or create a new one"
            ad_script_abort
        }
        # create a tmp file to import from user entered HTML
        set content_body [template::util::richtext::get_property html_value $content_body]
        set mime_type text/html
        set tmp_filename [ns_tmpnam]
        set fd [open $tmp_filename w] 
        puts $fd $content_body
        close $fd
        set upload_files [list $title]
        set upload_tmpfiles [list $tmp_filename]
    }
    ns_log notice "file_add mime_type='${mime_type}'"	    
    set i 0
    set number_upload_files [llength $upload_files]
    foreach upload_file $upload_files tmpfile $upload_tmpfiles {
	set this_file_id $file_id
	set this_title $title
	set mime_type [cr_filename_to_mime_type -create -- $upload_file]
	# upload a new file
	# if the user choose upload from the folder view
	# and the file with the same name already exists
	# we create a new revision
	
	if {[string equal $this_title ""]} {
	    set this_title $upload_file
	}
	
	if {![empty_string_p $name]} {
	    set upload_file $name
	}

	set existing_item_id [fs::get_item_id -name $upload_file -folder_id $folder_id]
	
	if {![empty_string_p $existing_item_id]} {
	    # file with the same name already exists
	    # in this folder, create a new revision
	    set this_file_id $existing_item_id
	    permission::require_permission \
		-object_id $this_file_id \
		-party_id $user_id \
		-privilege write
	}

	set revision_id [fs::add_file \
	    -name $upload_file \
	    -item_id $this_file_id \
	    -parent_id $folder_id \
	    -tmp_filename $tmpfile\
	    -creation_user $user_id \
	    -creation_ip [ad_conn peeraddr] \
	    -title $this_title \
	    -description $description \
	    -package_id $package_id \
			     -mime_type $mime_type]

        file delete $tmpfile
        incr i
        if {$i < $number_upload_files} {
            set file_id [db_nextval "acs_object_id_seq"]
        }
    }
    file delete $upload_file.tmpfile
} -edit_data {
    set this_title $title
    set filename [template::util::file::get_property filename $upload_file]
    if {[string equal $this_title ""]} {
	set this_title $filename
    }
    	
    set revision_id [fs::add_version \
	-name $filename \
	-tmp_filename [template::util::file::get_property tmp_filename $upload_file] \
        -item_id $file_id \
	-creation_user $user_id \
	-creation_ip [ad_conn peeraddr] \
	-title $this_title \
	-description $description \
			 -package_id $package_id]
	
} -after_submit {

	if { $description eq "" } {
		set description $upload_file
		if { $title eq "" } {
			set title $upload_file
		}
	}
	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	set context_id [ad_conn package_id]		
	set date [clock format [clock seconds] -format {%D} ]
	
	set send_file [send_file $chat_id $upload_file $title $description $date $context_id $creation_user $creation_ip $revision_id]
	
	db_1row room_info2 {
    		select count(r.alias)
    		from chat_registered_users r
    		where r.user_id = :creation_user
    		and r.room_id = :chat_id
	}

	if { $count > 0} {
		db_1row room_info2 {
    			select r.alias
    			from chat_registered_users r
    			where r.user_id = :creation_user
    			and r.room_id = :chat_id
		}
		set post [chat_message_post $chat_id -1 "The file '$title' has been sent by the user $alias" "1"]
	} else {
		set post [chat_message_post $chat_id -1 "The file '$title' has been sent by the user [chat_user_name $creation_user]" "1"]
	}	
	
	
	
        
		
    if {[exists_and_not_null return_url]} {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect "./?[export_url_vars folder_id]"
    }
    ad_script_abort

}

# if title isn't passed in ignore lock_title_p
if {[empty_string_p $title]} {
    set lock_title_p 0
}

ad_return_template
