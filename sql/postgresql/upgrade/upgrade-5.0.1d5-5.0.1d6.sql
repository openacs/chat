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

    -- alter table chat_rooms add column avatar_p boolean default 't';

    -- select acs_privilege__create_privilege('chat_avatar_allow', 'Enable/disable user avatars in a chat room', null);
    -- select acs_privilege__add_child('chat_room_admin', 'chat_avatar_allow');
    -- select acs_attribute__create_attribute('chat_room','avatar_p','boolean','Avatar','Avatars',null,null,'t',1,1,null,'type_specific','f');

end;
