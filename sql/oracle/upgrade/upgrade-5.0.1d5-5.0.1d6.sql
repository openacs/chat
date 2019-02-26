---
--- Upgrade script from 5.0.1d5 to 5.0.1d6
---
--- Allow control over the avatar display in chat rooms
---
--- @author Hector Romojaro (hector.romojaro@gmail.com)
--- @creation-date 26/02/2019
--- @cvs-id $Id$
---

begin;

    alter table chat_rooms add column avatar_p char(1) default 't' constraint chat_rooms_avatar_p_ck check (avatar_p in ('t', 'f'));

    acs_privilege.create_privilege('chat_avatar_allow', 'Enable/disable user avatars in a chat room');
    acs_privilege.add_child('chat_room_admin', 'chat_avatar_allow');

    acs_attribute.create_attribute (
        object_type    => 'chat_room',
        attribute_name => 'avatar_p',
        pretty_name    => 'Avatar',
        pretty_plural  => 'Avatars',
        datatype       => 'boolean'
    );

end;
