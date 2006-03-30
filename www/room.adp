<!--
     Display detail information about available room.

     @author David Dao (ddao@arsdigita.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">#chat.Room_Information#</property>

<h4>#chat.Room_Information#</h4>
<if @room_view_p@ eq "1">
<table border="0" cellpadding="2" cellspacing="2">
    <tr class="form-element">
        <td class="form-label">#chat.Room_name#</td>
        <td>@pretty_name@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.Description#</td>
        <td>@description@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.Active#</td>
        <td>@active_p@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.message_count#</td>
        <td>@message_count@</td>
    </tr>
</table>
<if @room_edit_p@ eq "1">
<p>
<a class="button" href="room-edit?room_id=@room_id@">#chat.Edit#</a>
<a class="button" href="/permissions/one?object_id=@room_id@">#acs-kernel.common_Permissions#</a>
</if>
<if @room_delete_p@ eq "1">
<a class="button" href="message-delete?room_id=@room_id@">#chat.Delete_all_messages_in_the_room#</a>
<a class="button" href="room-delete?room_id=@room_id@">#chat.Delete_room#</a>
</if>
</if>
<else>
<p><i>#chat.No_information_available#.
</else>

<p><b>#chat.Users_ban#</b></p>
<listtemplate name="banned_users"></listtemplate>
<if @user_ban_p@ eq "1">
<p><a class="button" href="search?room_id=@room_id@&type=ban">#chat.Ban_user#</a>      
</if>
   
<p><b>#chat.Transcripts#</b>
<include src="/packages/chat/lib/transcripts" room_id=@room_id@>
<if @transcript_create_p@ eq "1">
<p><a class="button" href="transcript-new?room_id=@room_id@">#chat.Create_transcript#</a>
</if>

