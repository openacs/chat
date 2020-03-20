#/chat/www/room-enter.tcl
ad_page_contract {

    Perform initialize before chat "Need to change this comment"

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
}

set user_id [ad_conn user_id]

set read_p  [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p   [permission::permission_p -object_id $room_id -privilege "chat_ban"]
ns_log notice "--query ban $ban_p: permission::permission_p -object_id $room_id -privilege chat_ban -party_id [ad_conn user_id]"

if { [catch {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
} errmsg] } {
    ad_return_error [_ chat.Room_not_found] [_ chat.Room_not_found]
    ad_log Warning "Chat room not found. Invalid room_id: $room_id"
    ad_script_abort
}

set active  [$r set active_p]

if { ($read_p == 0 && $write_p == 0) || ($ban_p == 1) || ($active == "f") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

ad_returnredirect [export_vars -base "chat" {room_id}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
