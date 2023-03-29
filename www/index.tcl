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
set base_url [ad_conn package_url]
set user_id [ad_conn user_id]
set actions [list]
set room_create_p [permission::permission_p -object_id $package_id -privilege chat_room_create]
set warning ""

if { $room_create_p } {
    lappend actions "#chat.Create_a_new_room#" room-edit "#chat.Create_a_new_room#"
}

db_multirow -extend {
    active_users
    last_activity
    room_url
    toggle_active_url
} rooms rooms_list {
    select rm.room_id,
           rm.pretty_name,
           rm.description,
           rm.active_p,
           rm.archive_p
     from chat_rooms rm,
          acs_objects obj
    where rm.room_id = obj.object_id
      and obj.package_id = :package_id
      and acs_permission.permission_p(rm.room_id, :user_id, 'chat_read')
    order by rm.pretty_name
} {
    set room [::chat::Chat create new -volatile -chat_id $room_id]
    set active_users [$room nr_active_users]
    set last_activity [$room last_activity]

    if {[permission::permission_p -object_id $package_id \
             -party_id $user_id -privilege chat_room_edit]} {
        set toggle_active_url toggle-active?room_id=$room_id
    }

    if { $active_p } {
        set room_url [export_vars -base "chat" {room_id}]
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
                <if @rooms.toggle_active_url@ ne "">
                  <a href="@rooms.toggle_active_url@">
                </if>
                  <if @rooms.active_p;literal@ true>
                    <img src="/resources/chat/active.png" alt="#chat.Room_active#">
                  </if>
                  <else>
                    <img src="/resources/chat/inactive.png" alt="#chat.Room_no_active#">
                  </else>
                <if @rooms.toggle_active_url@ ne "">
                  </a>
                </if>
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
                <a href="${base_url}room?room_id=@rooms.room_id@" class=button>#chat.room_admin#</a>
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
