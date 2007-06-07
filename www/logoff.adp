<!--
     Log off screen
     @author Pablo Muñoz (pablomp@tid.es)
     @creation-date September 19, 2006
-->
<master>
<property name="title">Log off</property>


<h4>Are you sure you want to log off?</h4>
<table><tr>

	<td><form action="logoff2" method="post">	
		<input type="hidden" name="room_id" value=@room_id@>
		<input type="hidden" name="action" value=@action@>
	<input type="submit" value="Yes"></form>
	</td>
	
	<td><form action=@action@ method="post"><input type="submit" value="No"></form></td></tr></table>

