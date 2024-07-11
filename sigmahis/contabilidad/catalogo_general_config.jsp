<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="ContMgr" scope="page" class="issi.contabilidad.AccountMapMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ContMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
Integer nivel = 0;
if(request.getParameter("nivel")!=null && !request.getParameter("nivel").equals("")) nivel = Integer.parseInt(request.getParameter("nivel"));
String compId = request.getParameter("compId");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		fechaCrea = cDateTime;
		fechaMod = cDateTime;
		userCrea = UserDet.getUserEmpId();
		userMod = UserDet.getUserEmpId();
		if(cta1!=null && !cta1.equals("0")){
			sbSql.append("select codigo_clase claseCuentaCode, descripcion as claseCuenta");
			sbSql.append(", (select cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6||' '||descripcion from tbl_con_catalogo_gral where cta1 = '");
			sbSql.append(cta1);
			sbSql.append("'");
			if (cta2 == null || cta2.equals("0")) sbSql.append(" and cta2 = '00'"); else { sbSql.append(" and cta2 = '"); sbSql.append(cta2); sbSql.append("'"); }
			if (cta3 == null || cta3.equals("0")) sbSql.append(" and cta3 = '000'"); else  { sbSql.append(" and cta3 = '"); sbSql.append(cta3); sbSql.append("'"); }
			if (cta4 == null || cta4.equals("0")) sbSql.append(" and cta4 = '000'"); else  { sbSql.append(" and cta4 = '"); sbSql.append(cta4); sbSql.append("'"); }
			if (cta5 == null || cta5.equals("0")) sbSql.append(" and cta5 = '000'"); else  { sbSql.append(" and cta5 = '"); sbSql.append(cta5); sbSql.append("'"); }
			if (cta6 == null || cta6.equals("0")) sbSql.append(" and cta6 = '000'"); else  { sbSql.append(" and cta6 = '"); sbSql.append(cta6); sbSql.append("'"); }
			sbSql.append(" and compania = ");
			sbSql.append(compId);
			sbSql.append(") as cuenta_madre");
			sbSql.append(" from tbl_con_cla_ctas where codigo_clase = ");
			sbSql.append(cta1);
			cdo = SQLMgr.getData(sbSql.toString());
			if(cta1!=null && !cta1.equals("") && nivel >= 1) cdo.addColValue("cta1",cta1);
			if(cta2!=null && !cta2.equals("") && nivel >= 2) cdo.addColValue("cta2",cta2);
			if(cta3!=null && !cta3.equals("") && nivel >= 3) cdo.addColValue("cta3",cta3);
			if(cta4!=null && !cta4.equals("") && nivel >= 4) cdo.addColValue("cta4",cta4);
			if(cta5!=null && !cta5.equals("") && nivel >= 5) cdo.addColValue("cta5",cta5);
			if(cta6!=null && !cta6.equals("") && nivel >= 6) cdo.addColValue("cta6",cta6);
		} else {
			cdo.addColValue("cuenta_madre","");
			cdo.addColValue("cta1","");
			cdo.addColValue("cta2","00");
			cdo.addColValue("cta3","000");
			cdo.addColValue("cta4","000");
			cdo.addColValue("cta5","000");
			cdo.addColValue("cta6","000");
		}
	}
	else
	{
		/*if (code == null) throw new Exception("La Cuenta Principal no es válida. Por favor intente nuevamente!");*/

		fechaMod =cDateTime;
		userMod = UserDet.getUserEmpId();

		sbSql.append("SELECT a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.compania, a.descripcion, a.lado_movim as ladoMov, decode(a.recibe_mov,'1','S','2','N',a.recibe_mov) as recibeMov, a.tipo_cuenta as claseCuentaCode, b.descripcion as claseCuenta, a.ult_mes as ultMes, a.ult_anio as ultAnio");
		if (nivel == 1) sbSql.append(", ' '");
		else {
			sbSql.append(", (select cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6||' '||descripcion from tbl_con_catalogo_gral where cta1 = a.cta1");
			if (nivel <= 2) sbSql.append(" and cta2 = '00'"); else sbSql.append(" and cta2 = a.cta2");
			if (nivel <= 3) sbSql.append(" and cta3 = '000'"); else sbSql.append(" and cta3 = a.cta3");
			if (nivel <= 4) sbSql.append(" and cta4 = '000'"); else sbSql.append(" and cta4 = a.cta4");
			if (nivel <= 5) sbSql.append(" and cta5 = '000'"); else sbSql.append(" and cta5 = a.cta5");
			if (nivel <= 6) sbSql.append(" and cta6 = '000'"); else sbSql.append(" and cta6 = a.cta6");
			sbSql.append(" and compania = a.compania)");
		}
		sbSql.append(" as cuenta_madre FROM tbl_con_catalogo_gral a, tbl_con_cla_ctas b WHERE a.tipo_cuenta = b.codigo_clase and a.cta1='");
		sbSql.append(cta1);
		sbSql.append("' and a.cta2='");
		sbSql.append(cta2);
		sbSql.append("' and a.cta3='");
		sbSql.append(cta3);
		sbSql.append("' and a.cta4='");
		sbSql.append(cta4);
		sbSql.append("' and a.cta5='");
		sbSql.append(cta5);
		sbSql.append("' and a.cta6='");
		sbSql.append(cta6);
		sbSql.append("' and compania=");
		sbSql.append(compId);
		cdo = SQLMgr.getData(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Catálogo General - "+document.title;
function add(){abrir_ventana1('../contabilidad/catalogo_clasecuenta_list.jsp');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("userCrea",userCrea)%>
		<%=fb.hidden("userMod",userMod)%>
		<%=fb.hidden("compId",compId)%>
		<%=fb.hidden("fechaCrea",fechaCrea)%>
		<%=fb.hidden("fechaMod",fechaMod)%>
		<%=fb.hidden("cta1",cta1)%>
		<%=fb.hidden("cta2",cta2)%>
		<%=fb.hidden("cta3",cta3)%>
		<%=fb.hidden("cta4",cta4)%>
		<%=fb.hidden("cta5",cta5)%>
		<%=fb.hidden("cta6",cta6)%>
		<%=fb.hidden("nivel",""+nivel)%>
		<tr class="TextHeader">
			<td colspan="4" align="center">&nbsp;<%=cdo.getColValue("cuenta_madre")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo de Cuenta</td>
			<td>
				<%=fb.textBox("claseCuentaCode",cdo.getColValue("claseCuentaCode"),true,false,true,5)%>
				<%=fb.textBox("claseCuenta",cdo.getColValue("claseCuenta"),true,false,true,37)%>
				<%=fb.button("btntipo","...",true,!((mode.equalsIgnoreCase("add") && nivel == 0) || (mode.equalsIgnoreCase("edit") && nivel == 1)),null,null,"onClick=\"javascript:add()\"")%>
			</td>
<% if (mode.equalsIgnoreCase("add") && nivel >= 2) { %>
			<td>Replicar en otras cuentas:</td>
			<td><%=fb.select("replicar","N=No,S=Sí","")%></td>
<% } else { %>
			<td>&nbsp;</td>
			<td><%=fb.hidden("replicar","N")%></td>
<% } %>
		</tr>
		<% int accLvlDiff = (mode.equalsIgnoreCase("add"))?1:0; %>
		<tr class="TextRow01">
			<td width="14%">Cuenta Financiera</td>
			<td width="38%">
			<%=fb.textBox("cuenta1",cdo.getColValue("cta1"),true,false,true,3,3)%><%--always readonly, it changes when selecting account type--%>
			<%=fb.textBox("cuenta2",(mode.equals("edit")?cdo.getColValue("cta2"):mode.equals("add") && nivel >=2?cdo.getColValue("cta2"):nivel==1?"":"00"),true,false,nivel != (2 - accLvlDiff),3,2)%>
			<%=fb.textBox("cuenta3",(mode.equals("edit")?cdo.getColValue("cta3"):mode.equals("add") && nivel >=3?cdo.getColValue("cta3"):nivel==2?"":"000"),true,false,nivel != (3 - accLvlDiff),3,3)%>
			<%=fb.textBox("cuenta4",(mode.equals("edit")?cdo.getColValue("cta4"):mode.equals("add") && nivel >=4?cdo.getColValue("cta4"):nivel==3?"":"000"),true,false,nivel != (4 - accLvlDiff),3,3)%>
			<%=fb.textBox("cuenta5",(mode.equals("edit")?cdo.getColValue("cta5"):mode.equals("add") && nivel >=5?cdo.getColValue("cta5"):nivel==4?"":"000"),true,false,nivel != (5 - accLvlDiff),3,3)%>
			<%=fb.textBox("cuenta6",(mode.equals("edit")?cdo.getColValue("cta6"):mode.equals("add") && nivel >=6?cdo.getColValue("cta6"):nivel==5?"":"000"),true,false,nivel != (6 - accLvlDiff),3,3)%>
			</td>
			<td width="13%">Descripci&oacute;n</td>
			<td width="35%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Recibe Movimiento</td>
			<td><%=fb.select("recibeMov","S=Sí,N=No",cdo.getColValue("recibeMov"),true,false,false,0,null,null,null,null,"S")%></td>
			<td>Lado Movimiento</td>
			<td><%=fb.select("ladoMov","CR=Crédito,DB=Débito",cdo.getColValue("ladoMov"),true,false,false,0,null,null,null,null,"S")%></td>
		</tr>
		<tr class="TextRow01">
			<td>&Uacute;ltimo Mes</td>
			<td><%=fb.select("ultMes","1=Enero,2=Febrero,3=Marzo,4=Abril,5=Mayo,6=Junio,7=Julio,8=Agosto,9=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",cdo.getColValue("ultMes"))%></td>
			<td>&Uacute;ltimo A&ntilde;o</td>
			<td><%=fb.intBox("ultAnio",cdo.getColValue("ultAnio"), false, false, false, 6,4)%></td>
		</tr>
		<tr>
			<td colspan="4">
				<jsp:include page="../common/bitacora.jsp" flush="true">
				<jsp:param name="audTable" value="tbl_con_catalogo_gral"></jsp:param>
				<jsp:param name="audFilter" value="<%="cta1 = '"+cta1+"' and cta2 = '"+cta2+"' and cta3 = '"+cta3+"' and cta4 = '"+cta4+"' and cta5 = '"+cta5+"' and cta6 = '"+cta6+"' and compania = "+session.getAttribute("_companyId")%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
			<%=fb.submit("save","Guardar",true,false)%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
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

	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	if(request.getParameter("ladoMov")!=null) cdo.addColValue("lado_movim",request.getParameter("ladoMov"));
	cdo.addColValue("recibe_mov",request.getParameter("recibeMov"));
	cdo.addColValue("tipo_cuenta",request.getParameter("claseCuentaCode"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("ult_mes",request.getParameter("ultMes"));
	cdo.addColValue("nivel",request.getParameter("nivel"));
	cdo.addColValue("replicar",request.getParameter("replicar"));
	cdo.addColValue("mode",request.getParameter("mode"));
	StringBuffer numCta = new StringBuffer();
	numCta.append(request.getParameter("cuenta1"));
	if(mode.equals("add")){
		cdo.addColValue("cta1",request.getParameter("cuenta1"));
		cdo.addColValue("cta2",request.getParameter("cuenta2"));
		cdo.addColValue("cta3",request.getParameter("cuenta3"));
		cdo.addColValue("cta4",request.getParameter("cuenta4"));
		cdo.addColValue("cta5",request.getParameter("cuenta5"));
		cdo.addColValue("cta6",request.getParameter("cuenta6"));
		cdo.addColValue("compania",request.getParameter("compId"));
		if(cdo.getColValue("nivel").equals("1")) cdo.addColValue("num_cta", request.getParameter("cuenta2"));
		if(cdo.getColValue("nivel").equals("2")) cdo.addColValue("num_cta", request.getParameter("cuenta3"));
		if(cdo.getColValue("nivel").equals("3")) cdo.addColValue("num_cta", request.getParameter("cuenta4"));
		if(cdo.getColValue("nivel").equals("4")) cdo.addColValue("num_cta", request.getParameter("cuenta5"));
		if(cdo.getColValue("nivel").equals("5")) cdo.addColValue("num_cta", request.getParameter("cuenta6"));
		if(nivel==1){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
		} else if(nivel==2){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta3"));
		} else if(nivel==3){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta3"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta4"));
		} if(nivel==4){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta3"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta4"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta5"));
		} else if(nivel==5){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta3"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta4"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta5"));
			numCta.append(".");
			numCta.append(request.getParameter("cuenta6"));
		}
	} else {
		cdo.addColValue("cta1",request.getParameter("cta1"));
		cdo.addColValue("cta2",request.getParameter("cta2"));
		cdo.addColValue("cta3",request.getParameter("cta3"));
		cdo.addColValue("cta4",request.getParameter("cta4"));
		cdo.addColValue("cta5",request.getParameter("cta5"));
		cdo.addColValue("cta6",request.getParameter("cta6"));
		cdo.addColValue("compania",request.getParameter("compId"));
		cdo.addColValue("new_cta1",request.getParameter("cuenta1"));
		cdo.addColValue("new_cta2",request.getParameter("cuenta2"));
		cdo.addColValue("new_cta3",request.getParameter("cuenta3"));
		cdo.addColValue("new_cta4",request.getParameter("cuenta4"));
		cdo.addColValue("new_cta5",request.getParameter("cuenta5"));
		cdo.addColValue("new_cta6",request.getParameter("cuenta6"));
		if(cdo.getColValue("nivel").equals("1")) cdo.addColValue("num_cta", request.getParameter("cuenta1"));
		if(cdo.getColValue("nivel").equals("2")) cdo.addColValue("num_cta", request.getParameter("cuenta2"));
		if(cdo.getColValue("nivel").equals("3")) cdo.addColValue("num_cta", request.getParameter("cuenta3"));
		if(cdo.getColValue("nivel").equals("4")) cdo.addColValue("num_cta", request.getParameter("cuenta4"));
		if(cdo.getColValue("nivel").equals("5")) cdo.addColValue("num_cta", request.getParameter("cuenta5"));
		if(cdo.getColValue("nivel").equals("6")) cdo.addColValue("num_cta", request.getParameter("cuenta6"));
		if(nivel>1){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta2"));
		}
		if(nivel>2){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta3"));
		}
		if(nivel>3){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta4"));
		}
		if(nivel>4){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta5"));
		}
		if(nivel>5){
			numCta.append(".");
			numCta.append(request.getParameter("cuenta6"));
		}
	}
	cdo.addColValue("numero_cta", numCta.toString());
	System.out.println("numero_cta="+numCta.toString());

	if(request.getParameter("ultAnio")!=null && !request.getParameter("ultAnio").equals("")) cdo.addColValue("ult_anio",request.getParameter("ultAnio"));

	if (mode.equalsIgnoreCase("add")){
		ContMgr.addCuenta(cdo);
	} else {
		ContMgr.updateCuenta(cdo);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ContMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ContMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/catalogo_general_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/catalogo_general_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/catalogo_general_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(ContMgr.getErrException());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>