--
-- packages/chat/sql/chat-create.sql
--
-- @author ddao@arsdigita.com
-- @creation-date November 09, 2000
-- @cvs-id $Id$
--


-- create the privileges
select acs_privilege__create_privilege('chat_room_create', 'Create chat room', null);
select acs_privilege__create_privilege('chat_room_view', 'View room information', null);
select acs_privilege__create_privilege('chat_room_edit', 'Edit chat room', null);
select acs_privilege__create_privilege('chat_room_delete', 'Delete chat room', null);

select acs_privilege__create_privilege('chat_transcript_create', 'Create chat transcript', null);
select acs_privilege__create_privilege('chat_transcript_view', 'View chat transcript', null);
select acs_privilege__create_privilege('chat_transcript_edit', 'Edit chat transcipt', null);
select acs_privilege__create_privilege('chat_transcript_delete', 'Delete chat transcript', null);

select acs_privilege__create_privilege('chat_room_moderate', 'Moderate chat room', null);

select acs_privilege__create_privilege('chat_moderator_grant', 'Add moderator to a chat room', null);
select acs_privilege__create_privilege('chat_moderator_revoke', 'Remove moderator from a chat room', null);

select acs_privilege__create_privilege('chat_user_grant', 'Grant user to a chat room', null);
select acs_privilege__create_privilege('chat_user_revoke', 'Remove user from a chat room', null);
select acs_privilege__create_privilege('chat_user_ban', ' Ban user from a chat room', null);
select acs_privilege__create_privilege('chat_user_unban', 'Unban user from a chat room', null);

select acs_privilege__create_privilege('chat_ban', 'Ban from a chat room', null);
select acs_privilege__create_privilege('chat_read', 'View chat message', null);
select acs_privilege__create_privilege('chat_write', 'Write chat message', null);

select acs_privilege__create_privilege('chat_avatar_allow', 'Enable/disable user avatars in a chat room', null);

-- Set of privileges for regular chat user.
select acs_privilege__create_privilege('chat_user', 'Regular chat user', null);
select acs_privilege__add_child('chat_user', 'chat_read');
select acs_privilege__add_child('chat_user', 'chat_write');

-- Set of privileges for moderator of the chat room.
select acs_privilege__create_privilege('chat_moderator', 'Chat room moderator', null);
select acs_privilege__add_child('chat_moderator', 'chat_room_moderate');
select acs_privilege__add_child('chat_moderator', 'chat_user_ban');
select acs_privilege__add_child('chat_moderator', 'chat_user_unban');
select acs_privilege__add_child('chat_moderator', 'chat_user_grant');
select acs_privilege__add_child('chat_moderator', 'chat_user_revoke');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_create');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_view');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_edit');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_delete');
select acs_privilege__add_child('chat_moderator', 'chat_user');

 -- Set of privileges for administrator of the chat room.
select acs_privilege__create_privilege('chat_room_admin', 'Chat room administrator', null);
select acs_privilege__add_child('chat_room_admin', 'chat_room_create');
select acs_privilege__add_child('chat_room_admin', 'chat_room_delete');
select acs_privilege__add_child('chat_room_admin', 'chat_room_edit');
select acs_privilege__add_child('chat_room_admin', 'chat_room_view');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator_grant');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator_revoke');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator');
select acs_privilege__add_child('chat_room_admin', 'chat_avatar_allow');

-- Site wite admin also administrator of the chat room.
select acs_privilege__add_child('admin', 'chat_room_admin');
