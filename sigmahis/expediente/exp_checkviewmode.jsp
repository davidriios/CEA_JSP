var estadoAtencion = "";
<% String form = request.getParameter("from") != null && request.getParameter("from").equals("salida_pop") ? "form0" : "form1";%>
if (parent.document.<%=form%> && parent.document.<%=form%>.estadoAtencion) estadoAtencion = parent.document.<%=form%>.estadoAtencion.value;
else estadoAtencion = "";
var _viewMode = 'view';
<%if(request.getParameter("_viewMode")!=null){%>
_viewMode = "<%=request.getParameter("mode")%>";
<%}%>
function checkViewMode(){
  var objSave = document.getElementById("save");
  if(objSave!=null && _viewMode=='view' && estadoAtencion == 'F') objSave.disabled = true;
}