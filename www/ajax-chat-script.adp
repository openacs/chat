<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">@room_name;noquote@</property>
<property name="focus">ichat_form.msg</property>

<p>
<a href="room-exit?room_id=@room_id@" class="button" title="#chat.exit_msg#">#chat.Log_off#</a> 
<a href="chat-transcript?room_id=@room_id@" class="button" title="#chat.transcription_msg#">#chat.Transcript#</a>
<a href="room-enter?room_id=@room_id@&client=html" class="button" title="#chat.html_client_msg#">#chat.Hml#</a>
</p>

@chat_frame;noquote@
