<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al= new ArrayList();
ArrayList alWh = new ArrayList();

int rowCount = 0;

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cod_almacen=request.getParameter("cod_almacen");
String articulo=request.getParameter("articulo");
String familyCode=request.getParameter("familyCode");
String classCode=request.getParameter("classCode");
String subclassCode=request.getParameter("subclassCode");
String anaquel = request.getParameter("anaquel");
String descAlmacen = "";
String barCode ="";

String cantidad="",disponible="",cod_articulo="",descripcion="";

XMLCreator xml = new XMLCreator(ConMgr);
sbSql.append("select * from (select codigo as value_col, codigo||' - '||descripcion as label_col, compania||'@'||codigo_almacen as key_col from tbl_inv_anaqueles_x_almacen ana where compania = ").append(session.getAttribute("_companyId")).append(" and cod_anaquel is not null union all select -1 as value_col, -1||' - TODOS' as label_col, compania||'@'||codigo_almacen as key_col from tbl_inv_almacen where compania = ").append(session.getAttribute("_companyId")).append(") z order by 2 asc");
xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"anaqueles_x_compania"+UserDet.getUserId()+".xml",sbSql.toString());

if (fg == null) fg = "";
if (familyCode == null) familyCode = "";
if (subclassCode == null) subclassCode = "";
if (anaquel == null) anaquel = "";

if (!familyCode.equals("")) {
	sbFilter.append(" and f.cod_flia = ").append(familyCode);

	if (classCode == null) classCode = "";
	if (!classCode.equals("")) sbFilter.append(" and f.cod_clase = ").append(classCode);
}

if (!subclassCode.trim().equals("")) {
	sbFilter.append(" and f.cod_subclase = ").append(subclassCode);
}

sbSql = new StringBuffer();
sbSql.append("select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania = ").append(session.getAttribute("_companyId")).append(" order by codigo_almacen");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
if (cod_almacen == null || cod_almacen.trim().equals("")) {
	if (alWh.size() > 0) {
		//cod_almacen = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
		//descAlmacen = ((CommonDataObject) alWh.get(0)).getOptLabelColumn();
		//sbFilter.append(" and a.codigo_almacen = ").append(cod_almacen);
	} else cod_almacen = "";
} else {
	sbFilter.append(" and a.codigo_almacen = ").append(cod_almacen);
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

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

	if (request.getParameter("barcode") != null && !request.getParameter("barcode").trim().equals("")) {
		barCode = request.getParameter("barcode");
		if (crypt) {
			try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		sbFilter.append(" and f.cod_barra = '").append(IBIZEscapeChars.forSingleQuots(barCode).trim()).append("'");
		barCode = "";
	}

	if ((request.getParameter("disponible") != null && !request.getParameter("disponible").trim().equals("") )&& (request.getParameter("cantidad") != null && !request.getParameter("cantidad").trim().equals(""))) {
		if (request.getParameter("disponible").trim().equals("M"))
			sbFilter.append(" and a.disponible >= ").append(request.getParameter("cantidad"));
		else if (request.getParameter("disponible").trim().equals("ME"))
			sbFilter.append(" and a.disponible <= ").append(request.getParameter("cantidad"));
		else if (request.getParameter("disponible").trim().equals("I"))
			sbFilter.append(" and a.disponible = ").append(request.getParameter("cantidad"));

		disponible =request.getParameter("disponible");
		cantidad = request.getParameter("cantidad");
	}
	if (request.getParameter("cod_articulo") != null && !request.getParameter("cod_articulo").equals("")){
		//sbFilter.append(" and upper(a.cod_articulo) like '%").append(request.getParameter("cod_articulo").toUpperCase()).append("%'");
		sbFilter.append(" and upper(a.cod_articulo) = ").append(request.getParameter("cod_articulo").toUpperCase());
		cod_articulo = request.getParameter("cod_articulo");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals("")){
		sbFilter.append(" and upper(f.descripcion) like '%").append(request.getParameter("descripcion").toUpperCase()).append("%'");
		descripcion = request.getParameter("descripcion");
	}

	if (!anaquel.equals("-1") && !anaquel.trim().equals("")) {
		sbFilter.append(" and a.codigo_anaquel = '").append(anaquel).append("'");
	}


	if(cod_almacen != null) {
		sbSql = new StringBuffer();
		sbSql.append("select a.compania, a.codigo_almacen as almacenes, a.cod_articulo as articuloid, f.cod_flia as familiaid, f.cod_clase as claseid, f.cod_subclase, nvl(a.disponible,0) as disponible, nvl(a.pto_reorden,0) as pto_reorden, nvl(a.pto_max_existencia,0) as pto_max_existencia, b.descripcion as descalmacen, f.descripcion as nom,f.cod_medida from tbl_inv_inventario a, tbl_inv_almacen b, tbl_inv_articulo f where a.compania = b.compania and a.codigo_almacen = b.codigo_almacen and a.compania = f.compania and a.cod_articulo = f.cod_articulo and f.estado = 'A' and a.compania = ").append(session.getAttribute("_companyId")).append(sbFilter).append(" order by a.codigo_almacen, f.cod_flia,  f.cod_clase, a.cod_articulo");
		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (").append(sbSql).append(") a) where rn between ").append(previousVal).append(" and ").append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) count from (").append(sbSql).append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
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
document.title="Punto de Reorden de Art�culos por Almac�n - Editar - "+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
function getMain(formX)
{
	formX.familyCode.value  = document.search00.familyCode.value;
	formX.classCode.value   = document.search00.classCode.value;
	formX.cod_almacen.value = document.search00.cod_almacen.value;
	formX.disponible.value = document.search02.disponible.value;
	return true;
}
function setPunto(fg,k)
{
	var pto_max     = eval('document.form1.pto_max_existencia'+k).value;
	var pto_reorden = eval('document.form1.pto_reorden'+k).value;
	var disponible = eval('document.form1.disponible'+k).value;
	var x=0;

if(fg ==1)//pto_reorden
{
		if ((!isNaN(pto_reorden)|| (pto_reorden !='')) && (!isNaN(pto_max)|| (pto_max !='') ))
		{

				if((parseInt(pto_reorden) > parseInt(pto_max)))
				{
					eval('document.form1.pto_reorden'+k).value='';
					alert('El punto de reorden NO puede ser mayor que el punto m�ximo...,VERIFIQUE!');
					x++;
					//eval('document.form1.check'+k).value = "N";
				}

		}
}
//if(!isNaN(eval('document.requisicion.cantidad'+i).value)){
else if(fg ==2)//pto_max
{
	if((!isNaN(pto_max)|| (pto_max !='')) && (!isNaN(pto_reorden)|| (pto_reorden !='')) )
	{
			if((parseInt(pto_max) < parseInt(pto_reorden)))
			{
				eval('document.form1.pto_max_existencia'+k).value='';
				alert('El punto m�ximo NO puede ser menor que el punto de reorden...,VERIFIQUE!');
				x++;
				//eval('document.form1.check'+k).value = "N";
			}
			if((parseFloat(pto_max) < parseFloat(disponible)))
			{
				eval('document.form1.pto_max_existencia'+k).value='';
				alert('El punto m�ximo NO puede ser menor que el disponible...,VERIFIQUE!');
				x++;
				//eval('document.form1.check'+k).value = "N";
			}

	}
}


	if(x==0)
		eval('document.form1.check'+k).value = "S";
	else eval('document.form1.check'+k).value = "N";
}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true">
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value=""></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input c�digo barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el c�digo de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PUNTO REORDEN DE ART�CULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<% if (!fg.equalsIgnoreCase("CTRL")) { %>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">



	<tr class="TextFilter">
		<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

		<td colspan="3">
		 Almac&eacute;n
			<%=fb.select("cod_almacen",alWh,cod_almacen,false, false, 0,null,"width:130px","onchange=loadXML('../xml/anaqueles_x_compania"+UserDet.getUserId()+".xml','anaquel','','VALUE_COL','LABEL_COL','"+(session.getAttribute("_companyId"))+"@'+this.value,'KEY_COL','')",null,"S")%>


				&nbsp;&nbsp;
				Anaquel:&nbsp;<%=fb.select("anaquel",anaquel,anaquel,false,false,0,null,"width:130px","",null,"T")%>
				<script>
					loadXML('../xml/anaqueles_x_compania<%=UserDet.getUserId()%>.xml','anaquel','<%=anaquel%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>@<%=cod_almacen%>','KEY_COL','T');
				</script>


			Familia
			<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
			<script language="javascript">
			loadXML('../xml/itemFamily.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
			</script>
			Clase
			<%=fb.select("classCode","","",false,false,0,"text10",null,"onChange=\"javascript:loadXML('../xml/subclase.xml','subclassCode','"+subclassCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.search00.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>

			<script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');
			</script>

			Subclase:
			<%=fb.select("subclassCode","","",false,false,0,"text10",null,"")%>
			<script language="javascript">
			loadXML('../xml/subclase.xml','subclassCode','<%=subclassCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.search00.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.search00.classCode.value"%>','KEY_COL','T');
			</script>

		</td>
		</tr>
			<tr class="TextFilter">
				<td width="20%">
					Art&iacute;culo
					<%=fb.intBox("cod_articulo","",false,false,false,15)%>
				</td>
				<td width="20%">
					Descripci&oacute;n
					<%=fb.textBox("descripcion","",false,false,false,20)%>
				</td>
				<td width="60%">
					Disponible
					<%=fb.select("disponible","M=MAYOR, ME=MENOR, I=IGUAL",disponible,false,false,0,"Text10",null,null,"","T")%> <%=fb.textBox("cantidad",cantidad,false,false,false,8,10,null,null,null)%>
					<%=fb.submit("go","Ir")%>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C.Barra <%=fb.textBox("barcode",barCode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
				</td>
<%=fb.formEnd()%>
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("cod_almacen",cod_almacen).replaceAll(" id=\"cod_almacen\"","")%>
				<%=fb.hidden("disponible",disponible).replaceAll(" id=\"disponible\"","")%>
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("cod_articulo",""+cod_articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("anaquel",""+anaquel)%>

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
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("cod_almacen",cod_almacen).replaceAll(" id=\"cod_almacen\"","")%>
				<%=fb.hidden("disponible",disponible).replaceAll(" id=\"disponible\"","")%>
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("cod_articulo",""+cod_articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("anaquel",""+anaquel)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<% } %>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("cod_almacen",cod_almacen)%>
<%=fb.hidden("invSize",""+al.size())%>
<%=fb.hidden("fg",fg)%>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			 <%if(cod_almacen != null){%>

				<tr>
					<td colspan="2"><table width="100%" cellpadding="1" cellspacing="1">
<% if (fg.equalsIgnoreCase("CTRL")) { %>
							<tr class="TextHeader SpacingTextBold" align="center">
								<td colspan="9" align="center">PUNTO DE REORDEN</td>
							</tr>
<% } %>
							<tr class="TextHeader" align="center">
								<td width="06%">Familia</td>
								<td width="06%">Clase</td>
								<td width="06%">Subclase</td>
								<td width="06%">Art&iacute;culo</td>
								<td width="42%" align="left">Descripci&oacute;n de Art&iacute;culo</td>
								<td width="10%">Unidad</td>
								<td width="10%">Disponible</td>
								<td width="10%">Pto Reorden</td>
								<td width="10%">Pto Max</td>

							</tr>
							<%if(al.size()==0){%>
							<tr>
								<td colspan="9" class="TextRow01" align="center"> NO HAY ARTICULOS EN INVENTARIO EN ESTE ALMAC&Eacute;N </td>
							</tr>
							<%}%>
							<%for(int a=0;a<al.size();a++){
								CommonDataObject cdos= (CommonDataObject) al.get(a);
								%>
							<tr class="TextRow01">
							<%=fb.hidden("check"+a,"N")%>
							<%=fb.hidden("familiaId"+a,cdos.getColValue("familiaId"))%>
							<%=fb.hidden("claseId"+a,cdos.getColValue("claseId"))%>
							<%=fb.hidden("cod_subclase"+a,cdos.getColValue("cod_subclase"))%>
							<%=fb.hidden("articuloId"+a,cdos.getColValue("articuloId"))%>
							<%=fb.hidden("disponible"+a,cdos.getColValue("disponible"))%>
							<%=fb.hidden("almacenes"+a,cdos.getColValue("almacenes"))%>


								<td align="center"><%=cdos.getColValue("familiaId")%></td>
								<td align="center"><%=cdos.getColValue("claseId")%></td>
								<td align="center"><%=cdos.getColValue("cod_subclase")%></td>
								<td align="center"><%=cdos.getColValue("articuloId")%></td>
								<td align="left"><%=cdos.getColValue("nom")%> </td>
								<td align="center"><%=cdos.getColValue("cod_medida")%> </td>
								<td align="center"><%=cdos.getColValue("disponible")%> </td>
								<td align="center"><%=fb.intBox("pto_reorden"+a,cdos.getColValue("pto_reorden"),false,false,viewMode,10,10,"Text10",null,"onChange=\"javascript:setPunto(1,"+a+")\"")%> </td>
								<td align="center"><%=fb.intBox("pto_max_existencia"+a,cdos.getColValue("pto_max_existencia"),false,false,viewMode,10,10,"Text10",null,"onChange=\"javascript:setPunto(2,"+a+")\"")%> </td>

							</tr>
							<%}%>
						</table></td>
				</tr>
				<%}else{%>
				<tr class="TextRow02">
					<td colspan="2" align="right">&nbsp;</td>
				</tr>
				<%}%>
			</table>
</div>
</div>
<% if (cod_almacen != null) { %>
				<tr class="TextRow02">
					<td colspan="2" align="right" class="TableLeftBorder TableRightBorder"><%=fb.submit("save","Guardar",true,viewMode)%></td>
				</tr>
<% } %>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</td>
	</tr>
<% if (!fg.equalsIgnoreCase("CTRL")) { %>
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
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("cod_almacen",cod_almacen).replaceAll(" id=\"cod_almacen\"","")%>
				<%=fb.hidden("disponible",disponible).replaceAll(" id=\"disponible\"","")%>
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("cod_articulo",""+cod_articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("anaquel",""+anaquel)%>
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
				<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
				<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
				<%=fb.hidden("cod_almacen",cod_almacen).replaceAll(" id=\"cod_almacen\"","")%>
				<%=fb.hidden("disponible",disponible).replaceAll(" id=\"disponible\"","")%>
				<%=fb.hidden("cantidad",""+cantidad)%>
				<%=fb.hidden("cod_articulo",""+cod_articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("anaquel",""+anaquel)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<% } %>
</table>
<%@ include file="/common/footer.jsp"%>
</body>
</html>
<%
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
ArrayList al1= new ArrayList();
//String fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
int invSize =Integer.parseInt(request.getParameter("invSize"));
for(int z=0;z<invSize;z++)
{
	if (request.getParameter("check"+z) != null && !request.getParameter("check"+z).equals(""))
	{
			articulo=request.getParameter("articuloId"+z);
			familyCode=request.getParameter("familiaId"+z);
			classCode=request.getParameter("claseId"+z);
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_inv_inventario");
			cdo.addColValue("pto_reorden",request.getParameter("pto_reorden"+z));
			cdo.addColValue("pto_max_existencia",request.getParameter("pto_max_existencia"+z));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion","sysdate");
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_articulo="+articulo+" and codigo_almacen="+request.getParameter("almacenes"+z));
		 al1.add(cdo);
	}
}
if(al1.size() == 0)
{
	 cdo = new CommonDataObject();
	 cdo.setTableName("tbl_inv_inventario");
	 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and codigo_almacen="+cod_almacen);
	 al1.add(cdo);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
SQLMgr.updateList(al1);
ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (fg.equalsIgnoreCase("CTRL")) { %>
	window.opener.location.reload(true);
	window.close();
<%
} else {
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/punto_reorden_articulo_list.jsp")) {
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/punto_reorden_articulo_list.jsp")%>';
<% } else { %>
	window.location = '<%=request.getContextPath()%>/inventario/punto_reorden_articulo_list.jsp';
<%
	}
}
} else throw new Exception(SQLMgr.getErrMsg());
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
