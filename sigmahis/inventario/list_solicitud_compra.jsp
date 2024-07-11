
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
200065	VER LISTA DE SOLICITUD DE COMPRA
200066	IMPRIMIR LISTA DE SOLICITUD DE COMPRA
200067	AGREGAR SOLICITUD DE COMPRA
200068	MODIFICAR SOLICITUD DE COMPRA
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
String sql = "";
int iconHeight = 40;
int iconWidth = 40;

StringBuffer appendFilter = new StringBuffer();
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
	
	String noSolic = "";                 // variables para mantener el valor de los campos filtrados en la consulta
	String anio    = "", estado = "", almacen ="";
	if (request.getParameter("requi_numero") != null && !request.getParameter("requi_numero").equals(""))
	{
		appendFilter.append(" and a.requi_numero = ");
		appendFilter.append(request.getParameter("requi_numero"));
 		noSolic    = request.getParameter("requi_numero");
	}
	if (request.getParameter("requi_anio") != null && !request.getParameter("requi_anio").equals(""))
	{
		appendFilter.append(" and upper(a.requi_anio) like '%");
		appendFilter.append(request.getParameter("requi_anio").toUpperCase());
		appendFilter.append("%'");
 		anio       = request.getParameter("requi_anio");       // utilizada para mantener el Año de la Solicitud
	}
	
	 if (request.getParameter("requi_almacen") != null && !request.getParameter("requi_almacen").equals(""))
	{
		appendFilter.append(" and upper(a.codigo_almacen) like '%");
		appendFilter.append(request.getParameter("requi_almacen").toUpperCase());
		appendFilter.append("%'"); 
		almacen       = request.getParameter("requi_almacen");       // utilizada para mantener el Año de la Solicitud
	}
	if (request.getParameter("estado_requi") != null && !request.getParameter("estado_requi").equals(""))
	{
		appendFilter.append(" and upper(estado_requi) = '");
		appendFilter.append(request.getParameter("estado_requi").toUpperCase());
		appendFilter.append("'");
		estado     = request.getParameter("estado_requi");    // utilizada para mantener el Estado de la Solicitud
	} //else appendFilter.append(" and a.estado_requi in ('A','P') ");
	
	if (request.getParameter("fechaini") != null && !request.getParameter("fechaini").trim().equals(""))
	{
		appendFilter.append(" and to_date(to_char(a.requi_fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('");appendFilter.append(request.getParameter("fechaini"));appendFilter.append("','dd/mm/yyyy')");
	}
	if (request.getParameter("fechafin") != null && !request.getParameter("fechafin").trim().equals(""))
	{
		appendFilter.append(" and to_date(to_char(a.requi_fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('");appendFilter.append(request.getParameter("fechafin"));appendFilter.append("','dd/mm/yyyy')"); 
	}
	
if (request.getParameter("estado_requi") != null){
	sql = "SELECT a.requi_anio, a.requi_numero, a.compania, to_char(a.requi_fecha, 'dd/mm/yyyy') requi_fecha, a.estado_requi, decode(a.estado_requi,'A','Aprobado','P','Pendiente','R','Rechazado','PR','Procesado') desc_estado_requi, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, NVL(a.observaciones,' ') observaciones, NVL(a.monto_total,0) monto_total, NVL(a.subtotal,0) subtotal, NVL(a.itbm,0) itbm, nvl(a.activa,' ') activa, nvl(a.unidad_administrativa,0) unidad_administrativa,nvl((select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_administrativa and compania=a.compania),' ') as descripcionUnd , nvl(a.codigo_almacen,0) codigo_almacen, NVL(a.especificacion, ' ') especificacion, b.descripcion,decode(a.estado_requi,'A',(select count(*) from tbl_com_comp_formales cf where cf.requi_numero=a.requi_numero and cf.requi_anio =a.requi_anio and cf.compania= a.compania and cf.status not in ('N','Z')),1) as anularReq,getNoOrdenComp(a.compania,a.requi_anio,a.requi_numero) as ordenes from tbl_inv_requisicion a, tbl_inv_almacen b where a.compania="+(String) session.getAttribute("_companyId")+appendFilter.toString()+" and a.codigo_almacen = b.codigo_almacen and a.compania = b.compania order by 1 desc, 2 desc";
	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_inv_requisicion a, tbl_inv_almacen b where a.compania="+(String) session.getAttribute("_companyId")+""+appendFilter.toString()+" and a.codigo_almacen = b.codigo_almacen and a.compania = b.compania");
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
function add(){abrir_ventana('../inventario/reg_solicitud_compra.jsp');}
function view(anio,id,mode){abrir_ventana('../inventario/reg_solicitud_compra.jsp?mode='+mode+'&id='+id+'&anio='+anio);}
function printList(){abrir_ventana('../inventario/print_list_reg_solic_compra.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter.toString())%>');}
function printSol(anio,id,wh){abrir_ventana('../inventario/print_list_solicitud_compra.jsp?id='+id+'&anio='+anio+'&wh='+wh);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Nueva Solicitud';break;
		case 1:msg='Ver Solicitud';break;
		case 2:msg='Imprimir';break;
		case 3:msg='Aprobar Solicitud';break;
		case 4:msg='Rechazar Solicitud';break;
		case 5:msg='Editar Solicitud';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
} 
function goOption(option)
{
	if(option==0)add();
	else{
	if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		var k=document.form0.index.value;
		if(k=='')alert('Por favor seleccione una Solictud antes de ejecutar una acción!');
			else
			{
				var compania = '<%=(String)session.getAttribute("_companyId")%>'; 
				var anio = eval('document.form0.anio'+k).value;
				var id = eval('document.form0.id'+k).value; 
				var wh = eval('document.form0.wh'+k).value; 
				var estado = eval('document.form0.estado'+k).value;
				var anularReq  = eval('document.form0.anularReq'+k).value;
				var estadoAp='';
				var msg='';
				if(option==1)view(anio,id,'view');
				else if(option==2)printSol(anio,id,wh);
				else if(option==3)
				{
				 if(estado=="P"){estadoAp='A';showPopWin('../process/inv_aprob_solicitud.jsp?id='+id+'&anio='+anio+'&estado='+estadoAp,winWidth*.75,winHeight*.65,null,null,''); }
				 else CBMSG.warning('La Solicitud de compra no permite esta accion!!!!');
				}
				else if(option==4)
				{
				   if(estado=="A" && anularReq!="0" )msg = ' Existen Ordenes de Compras para Está solicitud. ';
				   if(estado=="P" || (estado=="A" && anularReq=="0" )){estadoAp='R';showPopWin('../process/inv_aprob_solicitud.jsp?id='+id+'&anio='+anio+'&estado='+estadoAp,winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('La Solicitud de compra no permite esta accion!!!!'+msg);
				}
				else if(option==5){if(estado=="P"){view(anio,id,'edit');	}else CBMSG.warning('La Solicitud de compra no permite esta accion!!!!'+anularReq);}
				 
			 }
	    }
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOLICITUD DE COMPRA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>		
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>	
		<authtype type='4'><a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/edit.png"></a></authtype> 
		<authtype type='1'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/search.gif"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/printer.png"></a></authtype>
		<authtype type='6'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/check_mark.png"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/anular.png"></a></authtype> 
		
		</td>
	</tr>
  
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
			<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="100%">
				<%sql = "select codigo_almacen, descripcion from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen asc";%>
				Almacén.<%=fb.select(ConMgr.getConnection(), sql, "requi_almacen", almacen,"T")%>					
				
				
				A&ntilde;o<%=fb.intBox("requi_anio",anio,false,false,false,10)%>
				Solicitud No.<%=fb.intBox("requi_numero",noSolic,false,false,false,10)%>
				 
					Estado
					<%=fb.select("estado_requi","A=APROBADO,P=PENDIENTE,R=RECHAZADO,PR=PROCESADO",estado,"T")%>
					Fecha:&nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="fechaini"/>
			<jsp:param name="valueOfTBox1" value=""/>
			<jsp:param name="nameOfTBox2" value="fechafin"/>
			<jsp:param name="valueOfTBox2" value=""/>
		</jsp:include>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
				<%=fb.hidden("estado_requi",estado)%>
				<%=fb.hidden("requi_numero",noSolic)%>
				<%=fb.hidden("requi_almacen",almacen)%>
				<%=fb.hidden("requi_anio",anio)%>
				<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
				<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
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
				<%=fb.hidden("estado_requi",estado)%>
				<%=fb.hidden("requi_numero",noSolic)%>
				<%=fb.hidden("requi_almacen",almacen)%>
				<%=fb.hidden("requi_anio",anio)%>
				<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
				<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
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
  <table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("beginSearch","")%> 
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("index","")%>
 		<tr class="TextHeader" align="center">
 			<td width="5%">A&ntilde;o</td>
			<td width="7%">No. Solicitud</td>	
			<td width="8%">Fecha Doc.</td>		
			<td width="20%">Almacén</td>
			<td width="30%">Unidad Adm.</td>
			<td width="10%">Estado</td>
			<td width="15%">Ordenes Comp.</td>			
			<td width="5%">&nbsp;</td> 
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>

	<%=fb.hidden("anio"+i,cdo.getColValue("requi_anio"))%>
	<%=fb.hidden("id"+i,cdo.getColValue("requi_numero"))%>
	<%=fb.hidden("wh"+i,cdo.getColValue("codigo_almacen"))%>
	<%=fb.hidden("estado"+i,cdo.getColValue("estado_requi"))%>
	<%=fb.hidden("anularReq"+i,cdo.getColValue("anularReq"))%>
	  
	
	
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
 			<td align="center"><%=cdo.getColValue("requi_anio")%></td>
			<td align="center"><%=cdo.getColValue("requi_numero")%></td>
			<td align="center"><%=cdo.getColValue("requi_fecha")%></td>
			<td align="center"><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("descripcionUnd")%></td>
			<td align="center"><%=cdo.getColValue("desc_estado_requi")%></td>
			<td align="center"><%=cdo.getColValue("ordenes")%></td>
			<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
 <%=fb.formEnd(true)%>
   </table>
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
				<%=fb.hidden("estado_requi",estado)%>
				<%=fb.hidden("requi_numero",noSolic)%>
				<%=fb.hidden("requi_almacen",almacen)%>
				<%=fb.hidden("requi_anio",anio)%>
				<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
				<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
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
				<%=fb.hidden("estado_requi",estado)%>
				<%=fb.hidden("requi_numero",noSolic)%>
				<%=fb.hidden("requi_almacen",almacen)%>
				<%=fb.hidden("requi_anio",anio)%>
				<%=fb.hidden("fechaini",request.getParameter("fechaini"))%>
				<%=fb.hidden("fechafin",request.getParameter("fechafin"))%>
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
