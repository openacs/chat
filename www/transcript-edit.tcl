#/chat/www/transcript-edit.tcl
ad_page_contract {
    Retrieve transcript content.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
} {
    transcript_id:naturalnum,notnull
    room_id:naturalnum,notnull
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_edit
set context_bar [list "[_ chat.Edit_transcript]"]

set submit_label "[_ chat.Edit]"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set active_p [$r set active_p]

set t [::xo::db::Class get_instance_from_db -id $transcript_id]
set pretty_name [$t set pretty_name]
set description [$t set description]
set contents    [$t set contents]

ad_form -name "edit-transcription" -edit_buttons [list [list [_ chat.Edit] next]] -has_edit 1 -form {
    {room_id:integer(hidden)
        {value $room_id}
    }
    {transcript_id:integer(hidden)
        {value $transcript_id}
    }
    {pretty_name:text(text)
        {label "#chat.Transcript_name#" }
        {value $pretty_name}
    }
    {description:text(textarea),optional
        {label "#chat.Description#" }
        {html {rows 6 cols 65}}
        {value $description}
    }
    {contents:text(textarea)
        {label "#chat.Transcript#" }
        {html {rows 6 cols 65}}
        {value $contents}
    }
} -on_submit {
    $t set pretty_name $pretty_name
    $t set description $description
    $t set contents    $contents
    if { [catch {
        $t save
    } errmsg] } {
        ad_return_complaint 1 "[_ chat.Could_not_update_transcript]: $errmsg"
    } else {
        ad_returnredirect [export_vars -base "chat-transcript" {transcript_id room_id}]
    }
    ad_script_abort
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
