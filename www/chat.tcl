#/chat/www/chat.tcl
ad_page_contract {

    Decide which template to use HTML or AJAX.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
} -properties {
    context:onevalue
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

set r [::xo::db::Class get_instance_from_db -id $room_id]
set room_name [$r set pretty_name]
set doc(title) $room_name
set doc(type) {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}

set context [list $doc(title)]

set user_id [ad_conn user_id]
set read_p  [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p   [permission::permission_p -object_id $room_id -privilege "chat_ban"]
set moderate_room_p [$r set moderated_p]

if { $moderate_room_p == "t" } {
    set moderator_p [permission::permission_p -object_id $room_id -privilege "chat_moderator"]
} else {
    # This is an unmoderated room, therefore, everyone is a moderator.
    set moderator_p "1"
}

if { ($read_p == 0 && $write_p == 0) || ($ban_p == 1) } {
    # Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

set chat_frame [::chat::Chat login -chat_id $room_id]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
