ad_page_contract {
@author Pablo Muñoz(@pablomp@tid.es)

} {
    type:notnull
    room_id:integer,notnull
    party_id:integer,notnull
}


if {$type eq "user"} {

set user_id [ad_conn user_id]
#A professor who creates a rooom will be able to admin it.
db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
if { $admin_professor eq "t"} {
} else {
  ad_require_permission $room_id chat_user_grant
}
  chat_user_grant $room_id $party_id
} else {

set user_id [ad_conn user_id]
#A professor who creates a rooom will be able to admin it.
db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
 
if { $admin_professor eq "t"} {

} else {

ad_require_permission $room_id chat_user_ban
} 
  chat_user_ban $room_id $party_id
}
ad_returnredirect "room?room_id=$room_id"

