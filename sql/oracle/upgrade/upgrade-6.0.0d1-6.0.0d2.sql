---
--- Upgrade script from 6.0.0d1 to 6.0.0d2
---
--- Remove the unused privilege 'chat_avatar_allow'
---
--- @author Hector Romojaro (hector.romojaro@gmail.com)
--- @creation-date 01/03/2019
--- @cvs-id $Id$
---

acs_privilege.remove_child('chat_room_admin', 'chat_avatar_allow');
acs_privilege.drop_privilege('chat_avatar_allow');
