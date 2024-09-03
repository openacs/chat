ad_page_contract {

} {
    type:notnull
    room_id:naturalnum,notnull
    party_id:naturalnum,notnull
}

set room [::xo::db::Class get_instance_from_db -id $room_id]
if {$type eq "user"} {
    permission::require_permission -object_id $room_id -privilege chat_user_grant
    $room grant_user -party_id $party_id
} else {
    permission::require_permission -object_id $room_id -privilege chat_user_ban
    $room ban_user -party_id $party_id
}
ad_returnredirect "room?room_id=$room_id"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
