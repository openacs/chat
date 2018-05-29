<?xml version="1.0" encoding="utf-8"?>
o<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="list_user_ban">
  <querytext>
    select person_id as party_id, first_names, last_name    
    from acs_object_party_privilege_map m, persons p
    where m.object_id = :room_id
      and m.party_id = person_id
      and m.privilege = 'chat_ban'
    order by last_name, first_names
  </querytext>
</fullquery>

</queryset>








