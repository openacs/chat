#/chat/www/room-edit.tcl
ad_page_contract {
    Display a form to edit room information.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 13, 2000
    @cvs-id $Id$
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    room_id:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    pretty_name:onevalue
    description:onevalue
    moderated_p:onevalue
    room:onerow
}

ad_require_permission $room_id chat_room_edit


if {[catch {db_1row room_info {
    select pretty_name, description, moderated_p, archive_p, active_p 
    from chat_rooms
    where room_id = :room_id}} errmsg]} {

    ad_return_complaint "Room not found" "Room not found."
}

set context_bar [ad_context_bar "Edit room '$pretty_name'"]
set title "Edit room '$pretty_name'"
set action "room-edit-2"
set submit_label "Update room"

ad_return_template "room-entry"






