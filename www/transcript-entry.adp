<!--
    Create/edit form for chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
-->
<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">@title@</property>

<form action="@action@" method="post">
    <input type="hidden" name="transcript_id" value="@transcript_id@">
    <input type="hidden" name="room_id" value="@room_id@">
    <table>
       <tr>
          <th align="right">Transcript name:</th>
          <td><input size=50 name="transcript_name" value="@transcript_name@">
       </tr>
       <tr>
          <th align="right">Description:</th>
          <td><textarea name="description" rows=6 cols=65>@description@</textarea>
       </tr>
       <tr>
          <th align="right">Contents:</th>
    	  <td><textarea name="contents" rows=20 cols=70>@contents@</textarea>
       </tr>
       <tr>
          <th></th>
          <td><input type=submit value="@submit_label@">
    </table>
    
</form>
