<master>
<property name="context">@context_bar@</property>
<property name="title">@room_name@</property>

<center>
   <applet code=adChatApplet.class archive=chat.jar width=@width@ height=@height@>
   <param name="user_id" value="@user_id@">
   <param name="user_name" value="@user_name@">
   <param name="room_id" value="@room_id@">
   <param name="host" value="@host@">
   <param name="port" value="@port@">
   <if @moderator_p@ eq "1">
   <param name="moderator" value="true">
   </if>
   </applet>
</center>