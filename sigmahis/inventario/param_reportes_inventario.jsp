
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");

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
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}

function showReporte(value, doingExcel)
{

var msg = '';
var caja = eval('document.form0.compania').value  ;
var indice = document.form0.compania.selectedIndex ;
var descCja= document.form0.compania.options[indice].text;

var company = eval('document.form0.compania').value ;
var almacen = eval('document.form0.almacen').value ;
var anaquelx = eval('document.form0.anaquelx').value ;
var anaquely = eval('document.form0.anaquely').value ;
var consignacion = eval('document.form0.consignacion').value ;
var status = document.form0.status.value;
var pCtrlHeader = $("#pCtrlHeader").is(":checked");
var x=0;
if(almacen == "")
msg = ' Almacen ';

if(msg == '')
{
/*
FP		REPORTE
CE 		INV0053.RDF 1
---     INV0062.RDF 2   
CSE		INV0060.RDF 3
CF		INV0055.RDF 4 
CFC	    INV0061.RDF 5 
SACE    INV0076.RDF 7
*/
	if(value!="2" && value !="7"){if(anaquelx !='' || anaquely !=''){ if(isNaN(anaquelx)||isNaN(anaquely)){alert('Numero de anaquel invalido');x++;}}}
	if(x==0){
	if(value=="1") {
	  if (!doingExcel) abrir_ventana('../inventario/print_articulos_x_anaquel.jsp?fp=CE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_x_anaquel.rptdesign&fp=CE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="2") {
	  if (!doingExcel) abrir_ventana('../inventario/print_articulos_con_sin_anaquel.jsp?fp=CSACE&compania='+company+'&almacen='+almacen+'&almacen='+almacen+'&consignacion='+consignacion+'&status='+status);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_con_sin_anaquel.rptdesign&fp=CSACE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="3") {
	  if (!doingExcel) abrir_ventana('../inventario/print_articulos_x_anaquel_central.jsp?fp=CSE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_x_anaquel_central.rptdesign&fp=CSE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="4") {
	  if (!doingExcel) abrir_ventana('../inventario/print_articulos_x_anaquel.jsp?fp=CF&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_x_anaquel.rptdesign&fp=CF&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="5") {
      if (!doingExcel) abrir_ventana('../inventario/print_articulos_x_anaquel.jsp?fp=CFC&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status);
      else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_x_anaquel.rptdesign&fp=CFC&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	//else if(value=="6")
	//abrir_ventana('../inventario/print_diferencia_sistema.jsp?fp=CFC&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio=2009&consigna=N');
	else if(value=="7") {
	  if (!doingExcel) abrir_ventana('../inventario/print_articulos_con_sin_anaquel.jsp?fp=SACE&compania='+company+'&almacen='+almacen+'&consignacion='+consignacion+'&status='+status);
    else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_con_sin_anaquel.rptdesign&fp=SACE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="8") {
	  if(!doingExcel)abrir_ventana('../inventario/print_articulos_con_sin_anaquel.jsp?fp=SASE&compania='+company+'&almacen='+almacen+'&consignacion='+consignacion+'&status='+status);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_articulos_con_sin_anaquel.rptdesign&fp=SASE&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&consignacion='+consignacion+'&status='+status+'&pCtrlHeader='+pCtrlHeader);
	}
	
	}
}
else alert('Seleccione '+msg);

//	abrir_ventana2('../caja/print_recibos_sin_adm.jsp?fp=reporte&caja='+caja+'&descCaja='+descCaja);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE INVENTARIO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>

	<tr class="TextFilter">
		<td width="50%">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>

		</td>
		<td width="50%">

			Almacen
			<%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>





											</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">Anaquel Desde<%=fb.textBox("anaquelx","",false,false,false,5)%></td>
			<td width="50%"> Hasta <%=fb.textBox("anaquely","",false,false,false,5)%></td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2">Consignaci&oacute;n&nbsp;&nbsp;<%=fb.select("consignacion","S=SI,N=NO","",false,false,0,"",null,null,null,"T")%>
            &nbsp;&nbsp;&nbsp;&nbsp;Estado&nbsp;&nbsp;<%=fb.select("status","A=Activo,I=Inactivo","",false,false,0,"",null,null,null,"T")%>
            </td>
		</tr>
		</table>
</td></tr>

		<tr><td>&nbsp;</td></tr>

<tr>
 <td>
   <table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextHeader">
							<td colspan="2" align="center">Reportes</td>
				</tr>
				
				
				
				<tr class="TextRow02">
					<td colspan="2">
            <label>
             <input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">
              Esconder cabecera de label compa&ntilde;&iacute;a en Excel
            </label>
          </td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2">
            <%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos por Anaquel
            &nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(1, true)" class="Link00">Excel</a>
          </td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos Con y sin Anaquel Con Existencia
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(2, true)" class="Link00">Excel</a>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos Con y sin Existencia por Anaquel
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(3, true)" class="Link00">Excel</a>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos por Anaquel para Conteo fìsico
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(4, true)" class="Link00">Excel</a>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos con y sin Existencia para Inventario f&iacute;sico
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(5, true)" class="Link00">Excel</a>
					</td>
				</tr>
				<!--<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Diferencia entre Inventario vs. Sistema</td>
				</tr>--->
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos sin Anaquel y Con Existencia
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(7, true)" class="Link00">Excel</a>
					</td>
				</tr>
                <tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Articulos sin Anaquel y Sin Existencia
					&nbsp;&nbsp;&nbsp;
            <a href="javascript:showReporte(8, true)" class="Link00">Excel</a>
					</td>
				</tr>

	<%fb.appendJsValidation("if(error>0)doAction();");%>

<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
