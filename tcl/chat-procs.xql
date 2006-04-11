<?xml version="1.0"?>

<queryset>

  <fullquery name="chat_transcript_new.update_contents">
    <querytext>
	update chat_transcripts 
	set contents = :contents 
	where transcript_id = :transcript_id
    </querytext>
  </fullquery>

  <fullquery name="chat_transcript_edit.update_contents">
    <querytext>
	update chat_transcripts 
	set contents = :contents 
	where transcript_id = :transcript_id
    </querytext>
  </fullquery>

</queryset>

