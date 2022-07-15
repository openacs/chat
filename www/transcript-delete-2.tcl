#/chat/www/transcript-delete-2.tcl
ad_page_contract {
    Delete chat transcript.
} {
    room_id:object_type(chat_room)
    transcript_id:object_type(chat_transcript)
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_delete

set t [::xo::db::Class get_instance_from_db -id $transcript_id]
$t delete

ad_returnredirect "room?room_id=$room_id"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
