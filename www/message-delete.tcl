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

set pretty_name [chat_room_name $room_id]

set message_count [chat_message_count $room_id]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
