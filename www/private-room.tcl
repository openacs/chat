ad_page_contract {
    page to add a new file to the system

    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date 26 Feb 2007    
} {
    room_id:integer,optional
    user_id1:integer,optional
    user_id2:integer,optional    
} -properties {
    context_bar:onevalue
    room_id:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    pretty_name:onevalue
    moderated_p:onevalue
}

#ad_require_permission [ad_conn package_id] chat_room_create

set context_bar [list "[_ chat.Create_a_room]"]
set title "[_ chat.Create_a_room]"
set action "room-new-2"
set submit_label "[_ chat.Create_room]"
set pretty_name ""
set description ""
set archive_p "t"
set active_p "t"
set moderated_p "f"

set maxP ""
set minP ""
set end_date ""
set key_words ""
set alias ""
set Rss_service ""
set frequency [list daily monthly weekly] 

#permission::require_permission -object_id [ad_conn package_id] -privilege chat_room_edit

set user_id [ad_conn user_id]


if { ![info exists room_id] } {
    set title "[_ chat.Create_a_new_room]"
} else {
    set title "[_ chat.Edit_room] \"[chat_room_name $room_id]\""
}

set user_id [ad_conn user_id]


db_1row room_info {
        select rm.room_id,
           rm.pretty_name as pretty_name,
           rm.description as description,
           rm.moderated_p as moderated,
           rm.maximal_participants as max_p,
           rm.active_p as active_p,
           rm.archive_p as archive_p,
           rm.end_date as end_date,    
           (select ru.alias
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as alias,
           (select ru.RSS_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as rss_service,
           (select ru.mail_service
           from chat_registered_users ru
           where rm.room_id = ru.room_id
           and ru.user_id = :user_id) as mail_service
    from chat_rooms rm
    where rm.room_id = :room_id
}

if { $alias eq "" } {
	db_1row room_info {
		select du.first_names as alias
		from dotlrn_users as du, users as u
		where u.user_id = :user_id
		and u.user_id = du.user_id
		
	}	
}

	set date [lrange $end_date 0 2]
	set comm_id [dotlrn_community::get_community_id]
	if { $comm_id eq "" } {
		set comm_id 0
	} else {
		set comm_id [dotlrn_community::get_community_id]
	}
	
	append name $pretty_name "_private_"
	set pretty_name ""
	append pretty_name $name $alias	
	if {[catch {set room_id [chat_room_private_new \
	                      -alias $alias \
                              -key_words "dsa" \
                              -maxP $max_p \
                              -end_date $date \
                              -Rss_service "true" \
                              -Mail_service "true" \
                              -moderated_p $moderated_p \
                              -active_p $active_p \
                              -archive_p $archive_p \
                              -auto_flush_p t \
                              -auto_transcript_p t \
                              -context_id [ad_conn package_id] \
                              -comm_id $comm_id \
                              -creation_user [ad_conn user_id] \
                              -creation_ip [ad_conn peeraddr] \
                              -private "true" \
                              $description $pretty_name]} errmsg]} {
        ad_return_complaint 1 "[_ chat.Create_new_room_failed]: $errmsg"
        break
    }
   db_dml insert_users {insert into chat_private_room_users (room_id,user_id1,user_id2) values (:room_id,:user_id1,:user_id2);}   
ad_returnredirect "chat?room_id=$room_id&client=ajax"  

