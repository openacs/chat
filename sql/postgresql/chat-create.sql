--
-- packages/chat/sql/chat-create.sql
--
-- @author ddao@arsdigita.com
-- @creation-date November 09, 2000
-- @cvs-id $Id$
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

---------------------------------------------

CREATE TABLE "public"."chat_rooms" (
  "room_id" INTEGER NOT NULL, 
  "pretty_name" VARCHAR(100) NOT NULL, 
  "description" VARCHAR(2000), 
  "moderated_p" BOOLEAN DEFAULT false, 
  "active_p" BOOLEAN DEFAULT true, 
  "archive_p" BOOLEAN DEFAULT false, 
  "maximal_participants" INTEGER, 
  "end_date" DATE, 
  "creator" INTEGER, 
  "context_id" INTEGER, 
  "comm_name" VARCHAR, 
  CONSTRAINT "chat_rooms_room_id_pk" PRIMARY KEY("room_id"), 
  CONSTRAINT "chat_rooms_active_p_ck" CHECK ((active_p = true) OR (active_p = false)), 
  CONSTRAINT "chat_rooms_archive_p_ck" CHECK ((archive_p = true) OR (archive_p = false)), 
  CONSTRAINT "chat_rooms_moderate_p_ck" CHECK ((moderated_p = true) OR (moderated_p = false)), 
  CONSTRAINT "chat_rooms_fk" FOREIGN KEY ("creator")
    REFERENCES "public"."users"("user_id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE, 
  CONSTRAINT "chat_rooms_room_id_fk" FOREIGN KEY ("room_id")
    REFERENCES "public"."acs_objects"("object_id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) WITH OIDS;


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


---------------------------------

create table chat_transcripts (
    transcript_id      integer
                       constraint chat_trans_transcript_id_pk primary key
                       constraint chat_trans_transcript_id_fk
                       references acs_objects(object_id),
    contents           varchar(32000)
                       constraint chat_trans_contents_nn not null,
    -- Chat transcript name.
    pretty_name        varchar(100)
                       constraint chat_trans_pretty_name_nn not null,
    description        varchar(2000),
    room_id            integer
                       constraint chat_trans_room_id_fk references chat_rooms
);


---------------------------------

create table chat_msgs (
    msg_id             integer
                       constraint chat_msgs_msg_id_pk primary key,
    msg                varchar(4000),
    msg_len            integer
                       constraint chat_msgs_msg_len_ck
                       check (msg_len >= 0),
    html_p             boolean
                       default 'f'
                       constraint chat_msgs_html_p_ck
                       check (html_p in ('t','f')),
    approved_p         boolean
                       default 't'
                       constraint chat_msgs_approve_p_ck
                       check(approved_p in ('t','f')),
    creation_user      integer
                       constraint chat_msgs_creation_user_fk
                       references parties(party_id)
                       constraint chat_msgs_creation_user_nn not null,
    creation_ip        varchar(50) ,
    creation_date      timestamptz,
    room_id            integer
                       constraint chat_msgs_room_id_fk references chat_rooms
);


--------------------------------

CREATE TABLE "public"."chat_registered_users" (
  "alias" VARCHAR(20) NOT NULL, 
  "room_id" INTEGER, 
  "user_id" INTEGER, 
  "rss_service" BOOLEAN, 
  "mail_service" BOOLEAN, 
  "registered_id" INTEGER NOT NULL, 
  CONSTRAINT "chat_registered_users_pkey" PRIMARY KEY("registered_id"), 
  CONSTRAINT "chat_registered_users_fk" FOREIGN KEY ("room_id")
    REFERENCES "public"."chat_rooms"("room_id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE, 
  CONSTRAINT "chat_registered_users_fk1" FOREIGN KEY ("user_id")
    REFERENCES "public"."users"("user_id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE, 
  CONSTRAINT "chat_registered_users_fk2" FOREIGN KEY ("registered_id")
    REFERENCES "public"."acs_objects"("object_id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) WITH OIDS;



---------------------------------

CREATE OR REPLACE FUNCTION "public"."chat_room__new" (varchar, varchar, varchar, varchar, integer, timestamp, boolean, boolean, boolean, boolean, boolean, integer, integer, integer, varchar, varchar) RETURNS integer AS'
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
   v_room_id        chat_rooms.room_id%TYPE;
   v_registered_id  chat_rooms.room_id%TYPE;
   v_comm_name      varchar;
begin
     v_room_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );
     v_registered_id := acs_object__new(null,''chat_room'',now(),p_creation_user,p_creation_ip,p_context_id   );

     if exists (select dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id) then
        select into v_comm_name dot.pretty_name from dotlrn_communities_all as dot where dot.community_id = p_comm_id;
        insert into chat_rooms
               (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name)
       values
             (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,v_comm_name);
     else
         insert into chat_rooms
                (room_id, pretty_name, description, moderated_p, active_p, archive_p, maximal_participants, end_date, creator, context_id,comm_name)
         values
               (v_room_id, p_pretty_name, p_description, p_moderated_p, p_active_p, p_archive_p, p_maxP, p_end_date,p_creation_user, p_context_id,''Dotlrn'');
     end if;


   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id)
   values
       (p_alias, v_room_id, p_creation_user, p_Rss_service, p_Mail_service, v_registered_id);

return v_room_id;

end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;





---------------------------------

create function chat_room__name (integer)
returns varchar as '
declare
   p_room_id         alias for $1;
   v_pretty_name     chat_rooms.pretty_name%TYPE;
begin
     select into v_pretty_name pretty_name from chat_rooms where room_id =  p_room_id;
     return v_pretty_name;
end;' language 'plpgsql';




-------------------------------



create function chat_room__message_count (integer)
returns integer as '
declare
   p_room_id        alias for $1;
   v_count integer;
begin
   select count(*) as total into v_count
   from chat_msgs
   where room_id = p_room_id;
   return v_count;

end;' language 'plpgsql';

---------------------------------



create function chat_room__delete_all_msgs (integer)
returns integer as '
declare
   p_room_id        alias for $1;
begin
   delete from chat_msgs where room_id = p_room_id;
   return 0;
end;' language 'plpgsql';

---------------------------------



create function chat_room__del (integer)
returns integer as '
declare
   p_room_id        alias for $1;
begin

    --TO DO: delete transcriptions?


    -- First erase all the messages relate to this chat room.
    delete from chat_msgs where room_id = p_room_id;
    
     -- Secondly erase all the registered users relate to this chat room.
    delete from chat_registered_users where room_id = p_room_id;

     -- Delete all privileges associate with this room
     delete from acs_permissions where object_id = p_room_id;

     -- Now delete the chat room itself.
     delete from chat_rooms where room_id = p_room_id;

     PERFORM acs_object__delete(p_room_id);

   return 0;
end;' language 'plpgsql';


---------------------------------

CREATE OR REPLACE FUNCTION "public"."chat_room__delete_registered_users" (integer, integer) RETURNS integer AS'
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

CREATE OR REPLACE FUNCTION "public"."chat_room_registered__user" (varchar, integer, integer, boolean, boolean, integer, varchar) RETURNS integer AS'
/* Nuevo cuerpo de Function */
declare
   p_alias          alias for $1;
   p_user_id        alias for $2;
   p_room_id        alias for $3;
   p_RSS_service    alias for $4;
   p_mail_service   alias for $5;
   p_context_id     alias for $6;
   p_creation_ip    alias for $7;
   v_registered_id          chat_rooms.room_id%TYPE;
begin
   v_registered_id := acs_object__new(null,''chat_room'',now(),p_user_id,p_creation_ip,p_context_id   );
   insert into chat_registered_users
       (alias, room_id, user_id, RSS_service, mail_service, registered_id)
   values
       (p_alias, p_room_id, p_user_id, p_RSS_service, p_mail_service, v_registered_id);
return v_registered_id;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

---------------------------------


create function chat_transcript__new (varchar, varchar, varchar, integer, integer, timestamptz, integer,  varchar, varchar)
returns integer as '
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

   insert into chat_transcripts (transcript_id,   pretty_name,   contents,   description,   room_id)
                        values  (v_transcript_id, p_pretty_name, p_contents, p_description, p_room_id);

   return v_transcript_id;
end;' language 'plpgsql';



-----------------------------
create function chat_transcript__del (integer)
returns integer as '
declare
   p_transcript_id      alias for $1;
begin

        -- Delete all privileges associate with this transcript
        delete from acs_permissions where object_id = p_transcript_id;

        delete from chat_transcripts
        where transcript_id = p_transcript_id;

        PERFORM acs_object__delete(p_transcript_id);
        return 0;
end;' language 'plpgsql';
----------------------------


CREATE OR REPLACE FUNCTION "public"."chat_room__edit" (varchar, varchar, varchar, varchar, integer, timestamp, boolean, boolean, boolean, boolean, boolean, integer, integer) RETURNS integer AS'
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
begin

     update chat_rooms set
            pretty_name = p_pretty_name,
            description = p_description,
            maximal_participants = p_maxP,
            end_date = p_end_date,
            moderated_p = p_moderated_p,
            active_p    = p_active_p,
            archive_p   = p_archive_p
            where room_id = p_room_id;
         
     update chat_registered_users set
            alias = p_alias,
            RSS_service = p_Rss_service,
            mail_service = p_Mail_service
            where room_id = p_room_id
            and user_id = p_user_id;
            
            return 0;
end;
'LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


---------------------------

create function chat_room__message_post (integer, varchar, integer, varchar)
returns integer as '
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
end;' language 'plpgsql';

---------------------------


create function chat_transcript__edit (integer, varchar, varchar, varchar )
returns integer as '
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
end;' language 'plpgsql';

































































































