#/chat/www/transcript-new.tcl
ad_page_contract {
    Display available all available chat messages.
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    room_id:onevalue
    transcript_id:onevalue
    transcript_name:onevalue
    description:onevalue
    contents:onevalue
}

ad_require_permission $room_id chat_transcript_create

set context_bar [ad_context_bar [list "room?room_id=$room_id" "Room Information"] "Create transcript"]

set transcript_id ""
set transcript_name "Untitled"
set description ""
set contents ""
set action "transcript-new-2"
set title "Create transcript"
set submit_label "Create transcript"

#Build a list of all message.
db_foreach get_archives_messages {
    select msg, person.name(creation_user) as name
    from chat_msgs
    where room_id = :room_id 
          and msg is not null
    order by msg_id
} {
    append contents "<b>$name</b>: $msg<br>\n"
}

ad_return_template "transcript-entry"








