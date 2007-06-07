ad_page_contract {
    Options chat room.
    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date October 10, 2006    
} {
    action
    room_id
    {transcript_id:integer,optional 0}
}
set user_id [ad_conn user_id]


db_1row room_info {
        select rm.room_id,               
           (select ru.alias
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as alias,
           (select ru.RSS_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as rss_service,
           (select ru.mail_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as mail_service
    from chat_rooms rm
    where rm.room_id = :room_id
}



 
ad_return_template "options"
   