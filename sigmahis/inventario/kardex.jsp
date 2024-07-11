<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
CommonDataObject cdoP = new CommonDataObject();

String mode = request.getParameter("mode");
String id = request.getParameter("id");
int anio = 2010;//Integer.parseInt(request.getParameter("anio"));
int prevAnio = anio -1;
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String art_familia = "";
String art_clase = "";
String cod_articulo = "";
String descripcion = "";
String almacen = "";
String fDate = "";
String tDate = "",consignacion="",estado="";
String ver_art_sin_mov = "S";
String barcode = "", barcodeToPrint="", barcodeToRpt="";
if(request.getParameter("art_familia")!=null) art_familia = request.getParameter("art_familia");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
if(request.getParameter("consignacion")!=null) consignacion = request.getParameter("consignacion");
if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
if(request.getParameter("ver_art_sin_mov")!=null) ver_art_sin_mov = request.getParameter("ver_art_sin_mov");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
	String runQuery = "N";
	
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'INV_FLIA_USA_KARDEX'),'TRX') as flia_kardex from dual");
	cdoP = SQLMgr.getData(sbSql.toString());
	if (cdoP == null){
		cdoP = new CommonDataObject();
		cdoP.addColValue("flia_kardex","TRX"); 
	}
	
	CommonDataObject _cdo = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");
	if(fDate.equals("")) fDate=_cdo.getColValue("fecha_ini");
	if(tDate.equals("")) tDate=_cdo.getColValue("fecha_fin");

	sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo_almacen, a.cod_familia, a.cod_clase,");
	
	
	
	sbSql.append(" a.cod_articulo, a.descripcion, a.saldo_inicial + qty_prev saldo_inicial, a.qty_in, a.qty_out, a.qty_aju, (a.saldo_inicial + a.qty_prev + a.qty_in - a.qty_out + a.qty_aju) saldo, (select descripcion from tbl_inv_almacen ia where ia.compania = a.compania and ia.codigo_almacen = a.codigo_almacen) almacen_desc from (select compania, codigo_almacen,");
	if(cdoP.getColValue("flia_kardex","TRX").equalsIgnoreCase("TRX") )sbSql.append(" a.cod_familia, a.cod_clase,");
	else sbSql.append(" a.flia_art as cod_familia, a.clase_art as cod_clase,");
	
	 sbSql.append(" cod_articulo, descripcion, saldo_inicial, sum(case when trunc(fecha_docto) < to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_in - qty_out + qty_aju else 0 end) qty_prev, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_in else 0 end) qty_in, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_out else 0 end) qty_out, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_aju else 0 end) qty_aju from vw_inv_mov_item a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId")); 
	if (!consignacion.equals("")){
		sbSql.append(" and a.consignacion = '");
		sbSql.append(consignacion); 
		sbSql.append("'"); 
	}
	sbSql.append(" group by compania, codigo_almacen,cod_articulo, descripcion, saldo_inicial,");	
	if(cdoP.getColValue("flia_kardex","TRX").equalsIgnoreCase("TRX") )sbSql.append(" a.cod_familia, a.cod_clase");
	else sbSql.append(" a.flia_art, a.clase_art");
	
	
	sbSql.append(" ) a where a.compania = ");

	sbSql.append((String) session.getAttribute("_companyId"));
	if (!estado.equals("")){
sbSql.append(" AND EXISTS (select 1  from  tbl_inv_articulo TIA where TIA.COMPANIA   = A.COMPANIA  AND TIA.COD_FLIA     = A.COD_FAMILIA AND TIA.COD_CLASE    = A.COD_CLASE  AND TIA.COD_ARTICULO = A.COD_ARTICULO AND TIA.ESTADO       = '");
    sbSql.append(estado);
    sbSql.append("')");}

	if (!art_familia.equals("")){
		sbSql.append(" and a.cod_familia = "); 
		sbSql.append(art_familia);
		runQuery = "Y";
	}


	if (!art_clase.equals("")){
		 sbSql.append(" and a.cod_clase = "); 
		sbSql.append(art_clase);
		runQuery = "Y";
	}
	if (!cod_articulo.equals("")){
		sbSql.append(" and a.cod_articulo = ");
		sbSql.append(cod_articulo);
		runQuery = "Y";
	}
	if (!descripcion.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(descripcion.toUpperCase());
		sbSql.append("%'");
		runQuery = "Y";
	}
	if (!almacen.equals("")){
		sbSql.append(" and a.codigo_almacen = ");
		sbSql.append(almacen);
		runQuery = "Y";
	}
	if(ver_art_sin_mov.equals("S")){
		sbSql.append(" and ( saldo_inicial + qty_prev != 0 or qty_in != 0 or qty_aju != 0 or qty_out != 0)");
	}
	if (request.getParameter("barcode") != null && !request.getParameter("barcode").equals(""))
	{
		barcode = request.getParameter("barcode");
		if (crypt) {
			try{barcode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		sbSql.append(" and exists (select null from tbl_inv_articulo ar where ar.compania = a.compania and ar.cod_articulo = a.cod_articulo and ar.tipo !='A' and ar.cod_barra = '");
		sbSql.append(IBIZEscapeChars.forSingleQuots(barcode).trim());
		sbSql.append("')");
		barcodeToPrint=barcode;
		barcodeToRpt=IBIZEscapeChars.forSingleQuots(barcode).trim();
		barcode = "";
		runQuery = "Y";
	}

	sbSql.append(" order by a.codigo_almacen, a.descripcion");
	System.out.println("Inventario Kardex:>>>>>>>>>>>>>>>>>"+sbSql.toString());
	if(runQuery.equals("Y")){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	
	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sbSql.toString()+")");
	}
  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  if(rowCount==0) pVal=0;
  else pVal=preVal;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
</script>
<script language="javascript">

function showMov(id, tipo, almacen){
	abrir_ventana('../inventario/kardex_item.jsp?almacen='+almacen+'&cod_articulo='+id+'&tipo_mov='+tipo+'&fDate=<%=fDate%>&tDate=<%=tDate%>&flia_kardex=<%=cdoP.getColValue("flia_kardex","TRX")%>');
}

function print(){
	abrir_ventana("../inventario/print_kardex.jsp?art_familia=<%=art_familia%>&art_clase=<%=art_clase%>&cod_articulo=<%=cod_articulo%>&descripcion=<%=descripcion.toUpperCase()%>&almacen=<%=almacen%>&fDate=<%=fDate%>&tDate=<%=tDate%>&consignacion=<%=consignacion%>&flia_kardex=<%=cdoP.getColValue("flia_kardex","TRX")%>&ver_art_sin_mov=<%=ver_art_sin_mov%>&barcode=<%=barcodeToPrint%>");
}
function printExcel(){
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
	var almacen 		= document.search01.almacen.value;
	var cod_articulo 			= document.search01.cod_articulo.value;
	
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/kardex_res.rptdesign&pAlmacen='+almacen+'&pArticulo='+cod_articulo+'&fechaDesde='+fDate+'&fechaHasta='+tDate+'&pFlia=<%=art_familia%>&pClase=<%=art_clase%>&pDescripcion=<%=descripcion.toUpperCase()%>&pConsignacion=<%=consignacion%>&pFlia_kardex=<%=cdoP.getColValue("flia_kardex","TRX")%>&ver_art_sin_mov=<%=ver_art_sin_mov%>&pEstado=<%=estado%>&barcode=<%=barcodeToRpt%>');

}
function doAction(){document.search01.barcode.focus();}
function Search(){
	document.getElementById('loading').classList.remove('Dp');
	document.getElementById("search01").submit();
}
function NxtPrev(v_form){
	document.getElementById('loading').classList.remove('Dp');
	document.getElementById(v_form).submit();
}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search01"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value=""></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
		<jsp:param name="substrType" value="01"></jsp:param>
</jsp:include>
	<style>
		#loading {
			width: 100%;
			height: 100%;
			top: 0px;
			left: 0px;
			position: fixed;
			opacity: 0.7;
			background-color: #fff;
			z-index: 99;
			text-align: center;
		}
		.Dp{
			display: none;
		}
		#loading-image {
			top: 100%;
			left: 240px;
			z-index: 100;
		}
	</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
	<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
	<div id="loading" class="Dp">
		<img id="loading-image" src="../images/loading.gif" alt="Loading..." />
	</div>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;<a href="javascript:print()">[ Imprimir ]</a>&nbsp;&nbsp;&nbsp;<a href="javascript:printExcel()">[ Imprimir Excel ]</a></td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
				<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
			<tr class="TextFilter">
				<td colspan="8">
        	Almac&eacute;n:
          <%=fb.select(ConMgr.getConnection(),"SELECT codigo_almacen, codigo_almacen ||'-'||descripcion descripcion FROM TBL_INV_ALMACEN a WHERE compania = "+session.getAttribute("_companyId") +" ORDER BY descripcion","almacen",almacen,false,false,0,"text10",null,"","","S")%> 
				</td>
			</tr>
			<tr class="TextFilter">
				<td>
					Familia<br>
					<%=fb.intBox("art_familia",art_familia,false,false,false,5,10,"Text10","","")%>
        </td>
				<td>
					Clase<br>
					<%=fb.intBox("art_clase",art_clase,false,false,false,5,10,"Text10","","")%>
          </td>
				<td>
					Art&iacute;culo<br>
					<%=fb.intBox("cod_articulo",cod_articulo,false,false,false,10,10,"Text10","","")%>
          </td>
				<td>
					Descripci&oacute;n<br>
					<%=fb.textBox("descripcion",descripcion,false,false,false,25,100,"Text10","","")%>
					</td>
					<td>
				Estado<br>
		<%=fb.select("estado","A=ACTIVOS,I=INACTIVOS",estado,false,false,0,"T")%>
					</td>
				<td>
				Consignaci&oacute;n<br>
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
					</td>
					<td>
				Excluir Art. Sin Mov.?<br>
		<%=fb.select("ver_art_sin_mov","S=SI,N=NO",ver_art_sin_mov,false,false,0,"")%>
					</td>
					<td>
				C&oacute;d Barra<br>
		<%=fb.textBox("barcode",barcode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
					</td>
				<td>
					Fecha:<br>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fDate" />
					<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
					<jsp:param name="nameOfTBox2" value="tDate" />
					<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
					</jsp:include>
					<%=fb.button("go","ir",true,false,null,null,"onClick=\"javascript:Search()\"")%>
					
				</td>
			</tr>
				<%=fb.formEnd()%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
		<%=fb.hidden("consignacion",consignacion)%>
		<%=fb.hidden("estado",estado)%>
<%=fb.hidden("ver_art_sin_mov",ver_art_sin_mov)%>
<%=fb.hidden("barcode",barcode)%>

				<td width="10%"><%=(preVal != 1)?fb.button("previous","<<-",true,false,null,null,"onClick=\"javascript:NxtPrev(this.form.name)\""):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
		<%=fb.hidden("consignacion",consignacion)%>
		<%=fb.hidden("estado",estado)%>
<%=fb.hidden("ver_art_sin_mov",ver_art_sin_mov)%>
<%=fb.hidden("barcode",barcode)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.button("next","->>",true,false,null,null,"onClick=\"javascript:NxtPrev(this.form.name)\""):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("articles","","post","");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
<tr>
	<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">	
			<tr class="TextHeader">
				<td width="12%" align="center" rowspan="2">Almac&eacute;n</td>
				<td width="18%" align="center" colspan="3">C&oacute;digo</td>
				<td width="25%" align="center" rowspan="2">Descripci&oacute;n</td>
				<td width="9%" align="center" rowspan="2">Saldo Ini.</td>
				<td width="9%" align="center" rowspan="2">Cant. Entrada</td>
				<td width="9%" align="center" rowspan="2">Cant. Salida</td>
				<td width="9%" align="center" rowspan="2">Cant. Ajuste</td>
				<td width="9%" align="center" rowspan="2">Saldo</td>
			</tr>
			<tr class="TextHeader">
				<td width="6%" align="center">Familia</td>
				<td width="6%" align="center">Clase</td>
				<td width="6%" align="center">Art&iacute;culo</td>
			</tr>
<%
String flg = "S";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
      <td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("cod_familia")%></td>
			<td align="center"><%=cdo.getColValue("cod_clase")%></td>
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("saldo_inicial")%></td>
			<td align="center" <%if(!cdo.getColValue("qty_in").equals("0")){%> onClick="javascript:showMov(<%=cdo.getColValue("cod_articulo")%>, 'in', <%=cdo.getColValue("codigo_almacen")%>)" class="RedTextBold" style="cursor:pointer"<%}%>>
			 <%if(!cdo.getColValue("qty_in").equals("0")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%><%=cdo.getColValue("qty_in")%> <%if(!cdo.getColValue("qty_in").equals("0")){%>&nbsp;&nbsp;</label></label><%}%>
			</td>
			<td align="center" <%if(!cdo.getColValue("qty_out").equals("0")){%> onClick="javascript:showMov(<%=cdo.getColValue("cod_articulo")%>, 'out', <%=cdo.getColValue("codigo_almacen")%>)" class="RedTextBold" style="cursor:pointer"<%}%>>
			<%if(!cdo.getColValue("qty_out").equals("0")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%><%=cdo.getColValue("qty_out")%><%if(!cdo.getColValue("qty_out").equals("0")){%>&nbsp;&nbsp;</label></label><%}%>
			</td>
			<td align="center" <%if(!cdo.getColValue("qty_aju").equals("0")){%> onClick="javascript:showMov(<%=cdo.getColValue("cod_articulo")%>, 'aju', <%=cdo.getColValue("codigo_almacen")%>)" class="RedTextBold" style="cursor:pointer"<%}%>>
			
			<%if(!cdo.getColValue("qty_aju").equals("0")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
			<%=cdo.getColValue("qty_aju")%>
			<%if(!cdo.getColValue("qty_aju").equals("0")){%>&nbsp;&nbsp;</label></label><%}%>
			
			</td>
			<td align="center" onClick="javascript:showMov(<%=cdo.getColValue("cod_articulo")%>, '', <%=cdo.getColValue("codigo_almacen")%>)" class="RedTextBold" style="cursor:pointer"><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%=cdo.getColValue("saldo")%>&nbsp;&nbsp;</label></label></td>
		</tr>
	<%
}
if(al.size()==0){
%>
		<tr><td align="center" colspan="11">No registros encontrados.</td></tr>
<%}%>	
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
		<%=fb.hidden("consignacion",consignacion)%>
		<%=fb.hidden("estado",estado)%>
<%=fb.hidden("ver_art_sin_mov",ver_art_sin_mov)%>
<%=fb.hidden("barcode",barcode)%>
				<td width="10%"><%=(preVal != 1)?fb.button("previous","<<-",true,false,null,null,"onClick=\"javascript:NxtPrev(this.form.name)\""):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("anio",""+anio)%>
				<%=fb.hidden("fp",""+fp)%>
        <%=fb.hidden("art_familia",art_familia)%>
        <%=fb.hidden("art_clase",art_clase)%>
        <%=fb.hidden("cod_articulo",cod_articulo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("almacen",almacen)%>
        <%=fb.hidden("fDate",fDate)%>
        <%=fb.hidden("tDate",tDate)%>
		<%=fb.hidden("consignacion",consignacion)%>
		<%=fb.hidden("estado",estado)%>
<%=fb.hidden("ver_art_sin_mov",ver_art_sin_mov)%>
<%=fb.hidden("barcode",barcode)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.button("next","->>",true,false,null,null,"onClick=\"javascript:NxtPrev(this.form.name)\""):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
