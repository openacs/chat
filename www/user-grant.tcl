#/chat/www/user-grant.tcl
ad_page_contract {
    
    Allow user to the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
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

ad_require_permission $room_id chat_user_grant

set context_bar [list "Grant user"]
set submit_label "Grant"
set title "Grant user"
set action "user-grant-2"
set description "Grant chat read/write privilege for <b>[chat_room_name $room_id]</b> to"
db_multirow parties list_parties {
  select party_id, acs_object.name(party_id) as name
  from parties
} 

ad_return_template grant-entry


