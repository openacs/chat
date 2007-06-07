<?xml version="1.0"?>
<queryset>

<fullquery name="list_transcripts">
  <querytext>    
    select ct.transcript_id, ct.pretty_name, ao.creation_date,crss.room_name,cr.room_id as room_id
    from chat_transcripts ct, acs_objects ao, chat_rss crss,chat_rooms cr
    where crss.transcription_name = :pretty_name
    or crss.transcription_date = :date2 or crss.partitipants = :partitipants or crss.file_name = :sent_files
    or crss.file_name=:sent_files or crss.keywords = :key_words
    and ct.transcript_id = ao.object_id
    and ct.pretty_name = crss.transcription_name
    and cr.pretty_name = crss.room_name
    order by ao.creation_date desc
 </querytext>
</fullquery>

</queryset>