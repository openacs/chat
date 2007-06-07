#/chat/www/index.tcl
ad_page_contract {
    Display a list of available chat rooms that the user has permission to edit.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 13, 2000
    @cvs-id $Id$
} {
} -properties {
    context_bar:onevalue
    package_id:onevalue
    user_id:onevalue
    room_create_p:onevalue
    rooms:multirow
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]
set actions [list]
set room_create_p [permission::permission_p -object_id $package_id -privilege chat_room_create]
set default_client [parameter::get -parameter "DefaultClient" -default "ajax"]
set warning ""
set path [ad_return_url]

if { $default_client eq "ajax" && ![apm_package_installed_p xotcl-core] } {
    set warning "[_ chat.xotcl_missing]"
}

if { $room_create_p } {
    lappend actions "#chat.Create_a_new_room#" room-new "#chat.Create_a_new_room#"    
}
lappend actions "#chat.Search_a_room#" room-search?package_id=[ad_conn package_id] "#chat.Search_a_room#"

set community_id [dotlrn_community::get_community_id]

if { $community_id eq "" } {	
	set list 0
} else {
	set list 1	
}

db_multirow -extend { active_users last_activity rss_exists rss_feed_url2 rss_service admin_professor} rooms rooms_list {} {
  set room [::chat::Chat create new -volatile -chat_id $room_id]
  set active_users [$room nr_active_users]
  set last_activity [$room last_activity]
  set rss_exists [rss_support::subscription_exists -summary_context_id $room_id -impl_name chat_rss]
  set rss_feed_url2 [chat_util_get_url $package_id]/rss/rss.tcl?room_id=$room_id
  
  db_1row room_info {
		select count(cru.rss_service) as counter
		from chat_registered_users cru
		where cru.user_id = :user_id
		and cru.room_id = :room_id
		and cru.rss_service = 'true'
 } 
 if { $counter > 0} {		
	set rss_service 1
 } else {
	set rss_service 0
 }
 db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
}


db_multirow -extend { active_users last_activity rss_exists rss_feed_url2 rss_service admin_professor} rooms2 rooms_list2 {} {
  set room [::chat::Chat create new -volatile -chat_id $room_id]
  set active_users [$room nr_active_users]
  set last_activity [$room last_activity]
  set rss_exists [rss_support::subscription_exists -summary_context_id $room_id -impl_name chat_rss]
  set rss_feed_url2 [chat_util_get_url $package_id]/rss/rss.tcl?room_id=$room_id
  
  db_1row room_info {
		select count(cru.rss_service) as counter
		from chat_registered_users cru
		where cru.user_id = :user_id
		and cru.room_id = :room_id
		and cru.rss_service = 'true'
 } 
 if { $counter > 0} {		
	set rss_service 1
 } else {
	set rss_service 0
 }
 db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
}



list::create \
    -name "rooms" \
    -multirow "rooms" \
    -key room_id \
    -pass_properties {room_create_p} \
    -actions $actions \
    -row_pretty_plural [_ chat.rooms] \
    -elements {
        open {
            label "#chat-portlet.open_room#"
            html { align "center" }
            display_template {
            	
                <if @rooms.open@ eq t>
                <div style="padding-top:5px;">
                <img src="/resources/chat/active.png" title="#chat-portlet.open_room#">
                </div>
                </if>
                <else>
                <div style="padding-top:5px;">                
                <img src="/resources/chat/inactive.png" title="#chat-portlet.close_room#">
                </div>
                </else>
            }
        }        
        private {
            label "#chat-portlet.private_room#"
            html { align "center" }
            display_template {
            	
                <if @rooms.private@ eq f>
                <div style="padding-top:5px;">
                <img src="/resources/chat/active.png" title="#chat-portlet.not_private_room#">
                </div>
                </if>
                <else>
                <div style="padding-top:5px;">                
                <img src="/resources/chat/inactive.png" title="#chat-portlet.private_room#">
                </div>
                </else>
            }
        }
        pretty_name {
            label "#chat.Room_name#"
            html { align "center" }
            display_template {
                <if @rooms.active_p@ eq t>
                <a href="room-enter?room_id=@rooms.room_id@&client=$default_client">@rooms.pretty_name@</a>
                </if>
                <else>
                @rooms.pretty_name@
                </else>
                <div style="float:center">@rooms.description@</div>                
            }
        }
        community {
            label "#chat-portlet.community_class#"
            html { align "center"}
            display_template {
            	<if @rooms.user_p@ eq t>
            	@rooms.community@
            	</if>
            }
        }
        rss {
        	label "#chat-portlet.rss#"
            	html { align "center" }
            	display_template {
            		
                	<if @rooms.rss_exists@ eq 1>
                	<if @rooms.rss_service@ eq 1>
	  		<br/><a href="@rooms.rss_feed_url2@">#rss-support.Syndication_Feed#&nbsp;<img src="/resources/xml.gif" alt="Subscribe via RSS" width="26" height="10" border=0 /></a><hr/><br/>
        		</if>
        		<else> #chat-portlet.no_rss#
        		</else>
        		</if>
        		<else> #chat-portlet.no_rss#
        		</else>
        	}
        }       
        active_users {
            label "#chat.active_users#"
            html { style "text-align:center;" }
        }
        last_activity {
            label "#chat.last_activity#"
            html { style "text-align:center;" }
        }
        actions {
            label "#chat.actions#"
            display_template {
            <if @rooms.admin_p@ eq f>
            		<if @rooms.admin_professor@ eq "t">            			                             	
                	<a href="@rooms.base_url@room?room_id=@rooms.room_id@" class=button>#chat.room_admin#</a>
                	<a href="chat-transcripts?room_id=@rooms.room_id@" class=button>#chat.Transcripts#</a>
            		</if>
            		<else>
            			<a href="@rooms.base_url@options?action=$path&room_id=@rooms.room_id@" class=button>\n#chat.room_change_options#</a>
        		</br>
        			<a href="@rooms.base_url@chat-transcripts?room_id=@rooms.room_id@" class=button>\n#chat.Transcripts#</a>
        		</else>
            </if>
            <else>
            	<a href="@rooms.base_url@room?room_id=@rooms.room_id@" class=button>#chat.room_admin#</a>  
                <a href="chat-transcripts?room_id=@rooms.room_id@" class=button>#chat.Transcripts#</a>                            	
            </else>
            }
        }
    }

list::create \
    -name "rooms2" \
    -multirow "rooms2" \
    -key room_id \
    -pass_properties {room_create_p} \
    -actions $actions \
    -row_pretty_plural [_ chat.rooms] \
    -elements {
        open {
            label "#chat-portlet.open_room#"
            html { align "center" }
            display_template {
            	
                <if @rooms2.open@ eq t>
                <div style="padding-top:5px;">
                <img src="/resources/chat/active.png" title="#chat-portlet.open_room#">
                </div>
                </if>
                <else>
                <div style="padding-top:5px;">                
                <img src="/resources/chat/inactive.png" title="#chat-portlet.close_room#">
                </div>
                </else>
            }
        }        
        private {
            label "#chat-portlet.private_room#"
            html { align "center" }
            display_template {
            	
                <if @rooms2.private@ eq f>
                <div style="padding-top:5px;">
                <img src="/resources/chat/active.png" title="#chat-portlet.not_private_room#">
                </div>
                </if>
                <else>
                <div style="padding-top:5px;">                
                <img src="/resources/chat/inactive.png" title="#chat-portlet.private_room#">
                </div>
                </else>
            }
        }
        pretty_name {
            label "#chat.Room_name#"
            html { align "center" }
            display_template {
                <if @rooms2.active_p@ eq t>
                	<a href="@rooms2.base_url@chat?room_id=@rooms2.room_id@&client=ajax">@rooms2.pretty_name@</a>
                </if>       	
        	<if @rooms2.active_p@ ne t>
          	(NO #chat.Active#)
        	</if>
                <div style="float:center">@rooms2.description@</div>                
            }
        }
        community {
            label "#chat-portlet.community_class#"
            html { align "center"}
            display_template {
            	<if @rooms2.user_p@ eq t>
            	@rooms2.community@
            	</if>
            }
        }
        rss {
        	label "#chat-portlet.rss#"
            	html { align "center" }
            	display_template {
            		
                	<if @rooms2.rss_exists@ eq 1>
                	<if @rooms2.rss_service@ eq 1>
	  		<br/><a href="@rooms2.rss_feed_url2@">#rss-support.Syndication_Feed#&nbsp;<img src="/resources/xml.gif" alt="Subscribe via RSS" width="26" height="10" border=0 /></a><hr/><br/>
        		</if>
        		<else> #chat-portlet.no_rss#
        		</else>
        		</if>
        		<else> #chat-portlet.no_rss#
        		</else>
        	}
        }       
        active_users {
            label "#chat.active_users#"
            html { style "text-align:center;" }
        }
        last_activity {
            label "#chat.last_activity#"
            html { style "text-align:center;" }
        }
        actions {
            label "#chat.actions#"
            display_template {
            <if @rooms2.admin_p@ eq f>
            		<if @rooms2.admin_professor@ eq "t">            			                             	
                	<a href="@rooms2.base_url@room?room_id=@rooms2.room_id@" class=button>#chat.room_admin#</a>
                	<a href="chat-transcripts?room_id=@rooms2.room_id@" class=button>#chat.Transcripts#</a>
            		</if>
            		<else>
            			<a href="@rooms2.base_url@options?action=$path&room_id=@rooms2.room_id@" class=button>\n#chat.room_change_options#</a>
        		</br>
        			<a href="@rooms2.base_url@chat-transcripts?room_id=@rooms2.room_id@" class=button>\n#chat.Transcripts#</a>
        		</else>
            </if>
            <else>
            	<a href="@rooms2.base_url@room?room_id=@rooms2.room_id@" class=button>#chat.room_admin#</a>  
                <a href="chat-transcripts?room_id=@rooms2.room_id@" class=button>#chat.Transcripts#</a>                            	
            </else>
            }
        }
    }

ad_return_template
