<!--
    Display confirmation for deleting chat transcript.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 28, 2000
    @cvs-id $Id$
-->
<master>
<property name="context">@context;noquote@</property>
<property name="title">#chat.Confirm_chat_transcript_delete#</property>

<form method="post" action="transcript-delete-2">
<div>
<input type="hidden" name="transcript_id" value="@transcript_id@">
<input type="hidden" name="room_id" value="@room_id@">
</div>
<p>#chat.Are_you_sure_you_want_to_delete# <b>Replace with transcript name</b>?</p>
<p><input type="submit" value="#acs-kernel.common_Yes#"></p>
</form>
