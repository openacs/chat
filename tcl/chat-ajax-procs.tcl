ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @author Peter Alberer
<<<<<<< chat-ajax-procs.tcl
    @cvs-id $Id$  
=======
    @cvs-id $Id$  
>>>>>>> 1.5
}

namespace eval ::chat {
  ::xo::ChatClass Chat -superclass ::xo::Chat
  
  
  Chat instproc login {} {        
    my instvar array user_id now chat_id
    
    
    db_1row room_info {
		select maximal_participants as maximal
		from chat_rooms as cp
		where cp.room_id = :chat_id
	}
	db_1row room_info {
		select count(cr.room_id) as count
		from chat_room_user_id as cr
		where cr.room_id = :chat_id
	}	
	if { $count < $maximal} {		
        	db_1row room_info {
			select count(cr.room_id) as count2
			from chat_room_user_id as cr
			where cr.user_id = :user_id
			and cr.room_id = :chat_id		
		}
        	if { $count2 == 0 } {
        		db_dml insert_users {insert into chat_room_user_id (room_id,user_id) values (:chat_id,:user_id);}
        	}
        } 
        if { $count == $maximal} {
              
		db_1row room_info {
			select count(chat_room_user_id.user_id) as count
			from chat_room_user_id
			where chat_room_user_id.user_id = :user_id
			and chat_room_user_id.room_id = :chat_id
		}	
		if { $count == 0 } {
			if { [permission::permission_p -party_id $user_id -object_id [dotlrn::get_package_id] -privilege admin] } {
				
			} else {
				
				ns_return 200 text/html "<HTML><BODY>\
				<div id='messages'>[_ chat.You_dont_have_permission_room]</div>\
				</BODY></HTML>"
  				ad_script_abort
  			}
  		}
  	}
    
    if {![nsv_exists $array-last-activity $user_id]} {        
        my add_msg -get_new false [_ xotcl-core.has_entered_the_room]
        
	

    }    
    my encoder noencode      
    my get_all 
  }
  
  
   
  
  Chat proc login {-chat_id -package_id -folder_id} {
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
<<<<<<< chat-ajax-procs.tcl
    set send_url  ${path}ajax/chat?m=add_msg&$context&msg=    
    
=======
    set send_url  ${path}ajax/chat?m=add_msg&$context&msg=    
    #$send_file
>>>>>>> 1.5
   
<<<<<<< chat-ajax-procs.tcl
    set user_id [ad_conn user_id]
    set return_url [ad_return_url]
        
    set users_url ${path}ajax/chat?m=get_users&$context  
    
    set files_url ${path}ajax/chat?m=get_files&$context      
    
    
=======
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
    
    
>>>>>>> 1.5
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
  
<<<<<<< chat-ajax-procs.tcl
  Chat instproc render {} {
=======
  Chat instproc render2 {-chat_id} {
>>>>>>> 1.5
    my orderby time
    set result ""
    set msg_true "f"
      
    my instvar chat_id
    
    
    
    
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
<<<<<<< chat-ajax-procs.tcl
      set color     [$child color]           
     set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set timeshort2 [clock format [$child time] -format {[%D]}]
    
    
=======
      set color     [$child color]           
     set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set timeshort2 [clock format [$child time] -format {[%D]}]
    
      
      
      
      
      
>>>>>>> 1.5
      db_1row room_info {
        select count(1) as info
        from chat_registered_users
        where room_id = :chat_id
        and user_id = :user_id
<<<<<<< chat-ajax-procs.tcl
      }
   
=======
      }
        
    
>>>>>>> 1.5
    
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
<<<<<<< chat-ajax-procs.tcl
     
         
    
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
    
    
=======
     
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
    
    
>>>>>>> 1.5
    return $result
  }
  
  
  Chat instproc get_files {} {
    my instvar chat_id
    set output ""
    set count 0    
       	ns_log Notice "en el get files...     $output"
   
   
    db_foreach file "select distinct fil.file as file
        from chat_rooms_files_sent as fil
        where fil.room_id = :chat_id " {
          
   
    set url [ad_conn url]
    
    set inicio 0
    set final [expr [string length $url]-16]
    set comm_name [string range $url $inicio $final]
    
    if { [string length $comm_name] > 0 } {    	
    	append output "<tr><td class='files'><a href='$comm_name/file-storage/view/public\/$file' target='_blank'>$file</a></td></tr>"
    } else {   
    	set user_id [ad_conn user_id]
    	acs_user::get -user_id $user_id -array user      		
      		set name [expr {$user(screen_name) ne "" ? $user(screen_name) : $user(name)}]      		
      		set folder_id "$name's Shared Files"
      		
      		db_1row room_info {
        		select fs.folder_id as id
        		from fs_folders as fs
        		where fs.name = :folder_id
      		}  
      		set folder_id $id
      		append url_file "dotlrn_fs_" $user_id
      		append url_file "_root_folder"
      		append url_file2 "dotlrn_fs_" $user_id
      		append url_file2 "_shared_folder"
      		
      		append output "<tr><td class='files'><a href='/dotlrn/file-storage/view/$url_file/$url_file2/\/$file' target='_blank'>$file</a></td></tr>"     	
        
    }    
    } if_no_rows {
       append output "<tr><td class='files'>[_ chat.no_files]</td></tr>"
    }	 
        
    return $output
  }
  
  
  
  
  Chat instproc sweeper {} {
    my instvar array now chat_id
    my log "-- starting"
       
   
    foreach {user timestamp} [nsv_array get $array-last-activity] {
      ns_log Notice "YY at user $user with $timestamp"
      set ago [expr {($now - $timestamp) / 1000}]
      
          
      if {$ago > 1000} { 
		my add_msg -get_new false -uid $user "auto logout"		
     		db_dml insert_users {delete from chat_room_user_id where room_id = :chat_id and user_id = :user;}
		nsv_unset $array-last-activity $user
		nsv_unset $array-color $user 
		nsv_unset $array-login $user
					
      }
          
    }    
    my log "-- ending"
  }
  
  
  Chat instproc get_users {} {
    my instvar chat_id
    set output ""
    set count 0
    
	
    
    foreach {user_id timestamp} [my active_user_list] {
    
    	
      set count [expr $count+1]
      if {$user_id > 0} {
      	db_1row room_info {
        	select count(1) as info
        	from chat_registered_users
        	where room_id = :chat_id
        	and user_id = :user_id
    	}
    	if { $info > 0 } {
		db_1row room_info {	
        		select alias as alias
        		from chat_registered_users
        		where room_id = :chat_id
        		and user_id = :user_id
		}
	
	set pp [my sweeper]
		
	
		
	set color [my user_color $user_id]
	set diff [clock format [expr {[clock seconds] - $timestamp}] -format "%H:%M:%S" -gmt 1]
	
	set package_id [ad_conn package_id]
	db_1row url { 
     		   select site_node__url(node_id) as url
        		from site_nodes
        		where object_id=:package_id
    	}
	
	set userlink  [my user_link2 -user_id $user_id -alias $alias]
	set user_id2 [ad_conn user_id]
      		set url2 "private-room?room_id=$chat_id&user_id1=$user_id&user_id2=$user_id2"     		      		      		 
    		append link $url $url2
    		set address [my encode $link]
      		set narrow [dt_right_arrow]      		
      		ns_log Notice "URL---------------$link---------$userlink"      		
		append output "<tr><td><a target='_blank' title='[_ chat-portlet.private_room]' href='$address'><img src='$narrow' /></a></td><td class='user'>$userlink</td> <td class='timestamp'>$diff</td></tr>"
	
	}
	if { $info eq 0 } {
		set link ""
		set package_id [ad_conn package_id]
		db_1row url { 
     		   select site_node__url(node_id) as url
        		from site_nodes
        		where object_id=:package_id
    		}
		set diff [clock format [expr {[clock seconds] - $timestamp}] -format "%H:%M:%S" -gmt 1]
		set userlink  [my user_link -user_id $user_id]
		set user_id2 [ad_conn user_id]
      		set url2 "private-room?room_id=$chat_id&user_id1=$user_id&user_id2=$user_id2"     		      		      		 
    		append link $url $url2
    		set address [my encode $link]
      		set narrow [dt_right_arrow]      		
      		ns_log Notice "URL---------------$link---------$userlink"      		
		append output "<tr><td><a target='_blank' title='[_ chat-portlet.private_room]' href='$address'><img src='$narrow' /></a></td><td class='user'>$userlink</td> <td class='timestamp'>$diff</td></tr>"
	}
      }
    }  
     
    return $output
  }



Chat instproc logout {} {  
    my instvar array user_id chat_id    
    my add_msg -get_new false [_ chat.has_left_the_room].
    
    db_dml insert_users {delete from chat_room_user_id where room_id = :chat_id and user_id = :user_id;}

    catch {        
        nsv_unset $array-last-activity $user_id
        nsv_unset $array-login $user_id
        nsv_unset $array-color $user_id
    }
  }  
  
  
  
   Chat instproc user_link { -user_id -color } {  
  my instvar chat_id
   if {$user_id > 0} {
        set name [my user_name $user_id]
      set url "/shared/community-member?user%5fid=$user_id"
      if {![info exists color]} {
	set color [my user_color $user_id]
      }
      set user_id2 [ad_conn user_id]
      set user_info "#chat.user_info#"
      set creator "<a style='color:$color;' title='[_ chat.user_info]' target='_blank' href='$url'>$name</a>"
    } elseif { $user_id == 0 } {
      set creator "Nobody"
    } else {
      set creator "System"
    }  
    return [my encode $creator]  
  }
  
 
  
  Chat instproc user_link2 { -user_id -color -alias} {    
  my instvar chat_id
   if {$user_id > 0} {
        set name $alias
      set url "/shared/community-member?user%5fid=$user_id"
      set user_id2 [ad_conn user_id]
      if {![info exists color]} {
	set color [my user_color $user_id]
      }
      set user_info "#chat.user_info#"
      set creator "<a style='color:$color;' title='[_ chat.user_info]' target='_blank' href='$url'>$alias</a>"
      ns_log Notice "El creator vale---------------$creator"
    } elseif { $user_id == 0 } {
      set creator "Nobody"
    } else {
      set creator "System"
    }  
    set tt [my encode $creator]
    ns_log Notice "El creator a string vale          $tt"
    return [my encode $creator]  
  }
  
  Chat instproc user_link3 { -url -color} {    
      set creator "<a style='color:$color;' title='[_ chat.user_info]' target='_blank' href='$url'>$url</a>"
   
    return [my encode $creator]  
  }
  
  Chat instproc user_link4 { -url -color} {    
      set creator "<a style='color:$color;' title='[_ chat.user_info]' target='_blank' href='http://$url/'>$url</a>"
   
    return [my encode $creator]  
  }
  
  Chat instproc user_link5 { -url -msg -color} {    
      set creator "<a style='color:$color;' title='[_ chat.user_info]' target='_blank' href='/../$url'>$msg</a>"
   
    return [my encode $creator]  
  }    
  
  
  Chat instproc add_msg {{-get_new:boolean true} -uid msg} {  
    my instvar array now user_id chat_id    
  
     if { $get_new eq "true" } {
    	
	db_1row room_info {
		select count(cr.room_id) as count
		from chat_room_user_id as cr
		where cr.room_id = :chat_id
		and cr.user_id = :user_id
	}
	if { $count == 1 || [permission::permission_p -party_id $user_id -object_id [dotlrn::get_package_id] -privilege admin]} {    	       
    		set user_id [expr {[info exists uid] ? $uid : [my set user_id]}]
    		set color   [my user_color $user_id]        		
    		set msg $msg    		
    
    		if {$get_new && [info command ::thread::mutex] ne ""} { 
      				
      		my broadcast_msg [Message new -volatile -time [clock seconds] \
			    -user_id $user_id -msg $msg -color $color]
	
    	}

    	set msg_id $now.$user_id
    	if { ![nsv_exists $array-login $user_id] } {
      			nsv_set $array-login $user_id [clock seconds]
      	}
    	
    	nsv_set $array $msg_id [list $now [clock seconds] $user_id $msg $color]    
    	nsv_set $array-seen newest $now
    	nsv_set $array-seen last [clock seconds]
    	nsv_set $array-last-activity $user_id $now
    	if {$get_new} {my get_new}
    	}
    
    
    } else {
    	
    	set user_id [expr {[info exists uid] ? $uid : [my set user_id]}]
    	set color   [my user_color $user_id]    
    	
    	set msg $msg
    	
    
    	if {$get_new && [info command ::thread::mutex] ne ""} { 
    	  
    	  my broadcast_msg [Message new -volatile -time [clock seconds] \
			    -user_id $user_id -msg $msg -color $color]
	
    	}

   	 set msg_id $now.$user_id
   	 if { ![nsv_exists $array-login $user_id] } {
   	   nsv_set $array-login $user_id [clock seconds]
   	 }
   	 nsv_set $array $msg_id [list $now [clock seconds] $user_id $msg $color]    
   	 nsv_set $array-seen newest $now
   	 nsv_set $array-seen last [clock seconds]
   	 nsv_set $array-last-activity $user_id $now
   	 if {$get_new} {my get_new}
    }
    
  }  
  
  
}	
