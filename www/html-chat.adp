<master src="master">
<property name="context">@context_bar@</property>
<property name="title">@room_name@</property>

[<a href="room-exit?room_id=@room_id@">Log off</a>]
<form method=post action="chat">
Chat: <input name=message size=40>

<input type=hidden name="room_id" value="@room_id@">
<input type=hidden name="client" value="html">
<input type=submit value="Send/Refresh">
</form>

<ul>

<if @message@ ne "">
<if @moderator_p@ eq "1">
@user_name@: @message@<br>
</if>
</if>
<multiple name=msgs>
@msgs.screen_name@: @msgs.chat_msg@<br>
</multiple>

</ul>
