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
  
  

  <fullquery name="chat_flush_rooms.get_rooms">
    <querytext>
            select room_id 
            from chat_rooms 
            where archive_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="chat_room_flush.get_archives_messages">
    <querytext>
      select msg, creation_user, to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date
      from chat_msgs
      where room_id = :room_id
      	  and creation_date >= :time 
          and msg is not null
      order by creation_date
    </querytext>
  </fullquery>
  
  <fullquery name="get_archives_messages">
  	<querytext>
    	select msg, creation_user, to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date
    	from chat_msgs
    	where room_id = :room_id
          and msg is not null
    	order by creation_date
  	</querytext>
  </fullquery> 
  
  <fullquery name="chat_room_message_delete.delete_message">
    <querytext>
   	 begin
            perform chat_room__delete_all_msgs(:room_id);
            return 0;
         end;
    </querytext>
  </fullquery> 
  
  <fullquery name="chat_room_flush.get_files_sent">
  	<querytext>
    	select fs.send_file_id as f_id
      from chat_rooms_files_sent fs
      where room_id = :room_id
      	  and date >= :time 
  	</querytext>
  </fullquery>
  
 
  
</queryset>

