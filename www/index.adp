<!--
     Display a list of available rooms.

     @author David Dao (ddao@arsidigta.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">Chat main page</property>

<if @room_create_p@ ne 0>
[<a href="room-new">Create a new room</a>]
</if>

<if @rooms:rowcount@ eq 0>
<p><i>There are no rooms available.</i>
</if>
<else>
<table>
    <multiple name=rooms>
    <tr>
	<td valign=top><dt><p><b>@rooms.pretty_name@</b></td>
	<td valign=top> 
            [<a href="room-enter?room_id=@rooms.room_id@&client=html">HTML chat</a>] 
            [<a href="room-enter?room_id=@rooms.room_id@&client=java">Java chat</a>]
	    <if @rooms.admin_p@ eq "t">[<a href="room?room_id=@rooms.room_id@">room admin</a>]</if>
        </td>
	<td valign=top>
        <i>@rooms.description@</i></td>
     </tr>
     </multiple>
</table>
</else>
