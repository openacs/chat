begin;

    drop package chat_room;
    drop package chat_transcript;

    alter table chat_rooms add messages_time_window integer default 600;

    alter table chat_rooms drop constraint chat_rooms_room_id_fk;
    alter table chat_rooms add  constraint chat_rooms_room_id_fk
          foreign key (room_id) references acs_objects(object_id) on delete cascade;

    alter table chat_transcripts drop constraint chat_trans_transcript_id_fk;
    alter table chat_transcripts add  constraint chat_trans_transcript_id_fk
          foreign key (transcript_id) references acs_objects(object_id) on delete cascade;

    alter table chat_transcripts drop constraint chat_trans_room_id_fk;
    alter table chat_transcripts add  constraint chat_trans_room_id_fk
          foreign key (room_id) references chat_rooms(room_id) on delete cascade;

    alter table chat_msgs drop constraint chat_msgs_creation_user_fk;
    alter table chat_msgs add  constraint chat_msgs_creation_user_fk
          foreign key (creation_user) references parties(party_id) on delete cascade;

    alter table chat_msgs drop constraint chat_msgs_room_id_fk;
    alter table chat_msgs add  constraint chat_msgs_room_id_fk
          foreign key (room_id) references chat_rooms(room_id) on delete cascade;

end;
