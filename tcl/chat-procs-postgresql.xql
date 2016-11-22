<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="chat_room_new.create_room">
    <querytext>
      select chat_room__new (
      NULL,
      :pretty_name,
      :description,
      :moderated_p,
      :active_p,
      :archive_p,
      :auto_flush_p,
      :auto_transcript_p,
      :login_messages_p,
      :logout_messages_p,	     
      :context_id,
      now(),
      :creation_user,
      :creation_ip,
      'chat_room'
      )
    </querytext>
  </fullquery>

  <fullquery name="chat_room_edit.edit_room">
    <querytext>
      select chat_room__edit (
      :room_id,
      :pretty_name,
      :description,
      :moderated_p,
      :active_p,
      :archive_p,
      :auto_flush_p,
      :auto_transcript_p,
      :login_messages_p,
      :logout_messages_p		
      )
    </querytext>
  </fullquery>

  <fullquery name="chat_message_count.message_count">
    <querytext>
      select chat_room__message_count(:room_id)
    </querytext>
  </fullquery>


  <fullquery name="chat_room_message_delete.delete_message">
    <querytext>
      select chat_room__delete_all_msgs(:room_id)
    </querytext>
  </fullquery>


  <fullquery name="chat_transcript_new.create_transcript">
    <querytext>
      select chat_transcript__new (
      :pretty_name,
      :contents,
      :description,
      :room_id,
      :context_id,
      now(),
      :creation_user,
      :creation_ip,
      'chat_transcript'
      )
    </querytext>
  </fullquery>

  <fullquery name="chat_transcript_delete.delete_transcript">
    <querytext>
      select chat_transcript__del(:transcript_id)
    </querytext>
  </fullquery>

  <fullquery name="chat_post_message_to_db.post_message">
    <querytext>
      select chat_room__message_post(:room_id, :msg, :creation_user, :creation_ip)
    </querytext>
  </fullquery>

  <fullquery name="chat_room_delete.delete_room">
    <querytext>
      select chat_room__del(:room_id)
    </querytext>
  </fullquery>

  <fullquery name="chat_transcript_edit.edit_transcript">
    <querytext>
      select chat_transcript__edit (
      :transcript_id,
      :pretty_name,
      :contents,
      :description
      )
    </querytext>
  </fullquery>

</queryset>

