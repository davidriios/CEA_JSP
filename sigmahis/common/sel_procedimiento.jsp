<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="htCPT" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCPTKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCita" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCitaKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htProcKey" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500005") || SecMgr.checkAccess(session.getId(),"500006") || SecMgr.checkAccess(session.getId(),"500007") || SecMgr.checkAccess(session.getId(),"500008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p?gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
XML.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cs = request.getParameter("cs");
String pac_id = request.getParameter("pac_id");
String admision = request.getParameter("admision");
String index = request.getParameter("index");
String fDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cds = request.getParameter("cds");

String tab = request.getParameter("tab");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String codigo="",descripcion="";
if (fg == null) fg = "";
if (cs == null) cs = "";
if (cds == null) cds = "";
if (index == null) index = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
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

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
    appendFilter += " and upper(b.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
    appendFilter += " and upper(decode(b.observacion,null, b.descripcion,b.observacion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

	if(fp.equals("imagen")){
		sql = "select distinct decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo, a.cod_centro_servicio centro_servicio, c.descripcion centro_servicio_desc from tbl_cds_procedimiento_x_cds a, tbl_cds_procedimiento b, tbl_cds_centro_servicio c where a.cod_procedimiento = b.codigo and a.cod_centro_servicio = c.codigo and a.cod_centro_servicio = "+cs+appendFilter+" and b.estado = 'A' order by decode (b.observacion, null, b.descripcion, b.observacion)";
	} else if(fp.equals("sol_img_estudio")){
		sql = "select distinct decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo, a.cod_centro_servicio centro_servicio, c.descripcion centro_servicio_desc from tbl_cds_procedimiento_x_cds a, tbl_cds_procedimiento b, tbl_cds_centro_servicio c where a.cod_procedimiento = b.codigo and a.cod_centro_servicio = c.codigo and a.cod_centro_servicio = "+cs+appendFilter+" and b.estado = 'A' order by decode (b.observacion, null, b.descripcion, b.observacion)";
	} else if(fp.equals("sol_lab_estudio")){
		sql = "select distinct decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo, c.codigo centro_servicio, c.descripcion centro_servicio_desc from tbl_cds_procedimiento_x_cds a, tbl_cds_procedimiento b, tbl_cds_centro_servicio c where a.cod_procedimiento = b.codigo and a.cod_centro_servicio = c.codigo and a.cod_centro_servicio = "+cs+appendFilter+" and b.estado = 'A' order by decode (b.observacion, null, b.descripcion, b.observacion)";
	} else if(fp.equals("citas") || fp.equals("edit_cita")){
		sql = "select   nvl(nvl(b.nombre_corto, b.observacion), b.descripcion) descripcion, b.codigo, a.nombre especialidad, b.tipo_categoria as tipo_cirugia, nvl (b.tiempo_estimado, 0) horas, nvl (b.unidad_tiempo, 0) minutos from tbl_cds_procedimiento b, TBL_CDS_TIPO_CATEGORIA a where  b.tipo_categoria is not null and (a.codigo = b.tipo_categoria) "+appendFilter+" and b.estado = 'A' order by nvl (nvl (b.nombre_corto, b.observacion), b.descripcion)";
		
	} else if(fp.equals("mat_paciente")){
		sql = "select   nvl(nvl(b.nombre_corto, b.observacion), b.descripcion) descripcion, b.codigo, a.descripcion especialidad, b.tipo_cirugia, nvl (b.tiempo_estimado, 0) horas, nvl (b.unidad_tiempo, 0) minutos from tbl_cds_procedimiento b, tbl_cdc_tipo_cirugia a where b.cod_cds = 24 and b.estado = 'A' and (a.codigo = b.tipo_cirugia) "+appendFilter+" order by nvl (nvl (b.nombre_corto, b.observacion), b.descripcion)";
	}
	else if(fp.equals("citas_cons")){
	  appendFilter = "";
	  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo = request.getParameter("codigo");
	  }
	  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
		appendFilter += " and upper(coalesce(a.nombre_corto,a.observacion,a.descripcion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	  }
		sql = "select distinct a.codigo, coalesce(a.nombre_corto,a.observacion,a.descripcion) as descripcion, nvl((select descripcion from tbl_cdc_tipo_cirugia where codigo=a.tipo_cirugia),' ') as especialidad, decode(a.tipo_cirugia,null,' ',''||a.tipo_cirugia) as tipo_cirugia, nvl(a.tiempo_estimado,0) as horas, nvl(a.unidad_tiempo,0) as minutos, decode(a.precio,null,0,a.precio) as precio, decode(a.costo,null,0,a.costo) as costo, (select descripcion from tbl_cds_tipo_categoria where codigo=a.tipo_categoria) as tipoCategoriaDesc from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds c where a.estado='A' and a.codigo = c.cod_procedimiento and c.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO') )  "+appendFilter+" order by 2";
	}
	else if(fp.equals("protocolo"))
	{

		sql = "select decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.descripcion nombre_ingles, b.codigo, b.tipo_cirugia from tbl_cds_procedimiento b where tipo_categoria = 3 "+appendFilter;

	}
	else if(fp.equals("reporte_ris_lis")||fp.equals("cotizacion"))
	{

		sql = "select decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo, b.tipo_cirugia from tbl_cds_procedimiento b where codigo is not null "+appendFilter;

	} 
	else if(fp.equalsIgnoreCase("orderset")){
    sql = "select distinct decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo, a.cod_centro_servicio centro_servicio, c.descripcion centro_servicio_desc from tbl_cds_procedimiento_x_cds a, tbl_cds_procedimiento b, tbl_cds_centro_servicio c where a.cod_procedimiento = b.codigo and a.cod_centro_servicio = c.codigo "+appendFilter+" and b.estado = 'A' and c.interfaz = '"+fg+"' order by decode (b.observacion, null, b.descripcion, b.observacion)";
 }
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
  
  String jsContext = "window.opener.";
  if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Procedimientos - '+document.title;

function getMain(formx)
{
	formx.cds.value = document.search00.cds.value;
	formx.catCode.value = document.search00.catCode.value;
	return true;
}

function setProcedimiento(i){
	var cs = document.procedimiento.cs.value;
	var index = document.procedimiento.index.value;
<%
	if (fp.equalsIgnoreCase("imagen")){
%>
	eval('window.opener.document.form1.cod_procedimiento'+index).value = eval('document.procedimiento.codigo'+i).value;
	eval('window.opener.document.form1.nombre_procedimiento'+index).value = eval('document.procedimiento.descripcion'+i).value;
<%
	} else if (fp.equalsIgnoreCase("mat_paciente")){
%>
	window.opener.document.requisicion.procedimiento.value = eval('document.procedimiento.codigo'+i).value;
	window.opener.document.requisicion.procedimiento_desc.value = eval('document.procedimiento.descripcion'+i).value;

<%}else if (fp.equals("protocolo")){%>

	window.opener.document.form0.codProc.value = eval('document.procedimiento.codigo'+i).value;
	window.opener.document.form0.descProc.value = eval('document.procedimiento.descripcion'+i).value;

<%}else if (fp.equals("citas_cons")){%>

	window.opener.document.search01.proc_code.value = eval('document.procedimiento.codigo'+i).value;
	window.opener.document.search01.proc_name.value = eval('document.procedimiento.descripcion'+i).value;
<%	} else if (fp.equalsIgnoreCase("reporte_ris_lis")){
%>
	window.opener.document.form0.codProc.value = eval('document.procedimiento.codigo'+i).value;
	window.opener.document.form0.descProc.value = eval('document.procedimiento.descripcion'+i).value;

<%} else if (fp.equalsIgnoreCase("cotizacion")){
%>
	window.opener.document.form0.cod_proc.value = eval('document.procedimiento.codigo'+i).value;
	window.opener.document.form0.procedimiento.value = eval('document.procedimiento.descripcion'+i).value;

<%} else if (fp.equalsIgnoreCase("orderset")){%>
     console.log( $("#ref_code<%=index%>", <%=jsContext%>document) )

     $("#ref_code<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.codigo'+i).value);
     $("#ref_name<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.descripcion'+i).value);

<%} %>
	
<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
<%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
<%}else{%>
<%if (!fp.equalsIgnoreCase("admision")){%>window.close();<%}%>
<%}%>
}

function verificar(i){
	var secuencia = document.procedimiento.admision.value;
	var pac_id = document.procedimiento.pac_id.value;
	var fecha = '<%=fDate%>';
	var procedimiento = eval('document.procedimiento.codigo'+i).value;

	var cod = getDBData('<%=request.getContextPath()%>','procedimiento','tbl_sal_detalle_orden_med','procedimiento=\''+procedimiento+'\' and secuencia = '+secuencia+' and pac_id='+pac_id+' and to_date(to_char(fecha_creacion,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');

	if(procedimiento==cod && eval('document.procedimiento.chkProc'+i).checked==true){
		eval('document.procedimiento.chkProc'+i).checked = confirm("Este procedimiento ya fue solicitado para esta admisi?n en este d?a, desea volver a solicitarlo?");
	}
}

function verificarCant(){
	size = <%=al.size()%>;
	<%if(fp.equals("citas")){%>
	var htProc = <%=htCita.size()%>;
	<%} else if(fp.equals("edit_cita")){%>
	var htProc = <%=htProc.size()%>;
	<%}%>
	var contChk =0;
	for(i=0;i<size;i++){
		if(eval('document.procedimiento.chkProc'+i) && eval('document.procedimiento.chkProc'+i).checked) contChk++;
		if((contChk+htProc)==5){
			alert('No puede seleccionar m?s de 4 procedimientos!')
			eval('document.procedimiento.chkProc'+i).checked = false;
			break;
		}
	}
}

function doAction() {
  <% if(context.equalsIgnoreCase("preventPopupFrame")) { 
    if (al.size() == 0) {%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}
    else if (al.size() == 1) {%>setProcedimiento(0);<%}%>
  <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CENTRO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("pac_id",pac_id)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codCita",codCita)%>
				<%=fb.hidden("fechaCita",fechaCita)%>
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("context",context)%>
				<td width="40%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,15)%>
				</td>
				<td width="60%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,70)%>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>

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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
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
<%
fb = new FormBean("procedimiento","","post","");
%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("context",context)%>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%
				if(fp.equals("sol_img_estudio") || fp.equals("citas") || fp.equals("edit_cita") || fp.equals("sol_lab_estudio")){
				%>
				<tr>
					<td align="right" colspan="3"><%=fb.submit("add","Agregar")%><!--<%=fb.submit("addCont","Agregar y Continuar")%>--></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="50%">Descripci&oacute;n</td>
					<td width="3%">&nbsp;</td>
				</tr>
				<%
				} else if(fp.equals("imagen") || fp.equals("mat_paciente")  || fp.equals("protocolo")|| fp.equals("reporte_ris_lis")||fp.equals("cotizacion") || fp.equals("orderset")){
				%>
				<tr class="TextHeader" align="center">
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Ingl&eacute;s</cellbytelabel></td>
				</tr>
				<%
				}
				%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("centro_servicio"+i,cdo.getColValue("centro_servicio"))%>
				<%=fb.hidden("centro_servicio_desc"+i,cdo.getColValue("centro_servicio_desc"))%>

				<%
				if(fp.equals("imagen") || fp.equals("mat_paciente") || fp.equals("protocolo")|| fp.equals("citas_cons")|| fp.equals("reporte_ris_lis")||fp.equals("cotizacion") || fp.equals("orderset")){
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setProcedimiento(<%=i%>)" style="cursor:pointer">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("nombre_ingles")%></td>
				</tr>
				<%
				} else if(fp.equals("sol_img_estudio") || fp.equals("citas") || fp.equals("edit_cita") || fp.equals("sol_lab_estudio")){
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">
          <%if(fp.equals("sol_img_estudio") || fp.equals("sol_lab_estudio")){%>
					<%=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:verificar("+i+")\"")%>
          <%} %>
					<%if((fp.equals("citas") && htCitaKey.containsKey(cdo.getColValue("codigo"))) || (fp.equals("edit_cita") && htProcKey.containsKey(cdo.getColValue("codigo")))){
					%>
          <cellbytelabel>elegido</cellbytelabel>
          <%} else if((fp.equals("citas") && !htCitaKey.containsKey(cdo.getColValue("codigo"))) || (fp.equals("edit_cita") && !htProcKey.containsKey(cdo.getColValue("codigo")))){%>
					<%=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:verificarCant()\"")%>
					<%}%>
					</td>
				</tr>
				<%
				}
				%>
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
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
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
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
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
}
else
{
	System.out.println("=====================POST=====================");
	int lineNo = 0;
	lineNo = htCPT.size();

	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if(fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("edit_cita")){
		lineNo = htCita.size();
		if(fp.equalsIgnoreCase("edit_cita")) lineNo = htProc.size();
		for(int i=0;i<keySize;i++){
			CitaProcedimiento det = new CitaProcedimiento();

			det.setProcedimiento(request.getParameter("codigo"+i));
			det.setProcedimientoDesc(request.getParameter("descripcion"+i));

			if(request.getParameter("chkProc"+i)!=null){

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					if(fp.equalsIgnoreCase("citas")){
						htCita.put(key, det);
						htCitaKey.put(det.getProcedimiento(), key);
					} else if(fp.equalsIgnoreCase("edit_cita")){
						htProc.put(key, det);
						htProcKey.put(det.getProcedimiento(), key);
					}
					System.out.println("adding item "+key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	} else {
		for(int i=0;i<keySize;i++){
			DetalleOrdenMed det = new DetalleOrdenMed();

			det.setProcedimiento(request.getParameter("codigo"+i));
			det.setNombreProcedimiento(request.getParameter("descripcion"+i));
			det.setCentroServicio(request.getParameter("centro_servicio"+i));
			det.setCentroServicioDesc(request.getParameter("centro_servicio_desc"+i));

			if(request.getParameter("chkProc"+i)!=null){

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					htCPT.put(key, det);
					htCPTKey.put(det.getProcedimiento()+"_"+det.getCentroServicio(), key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}

			}
		}
	}
	/*
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_procedimiento.jsp?change=1&type=1&fg="+fg+"&fp="+fp+"&cs="+cs);
		return;
	}
	*/

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && (fp.equals("sol_img_estudio") || fp.equals("sol_lab_estudio"))){%>
	window.opener.location = '<%=request.getContextPath()+"/expediente/reg_img_lab_det.jsp?mode=add&change=1&fg="+fg%>&fp=<%=fp%>&cs=<%=cs%>';
	<%} else if(fp!= null && fp.equals("citas")){%>
	window.opener.location = '<%=request.getContextPath()+"/cita/reg_cita_det.jsp?mode=add&change=1&fg="+fg%>&fp=<%=fp%>';
	<%} else if(fp!= null && fp.equals("edit_cita")){%>
	window.opener.location = '<%=request.getContextPath()+"/cita/edit_cita.jsp?mode=edit&change=1&fg="+fg%>&fp=<%=fp%>&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&context=<%=context%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>