<!--
     Chat transcript preview.

     @author David Dao (ddao@arsdigita.com)
     @creation-date November 27, 2000
     @cvs-id $Id$
-->
<master>
<property name="context">@context_bar;literal@</property>
<property name="doc(title)">#chat.Transcript_preview#</property>

[<a href="transcript-edit?transcript_id=@transcript_id@&amp;room_id=@room_id@">#chat.Edit#</a>]
<ul>
<li>#chat.Name#: <strong>@transcript_name@</strong>
<li>#chat.Description#: <strong><em>@description@</em></strong>


<ul>
<p>@contents;noquote@
</ul>
</ul>


