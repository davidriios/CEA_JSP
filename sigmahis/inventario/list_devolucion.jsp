<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
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
FG         FP                 DESCRIPCION
UA 		   SD				  SOLICITUD DE DEVOLUCION DE UNIDADES ADMINISTRATIVAS
EA         SD 				  DEVOLUCION DE ALMACENES
UA		   AP 				  APROBACION DE DEVOLUCIONES DE UNIDADES ADMINISTRATIVAS
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
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String wh = request.getParameter("wh");
String codRef = request.getParameter("cod_ref");
String fDate = "";
String tDate = "";
StringBuffer sbSql = new StringBuffer();
if(fg==null) fg = "UA";
if(fp==null) fp = "SD";
if(wh==null) wh = "";
if(codRef==null) codRef = "";

sbSql = new StringBuffer();
sbSql.append("select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania=");
sbSql.append(session.getAttribute("_companyId"));
if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_almacen_ua")!=null){
	sbSql.append(" and codigo_almacen in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_almacen_ua")));
	sbSql.append(")");}
	else sbSql.append(" and codigo_almacen in (-2)");
}
sbSql.append(" order by codigo_almacen");
System.out.println("whSql = \n"+sql);
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

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
	String devPor = "";
	String estado  = "";
	String fechaini = "";
	String fechafin = "";
	if (request.getParameter("num_devolucion") != null && !request.getParameter("num_devolucion").trim().equals("")){
		appendFilter += " and d.num_devolucion = "+request.getParameter("num_devolucion");
		numDev     = request.getParameter("num_devolucion");   // utilizada para mantener el número de la devolción filtrada

	}  if (request.getParameter("anio_devolucion") != null && !request.getParameter("anio_devolucion").trim().equals("")){
		appendFilter += " and d.anio_devolucion = "+request.getParameter("anio_devolucion");
		anioDev    = request.getParameter("anio_devolucion");   // utilizada para mantener el año de la devolución
	}
	if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals("")){
		appendFilter += " and upper(d.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
		estado     = request.getParameter("estado");    // utilizada para mantener el estado filtrado
	}
	if (request.getParameter("devuelve") != null && !request.getParameter("devuelve").trim().equals(""))
		{
		if(!fg.equals("EA")){
				appendFilter += " and upper(ue.descripcion) like '%"+request.getParameter("devuelve").toUpperCase()+"%'";
			}
			else
			{
			appendFilter += " and upper(al.descripcion) like '%"+request.getParameter("devuelve").toUpperCase()+"%'";
			}
	}
    if (request.getParameter("fechaini") != null && !request.getParameter("fechaini").trim().equals(""))
	{
	 fechaini    = request.getParameter("fechaini");
	 appendFilter += " and trunc(d.fecha_devolucion) >= to_date('"+request.getParameter("fechaini")+"','dd/mm/yyyy')";
	}
	if (request.getParameter("fechafin") != null && !request.getParameter("fechafin").trim().equals(""))
	{
	 fechafin    = request.getParameter("fechafin");
	 appendFilter += " and trunc(d.fecha_devolucion) <= to_date('"+request.getParameter("fechafin")+"','dd/mm/yyyy')";
	}
    
    if (!codRef.trim().equals("")){
      appendFilter += " and d.cod_ref like '%"+codRef+"%'";
    }
    
	String userFilter = "";

	if(request.getParameter("wh") != null) {

	if(!wh.trim().equals(""))appendFilter += " and d.codigo_almacen="+wh;
	else {
		if (!UserDet.getUserProfile().contains("0"))
			if(session.getAttribute("_almacen_ua")!=null){
				appendFilter += " and d.codigo_almacen in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua"))+")";
			} else appendFilter += " and d.codigo_almacen = -2";
	}

	if(fg.equals("UA"))
	{
	    appendFilter += " and sr.tipo_transferencia IN ('U','C') ";
		if (!UserDet.getUserProfile().contains("0")) 
		{
			userFilter = " and (d.unidad_administrativa in (";
			if(session.getAttribute("_ua")!=null)
			  userFilter +=CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua"));
			else userFilter +="-1";
			  userFilter +=")";
		
			userFilter +="  or d.codigo_almacen in (";
			if(session.getAttribute("_almacen_ua")!=null) userFilter +=CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua"));
			else  userFilter +="-2";
			userFilter +="))";
		}
	}else if(fg.equals("EA")){
		appendFilter += " and sr.tipo_transferencia = 'A' ";
	}
	sql="SELECT d.anio_devolucion, d.num_devolucion, d.compania, to_char(d.fecha_devolucion,'dd/mm/yyyy') as fecha_devolucion, d.observacion, d.monto, d.estado, decode(d.estado, 'A', 'APROBADO', 'R', 'RECIBIDO', 'T', 'TRAMITE', 'N', 'ANULADO') desc_estado, en.anio, en.no_entrega, sr.tipo_transferencia, decode(sr.tipo_transferencia, 'U', ue.descripcion, 'A', al.descripcion, ue.descripcion) devuelve, d.codigo_almacen, d.cod_ref FROM tbl_inv_devolucion d, tbl_inv_entrega_material en, tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_almacen al where d.compania = "+(String) session.getAttribute("_companyId")+" and d.anio_entrega = en.anio(+) and d.no_entrega = en.no_entrega(+) and d.compania_dev = en.compania(+) and en.req_anio = sr.anio(+) and en.req_tipo_solicitud = sr.tipo_solicitud(+) and en.req_solicitud_no = sr.solicitud_no(+) and en.compania_sol = sr.compania(+) and sr.compania = d.compania and al.compania = d.compania_dev and d.codigo_almacen = al.codigo_almacen and ue.codigo(+) = d.unidad_administrativa and ue.compania(+) = d.compania " + appendFilter + userFilter + " order by d.anio_devolucion desc,d.num_devolucion desc ";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Inventario - '+document.title;
function add(){abrir_ventana('../inventario/reg_devolucion.jsp?mode=add&fg=<%=fg%>');}
function edit(anio_devolucion, id, tp){abrir_ventana('../inventario/reg_devolucion.jsp?mode=view&id='+id+'&anio='+anio_devolucion+'&fg=<%=fg%>');}
function aprov(anio_devolucion, id, tp){abrir_ventana('../inventario/reg_devolucion.jsp?mode=view&id='+id+'&anio='+anio_devolucion+'&fg=<%=fg%>&fp=AP');}
function confirmar(anio_devolucion, id, tp){abrir_ventana('../inventario/reg_devolucion.jsp?mode=view&id='+id+'&anio='+anio_devolucion+'&fg=<%=fg%>&fp=CO');}
function printList(){<% if ((appendFilter != null || !appendFilter.trim().equals("")) && al.size() != 0){%>abrir_ventana('../inventario/print_list_devolucion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>&fp=<%=fp%>');<%}else{%>alert('I N T R O D U Z C A     P A R A M E T R O S    D E    B U S Q U E D A');<%}%>}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%if(fg.equals("UA") && fp.trim().equals("AP")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - APROBACION DE DEVOLUCIONES DE MATERIALES DE UNIDADES ADMINISTRATIVAS"></jsp:param>
</jsp:include>
<%} else if(fg.equals("UA")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - DEVOLUCION DE MATERIALES DE UNIDADES ADMINISTRATIVAS"></jsp:param>
</jsp:include>
<%} else if(fg.equals("MP")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - DEVOLUCION DE MATERIALES DE PROVEEDORES"></jsp:param>
</jsp:include>
<%} else if(fg.equals("EA")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - DEVOLUCION DE MATERIALES ENTRE ALMACENES"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Devoluci&oacute;n ]</a></authtype>
		</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">

	<tr class="TextFilter">
		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		 <td width="100%" >
		<%sbSql= new StringBuffer();
		if(!UserDet.getUserProfile().contains("0"))
		{
			sbSql.append(" and codigo_almacen in (");
				if(session.getAttribute("_almacen_ua")!=null)
					sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua")));
				else sbSql.append("-2");
			sbSql.append(")");
		}
		%>
			Almac&eacute;n
			<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","wh",(!wh.equals("")?wh:(SecMgr.getParValue(UserDet,"almacen_ua")!=null && !SecMgr.getParValue(UserDet,"almacen_ua").equals("")?SecMgr.getParValue(UserDet,"almacen_ua"):"")),false,false,0, "")%>


	Fecha
			<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="fechaini"/>
		<jsp:param name="valueOfTBox1" value=""/>
		<jsp:param name="nameOfTBox2" value="fechafin"/>
		<jsp:param name="valueOfTBox2" value=""/>
		</jsp:include>

			<%//=fb.submit("go","Ir")%>
		</td>

	</tr>
	 <tr class="TextFilter">
		<td width="70%">
			A&ntilde;o
			<%=fb.intBox("anio_devolucion",anioDev,false,false,false,10)%>
			<%//=fb.submit("go","Ir")%>

			No. Devolución
			<%=fb.intBox("num_devolucion",numDev,false,false,false,10)%>

			Devuelto Por
			<%=fb.textBox("devuelve",devPor,false,false,false,30)%>
            &nbsp;&nbsp;
            <cellbytelabel>C&oacute;d. Ref.</cellbytelabel>
            <%=fb.textBox("cod_ref",codRef,false,false,false,10)%>
			<%=fb.submit("go","Ir")%>


		</td>
	<%=fb.formEnd(true)%>

	</tr>
</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("devuelve",devPor)%>
				<%=fb.hidden("cod_ref",codRef)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("devuelve",devPor)%>
                <%=fb.hidden("cod_ref",codRef)%>
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
		<tr class="TextHeader" align="center">
			<td width="3%">&nbsp;</td>
			<td width="8%">A&ntilde;o</td>
			<td width="8%">No. Devoluci&oacute;n</td>
			<td width="7%">C&oacute;d. Ref.</td>
			<td width="30%" align="left">Devuelto por </td>
			<td width="8%">Fecha Doc.</td>
			<td width="10%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		</tr>

				<% if ((appendFilter == null || appendFilter.trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="9">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="9"> <font color="#FF0000"> I N T R O D U Z C A &nbsp;&nbsp;&nbsp;&nbsp;P A R Á M E T R O S&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;B Ú S Q U E D A</font></td>
		</tr>
		<%}%>


<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("anio_devolucion")%></td>
			<td align="center"><%=cdo.getColValue("num_devolucion")%></td>
			<td align="center"><%=cdo.getColValue("cod_ref")%></td>
			<td><%=cdo.getColValue("devuelve")%></td>
			<td align="center"><%=cdo.getColValue("fecha_devolucion")%></td>
			<td align="center">

			<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio_devolucion")%>,<%=cdo.getColValue("num_devolucion")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>


			</td>
			<td align="center">&nbsp;
			<%if(cdo.getColValue("estado").trim().equals("T")){%>
			<authtype type='6'><a href="javascript:aprov(<%=cdo.getColValue("anio_devolucion")%>,<%=cdo.getColValue("num_devolucion")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Aprobar</a></authtype>
			<%}%>
			</td>
			<td align="center">&nbsp;
			<%if(cdo.getColValue("estado").trim().equals("A")){%>
			<authtype type='50'><a href="javascript:confirmar(<%=cdo.getColValue("anio_devolucion")%>,<%=cdo.getColValue("num_devolucion")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Confirmar</a></authtype>
			<%}%>
			</td>
		</tr>
<%
}
%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("devuelve",devPor)%>
                <%=fb.hidden("cod_ref",codRef)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fDate",fechaini)%>
				<%=fb.hidden("tDate",fechafin)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("devuelve",devPor)%>
                <%=fb.hidden("cod_ref",codRef)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<% } %>