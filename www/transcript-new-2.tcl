#/chat/www/transcript-new-2.tcl
ad_page_contract {
    Save transcript.
} {
    room_id:naturalnum,notnull
    transcript_name:trim,notnull
    {description:trim ""}
    {delete_messages:optional "off"}
    {deactivate_room:optional "off"}
}

permission::require_permission -object_id $room_id -privilege chat_transcript_create

set user_id [ad_conn user_id]
set creation_ip [ad_conn peeraddr]

set r [::xo::db::Class get_instance_from_db -id $room_id]

set transcript_id [$r create_transcript \
                       -pretty_name $transcript_name \
                       -description $description \
                       -creation_user $user_id \
                       -creation_ip $creation_ip]

if { $delete_messages eq "on" } {
    $r delete_messages
    # forward the information to AJAX
    ::chat::Chat flush_messages -chat_id $room_id
}

if { $deactivate_room eq "on" } {
    $r set active_p false
    $r save
}

ad_returnredirect "chat-transcript?room_id=$room_id&transcript_id=$transcript_id"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
