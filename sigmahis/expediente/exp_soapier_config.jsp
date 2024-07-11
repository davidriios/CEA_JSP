<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.DetallesCondicionPaciente"%>
<%@ page import="issi.expediente.CondicionPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String codDiag = request.getParameter("cod_diag");
String diagDesc = request.getParameter("desc_diag");

String key = "";

CondicionPaciente cp = new CondicionPaciente();
if (mode == null) mode = "add";
if (fg == null) fg = "DIA";
if (codDiag == null) codDiag = "";
if (diagDesc == null) diagDesc = "";

if (request.getMethod().equalsIgnoreCase("GET")){

	if (mode.equalsIgnoreCase("add")){ 
        id = "0";
        cp = new CondicionPaciente();
        cp.setDescripcion("");
        cp.setPlan("");
        cp.setEstado("");
	}
	else{
		sql = "SELECT codigo, descripcion,plan, estatus estado from tbl_sal_soapier_condicion where codigo="+id+"  ";
		cp = (CondicionPaciente) sbb.getSingleRowBean(ConMgr.getConnection(), sql, CondicionPaciente.class); 
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0">
<script>
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Mantenimiento - Tipo Escala Glasgow - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Mantenimiento - Tipo Escala Glasgow - Edición - "+document.title;
<%}%>
</script>

<script>
function save1(){
	
	if(form1Validation()){	
	window.frames['detalle'].formDetalle.baction.value = "Guardar";
	window.frames['detalle'].doSubmit(); 
	}
}

$(function(){
    var lastLineNo = $("#lastLineNo").val() || 0;
    $("#diag, #motivo_causa, #metas, #necesidades, #intervenciones").click(function(){
        var urls = {};
        urls['diag'] = "../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=DIA&id=<%=id%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>";
        urls['motivo_causa'] = "../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=MOT&id=<%=id%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>";
        urls['metas'] = "../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=MET&id=<%=id%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>";
        urls['necesidades'] = "../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=NEC&id=<%=id%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>";
        urls['intervenciones'] = "../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=INT&id=<%=id%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>";
        var that = this;
        setIfUrl(urls[that.name])
    });                 
});

function setIfUrl(url, ln) {
 if (ln!=undefined) {
  url += "&lastLineNo="+ln;
  $("#lastLineNo").val(ln)
 }
 $("#detalle").attr("src", url);
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - CONDICION PACIENTE - PLAN DE CUIDADO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">
<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("errCode","")%>
	<%=fb.hidden("errMsg","")%>
	<%=fb.hidden("lastLineNo","")%>
	<%=fb.hidden("fg", fg)%>
	<%=fb.hidden("cod_diag", codDiag)%>
	<%=fb.hidden("desc_diag", diagDesc)%>
		<tr>
            <td colspan="2">&nbsp;</td></tr>
			<tr class="TextHeader"><td colspan="2">CONDICION PACIENTE - PLAN DE CUIDADO</td></tr>
				<tr class="TextRow01">
                    <td><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
                    <td><%=id%></td>
				</tr>
				<tr class="TextRow01">
					<td width="20%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="80%"><%=fb.textBox("descripcion",cp.getDescripcion(),true,false,false,100)%></td>
				</tr>
                
                <tr class="TextRow01">
					<td><cellbytelabel id="3">Plan</cellbytelabel></td>
					<td><%=fb.textBox("plan",cp.getPlan(),true,false,false,100)%></td>
				</tr>
                
                <tr class="TextRow01">
					<td><cellbytelabel id="3">Estado</cellbytelabel></td>
					<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cp.getEstado(),false,false,0,"")%></td>
				</tr>
                <%if(!codDiag.trim().equals("")){%>
                   <tr class="TextRow01">
                    <td>Diagn&oacute;stico</td>
                    <td><b>[<%=codDiag%>]&nbsp;<%=diagDesc%></b></td>
				  </tr>
                <%}%>
                <tr class="TextRow02">
                    <td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
                    <td colspan="2">
                        <%=fb.button("diag","Diagnósticos",true,!fg.trim().equalsIgnoreCase("DIA"),null, null, "")%>
                        <%=fb.button("motivo_causa","Motivos o Causa",true,!fg.trim().equalsIgnoreCase("MOT"),null, null, "")%>
                        <%=fb.button("metas","Metas",true,!fg.trim().equalsIgnoreCase("MET"),null, null, "")%>
                        <%=fb.button("necesidades","Necesidades Alteradas",true,!fg.trim().equalsIgnoreCase("NEC"),null, null, "")%>
                        <%=fb.button("intervenciones","Intervenciones",true,!fg.trim().equalsIgnoreCase("INT"),null, null, "")%>
                    </td>
				</tr>
			<tr class="TextRow02">
			<td colspan="2">
                <div id="panel1" style="inline:display;">
                <iframe name="detalle" id="detalle" width="100%" height="300px" scrolling="yes" frameborder="0" src="../expediente/exp_soapier_detalle.jsp?mode=<%=mode%>&fg=<%=fg%>&id=<%=id%>&cod_diag=<%=codDiag%>"></iframe>
                </div>
            </td>
            </tr>
	<tr class="TextRow02">
	<td colspan="2" align="right"><cellbytelabel id="5">Opciones de Guardar</cellbytelabel>: 
	<%=fb.radio("saveOption","N")%><cellbytelabel id="6">Crear Otro</cellbytelabel> 
	<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel> 
	<%=fb.radio("saveOption","C")%><cellbytelabel id="8">Cerrar</cellbytelabel>

	<%=fb.button("save","Guardar",true,false,null, null, "onClick=\"javascript:save1()\"")%>
	<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr><tr><td colspan="2">&nbsp;</td></tr>
	<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>		
</td>
</tr>
</table>		
</body>
</html>
<%
}//GET 
else
{

//System.out.println("=================================== POST ===============================");

  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  String baction = request.getParameter("baction");
  
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");


%>
<html>
<head>
<script>
function closeWindow()
{
<%

if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_soapier_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_soapier_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/exp_soapier_list.jsp';
<%
	}
%>

<%

	if (saveOption.equalsIgnoreCase("N"))																					
	{
%>
	setTimeout('addMode()',900);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',900);
	
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}

} else throw new Exception(errMsg);
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=request.getParameter("id")%>&fg=<%=fg%>&cod_diag=<%=codDiag%>&desc_diag=<%=diagDesc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>