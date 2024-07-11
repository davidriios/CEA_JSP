<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OCMgr" scope="page" class="issi.compras.OrdenCompraMgr" />
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
OCMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String fg = request.getParameter("fg");
String tipoComp = request.getParameter("tipoComp");
String status = request.getParameter("status");
String anio = request.getParameter("anio");
String num_doc = request.getParameter("num_doc");

String appendFilter = "";

if (fg == null) fg = "conf";
if (status == null) status = "T";
if (tipoComp == null)tipoComp="";
if (anio == null )anio="";
if (num_doc == null) num_doc="";
if (!tipoComp.trim().equals("")){ appendFilter += " and a.tipo_compromiso="+tipoComp;}
if (!anio.trim().equals("")) appendFilter += " and a.anio="+anio;
if (!num_doc.trim().equals("")) appendFilter += " and a.num_doc="+num_doc;
//com220091

String currentDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if(fg.equals("app")){
	if(request.getParameter("status")==null) status = "P";
} 
if(fg.equals("con")){
	if(request.getParameter("status")==null) status = "A";
	appendFilter += " and a.monto_total > 1000";
	//appendFilter += " and (a.monto_total > 1000 or (a.monto_total <= 1000 and a.status = 'A'))";
} else if(fg.equals("fin")){
	if(request.getParameter("status")==null) status = "C";
	appendFilter += " and a.monto_total > 2500";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	if(appendFilter != null && !appendFilter.trim().equals(""))
	{
		sql = "select a.anio, a.num_doc as numDoc, a.cod_proveedor as codProveedor, b.nombre_proveedor as descCodProveedor, to_char(a.fecha_documento,'dd/mm/yyyy') as fechaDocto, a.monto_total as montoTotal, a.status, nvl((select distinct 'S' from tbl_com_detalle_compromiso dc/*, tbl_inv_articulo ia*/ where dc.cf_anio = a.anio and dc.cf_tipo_com = a.tipo_compromiso and dc.cf_num_doc = a.num_doc and dc.compania = a.compania /*and dc.compania = ia.compania and dc.cod_familia = ia.cod_flia and dc.cod_Clase = ia.cod_Clase and dc.cod_articulo = ia.cod_articulo*/ and dc.monto_articulo != getlastprecioprovprueba(a.compania, a.cod_proveedor, a.cod_almacen, dc.cod_articulo)), 'N') noInventario, (select descripcion from tbl_inv_almacen al where al.compania = a.compania and al.codigo_almacen = a.cod_almacen) descCodAlmacen, nvl(a.usuario_aprob,' ') usuarioAprob, to_char(a.fecha_aprob,'dd/mm/yyyy') as fechaAprob from tbl_com_comp_formales a, tbl_com_proveedor b where a.compania="+session.getAttribute("_companyId")+appendFilter+" and a.status='"+status+"' and a.cod_proveedor=b.cod_provedor order by a.fecha_documento desc, a.anio desc ,a.num_doc desc";
		System.out.println("sql...="+sql);
		
		al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal,OrdenCompra.class);
		//al = sbb.getBeanList(ConMgr.getConnection(),sql,OrdenCompra.class);
		rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
  
  String validarPrecio = "N";
  try{validarPrecio = java.util.ResourceBundle.getBundle("issi").getString("validarPrecio");}catch(Exception e){validarPrecio="N";}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Ordenes de Compras - '+document.title;

function doAction()
{
	setTipoComp();
}

function view(anio,docNo)
{
<%
String tp = "";
/*if (tipoComp.equals("1")) tp = "../compras/reg_orden_compra_normal.jsp";
else if (tipoComp.equals("2")) tp = "../compras/reg_orden_compra_esp.jsp";
else if (tipoComp.equals("3"))*/ tp = "../compras/reg_orden_compra_parcial.jsp";
%>
	abrir_ventana('<%=tp%>?mode=view&id='+docNo+'&anio='+anio);
}

function setTipoComp(){
	document.form1.tipoComp.value = document.search01.tipoComp.value;
}

function chkOC(i){
	var estado = eval('document.form1.status'+i).value;
	var anio = eval('document.form1.anio'+i).value;
	var num_doc = eval('document.form1.num_doc'+i).value;
	if(/*estado == 'N' &&*/ hasDBData('<%=request.getContextPath()%>','tbl_inv_recepcion_material','cf_anio = '+anio+' and cf_num_doc = '+num_doc+' and cf_tipo_com = 3 and estado = \'R\' and compania = <%=(String) session.getAttribute("_companyId")%>')){
		CBMSG.warning('Esta orden de compra ya fue recibida, no se puede Cambiar el Estado.!');
		eval('document.form1.status'+i).value = '<%=status%>';
	}
}

function printDet(i){
	var num = eval('document.form1.num_doc'+i).value;
	var anio = eval('document.form1.anio'+i).value;
	var tp = document.form1.tipoComp.value;
	var wh = eval('document.form1.desc_almacen'+i).value;
	var st = eval('document.form1.old_status'+i).value;
	if(st=='A') st = 'APROBADO';
	else if(st=='N') st = 'ANULADO';
	else if(st=='T') st = 'TRAMITE';
	else if(st=='P') st = 'PENDIENTE';
	//abrir_ventana('../compras/print_orden_parcial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st);
	abrir_ventana('../compras/print_orden_parcial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st+'&fp=cambio_precio_all');
}

function ctrlCambioPrecioVenta(i){
   var status = $("#status"+i).val();
   var validarPrecio = "<%=validarPrecio%>";
   var fg = "<%=fg%>";
   var anio = $("#anio"+i).val();
   var tipoComp = $("#tipoComp").val();
   var numDoc = $("#num_doc"+i).val();
   var descAlmacen = $("#desc_almacen"+i).val();
   var oStatus = $("#old_status"+i).val();
    if (validarPrecio == "Y"){
   var alreadyChanged = hasDBData('<%=request.getContextPath()%>','tbl_com_cambio_precio_hist','cf_anio = '+anio+' and num_doc = '+numDoc+' and tipo_comp = 3 and compania = <%=(String) session.getAttribute("_companyId")%>');
   if (status == "A" && alreadyChanged == true && confirm("Ya se cambio el precio. Quiere usted eliminar y volver a cambiar el precio?")==false) {$("#status"+i).val("P"); return false;}
   if (validarPrecio == "Y" && fg=="app"){
       if (status == "A"){
			$("#saveU, #saveB").attr("disabled",true);
			showPopWin('../compras/actualizar_precio_venta.jsp?fp=&tipoComp='+tipoComp+'&anio='+anio+'&id='+numDoc+'&descAlmacen='+descAlmacen+'&status='+oStatus+'&del='+alreadyChanged,winWidth*.95,winHeight*.85,null,null,'');
	   }
   }
   }
}

function getIncPercent(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.equalsIgnoreCase("conf")) {%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CONFIRMAR ORDEN DE COMPRA"></jsp:param>
</jsp:include>
<%} else if(fg.equalsIgnoreCase("app")) {%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - APROBAR ORDEN DE COMPRA"></jsp:param>
</jsp:include>
<%} else if(fg.equalsIgnoreCase("con")) {%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - APROBAR ORDEN DE COMPRA POR CONTABILIDAD"></jsp:param>
</jsp:include>
<%}else if(fg.equalsIgnoreCase("fin")) {%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - APROBAR ORDEN DE COMPRA POR FINANZA"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<tr class="TextFilter">
	<td>Año
	<%=fb.textBox("anio",anio,false,false,false,10)%> 
						<cellbytelabel>No Documento</cellbytelabel>: 
						<%=fb.textBox("num_doc",num_doc,false,false,false,10)%> 
						
						
		<cellbytelabel>Tipo de Orden</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),"select tipo_com, '[ '||tipo_com||' ] '||descripcion from tbl_com_tipo_compromiso where estatus='A' order by tipo_com","tipoComp",tipoComp,false,false,0,"")%>
		<cellbytelabel>Estado</cellbytelabel>
		<%
		if(fg.equalsIgnoreCase("app")){
		%>
		<%=fb.select("status","A=APROBADO,P=PENDIENTE",status)%>
		<%
		} else if (fg.equalsIgnoreCase("conf")){
		%>
		<%=fb.select("status","T=TRAMITE",status)%>
		<%
		} else if (fg.equalsIgnoreCase("con")){
		%>
		<%=fb.select("status","A=APROBADO POR COMPRAS,C=APROBADO POR CONTABILIDAD",status)%>
		<%
		} else if (fg.equalsIgnoreCase("fin")){
		%>
		<%=fb.select("status","C=APROBADO POR CONTABILIDAD,F=APROBADO FINA",status)%>
		<%
		}
		%>

		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("tipoComp",tipoComp)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("tipoComp",tipoComp)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="1">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("change","")%>
<%=fb.hidden("tipoComp",tipoComp)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("num_doc",num_doc)%>
<%=fb.hidden("size",""+al.size())%>
				<tr class="TextRow02">
					<td colspan="<%=fg.equals("app")?"9":"7"%>" align="right"><%=fb.submit("saveU","Guardar",true,false)%></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="6%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
					<td width="8%"><cellbytelabel>N&uacute;mero</cellbytelabel></td>
					<td width="<%=fg.equals("app")&&status.equals("A")?"47%":"57%"%>"><cellbytelabel>Proveedor</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
					<%if (fg.equals("app") && status.equals("A")){%>
					<td width="10%"><cellbytelabel>Aprobada por</cellbytelabel></td>
					<%}%>
					<td width="3%">&nbsp;</td>
					<%if(fg.equals("app")){%><td width="3%">&nbsp;</td><%}%>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	OrdenCompra oc = (OrdenCompra) al.get(i);
%>
				<%=fb.hidden("anio"+i,oc.getAnio())%>
				<%=fb.hidden("num_doc"+i,oc.getNumDoc())%>
				<%=fb.hidden("cod_proveedor"+i,oc.getCodProveedor())%>
				<%=fb.hidden("nombre_proveedor"+i,oc.getDescCodProveedor())%>
				<%=fb.hidden("fecha_documento"+i,oc.getFechaDocto())%>
				<%=fb.hidden("monto_total"+i,oc.getMontoTotal())%>
        <%=fb.hidden("old_status"+i,oc.getStatus())%>
        <%=fb.hidden("desc_almacen"+i,oc.getDescCodAlmacen())%>
				<tr class="TextRow01" align="center">
					<td><%=oc.getFechaDocto()%></td>
					<td><%=oc.getAnio()%></td>
					<td><%=oc.getNumDoc()%></td>
					<td align="left"><%=oc.getDescCodProveedor()%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(oc.getMontoTotal())%></td>
					<td>
					<%
		if(fg.equalsIgnoreCase("app")){
		%>
<%=fb.select("status"+i,"A=APROBADO,N=ANULADO,T=TRAMITE,P=PENDIENTE",oc.getStatus(), false, false, 0, "", "", "onChange=\"chkOC("+i+"); ctrlCambioPrecioVenta("+i+");\"")%>
		<%
		} else if (fg.equalsIgnoreCase("conf")){
		%>
<%=fb.select("status"+i,"T=TRAMITE,P=PENDIENTE",oc.getStatus())%>
		<%
		} else if (fg.equalsIgnoreCase("con")){
		%>
		<%=fb.select("status"+i,"C=APROBADO CONTA,N=ANULADO,T=TRAMITE,A=APROBADO",oc.getStatus(), false, false, 0, "", "", "onChange=\"javascript:chkOC("+i+");\"")%>
		<%
		} else if (fg.equalsIgnoreCase("fin")){
		%>
		<%=fb.select("status"+i,"F=APROBADO FINA,N=ANULADO,T=TRAMITE,C=APROBADO CONTA",oc.getStatus(), false, false, 0, "", "", "onChange=\"javascript:chkOC("+i+");\"")%>
		<%
		}
		%></td>
					<%if (fg.equals("app") && status.equals("A")){%>
						<td><%=oc.getUsuarioAprob()%></td>
					<%}%>
					<td>
					<authtype type='1'>
					<a href="javascript:view(<%=oc.getAnio()%>,<%=oc.getNumDoc()%>)" class="Link02Bold"><img src="../images/search.gif" width="16" height="16" border="0"></a></authtype></td>
					<td width="3%"><%if(fg.equals("app") && oc.getStatus().equals("A")){%><authtype type='1'><a href="javascript:printDet(<%=i%>)" class="Link02Bold"><img src="../images/printer.gif" width="16" height="16" border="0"></a></authtype><%}%>&nbsp;</td>
				</tr>
<%
}
%>
				<tr class="TextRow02">
					<td colspan="<%=fg.equals("app")?"9":"7"%>" align="right"><%=fb.submit("saveB","Guardar",true,false)%></td>
				</tr>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("tipoComp",tipoComp)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("tipoComp",tipoComp)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num_doc",num_doc)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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
}//GET
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	int lineNo = 0;
	Hashtable ht = new Hashtable();
	for (int i=0; i<size; i++)
	{
		OrdenCompra oc = new OrdenCompra();

		oc.setAnio(request.getParameter("anio"+i));
		oc.setNumDoc(request.getParameter("num_doc"+i));
		oc.setCodProveedor(request.getParameter("cod_proveedor"+i));
		oc.setDescCodProveedor(request.getParameter("nombre_proveedor"+i));
		oc.setFechaDocto(request.getParameter("fecha_documento"+i));
		oc.setMontoTotal(request.getParameter("monto_total"+i));
		oc.setStatus(request.getParameter("status"+i));
		oc.setOldStatus(request.getParameter("old_status"+i));
		oc.setCompania((String) session.getAttribute("_companyId"));
		oc.setUsuarioMod((String) session.getAttribute("_userName"));
		
		oc.setUsuarioAprob((String) session.getAttribute("_userName"));
		oc.setFechaAprob(currentDateTime);
		
		oc.setTipoCompromiso(tipoComp);
		String key = "";
		if(!status.equals(request.getParameter("status"+i))){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try
			{
				ht.put(key, oc);
			}
			catch (Exception e)
			{
				System.out.println("Unable to add item "+key);
			}
		}
	}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (fg.equalsIgnoreCase("conf")) OCMgr.confirm(ht);
	else if ((fg.equalsIgnoreCase("app"))|| (fg.equalsIgnoreCase("con")) || (fg.equalsIgnoreCase("fin"))) OCMgr.approve(ht);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (OCMgr.getErrCode().equals("1"))
{
%>
	alert('<%=OCMgr.getErrMsg()%>');
	window.location = '../compras/confirmar_orden_compra.jsp?fg=<%=fg%>&tipoComp=<%=tipoComp%>&status=<%=status%>&anio=<%=anio%>&num_doc=<%=num_doc%>';
<%
}
else throw new Exception(OCMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
