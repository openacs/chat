#/chat/www/index.tcl
ad_page_contract {
    Display a list of available chat rooms that the user has permission to edit.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 13, 2000
    @cvs-id $Id$
} {
} -properties {
    context_bar:onevalue
    package_id:onevalue
    user_id:onevalue
    room_create_p:onevalue
    rooms:multirow
}

set package_id [ad_conn package_id]

set context_bar [ad_context_bar]

set user_id [ad_conn user_id]

set room_create_p [ad_permission_p $package_id chat_room_create]

db_multirow rooms rooms_list {
    select rm.room_id, rm.pretty_name, rm.description, rm.moderated_p, rm.active_p, rm.archive_p, 
           acs_permission.permission_p(room_id, :user_id, 'chat_room_admin') as admin_p
    from chat_rooms rm, acs_objects obj
    where obj.context_id = :package_id
      and rm.room_id = obj.object_id
    order by rm.pretty_name
}


ad_return_template
    







