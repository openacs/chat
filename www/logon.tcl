ad_page_contract {
    Log on chat room.
    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date September 19, 2006    
} {
	room_id
}

set Rss_service ""
set Mail_service ""
set alias ""


ad_form -name "logon" -edit_buttons [list [list [_ chat.enter_room] next]] -has_edit 1 -form {
    {room_id:key}
    {alias:text(text)
        {label "Alias" }
    }
    {Rss_service:boolean(radio)
        {label "Rss_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {value "f"}
    }
    {frequency1:boolean(select),optional
        {label "Frequency Rss" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
    }
    {Mail_service:boolean(radio)
        {label "Mail_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {value "f"}
    }
    {frequency2:boolean(select),optional
        {label "Frequency Mail" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
    }
} -new_data {
	
	          
} -edit_request {
}  -after_submit {
		set context_id [ad_conn package_id]
		set creation_ip [ad_conn peeraddr]
		set user_id [ad_conn user_id]
		db_1row room_info {
        		select count(1) as info
        		from chat_registered_users
        		where room_id = :room_id
        		and user_id = :user_id
        	}
		if { $info == 0 } {
			if {[catch {set user [chat_registered_user -RSS_service $Rss_service \
                	-mail_service $Mail_service \
                	-context_id $context_id \
                	-creation_ip $creation_ip \
                	$room_id $alias $user_id]} errmsg]} {
        		ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        		break
    			}
    		} else {
    			
    		}
                ad_returnredirect "room?room_id=$room_id"
                ad_script_abort
}
ad_return_template "logon"
   