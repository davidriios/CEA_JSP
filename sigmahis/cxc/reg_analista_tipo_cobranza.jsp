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
<jsp:useBean id="iTipo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTipo" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
cxc90062
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
String tipo = request.getParameter("tipo");
String change = request.getParameter("change");

if (id == null || tipo == null) throw new Exception("El Analista / Cobrador no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select a.codigo, a.tipo_cobrador, decode(a.provincia,null,' ',''||a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',''||a.tomo) as tomo, decode(a.asiento,null,' ',''||a.asiento) as asiento, decode(a.codigo_empresa,null,' ',''||a.codigo_empresa) as codigo_empresa, nvl(a.encargado_empresa,' ') as encargado_empresa, decode(a.compania,null,' ',''||a.compania) as compania, nvl(a.nombre_cobrador,' ') as nombre_cobrador, decode(a.emp_id,null,' ',''||a.emp_id) as emp_id, decode(a.tipo_cobrador,'E','EMPLEADO','M','EMPRESA',a.tipo_cobrador) as tipo, decode(a.tipo_cobrador,'E',a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,'M',''||a.codigo_empresa,' ') as codigo_cobrador from tbl_cxc_cobrador a where a.codigo = ");
	sbSql.append(id);
	sbSql.append(" and a.tipo_cobrador = '");
	sbSql.append(tipo);
	sbSql.append("' and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	cdo = SQLMgr.getData(sbSql.toString());

	if (change == null)
	{
		iTipo.clear();
		vTipo.clear();

		sbSql = new StringBuffer();
		sbSql.append("select z.*, lpad(rownum,3,'0') as key from (select a.cod_tipo_analista, nvl(a.observacion,' ') as observacion, (select descripcion from tbl_cxc_tipo_analista where tipo = a.cod_tipo_analista) as desc_tipo_analista from tbl_cxc_cobrador_x_tipo a where a.cod_cobrador = ");
		sbSql.append(id);
		sbSql.append(" and nvl(a.compania,");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(") = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" order by 1) z");
		al  = SQLMgr.getDataList(sbSql.toString());
		for (int i=1; i<=al.size(); i++)
		{
			CommonDataObject t = (CommonDataObject) al.get(i-1);
			t.setAction("U");
			try
			{
				iTipo.put(t.getColValue("key"),t);
				vTipo.add(t.getColValue("cod_tipo_analista"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for
	}//change null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title='Tipo de Cobranza por Analista - '+document.title;
function doAction(){<% if (request.getParameter("type") != null) { %>abrir_ventana1('../common/check_tipo_analista.jsp?fp=analista&id=<%=id%>&tipo=<%=tipo%>');<% } %>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TIPO DE COBRANZA POR ANALISTA"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%">
		<table width="100%" cellpadding="1" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("size",""+iTipo.size())%>
<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2">Tipo Cobrador: <label class="RedText Text12"><%=cdo.getColValue("tipo")%></label></td>
			<td colspan="2">Cobrador: <label class="RedText Text12">[<%=cdo.getColValue("codigo_cobrador")%>] <%=cdo.getColValue("nombre_cobrador")%></label></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td colspan="2">Tipo Analista</td>
			<td rowspan="2" width="57%">Observaci&oacute;n</td>
			<td rowspan="2" width="3%"><%=fb.submit("addTipo","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Tipo Analista")%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%">C&oacute;digo</td>
			<td width="33%">Descripci&oacute;n</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iTipo);
for (int i=1; i<=iTipo.size(); i++)
{
  CommonDataObject t = (CommonDataObject) iTipo.get(al.get(i - 1).toString());
  String style = (t.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
%>
		<%=fb.hidden("action"+i,t.getAction())%>
		<%=fb.hidden("key"+i,t.getColValue("key"))%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("cod_tipo_analista"+i,t.getColValue("cod_tipo_analista"))%>
		<%=fb.hidden("desc_tipo_analista"+i,t.getColValue("desc_tipo_analista"))%>
		<tr class="TextRow01"<%=style%> align="center">
			<td><%=t.getColValue("cod_tipo_analista")%></td>
			<td align="left"><%=t.getColValue("desc_tipo_analista")%></td>
			<td><%=fb.textBox("observacion"+i,t.getColValue("observacion"),false,false,false,80,2000)%></td>
			<td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				Opciones de Guardar:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";

	al.clear();
	iTipo.clear();
	for (int i=1; i<=size; i++)
	{
		CommonDataObject t = new CommonDataObject();

		t.setTableName("tbl_cxc_cobrador_x_tipo");
		t.setKey(i);
		t.setAction(request.getParameter("action"+i));
		t.setWhereClause("cod_cobrador = "+id+" and cod_tipo_analista = "+request.getParameter("cod_tipo_analista"+i)+" and compania = "+(String) session.getAttribute("_companyId"));
		t.addColValue("cod_cobrador",id);
		t.addColValue("compania",(String) session.getAttribute("_companyId"));
		t.addColValue("cod_tipo_analista",request.getParameter("cod_tipo_analista"+i));
		t.addColValue("desc_tipo_analista",request.getParameter("desc_tipo_analista"+i));
		t.addColValue("observacion",request.getParameter("observacion"+i));
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = t.getColValue("cod_tipo_analista");
			if (t.getAction().equalsIgnoreCase("I")) t.setAction("X");//if it is not in DB then remove it
			else t.setAction("D");
		}

		if (!t.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iTipo.put(t.getKey(),t);
				al.add(t);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for

	if (!itemRemoved.equals(""))
	{
		vTipo.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&tipo="+tipo);
		return;
	}
	else if (baction.equalsIgnoreCase("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&id="+id+"&tipo="+tipo);
		return;
	}
	else if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.saveList(al,true,false);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	<% if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
	<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
	<% }%>
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>&tipo=<%=tipo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>