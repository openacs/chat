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
             varchar :comm_name,
             integer :creation_user,
             varchar :creation_ip,
             varchar 'chat_room',
             varchar :frequency1,
             varchar :frequency2
            )
      </querytext>
</fullquery>

<fullquery name="chat_room_new.insert_keywords">
      <querytext>
            select chat_room__insert_keywords (             
             :word,
             :room_id
             )
      </querytext>
</fullquery>

<fullquery name="chat_room_edit.insert_keywords">
      <querytext>
            select chat_room__insert_keywords (             
             :word,
             :room_id
             )
      </querytext>
</fullquery>

<fullquery name="chat_room_private_new.create_private_room">
      <querytext>      
            select chat_room__private_new (            
             varchar :pretty_name,
             varchar :alias,
             varchar :description,
             varchar :key_words,
             integer :maxP,
             timestamp :end_date,
             boolean :Rss_service,
             boolean :Mail_service,
             boolean :moderated_p,
             boolean :active_p,
             boolean :archive_p,
             integer :context_id,
             varchar :comm_name,             
             integer :creation_user,
             varchar :creation_ip,
             varchar 'chat_room',
             boolean :private		                                       
            )
      </querytext>
</fullquery>

<fullquery name="chat_send_mails.sender_info3">
<querytext>
	select '$from' as from_addr,
               '$sender_first_names' as sender_first_names,
               '$sender_last_name' as sender_last_name,
               parties.email as email
               from dotlrn_member_rels_full,parties
               where dotlrn_member_rels_full.community_id = '2267'
               and parties.party_id = dotlrn_member_rels_full.user_id               
</querytext>
</fullquery>

<fullquery name="chat_send_mails.sender_info4">
<querytext>
	select '$from' as from_addr,
               '$sender_first_names' as sender_first_names,
               '$sender_last_name' as sender_last_name,
               parties.email as email
               from dotlrn_member_rels_full,parties
               where dotlrn_member_rels_full.community_id = '$community_id'
               and parties.party_id = dotlrn_member_rels_full.user_id
               and parties.party_id = '$user_id'
</querytext>
</fullquery>



<fullquery name="chat_send_mails.sender_info">
        <querytext>
        select '$from' as from_addr,
               '$sender_first_names' as sender_first_names,
               '$sender_last_name' as sender_last_name,
               parties.email,
               CASE
                  WHEN
                      acs_objects.object_type = 'user'
                  THEN
                      (select first_names
                       from persons
                       where person_id = parties.party_id)
                  WHEN
                      acs_objects.object_type = 'group'
                  THEN
                      (select group_name
                       from groups
                       where group_id = parties.party_id)
                  WHEN
                      acs_objects.object_type = 'rel_segment'
                  THEN
                      (select segment_name
                       from rel_segments
                       where segment_id = parties.party_id)
                  ELSE
                      ''
               END as first_names,
               CASE
                  WHEN
                     acs_objects.object_type = 'user'
                  THEN
                      (select last_name
                       from persons
                       where person_id = parties.party_id)
                  ELSE 
                      ''
               END as last_name,
               '$safe_community_name' as community_name,
               '$community_url' as community_url
            from acs_rels,
                 parties,
                 acs_objects
            where (acs_rels.object_id_one = $community_id
            and acs_rels.object_id_two = parties.party_id
            and parties.party_id = acs_objects.object_id
            and parties.party_id in (select acs_rels.object_id_two  
                                     from acs_rels, membership_rels
                                     where acs_rels.object_id_one = acs__magic_object_id('registered_users')
                                     and acs_rels.rel_id = membership_rels.rel_id
                                     and membership_rels.member_state = 'approved' ))
	    $who_will_receive_this_clause
        </querytext>
    </fullquery>
    
    <fullquery name="select_sender_info">
        <querytext>
            select parties.email as sender_email,
                   persons.first_names as sender_first_names,
                   persons.last_name as sender_last_name
            from parties,
                 persons
            where parties.party_id = :sender_id
            and persons.person_id = :sender_id
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
          :room_id,
          :frequency1,
	  :frequency_mail
	    );
            return 0;
	end;
     </querytext>
</fullquery>

<fullquery name="chat_room_edit.edit_room_admin">
      <querytext>        
	    select chat_room__edit_admin (
	        :alias,
	        :Rss_service,
	        :Mail_service,
	        :context_id,
	        :user_id,
	        :creation_ip,
          	:room_id,
                :frequency_mail
	    )        
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


<fullquery name="chat_transcript_edit_keywords.store_transcripts_keywords">
      <querytext>
          select chat_room__store_transcripts_keywords (
             :word,
             :transcript_id
            )
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
             varchar :creation_ip,
             varchar :frequency_mail
            )
      </querytext>
</fullquery>


<fullquery name="send_file.send_file">
      <querytext>
            select chat_room__send_files (
             integer :chat_id,
             varchar :file,
             varchar :title,
             varchar :description,
             date :date,
             integer :context_id,
             integer :creation_user,
             varchar :creation_ip,
	     integer :send_file_id
            )
      </querytext>
</fullquery>

<fullquery name="send_file_message.send_file_message">
      <querytext>      
      	begin      	
            perform chat_room__send_files_message (:chat_id);
            return 0;
        end;
      </querytext>
</fullquery>


<fullquery name="chat::rss::lastUpdated.select_last_updated">
    <querytext>    
    	select max(o.last_modified) as last_updated
        from acs_objects o, chat_rooms cr
        where cr.context_id=:package_id
        and o.object_id=cr.room_id
    </querytext>
  </fullquery>
  
  <fullquery name="chat__rss_datasource.get_chat_items">
        <querytext>
        select cr.room_id as item_id,
        cr.pretty_name as title,
        to_char(o.last_modified, 'YYYY-MM-DD HH24:MI:SS') as last_modified
        from chat_rooms cr,
        acs_objects o
        where cr.context_id=:package_id
        and o.object_id = cr.room_id
        and cr.room_id=:summary_context_id
        order by o.last_modified desc
        limit $limit
        </querytext>        
        
</fullquery>


<fullquery name="rss_db.rss_db">
      <querytext>     
      	select chat_rss__store_db (
            	varchar :room_name,
            	varchar :room_description,
            	date :end_date,
            	varchar :r_creator,
            	varchar :comm_name,
            	varchar :registered_users,
            	timestamp :entry_timestamp
           	);
      </querytext>
</fullquery>


<fullquery name="store_partitipants_rss.store_partitipants_rss">
      <querytext>     
      	select chat_rss__store_partitipants_rss (
            	:rss_id,
            	:partitipant
           	);
      </querytext>
</fullquery>

<fullquery name="store_partitipants_transcript.store_partitipants_transcript">
      <querytext>     
      	select chat_transcript__store_partitipants_transcript (
            	:transcript_id,
            	:partitipant
           	);
      </querytext>
</fullquery>

<fullquery name="store_sent_files_rss.store_sent_files_rss">
      <querytext>     
      	select chat_rss__store_sent_files_rss (
            	:rss_id,
            	:send_file_id
           	);
      </querytext>
</fullquery>

<fullquery name="store_sent_files_tanscript.store_sent_files_tanscript">
      <querytext>     
      	select chat_transcript__store_sent_files_tanscript (
            	:transcript_id,
            	:f_id
           	);
      </querytext>
</fullquery>

<fullquery name="store_keywords_rss.store_keywords_rss">
      <querytext>     
      	select chat_rss__store_keywords_rss (
            	:rss_id,
            	:key
           	);
      </querytext>
</fullquery>


<fullquery name="store_transcripts_rss.store_transcripts_rss">
      <querytext>     
      	select chat_rss__store_transcripts_rss (
            	:rss_id,
            	:transcription_id
           	);
      </querytext>
</fullquery>


<fullquery name="get_files_sent">
  	<querytext>
    	select fs.send_file_id as f_id
      from chat_files_sent fs
      where room_id = :room_id
      	  and date >= :time 
  	</querytext>
  </fullquery>
  
</queryset>

