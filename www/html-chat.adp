<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">@room_name;noquote@</property>

<style type='text/css'>
#messages { margin-right:15px; float:left; width:70%; height:250px; overflow:auto; border:1px solid black; padding:5px; font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#messages .timestamp {vertical-align: top; color: #CCCCCC; }
#messages .user {margin: 0px 5px; text-align: right; vertical-align: top; font-weight:bold;}
#messages .message {vertical-align: top;}
#messages .line {margin:0px;}
#users { float:right; width:25%; height:250px; border:1px solid black; padding:5px; font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#users .user {text-align: left; vertical-align: top; font-weight:bold; }
#users .timestamp {text-align: right; vertical-align: top; }
</style>

<p>
<a href="room-exit?room_id=@room_id@" class=button title="#chat.exit_msg#">#chat.Log_off#</a>
<a href="chat-transcript?room_id=@room_id@" class=button title="#chat.transcription_msg#" >#chat.Transcript#</a>
<a href="room-enter?room_id=@room_id@&client=@richclient.short@#xj220" class=button title="@richclient.msg@" >@richclient.title@</a>
</p>

<div id='messages'>
@html_chat;noquote@
<a id="xj220" name="#xj220"></a>
</div>

<div id='users'>
    <table width="100%"><tbody>@html_users;noquote@</tbody></table>
</div>

<br clear="all"><br>

<form method=post action="chat#xj220">
#chat.message#: <input tabindex='1' type='text' size='80' name='message' id='chatMsg'>
<input type=hidden name="room_id" value="@room_id@">
<input type=hidden name="client" value="html">
<input type=submit value="#chat.Send_Refresh#">
</form>

