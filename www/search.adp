<master>
<property name=title>#chat.Add_user_to_room#</property>
<property name="context">@context;noquote@</property>

<FORM METHOD=get ACTION=search-2>
  <input type="hidden" name="room_id" value="@room_id@" />
  <input type="hidden" name="target" value="one" />
  <input type="hidden" name="type" value="@type@" />
  <input type="text" size="15" name="keyword" />
  <input type="submit" value="#dotlrn.User_Search#" />
</FORM>
