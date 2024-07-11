
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
String familyCode=request.getParameter("familyCode");
String classCode=request.getParameter("classCode");
String punto=request.getParameter("punto");
String tipo=request.getParameter("tipo");
String existencia=request.getParameter("existencia");
String fechaini=request.getParameter("fechaini");
String fechafin=request.getParameter("fechafin");

String salida = request.getParameter("salida");

int cantidad = 0;
int i=1;

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
document.title = 'Reporte de Activos- '+document.title;
function addArticulo()
{
}

function showReporte(value)
{

var msg = '';

var company = eval('document.form0.compania').value ;
var anio = eval('document.form0.almacen').value ;
var mes = eval('document.form0.punto').value ;
var fecha = eval('document.form0.tipo').value ;
var desde = eval('document.form0.existencia').value ;
var hasta = eval('document.form0.familyCode').value ;
var secuencia = eval('document.form0.classCode').value ;
var subclase = eval('document.form0.subclase').value ;
var fechaini = eval('document.form0.fechaini').value ;
var fechafin = eval('document.form0.fechafin').value ;
var codArticulo = eval('document.form0.codigo').value ;

if ((anio=='' || mes=='' || fecha=='' || secuencia == '') && value=="3" )
{
{alert('Algún parámetro: Año, Mes, Fecha o Secuencia sin Valor.. Revise.. '); return false;}
}

if(msg == '')

{
	if(value=="1")
	abrir_ventana('../compras/print_articulo_consin_existencia.jsp?fp=CSE&compania='+company+'&almacen='+almacen+'&existencia='+existencia+'&familia='+familyCode+'&clase='+classCode);
	else if(value=="2")
	abrir_ventana('../compras/print_articulo_consin_existencia.jsp?fp=CPR&compania='+company+'&almacen='+almacen+'&punto='+punto+'&tipo='+tipo+'&familia='+familyCode+'&clase='+classCode);
	else if(value=="3")
	abrir_ventana2('../inventario/print_historia_mov_articulo.jsp?fp=CSE&compania='+company+'&familyCode='+familyCode+'&classCode='+classCode+'&wh='+almacen+'&id='+codArticulo+'&fdate='+fechaini+'&tdate='+fechafin+'&subclase='+subclase);
	
	
	//else if(value=="6")
	//abrir_ventana2('../inventario/print_diferencia_sistema.jsp?fp=CFC&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio=2009&consigna=N');
	
}
else alert('Seleccione '+msg);

//	abrir_ventana2('../caja/print_recibos_sin_adm.jsp?fp=reporte&caja='+caja+'&descCaja='+descCaja);

}
function addArticulo(index)

{
var famCode = eval('document.form0.familyCode').value ;
var claCode = eval('document.form0.classCode').value ;
var almacen = eval('document.form0.almacen').value ;
var msg='';
	if(almacen ==' ') msg=' Almacen';
	if(famCode =='')  msg+=' , Familia';
	if(claCode =='')  msg+=' ,Clase';
	if(msg=='')
	abrir_ventana('../common/search_articulo.jsp?id=2&fp=RA&familia='+famCode+'&clase='+claCode+'&almacen='+almacen);
	else alert('Seleccione '+msg);
   
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE ACTIVOS FIJOS"></jsp:param>
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
			<td colspan="2">Activos: </td>
		</tr>

	
	<tr class="TextFilter">
		<td width="50%">A&ntilde;o		
			<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
     			 <script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
				</script>		</td>
		<td width="50%">Mes
			<%=fb.select("classCode","","")%>
      			<script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
				</script>		</td>
	</tr>
		<tr class="TextFilter">
			<td colspan="2">Secuencia : Desde: 
			<%=fb.intBox("desde","",false,false,false,8,5)%>
			Hasta : 	<%=fb.intBox("hasta","",false,false,false,8,5)%>		</tr>
		<tr class="TextFilter">
			<td colspan="2">Reportes: </td>
		</tr>
		
	<tr class="TextFilter">
		
		<td width="50%"> No. de Placa <%=fb.intBox("placa","",false,false,false,8,5)%> </td>
		<td width="50%">Tipo de Transferencia <%=fb.select("tipo","I=Permanente, T=Temporal",tipo,false,false,0,"Text10",null,null,"","T")%>					</td>
	</tr>
	
	<tr class="TextFilter">
		<td colspan="2">Fecha para el Reporte de Salida de Activos:  
		  <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />											</jsp:include>
											&nbsp;Tipo de Salida <%=fb.select(ConMgr.getConnection(),"SELECT cod_salida codigo, cod_salida||'-'||descripcion FROM tbl_con_tipo_salida order by cod_salida","salida",salida,false,false,0,"S")%>											</td>
	</tr>
	
	<tr class="TextFilter">
			<td colspan="2">Depreciación: </td>
		</tr>
	
		
	<tr class="TextFilter">
			<td colspan="2">Fecha para el Reporte de Historial de Compra :  <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include>
					&nbsp; Cuenta de Activo <%=fb.intBox("codigo","",false,false,false,8,5)%>			 <%=fb.textBox("descCta","",false,false,true,30,30)%><%=fb.button("btnCuenta","...",true,false,null,null,"onClick=\"javascript:addCuenta("+i+")\"")%></td>
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
					<td colspan="2"><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos: Generales del Activo</td>
				</tr>
			
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos: Por Orden de Compra</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos: Por Cuenta Contable </td>
				</tr>
					
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Activos: Por  Tipo de Activo</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de Moviemientos de Activos </td>
				</tr>
				
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de Transferencias de Activos </td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de Salidas de Activos</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depreciación : Reporte de Depreciación </td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Depreciación :  Activos Depreciados </td>
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
