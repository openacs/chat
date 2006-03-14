<!--
     Display a list of available rooms.

     @author David Dao (ddao@arsidigta.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#chat.Chat_main_page#</property>



<if @room_create_p@ ne 0>
[<a href="room-new">#chat.Create_a_new_room#</a>]
</if>

<if @rooms:rowcount@ eq 0>
<p><i>#chat.There_are_no_rooms_available#</i>
</if>
<else>
<table>
    <multiple name=rooms>
    <%
    set can_see 0
    if {($rooms(active_p) eq "t" && $rooms(user_p) eq "t") || ($rooms(admin_p) eq "t")} {
      set can_see 1
    }   
    %>
    <if @can_see@ eq 1>
      <tr>
        <td valign=top>@rooms.pretty_name@</td>
        <td valign=top>
            [&nbsp;<a href="@rooms.base_url@room-enter?room_id=@rooms.room_id@&client=html">HTML</a>&nbsp;|&nbsp;<a href="@rooms.base_url@room-enter?room_id=@rooms.room_id@&client=java">java</a>&nbsp;]
        </td>
        <td valign=top>
        <if @rooms.admin_p@ eq "t">
          [<a href="@rooms.base_url@room?room_id=@rooms.room_id@">#chat.room_admin#</a>] 
        </if>
        <if @rooms.active_p@ ne "t">
          (NO #chat.Active#)
        </if>
        <% set desc [string range $rooms(description) 0 50] %>
        <td valign=top>
            <I>@desc@</I>
        </td>
      </tr>            
    </if>
    </multiple>
</table>
</else>
