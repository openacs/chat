ad_library {

    Web utilities for automated testing of the Chat package.

}

namespace eval chat::test {

    ad_proc -private new {
        {-pretty_name "Test Room"}
        {-user_id 0}
        {-user_info ""}
    } {
        Create a new forum via the web interface.
    } {

        #
        # Get the chat package URL
        #
        set chat_page [aa_get_first_url -package_key chat]

        #
        # Get Data and check status code
        #
        if {$user_info eq ""} {
            set d [acs::test::http -user_id $user_id $chat_page/room-edit]
        } else {
            set d [acs::test::http -user_info $user_info $chat_page/room-edit]
        }
        acs::test::reply_has_status_code $d 200

        #
        # Get the form specific data (action, method and provided form-fields)
        #
        set form_data [::acs::test::get_form [dict get $d body] {//form[@id="edit-room"]}]

        #
        # Fill in a few values into the form
        #
        set d [::acs::test::form_reply \
                   -last_request $d \
                   -url [dict get $form_data @action] \
                   -update [list \
                                pretty_name $pretty_name \
                               ] \
                   [dict get $form_data fields]]
        set reply [dict get $d body]

        #
        # Check, if the form was correctly validated.
        #
        acs::test::reply_contains_no $d form-error
        acs::test::reply_has_status_code $d 302

        #
        # Parse the final room_id from the return_url
        #
        set room_url [acs::test::get_url_from_location $d]
        regexp {[^&]?room_id=(\d+)[^&\d]?} $room_url _ room_id

        dict set d payload room_id $room_id

        return $d
    }

    ad_proc -private view {
        {-last_request ""}
        -room_id:required
    } {
        View a forum via the web interface.
    } {
        set chat_page [aa_get_first_url -package_key chat]

        set d $last_request

        aa_log "Entering room via '$chat_page/room-enter?room_id=$room_id'"
        set d [::acs::test::http \
                   -last_request $d \
                   $chat_page/room-enter?room_id=$room_id]
        acs::test::reply_has_status_code $d 302

        set room_url [acs::test::get_url_from_location $d]
        aa_log "Redirected to '$room_url'"
        set d [::acs::test::http \
                   -last_request $d \
                   $room_url]
        acs::test::reply_has_status_code $d 200

        return $d
    }

}
