<!--
    Display confirmation for deleting chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
-->
<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">Confirm chat transcript delete</property>

<form method="post" action="transcript-delete-2">
<input type=hidden name=transcript_id value=@transcript_id@>
<input type=hidden name=room_id value=@room_id@>
Are you sure you want to delete <b>Replace with transcript name</b>?
<p><input type=submit value=Yes>
</form>