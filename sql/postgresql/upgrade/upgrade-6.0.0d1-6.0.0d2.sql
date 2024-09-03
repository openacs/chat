---
--- Upgrade script from 6.0.0d1 to 6.0.0d2
---
--- Remove the unused privilege 'chat_avatar_allow'
---
--- @author Hector Romojaro (hector.romojaro@gmail.com)
--- @creation-date 01/03/2019
--- @cvs-id $Id$
---

begin;
    select acs_privilege__remove_child('chat_room_admin', 'chat_avatar_allow');
    select acs_privilege__drop_privilege('chat_avatar_allow');
end;
