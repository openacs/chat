<html>
  <head>
  
  <link rel="stylesheet" type="text/css" href="/resources/acs-templating/lists.css" media="all">
  <link rel="stylesheet" type="text/css" href="/resources/acs-templating/forms.css" media="all">
   <link rel="stylesheet" type="text/css" href="/resources/acs-subsite/default-master.css" media="all">
   <link rel="stylesheet" type="text/css" href="/resources/dotlrn/dotlrn-master.css" media="all">
   <link rel="stylesheet" type="text/css" href="/resources/calendar/calendar.css" media="all">
    
<script language=javascript>
function SubmitForm() {
    document.frm_button.message.value=document.frm_imput.message.value;
    document.frm_button.submit();
    document.frm_imput.message.value="";
    document.frm_imput.message.focus();
    refreshForm();
}
</script>

<script language=javascript>
function refreshForm() {
window.parent.frames["chat_rows"].location.reload();
return false;
}
</script>

</head>

<body bgcolor=white onLoad="document.frm_imput.message.focus()" topmargin=0 leftmargin=0>





<form name=frm_imput >

   #chat.Chat#: <input name=message size=40>
   <input type=hidden name="client" value="html-chat-script">
   <input type=hidden name="room_id" value="@room_id@">
   <input type="submit" value="#chat.Send_Refresh#" style="font-size: 11px" onClick="SubmitForm()">

   
</form>




<form name=frm_button  method=post action="chat" style="margin:0; padding:0; border:0">
<input type=hidden name="client" value="html-chat-script">
   <input type=hidden name=message>
   <input type=hidden name="room_id" value="@room_id@">
</form>

</body>

