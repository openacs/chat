<!--
    Display confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
-->
<master src="master">
<property name="context_bar">@context_bar@</property>
<property name="title">Confirm revoke moderator</property>

<form method=post action=moderator-revoke-2>
<input type=hidden name=room_id value="@room_id@">
<input type=hidden name=party_id value="@party_id@">
Are you sure you want to revoke moderator privilege of <b>@party_pretty_name@</b> from @pretty_name@?
<p><input type=submit value="Revoke">
</form>