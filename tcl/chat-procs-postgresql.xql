<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
<fullquery name="chat_room_new.create_room">
      <querytext>
            select chat_room__new (            
             :pretty_name,
             :alias,
             :description,
             :key_words,
             :maxP,
             timestamp :end_date,
             boolean :Rss_service,
             boolean :Mail_service,
             boolean :moderated_p,
             boolean :active_p,
             boolean :archive_p,
             integer :context_id,
             integer :comm_id,             
             integer :creation_user,
             varchar :creation_ip,
             varchar 'chat_room'                          
            )
      </querytext>
</fullquery>



<fullquery name="chat_room_new.grant_permission">
      <querytext>
        -- Automatic grant room privilege to creator of the room (must not be null).
        begin
        if :creation_user <> ''
        then
            perform acs_permission__grant_permission(:room_id, :creation_user, 'chat_room_edit');
            perform acs_permission__grant_permission(:room_id, :creation_user, 'chat_room_view');
            perform acs_permission__grant_permission(:room_id, :creation_user, 'chat_room_delete');
            perform acs_permission__grant_permission(:room_id, :creation_user, 'chat_transcript_create');

	end if;
        return 0;
        end;


      </querytext>
</fullquery>

<fullquery name="chat_room_name.get_room_name">
      <querytext>
          select chat_room__name (:room_id) from    dual;
      </querytext>
</fullquery>


 <fullquery name="chat_user_name.get_chat_user_name">
      <querytext>
          select person__name(:user_id);
      </querytext>
</fullquery>


 <fullquery name="chat_user_grant.grant_user">
      <querytext>
         begin
           perform acs_permission__grant_permission(:room_id, :party_id, 'chat_write');
           perform acs_permission__grant_permission(:room_id, :party_id, 'chat_read');
           return 0;
         end;
      </querytext>
</fullquery>


<fullquery name="chat_user_revoke.revoke_user">
      <querytext>
         begin
            perform acs_permission__revoke_permission(:room_id, :party_id, 'chat_write');
	    perform acs_permission__revoke_permission(:room_id, :party_id, 'chat_read');
            return 0;
         end;
      </querytext>
</fullquery>

<fullquery name="chat_user_ban.ban_user">
      <querytext>
      begin
	perform acs_permission__grant_permission(:room_id, :party_id, 'chat_ban');
        return 0;
      end;
      </querytext>
</fullquery>


<fullquery name="chat_user_unban.ban_user">
      <querytext>
      begin
        perform acs_permission__revoke_permission(:room_id, :party_id, 'chat_ban');
        return 0;
      end;
      </querytext>
</fullquery>

<fullquery name="chat_moderator_grant.grant_moderator">
      <querytext>
        begin
          perform acs_permission__grant_permission(:room_id, :party_id, 'chat_room_moderate');
          return 0;
	end;
      </querytext>
</fullquery>

<fullquery name="chat_moderator_revoke.revoke_moderator">
      <querytext>
        begin
           perform acs_permission__revoke_permission(:room_id, :party_id, 'chat_room_moderate');
           return 0;
	end;
     </querytext>
</fullquery>   

<fullquery name="chat_room_edit.edit_room">
      <querytext>
         begin
	    perform chat_room__edit (
	        :pretty_name,
	        :alias,
	        :description,
	        :key_words,
	        :maxP,
	        :end_date,
	        :Rss_service,
	        :Mail_service,
	        :moderated_p,
	        :active_p,
            :archive_p,
            :user_id,
            :room_id
	    );
            return 0;
	end;
     </querytext>
</fullquery>


<fullquery name="chat_message_count.message_count">
      <querytext>
         select chat_room__message_count(:room_id);
     </querytext>
</fullquery>



<fullquery name="chat_room_delete_registered_users.delete_users">
      <querytext>
          begin          
	    perform chat_room__delete_registered_users(:room_id,:user_id);
            return 0;
	end;
     </querytext>
</fullquery>


<fullquery name="chat_transcript_new.create_transcript">
      <querytext>
      select chat_transcript__new  (
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


<fullquery name="chat_transcript_new.grant_permission">
      <querytext>
        begin
           -- Automatic grant transcript privilege to creator of the transcript (must not be null).
                if :creation_user is not null
                then
	           perform acs_permission__grant_permission(:transcript_id, :creation_user, 'chat_transcript_edit');
	           perform acs_permission__grant_permission(:transcript_id, :creation_user, 'chat_transcript_view');
	           perform acs_permission__grant_permission(:transcript_id, :creation_user, 'chat_transcript_delete');
                end if;
        return 0;
        end;
      </querytext>
</fullquery>


<fullquery name="chat_transcript_delete.delete_transcript">
      <querytext>
        begin
	    perform chat_transcript__del(:transcript_id);
            return 0;
	end;
      </querytext>
</fullquery>


<fullquery name="chat_post_message_to_db.post_message">
      <querytext>
                select chat_room__message_post (:room_id, :msg, :creation_user, :creation_ip);
      </querytext>
</fullquery>

 <fullquery name="chat_room_delete.delete_room">
      <querytext>
        select  chat_room__del(:room_id);

      </querytext>
</fullquery>


<fullquery name="chat_transcript_edit.edit_transcript">
      <querytext>
           begin
	    perform chat_transcript__edit (
	        :transcript_id,
	        :pretty_name,
                :contents,
                :description);
                return 0;
	    end;
      </querytext>
</fullquery>

<fullquery name="chat_registered_user.register">
      <querytext>
            select chat_room_registered__user (
             varchar :alias,
             integer :user_id,
             integer :room_id,
             boolean :RSS_service,
             boolean :mail_service,
             integer :context_id,
             varchar :creation_ip
            )
      </querytext>
</fullquery>



</queryset>

