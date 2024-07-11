<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String fp = "";
StringBuffer sbSql = new StringBuffer();
if(request.getParameter("fp")!= null) fp = request.getParameter("fp");
if(fg==null) fg = "DM";
String descTitle ="";

if(fg.equals("CDM"))descTitle ="INVENTARIO - CONSULTA DE DEVOLUCION DE MATERIALES - PACIENTES";
else if(fg.equals("DM"))descTitle ="INVENTARIO - DEVOLUCION DE MATERIALES  PACIENTES";
else if(fg.equals("DMA"))descTitle ="INVENTARIO - CONFIRMACIÒN DE DEVOLUCION DE MATERIALES  PACIENTES";
else descTitle ="INVENTARIO - DEVOLUCION DE MATERIALES  PACIENTES";

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
	String estado  = "";
	String nombre  = "",codigo="",admision="";
	String fecha_nac  = "";
	String wh  = "", cds = "";
	String fecha_ini  = "";
	String fecha_fin  = "";
	if(request.getParameter("cds") != null && !request.getParameter("cds").equals("")) cds = request.getParameter("cds");
	if (request.getParameter("num_devolucion") != null && !request.getParameter("num_devolucion").trim().equals("") ){
		appendFilter += " and upper(dp.num_devolucion) like '%"+request.getParameter("num_devolucion").toUpperCase()+"%'";
		numDev     = request.getParameter("num_devolucion");   // utilizada para mantener el número de la devolción filtrada	
	} 
	if (request.getParameter("almacen") != null && !request.getParameter("almacen").trim().equals("") ){
		appendFilter += " and dp.codigo_almacen = "+request.getParameter("almacen");
		wh = request.getParameter("almacen");
	}
	if (request.getParameter("cds") != null && !request.getParameter("cds").trim().equals("") ){
		appendFilter += " and dp.sala_cod = "+request.getParameter("cds");
		cds = request.getParameter("cds");
	}
	if (request.getParameter("fecha_nac") != null && !request.getParameter("fecha_nac").trim().equals("") ){
		appendFilter += " and to_date(to_char(p.f_nac,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+request.getParameter("fecha_nac")+"','dd/mm/yyyy')";
		fecha_nac = request.getParameter("fecha_nac");
	}
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("") ){
		appendFilter += " and  p.pac_id = "+request.getParameter("codigo");
		codigo = request.getParameter("codigo");
	}
	if (request.getParameter("anio_devolucion") != null && !request.getParameter("anio_devolucion").trim().equals("") ){
		appendFilter += " and upper(anio) = "+request.getParameter("anio_devolucion");
		anioDev    = request.getParameter("anio_devolucion");   // utilizada para mantener el año de la devolución
	} 
	if (request.getParameter("nombre") != null  && !request.getParameter("nombre").trim().equals("") ){
		appendFilter += " and upper(p.nombre_paciente) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}
	if (request.getParameter("admision") != null && !request.getParameter("admision").trim().equals("")){
    appendFilter += " and dp.adm_secuencia  = "+request.getParameter("admision");
    admision =request.getParameter("admision");
 	}
 	if (request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").trim().equals(""))
    {
    appendFilter += " and trunc(dp.fecha) >= to_date('"+request.getParameter("fecha_ini")+"','dd/mm/yyyy')";
    fecha_ini =request.getParameter("fecha_ini");
    }
    if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals(""))
    {
    appendFilter += " and trunc(dp.fecha) <= to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy')";
    fecha_fin =request.getParameter("fecha_fin");
    }
    if (request.getParameter("estado") != null  && !request.getParameter("estado").trim().equals("") ){
		appendFilter += " and upper(dp.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
		estado     = request.getParameter("estado");    // utilizada para mantener el estado filtrado
	}		
//Devolucion de materiales paciente	
if(fp.trim().equals("CU"))
{
appendFilter +=" and adm.estado in ('A','E') and adm.categoria in (1,2)";
}
else if(fp.trim().equals("DIET"))
{
appendFilter +=" and adm.estado in ('A','E','S')";
}
else if(fp.trim().equals("HEM"))
{
appendFilter +=" and adm.estado in ('A','E','S','C')";
}
/*else
{
appendFilter +=" and adm.estado in ('A','E','S','C')";
}*/

if(fg.trim().equals("DMA"))
{
appendFilter +=" and adm.estado in ('A','E','S') and dp.estado = 'T' ";
}


if(fg.equals("DM")||fg.equals("DMA") ||fg.equals("CDM") )
{

sql="SELECT dp.anio anio_devolucion, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, dp.monto, dp.estado, decode(dp.estado,'T','TRAMITE','P','PENDIENTE','R','PROCESADO','A','ANULADO') desc_estado,dp.pac_id, dp.adm_secuencia, p.nombre_paciente as nombre FROM tbl_inv_devolucion_pac dp, vw_adm_paciente p ,tbl_adm_admision adm  ,tbl_cds_centro_servicio cs  where dp.compania = "+ (String) session.getAttribute("_companyId") +fgFilter+ appendFilter+" and dp.compania = adm.compania  and dp.pac_id = p.pac_id  and (dp.pac_id = adm.pac_id and dp.adm_secuencia = adm.secuencia) and (adm.pac_id= p.pac_id) and cs.codigo(+) = dp.sala_cod order by  dp.anio desc,dp.num_devolucion desc";

}
if(!appendFilter.trim().equals("") && !cds.equals("") && !wh.equals(""))
{
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
function add(){	<%if(fg.equals("DM")){%>abrir_ventana('../inventario/dev_mat_pacientes.jsp?mode=add&fp=<%=fp%>&fg=<%=fg%>');<%}%>}
function edit(anio, id,admision,pac_id){<%if(fg.trim().equals("DM") || fg.trim().equals("DMA")){%>abrir_ventana('../inventario/dev_mat_pacientes.jsp?mode=edit&id='+id+'&anio='+anio+'&pacId='+pac_id+'&noAdmision='+admision+'&fg=DMA&fp=<%=fp%>');<%}%>}
function ver(anio, id,admision,pac_id){<%if(fg.trim().equals("DM")||fg.trim().equals("DMA") || fg.equals("CDM")){%>abrir_ventana('../inventario/dev_mat_pacientes.jsp?mode=view&id='+id+'&anio='+anio+'&pacId='+pac_id+'&noAdmision='+admision+'&fg=<%=fg%>&fp=<%=fp%>');<%}%>}
function printList(){abrir_ventana('../inventario/print_list_devolucion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>&fp=<%=fp%>');}
function setFp(){var cds = document.search02.cds.value;if(cds!=''){var x = getFlagCds('<%=request.getContextPath()%>',cds);if(x!='-1') document.search02.fp.value= x;else document.search02.fp.value = '';}}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();/*setFp();*/}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="<%=descTitle%>"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right">&nbsp;
<% if(fg.equals("DM")){%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Devoluci&oacute;n ]</a></authtype>
<%}%>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			
<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
        <tr class="TextFilter">
					<td colspan="2" width="50%"> 
					<%sbSql = new StringBuffer();
					if(!UserDet.getUserProfile().contains("0"))
					{
						sbSql.append(" and codigo in (");
							if(session.getAttribute("_cds")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
							else sbSql.append("-1");
						sbSql.append(")");
					}%>
						Centro Servicio
						<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A' /*origen = 'S'*/ and compania_unorg = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","cds",(!cds.equals("")?cds:(SecMgr.getParValue(UserDet,"cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):"")),false,false,0, "", "", "")%>
            
					</td>	
			  	<td colspan = "2" width="50%"> 
				<%sbSql = new StringBuffer();
					if(!UserDet.getUserProfile().contains("0"))
					{
						sbSql.append(" and codigo_almacen in (");
							if(session.getAttribute("_almacen_cds")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
							else sbSql.append("-2");
						sbSql.append(")");
					}%>
						Almacen
            <%=fb.select(ConMgr.getConnection(),"select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","almacen",(!wh.equals("")?wh:(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_cds"):"")),false,false,0, "")%>
        	</td>
        </tr>
				<tr class="TextFilter">
				<td>
					Fecha Nacimiento&nbsp; 
				</td>
				<td colspan="3">
					<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="clearOption" value="true"/>
							<jsp:param name="nameOfTBox1" value="fecha_nac"/>
							<jsp:param name="valueOfTBox1" value="<%=fecha_nac%>"/>
							</jsp:include>
							Código Pac.&nbsp;<%=fb.intBox("codigo",codigo,false,false,false,10)%>
							Admisión&nbsp;<%=fb.intBox("admision",admision,false,false,false,10)%>
					Nombre Paciente
					<%=fb.textBox("nombre",nombre,false,false,false,40)%>
					
				</td>
			</tr>
			<tr class="TextFilter">
				<td width="10%">
					A&ntilde;o
				</td>
				<td colspan="3">
					<%=fb.intBox("anio_devolucion",anioDev,false,false,false,10)%>
				
					Solicitud No.
					<%=fb.intBox("num_devolucion",numDev,false,false,false,10)%>
					<% if(!fg.trim().equals("DMA")){%>
					Estado
					<%=fb.select("estado","A =ANULADO ,T=TRAMITE ,  R= PROCESADO O DEVUELTO",estado,"S")%>
					
					<%}%>
					<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2"/>
							<jsp:param name="clearOption" value="true"/>
							<jsp:param name="nameOfTBox1" value="fecha_ini"/>
							<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>"/>
							<jsp:param name="nameOfTBox2" value="fecha_fin"/>
							<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>"/>
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
    <td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
			&nbsp;
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
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("almacen",wh)%>
				<%=fb.hidden("codigo",codigo)%>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("almacen",wh)%>
				<%=fb.hidden("codigo",codigo)%>
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
			<td width="10%">A&ntilde;o</td>
			<td width="15%">No. Devolución</td>
			<td width="35%" align="left">Nombre</td>
			<td width="10%">Estado</td>
			<td width="10%">Fecha Doc.</td>
			<td width="10%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio_devolucion")%></td>
			<td align="center"><%=cdo.getColValue("num_devolucion")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("desc_estado")%></td>
			<td align="center"><%=cdo.getColValue("fecha_devolucion")%></td>
			<td align="center">
<%
if(fg.trim().equals("DM") || fg.trim().equals("DMA") || fg.trim().equals("CDM"))
{
%>
			<authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("anio_devolucion")%>,<%=cdo.getColValue("num_devolucion")%>,<%=cdo.getColValue("adm_secuencia")%>,<%=cdo.getColValue("pac_id")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>
<%
}
%>
			</td>
			<td align="center">
<%

if(fg.trim().equals("DMA") || fp.trim().equals("CU"))
{
if(cdo.getColValue("estado").trim().equals("T"))
{
%>
			<authtype type='9'><a href="javascript:edit(<%=cdo.getColValue("anio_devolucion")%>,<%=cdo.getColValue("num_devolucion")%>,<%=cdo.getColValue("adm_secuencia")%>,<%=cdo.getColValue("pac_id")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Confirmar</a></authtype>
<%
}
%>
			
			<%}else{%>
			&nbsp;
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("almacen",wh)%>
				<%=fb.hidden("codigo",codigo)%>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("num_devolucion",numDev)%>
				<%=fb.hidden("anio_devolucion",anioDev)%>
				<%=fb.hidden("almacen",wh)%>
				<%=fb.hidden("codigo",codigo)%>
				
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