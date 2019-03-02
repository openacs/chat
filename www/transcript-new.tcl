#/chat/www/transcript-new.tcl
ad_page_contract {
    Display available all available chat messages.
} {
    room_id:naturalnum,notnull
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

permission::require_permission -object_id $room_id -privilege chat_transcript_create

set title "[_ chat.Create_transcript]"
set context [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] $title]

set transcript_id ""
set transcript_name "[_ chat.transcript_of_date] [clock format [clock seconds] -format "%d.%m.%y %H:%M:%S"]"
set description ""
set contents ""
set action "transcript-new-2"
set submit_label "[_ chat.Create_transcript]"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set active_p [$r set active_p]

#Build a list of all message.
db_foreach get_archives_messages {} {
    set user_name [::chat::Package get_user_name -user_id $creation_user]
    append contents "\[$creation_date\] <b>$user_name</b>: $msg<br>\n"
}

ad_return_template "transcript-entry"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
