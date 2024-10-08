<!--
     Display detail information about available room.

     @author David Dao (ddao@arsdigita.com)
     @creation-date November 13, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;literal@</property>
<property name="doc(title)">#chat.Room_Information#</property>

<h1>#chat.Room_Information#</h1>
<if @room_view_p;literal@ true>
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
        <td class="form-label">#chat.Archive#</td>
        <td>@archive_p@</td>
    </tr>   
    <tr class="form-element">
        <td class="form-label">#chat.AutoFlush#</td>
        <td>@auto_flush_p@</td>
    </tr>  
    <tr class="form-element">
        <td class="form-label">#chat.AutoTranscript#</td>
        <td>@auto_transcript_p@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.LoginMessages#</td>
        <td>@login_messages_p@</td>
    </tr>          
    <tr class="form-element">
        <td class="form-label">#chat.LogoutMessages#</td>
        <td>@logout_messages_p@</td>
    </tr>          
    <tr class="form-element">
        <td class="form-label">#chat.MessagesTimeWindow#</td>
        <td>@messages_time_window@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.message_count#</td>
        <td>@message_count@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.ShowAvatar#</td>
        <td>@avatar_p@</td>
    </tr>
</table>
<if @room_edit_p;literal@ true>
  <a class="button" href="room-edit?room_id=@room_id@">#chat.Edit#</a>
  <a class="button" href="/permissions/one?object_id=@room_id@">#acs-kernel.common_Permissions#</a>
</if>
<if @room_delete_p;literal@ true>
  <a class="button" href="message-delete?room_id=@room_id@">#chat.Delete_all_messages_in_the_room#</a>
  <a class="button" href="room-delete?room_id=@room_id@">#chat.Delete_room#</a>
</if>
</if>
<else>
  <p><em>#chat.No_information_available#</em></p>
</else>

<h2>#chat.Users_ban#</h2>
<listtemplate name="banned_users"></listtemplate>
   
<h2>#chat.Transcripts#</h2>
<if @transcript_create_p;literal@ true>
<include src="/packages/chat/lib/transcripts" room_id=@room_id@>
</if>

<if @room_edit_p;literal@ true>
  <h2>#xowiki.pretty_name# Includelet</h2>
  <span id="xowiki-includelet">
    <input id="xowiki-includelet-code"
           type="text"
           size="@xowiki_includelet_size;literal@"
           readonly="true"
           value="@xowiki_includelet_code@">
  </span>
  <p class="form-help-text">
    <img src="/shared/images/info.gif"
         width="12" height="9" alt="Help"
         title="Help text" style="border:0">
    #chat.xowiki_includelet_help_text#
  </p>
  <script nonce="@::__csp_nonce;literal@">
    if (document.execCommand != undefined) {
        var button = document.createElement("button");
        button.textContent = "#acs-kernel.common_Copy#";
        button.addEventListener("click", function () {
           document.getElementById("xowiki-includelet-code").select();
           document.execCommand("copy");
           this.textContent = "#acs-admin.Success#!";
        });
        document.getElementById("xowiki-includelet").appendChild(button);
    }
  </script>
</if>
