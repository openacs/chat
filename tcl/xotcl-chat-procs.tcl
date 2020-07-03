::xo::library doc {

    Chat Objects

    @author Antonio Pisano

}

namespace eval ::chat {

    #
    ## Chat Package
    #

    Class create ::chat::Package

    ::chat::Package ad_proc flush_rooms {} {
        Flush every room supposed to be archived and automatically
        flushed. Meant to be executed in a scheduled procedure.
    } {
        foreach room_id [::xo::dc list get_rooms {
            select room_id from chat_rooms
            where archive_p and auto_flush_p
        }] {
            set room [::xo::db::Class get_instance_from_db -id $room_id]
            $room flush
        }
    }

    ::chat::Package ad_proc get_user_name {
        -user_id:required
    } {
        Retrieves the username supposed to be displayed in the chat
        UI: aither the screen name or the person name when the former
        is missing.

        @return a username
    } {
        set name [acs_user::get_user_info -user_id $user_id -element screen_name]
        if {$name eq ""} {
            set name [person::name -person_id $user_id]
        }
        return $name
    }

    #
    ## Chat Room
    #

    ::xo::db::Class create ::xo::db::chat_room \
        -id_column room_id \
        -object_type "chat_room" \
        -table_name "chat_rooms" \
        -pretty_name   "#chat.Room#" \
        -pretty_plural "#chat.Rooms#" \
        -superclass ::xo::db::Object -slots {
            ::xo::db::Attribute create pretty_name \
                -sqltype varchar(100) -not_null true
            ::xo::db::Attribute create description \
                -sqltype varchar(2000)
            ::xo::db::Attribute create moderated_p \
                -datatype boolean -default false
            ::xo::db::Attribute create active_p \
                -datatype boolean -default true
            ::xo::db::Attribute create archive_p \
                -datatype boolean -default true
            ::xo::db::Attribute create auto_flush_p \
                -datatype boolean -default true
            ::xo::db::Attribute create auto_transcript_p \
                -datatype boolean -default false
            ::xo::db::Attribute create login_messages_p \
                -datatype boolean -default true
            ::xo::db::Attribute create logout_messages_p \
                -datatype boolean -default true
            ::xo::db::Attribute create messages_time_window \
                -datatype integer -default 600
            ::xo::db::Attribute create avatar_p \
                -datatype boolean -default true
        }

    ::xo::db::require table chat_msgs {
        msg_id        {integer primary key}
        room_id       {integer references chat_rooms(room_id) on delete cascade}
        msg           {varchar(4000)}
        msg_len       integer
        html_p        {boolean default false}
        approved_p    {boolean default true}
        creation_user {integer references parties(party_id) on delete cascade not null}
        creation_ip   {varchar(50)}
        creation_date {timestamp with timezone}
    }

    ::xo::db::chat_room ad_instproc grant_creator {} {
        Grants operative privileges to the chat creator (when
        available on the chat room object). In detail the permissions
        to edit, view and delete the chat room and also to create
        transcripts of it.
    } {
        if {${:creation_user} ne ""} {
            foreach privilege {edit view delete} {
                permission::grant \
                    -party_id  ${:creation_user} \
                    -object_id ${:room_id} \
                    -privilege chat_room_${privilege}
            }
            permission::grant \
                -party_id  ${:creation_user} \
                -object_id ${:room_id} \
                -privilege chat_transcript_create
        }
    }

    ::xo::db::chat_room ad_instproc grant_user {
        -party_id:required
    } {
        Grants operative privileges to the specified party. In detail,
        the permission to read and write for the chat room.
    } {
        ::xo::dc transaction {
            foreach privilege {read write} {
                permission::grant \
                    -party_id  $party_id \
                    -object_id ${:room_id} \
                    -privilege chat_${privilege}
            }
        }
    }

    ::xo::db::chat_room ad_instproc revoke_user {
        -party_id:required
    } {
        Revokes operative privileges to the specified party. In detail,
        the permission to read and write for the chat room.
    } {
        ::xo::dc transaction {
            foreach privilege {read write} {
                permission::revoke \
                    -party_id  $party_id \
                    -object_id ${:room_id} \
                    -privilege chat_${privilege}
            }
        }
    }

    ::xo::db::chat_room ad_instproc ban_user {
        -party_id:required
    } {
        Bans specified user from the chat room
    } {
        permission::grant \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_ban
    }

    ::xo::db::chat_room ad_instproc unban_user {
        -party_id:required
    } {
        Lift ban on specified user from the chat room
    } {
        permission::revoke \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_ban
    }

    ::xo::db::chat_room ad_instproc grant_moderator {
        -party_id:required
    } {
        Make specified party the chat room moderator
    } {
        permission::grant \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_room_moderate
    }

    ::xo::db::chat_room ad_instproc revoke_moderator {
        -party_id:required
    } {
        Revoke moderation rights on the chat room for specified party
    } {
        set parties $party_id
        foreach party_id $parties {
            permission::revoke \
                -party_id  $party_id \
                -object_id ${:room_id} \
                -privilege chat_room_moderate
        }
    }

    ::xo::db::chat_room ad_instproc save_new {} {
        Create a new chat room and make sure its creator is granted
        the necessary privileges

        @return new chat room id
    } {
        if {![info exists :context_id]} {
            set :context_id ${:package_id}
        }
        ::xo::dc transaction {
            set room_id [next]
            :grant_creator
        }
        return $room_id
    }

    ::xo::db::chat_room ad_instproc delete {} {
        Delete the chat room and all of its transcripts
    } {
        set room_id ${:room_id}
        foreach transcript_id [::xo::dc list get_transcripts {
            select transcript_id from chat_transcripts
            where room_id = :room_id
        }] {
            ::xo::db::sql::acs_object delete \
                -object_id $transcript_id
        }
        next
    }


    ::xo::db::chat_room ad_instproc post_message {
        {-msg ""}
        {-creation_user ""}
        {-creation_ip ""}
    } {
        Post a message in the chat room. This actually means
        persisting the message in the database, but only if the chat
        room is configured to be archived.

        @param msg the message
        @param creation_user the alleged creation user of the
               persisted message. Won't be set automatically from the
               connection
        @param creation_ip the alleged creation IP of the
               persisted message. Won't be set automatically from the
               connection
    } {
        if {!${:archive_p}} {
            return
        }
        set room_id ${:room_id}
        set message_id [db_nextval acs_object_id_seq]
        ::xo::dc dml save_message {
            insert into chat_msgs (
                                   msg_id,
                                   room_id,
                                   msg,
                                   creation_user,
                                   creation_ip,
                                   creation_date)
            values (
                    :message_id,
                    :room_id,
                    :msg,
                    :creation_user,
                    :creation_ip,
                    current_timestamp
                    )
        }
    }

    ::xo::db::chat_room ad_instproc delete_messages {} {
        Delete all persisted messages from the chat room.
    } {
        set room_id ${:room_id}
        ::xo::dc dml delete_messages {
            delete from chat_msgs where room_id = :room_id
        }
    }

    ::xo::db::chat_room ad_instproc count_messages {} {
        Count messages currently persisted for this chat room.
    } {
        set room_id ${:room_id}
        ::xo::dc get_value count_messages {
            select count(*) from chat_msgs
            where room_id = :room_id
        }
    }

    ::xo::db::chat_room ad_instproc flush {} {
        Save all currently persisted messages for this chat room as a
        new transcript and then delete them.
    } {
        if {${:auto_transcript_p}} {
            :create_transcript
        }
        :delete_messages
    }

    ::xo::db::chat_room ad_instproc create_transcript {
        -pretty_name
        -description
        -creation_user
        {-creation_ip ""}
    } {
        Creates a new transcript of all current chat room messages.

        @return transcript_id of the new transcript or 0 when no
                messages were in the chat room.
    } {
        if {![info exists pretty_name]} {
            set today [clock format [clock seconds] -format "%d.%m.%Y"]
            set pretty_name "#chat.transcript_of_date# $today"
        }
        if {![info exists description]} {
            set description "#chat.automatically_created_transcript#"
        }
        if {![info exists creation_user]} {
            set creation_user ${:creation_user}
        }

        set contents [:transcript_messages]
        if {[llength $contents] > 0} {
            set t [::xo::db::chat_transcript new \
                       -creation_user $creation_user \
                       -creation_ip $creation_ip \
                       -pretty_name $pretty_name \
                       -description $description \
                       -package_id ${:package_id} \
                       -room_id ${:room_id} \
                       -contents [join $contents \n]]
            $t save_new
            return [$t set transcript_id]
        } else {
            return 0
        }
    }

    ::xo::db::chat_room ad_instproc transcript_messages {} {
        Formats the current content of a chat room as a list of
        messages formatted so they can be displayed or stored in the
        transcript.

        @return list of formatted messages
    } {
        set room_id ${:room_id}
        set contents [list]
        ::xo::dc foreach get_archives_messages {
            select msg,
            creation_user,
            to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date
            from chat_msgs
            where room_id = :room_id
            and msg is not null
            order by creation_date
        } {
            if {$creation_user > 0} {
                set user_name [::chat::Package get_user_name -user_id $creation_user]
                if {$user_name eq ""} {
                    set user_name Unknown
                }
            } else {
                set user_name "system"
            }
            lappend contents "\[$creation_date\] ${user_name}: $msg"
        }
        return $contents
    }

    #
    ## Transcripts
    #

    ::xo::db::Class create ::xo::db::chat_transcript \
        -id_column transcript_id \
        -object_type "chat_transcript" \
        -table_name "chat_transcripts" \
        -pretty_name   "#chat.Transcript#" \
        -pretty_plural "#chat.Transcripts#" \
        -superclass ::xo::db::Object -slots {
            ::xo::db::Attribute create pretty_name \
                -sqltype varchar(100) -not_null true
            ::xo::db::Attribute create description \
                -sqltype varchar(2000)
            ::xo::db::Attribute create contents \
                -sqltype varchar(32000) -not_null true
            ::xo::db::Attribute create room_id \
                -datatype integer \
                -references "chat_rooms(room_id) on delete cascade"
        }

    ::xo::db::chat_transcript ad_instproc save_new {} {
        Save a new transcript, making sure its creator is granted the
        necessary operative privileges.

        @return new transcript id
    } {
        if {![info exists :context_id]} {
            set :context_id ${:package_id}
        }
        ::xo::dc transaction {
            set transcript_id [next]
            foreach privilege {edit view delete} {
                permission::grant \
                    -party_id  ${:creation_user} \
                    -object_id ${:transcript_id} \
                    -privilege chat_transcript_${privilege}
            }
        }
        return $transcript_id
    }

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
