
set transcript_delete_p [permission::permission_p -object_id $room_id -privilege chat_transcript_delete]
set transcript_view_p [permission::permission_p -object_id $room_id -privilege chat_transcript_view]

# List available chat transcript
db_multirow -extend { creation_date_pretty viewer } chat_transcripts list_transcripts *SQL* {
    set creation_date_pretty [lc_time_fmt $creation_date "%q %X"]
}

list::create \
    -name "chat_transcripts" \
    -multirow "chat_transcripts" \
    -key transcript_id \
    -pass_properties { transcript_delete_p room_id } \
    -row_pretty_plural [_ chat.Transcripts] \
    -elements {
        pretty_name {
            label "#chat.Name#"
            link_url_eval {chat-transcript?room_id=$room_id&transcript_id=$transcript_id}
        }
        creation_date_pretty {
            label "#chat.creation_date#"
        }
        actions {
            label "#chat.actions#"
            html { align "center" }
            display_template {
                <if @transcript_delete_p@ eq "1">
                <a href="transcript-delete?transcript_id=@chat_transcripts.transcript_id@&room_id=@room_id@">
                <img src="/shared/images/Delete16.gif" border="0">
                </a>
                </if>
            }
        }
    }
