--
-- packages/chat/sql/chat-create.sql
--
-- @author ddao@arsdigita.com and Pablo Mu�oz(pablomp@tid.es)
--


-- create the privileges
select acs_privilege__create_privilege('chat_room_create', 'Create chat room', null);
select acs_privilege__create_privilege('chat_room_view', 'View room information', null);
select acs_privilege__create_privilege('chat_room_edit', 'Edit chat room', null);
select acs_privilege__create_privilege('chat_room_delete', 'Delete chat room', null);

select acs_privilege__create_privilege('chat_transcript_create', 'Create chat transcript', null);
select acs_privilege__create_privilege('chat_transcript_view', 'View chat transcript', null);
select acs_privilege__create_privilege('chat_transcript_edit', 'Edit chat transcipt', null);
select acs_privilege__create_privilege('chat_transcript_delete', 'Delete chat transcript', null);

select acs_privilege__create_privilege('chat_room_moderate', 'Moderate chat room', null);

select acs_privilege__create_privilege('chat_moderator_grant', 'Add moderator to a chat room', null);
select acs_privilege__create_privilege('chat_moderator_revoke', 'Remove moderator from a chat room', null);

select acs_privilege__create_privilege('chat_user_grant', 'Grant user to a chat room', null);
select acs_privilege__create_privilege('chat_user_revoke', 'Remove user from a chat room', null);
select acs_privilege__create_privilege('chat_user_ban', ' Ban user from a chat room', null);
select acs_privilege__create_privilege('chat_user_unban', 'Unban user from a chat room', null);

select acs_privilege__create_privilege('chat_ban', 'Ban from a chat room', null);
select acs_privilege__create_privilege('chat_read', 'View chat message', null);
select acs_privilege__create_privilege('chat_write', 'Write chat message', null);

-- Set of privileges for regular chat user.
select acs_privilege__create_privilege('chat_user', 'Regular chat user', null);
select acs_privilege__add_child('chat_user', 'chat_read');
select acs_privilege__add_child('chat_user', 'chat_write');

-- Set of privileges for moderator of the chat room.
select acs_privilege__create_privilege('chat_moderator', 'Chat room moderator', null);
select acs_privilege__add_child('chat_moderator', 'chat_room_moderate');
select acs_privilege__add_child('chat_moderator', 'chat_user_ban');
select acs_privilege__add_child('chat_moderator', 'chat_user_unban');
select acs_privilege__add_child('chat_moderator', 'chat_user_grant');
select acs_privilege__add_child('chat_moderator', 'chat_user_revoke');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_create');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_view');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_edit');
select acs_privilege__add_child('chat_moderator', 'chat_transcript_delete');
select acs_privilege__add_child('chat_moderator', 'chat_user');

 -- Set of privileges for administrator of the chat room.
select acs_privilege__create_privilege('chat_room_admin', 'Chat room administrator', null);
select acs_privilege__add_child('chat_room_admin', 'chat_room_create');
select acs_privilege__add_child('chat_room_admin', 'chat_room_delete');
select acs_privilege__add_child('chat_room_admin', 'chat_room_edit');
select acs_privilege__add_child('chat_room_admin', 'chat_room_view');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator_grant');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator_revoke');
select acs_privilege__add_child('chat_room_admin', 'chat_moderator');

-- Site wite admin also administrator of the chat room.
select acs_privilege__add_child('admin', 'chat_room_admin');


-- create chat room object type
CREATE FUNCTION inline_0()
RETURNS integer
AS 'declare
       attr_id acs_attributes.attribute_id%TYPE;
    begin
       PERFORM

       acs_object_type__create_type(
          ''chat_room'',  -- object_type
          ''Chat Room'',  -- pretty_name
          ''Chat Rooms'', -- pretty_plural
          ''acs_object'', -- supertype
          ''CHAT_ROOMS'', -- table_name
          ''ROOM_ID'',    -- id_column
          null,           -- package_name
          ''f'',          -- abstract_p
          null,           -- type_extension_table
          null            -- name_method
       );


	

       attr_id := acs_attribute__create_attribute (
          ''chat_room'',       -- object_type
          ''pretty_name'',     -- attribute_name
          ''string'',          -- datatype
          ''Room name'',       -- pretty_name
          ''Room names'',      -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );



        attr_id := acs_attribute__create_attribute (
          ''chat_room'',       -- object_type
          ''description'',     -- attribute_name
          ''string'',          -- datatype
          ''Description'',     -- pretty_name
          ''Descriptions'',    -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


        attr_id := acs_attribute__create_attribute (
          ''chat_room'',       -- object_type
          ''moderated_p'',     -- attribute_name
          ''boolean'',         -- datatype
          ''Moderated'',       -- pretty_name
          ''Moderated'',       -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


        attr_id := acs_attribute__create_attribute (
          ''chat_room'',       -- object_type
          ''active_p'',        -- attribute_name
          ''boolean'',         -- datatype
          ''Activated'',       -- pretty_name
          ''Activated'',       -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


        attr_id := acs_attribute__create_attribute (
          ''chat_room'',       -- object_type
          ''archive_p'',       -- attribute_name
          ''boolean'',         -- datatype
          ''Archived'',        -- pretty_name
          ''Archived'',        -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


         return 0;

    end;'

LANGUAGE 'plpgsql';
SELECT inline_0();
DROP function inline_0();

---------------------------------------

-- create chat transcript object type
CREATE FUNCTION inline_0()
RETURNS integer
AS 'declare
       attr_id acs_attributes.attribute_id%TYPE;
    begin
       PERFORM

     acs_object_type__create_type(
          ''chat_transcript'',  -- object_type
          ''Chat Transcript'',  -- pretty_name
          ''Chat Transcripts'', -- pretty_plural
          ''acs_object'',       -- supertype
          ''CHAT_TRANSCRIPTS'', -- table_name
          ''TRANSCRIPT_ID'',    -- id_column
          null,           -- package_name
          ''f'',          -- abstract_p
          null,           -- type_extension_table
          null            -- name_method
       );


       attr_id := acs_attribute__create_attribute (
          ''chat_transcript'', -- object_type
          ''pretty_name'',     -- attribute_name
          ''string'',          -- datatype
          ''Transcript name'', -- pretty_name
          ''Transcript names'',-- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


        attr_id := acs_attribute__create_attribute (
          ''chat_transcript'', -- object_type
          ''description'',     -- attribute_name
          ''string'',          -- datatype
          ''Description'',     -- pretty_name
          ''Descriptions'',    -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );


        attr_id := acs_attribute__create_attribute (
          ''chat_transcript'',          -- object_type
          ''contents'',                 -- attribute_name
          ''string'',                   -- datatype
          ''Transcript content'',       -- pretty_name
          ''Transcript contents'',      -- pretty_plural
          null,                -- table_name (default)
          null,                -- column_name (default)
          null,                -- default_value (default)
          1,                   -- min_n_values (default)
          1,                   -- max_n_values (default)
          null,                -- sort_order (default)
          ''type_specific'',   -- storage (default)
          ''f''                -- static_p (default)
        );



         return 0;

    end;'

LANGUAGE 'plpgsql';
SELECT inline_0();
DROP function inline_0();


---------------------------------------------

CREATE TABLE chat_rooms (
  room_id INTEGER NOT NULL, 
  pretty_name VARCHAR(100) NOT NULL, 
  description VARCHAR(2000), 
  moderated_p BOOLEAN DEFAULT false, 
  active_p BOOLEAN DEFAULT true, 
  archive_p BOOLEAN DEFAULT false, 
  maximal_participants INTEGER, 
  end_date DATE, 
  creator INTEGER, 
  context_id INTEGER, 
  comm_name VARCHAR, 
  open BOOLEAN, 
  auto_transcript_p BOOLEAN, 
  file_sent BOOLEAN, 
  private BOOLEAN, 
  frequency1 VARCHAR, 
  CONSTRAINT chat_rooms_room_id_pk PRIMARY KEY(room_id), 
  CONSTRAINT chat_rooms_active_p_ck CHECK ((active_p = true) OR (active_p = false)), 
  CONSTRAINT chat_rooms_archive_p_ck CHECK ((archive_p = true) OR (archive_p = false)), 
  CONSTRAINT chat_rooms_moderate_p_ck CHECK ((moderated_p = true) OR (moderated_p = false)), 
  CONSTRAINT chat_rooms_fk FOREIGN KEY ("creator")
    REFERENCES users(user_id)
    ON DELETE cascade
    NOT DEFERRABLE, 
  CONSTRAINT chat_rooms_room_id_fk FOREIGN KEY (room_id)
    REFERENCES acs_objects(object_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------

CREATE TABLE chat_transcripts (
  transcript_id INTEGER NOT NULL, 
  contents VARCHAR(32000) NOT NULL, 
  pretty_name VARCHAR(100) NOT NULL, 
  description VARCHAR(2000), 
  room_id INTEGER, 
  date DATE,
  keywords VARCHAR,  
  CONSTRAINT chat_trans_transcript_id_pk PRIMARY KEY(transcript_id), 
  CONSTRAINT chat_trans_room_id_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE, 
  CONSTRAINT chat_trans_transcript_id_fk FOREIGN KEY (transcript_id)
    REFERENCES acs_objects(object_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------

CREATE TABLE chat_msgs (
  msg_id INTEGER NOT NULL, 
  msg VARCHAR(4000), 
  msg_len INTEGER, 
  html_p BOOLEAN DEFAULT false, 
  approved_p BOOLEAN DEFAULT true, 
  creation_user INTEGER NOT NULL, 
  creation_ip VARCHAR(50), 
  creation_date DATE NOT NULL, 
  room_id INTEGER, 
  CONSTRAINT chat_msgs_msg_id_pk PRIMARY KEY(msg_id), 
  CONSTRAINT chat_msgs_approve_p_ck CHECK ((approved_p = true) OR (approved_p = false)), 
  CONSTRAINT chat_msgs_html_p_ck CHECK ((html_p = true) OR (html_p = false)), 
  CONSTRAINT chat_msgs_msg_len_ck CHECK (msg_len >= 0), 
  CONSTRAINT chat_msgs_creation_user_fk FOREIGN KEY (creation_user)
    REFERENCES parties(party_id)
    ON DELETE cascade
    NOT DEFERRABLE, 
  CONSTRAINT chat_msgs_room_id_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


--------------------------------

CREATE TABLE chat_registered_users (
  alias VARCHAR(20) NOT NULL, 
  room_id INTEGER, 
  user_id INTEGER, 
  rss_service BOOLEAN, 
  mail_service BOOLEAN, 
  registered_id INTEGER NOT NULL, 
  frequency_mail varchar,
  registered_date TIMESTAMP(0) WITHOUT TIME ZONE, 
  CONSTRAINT chat_registered_users_pkey PRIMARY KEY(registered_id), 
  CONSTRAINT chat_registered_users_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE cascade
    NOT DEFERRABLE, 
  CONSTRAINT chat_registered_users_fk1 FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE cascade
    NOT DEFERRABLE, 
  CONSTRAINT chat_registered_users_fk2 FOREIGN KEY (registered_id)
    REFERENCES acs_objects(object_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------

CREATE TABLE chat_keywords (
  room_id INTEGER, 
  keyword VARCHAR, 
  CONSTRAINT chat_keywords_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------

CREATE TABLE chat_private_room_users (
  room_id INTEGER, 
  user_id1 INTEGER, 
  user_id2 INTEGER, 
  CONSTRAINT chat_private_room_users_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------

CREATE TABLE chat_room_user_id (
  room_id INTEGER NOT NULL references chat_rooms
                           on delete cascade, 
  user_id INTEGER NOT NULL, 
  CONSTRAINT chat_room_user_id_fk FOREIGN KEY (user_id)
    REFERENCES users(user_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------


CREATE TABLE chat_rooms_files_sent (
  file VARCHAR, 
  title VARCHAR, 
  room_id INTEGER NOT NULL, 
  date DATE, 
  send_file_id INTEGER references cr_revisions
                       on delete cascade, 
  description VARCHAR, 
  message BOOLEAN, 
  creation_user INTEGER, 
  CONSTRAINT chat_rooms_files_sent_fk FOREIGN KEY (room_id)
    REFERENCES chat_rooms(room_id)
    ON DELETE cascade
    NOT DEFERRABLE
) WITH OIDS;


---------------------------------


CREATE TABLE chat_rss (
  room_name VARCHAR, 
  creator VARCHAR, 
  end_date DATE, 
  description VARCHAR, 
  comm_name VARCHAR, 
  user_registered VARCHAR, 
  rss_id INTEGER NOT NULL, 
  date TIMESTAMP(0) WITHOUT TIME ZONE, 
  entry_timestamp TIMESTAMP(0) WITHOUT TIME ZONE, 
  CONSTRAINT "chat_rss_pkey" PRIMARY KEY("rss_id")
) WITH OIDS;


---------------------------------

CREATE TABLE chat_file_transcript (
  transcript_id INTEGER, 
  file_id INTEGER
) WITH OIDS;

---------------------------------

CREATE TABLE chat_files_rss (
  file_id INTEGER, 
  rss_id INTEGER
) WITH OIDS;


---------------------------------

CREATE TABLE chat_key_rss (
  rss_id INTEGER, 
  key VARCHAR
) WITH OIDS;


---------------------------------

CREATE TABLE chat_partitipants_rss (
  partitipant VARCHAR, 
  rss_id INTEGER
) WITH OIDS;


---------------------------------

CREATE TABLE chat_partitipants_transcript (
  transcript_id INTEGER, 
  partitipant VARCHAR
) WITH OIDS;

---------------------------------

CREATE TABLE chat_room_transcript_keywords (
  keyword VARCHAR, 
  transcript_id INTEGER
) WITH OIDS;


---------------------------------

CREATE TABLE chat_transcription_rss (
  rss_id INTEGER, 
  transcription_id INTEGER
) WITH OIDS;


---------------------------------

CREATE OR REPLACE FUNCTION chat_room__new (varchar, varchar, varchar, varchar, integer, timestamp, boolean, boolean, boolean, boolean, boolean, integer, integer, integer, varchar, varchar, varchar, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_pretty_name    alias for $1;
   p_alias          alias for $2;
   p_description    alias for $3;
   p_key_words      alias for $4;
   p_maxP           alias for $5;
   p_end_date       alias for $6;
   p_Rss_service    alias for $7;
   p_Mail_service   alias for $8;
   p_moderated_p    alias for $9;
   p_active_p       alias for $10;
   p_archive_p      alias for $11;
   p_context_id     alias for $12;
   p_comm_id        alias for $13;
   p_creation_user  alias for $14;
   p_creation_ip    alias for $15;
   p_object_type    alias for $16;
   p_frequency1     alias for $17;
   p_frequency2	    alias for $18;
   v_room_id        chat_rooms.room_id%TYPE;
   v_registered_id  chat_rooms.room_id%TYPE;
   v_comm_name      varchar;
begin
     v_room_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );
     v_registered_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );

     if exists (select dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id) then
        select into v_comm_name dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id;
        insert into chat_rooms
               (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name,auto_transcript_p,file_sent,private,frequency1)
       values
             (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,v_comm_name,''true'',''false'',''false'',p_frequency1);
     else
         insert into chat_rooms
                (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name,auto_transcript_p, file_sent,private,frequency1)
         values
               (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,''Dotlrn'',''true'', ''false'',''false'',p_frequency1);
     end if;


   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id, frequency_mail)
   values
       (p_alias, v_room_id, p_creation_user, p_Rss_service, p_Mail_service, v_registered_id, p_frequency2);

return v_room_id;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;



-------------------------------

CREATE OR REPLACE FUNCTION chat_room__message_count (integer) RETURNS integer AS'
declare
   p_room_id        alias for $1;
   v_count integer;
begin
   select count(*) as total into v_count
   from chat_msgs
   where room_id = p_room_id;
   return v_count;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------

CREATE OR REPLACE FUNCTION chat_room__delete_all_msgs (integer) RETURNS integer AS'
declare
   p_room_id        alias for $1;
begin
   delete from chat_msgs where room_id = p_room_id;
   return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------


CREATE OR REPLACE FUNCTION chat_room__del (integer) RETURNS integer AS'
declare
   p_room_id        alias for $1;
begin

    --TO DO: delete transcriptions?

    -- Erase all the users relate to this chat room.
    delete from chat_private_room_users where room_id = p_room_id;
    
    -- Erase all the files sent relate to this chat room.
    delete from chat_rooms_files_sent where room_id = p_room_id;

    -- Erase all the messages relate to this chat room.
    delete from chat_msgs where room_id = p_room_id;

    -- Erase all the registered users relate to this chat room.
    delete from chat_registered_users where room_id = p_room_id;
    
    -- Erase all the transcripts relate to this chat room.
    delete from chat_transcripts where room_id = p_room_id;
    
    -- Erase all the keywords to this chat room.
    delete from chat_keywords where room_id = p_room_id;
    
     -- Delete all privileges associate with this room
     delete from acs_permissions where object_id = p_room_id;

     -- Now delete the chat room itself.
     delete from chat_rooms where room_id = p_room_id;
     
     delete from rss_gen_subscrs where summary_context_id = p_room_id;
     
     delete from acs_objects where context_id = p_room_id;

     PERFORM acs_object__delete(p_room_id);

   return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------

CREATE OR REPLACE FUNCTION chat_room__delete_registered_users (integer, integer) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_room_id        alias for $1;
   p_user_id        alias for $2;
begin
    delete from chat_registered_users where room_id = p_room_id
    and user_id = p_user_id;
    return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;



---------------------------------

CREATE OR REPLACE FUNCTION chat_room_registered__user (varchar, integer, integer, boolean, boolean, integer, varchar, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_alias          alias for $1;
   p_user_id        alias for $2;
   p_room_id        alias for $3;
   p_RSS_service    alias for $4;
   p_mail_service   alias for $5;
   p_context_id     alias for $6;
   p_creation_ip    alias for $7;
   p_frequency_mail alias for $8;
   v_registered_id          chat_rooms.room_id%TYPE;
begin
   v_registered_id := acs_object__new(null,''chat_room'',now(),p_user_id,p_creation_ip,p_context_id   );
   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id, frequency_mail, registered_date)
   values
       (p_alias, p_room_id, p_user_id, p_RSS_service, p_mail_service, v_registered_id, p_frequency_mail, now());
return v_registered_id;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------


CREATE OR REPLACE FUNCTION chat_transcript__new (varchar, varchar, varchar, integer, integer, timestamptz, integer, varchar, varchar) RETURNS integer AS'
declare

   p_pretty_name      alias for $1;
   p_contents         alias for $2;
   p_description      alias for $3;
   p_room_id          alias for $4;
   p_context_id       alias for $5;
   p_creation_date    alias for $6;
   p_creation_user    alias for $7;
   p_creation_ip      alias for $8;
   p_object_type      alias for $9;
   v_transcript_id    chat_transcripts.transcript_id%TYPE;
begin
   v_transcript_id := acs_object__new (
     null,
     ''chat_transcript'',
     now(),
     p_creation_user,
     p_creation_ip,
     p_context_id
   );

   insert into chat_transcripts (transcript_id,   pretty_name,   contents,   description,   room_id, date)
                        values  (v_transcript_id, p_pretty_name, p_contents, p_description, p_room_id, now());

   return v_transcript_id;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;



-----------------------------


CREATE OR REPLACE FUNCTION chat_transcript__del (integer) RETURNS integer AS'
declare
   p_transcript_id      alias for $1;
begin

        -- Delete all privileges associate with this transcript
        delete from acs_permissions where object_id = p_transcript_id;

        delete from chat_transcripts
        where transcript_id = p_transcript_id;

        PERFORM acs_object__delete(p_transcript_id);
        return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


----------------------------

CREATE OR REPLACE FUNCTION chat_room__edit (varchar, varchar, varchar, varchar, integer, timestamp, boolean, boolean, boolean, boolean, boolean, integer, integer, varchar, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_pretty_name    alias for $1;
   p_alias          alias for $2;
   p_description    alias for $3;
   p_key_words      alias for $4;
   p_maxP           alias for $5;
   p_end_date       alias for $6;
   p_Rss_service    alias for $7;
   p_Mail_service   alias for $8;
   p_moderated_p    alias for $9;
   p_active_p       alias for $10;
   p_archive_p      alias for $11;
   p_user_id        alias for $12;
   p_room_id        alias for $13;
   p_frequency1     alias for $14;
   p_frequency_mail alias for $15;
begin

     update chat_rooms
            set pretty_name = p_pretty_name,
            description = p_description,
            maximal_participants = p_maxP,
            end_date = p_end_date,
            moderated_p = p_moderated_p,
            active_p    = p_active_p,
            archive_p   = p_archive_p,
            frequency1 = p_frequency1
            where
                 room_id = p_room_id;
         
     update chat_registered_users
            set alias = p_alias,
            RSS_service = p_Rss_service,
            mail_service = p_Mail_service,
	    frequency_mail = p_frequency_mail
            where
                 room_id = p_room_id
                 and user_id = p_user_id;
            
            return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


---------------------------

CREATE OR REPLACE FUNCTION chat_room__message_post (integer, varchar, integer, varchar) RETURNS integer AS'
declare
   p_room_id        alias for $1;
   p_msg            alias for $2;
   p_creation_user  alias for $3;
   p_creation_ip    alias for $4;
   -- p_html_p         alias for $3;
   -- p_approved_p     alias for $4;
   v_msg_id chat_msgs.msg_id%TYPE;
   v_msg_archive_p chat_rooms.archive_p%TYPE;
   v_msg chat_msgs.msg%TYPE;
begin
    -- Get msg id from the global acs_object sequence.
    select acs_object_id_seq.nextval into v_msg_id from dual;


    select archive_p into v_msg_archive_p from chat_rooms where room_id = p_room_id;

    if v_msg_archive_p = ''t'' then
            v_msg := p_msg;
        else
            v_msg := null;
        end if;

    -- TO DO: aproved_p, Hhtml_p and lengh
    -- Insert into chat_msgs table.
        insert into chat_msgs (
            msg_id,
            room_id,
            msg,
            creation_user,
            creation_ip,
            creation_date)
        values (
            v_msg_id,
            p_room_id,
            v_msg,
            p_creation_user,
            p_creation_ip,
            now()) ;



return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------


CREATE OR REPLACE FUNCTION chat_transcript__edit (integer, varchar, varchar, varchar) RETURNS integer AS'
declare
    p_transcript_id   alias for $1;
    p_pretty_name     alias for $2;
    p_contents        alias for $3;
    p_description     alias for $4;
begin
    update chat_transcripts
        set pretty_name = p_pretty_name,
            contents    = p_contents,
            description = p_description
        where
            transcript_id = p_transcript_id;


return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;




-----------------------------


CREATE OR REPLACE FUNCTION chat_room__insert_keywords (varchar, integer) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
p_word      alias for $1;
p_room_id           alias for $2;
begin
insert into chat_keywords
               (keyword,room_id)
       values
             (p_word, p_room_id);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

----------------------------

CREATE OR REPLACE FUNCTION chat_room__name (integer) RETURNS varchar AS'
declare
   p_room_id         alias for $1;
   v_pretty_name     chat_rooms.pretty_name%TYPE;
begin
     select into v_pretty_name pretty_name from chat_rooms where room_id =  p_room_id;
     return v_pretty_name;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


----------------------------

CREATE OR REPLACE FUNCTION chat_room__private_new (varchar, varchar, varchar, varchar, integer, timestamp, boolean, boolean, boolean, boolean, boolean, integer, integer, integer, varchar, varchar, boolean) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_pretty_name    alias for $1;
   p_alias          alias for $2;
   p_description    alias for $3;
   p_key_words      alias for $4;
   p_maxP           alias for $5;
   p_end_date       alias for $6;
   p_Rss_service    alias for $7;
   p_Mail_service   alias for $8;
   p_moderated_p    alias for $9;
   p_active_p       alias for $10;
   p_archive_p      alias for $11;
   p_context_id     alias for $12;
   p_comm_id        alias for $13;
   p_creation_user  alias for $14;
   p_creation_ip    alias for $15;
   p_object_type    alias for $16;
   p_private        alias for $17;
   v_room_id        chat_rooms.room_id%TYPE;
   v_registered_id  chat_rooms.room_id%TYPE;
   v_comm_name      varchar;
begin

     v_room_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );
     v_registered_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );

     if exists (select dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id) then
        select into v_comm_name dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id;
        insert into chat_rooms
               (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name,auto_transcript_p,file_sent,private)
       values
             (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,v_comm_name,''true'',''false'',p_private);
     else
         insert into chat_rooms
                (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name,auto_transcript_p, file_sent,private)
         values
               (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,''Dotlrn'',''true'', ''false'',p_private);
     end if;


   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id)
   values
       (p_alias, v_room_id, p_creation_user, p_Rss_service, p_Mail_service, v_registered_id);

return v_room_id;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

------------------------------------

CREATE OR REPLACE FUNCTION chat_room__send_files (integer, varchar, varchar, varchar, date, integer, integer, varchar, integer) RETURNS integer AS'
/* Nuevo cuerpo de Function */

declare
   p_chat_id    alias for $1;
   p_file    alias for $2;
   p_title          alias for $3;
   p_description    alias for $4;
   p_date      alias for $5;
   p_context_id     alias for $6;
   p_creation_user  alias for $7;
   p_creation_ip    alias for $8;
   p_send_file_id   alias for $9;

begin

   insert into chat_rooms_files_sent
       (room_id, file, title, description, date, send_file_id, message,creation_user)
   values
       (p_chat_id, p_file, p_title, p_description, p_date, p_send_file_id,''false'',p_creation_user);

return p_send_file_id;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-----------------------------------------


CREATE OR REPLACE FUNCTION chat_room__send_files_message (integer) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
p_chat_id       alias for $1;
begin
update chat_rooms_files_sent set
            message = ''true''
            where room_id = p_chat_id;
return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-----------------------------------------


CREATE OR REPLACE FUNCTION chat_rss__store_db (varchar, varchar, date, varchar,
varchar, varchar, timestamp) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
p_room_name           alias for $1;
p_room_description    alias for $2;
p_end_date            alias for $3;
p_r_creator           alias for $4;
p_comm_name           alias for $5;
p_registered_users    alias for $6;
p_entry_timestamp     alias for $7;

v_rss_id                  chat_rss.rss_id%TYPE;


begin
v_rss_id := acs_object__new(null,''chat_room'',now(),null,null,null );

insert into chat_rss
               ( room_name, creator, end_date, description, comm_name,
user_registered, rss_id,date, entry_timestamp)
       values
             (p_room_name, p_r_creator,p_end_date,
p_room_description,p_comm_name,p_registered_users,v_rss_id,now(),p_entry_timestamp);
return v_rss_id;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

------------------------------------------


CREATE OR REPLACE FUNCTION chat_update_rss (varchar, varchar, timestamp, varchar, varchar, varchar, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
p_room_name     alias for $1;
p_room_creator  alias for $2;
p_end_date      alias for $3;
p_room_description    alias for $4;
p_comm_name           alias for $5;
p_msg_creator         alias for $6;
p_registered_users    alias for $7;

begin

     update chat_rss set
            room_name = p_room_name,
            creator = p_room_creator,
            end_date = p_end_date,
            description = p_room_description,
            comm_name = p_comm_name,
-- xxx jopez no existe este campo ?            msg_creator = p_msg_creator,
            user_registered = p_registered_users
            where room_id = p_room_id;
            
    return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


-------------------------------------

CREATE OR REPLACE FUNCTION chat_upload (varchar, varchar, timestamp, varchar, varchar, varchar, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
p_room_name     alias for $1;
p_room_creator  alias for $2;
p_end_date      alias for $3;
p_room_description    alias for $4;
p_comm_name           alias for $5;
p_msg_creator         alias for $6;
p_registered_users    alias for $7;

begin

     update chat_rss set
            room_name = p_room_name,
            creator = p_room_creator,
            end_date = p_end_date,
            description = p_room_description,
            comm_name    = p_comm_name,
-- xxx jopez no existe este campo ?           msg_creator   = p_msg_creator
            user_registered = p_registered_users
            where rss_id = p_rss_id;

    return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-----------------------------------

CREATE OR REPLACE FUNCTION chat_room__edit_admin (varchar, boolean, boolean, integer, integer, varchar, integer, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   
   p_alias          alias for $1;
   p_Rss_service    alias for $2;
   p_Mail_service   alias for $3;
   p_context_id     alias for $4;
   p_creation_user  alias for $5;
   p_creation_ip    alias for $6;
   p_room_id        alias for $7;
   p_frequency_mail alias for $8;
   v_registered_id  chat_rooms.room_id%TYPE;
   
   begin
   
   v_registered_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );
   if exists (select ru.user_id from chat_registered_users as ru where ru.room_id = p_room_id and ru.user_id = p_creation_user) then

   else
   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id, frequency_mail)
   values
       (p_alias, p_room_id, p_creation_user, p_Rss_service, p_Mail_service, v_registered_id, p_frequency_mail);
   end if;
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-------------------------------------


CREATE OR REPLACE FUNCTION chat_room__store_transcripts_keywords (varchar, integer) RETURNS integer AS'
/* New function body */
declare
p_keyword         alias for $1;
p_transcript_id  alias for $2;
begin
insert into chat_room_transcript_keywords
               ( transcript_id,keyword)
       values
             (p_transcript_id,p_keyword);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

------------------------------------------

CREATE OR REPLACE FUNCTION chat_rss__store_keywords_rss (integer, varchar) RETURNS integer AS'
/* New function body */
declare
p_rss_id          alias for $1;
p_keywords    alias for $2;

begin
insert into chat_key_rss
               (rss_id,key)
       values
             (p_rss_id, p_keywords);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


---------------------------------------------


CREATE OR REPLACE FUNCTION chat_rss__store_partitipants_rss (integer, varchar) RETURNS integer AS'
/* New function body */
declare
p_rss_id          alias for $1;
p_partitipant    alias for $2;
begin
insert into chat_partitipants_rss
               ( partitipant,rss_id)
       values
             (p_partitipant,p_rss_id);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

----------------------------------------------

CREATE OR REPLACE FUNCTION chat_rss__store_sent_files_rss (integer, integer) RETURNS integer AS'
/* New function body */
declare
p_rss_id          alias for $1;
p_file_id   alias for $2;
begin
insert into chat_files_rss
               ( rss_id,file_id)
       values
             (p_rss_id, p_file_id);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------------------

CREATE OR REPLACE FUNCTION chat_rss__store_transcripts_rss (integer, integer) RETURNS integer AS'
/* New function body */
declare
p_rss_id          alias for $1;
p_t_id   alias for $2;

begin
insert into chat_transcription_rss
               ( rss_id,transcription_id)
       values
             (p_rss_id, p_t_id);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

----------------------------------------------

CREATE OR REPLACE FUNCTION chat_transcript__store_partitipants_transcript (integer, varchar) RETURNS integer AS'
/* New function body */
declare
p_transcript_id          alias for $1;
p_partitipant    alias for $2;
begin
insert into chat_partitipants_transcript
               ( transcript_id,partitipant)
       values
             (p_transcript_id,p_partitipant);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

------------------------------------------------

CREATE OR REPLACE FUNCTION chat_transcript__store_sent_files_tanscript (integer, integer) RETURNS integer AS'
/* New function body */
declare
p_transcript_id          alias for $1;
p_f_id   alias for $2;
begin
insert into chat_file_transcript
               ( transcript_id,file_id)
       values
             (p_transcript_id, p_f_id);
return 0;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
































































































