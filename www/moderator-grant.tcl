#/chat/www/moderator-grant.tcl
ad_page_contract {

    Add moderator to a room.
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 16, 2000
    @cvs-id $Id$
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    room_id:onevalue
    description:onevalue
    parties:multirow
}

ad_require_permission $room_id chat_moderator_grant

set context_bar [list "Grant moderator"]
set submit_label "Grant"
set title "Grant moderator"
set action "moderator-grant-2"
set description "Grant moderator for <b>[chat_room_name $room_id]</b> to"
db_multirow parties list_parties {
  select party_id, acs_object.name(party_id) as name
  from parties
} 

ad_return_template grant-entry

