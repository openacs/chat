#/chat/www/user-ban.tcl
ad_page_contract {

    Explicit ban user from the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    room_id:onevalue
    description:onevalue
    parties:multirow
}

permission::require_permission -object_id $room_id -privilege chat_user_ban

set context_bar [list "[_ chat.Ban_user]"]
set submit_label "[_ chat.Ban]"
set title "[_ chat.Ban_user]"
set action "user-ban-2"
set description "[_ chat.Ban_chat_read_write] <b>[chat_room_name $room_id]</b> [_ chat.to]"
db_multirow parties list_parties {}

ad_return_template grant-entry

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
