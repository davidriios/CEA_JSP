<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
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
CompMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String consecutivo = request.getParameter("consecutivo");
String anio = request.getParameter("ea_ano");
String clase = request.getParameter("clase_comprob");
String mes = request.getParameter("mes");
String regType = request.getParameter("regType");
String estado = request.getParameter("estado");
if (consecutivo == null) consecutivo = "";
if (anio == null) anio = "";
if (clase == null) clase = "";
if (mes == null) mes = "";
if (regType == null) regType = "";
if (estado == null) estado = "";

String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (fp == null) fp = "";
String date = CmnMgr.getCurrentDate("dd/mm/yyyy");
int iconHeight = 40;
int iconWidth = 40;

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!anio.trim().equals("")) { sbFilter.append(" and a.ea_ano = "); sbFilter.append(anio); }
	if(request.getParameter("ea_ano") ==null) anio = date.substring(6,10);
	if (!consecutivo.trim().equals("")) { sbFilter.append(" and a.consecutivo = "); sbFilter.append(consecutivo); }
	if (!clase.trim().equals("")) { sbFilter.append(" and clase_comprob = "); sbFilter.append(clase); }
	if (!mes.trim().equals("")) { sbFilter.append(" and a.mes = "); sbFilter.append(mes); }
	if (!regType.trim().equals("")) { sbFilter.append(" and a.reg_type = '");sbFilter.append(regType);sbFilter.append("'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.status = '");sbFilter.append(estado);sbFilter.append("'"); }

	String tableName = "";
	tableName = "tbl_con_encab_comprob";
	if (fg.equalsIgnoreCase("CD")) sbFilter.append(" and  a.status = 'PE'");

	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select a.ea_ano, a.consecutivo, a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE',13,'CIERRE ANUAL') as mes, a.mes as mes_cons, a.clase_comprob, a.descripcion, (select nombre_corto from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo =decode('"+fg+"','PLA','P','C')) as comprob_desc, a.total_cr, a.total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario,nvl(a.usuario_creacion,a.usuario) as usuario_creacion, to_char(nvl(a.fecha_creacion,fecha_comp),'dd/mm/yyyy') as fecha_creacion, a.creado_por,(select estado from tbl_con_estado_anos where cod_cia = a.compania and ano =a.ea_ano) estadoAnio, a.estado,case when a.consecutivo < 0 or a.ea_ano < (select z.ano from tbl_con_estado_anos z where z.estado ='ACT' and z.cod_cia =a.compania)-1 then 'N' else 'S' end as anular,(select estatus from tbl_con_estado_meses where ano=a.ea_ano and cod_cia=a.compania and mes = a.mes) estadoMes,decode(a.status,'AP','APROBADO','PE','PENDIENTE','DE','DESAPROB.') descStatus, a.tipo, a.reg_type as regType, decode(a.reg_type,'D','COMP. DIARIO','H','COMP. HIST.') regTypeDesc,decode(a.total_db,total_cr,1,0) as fg ");
		sbSql.append(" from ");
		sbSql.append(tableName);
		sbSql.append(" a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by a.ea_ano desc, a.mes desc, a.consecutivo desc");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);

	if(request.getParameter("ea_ano") !=null){
	al = SQLMgr.getDataList(sbSql);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) count from ");
	sbSql.append(tableName);
	sbSql.append(" a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());
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
var ignoreSelectAnyWhere = true;
document.title = 'Comprobante <%=(fg.equals("CD"))?"Aprobacion de Comprobantes":""%> - '+document.title;
function add(regType){abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode=add&fg=<%=fg%>&fp=<%=fp%>&tipo=1&regType='+regType);}
function edit(id,anio,tipo,regType,mode,fp){abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode='+mode+'&no='+id+'&fg=<%=fg%>&fp='+fp+'&anio='+anio+'&tipo='+tipo+'&regType='+regType);}
function app(k,status,fp){var anio = eval('document.form1.ea_ano'+k).value;var id = eval('document.form1.consecutivo'+k).value;var mes = eval('document.form1.mes'+k).value;var tipo = eval('document.form1.tipo'+k).value;var total_cr = eval('document.form1.total_cr'+k).value;var total_db = eval('document.form1.total_db'+k).value;var claseComprob = eval('document.form1.claseComprob'+k).value; var creado_por = eval('document.form1.creado_por'+k).value; var x=0; if(status !='DE'){	if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_anos','ano='+anio+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and estado in (\'ACT\',\'TRS\')',''))	{		alert('Este año no existe o no está Activo o en Transicion!');x++;	}else if( claseComprob !='21' && claseComprob !='22' && claseComprob !='25' && status !='DE'){if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_meses','ano='+anio+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and mes = '+mes+' and estatus=\'ACT\'','')){alert('Este mes no existe o no está Activo!');x++;}}if(total_db!=total_cr){alert('El Comprobante no está Balanceado');x++;}else if(total_db==total_cr&&total_db==0.00){alert('El Balance no puede ser igual a Cero (0)');x++;}}
	if(x==0){if(fp=='AP')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=50&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');
	else if(fp=='DE')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=51&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');
	else if(fp=='AN')showPopWin('../common/run_process.jsp?fp=COMPDIARIO&actType=52&docType=COMPDIARIO&docId='+id+'&docNo='+id+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes+'&tipo='+tipo+'&comprob='+claseComprob+'&creadoPor='+creado_por,winWidth*.75,winHeight*.60,null,null,'');}}
function cerrar(consecutivo,anio,mes,fg,tipo){var actType ='';if(fg=='AP')actType='6';else actType ='7';showPopWin('../common/run_process.jsp?fp=comp_hist&actType='+actType+'&docType=COMP_HIST&docId='+consecutivo+'&docNo='+consecutivo+'&anio='+anio+'&mes='+mes+'&tipo='+tipo,winWidth*.75,winHeight*.60,null,null,'');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
function anularCH(anio,mes,id,tipo){if(confirm('Estimado usuario, está usted seguro de ANULAR el comprobante Historico # '+id+' del año '+anio+'!')){showPopWin('../common/run_process.jsp?fp=comp_hist&actType=50&docType=COMP_HIST&docId='+id+'&docNo='+id+'&anio='+anio+'&mes='+mes+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.60,null,null,'');}else alert('Proceso cancelado');}
function detalle(id,anio,tipo,clase){abrir_ventana('../contabilidad/ver_comp_diario.jsp?mode=view&no='+id+'&fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&tipo='+tipo+'&claseComp='+clase);}
function setIndex(k){document.form1.index.value=k;checkOne('form1','check',<%=al.size()%>,eval('document.form1.check'+k),0);
if(!eval('document.form1.checkAP'+k).checked)eval('document.form1.checkAP'+k).checked =true;

}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 1:msg='Editar';break;
		case 2:msg='Aprobar Comprobante';break;
		case 5:msg='Ver';break;
		case 6:msg='Imprimir Comprobante Detallado';break;
		case 13:msg='Imprimir Comprobante Resumido';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0||option==9){if(option==0)add('D');else if(option==9)add('H');}
	else
	{
		if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
		else
		{
			var k=document.form1.index.value;
			if(k==''&&option!='2')alert('Por favor seleccione un Comprobante antes de ejecutar una acción!');
			else
			{
				if(option!='2'){
				var anio = eval('document.form1.anio'+k).value;
				var mes = eval('document.form1.mes'+k).value;
				var id = eval('document.form1.id'+k).value;
				var tipo = eval('document.form1.tipo'+k).value;
				var regType = eval('document.form1.regType'+k).value;
				var estado = eval('document.form1.estado'+k).value;
				var status = eval('document.form1.status'+k).value;
				var stdAnio = eval('document.form1.estadoAnio'+k).value;
				var anular = eval('document.form1.anular'+k).value;}
				var  descAnio = '';
				if(stdAnio=='CER')descAnio='CERRADO ';
				else if(stdAnio=='INA')descAnio='INACTIVO ';		
				
				
				if(option==1){if(status='PE'){if(tipo=='1')edit(id,anio,tipo,regType,'edit','AP');else alert('Solo para Comprobante Original.');}else alert('El estado del registro Seleccionado, no permite está Accion');}
				else if(option==2)
				{ 
					if(ckeckEstado()){document.form1.submit();}
				}
				else if(option==5)edit(id,anio,tipo,regType,'view','<%=fp%>');
				else if(option==6)printComprob(anio,mes,id,tipo,regType,'DET');
				else if(option==13)printComprob(anio,mes,id,tipo,regType,'RES');
			}
		}
	}
}
function printComprob(anio,mes,id,tipo,regType,tipoRep){ if(tipoRep=='DET')abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);else if(tipoRep=='RES')abrir_ventana('../contabilidad/print_comprob_resumido.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);}
function ckeckEstado()
{
var w=0;var x=0;var y=0;var z=0;var p=0;var b=0; var d=0;
	  for(k=0;k<<%=al.size()%>;k++)
	  {
			if(eval('document.form1.checkAp'+k).checked)
			{
				var anio = eval('document.form1.anio'+k).value;
				var mes = eval('document.form1.mes'+k).value;
				var id = eval('document.form1.id'+k).value;
				var tipo = eval('document.form1.tipo'+k).value;
				var regType = eval('document.form1.regType'+k).value;
				var estado = eval('document.form1.estado'+k).value;
				var status = eval('document.form1.status'+k).value;
				var stdAnio = eval('document.form1.estadoAnio'+k).value;
				var anular = eval('document.form1.anular'+k).value;
				var  descAnio = '';
				if(stdAnio=='CER')descAnio='CERRADO ';
				else if(stdAnio=='INA')descAnio='INACTIVO ';	
				
				if(regType.trim()=='D')
				{
					if(stdAnio.trim() !='CER' && stdAnio.trim() !='INA')
					{
						if(status.trim()!='PE')z++;
						if(ckeckStatus(anio,mes))w++;
					}
					else{ /*alert('Estado de año Invalido para está Accion - '+descAnio+'!!'); */x++;}
				}
				else if(regType.trim()=='H')
				{	
					if((stdAnio.trim() =='CER' || stdAnio.trim() =='TRS') && anular.trim()=='S')
					{
						if(status.trim()!='PE')z++;
					}else{/* alert('Estado de año Invalido para está Accion - '+descAnio+'!!');*/y++;}
				}
				var total_cr = eval('document.form1.total_cr'+k).value;var total_db = eval('document.form1.total_db'+k).value;
				if(total_db!=total_cr){b++;}
				else if(total_db==total_cr&&total_db==0.00){d++;}
				p++;
			}//checked
	  }
	  if(z>0){alert('Existen registros con Estados invalidos para este proceso!');return false;}
	  if(w>0){alert('Existen registros con Estados de Meses invalidos para este proceso. Estado de mes debe ser [ACTIVO]!');return false;}
	  if(x>0){alert('Existen COMPROBANTES DIARIOS donde el Estado del Año es invalido para este proceso. El Año debe estar [ACTIVO]!');return false;}
	  if(y>0){alert('Existen COMPROBANTES HISTORICOS donde el Estado del Año es invalido para este proceso. El Año debe estar [CERRADO/TRANSICION]!');return false;}
	  if(p==0){alert('No hay Registros Seleccionados!');return false;}
	  if(b>0){alert('Existen Comprobantes que no está Balanceado. Verifique');return false;}
	  if(d>0){alert('Existen Comprobantes con Balance Cero (0). Favor Verifique!');return false;};
	  return true;
}
function ckeckStatus(anio,mes)
{
	if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_meses','ano='+anio+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and mes = '+mes+' and estatus=\'ACT\'',''))return true;else return false;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - REGISTRO COMPROBANTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;
	<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='1'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)"  src="../images/ver.png"></a></authtype>		
		<authtype type='4'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/editar.png"></a></authtype>	
		<authtype type='2'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/print_d.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(13)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)" src="../images/print_r.png"></a></authtype>	
		<authtype type='6'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/check_mark.png"></a></authtype>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
			<td>
				AÑO
				<%=fb.intBox("ea_ano",anio,false,false,false,10)%>
				MES:
				<%=fb.select("mes","1=Enero,2=Febrero,3=Marzo,4=Abril,5=Mayo,6=Junio,7=Julio,8=Agosto,9=Septiembre,10=Octubre,11=Noviembre,12=Diciembre,13=Cierre Anual",mes,false,false,0,"Text10",null,null,null,"T")%>
				ID
				<%=fb.intBox("consecutivo",consecutivo,false,false,false,10)%>
				Estado:<%=fb.select("estado","PE=PENDIENTE",estado,false,false,0,"Text10",null,null,null,"T")%>
				Clase
				<%=fb.select(ConMgr.getConnection(), "select codigo_comprob,codigo_comprob||' - '||substr(descripcion,1,65) as descripcion from tbl_con_clases_comprob where tipo='C'","clase_comprob",clase,false,false,0,"Text10",null,null,null,"S")%>
				T. Registro:<%=fb.select("regType","D=DIARIO,H=HISTORICO",regType,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("index","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("baction","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="3%">A&ntilde;o</td>
			<td width="6%">Id</td>
			<td width="7%">Mes</td>
			<td width="6%">F. Creaci&oacute;n</td>
			<td width="7%">U. Creaci&oacute;n</td>
			<td width="21%">Descripci&oacute;n</td>
			<td width="16%">Tipo Comprob.</td>
			<td width="8%">Total DB</td>
			<td width="8%">Total CR</td>
			<td width="7%">T. Registro</td>
			<td width="8%">Estado</td>
			<td width="1%">&nbsp;</td>
			<td width="1%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','checkAp',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados(APROBAR)!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("anio"+i,cdo.getColValue("ea_ano"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("consecutivo"))%>
		<%=fb.hidden("mes"+i,cdo.getColValue("mes_cons"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("total_cr"+i,cdo.getColValue("total_cr"))%>
		<%=fb.hidden("total_db"+i,cdo.getColValue("total_db"))%>
		<%=fb.hidden("claseComprob"+i,cdo.getColValue("clase_comprob"))%>
		<%=fb.hidden("creado_por"+i,cdo.getColValue("creado_por"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("anular"+i,cdo.getColValue("anular"))%>
		<%=fb.hidden("estadoAnio"+i,cdo.getColValue("estadoAnio"))%>
		<%=fb.hidden("estadoMes"+i,cdo.getColValue("estadoMes"))%>
		<%=fb.hidden("regType"+i,cdo.getColValue("regType"))%> 
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("ea_ano")%></td>
			<td align="center"><%if(!fg.trim().equals("PLA")){%><a href="javascript:printComprob(<%=cdo.getColValue("ea_ano")%>,<%=cdo.getColValue("mes_cons")%>,<%=cdo.getColValue("consecutivo")%>,<%=cdo.getColValue("tipo")%>,'<%=cdo.getColValue("regType")%>','DET')"><%}%><%=cdo.getColValue("consecutivo")%></a></td>
			<td align="center"><%=cdo.getColValue("mes")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
			<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td align="left"><%=cdo.getColValue("comprob_desc")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_db"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_cr"))%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("regTypeDesc")%></td>
			<td align="center"><!--<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("consecutivo")%>,<%=cdo.getColValue("ea_ano")%>,<%=cdo.getColValue("tipo")%>,'<%=cdo.getColValue("regType")%>','view')" class="Link02Bold">--><%=cdo.getColValue("descStatus")%><!--</a></authtype>--></td>			
			<td align="center"><%=fb.checkbox("check"+i,""+i,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
			<td align="center"><%=fb.checkbox("checkAp"+i,""+i,false,cdo.getColValue("fg").trim().equals("0"),null,null,"")%></td>
		</tr>
<%}%>
		</table>
<%=fb.formEnd(true)%>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
 <tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("ea_ano",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase_comprob",clase)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("regType",regType)%>
<%=fb.hidden("estado",estado)%>
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
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
ArrayList al1= new ArrayList();
String fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
 int size =Integer.parseInt(request.getParameter("size"));
 for(int i=0;i<size;i++)
 {
   if (request.getParameter("checkAp"+i) != null)
   {
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_con_encab_comprob");			
 		 	cdo.addColValue("consecutivo",request.getParameter("id"+i));
			cdo.addColValue("anio",request.getParameter("anio"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("tipo",request.getParameter("tipo"+i));
			cdo.addColValue("reg_type",request.getParameter("regType"+i));			
			cdo.addColValue("status","TR");//Estado temporal para el proceso de aprobacion...
			cdo.addColValue("usuario_aprob",(String) session.getAttribute("_userName"));
			cdo.addColValue("fg",fg);
			al1.add(cdo);
	}
 }
	/*if(al1.size() == 0)
	{
		 CommonDataObject cdo = new CommonDataObject();
		 cdo.setTableName("tbl_con_encab_comprob");
		 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" ");
		 al1.add(cdo);
	}*/
  	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());	
	CompMgr.aprobList(al1,fg);
	ConMgr.clearAppCtx(null);  
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CompMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CompMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/list_mg_aprob_comp.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/list_mg_aprob_comp.jsp")%>';
<%
	}
	else
	{
%> 
	window.location = '<%=request.getContextPath()%>/contabilidad/list_mg_aprob_comp.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(CompMgr.getErrMsg());
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
