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
==================================================================================
consulta de notas de ajustes
fp = REV  = reversion de incobrable
FP= CS = CONSULTA DE AJUSTES
==================================================================================
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
String sql = "";
String appendFilter = "";
String sqlCds = "";
String fp = request.getParameter("fp");
int iconHeight = 40;
int iconWidth = 40;
if(fp == null)fp="";
  
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

	String codigo  = "", cds="";  // variable para mantener el valor de los campos filtrados en la consulta
	String descrip = "",tipo_doc="",fecha_hasta="",fecha_desde="",factura="",paciente,recibo="",documento="",tipo_ajuste="", tipo_fecha="", estado="", tipoAjuste = "",grupo="";

	/*if(!UserDet.getUserProfile().contains("0")){//if (fp.equals("NA")) sqlCds = "select c.codigo, c.descripcion  from tbl_cds_centro_servicio c  where exists  ( select 'x' from tbl_cds_usuario_x_cds cu where upper(cu.usuario) = upper('"+session.getAttribute("_userName")+"')  and (crea_ajuste='S' or aprob_ajuste='S') and cu.cod_cds = c.codigo) order by c.descripcion ";
	}
	else sqlCds = "select c.codigo, c.descripcion  from tbl_cds_centro_servicio c order by c.descripcion";*/

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(c.nota_ajuste) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");   // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(c.explicacion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion");   // utilizada para mantener la descripción de las notas de ajustes
  }

 	if (request.getParameter("tipo_fecha") != null && request.getParameter("tipo_fecha").trim().equals("A"))		// aprobacion
	{
 	  if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	  {
	    appendFilter += " and trunc(c.fecha_aprob) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
			fecha_desde    = request.getParameter("fecha_desde");   // utilizada para mantener la descripción de las notas de ajustes
	  }
	  if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	  {
	    appendFilter += " and trunc(c.fecha_aprob) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
			fecha_hasta    = request.getParameter("fecha_hasta");   // utilizada para mantener la descripción de las notas de ajustes
	  }
	  tipo_fecha = request.getParameter("tipo_fecha");
 	}
 	else if (request.getParameter("tipo_fecha") != null && request.getParameter("tipo_fecha").trim().equals("C"))  // creacion 0 rechazados
 	{
 	  if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	  {
	    appendFilter += " and trunc(c.fecha) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
			fecha_desde    = request.getParameter("fecha_desde");   // utilizada para mantener la descripción de las notas de ajustes
	  }
	  if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	  {
	    appendFilter += " and trunc(c.fecha) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
			fecha_hasta    = request.getParameter("fecha_hasta");   // utilizada para mantener la descripción de las notas de ajustes
	  }
	  tipo_fecha = request.getParameter("tipo_fecha");
	}
/*
  if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
  {
    appendFilter += " and trunc(c.fecha) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
	fecha_desde    = request.getParameter("fecha_desde");   // utilizada para mantener la descripción de las notas de ajustes
  }
  if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
  {
    appendFilter += " and trunc(c.fecha) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
	fecha_hasta    = request.getParameter("fecha_hasta");   // utilizada para mantener la descripción de las notas de ajustes
  }
*/
  if (request.getParameter("tipo_doc") != null && !request.getParameter("tipo_doc").trim().equals(""))
  {
    appendFilter += " and c.tipo_doc = '"+request.getParameter("tipo_doc")+"'";
	tipo_doc    = request.getParameter("tipo_doc");   // utilizada para mantener la descripción de las notas de ajustes
  }
  if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals(""))
  {
    appendFilter += " and c.factura = '"+request.getParameter("factura")+"'";
	factura    = request.getParameter("factura");
  }/* */
  if (request.getParameter("recibo") != null && !request.getParameter("recibo").trim().equals(""))
  {
    appendFilter += " and c.recibo = '"+request.getParameter("recibo")+"'";
	recibo    = request.getParameter("recibo");
  }
  if (request.getParameter("documento") != null && !request.getParameter("documento").trim().equals(""))
  {
    appendFilter += " and c.referencia = '"+request.getParameter("documento")+"'";
	documento    = request.getParameter("documento");
  }
  /*if (request.getParameter("tipo_ajuste") != null && !request.getParameter("tipo_ajuste").trim().equals(""))
  {
    appendFilter += " and c.tipo_ajuste = '"+request.getParameter("tipo_ajuste")+"'";
	tipo_ajuste    = request.getParameter("tipo_ajuste");
  }*/
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
  {
    appendFilter += " and c.status = '"+request.getParameter("estado")+"'";
		estado    = request.getParameter("estado");
  }
  if (request.getParameter("cds") != null && !request.getParameter("cds").trim().equals(""))
  {
    appendFilter += " and c.cds = '"+request.getParameter("cds")+"'";
	cds    = request.getParameter("cds");
  } 
  /*if (request.getParameter("cds") != null && !request.getParameter("cds").trim().equals(""))
  {
  		//if(!UserDet.getUserProfile().contains("0")){if (fp.equals("NA")) appendFilter += " and c.cds in (select c.codigo  from tbl_cds_centro_servicio c  where exists  ( select 'x' from tbl_cds_usuario_X_cds cu  where upper(cu.usuario) = upper('"+session.getAttribute("_userName")+"')  and (crea_ajuste='S' or aprob_ajuste='S') and cu.cod_cds = c.codigo)) ";}
  if (!UserDet.getUserProfile().contains("0")) {
  //appendFilter += " and ( c.tipo_ajuste in  ( select idAjuste from tbl_sec_user_adjustment where user_id = "+UserDet.getUserId()+" and compania = "+(String) session.getAttribute("_companyId")+" and( aprobAjuste ='S' or creaAjuste ='S')) or c.cds in (select cod_cds from tbl_cds_usuario_x_cds where aprob_ajuste ='S' or crea_ajuste ='S' and usuario='"+session.getAttribute("_userName")+"') )"; 
  		}
   }*/
   if (fp.equals("REV"))
   {
     appendFilter += " and t.codigo in (select param_value    from  tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name ='COD_AJ_INCOB')";
   }
   
   
   //if (fp.equalsIgnoreCase("CS")){
      if (request.getParameter("tipo_ajuste_filter") != null && !request.getParameter("tipo_ajuste_filter").equals("")){
        tipoAjuste = request.getParameter("tipo_ajuste_filter");
        appendFilter += " and t.codigo = '"+request.getParameter("tipo_ajuste_filter")+"'";
      }
   //}
    if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")){
        grupo = request.getParameter("grupo");
        appendFilter += " and t.group_type = '"+request.getParameter("grupo")+"'";
      }
   
	if(request.getParameter("codigo") != null ){

  //sql = "SELECT distinct a.data_refer, a.COMPANIA, a.CODIGO, a.EXPLICACION,to_char(a.fecha,'dd/mm/yyyy')as fecha,decode(a.TIPO_DOC,'F', 'FACTURA', 'R','RECIBO') as TIPO_DOC,a.TIPO_AJUSTE, a.RECIBO, a.TOTAL, b.descripcion FROM  vw_con_adjustment a, tbl_fac_tipo_ajuste b,vw_con_adjustment_det c where  a.tipo_ajuste=b.codigo and a.codigo = c.nota_ajuste and a.compania = c.compania and a.data_refer = c.data_refer and b.compania="+ (String) session.getAttribute("_companyId")+" "+appendFilter+" order by a.codigo desc";
  
  sql = "select distinct c.fecha, c.data_refer, c.compania, c.nota_ajuste codigo, c.explicacion,to_char(c.fecha,'dd/mm/yyyy')as fecha_dsp,decode(c.tipo_doc,'F', 'FACTURA', 'R','RECIBO') as tipo_docDesc,c.tipo_doc,c.tipo_ajuste, c.recibo, c.total,t.descripcion||decode(c.data_refer,'N',decode(c.tipo_transac,'C',' - (CARGO)','D',' - (DEVOLUCION)')) descripcion, decode(c.status,'P','PENDIENTE','O','ABIERTO','C','CERRADO','A','APROBADO','R','RECHAZADO') as statusDesc,c.status, c.referencia, c.usuario_creacion, c.usuario_aprob,nvl(c.ref_reversion,'')ref_reversion,c.factura,c.tipo_transac tipo_transaccion,c.pac_id pacId, c.amision noAdmision, (case when c.data_refer in ('N', 'O') and exists (select null from tbl_cja_detalle_pago dp where dp.fac_codigo = c.ref_factura and dp.no_ajuste = c.nota_ajuste) then 'S' else 'N' end) ajustado,decode(c.lado_mov,'C','CRED','DEB') as ladoDesc, (select codigo||','||compania||','||anio||','''||tipo_cliente||'''' from tbl_cja_transaccion_pago where compania = c.compania and recibo = c.recibo) as rec_key, getDataAjustes(c.compania, c.tipo_doc, coalesce(c.factura, c.recibo), 'FECHA') fecha_factura, getDataAjustes(c.compania, c.tipo_doc, coalesce(c.factura, c.recibo), 'NOMBRE') nombre_en_factura, getDataAjustes(c.compania, c.tipo_doc, coalesce(c.factura, c.recibo), 'DOCUMENTO') no_factura, c.pac_id || '-'||c.amision expediente from tbl_fac_tipo_ajuste t,vw_con_adjustment_all c  where  c.tipo_ajuste=t.codigo and c.compania = t.compania and c.compania="+ (String) session.getAttribute("_companyId")+" "+appendFilter+" order by c.fecha desc, 2,3,4";
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	//rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_recuperacion_anestesia "+appendFilter);
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
<script language="javascript">
document.title = 'Listado de Notas de Ajustes- '+document.title;
function printList(){
abrir_ventana('../facturacion/print_list_notas_ajustes_cargo.jsp?fg=CS&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function printExcel(){
var tipoFechaParam = document.search01.tipo_fecha.value;
var desdeParam = document.search01.fecha_desde.value;
var hastaParam = document.search01.fecha_hasta.value;
var codParam = document.search01.codigo.value;
var tipoParam = document.search01.tipo_doc.value;
var facturaParam = document.search01.factura.value;
var reciboParam = document.search01.recibo.value;
var refParam = document.search01.documento.value;
var estadoParam = document.search01.estado.value||'ALL';
var tipoAjuParam = document.search01.tipo_ajuste_filter.value||'ALL';
var grupoParam = document.search01.grupo.value||'ALL';

abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_nota_ajuste_list.rptdesign&tipoFechaParam='+tipoFechaParam+'&desdeParam='+desdeParam+'&hastaParam='+hastaParam+'&codParam='+codParam+'&tipoParam='+tipoParam+'&facturaParam='+facturaParam+'&reciboParam='+reciboParam+'&refParam='+refParam+'&estadoParam='+estadoParam+'&tipoAjuParam='+tipoAjuParam+'&grupoParam='+grupoParam);	
}
function printListDet(){abrir_ventana1('../facturacion/print_nota_ajuste.jsp?fg=consulta&compania=<%=(String) session.getAttribute("_companyId")%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
  var optDescObj=document.getElementById('optDesc');
  var msg='&nbsp;';
  switch(option)
  {
    case 1:msg='Registrar';break;
    case 2:msg='Ver';break;
	case 3:msg='Editar';break;
	case 4:msg='Aprobar';break;
	case 5:msg='Revertir';break;
	case 6:msg='Imprimir';break;
	case 7:msg='Rechazar Ajuste';break;
	case 8:msg='Ajustar Aplicacion Pago';break;
  }
  setoverc(obj,'ImageBorderOver');
  optDescObj.innerHTML=msg;
  obj.alt=msg;
}
function goOption(option)
{
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		var k=document.form0.index.value;
		if(k=='')CBMSG.warning('Por favor seleccione un ajuste antes de ejecutar una acción!');
		else
		{
			var data_ref = eval('document.form0.data_refer'+k).value;
			var id = eval('document.form0.codigo'+k).value;
			var compania = eval('document.form0.compania'+k).value;	
			var status = eval('document.form0.status'+k).value;	
			var factura = eval('document.form0.factura'+k).value;
			var tipoTransaccion = eval('document.form0.tipoTransaccion'+k).value ;
			var tipo = eval('document.form0.tipo'+k).value ;
			var pacId = eval('document.form0.pacId'+k).value ;
			var noAdmision = eval('document.form0.noAdmision'+k).value;
			var tipoDoc = eval('document.form0.tipoDoc'+k).value;	
			var referencia =eval('document.form0.referencia'+k).value;	
			var ref_reversion =eval('document.form0.ref_reversion'+k).value;
			var ajustado =eval('document.form0.ajustado'+k).value;
				
			if(option==1)abrir_ventana1('../facturacion/notas_ajuste_cargo_dev.jsp?nt=C&fg=C&tr=RE');
			else if(option==2){if(data_ref =='O')abrir_ventana('../facturacion/notas_ajustes_config.jsp?mode=view&codigo='+id+'&compania='+compania);else if(data_ref =='N') abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=view&codigo='+id+'&compania='+compania);}
			else if(option==3){if(status =='O'){if(data_ref =='N')abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=edit&codigo='+id+'&compania='+compania+'&nt='+tipoTransaccion+'&fg='+tipo+'&pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&tr=ED');else CBMSG.warning('No es posible editar este tipo de ajuste!');}else CBMSG.warning('El estado del ajuste no permite esta Accion!!');}
			else if(option==4){	
				if((data_ref =='N' && status =='C') ||(data_ref =='O' && status =='P'))
				{
					showPopWin('../common/run_process.jsp?fp=AJ&actType=51&docType=AJ&id='+id+'&docId='+data_ref+'&docNo='+id+'&compania='+compania+'&tipo='+tipoDoc+'&factura='+factura+'&estado=A',winWidth*.75,winHeight*.65,null,null,'');	//abrir_ventana('../facturacion/notas_ajuste_cargo_dev.jsp?mode=edit&codigo='+id+'&compania='+compania+'&nt='+tipoTransaccion+'&fg='+tipo+'&pacienteId='+pacId+'&noAdmision='+noAdmision+'&factura='+factura+'&tr=AP');
				}else CBMSG.warning('El estado del ajuste no permite esta Accion!!');
			}
			else if(option==7){if((data_ref =='N' && status =='C') ||(data_ref =='O' && status =='P')){showPopWin('../common/run_process.jsp?fp=AJ&actType=52&docType=AJ&id='+id+'&docId='+data_ref+'&docNo='+id+'&compania='+compania+'&tipo='+tipoDoc+'&estado=R',winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('El estado del ajuste no permite esta Accion!!');}
			else if(option==5){if(status =='A'){if(ref_reversion=='')showPopWin('../common/run_process.jsp?fp=AJ&actType=50&docType=AJ&id='+id+'&docId='+data_ref+'&docNo='+id+'&compania='+compania+'&tipo='+tipoDoc+'&factura='+factura,winWidth*.75,winHeight*.65,null,null,'');/*}*/else CBMSG.warning('La referencia del ajuste no permite esta accion.El Ajuste ya fue reversado!.');}else CBMSG.warning('El estado del ajuste no permite esta Accion!!');}
			else if(option==6){if(data_ref =='O')abrir_ventana1('../facturacion/print_nota_ajuste.jsp?compania='+compania+'&codigo='+id);else abrir_ventana1('../facturacion/print_nota_ajuste.jsp?fg=ajust&compania='+compania+'&codigo='+id);}
			else if(option==8){
				if(tipoDoc=='F'){
				if(status == 'A'){
					if(ajustado=='S') alert('El ajuste a la aplicacion de pago ya fue realizado!');
					else
					if((data_ref == 'O' || data_ref == 'N') && ajustado == 'N') showPopWin('../process/fac_ajusta_app_pago.jsp?code='+id+'&data_refer='+data_ref,winWidth*.55,winHeight*.45,null,null,'');
				} else CBMSG.warning('El ajuste debe estar aprobado!');
			} else CBMSG.warning('Solo para tipo documento Factura!');
			}
		}
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function viewRec(codigo,compania,anio,tipoCliente){abrir_ventana('../caja/reg_recibo.jsp?mode=view&tipoCliente='+tipoCliente+'&codigo='+codigo+'&compania='+compania+'&anio='+anio);}
function viewFac(factura,compania){abrir_ventana('../facturacion/print_factura.jsp?factura='+factura+'&compania='+compania);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="NOTAS AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<!--<authtype type='3'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/shopping-cart-full-plus.gif"></a></authtype> -->
		<authtype type='1'><a href="javascript:goOption(2)" class="hint hint--top" data-hint="Ver"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/ver.png"></a></authtype>
		<%if(!fp.trim().equals("CS")){%><authtype type='4'><a href="javascript:goOption(3)" class="hint hint--top" data-hint="Editar"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/editar.png"></a></authtype><!---->		
		<authtype type='7'><a href="javascript:goOption(4)" class="hint hint--top" data-hint="Aprobar"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/check_mark.png"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(7)" class="hint hint--top" data-hint="Rechazar Ajuste"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/anular.png"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(5)" class="hint hint--left" data-hint="Revertir"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/cambiar.png"></a></authtype><%}%>
		<authtype type='2'><a href="javascript:goOption(6)" class="hint hint--left" data-hint="Imprimir"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/imprimir.png"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(8)" class="hint hint--left" data-hint="Ajustar Aplicacion Pago"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/dollar_circle_adjust.gif"></a></authtype>
		</td>
	</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<tr class="TextFilter">
	<td width="60%"><cellbytelabel>C&oacute;digo</cellbytelabel>
			<%=fb.intBox("codigo",codigo,false,false,false,10)%>&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Tipo Doc</cellbytelabel>. <%=fb.select("tipo_doc","F=FACTURA,R=RECIBO",tipo_doc,false,false,0,"Text10",null,null,null,"S")%>&nbsp;&nbsp;&nbsp;
			<cellbytelabel>Factura</cellbytelabel>#: <%=fb.textBox("factura","",false,false,false,15,"Text10",null,null)%>
	</td>
	<td width="40%"><cellbytelabel>Recibo</cellbytelabel> #:<%=fb.intBox("recibo",recibo,false,false,false,12)%>&nbsp;&nbsp;&nbsp;
									<cellbytelabel>Referencia</cellbytelabel> #:<%=fb.textBox("documento",documento,false,false,false,10,null,null,null)%>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="2">Fecha:<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha_desde" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
						<jsp:param name="nameOfTBox2" value="fecha_hasta" />
						<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
				</jsp:include>
		<cellbytelabel>Tipo Fecha</cellbytelabel>: <%=fb.select("tipo_fecha","C=CREACION,A=APROBACION",tipo_fecha,false,false,0,"Text10",null,null,null,"")%>&nbsp;&nbsp;&nbsp;
        <%//if(fp.equalsIgnoreCase("CS")){%>
          <cellbytelabel>Tipo Ajus.</cellbytelabel>:
          <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_fac_tipo_ajuste where compania = "+(String)session.getAttribute("_companyId")+" order by descripcion","tipo_ajuste_filter",tipoAjuste,false,false,0,"Text10","width:160px",null,null,"T")%>
		  <cellbytelabel>Grupo Ajus.</cellbytelabel>:
          <%=fb.select(ConMgr.getConnection(),"select id, id||' - '||description, id from tbl_fac_adjustment_group where status ='A' order by 1","grupo",grupo,false,false,0,"Text10","width:160px",null,null,"T")%>
        <%//}%>
        
	 <cellbytelabel>Estado</cellbytelabel> #: <%=fb.select("estado","P=PENDIENTE,O=ABIERTO,C=CERRADO,R=RECHAZADO,A=APROBADO",estado,false,false,0,"Text10",null,null,null,"S")%>
	<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
 <tr>
        <td align="right">&nbsp;
					<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
					<authtype type='0'><a href="javascript:printExcel()" class="Link00">[ <cellbytelabel>Excel</cellbytelabel> ]</a></authtype>
					<authtype type='0'><a href="javascript:printListDet()" class="Link00">[ <cellbytelabel>Imprimir Lista Detallada</cellbytelabel> ]</a></authtype>
		</td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%> 
					<%=fb.hidden("tipo_ajuste",""+tipo_ajuste)%>  
					<%=fb.hidden("grupo",grupo)%>					
					<%=fb.hidden("codigo",codigo)%> 
					<%=fb.hidden("tipo_doc",tipo_doc)%> 
					<%=fb.hidden("factura",factura)%> 
					<%=fb.hidden("recibo",recibo)%> 
					<%=fb.hidden("documento",documento)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>        
					<%=fb.hidden("tipo_ajuste_filter",tipoAjuste)%>   
					<%=fb.hidden("estado",estado)%>    

					
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>					
					<%=fb.hidden("tipo_ajuste",""+tipo_ajuste)%>  
					<%=fb.hidden("grupo",grupo)%>					
					<%=fb.hidden("codigo",codigo)%> 
					<%=fb.hidden("tipo_doc",tipo_doc)%> 
					<%=fb.hidden("factura",factura)%> 
					<%=fb.hidden("recibo",recibo)%> 
					<%=fb.hidden("documento",documento)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>        
					<%=fb.hidden("tipo_ajuste_filter",tipoAjuste)%>   
					<%=fb.hidden("estado",estado)%>    
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<tr>
  <td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
		<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("index","")%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
				<td width="6%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
				<td width="3%"><cellbytelabel>Afecta</cellbytelabel>.</td>
				<td width="16%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width="8%"><cellbytelabel>Referencia</cellbytelabel></td>
				<td width="8%"><cellbytelabel>U. Creación</cellbytelabel></td>
				<td width="8%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
				<td width="8%"><cellbytelabel>REC/FAC</cellbytelabel></td>
				<td width="7%"><cellbytelabel>Monto</cellbytelabel></td>
				<td width="8%"><cellbytelabel>U. Aprob</cellbytelabel></td>
				<td width="5%" align="center"><cellbytelabel>Ref. Rev</cellbytelabel></td>
				<td width="5%" align="center"><cellbytelabel>Fecha F/R</cellbytelabel></td>
				<td width="5%" align="center"><cellbytelabel>No. F/R</cellbytelabel></td>
				<td width="10%" align="center"><cellbytelabel>Nombre F/R</cellbytelabel></td>
				<td width="8%" align="center"><cellbytelabel>Pac. Id - Adm.</cellbytelabel></td>
				<td width="5%">&nbsp;</td>
			</tr>
		<%
		for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
		%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("data_refer"+i,cdo.getColValue("data_refer"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
		<%=fb.hidden("tipoTransaccion"+i,cdo.getColValue("tipoTransaccion"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("pacId"+i,cdo.getColValue("pacId"))%>
		<%=fb.hidden("noAdmision"+i,cdo.getColValue("noAdmision"))%>
		<%=fb.hidden("tipoDoc"+i,cdo.getColValue("tipo_doc"))%>
		<%=fb.hidden("ref_reversion"+i,cdo.getColValue("ref_reversion"))%>
		<%=fb.hidden("referencia"+i,cdo.getColValue("referencia"))%>
		<%=fb.hidden("ajustado"+i,cdo.getColValue("ajustado"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<td align="center"><%=cdo.getColValue("codigo")%></td>
		<td align="center"><%=cdo.getColValue("fecha_dsp")%></td>
		<td align="center"><%=cdo.getColValue("tipo_docDesc")%></td>
		<td align="center"><%=cdo.getColValue("ladoDesc")%></td>
		<td><%=cdo.getColValue("descripcion")%></td>
		<td align="center"><%=cdo.getColValue("referencia")%></td>
		<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
		<td align="center"><%if(cdo.getColValue("status").trim().equals("A")){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold"> &nbsp;&nbsp;<%=cdo.getColValue("statusDesc")%> &nbsp;&nbsp;</label></label><%}else{%><%=cdo.getColValue("statusDesc")%><%}%></td>
        <%
        String facOrRec = "";
        if (cdo.getColValue("recibo")!=null && !cdo.getColValue("recibo").trim().equals("") && cdo.getColValue("factura")!=null && !cdo.getColValue("factura").trim().equals("")){
           facOrRec = cdo.getColValue("recibo") + " / " + cdo.getColValue("factura");
        }else facOrRec = cdo.getColValue("recibo",cdo.getColValue("factura","")); 
        %>
		<td><a href="javascript:<% if (cdo.getColValue("tipo_doc").equalsIgnoreCase("R")) { %>viewRec(<%=cdo.getColValue("rec_key")%>)<% } else { %>viewFac('<%=cdo.getColValue("factura")%>',<%=cdo.getColValue("compania")%>)<% } %>" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=facOrRec%></a></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%></td>
		<td><%=cdo.getColValue("usuario_aprob")%></td>
		<td><%=cdo.getColValue("ref_reversion")%></td>
		<td align="center"><%=cdo.getColValue("fecha_factura")%></td>
		<td align="center"><%=cdo.getColValue("no_factura")%></td>
		<td align="center"><%=cdo.getColValue("nombre_en_factura")%></td>
		<td align="center"><%=cdo.getColValue("expediente")%></td>
		<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
		<!--
		<authtype type='1'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("data_refer")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
		<%if (fp.equals("REV")){ if(cdo.getColValue("ref_reversion") == null || cdo.getColValue("ref_reversion").trim().equals("")){ %>&nbsp;&nbsp;
		<authtype type='50'><a href="javascript:revertir('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("data_refer")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Rev.</a></authtype>
		<authtype type='51'><a href="javascript:corregir('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("data_refer")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">&nbsp;&nbsp;<cellbytelabel>Cor</cellbytelabel>.</a></authtype>-->
		<%} } %>
		</td>
		<!--<td align="center">&nbsp;
		<authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:imprimirNota('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>','<%=cdo.getColValue("data_refer")%>')"></authtype>
		</td>-->
		</tr>
		<% } %>
		</table>
		<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		<%=fb.formEnd()%>
	</div>
	</div>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("tipo_ajuste",""+tipo_ajuste)%>  
				<%=fb.hidden("grupo",grupo)%>					
				<%=fb.hidden("codigo",codigo)%> 
				<%=fb.hidden("tipo_doc",tipo_doc)%> 
				<%=fb.hidden("factura",factura)%> 
				<%=fb.hidden("recibo",recibo)%> 
				<%=fb.hidden("documento",documento)%> 
				<%=fb.hidden("fecha_desde",fecha_desde)%> 
				<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
				<%=fb.hidden("tipo_fecha",tipo_fecha)%>        
				<%=fb.hidden("tipo_ajuste_filter",tipoAjuste)%>   
				<%=fb.hidden("estado",estado)%>    
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>					
					<%=fb.hidden("tipo_ajuste",""+tipo_ajuste)%>  
					<%=fb.hidden("grupo",grupo)%>					
					<%=fb.hidden("codigo",codigo)%> 
					<%=fb.hidden("tipo_doc",tipo_doc)%> 
					<%=fb.hidden("factura",factura)%> 
					<%=fb.hidden("recibo",recibo)%> 
					<%=fb.hidden("documento",documento)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>        
					<%=fb.hidden("tipo_ajuste_filter",tipoAjuste)%>   
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
}
%>
