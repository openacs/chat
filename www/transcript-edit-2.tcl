#/chat/www/transcript-edit-2.tcl
ad_page_contract {
    Update chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
} {
    transcript_id:notnull,naturalnum
    transcript_name:trim,notnull
    contents:html,notnull
    room_id:notnull,naturalnum
    {description:trim ""}
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_edit

if { [catch {chat_transcript_edit $transcript_id $transcript_name $description $contents} errmsg] } {
    ad_return_complaint 1 "[_ chat.Could_not_update_transcript]: $errmsg"
    ad_script_abort
}

ad_returnredirect "transcript-view?transcript_id=$transcript_id&room_id=$room_id"
ad_script_abort

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
