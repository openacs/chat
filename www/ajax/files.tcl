ad_page_contract {
  realtime file list for a chat room

  @author Pablo Muñoz (pablomp@tid.es)
  @creation-date Dec 13, 2006
} -query {
  id
  s
}

::chat::Chat c1 -volatile -chat_id $id -session_id $s
set output [c1 get_files]

ns_return 200 text/html "
<HTML>
<style type='text/css'>
#files { font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#files .file {text-align: left; vertical-align: top; }
</style>
<body>
<table id='files'><tbody>$output</tbody></table>
</body>
</HTML>"