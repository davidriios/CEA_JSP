
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
tr2 flag para filtrar las requisiciones de hemodialisis
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
String tr2 = request.getParameter("tr2");
if(tr==null) tr = "";

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
String centro = "";
String area="",almacen="",nombre_paciente="",noSolicitud="",fecha_nac="",paciente="",fecha_docto="",anio="",noAdmision="",fecha_fin="",descArea="";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String estado = request.getParameter("estado");
String req_filter = "";
StringBuffer sbSql = new StringBuffer();
 
 sbSql = new StringBuffer();
	if(!UserDet.getUserProfile().contains("0"))
	{
		sbSql.append(" and a.centro_servicio in (");
			if(session.getAttribute("_cds")!=null)
				sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
			else sbSql.append("-1");
		sbSql.append(")");
	}
  	if(!UserDet.getUserProfile().contains("0"))
	{
		sbSql.append(" and a.codigo_almacen in (");
			if(session.getAttribute("_almacen_cds")!=null)
				sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
			else sbSql.append("-2");
		sbSql.append(")");
	}
		req_filter  +=sbSql.toString();
		 
if (estado == null) estado = "";
else if (!estado.trim().equals("")) appendFilter += " and upper(a.estado)='"+estado.toUpperCase()+"'";

/*
===================================================================================
tr	= 	
===================================================================================
===================================================================================
*/
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

	
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
    	anio = request.getParameter("anio");
	}
	if (request.getParameter("noSolicitud") != null && !request.getParameter("noSolicitud").trim().equals(""))
	{
		appendFilter += " and a.solicitud_no = "+request.getParameter("noSolicitud");
    	noSolicitud = request.getParameter("noSolicitud");
	}
	if (request.getParameter("fecha_docto") != null && !request.getParameter("fecha_docto").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_docto) >= to_date('"+request.getParameter("fecha_docto")+"','dd/mm/yyyy')";
    	fecha_docto = request.getParameter("fecha_docto");
	}
	if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_docto) <= to_date('"+request.getParameter("fecha_fin")+"','dd/mm/yyyy')";
    	fecha_fin = request.getParameter("fecha_fin");
	}
	/*else 
	{
		appendFilter += " and to_date(to_char(a.fecha_docto,'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+cDate+"','dd/mm/yyyy')";
    	fecha_docto = cDate;
	}*/
	if (request.getParameter("paciente") != null && !request.getParameter("paciente").trim().equals(""))
	{
		appendFilter += " and a.pac_id = "+request.getParameter("paciente");
    	paciente = request.getParameter("paciente");
	}
	if (request.getParameter("fecha_nac") != null && !request.getParameter("fecha_nac").trim().equals(""))
	{
		appendFilter += " and to_date(to_char(a.fecha_nac,'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+request.getParameter("fecha_nac")+"','dd/mm/yyyy')";
    	fecha_nac = request.getParameter("fecha_nac");
	}
	if (request.getParameter("noAdmision") != null && !request.getParameter("noAdmision").trim().equals(""))
	{
		appendFilter += " and a.adm_secuencia = "+request.getParameter("noAdmision");
    	noAdmision = request.getParameter("noAdmision");
	}
	if (request.getParameter("nombre_paciente") != null && !request.getParameter("nombre_paciente").trim().equals(""))
	{
		appendFilter += " and upper(a.nombre_paciente) like '%"+request.getParameter("nombre_paciente").toUpperCase()+"%'";
    	nombre_paciente = request.getParameter("nombre_paciente");
	}
	if (request.getParameter("almacen") != null && !request.getParameter("almacen").trim().equals(""))
	{
		appendFilter += " and a.codigo_almacen = "+request.getParameter("almacen");
    	almacen = request.getParameter("almacen");
	}
	if (request.getParameter("area") != null && !request.getParameter("area").trim().equals(""))
	{
		appendFilter += " and a.centro_servicio = "+request.getParameter("area");
    	area = request.getParameter("area");
	}
	if (request.getParameter("descArea") != null && !request.getParameter("descArea").trim().equals(""))
	{
		appendFilter += " and upper(a.area_desc) like '%"+request.getParameter("descArea").toUpperCase()+"%'";
    	descArea = request.getParameter("descArea");
	}
	 
	if (request.getParameter("noAdmision")!=null)
	{
sql = "select a.*, to_char(a.fecha_docto, 'dd/mm/yyyy') fecha_documento, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento from (select  a.codigo_almacen ,a.centro_servicio, a.compania, a.anio, a.solicitud_no, a.fecha_documento fecha_docto, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO','D','DEVUELTO') desc_estado, a.paciente, a.fecha_nacimiento fecha_nac, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia,a.pac_id, a.centro_servicio ||' '|| d.descripcion area_desc, d.descripcion, a.fecha_creacion,  decode(a.estado, 'T', decode((case when ad.estado in ('A', 'E', 'S') then 'S' else 'N'  end), 'S', (case when to_date (to_char (a.fecha_documento, 'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date(to_char(ad.fecha_ingreso, 'dd/mm/yyyy'),'dd/mm/yyyy') then 'S' else 'N' end), 'N'), 'N') entregar ,(select case when sum(spd.cantidad) > sum(de.cantidad_entregada) then '*' end from tbl_inv_detalle_entrega de, tbl_inv_entrega_material em, tbl_inv_d_sol_pac spd where de.anio = em.anio and de.no_entrega = em.no_entrega and de.compania = em.compania and em.pac_anio = a.anio and em.pac_solicitud_no = a.solicitud_no and em.compania = a.compania and a.anio = spd.anio and a.solicitud_no = spd.solicitud_no and a.compania = spd.compania) as parcial from tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d, tbl_adm_admision ad where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo "+req_filter+" and a.pac_id = ad.pac_id and a.adm_secuencia = ad.secuencia order by a.fecha_documento desc) a where compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha_docto desc, a.solicitud_no desc ";

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - '+document.title;
function add(){abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?tr=<%=tr%>&tr2=<%=tr2%>');}
function edit(anio, id,k){<%if(tr != null && tr.trim().equals("MPS")){%>var pac_id     = eval('document.form1.pac_id'+k).value;var admision = eval('document.form1.admision'+k).value;abrir_ventana('../inventario/view_sol_mat_pacientes.jsp?mode=view&id='+id+'&anio='+anio+'&tr=<%=tr%>&pac_id='+pac_id+'&noAdmision='+admision+'&tr2=<%=tr2%>');<%}else{%>abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?mode=view&id='+id+'&anio='+anio+'&tr=<%=tr%>&tr2=<%=tr2%>');<%}%>}
function printList(){abrir_ventana('../inventario/print_list_sol_mat_pac.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function getCentro(){abrir_ventana('../common/search_centro_servicio.jsp?fp=RP&fg=<%=tr%>&fp=<%=tr2%>');}
function entregar(anio, sol_no, cia){abrir_ventana('../inventario/reg_delivery.jsp?anio='+anio+'&solicitud_no='+sol_no+'&compania='+cia+'&fp=requisitions&fg=MP&tr=<%=tr%>&tr2=<%=tr2%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOL. MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right">
		<%if(tr != null && !tr.trim().equals("MPS")){%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Requisici&oacute;n ]</a></authtype>
		<%}%>
		</td>
  </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp","","");%>
          <%=fb.formStart()%> 
		  <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
		  <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		  <%=fb.hidden("tr",tr)%>
		  <%=fb.hidden("tr2",tr2)%>
			  	<td width="50%"> 
				<%sbSql = new StringBuffer(); 
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and codigo_almacen in (");
						if(session.getAttribute("_almacen_cds")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_cds")));
						else sbSql.append("-2");
					sbSql.append(")");
				}
				%>
						Almacen
            <%=fb.select(ConMgr.getConnection(),"select codigo_almacen, descripcion from tbl_inv_almacen where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","almacen",(almacen!=null && !almacen.equals("")?almacen:(SecMgr.getParValue(UserDet,"almacen_cds")!=null && !SecMgr.getParValue(UserDet,"almacen_cds").equals("")?SecMgr.getParValue(UserDet,"almacen_cds"):"")),false,false,0, "T")%>
        	</td>
					<td width="50%"> 
				<%sbSql = new StringBuffer(); 
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and codigo in (");
						if(session.getAttribute("_cds")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
						else sbSql.append("-1");
					sbSql.append(")");
				}
				%>
						Centro Servicio
						<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where compania_unorg = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by descripcion","area",(area!=null && !area.equals("")?area:(SecMgr.getParValue(UserDet,"cds")!=null && !SecMgr.getParValue(UserDet,"cds").equals("")?SecMgr.getParValue(UserDet,"cds"):"")),false,false,0, "T")%>
						<%//=fb.intBox("area",area,false,false,false,5)%><%//=fb.textBox("descArea","",false,false,false,25)%>
						<%//=fb.button("searchCentro","...",false,false,null,null,"onClick=\"javascript:getCentro()\"")%>
					</td>	
        </tr>
        <tr class="TextFilter">
					<td>
          Solicitud No 
					<%=fb.intBox("anio",anio,false,false,false,5)%><%=fb.intBox("noSolicitud","",false,false,false,10)%>
					Estado
					<%=fb.select("estado","A= APROBADO,T=TRAMITE,E=ENTREGADO,P=PENDIENTE,D=DEVUELTO,N=ANULADO,R=RECHAZADA",estado,false,false,0,"T")%>
          </td>	
          <td>		
					Fecha 	<jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="nameOfTBox1" value="fecha_docto" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_docto%>" />
          <jsp:param name="fieldClass1" value="Text10" />
          <jsp:param name="buttonClass1" value="Text10" />
          <jsp:param name="nameOfTBox2" value="fecha_fin" />
          <jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
          <jsp:param name="fieldClass2" value="Text10" />
          <jsp:param name="buttonClass2" value="Text10" />
          <jsp:param name="clearOption" value="true" />
          </jsp:include>
					</td>
				</tr>
        <tr class="TextFilter">
	        <td>Nombre Paciente	<%=fb.textBox("nombre_paciente","",false,false,false,30)%>
          Fecha Nac.
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="nameOfTBox1" value="fecha_nac" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_nac%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          <jsp:param name="clearOption" value="true" />
          </jsp:include>	
          </td>
          <td> 
					Codigo Pac.
					<%=fb.intBox("paciente","",false,false,false,10)%>
					No Admisión
					<%=fb.intBox("noAdmision","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%> 
	  			</td>
          <%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>&nbsp;</td>
  </tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("tr2",tr2)%>
				
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noSolicitud",noSolicitud)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("area",area)%>
				<%=fb.hidden("descArea",descArea)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_paciente",nombre_paciente)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("paciente",paciente)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fecha_docto",fecha_docto)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				
				
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("tr2",tr2)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noSolicitud",noSolicitud)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("area",area)%>
				<%=fb.hidden("descArea",descArea)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_paciente",nombre_paciente)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("paciente",paciente)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fecha_docto",fecha_docto)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
		<tr class="TextHeader" align="center">
			<td width="3%" rowspan="2">A&ntilde;o</td>
			<td width="6%" rowspan="2">No. Solicitud</td>
			<td width="6%" rowspan="2">Fecha Doc.</td>
			<td width="45%" colspan="4">Paciente</td>
			<td width="17%" rowspan="2">Almac&eacute;n</td>
			<td width="15%" rowspan="2">Area</td>
			<td width="3%" rowspan="2">&nbsp;</td>
			<td width="5%" rowspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%">Cod.</td>
			<td width="7%">Fecha Nac.</td>
			<td width="27%">Nombre</td>
			<td width="6%">No. Admi.</td>
		</tr>
	<%if(al.size()==0){%>
              <tr>
                <td colspan="11" class="TextRow01" align="center"> NO HAY SOLICITUDES DE MATERIALES Y MEDICAMENTOS PARA PACIENTES </td>
              </tr>
              <%}%>	
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("adm_secuencia"))%>
		<%if(tr != null && tr.trim().equals("MPS")){%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,<%=i%>)" style="cursor:pointer">
		
		<%}else{%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<%}%>
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td align="center"><%=cdo.getColValue("solicitud_no")%></td>
			<td align="center"><%=cdo.getColValue("fecha_documento")%></td>
			<td align="center"><%=cdo.getColValue("paciente")%></td>
			<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td align="left"><%=cdo.getColValue("nombre_paciente")%></td>
			<td align="center"><%=cdo.getColValue("adm_secuencia")%></td>
			<td align="left"><%=cdo.getColValue("almacen_desc")%></td>
			<td align="left"><%=cdo.getColValue("area_desc")%></td>
			
			<td align="center">
			<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,<%=i%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>
			</td>
      <td>
      <%if(cdo.getColValue("entregar")!=null && cdo.getColValue("entregar").equals("S")){%>
			<authtype type='50'><a href="javascript:entregar(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("solicitud_no")%>,<%=cdo.getColValue("compania")%>)"class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Entregar</a></authtype>
			<%}%>
           <span class="RedTextBold"><%=cdo.getColValue("parcial")%></span>
      </td>
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
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("tr2",tr2)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noSolicitud",noSolicitud)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("area",area)%>
				<%=fb.hidden("descArea",descArea)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_paciente",nombre_paciente)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("paciente",paciente)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fecha_docto",fecha_docto)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:return(replacePercent(this.searchVal))\"");%>
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
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("tr2",tr2)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noSolicitud",noSolicitud)%>
				<%=fb.hidden("almacen",almacen)%>
				<%=fb.hidden("area",area)%>
				<%=fb.hidden("descArea",descArea)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_paciente",nombre_paciente)%>
				<%=fb.hidden("fecha_nac",fecha_nac)%>
				<%=fb.hidden("paciente",paciente)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fecha_docto",fecha_docto)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
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
