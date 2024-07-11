
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
document.title = 'Reporte de Articulo- '+document.title;
function addArticulo()
{
}

function showReporte(value)
{

var msg = '';

var company = eval('document.form0.compania').value ;
var almacen = eval('document.form0.almacen').value ;
var punto = eval('document.form0.punto').value ;
var tipo = eval('document.form0.tipo').value ;
var existencia = eval('document.form0.existencia').value ;
var familyCode = eval('document.form0.familyCode').value ;
var classCode = eval('document.form0.classCode').value ;
var subclase = eval('document.form0.subclase').value ;
var fechaini = eval('document.form0.fechaini').value ;
var fechafin = eval('document.form0.fechafin').value ;
var codArticulo = eval('document.form0.codigo').value ;

if ((almacen=='' || familyCode=='' || classCode=='' || codArticulo == '') && value=="3" )
{
{alert('Algún parámetro: Almacen, Familia, Clase o Artículo sin Valor.. Revise.. '); return false;}
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
	<jsp:param name="title" value="REPORTE DE ARTICULOS"></jsp:param>
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
		<td width="50%"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel><%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%>
		
		</td>
		<td width="50%">											
		<cellbytelabel>Almac&eacute;n</cellbytelabel> <%=fb.select("almacen","","")%>
			 <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>
			
		</td>
	</tr>
	
	
	<tr class="TextFilter">
		<td width="50%"><cellbytelabel>Familia</cellbytelabel>		
			<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
     			 <script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
				</script>
		</td>
		<td width="50%"><cellbytelabel>Clase</cellbytelabel>
			<%=fb.select("classCode","","")%>
      			<script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
				</script>
		</td>
	</tr>
		<tr class="TextFilter">
			<td colspan="2"><cellbytelabel>SubClase</cellbytelabel>
			<%=fb.select(ConMgr.getConnection(),"select subclase_id as optValueColumn, subclase_id||' - '||descripcion as optLabelColumn from tbl_inv_subclase where compania="+(String) session.getAttribute("_companyId")+" order by subclase_id","subclase","",false,false,0,"T")%>
				
		</tr>
	<tr class="TextFilter">
		
		<td width="50%"> <cellbytelabel>Art&iacute;culo</cellbytelabel> <%=fb.intBox("codigo","",false,false,false,8,5)%>
			 <%=fb.textBox("descArticulo","",false,false,true,30,30)%>
			 <%=fb.button("btnArticulo","...",true,false,null,null,"onClick=\"javascript:addArticulo("+i+")\"")%>
		</td>
		<td width="50%"><cellbytelabel>Pto. Reorden</cellbytelabel>
			<%=fb.select("punto","G=Todos los Artículos, S=Solo con Reorden",punto,false,false,0,"Text10",null,null,"","T")%> 
					</td>
	</tr>
	
	<tr class="TextFilter">
		<td width="50%"><cellbytelabel>Tipo de Art&iacute;culo</cellbytelabel>
		 	<%=fb.select("tipo","A=ACTIVO, N=NORMAL, K=KIT, B=BANDEJA",tipo,false,false,0,"Text10",null,null,"","T")%>	
		</td>
		<td width="50%"><cellbytelabel>Existencia</cellbytelabel>
			<%=fb.select("existencia","S=Sin Existencia, C=Con Existencia",existencia,false,false,0,"Text10",null,null,"","T")%>
		</td>
	</tr>
	
	<tr class="TextFilter">
			<td colspan="2"><cellbytelabel>Fecha para el Reporte de Historial de Compra</cellbytelabel> :  <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include></td>
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
							<td colspan="2" align="center"><cellbytelabel>Reportes</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Art&iacute;culos: Con y Sin Existencias</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Art&iacute;culos: Con y Sin Punto de Reorden</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Art&iacute;culos: Historial de Compra</cellbytelabel> </td>
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
