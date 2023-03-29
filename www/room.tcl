#/www/chat/room.tcl
ad_page_contract {
    Display information about chat room.
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id$
} {
  room_id:object_type(chat_room)
} -properties {
    context_bar:onevalue
    pretty_name:onevalue
    description:onevalue
    archive_p:onevalue
    active_p:onevalue
    room_view_p:onevalue
    room_edit_p:onevalue
    room_delete_p:onevalue
    user_ban_p:onevalue
    user_unban_p:onevalue
    user_grant_p:onevalue
    user_revoke_p:onevalue
    moderator_grant_p:onevalue
    moderator_revoke_p:onevalue
    transcript_create_p:onevalue
    transcript_edit_p:onevalue
    transcript_view_p:onevalue
    avatar_p:onevalue
    moderators:multirow
    users_allow:multirow
    users_ban:multirow
    chat_transcripts:multirow
}

set context_bar [list "[_ chat.Room_Information]"]

###
# Get all available permission of this user on this room.
###
set room_view_p         [permission::permission_p -object_id $room_id -privilege chat_room_view]
set room_edit_p         [permission::permission_p -object_id $room_id -privilege chat_room_edit]
set room_delete_p       [permission::permission_p -object_id $room_id -privilege chat_room_delete]
set user_ban_p          [permission::permission_p -object_id $room_id -privilege chat_user_ban]
set user_unban_p        [permission::permission_p -object_id $room_id -privilege chat_user_unban]
set user_grant_p        [permission::permission_p -object_id $room_id -privilege chat_user_grant]
set user_revoke_p       [permission::permission_p -object_id $room_id -privilege chat_user_revoke]
set moderator_grant_p   [permission::permission_p -object_id $room_id -privilege chat_moderator_grant]
set moderator_revoke_p  [permission::permission_p -object_id $room_id -privilege chat_moderator_revoke]
set transcript_create_p [permission::permission_p -object_id $room_id -privilege chat_transcript_create]

###
# Get room basic information.
###
set r [::xo::db::Class get_instance_from_db -id $room_id]
set pretty_name          [$r set pretty_name]
set description          [$r set description]
set active_p             [$r set active_p]
set archive_p            [$r set archive_p]
set auto_flush_p         [$r set auto_flush_p]
set auto_transcript_p    [$r set auto_transcript_p]
set login_messages_p     [$r set login_messages_p]
set logout_messages_p    [$r set logout_messages_p]
set messages_time_window [$r set messages_time_window]
set avatar_p             [$r set avatar_p]

# prettify flags
foreach property {
    active_p
    archive_p
    auto_flush_p
    auto_transcript_p
    login_messages_p
    logout_messages_p
    avatar_p
} {
    set $property [expr {[set $property] eq "t" ? [_ acs-kernel.common_yes] : [_ acs-kernel.common_no] }]
}

# get db-message count
set message_count [$r count_messages]

# List user ban from chat
db_multirow -extend {name email unban_url unban_text} banned_users list_user_ban {} {
    set name "$last_name, $first_names"
    set email [acs_user::get_element -user_id $party_id -element email]
    if { $user_unban_p } {
        set unban_url [export_vars -base "user-unban" {room_id party_id}]
        set unban_text [_ chat.Unban_user]
    }
}

set xowiki_includelet_code "\{\{chat_room -chat_id $room_id\}\}"
set xowiki_includelet_size [string length $xowiki_includelet_code]

set actions ""
if { $user_ban_p } {
    set actions [list [_ chat.Ban_user] [export_vars -base "search" {room_id {type ban}}]]
}

list::create \
    -name "banned_users" \
    -multirow "banned_users" \
    -key party_id \
    -pass_properties { user_unban_p room_id } \
    -row_pretty_plural [_ chat.banned_users] \
    -actions $actions \
    -elements {
        name {
            label "#chat.Name#"
        }
        email {
            label "#acs-kernel.Email_Address#"
        }
        actions {
            label "#chat.actions#"
            html { style "text-align:center" }
            link_url_col unban_url
            display_col unban_text
            link_html {class "button"}
        }
    }

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
