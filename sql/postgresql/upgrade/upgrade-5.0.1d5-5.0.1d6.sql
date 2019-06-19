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

    select acs_privilege__create_privilege('chat_avatar_allow', 'Enable/disable user avatars in a chat room', null);
    select acs_privilege__add_child('chat_room_admin', 'chat_avatar_allow');

end;
