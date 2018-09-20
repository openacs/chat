ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @author Peter Alberer
    @cvs-id $Id$
}

namespace eval ::chat {
    ::xo::ChatClass Chat -superclass ::xo::Chat

    Chat instproc init {} {
        :instvar chat_id
        if {[chat_room_exists_p $chat_id]} {
            chat_room_get -room_id $chat_id -array c
            set :login_messages_p  $c(login_messages_p)
            set :logout_messages_p $c(logout_messages_p)
            set :timewindow        $c(messages_time_window)
        }
        next
    }

    Chat proc login {-chat_id -package_id} {
        auth::require_login
        if {![info exists package_id]} {
            set package_id [ad_conn package_id]
        }
        if {![info exists chat_id]} {
            set chat_id $package_id
        }

        set path [lindex [site_node::get_url_from_object_id -object_id $package_id] 0]
        set base_url ${path}ajax/chat
        template::head::add_javascript -src ${base_url}.js
        set base_url [export_vars -base ${base_url} {{id $chat_id} {s "[ad_conn session_id].[clock seconds]"}}]

        set login_url [ns_quotehtml "${base_url}&m=login"]
        set send_url  "${base_url}&m=add_msg&msg="
        set users_url [ns_quotehtml "${base_url}&m=get_users"]
        set html_url [ns_quotehtml [ad_conn url]?[ad_conn query]]
        regsub {client=ajax} $html_url {client=html} html_url

        return [subst {
          <script type='text/javascript' nonce='$::__csp_nonce'>
              // register the data sources (for sending messages,
              // receiving updates)
              var pushMessage = registerDataConnection(pushReceiver, '${base_url}&m=get_new', false);
              var pullUpdates = registerDataConnection(updateReceiver, '${base_url}&m=get_updates', true);
          </script>
          <form id='ichat_form' name='ichat_form' action='#'>
            <iframe name='ichat' id='ichat' title='#chat.Conversation_area#'
                    src='$login_url'>
            </iframe>
            <iframe name='ichat-users' id='ichat-users' title='#chat.Participants_list#'
                    src='$users_url'>
            </iframe>
            <noframes>
              <p>#chat.Your_browser_doesnt_support_#</p>
              <p><a href='$html_url'>#chat.Go_to_html_version#</a></p>
            </noframes>
            <div id='ichat-message'>
              #chat.message# <input tabindex='1' type='text' size='80' name='msg' id='chatMsg'>
              <input type='submit' value='#chat.Send_Refresh#'>
            </div>
          </form>

          <script type='text/javascript' nonce='$::__csp_nonce'>
              // Get a first update of users when the iframe is ready,
              // then register a 5s interval to get new ones
              document.getElementById('ichat-users').addEventListener('load', function (event) {
                  updateDataConnections();
              }, false);
              document.getElementById('ichat_form').addEventListener('submit', function (event) {
                  event.preventDefault();
                  pushMessage.chatSendMsg('$send_url');
              }, false);
              var updateInterval = setInterval(updateDataConnections,5000);
          </script>
        }]
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
        if {![chat_room_exists_p [:chat_id]]} {
            return
        }

        # ignore empty messages
        if {$msg eq ""} return

        # code around expects the return value of the original method
        set retval [next]

        # This way messages can be persisted immediately every time a
        # message is sent
        if {[:current_message_valid]} {
            chat_message_post [:chat_id] [:user_id] $msg 1
        }

        return $retval
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
