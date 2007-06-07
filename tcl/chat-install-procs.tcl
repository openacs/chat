ad_library {
    
    Sets up WebDAV support service contracts
    
    @author Pablo Muñoz (pablomp@tid.es)
    @creation-date 2007-01-08    
    
}


namespace eval chat::install {}

ad_proc -private chat::install::package_install {} {
} {
    db_transaction {	
	chat::rss::create_rss_gen_subscr_impl
    }
}