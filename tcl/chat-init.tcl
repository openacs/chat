# /chat/tcl/chat-init.tcl
ad_library {
    Startup script for the chat system.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
}

## These mutex were needed by the old chat implementation
# nsv_set chat new_message [ns_mutex create oacs:chat]
# nsv_set chat server_started 0
##

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 0 5] chat_flush_rooms

ns_cache create chat_room_cache \
    -size 350000 \
    -timeout [expr {3600 * 24}]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
