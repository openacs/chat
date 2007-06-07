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
set rss_active $rss_service

ad_form -name "options" -edit_buttons [list [list [_ chat.change_room_options] next]] -has_edit 1 -form {
    {room_id:key}
    {action:text(hidden)
    {value $action}}
    {alias:text(text)
        {label "#chat.alias#" }
        {help_text "[_ chat.alias_in_this_room]"}
    }
    {rss_service:boolean(radio)
        {label "#chat.rss_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.rss_syndication]"}
    }    
    {mail_service:boolean(radio)
        {label "#chat.mail_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.receive_mails]"}
    }
    {frequency2:text(select),optional	
        {label "#chat.frequency_mail#" }
        {options {{"daily" dayly} {"monthly" monthly} {"weekly" weekly}}}        
        {help_text "[_ chat.frequency_mail_description]"} 
    }
} -after_submit {
		
		set community_id [dotlrn_community::get_community_id]
		set context_id [ad_conn package_id]
		set creation_ip [ad_conn peeraddr]
		set package_id [ad_conn package_id]
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
			-frequency_mail $frequency2 \
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
			-frequency_mail $frequency2 \
                	$room_id $alias $user_id]} errmsg]} {
                	
        		ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        		break
    			}
    }
    
    if { $mail_service eq "t"} {  
   		if { $frequency2 eq "dayly" } {
   				ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 00 29] chat_send_mails $room_id $community_id $user_id $package_id
   		}
   		if { $frequency2 eq "weekly" } {
   				ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 15 16] chat_send_mails $room_id $community_id $user_id $package_id
   		}
   		if { $frequency2 eq "monthly" } {
   				set week 1
   				ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 15 18] chat_send_mails_monthly $room_id $community_id $user_id $package_id $week
   		}
   	}	
    
    		ad_returnredirect $action
                ad_script_abort
} -new_data {	          
} -edit_request {
}