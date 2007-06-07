ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @author Peter Alberer
    @cvs-id $Id$  
}

namespace eval ::chat {
  ::xo::ChatClass Chat -superclass ::xo::Chat

  Chat instproc render {} {
    my orderby time
    set result ""
    
    foreach child [my children] {      
      
      set msg       [$child msg]
      set user_id   [$child user_id]
      set color     [$child color]
      set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set userlink  [my user_link -user_id $user_id -color $color]
      append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>" \
	  "<span class='message'>[my encode $msg]</span></p>\n"
    }        
    return $result
  }

  Chat proc login {-chat_id -package_id} {
    auth::require_login
    if {![info exists package_id]} {set package_id [ad_conn package_id] }
    if {![info exists chat_id]}    {set chat_id $package_id }

    
    

    set context id=$chat_id&s=[ad_conn session_id].[clock seconds]
    set jspath packages/chat/www/ajax/chat.js
    if { ![file exists [acs_root_dir]/$jspath] } {
      return -code error "File [acs_root_dir]/$jspath does not exist"
    }
    set file [open [acs_root_dir]/$jspath]; set js [read $file]; close $file
    set path      [site_node::get_url_from_object_id -object_id $package_id]
    set login_url ${path}ajax/chat?m=login&$context
    set send_url  ${path}ajax/chat?m=add_msg&$context&msg=    
    #$send_file
   
    set user_id [ad_conn user_id]
    set return_url [ad_return_url]
    db_1row room_info {
        select room.comm_name
        from chat_rooms as room
        where room.room_id = :chat_id        
      }  		
    	set folder_id "$comm_name's Public Files" 
    	db_1row room_info {
        	select count(acs.object_id) as count
        	from acs_objects as acs
        	where acs.title = :folder_id        
      	}  
    	if { $count > 0 } {   
    		db_1row room_info {
        		select acs.object_id as id
        		from acs_objects as acs
        		where acs.title = :folder_id        
      		}
      		set folder_id $id  
      	} else {
      		acs_user::get -user_id $user_id -array user      		
      		set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]      		
      		set folder_id "$name's Shared Files"      		
      		  
      		#$folder_id
      		db_1row room_info {
        		select fs.folder_id as id
        		from fs_folders as fs
        		where fs.name = :folder_id
      		}  
      		set folder_id $id  
      	}
   	
    
    set users_url ${path}ajax/chat?m=get_users&$context  
    
    set files_url ${path}ajax/chat?m=get_files&$context      
    
    
    return "\
      <script type='text/javascript' language='javascript'>
      $js
     
      // register the data sources (for sending messages, receiving updates)
      var pushMessage = registerDataConnection(pushReceiver, '$path/ajax/chat?m=get_new&$context', false);
      var pullUpdates = registerDataConnection(updateReceiver, '$path/ajax/chat?m=get_updates&$context', true);
      // register an update function to refresh the data sources every 5 seconds
      var updateInterval = setInterval(updateDataConnections,5000);
      
      </script>
     
      <form id='ichat_form' name='ichat_form' action='#' onsubmit='pushMessage.chatSendMsg(\"$send_url\"); return false;'>
      <iframe name='ichat' id='ichat' frameborder='0' src='$login_url'
          style='width:65%; border:1px solid black; margin-right:12px;' height='257'></iframe>
      <iframe name='ichat-users' id='ichat-users' frameborder='0' src='$users_url'
          style='width:16%; border:1px solid black; margin-right:12px;' height='257'></iframe>
       <iframe name='ichat-files' id='ichat-files' frameborder='0' src='$files_url'
          style='width:15%; border:1px solid black;' height='257'></iframe>                   
      <table>
      <tr>
      <td>
      <div style='margin-top:10px; margin-right:5px;'>
      #chat.message# <input tabindex='1' type='text' size='58' name='msg' id='chatMsg'> <input type='submit' value='#chat.Send_Refresh#'>        </form>
      </div></td><td>      
       <div style='margin-top:10px; margin-right:10px;'>
       <form name='upload'  action='upload' onsubmit='upload'>
       
      		 		   		      		      		
      		<input type='submit' value='[_ chat.send_file]'><input type='hidden' name='folder_id' value='$folder_id'>
      		<input type='hidden' name='chat_id' value='$chat_id'>
      		<input type='hidden' name='return_url' value='$return_url'></form></div></td><td>      
      </td></tr></table>      		
      		
                        
	
"
  }  
  
  Chat instproc render2 {-chat_id} {
    my orderby time
    set result ""
    set msg_true "f"
      
    
    
    
    
    db_1row room_info {
        select room.maximal_participants as maxp
        from chat_rooms as room
        where room.room_id = :chat_id        
      }   
     
	
    foreach child [my children] {
    
      set msg       [$child msg]      
      set msg_all ""
     
      for {set i 0} {$i < [llength $msg]} {incr i 1} {
      	set word [lindex $msg $i]
      	
     
      	    	set j 0
      		if { [string range $word $j $j] eq "h" } {      	      		
      			set aux [expr $j+1]      		
      			if { [string range $word $aux [expr $aux+5] ] eq "ttp://" } { 
      		  		set url [lindex $msg $i]  		  		
      		  		lappend msg_all $i
      		  		set msg_true "t"
      		  		
      			}      		      		
      		} else {
      			if { [string range $word $j $j] eq "w" } { 
      			set aux [expr $j+1]      		
      				if { [string range $word $aux [expr $aux+1] ] eq "ww" } { 
      		  			set url [lindex $msg $i]  		  		
      		  			lappend msg_all $i
      		  			set msg_true "t"
      		  		
      				}
      			}
      		}
      	
      }
            
      set user_id   [$child user_id]
      set color     [$child color]           
     set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set timeshort2 [clock format [$child time] -format {[%D]}]
    
      
      
      
      
      
      db_1row room_info {
        select count(1) as info
        from chat_registered_users
        where room_id = :chat_id
        and user_id = :user_id
      }
        
    
    
    if { $info > 0 } {
    	set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
	db_1row room_info {	
        	select alias as alias
        	from chat_registered_users
        	where room_id = :chat_id
        	and user_id = :user_id
	}	
	set userlink  [my user_link2 -user_id $user_id -color $color -alias $alias]
	
	if {$msg_true eq  "t"} {
	
	append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>"
	
	append result "<span class='message'>"
	set k 0
	for {set l 0} {$l < [llength $msg]} {incr l 1} {
		
		
			if { $l eq [lindex $msg_all $k] } {
			
				if { [string range [lindex $msg $l] 0 0] eq "w" } {
					set msg_url  [my user_link4 -url [lindex $msg $l] -color $color]
				} else {
					set msg_url  [my user_link3 -url [lindex $msg $l] -color $color]
				}
				
				append result $msg_url
				append result " "
				if { $k < [llength $msg_all]} {
					set k [expr $k+1]
				}
			} else {
				append result [lindex $msg $l]
				append result " "
			}
		
	  	
	}
	append result "</span></p>\n"
	} else {		
        append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>" \
	  "<span class='message'>[my encode $msg]</span></p>\n"
	}
	  
    }
   
    if {$info eq 0} {
    	set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      
    	set userlink  [my user_link -user_id $user_id -color $color]
    	
    	if {$msg_true eq  "t"} {
	
	append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>"
	
	append result "<span class='message'>"
	set k 0
	for {set l 0} {$l < [llength $msg]} {incr l 1} {
		
		
			if { $l eq [lindex $msg_all $k] } {
			
				if { [string range [lindex $msg $l] 0 0] eq "w" } {
					set msg_url  [my user_link4 -url [lindex $msg $l] -color $color]
				} else {
					set msg_url  [my user_link3 -url [lindex $msg $l] -color $color]
				}				
				append result $msg_url
				append result " "
				if { $k < [llength $msg_all]} {
					set k [expr $k+1]
				}
			} else {
				append result [lindex $msg $l]
				append result " "
			}
		
	  	
	}
	append result "</span></p>\n"
	} else {

        append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>" \
	  "<span class='message'>[my encode $msg]</span></p>\n"
	}
    }
    }
     
          #test send files
    
    db_1row room_info1 {
        select count(files.message) as message
        from chat_rooms_files_sent as files
        where files.room_id = :chat_id
        and files.message = false
      }
    
    if { $message > 0 } {
      db_1row room_info1 {
      select files.title as title,files.file as fil
        from chat_rooms_files_sent as files
        where files.room_id = :chat_id
        and files.message = false
      }
      
      
    
      
      
      
      db_1row room_info {
        select room.comm_name
        from chat_rooms as room
        where room.room_id = :chat_id        
      }  		
    	set folder_id "$comm_name's Public Files" 
    	   
    	db_1row room_info {
        select count(acs.object_id) as count
        from acs_objects as acs
        where acs.title = :folder_id        
      	}  
      	if { $count > 0 } {
      		db_1row room_info {
        		select acs.object_id as id
        		from acs_objects as acs
        		where acs.title = :folder_id        
      		}
      		set url [ad_conn url]  
      		set folder_id $id
      		set inicio 0
      		set final [expr [string length $url]-16]
      		set comm_name [string range $url $inicio $final]  
      		if { [string length $comm_name] > 0 } {      			 
      			set url "$comm_name/file-storage/index?folder_id=$folder_id"
      		}
      	} else {
      		
      		acs_user::get -user_id $user_id -array user      		
      		set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]      		
      		set folder_id "$name's Shared Files" 
      		#$folder_id
      		
      		
      		db_1row room_info {
        		select fs.folder_id as id
        		from fs_folders as fs
        		where fs.name = :folder_id        
      		}  
      		set folder_id $id
      		set url "/dotlrn/file-storage/index?folder_id=$folder_id"  
      	}
   	   	
      
      
      set user_file -1
      
      
      set userlink  [my user_link -user_id "-1" -color ""]
      set msg_file  [my user_link4 -url "I has uploaded the '$title' file ($fil) to the " -color ""]    
      append result2 "<span class='message'>"
      
      append msg_file [my user_link5 -url "$url" -msg "public files of the community" -color ""]      
         
      append result2 $msg_file
      append result2 " "
      append result2 "</span>\n"
      set delete_message [send_file_message $chat_id]
      set uid -1
      set m [my add_msg -get_new true -uid $user_id "$result2"]
      
      set userlink  [my user_link -user_id $user_file -color ""]        
      append result "<p class='line'><span class='timestamp'>$timeshort</span><span class='user'>$userlink:</span>"
      append result "<span class='message'>"
      set msg_file  [my user_link4 -url "The file '$title' has been sent to the " -color ""]
      append msg_file [my user_link5 -url "$url" -msg "public files of the community." -color ""]      
     append result $msg_file
      append result " "
      append result "</span></p>\n"
      
     
    }
    
    
    return $result
  }
  
  
  
}	
