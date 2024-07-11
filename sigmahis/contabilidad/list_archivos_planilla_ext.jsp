<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%> 
<%@ page import="issi.admin.CommonDataObject"%>
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
==================================================================================
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
int iconHeight = 40;
int iconWidth = 40;
String sql = "";
String appendFilter = "";
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String estado = request.getParameter("estado");  
String fg = request.getParameter("fg");
if (fg == null)fg="";

if (anio == null)anio = "";
if (mes == null) mes = "";
if (estado == null) estado = "";
if (!estado.trim().equals("")) appendFilter += " and upper(a.estado)='"+estado+"'"; 

if (request.getMethod().equalsIgnoreCase("GET"))
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
 
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and anio="+request.getParameter("anio"); 
	}
	if (request.getParameter("mes") != null && !request.getParameter("mes").equals(""))
	{
		appendFilter += " and mes="+request.getParameter("mes"); 
	}
	 
	if (request.getParameter("estado") != null && !request.getParameter("estado").equals(""))
	{
		appendFilter += " and a.estado ='"+request.getParameter("estado")+"'";
 	}
	 
 	 
	
 	if(request.getParameter("anio") != null)
	{

sql="select distinct a.anio ,a.mes, nombre_archivo,decode(estado,'C','CARGADO','P','PROCESADO','A','APROBADO') as estadoDesc,estado,usuario_creacion as usuarioCrea,decode(lpad(mes,2,'0'), '01','ENERO','02','FEBRERO','03','MARZO','04','ABRIL','05','MAYO','06','JUNIO','07','JULIO','08','AGOSTO','09','SEPTIEMBRE','10','OCTUBRE','11','NOVIEMBRE','12','DICIEMBRE') descMes,nvl(asiento_generado,'N') as asiento_generado,asconsecutivo as no from tbl_pla_pago_empleado_ext a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.anio desc, a.mes desc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) FROM ("+sql+")");
	
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
document.title = 'Inventario - Articulos - '+document.title;
function add(){showPopWin('../contabilidad/param_cargar_txt.jsp',winWidth*.95,_contentHeight*.75,null,null,'');}
function preComp(anio,mes){showPopWin('../common/read_file.jsp?fp=FILEPLA&docType=FILEPLA&procesar=S&anio='+anio+'&mes='+mes,winWidth*.65,_contentHeight*.75,null,null,'');}
function delArchivo(anio,mes,file){showPopWin('../process/del_reg_archivo_pla.jsp?fp=FILEPLA&docType=FILEPLA&procesar=S&anio='+anio+'&mes='+mes+'&file='+file,winWidth*.65,_contentHeight*.75,null,null,'');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Cargar Nuevo Archivo';break;
		case 1:msg='Generar Pre-Comprobante';break;
		case 2:msg='Eliminar Archivo';break;
		case 3:msg='Imprimir Reporte';break;
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
		if(k=='')alert('Por favor seleccione un Archivo antes de ejecutar una acción!');
			else
			{
				var compania = '<%=(String)session.getAttribute("_companyId")%>';  
				var anio = eval('document.form0.anio'+k).value; 
				var mes = eval('document.form0.mes'+k).value;
				var nombre = eval('document.form0.nombre_archivo'+k).value; 
				var estado = eval('document.form0.estado'+k).value; 
				var asiento_generado = eval('document.form0.asiento_generado'+k).value; 
				var no = eval('document.form0.no'+k).value;
				
				if(option==1){if(asiento_generado=='N'&&estado=='C')preComp(anio,mes);else CBMSG.warning('EL ARCHIVO YA TIENE PRE - COMPROBANTE GENERADO!!!');}
				else if(option==2){if(asiento_generado=='N'&&estado=='C')delArchivo(anio,mes,nombre);else CBMSG.warning('EL ARCHIVO YA TIENE PRE - COMPROBANTE GENERADO. NO SE PUEDE ELIMINAR !!!');}
				else if(option==3){abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&mes='+mes+'&no='+no+'&tipo=&fg=PLA&docType=PLAEXT&regType=');}   
				 
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
	<jsp:param name="title" value="MAYOR GENERAL - CARGAR ARCHIVOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
	 <tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>		
		<authtype type='50'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>	
		<authtype type='51'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/proceso.bmp"></a></authtype>		
		<authtype type='52'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/x.png"></a></authtype>		
		<authtype type='53'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/printer.gif"></a></authtype>
		
		</td>
	</tr>
	<tr>
		<td>
 <table width="100%" cellpadding="1" cellspacing="0">
	 
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<tr class="TextFilter">
	<td colspan="2">
		Año
		<%=fb.intBox("anio",anio,false,false,false,15,null,null,null)%> 
		&nbsp;&nbsp; Mes:
		 <%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"T")%>
		&nbsp;&nbsp;Estado
		<%=fb.select("estado","C=PENDIENTE,A=PROCESADO",estado,false,false,0,"T")%>
		 
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
 <tr>
	<td align="right">&nbsp;<!--<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>--></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>

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
			<td width="10%">Año</td>
			<td width="10%">Mes</td>
			<td width="40%">Nombre</td>
			<td width="10%">Estado</td>
			<td width="15%">Usuario Creacion</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
	for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
		<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("nombre_archivo"+i,cdo.getColValue("nombre_archivo"))%>
		<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("asiento_generado"+i,cdo.getColValue("asiento_generado"))%>
		<%=fb.hidden("no"+i,cdo.getColValue("no"))%>
		
		
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("anio")%></td>
					<td>&nbsp;<%=cdo.getColValue("descMes")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre_archivo")%></td>
					<td>&nbsp;<%=cdo.getColValue("estadoDesc")%></td> 
					<td>&nbsp;<%=cdo.getColValue("usuarioCrea")%></td> 
					<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("fg",fg)%>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("estado",estado)%> 
<%=fb.hidden("fg",fg)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>