#/chat/www/transcript-edit.tcl
ad_page_contract {
    Retrieve transcript content.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
    
} {
    transcript_id:integer,notnull
    room_id:integer,notnull
} 

permission::require_permission -object_id $transcript_id -privilege chat_transcript_edit
set context_bar [list "[_ chat.Edit_transcript]"]

set submit_label "[_ chat.Edit]"
set active_p [room_active_status $room_id]

db_1row get_transcript_info {
    select ct.pretty_name, ct.description, ct.contents
    from chat_transcripts ct
    where transcript_id = :transcript_id    
}
set keywords ""
db_foreach get_transcript_info2 {
    select ck.keyword as key
    from chat_room_transcript_keywords ck
    where ck.transcript_id = :transcript_id    
} {
	append keywords $key " "
}


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
    {keywords:text(textarea),optional
        {label "#chat.keywords#" }
        {html {rows 6 cols 65}}
        {value $keywords}
    }
    {contents:text(textarea)
        {label "#chat.Transcript#" }
        {html {rows 3 cols 65}}
        {value $contents}
    }
} -on_submit {
    if { [catch {chat_transcript_edit $transcript_id $pretty_name $description $contents} errmsg] } {
        ad_return_complaint 1 "[_ chat.Could_not_update_transcript]: $errmsg"
    }    
    chat_transcript_edit_keywords $transcript_id $keywords
    
    ad_returnredirect "chat-transcript?transcript_id=$transcript_id&room_id=$room_id"    
}
