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
set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]
set warning ""

if { $default_client eq "ajax" && ![apm_package_installed_p xotcl-core] } {
    set warning "[_ chat.xotcl_missing]"
}

if { $room_create_p } {
    lappend actions "#chat.Create_a_new_room#" room-edit "#chat.Create_a_new_room#"
}

db_multirow -extend { active_users last_activity room_url} rooms rooms_list {} {

    set room [::chat::Chat create new -volatile -chat_id $room_id]
    set active_users [$room nr_active_users]
    set last_activity [$room last_activity]

    if { $active_p } {
        set room_url [export_vars -base "room-enter" {room_id {client $default_client}}]
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
                <if @rooms.active_p@ eq t>
                <img src="/resources/chat/active.png" alt="#chat.Room_active#">
                </if>
                <else>
                <img src="/resources/chat/inactive.png" alt="#chat.Room_no_active#">
                </else>
            }
        }
        pretty_name {
            label "#chat.Room_name#"
            link_url_col room_url
            link_html {title "[_ chat.Enter_rooms_pretty_name]"}
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
                <if @room_create_p@ eq 1>
                <a href="@rooms.base_url@room?room_id=@rooms.room_id@" class=button>#chat.room_admin#</a>
                </if>
            }
        }
    }

# set page properties

set doc(title) [_ chat.Chat_main_page]

ad_return_template
