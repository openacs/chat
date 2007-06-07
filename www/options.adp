<master>
<property name="title">#chat.room_options#</property>

<style type='text/css'>
#messages { 
    border: 1px dotted black; 
    padding: 5px;
    margin-top:10px; 
    font-size: 12px; 
    color: #666666; 
    font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; 
}
#messages .timestamp {vertical-align: top; color: #CCCCCC; }
#messages .user {text-align: right; vertical-align: top; font-weight:bold; }
#messages .message {vertical-align: top}
#messages .line {margin:0px;}
</style>


<h4>#chat.room_options#</h4>

<table border="0" cellpadding="2" cellspacing="2">
    
    <tr class="form-element">
        <td class="form-label">#chat.alias#</td>
        <td>@alias@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.rss_service#</td>
        <td>@rss_service@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.mail_service#</td>
        <td>@mail_service@</td>
    </tr>  
    
</table>
<p>
<a class="button" href="options2?room_id=@room_id@&action=@action@">#chat.edit_room_options#</a>
</p>


<p><b>#chat.Transcripts#</b>
<include src="/packages/chat/lib/transcripts" room_id=@room_id@>
</p>
<h4>#chat.current_transcript#</h4>
<p>
<include src="/packages/chat/lib/current-messages" room_id=@room_id@>
</p>

