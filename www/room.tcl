#/www/chat/room.tcl
ad_page_contract {
    Display information about chat room.
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id$
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    pretty_name:onevalue
    description:onevalue
    archive_p:onevalue
    moderated_p:onevalue
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
    moderators:multirow
    users_allow:multirow
    users_ban:multirow
    chat_transcripts:multirow
}

set context_bar [list "[_ chat.Room_Information]"]

###
# Get all available permission of this user on this room.
###
set room_view_p [permission::permission_p -object_id $room_id -privilege chat_room_view]
set room_edit_p [permission::permission_p -object_id $room_id -privilege chat_room_edit]
set room_delete_p [permission::permission_p -object_id $room_id -privilege chat_room_delete]
set user_ban_p [permission::permission_p -object_id $room_id -privilege chat_user_ban]
set user_unban_p [permission::permission_p -object_id $room_id -privilege chat_user_unban]
set user_grant_p [permission::permission_p -object_id $room_id -privilege chat_user_grant]
set user_revoke_p [permission::permission_p -object_id $room_id -privilege chat_user_revoke]
set moderator_grant_p [permission::permission_p -object_id $room_id -privilege chat_moderator_grant]
set moderator_revoke_p [permission::permission_p -object_id $room_id -privilege chat_moderator_revoke]
set transcript_create_p [permission::permission_p -object_id $room_id -privilege chat_transcript_create]

###
# Get room basic information.
###
db_1row room_info {
    select pretty_name, description, moderated_p, active_p, archive_p
    from chat_rooms
    where room_id = :room_id
}

# get db-message count
set message_count [db_string message_count "select count(*) from chat_msgs where room_id = :room_id" -default 0]

# List user ban from chat
db_multirow banned_users list_user_ban {}

list::create \
    -name "banned_users" \
    -multirow "banned_users" \
    -key party_id \
    -pass_properties { user_unban_p room_id } \
    -row_pretty_plural [_ chat.banned_users] \
    -elements {
        name {
            label "#chat.Name#"
        }
        email {
            label "#acs-kernel.Email_Address#"
        }
        actions {
            label "#chat.actions#"
            html { align "center" }
            display_template {
                <if @user_unban_p@ eq "1">
                <a href="user-unban?room_id=@room_id@&party_id=@banned_users.party_id@">
                <img src="/shared/images/Delete16.gif" border="0">
                </a>
                </if>
            }
        }
    }

ad_return_template

