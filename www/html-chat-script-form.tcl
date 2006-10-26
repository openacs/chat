ad_page_contract {
    
    mostra mensagens do chat

    @author TEKNE (tekne@teknedigital.com.br)
    @creation-date 2005-03-09
    
} {
room_id:integer
}

set user_id [ad_conn user_id]

set read_p  [ad_permission_p $room_id "chat_read"]
set write_p [ad_permission_p $room_id "chat_write"]
set ban_p   [ad_permission_p $room_id "chat_ban"]
set active  [room_active_status $room_id]


if { ($read_p == "0" && $write_p == "0") || ($ban_p == "1") || ($active == "f") } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
} 



if { [catch {set room_name [chat_room_name $room_id]} errmsg] } {
    ad_return_complaint 1 "[_ chat.Room_not_found]"
}

set context_bar   "[list $room_name]"

ad_return_template