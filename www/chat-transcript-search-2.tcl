ad_page_contract {
    Display a form to create a new room.

    @author Pablo Muñoz (pablomp@tid.es)    
} {
   room_id
   pretty_name
   date2   
   partitipants   
   key_words
   sent_files
   sent_files_title   
}
set transcript_delete_p [permission::permission_p -object_id $room_id -privilege chat_transcript_delete]
set transcript_view_p [permission::permission_p -object_id $room_id -privilege chat_transcript_view]

set query ""
set query1 ""
set query2 ""
set query3 ""
set query4 ""
set query5 ""
set query6 ""

db_1row room_info {
        		select cr.pretty_name as room_name
        		from chat_rooms cr
        		where cr.room_id = :room_id  
}

#append query "select distinct ct.transcript_id, ct.pretty_name, ao.creation_date,cr.room_id
#    from chat_transcripts ct, chat_partitipants_transcript ptr,acs_objects ao, chat_rss crss, chat_room_transcript_keywords as tk, chat_rooms_files_sent fs,chat_file_transcript ftr, chat_rooms cr where" 

append query "select distinct ct.transcript_id, ct.pretty_name, ao.creation_date,cr.room_id
    from chat_transcripts ct,acs_objects ao, chat_rooms cr " 


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
	append query ",chat_room_transcript_keywords tk"	
}

    
if { !($pretty_name eq "") } {
	set query1 " where ct.pretty_name = :pretty_name"
	
}
if {!($date2 eq "") } {
	if { !($pretty_name eq "") } {
			set query2 " and ct.date = :date2 "
			
	} else {
			set query2 " where ct.date = :date2 "
			
	}
}
if { !($partitipants eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "")} {
		set query3 " and ptr.partitipant = :partitipants and ptr.transcript_id = ct.transcript_id "
		
	} else {
		set query3 " where ptr.partitipant = :partitipants and ptr.transcript_id = ct.transcript_id "
		
	}
}
if { !($sent_files_title eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") } {
		set query4 " and fs.title = :sent_files_title and fs.send_file_id = ftr.file_id and ftr.transcript_id = ct.transcript_id"
		
	} else {
		set query4 " where fs.title = :sent_files_title and fs.send_file_id = ftr.file_id and ftr.transcript_id = ct.transcript_id "
		
	}
}
if { !($sent_files eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") || !($sent_files_title eq "") } {
		set query5 " and fs.file = :sent_files and fs.send_file_id = ftr.file_id and ftr.transcript_id = ct.transcript_id"
		
	} else {
		set query5 " where fs.file = :sent_files and fs.send_file_id = ftr.file_id and ftr.transcript_id = ct.transcript_id "
		
	}
}
if { !($key_words eq "") } {
	if { !($pretty_name eq "") || !($date2 eq "") || !($partitipants eq "") || !($sent_files_title eq "") || !($sent_files eq "") } {
		set query6 " and tk.keyword = :key_words and tk.transcript_id = ct.transcript_id"
		
	} else {
		set query6 " where tk.keyword = :key_words and tk.transcript_id = ct.transcript_id "
		
	}
}
set creation_date ""
set query7 " and ct.transcript_id = ao.object_id    
    and ct.room_id = :room_id and cr.room_id = ct.room_id
    order by ao.creation_date desc"
set queryT [concat $query $query1 $query2 $query3 $query4 $query5 $query6 $query7]

#$queryT
db_multirow -extend { creation_date_pretty } chat_transcripts *SQL* $queryT {
    set creation_date_pretty [lc_time_fmt $creation_date "%q %X"]

}

list::create \
    -name "chat_transcripts" \
    -multirow "chat_transcripts" \
    -elements {
        pretty_name {
            label "#chat.Name#"
            link_url_eval {chat-transcript?room_id=$room_id&transcript_id=$transcript_id}
        }
        creation_date_pretty {
            label "#chat.creation_date#"
        }
        actions {
            label "#chat.actions#"
            html { align "center" }
            display_template {
                <if $transcript_delete_p eq "1">
                <a href="transcript-delete?transcript_id=@chat_transcripts.transcript_id@&room_id=$room_id">
                <img src="/shared/images/Delete16.gif" border="0">
                </a>
                </if>
            }
        }
    }