<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="rooms_list">
  <querytext>
  select
    rm.room_id, rm.pretty_name, rm.description, rm.active_p, rm.archive_p
  from
    acs_permission.permission_p_recursive_array(array(
       select object_id from acs_objects where package_id = :package_id
    ), :user_id, 'chat_read') p
  join chat_rooms rm on (p.orig_object_id = rm.room_id)
  order by rm.pretty_name
  </querytext>
</fullquery>

</queryset>