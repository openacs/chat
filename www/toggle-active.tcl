ad_page_contract {

    Toggle chat room active state

} {
    room_id:object_type(chat_room)
    {return_url:localurl .}
}

permission::require_permission -object_id [ad_conn package_id] -privilege chat_room_edit

set r [::xo::db::Class get_instance_from_db -id $room_id]
$r set active_p [expr {![$r set active_p]}]
$r save

ad_returnredirect $return_url
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
