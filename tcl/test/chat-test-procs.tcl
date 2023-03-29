ad_library {
    Chat Test Procs
}

aa_register_case \
    -procs {
        "::chat::Package proc get_user_name"
        "::xo::db::chat_room instproc save_new"
        "::xo::db::chat_room instproc grant_creator"
        "::xo::db::chat_room instproc grant_moderator"
        "::xo::db::chat_room instproc revoke_moderator"
        "::xo::db::chat_room instproc grant_user"
        "::xo::db::chat_room instproc revoke_user"
        "::xo::db::chat_room instproc ban_user"
        "::xo::db::chat_room instproc unban_user"
        "::xo::db::chat_room instproc count_messages"
        "::xo::db::chat_room instproc post_message"
        "::xo::db::chat_room instproc flush"
        "::xo::db::chat_room instproc create_transcript"
        "::xo::db::chat_room instproc transcript_messages"
        "::xo::db::chat_transcript instproc save_new"
        "::xo::db::chat_room instproc delete_messages"
        "::xo::db::chat_room instproc delete"
        "::chat::Package proc flush_rooms"
    } chat_room_tests {

        Test the chat room api

    } {
        set test_user [acs::test::user::create]
        set test_user_2 [acs::test::user::create]

        aa_run_with_teardown -rollback -test_code {

            aa_section "Utilities"

            set user [acs_user::get -user_id [dict get $test_user user_id]]
            aa_equals "get_user_name returns expected" \
                [chat::Package get_user_name -user_id [dict get $test_user user_id]] \
                [expr {[dict get $user screen_name] ne "" ?
                       [dict get $user screen_name] : [dict get $user name]}]


            aa_section "Chat Room Creation"
            set package_id [::xo::dc get_value get_package {
                select max(package_id) from apm_packages
            }]

            set test_user_id [dict get $test_user user_id]

            set r [::xo::db::chat_room new \
                       -moderated_p          t \
                       -description          {Test Chat Room} \
                       -active_p             t \
                       -archive_p            t \
                       -auto_flush_p         t \
                       -auto_transcript_p    t \
                       -login_messages_p     t \
                       -logout_messages_p    t \
                       -messages_time_window 2000 \
                       -avatar_p             t \
                       -package_id           $package_id \
                       -creation_user        $test_user_id \
                       -creation_ip          127.0.0.1 \
                       -pretty_name          {Test Room}]
            set room_id [$r save_new]

            aa_true "Chat room was created" [::xo::dc 0or1row check {
                select o.creation_ip from chat_rooms r, acs_objects o
                where r.room_id = :room_id
                  and o.object_id = r.room_id
                  and r.description = 'Test Chat Room'
                  and r.pretty_name = 'Test Room'
                  and o.package_id = :package_id
                  and o.context_id = :package_id
                  and o.creation_user = :test_user_id
                  and o.creation_ip = '127.0.0.1'
            }]

            aa_true "Creation user was granted the expected privileges" {
                [permission::permission_p \
                     -party_id $test_user_id -object_id $room_id -privilege chat_room_edit] &&
                [permission::permission_p \
                     -party_id $test_user_id -object_id $room_id -privilege chat_room_view] &&
                [permission::permission_p \
                     -party_id $test_user_id -object_id $room_id -privilege chat_room_delete] &&
                [permission::permission_p \
                     -party_id $test_user_id -object_id $room_id -privilege chat_transcript_create]
            }


            aa_section "Permission api"

            set test_user_id_2 [dict get $test_user_2 user_id]

            aa_log "Grant moderator to user '$test_user_id_2'"
            $r grant_moderator -party_id $test_user_id_2
            aa_true "User '$test_user_id_2' was granted the expected privilege" \
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_room_moderate]

            aa_log "Revoke moderator to user '$test_user_id_2'"
            $r revoke_moderator -party_id $test_user_id_2
            aa_false "User '$test_user_id_2' was revoked the expected privilege" \
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_room_moderate]

            aa_log "Grant usage to user '$test_user_id_2'"
            $r grant_user -party_id $test_user_id_2
            aa_true "User '$test_user_id_2' was granted the expected privilege" {
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_read] &&
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_write]
            }

            aa_log "Revoke usage to user '$test_user_id_2'"
            $r revoke_user -party_id $test_user_id_2
            aa_false "User '$test_user_id_2' was revoked the expected privilege" {
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_read] &&
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_write]
            }

            aa_log "Ban user '$test_user_id_2'"
            $r ban_user -party_id $test_user_id_2
            aa_true "User '$test_user_id_2' was banned" \
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_ban]

            aa_log "Unban user '$test_user_id_2'"
            $r unban_user -party_id $test_user_id_2
            aa_false "User '$test_user_id_2' was unbanned" \
                [permission::permission_p \
                     -party_id $test_user_id_2 -object_id $room_id -privilege chat_ban]


            aa_section "Messaging"

            aa_equals "Chat Room '$room_id' is empty" \
                [$r count_messages] 0

            $r post_message \
                -creation_user $test_user_id_2 \
                -creation_ip 192.168.1.1 \
                -msg "Hello there!"

            $r post_message \
                -creation_user $test_user_id \
                -creation_ip 192.168.1.2 \
                -msg "General Kenobi!"

            aa_equals "Chat Room '$room_id' has 2 messages" \
                [$r count_messages] 2

            aa_log "Flushing all messages"
            $r flush

            set transcript [::xo::dc get_value get_transcript {
                select contents from chat_transcripts
                where room_id = :room_id
            }]
            aa_true "Transcript '$transcript' contains the expected content" {
                [string first "Hello there!" $transcript] >= 0 &&
                [string first "General Kenobi!" $transcript] >= 0 &&
                [string first [chat::Package get_user_name -user_id $test_user_id] $transcript] >= 0 &&
                [string first [chat::Package get_user_name -user_id $test_user_id_2] $transcript] >= 0
            }

            aa_equals "Chat Room '$room_id' is empty again" \
                [$r count_messages] 0


            aa_section "Deleting room"
            $r delete
            aa_false "Room was deleted" [::xo::dc 0or1row check {
                select 1 from chat_rooms where room_id = :room_id
            }]


            aa_section "Flushing all rooms"

            aa_log "Creating a few rooms, with a couple messages"
            set other_rooms [list]
            for {set i 2} {$i <= 4} {incr i} {
                set r [::xo::db::chat_room new \
                           -description          "Test Chat Room $i" \
                           -archive_p            t \
                           -auto_flush_p         t \
                           -auto_transcript_p    t \
                           -creation_user        $test_user_id \
                           -package_id           $package_id \
                           -pretty_name          "Test Room $i"]
                lappend other_rooms [$r save_new]

                $r post_message \
                    -creation_user $test_user_id_2 \
                    -creation_ip 192.168.1.1 \
                    -msg "Ping!"
                $r post_message \
                    -creation_user $test_user_id \
                    -creation_ip 192.168.1.2 \
                    -msg "Pong!"
            }

            aa_log "Flush the rooms"
            ::chat::Package flush_rooms

            aa_equals "3 new transcripts have been created" \
                [::xo::dc get_value count \
                     "select count(*) from chat_transcripts where room_id in ([join $other_rooms ,])"] \
                3

            aa_false "Rooms are empty now" \
                [::xo::dc 0or1row check_messages \
                     "select 1 from chat_msgs where room_id in ([join $other_rooms ,])"]

        } -teardown_code {
            acs::test::user::delete -user_id [dict get $test_user user_id] \
                -delete_created_acs_objects
            acs::test::user::delete -user_id [dict get $test_user_2 user_id] \
                -delete_created_acs_objects
        }

    }

aa_register_case \
    -cats {web smoke} \
    -urls {
        /room-edit
        /room
        /chat
    } web_chat_room_create {
       Testing the creation of a chat room via web
    } {
        set room_id 0
        aa_run_with_teardown -test_code {

            #
            # Create a new admin user
            #
            set user_info [acs::test::user::create -admin]
            set user_id [dict get $user_info user_id]

            #
            # Create a new chat
            #
            set pretty_name [ad_generate_random_string]
            set d [chat::test::new \
                       -user_info $user_info \
                       -pretty_name $pretty_name]
            set room_id [dict get $d payload room_id]
            aa_log "Created chat with id $room_id"

            #
            # View a chat via name.
            #
            set response [chat::test::view \
                              -last_request $d \
                              -room_id $room_id]

        } -teardown_code {
            #
            # Delete the chat.
            #
            if {$room_id != 0} {
                set r [::xo::db::Class get_instance_from_db -id $room_id]
                $r delete
            }
            acs::test::user::delete -user_id [dict get $user_info user_id]
        }
    }
