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
db_1row get_transcript {
    select pretty_name as transcript_name,
           description,
           contents,
           room_id
    from chat_transcripts
    where transcript_id=:transcript_id
}

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
