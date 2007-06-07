
db_1row get_transcript {
    select pretty_name as transcript_name,
           description,
           contents,
           room_id
    from chat_transcripts
    where transcript_id=:transcript_id
}

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
set edit_p 1
} else {
set edit_p [permission::permission_p -object_id $room_id -privilege "chat_transcript_edit"]
}
