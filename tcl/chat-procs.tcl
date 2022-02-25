ad_library {
    TCL Library for the chat system v.6

    These procs serve now only as a backward compatibility layer, as
    all the relevant logic is implemented in xotcl-chat-procs. These
    procs will soon be deprecated.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 17, 2000
    @cvs-id $Id$
}

ad_proc -deprecated -public chat_room_get {
    {-room_id {}}
    {-array:required}
} {
    Get all the information about a chat room into an array

    @see ::xo::db::chat_room
} {
    upvar $array row
    array set row [ns_cache eval chat_room_cache $room_id {
        chat_room_get_not_cached $room_id
    }]
    #array set row [chat_room_get_not_cached $room_id]
}

ad_proc -deprecated -private chat_room_get_not_cached {
    room_id
} {
    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    foreach var [$r info vars] {
        set row($var) [$r set $var]
    }
    # todo: extend oo machinery so these attributes are also returned
    # by get_instance_from_db
    acs_object::get \
        -object_id $room_id \
        -array obj
    set row(object_id)      $obj(object_id)
    set row(context_id)     $obj(context_id)
    set row(creation_user)  $obj(creation_user)
    set row(creation_date)  $obj(creation_date_ansi)
    set row(creation_ip)    $obj(creation_ip)
    set row(modifying_user) $obj(modifying_user)
    set row(last_modified)  $obj(last_modified_ansi)
    set row(modifying_ip)   $obj(modifying_ip)
    return [array get row]
}

ad_proc -deprecated -public chat_room_new {
    {-description ""}
    {-moderated_p f}
    {-active_p t}
    {-archive_p f}
    {-auto_flush_p t}
    {-auto_transcript_p f}
    {-login_messages_p t}
    {-logout_messages_p t}
    {-messages_time_window 600}
    {-context_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    {-avatar_p t}
    pretty_name
} {
    Create new chat room. Return room_id if successful else raise error.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::chat_room new \
               -description          $description \
               -moderated_p          $moderated_p \
               -active_p             $active_p \
               -archive_p            $archive_p \
               -auto_flush_p         $auto_flush_p \
               -auto_transcript_p    $auto_transcript_p \
               -login_messages_p     $login_messages_p \
               -logout_messages_p    $logout_messages_p \
               -messages_time_window $messages_time_window \
               -avatar_p             $avatar_p \
               -pretty_name          $pretty_name]
    $r set context_id    $context_id
    $r set creation_user $creation_user
    $r set creation_ip   $creation_ip
    return [$r save_new]
}

ad_proc -deprecated -public chat_room_exists_p {
    room_id
} {
    Return whether a chat room exists

    @return a boolean

    @see ::xo::db::chat_room
} {
    return [::xo::db::Class exists_in_db -id $room_id]
}

ad_proc -deprecated -public chat_room_edit {
    room_id
    pretty_name
    description
    moderated_p
    active_p
    archive_p
    auto_flush_p
    auto_transcript_p
    login_messages_p
    logout_messages_p
    messages_time_window
    avatar_p
} {
    Edit information on chat room. All information require.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    foreach var {
        pretty_name
        description
        moderated_p
        active_p
        archive_p
        auto_flush_p
        auto_transcript_p
        login_messages_p
        logout_messages_p
        messages_time_window
        avatar_p
    } {
        $r set $var [set $var]
    }
    $r save
    ns_cache flush -- chat_room_cache $room_id
}

ad_proc -deprecated -public chat_room_delete {
    room_id
} {
    Delete chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r delete
    ns_cache flush -- chat_room_cache $room_id
}

ad_proc -deprecated -public chat_room_message_delete {
    room_id
} {
    Delete all message in the room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r delete_messages
}

ad_proc -deprecated -public chat_message_count {
    room_id
} {
    Get message count in the room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r count_messages
}

ad_proc -deprecated -public room_active_status {
    room_id
} {
    Get room active status.

    @see ::xo::db::chat_room
} {
    if {[::xo::db::Class exists_in_db -id $room_id]} {
        set r [::xo::db::Class get_instance_from_db -id $room_id]
        return [string is true -strict [$r set active_p]]
    } else {
        return false
    }
}

ad_proc -deprecated -public chat_room_name {
    room_id
} {
    Get chat room name.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    return [$r set pretty_name]
}

ad_proc -deprecated -public chat_moderator_grant {
    room_id
    party_id
} {
    Grant party a chat moderate privilege to this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r grant_moderator -party_id $party_id
}

ad_proc -deprecated -public chat_moderator_revoke {
    room_id
    party_id
} {
    Revoke party a chat moderate privilege to this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r revoke_moderator -party_id $party_id
}

ad_proc -deprecated -public chat_user_grant {
    room_id
    party_id
} {
    Grant party a chat privilege to this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r grant_user -party_id $party_id
}

ad_proc -deprecated -public chat_user_revoke {
    room_id
    party_id
} {
    Revoke party a chat privilege to this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r revoke_user -party_id $party_id
}

ad_proc -deprecated -public chat_user_ban {
    room_id
    party_id
} {
    Explicit ban user from this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r ban_user -party_id $party_id
}

ad_proc -deprecated -public chat_user_unban {
    room_id
    party_id
} {
    unban user from this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r unban_user -party_id $party_id
}

ad_proc -deprecated -public chat_revoke_moderators {
    room_id
    revoke_list
} {
    Revoke a list of parties of a moderate privilege from this room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r revoke_moderator -party_id $revoke_list
}

ad_proc -deprecated -public chat_room_moderate_p {
    room_id
} {
    Return the moderate status of this chat room.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    return [$r set moderated_p]
}

ad_proc -deprecated -public chat_user_name {
    user_id
} {
    Return display name of this user to use in chat.

    @see ::chat::Package
} {
    return [::chat::Package get_user_name -user_id $user_id]
}

ad_proc -deprecated -public chat_message_post {
    room_id
    user_id
    message
    moderator_p
} {
    Post message to the chat room and broadcast to all applet clients. Used by ajax + html.

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r post_message -msg $message -creation_user $user_id
}

ad_proc -deprecated -public chat_transcript_new {
    {-description ""}
    {-context_id ""}
    {-creation_user ""}
    {-creation_ip ""}
    pretty_name
    contents
    room_id
} {
    Create chat transcript.

    @see ::xo::db::chat_transcript
} {
    set t [::xo::db::chat_transcript new \
               -description $description \
               -pretty_name $pretty_name \
               -contents $contents \
               -room_id $room_id]
    $t set context_id    $context_id
    $t set creation_user $creation_user
    $t set creation_ip   $creation_ip
    return [$t save_new]
}

ad_proc -deprecated -public chat_transcript_delete {
    transcript_id
} {
    Delete chat transcript.

    @see ::xo::db::chat_transcript
} {
    ::acs::dc call acs_object delete \
        -object_id $transcript_id
}

ad_proc -deprecated -public chat_transcript_edit {
    transcript_id
    pretty_name
    description
    contents
} {
    Edit chat transcript.

    @see ::xo::db::chat_transcript
} {
    set t [::xo::db::Class get_instance_from_db -id $transcript_id]
    foreach var {
        pretty_name
        description
        contents
    } {
        $t set $var [set $var]
    }
    $t save
}

ad_proc -private chat_flush_rooms {} {
    Flush the messages in all of the chat rooms

    @see ::chat::Package
} {
    ::chat::Package flush_rooms
}

ad_proc -private chat_room_flush {
    room_id
} {
    Flush the messages a single chat room

    @see ::xo::db::chat_room
} {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r flush
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
