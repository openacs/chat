<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="list_user_ban">
  <querytext>
   select m.party_id, p.last_name || ', ' || p.first_names as name, pa.email
    from persons p, parties pa
    where p.person_id = pa.party_id
    and acs_permission__permission_p(:room_id, pa.party_id, 'chat_ban')
    order by p.last_name, p.first_names
  </querytext>
</fullquery>

</queryset>








