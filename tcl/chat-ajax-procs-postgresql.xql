<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>
   
    <fullquery name="get_root_folder">
        <querytext>
            select file_storage__get_root_folder(:package_id);
        </querytext>
    </fullquery> 
    
   
    
</queryset>