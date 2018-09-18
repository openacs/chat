<master>
<property name="context">@context;literal@</property>
<property name="&doc">doc</property>
<property name="focus">ichat_form.msg</property>

<style type='text/css'>
   #ichat {
       width:70%;
       height:257px;
       border:1px solid black;
       margin-right:15px;
   }
   #ichat-users {
       height:257px;
       width:25%;
       border:1px solid black;
   }
   #ichat-message {
       margin-top:10px;
   }
</style>

<h1>@doc.title@</h1>
<p>
<a href="room-exit?room_id=@room_id@" class="button" title="#chat.exit_msg#">#chat.Log_off#</a> 
<a href="chat-transcript?room_id=@room_id@" class="button" title="#chat.transcription_msg#">#chat.Transcript#</a>
<a href="@html_room_url@" class="button" title="#chat.html_client_msg#">#chat.Hml#</a>
</p>

@chat_frame;noquote@
