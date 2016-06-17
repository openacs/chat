#/chat/www/user-unban-2.tcl
ad_page_contract {

    Unban chat user

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:integer,notnull
    party_id:integer,notnull
}

permission::require_permission -object_id $room_id -privilege chat_user_unban

chat_user_unban $room_id $party_id

ad_returnredirect "room?room_id=$room_id"
