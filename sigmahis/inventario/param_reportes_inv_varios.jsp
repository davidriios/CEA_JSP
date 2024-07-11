
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
String almacenDev = request.getParameter("almacenDev");
String companiaDev = request.getParameter("companiaDev");
String unidad = request.getParameter("unidad");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");	
if (companiaDev == null) companiaDev = (String) session.getAttribute("_companyId");
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
document.title = 'Reporte de Recibos- '+document.title;
function doAction()
{
}
function showArea()
{
		abrir_ventana1('../inventario/sel_unid_ejec.jsp?fg=RUA');
}
function showReporte(value)
{

var msg = '';
var caja = eval('document.form0.compania').value  ;
var indice = document.form0.compania.selectedIndex ;
var descCja= document.form0.compania.options[indice].text;

var company = eval('document.form0.compania').value ;
var almacen = eval('document.form0.almacen').value ;
var unidad = eval('document.form0.codArea').value ;
var companiaDev = eval('document.form0.companiaDev').value ;
var almacenDev = eval('document.form0.almacenDev').value ;

var fechaini = eval('document.form0.fechaini').value ;
var fechafin = eval('document.form0.fechafin').value ;

//if(almacen == "")
//msg = ' Almacen ';

if((fechaini =='') || (fechafin =='')) msg=' Fecha Inicial y Final ';
if (fechaini > fechafin) msg=' un Rango de Fecha Válido';

if(msg == '')

{
	if(value=="1")
	abrir_ventana('../inventario/print_cargos_departamento.jsp?fp=CE&compania='+company+'&almacen='+almacen+'&almacenDev='+almacenDev+'&fechaini='+fechaini+'&fechafin='+fechafin+'&unidad='+unidad+'&companiaDev='+companiaDev);
	else if(value=="2")
	abrir_ventana('../inventario/print_activo_departamento.jsp?fp=CFC&compania='+company+'&almacen='+almacen+'&fechaini='+fechaini+'&fechafin='+fechafin+'&companiaDev='+companiaDev+'&almacenDev='+almacenDev);
	
}
else alert('Seleccione '+msg);


}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE RECIBOS"></jsp:param>
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
			
	<tr class="TextHeader">
		<td colspan="2" align="center"> Solicitante  </td>
	</tr>
			
	<tr class="TextFilter">
		<td colspan="2" align="center">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%></td>
	</tr>
	<tr class="TextFilter">
		<td colspan="2" align="center">	Almacen <%=fb.select("almacen","","")%>
			<script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>	
		</td>
		</tr>
		<tr class="TextFilter">
		<td colspan="2" align="center">	Unidad <%=fb.textBox("codArea","",false,false,false,5)%><%=fb.textBox("descArea","",false,false,true,40)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>	
		</td>
	</tr>
	<tr class="TextHeader">
		<td colspan="2" align="center"> Entrega / Devolución  </td>
	</tr>
			
		
	<tr class="TextFilter">
		<td colspan="2" align="center">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","companiaDev",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacenDev','"+almacenDev+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%>		</td>
	</tr>
	
	<tr class="TextFilter">
		<td colspan="2" align="center">											
			Almacen
			<%=fb.select("almacenDev","","")%>
					
           <script language="javascript">
			loadXML('../xml/almacenes.xml','almacenDev','<%=almacenDev%>','VALUE_COL','LABEL_COL','<%=(companiaDev != null && !companiaDev.equals(""))?companiaDev:"document.form0.companiaDev.value"%>','KEY_COL','T');
			</script>			
		</td>
	</tr>
		
	<tr class="TextFilter">
		<td width="50%">Fecha 
			Desde &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="1" />        
        	<jsp:param name="clearOption" value="true" />        
        	<jsp:param name="nameOfTBox1" value="fechaini" />        
        	<jsp:param name="valueOfTBox1" value="" />        </jsp:include>
		</td>
											
		<td width="50%"> Hasta &nbsp;&nbsp; 
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechafin" />
			<jsp:param name="valueOfTBox1" value="" />
			</jsp:include>
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
				
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos a los Departamentos </td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos por Activos a los Departamentos </td>
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
