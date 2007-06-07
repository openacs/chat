#/chat/www/transcript-new-2.tcl
ad_page_contract {
    Save transcript.
    @author Pablo Muñoz(pablomp@tid.es)
} {
    room_id:integer,notnull
    transcript_name:trim,notnull
    {description:trim ""}
    {keywords:trim ""}
    {delete_messages:optional "off"}
    {deactivate_room:optional "off"}
    contents:trim,notnull,html
} 

permission::require_permission -object_id $room_id -privilege chat_transcript_create

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set creation_ip [ad_conn peeraddr]

set transcript_id [chat_transcript_new \
    -description $description \
    -context_id $package_id \
    -creation_user $user_id \
    -creation_ip $creation_ip \
    $transcript_name $contents $room_id
]

#store_transcripts_keywords $keywords transcript_id
for {set i 0} {$i < [llength $keywords]} {incr i 1} {
    	set word [lindex $keywords $i]
    	#set k [store_transcripts_keywords $word $transcript_id]
    	db_exec_plsql store_transcripts_keywords {}
	}	



if { $delete_messages eq "on" } {
    chat_room_message_delete $room_id
    # forward the information to AJAX
    ::chat::Chat flush_messages -chat_id $room_id
}

if { $deactivate_room eq "on" } {
    db_dml "update_chat" "update chat_rooms set active_p = 'f' where room_id = $room_id"
}



ad_returnredirect "chat-transcript?room_id=$room_id&transcript_id=$transcript_id"


ad_proc store_transcripts_keywords { 
	keywords
	transcript_id
} {
	for {set i 0} {$i < [llength $keywords]} {incr i 1} {
    	set word [lindex $keywords $i]
    	#set k [store_transcripts_keywords $word $transcript_id]
    	db_exec_plsql store_transcripts_keywords {}
	}	
	
}	