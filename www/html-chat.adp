<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">@room_name;noquote@</property>

<a href="room-exit?room_id=@room_id@" class=button title="#chat.exit_msg#">#chat.Log_off#</a>
<a href="chat-transcript?room_id=@room_id@" class=button title="#chat.transcription_msg#" >#chat.Trascript#</a>
<a href="room-enter?room_id=@room_id@&client=@richclient.short@" class=button title="@richclient.msg@" >@richclient.title@</a>
<p>

<form method=post action="chat">
#chat.Chat#: <input name=message size=40>
<input type=hidden name="room_id" value="@room_id@">
<input type=hidden name="client" value="html">
<input type=submit value="#chat.Send_Refresh#">
</form>

<listtemplate name="chat_msg" id="messages"></listtemplate>
