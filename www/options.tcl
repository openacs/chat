ad_page_contract {
    Options chat room.
    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date October 10, 2006    
} {
    action
    room_id
}
set user_id [ad_conn user_id]

db_1row room_info {
        select rm.room_id,               
           (select ru.alias
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as alias,
           (select ru.RSS_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as rss_service,
           (select ru.mail_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as mail_service
    from chat_rooms rm
    where rm.room_id = :room_id
}

ad_form -name "options" -edit_buttons [list [list [_ chat.room_options] next]] -has_edit 1 -form {
    {room_id:key}
    {action:text(hidden)
    {value $action}}
    {alias:text(text)
        {label "Alias" }
    }
    {rss_service:boolean(radio)
        {label "Rss_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {value "f"}
    }
    {frequency1:boolean(select),optional
        {label "Frequency Rss" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
    }
    {mail_service:boolean(radio)
        {label "Mail_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {value "f"}
    }
    {frequency2:boolean(select),optional
        {label "Frequency Mail" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
    }
} -after_submit {
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
			if {[catch {set user [chat_registered_user -RSS_service $rss_service \
                	-mail_service $mail_service \
                	-context_id $context_id \
                	-creation_ip $creation_ip \
                	$room_id $alias $user_id]} errmsg]} {
        		ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        		break
    			}
    		} else {
    		
    			set del [chat_room_delete_registered_users $room_id $user_id]    			
    			if {[catch {set user [chat_registered_user -RSS_service $rss_service \
                	-mail_service $mail_service \
                	-context_id $context_id \
                	-creation_ip $creation_ip \
                	$room_id $alias $user_id]} errmsg]} {
        		ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        		break
    			}
    		}
    		ad_returnredirect $action
                ad_script_abort
} -new_data {	          
} -edit_request {
} 
ad_return_template "options"
   