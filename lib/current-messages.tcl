
set sql {
    select to_char(creation_date, 'DD.MM.YYYY hh24:mi:ss') as creation_date, creation_user, msg 
    from chat_msgs 
    where room_id  = :room_id 
    order by creation_date
}

db_multirow -extend { person_name } messages select_msg_itens $sql {
    db_1row room_info2 {
    		select count(r.alias)
    		from chat_registered_users r
    		where r.user_id = :creation_user
    		and r.room_id = :room_id
    }
    if { $count > 0} {
	db_1row room_info2 {
		select r.alias
		from chat_registered_users r
    		where r.user_id = :creation_user
    		and r.room_id = :room_id
	}
        if { [catch { set person_name [chat_user_name2 $creation_user $alias] }] } {
        	set person_name "System"
    	}
    } else {
    	if { [catch { set person_name [chat_user_name $creation_user] }] } {
        	set person_name "System"
    	}
    }
}
