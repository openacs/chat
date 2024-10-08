ad_page_contract {

} {
    type:notnull
    room_id:object_type(chat_room)
}

set context [list "Users"]

db_1row users_n_users {}

set n_users [lc_numeric $n_users]
set last_registration [lc_time_fmt $last_registration "%q"]

set groups [db_html_select_value_options groups_select {
    select groups.group_id,
           groups.group_name,
           m.num as n_members,
           c.num as n_components
    from   groups,
           (select group_id, count(*) as num
            from group_member_map group by group_id) m,
           (select group_id, count(*) as num
            from group_component_map group by group_id) c
    where  groups.group_id=m.group_id
    and    groups.group_id = c.group_id
    order  by group_name
} ]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
