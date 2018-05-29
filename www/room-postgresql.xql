<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="list_user_ban">
  <querytext>
    select person_id as party_id, first_names, last_name
    from persons
    where person_id in 
    (select acs_permission.parties_with_object_privilege(:room_id::integer, 'chat_ban'::varchar))
    order by last_name, first_names
  </querytext>
</fullquery>

</queryset>








