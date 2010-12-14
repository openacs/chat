-- PG 9.0 support 
-- @author Victor Guerra ( vguerra@gmail.com )

create or replace function chat_room__message_post (integer, varchar, integer, varchar)
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
    select nextval(''t_acs_object_id_seq'') into v_msg_id from dual;


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
