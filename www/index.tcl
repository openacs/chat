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
set user_id [ad_conn user_id]
set actions [list]
set room_create_p [permission::permission_p -object_id $package_id -privilege chat_room_create]
set warning ""

if { $room_create_p } {
    lappend actions "#chat.Create_a_new_room#" room-edit "#chat.Create_a_new_room#"
}

db_multirow -extend {
    active_users last_activity room_url base_url
} rooms rooms_list {
    select rm.room_id,
           rm.pretty_name,
           rm.description,
           rm.moderated_p,
           rm.active_p,
           rm.archive_p,
           obj.context_id,
           acs_permission.permission_p(rm.room_id, :user_id, 'chat_room_admin') as admin_p,
           acs_permission.permission_p(rm.room_id, :user_id, 'chat_read') as user_p
     from chat_rooms rm,
          acs_objects obj
    where rm.room_id = obj.object_id
      and obj.context_id = :package_id
    order by rm.pretty_name
} {
    set base_url [site_node::get_url_from_object_id -object_id $context_id]
    set room [::chat::Chat create new -volatile -chat_id $room_id]
    set active_users [$room nr_active_users]
    set last_activity [$room last_activity]

    if { $active_p } {
        set room_url [export_vars -base "room-enter" {room_id}]
    }
}

list::create \
    -name "rooms" \
    -multirow "rooms" \
    -key room_id \
    -pass_properties {room_create_p} \
    -actions $actions \
    -row_pretty_plural [_ chat.rooms] \
    -no_data [_ chat.There_are_no_rooms_available] \
    -elements {
        active {
            label "#chat.Active#"
            html { style "text-align: center" }
            display_template {
                <if @rooms.active_p;literal@ true>
                <img src="/resources/chat/active.png" alt="#chat.Room_active#">
                </if>
                <else>
                <img src="/resources/chat/inactive.png" alt="#chat.Room_no_active#">
                </else>
            }
        }
        pretty_name {
            label "#chat.Room_name#"
            display_template {
                <if @rooms.active_p;literal@ true>
                <a href="@rooms.room_url;noquote@">@rooms.pretty_name@</a>
                </if>
                <else>
                @rooms.pretty_name@
                </else>
            }
        }
        description {
            label "[_ chat.Description]"
        }
        active_users {
            label "#chat.active_users#"
            html { style "text-align:center;" }
        }
        last_activity {
            label "#chat.last_activity#"
            html { style "text-align:center;" }
        }
        actions {
            label "#chat.actions#"
            display_template {
                <a href="chat-transcripts?room_id=@rooms.room_id@" class=button>#chat.Transcripts#</a>
                <if @room_create_p;literal@ true>
                <a href="@rooms.base_url@room?room_id=@rooms.room_id@" class=button>#chat.room_admin#</a>
                </if>
            }
        }
    }

# set page properties

set doc(title) [_ chat.Chat_main_page]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
