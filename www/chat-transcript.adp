<master>
<property name="context">@context;literal@</property>
<property name="doc(title)">#chat.transcript_of_room# "@room_name;noquote@"</property>

<include src="/packages/chat/lib/current-messages" room_id=@room_id;literal@>
