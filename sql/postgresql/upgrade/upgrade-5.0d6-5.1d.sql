-- upgrade script 

alter table chat_rooms add open boolean;
alter table chat_rooms add auto_transcript_p boolean;
alter table chat_rooms add private boolean;
alter table chat_rooms add file_sent boolean;
alter table chat_rooms add frequency1 varchar;

---------------------------------

alter table chat_transcripts add date date;
alter table chat_transcripts add keywords varchar;

---------------------------------

alter table chat_registered_users add frequency_mail varchar;
alter table chat_registered_users add registered_date timestamp(0) without time zone;

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

CREATE OR REPLACE FUNCTION chat_room_registered__user (varchar, integer, integer, boolean, boolean, integer, varchar, varchar) RETURNS integer AS'
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

CREATE OR REPLACE FUNCTION chat_room__delete_registered_users (integer, integer) RETURNS integer AS'
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
            user_registered = p_registered_users
            where room_id = p_room_id;
            
    return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-------------------------------------

CREATE OR REPLACE FUNCTION chat_upload (varchar, varchar, timestamp, varchar, varchar, varchar, varchar) RETURNS integer AS'
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
            user_registered = p_registered_users
            where rss_id = p_rss_id;

    return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-----------------------------------

CREATE OR REPLACE FUNCTION chat_room__edit_admin (varchar, boolean, boolean, integer, integer, varchar, integer, varchar) RETURNS integer AS'
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

 
 
 
