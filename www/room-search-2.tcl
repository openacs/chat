ad_page_contract {
    Display a form to create a new room.

    @author Pablo Muñoz (pablomp@tid.es)    
} {   
   pretty_name
   date2   
   partitipants   
   key_words
   sent_files
   sent_files_title   
}
#set transcript_delete_p [permission::permission_p -object_id $room_id -privilege chat_transcript_delete]
#set transcript_view_p [permission::permission_p -object_id $room_id -privilege chat_transcript_view]

set query ""
set query1 ""
set query2 ""
set query3 ""
set query4 ""
set query5 ""
set query6 ""



#append query "select distinct cr.pretty_name, cr.description,cr.comm_name,cr.creator,ao.creation_date,cr.room_id
#    from chat_partitipants_transcript ptr,chat_transcripts ct,acs_objects ao, chat_keywords as ck, chat_rooms_files_sent fs, chat_rooms cr where" 

append query "select distinct cr.pretty_name, cr.description,cr.comm_name,cr.creator,ao.creation_date,cr.room_id
from acs_objects ao, chat_rooms cr" 
 


if { !($partitipants eq "") } {	
		append query ",chat_partitipants_transcript ptr"		
}
if { !($sent_files_title eq "") } {	
		append query ",chat_rooms_files_sent fs"		
}
if { !($sent_files eq "") } {	
		if { $sent_files_title eq "" } {
			append query ",chat_rooms_files_sent fs"
		}	
}
if { !($key_words eq "") } {	
		append query ",chat_keywords ck"	
}

    
if { !($pretty_name eq "") } {	
	set query1 " where cr.pretty_name = :pretty_name"
	
}
if {!($date2 eq "") } {
	if { !($pretty_name eq "") } {
			set query2 " and cr.end_date = :date2 "
			
	} else {
			set query2 " where cr.end_date = :date2 "
			
	}
}
if { !($partitipants eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "")} {
		set query3 " and ptr.partitipant = :partitipants and ptr.transcript_id = ct.transcript_id and ct.room_id = cr.room_id"
		
	} else {
		set query3 " where ptr.partitipant = :partitipants and ptr.transcript_id = ct.transcript_id and ct.room_id = cr.room_id "
		
	}
}
if { !($sent_files_title eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") } {
		set query4 " and fs.title = :sent_files_title and fs.room_id = cr.room_id"
		
	} else {
		set query4 " where fs.title = :sent_files_title and fs.room_id = cr.room_id "
		
	}
}
if { !($sent_files eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") || !($sent_files_title eq "") } {
		
		set query5 " and fs.file = :sent_files and fs.room_id = cr.room_id"
		
	} else {
		
		set query5 " where fs.file = :sent_files and fs.room_id = cr.room_id "
		
	}
}
if { !($key_words eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") || !($sent_files_title eq "") || !($sent_files eq "") } {
		
		set query6 " and ck.keyword = :key_words and ck.room_id = cr.room_id"
		
	} else {
		
		set query6 " where ck.keyword = :key_words and ck.room_id = cr.room_id "
		
	}
}
set creation_date ""
set query7 " and cr.room_id = ao.object_id
    order by ao.creation_date desc"
set queryT [concat $query $query1 $query2 $query3 $query4 $query5 $query6 $query7]
#$date2
#$queryT
db_multirow -extend { creation_date_pretty creator_name admin_p user_p path path2 path3 path4} chat_room *SQL* $queryT {
	set path ""
	set path2 ""
	set path3 ""
	set path4 ""
    set creation_date_pretty [lc_time_fmt $creation_date "%q %X"]
		db_1row room_info {
  							select p.first_names as first_names, p.last_name as last_name
  							from persons p
  							where p.person_id = :creator
  	}
    append msg_creator1 $first_names " "
  	append creator_name $msg_creator1 $last_name
  	set user_id [ad_conn user_id]
  	db_1row room_info {
  		select acs_permission__permission_p(room_id, :user_id, 'chat_room_admin') as admin_p,
  		(select site_node__url(site_nodes.node_id)
                   from site_nodes
                   where site_nodes.object_id = obj.context_id) as base_url,
    					acs_permission__permission_p(room_id, :user_id, 'chat_read') as user_p
    					from chat_rooms rm, acs_objects obj
    					where rm.room_id = obj.object_id
    					and rm.room_id = :room_id
		}
		append path $base_url "options?action=&room_id=$room_id"
		append path2 $base_url "chat-transcripts?room_id=$room_id"
				append path3 $base_url "room?room_id=$room_id"
			append path4 $base_url "chat-transcripts?room_id=$room_id"
			

}



list::create \
    -name "chat_room" \
    -multirow "chat_room" \
    -elements {
        pretty_name {
            label "#chat.Name#"
            html { style "text-align:center;" }
            link_url_eval {chat?room_id=$room_id&client=ajax}
        }
        description {
            label "#chat.Description#"
            html { style "text-align:center;" }
        }
        creator_name {
            label "#chat.room_creator2#"
            html { style "text-align:center;" }
        }
        comm_name {
            label "#chat.comm_name2#"
            html { style "text-align:center;" }
        }  
        creation_date_pretty {
            label "#chat.creation_date#"
        }
        admin {
        	label "#chat.actions#"
            	html { align "center" }
            	display_template {            		
        				<if @chat_room.admin_p@ eq "f">        	
        				<a href="@chat_room.path@" class=button>\n#chat.room_change_options#</a>
        				</br>
        				<a href="@chat_room.path2@" class=button>\n#chat.Transcripts#</a>
        				</if>
        				<else>             
                		<a href="@chat_room.path3@" class=button>\n#chat.room_admin#</a>
                		</br>
                		<a href="@chat_room.path4@" class=button>\n#chat.Transcripts#</a>
           			 </else> 
        			}
        }    
    }