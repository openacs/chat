ad_library {
    Chat Test Procs
}

aa_register_case \
    -procs {
        "xo::db::chat_room instproc save_new"
        "xo::db::chat_room instproc grant_creator"
    } chat_room_tests {

        Test the chat room api

    } {
        set test_user [acs::test::user::create]

        aa_run_with_teardown -rollback -test_code {

            set package_id [db_string get_package {
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
                [permission::permission_p -party_id $test_user_id -object_id $room_id -privilege chat_room_edit] &&
                [permission::permission_p -party_id $test_user_id -object_id $room_id -privilege chat_room_view] &&
                [permission::permission_p -party_id $test_user_id -object_id $room_id -privilege chat_room_delete] &&
                [permission::permission_p -party_id $test_user_id -object_id $room_id -privilege chat_transcript_create]
            }

        } -teardown_code {
            acs::test::user::delete -user_id [dict get $test_user user_id] \
                -delete_created_acs_objects
        }

    }
