ad_page_contract {
    Log on chat room.
    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date September 19, 2006    
} {
	room_id
	action
}
set user_id [ad_conn user_id]
set delete [chat_room_delete_registered_users $room_id $user_id]
ad_returnredirect $action