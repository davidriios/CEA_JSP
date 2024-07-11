<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

int count = 0;
String sql = "";
String mode = "";
String id = request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (id == null) throw new Exception("El Código de la Compañia no es válido. Por favor intente nuevamente!");
	count = CmnMgr.getCount("SELECT count(*) FROM tbl_sal_exp_cli_param WHERE compania="+id);
	if (count == 0) mode = "add";
	else mode = "edit";
	
	if (mode.equalsIgnoreCase("add"))
	{ 	
	}
	else
	{
		sql = "SELECT ruta_sonido as rutaSonido, cod_centro_sol_lab as centroCode, tref_sec01 as trefSec, tref_msec01 as trefMsec, frm_resultado_rx as resultRx, frm_resultado_lab as resultLab, cod_almacen_cu as almacenCode, tref_frm_enf_sec as enfSec, tref_frm_enf_msec as enfMsec, tref_frm_med_sec as medSec, tref_frm_med_msec as medMsec, tref_frm_tri_sec as triSec, tref_frm_tri_msec as triMsec FROM tbl_sal_exp_cli_param WHERE compania="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title="Parámetros del Expediente Clínico Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title="Parámetros del Expediente Clínico Edición - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Generales</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
							    <td width="17%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="25%"><%=fb.intBox("compania",id,false,false,true,30,2)%></td>
								<td width="18%"><cellbytelabel id="3">Ruta Sonido</cellbytelabel></td>
							    <td width="40"><%=fb.textBox("rutaSonido",cdo.getColValue("rutaSonido"),false,false,false,55,500)%></td>																													
							</tr>	
							<tr class="TextRow01">
								<td><cellbytelabel id="4">Atorios Solicitados a</cellbytelabel>:</td>
							    <td><%=fb.intBox("centroCode",cdo.getColValue("centroCode"),false,false,false,30,5)%></td>
								<td><cellbytelabel id="5">Almacen que Entrega Insumo en C.U</cellbytelabel>:</td>
							    <td><%=fb.intBox("almacenCode",cdo.getColValue("almacenCode"),false,false,false,55,3)%></td>																						
							</tr>	
							<tr class="TextRow01">
								<td><cellbytelabel id="6">Resultados Imagenolog&iacute;a</cellbytelabel>:</td>
							    <td><%=fb.textBox("resultRx",cdo.getColValue("resultRx"),false,false,false,30,30)%></td>
								<td><cellbytelabel id="7">Resultados Laboratorio</cellbytelabel>:</td>
							    <td><%=fb.textBox("resultLab",cdo.getColValue("resultLab"),false,false,false,55,30)%></td>																						
							</tr>													
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel id="8">Tiempo</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
				    <td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
							    <td width="30%"><cellbytelabel id="9">Tiempo de Refrescamiento</cellbytelabel>:</td>
							    <td width="70%"><%=fb.textBox("trefSec",cdo.getColValue("trefSec"),false,false,false,10,8)%>&nbsp;<cellbytelabel id="10">Segundos</cellbytelabel>&nbsp;&nbsp;<%=fb.intBox("trefMsec",cdo.getColValue("trefMsec"),false,false,false,12,8)%>&nbsp;<cellbytelabel id="11">Milsegundos</cellbytelabel></td>
							</tr>
							<tr class="TextRow01">
							    <td><cellbytelabel id="12">Tiempo de Ref. en Forma de Triage</cellbytelabel>:</td>
							    <td><%=fb.intBox("triSec",cdo.getColValue("triSec"),false,false,false,10,8)%>&nbsp;Segundos&nbsp;&nbsp;<%=fb.intBox("triMsec",cdo.getColValue("triMsec"),false,false,false,12,8)%>&nbsp;<cellbytelabel id="11">Milsegundos</cellbytelabel></td>
							</tr>
							<tr class="TextRow01">
							    <td><cellbytelabel id="13">Tiempo de Ref. en Forma de Enf</cellbytelabel>:</td>
							    <td><%=fb.intBox("enfSec",cdo.getColValue("enfSec"),false,false,false,10,8)%>&nbsp;Segundos&nbsp;&nbsp;<%=fb.intBox("enfMsec",cdo.getColValue("enfMsec"),false,false,false,12,8)%>&nbsp;<cellbytelabel id="11">Milsegundos</cellbytelabel></td>
							</tr>
							<tr class="TextRow01">
							    <td><cellbytelabel id="14">Tiempo de Ref. en Forma de Med</cellbytelabel>:</td>
							    <td><%=fb.intBox("medSec",cdo.getColValue("medSec"),false,false,false,10,8)%>&nbsp;Segundos&nbsp;&nbsp;<%=fb.intBox("medMsec",cdo.getColValue("medMsec"),false,false,false,12,8)%>&nbsp;<cellbytelabel id="11">Milsegundos</cellbytelabel></td>
							</tr>
						</table>
					</td>							
				</tr>													
                <tr class="TextRow02">
					<td align="right" colspan="2">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="17">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>    
	</tr>
</table>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  cdo = new CommonDataObject();
  id = request.getParameter("compania");
  mode = request.getParameter("mode");

  cdo.setTableName("tbl_sal_exp_cli_param");
  if (request.getParameter("rutaSonido") != null && !request.getParameter("rutaSonido").equals(""))
  cdo.addColValue("ruta_sonido",request.getParameter("rutaSonido"));
  if (request.getParameter("centroCode") != null && !request.getParameter("centroCode").equals(""))
  cdo.addColValue("cod_centro_sol_lab",request.getParameter("centroCode"));
  if (request.getParameter("almacenCode") != null && !request.getParameter("almacenCode").equals(""))
  cdo.addColValue("cod_almacen_cu",request.getParameter("almacenCode"));
  if (request.getParameter("resultRx") != null && !request.getParameter("resultRx").equals(""))
  cdo.addColValue("frm_resultado_rx",request.getParameter("resultRx"));
  if (request.getParameter("resultLab") != null && !request.getParameter("resultLab").equals(""))
  cdo.addColValue("frm_resultado_lab",request.getParameter("resultLab")); 
  
  if (request.getParameter("trefSec") != null && !request.getParameter("trefSec").equals(""))
  cdo.addColValue("tref_sec01",request.getParameter("trefSec"));
  if (request.getParameter("trefMsec") != null && !request.getParameter("trefMsec").equals(""))
  cdo.addColValue("tref_msec01",request.getParameter("trefMsec"));
  
  if (request.getParameter("triSec") != null && !request.getParameter("triSec").equals(""))
  cdo.addColValue("tref_frm_tri_sec",request.getParameter("triSec"));
  if (request.getParameter("triMsec") != null && !request.getParameter("triMsec").equals(""))
  cdo.addColValue("tref_frm_tri_msec",request.getParameter("triMsec"));  
    
  if (request.getParameter("enfSec") != null && !request.getParameter("enfSec").equals(""))
  cdo.addColValue("tref_frm_enf_sec",request.getParameter("enfSec"));
  if (request.getParameter("enfMsec") != null && !request.getParameter("enfMsec").equals(""))
  cdo.addColValue("tref_frm_enf_msec",request.getParameter("enfMsec"));
  if (request.getParameter("medSec") != null && !request.getParameter("medSec").equals(""))
  cdo.addColValue("tref_frm_med_sec",request.getParameter("medSec"));
  if (request.getParameter("medMsec") != null && !request.getParameter("medMsec").equals(""))
  cdo.addColValue("tref_frm_med_msec",request.getParameter("medMsec"));
  
  if (mode.equalsIgnoreCase("add"))
  {    
    cdo.addColValue("compania",id);
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+id);
	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/param_expclinico_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/param_expclinico_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/param_expclinico_list.jsp';
<%
	}
	
	if (saveOption.equalsIgnoreCase("N"))																					
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>