--
-- packages/chat/sql/chat-drop.sql
--
-- @author ddao@arsdigita.com
-- @creation-date November 09, 2000
-- @cvs-id $Id$
--

--
-- Drop chat_room object types and tables
--
select acs_object_type__drop_type('chat_transcript','t', 't');
select acs_object_type__drop_type('chat_room','t', 't');

drop table chat_msgs;


--
-- Drop all chat privileges
--
CREATE OR REPLACE FUNCTION inline_0 () RETURNS integer AS $$
BEGIN

  -- Drop child privileges for regular chat user.
 PERFORM acs_privilege__remove_child('chat_user', 'chat_read');
 PERFORM acs_privilege__remove_child('chat_user', 'chat_write');

 -- Drop child privileges for chat moderator.
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_room_moderate');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_user_ban');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_user_unban');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_user_grant');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_user_revoke');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_transcript_create');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_transcript_view');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_transcript_edit');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_transcript_delete');
 PERFORM acs_privilege__remove_child('chat_moderator', 'chat_user');

  -- Drop child privileges for chat administrator.
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_room_create');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_room_delete');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_room_edit');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_room_view');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_moderator_grant');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_moderator_revoke');
 PERFORM acs_privilege__remove_child('chat_room_admin', 'chat_moderator');

 -- remove site-wide admin also administrator of the chat room
 PERFORM acs_privilege__remove_child('admin', 'chat_room_admin');

 PERFORM acs_privilege__drop_privilege('chat_room_create');
 PERFORM acs_privilege__drop_privilege('chat_room_view');
 PERFORM acs_privilege__drop_privilege('chat_room_edit');
 PERFORM acs_privilege__drop_privilege('chat_room_delete');
 PERFORM acs_privilege__drop_privilege('chat_transcript_create');
 PERFORM acs_privilege__drop_privilege('chat_transcript_view');
 PERFORM acs_privilege__drop_privilege('chat_transcript_edit');
 PERFORM acs_privilege__drop_privilege('chat_transcript_delete');
 PERFORM acs_privilege__drop_privilege('chat_room_moderate');
 PERFORM acs_privilege__drop_privilege('chat_moderator_grant');
 PERFORM acs_privilege__drop_privilege('chat_moderator_revoke');
 PERFORM acs_privilege__drop_privilege('chat_user_grant');
 PERFORM acs_privilege__drop_privilege('chat_user_revoke');
 PERFORM acs_privilege__drop_privilege('chat_user_ban');
 PERFORM acs_privilege__drop_privilege('chat_user_unban');
 PERFORM acs_privilege__drop_privilege('chat_ban');
 PERFORM acs_privilege__drop_privilege('chat_read');
 PERFORM acs_privilege__drop_privilege('chat_write');
 PERFORM acs_privilege__drop_privilege('chat_room_admin');
 PERFORM acs_privilege__drop_privilege('chat_moderator');
 PERFORM acs_privilege__drop_privilege('chat_user');

  return 0;
END;
$$ LANGUAGE plpgsql;

select inline_0 ();
drop function inline_0 ();
