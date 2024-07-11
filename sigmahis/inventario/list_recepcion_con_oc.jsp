<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
/**
/**
==========================================================================================
 COC - CON ORDEN DE COMPRA
 SOC - SIN ORDEN DE COMPRA
 CNE - CONSIGNACION NOTA DE ENTREGA
 CFP - CONSIGNACION FACTURA DE PROVEEDOR
 --  - CONSULTA DE FACTURAS POR ORDEN DE COMPRA
 --  - CONSULTA DE RECEPCION DE MATERIAL
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
int iconHeight = 40;
int iconWidth = 40;

String sql = "";
String appendFilter =  "" ;
String fg = request.getParameter("fg");
if(fg==null)fg="";
String fp = request.getParameter("fp");
if(fp==null)fp="";

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

	String anio="",factura="",proveedor="",fDate="",tDate="",docNo="",estado="", filtro_fecha = request.getParameter("filtro_fecha");
	if(filtro_fecha==null) filtro_fecha = "D";
	if (request.getParameter("numero_documento") != null  && !request.getParameter("numero_documento").trim().equals(""))
	{
		appendFilter += " and a.numero_documento like '%"+request.getParameter("numero_documento").toUpperCase()+"%'";
		docNo =request.getParameter("numero_documento");
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio_recepcion ="+request.getParameter("anio");
		anio = request.getParameter("anio");
	}
	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
		appendFilter += " and upper(a.estado) ='"+request.getParameter("estado").toUpperCase()+"'";
		estado = request.getParameter("estado");
	}
	if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals(""))
	{
		appendFilter += " and upper(a.numero_factura) like '%"+request.getParameter("factura").toUpperCase()+"%'";
		factura = request.getParameter("factura");
	}
	if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	{
		appendFilter += " and trunc("+(filtro_fecha.equals("D")?"a.fecha_documento":"a.fecha_sistema")+") >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
		fDate = request.getParameter("fecha_desde");
	}
	if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	{
		appendFilter += " and trunc("+(filtro_fecha.equals("D")?"a.fecha_documento":"a.fecha_sistema")+") <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
		tDate = request.getParameter("fecha_hasta");
	}
	if (request.getParameter("proveedor") != null && !request.getParameter("proveedor").trim().equals(""))
	{
		appendFilter += " and upper(b.nombre_proveedor) like '%"+request.getParameter("proveedor").toUpperCase()+"%'";
		proveedor = request.getParameter("proveedor");
	}
	if(fg.equalsIgnoreCase("COC"))appendFilter += " and a.fre_documento in ('FC','OC') and a.cf_anio is not null";
	else if(fg.equalsIgnoreCase("SOC"))appendFilter += "  and a.fre_documento in ('FC','FR') and a.cf_anio is null";
	else if(fg.equalsIgnoreCase("CNE"))appendFilter += " and a.fre_documento = 'NE' ";
	else if(fg.equalsIgnoreCase("CFP"))appendFilter += " and a.fre_documento = 'FG' ";

	if(request.getParameter("proveedor") !=null){
	sql = "SELECT a.anio_recepcion, a.numero_documento, a.estado, decode(a.estado,'A','ANULADO','R','RECIBIDO') desc_estado,to_char(a.fecha_documento,'dd/mm/yyyy') fecha_documento, a.cod_proveedor, a.codigo_almacen, b.nombre_proveedor, c.descripcion almacen_desc,a.fre_documento,decode(a.cf_tipo_com,null,' ',a.cf_tipo_com) as cf_tipo_com,a.numero_factura,to_char(a.fecha_sistema,'dd/mm/yyyy')fecha_sistema,a.monto_total,to_char(sysdate,'dd/mm/yyyy')fechaSys,case when nvl(a.comprobante,'N') ='S' or nvl(a.comprobante_an,'N') ='S' then 'S' else 'N' end as comprobante FROM tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c where a.cod_proveedor = b.cod_provedor and a.codigo_almacen = c.codigo_almacen and a.compania = c.compania and a.compania = "+session.getAttribute("_companyId") + appendFilter+" and a.tipo_factura ='I' order by a.fecha_creacion desc";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
function add(option){var barcode ='';if(option=='5')barcode='CB';
<%if (fg.trim().equalsIgnoreCase("COC")){%>abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?fg=<%=fg%>&fp=<%=fp%>');
<%} else if (fg.trim().equalsIgnoreCase("SOC")){%>abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?fg=<%=fg%>&fp=<%=fp%>');
<%} else if (fg.trim().equalsIgnoreCase("CNE")){%>abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?fg=<%=fg%>&fp='+barcode);
<%} else if (fg.trim().equalsIgnoreCase("CFP")){%>abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?fg=<%=fg%>');
<%}%>
}
function printList(){abrir_ventana('../inventario/print_list_recepcion.jsp?fp=<%=fg%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function view(docto,ocType,anio,id){
<%if (fg.trim().equalsIgnoreCase("COC")){%>	abrir_ventana('../inventario/reg_recepcion_con_oc.jsp?fg=<%=fg%>&mode=view&id='+id+'&anio='+anio);
<%} else if (fg.trim().equalsIgnoreCase("SOC")){%>abrir_ventana('../inventario/reg_recepcion_sin_oc.jsp?fg=<%=fg%>&mode=view&id='+id+'&anio='+anio);
<%} else if (fg.trim().equalsIgnoreCase("CNE")){%>abrir_ventana('../inventario/reg_recepcion_nentrega.jsp?fg=<%=fg%>&mode=view&id='+id+'&anio='+anio);
<%} else if (fg.trim().equalsIgnoreCase("CFP")){%>abrir_ventana('../inventario/reg_recepcion_fact_prov.jsp?fg=<%=fg%>&mode=view&id='+id+'&anio='+anio);
<%} else if (fg.trim().equals("")){%><%}%>
}
function printReport(recptYear, docId){
var fg = "<%=fg.trim()%>";
if (fg == "CNE"){abrir_ventana('../inventario/print_recep_nota_entrega.jsp?fg=<%=fg%>&numero='+docId+'&anio='+recptYear);}
else if (fg == "COC"){abrir_ventana('../inventario/print_mat_equipo_con_oc.jsp?fg=<%=fg%>&numero='+docId+'&anio='+recptYear);}
else if (fg == "SOC"){abrir_ventana('../inventario/print_mat_equipo_sin_oc.jsp?fg=<%=fg%>&numero='+docId+'&anio='+recptYear);}
else if (fg == "CFP"){abrir_ventana('../inventario/print_recepcion_fact_prov.jsp?fg=<%=fg%>&numero='+docId+'&anio='+recptYear);}
}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Nueva Recepcion';break;
		case 1:msg='Ver Recepcion';break;
		case 2:msg='Imprimir';break;
		case 3:msg='Generar Requisicion';break;
		case 4:msg='Anular Recepcion';break;
		case 5:msg='Registrar Nueva Recepcion CB';break;
		case 6:msg='Actualizar Contado/Credito';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
var esInv ='S';
var whInv ='null';

function goOption(option)
{
	if(option==0||option==5)add(option);
	else{
	if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		var k=document.form0.index.value;
		if(k=='')alert('Por favor seleccione una Recepcion antes de ejecutar una acción!');
			else
			{
				var compania = '<%=(String)session.getAttribute("_companyId")%>';
				var docto = eval('document.form0.tipoDocto'+k).value;
				var ocType = eval('document.form0.tipoOc'+k).value;
				var anio = eval('document.form0.anio'+k).value;
				var id = eval('document.form0.id'+k).value;
				var wh = eval('document.form0.wh'+k).value;
				var descWh = eval('document.form0.whDesc'+k).value;	
				var fechaDoc = eval('document.form0.fechaDoc'+k).value;	
				var proveedor = eval('document.form0.proveedor'+k).value;	
				var montoFact = eval('document.form0.monto'+k).value;
				var factura = eval('document.form0.factura'+k).value;		
				var comprobante = eval('document.form0.comprobante'+k).value;
				var fechaSys = '';
				if(eval('document.form0.fechaSys'+k))fechaSys=eval('document.form0.fechaSys'+k).value;
				if(option==1)view(docto,ocType,anio,id);
				else if(option==2)printReport(anio,id);
				else if(option==3)abrir_ventana('../inventario/reg_req_unid_adm.jsp?tr=EA&recepId='+id+'&recepYear='+anio+'&codEmp='+wh+'&descEmp='+descWh);
				else if(option==4){//anular(anio,id);
				if(wh!='')whInv=wh;
				var saldo = getDBData('<%=request.getContextPath()%>','nvl(getSaldoFactPRov(<%=(String) session.getAttribute("_companyId")%>,'+proveedor+', \''+factura+'\',2),0)','dual','');
				if(montoFact==saldo){
				if(!checkEstado(fechaSys)){CBMSG.warning('Revise Fecha de la Transaccion!');}else{
				showPopWin('../common/run_process.jsp?fp=INV&actType=7&docType=RECEP&docNo='+id+'&compania='+compania+'&docId='+id+'&anio='+anio+'&almacen='+wh+'&tipo='+docto+'&fecha='+fechaDoc,winWidth*.75,winHeight*.65,null,null,'');}}
				else CBMSG.warning('La recepcion a anular Tiene transacciones [ PAGOS, AJUSTE, DEVOLUCIONES,REG. AUXILIAR ] Relacionadas a su Factura. Verifique!!!!');}
				else if(option==6){if(!checkEstado(fechaDoc)||comprobante=='S'){var msg =''; if(comprobante=='S')msg='La Transaccion ya tiene Comprobante generado';else msg='El mes/año está Cerrado'; CBMSG.warning(msg+' !');}else{showPopWin('../process/inv_upd_recepcion.jsp?factura='+factura+'&compania='+compania+'&id='+id+'&anio='+anio+'&tipoDoc='+docto+'&fg=<%=fg%>',winWidth*.75,winHeight*.65,null,null,'');}
				
				}
			 }
	    }
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function checkEstado(fecha){var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - RECEPCION MAT. Y EQUIPOS CON ORDEN DE COMPRA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>		
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>	
		<%if(fg.trim().equalsIgnoreCase("CNE")){%><authtype type='51'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/case.jpg"></a></authtype><%}%>	
		<authtype type='1'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/search.gif"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/print_analysis.gif"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/req_icon.png"></a></authtype>
		<%if (!fg.trim().equalsIgnoreCase("CNE")){%><authtype type='7'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/cancel.gif"></a></authtype><%}%>
		
		<%if(fg.trim().equalsIgnoreCase("COC")|| fg.trim().equalsIgnoreCase("SOC") ){%><authtype type='52'><a href="javascript:goOption(6)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/refresh.png"></a></authtype><%}%>	
		</td>
	</tr>
	<tr>
		<td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart(true)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
				<tr class="TextFilter">
				 <td>
								 A&ntilde;o<br>
				<%=fb.intBox("anio",anio,false,false,false,10,"text10",null,"")%>
				</td>
				<td>
				No. Recepci&oacute;n<br>
								<%=fb.intBox("numero_documento","",false,false,false,10,"text10",null,"")%>
					</td>
					<td>
				No. Factura<br>
								<%=fb.textBox("factura","",false,false,false,10,"text10",null,"")%>
				</td>
<td align="center">				
								<%=fb.select("filtro_fecha","D=Fecha Documento,C=Fecha Creacion",filtro_fecha, false, false, 0, "text10", "", "", "", "")%>
								<br>
							<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2"/>
						<jsp:param name="nameOfTBox1" value="fecha_desde"/>
						<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
						<jsp:param name="nameOfTBox2" value="fecha_hasta"/>
						<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
						<jsp:param name="fieldClass" value="Text10"/>
						<jsp:param name="buttonClass" value="Text10"/>
						<jsp:param name="clearOption" value="true"/>
						</jsp:include>
							</td>
							<td>
							Estado:<br>
							<%=fb.select("estado","R=RECIBIDO,A=ANULADO",estado, false, false, 0, "text10", "", "", "", "S")%>
				</td>
				<td>
				Proveedor:<br><%=fb.textBox("proveedor","",false,false,false,30,"text10",null,"")%>
				<%=fb.submit("go","Ir")%>
						</td>
				</tr>
					<%=fb.formEnd(true)%>
			</table>
			<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00 btn_link">[ Imprimir Lista ]</a></authtype> &nbsp; </td>
	</tr>
 	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","");%>
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
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("numero_documento",docNo)%>
					<%=fb.hidden("fecha_desde",fDate)%>
					<%=fb.hidden("fecha_hasta",tDate)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("proveedor",proveedor)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("filtro_fecha",filtro_fecha)%>
			<%=fb.hidden("fp",fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","");%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("numero_documento",docNo)%>
					<%=fb.hidden("fecha_desde",fDate)%>
					<%=fb.hidden("fecha_hasta",tDate)%>
					<%=fb.hidden("proveedor",proveedor)%>
					<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("filtro_fecha",filtro_fecha)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%> </tr>
			</table></td>
	</tr>
 	<tr>
	<td class="TableLeftBorder TableRightBorder">
	<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>   
  		<tr class="TextHeader" align="center">
			<td width="4%">A&ntilde;o</td>
			<td width="8%">No. Recepci&oacute;n</td>
			<td width="7%">Fecha Doc.</td>
			<td width="7%">Fecha Creac.</td>
			<td width="23%">Proveedor</td>
			<td width="10%">No. Factura</td>
			<td width="21%">Almac&eacute;n</td>
			<td width="8%">Estado</td>
			<td>&nbsp;</td>
		</tr>
<%for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio_recepcion"))%>
		<%=fb.hidden("id"+i,cdo.getColValue("numero_documento"))%>
		<%=fb.hidden("whDesc"+i,cdo.getColValue("almacen_desc"))%>
		<%=fb.hidden("wh"+i,cdo.getColValue("codigo_almacen"))%>
		<%=fb.hidden("tipoDocto"+i,cdo.getColValue("fre_documento"))%>
		<%=fb.hidden("tipoOc"+i,cdo.getColValue("cf_tipo_com"))%>
		<%=fb.hidden("fechaDoc"+i,cdo.getColValue("fecha_documento"))%>
		<%=fb.hidden("proveedor"+i,cdo.getColValue("cod_proveedor"))%>
		<%=fb.hidden("monto"+i,cdo.getColValue("monto_total"))%>		
		<%=fb.hidden("factura"+i,cdo.getColValue("numero_factura"))%>
		<%=fb.hidden("fechaSys"+i,cdo.getColValue("fechaSys"))%>
		<%=fb.hidden("comprobante"+i,cdo.getColValue("comprobante"))%>		
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio_recepcion")%></td>
			<td align="center"><%=cdo.getColValue("numero_documento")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="center"><%=cdo.getColValue("fecha_sistema")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("cod_proveedor")+" "+cdo.getColValue("nombre_proveedor")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("numero_factura")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("codigo_almacen")+" "+cdo.getColValue("almacen_desc")%></td>
			<td align="center"><%=cdo.getColValue("desc_estado")%></td>
			<td  align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%}%>
			<%=fb.formEnd()%>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","");%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("numero_documento",docNo)%>
					<%=fb.hidden("fecha_desde",fDate)%>
					<%=fb.hidden("fecha_hasta",tDate)%>
					<%=fb.hidden("proveedor",proveedor)%>
					<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("filtro_fecha",filtro_fecha)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","");%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("numero_documento",docNo)%>
					<%=fb.hidden("fecha_desde",fDate)%>
					<%=fb.hidden("fecha_hasta",tDate)%>
					<%=fb.hidden("proveedor",proveedor)%>
					<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("filtro_fecha",filtro_fecha)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table></td>
	</tr>
</table>
</body>
</html>
<%
}
%>
