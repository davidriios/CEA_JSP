<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sbSql.append("select a.codigo, a.descripcion, decode(b.cod_eval,null,'I','U') as action, b.valor from tbl_sal_eval_final_vida a, tbl_sal_escala_final_vida b where a.estado = 'A' and a.codigo = b.cod_eval(+) and b.pac_id(+) = ");
	sbSql.append(pacId);
	sbSql.append(" and b.admision(+) = ");
	sbSql.append(noAdmision);
	sbSql.append(" order by a.codigo");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
$(function(){
  $(".__presente").click(function() {
    getTotal()
  });
  getTotal();
  
  $("#imprimir").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_eval_pac_final_vida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");
  });
});

function getTotal() {
  var tot = 0;
  for (var i = 0; i<<%=al.size()%>; i++) {
    var val = $("input[name='valor"+i+"']:checked"). val() || 0;
    tot += parseInt(val,10);
  }
  if (tot >= 3) {
    parent.CBMSG.alert("La sumatoria total es 3 o mayor de 3, comunicarse con el médico para llevar el plan de cuidado del paciente al final de la vida.");
  }
  $("#total").val(tot); 
}
</script>
</head>
<body class="body-form">

    <!---/INICIO Fila de Peneles/--------------->
<!--INICIO de una fila de elementos-->
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>



<!--tabla de boton imprimit-->
    <div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
<tr>
<td>
<%=fb.button("imprimir","Imprimir",false,false,null,null,"")%>
</td>
</tr>
</table>
    </div>
<!--fin tabla de boton imprimit-->
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>

<tr class="bg-headtabla" >
    <th>SINTOMAS</th>
    <th>No Presente = 0</th>
    <th>Presente = 1</th>
</tr>
</thead>

<tbody>
<% for (int i = 0; i<al.size(); i++){%>
<%
 cdo = (CommonDataObject) al.get(i);
%>
<tr>
    <td align="left"><label><%=cdo.getColValue("descripcion")%></label></td>
    <td align="center"><label><%=fb.radio("valor"+i,"0",cdo.getColValue("valor").equals("0"),viewMode,false,"__presente",null,null)%></label></td>
    <td align="center"><label><%=fb.radio("valor"+i,"1",cdo.getColValue("valor").equals("1"),viewMode,false,"__presente",null,null)%></label></td>
</tr>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
<%}%>
<tr>
    <td colspan="3" align="right" class="form-inline"><label>Total: <%=fb.textBox("total","0",false,false,true,0,"form-control input-sm",null,null)%></label></td>
</tr>
</tbody>
</table>
<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
    <tr>
       <td>
				Opciones de Guardar:
				<label><%=fb.radio("saveOption","O",true,viewMode,false,null,null,null)%> Mantener Abierto</label>
				<label><%=fb.radio("saveOption","C",false,viewMode,false,null,null,null)%> Cerrar</label>
        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
			</td>
    </tr>
    </table>   
</div>

<%=fb.formEnd(true)%>
</div>

<!-- FIN contenido del sitio aqui-->
</div>
<!-- FIN contenido del sitio aqui-->

<!-- FIN Cuerpo del sitio -->
</body>
<!-- FIN Cuerpo del sitio -->


</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size= Integer.parseInt(request.getParameter("size"));

	al.clear();
	for (int i=0; i<size; i++) {
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_escala_final_vida");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and cod_eval="+request.getParameter("codigo"+i)+" and admision = "+request.getParameter("noAdmision"));

		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		cdo.addColValue("cod_eval",request.getParameter("codigo"+i));
		if (request.getParameter("valor"+i) != null) cdo.addColValue("valor",request.getParameter("valor"+i));
		cdo.setAction(request.getParameter("action"+i));
		if (cdo.getAction().equalsIgnoreCase("I")) {
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion","sysdate");
		}
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion","sysdate");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp")) { %>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<% } else { %>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N")) {
%>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
