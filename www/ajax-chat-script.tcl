ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at) and Pablo Muñoz (pablomp@tid.es)
  @creation-date Jan 31, 2006
  @cvs-id $Id$
} -query {
  msg:optional   
}

set chat_frame [ ::chat::Chat login -chat_id $room_id -folder_id $folder_id]

