
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
=============================================================================================
		FG             		REPORTE                DESCRIPCION                        FORMA EN ORACLE
		DF          		INV0082.RDF            DETALLE DE FACTURAS POR ALMACEN     INV950100.FMB
		RF          		INV0032_F.RDF          RESUMEN DE FACTURAS POR ALMACEN     INV800650.FMB
		RP					INV70231.RDF		   RESUMEN DE RECEPCIONES DE PROVEEDOR POR FAMILIA
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


String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");

StringBuffer sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(compania);
sbSql.append(", 'TIPO_PAGO_ORD_COMP'), '1') excluir_recep_contado  from dual");
CommonDataObject _cdo = SQLMgr.getData(sbSql.toString());
if (_cdo == null) _cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}

function showProveedor()
{
		abrir_ventana('../compras/sel_proveedor.jsp?fp=<%=fg%>');
}

function showReporte(isExcel)
{
	var almacen   = eval('document.form0.almacen').value;
	var compania  = eval('document.form0.compania').value;
	var fecha_i   = eval('document.form0.fechaini').value;
	var fecha_f   = eval('document.form0.fechafin').value;
	var proveedor = eval('document.form0.codProv').value;


<%if(fg.trim().equals("DF")){%>
var factura   = eval('document.form0.factura').value;
var familia   = eval('document.form0.familia').value;
var articulo  = eval('document.form0.articulo').value;
	abrir_ventana('../compras/print_detalle_facturas.jsp?fp=RDA&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&proveedor='+proveedor+'&factura='+factura+'&articulo='+articulo+'&familia='+familia);

<%}else if(fg.trim().equals("RP")){%>

var factura   = eval('document.form0.factura').value;
var familia   = eval('document.form0.familia').value;
var articulo  = eval('document.form0.articulo').value;

var descAlm1 ='';
var indice = document.form0.almacen.selectedIndex ;
var descAlm= document.form0.almacen.options[indice].text;
if(almacen !='')
 descAlm1 = document.form0.almacen.options[indice].text;
 else descAlm1 = '';
if(descAlm1 =='')
alert('Seleccione un Almacen')
else
{
	if(!isExcel) abrir_ventana('../compras/print_resumen_recepcion_familia.jsp?compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&proveedor='+proveedor+'&factura='+factura+'&familia='+familia+'&descAlm='+descAlm1+'&articulo='+articulo);
    else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=compras/resumen_recepcion_familia.rptdesign&pCtrlHeader=true&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&proveedor='+proveedor+'&factura='+factura+'&familia='+familia+'&descAlm='+descAlm1+'&articulo='+articulo+'&excluir_recep_contado=<%=_cdo.getColValue("excluir_recep_contado")%>');
}
<%}else {%>

var titulo   = eval('document.form0.titulo').value;
var tipo   = eval('document.form0.tipo').value;
var depto  = eval('document.form0.depto').value;
var descAlm1 ='';
var indice = document.form0.almacen.selectedIndex ;
var descAlm= document.form0.almacen.options[indice].text;
if(almacen !='')
 descAlm1 = descAlm.substr(0,descAlm.length);
 else descAlm1 = '';
var generar ='N';
if(tipo ==''){if(confirm('Se generara el reporte para las rececpiones con orden de compra y las facturas a credito')){generar='S';}}else{generar='S';}
if(generar=='S')
{
 if(tipo =='PA'){abrir_ventana('../compras/print_resumen_facturas_pam.jsp?fp=RDA&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&cod_prov='+proveedor+'&depto='+depto+'&titulo='+titulo+'&descAlm='+descAlm1);}
else if(tipo =='FG'){
abrir_ventana('../compras/print_resumen_facturas_consig.jsp?fp=RDA&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&cod_prov='+proveedor+'&depto='+depto+'&titulo='+titulo+'&descAlm='+descAlm1);}
else {abrir_ventana('../compras/print_resumen_facturas.jsp?almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&cod_prov='+proveedor+'&depto='+depto+'&titulo='+titulo+'&descAlm='+descAlm1+'&tipoDoc='+tipo);}
}
<%}%>
}
function clearP()
{
document.form0.descProv.value = "";
document.form0.codProv.value = "";
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("DF")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DETALLE DE FACTURAS"></jsp:param>
</jsp:include>
<%}else if(fg.trim().equals("RP")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE RESUMEN DE RECEPCION DE PROVEEDOR POR FAMILIA"></jsp:param>
</jsp:include>
<%}else if(fg.trim().equals("RF")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE RESUMEN DE FACTURAS"></jsp:param>
</jsp:include>

<%}%>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
		<%if(fg.trim().equals("RF")){%>
		<tr class="TextFilter">
			<td><cellbytelabel>Departamento</cellbytelabel></td>
			<td><%=fb.textBox("depto","",false,false,false,50)%></td>

		</tr>
		<tr class="TextFilter">
			<td><cellbytelabel>T&iacute;tulo</cellbytelabel></td>
			<td><%=fb.textBox("titulo","",false,false,false,50)%></td>

		</tr>


		<%}%>
		<tr class="TextFilter">
		<td width="15%"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel>
		</td>
		<td width="85%">

		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,codigo||' - '||nombre FROM   tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>



			<cellbytelabel>Almac&eacute;n</cellbytelabel>
			<%=fb.select("almacen","","")%>
<%if(fg.trim().equals("RP")){%>
      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>
			
			<%}else {%>
			 <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>
			
			<%}%>
			
			</td>
		</tr>
		<tr class="TextFilter">
			<td><cellbytelabel>Proveedor</cellbytelabel> </td>
			<td>
				<%=fb.textBox("codProv","",false,false,false,5,null,null,"onFocus=\"javascript:clearP()\"")%>
				<%=fb.textBox("descProv","TODOS LOS PROVEEDORES",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
			</td>
		</tr>
		<%if((fg.trim().equals("DF"))||(fg.trim().equals("RP"))){%>
		<tr class="TextFilter">
			<td><cellbytelabel>Factura</cellbytelabel></td>
			<td> <%=fb.textBox("factura","",false,false,false,15)%> 
			<cellbytelabel>Familia</cellbytelabel><%=fb.textBox("familia","",false,false,false,15)%>
			 
			 <cellbytelabel>Art&iacute;culo</cellbytelabel><%=fb.textBox("articulo","",false,false,false,15)%> <font color="#FF9900">(Familia-Clase-Articulo)</font></td>
		</tr>
		<%}%>
		<tr class="TextFilter">
			<td><cellbytelabel>Fecha</cellbytelabel></td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />

											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include></td>

		</tr>
	<%if(fg.trim().equals("RF")){%>

	<tr class="TextFilter">
			<td><cellbytelabel>Tipo Factura</cellbytelabel></td>
			<td><%//=fb.select("tipo","FC=FACTURAS DE CONTADO,FR=FACTURAS A CREDITO,FG=FACTURAS A CONSIGNACION","","S")%>
				<%=fb.select(ConMgr.getConnection(),"select documento, documento||' - '||descripcion from tbl_inv_documento_recepcion where documento not in('NE') order by 1","tipo","",false,false,0,"T","","","","S")%>

			</td>
		</tr>
	<%}%>

		<tr class="TextHeader">
			<td>&nbsp;</td>
			<td>
            
                <%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <%if(fg.trim().equals("RP")){%>
                    <%=fb.button("reporteXls","Excel",true,false,null,null,"onClick=\"javascript:showReporte(1)\"")%>
                <%}%>
            
            </td>
		</tr>


		</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
