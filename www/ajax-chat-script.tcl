ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id$
} -query {
  msg:optional
}

set html_room_url [export_vars -base "room-enter" {room_id {client html}}]

set chat_frame [ ::chat::Chat login -chat_id $room_id]

