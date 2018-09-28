#/chat/www/room-exit.tcl
ad_page_contract {
    Post log off message.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 25, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
}

set user_id [ad_conn user_id]
set read_p [permission::permission_p -object_id $room_id -privilege "chat_read"]
set write_p [permission::permission_p -object_id $room_id -privilege "chat_write"]
set ban_p [permission::permission_p -object_id $room_id -privilege "chat_ban"]

if { ($read_p == 0 && $write_p == 0) || ($ban_p == 1) } {
    #Display unauthorize privilege page.
    ad_returnredirect unauthorized
    ad_script_abort
}

# send to AJAX
set session_id [ad_conn session_id]
::chat::Chat c1 -volatile -chat_id $room_id -session_id $session_id
c1 logout

ad_returnredirect index
