# /chat/tcl/chat-procs.tcl
ad_library {
    TCL Library for the chat system v.4

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
    
}

namespace eval chat::rss {}

ad_proc -private chat_start_server {} { Start Java chat server. } {

    if {[nsv_get chat server_started]} {
        return
    }
    ns_log notice "chat_start_server: Starting chat server"
    set port [ad_parameter ServerPort]
    set path "ns/server/[ns_info server]/module/nssock"
    set host_location "[ns_config $path Address]"

    exec java -classpath [acs_root_dir]/packages/chat/java adChatServer start $port &

    set done 0

    # Wait until chat server started before spawning new threads connecting to the server.
    while { $done == 0} {
        if [catch {set fds [ns_sockopen -nonblock $host_location $port]} errmsg] {
            set done 0
        } else {
            set done 1
        }
    }

    # Free up resources.
    set r [lindex $fds 0]
    set w [lindex $fds 1]

    close $r
    close $w
    ns_thread begindetached "chat_broadcast_to_applets $host_location $port"
    ns_thread begindetached "chat_receive_from_server $host_location $port"

    ns_log notice "chat_start_server: Chat server started."
    nsv_set chat server_started 1
}

ad_proc -private chat_broadcast_to_applets {host port} { Broadcast chat message from HTML client to Java server. } {

    # Chat server must already started otherwise error will occur.
    set fds [ns_sockopen -nonblock $host $port]

    set r [lindex $fds 0]
    set w [lindex $fds 1]

    ns_log Notice "chat_broadcast_to_applets: Ready to broadcast message to applets."
    ns_log Notice $host
    ns_log Notice $port

    # Register to java chat server.
    puts $w "<login><user_id>-1</user_id><user_name>AOL_WRITER</user_name><pw>T</pw><room_id>-1</room_id></login>"
    flush $w

    while { 1 } {
        # Wait until there is new message in queue.
        ns_mutex lock [nsv_get chat new_message]
        if {[nsv_exists chat html_message]} {
            # Get message from queue.
            puts $w [nsv_get chat html_message]
            flush $w
        }
    }
}


ad_proc -private chat_receive_from_server {host port} { Receive messages from Java clients. } {

    set fds [ns_sockopen -nonblock $host $port]

    set r [lindex $fds 0]
    set w [lindex $fds 1]
    set r_fd [list $r]

    ns_log Notice "chat_receive_from_server: Listening for messages from applets."

    puts $w "<login><user_id>-1</user_id><user_name>AOL_READER</user_name><pw>T</pw><room_id>-1</room_id></login>"
    flush $w

    set running 1

    while { $running } {
        set sel [ns_sockselect $r_fd {} {}]
        set rfds [lindex $sel 0]

        foreach r $rfds {

            if {[ns_sockcheck $r] && [set line [string trim [gets $r]]] != ""} {
                
                regexp "<room_id>(.*)</room_id>" $line match room_id
                regexp "<from>(.*)</from>" $line match screen_name
                regexp "<body>(.*)</body>" $line match msg
                regexp "<from_user_id>(.*)</from_user_id>" $line match user_id
                if {![nsv_exists chat_room $room_id]} {
                    nsv_set chat_room $room_id {}                   
                }

                ns_log Notice "YY Nachricht: $msg"
                ::chat::Chat c1 -volatile -chat_id $room_id -user_id $user_id -session_id 0
                switch $msg {
                    "/enter" {
                        c1 login
                        set msg [_ xotcl-core.has_entered_the_room]
                    }
                    "/leave" {
                        c1 logout
                        set msg [_ xotcl-core.has_left_the_room]
                    }
                    default {
                c1 add_msg -uid $user_id $msg
                    }
                }

                chat_room_get -room_id $room_id -array room_info
                if { $room_info(archive_p) eq "t" } { 
                    if {[catch {chat_post_message_to_db -creation_user $user_id $room_id $msg} errmsg]} {
                        ns_log error "chat_post_message_to_db: error: $errmsg"
                    }
                }

                nsv_lappend chat_room $room_id $line

            } else {
                set running 0
            }
        }
    }
}

ad_proc -private chat_post_message_to_db {
    {-creation_user ""}
    {-creation_ip ""}
    room_id
    msg
} {
    Log chat message to the database.
} {
   
    db_exec_plsql post_message {}

}
ad_proc -public chat_room_new {    
    {-alias ""}    
    {-key_words ""}
    {-maxP ""}
    {-end_date ""}
    {-Rss_service ""}
    {-frequency1 ""}
    {-frequency2 ""}
    {-Mail_service ""}
    {-moderated_p ""}
    {-active_p ""}
    {-archive_p ""}
    {-auto_flush_p ""}
    {-auto_transcript_p ""}
    {-context_id ""}    
    {-comm_name ""}
    {-creation_user ""}
    {-creation_ip ""}
    description
    pretty_name
} {
    Create new chat room. Return room_id if successful else raise error.
} {

    
    db_transaction {
        set room_id [db_exec_plsql create_room {}]
    }

    db_exec_plsql grant_permission {}
    
    for {set i 0} {$i < [llength $key_words]} {incr i 1} {
    	set word [lindex $key_words $i]
	
    	db_exec_plsql insert_keywords { }
    }
    
    

    return $room_id
}

ad_proc -public chat_room_private_new {    
    {-alias ""}    
    {-key_words ""}
    {-maxP ""}
    {-end_date ""}
    {-Rss_service ""}
    {-Mail_service ""}
    {-moderated_p ""}
    {-active_p ""}
    {-archive_p ""}
    {-auto_flush_p ""}
    {-auto_transcript_p ""}
    {-context_id ""}    
    {-comm_name ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-private ""}
    description
    pretty_name
} {
    Create new chat room. Return room_id if successful else raise error.
} {

    db_transaction {
        set room_id [db_exec_plsql create_private_room {}]
    }

    

    return $room_id
}

ad_proc -public chat_room_edit {
    {-alias ""}
    {-key_words ""}
    {-maxP ""}
    {-end_date ""}
    {-Rss_service ""}
    {-frequency1 ""}
    {-frequency_mail ""}
    {-Mail_service ""}
    {-moderated_p ""}
    {-active_p ""}
    {-archive_p ""}
    {-user_id ""}
    {-room_id ""}
    description
    pretty_name
} {
    Edit information on chat room. All information require.
} {

  for {set i 0} {$i < [llength $key_words]} {incr i 1} {  
    	set word [lindex $key_words $i]
	
	db_1row room_info {
		select count(ck.room_id) as words
		from chat_keywords ck
		where ck.room_id = :room_id
		and ck.keyword = :word
	} 
	if {  $words eq 0 } {
    		db_exec_plsql insert_keywords { }
    	}
    }
        
  db_exec_plsql edit_room {}
  
  
  #A professor who creates a rooom will be able to admin it.
	db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 	}
 	if { $counter2 > 0} {
 		return 0 	 		
	} else {	
		set context_id [ad_conn package_id]
		set creation_ip [ad_conn peeraddr]
		db_exec_plsql edit_room_admin {}
		return 0
	}  
  
   
}

ad_proc -public chat_room_delete {
    room_id
} {
    Delete chat room.
} {
    db_exec_plsql delete_room {}
}

ad_proc -public chat_room_message_delete {
    room_id
} {
    Delete all message in the room.
} {
    db_exec_plsql delete_message {}
}

ad_proc -public chat_message_count {
    room_id
} {
    Get message count in the room.
} {

    return [db_exec_plsql message_count {}]
}



ad_proc -public room_active_status {
    room_id
} {
    Get room active status.
} {

    return [db_string get_active { select active_p from chat_rooms where room_id =  :room_id}]

}

ad_proc -public chat_room_name {
    room_id
} {
    Get chat room name.
} {
    return [db_string get_room_name {} -default "" ]

}

ad_proc -public chat_moderator_grant {
    room_id
    party_id
} {
    Grant party a chat moderate privilege to this chat room.
} {
    db_exec_plsql grant_moderator {}
}

ad_proc -public chat_moderator_revoke {
    room_id
    party_id
} {
    Revoke party a chat moderate privilege to this chat room.
} {

    db_exec_plsql revoke_moderator {}

}

ad_proc -public chat_user_grant {
    room_id
    party_id
} {
    Grant party a chat privilege to this chat room.
} {
    db_transaction {
        db_exec_plsql grant_user {}
    }
}


ad_proc -public chat_user_revoke {
    room_id
    party_id
} {
    Revoke party a chat privilege to this chat room.
} {
    db_transaction {
        db_exec_plsql revoke_user {}
    }
}

ad_proc -public chat_user_ban {
    room_id
    party_id
} {
    Explicit ban user from this chat room.
} {
    util_memoize_flush  \
	"permission::permission_p_not_cached -party_id $party_id -object_id $room_id -privilege chat_ban"
    db_exec_plsql ban_user {}
}


ad_proc -public chat_user_unban {
    room_id
    party_id
} {
    unban user from this chat room.
} {
    util_memoize_flush  \
	"permission::permission_p_not_cached -party_id $party_id -object_id $room_id -privilege chat_ban"
    db_exec_plsql ban_user {}
}

ad_proc -public chat_revoke_moderators {
    room_id
    revoke_list
} {
    Revoke a list of parties of a moderate privilege from this room.
} {
    foreach party_id $revoke_list {
        db_dml revoke_moderate {
            begin
                acs_persmission.revoke_permission(:room_id, :party_id, 'chat_moderate_room');
            end
        }
    }

}

ad_proc -public chat_room_moderate_p {
    room_id
} {
    Return the moderate status of this chat room.
} {
    set moderate_p [db_string get_chat_room_moderate {
        select moderated_p
        from chat_rooms
        where room_id = :room_id
    }]

    return $moderate_p

}

ad_proc -public chat_user_name {
    user_id
} {
    Return display name of this user to use in chat.
} {
	acs_user::get -user_id $user_id -array user
	
	
	set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]
	
    return $name

}

ad_proc -public chat_message_post {
    room_id
    user_id
    message
    moderator_p
} {
    Post message to the chat room and broadcast to all applet clients. Used by ajax + html.
} {
    if {$moderator_p == "1" } {
        set status "approved"
    } else {
        set status "pending"
    }

	set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]

	if {$default_client eq "java"} {
		set chat_msg "<message><from>[chat_user_name $user_id]</from><from_user_id>$user_id</from_user_id><room_id>$room_id</room_id><body>$message</body><status>$status</status></message>"
		# Add message to queue. Notify thread responsible for 
		# broadcast message to applets.
		nsv_set chat html_message $chat_msg
		ns_mutex unlock [nsv_get chat new_message]  
	}
    
        # do not write messages to the database if the room should not be archived
        chat_room_get -room_id $room_id -array room_info
        if { $room_info(archive_p) eq "f" } { return }
        
        # write message to the database
        if {[catch {chat_post_message_to_db -creation_user $user_id $room_id $message} errmsg]} {
            ns_log error "chat_post_message_to_db: error: $errmsg"
        }
}




ad_proc -public chat_moderate_message_post {
    room_id
    user_id
    message
} {
    Post moderate message to the chat room and broadcast to all applet clients. Only use by HTML client.
} {
    set chat_msg "<message><from>[chat_user_name2 $user_id $alias]</from><from_user_id>$user_id</from_user_id><room_id>$room_id</room_id><body>$message</body><status>pending</status></message>"

    # Add message to queue. Notify thread responsible for broadcast message to applets.
    nsv_set chat html_message $chat_msg
    ns_mutex unlock [nsv_get chat new_message]
}

ad_proc -public chat_message_retrieve {
    msgs
    room_id
    user_id
} {
    Retrieve all messages from the chat room starting from first_msg_id. Return messages are store in multirow format.
} {

    ns_log debug "chat_message_retrieve: starting message retrieve"

    # The first time html client enter chat room, chat_room variable is not initialize correctly.
    # Therefore I just hard code the variable.
    if {![nsv_exists chat_room $room_id]} {
        nsv_set chat_room $room_id [list "<message><from>[chat_user_name $user_id]</from><room_id>$room_id</room_id><body>[_ chat.has_entered_the_room]</body><status>approved</status></message>"]
    }

    set user_name [chat_user_name $user_id]

     upvar "$msgs:rowcount" counter

    set chat_messages [nsv_get chat_room $room_id]

    set count [llength $chat_messages]

    set cnt $count
    set counter 0

    #foreach msg $chat_messages 
    for { set i [expr {$cnt - 1}] } { $i >= 0 } { set i [expr {$i - 1}] } {
        set msg [lindex $chat_messages $i]
        regexp "<from>(.*)</from>" $msg match screen_name
        regexp "<body>(.*)</body>" $msg match chat_msg
        regexp "<status>(.*)</status>" $msg match status


        if {$status eq "pending" || $status eq "rejected"} {
            continue;
        }

        upvar "$msgs:[expr {$counter + 1}]" array_val

        set array_val(screen_name) $screen_name
        set array_val(chat_msg) $chat_msg
        incr counter
        set array_val(rownum) $counter

        if {$screen_name == $user_name && $chat_msg eq "has entered the room."} {
            return
        }
    }

}


ad_proc -public chat_transcript_new {
    {-description ""}
    {-context_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-keywords ""}
    pretty_name
    contents
    room_id
} {
    Create chat transcript.
} {

    db_transaction {
        set transcript_id [db_exec_plsql create_transcript {}]
	if { $transcript_id ne 0 } {
	    db_dml update_contents {}
	    db_exec_plsql grant_permission {}
	}
    }

    return $transcript_id

}

ad_proc -public chat_transcript_delete {
    transcript_id
} {
    Delete chat transcript.
} {
    db_exec_plsql delete_transcript {}
}

ad_proc -public chat_transcript_edit {
    transcript_id
    pretty_name
    description
    contents    
} {
    Edit chat transcript.
} {
    db_exec_plsql edit_transcript {}
    db_dml update_contents {}
}

ad_proc -public chat_transcript_edit_keywords {
    transcript_id
    keywords    
} {
    Edit chat transcript.
} {    	
	for {set i 0} {$i < [llength $keywords]} {incr i 1} {
	    	set word [lindex $keywords $i]
		
		db_1row select_keywords {select count(ck.keyword) as ckey from chat_room_transcript_keywords ck where ck.transcript_id = :transcript_id and ck.keyword = :word}
		if { $ckey > 0 } {
		} else {
			db_exec_plsql store_transcripts_keywords {}
		}    		
	}
	
        
}

ad_proc -public chat_room_get {
    {-room_id {}}
    {-array:required}
} {
    Get all the information about a chat room into an array
} {
    upvar $array row
    array set row [util_memoize [list chat_room_get_not_cached $room_id]]
}

ad_proc -private chat_room_get_not_cached { 
    room_id
} {
    db_1row select_user_info {select * from chat_rooms where room_id = :room_id} -column_array row
    return [array get row]    
}

ad_proc -private chat_flush_rooms {} {Flush the messages in all of the chat rooms} {
    
    set room_ids [db_list get_rooms *SQL*] 
    foreach room_id $room_ids {
        chat_room_flush $room_id
    }
} 
  

ad_proc -private chat_room_flush { room_id } {Flush the messages a single chat room} {
    
    db_transaction {
        array set room_info [chat_room_get_not_cached $room_id]
        set contents ""
        # do we have to create a transcript for the room
        if { $room_info(auto_transcript_p) eq "t" } {               
        		set time [clock format [expr [clock seconds]-86400] -format "%D"]
            		# build a list of all messages
            		db_foreach get_archives_messages {} {
            		
            		if { $creation_user eq "-1" } {
				append contents "\[$creation_date\] <b>System</b>: $msg<br>\n"
			} else {
            			db_1row room_info2 {
    					select count(r.alias)
    					from chat_registered_users r
    					where r.user_id = :creation_user
    					and r.room_id = :room_id
				}

				if { $count > 0} {
					db_1row room_info2 {
    						select r.alias
    						from chat_registered_users r
    						where r.user_id = :creation_user
    						and r.room_id = :room_id
					}
					append contents "\[$creation_date\] <b>[chat_user_name2 $creation_user $alias]</b>: $msg<br>\n"
				} else {
	    				append contents "\[$creation_date\] <b>[chat_user_name $creation_user]</b>: $msg<br>\n"
				}
            		}
                	#append contents "\[$creation_date\] <b>[chat_user_name $creation_user]</b>: $msg<br>\n"
            		}
            		   
            if { $contents ne "" } {
            	
                set transcript_id [chat_transcript_new \
                    -description "#chat.automatically_created_transcript#" \
                    "#chat.transcript_of_date# [clock format [clock seconds] -format "%d.%m.%Y"]" $contents $room_id]
                set time [clock format [expr [clock seconds]-86400] -format "%D"]    
                db_foreach get_files_sent {} {
                		set ft [store_sent_files_tanscript $transcript_id $f_id]
                }
                
                db_foreach partitipants_transcript "select distinct msg.creation_user as msg_creator
     						from chat_msgs as msg
     						where msg.room_id = :room_id and creation_date >= :time and msg.creation_user>-1" {
	
								#append de los participantes
		
								db_1row room_info {
  							select count(r.alias) as count
  							from chat_registered_users r
  							where r.room_id = :room_id
  							and r.user_id = :msg_creator
  							}
    	
  							if { $count > 0 } {
  								db_1row room_info {
  									select r.alias as partitipant
  									from chat_registered_users r
  									where r.room_id = :room_id
  									and r.user_id = :msg_creator
  								}
  							} else {
  								db_1row room_info {
  									select p.first_names as first_names, p.last_name as last_name
  									from persons p
  									where p.person_id = :msg_creator
  								}
  								append msg_creator1 $first_names " "
  								append partitipant $msg_creator1 $last_name
  							}    		
    				
  							set pt [store_partitipants_transcript $transcript_id $partitipant]  		
		
								
								} if_no_rows {
								
								}
            }
       }     
         # clear all the messages in the room
        #chat_room_message_delete $room_id
    }
}

ad_proc -public chat_registered_user {     
    {-RSS_service ""}
    {-mail_service ""}
    {-context_id ""}
    {-creation_ip ""}
    {-frequency_mail ""}
    room_id   
    alias    
    user_id
} {
    A user is regitered in a chat room.
} {

    db_transaction {
    	set registered_id [db_exec_plsql register {}]
    }  

    return $registered_id
}

ad_proc -public chat_send_mails {    
    room_id
    community_id
    user_id
    package_id
    frequency
} {
    Send mails to the registered users with the brief of the chat room conversation
} {
    
     db_1row info {
	select r.frequency_mail,
        to_char(r.registered_date, 'YYYY-MM-DD HH24:MI:SS') as registered_date
	from chat_registered_users r
	where r.room_id = :room_id
	 and r.user_id = :user_id
    }

     set entry_date_ansi [lc_time_tz_convert -from [lang::system::timezone] -to "Etc/GMT" -time_value $registered_date]
     set entry_timestamp [clock scan $entry_date_ansi]
    
    switch $frequency_mail {
	"dayly" {
	    set mail_time [expr [clock seconds]-86400]
	
	}
	"weekly" {
	    set mail_time [expr [clock seconds]-604800]
	}
	"monthly" {
	    set mail_time [expr [clock seconds]-2592000] 
	}
    }
     
     if { !($mail_time eq $entry_timestamp) } {
	 # the mail does not have to be sent
	 return
     }

     set sende_first_names ""
     set sender_last_name ""
     set sender_email ""
    db_foreach room_info "select user_id as user_id from chat_registered_users where chat_registered_users.room_id = :room_id" {
    
    	  set sender_id $user_id
    	  db_1row select_sender_info {
    
    		select parties.email as sender_email,
                   persons.first_names as sender_first_names,
                   persons.last_name as sender_last_name
          	  from parties,persons
          	  where parties.party_id = :sender_id
            	and persons.person_id = :sender_id    
    	  }
    	  
    	  db_1row query {    		
    		select parties.email as email
               from dotlrn_member_rels_full,parties
               where dotlrn_member_rels_full.community_id = :community_id
               and parties.party_id = dotlrn_member_rels_full.user_id
               and parties.party_id = :user_id
    	  }
    	  
   
    	  
    	
   	 
   	 set from $sender_email
   	 
   	
   	 if { $community_id eq "" } {
   	 	set community_name "All Dotlrn communities"
   	 	set community_url "Dotlrn"
   	 	set safe_community_name [db_quote $community_name]
  		append who_will_receive_this_clause [db_map recipients_clause]
  	  	set query [db_map sender_info]
 	   	
    	} else {
    		set community_name [dotlrn_community::get_community_name_not_cached $community_id]
    		set community_url "[ad_parameter -package_id [ad_acs_kernel_id] SystemURL][dotlrn_community::get_community_url $community_id]"
    		set safe_community_name [db_quote $community_name]
    		append who_will_receive_this_clause [db_map recipients_clause]
    		
    		set query [db_map sender_info4]
    		
    	}   
     
    
    	set send_date [template::util::date::now_min_interval]    
    
    	db_1row room_info {
    		select r.pretty_name as name,r.comm_name as comm_name,r.description as description,p.first_names as first_names, p.last_name as last_name
    		from chat_rooms as r, persons as p
    		where r.room_id = :room_id
    		and p.person_id = r.creator	    		    		
    	} 
    	db_1row room_info2 { select count(fs.title) as count
    		from chat_rooms as r, chat_rooms_files_sent as fs
    		where r.room_id = :room_id
    		and r.room_id = fs.room_id }
    	
    	if { $count > 0 } {
    		db_1row room_info2 { select fs.title as file_name, fs.description as fdescription,fs.creation_user as sender
    			from chat_rooms as r, chat_rooms_files_sent as fs
    			where r.room_id = :room_id
    			and r.room_id = fs.room_id }
    			db_0or1row sf2 {
    					select p.first_names as sender_first_names, p.last_name as sender_last_name
    					from persons p
    					where p.person_id = :sender
    				}
    				append sender_name1 $sender_first_names " "
    				append sender_name $sender_name1 $sender_last_name   			
												
    	 }
    	set partitipants ""
    	
    	db_foreach rss_partitipants "select distinct  persons.first_names as first_names, persons.last_name as last_name
        	from chat_msgs as msg,persons
        	where msg.room_id = :room_id
        	and msg.creation_user = persons.person_id" {
		#append de los participantes
		append partitipants $first_names " "
		append partitipants $last_name " "
		append partitipants " |" " "
		
	} if_no_rows {
		
		set partitipants "There are not partitipants"
	}


	if { [string index $partitipants [expr [string length $partitipants]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $partitipants]-3]
		
		set partitipants [string range $partitipants $inicio $final]
		
	}
	
	set registered_users ""
        db_foreach rss_registered "select distinct registered.alias as users
        	from chat_registered_users as registered
        	where registered.room_id = :room_id" {
		#append de los participantes
		append registered_users $users " | "
	} if_no_rows {
		
		set registered_users "There are not registered users"
	}	
    	
    	

	if { [string index $registered_users [expr [string length $registered_users]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $registered_users]-3]
		set registered_users [string range $registered_users $inicio $final]
		
	}
	
	set keywords ""
	db_foreach keywords "select k.keyword as key from chat_keywords as k
    		where k.room_id = :room_id" {
			#append de las keywords 
			append keywords $key " | "
	} if_no_rows {
			
			set keywords "There are not keywords"
	}
	if { [string index $keywords [expr [string length $keywords]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $keywords]-3]
		set keysw [string range $keywords $inicio $final]		
	}
    	
    	set subject "$name conversations brief"
    	if { $count > 0 } {
    		set message "This is a brief of the conversations during the $frequency: \r\n\r\n Room name --> $name \r\n\r\n Community name --> $comm_name \r\n\r\n Description --> $description \r\n\r\n Creator --> $first_names $last_name \r\n\r\n Keywords --> $keysw \r\n\r\n Partitipants --> $partitipants \r\n\r\n Registered users --> $registered_users \r\n\r\n File Title--> $file_name \r\n\r\n File description --> $fdescription \r\n\r\n File sender --> $sender_name"
    	} else {
    		set message "This is a brief of the conversations during the $frequency: \r\n\r\n Room name --> $name \r\n\r\n Community name --> $comm_name \r\n\r\n Description --> $description \r\n\r\n Creator --> $first_names $last_name \r\n\r\n Keywords --> $keysw \r\n\r\n Partitipants --> $partitipants \r\n\r\n Registered users --> $registered_users \r\n\r\n File Title-->  "
    	}
    	set message_type "text"    
    
    	bulk_mail::new \
        	-package_id $package_id \
        	-send_date [template::util::date::get_property linear_date $send_date] \
        	-date_format "YYYY MM DD HH24 MI SS" \
        	-from_addr $from \
        	-subject "\[$community_name\] $subject" \
        	-message $message \
        	-message_type $message_type \
        	-query $query \
        } if_no_rows {
        	
        }
        
}

ad_proc -public chat_send_mails_monthly {    
    room_id
    community_id
    user_id
    package_id
    week
    frequency
} {
    Send mails to the registered users with the brief of the chat room conversation
} {
     if { $week eq "4"} {    	
     
     
     
     set sende_first_names ""
     set sender_last_name ""
     set sender_email ""
    db_foreach room_info "select user_id as user_id from chat_registered_users where chat_registered_users.room_id = :room_id" {
    
    	  set sender_id $user_id
    	 
    	  db_1row select_sender_info {
    
    		select parties.email as sender_email,
                   persons.first_names as sender_first_names,
                   persons.last_name as sender_last_name
          	  from parties,persons
          	  where parties.party_id = :sender_id
            	and persons.person_id = :sender_id    
    	  }
    	  
    	  db_1row query {    		
    		select parties.email as email
               from dotlrn_member_rels_full,parties
               where dotlrn_member_rels_full.community_id = :community_id
               and parties.party_id = dotlrn_member_rels_full.user_id
               and parties.party_id = :user_id
    	  }
    	  
   
   	 
   	 set from $sender_email
   	 
   	
   	 if { $community_id eq "" } {
   	 	set community_name "All Dotlrn communities"
   	 	set community_url "Dotlrn"
   	 	set safe_community_name [db_quote $community_name]
  		append who_will_receive_this_clause [db_map recipients_clause]
  	  	set query [db_map sender_info]
 	   	
    	} else {
    		set community_name [dotlrn_community::get_community_name_not_cached $community_id]
    		set community_url "[ad_parameter -package_id [ad_acs_kernel_id] SystemURL][dotlrn_community::get_community_url $community_id]"
    		set safe_community_name [db_quote $community_name]
    		append who_will_receive_this_clause [db_map recipients_clause]
    		
    		set query [db_map sender_info4]
    		
    	}   
     
    
    	set send_date [template::util::date::now_min_interval]    
    
    	db_1row room_info {
    		select r.pretty_name as name,r.comm_name as comm_name,r.description as description,p.first_names as first_names, p.last_name as last_name
    		from chat_rooms as r, persons as p
    		where r.room_id = :room_id
    		and p.person_id = r.creator	    		    		
    	} 
    	db_1row room_info2 { select count(fs.title) as count
    		from chat_rooms as r, chat_rooms_files_sent as fs
    		where r.room_id = :room_id
    		and r.room_id = fs.room_id }
    	
    	if { $count > 0 } {
    		db_1row room_info2 { select fs.title as file_name, fs.description as fdescription
    			from chat_rooms as r, chat_rooms_files_sent as fs
    			where r.room_id = :room_id
    			and r.room_id = fs.room_id }
    	 }
    	set partitipants ""
    	
    	db_foreach rss_partitipants "select distinct  persons.first_names as first_names, persons.last_name as last_name
        	from chat_msgs as msg,persons
        	where msg.room_id = :room_id
        	and msg.creation_user = persons.person_id" {
		#append de los participantes
		append partitipants $first_names " "
		append partitipants $last_name " "
		append partitipants " |" " "
		
	} if_no_rows {
		
		set partitipants "There are not partitipants"
	}
	

	if { [string index $partitipants [expr [string length $partitipants]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $partitipants]-3]
		
		set partitipants [string range $partitipants $inicio $final]
		
	}
	
	set registered_users ""
        db_foreach rss_registered "select distinct registered.alias as users
        	from chat_registered_users as registered
        	where registered.room_id = :room_id" {
		#append de los participantes
		append registered_users $users " | "
	} if_no_rows {
		
		set registered_users "There are not registered users"
	}	
    	
    	

	if { [string index $registered_users [expr [string length $registered_users]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $registered_users]-3]
		set registered_users [string range $registered_users $inicio $final]
		#set registered_users [string range 0 [expr [string length $registered_users]-3]]
		
	}
	
	set keywords ""
	db_foreach keywords "select k.keyword as key from chat_keywords as k
    		where k.room_id = :room_id" {
			#append de las keywords 
			append keywords $key " | "
	} if_no_rows {
			
			set keywords "There are not keywords"
	}
	if { [string index $keywords [expr [string length $keywords]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $keywords]-3]
		set registered_users [string range $keywords $inicio $final]
		
	}
    	
    	set subject "$name conversations brief"
    	if { $count > 0 } {
    		set message "This is a brief of the conversations during the $frequency: \r\n\r\n Room name --> $name \r\n\r\n Community name --> $comm_name \r\n\r\n Description --> $description \r\n\r\n Creator --> $first_names $last_name \r\n\r\n Keywords --> $keysw \r\n\r\n Partitipants --> $partitipants \r\n\r\n Registered users --> $registered_users \r\n\r\n File Title--> $file_name \r\n\r\n File description --> $fdescription \r\n\r\n File sender --> $sender_name"
    	} else {
    		set message "This is a brief of the conversations during the $frequency: \r\n\r\n Room name --> $name \r\n\r\n Community name --> $comm_name \r\n\r\n Description --> $description \r\n\r\n Creator --> $first_names $last_name \r\n\r\n Keywords --> $keysw \r\n\r\n Partitipants --> $partitipants \r\n\r\n Registered users --> $registered_users \r\n\r\n File Title-->  "
    	}
    	set message_type "text"    
    
    	bulk_mail::new \
        	-package_id $package_id \
        	-send_date [template::util::date::get_property linear_date $send_date] \
        	-date_format "YYYY MM DD HH24 MI SS" \
        	-from_addr $from \
        	-subject "\[$community_name\] $subject" \
        	-message $message \
        	-message_type $message_type \
        	-query $query \
        } if_no_rows {
        	
        }
        } else {
        	set week [expr $week+1]
        	ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 15 18] chat_send_mails_monthly $room_id $community_id $user_id $package_id $week 
        }
        
}


ad_proc -public chat_message_post2 {
    room_id
    user_id
    alias
    message
    moderator_p
} {
    Post message to the chat room and broadcast to all applet clients. Used by ajax + html.
} {
    if {$moderator_p == "1" } {
        set status "approved"
    } else {
        set status "pending"
    }
    	
	set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]
	if {$default_client eq "java"} {
		set chat_msg "<message><from>[chat_user_name2 $user_id $alias]</from><from_user_id>$user_id</from_user_id><room_id>$room_id</room_id><body>$message</body><status>$status</status></message>"
		# Add message to queue. Notify thread responsible for 
		# broadcast message to applets.
		nsv_set chat html_message $chat_msg
		ns_mutex unlock [nsv_get chat new_message]  
	}
    
        # do not write messages to the database if the room should not be archived
        chat_room_get -room_id $room_id -array room_info
        if { $room_info(archive_p) eq "f" } { return }
        
        # write message to the database
        if {[catch {chat_post_message_to_db -creation_user $user_id $room_id $message} errmsg]} {
            ns_log error "chat_post_message_to_db: error: $errmsg"
        }
}

ad_proc -public chat_user_name2 {
    user_id
    alias
} {
    Return display name of this user to use in chat.
} {
	acs_user::get -user_id $user_id -array user
	set name [expr {$alias ne "" ? $alias : $alias}]
    return $name

}

ad_proc -public chat_room_delete_registered_users {
    room_id
    user_id
} {
    Delete the registered users in a room. 
} {
   db_exec_plsql delete_users {}
}

#pablomp

ad_proc -private send_file {
	chat_id
	file
	title
	description
	date
	context_id
	creation_user
	creation_ip
        send_file_id
} {

	
    	db_exec_plsql send_file {}
    	  
 }


ad_proc -private send_file_message {
	chat_id	
} {

    	db_exec_plsql send_file_message {}
    	 
 }







ad_proc -private chat__rss_datasource {
summary_context_id
} {
    This procedure implements the "datasource" operation of the 
    RssGenerationSubscriber service contract.  

    @author Dave Bauer (dave@thedesignexperience.org) and Pablo Muñoz (pablomp@tid.es)
} {
    
    
    set limit 15
    set items [list]

    db_1row room_info {
    	select r.context_id as package_id
    	from chat_rooms r
    	where r.room_id = :summary_context_id
    }
    
    set package_url [chat_util_get_url $package_id]
    set content "RSS in the chat"
    set column_array(channel_lastBuildDate) ""
    set items ""

    db_foreach get_chat_items {} {
        #set entry_url [export_vars -base "[ad_url]${package_url}chat?[export_vars -url {{room_id $summary_context_id}}]"]
	set entry_url [export_vars -base "[ad_url]${package_url}chat?room_id=$summary_context_id"]
	
        set content_as_text [ad_html_text_convert -from "text/plain" -to text/plain -- $content]
	# for now, support only full content in feed
        set description $content_as_text

        # Always convert timestamp to GMT
        set entry_date_ansi [lc_time_tz_convert -from [lang::system::timezone] -to "Etc/GMT" -time_value $last_modified]
        #set entry_timestamp "[clock format [clock scan $entry_date_ansi] -format "%a, %d %b %Y %H:%M:%S"] GMT"
	set entry_timestamp "[clock format [clock scan $entry_date_ansi] -format "%Y-%m-%d %H:%M:%S"] GMT"
	
	set items [rss_generation $summary_context_id $entry_url $content_as_text $entry_timestamp]
	
	# set the lastbuilddate just once
	expr { [string eq $column_array(channel_lastBuildDate) ""] ? [set column_array(channel_lastBuildDate) $entry_timestamp] : [set column_array(channel_lastBuildDate) ""] }
    }
    set column_array(channel_title) "RSS Chat"
    set column_array(channel_description) "RSS Chat"
    set column_array(items) $items
    set column_array(channel_language) ""
    set column_array(channel_copyright) ""
    set column_array(channel_managingEditor) ""
    set column_array(channel_webMaster) ""
    set column_array(channel_rating) ""
    set column_array(channel_skipDays) ""
    set column_array(channel_skipHours) ""
    set column_array(version) 2.0
    set column_array(image) ""
    set column_array(channel_link) $entry_url
    
    return [array get column_array]
}

ad_proc -private chat::rss::create_rss_gen_subscr_impl {} {
} {
    set spec {
	name "chat_rss"
	aliases {
	    datasource chat__rss_datasource
	    lastUpdated chat_update_rss
	}
        contract_name "RssGenerationSubscriber"
        owner "chat"
    }
    acs_sc::impl::new_from_spec -spec $spec
}

ad_proc chat_util_get_url {
    package_id
} {
    @author Pablo Muñoz
} {

    set url_stub ""

    db_0or1row get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
    "

    return $url_stub

}

ad_proc -private chat_update_rss_monthly {
summary_context_id
week    
} {
    Returns the time that the last chat room was modified,
    in Unix time.  Returns 0 otherwise.

    @author PabloMP (pablomp@tid.es)
} {
		if { $week eq "4" } {
			[chat_update_rss $summary_context_id]
		} else {
        	set week [expr $week+1]
   			  ad_schedule_proc -thread t -schedule_proc ns_schedule_weekly [list 0 15 18] [chat_update_rss_monthly $room_id $week]
    }
    
}


ad_proc -private chat_update_rss {
summary_context_id    
} {
    Returns the time that the last chat room was modified,
    in Unix time.  Returns 0 otherwise.

    @author PabloMP (pablomp@tid.es)
} {

   
    
    set subscr_id [rss_support::get_subscr_id \
                       -summary_context_id $summary_context_id \
                       -impl_name "chat_rss" \
                       -owner "chat"]
                       
    rss_gen_report $subscr_id
    
}







ad_proc rss_generation { room_id entry_url content_as_text entry_timestamp } {
	@author Pablo Muñoz (pablomp@tid.es)
} {
    set msg_creator ""
    set registered_users ""
    set partitipants ""
    set r_creator ""
    
    db_foreach rss_partitipants {
	select distinct room.pretty_name as room_name,room.frequency1, 
	room.creator as room_creator, room.description as room_description, 
	room.end_date as end_date 
	from chat_rooms as room where room.room_id = :room_id 
    } {
	if { ![db_0or1row user_info {
	    select r.alias as r_creator
	    from chat_registered_users r
	    where r.room_id = :room_id
	    and r.user_id = :room_creator
	    limit 1
	}] } {
	    set r_creator [person::name -person_id $room_creator]
	}
	
    }
    
    #regisered users
    set registered_users_list [db_list rss_registered_users {
	select distinct registered.alias as users
	from chat_registered_users as registered
	where registered.room_id = :room_id
    }]
    set registered_users [join $registered_users_list " | "]

# 	# room participants
# 	append registered_users $users " | "
#     #$registered_users
#     if { [string index $registered_users [expr [string length $registered_users]-2]] eq "|" } {
# 	set inicio 0
# 	set final [expr [string length $registered_users]-4]
# 	set registered_users [string range $registered_users $inicio $final]
	
#     }
    
    #comm_name 
    
    db_1row room_info {
	select r.comm_name as comm_name
	from chat_rooms r, persons p
	where r.room_id = :room_id
	and p.person_id = r.creator	    		    		
    }  
    
    #Store the values of the new rss in the data base

    set rss_id [rss_db $room_name $room_description $end_date $r_creator $comm_name $registered_users $entry_timestamp]
    
    db_1row frequency {
	select r.frequency1
	from chat_rooms r
	where r.room_id = :room_id	    		    		
    }
    
    switch $frequency1 {
	"dayly" {
	    set rss_time [clock format [expr [clock scan $entry_timestamp -gmt "true"]-86400] -format "%D"]
	}
	"weekly" {
	    set rss_time [clock format [expr [clock scan $entry_timestamp -gmt "true"]-604800] -format "%D"]  
	}
	"monthly" {
	    set rss_time [clock format [expr [clock scan $entry_timestamp -gmt "true"]-2592000] -format "%D"] 
	}
    }
    
    #partitipants  	  
    
    db_foreach rss_partitipants "select distinct msg.creation_user as msg_creator
     	from chat_msgs as msg
     	where msg.room_id = :room_id and creation_date >= :rss_time" {
	    
	    #append de los participantes
	    #$msg_creator
	    if { $msg_creator eq "-1" } {
		append partitipant "System" ""
	    } else {
		db_1row room_info {
		    select count(r.alias) as count
		    from chat_registered_users r
		    where r.room_id = :room_id
		    and r.user_id = :msg_creator
		}
		
		if { $count > 0 } {
		    db_1row room_info {
			select r.alias as partitipant
			from chat_registered_users r
			where r.room_id = :room_id
			and r.user_id = :msg_creator
		    }
		} else {
		    db_1row room_info {
			select p.first_names as first_names, p.last_name as last_name
			from persons p
			where p.person_id = :msg_creator
		    }
		    append msg_creator1 $first_names " "
		    append partitipant $msg_creator1 $last_name
		}    		
	    }
	    
	    set p [store_partitipants_rss $rss_id $partitipant]
	    set partitipant ""  		
	    
	    #append partitipants $creator " | "
	    
	} if_no_rows {
	    
	}
    
    
    db_1row room_info {
	select r.comm_name as comm_name
	from chat_rooms r, persons p
	where r.room_id = :room_id
	and p.person_id = r.creator	    		    		
    }
    
    
    #sent files
    
    db_foreach room_info2 "select fs.send_file_id
   			from chat_rooms_files_sent fs
   			where fs.room_id = :room_id and date >= :rss_time" {   		
			    
			    set s [store_sent_files_rss $rss_id $send_file_id]
   			}
    
    #keywords
    
    set keywords ""
    set keysw ""
    db_foreach keywords "select k.keyword as key from chat_keywords k
    			where k.room_id = :room_id" {
			    #append de las keywords 
			    
			    set k [store_keywords_rss $rss_id $key]
			    
			    #append keywords $key " | "			
			} if_no_rows {
			    
			    set keywords "There are not keywords"
			}
    
    
    db_1row room_info6 { 
	select count(ct.room_id) as count2
	from chat_transcripts ct
	where ct.room_id = :room_id    		 
    }
    set tname ""
    set tdescription ""
    set tdate ""
    
    db_foreach room_info2 "select ct.transcript_id as transcription_id
    			from chat_transcripts ct
    			where ct.room_id = :room_id and date >= :rss_time" {
			    set t [store_transcripts_rss $rss_id $transcription_id]
			}
    
    set rss_data [list]
    
    db_foreach rss_stored "select r.room_name as r_name,r.rss_id,r.creator as r_cre,r.end_date as r_end_date,r.description as r_description,r.comm_name as r_comm_name,r.user_registered as r_user_registered,r.date as entry_timestamp from chat_rss r 	where r.room_name = :room_name
    	and r.creator = :r_creator
    	order by entry_timestamp desc" {
	    
	    
	    set keywords ""
	    set keysw ""
	    db_foreach keywords "select k.key from chat_key_rss k
    				where k.rss_id = :rss_id" {
				    
				    #append de las keywords 
				    append keywords $key " | "
				    
				} if_no_rows {
				    
				    set keywords "There are not keywords"
				}
	    if { [string index $keywords [expr [string length $keywords]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $keywords]-4]
		set keysw [string range $keywords $inicio $final]		
	    }   	
	    
	    set partitipants ""
	    
	    db_foreach partitipants "select p.partitipant as part from chat_partitipants_rss p
    				where p.rss_id = :rss_id" {
				    
				    #append de las keywords 
				    append partitipants $part " | "
				    
				} if_no_rows {
				    
				    set partitipants "There are not partitipants"
				}    	 
	    #set p_pants "There are not partitipants"
	    
	    if { [string index $partitipants [expr [string length $partitipants]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $partitipants]-4]
		set p_pants [string range $partitipants $inicio $final]				
	    } else {
		set p_pants ""
	    }
	    set file ""
	    set file [list]
	    set files ""
	    
	    db_foreach sent_files "select f.file_id as f_id from chat_files_rss f
    				where f.rss_id = :rss_id" {
				    
				    
				    append file $f_id " "					
				    
				    
				} if_no_rows {
				    
				    set f_name ""
				    set f_description ""
				    set f_sender ""
				    set files "f"
				    
				}
	    
	    set f_name_end ""
	    set f_description_end ""    		
	    set f_sender_end ""
	    set sender_name1 ""
	    set sender_name ""
	    
	    if { !($files eq "f") } {
		set sender_name1 " "
		set sender_name ""
		
		
		for {set i 0} {$i < [llength $file]} {incr i 1} {
		    set f_id [lindex $file $i]
		    
		    db_1row sf {
			select fs.title as file_name, fs.description as fdescription, fs.creation_user as sender
			from chat_rooms_files_sent fs
			where fs.send_file_id = :f_id
		    }
		    db_0or1row sf2 {
			select p.first_names as sender_first_names, p.last_name as sender_last_name
			from persons p
			where p.person_id = :sender
		    }
		    append sender_name1 $sender_first_names " "
		    append sender_name $sender_name1 $sender_last_name    			
		    append f_name $file_name " | "
		    append f_description $fdescription " | "
		    append f_sender $sender_name " | "
		    set sender_name1 ""
		    set sender_name ""	
		}
		
		if { [string index $f_name [expr [string length $f_name]-2]] eq "|" } {
		    set inicio 0
		    set final [expr [string length $f_name]-4]
		    set f_name_end [string range $f_name $inicio $final]
		    
		    set final [expr [string length $f_description]-4]
		    set f_description_end [string range $f_description $inicio $final]
		    
		    set final [expr [string length $f_sender]-4]
		    set f_sender_end [string range $f_sender $inicio $final]
		    set f_sender ""						
		    set sender_name1 ""
		    set sender_name ""	
		}
		
	    }
	    
	    
	    set trans ""
	    set tname ""    		
	    set tdescription ""
	    set tdate ""
	    set tname6 ""
	    set tname5 ""
	    set transcription ""
	    
	    db_foreach transcripts "select t.transcription_id as t_id from chat_transcription_rss t
    				where t.rss_id = :rss_id" {
				    
				    
				    append transcription $t_id " "					
				    
				    
				} if_no_rows {
				    
				    set trans "f"						
				}
	    
	    
	    
	    
	    if { !($trans eq "f") } {
		
		
		for {set i 0} {$i < [llength $transcription]} {incr i 1} {
		    set t_id [lindex $transcription $i]
		    
		    db_1row sf {
			select ct.pretty_name as tname1, ct.description as tdescription1,ct.date as tdate1
			from chat_transcripts ct
			where ct.transcript_id = :t_id								
		    }	
		    if { [string index $tname1 0] eq "#" } { 
			
			set inicio 6
			set final [expr [string length $tname1]-13]
			set tname2 [string range $tname1 $inicio $final]
			set tname3 [string range $tname1 [expr $final+2] [string length $tname1]]
			db_1row room_info2 { 
			    select distinct lm.message as tname4
			    from lang_messages lm
			    where lm.message_key = :tname2
			}
			set tname6 ""
			set tname5 ""
			append tname5 $tname4 " "
			append tname6 $tname5 $tname3
			append tname $tname6 " | "
		    } else {
			append tname $tname1 " | "
		    }
		    set tname1 ""
		    set transcriptname ""
		    
		    if { [string index $tdescription1 0] eq "#" } { 
			
			set inicio 6
			set final [expr [string length $tdescription1]-2]
			set tdescription2 [string range $tdescription1 $inicio $final]
			
			db_1row room_info11 { 
			    select distinct lm.message as tdescription3
			    from lang_messages lm
			    where lm.message_key = :tdescription2
			}
			
			append tdescription $tdescription3 " | "
			
		    } else {
			if { $tdescription eq "" } {
			    append tdescription "No description" " | "
			} else {
			    append tdescription $tdescription1 " | "
			}
		    }
		    set tdescription1 ""
		    
		    
		    
		    
		    append tdate $tdate1 " | "		
		}
	    }
	    set transcriptname ""
	    #le quito la barrita del final
	    if { [string index $tname [expr [string length $tname]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $tname]-4]
		set transcriptname [string range $tname $inicio $final]		
	    }
	    set transcriptdescription ""
	    #le quito la barrita del final
	    if { [string index $tdescription [expr [string length $tdescription]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $tdescription]-4]
		set transcriptdescription [string range $tdescription $inicio $final]		
	    }
	    set transcriptdate ""
	    #le quito la barrita del final
	    if { [string index $tdate [expr [string length $tdate]-2]] eq "|" } {
		set inicio 0
		set final [expr [string length $tdate]-4]
		set transcriptdate [string range $tdate $inicio $final]			
	    }				
	    
	    db_1row room_info2 {
    			select r.context_id as package_id
    			from chat_rooms r
    			where r.room_id = :room_id
    		}
		
    		
		set package_url [chat_util_get_url $package_id]
		set entry_url [export_vars -base "[ad_url]${package_url}chat-transcripts?room_id=$room_id"]
				
		set dat ""
		set dat "#chat.transcript_of_date# "
		append dat [clock format [clock seconds] -format %d.%m.%Y]				
				
				
		db_1row room_info2 { 
			select cr.frequency1
    			from chat_rooms cr
    			where cr.room_id = :room_id    						
    	  	}
    	  	if { $frequency1 eq "dayly" } {
			db_1row room_info2 { 
				select count(ct.pretty_name) as trans
    				from chat_transcripts ct
    				where ct.pretty_name = :dat
    				and ct.room_id = :room_id
   	  		}      
    	  		if { $trans > 0 } {
    	  			db_1row room_info2 { 
					select ct.transcript_id
    					from chat_transcripts ct
    					where ct.pretty_name = :dat
    					and ct.room_id = :room_id
    	  			}
    	  			set entry_url [export_vars -base "[ad_url]${package_url}chat-transcript?room_id=$room_id&transcript_id=$transcript_id"]
    	  		}
		}			
	    
	    
	    
	    
	    
	    set rss_data_stored1 	[list 	\
					     link $entry_url \
					     title "$room_name $entry_timestamp" \
					     description "<p><b>[_ chat.Description]:</b> $r_description </p> <p> <b>[_ chat.room_creator]:</b> $r_cre  </p> <p> <b>[_ chat.comm_name]:</b> $r_comm_name </p> <p> <b> [_ chat.reg_users]:</b> $r_user_registered </p> <b>[_ chat.k_words]:</b> $keysw </p> <p> <b> [_ chat.partitipants]:</b> $p_pants </p> <b>[_ chat.files_sent]:</b> <p> <BLOCKQUOTE> <b> [_ chat.name]: </b> $f_name_end </p> <p> <BLOCKQUOTE> <b> [_ chat.Description]: </b> $f_description_end </p> <p> <BLOCKQUOTE> <b> [_ chat.sender]: </b> $f_sender_end </p> <p> <b>[_ chat.transcripton]:</b> <p> <BLOCKQUOTE> <b>[_ chat.name]:</b> $transcriptname </p> <p> <BLOCKQUOTE> <b>[_ chat.Description]:</b> $transcriptdescription </p> <p> <BLOCKQUOTE> <b>[_ chat.date_rss2]:</b> $transcriptdate </p> </p>" \
					     value $content_as_text \
					     timestamp $entry_timestamp]		                               
	    lappend rss_data $rss_data_stored1
	    
	    set f_name ""
	    set f_name_end ""
	    set f_description ""
	    set f_description_end ""
	    set f_sender ""
	    set sender_name1 ""
	    set sender_name ""
	    set f_sender_end ""
	    set tname ""
	    set trans ""
	    set tdescription ""
	    set tdate ""
	}	
    
    return $rss_data
    
    #	set rss [rss_creation $room_id $entry_url $content_as_text $entry_timestamp]		
    
    #	return $rss
    
}

# ad_proc rss_creation { room_id entry_url content_as_text entry_timestamp } {
# 	@author Pablo Muñoz (pablomp@tid.es)
# } {
# }

ad_proc rss_db { 
	room_name
	room_description
	end_date
	r_creator
	comm_name
	registered_users
	entry_timestamp
} {
	db_exec_plsql rss_db {}
	
}

ad_proc store_partitipants_rss { 
	rss_id
	partitipant	
} {
	db_exec_plsql store_partitipants_rss {}
	
} 

ad_proc store_partitipants_transcript { 
	transcript_id
	partitipant	
} {
	db_exec_plsql store_partitipants_transcript {}
	
} 

ad_proc store_sent_files_rss { 
	rss_id
	send_file_id	
} {
	db_exec_plsql store_sent_files_rss {}
	
}

ad_proc store_sent_files_tanscript { 
	transcript_id
	f_id	
} {
	db_exec_plsql store_sent_files_tanscript {}
	
}  

ad_proc store_keywords_rss { 
	rss_id
	key
} {
	db_exec_plsql store_keywords_rss {}
	
} 	 	
  	
ad_proc store_transcripts_rss { 
	rss_id
	transcription_id
} {
	db_exec_plsql store_transcripts_rss {}
	
}	
