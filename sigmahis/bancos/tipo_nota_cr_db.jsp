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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String id=request.getParameter("id");
String mode=request.getParameter("mode");
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		//cdo.addColValue("codigo","-1");
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de control de asistencia de Empleado no es válido. Por favor intente nuevamente!");
sql = "select a.tipo_mov, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion desc_cta, a.id, a.codigo, a.descripcion, a.tipo_mov from tbl_con_tipo_nota_cr_db a, tbl_con_catalogo_gral b where a.compania="+(String)session.getAttribute("_companyId")+" and a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.id='"+id+"'"; 
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Cuentas Relacionadas a Banco - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cuentas Relacionadas a Banco - Edición - "+document.title;
<%}%>
function setBAction(fName,actionValue){	document.forms[fName].baction.value = actionValue;}
function list_value(){abrir_ventana1('../common/check_cuentas.jsp?fp=tipo_nota_cr_db');}
function checkCode(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_con_tipo_nota_cr_db','codigo=\''+obj.value+'\' and compania=<%=(String)session.getAttribute("_companyId")%>','<%=cdo.getColValue("codigo")%>');}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS RELACIONADAS A BANCO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("baction","")%>
			<%//=fb.hidden("cot",cdo.getColValue("cot"))%>
			<%//=fb.hidden("code",cdo.getColValue("code"))%>
			<%//=fb.hidden("alterno",cdo.getColValue("alterno"))%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="18%" align="right">Cuenta Contable</td>
				<td width="82%">
					<%=fb.textBox("cta1", cdo.getColValue("cta1"),true,false,true,5)%>
					<%=fb.textBox("cta2", cdo.getColValue("cta2"),true,false,true,5)%>
					<%=fb.textBox("cta3", cdo.getColValue("cta3"),true,false,true,5)%>
					<%=fb.textBox("cta4", cdo.getColValue("cta4"),true,false,true,5)%>
					<%=fb.textBox("cta5", cdo.getColValue("cta5"),true,false,true,5)%>
					<%=fb.textBox("cta6", cdo.getColValue("cta6"),true,false,true,5)%>
					<%=fb.textBox("desc_cta", cdo.getColValue("desc_cta"),true,false,true,60)%>
					<%=fb.button("btnldv","...",true,false,null,null,"onClick=\"javascript:list_value()\"")%>
					</td>
				<tr class="TextRow01">
					<td align="right">Codigo</td>
				<td>
				<%=fb.textBox("codigo", cdo.getColValue("codigo"),true,false,(mode.equals("edit")),4,4,null,null,"onBlur=\"javascript:checkCode(this)\"")%>
				<%=fb.textBox("descripcion", cdo.getColValue("descripcion"),true,false,false,62)%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Tipo</td>
				<td><%=fb.select("tipo_mov","DB=DEBITO,CR=CREDITO",cdo.getColValue("tipo_mov"),false,false,0,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Estado</td>
				<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"")%></td>
			</tr>
			<tr>
				<td colspan="2">
				<jsp:include page="../common/bitacora.jsp" flush="true">
				<jsp:param name="audCollapsed" value="y"></jsp:param>
				<jsp:param name="audTable" value="TBL_CON_TIPO_NOTA_CR_DB"></jsp:param>
				<jsp:param name="audFilter" value="<%="id="+id%>"></jsp:param>
			    </jsp:include>
		    </td>
			</tr>					
			<tr class="TextRow02">
				<td colspan="2" align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>	
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>		
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
  cdo = new CommonDataObject();
  cdo.setTableName("TBL_CON_TIPO_NOTA_CR_DB");
  cdo.addColValue("tipo_mov",request.getParameter("tipo_mov")); 
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
	cdo.addColValue("cta6",request.getParameter("cta6"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion","sysdate");
	cdo.addColValue("estado",request.getParameter("estado"));
	cdo.addColValue("codigo",request.getParameter("codigo"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	
  if (mode.equalsIgnoreCase("add"))
  {
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("fecha_creacion","sysdate");
		cdo.setAutoIncCol("id");
		cdo.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId"));
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("id="+request.getParameter("id") + " and compania = "+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/tipo_nota_cr_db_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/tipo_nota_cr_db_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/tipo_nota_cr_db_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>