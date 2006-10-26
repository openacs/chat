#/chat/www/room-new.tcl
ad_page_contract {
    Display a form to create a new room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 13, 2000
    @cvs-id $Id$
} {
} -properties {
    context_bar:onevalue
    room_id:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    pretty_name:onevalue
    moderated_p:onevalue
}

ad_require_permission [ad_conn package_id] chat_room_create

set context_bar [list "[_ chat.Create_a_room]"]
set title "[_ chat.Create_a_room]"
set action "room-new-2"
set submit_label "[_ chat.Create_room]"
set pretty_name ""
set description ""
set archive_p "t"
set active_p "t"
set moderated_p "f"
set room_id ""
set maxP ""
set minP ""
set end_date ""
set key_words ""
set alias ""
set Rss_service ""
set frequency [list daily monthly weekly] 

ad_form -name "room-entry" -edit_buttons [list [list [_ chat.Create_room] next]] -has_edit 1 -form {
    {pretty_name:text(text)
        {label "#chat.Room_name#" }
        {title "Name of the room"}
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
    {maxP:text(text)
        {label "Maximal participants" }
        {help_text "Maximal number of participants in this room"}
    }    
    {end_date:date(date)
        {label "End date (dd/mm/yyyy)" }
        {help_text "From this date the room will be closed"}
    }    
    {Rss_service:boolean(radio)
        {label "Rss_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "Sindicate into RSS"}        
    }
    {frequency1:boolean(select),optional
        {label "Frequency Rss" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
        {help_text "Frecuency of RSS service"}            
    }
    {Mail_service:boolean(radio)
        {label "Mail_service" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "Receive brief mails"}        
    }
    {frequency2:boolean(select),optional	
        {label "Frequency Mail" }
        {options {{"daily"} {"monthly" } {"weekly" }}}
        {help_text "Frecuency of mail service"}            
    }
    {moderated_p:boolean(radio)
        {label "Moderated" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }
    {active_p:boolean(radio)
        {label "#chat.Active#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }
    {archive_p:boolean(radio)
        {label "#chat.Archive#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    }    
  #  {auto_flush_p:boolean(radio)
  #      {label "#chat.AutoFlush#" }
  #      {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
  #      {help_text "[_ chat.AutoFlushHelp]"}
 #   }  
 #   {auto_transcript_p:boolean(radio)
  #      {label "#chat.AutoTranscript#" }
   #     {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
    #    {help_text "[_ chat.AutoTranscriptHelp]"}
  #  } 
}  -after_submit {
	set date [lrange $end_date 0 2]
	set comm_id [dotlrn_community::get_community_id]
	if { $comm_id eq "" } {
		set comm_id 0
	} else {
		set comm_id [dotlrn_community::get_community_id]
	}						
	if {[catch {set room_id [chat_room_new \
	                      -alias $alias \
                              -key_words $key_words \
                              -maxP $maxP \
                              -end_date $date \
                              -Rss_service $Rss_service \
                              -Mail_service $Mail_service \
                              -moderated_p $moderated_p \
                              -active_p $active_p \
                              -archive_p $archive_p \
                              -auto_flush_p t \
                              -auto_transcript_p t \
                              -context_id [ad_conn package_id] \
                              -comm_id $comm_id \
                              -creation_user [ad_conn user_id] \
                              -creation_ip [ad_conn peeraddr] \
                              $description $pretty_name]} errmsg]} {
        ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        break
    }
    set comm_id ""
    if {[info command dotlrn_community::get_community_id] ne ""} {
      set comm_id [dotlrn_community::get_community_id] 
    }
    if {$comm_id ne ""} {
      chat_user_grant $room_id $comm_id
    } else {
      #-2 Registered Users
      #chat_user_grant $room_id -2 
      #0 Unregistered Visitor
      #chat_user_grant $room_id 0
      #-1 The Public
      chat_user_grant $room_id -2
    }
    ad_returnredirect "room?room_id=$room_id"
    ad_script_abort    
}
ad_return_template "room-entry"

