<!--
    Display confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
-->
<master>
<property name="context">@context_bar@</property>
<property name="title">Confirm unban user</property>

<form method=post action=user-unban-2>
<input type=hidden name=room_id value="@room_id@">
<input type=hidden name=party_id value="@party_id@">
Are you sure you want to unban  <b>@party_pretty_name@</b> from @pretty_name@?
<p><input type=submit value="Unban">
</form>
