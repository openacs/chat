<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#chat.transcript_of_room# "@room_name;noquote@"</property>

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

<if @transcript_id@ eq 0>
<include src="/packages/chat/lib/current-messages" room_id=@room_id@>
</if>
<else>
<include src="/packages/chat/lib/transcript-view" room_id=@room_id@ transcript_id=@transcript_id@ write_p=@write_p@>
</else>
