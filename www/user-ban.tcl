#/chat/www/user-ban.tcl
ad_page_contract {
    
    Explicit ban user from the chat room.

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

ad_require_permission $room_id chat_user_ban

set context_bar [ad_context_bar "Ban user"]
set submit_label "Ban"
set title "Ban user"
set action "user-ban-2"
set description "Ban chat read/write privilege for <b>[chat_room_name $room_id]</b> to"
db_multirow parties list_parties {
  select party_id, acs_object.name(party_id) as name
  from parties
} 

ad_return_template grant-entry
