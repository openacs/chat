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
set submit_label "[_ chat.Create_transcript]"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set active_p [$r set active_p]

set messages [$r transcript_messages]
set messages_html "<div id='messages'><pre>"
foreach m $messages {
    append messages_html "$m<br>"
}
append messages_html "</pre></div>"

ad_form \
    -name transcript_entry \
    -export {transcript_id room_id} \
    -has_submit 1 \
    -actions {$action} \
    -form {
        {transcript_name:text(text)
            {label {[_ chat.Transcript_name]}}
            {help_text {}}
            {html {size 60}}
            {value {$transcript_name}}
        }
        {delete_messages:text(checkbox),optional
            {label {[_ chat.Delete_messages]}}
            {options {{"#chat.delete_messages_after_transcript#" t}}}
        }
        {deactivate_room:text(checkbox),optional
            {label {[_ chat.Room_deactivate]}}
            {options {{"#chat.deactivate_room_after_transcript#" t}}}
        }
        {description:text(textarea),optional
            {label {[_ chat.Description]}}
        }
        {messages:text(inform),optional,noquote
            {label {[_ chat.Contents]}}
            {value {$messages_html}}
        }
        {submit:text(submit)
            {label $submit_label}
        }

    } -on_submit {
        permission::require_permission -object_id $room_id -privilege chat_transcript_create

        set user_id [ad_conn user_id]
        set creation_ip [ad_conn peeraddr]
        
        set r [::xo::db::Class get_instance_from_db -id $room_id]
        
        set transcript_id [$r create_transcript \
                               -pretty_name $transcript_name \
                               -description $description \
                               -creation_user $user_id \
                               -creation_ip $creation_ip]
        ns_log notice "DELETE MESSAGES: $delete_messages"
        if { $delete_messages eq "t" } {
            $r delete_messages
            # forward the information to AJAX
            ::chat::Chat flush_messages -chat_id $room_id
        }
        
        if { $deactivate_room eq "t" } {
            $r set active_p false
            $r save
        }
        
        ad_returnredirect "chat-transcript?room_id=$room_id&transcript_id=$transcript_id"
        ad_script_abort
    }


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
