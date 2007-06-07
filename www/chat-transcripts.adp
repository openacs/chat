<master>
<property name="context">#chat.Transcripts#</property>
<property name="title">#chat.transcript_of_room# "@room_name;noquote@"</property>

<if @active@ eq "t">
<p><table><tr><td><a class="button" href="chat-transcript?room_id=@room_id@">#chat.current_transcript#</a></td><td><a class="button" href="chat-transcript-search?room_id=@room_id@">#chat.search_transcription#</a></td></tr></table></p><br>
</if>
<else>
<br>
</else>

<include src="/packages/chat/lib/transcripts" room_id=@room_id@>
