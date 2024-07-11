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

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fg = request.getParameter("fg");
String title="MOTIVOS DE DEMORAS";
if (mode == null) mode = "add";
if (fg == null) fg = "CA";
if(fg.trim().equals("SP"))title="SOLICTUD DE PROCEDIMIENTOS";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code= "0";
		cdo = new CommonDataObject();
		cdo.addColValue("fecha_creacion",""+cDateTime);
		cdo.addColValue("fecha_modificacion",""+cDateTime);
		cdo.addColValue("usuario_creacion",""+(String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion",""+(String) session.getAttribute("_userName"));
		cdo.addColValue("activa_observ","N");

	}
	else
	{
		if (code == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");

		sql.append("select codigo, descrip_motivo descripcion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, usuario_creacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, usuario_modificacion, estado_motivo estado");
		if(!fg.trim().equals("CA"))
		{

			sql.append(",observacion,activa_observ ");
			sql.append(" from tbl_sal_motivo_sol_proc where ");
		}
		else{ sql.append(" from tbl_sal_cama_motivo where ");
		sql.append("  compania = ");
		sql.append(session.getAttribute("_companyId"));
		sql.append(" and ");
		}
		sql.append(" codigo =");
		sql.append(code);
		cdo = SQLMgr.getData(sql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title=" Motivos  - "+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - <%=title%>"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
			<%=fb.hidden("fg",fg)%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="25%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="25%"><%=code%></td>
					<td width="25%"></td>
					<td width="25%"></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60,60)%></td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="3">Estado</cellbytelabel></td>
					<td colspan="3"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"), false, false, 0, "Text10", "", "S")%></td>
				</tr>
				<%if(fg.trim().equals("SP")){%>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Observaciones:</cellbytelabel></td>
					<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,50,2,2000,null,"width='100%'","",null,false,null,"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="5">Activar Observaciones Adicionales:</cellbytelabel></td>
					<td colspan="3"><%=fb.select("activa_observ","N=NO,S=SI",cdo.getColValue("activa_observ"), false, false, 0, "Text10", "", "")%></td>
				</tr>
				<%}%>

				<tr class="TextRow01">
					<td><cellbytelabel id="6">Usuario Creación</cellbytelabel></td>
					<td><%=fb.textBox("usuario_creacion",cdo.getColValue("usuario_creacion"),false,false,true,30,30)%></td>
					<td><cellbytelabel id="7">Usuario Modificación</cellbytelabel></td>
					<td><%=fb.textBox("usuario_modificacion",cdo.getColValue("usuario_modificacion"),false,false,true,30,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="8">Fecha Creación</cellbytelabel></td>
					<td><%=fb.textBox("fecha_creacion",cdo.getColValue("fecha_creacion"),false,false,true,20)%></td>
					<td><cellbytelabel id="9">Fecha Modificación</cellbytelabel></td>
					<td><%=fb.textBox("fecha_modificacion",cdo.getColValue("fecha_modificacion"),false,false,true,20)%></td>
				</tr>

				<tr class="TextRow02">
				<td align="right" colspan="4">
					<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:
					<%=fb.radio("saveOption","N")%><cellbytelabel id="11">Crear Otro</cellbytelabel>
					<%=fb.radio("saveOption","O")%><cellbytelabel id="12">Mantener Abierto</cellbytelabel>
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="13">Cerrar</cellbytelabel>
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
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
  code = request.getParameter("code");
  if(fg.trim().equals("SP"))
  {
    cdo.setTableName("tbl_sal_motivo_sol_proc");
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("activa_observ",request.getParameter("activa_observ"));
  }
  else
  {
  	cdo.setTableName("tbl_sal_cama_motivo");
	cdo.addColValue("compania",""+(String) session.getAttribute("_companyId"));
  }


    cdo.addColValue("descrip_motivo",request.getParameter("descripcion"));
	cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"));
	cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"));
	cdo.addColValue("fecha_modificacion",cDateTime);
	cdo.addColValue("usuario_modificacion",""+(String) session.getAttribute("_userName"));
	cdo.addColValue("estado_motivo",request.getParameter("estado"));


  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncCol("codigo");
	cdo.addPkColValue("codigo","");
	SQLMgr.insert(cdo);
  code = SQLMgr.getPkColValue("codigo");

  }
  else
  {
    cdo.setWhereClause("codigo="+code);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/list_motivos.jsp?fg="+fg))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/list_motivos.jsp?fg="+fg)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/list_motivos.jsp?fg=<%=fg%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>