<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="store_transcripts_keywords.store_transcripts_keywords">
  <querytext>
    select chat_room__store_transcripts_keywords (
             :word,
             :transcript_id
            )
  </querytext>
</fullquery>
<fullquery name="store_transcripts_keywords">
  <querytext>
    select chat_room__store_transcripts_keywords (
             :word,
             :transcript_id
            )
  </querytext>
</fullquery>

</queryset>
