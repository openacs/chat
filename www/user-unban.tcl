#/chat/www/user-unban.tcl
ad_page_contract {
    
    Display confirmation before unban user.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:integer,notnull
    party_id:integer,notnull
}

ad_require_permission $room_id chat_user_unban

set context_bar [list [list "room?room_id=$room_id" "Room information"] "Unban user"]

set party_pretty_name [db_string get_party_name "select acs_object.name(:party_id) from dual"]

set pretty_name [chat_room_name $room_id]

ad_return_template