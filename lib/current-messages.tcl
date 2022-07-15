ad_include_contract {
    This include displays currently persisted chat room messages
} {
    room_id:object_type(chat_room)
}

set r [::xo::db::Class get_instance_from_db -id $room_id]
set messages [$r transcript_messages]
set n_messages [llength $messages]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
