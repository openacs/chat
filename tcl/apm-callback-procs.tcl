ad_library {

    APM Callback procs

}

namespace eval chat::apm {}

ad_proc -private chat::apm::after_upgrade {
    -from_version_name:required
    -to_version_name:required
} {
    Upgrade logics for the chat package
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
	    6.0.0d3 6.0.0d4 {
                ns_write "\n\nDeleting obsolete parameters"
                set parameter_names {
                    AppletHeight
                    AppletWidth
                    DefaultClient
                    ServerHost
                    ServerPort
                    ShowAvatarP
                }
                ::xo::dc foreach get_parameters [subst {
                    select parameter_id, parameter_name
                      from apm_parameters
                    where package_key = 'chat'
                      and parameter_name in ('[join $parameter_names ',']')
                }] {
                    apm_parameter_unregister \
                        -package_key chat $parameter_id
                    ns_write "\n - deleting obsolete parameter chat.$parameter_name"
                }
                ns_write "\nFinished!"
            }
	    6.0.0d6 6.0.0d7 {
                ns_write "<br>Setting rooms and transcripts package_id to context_id where missing"
                set n_rows [::xo::dc dml update_package {
                    update acs_objects set
                    package_id = context_id
                    where object_type in ('chat_room', 'chat_transcript')
                    and package_id is null
                }]
                ns_write "<br>$n_rows objects updated."
                ns_write "<br>Finished!"
            }
        }
}
