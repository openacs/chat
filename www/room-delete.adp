<!--
    Display confirmation for deleting chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
-->
<master src="master">
<property name="context">@context_bar@</property>
<property name="title">Confirm room delete</property>

<form method="post" action="room-delete-2">	
<input type=hidden name=room_id value=@room_id@>
Are you sure you want to delete @pretty_name@?
<p><input type=submit value=Yes>
</form>


