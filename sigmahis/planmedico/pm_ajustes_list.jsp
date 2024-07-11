<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

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
String fecha_ini_plan_f = "", fecha_ini_plan_t = "", tipo_aju = "";
String fg = "cxc", estado="", id="", nombreCliente="";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

	
if(request.getMethod().equalsIgnoreCase("GET"))
{

int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  if(request.getParameter("fecha_ini_plan_f")!=null) fecha_ini_plan_f = request.getParameter("fecha_ini_plan_f");
	if(request.getParameter("fecha_ini_plan_t")!=null) fecha_ini_plan_t = request.getParameter("fecha_ini_plan_t");
	if(request.getParameter("id")!=null) id = request.getParameter("id");
	if(request.getParameter("nombre_cliente")!=null) nombreCliente = request.getParameter("nombre_cliente");
	if(request.getParameter("fg")!=null) fg = request.getParameter("fg");
	if(request.getParameter("tipo_aju")!=null) tipo_aju = request.getParameter("tipo_aju");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");

	sbSql = new StringBuffer();

	sbSql.append("select a.id, a.compania, a.anio, a.mes, a.tipo_aju, decode(a.tipo_aju, 1, 'Descuento a Factura', 2, 'Anular Pago', 3, 'Nota de Credito', 4, 'Nota de Credito CxP', 5, 'Nota de Debito', 0, 'NC Anular Factura') tipo_aju_desc, a.tipo_ben, decode(a.tipo_ben, 1, 'CxC Afiliado', 2, 'CxP Medico', 3, 'CxP Empresa Reclamos') tipo_ben_desc, a.id_solicitud, a.id_referencia, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, a.usuario_aprobacion, a.estado, a.observacion, (case when a.tipo_ben = 1 then (select v.nombre_paciente from vw_pm_cliente v where to_char(v.codigo) = a.id_referencia) else ''  end) nombre_beneficiario, decode(a.estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo', a.estado) estado_desc from tbl_pm_ajuste a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!fecha_ini_plan_f.equals("")){
		sbSql.append(" and trunc(a.fecha_creacion) >= to_date('");
		sbSql.append(fecha_ini_plan_f);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_ini_plan_t.equals("")){
		sbSql.append(" and trunc(a.fecha_creacion) <= to_date('");
		sbSql.append(fecha_ini_plan_t);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!id.equals("")){
		sbSql.append(" and id = ");
		sbSql.append(id);
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}   
	if(!nombreCliente.equals("") && fg.equals("cxc")){
		sbSql.append(" and exists (select null from vw_pm_cliente p where to_char(p.codigo) = a.id_referencia and nombre_paciente like '%");
		sbSql.append(nombreCliente.toUpperCase());
		sbSql.append("%')");
	}   	
	if(!tipo_aju.equals("")){
		sbSql.append(" and tipo_aju = ");
		sbSql.append(tipo_aju);
	}   
	
	sbSql.append(" order by a.id desc");
     
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");

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
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}

function manageSurvey(option){
	
   if (typeof option == "undefined") abrir_ventana('../planmedico/reg_pm_ajuste.jsp?fg=<%=fg%>');
   else if(option=='edit'){
    if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			if(estado=='F') CBMSG.warning('No puede editar un Ajuste Finalizado!');
			else abrir_ventana('../planmedico/reg_pm_ajuste.jsp?mode=edit&id='+getCurVal()+'&fg=<%=fg%>');
		}
   }
   else if(option=='view'){
    if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else abrir_ventana('../planmedico/reg_pm_ajuste.jsp?mode=view&id='+getCurVal()+'&fg=<%=fg%>');
   }
   else if(option=='print_ajuste'){
      if (getCurVal() != ""){
        var ind = document.getElementById("curIndex").value;
        var tipo_aju = document.getElementById("tipo_aju"+ind).value;
         abrir_ventana('../planmedico/print_nota_ajuste.jsp?codigo='+getCurVal()+'&fg=<%=fg%>&tipo_aju='+tipo_aju);
      }else{
      }
   } else if(option=='approve'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			var tipo_aju = document.getElementById("tipo_aju"+ind).value;
			 if(estado=='I') CBMSG.warning('El Ajuste ya esta inactivo y no se puede aprobar!');
			 else if(estado=='A') CBMSG.warning('El Ajuste ya está aprobado!');
			 else if(estado=='F') CBMSG.warning('No puede aprobar un Ajuste ya Finalizado!');
			else showPopWin('../process/pm_app_ajuste.jsp?fp=ajuste_pm&mode=app&code='+getCurVal()+'&tipo_aju='+tipo_aju,winWidth*.95,_contentHeight*.55,null,null,'');
		}
	 } else if(option=='inactivate'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			var tipo_aju = document.getElementById("tipo_aju"+ind).value;
			 if(estado=='I') CBMSG.warning('El Ajuste ya está Inactivo!');
			 else if(estado=='F') CBMSG.warning('No puede inactivar un Ajuste ya Finalizado!');
			 else if(estado=='A') CBMSG.warning('El ajuste está aprobado y no se puede inactivar!');
			else showPopWin('../process/pm_app_ajuste.jsp?fp=ajuste_pm&mode=ina&code='+getCurVal()+'&tipo_aju='+tipo_aju,winWidth*.95,_contentHeight*.55,null,null,'');
	}
	 } else if(option=='close'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado!='A') CBMSG.warning('Solo las solicitudes aprobadas pueden ser cerradas!');
			 else if(estado=='A') showPopWin('../process/pm_cerrar_solicitud.jsp?code='+getCurVal(),winWidth*.95,_contentHeight*.75,null,null,'');
	}
	}
}


function changeAltTitleAttr(obj,type,ctx){
  var opt = {"view":"Ver","edit":"Editar","print":"Imprimir","approve":"Aprobar","inactivate":"Inactivar"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Lista Ajuste";
	  document.getElementById("editImg").alt = "Seleccione un Ajuste a Editar";
	  document.getElementById("viewImg").alt = "Seleccione un Ajuste a Ver";
	  document.getElementById("appImg").alt = "Aprobar Ajuste";
	  document.getElementById("inacImg").alt = "Inactivar Ajuste";
	  document.getElementById("cerrarImg").alt = "Cerrar Ajuste";
	  document.getElementById("printImg").title = "Imprimir Lista Ajuste";
	  document.getElementById("editImg").title = "Seleccione un Ajuste a Editar";
	  document.getElementById("viewImg").title = "Seleccione un Ajuste a Ver";
	  document.getElementById("appImg").title = "Aprobar Ajuste";
	  document.getElementById("inacImg").title = "Inactivar Ajuste";
	  document.getElementById("cerrarImg").title = "Cerrar Ajuste";
	  document.getElementById("print_ajuste").title = "Imprimir Ajuste";
	}
}
function printList(){
	var fDesde= document.search01.fecha_ini_plan_f.value||'ALL';
	var fHasta= document.search01.fecha_ini_plan_t.value||'ALL';
	var estado= document.search01.estado.value;
	var noAjuste= document.search01.id.value;
	var tipoAjuste= document.search01.tipo_aju.value;
	var beneficiario= document.search01.nombre_cliente.value;
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_ajuste_list.rptdesign&fDesdeParam='+fDesde+'&fHastaParam='+fHasta+'&estadoParam='+estado+'&noAjuParam='+noAjuste+'&tipoAjusteParam='+tipoAjuste+'&benefParam='+beneficiario);
}
function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal,curIndex){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nuevo Ajuste" title="Registrar Nuevo Ajuste" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Ajuste')" width="32px" height="32px" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='1'>
			<img src="../images/ver.png" onClick="javascript:manageSurvey('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Ajuste')" width="32px" height="32px" id="viewImg"/>
			</authtype>&nbsp;
			<!--
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Ajuste')" id="printImg"/>
			</authtype>
			-->
			<authtype type='6'>
			<img src="../images/check.gif" onClick="javascript:manageSurvey('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Solicitud')" id="appImg" height="30" width="30"/>
			</authtype>
			<authtype type='7'>
			<img src="../images/cancel.gif" onClick="javascript:manageSurvey('inactivate')" onMouseOver="javascript:changeAltTitleAttr(this,'inactivate','Ajuste')" id="inacImg" height="30" width="30"/>
			</authtype>
			<!--
			<authtype type='50'>
			<img src="../images/lock_circle.png" onClick="javascript:manageSurvey('close')" onMouseOver="javascript:changeAltTitleAttr(this,'close','Ajuste')" id="cerrarImg" height="30" width="30"/>
			</authtype>
			-->
            <authtype type='51'>
			<img src="../images/print_contract.png" onClick="javascript:manageSurvey('print_ajuste')" onMouseOver="javascript:changeAltTitleAttr(this,'print_ajuste','Imprimir Ajuste')" id="print_ajuste" height="30" width="30"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fg",fg)%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">Fecha</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_ini_plan_f" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_ini_plan_f%>" />
			<jsp:param name="nameOfTBox2" value="fecha_ini_plan_t" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_ini_plan_t%>" />
			</jsp:include>
			<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo,P=Pendiente, F=Finalizado",estado,"T")%>
			<cellbytelabel>Tipo Ajuste</cellbytelabel>&nbsp;
			<%=fb.select("tipo_aju",(fg.equals("cxc")?"1=Descuento a Factura,2=Anular Pago,3=Nota de Credito,5=Nota de Debito":"4=Nota de Credito CxP, 0=NC Anular Factura"),estado,"T")%>
			No. Ajuste:
			<%=fb.intBox("id",id,false,false,false,5,10,"",null,null)%>
      Cliente: <%=fb.textBox("nombre_cliente",nombreCliente,false,false,false,30,100,"",null,null)%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("tipo_aju",tipo_aju)%>
			<%=fb.hidden("fg",fg)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("tipo_aju",tipo_aju)%>
			<%=fb.hidden("fg",fg)%>
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
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>No. Ajuste</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>Contrato</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>Tipo Ajuste</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Tipo</cellbytelabel></td>
		<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("id_solicitud")%></td>
					<td><%=cdo.getColValue("tipo_aju_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_ben_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("nombre_beneficiario")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
				<%=fb.hidden("tipo_aju"+i,cdo.getColValue("tipo_aju"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%
				}
				%>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fg",fg)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("tipo_aju",tipo_aju)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fg",fg)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("tipo_aju",tipo_aju)%>
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
%>