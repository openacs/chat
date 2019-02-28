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

    acs_privilege.create_privilege('chat_avatar_allow', 'Enable/disable user avatars in a chat room');

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
    acs_privilege.add_child('chat_room_admin', 'chat_avatar_allow');

    -- Site wite admin also administrator of the chat room.
    acs_privilege.add_child('admin', 'chat_room_admin');
end;
/
show errors


declare
    attr_id acs_attributes.attribute_id%TYPE;
begin
    -- create chat room object type
    acs_object_type.create_type (
        supertype      => 'acs_object',
        object_type    => 'chat_room',
        pretty_name    => 'Chat Room',
        pretty_plural  => 'Chat Rooms',
        table_name     => 'CHAT_ROOMS',
        id_column      => 'ROOM_ID'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'pretty_name',
        pretty_name    => 'Room name',
        pretty_plural  => 'Room names',
        datatype       => 'string'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'description',
        pretty_name    => 'Description',
        pretty_plural  => 'Descriptions',
        datatype       => 'string'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'moderated_p',
        pretty_name    => 'Moderated',
        pretty_plural  => 'Moderated',
        datatype       => 'boolean'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'active_p',
        pretty_name    => 'Activated',
        pretty_plural  => 'Activated',
        datatype       => 'boolean'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'archive_p',
        pretty_name    => 'Archived',
        pretty_plural  => 'Archived',
        datatype       => 'boolean'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'avatar_p',
        pretty_name    => 'Avatar',
        pretty_plural  => 'Avatars',
        datatype       => 'boolean'
    );
end;
/
show errors;

create table chat_rooms (
    room_id            integer
                       constraint chat_rooms_room_id_pk primary key
                       constraint chat_rooms_room_id_fk
                       references acs_objects(object_id) on delete cascade,
    -- This is room name.
    pretty_name        varchar2(100)
                       constraint chat_rooms_pretty_name_nn not null,
    description        varchar2(2000),
    moderated_p        char(1) default 'f'
                       constraint chat_rooms_moderate_p_ck
                       check (moderated_p in ('t','f')),
    active_p           char(1) default 't'
                       constraint chat_rooms_active_p_ck
                       check (active_p in ('t','f')),
    -- if set then log all chat messages in this room.
    archive_p          char(1) default 'f'
                       constraint chat_rooms_archive_p_ck
                       check (archive_p in ('t', 'f')),
    auto_flush_p       char(1) default 't'
                       constraint chat_rooms_auto_flush_ck
                       check (auto_flush_p in ('t', 'f')),
    auto_transcript_p  char(1) default 'f'
                       constraint chat_rooms_auto_transcript_ck
                       check (auto_transcript_p in ('t', 'f')),
    login_messages_p  char(1) default 't'
                       constraint chat_rooms_login_messages_ck
                       check (login_messages_p in ('t', 'f')),
    logout_messages_p  char(1) default 't'
                       constraint chat_rooms_logout_messages_ck
                       check (logout_messages_p in ('t', 'f')),
    -- set how much in the past users will see when entering a chat in
    -- seconds this is needed to specify, for example, that users will
    -- see only the previous 10 minutes of the conversation
    messages_time_window integer default 600,
    avatar_p           char(1) default 't'
                       constraint chat_rooms_avatar_p_ck
                       check (avatar_p in ('t', 'f'))
);

declare
    attr_id acs_attributes.attribute_id%TYPE;
begin
    -- create chat transcript object type
    acs_object_type.create_type (
        supertype      => 'acs_object',
        object_type    => 'chat_transcript',
        pretty_name    => 'Chat Transcript',
        pretty_plural  => 'Chat Transcripts',
        table_name     => 'CHAT_TRANSCRIPTS',
        id_column      => 'TRANSCRIPT_ID'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_transcript',
        attribute_name => 'pretty_name',
        pretty_name    => 'Transcript name',
        pretty_plural  => 'Transcript names',
        datatype       => 'string'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_transcript',
        attribute_name => 'description',
        pretty_name    => 'Description',
        pretty_plural  => 'Descriptions',
        datatype       => 'string'
    );

    attr_id := acs_attribute.create_attribute (
        object_type    => 'chat_transcript',
        attribute_name => 'contents',
        pretty_name    => 'Transcript content',
        pretty_plural  => 'Transcript contents',
        datatype       => 'string'
    );
end;
/
show errors

create table chat_transcripts (
    transcript_id      integer
                       constraint chat_trans_transcript_id_pk primary key
                       constraint chat_trans_transcript_id_fk
                       references acs_objects(object_id) on delete cascade,
    contents           clob
                       constraint chat_trans_contents_nn not null,
    -- Chat transcript name.
    pretty_name        varchar2(100)
                       constraint chat_trans_pretty_name_nn not null,
    description        varchar2(2000),
    room_id            integer
                       constraint chat_trans_room_id_fk
                       references chat_rooms(room_id) on delete cascade
);

create table chat_msgs (
    msg_id             integer
                       constraint chat_msgs_msg_id_pk primary key,
    msg                varchar2(4000),
    msg_len            integer
                       constraint chat_msgs_msg_len_ck
                       check (msg_len >= 0),
    html_p             char(1) default 'f'
                       constraint chat_msgs_html_p_ck
                       check (html_p in ('t','f')),
    approved_p         char(1) default 't'
                       constraint chat_msgs_approve_p_ck
                       check(approved_p in ('t','f')),
    creation_user      integer
                       constraint chat_msgs_creation_user_fk
                       references parties(party_id) on delete cascade
                       constraint chat_msgs_creation_user_nn not null,
    creation_ip        varchar2(50) ,
    creation_date      date
                       constraint chat_msgs_creation_date_nn not null,
    room_id            integer
                       constraint chat_msgs_room_id_fk
                       references chat_rooms(room_id) on delete cascade
);

