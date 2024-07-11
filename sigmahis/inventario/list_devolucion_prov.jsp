<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
200069	VER LISTA DE ORDEN DE COMPRA NORMAL
200070	IMPRIMIR LISTA DE ORDEN DE COMPRA NORMAL
200071	AGREGAR SOLICITUD DE ORDEN DE COMPRA NORMAL
200072	MODIFICAR SOLICITUD DE ORDEN DE COMPRA NORMAL
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
ArrayList alWh = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String wh = request.getParameter("wh");
String fg = request.getParameter("fg");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String allItem = request.getParameter("all_item");
String estado ="";
String tipo_dev="";
if(fg==null) fg = "DP";
if (allItem == null) allItem = "";

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null ) wh ="";
if(!wh.trim().equals(""))appendFilter = " and dp.codigo_almacen="+wh;
int iconHeight = 48;
int iconWidth = 48;

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
	
	String numDev  = "";          // variables para mantener el valor de los campos filtrados en la consulta
	String anioDev = "";
	String fechaini = "";
	String fechafin = "";
	String factura  = "";
	String ncredito = "";
	String codProv = "";

    
	if (request.getParameter("num_devolucion") != null && !request.getParameter("num_devolucion").trim().equals(""))
	{
	   numDev = request.getParameter("num_devolucion"); 
	    appendFilter += " and dp.num_devolucion = "+numDev;

	}
	 
	 if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals(""))
	{
	   factura = request.getParameter("factura"); 
	    appendFilter += " and dp.numero_factura = '"+factura+"'";

	}
	
	if (request.getParameter("ncredito") != null && !request.getParameter("ncredito").trim().equals(""))
	{
	   ncredito = request.getParameter("ncredito"); 
	   appendFilter += " and dp.nota_credito = '"+ncredito+"'";

	}
	if (request.getParameter("codProv") != null && !request.getParameter("codProv").trim().equals(""))
	{
	 codProv = request.getParameter("codProv"); 
	 appendFilter += " and dp.cod_provedor = "+codProv;

	}
	
	if (request.getParameter("fechaini") != null && !request.getParameter("fechaini").trim().equals(""))
  {
   fechaini    = request.getParameter("fechaini");
   appendFilter += " and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+request.getParameter("fechaini")+"','dd/mm/yyyy')";
	
	}
	 if (request.getParameter("fechafin") != null && !request.getParameter("fechafin").trim().equals(""))
  {
   fechafin    = request.getParameter("fechafin");
   appendFilter += " and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+request.getParameter("fechafin")+"','dd/mm/yyyy')";
	
	}
	if (request.getParameter("anio_devolucion") != null && !request.getParameter("anio_devolucion").trim().equals(""))
	{
	anioDev    = request.getParameter("anio_devolucion");
	appendFilter += " and dp.anio = "+anioDev;
	} 
	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
	{
	estado    = request.getParameter("estado");
	appendFilter += " and dp.anulado_sino = '"+estado+"'";
	}
	if (request.getParameter("tipo_dev") != null && !request.getParameter("tipo_dev").trim().equals(""))
	{
	tipo_dev    = request.getParameter("tipo_dev");
	appendFilter += " and dp.tipo_dev = '"+tipo_dev+"'";
	} 
	/*
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST")){
    if (searchType.equals("1")){
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
*/
 if(request.getParameter("wh") != null)
 {
	
	sql = "select dp.anio, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, dp.monto, dp.cod_provedor, dp.cod_provedor||' - '||p.nombre_proveedor as nombre_proveedor, dp.usuario_creacion as usuario, dp.numero_factura as factura, dp.nota_credito as nCredito,nvl(dp.anulado_sino,'N') as anulado,dp.tipo ,decode(nvl(dp.anulado_sino,'N'),'N','ACTIVA','S','ANULADA') as anuladoDesc,decode(dp.tipo_dev,'C','DEV. CONSIGNACION','N','DEV. NORMAL','R','RETIRO - CONSIGNACION') as desc_tipo_dev,dp.tipo_dev FROM tbl_inv_devolucion_prov dp ,tbl_com_proveedor p where dp.compania = "+session.getAttribute("_companyId")+" and dp.cod_provedor= p.cod_provedor(+)"+ appendFilter+" order by dp.anio desc,dp.num_devolucion desc";

	/*
	sql="select dp.anio as anio, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, dp.monto,dp.cod_provedor,dp.cod_provedor||' - '||p.nombre_proveedor nombre_proveedor, decode(dp.tipo_dev,'C','DEV. CONSIGNACION','N','DEV. NORMAL') as desc_estado, dp.codigo_almacen, dp.nota_credito as nCredito, dp.itbm, dd.cantidad, dd.precio, (dd.cantidad*dd.precio) as total, dd.cod_familia||'-'||dd.cod_clase||'-'||dd.cod_articulo as codigo, ar.descripcion, dp.usuario_creacion as usuario, dp.numero_factura as factura FROM tbl_inv_devolucion_prov dp ,tbl_com_proveedor p, tbl_inv_detalle_proveedor dd, tbl_inv_articulo ar where dp.compania = "+session.getAttribute("_companyId")+" and dp.num_devolucion = dd.num_devolucion and dp.anio = dd.anio and dp.compania = dd.compania and dd.cod_familia = ar.cod_flia and dd.cod_clase = ar.cod_clase and dd.cod_articulo = ar.cod_articulo and dd.compania = ar.compania and dp.cod_provedor= p.cod_provedor"+ appendFilter+" order by dp.anio,dp.num_devolucion desc";
	*/
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
<script language="javascript">
document.title = 'Inventario - '+document.title;

function add(){abrir_ventana('../inventario/reg_dev_proveedor.jsp?mode=add&fg=<%=fg%>&all_item=<%=allItem%>');}
function edit(anio, id){abrir_ventana('../inventario/reg_dev_proveedor.jsp?mode=view&id='+id+'&anio='+anio+'&fg=<%=fg%>&all_item=<%=allItem%>');}
function printList(){
<% if ((appendFilter != null || !appendFilter.trim().equals("")) && al.size() != 0){%>
<%if(fg.trim().equals("DP")){%>
abrir_ventana('../inventario/print_list_devolucion_cons.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>&wh=<%=wh%>&tDate=<%=fechaini%>&fDate=<%=fechafin%>');
	<%}else{ %>
abrir_ventana('../inventario/print_list_devolucion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	<%}%>
	<%}else{%>
	alert('I N T R O D U Z C A     P A R Á M E T R O S    D E    B Ú S Q U E D A');
	<%}%>
}
function showProveedor(){abrir_ventana('../inventario/sel_proveedor.jsp?fp=RM');}
function editFact(year,noDev,factNo,nCred,k)
{
	var userMod = '<%=(String) session.getAttribute("_userName")%>';
	
		if(confirm('¿Esta seguro de MODIFICAR este Registro?'))
		{
			var factura = eval('document.devolucion.factura'+k).value;
			var nCredito = eval('document.devolucion.nCredito'+k).value;
			//update tbl_inv_devolucion_prov  set  numero_factura  = 6854 , nota_credito = 6849  where   anio = 2009 and compania = 1 and num_devolucion = 299

			if(executeDB('<%=request.getContextPath()%>','update tbl_inv_devolucion_prov set  numero_factura = \''+factura+'\',nota_credito = \''+nCredito+'\' , usuario_mod =\''+userMod+'\',fecha_mod = sysdate  where compania = <%=session.getAttribute("_companyId")%> and anio = '+year+'  and num_devolucion = '+noDev+'  and nota_credito = \''+nCred+'\''))
			{
			alert('Datos Modificados');
			var nota = document.searchMain.ncredito.value;
			var fact = document.searchMain.factura.value;
			if(fact != '')  document.searchMain.factura.value  =  factura;
			if(nota != '')  document.searchMain.ncredito.value =  nCredito;
			
			document.searchMain.submit();
			
			}
			else alert('Error al modificar los datos');
			
		}else alert('Modificación canelada');
}
function printDev(anio,id){abrir_ventana('../inventario/print_dev_proveedor.jsp?num='+id+'&anio='+anio);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function setIndex(k){document.devolucion.index.value=k;checkOne('devolucion','check',<%=al.size()%>,eval('document.devolucion.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Devolucion';break;
		case 1:msg='Anular Devolucion';break;
		case 2:msg='Imprimir Devolucion';break;
		case 3:msg='Ver Devolucion';break;	

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
		var k=document.devolucion.index.value;
		if(k=='')alert('Por favor seleccione una factura antes de ejecutar una acción!');
		else
		{
			var id = eval('document.devolucion.id'+k).value ;
			var anio = eval('document.devolucion.anio'+k).value ;
			var anulado = eval('document.devolucion.anulado'+k).value ;
			var tipo = eval('document.devolucion.tipo'+k).value ;
			var tipoDev = eval('document.devolucion.tipoDev'+k).value ;
			if(option=='2')printDev(anio,id);
			else if(option=='3')edit(anio, id);
			else if(option=='1'){if(anulado=='N'){			
			showPopWin('../common/run_process.jsp?fp=DEVPROV&actType=50&docType=DEVPROV&compania=<%=session.getAttribute("_companyId")%>&docId='+id+'&docNo='+id+'&anio='+anio+'&tipo='+tipo,winWidth*.75,winHeight*.65,null,null,'');}else CBMSG.warning('La devolucion ya se encuentra anulada!');}
		}
	}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - DEVOLUCION DE MATERIALES DE PROVEEDORES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right">
	<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)" class="hint hint--top" data-hint="Registrar Devolucion"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/add.png"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(1)" class="hint hint--top" data-hint="Anular Devolucion"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/anular.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(2)" class="hint hint--top" data-hint="Imprimir Devolucion"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/print.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(3)" class="hint hint--top" data-hint="Ver Devolucion"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder image-contrast" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/search.png"></a></authtype>
		
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

<table width="100%" cellpadding="0" cellspacing="0">
			
	<tr class="TextFilter">
    <%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%> 
     <%=fb.formStart()%>
     <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
     <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
     <%=fb.hidden("fg",fg)%>
     <%=fb.hidden("all_item",allItem)%>
    	<td width="100%" >
     	Almac&eacute;n
     	<%=fb.select("wh",alWh,wh,"T")%>     
    	Fecha 
    	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="fechaini"/>
		<jsp:param name="valueOfTBox1" value="<%=fechaini%>"/>
		<jsp:param name="nameOfTBox2" value="fechafin"/>
		<jsp:param name="valueOfTBox2" value="<%=fechafin%>"/>
		</jsp:include>
					Estado: <%=fb.select("estado","N=ACTIVA,S=ANULADA",estado,false,false,0,"T")%>	
					Tipo Dev: <%=fb.select("tipo_dev","N=NORMAL,C=CONSIGNACION,R=RETIRO - CONSIGNACION",tipo_dev,false,false,0,"T")%>						
	  
    	</td>
  	</tr>
			
	<tr class="TextFilter">
		<td width="70%">
			A&ntilde;o.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<%=fb.intBox("anio_devolucion",anioDev,false,false,false,10)%>
			<%//=fb.submit("go","Ir")%>
		
			No.Devolución&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<%=fb.intBox("num_devolucion",numDev,false,false,false,10)%>
			<%//=fb.submit("go","Ir")%>
				
			Proveedor&nbsp;&nbsp;
		     <%=fb.textBox("codProv",codProv,false,false,false,5)%>&nbsp;&nbsp;
			 <%=fb.textBox("descProv","",false,false,true,30)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
			Factura.
			<%=fb.intBox("factura",factura,false,false,false,10)%>
			<%//=fb.submit("go","Ir")%>
				
			Nota de Crédito &nbsp;&nbsp;
			<%=fb.intBox("ncredito",ncredito,false,false,false,10)%>
			<%=fb.submit("go","Ir")%>
		</td>
	<%=fb.formEnd()%>
	</tr>
	
</table>
	</td>
	</tr>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

 <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070")){

if (anioDev==null)  anioDev  ="";
if (numDev==null)   numDev   ="";

if (factura==null)  factura  ="";
if (ncredito==null) ncredito ="";
if (codProv==null)  codProv  ="";
%>
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
		<%
//}
%>
			&nbsp;
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("codProv",codProv)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("ncredito",ncredito)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("tipo_dev",tipo_dev)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("all_item",allItem)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("codProv",codProv)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("ncredito",ncredito)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("tipo_dev",tipo_dev)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("all_item",allItem)%>
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

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("devolucion",request.getContextPath()+request.getServletPath(),"");%>
<%=fb.formStart(true)%>
<%=fb.hidden("index","")%>
		<tr class="TextHeader" align="center">
			<td width="8%">Fecha Doc.</td>
			<td width="4%">A&ntilde;o</td>
			<td width="8%">No. Devoluciòn</td>
			<td width="25%" align="left">Proveedor</td>
			<td width="10%">N/C.</td>
			<td width="17%">Factura</td>
			<td width="10%">Usuario</td>
			<td width="10%">Tipo Dev.</td>
			<td width="5%">Estado</td>
			<td width="3%">&nbsp;</td>
		</tr>
		
		
		  	<% if ((appendFilter == null || appendFilter.trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="11">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="11"> <font color="#FF0000"> I N T R O D U Z C A &nbsp;&nbsp;&nbsp;&nbsp;P A R Á M E T R O S&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;B Ú S Q U E D A</font></td>
		</tr>
		<%}
		
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%> 
	<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
 	<%=fb.hidden("id"+i,cdo.getColValue("num_devolucion"))%>
	<%=fb.hidden("anulado"+i,cdo.getColValue("anulado"))%>
	<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
	<%=fb.hidden("tipoDev"+i,cdo.getColValue("tipo_dev"))%>
	
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("fecha_devolucion")%></td>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("num_devolucion")%></td>
			<td><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="center"><%//=cdo.getColValue("nCredito")%>
      <%=fb.hidden("nCredito"+i,cdo.getColValue("nCredito"))%>
      <%=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
			<%=cdo.getColValue("nCredito")%>
			</td>
			<td align="right"><%=cdo.getColValue("factura")%></td>
			<td align="center"><%=cdo.getColValue("usuario")%></td>
			<td align="center"><%=cdo.getColValue("desc_tipo_dev")%></td>
			<td align="center"><%=cdo.getColValue("anuladoDesc")%></td>
			<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("codProv",codProv)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("ncredito",ncredito)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("tipo_dev",tipo_dev)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("all_item",allItem)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("codProv",codProv)%>
				<%=fb.hidden("factura",factura)%>
				<%=fb.hidden("ncredito",ncredito)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("tipo_dev",tipo_dev)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("all_item",allItem)%>
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