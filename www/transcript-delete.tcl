#/chat/www/transcript-delete.tcl
ad_page_contract {
    Display confirmation before delete chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
    transcript_id:naturalnum,notnull
} -properties {
    context_bar:onevalue
    room_id:onevalue
    transcript_id:onevalue
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_delete

set t [::xo::db::Class get_instance_from_db -id $transcript_id]
set transcript_name [$t set pretty_name]

set context [list "[_ chat.Delete_transcript]"]
ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
