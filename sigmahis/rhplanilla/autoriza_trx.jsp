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
<jsp:useBean id="htextra" scope="session" class="java.util.Hashtable" />

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


SQL2BeanBuilder sbb = new SQL2BeanBuilder();

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

String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = cDateTime.substring(6,10);
String mes = cDateTime.substring(3,5);
String dia = cDateTime.substring(0,2);
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int extraLastLineNo = 0;
int auseLastLineNo = 0;
int descLastLineNo = 0;
int day = Integer.parseInt(dia);
int mont = Integer.parseInt(mes);

if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	
sec = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, descripcion as optLabelColumn from tbl_sec_unidad_ejec where codigo <= 100 and nivel = 3 and compania="+(String) session.getAttribute("_companyId")+" order by descripcion", CommonDataObject.class);
		
if (tab == null) tab = "0";
if (mode == null) mode = "add";
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
function refreshPage()
{
var pe=document.form0.periodo.value;
var an=document.form0.anio.value;
var pl=document.form0.planilla.value;
var se=document.form0.seccion.value;
var ta=document.form0.tab.value;
var empId=document.form0.empId.value;
var tipoTrx=document.form0.tipoTrx.value;
abrir_ventana('../rhplanilla/autoriza_detalle_trx.jsp?mode=view&planilla='+pl+'&anio='+an+'&periodo='+pe+'&seccion='+se+'&tab=0&tipoTrx='+tipoTrx+'&empId='+empId);
}
function actualiza(fg){abrir_ventana('../rhplanilla/actualiza_ajuste_trx.jsp?mode=view&fg='+fg);}
function searchEmpleado(){abrir_ventana("../common/search_empleado.jsp?fp=autorizaTrx");}
function searchTipoTrx(){abrir_ventana("../common/search_tipohoraExtra.jsp?fp=autorizaTrx");}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - APROBAR TRANSACCIONES "></jsp:param>
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

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("extraSize",""+htextra.size())%> 


    <tr class="TextHeader">
      <td colspan="4" align="center">Autorizaciones de Transacciones para Cálculo de Planilla</td>
	</tr>
	<tr class="TextFilter">
      <td>Año :</td>
	  <td colspan="3"><%=fb.textBox("anio",anio,false,false,false,5)%></td>
	</tr>
	<tr class="TextFilter">
      <td width="20%">Tipo Planilla</td>
	  <td width="30%"><%=fb.select(ConMgr.getConnection(),"select cod_planilla , nombre from tbl_pla_planilla where compania = "+(String) session.getAttribute("_companyId")+" order by cod_planilla" ,"planilla",planilla,false,false,0,"Text10",null,null)%></td>
	  <td width="20%">Periodo :</td>
	  <td width="30%"><%=fb.textBox("periodo",periodo,false,false,false,5)%></td>
	</tr>
	<tr class="TextFilter">
      <td>Sección :</td>
	  <td colspan="3"><%=fb.select("seccion",sec,seccion,"T")%></td>
	</tr>
	<tr class="TextFilter">
      <td>Empleado :</td>
	  <td colspan="3">ID.<%=fb.textBox("empId","",false,false,false,5)%>No. Empleado<%=fb.textBox("noEmpleado","",false,false,false,5)%>
	  				  <%=fb.textBox("nombreEmpleado","",false,false,true,30)%>
					  <%=fb.button("btnEmpleado","...",false,false,"Text10",null,"onClick=\"javascript:searchEmpleado()\"")%></td>
	</tr>
	<tr class="TextFilter">
      <td>Tipo Transacción  :</td>
	  <td colspan="3"><%=fb.textBox("tipoTrx","",false,false,false,5)%>
	  				  <%=fb.textBox("nombreTrx","",false,false,true,30)%>
					  <%=fb.button("btnTrx","...",false,false,"Text10",null,"onClick=\"javascript:searchTipoTrx()\"")%></td>
	</tr>
	<tr class="TextHeader">
      <td colspan="4" align="center">        
		<authtype type='51'><%=fb.button("go","Aprobar Transacciones",false,false,"Text10",null,"onClick=\"javascript:refreshPage()\"")%></authtype>
		</td>
    </tr>
	
	<tr class="TextHeader">
      <td colspan="4" align="center">
		<authtype type='50'><%=fb.button("goaj","Actualizar Ajustes",false,false,"Text10",null,"onClick=\"javascript:actualiza('AP')\"")%></authtype>
		<authtype type='52'><%=fb.button("rechazaraj","Rechazar Ajustes",false,false,"Text10",null,"onClick=\"javascript:actualiza('RE')\"")%></authtype>
		</td>
    </tr>
	<%=fb.formEnd(true)%>
	</table>
  </td>
</tr>

</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET
else
{


String saveOption 	= request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction 		= request.getParameter("baction");
int keySize			= Integer.parseInt(request.getParameter("extraSize"));
String itemRemoved 	= "";
			empId 	= request.getParameter("empId");
ArrayList list = new ArrayList();
	if(tab.equals("0"))
	{
	int size=0;
 
	}//End Tab
  
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
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/autoriza_trx.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/autoriza_trx.jsp")%>';
	
	window.close();
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/autoriza_trx.jsp';
	window.close();
<%
		}
	}

	} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/autoriza_trx.jsp?anio=<%=anio%>&planilla=<%=planilla%>&periodo=<%=periodo%>&seccion=<%=seccion%>';

	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
