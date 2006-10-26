ad_page_contract {
mostra mensagens do chat
} {
   
room_id:integer

}


# ns_log notice $room_id:onevalue
template::list::create -name chat_msg \
                       -multirow chat_msg_query \
		       -no_data "Sem dados no momento " \
		       -page_flush_p 1 \
		       -elements {
		            creation_date               { label "[_ chat.date]" }
                            msg                         { label "[_ chat.msg]" }
			    			    
			  } 
	 

db_multirow -extend {} chat_msg_query select_msg_itens {
                    select to_char(creation_date, 'DD-MM-YYYY hh:mm:ss') as creation_date, 
		           msg
	             from chat_msgs 
		    where room_id  = :room_id 
		    order by msg_id desc
		    limit 15 } 
ad_return_template