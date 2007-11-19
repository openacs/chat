<!--
     Display a list of available rooms.

     @author David Dao (ddao@arsidigta.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">#chat.Chat_main_page#</property>
<property name="title">#chat.Chat_main_page#</property>

<if @warning@ not nil>
<div style="border: 1px solid red; padding: 5px; margin: 10px;">
    @warning;noquote@
</div>
</if>

<if @rooms:rowcount@ eq 0>
<p><i>#chat.There_are_no_rooms_available#</i></p>
<if @room_create_p@ eq 1><p><a class="button" href="room-edit">#chat.Create_a_new_room#</a></p></if>
</if>
<else>
<listtemplate name="rooms"></listtemplate>
</else>

