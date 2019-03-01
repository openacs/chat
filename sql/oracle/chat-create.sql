--
-- packages/chat/sql/chat-create.sql
--
-- @author ddao@arsdigita.com
-- @creation-date November 09, 2000
-- @cvs-id $Id$
--

begin

    -- create the privileges
    acs_privilege.create_privilege('chat_room_create', 'Create chat room');
    acs_privilege.create_privilege('chat_room_view', 'View room information');
    acs_privilege.create_privilege('chat_room_edit', 'Edit chat room');
    acs_privilege.create_privilege('chat_room_delete', 'Delete chat room');

    acs_privilege.create_privilege('chat_transcript_create', 'Create chat transcript');
    acs_privilege.create_privilege('chat_transcript_view', 'View chat transcript');
    acs_privilege.create_privilege('chat_transcript_edit', 'Edit chat transcipt');
    acs_privilege.create_privilege('chat_transcript_delete', 'Delete chat transcript');

    acs_privilege.create_privilege('chat_room_moderate', 'Moderate chat room');

    acs_privilege.create_privilege('chat_moderator_grant', 'Add moderator to a chat room');
    acs_privilege.create_privilege('chat_moderator_revoke', 'Remove moderator from a chat room');

    acs_privilege.create_privilege('chat_user_grant', 'Grant user to a chat room');
    acs_privilege.create_privilege('chat_user_revoke', 'Remove user from a chat room');
    acs_privilege.create_privilege('chat_user_ban', ' Ban user from a chat room');
    acs_privilege.create_privilege('chat_user_unban', 'Unban user from a chat room');

    acs_privilege.create_privilege('chat_ban', 'Ban from a chat room');
    acs_privilege.create_privilege('chat_read', 'View chat message');
    acs_privilege.create_privilege('chat_write', 'Write chat message');

    -- Set of privileges for regular chat user.
    acs_privilege.create_privilege('chat_user', 'Regular chat user');
    acs_privilege.add_child('chat_user', 'chat_read');
    acs_privilege.add_child('chat_user', 'chat_write');

    -- Set of privileges for moderator of the chat room.
    acs_privilege.create_privilege('chat_moderator', 'Chat room moderator');
    acs_privilege.add_child('chat_moderator', 'chat_room_moderate');
    acs_privilege.add_child('chat_moderator', 'chat_user_ban');
    acs_privilege.add_child('chat_moderator', 'chat_user_unban');
    acs_privilege.add_child('chat_moderator', 'chat_user_grant');
    acs_privilege.add_child('chat_moderator', 'chat_user_revoke');
    acs_privilege.add_child('chat_moderator', 'chat_transcript_create');
    acs_privilege.add_child('chat_moderator', 'chat_transcript_view');
    acs_privilege.add_child('chat_moderator', 'chat_transcript_edit');
    acs_privilege.add_child('chat_moderator', 'chat_transcript_delete');
    acs_privilege.add_child('chat_moderator', 'chat_user');

    -- Set of privileges for administrator of the chat room.
    acs_privilege.create_privilege('chat_room_admin', 'Chat room administrator');
    acs_privilege.add_child('chat_room_admin', 'chat_room_create');
    acs_privilege.add_child('chat_room_admin', 'chat_room_delete');
    acs_privilege.add_child('chat_room_admin', 'chat_room_edit');
    acs_privilege.add_child('chat_room_admin', 'chat_room_view');
    acs_privilege.add_child('chat_room_admin', 'chat_moderator_grant');
    acs_privilege.add_child('chat_room_admin', 'chat_moderator_revoke');
    acs_privilege.add_child('chat_room_admin', 'chat_moderator');

    -- Site wite admin also administrator of the chat room.
    acs_privilege.add_child('admin', 'chat_room_admin');
end;
/
show errors
