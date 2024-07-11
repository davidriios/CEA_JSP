
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="java.io.*"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
=============================================================================================
		FLAG     REPORTE           DESCRIPCION                                   FORMA EN ORACLE 
		PEP		COM0013.RDF	   PENDIENTE DE ENTREGA POR RECEPCION POR PROVEEDOR 	COM800050
		PEA     COM0014.RDF    PENDIENTE DE ENTREGA POR RECEPCION POR ARTICULO		COM800051
=============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String compania =  (String) session.getAttribute("_companyId");	
String fg       = request.getParameter("fg");
String almacen = request.getParameter("almacen");

String sql        = "";
String classCode  = request.getParameter("classCode");
String familyCode = request.getParameter("familyCode");
String wh         = "";
String popUp      = "";
if(almacen == null ) almacen = "";
/*
sql = "select i.art_familia value_col, i.art_familia||' - '||a.nombre as label_col, i.art_familia as title_col, i.compania||'-'||i.codigo_almacen as key_col from (select distinct compania, art_familia, codigo_almacen from tbl_inv_inventario where compania="+(String) session.getAttribute("_companyId")+") i, tbl_inv_familia_articulo a where i.compania=a.compania(+) and i.art_familia=a.cod_flia(+) order by i.compania, i.codigo_almacen, a.nombre";
		XMLCreator xc = new XMLCreator(ConMgr);
		xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"itemFamily.xml",sql);
*/
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Compras- '+document.title;
function doAction()
{
}
function showProveedor()
{
	abrir_ventana('../inventario/sel_proveedor.jsp?fp=RP');
}
function showReporte(fg)
{
	var depto     = eval('document.form0.depto').value;
	var titulo    = eval('document.form0.titulo').value;	
	var fecha_i   = eval('document.form0.fechaini').value;
	var fecha_f   = eval('document.form0.fechafin').value;	
	var proveedor = eval('document.form0.codProv').value;
	var familia   = eval('document.form0.familyCode').value;
	var clase     = eval('document.form0.classCode').value;
	var subclase  = eval('document.form0.subclase').value;
	var articulo  = eval('document.form0.codigo').value;
	var anio_oc  = eval('document.form0.anio_oc').value;
	var num_oc  = eval('document.form0.num_oc').value;
	var tipo_pago = document.form0.tipo_pago?document.form0.tipo_pago.value||'all':'all';

  if(fg=='PEA'){ 
   // var almacen    = eval('document.form0.wh').value;
	
	abrir_ventana('../compras/print_list_ordencompra_art.jsp?fp=RP&fDate='+fecha_i+'&tDate='+fecha_f+'&familia='+familia+'&clase='+clase+'&articulo='+articulo+'&proveedor='+proveedor+'&depto='+depto+'&titulo='+titulo+'&subclase='+subclase+'&anio='+anio_oc+'&numOc='+num_oc+'&tipo_pago='+tipo_pago);

}else {
    
    abrir_ventana('../compras/print_list_ordencompra_prov.jsp?fp=RP&fDate='+fecha_i+'&tDate='+fecha_f+'&familia='+familia+'&clase='+clase+'&articulo='+articulo+'&proveedor='+proveedor+'&depto='+depto+'&titulo='+titulo+'&subclase='+subclase+'&anio='+anio_oc+'&numOc='+num_oc+'&tipo_pago='+tipo_pago);
}
}

function buscaArticulo()
{
	var msg ='';
//	var almacen     = eval('document.form0.wh').value;
	var familia     = eval('document.form0.familyCode').value;
	var clase       = eval('document.form0.classCode').value;
	//if(almacen ==' ') msg=' Almacen';
	//if(familia =='') msg+=' , Familia';
	//if(clase =='')   msg+=' ,Clase';
	if(msg=='')
	 abrir_ventana('../common/search_articulo.jsp?id=2&fp=RA&familia='+familia+'&clase='+clase);
	else alert('Seleccione '+msg);
} 
function cargarClase()
{
var clase = eval('document.form0.classCode').value;
var flia = eval('document.form0.familyCode').value;
loadXML('../xml/itemClass.xml','classCode',clase,'VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+flia,'KEY_COL','S');
eval('document.form0.classCode').value="";
}	
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("PEP")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE PENDIENTE DE ENTREGA RECEPCION POR PROVEEDOR"></jsp:param>
</jsp:include>
<%}else if(fg.trim().equals("PEA")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE PENDIENTE DE ENTREGA RECEPCION POR ARTICULO"></jsp:param>
</jsp:include>
<%}%>

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("descripcion","")%>
		
		<tr class="TextFilter">
			<td><cellbytelabel>Departamento</cellbytelabel></td>
			<td><%=fb.textBox("depto","",false,false,false,50)%></td>
		</tr>
	
		<tr class="TextFilter">
			<td><cellbytelabel>T&iacute;tulo</cellbytelabel></td>
			<td><%=fb.textBox("titulo","",false,false,false,50)%></td>
			
		</tr>
			
		<%//if(fg.trim().equals("PEA")){%>
	
	
		
		<tr class="TextFilter">
			<td><cellbytelabel>Familia</cellbytelabel></td>
			<td colspan="2">
				<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		
		</td>
			</tr>
		<tr class="TextFilter">	
		<td> <cellbytelabel>Clase</cellbytelabel> </td>
		<td colspan="2">
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
		</script>
			</td>
			</tr>
				<tr class="TextFilter">
			<td><cellbytelabel>SubClase</cellbytelabel></td>
			<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select subclase_id as optValueColumn, subclase_id||' - '||descripcion as optLabelColumn from tbl_inv_subclase where compania="+(String) session.getAttribute("_companyId")+" order by subclase_id","subclase","",false,false,0,"T")%>
				
		</tr>
	
		<tr class="TextFilter">
			<td>&Aacute;rticulo</td>
			<td colspan="2"><%=fb.intBox("codigo","",false,false,false,10)%><%=fb.textBox("descArticulo","",false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%> </td>
		</tr>
				<%//}%>
				
				
		<%//if(fg.trim().equals("PEP")){%>	
		<tr class="TextFilter">
			<td><cellbytelabel>Proveedor</cellbytelabel> </td>
			<td><%=fb.textBox("codProv","",false,false,false,5)%> 
			 <%=fb.textBox("descProv","",false,false,true,50)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%></td>
		</tr>
		<%//}%>
		<tr class="TextFilter">
			<td><cellbytelabel>Rango de Fecha</cellbytelabel></td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaini" />
				<jsp:param name="valueOfTBox1" value="" />
										
				<jsp:param name="nameOfTBox2" value="fechafin" />
				<jsp:param name="valueOfTBox2" value="" />
				</jsp:include></td>
		</tr>
		<tr class="TextFilter">
			<td><cellbytelabel>Año orden</cellbytelabel></td>
			<td><%=fb.textBox("anio_oc","",false,false,false,5)%>  Numero de Orden:<%=fb.textBox("num_oc","",false,false,false,5)%> &nbsp;
			<%
			//if(fg.equals("PEP")){
			%>
			Tipo Pago:
			<%=fb.select("tipo_pago","2=Crédito,1=Contado","",false,false,0, "S")%>
			<%//}%>
			</td>

		</tr>
		<tr class="TextHeader">
			<td>&nbsp;</td>
			<td><%=fb.button("reporte","Reporte por Articulo",true,false,null,null,"onClick=\"javascript:showReporte('PEA')\"")%>&nbsp;&nbsp;&nbsp;<%=fb.button("reporte","Reporte por Proveedor",true,false,null,null,"onClick=\"javascript:showReporte('PP')\"")%></td>
		</tr>
	
		</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
