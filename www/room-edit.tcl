#/chat/www/room-edit.tcl
ad_page_contract {
    Display a form to edit room information.

    @author Peter Alberer (peter@alberer.com)
    @creation-date March 26, 2006
} {
    room_id:integer,optional
} 

permission::require_permission -object_id [ad_conn package_id] -privilege chat_room_edit

if { ![info exists room_id] } {
    set title "[_ chat.Create_a_new_room]"
} else {
    set title "[_ chat.Edit_room] \"[chat_room_name $room_id]\""
}

set user_id [ad_conn user_id]


db_1row room_info {
        select rm.room_id,
           rm.pretty_name as pretty_name,
           rm.description as description,
           rm.moderated_p as moderated,
           rm.maximal_participants as max_p,
           rm.active_p as active_p,
           rm.archive_p as archive_p,
           rm.end_date as end_date,    
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


ad_form -name "edit-room" -edit_buttons [list [list [_ chat.Update_room] next]] -has_edit 1 -form {
    {room_id:key} 
    {pretty_name:text(text)
        {label "#chat.Room_name#" }
    }
    {alias:text(text)
    	{label "Alias" }
    	{help_text "Alias in this room"}
    }
    {description:text(textarea),optional
        {label "#chat.Description#" }
        {html {rows 6 cols 65}}
    }
    {key_words:text(textarea),optional
        {label "Key words" }
        {html {rows 3 cols 25}}
        {help_text "Main words of the room, in order to describe it"}

    }
    {end_date:date(date)
        {label "End date (dd/mm/yyyy)" }
        {help_text "From this date the room will be closed"}
    }
    {max_p:text(text)
        {label "Maximal participants"}
        {help_text "Maximal number of participants in this room"}

    }       
    {rss_service:boolean(radio)
        {label "Rss_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "Sindicate into RSS"}     
    }
    {frequency:boolean(select),optional
        {label "frequency" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
        {help_text "Frecuency of RSS service"}            
    }
    {mail_service:boolean(radio)
        {label "Mail_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "Receive brief mails"}    
    }
    {frequency2:boolean(select),optional
        {label "frequency" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
        {help_text "Frecuency of mail service"}            
    }   
    {active_p:boolean(radio)
        {label "#chat.Active#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        
    }
    {archive_p:boolean(radio)
        {label "#chat.Archive#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }
    {moderated:boolean(radio)
        {label "Moderated" }
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
	set date [lrange $end_date 0 2]									
	if {[catch {set room_edit [chat_room_edit \
	                      -alias $alias \
                              -key_words $key_words \
                              -maxP $max_p \
                              -end_date $date \
                              -Rss_service $rss_service \
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
    ad_returnredirect "room?room_id=$room_id"
    ad_script_abort    
}

