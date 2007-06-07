<!--
    Create/edit form for chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;noquote@</property>
<property name="title">@title;noquote@</property>

<form action="@action@" method="post">
    <input type="hidden" name="transcript_id" value="@transcript_id@">
    <input type="hidden" name="room_id" value="@room_id@">
    <input type="hidden" name="contents" value="@contents@">
    <table border="0" cellpadding="2" cellspacing="2">
       <tr class="form-element">
          <td class="form-label">#chat.Transcript_name#</th>
          <td><input size="50" name="transcript_name" value="@transcript_name@"></td>
       </tr>
       <tr class="form-element">
          <td class="form-label">#chat.Delete_messages#</td>
          <td><input type="checkbox" name="delete_messages">
          <div class="form-help-text">
            <img src="/shared/images/info.gif" alt="[i]" title="Help text" border="0" height="9" width="12">
            #chat.delete_messages_after_transcript#
          </div>
          </td>
       </tr>
       <if @active_p@ eq "t">
       <tr class="form-element">
          <td class="form-label">#chat.Room_deactivate#</td>
          <td><input type="checkbox" name="deactivate_room">
          <div class="form-help-text">
            <img src="/shared/images/info.gif" alt="[i]" title="Help text" border="0" height="9" width="12">
            #chat.deactivate_room_after_transcript#
          </div>
          </td>
       </tr>       
       </if>
       <tr class="form-element">
          <td class="form-label">#chat.Description#</th>
          <td><textarea name="description" rows=6 cols=65>@description@</textarea>
       </tr>
       <tr class="form-element">
          <td class="form-label">#chat.keywords#</th>
          <td><textarea name="keywords" rows=3 cols=65>@keywords@</textarea>
       </tr>
       <tr class="form-element">
          <td class="form-label">#chat.Contents#</th>
    	  <td><div style="border: 1px solid #A4B97F; padding:3px; color: #666666;">@contents;noquote@</div>
       </tr>
       <tr class="form-element">
          <td><input type="submit" value="@submit_label@">
    </table>
    
</form>
