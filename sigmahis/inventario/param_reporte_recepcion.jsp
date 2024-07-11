
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
		FG             	REPORTE                DESCRIPCION
		RDA          		INV70307.RDF           RECEPCION DE ARTICULOS POR RANGO DE FECHA Y ALMACEN (ORDEN DE COMPRA,FACTURA CREDITO, FACTURAS CONTADO)
		RDAN            INV70307_NEW.RDF	 		 RECEPCION DE ARTICULOS POR RANGO DE FECHA Y ALMACEN,FAMILIA,CLASE (ORDEN DE COMPRA,FACTURA CREDITO, FACTURAS CONTADO)
		FC							INV70307_FG.RDF				 RECEPCION DE ARTICULOS (POR CONSIGNACIÓN)
		FCN							INV70307_FG_NEW.RDF    RECEPCION DE ARTICULOS (POR CONSIGNACIÓN) CON SUBTOTALES
		FG							INV70307_FC.RDF				 RECEPCION DE ARTICULOS (CREDITO)
		FGN       			INV70307_FC_NEW.RDF		 RECEPCION DE ARTICULOS (CREDITO) CON SUBTOTALES
		RCC					INV00132.RDF  			 COMPARATIVO DE MOVIMIENTO DEL MATERIAL A CONSIGNACION POR PROVEEDOR
		   					INV00132_V2.RDF  		 COMPARATIVO DE MOVIMIENTO DEL MATERIAL A CONSIGNACION POR PROVEEDOR CON COSTOS
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

String fg = request.getParameter("fg");
String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String familyCode = "";
String classCode = "";
if(fg == null) fg = "RR";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<style>
	.excel-button {
		background-color: transparent;
		background-repeat: no-repeat;
		border: none;
		cursor: pointer;
		overflow: hidden;
		outline: none;
	}
</style>
<script language="javascript">
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}
function showProveedor()
{
		abrir_ventana('../inventario/sel_proveedor.jsp?fp=RAD');
}
function showReporte2(xtraOpt)
{
	<%if(fg.trim().equals("RLP")){%>
		var compania = document.form0.compania.value;
        var familyCode = document.form0.familyCode.value;
        var classCode  = document.form0.classCode.value;
        var almacen = document.form0.almacen.value;
        var status = document.form0.status.value;
		if(!xtraOpt) abrir_ventana('../inventario/print_listado_articulo_usuario.jsp?compania='+compania+'&family_code='+familyCode+'&class_code='+classCode+'&almacen='+almacen+'&status='+status);
        else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_listado_articulo_usuario.rptdesign&compania='+compania+'&family_code='+familyCode+'&class_code='+classCode+'&almacen='+almacen+'&status='+status+'&pCtrlHeader=true');
	<%}else if(fg.trim().equals("RCC")){%>
		var almacen = eval('document.form0.almacen').value;
		var prov = eval('document.form0.codProv').value;
		var tDate = eval('document.form0.fechaini').value;
		var fDate = eval('document.form0.fechafin').value;
		if(almacen== ''|| prov =='') alert('Seleccione valores en almacen y proveedor');
		else abrir_ventana('../inventario/print_comparativo_consig_costo.jsp?almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate);
<%}else if(fg.trim().equals("RC")){%>
		var almacen = eval('document.form0.almacen').value;
		var prov = eval('document.form0.codProv').value;
		var tDate = eval('document.form0.fechaini').value;
		var fDate = eval('document.form0.fechafin').value;
		if(almacen== ''|| prov =='') alert('Seleccione valores en almacen y proveedor');
		else abrir_ventana('../inventario/print_comparativo_consig_costo.jsp?almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate);
	<%}%>
}

function showReporte3(value)
{
	var almacen = eval('document.form0.almacen').value;
	var prov    = eval('document.form0.codProv').value;
	var tDate   = eval('document.form0.fechaini').value;
	var fDate   = eval('document.form0.fechafin').value;
	var familyCode = eval('document.form0.familyCode').value;
	var classCode  = eval('document.form0.classCode').value;
	var subclase = '';if(eval('document.form0.subclassCode').value) subclase = eval('document.form0.subclassCode').value;
    var pCtrlHeader = document.getElementById("pCtrlHeader").checked;
    var articulo ="";if(eval('document.form0.codigo')) articulo = eval('document.form0.codigo').value;
 	var msg = '';
	//if(almacen == '')  msg = ' Almacen / Proveedor ';
	if (msg == '')
	{
		if(value=="1"){
           //if(!xtraOpt) abrir_ventana('../inventario/print_comparativo_consig.jsp?almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate+'&familyCode='+familyCode+'&classCode='+classCode+'&subclase='+subclase);
            abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_comparativo_consig.rptdesign&almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate+'&familyCode='+familyCode+'&classCode='+classCode+'&subclase='+subclase+'&pCtrlHeader='+pCtrlHeader+'&articulo='+articulo);
		}else if(value=="2"){
		
		if(almacen == ''||prov=='') alert('Seleccione Almacen / Proveedor ');
		else{
           //if(!xtraOpt) 
		   //abrir_ventana('../inventario/print_comparativo_consig_costo.jsp?almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate+'&familyCode='+familyCode+'&classCode='+classCode+'&subclase='+subclase);
             abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_comparativo_consig_costo.rptdesign&almacen='+almacen+'&prov='+prov+'&tDate='+tDate+'&fDate='+fDate+'&familyCode='+familyCode+'&classCode='+classCode+'&subclase='+subclase+'&pCtrlHeader='+pCtrlHeader+'&articulo='+articulo);
		   }
		   }
	}
	else alert('Seleccione '+msg);
}

function showReporte(value)
{
	var almacen    = eval('document.form0.almacen').value;
	var compania   = eval('document.form0.compania').value;
	var fecha_i    = eval('document.form0.fechaini').value;
	var fecha_f    = eval('document.form0.fechafin').value;
	var familyCode = eval('document.form0.familyCode').value;
	var classCode  = eval('document.form0.classCode').value;
	var proveedor  = eval('document.form0.codProv').value;
	var estado     = eval('document.form0.estado').value;
	var subclase = '';
	if(eval('document.form0.subclassCode').value) subclase = eval('document.form0.subclassCode').value;
	var msg = '';
	var fp ='';


if(fecha_i == "" && fecha_f == "") msg = ' Rango de Fecha ';

if(msg == '')
{
	if(value=="1")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=RDA&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="2")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=FG&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="3")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=FC&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="4")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=RDAN&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="5")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=FGN&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="6")abrir_ventana('../inventario/print_recepcion_articulos.jsp?fp=FCN&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);
	else if(value=="7")abrir_ventana('../inventario/print_recepcion_articulos_agrupados.jsp?fp=FC&compania='+compania+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&familyCode='+familyCode+'&classCode='+classCode+'&proveedor='+proveedor+'&subclase='+subclase+'&estado='+estado);


}
else alert('Seleccione '+msg);

}
function buscaArticulo()
{
	var msg ='';
 	var familia     = eval('document.form0.familyCode').value;
	var clase       = eval('document.form0.classCode').value;
	
 	 abrir_ventana('../common/search_articulo.jsp?id=9&fp=CONSIG&familia='+familia+'&clase='+clase);
 } 
function showReporteRecep(tipo)
{
    var almacen = eval('document.form0.almacen').value||'0';
	var prov    = eval('document.form0.codProv').value||'0';
	var compania   = eval('document.form0.compania').value;
	var tDate   = eval('document.form0.fechaini').value;
	var fDate   = eval('document.form0.fechafin').value;
	var familyCode = eval('document.form0.familyCode').value||'0';
	var classCode  = eval('document.form0.classCode').value||'0';
    var pCtrlHeader = document.getElementById("pCtrlHeader").checked;
    var articulo ="0";if(eval('document.form0.codigo')) articulo = eval('document.form0.codigo').value||'0';
	var estado     = eval('document.form0.estado').value;
	var subclase = '';
	if(eval('document.form0.subclassCode').value) subclase = eval('document.form0.subclassCode').value;
	var msg = '';
	var fp ='';


	if(tDate == "" && fDate == "") msg = ' Rango de Fecha ';

  if(tipo ==1){
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_recepciones_art_x_prov.rptdesign&pWh='+almacen+'&pVendor='+prov+'&tDate='+tDate+'&fDate='+fDate+'&gpFamily='+familyCode+'&gpClass='+classCode+'&pCtrlHeader='+pCtrlHeader+'&pCode='+articulo);} 
  else if(tipo ==2){
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_recepciones_x_prov.rptdesign&pWh='+almacen+'&pVendor='+prov+'&tDate='+tDate+'&fDate='+fDate+'&gpFamily='+familyCode+'&gpClass='+classCode+'&pCtrlHeader='+pCtrlHeader+'&pCode='+articulo);}
  else if (tipo ==3){
	if(msg == '') {
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_recepciones_orden_compra_fac_cred_contado.rptdesign&almacenParam='+almacen+'&pVendor='+prov+'&tDate='+tDate+'&fDate='+fDate+'&gpFamily='+familyCode+'&gpClass='+classCode+'&pCode='+articulo+'&pSubclase='+subclase+'&pEstado='+estado+'&pComp='+compania+'&fp=RDA');
	}
	else {
		alert('Seleccione '+msg);
	}
  }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("RR")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE RECEPCION DE ARTICULOS" />
</jsp:include>
<%}else if(fg.trim().equals("RLP")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE - LISTADO DE ARTICULO Y PRECIOS " />
</jsp:include>
<%}else if(fg.trim().equals("RCC")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE - COMPARATIVO MOVIMIENTO DE MATERIAL A CONSIGNACION" />
</jsp:include>
<%}else if(fg.trim().equals("RC")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE - COMPARATIVO MOVIMIENTO DE MATERIAL A CONSIGNACION/COSTOS" />
</jsp:include>
<%}%>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
		<%if(fg.trim().equals("RR") || fg.trim().equals("RLP")){%>
		<tr class="TextFilter">
		<td width="50%">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO, codigo||' - '||nombre FROM   tbl_sec_compania /*where codigo = "+(String) session.getAttribute("_companyId")+"*/ ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T');loadXML('../xml/itemFamily.xml','familyCode','"+familyCode+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"")%>
		</td>
		<td width="50%">
			Almacen
			<%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>
			</td>
	</tr>
	<tr class="TextFilter">
		<td>
			Familia
			<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals("A"))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>
			</td>
			<td>
			Clase
			<%=fb.select("classCode","","",false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/subclase.xml', "+(!fg.equals("RLP")?"'subclassCode'":"''")+",'','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form0.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
			</script>
      <%if (!fg.equals("RLP")){%>  
      Subclase: <%=fb.select("subclassCode","","",false,false,0,"text10",null,"")%>
      <script language="javascript">
    loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.form0.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.form0.classCode.value"%>','KEY_COL','T');
    </script><%}else{%>
    &nbsp;&nbsp;&nbsp;Estado:&nbsp;<%=fb.select("status","A=Activo,I=Inactivo","","S")%>
    <%}%>
		 </td>
		</tr>
        <%if (!fg.equals("RLP")){%>  
		<tr class="TextFilter">
			<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="" />
							<jsp:param name="nameOfTBox2" value="fechafin" />
							<jsp:param name="valueOfTBox2" value="" />
							</jsp:include></td>

		</tr>
		<tr class="TextFilter">
			<td colspan="2">Recep.:&nbsp;<%=fb.select("estado","R=RECIBIDAS,A=ANULADAS","R","T")%></td>
		</tr>
		<tr id="detail1"  class="TextFilter">
			<td colspan="2" align="center">Proveedor<%=fb.textBox("codProv","",false,false,false,5)%>
			 <%=fb.textBox("descProv","",false,false,true,30)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
			 <label class="pointer"><input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">Esconder Cabecera?</label>
			 </td>
		</tr>
		 
		<tr class="TextFilter">
			<td>&Aacute;rticulo</td>
			<td><%=fb.intBox("codigo","",false,false,false,10)%><%=fb.textBox("descArticulo","",false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%> </td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="2">Reportes Sin SubTotales</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>1 - Recepcion de Articulos  (Orden de compra,Factura Credito, Facturas Contado)
			<button type="button" class="excel-button" id="excel1" name="excel1" value="3" onclick="showReporteRecep('3')">[ Excel ]</button>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>2 - Recepcion de Articulos  (Por Consignación)
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>3 - Recepcion de Articulos  (Credito)
			</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2">Reportes Con SubTotales</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>4 - Recepcion de Articulos  (Orden de compra,Factura Credito, Facturas Contado)
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>5 - Recepcion de Articulos  (Por Consignación)
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>6 - Recepcion de Articulos  (Credito)
			</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2">Reportes Con Resumen</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>7 - Recepciones Agrupadas por Tipo
			</td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="2">Otros Reportes de Recepciones</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2">Recepcion de articulos por Proveedor			
            <%=fb.button("reporteX","Recepciones por Prov.",true,false,null,null,"onClick=\"javascript:showReporteRecep(1)\"")%>
			</td>
		</tr>
        <tr class="TextRow01">
			<td colspan="2">Recepcion de articulos			
            <%=fb.button("reporteX","Recepciones por articulos",true,false,null,null,"onClick=\"javascript:showReporteRecep(2)\"")%>
			</td>
		</tr>
		<%}}else if(fg.trim().equals("RCC") || fg.trim().equals("RC")){%>

	<tr class="TextFilter">
		<td width="10%">Almacen
		<td width="90%"><%=fb.select(ConMgr.getConnection(),"select distinct codigo_almacen, codigo_almacen||' - '||descripcion from   tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+" order by 1","almacen","",false,false,0,null,null,null,null,(fg.trim().equals("RCC"))?"S":"")%>
		</td>
	</tr>
	<tr class="TextFilter">
		<td>Familia</td>
		<td>
			<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals("A"))?compania:"document.form0.compania.value"%>','KEY_COL','T');
			</script>
			 &nbsp;&nbsp;&nbsp;
			Clase
			<%=fb.select("classCode","","",false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form0.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
			</script>&nbsp;&nbsp;&nbsp;
      Subclase: <%=fb.select("subclassCode","","",false,false,0,"text10",null,"")%>
      <script language="javascript">
    loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.form0.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.form0.classCode.value"%>','KEY_COL','T');
    </script>
		 </td>
		</tr>
	<tr class="TextFilter">
	<td>Fecha</td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="" />

							<jsp:param name="nameOfTBox2" value="fechafin" />
							<jsp:param name="valueOfTBox2" value="" />
							</jsp:include></td>

		</tr>
		<tr id="detail1"  class="TextFilter">
			<td>Proveedor</td>
			<td> <%=fb.textBox("codProv","",false,false,false,5)%>
			 <%=fb.textBox("descProv","",false,false,true,30)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
             &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">Esconder Cabecera?</label>
             </td>
		</tr>
		<tr class="TextFilter">
			<td>&Aacute;rticulo</td>
			<td><%=fb.intBox("codigo","",false,false,false,10)%><%=fb.textBox("descArticulo","",false,false,true,60)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%> </td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="2">Reportes Consignacion por Proveedor</p></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%//=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte3(this.value)\"")%>1 - Comparativo Cantidad&nbsp;&nbsp;&nbsp;<a href="javascript:showReporte3(1,1)" class="Link00Bold">Excel</a>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><%//=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte3(this.value,'')\"")%>2 - Comparativo Cantidad y Costo&nbsp;&nbsp;&nbsp;<!----><a href="javascript:showReporte3(2,2)" class="Link00Bold">Excel</a>
			</td>
		</tr>
	
		<%}else{%>
		<tr class="TextFilter">
		<td align="center">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO, codigo||' - '||nombre FROM   tbl_sec_compania /*where codigo = "+(String) session.getAttribute("_companyId")+"*/ ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"")%>		</td>
		</tr>
		<tr class="TextFilter">
			<td align="center"><%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte2()\"")%></td>
		</tr>
		<%}%>
        <%if (fg.equals("RLP")){%>
           <tr class="TextFilter">
			<td align="center" colspan="2">
            <%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte2()\"")%>
            &nbsp;&nbsp;&nbsp;
            <%=fb.button("reporteX","Excel",true,false,null,null,"onClick=\"javascript:showReporte2(2)\"")%></td>
		   </tr>
		<%}%>
		</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
