<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetCargoCliente"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranCargQ" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargQKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargA" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargAKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
XML.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
CommonDataObject cdoP = new CommonDataObject();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String inv_almacen = "", tipo_servicio = "", sqlInv = "", sqlTS = "", tipo_detalle = "";

String codCita	= request.getParameter("codCita");
String fechaCita	= request.getParameter("fechaCita");
String fck = "";
String secuencia = request.getParameter("secuencia");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String habitacion = request.getParameter("habitacion");
String estadoCita = request.getParameter("estadoCita");

String flia = request.getParameter("flia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String tipoTrx = request.getParameter("tipoTrx");
String horaEntrada = request.getParameter("horaEntrada");
String horaSalida= request.getParameter("horaSalida");
String addArt = request.getParameter("addArt");

if(tipoTrx==null) tipoTrx = "";
if(horaEntrada==null) horaEntrada = "";
if(horaSalida==null) horaSalida = "";
if(addArt==null) addArt = "";

if (fg == null) fg = "xxx";

if(fg.equals("yyy")){
	sqlInv = "select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion";
	sqlTS = "select codigo, descripcion from tbl_cds_tipo_servicio where codigo /* in ('02','03','04','08','30') and*/ compania = "+(String) session.getAttribute("_companyId")+" order by descripcion";
	CommonDataObject cdoI = SQLMgr.getData(sqlInv);
	CommonDataObject cdoTS = SQLMgr.getData(sqlTS);
	inv_almacen = cdoI.getColValue("codigo_almacen");
	tipo_servicio = cdoTS.getColValue("codigo");
}
if(request.getParameter("inv_almacen")!=null) inv_almacen = request.getParameter("inv_almacen");
if(request.getParameter("tipo_servicio")!=null) tipo_servicio = request.getParameter("tipo_servicio");
if(request.getParameter("tipo_detalle")!=null) tipo_detalle = request.getParameter("tipo_detalle");
else if(fg.equals("yyy")) tipo_detalle = "O";

if (codCita == null) codCita = "";
if(inv_almacen.equals("")){
	String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");
	inv_almacen = almacenSOP;
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select param_value valida_dsp from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name = 'CHECK_DISP' ";
	cdoP = SQLMgr.getData(sql);
	if(cdoP ==null){cdoP =new CommonDataObject();cdoP.addColValue("valida_dsp","S");}

  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("cod_articulo") != null && !request.getParameter("cod_articulo").trim().equals("")){
    appendFilter += " and a.cod_articulo = "+request.getParameter("cod_articulo");
    searchOn = "a.codigo";
    searchVal = request.getParameter("cod_articulo");
    searchType = "2";
    searchDisp = "Codigo";
  }
  if (request.getParameter("art_familia") != null && !request.getParameter("art_familia").equals("")){
    appendFilter += " and a.cod_flia = "+request.getParameter("art_familia");
  }
  if (request.getParameter("art_clase") != null && !request.getParameter("art_clase").equals("")){
    appendFilter += " and a.cod_clase = "+request.getParameter("art_clase");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals("")){
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
  }

	//al = SQLMgr.getDataList(sql);

	sql = "";
	int x = 0;
	if(tipoTrx.equals("A")){
		sql = "select i.disponible, a.descripcion, a.cod_medida, a.cod_articulo, a.cod_flia as art_familia, a.cod_clase as art_clase, i.precio,nvl(a.other3,'Y')afecta_inv ,0 entrega from tbl_inv_inventario i, tbl_inv_articulo a where a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and a.venta_sino = 'S' and i.codigo_almacen = "+inv_almacen+" and i.cod_articulo =" + articulo;
	} else if(tipoTrx.equals("D")){
		sql = "select i.disponible,a.descripcion, a.cod_medida,a.cod_articulo,a.cod_flia as art_familia, a.cod_clase as art_clase, i.precio,nvl(a.other3,'Y')afecta_inv,(select  (nvl(det.entrega, 0) + nvl(det.adicion, 0) - nvl(det.devolucion, 0)) from tbl_cdc_solicitud_det det where det.cod_articulo=i.cod_articulo and cita_codigo = "+ codCita +" and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+ fechaCita +"', 'dd/mm/yyyy') and secuencia = " + secuencia + " ) as entrega from tbl_inv_inventario i, tbl_inv_articulo a where a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and a.venta_sino = 'S' and i.codigo_almacen = "+inv_almacen+" and exists (select null from tbl_cdc_solicitud_det det where det.cod_articulo=i.cod_articulo and cita_codigo = "+ codCita +" and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+ fechaCita +"', 'dd/mm/yyyy') and secuencia = " + secuencia + " )"+appendFilter+"  and i.cod_articulo =" + articulo+" order by a.descripcion";
	} else {
		sql = "select i.disponible,a.descripcion, a.cod_medida,a.cod_articulo,a.cod_flia as art_familia, a.cod_clase as art_clase, i.precio,nvl(a.other3,'Y')afecta_inv, 0 entrega from tbl_inv_inventario i, tbl_inv_articulo a where a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and a.venta_sino = 'S' and i.codigo_almacen = "+inv_almacen+" and not exists (select null from tbl_cdc_solicitud_det det where det.cod_articulo=i.cod_articulo and cita_codigo = "+ codCita +" and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+ fechaCita +"', 'dd/mm/yyyy') and secuencia = " + secuencia + ")"+appendFilter+" order by a.descripcion";
	}


	if(!sql.equals("")){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a order by descripcion) where rn between "+previousVal+" and "+nextVal);
		if(!tipoTrx.equals("A") && !tipoTrx.equals("D"))rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
<script language="javascript">
document.title = 'Agregar articulos - '+document.title;
function chkValues(){var size = parseInt(document.detail.keySize.value);for(i=0;i<size;i++){chkValue(i);}return true;}
function chkValue(i){
	<%if(!tipoTrx.equals("D")){%>
	var art_flia 				= eval('document.detail.art_familia'+i).value;
	var art_clase 			= eval('document.detail.art_clase'+i).value;
	var cod_art 				= eval('document.detail.cod_articulo'+i).value;
	var cantidad 				= parseInt(eval('document.detail.cantidad'+i).value);
	var afecta_inv 				= eval('document.detail.afecta_inv'+i).value;
	var cia							= '<%=session.getAttribute("_companyId")%>';
	var almacen					= '<%=inv_almacen%>';
	<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>
	if(afecta_inv=='Y'){
	var disponible = getInvDisponible('<%=request.getContextPath()%>', cia, almacen, art_flia, art_clase, cod_art);
	if(disponible <= 0){
		alert('No hay disponibilidad para este artículo');
		//eval('document.detail.cantidad'+i).value = 0;
		//eval('document.detail.chkServ'+i).checked = false;
	} else if(cantidad <= disponible){
		setChecked(eval('document.detail.cantidad'+i), eval('document.detail.chkServ'+i));
	} else{
		alert('La cantidad introducida supera la disponible');
		if(confirm('Desea agregar el articulo sin disponibilidad')){}else{
		eval('document.detail.cantidad'+i).value = 0;}
	}}
	<%}}else{%>
		 	
		
	var cantidad = parseInt(eval('document.detail.cantidad'+i).value);
	var entrega = parseInt(eval('document.detail.entrega'+i).value); 
	if(isNaN(cantidad)) cantidad = 0;
	if(isNaN(entrega)) entrega = 0;
	if(cantidad <= entrega) {
	
			if(cantidad!="0"&&cantidad!="")setChecked(eval('document.detail.cantidad'+i), eval('document.detail.chkServ'+i));
			}else {top.CBMSG.error('La Cantidad a devolver es mayor a lo utilizado..,VERIFIQUE...'); eval('document.detail.cantidad'+i).value="0";}

	<%}%>
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<% if(addArt.trim().equals("S")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE OTROS CARGOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("codCita",codCita)%>
        <%=fb.hidden("fechaCita",fechaCita)%>
        <%=fb.hidden("secuencia",secuencia)%>
        <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
        <%=fb.hidden("habitacion",habitacion)%>
        <%=fb.hidden("estadoCita",estadoCita)%>
        <%=fb.hidden("tipoTrx",tipoTrx)%>
		<%=fb.hidden("horaEntrada",horaEntrada)%>
		<%=fb.hidden("horaSalida",horaSalida)%>
		<%=fb.hidden("addArt",addArt)%>
				<td>
					<cellbytelabel>Art&iacute;culo</cellbytelabel>
          <%=fb.textBox("art_familia","",false,false,false,8)%>
          <%=fb.textBox("art_clase","",false,false,false,8)%>
					<%=fb.textBox("cod_articulo","",false,false,false,8)%>
          &nbsp;
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,26)%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>


<%}%>


<% if (fp.equals("cargo_dev_so") && (tipoSolicitud.equals("Q")||tipoSolicitud.equals("A")) && addArt.trim().equals("")) {//AGREGAR O DEVOLVER %>
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("detail",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document.form1.baction.value=='Guardar'&&!useOtherPrice())error++;");%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("habitacion",habitacion)%>
<%=fb.hidden("estadoCita",estadoCita)%>
<%=fb.hidden("tipoTrx",tipoTrx)%>
<%=fb.hidden("horaEntrada",horaEntrada)%>
<%=fb.hidden("horaSalida",horaSalida)%>
<%=fb.hidden("addArt",addArt)%>
<tr class="TextHeader" align="center">
	<td width="15%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="33%" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="10%" rowspan="2"><cellbytelabel>Unidad Medida</cellbytelabel></td>
	<td width="10%" rowspan="2"><cellbytelabel>Cantidad Solicitada</cellbytelabel></td>
	<td width="3%" rowspan="2">&nbsp;</td>
	<%if(tipoTrx.equals("")){%>
	<td width="10%" rowspan="2"><cellbytelabel>Incl. Pqte?</cellbytelabel></td>
	<td width="10%" rowspan="2"><cellbytelabel>Cant. paquete</cellbytelabel></td>
	<%}%>
</tr>
<tr class="TextHeader" align="center">
	<td><cellbytelabel>Flia</cellbytelabel>.</td>
	<td><cellbytelabel>Clase</cellbytelabel></td>
	<td><cellbytelabel>Cod</cellbytelabel>.</td>
</tr>
<%
String onCheck = "";System.out.println("********************* SEL ARTICULO DE SOP ********************* tipoTrx ==="+tipoTrx);
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
<%=fb.hidden("art_familia"+i,cdo.getColValue("art_familia"))%>
<%=fb.hidden("art_clase"+i,cdo.getColValue("art_clase"))%>
<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("cod_medida"+i,cdo.getColValue("cod_medida"))%>
<%=fb.hidden("afecta_inv"+i,cdo.getColValue("afecta_inv"))%>
<%=fb.hidden("entrega"+i,cdo.getColValue("entrega"))%>
<%=fb.hidden("chkServ"+i,""+i)%>
<%
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = "";
	
	cargoKey = tipoSolicitud+"_"+cdo.getColValue("cod_articulo");
	String str_disponible = "Disponible="+cdo.getColValue("disponible");
	if(fp.equals("cargo_dev_so")) str_disponible = "";
	if(fTranCargQKey.containsKey(cargoKey)) key = (String) fTranCargQKey.get(cargoKey);
%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
	<td align="center"><%=cdo.getColValue("art_familia")%></td>
	<td align="center"><%=cdo.getColValue("art_clase")%></td>
	<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
	<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
	<td align="center">&nbsp;<%=cdo.getColValue("cod_medida")%></td>
	<td align="center"><%=fb.intBox("cantidad"+i,"0",true,false,false,3, 4, "", "", "onChange=\"javascript:chkValue("+i+")\"", str_disponible, false)%></td>
	<td align="center">&nbsp;</td>
	<%if(tipoTrx.equals("")){%>
	<td align="center"><%=fb.checkbox("chkPqt"+i,""+i,false, false, "", "", onCheck)%></td>
	<td align="right"><%=fb.intBox("cantidad_paquete"+i,"0",true,false,false,3)%></td>
	<%}%>
</tr>
<% } %>
<tr>
	<td align="right" colspan="9" class="TextHeader"><%=fb.submit("add",(tipoTrx.equals("A"))?"Agregar":"Devolver")%>&nbsp;</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
</table>
<% } else { %>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codCita",codCita)%>
			<%=fb.hidden("fechaCita",fechaCita)%>
		    <%=fb.hidden("secuencia",secuencia)%>
		    <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
		    <%=fb.hidden("habitacion",habitacion)%>
		    <%=fb.hidden("estadoCita",estadoCita)%>
		    <%=fb.hidden("tipoTrx",tipoTrx)%>
		    <%=fb.hidden("horaEntrada",horaEntrada)%>
		    <%=fb.hidden("horaSalida",horaSalida)%>
		    <%=fb.hidden("addArt",addArt)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codCita",codCita)%>
			<%=fb.hidden("fechaCita",fechaCita)%>
            <%=fb.hidden("secuencia",secuencia)%>
            <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
            <%=fb.hidden("habitacion",habitacion)%>
            <%=fb.hidden("estadoCita",estadoCita)%>
            <%=fb.hidden("tipoTrx",tipoTrx)%>
		    <%=fb.hidden("horaEntrada",horaEntrada)%>
		    <%=fb.hidden("horaSalida",horaSalida)%>
		    <%=fb.hidden("addArt",addArt)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String onSubmit = "";
fb = new FormBean("detail","","post",onSubmit);
%>
	<%=fb.formStart()%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("codCita",codCita)%>
	<%=fb.hidden("fechaCita",fechaCita)%>
  <%=fb.hidden("secuencia",secuencia)%>
  <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
  <%=fb.hidden("habitacion",habitacion)%>
  <%=fb.hidden("estadoCita",estadoCita)%>
  <%=fb.hidden("tipoTrx",tipoTrx)%>
  <%=fb.hidden("horaEntrada",horaEntrada)%>
  <%=fb.hidden("horaSalida",horaSalida)%>
  <%=fb.hidden("addArt",addArt)%>
	<%
	if(tipoSolicitud.equals("A")||tipoSolicitud.equals("Q")){
	%>
      <tr>
        <td align="right" colspan="<%=(tipoSolicitud.equals("Q")?"9":"7")%>"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
	  <tr class="TextHeader" align="center">
        <td width="15%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
        <td width="33%" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
        <td width="10%" rowspan="2"><cellbytelabel>Unidad Medida</cellbytelabel></td>
        <td width="10%" rowspan="2"><cellbytelabel>Cantidad Solicitada</cellbytelabel></td>
        <td width="3%" rowspan="2">&nbsp;</td>
      
	  <%if(tipoTrx.equals("")&&tipoSolicitud.equals("Q")){%>
          <td width="10%" rowspan="2"><cellbytelabel>Incl. Pqte?</cellbytelabel></td>
		  <td width="10%" rowspan="2"><cellbytelabel>Cant. paquete</cellbytelabel></td>
          <%}%>
		 
	  </tr>	  
      <tr class="TextHeader" align="center">
        <td><cellbytelabel>Flia</cellbytelabel>.</td>
        <td><cellbytelabel>Clase</cellbytelabel></td>
        <td><cellbytelabel>Cod</cellbytelabel>.</td>
      </tr>
	<%}%>
       
<%
String onCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if(tipoSolicitud.equals("Q") || tipoSolicitud.equals("A")) onCheck = "onClick=\"javascript:chkValue("+i+");\"";

	%>
  <%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
  <%=fb.hidden("art_familia"+i,cdo.getColValue("art_familia"))%>
  <%=fb.hidden("art_clase"+i,cdo.getColValue("art_clase"))%>
  <%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
  <%=fb.hidden("cod_medida"+i,cdo.getColValue("cod_medida"))%>
  <%=fb.hidden("afecta_inv"+i,cdo.getColValue("afecta_inv"))%>

	<%

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = "";
	cargoKey = tipoSolicitud+"_"+cdo.getColValue("cod_articulo");
	String str_disponible = "Disponible="+cdo.getColValue("disponible");
	if(fp.equals("cargo_dev_so")) str_disponible = "";
	if(tipoSolicitud.equals("Q")){
		if(fTranCargQKey.containsKey(cargoKey)) key = (String) fTranCargQKey.get(cargoKey);
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("art_familia")%></td>
            <td align="center"><%=cdo.getColValue("art_clase")%></td>
            <td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="center">&nbsp;<%=cdo.getColValue("cod_medida")%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,"0",true,false,false,3, 4, "", "", "onChange=\"javascript:chkValue("+i+")\"", str_disponible, false)%></td>
			<td align="center">
      <%if (fTranCargQKey.containsKey(cargoKey) && !tipoTrx.equals("A") && !tipoTrx.equals("D")){%>
      elegido
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
      </td>
			<%if(tipoTrx.equals("")){%>
			<td align="center"><%=fb.checkbox("chkPqt"+i,""+i,false, false, "", "", onCheck)%></td>
			<td align="right"><%=fb.intBox("cantidad_paquete"+i,"0",true,false,false,3)%></td>
      <%}%>
		</tr>
	<%
	} else if(tipoSolicitud.equals("A")){
	%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("art_familia")%></td>
      		<td align="center"><%=cdo.getColValue("art_clase")%></td>
      		<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td>&nbsp;<%=cdo.getColValue("cod_medida")%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,"0",true,false,false,3,null,null,"onChange=\"javascript:chkValue("+i+"); setChecked(this,document.detail.chkServ"+i+")\"")%></td>
			<td align="center">
      <%if (fTranCargAKey.containsKey(key) && !tipoTrx.equals("A") && !tipoTrx.equals("D")){%>
      elegido
      <%} else {%>
      <%=fb.checkbox("chkServ"+i,""+i,false, false, "", "", onCheck)%>
      <%}%>
      </td>
		</tr>
  <%
	}
}
if(al.size()==0){
%>
		<tr align="center">
			<td colspan="6"><cellbytelabel>No Existen Registros</cellbytelabel></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
          <%=fb.hidden("secuencia",secuencia)%>
          <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
          <%=fb.hidden("habitacion",habitacion)%>
          <%=fb.hidden("estadoCita",estadoCita)%>
          <%=fb.hidden("tipoTrx",tipoTrx)%>
		  <%=fb.hidden("horaEntrada",horaEntrada)%>
		  <%=fb.hidden("horaSalida",horaSalida)%>
		  <%=fb.hidden("addArt",addArt)%>
		  
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
          <%=fb.hidden("secuencia",secuencia)%>
          <%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
          <%=fb.hidden("habitacion",habitacion)%>
          <%=fb.hidden("estadoCita",estadoCita)%>
          <%=fb.hidden("tipoTrx",tipoTrx)%>
		  <%=fb.hidden("horaEntrada",horaEntrada)%>
		  <%=fb.hidden("horaSalida",horaSalida)%>
		  <%=fb.hidden("addArt",addArt)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
<% } %>
</body>
</html>
<%
}
else
{
	System.out.println("=====================POST=====================");
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	ArrayList trx = new ArrayList();
	if(fg.equals("xxx") || fg.equals("yyy")){
	} else if(fg.equals("zzz")){
		int lineNo = CdcSol.getCdcSolicitudDetail().size();
		for(int i=0;i<keySize;i++){

			CdcSolicitudDet det = new CdcSolicitudDet();

			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setPrecio(request.getParameter("precio"+i));
			det.setCantidad("1");
			det.setAfectaInv(request.getParameter("afecta_inv"+i));

			if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));
			if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));
			if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));
			if(request.getParameter("disponible"+i)!=null && !request.getParameter("disponible"+i).equals("null") && !request.getParameter("disponible"+i).equals("")) det.setDisponible(request.getParameter("disponible"+i));
			if(request.getParameter("cod_medida"+i)!=null && !request.getParameter("cod_medida"+i).equals("null") && !request.getParameter("cod_medida"+i).equals("")) det.setUnidad(request.getParameter("cod_medida"+i));
			if(request.getParameter("chkPqt"+i)!=null && !request.getParameter("chkPqt"+i).equals("null") && !request.getParameter("chkPqt"+i).equals("")) det.setPaquete("S");
			else det.setPaquete("N");
			if(request.getParameter("cantidad_paquete"+i)!=null && !request.getParameter("cantidad_paquete"+i).equals("null") && !request.getParameter("cantidad_paquete"+i).equals("")) det.setCantidadPaquete(request.getParameter("cantidad_paquete"+i));
			else det.setCantidadPaquete("0");

			//if(request.getParameter(""+i)!=null && !request.getParameter(""+i).equals("null") && !request.getParameter(""+i).equals("")) det.set(request.getParameter(""+i));
			if(fp!=null && fp.equals("cargo_dev_so")){
				det.setCitaCodigo(request.getParameter("codCita"));
				det.setCitaFechaReg(request.getParameter("fechaCita"));
				det.setSecuencia(request.getParameter("secuencia"));
				det.setCompania((String) session.getAttribute("_companyId"));
				det.setUsuario((String) session.getAttribute("_userName"));
				det.setRenglon("1");
				if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).equals("null") && !request.getParameter("cantidad"+i).equals("")) det.setAdicion(request.getParameter("cantidad"+i));
				if(tipoTrx.equals("A") || tipoTrx.equals("D")){
					det.setTrxTipo(tipoTrx);
					if(tipoTrx.equals("D")) det.setDevolucion(request.getParameter("cantidad"+i));
				}
			}

			if(request.getParameter("chkServ"+i)!=null){
				fck = tipoSolicitud+"_"+det.getCodArticulo();
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					if(tipoSolicitud.equals("Q")){
						fTranCargQ.put(key, det);
						fTranCargQKey.put(fck, key);
					} else if(tipoSolicitud.equals("A")){
						fTranCargA.put(key, det);
						fTranCargAKey.put(fck, key);
					}
					CdcSol.getCdcSolicitudDetail().add(det);
					trx.add(det);
					//System.out.println("adding item "+key+" _ "+fck);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}

			}
		}
	}

	if(fp!=null && fp.equals("cargo_dev_so")){
		CdcSolMgr.agregarTrx(trx);
	}

	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_articles_so.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&codCita="+codCita+"&fechaCita="+fechaCita+"&tipoSolicitud="+tipoSolicitud+"&inv_almacen="+inv_almacen+"&secuencia="+secuencia+"&horaEntrada="+horaEntrada+"&horaSalida="+horaSalida+"&addArt="+addArt);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%
	if(CdcSolMgr.getErrCode()!= null && CdcSolMgr.getErrCode().equals("1") && fp!=null && fp.equals("cargo_dev_so")){
	%>
	alert('<%=CdcSolMgr.getErrMsg()%><%=addArt%>');
	<%
	} else if(CdcSolMgr.getErrCode()!= null && !CdcSolMgr.getErrCode().equals("1") && fp!=null && fp.equals("cargo_dev_so")){
	%>
	alert('No se pudieron agregar los artículos! <%=addArt%>');
	<%
	}
	%>

<% if ((fp.equals("cargo_dev_so") && (tipoSolicitud.equals("Q")||tipoSolicitud.equals("A")))||addArt.equals("S")) { %>
	//parent.location.reload(true);
	<%if(addArt.equals("S")){%>window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&habitacion=<%=habitacion%>&estadoCita=<%=estadoCita%>&tipoSolicitud=<%=tipoSolicitud%>&horaSalida=<%=horaSalida%>&horaEntrada=<%=horaEntrada%>';window.close();<%}
	else {%>parent.window.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&habitacion=<%=habitacion%>&estadoCita=<%=estadoCita%>&tipoSolicitud=<%=tipoSolicitud%>&horaSalida=<%=horaSalida%>&horaEntrada=<%=horaEntrada%>';
	<%}%>
<% } else { %>
	<%if(fp!= null && fp.equals("cargo_dev_pac_oc")){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_oc.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&codCita=<%=codCita%>';
	<%} else if(fp!= null && (fp.equals("cargo_dev_so")||fp.equals("cita_x_hab"))){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_so_2.jsp?mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&habitacion=<%=habitacion%>&estadoCita=<%=estadoCita%>&tipoSolicitud=<%=tipoSolicitud%>&horaSalida=<%=horaSalida%>&horaEntrada=<%=horaEntrada%>';

	<%}%>
	window.close();
<% } %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>