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
    room_id:onevalue
    moderator_p:onevalue
}

set r [::xo::db::Class get_instance_from_db -id $room_id]

set doc(title) [$r set pretty_name]
set context [list $doc(title)]

set read_p  [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p   [permission::permission_p -object_id $room_id -privilege "chat_ban"]

if { (!$read_p && !$write_p) || $ban_p || ![$r set active_p] } {
    #
    # You won't be able to chat if:
    # - you cannot read nor write in the room
    # - you were banned
    # - the chat is not active
    #
    ad_returnredirect unauthorized
    ad_script_abort
}

set chat_frame [::chat::Chat login -chat_id $room_id]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
