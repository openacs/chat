ad_page_contract {

    Show available chat transcripts

    @author Peter Alberer (peter@alberer.com)
    @creation-date March 26, 2006
} {
    room_id:naturalnum,notnull
}

if { [catch {
  set r [::xo::db::Class get_instance_from_db -id $room_id]
  set room_name [$r set pretty_name]
} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
    ad_script_abort
}

set active  [$r set active_p]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
