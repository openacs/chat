<?xml version="1.0" encoding="utf-8"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="rooms_list">
  <querytext>
    select rm.room_id,
           rm.pretty_name,
           rm.description,
           rm.moderated_p,
           rm.active_p,
           rm.archive_p
     from chat_rooms rm,
          acs_objects obj
    where rm.room_id = obj.object_id
      and obj.package_id = :package_id
      and acs_permission.permission_p(rm.room_id, :user_id, 'chat_read')
    order by rm.pretty_name
  </querytext>
</fullquery>

</queryset>