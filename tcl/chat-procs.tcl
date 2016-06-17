# /chat/tcl/chat-procs.tcl
ad_library {
    TCL Library for the chat system v.4

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
}

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
				if { $room_info(archive_p) == "t" } { 
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
    # ns_log Notice $msg
    db_exec_plsql post_message {}

}
ad_proc -public chat_room_new {
    {-description ""}
    {-moderated_p f}
    {-active_p t}
    {-archive_p f}
    {-auto_flush_p t}
    {-auto_transcript_p f}
    {-context_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    pretty_name

} {
    Create new chat room. Return room_id if successful else raise error.
} {

    db_transaction {
        set room_id [db_exec_plsql create_room {}]
    }

    db_exec_plsql grant_permission {}

    return $room_id
}

ad_proc -public chat_room_edit {
    room_id
    pretty_name
    description
    moderated_p
    active_p
    archive_p
    auto_flush_p
    auto_transcript_p
} {
    Edit information on chat room. All information require.
} {
   db_exec_plsql edit_room {}
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
    if {$moderator_p == 1 } {
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
        if { $room_info(archive_p) == "f" } { return }
        
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
    set chat_msg "<message><from>[chat_user_name $user_id]</from><from_user_id>$user_id</from_user_id><room_id>$room_id</room_id><body>$message</body><status>pending</status></message>"

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
    # ns_log Notice "YY Starting chat_flush_rooms operation"
    set room_ids [db_list get_rooms *SQL*] 
    foreach room_id $room_ids {
        chat_room_flush $room_id
    }
}   

ad_proc -private chat_room_flush { room_id } {Flush the messages a single chat room} {
    # ns_log Notice "YY flushing room $room_id"
    db_transaction {
        array set room_info [chat_room_get_not_cached $room_id]
        set contents ""
        # do we have to create a transcript for the room
        if { $room_info(auto_transcript_p) == "t" } {
            # build a list of all messages
            db_foreach get_archives_messages {} {
                append contents "\[$creation_date\] <b>[chat_user_name $creation_user]</b>: $msg<br>\n"
            }
            if { $contents ne "" } {
                chat_transcript_new \
                    -description "#chat.automatically_created_transcript#" \
                    "#chat.transcript_of_date# [clock format [clock seconds] -format "%d.%m.%Y"]" $contents $room_id
            }
        }
        # clear all the messages in the room
        chat_room_message_delete $room_id
    }
}

