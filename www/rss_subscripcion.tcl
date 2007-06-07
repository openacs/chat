ad_page_contract {

    Display a list of news items summary for administration

    @author Stefan Deusch (stefan@arsdigita.com)
    @creation-date 2000-12-20
    @cvs-id $Id$

} {
	room_id
}
set package_id [ad_conn package_id]

set rss_exists [rss_support::subscription_exists \
                    -summary_context_id $room_id \
                    -impl_name chat_rss]
                    
set rss_feed_url [chat_util_get_url $package_id]rss/rss.tcl?room_id=$room_id