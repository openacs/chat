#/chat/www/room-edit.tcl
ad_page_contract {
    Display a form to edit room information.

    @author Peter Alberer (peter@alberer.com) and Pablo Muñoz(pablomp@tid.es)    
} {
    room_id:integer,optional
} 

set user_id [ad_conn user_id]

#A professor who creates a rooom will be able to admin it.
db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
if { $admin_professor eq "t"} {
	
} else {
	permission::require_permission -object_id [ad_conn package_id] -privilege chat_room_edit
}

if { ![info exists room_id] } {
    set title "[_ chat.Create_a_new_room]"
} else {
    set title "[_ chat.Edit_room] \"[chat_room_name $room_id]\""
}

set user_id [ad_conn user_id]


db_1row room_info {
    select rm.room_id,
    rm.pretty_name as pretty_name,
    rm.frequency1,
    rm.description as description,
    rm.moderated_p as moderated,
    rm.maximal_participants as max_p,
    rm.active_p as active_p,
    rm.archive_p as archive_p,
    to_char(rm.end_date,'YYYY-MM-DD HH24:MI:SS') as end_date_ansi, 
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
     and ru.user_id = :user_id) as mail_service,
    (select ru.frequency_mail
     from chat_registered_users ru
     where rm.room_id = ru.room_id
     and ru.user_id = :user_id) as frequency2
    from chat_rooms rm
    where rm.room_id = :room_id
}

set key_words ""
db_foreach room_info "select ck.keyword as key from chat_keywords ck where ck.room_id = :room_id" {
    append key_words $key " "	
}
	
set rss_active $rss_service
set frequency1_rss $frequency1
set end_date [template::util::date::from_ansi $end_date_ansi "YYYY-MM-DD HH24:MI:SS"]
set frequency_active $frequency2

ad_form -name "edit-room" -edit_buttons [list [list [_ chat.Update_room] next]] -has_edit 1 -form {
    {room_id:key} 
    {pretty_name:text(text)
        {label "#chat.Room_name#" }
        {title "Name of the room"}
    }
    {alias:text(text)
        {label "#chat.alias#" }
        {help_text "[_ chat.alias_in_this_room]"}
    }
    {description:text(textarea),optional
        {label "#chat.Description#" }
        {html {rows 6 cols 65}}
    }
    {key_words:text(textarea),optional
        {label "#chat.keywords#" }
        {html {rows 3 cols 25}}
        {help_text "[_ chat.main_words]"}
    }
    {max_p:text(text)
        {label "#chat.maximal_partitipants#" }
        {help_text "[_ chat.maximal_number_partitipants]"}
    }    
    {end_date:date(date)
        {label "#chat.end_date#" }
        {help_text "[_ chat.end_date_description]"}
    }    
    {rss_service:boolean(radio)
        {label "#chat.rss_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.rss_syndication]"}
    }
    {frequency1:text(select),optional
        {label "#chat.frequency_rss#" }
        {options {{"dayly" dayly} {"weekly" weekly} {"monthly" monthly} }}
        {help_text "[_ chat.frequency_rss_description]"} 
    }
    {mail_service:boolean(radio)
        {label "#chat.mail_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.receive_mails]"}
    }
    {frequency2:text(select),optional	
        {label "#chat.frequency_mail#" }
        {options {{"daily" dayly} {"weekly" weekly}  {"monthly" monthly} }}        
        {help_text "[_ chat.frequency_mail_description]"} 
    }
 #   {moderated:boolean(radio)
 #       {label "#chat.Moderated#" }
 #       {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
 #   }
    {active_p:boolean(radio)
        {label "#chat.Active#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }
    {archive_p:boolean(radio)
        {label "#chat.Archive#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }    
#    {auto_flush_p:boolean(radio)
 #       {label "#chat.AutoFlush#" }
  #      {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
   #     {help_text "[_ chat.AutoFlushHelp]"}
 #   }  
 #   {auto_transcript_p:boolean(radio)
 #       {label "#chat.AutoTranscript#" }
  #      {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
   #     {help_text "[_ chat.AutoTranscriptHelp]"}
  #  }
} -edit_request {
    
} -edit_data {
    
}  -after_submit {	
	#$rss_active
	set date [lrange $end_date 0 2]
	set community_id [dotlrn_community::get_community_id]
	if { $community_id eq "" } {
		set comm_id 0
	}
	set package_id [ad_conn package_id]
								
	if {[catch {set room_edit [chat_room_edit \
	                      -alias $alias \
                              -key_words $key_words \
                              -maxP $max_p \
                              -end_date $date \
                              -Rss_service $rss_service \
                              -frequency1 $frequency1 \
			      -frequency_mail $frequency2 \
                              -Mail_service $mail_service \
                              -moderated_p $moderated \
                              -active_p $active_p \
                              -archive_p $archive_p \
                              -user_id [ad_conn user_id] \
                              -room_id $room_id \
                              $description $pretty_name]} errmsg]} {
         
        ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        break
    }
    
	if { $mail_service eq "t" && ![string eq $frequency_active $frequency2]} {  

    		if { $frequency2 eq "dayly" } {
   			ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 01 00] chat_send_mails $room_id $community_id $user_id $package_id "daily"
   		}
   		if { $frequency2 eq "weekly" } {
		    ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 01 00] chat_send_mails $room_id $community_id $user_id $package_id "weekly"
   		}
   		if { $frequency2 eq "monthly" } {
   			set week 1
   			ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 01 00] chat_send_mails_monthly $room_id $community_id $user_id $package_id $week "monthly"
   		}
   }		
      
    if { $rss_service eq "t" } {    		
		if { $rss_active eq "f"} {			
                       		#ad_returnredirect "rss?room_id=$room_id"                	                	
      
			if { $frequency1_rss eq $frequency1} {
			} else {
				 #if the rss exists, only create a thread with the schedule
				 if { [rss_support::subscription_exists \
           			 	-summary_context_id $room_id \
            				-impl_name chat_rss] } {
            
            
           			 	if { $frequency1 eq "dayly" } {
						ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 00 10] [chat_update_rss $room_id]
					 }
   					 if { $frequency1 eq "weekly" } {
   						ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 00 10] [chat_update_rss $room_id]   						
   					 }
   					 if { $frequency1 eq "monthly" } {
   						set week 1
   						ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 00 10] [chat_update_rss_monthly $room_id $week]
   					 }
   				}	 
   		       }           
      		
		}
     }
    ad_returnredirect "room?room_id=$room_id"
    ad_script_abort    
}

