<master>
<property name="context">@context;literal@</property>
<property name="&doc">doc</property>
<property name="focus">ichat_form.msg</property>

<h1>@doc.title@</h1>
<p>
    <a href="room-exit?room_id=@room_id@" class="button" title="#chat.exit_msg#">#chat.Log_off#</a> 
    <a href="chat-transcript?room_id=@room_id@" class="button" title="#chat.transcription_msg#">#chat.Transcript#</a>
</p>

<div id="xowiki-chat-container">
    @chat_frame;noquote@
</div>
