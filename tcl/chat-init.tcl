# /chat/tcl/chat-init.tcl
ad_library {
    Startup script for the chat system.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
}

nsv_set chat new_message [ns_mutex create]

nsv_set chat server_started 0

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 0 5] chat_flush_rooms

