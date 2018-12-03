<master>
<property name="context">@context;literal@</property>
<property name="doc(title)">#chat.transcript_of_room# "@room_name;noquote@"</property>

<if @transcript_id;literal@ eq 0>
<include src="/packages/chat/lib/current-messages" room_id=@room_id;literal@>
</if>
<else>
<include src="/packages/chat/lib/transcript-view" room_id=@room_id;literal@ transcript_id=@transcript_id;literal@>
</else>
