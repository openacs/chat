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
      set html [subst {
        <div id='xowiki-chat-includelet'>
            [::chat::Chat login \
                  -chat_id $chat_id \
                  -mode    $mode \
                  -path    $path]
        </div>
      }]
  }

}

namespace eval ::chat {
    ::xo::ChatClass Chat -superclass ::xowiki::Chat

    Chat proc login {-chat_id {-package_id ""} {-mode ""} {-path ""}} {
        if {![::xo::db::Class exists_in_db -id $chat_id]} {
            return [_ chat.Room_not_found]
        } else {
            set r [::xo::db::Class get_instance_from_db -id $chat_id]
            set package_id [$r set context_id]
            set chat_skin [parameter::get -package_id $package_id -parameter ChatSkin]
            next -chat_id           $chat_id \
                 -skin              $chat_skin \
                 -package_id        $package_id \
                 -mode              $mode \
                 -path              $path \
                 -logout_messages_p [$r set logout_messages_p] \
                 -login_messages_p  [$r set login_messages_p] \
                 -timewindow        [$r set messages_time_window] \
                 -avatar_p          [$r set avatar_p]
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
        # Check read permissions
        set forbidden_p [expr {
                               ![permission::permission_p -object_id ${:chat_id} -privilege "chat_read"] ||
                               [permission::permission_p -object_id ${:chat_id} -privilege "chat_ban"]
                           }]
        if {$forbidden_p} {
            ad_return_forbidden
            ad_script_abort
        }
        next
    }

    # if chat doesn't exist anymore, send a message that will inform
    # the user of being looking at an invalid chat
    Chat instproc check_valid_room {} {
        if {![::xo::db::Class exists_in_db -id [:chat_id]]} {
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
        if {![::xo::db::Class exists_in_db -id ${:chat_id}]} {
            return
        }

        set uid [expr {$uid ne "" ? $uid : ${:user_id}}]

        # Check write permissions
        permission::require_permission \
            -party_id $uid \
            -object_id ${:chat_id} \
            -privilege "chat_write"

        set r [::xo::db::Class get_instance_from_db -id ${:chat_id}]

        # ignore empty messages
        if {$msg eq ""} return

        # code around expects the return value of the original method
        set retval [next]

        # This way messages can be persisted immediately every time a
        # message is sent
        if {[:current_message_valid]} {
            $r post_message -msg $msg -creation_user $uid
        }

        return $retval
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
