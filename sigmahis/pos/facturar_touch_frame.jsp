<%@ page errorPage="../error.jsp"%>
<%
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String almacen = request.getParameter("almacen")==null?"":request.getParameter("almacen");
String familia = request.getParameter("familia")==null?"":request.getParameter("familia");
String tipoPos = request.getParameter("tipo_pos")==null?"":request.getParameter("tipo_pos");
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String artType = request.getParameter("artType")==null?"":request.getParameter("artType");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_min.jsp"%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/js/jquery.fullscreen-0.4.1.min.js"></script>
<script language="javascript">
document.title="CellByte POS Touch";
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('posFrame'),xHeight,500,1);}
$(function() {
					// check native support
					$('#support').text($.fullscreen.isNativelySupported() ? 'supports' : 'doesn\'t support');

					// open in fullscreen
					$('#fullscreen .requestfullscreen').click(function() {
						$('#fullscreen').fullscreen();
						return false;
					});

					// exit fullscreen
					$('#fullscreen .exitfullscreen').click(function() {
						$.fullscreen.exit();
						return false;
					});

					// document's event
					$(document).bind('fscreenchange', function(e, state, elem) {
						// if we currently in fullscreen mode
						if ($.fullscreen.isFullScreen()) {
							$('#fullscreen .requestfullscreen').hide();
							$('#fullscreen .exitfullscreen').show();
						} else {
							$('#fullscreen .requestfullscreen').show();
							$('#fullscreen .exitfullscreen').hide();
						}

						$('#state').text($.fullscreen.isFullScreen() ? '' : 'not');
					});
				});
</script>
<style type="text/css">
#fullscreen {
	/* 
		it is recommended to explicitly set 'color' and 'background-color' properties for "fullscreened" object, 
		because otherwise Opera will use default styles "background-color: #000000; color: #fffff;".
	 */
	background: #fafafa;
	color: inherit;	
}
</style>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.min.js"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<div id="fullscreen">
<div class="col-xs-1"><a href="#" class="requestfullscreen btn btn-sm btn-primary">F U L L</a><a href="#" class="exitfullscreen btn btn-sm btn-primary" style="display: none">E X I T</a></div>
<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td><iframe id="posFrame" name="posFrame" frameborder="0" width="100%" height="0" scroll="no" src="../pos/facturar_touch.jsp?cds=<%=cds%>&almacen=<%=almacen%>&familia=<%=familia%>&tipo_pos=<%=tipoPos%>&tipo=<%=tipo%>&artType=<%=artType%>"></iframe></td>
</tr>
</table>
</div>
</body>
</html>