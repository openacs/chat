#/chat/www/chat.tcl
ad_page_contract {

    Decide which template to use HTML or AJAX.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id
  {client "ajax"}
    {message:html ""}
} -properties {
    context_bar:onevalue
    user_id:onevalue
    user_name:onevalue
    message:onevalue
    room_id:onevalue
    room_name:onevalue 
    width:onevalue
    height:onevalue
    host:onevalue
    port:onevalue
    moderator_p:onevalue
    msgs:multirow
}

if { [catch {set room_name [chat_room_name $room_id]} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
}

    set user_id [ad_conn user_id]
    set return_url [ad_return_url]
    db_1row room_info {
        select room.comm_name
        from chat_rooms as room
        where room.room_id = :room_id        
      }  		
    	set folder_id "$comm_name's Public Files" 
    	db_1row room_info {
        	select count(acs.object_id) as count
        	from acs_objects as acs
        	where acs.title = :folder_id        
      	}  
    	if { $count > 0 } {   
    		db_1row room_info {
        		select acs.object_id as id
        		from acs_objects as acs
        		where acs.title = :folder_id        
      		}
      		set folder_id $id  
      	} else {
      		acs_user::get -user_id $user_id -array user      		
      		set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]      		
      		set folder_id "$name's Shared Files"      		
      		  
      		#$folder_id
      		db_1row room_info {
        		select fs.folder_id as id
        		from fs_folders as fs
        		where fs.name = :folder_id
      		}  
      		set folder_id $id  
      	}



set context_bar $room_name
auth::require_login
set user_id [ad_conn user_id]
set read_p [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p [permission::permission_p -object_id $room_id -privilege "chat_ban"]
#set moderate_room_p [chat_room_moderate_p $room_id]


#if { $moderate_room_p eq "t" } {
#    set moderator_p [permission::permission_p -object_id $room_id -privilege "chat_moderator"]
#} else {
#    # This is an unmoderate room, therefore everyone is a moderator.
#    set moderator_p "1"
#}

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") } {
	db_1row room_info {
		select cr.private as private
		from chat_rooms as cr
		where cr.room_id = :room_id
	}
	if { $private eq "f"} {
	
    		#Display unauthorize privilege page.    
    		ad_returnredirect unauthorized
    		ad_script_abort
    	}	
}

# Get chat screen name.
set user_name [chat_user_name $user_id]

# send message to the database 
if { $message ne "" } {
    chat_message_post $room_id $user_id $message $moderator_p
}


# Determine which template to use for html or ajax client
switch $client {
    "html" {
        set template_use "html-chat"
        # forward to ajax if necessary
        if { $message ne "" } {
            set session_id [ad_conn session_id]
            ::chat::Chat c1 -volatile -chat_id $room_id -session_id $session_id
            c1 add_msg $message
        }
    }
    "ajax" {        
        set template_use "ajax-chat-script"        
    }
    "java" {    
        set template_use "java-chat"

        # Get config paramater for applet.
        set width [ad_parameter AppletWidth "" 500]
        set height [ad_parameter AppletHeight "" 400]   
    
        set host [ad_parameter ServerHost "" [ns_config "ns/server/[ns_info server]/module/nssock" Hostname]]
        set port [ad_parameter ServerPort "" 8200]
     }
}
ad_return_template $template_use

