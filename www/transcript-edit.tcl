#/chat/www/transcript-edit.tcl
ad_page_contract {
    Retrieve transcript content.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
    transcript_id:object_type(chat_transcript)
}

permission::require_permission -object_id $transcript_id -privilege chat_transcript_edit
set context_bar [list "[_ chat.Edit_transcript]"]

set submit_label "[_ chat.Edit]"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set active_p [$r set active_p]

set t [::xo::db::Class get_instance_from_db -id $transcript_id]
set pretty_name [lang::util::localize [$t set pretty_name]]
set description [lang::util::localize [$t set description]]
set contents    [lang::util::localize [$t set contents]]

ad_form \
    -mode display \
    -name "edit-transcription" \
    -form {
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
}

if { [template::form::get_action "edit-transcription"] eq "" } {
    ad_form -extend -name "edit-transcription" -form {
        {contents:text(inform)
            {label "#chat.Transcript#" }
            {html {rows 6 cols 65}}
            {noquote noquote}
            {value "<pre>$contents</pre>"}
        }
    }
} else {
    ad_form -extend -name "edit-transcription" -form {
        {contents:text(textarea)
            {label "#chat.Transcript#" }
            {html {rows 6 cols 65}}
            {value "$contents"}
        }
    }  -on_submit {
        $t set pretty_name $pretty_name
        $t set description $description
        $t set contents    $contents
        $t save
        ad_returnredirect [export_vars -base "transcript-edit" {transcript_id room_id}]
        ad_script_abort
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
