<master>
<property name="title">#chat.Add_user_to_room#</property>
<property name="context">@context;noquote@</property>

<if @search_type@ eq "keyword">
                                   
 #dotlrn.lt_The_results_of_your_s#<BR> 
   (#chat.What_search# @SQL_LIMIT@)
 </if><else>
 <if @search_type@ eq "email">
  for email "@email@"
 </if><else>
  for last name "@last_name@"
</else></else>

<ul>
<multiple name="user_search">
  <li>
    <a href="search-3?room_id=@room_id@&type=@type@&party_id=@user_search.user_id@">
       @user_search.first_names@ @user_search.last_name@ (@user_search.email@)
    </a>
  </li>
</multiple>

<if @user_search:rowcount@ eq 0>
  <li>No users found.
</if>

</ul>

