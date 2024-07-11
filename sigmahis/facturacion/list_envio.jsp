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
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sql= new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
int iconHeight = 40;
int iconWidth = 40;
String  file837= "N";
String  printFiscalCorp= "N";
try {file837 =java.util.ResourceBundle.getBundle("issi").getString("file837");}catch(Exception e){ file837 = "N";}
try {printFiscalCorp =java.util.ResourceBundle.getBundle("issi").getString("printFiscalCorporacion");}catch(Exception e){ printFiscalCorp = "N";}

if(fg==null) fg = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 50;
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

  String factura   = "", fDate="", tDate="", feFDate="", feTDate="", aseguradora="", aseguradora_desc="", enviado="",id="", lista = "", fRecCxcFrom = "", fRecCxcTo = "", fRecFrom = "", fRecTo = "";
	if(request.getParameter("factura")!=null) factura = request.getParameter("factura");
	if(request.getParameter("aseguradora")!=null) aseguradora = request.getParameter("aseguradora");
	if(request.getParameter("aseguradora_desc")!=null) aseguradora_desc = request.getParameter("aseguradora_desc");
	if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
	if(request.getParameter("feFDate")!=null) feFDate = request.getParameter("feFDate");
	if(request.getParameter("feTDate")!=null) feTDate = request.getParameter("feTDate");
	if(request.getParameter("enviado")!=null) enviado = request.getParameter("enviado");
	if(request.getParameter("lista")!=null) lista = request.getParameter("lista");
	if(request.getParameter("id")!=null) id = request.getParameter("id");
	if(request.getParameter("fRecCxcFrom")!=null) fRecCxcFrom = request.getParameter("fRecCxcFrom");
	if(request.getParameter("fRecCxcTo")!=null) fRecCxcTo = request.getParameter("fRecCxcTo");
	if(request.getParameter("fRecFrom")!=null) fRecFrom = request.getParameter("fRecFrom");
	if(request.getParameter("fRecTo")!=null) fRecTo = request.getParameter("fRecTo");
	
	
	String cds = request.getParameter("cds");
	String categoria = request.getParameter("categoria");
	if (cds == null) cds = "";
	if(categoria==null) categoria = "";

  if (!factura.trim().equals("")){
    sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed where a.id = ed.id and ed.factura like '");
		sbFilter.append(factura);
		sbFilter.append("%')");
  }
  if (!aseguradora.trim().equals("")){
    sbFilter.append(" and a.aseguradora = ");
		sbFilter.append(aseguradora);
  }
  if (!fDate.trim().equals("")){
    sbFilter.append(" and a.fecha_creacion >= to_date('");
		sbFilter.append(fDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!tDate.trim().equals("")){
    sbFilter.append(" and a.fecha_creacion <= to_date('");
		sbFilter.append(tDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!feFDate.trim().equals("")){
    sbFilter.append(" and a.fecha_envio >= to_date('");
		sbFilter.append(feFDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!feTDate.trim().equals("")){
    sbFilter.append(" and a.fecha_envio <= to_date('");
		sbFilter.append(feTDate);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!enviado.trim().equals("")){
    sbFilter.append(" and a.enviado = '");
		sbFilter.append(enviado);
		sbFilter.append("'");
  }
  if (!id.trim().equals("")){
      sbFilter.append(" and a.id = ");
  		sbFilter.append(id);
  }
  if (!lista.trim().equals("")){
      sbFilter.append(" and a.lista = ");
  		sbFilter.append(lista);
  }
		if (cds.trim().equalsIgnoreCase("")) {
			if (!UserDet.getUserProfile().contains("0")) {
				sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed, tbl_adm_admision ad where ed.id = a.id and ed.compania = a.compania and ed.pac_id = ad.pac_id and ed.admision = ad.secuencia and ed.compania = ad.compania and ad.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S') and ad.centro_servicio in (select cds from tbl_sec_user_cds where user_id=");
				sbFilter.append(UserDet.getUserId());
				sbFilter.append("))");
			}
		} else {
			sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed, tbl_adm_admision ad where ed.id = a.id and ed.compania = a.compania and ed.pac_id = ad.pac_id and ed.admision = ad.secuencia and ed.compania = ad.compania and ad.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S' ) and ad.centro_servicio = ");
			sbFilter.append(cds);
			sbFilter.append(")");
		}
		if(!categoria.equals("")){
			sbFilter.append(" and exists (select null from tbl_fac_lista_envio_det ed where ed.id = a.id and ed.compania = a.compania and ed.categoria = ");
			sbFilter.append(categoria);
			sbFilter.append(")");
		}
		
		if (!fRecCxcFrom.equals("") && !fRecCxcTo.equals("")) {
       sbFilter.append(" and trunc(a.fecha_recibido_cxc) between to_date('");
       sbFilter.append(fRecCxcFrom);
       sbFilter.append("', 'dd/mm/yyyy') and to_date('");
       sbFilter.append(fRecCxcTo);
       sbFilter.append("', 'dd/mm/yyyy')");
		}
		
		if (!fRecFrom.equals("") && !fRecTo.equals("")) {
       sbFilter.append(" and trunc(a.fecha_recibido) between to_date('");
       sbFilter.append(fRecFrom);
       sbFilter.append("', 'dd/mm/yyyy') and to_date('");
       sbFilter.append(fRecTo);
       sbFilter.append("', 'dd/mm/yyyy')");
		}
		
			if(request.getParameter("feFDate")!=null){
  sql.append("select a.enviado, to_char(a.fecha_recibido, 'dd/mm/yyyy')as  fecha_recibido, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_modificacion, to_char(a.system_date, 'dd/mm/yyyy') system_date, to_char(a.fecha_creacion, 'dd/mm/yyyy') as fecha_creacion, a.usuario_creacion, a.enviado_por, a.comentario, a.lista, a.aseguradora, (select nombre from tbl_adm_empresa e where e.codigo = a.aseguradora) aseguradora_desc, to_char(a.fecha_envio, 'dd/mm/yyyy') as fecha_envio, a.compania, a.id, (select name from tbl_sec_users where user_name = a.usuario_creacion) usuario_creacion_name, decode(a.enviado, 'S', 'Si', 'N', 'No', a.enviado) enviado_desc, nvl((select name from tbl_sec_users where user_name = a.enviado_por ), '') enviado_por_name,(case when a.aseguradora in (select column_value from table(select split((select get_sec_comp_param(a.compania,'COD_EMP_AXA') from dual),',') from dual))  then 'S' else 'N' end ) is_axa, join(cursor((select distinct descripcion from tbl_cds_centro_servicio cds where exists (select null from tbl_adm_admision adm where adm.centro_servicio = cds.codigo and adm.compania = cds.compania_unorg and exists (select null from tbl_fac_lista_envio_det ld where ld.pac_id = adm.pac_id and ld.admision = adm.secuencia and ld.id = a.id and ld.compania = a.compania)))), ', ') area_admite ,to_char(a.fecha_recibido_cxc, 'dd/mm/yyyy')as  fecha_recibido_cxc,nvl((select genera_archivo from tbl_adm_empresa e where e.codigo = a.aseguradora),'N') as genera_file, (select ruc from tbl_adm_empresa e where e.codigo = a.aseguradora) ruc, (case when exists (select null from tbl_fac_dgi_documents d where d.compania = a.compania and d.lista_envio = a.id and nvl(d.impreso, 'N') = 'Y') then 'S' else 'N' end) as impreso_dgi, (select max(id) from tbl_fac_dgi_documents d where d.compania = a.compania and d.lista_envio = a.id) doc_id, nvl(fact_corp, 'N') fact_corp, a.estado from tbl_fac_lista_envio a ");
  sql.append(" where a.compania = ");
  sql.append(session.getAttribute("_companyId"));
  sql.append(sbFilter.toString());
  sql.append(" order by a.fecha_creacion desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql.toString()+")");
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
document.title = 'Facturacion - '+document.title;
var xHeight=0;
function printList(bi){
  if(!bi)abrir_ventana('../facturacion/print_list_envio.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>');
  else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/print_list_envio.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=true');
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=consFact');}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  var msg='&nbsp;';
  switch(option)
  {
		case 0:msg='Registrar Lista de Envío';break;
		case 1:msg='Editar Lista de Envío';break;
		case 2:msg='Ver Lista de Envío';break;
		case 3:msg='Imprimir Lista de Envío';break;
		case 4:msg='Ver listado de Facturas';break;
		case 5:msg='Registrar fecha de Recibido';break;
		case 6:msg='Generar archivo para aseguradora';break;
		case 7:msg='Generar Documentos ASEG.';break;
		case 8:msg='Registrar fecha de Recibido cxc';break;
		case 9:msg='Imprimir Fiscalmente';break;
		case 10:msg='Registrar Lista de Envío Corporativa';break;
		case 11:msg='Lista de Envío Corporativa quitar Impreso SI';break;

  }
  setoverc(obj,'ImageBorderOver');
  optDescObj.innerHTML=msg;
  obj.alt=msg;
}
function goOption(option)
{
	if(option==0)abrir_ventana('../facturacion/reg_lista_envio.jsp?mode=add&fg=<%=fg%>');
	else if(option==4)showReport();
	else{
		if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
		else if(option==10) abrir_ventana('../facturacion/reg_lista_envio.jsp?mode=add&fact_corp=S&fg=<%=fg%>');
		else
		{
			var k=document.form0.index.value;
			var id = eval('document.form0.id'+k).value;
			var fact_corp = eval('document.form0.fact_corp'+k).value;
			if(k=='')CBMSG.warning('Por favor seleccione una Lista antes de ejecutar una acción!');
			else
			{
				if(option==1)abrir_ventana1('../facturacion/reg_lista_envio.jsp?mode=edit&id='+id+'&fact_corp='+fact_corp);
				else if(option==2)abrir_ventana1('../facturacion/reg_lista_envio.jsp?mode=view&id='+id+'&fact_corp='+fact_corp);
				else if(option==3)abrir_ventana1('../facturacion/print_list_envio_aseg.jsp?id='+id);
				else if(option==5){
					if(eval('document.form0.enviado'+k).value=='S')showPopWin('../common/run_process.jsp?fp=LISTA_ENVIO&actType=1&docType=LISTA_ENVIO&compania=<%=(String) session.getAttribute("_companyId")%>&docId='+id+'&docNo='+id,winWidth*.75,winHeight*.65,null,null,'');
					 else CBMSG.warning('La lista debe enviarse a la aseguradora antes de registrar fecha de recibido!');
				}
				else if(option==6){
					if(eval('document.form0.is_axa'+k).value=='S') {
					//CBMSG.prompt("Intoduzco No. Secuencia",{cb:function(r,v){ $(v).each( function(i,o) { debug(o.name+" "+o.value)  } )     } })
					var aseg =eval('document.form0.aseguradora'+k).value;
					var noSecuencia = prompt('Introduzca No. Secuencia:','');
					abrir_ventana('../facturacion/axa837.jsp?mode=add&id='+id+'&noSecuencia='+noSecuencia+'&aseg='+aseg);

					}else {
					if(eval('document.form0.genera_file'+k).value=='S'){
					var aseg =eval('document.form0.aseguradora'+k).value;
					showPopWin('../common/generate_file.jsp?fp=ASEGFILE&actType=1&docType=ASEGFILE&compania=<%=(String) session.getAttribute("_companyId")%>&id='+id+'&aseguradora='+aseg,winWidth*.75,winHeight*.65,null,null,'');
					}
					else CBMSG.warning('Opcion solo para empresas que Generan archivos !');
					}
				}else if(option==7){if(eval('document.form0.genera_file'+k).value=='S' || eval('document.form0.is_axa'+k).value=='S'){showPopWin('../facturacion/print_doctos_aseg.jsp?listId='+id+'&es_axa='+eval('document.form0.is_axa'+k).value,winWidth*.95,winHeight*.75,null,null,'');}else{CBMSG.warning('Opcion solo para empresas que Generan archivos !');}}
				else if(option==8){var fecha = eval('document.form0.fecha_creacion'+k).value;var fechaEnvio= eval('document.form0.fecha_envio'+k).value;showPopWin('../process/fact_fecha_rec_cxc.jsp?id='+id+'&fecha='+fecha+'&fechaEnvio='+fechaEnvio,winWidth*.75,winHeight*.65,null,null,'');}
				else if(option==9){
					
				} 
				else if(option==11){
					if(eval('document.form0.fact_corp'+k).value=='S' && eval('document.form0.impreso_dgi'+k).value == 'S')
					showPopWin('../process/fact_quitar_impreso_si.jsp?id='+id,winWidth*.75,winHeight*.65,null,null,'');
					else alert('Permitido solo para listas de Facturación Corporativas Impresas Fiscalmente!');
				}
			}
		}
  }
}
function printFistal(k, flag){
	var aseguradora = eval('document.form0.aseguradora_desc'+k).value;
	var ruc = eval('document.form0.ruc'+k).value;
	var id = eval('document.form0.id'+k).value;
	var doc_id = eval('document.form0.doc_id'+k).value;
	if (flag=='P') showPopWin('../common/run_process.jsp?fp=lista_envio&actType=2&docType=DGI&docId='+id+'&docNo='+id+'&tipo=FAC&identificacion_2='+ruc+'&id_lista='+id+'&nombre_2='+aseguradora,winWidth*.75,winHeight*.65,null,null,'');
	else if (flag=='R')showPopWin('../common/run_process.jsp?fp=lista_envio&actType=5&docType=DGI&docId='+doc_id+'&docNo='+doc_id+'&tipo=FAC&identificacion_2='+ruc+'&id_lista='+id+'&nombre_2='+aseguradora,winWidth*.75,winHeight*.65,null,null,'');
}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function addAseguradora(){
	abrir_ventana1('../common/search_empresa.jsp?fp=list_envio');
}
function showReport(){
	var aseguradora 		= document.search01.aseguradora.value;
	var aseguradora_desc 		= document.search01.aseguradora_desc.value;
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
	var enviado 			= document.search01.enviado.value;
	var fRecCxcFrom 			= document.search01.fRecCxcFrom.value;
	var fRecFrom 			= document.search01.fRecFrom.value;
	if(enviado=='') CBMSG.warning('Seleccionar facturas enviadas Si/No!');
	else if(aseguradora=='') CBMSG.warning('Seleccione Aseguradora!');
	else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/list_aseguradora.rptdesign&enviadoParam='+enviado+'&aseguradoraParam='+aseguradora+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&aseguradoraDescParam='+aseguradora_desc+'&fRecCxcFrom='+fRecCxcFrom+'&fRecFrom='+fRecFrom);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 <jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - LISTAS DE ENVIO"></jsp:param>
</jsp:include>
 <table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
  <tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/checklist.png"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/lista_envio.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/search.gif"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/printer.gif"></a></authtype>
		<!--<authtype type='50'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/invoice.png"></a></authtype>-->
		<authtype type='52'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/invoice.png"></a></authtype>
		<%if(file837.trim().equals("S")){%>
		<authtype type='51'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/AirMail.png"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(7)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/gen_doc_aseg.jpg"></a></authtype>
		<%}%>
		<authtype type='54'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/calendar_refresh.png"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(10)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/checklist.png"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(11)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/anular_factura_impresa_fiscal.png"></a></authtype>

		</td>
	</tr>

  <tr>
    <td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("fg",fg)%>
        <tr class="TextFilter">
        <td>
				<cellbytelabel>No. Factura</cellbytelabel><%=fb.textBox("factura",factura,false,false,false,10)%>
				&nbsp;&nbsp;
				<cellbytelabel>Empresa</cellbytelabel>
				<%=fb.hidden("aseguradora", aseguradora)%>
				<%=fb.textBox("aseguradora_desc",aseguradora_desc,false,false,true,36,"Text10",null,null)%>
				<%=fb.button("btnAseguradora","...",true,false,null,null,"onClick=\"javascript:addAseguradora()\"")%>
				&nbsp;&nbsp;
				<cellbytelabel>F. Creaci&oacute;n</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="nameOfTBox2" value="tDate" />
				<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				&nbsp;&nbsp;
				<cellbytelabel>F. Envio</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="feFDate" />
				<jsp:param name="valueOfTBox1" value="<%=feFDate%>" />
				<jsp:param name="nameOfTBox2" value="feTDate" />
				<jsp:param name="valueOfTBox2" value="<%=feTDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
				<td colspan="3">
						<%StringBuffer sbSql = new StringBuffer();
					if (!UserDet.getUserProfile().contains("0")) { sbSql.append(" and codigo in (select cds from tbl_sec_user_cds where user_id="); sbSql.append(UserDet.getUserId()); sbSql.append(")"); }
					%>
				<cellbytelabel id="1">&Aacute;rea</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_cds_centro_servicio where si_no = 'S' and estado='A' "+sbSql.toString()+" order by 2 asc","cds",cds,false,false,0,"Text10","width:175px",null,null,"T")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No. Lista: <%=fb.textBox("lista",lista,false,false,false,10,"Text10",null,null)%>&nbsp;Lista ID: <%=fb.textBox("id",id,false,false,false,10,"Text10",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;
					Cat. Admisi&oacute;n:
					<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_adm_categoria_admision order by codigo asc","categoria",categoria,false,false,0,null,null,null, "", "S")%>
					&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Enviado</cellbytelabel>
				<%=fb.select("enviado","S=Si,N=No",enviado,false,false,0,"Text10",null,null,null,"S")%>
				</td>
		</tr>
		
		<tr class="TextFilter">
				<td colspan="3">
						
					<cellbytelabel>Fecha CxC</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fRecCxcFrom" />
				<jsp:param name="valueOfTBox1" value="<%=fRecCxcFrom%>" />
				<jsp:param name="nameOfTBox2" value="fRecCxcTo" />
				<jsp:param name="valueOfTBox2" value="<%=fRecCxcTo%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel>F. Recibido</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fRecFrom" />
				<jsp:param name="valueOfTBox1" value="<%=fRecFrom%>" />
				<jsp:param name="nameOfTBox2" value="fRecTo" />
				<jsp:param name="valueOfTBox2" value="<%=fRecTo%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>	
						
						
						&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.submit("go","Ir")%></td>
		</tr>
		
		
		
		<%=fb.formEnd(true)%>
      </table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

    </td>
  </tr>
  <tr>
    <td align="right">
        <authtype type='0'>
          <a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
          <a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a>
        </authtype>
    </td>
  </tr>
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
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
			<%=fb.hidden("fRecCxcFrom",fRecCxcFrom)%>
			<%=fb.hidden("fRecCxcTo",fRecCxcTo)%>
			<%=fb.hidden("fRecFrom",fRecFrom)%>
			<%=fb.hidden("fRecTo",fRecTo)%>
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
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
			<%=fb.hidden("fRecCxcFrom",fRecCxcFrom)%>
			<%=fb.hidden("fRecCxcTo",fRecCxcTo)%>
			<%=fb.hidden("fRecFrom",fRecFrom)%>
			<%=fb.hidden("fRecTo",fRecTo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<%=fb.formEnd()%>
      </tr>
    </table>
  </td>
</tr>
<tr>
  <td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

    <table align="center" width="100%" cellpadding="0" cellspacing="1">
    <tr class="TextHeader" align="center">
			<td width="17%"><cellbytelabel>Aseguradora</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel>.</td>
			<td width="6%"><cellbytelabel>Fecha CXC</cellbytelabel>.</td>
			<td width="5%"><cellbytelabel>Lista/ID</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Enviado</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Envio</cellbytelabel></td>
			<td width="14%"><cellbytelabel>Enviado por</cellbytelabel></td>
			<td width="6%"><cellbytelabel>F. Recibido</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Area Admite</cellbytelabel></td>
			<%if(printFiscalCorp.equals("S")){%>
			<td width="5%">&nbsp;</td>
			<%}%>
			<td width="3%">&nbsp;</td>
    </tr>
		<%
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
		%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("is_axa"+i,cdo.getColValue("is_axa"))%>
		<%=fb.hidden("enviado"+i,cdo.getColValue("enviado"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%=fb.hidden("fecha_envio"+i,cdo.getColValue("fecha_envio"))%>
		<%=fb.hidden("genera_file"+i,cdo.getColValue("genera_file"))%>
		<%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>
		<%=fb.hidden("aseguradora_desc"+i,cdo.getColValue("aseguradora_desc"))%>
		<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
		<%=fb.hidden("doc_id"+i,cdo.getColValue("doc_id"))%>
		<%=fb.hidden("fact_corp"+i,cdo.getColValue("fact_corp"))%>
		<%=fb.hidden("impreso_dgi"+i,cdo.getColValue("impreso_dgi"))%>

    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
      <td align="center"><%=cdo.getColValue("aseguradora_desc")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
      <td align="center"><%=cdo.getColValue("usuario_creacion_name")%></td>
	  <td align="center"><%=cdo.getColValue("fecha_recibido_cxc")%></td>
      <td align="center"><%=cdo.getColValue("lista")%>&nbsp;&nbsp;[<%=cdo.getColValue("id")%>]</td>
      <td align="center"><%=cdo.getColValue("enviado_desc")%></td>
      <td align="center"><%=cdo.getColValue("fecha_envio")%></td>
      <td align="center"><%=cdo.getColValue("enviado_por_name")%></td>
	  <td align="center"><%=cdo.getColValue("fecha_recibido")%></td>
      <td align="center"><%=cdo.getColValue("area_admite")%></td>
      <%if(printFiscalCorp.equals("S")){%>
			<td align="center">
      <%if(cdo.getColValue("fact_corp").equals("S") && cdo.getColValue("estado").equals("A")){%>
			<authtype type='55'>
			<%if(cdo.getColValue("impreso_dgi").equals("N")){%>
			<a href="javascript:printFistal(<%=i%>, 'P')"><img height="20" width="20" class="ImageBorder" src="../images/printer.gif"></a>
			<%} else {%>
			<a href="javascript:printFistal(<%=i%>, 'R')"><img height="20" width="20" class="ImageBorder" src="../images/imprimir_copia.png"></a>
			<%}%>
			</authtype>
			<%}%>
			</td>
			<%}%>
			<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
    </tr>
<%
}
%>
    </table>
<%=fb.formEnd()%>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
			<%=fb.hidden("fRecCxcFrom",fRecCxcFrom)%>
			<%=fb.hidden("fRecCxcTo",fRecCxcTo)%>
			<%=fb.hidden("fRecFrom",fRecFrom)%>
			<%=fb.hidden("fRecTo",fRecTo)%>
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
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("aseguradora",aseguradora)%>
			<%=fb.hidden("aseguradora_desc",aseguradora_desc)%>
			<%=fb.hidden("fDate",fDate)%>
			<%=fb.hidden("tDate",tDate)%>
			<%=fb.hidden("enviado",enviado)%>
			<%=fb.hidden("feFDate",feFDate)%>
			<%=fb.hidden("feTDate",feTDate)%>
			<%=fb.hidden("categoria",categoria)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("lista",lista)%>
			<%=fb.hidden("fRecCxcFrom",fRecCxcFrom)%>
			<%=fb.hidden("fRecCxcTo",fRecCxcTo)%>
			<%=fb.hidden("fRecFrom",fRecFrom)%>
			<%=fb.hidden("fRecTo",fRecTo)%>
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
