<div id="messages">
  <if @n_messages;literal@ gt 0>
    <list name="messages">
      <p class="line">
        @messages:item@
      </p>
    </list>
  </if>
  <else>
    <p class="line">#chat.No_information_available#</p>
  </else>
</div>
