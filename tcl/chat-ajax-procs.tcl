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
          {-skin:optional ""}
        }}
      } -ad_doc {
          Include a chat room

          @param chat_id
          @param mode
          @param path
          @param skin
      }


  chat_room instproc render {} {
      :get_parameters
      return [::chat::Chat login \
                  -chat_id $chat_id \
                  -mode    $mode \
                  -path    $path \
                  -skin    $skin]
  }

}

namespace eval ::chat {
    ::xo::ChatClass Chat -superclass ::xowiki::Chat

    Chat proc login {-chat_id {-package_id ""} {-mode ""} {-path ""} {-skin ""}} {
        if {![::xo::db::Class exists_in_db -id $chat_id]} {
            return [_ chat.Room_not_found]
        } else {
            set r [::xo::db::Class get_instance_from_db -id $chat_id]
            set package_id [$r set package_id]
            if {$skin eq ""} {
                set skin [parameter::get -package_id $package_id -parameter ChatSkin]
            }
            next -chat_id           $chat_id \
                 -skin              $skin \
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
            ::acs::clusterwide nsv_set [self]-$room_id-seen last [clock scan $last_activity]
        }
    }

    Chat instproc init {} {
        # Instantiating a chat outside a connection context happens
        # e.g. in the sweeper. We don't want to check permissions in
        # this case.
        if {[ns_conn isconnected]} {
            # Check that user can read the chat and is not banned
            if {![permission::permission_p -object_id ${:chat_id} -privilege "chat_read"] ||
                 [permission::permission_p -object_id ${:chat_id} -privilege "chat_ban"]} {
                ad_return_forbidden
                ad_script_abort
            }
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

        #
        # Check write permissions for the chat user
        #
        if {[string is integer -strict $uid]} {
            #
            # The uid is an integer, that we expect to correspond to a
            # party_id.
            #
            set party_id $uid
        } else {
            #
            # The uid is another kind of anonymous identifier
            # (e.g. the IP address). We map these to the public.
            #
            set party_id [acs_magic_object the_public]
        }
        permission::require_permission \
            -party_id $party_id \
            -object_id ${:chat_id} \
            -privilege "chat_write"

        set r [::xo::db::Class get_instance_from_db -id ${:chat_id}]

        # ignore empty messages
        if {$msg eq ""} return

        # code around expects the return value of the original method
        set retval [next]

        #
        # Persist the chat message. We take note of the creation user,
        # which may be The Public for anonymous participants and the
        # IP address.
        #
        if {[:current_message_valid]} {
            $r post_message \
                -msg $msg \
                -creation_user $party_id \
                -creation_ip [ad_conn peeraddr]
        }

        return $retval
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
