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

set transcript_name [db_string query {
    select pretty_name from chat_transcripts
    where transcript_id = :transcript_id
}]

set context [list "[_ chat.Delete_transcript]"]
ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
