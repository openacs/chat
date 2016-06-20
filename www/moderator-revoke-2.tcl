#/chat/www/moderator-revoke-2.tcl
ad_page_contract {

    Revoke moderator privilege.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
    party_id:naturalnum,notnull
}

permission::require_permission -object_id $room_id -privilege chat_moderator_revoke

chat_moderator_revoke $room_id $party_id

ad_returnredirect "room?room_id=$room_id"