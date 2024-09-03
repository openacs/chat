#/chat/www/chat.tcl
ad_page_contract {

    Decide which template to use HTML or AJAX.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room),notnull
} -properties {
    context:onevalue
    room_id:onevalue
    moderator_p:onevalue
}

set r [::xo::db::Class get_instance_from_db -id $room_id]

set doc(title) [$r set pretty_name]
set context [list $doc(title)]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
