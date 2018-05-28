# /chat/tcl/chat-init.tcl
ad_library {
    Startup script for the chat system.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
}

nsv_set chat new_message [ns_mutex create oacs:chat]

nsv_set chat server_started 0

ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 0 5] chat_flush_rooms

#
# Create a cache for keeping chat_room info
#
# The chat_room_cache can be configured via the config file like the
# following:
#
#    ns_section ns/server/${server}/acs/chat
#         ns_param ChatRoomCacheSize                    350000
#         ns_param ChatRoomCacheTimeout     [expr {3600 * 24}]
#
ns_cache create chat_room_cache \
    -size [parameter::get \
	       -package_id [apm_package_id_from_key chat] \
	       -parameter ChatRoomCacheSize \
	       -default 350000] \
    -timeout [parameter::get \
	       -package_id [apm_package_id_from_key chat] \
	       -parameter ChatCacheTimeout \
		  -default [expr {3600 * 24}]]
