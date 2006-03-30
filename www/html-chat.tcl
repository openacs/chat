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

template::list::create -name chat_msg \
    -multirow chat_msg_query \
    -no_data "[_ chat.no_messages]" \
    -page_flush_p 1 \
    -elements {
        creation_date { label "[_ chat.date]" }
        person_name { label "[_ acs-kernel.User]" }
        msg { label "[_ chat.msg]" }
    }
	 
db_multirow -extend { person_name } chat_msg_query select_msg_itens {
    select to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date, creation_user, msg
    from chat_msgs 
    where room_id  = :room_id 
    order by creation_date desc
    limit 20 
} {
    set person_name [person::name -person_id $creation_user]
}

ad_return_template