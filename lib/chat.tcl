ad_include_contract {

    This include renders a chat room on a page.

    It assumes the including page to provide a master, as this is
    needed to provide the javascript machinery needed to run the chat.

} {
    room_id:object_type(chat_room),notnull
}

set r [::xo::db::Class get_instance_from_db -id $room_id]

set room_name [$r set pretty_name]

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
