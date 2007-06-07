ad_page_contract {
    Display a form to create a new room.

    @author Pablo Muñoz (pablomp@tid.es)    
} {
   room_id:integer,notnull
}

ad_require_permission [ad_conn package_id] chat_room_create


set title "[_ chat.search_transcription]"
set action "transcript-search-2"
set pretty_name ""
set description ""
set key_words ""
set date ""
set partitipants ""
set reg_users ""
set sent_files ""
set submit_label "[_ chat.search_transcription]"



ad_form -name "transcript-search" -edit_buttons [list [list [_ chat.search_transcription] next]] -has_edit 1 -form {    
    {room_id:key}
    {pretty_name:text(text),optional
        {label "#chat.name_rss2#" }
    }
    {date:date(date),optional
        {label "#chat.date_rss2#" }
    }    
    {partitipants:text,optional
        {label "#chat.partitipants2#" }
        {html {rows 3 cols 25}}       
    }       
    {key_words:text,optional
        {label "#chat.keyword#" }
        {html {rows 3 cols 25}}                
    }    
    {sent_files:text,optional
        {label "#chat.files_sent2#" }
        {html {rows 3 cols 25}}        
    }
    {sent_files_title:text,optional
        {label "#chat.files_sent4#" }
        {html {rows 3 cols 25}}        
    }
} -edit_request {
    
} -edit_data {
    
} -after_submit {
	
	
	set date2 [lrange $date 0 2]	
	ad_returnredirect "chat-transcript-search-2?room_id=$room_id&pretty_name=$pretty_name&date2=$date2&partitipants=$partitipants&key_words=$key_words&sent_files=$sent_files&sent_files_title=$sent_files_title"
    	ad_script_abort
}

ad_return_template "transcript-search"










    
    
    
    
    
    