<if @edit_p@ eq 1>
<a class="button" href="transcript-edit?transcript_id=@transcript_id@&room_id=@room_id@">#chat.Edit#</a>
</if>

<table border="0" cellpadding="2" cellspacing="2">
    <tr class="form-element">
        <td class="form-label">#chat.Transcript_name#</td>
        <td>@transcript_name@</td>
    </tr>
    <tr class="form-element">
        <td class="form-label">#chat.Description#</td>
        <td>@description@</td>
    </tr>
</table>
     
<div id="messages">@contents;noquote@</div>
