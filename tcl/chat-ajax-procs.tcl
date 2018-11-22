ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @author Peter Alberer
    @cvs-id $Id$
}

namespace eval ::xowiki::includelet {

  ::xowiki::IncludeletClass create chat_room \
      -superclass ::xowiki::Includelet \
      -parameter {
        {parameter_declaration {
          {-chat_id}
          {-mode:optional ""}
          {-path:optional ""}
        }}
      }

  chat_room instproc render {} {
      :get_parameters
      return [::chat::Chat login \
                  -chat_id $chat_id \
                  -mode    $mode \
                  -path    $path]
  }

}

namespace eval ::chat {
    ::xo::ChatClass Chat -superclass ::xowiki::Chat

    Chat proc login {-chat_id {-package_id ""} {-mode ""} {-path ""}} {
        if {![chat_room_exists_p $chat_id]} {
            return [_ chat.Room_not_found]
        } else {
            chat_room_get -room_id $chat_id -array c
            next -chat_id $chat_id \
                -package_id $c(context_id) \
                -mode $mode \
                -path $path \
                -logout_messages_p $c(logout_messages_p) \
                -login_messages_p $c(login_messages_p) \
                -timewindow $c(messages_time_window)
        }
    }

    Chat instproc initialize_nsvs {} {
        next

        # read the last_activity information at server start into a nsv array
        ::xo::dc foreach get_rooms {
            select room_id, to_char(max(creation_date),'HH24:MI:SS YYYY-MM-DD') as last_activity
            from chat_msgs group by room_id
        } {
            ::xo::clusterwide nsv_set [self]-$room_id-seen last [clock scan $last_activity]
        }
    }

    Chat instproc init {} {
        set ban_p [permission::permission_p -object_id ${:chat_id} -privilege "chat_ban"]
        if {$ban_p} {
            ad_return_forbidden
            ad_script_abort
        }
        next
    }

    # if chat doesn't exist anymore, send a message that will inform
    # the user of being looking at an invalid chat
    Chat instproc check_valid_room {} {
        if {![chat_room_exists_p [:chat_id]]} {
            ns_return 500 text/plain "chat-errmsg: [_ chat.Room_not_found]"
            ad_script_abort
        }
    }

    Chat instproc get_new {} {
        :check_valid_room
        next
    }

    Chat instproc add_msg {
        {-get_new:boolean true}
        {-uid ""}
        msg
    } {
        if {![chat_room_exists_p ${:chat_id}]} {
            return
        }

        # ignore empty messages
        if {$msg eq ""} return

        # code around expects the return value of the original method
        set retval [next]

        # This way messages can be persisted immediately every time a
        # message is sent
        if {[:current_message_valid]} {
            set uid [expr {$uid ne "" ? $uid : ${:user_id}}]
            chat_message_post ${:chat_id} $uid $msg 1
        }

        return $retval
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
