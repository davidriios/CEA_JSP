<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
String key = "";
String sql = "";
String appendFilter = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String anio = request.getParameter("anio");
String planilla = request.getParameter("planilla");
String periodo = request.getParameter("periodo");
String seccion = request.getParameter("seccion");

String empId = request.getParameter("empid");
String trxId = request.getParameter("trx");
String tipoId = request.getParameter("tipo");

String fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss");
String anioC = CmnMgr.getCurrentDate("yyyy");
String mes = CmnMgr.getCurrentDate("mm");
String dia = CmnMgr.getCurrentDate("dd");
String fecha=CmnMgr.getCurrentDate("dd/mm/yyyy");
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int extraLastLineNo = 0;
int auseLastLineNo = 0;
int descLastLineNo = 0;



int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));

if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	
	/*
if(dia >= '16') periodo = parseInt(mes, 10) * 2 - 1;
		else periodo = parseInt(mes, 10) * 2;
*/	

		
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
CommonDataObject cdoTot = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{

	
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;
function doAction(){}
function printPage()
{
var pe=document.form_0.periodo.value;
var an=document.form_0.anio.value;
var pl=document.form_0.planilla.value;
var ta=document.form_0.tab.value;
abrir_ventana('../rhplanilla/print_horas_extras.jsp?planilla='+pl+'&anio='+an+'&periodo='+pe+'&tab=0');		 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - REPORTE HORAS EXTRAS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextRow02">
  <td>&nbsp;</td>
</tr>
<tr class="TextRow02">
  <td>&nbsp;</td>
</tr>
<tr>
  <td>
    <table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form_0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
    <tr class="TextHeader">
      <td colspan="11" align="center">
        Parametros para reporte de Sobre tiempos. 
		<br> Año : &nbsp;<%=fb.textBox("anio",anio,false,false,false,5)%>
        <%=fb.select(ConMgr.getConnection(),"select cod_planilla , nombre from tbl_pla_planilla where compania = "+(String) session.getAttribute("_companyId")+" and is_visible ='S' and cod_planilla =1 order by cod_planilla" ,"planilla",planilla,false,false,0,"Text10",null,null)%> &nbsp;&nbsp;&nbsp;
		Periodo : &nbsp;<%=fb.textBox("periodo",periodo,false,false,false,5)%>
		<br>  &nbsp; 
		 <%=fb.button("go","Imprimir Horas Extras",false,false,"Text10",null,"onClick=\"javascript:printPage()\"")%>
		  &nbsp;&nbsp;&nbsp;
		 
		</td>
    </tr>		
	<%=fb.formEnd(true)%>
	</table>
  </td>
</tr>
</table> 
</body>
</html>
<%
} //GET
%>
