<!--
     Display detail information about available room.

     @author David Dao (ddao@arsdigita.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">Room Information</property>

<h4>Room information</h4>
<if @room_view_p@ eq "1">
<ul>
<li>Room name: @pretty_name@
<li>Description: <blockquote>@description@</blockquote>
<li>Moderated: @moderated_p@
<li>Active: @active_p@
<li>Archive: @archive_p@
<if @room_edit_p@ eq "1">
<p>(<a href="room-edit?room_id=@room_id@">Edit</a>)
</if>
</ul>
</if>
<else>
<p><i>No information available.
</else>

<p><b>Users allow</b>
<ul>
<multiple name=users_allow>
   <li>@users_allow.name@
   <if @user_revoke_p@ eq "1">(<a href="user-revoke?room_id=@room_id@&party_id=@users_allow.party_id@">revoke</a>)</if>
</multiple>
   <if @user_grant_p@ eq "1">

   <p>(<a href="user-grant?room_id=@room_id@">Grant user</a>)
   </if>
</ul>
<b>Users ban</b>
<ul>
<multiple name=users_ban>
   <li>@users_ban.name@</li>
   <if @user_unban_p@ eq "1">(<a href="user-unban?room_id=@room_id@&party_id=@users_ban.party_id@">unban</a>)</if>
</multiple>
   <if @user_ban_p@ eq "1">
      <p>(<a href="user-ban?room_id=@room_id@">Ban user</a>)
   </if>
</ul>
<b>Room moderators</b>
<ul>
<multiple name=moderators>
   <li>@moderators.name@
   <if @moderator_revoke_p@ eq "1">
       (<a href="moderator-revoke?party_id=@moderators.party_id@&room_id=@room_id@">remove</a>)
   </if>
</multiple>

<if @moderator_grant_p@ eq "1">
   <p>(<a href="moderator-grant?room_id=@room_id@">Add moderator</a>)
</if>
</ul>
<p><b>Transcripts</b>
<ul>
<multiple name=chat_transcripts>
<li>@chat_transcripts.pretty_name@ 
(<a href="transcript-view?transcript_id=@chat_transcripts.transcript_id@">View</a>)
<if @transcript_delete_p@ eq "1">
 (<a href="transcript-delete?transcript_id=@chat_transcripts.transcript_id@&room_id=@room_id@">remove</a>)
</if>
</multiple>
<if @transcript_create_p@ eq "1">
<p>(<a href="transcript-new?room_id=@room_id@">Create transcript</a>)
</if>

</ul>
<if @room_delete_p@ eq "1">
<p><b>Extreme Actions</b>
<ul>
<li><a href="message-delete?room_id=@room_id@">Delete all messages in the room</a>
<li><a href="room-delete?room_id=@room_id@">Delete room</a>
</ul>
</if>

