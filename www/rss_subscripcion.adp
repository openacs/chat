<master>
<property name="title">Rss Syndication</property>

<if @rss_exists@ true>
      <p><a href="@rss_feed_url@">#rss-support.Syndication_Feed# <img
            src="/resources/xml.gif" alt="Subscribe via RSS" /></a></p></if>

<ul>  
  <li>
  <if @rss_exists@ true>#rss-support.Rss_feed_active# [<a
  href="rss?room_id=@room_id@">#rss-support.Remove_feed#</a>]</if>
  
  <else>#rss-support.Rss_feed_inactive#[<a href="rss?room_id=@room_id@">
  #rss-support.Create_feed#</a>]</else>
</ul>