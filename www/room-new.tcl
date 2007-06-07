#/chat/www/room-new.tcl
ad_page_contract {
    Display a form to create a new room.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
   
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
set freq {{"daily"} {"monthly" } {"weekly" }}


ad_form -name "room-entry" -edit_buttons [list [list [_ chat.Create_room] next]] -has_edit 1 -form {
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
    {maxP:text(text)
        {label "#chat.maximal_partitipants#" }
        {help_text "[_ chat.maximal_number_partitipants]"}
    }    
    {end_date:date(date)
        {label "#chat.end_date#" }
        {help_text "[_ chat.end_date_description]"}
    }    
    {Rss_service:boolean(radio)
        {label "#chat.rss_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.rss_syndication]"}
    }
    {frequency1:text(select),optional
        {label "#chat.frequency_rss#" }
        {options {{"dayly" dayly} {"weekly" weekly} {"monthly" monthly}}}
        {help_text "[_ chat.frequency_rss_description]"} 
    }
    {Mail_service:boolean(radio)
        {label "#chat.mail_service#" }
        {options {{"#acs-kernel.common_Yes#" t} {"#acs-kernel.common_no#" f}}}
        {help_text "[_ chat.receive_mails]"}
    }
    {frequency2:text(select),optional	
        {label "#chat.frequency_mail#" }
        {options {{"daily" dayly} {"weekly" weekly} {"monthly" monthly}}}        
        {help_text "[_ chat.frequency_mail_description]"} 
    }
 #   {moderated_p:boolean(radio)
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
	
    # frequency1: rss frequency
    # frequency2: mail frequency
    if {[catch {set room_id [chat_room_new \
				 -alias $alias \
				 -key_words $key_words \
				 -maxP $maxP \
				 -end_date $date \
				 -Rss_service $Rss_service \
				 -frequency1 $frequency1 \
				 -frequency2 $frequency2 \
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
    set sender_id [ad_conn user_id]
    db_1row select_sender_info {
    
    select parties.email as sender_email,
                   persons.first_names as sender_first_names,
                   persons.last_name as sender_last_name
            from parties,
                 persons
            where parties.party_id = :sender_id
            and persons.person_id = :sender_id
    
    }
    set from $sender_email
    set community_id [dotlrn_community::get_community_id]
    if { $community_id eq "" } {
    	set community_name "All Dotlrn communities"
    	set community_url "Dotlrn"
    	set safe_community_name [db_quote $community_name]
  	append who_will_receive_this_clause [db_map recipients_clause]
    	set query [db_map sender_info2]
    	
    } else {
    	set community_name [dotlrn_community::get_community_name_not_cached $community_id]
    	set community_url "[ad_parameter -package_id [ad_acs_kernel_id] SystemURL][dotlrn_community::get_community_url $community_id]"
    	set safe_community_name [db_quote $community_name]
    	append who_will_receive_this_clause [db_map recipients_clause]
    	set query [db_map sender_info]
    }   
     
    
    set send_date [template::util::date::now_min_interval]    
    
      
    set subject "$pretty_name chat room created"
    set message "It has been created a new room, whose name is $pretty_name. It belongs to $community_name community. You can use it to talk about."
    set message_type "text"
    

    set package_id [ad_conn package_id]
    
    db_1row select_sender_info4 {
    	select count(acs.impl_name) as count
    	from acs_sc_impls acs
    	where acs.impl_name = 'chat_rss'
    }
    
   	 set subscr_id [rss_support::add_subscription \
                       -summary_context_id $room_id \
                       -impl_name "chat_rss" \
                       -owner "chat" \
                       -lastbuild "now"]
     	rss_gen_report $subscr_id
         
       
        if { $frequency1 eq "dayly" } {
		ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 01 00] chat_update_rss $room_id
	}
   	if { $frequency1 eq "weekly" } {
   		ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 01 00] chat_update_rss $room_id
   	}
   	if { $frequency1 eq "monthly" } {
   		set week 1
   		ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 01 00] chat_update_rss_monthly $room_id $week
   	}
         
        
 
   	set user_id [ad_conn user_id]
   
   
    if { $Mail_service eq "t"} {  
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
    
    	bulk_mail::new \
       	 -package_id [site_node_apm_integration::get_child_package_id -package_key [bulk_mail::package_key]] \
       	 -send_date [template::util::date::get_property linear_date $send_date] \
      	  -date_format "YYYY MM DD HH24 MI SS" \
      	  -from_addr $from \
      	  -subject "\[$community_name\] $subject" \
      	  -message $message \
      	  -message_type $message_type \
          -query $query \
    
    
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

