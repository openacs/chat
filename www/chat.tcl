#/chat/www/chat.tcl
ad_page_contract {

    Decide which template to use HTML or AJAX.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id
    client
    {message:html ""}
} -properties {
    context_bar:onevalue
    user_id:onevalue
    user_name:onevalue
    message:onevalue
    room_id:onevalue
    room_name:onevalue 
    width:onevalue
    height:onevalue
    host:onevalue
    port:onevalue
    moderator_p:onevalue
    msgs:multirow
}

if { [catch {set room_name [chat_room_name $room_id]} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
}

set context_bar $room_name
set user_id [ad_conn user_id]
set read_p [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p [permission::permission_p -object_id $room_id -privilege "chat_ban"]
set moderate_room_p [chat_room_moderate_p $room_id]

if { $moderate_room_p == "t" } {
    set moderator_p [permission::permission_p -object_id $room_id -privilege "chat_moderator"]
} else {
    # This is an unmoderate room, therefore everyone is a moderator.
    set moderator_p "1"
}

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

# Get chat screen name.
set user_name [chat_user_name $user_id]

# send message to the database 
if { ![empty_string_p $message] } {
    chat_message_post $room_id $user_id $message $moderator_p
}

# Determine which template to use for html or ajax client
switch $client {
    "html" {
        set template_use "html-chat"
        # forward to ajax if necessary
        if { ![empty_string_p $message] && [llength [info command ::chat::Chat]] > 0 } {
            set session_id [ad_conn session_id]
            ::chat::Chat c1 -volatile -chat_id $room_id -session_id $session_id
            c1 add_msg $message
        }
    }
    "ajax" {
        set template_use "ajax-chat-script"
    }
}

ad_return_template $template_use

