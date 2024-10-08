ad_include_contract {
    This include is the UI to display and manage chat room transcripts
} {
    room_id:object_type(chat_room)
}

set transcript_create_p [permission::permission_p -object_id $room_id -privilege chat_transcript_create]
set transcript_delete_p [permission::permission_p -object_id $room_id -privilege chat_transcript_delete]
set transcript_view_p   [permission::permission_p -object_id $room_id -privilege chat_transcript_view]

# List available chat transcript
db_multirow -extend {
    creation_date_pretty
    viewer
    transcript_url
    delete_url
} chat_transcripts list_transcripts {
    select ct.transcript_id, ct.pretty_name, ao.creation_date
    from chat_transcripts ct, acs_objects ao
    where ct.transcript_id = ao.object_id and ct.room_id = :room_id
    order by ao.creation_date desc
} {
    set creation_date_pretty [lc_time_fmt $creation_date "%q %X"]
    set transcript_url [export_vars -base "transcript-edit" {room_id transcript_id}]
    set delete_url [export_vars -base "transcript-delete" {room_id transcript_id}]
}

set actions {}
if {$transcript_create_p} {
    lappend actions \
        [_ chat.Create_transcript] [export_vars -base "transcript-new" {room_id}] ""
}

list::create \
    -name "chat_transcripts" \
    -multirow "chat_transcripts" \
    -key transcript_id \
    -pass_properties { transcript_delete_p room_id } \
    -row_pretty_plural [_ chat.Transcripts] \
    -actions $actions \
    -elements {
        pretty_name {
            label "#chat.Name#"
            link_url_col transcript_url
            link_html {title "[_ chat.View_transcript]"}
        }
        creation_date_pretty {
            label "#chat.creation_date#"
        }
        actions {
            label "#chat.actions#"
            html { align "center" }
            display_template {
                <if @transcript_delete_p;literal@ true>
                <a href="@chat_transcripts.delete_url@">
                <adp:icon name="trash" title="#chat.Delete_transcript#">
                </a>
                </if>
            }
        }
    }

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
