<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 40;
int iconWidth = 40;
String sql = "";
String appendFilter = "";
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String fg = request.getParameter("fg");
if (fg == null)fg="INV";
String codigo  = "";
String descrip = "";
String subclase ="";
String barcode = "",itbm="";
if (familyCode == null)
{
	familyCode = "";
	classCode = "";
}
if (!familyCode.trim().equals(""))
{
	appendFilter += " and a.cod_flia="+familyCode;

	if (classCode == null) classCode = "";
	if (!classCode.equals("")) appendFilter += " and a.cod_clase="+classCode;
}
if (estado == null) estado = "";
if (!estado.trim().equals("")) appendFilter += " and upper(a.estado)='"+estado+"'";
if (consignacion == null) consignacion = "";
if (!consignacion.trim().equals("")) appendFilter += " and upper(a.consignacion_sino)='"+consignacion+"'";
if (venta == null) venta = "";
if (!venta.trim().equals("")) appendFilter += " and upper(a.venta_sino)='"+venta+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

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


	String fDate="",tDate="",afectaMayor="";
	if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
	{
		appendFilter += " and upper(a.cod_articulo) like '%"+request.getParameter("code").toUpperCase()+"%'";
	codigo     = request.getParameter("code");
	}
	if (request.getParameter("name") != null && !request.getParameter("name").equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
	descrip    = request.getParameter("name");
	}
	if (request.getParameter("barcode") != null && !request.getParameter("barcode").equals(""))
	{
		barcode = request.getParameter("barcode");
		if (crypt) {
			try{barcode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		appendFilter += " and tipo !='A' and a.cod_barra = '"+IBIZEscapeChars.forSingleQuots(barcode).trim()+"'";
		barcode = "";
	}
	if (request.getParameter("subclase") != null && !request.getParameter("subclase").equals(""))
	{
		appendFilter += " and a.cod_subclase like '%"+request.getParameter("subclase").toUpperCase()+"%'";
	subclase    = request.getParameter("subclase"); // utilizada para mantener la Descripción del Artículo
	}
	if (request.getParameter("itbm") != null && !request.getParameter("itbm").equals(""))
	{
		appendFilter += " and upper(a.itbm) ='"+request.getParameter("itbm").toUpperCase()+"'";
		itbm    = request.getParameter("itbm");
	}
	if(!fg.trim().equals("FAR")){if(!fg.trim().equals("INV"))appendFilter += " and (a.fg ='"+fg+"' or nvl(get_sec_comp_param(a.compania,'INV_MOSTRAR_ART_INV'),'N')='S') ";

	if(fg.trim().equals("INV"))appendFilter +=" and replicado_far='N' and a.fg ='"+fg+"' ";}

	if(fg.trim().equals("FAR"))appendFilter +=" and replicado_far='S' ";

	if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_modif) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
		fDate = request.getParameter("fecha_desde");
	}
	if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_modif) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
		tDate = request.getParameter("fecha_hasta");
	}
	if (request.getParameter("afectaMayor") != null && !request.getParameter("afectaMayor").trim().equals(""))
	{
		appendFilter += " and a.fecha_afecta_conta is not null ";
		afectaMayor = request.getParameter("afectaMayor");
	}


	if(request.getParameter("familyCode") != null)
	{

sql="select a.product_id as productId,a.compania as companyCode, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode,substr(a.descripcion,1,100) as description, b.nombre as familyName, c.descripcion as className ,nvl(a.consignacion_sino,'N')isAppropiation,nvl(a.venta_sino,'N') isSaleItem,nvl(a.estado,' ')status,a.cod_subclase as subClassCode ,decode(a.foto,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("articulosimage").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.foto) as foto, nvl(a.foto,' ') as marcaDesc  from tbl_inv_articulo a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c where a.compania=b.compania and a.cod_flia=b.cod_flia and a.compania=c.compania and a.cod_flia=c.cod_flia and a.cod_clase=c.cod_clase and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.nombre, c.descripcion, a.descripcion";


	System.out.println("SQL:="+sql);
	al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Item.class);

	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.search00.barcode.focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="name,test"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
		<jsp:param name="substrType" value="01"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
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
		Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
		</script>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="2">
		Estado
		<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
		Consignaci&oacute;n
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"T")%>
		Venta
		<%=fb.select("venta","S=SI,N=NO",venta,false,false,0,"T")%>
		ITBM
		<%=fb.select("itbm","S=SI,N=NO",itbm,false,false,0,"T")%>&nbsp;Cod Subclase
		<%=fb.textBox("subclase",subclase,false,false,false,30,null,null,null)%>
		</td>
</tr>

<tr class="TextFilter">
	<td colspan="2">
		C&oacute;digo
		<%=fb.textBox("code",codigo,false,false,false,15,null,null,null)%>
		Nombre
		<%=fb.textBox("name",descrip,false,false,false,30,null,null,null)%>
&nbsp;

		<%=fb.submit("go","Ir")%>
		&nbsp;&nbsp; C&oacute;d Barra
		<%=fb.textBox("barcode",barcode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
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
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("index","")%>

			<tr class="TextRow02">
					<td colspan="4" align="right"><%=fb.submit("saveU","Guardar",true,false)%></td>
			</tr>
			<tr class="TextHeader" align="center">
			<td width="20%">C&oacute;digo</td>
			<td width="50%">Nombre</td>
			<td width="25%">Foto</td>
			<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','setImage',"+al.size()+",this,0);\"","Seleccionar todos los registros listados!")%></td>
		</tr>
<%
String familyClass = "";
for (int i=0; i<al.size(); i++)
{
	Item item = (Item) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!familyClass.equalsIgnoreCase("["+item.getFamilyName()+"] "+item.getClassName()))
	{
%>
		<tr class="TextHeader01">
			<td colspan="4">[<%=item.getFamilyName()%>] <%=item.getClassName()%></td>
		</tr>
<%
	}
%>
	<%=fb.hidden("id"+i,item.getItemCode())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=item.getItemCode()%></td>
			<td><%=item.getDescription()%></td>
			<td align="center">&nbsp;
			<%=fb.fileBox("foto"+i,item.getFoto(),false,false,20)%> - <%=item.getMarcaDesc()%>
			</td>
			<td align="center"><%=fb.checkbox("setImage"+i,"S",false,false ,null,null,"")%></td>
		</tr>
<%
	familyClass = "["+item.getFamilyName()+"] "+item.getClassName();
}
%>
			<tr class="TextRow02">
					<td colspan="4" align="right"><%=fb.submit("saveB","Guardar",true,false)%></td>
			</tr>
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
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("code",codigo)%>
<%=fb.hidden("name",descrip)%>
<%=fb.hidden("barcode",barcode)%>
<%=fb.hidden("itbm",itbm)%>
<%=fb.hidden("fg",fg)%>
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
		Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("articulosimage"),20);

	al.clear();
	int size = Integer.parseInt((String) ht.get("size"));
	System.out.println(" size =="+size);
		for (int i=0; i<size; i++)
	{

		if (((String) ht.get("setImage"+i)) != null)
		{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_inv_articulo");
		cdo.setWhereClause("cod_articulo="+(String) ht.get("id"+i) +" and compania="+(String) session.getAttribute("_companyId"));

		cdo.setKey(i);
		cdo.setAction("U");
		cdo.addColValue("fecha_modif","sysdate");
		cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
		cdo.addColValue("foto",(String) ht.get("foto"+i));

		al.add(cdo);
		}
	}

	if (al.size() == 0)
	{
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_inv_articulo");
		cdo.setWhereClause("cod_articulo=0 and  and compania=-"+(String) session.getAttribute("_companyId"));

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
	window.location = '../inventario/articulo_upd_images.jsp?fg=<%=fg%>&familyCode=<%=familyCode%>&classCode=<%=classCode%>&estado=<%=estado%>&consignacion=<%=consignacion%>&venta=<%=venta%>&subclase=<%=subclase%>&codigo=<%=codigo%>&descrip=<%=descrip%>&barcode=<%=barcode%>&itbm=<%=itbm%>';
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
