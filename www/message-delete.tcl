#/chat/www/message-delete.tcl
ad_page_contract {
    Display delete message confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date January 18, 2001
    @cvs-id $Id$
} {
    room_id:notnull,naturalnum
} -properties {
    room_id:onevalue
    pretty_name:onevalue
    message_count:onevalue
    context_bar:onevalue
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Delete_messages]"]

set r [::xo::db::Class get_instance_from_db -id $room_id]
set pretty_name [$r set pretty_name]

set message_count [$r count_messages]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
