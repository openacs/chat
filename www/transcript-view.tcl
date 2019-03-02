#/chat/www/transcript-view.tcl
ad_page_contract {
    Preview chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
} {
    transcript_id:naturalnum,notnull
} -properties {
    context_bar:onevalue
    transcript_name:onevalue
    transcript_id:onevalue
    room_id:onevalue
    description:onevalue
    contents:onevalue
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_view

set context_bar [list "[_ chat.View_transcript]"]
set t [::xo::db::Class get_instance_from_db -id $transcript_id]
set transcript_name [$t set transcript_name]
set description     [$t set description]
set contents        [$t set contents]
set room_is         [$t set room_id]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
