::xo::library doc {

    Chat Objects

    @author Antonio Pisano

}

namespace eval ::chat {

    #
    ## Chat Package
    #

    Class create ::chat::Package

    ::chat::Package proc flush_rooms {} {
        foreach room_id [::xo::dc list get_rooms {
            select room_id from chat_rooms
            where archive_p and auto_flush_p
        }] {
            set room [::xo::db::Class get_instance_from_db -id $room_id]
            $room flush
        }
    }

    ::chat::Package proc get_user_name {-user_id} {
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
        creation_date {timestamp with time zone}
    }

    ::xo::db::chat_room instproc grant_creator {} {
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

    ::xo::db::chat_room instproc grant_user {
        -party_id
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

    ::xo::db::chat_room instproc revoke_user {
        -party_id
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

    ::xo::db::chat_room instproc ban_user {
        -party_id
    } {
        permission::grant \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_ban
    }

    ::xo::db::chat_room instproc unban_user {
        -party_id
    } {
        permission::revoke \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_ban
    }

    ::xo::db::chat_room instproc grant_moderator {
        -party_id
    } {
        permission::grant \
            -party_id  $party_id \
            -object_id ${:room_id} \
            -privilege chat_room_moderate
    }

    ::xo::db::chat_room instproc revoke_moderator {
        -party_id
    } {
        set parties $party_id
        foreach party_id $parties {
            permission::revoke \
                -party_id  $party_id \
                -object_id ${:room_id} \
                -privilege chat_room_moderate
        }
    }

    ::xo::db::chat_room instproc save_new {} {
        if {![info exists :creation_user]} {
            set :creation_user [expr {[ns_conn isconnected] ? [ad_conn user_id] : ""}]
        }
        if {![info exists :creation_ip]} {
            set :creation_ip [expr {[ns_conn isconnected] ? [ad_conn peeraddr] : ""}]
        }
        if {![info exists :context_id]} {
            set :context_id [expr {[ns_conn isconnected] ? [ad_conn package_id] : ""}]
        }
        set creation_user ${:creation_user}
        set creation_ip   ${:creation_ip}
        set context_id    ${:context_id}
        ::xo::dc transaction {
            set room_id [next]
            # todo: changing the acs_object by hand might change if we
            # would add these metadata to the acs_object orm in
            # xotcl-core
            ::xo::dc dml update {
                update acs_objects set
                  creation_user = :creation_user
                 ,creation_ip   = :creation_ip
                 ,context_id    = :context_id
                where object_id = :room_id
            }
            :grant_creator
        }

        return $room_id
    }

    ::xo::db::chat_room instproc delete {} {
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


    ::xo::db::chat_room instproc post_message {
        {-msg ""}
        {-creation_user ""}
        {-creation_ip ""}
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

    ::xo::db::chat_room instproc delete_messages {} {
        set room_id ${:room_id}
        ::xo::dc dml delete_messages {
            delete from chat_msgs where room_id = :room_id
        }
    }

    ::xo::db::chat_room instproc count_messages {} {
        set room_id ${:room_id}
        ::xo::dc get_value count_messages {
            select count(*) from chat_msgs
            where room_id = :room_id
        }
    }

    ::xo::db::chat_room instproc flush {} {
        if {${:auto_transcript_p}} {
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
                set user_name [expr {$creation_user > 0 ? [chat_user_name $creation_user] : "system"}]
                lappend contents "\[$creation_date\] <b>${user_name}</b>: $msg"
            }
            if {[llength $contents] > 0} {
                set today [clock format [clock seconds] -format "%d.%m.%Y"]
                set t [::xo::db::chat_transcript new \
                           -pretty_name "#chat.transcript_of_date# $today" \
                           -description "#chat.automatically_created_transcript#" \
                           -room_id ${:room_id} \
                           -contents [join $contents "<br>\n"]]
                $t save_new
            }
        }
        :delete_messages
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

    ::xo::db::chat_transcript instproc save_new {} {
        if {![info exists :creation_user]} {
            set :creation_user [expr {[ns_conn isconnected] ? [ad_conn user_id] : ""}]
        }
        if {![info exists :creation_ip]} {
            set :creation_ip [expr {[ns_conn isconnected] ? [ad_conn peeraddr] : ""}]
        }
        if {![info exists :context_id]} {
            set :context_id [expr {[ns_conn isconnected] ? [ad_conn package_id] : ""}]
        }
        set creation_user ${:creation_user}
        set creation_ip   ${:creation_ip}
        set context_id    ${:context_id}
        ::xo::dc transaction {
            set transcript_id [next]
            # todo: changing the acs_object by hand might change if we
            # would add these metadata to the acs_object orm in
            # xotcl-core
            ::xo::dc dml update {
                update acs_objects set
                  creation_user = :creation_user
                 ,creation_ip   = :creation_ip
                 ,context_id    = :context_id
                where object_id = :transcript_id
            }
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
