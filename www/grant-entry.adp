<!--
    Template for granting user privilege to the room.
    
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;literal@</property>
<property name="doc(title)">@title;literal@</property>

<form method=post action=@action@>
    <input type="hidden" name="room_id" value="@room_id@">
    
    @description@
    <select name=party_id>
    <multiple name=parties>
    <option value="@parties.party_id@">@parties.name@
    </multiple>
    </select>
    <input type="submit" value="@submit_label@">
</form>
    