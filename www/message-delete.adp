<!--
    Display confirmation for delete chat messages in the room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date January 18, 2001
    @cvs-id $Id$
-->
<master>
<property name="context">@context_bar@</property>
<property name="title">Confirm message delete</property>

<form method="post" action="message-delete-2">
<input type=hidden name=room_id value=@room_id@>
Are you sure you want to delete @message_count@ messages in @pretty_name@?
<p><input type=submit value=Yes>
</form>