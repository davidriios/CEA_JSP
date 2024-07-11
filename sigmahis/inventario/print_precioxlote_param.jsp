<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="alDataForPrinting" class="java.util.ArrayList" scope="session"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = " where 1=1 ";
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String action = request.getParameter("action");
String code = request.getParameter("code");
String fg = request.getParameter("fg"); 
String actDesc = request.getParameter("actDesc");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

String fechaini = (request.getParameter("fechaini")==null?fecha:request.getParameter("fechaini"));
String fechafin = (request.getParameter("fechafin")==null?fecha:request.getParameter("fechafin"));
if (fg == null) fg = "ART";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	String codigo  = "";
	String descrip = "";
	String subclase ="";

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;

function submitForPrinting(){
	fechaini = document.formDetail.fechaini.value;
	fechafin = document.formDetail.fechafin.value;
	familyCode = "";
	classCode = "";
	consignacion = "";
	
	if(document.formDetail.familyCode)familyCode = document.formDetail.familyCode.value;
	if(document.formDetail.classCode)classCode = document.formDetail.classCode.value;
	if(document.formDetail.consignacion)consignacion = document.formDetail.consignacion.value;
	
	itemCode = document.formDetail.code.value;
	abrir_ventana('../inventario/print_pricexlote_activities.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&familyCode='+familyCode+'&classCode='+classCode+'&consignacion='+consignacion+'&itemCode='+itemCode+'&actDesc=<%=actDesc%>&fg=<%=fg%>');
}
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

<tr class="TextFilter">
<%fb = new FormBean("formDetail",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<td colspan="2">
		<%if(fg.trim().equals("ART")){%>Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.formDetail.familyCode.value"%>,'KEY_COL','T');
		</script>
			Subclase
		<%=fb.textBox("subclase",request.getParameter("subclase"),false,false,false,10,null,null,null)%>
		Consignaci&oacute;n
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
		<%}%>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="2">
		
		<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="fechaini"/>
			<jsp:param name="valueOfTBox1" value="<%=fechaini%>"/>
			<jsp:param name="nameOfTBox2" value="fechafin"/>
			<jsp:param name="valueOfTBox2" value="<%=fechafin%>"/>
		</jsp:include>
		C&oacute;digo
		<%=fb.textBox("code",code,false,false,false,10,null,null,null)%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.button("printB","Imprimir",true,false,null,null,"onClick=\"javascript:submitForPrinting()\"")%>

	</td>
	<%=fb.formEnd()%>
</tr>
</table>
</body>
</html>
<%
}
%>