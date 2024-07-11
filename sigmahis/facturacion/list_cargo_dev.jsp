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
==========================================================================================
**/
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*
*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

/*
*/

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String fechaDoc = request.getParameter("fecha_docto");
String fechaNac = request.getParameter("fecha_nacimiento");
if(fechaDoc ==null) fechaDoc = "";
if(fechaNac ==null) fechaNac = "";
if(fg==null) fg = "PAC";
if(fg.equals("PAC")){
	fgFilter = "";
} else if(fg.equals("FAR")){
	fgFilter = " and centro_servicio in (125,126,128)";
} else if(fg.equals("AI")){
	fgFilter = "";
} else if(fg.equals("ND")){
	fgFilter = "";
} else if(fg.equals("NE")){
	fgFilter = "";
} else if(fg.equals("HON")){
	fgFilter = " and a.centro_servicio = 0 and a.tipo_transaccion = 'H'";
}
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

	String secuencia    = "";  // variable para mantener el valor de los campos filtrados en la consulta
	String codPaciente  = "";
	String nombre       = "";

	if (request.getParameter("codigo") != null){
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";

    searchOn = "a.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "No. Documento";
		//codigo     = request.getParameter("codigo");

	}
	 if (request.getParameter("admi_secuencia") != null && !request.getParameter("admi_secuencia").equals("")){
		appendFilter += " and upper(a.admi_secuencia) like '%"+request.getParameter("admi_secuencia").toUpperCase()+"%'";

    searchOn = "a.admi_secuencia";
    searchVal = request.getParameter("admi_secuencia");
    searchType = "1";
    searchDisp = "Secuencia";
		secuencia  = request.getParameter("admi_secuencia"); // utilizada para mantener la admisión del paciente filtrada

	}
	 if (request.getParameter("admi_codigo_paciente") != null && !request.getParameter("admi_codigo_paciente").equals("")){
		appendFilter += " and a.pac_id = "+request.getParameter("admi_codigo_paciente");

    searchOn = "a.admi_codigo_paciente";
    searchVal = request.getParameter("admi_codigo_paciente");
    searchType = "1";
    searchDisp = "Paciente";
		codPaciente = request.getParameter("admi_codigo_paciente"); // utilizada para mantener el código del paciente filtrado

	} else if (request.getParameter("fecha_docto") != null && !request.getParameter("fecha_docto").equals("")){
		appendFilter += " and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+request.getParameter("fecha_docto")+"','dd/mm/yyyy')";

    searchOn = "a.fecha";
    searchVal = request.getParameter("fecha_docto");
    searchType = "3";
    searchDisp = "Fecha Documento";
	}
	 if (request.getParameter("fecha_nacimiento") != null && !request.getParameter("fecha_nacimiento").equals("")){
		appendFilter += " and to_date(to_char(b.fecha_nacimiento,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+request.getParameter("fecha_nacimiento")+"','dd/mm/yyyy')";

    searchOn = "b.fecha_nacimiento";
    searchVal = request.getParameter("fecha_nacimiento");
    searchType = "3";
    searchDisp = "Fecha Nacimiento";
	}
	 if (request.getParameter("nombre") != null && !request.getParameter("nombre").equals("")){
		appendFilter += " and upper(b.primer_nombre||b.segundo_nombre||b.primer_apellido||b.segundo_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";

    searchOn = "b.primer_nombre";
    searchVal = request.getParameter("nombre");
    searchType = "2";
    searchDisp = "Paciente";
		nombre     = request.getParameter("nombre");  // utilizada para mantener el nombre del paciente filtrado

	}
	 if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST")){
    if (searchType.equals("1")){
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    } else if (searchType.equals("2")){
			appendFilter += " and upper(b.primer_nombre||b.segundo_nombre||b.primer_apellido||b.segundo_apellido) like '%"+searchVal.toUpperCase()+"%'";
    } else if (searchType.equals("3")){
			appendFilter += " and to_date(to_char("+searchOn+",'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+searchVal+"','dd/mm/yyyy')";
    }
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	//01/06/2010 comenté este query ya que trae los cargos de articulos, lo cual me parece que no debe ya que al consultalo no le trae detalle.
	//sql = "SELECT a.codigo, a.admi_secuencia, a.admi_fecha_nacimiento, a.admi_codigo_paciente, a.descripcion, to_char(a.fecha,'dd/mm/yyyy') fecha, a.tipo_transaccion, a.centro_servicio, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombre, decode(a.tipo_transaccion,'C','Cargo','D','Devolucion','H','Honorario') desc_tipo_transaccion, a.pac_id, c.descripcion centro_servicio_desc, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento FROM tbl_fac_transaccion a, tbl_adm_paciente b, tbl_cds_centro_servicio c where a.pac_id = b.pac_id and a.centro_servicio = c.codigo(+) " + fgFilter + appendFilter + " order by a.fecha desc, a.codigo desc";

	sql = " select distinct a.* from (select  a.codigo, a.admi_secuencia, a.admi_fecha_nacimiento, a.admi_codigo_paciente, a.descripcion, to_char(a.fecha,'dd/mm/yyyy') fecha, a.tipo_transaccion, a.centro_servicio, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombre, decode(a.tipo_transaccion,'C','Cargo','D','Devolucion','H','Honorario') desc_tipo_transaccion, a.pac_id, c.descripcion centro_servicio_desc, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento FROM tbl_fac_transaccion a, tbl_adm_paciente b, tbl_cds_centro_servicio c ,tbl_fac_detalle_transaccion d where a.pac_id = b.pac_id and a.centro_servicio = c.codigo(+) " + fgFilter + appendFilter + " and a.pac_id = d.pac_id and a.admi_secuencia = d.fac_secuencia and a.compania =d.compania and a.codigo = d.fac_codigo and d.art_familia is null and d.art_clase is null and d.inv_articulo is null order by a.fecha desc, a.codigo desc) a order by to_date(a.fecha,'dd/mm/yyyy') desc, a.codigo desc ";

	if (appendFilter != null && !appendFilter.trim().equals("")){
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
document.title = 'Facturacion - '+document.title;

function add()
{
	abrir_ventana('../facturacion/reg_cargo_dev.jsp?mode=add&fg=<%=fg%>');
}

function edit(admi_secuencia, id, tp)
{
	abrir_ventana('../facturacion/reg_cargo_dev.jsp?mode=edit&id='+id+'&admi_secuencia='+admi_secuencia+'&fg=<%=fg%>');
}

function view(pac_id, id, admi_secuencia,tt)
{
	abrir_ventana('../facturacion/reg_cargo_dev.jsp?mode=view&codigo='+id+'&noAdmision='+admi_secuencia+'&fg=<%=fg%>&pacienteId='+pac_id+'&tt='+tt);
}

function printCargos(pac_id, admi_secuencia)
{
	abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id);
}

function printList()
{
  if ('<%=fg%>'=='HON')
  {
	abrir_ventana('../facturacion/print_list_cargo_dev.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	}else if('<%=fg%>'=='PAC')
	  {
		 abrir_ventana('../facturacion/print_list_cargo_dev.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
		  }
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.equals("PAC")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION PACIENTE"></jsp:param>
</jsp:include>
<%} else if(fg.equals("OC")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION OTROS CLIENTES"></jsp:param>
</jsp:include>
<%} else if(fg.equals("FAR")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION FARMACIA"></jsp:param>
</jsp:include>
<%} else if(fg.equals("FH")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION FARHOSPITALARIA"></jsp:param>
</jsp:include>
<%} else if(fg.equals("NE")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<%} else if(fg.equals("HON")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - HONORARIOS"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
	 <authtype type='3'>
<%
if(!fg.equals("HON")){
%>
			<a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Cargo/Devoluci&oacute;n</cellbytelabel> ]</a>
<%
} else {
%>
			<a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Honorario</cellbytelabel> ]</a>
<%
}
%></authtype>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">

<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<td width="10%">
					<cellbytelabel>No. Admisi&oacute;n</cellbytelabel>
					<%=fb.intBox("admi_secuencia",secuencia,false,false,false,7)%>
				</td>
				<td width="10%">
					<cellbytelabel>No. Paciente</cellbytelabel>
					<%=fb.intBox("admi_codigo_paciente",codPaciente,false,false,false,7)%>
				</td>
				<td width="35%">
					<cellbytelabel>Nombre Paciente</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,55)%>
				</td>
				<td width="20%">
				<cellbytelabel>Fecha Doc</cellbytelabel>.
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha_docto" />
					<jsp:param name="valueOfTBox1" value="<%=fechaDoc%>" />
					</jsp:include>
				</td>
				<td width="20%">
					<cellbytelabel>Fecha Nac</cellbytelabel>.
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha_nacimiento" />
					<jsp:param name="valueOfTBox1" value="<%=fechaNac%>" />
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
    <td align="right"> <authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("admi_secuencia",secuencia)%>
				<%=fb.hidden("admi_codigo_paciente",codPaciente)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_docto",fechaDoc)%>
				<%=fb.hidden("fecha_nacimiento",fechaNac)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("admi_secuencia",secuencia)%>
				<%=fb.hidden("admi_codigo_paciente",codPaciente)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_docto",fechaDoc)%>
				<%=fb.hidden("fecha_nacimiento",fechaNac)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="27%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
			<td width="8%"><cellbytelabel>Fecha Doc</cellbytelabel>.</td>
			<td width="10%"><cellbytelabel>Tipo Transacci&oacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>No. Paciente</cellbytelabel></td>
			<td width="8%"><cellbytelabel>No. Admisi&oacute;n</cellbytelabel></td>
			<td width="28%"><cellbytelabel>Centro Servicio</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
			<!--<td width="5%">&nbsp;</td>-->
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left">&nbsp;<%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("desc_tipo_transaccion")%></td>
			<td align="center"><%=cdo.getColValue("admi_codigo_paciente")%></td>
			<td align="center"><%=cdo.getColValue("admi_secuencia")%></td>
			<td align="left">&nbsp;<%=cdo.getColValue("centro_servicio")%>&nbsp;-&nbsp;<%=cdo.getColValue("centro_servicio_desc")%></td>
			<td align="center">
			<a href="javascript:view(<%=cdo.getColValue("pac_id")%>,<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("admi_secuencia")%>,'<%=cdo.getColValue("tipo_transaccion")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>Ver</cellbytelabel></a>
			</td>
			<!--<td><a href="javascript:printCargos(<%//=cdo.getColValue("pac_id")%>,<%//=cdo.getColValue("admi_secuencia")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Imprimir</a></td>-->
		</tr>
<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("admi_secuencia",secuencia)%>
				<%=fb.hidden("admi_codigo_paciente",codPaciente)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_docto",fechaDoc)%>
				<%=fb.hidden("fecha_nacimiento",fechaNac)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("admi_secuencia",secuencia)%>
				<%=fb.hidden("admi_codigo_paciente",codPaciente)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fecha_docto",fechaDoc)%>
				<%=fb.hidden("fecha_nacimiento",fechaNac)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
