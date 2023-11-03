<master>
<property name="context">@context;literal@</property>
<property name="&doc">doc</property>

<h1>@doc.title@</h1>

<p id=>#chat.active_users#: <span id="active_users"></span></p>

<button id="enableNotifications" style="display: none;">#chat.Enable_web_notifications#</button>
<p>
    <a href="room-exit?room_id=@room_id@" class="button" title="#chat.exit_msg#">#chat.Log_off#</a> 
    <a href="chat-transcript?room_id=@room_id@" class="button" title="#chat.transcription_msg#">#chat.Transcript#</a>
</p>
<include src="/packages/chat/lib/chat" room_id="@room_id;literal@">
