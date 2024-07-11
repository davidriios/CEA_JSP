<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" /> 
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String fg = request.getParameter("fg");
String tipoComp = request.getParameter("tipoComp");
String status = request.getParameter("status");
String anio = request.getParameter("anio");
String num_doc = request.getParameter("num_doc");
String fecha_ini="",fecha_fin=""; 

String appendFilter = "";

if (fg == null) fg = "cer";
if (status == null) status = "";
if (tipoComp == null)tipoComp="";
if (anio == null )anio="";
if (num_doc == null) num_doc="";
if (!tipoComp.trim().equals("")){ appendFilter += " and a.tipo_compromiso="+tipoComp;}
if (!anio.trim().equals("")) appendFilter += " and a.anio="+anio;
if (!num_doc.trim().equals("")) appendFilter += " and a.num_doc="+num_doc;
if (!status.trim().equals("")){ appendFilter += " and a.status='"+status+"'";}
else appendFilter += " and status in ('A','C','F') "; 
//com220091
 
String currentDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

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
  if ((request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").trim().equals("")))
	{
		fecha_ini = request.getParameter("fecha_ini");
 		appendFilter += " and trunc(a.fecha_documento) >= to_date('"+request.getParameter("fecha_ini")+"','dd/mm/yyyy')";
 	}
	if (( request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals("")))
	{
		fecha_fin = request.getParameter("fecha_fin");
		appendFilter += " and trunc(a.fecha_documento) <= to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy') ";
	}
	if(request.getParameter("anio") != null)
	{
		sql = "select a.anio, a.num_doc as numDoc, a.cod_proveedor as codProveedor, b.nombre_proveedor as descCodProveedor, to_char(a.fecha_documento,'dd/mm/yyyy') as fechaDocto, a.monto_total as montoTotal,nvl((select distinct 'S' from tbl_com_detalle_compromiso dc/*, tbl_inv_articulo ia*/ where dc.cf_anio = a.anio and dc.cf_tipo_com = a.tipo_compromiso and dc.cf_num_doc = a.num_doc and dc.compania = a.compania /*and dc.compania = ia.compania and dc.cod_familia = ia.cod_flia and dc.cod_Clase = ia.cod_Clase and dc.cod_articulo = ia.cod_articulo*/ and dc.monto_articulo != getlastprecioprovprueba(a.compania, a.cod_proveedor, a.cod_almacen, dc.cod_articulo)), 'N') noInventario, (select descripcion from tbl_inv_almacen al where al.compania = a.compania and al.codigo_almacen = a.cod_almacen) descCodAlmacen, nvl(a.usuario_aprob,' ') usuarioAprob, to_char(a.fecha_aprob,'dd/mm/yyyy') as fechaAprob,decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','F','APROBADO FINA','C','APROBADO CONTA','Z','CERRADO') as status,a.status as oldStatus from tbl_com_comp_formales a, tbl_com_proveedor b where a.compania="+session.getAttribute("_companyId")+appendFilter+" and a.cod_proveedor=b.cod_provedor order by a.fecha_documento desc, a.anio desc ,a.num_doc desc";
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
  %>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Ordenes de Compras - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();checkObser();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function view(anio,docNo)
{
<%String tp = "../compras/reg_orden_compra_parcial.jsp";%>
	abrir_ventana('<%=tp%>?mode=view&id='+docNo+'&anio='+anio);
}
function setTipoComp(){document.form1.tipoComp.value = document.search01.tipoComp.value;}
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


function checkObsev(k){

if(eval('document.form1.cerrar'+k).checked ==true)
{
eval('document.form1.comments'+k).readOnly=false;
eval('document.form1.comments'+k).className = "FormDataObjectRequired"; 
}
else
{

eval('document.form1.comments'+k).value="";
eval('document.form1.comments'+k).readOnly=true;
eval('document.form1.comments'+k).className = "FormDataObjectEnabled";  

}
}
function chkCant(){var size = <%=al.size()%>;var cant = 0;var err = 0;var art = '';
var cantCk=0;

for(i=0;i<size;i++)
{
 	if(eval('document.form1.cerrar'+i).checked ==true)
	{
	
	 if((eval('document.form1.comments'+i).value).trim()==''){CBMSG.warning('EXISTEN REGISTROS SELECCIONADOS SIN OBSERVACION. POR FAVOR VERIFIQUE... ');err++;break;}
	 if(err==0)cantCk ++;
	
	}
}
  if(err==0){if(cantCk!=0)return true;else{CBMSG.warning('NO HAY REGISTROS SELECCIONADOS PARA GUARDAR'); return false;}}else return false;
}
function checkObser()
{  var size = <%=al.size()%>;
	for(i=0;i<size;i++)
	{
		checkObsev(i);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 <jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CERRAR ORDEN DE COMPRA"></jsp:param>
</jsp:include> 
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
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
		<%=fb.select("status","A=APROBADO,C=APROBADO POR CONTABILIDAD,F=APROBADO FINA",status,"S")%> 
		Fecha:  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha_ini"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
				<jsp:param name="nameOfTBox2" value="fecha_fin"/>
				<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
				</jsp:include>

		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td align="right">&nbsp;</td>
</tr>
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
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
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
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableBorder">
	<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
	<table align="center" width="100%" cellpadding="0" cellspacing="1">
				
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("change","")%>
<%=fb.hidden("tipoComp",tipoComp)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("num_doc",num_doc)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fecha_ini",fecha_ini)%>
<%=fb.hidden("fecha_fin",fecha_fin)%>
				<tr class="TextRow02">
					<td colspan="11" align="right"><%=fb.submit("saveU","Guardar",true,false)%></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="6%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
					<td width="8%"><cellbytelabel>N&uacute;mero</cellbytelabel></td>
					<td width="21%"><cellbytelabel>Proveedor</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Aprobada por</cellbytelabel></td> 
					<td width="10%"><cellbytelabel>Estado</cellbytelabel></td> 
					<td width="3%">&nbsp;</td>
					<td width="3%">&nbsp;</td> 
					<td width="20%">Comentario</td> 
					<td width="3%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','cerrar',"+al.size()+",this,0);checkObser()\"","Seleccionar todos los registros listados!")%></td> 
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
				<%=fb.hidden("old_status"+i,oc.getOldStatus())%>
				<%=fb.hidden("desc_almacen"+i,oc.getDescCodAlmacen())%>
					<tr class="TextRow01" align="center">
					<td><%=oc.getFechaDocto()%></td>
					<td><%=oc.getAnio()%></td>
					<td><%=oc.getNumDoc()%></td>
					<td align="left"><%=oc.getDescCodProveedor()%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(oc.getMontoTotal())%></td>
					<td><%=oc.getUsuarioAprob()%></td>
					<td><%=oc.getStatus()%></td> 
 					<td><authtype type='1'> <a href="javascript:view(<%=oc.getAnio()%>,<%=oc.getNumDoc()%>)" class="Link02Bold"><img src="../images/search.gif" width="16" height="16" border="0"></a></authtype></td>
					<td><authtype type='50'><a href="javascript:printDet(<%=i%>)" class="Link02Bold"><img src="../images/printer.gif" width="16" height="16" border="0"></a></authtype>&nbsp;</td>
					<td><%=fb.textarea("comments"+i,"",false,false,false,50,1,2000,null,"","")%></td>
					<td><%=fb.checkbox("cerrar"+i,"S",false,false ,null,null,"onClick=\"javascript:checkObsev("+i+")\"")%></td>  
				</tr>
<%
}fb.appendJsValidation("if(!chkCant())error++;");
%>
				<tr class="TextRow02">
					<td colspan="11" align="right"><%=fb.submit("saveB","Guardar",true,false)%></td>
				</tr>
	<%=fb.formEnd(true)%>
				</table>
 </div>
</div>
	</td>
</tr>
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
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
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
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
    al.clear();
	int size = Integer.parseInt(request.getParameter("size"));
  	for (int i=0; i<size; i++)
	{
		
	  if (request.getParameter("cerrar"+i) != null) 
	  {	
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_com_comp_formales");
		cdo.setWhereClause("num_doc="+request.getParameter("num_doc"+i)+" and anio="+request.getParameter("anio"+i)+" and compania="+(String) session.getAttribute("_companyId"));
		
 		cdo.setKey(i);
		cdo.setAction("U"); 
		cdo.addColValue("status_old",""+request.getParameter("old_status"+i));
		cdo.addColValue("status","Z");
		cdo.addColValue("fecha_mod","sysdate");	 
		cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
		cdo.addColValue("motivo",request.getParameter("comments"+i));
		
		al.add(cdo);
	  }
 	}
	
	if (al.size() == 0)
	{
		CommonDataObject cdo = new CommonDataObject();
		
		cdo.setTableName("tbl_com_comp_formales");
		cdo.setWhereClause("anio=-1 and num_doc0-1 and compania=-1");

		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true,false);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '../compras/cerrar_ordenes_compras.jsp?fg=<%=fg%>&tipoComp=<%=tipoComp%>&status=<%=status%>&anio=<%=anio%>&num_doc=<%=num_doc%>&fecha_fin=<%=fecha_fin%>&fecha_ini=<%=fecha_ini%>';
<%
}
else throw new Exception(SQLMgr.getErrMsg());
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
