ad_page_contract {
    mostra mensagens do chat
} {
   page:optional
}   -properties {
    room_id:onevalue
}
   
set user_id [ad_conn user_id]
set read_p  [ad_permission_p $room_id "chat_read"]
set write_p [ad_permission_p $room_id "chat_write"]
set ban_p   [ad_permission_p $room_id "chat_ban"]
set active  [room_active_status $room_id]

# get the "rich" client settings
set richclient(short) [parameter::get -parameter "DefaultClient"]
set richclient(msg) "[_ chat.${richclient(short)}_client_msg]"
set richclient(title) "[_ chat.[string totitle $richclient(short)]]"

if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") || ($active == "f") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

if { [catch {set room_name [chat_room_name $room_id]} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
}

::chat::Chat c1 -volatile -encoder noencode -chat_id $room_id
set html_chat [c1 get_all]
set html_users [c1 get_users]

ad_return_template