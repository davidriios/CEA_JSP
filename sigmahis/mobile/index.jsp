<%String showMobile = ""; try {showMobile=java.util.ResourceBundle.getBundle("issi").getString("app.mobileaccess");}catch (Exception ex) {showMobile = "y";}%>
 <!doctype html>
 <html charset="utf-8">
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <title>Acceso no permitido</title>
 <head></head>
 <body>
 <%if(showMobile.equals("y")){%>
<table id="mob-content" style="width:100%; border:10px; text-align:center">
	<tr align="center">
		<td><div class="mob-content">
		<span style="font-size:2em">Acceso a trav&eacute;z de dispositivos moviles no est&aacute; permitido. Por favor comun&iacute;quese con su administrador de sistema.</span>
		</div>
		</td>
	</tr>
</table>	
<%}%>
 </body>
 </html>