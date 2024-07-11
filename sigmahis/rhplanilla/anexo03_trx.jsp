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

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function doSubmit(baction)
{
	document.form0.baction.value = baction;
	window.frames['iDetalle'].doSubmit();
}
function refreshPage()
{
var pe=document.form0.mes1.value;
var anio=document.form0.anio.value;
var ta=document.form0.tab.value;
var empId=document.form0.empId.value;
var noEmpleado=document.form0.noEmpleado.value;
var salario= ''
if(document.form0.salario.checked)salario='S';
if (anio!='')
{
   // abrir_ventana('../rhplanilla/anexo03_detalle_trx.jsp?mode=add&anio='+an+'&periodo='+pe+'&tab=0');
	setFrameSrc('iDetalle','../rhplanilla/anexo03_detalle_trx.jsp?mode=add&anio='+anio+'&periodo='+pe+'&empId='+empId+'&noEmpleado='+noEmpleado+'&salario='+salario);
} else alert('Introduzca año');
}

function printRep(index)
{
var pe=document.form0.mes1.value;
var anio=document.form0.anio.value;
var empId=document.form0.empId.value;
var noEmpleado=document.form0.noEmpleado.value;
var salario= ''
if(document.form0.salario.checked)salario='S';
var fisco= ''
if(document.form0.fisco.checked)fisco='S';

if(index==1)
{
    abrir_ventana('../rhplanilla/print_anexo03_proy.jsp?anio='+anio+'&mes='+pe+'&empId='+empId+'&noEmpleado='+noEmpleado+'&salario='+salario);
} else if(index==2)
{
    abrir_ventana('../rhplanilla/print_anexo03.jsp?anio='+anio+'&mes='+pe+'&empId='+empId+'&noEmpleado='+noEmpleado+'&salario='+salario+'&fisco='+fisco);
} else if(index==3)
{
    abrir_ventana('../rhplanilla/print_salario_acumulado.jsp?anio='+anio+'&mes='+pe+'&empId='+empId+'&noEmpleado='+noEmpleado+'&salario='+salario);
} else if(index==4)
{
    var justificacion = (prompt("Motivo del Descuento!", "IMPUESTO SOBRE LA RENTA DEL  "+anio));
	abrir_ventana('../rhplanilla/print_anexo03_descto.jsp?anio='+anio+'&mes='+pe+'&justificacion='+justificacion+'&empId='+empId+'&noEmpleado='+noEmpleado+'&salario='+salario);
}else if (index==0){
   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_anexo3_dgi.rptdesign&p_anio='+anio+'&p_emp_num='+empId+'<>'+noEmpleado+'&pFisco='+fisco+'&pCtrlHeader=true');
}else if (index==-1){
  showPopWin('../common/generate_file.jsp?fp=ANEXO03&docType=ANEXO03&fisco='+fisco+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');
}

}
function searchEmpleado()
{abrir_ventana('../common/search_empleado.jsp?fp=anexo03');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('iDetalle'),xHeight,250);
//resetFrameHeight(document.getElementById('iDetalle'),xHeight,250);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="ANEXO 03"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
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
<%=fb.hidden("baction","")%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("extraSize",""+htextra.size())%>

    <tr class="TextHeader">
      <td colspan="11" align="center">
        <cellbytelabel>Proceso para Generar la Planilla de Anexo 03 </cellbytelabel>
		<br> <cellbytelabel>A&ntilde;o</cellbytelabel> : &nbsp;<%=fb.textBox("anio",anio,false,false,false,5,4,"","","onChange=\"javascript:refreshPage()\"")%>
        <%=fb.select("mes1", "01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE","",false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;&nbsp;Empleado<%=fb.intBox("empId","",false,false,false,5,"","","")%><cellbytelabel>No</cellbytelabel>. <%=fb.textBox("noEmpleado","",false,false,false,5,"","","")%>
		<%=fb.textBox("nombreEmpleado","",false,false,true,30,"","","")%><%=fb.button("searchEmple","...",false,false,"Text10",null,"onClick=\"javascript:searchEmpleado()\"")%><br>
		<%=fb.checkbox("salario","",false,false,null,null,"","EMPLEADOS CON SALARIO MAYOR A $. 847")%>
		<%=fb.button("go","Cargar Empleados",false,false,"Text10",null,"onClick=\"javascript:refreshPage()\"")%>
		<%=fb.checkbox("fisco","",false,false,null,null,"","EMPLEADOS CON IMPUESTO A FAVOR DEL FISCO")%>

		</td>
    </tr>
	 <tr class="TextHeader02">
	  <td width="20%" align="center">
        <br>  <%=fb.button("goaj0","Anexo03 (Exp)",false,false,"Text10",null,"onClick=\"javascript:printRep(0)\"")%>
		<br>  <%=fb.button("goaj-1","Anexo03 (txt)",false,false,"Text10",null,"onClick=\"javascript:printRep(-1)\"")%>
	  </td>

      <td width="20%" align="center">
        <cellbytelabel>Proyectado</cellbytelabel>
		<br>  <%=fb.button("goaj","Anexo 03 Proyectado",false,false,"Text10",null,"onClick=\"javascript:printRep(1)\"")%>
	  </td>

      <td width="20%" align="center">
        <cellbytelabel>Real</cellbytelabel>
		<br>  <%=fb.button("goaj2","Anexo 03 Real",false,false,"Text10",null,"onClick=\"javascript:printRep(2)\"")%>
	  </td>

      <td width="20%" align="center">
        <cellbytelabel>Salario e Imp./Renta</cellbytelabel>
		<br>  <%=fb.button("goaj3","Salarios Acumulados ",false,false,"Text10",null,"onClick=\"javascript:printRep(3)\"")%>
	  </td>

      <td width="20%" align="center">
      <cellbytelabel>Autorizaci&oacute;n</cellbytelabel>
	  <br>  <%=fb.button("goaj4","Autoriz. de Desc. ",false,false,"Text10",null,"onClick=\"javascript:printRep(4)\"")%>
	  </td>


    </tr>
	<!--<tr class="TextHeader02">
      <td colspan="4" align="right">
	<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%></td>
	</tr>-->
	<tr>
			<td colspan="5">
				<!--<div id="anexoMain" width="100%" style="overflow:scroll;position:relative;height:300">
				<div id="anexode" width="98%" style="overflow;position:absolute">-->
				<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td><iframe name="iDetalle" id="iDetalle" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../rhplanilla/anexo03_detalle_trx.jsp?mode=<%=mode%>&anio=<%=anio%>&period=<%=mes%>&tab=0"></iframe>
					     					
					</td>
				</tr>
				</table>
				<!--</div>
				</div>-->
			</td>
		</tr>
	<!--<tr class="TextHeader02">
      <td colspan="4" align="right">
	<%=fb.submit("save2","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%></td>
	</tr>-->

	<%=fb.formEnd(true)%>
	</table>
  </td>
</tr>

</table>

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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/anexo03_trx.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/anexo03_trx.jsp")%>';

	window.close();
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/anexo03_trx.jsp';
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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/anexo03_trx.jsp?anio=<%=anio%>&planilla=<%=planilla%>&periodo=<%=periodo%>&seccion=<%=seccion%>';

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
