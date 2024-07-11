<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String compania = request.getParameter("compania");
String codigo = "", cliente = "";
if(fp==null) fp = "";
if(fg==null) fg = "";

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

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo = request.getParameter("codigo");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
		appendFilter += " and upper(cliente) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		cliente = request.getParameter("nombre");

	}

	if(fp.equals("cargo_dev_oc")){
		if (fg.equals("1")){
			sql = "select e.* from (select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido cliente, provincia, sigla, tomo, asiento, provincia||'-'||sigla||'-'||tomo||'-'||asiento codigo, num_empleado from tbl_pla_empleado) e  where num_empleado is not null "+appendFilter;
		} else if(fg.equals("2")){
			sql = "select e.* from (select nombre cliente, codigo codigo, digito_verificador, cob_tasa_gasnet from tbl_adm_empresa) e where e.codigo is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("3")){
			sql = "select e.* from (select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido cliente, codigo codigo, primer_apellido, identificacion from tbl_adm_medico) e where codigo is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("4")){
			sql = "select e.* from (select codigo codigo, descripcion cliente, tipo_cds from tbl_cds_centro_servicio where compania_unorg = "+(String) session.getAttribute("_companyId")+" and tipo_cds = 'T') e where codigo is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("5")){
			sql = "select e.* from (select codigo codigo, descripcion cliente from tbl_cds_centro_servicio where estado = 'A' and tipo_cds in ('I', 'E')) e where codigo is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("6")){
			sql = "select e.* from (select nombre cliente, codigo codigo from tbl_sec_compania where codigo <> "+compania+") e where codigo is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("7")){
			sql = "select e.* from (select decode (t.descripcion, 'MEDICO', c.primer_apellido||' '||c.primer_nombre, 'EMPRESA', d.nombre, 'CENTROS TERCEROS', cds.descripcion, 'CENTRO DE SERVICIO', cds.descripcion, 'PARTICULAR', par.descripcion, 'EMPLEADO', emp.primer_nombre||' '||emp.primer_apellido||' '||emp.segundo_apellido) cliente, decode (t.descripcion, 'MEDICO', a.medico, 'EMPRESA', a.empresa, 'CENTROS TERCEROS', a.centro_servicio, 'CENTRO DE SERVICIO', a.centro_servicio, 'PARTICULAR', par.codigo, 'EMPLEADO', a.provincia_emp||'-'||a.sigla_emp||'-'||a.tomo_emp||'-'||a.asiento_emp) codigo, a.contrato, t.codigo tipo_cliente, t.descripcion tipo_cliente_desc, a.empresa, a.empleado, a.medico, a.particular, emp.provincia, emp.sigla, emp.tomo, emp.asiento, emp.provincia||'-'||emp.sigla||'-'||emp.tomo||'-'||emp.asiento emp_cedula, a.compania, co.nombre desc_cia, d.digito_verificador, c.primer_nombre, c.segundo_nombre, c.primer_apellido, c.segundo_apellido, c.identificacion, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_medico, a.consultorio from tbl_cxc_contrato_alq a, tbl_adm_empresa d, tbl_adm_medico c, tbl_fac_tipo_cliente t, tbl_sec_compania co, tbl_cds_centro_servicio cds, tbl_cxc_cliente_particular par, tbl_pla_empleado emp where (d.codigo(+) = a.empresa and c.codigo(+) = a.medico and cds.codigo(+) = a.centro_servicio and par.codigo(+) = a.particular and emp.emp_id(+) = a.emp_id and co.codigo = a.compania and t.codigo = a.tipo_cliente and t.compania = a.compania and a.estado = 'A') and a.tipo_contrato = 1 and a.estado = 'A' /*and a.compania = "+(String) session.getAttribute("_companyId")+"*/ ) e where cliente is not null "+appendFilter+" order by e.cliente";
		} else if(fg.equals("8")){
			sql = "select e.* from (select distinct cliente from tbl_fac_cargo_cliente where tipo_cliente = 4) e where e.cliente is not null "+appendFilter+" order by cliente";
		} else if(fg.equals("9")){
			sql = "select e.* from (select pac_id, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula as cedula_pasaporte, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as cliente, aprobacion_hna, limite, diag_hna, to_char(fecha_vencim, 'dd/mm/yyyy') fecha_vencim from tbl_adm_paciente) e where e.cliente is not null "+appendFilter+" order by pac_id desc";
		} else if(fg.equals("10")){
			
			sql = "select e.* from (select 0 pac_id, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, codigo, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(apellido_de_casada,null,'',' '||apellido_de_casada) as cliente, admision, provincia||'-'||sigla||'-'||tomo||'-'||asiento||'-'||d_cedula as cedula_pasaporte, nvl(to_char(fecha_vencim, 'dd/mm/yyyy'), ' ') fecha_vencim, limite, aprobacion_hna, nvl(to_char(fecha_ingreso, 'dd/mm/yyyy'), ' ') fecha_ingreso from pamd_pac_int) e where e.cliente is not null "+appendFilter+" order by pac_id desc";
		}
	}

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a ) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");


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
document.title = 'Common - '+document.title;

function setValue(i){
	<%
	if(fp.equals("cargo_dev_oc")){
		if(fg.equals("1")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.provincia_emp.value = eval('document.detail.provincia'+i).value;
			window.opener.document.form0.sigla_emp.value = eval('document.detail.sigla'+i).value;
			window.opener.document.form0.tomo_emp.value = eval('document.detail.tomo'+i).value;
			window.opener.document.form0.asiento_emp.value = eval('document.detail.asiento'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.cod_medico.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.cod_medico.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("2")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.cod_empresa.value = eval('document.detail.cod_empresa'+i).value;
			window.opener.document.form0.cob_tasa_gasnet.value = eval('document.detail.cob_tasa_gasnet'+i).value;
			if(eval('document.detail.cob_tasa_gasnet'+i).value=='S' /*&& (eval('document.detail.cod_empresa'+i).value == '' || eval('document.detail.cod_empresa'+i).value == '')*/){
				window.opener.document.getElementById('pac_data').style.display='';
			} else {
				window.opener.document.getElementById('pac_data').style.display='none';
				window.opener.document.form0.fecha_nac.value = '';
				window.opener.document.form0.codigo_pac.value = '';
				window.opener.document.form0.admision.value = '';
			}

			window.opener.document.form0.cod_medico.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
		<%} else if(fg.equals("3")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.cod_medico.value = eval('document.detail.cod_medico'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("4") || fg.equals("5")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.centro_servicio_desc'+i).value;
			window.opener.document.form0.centro_servicio.value = eval('document.detail.centro_servicio'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.cod_medico.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.centro_servicio_desc'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("6")){%>
			window.opener.document.form0.icompania.value = eval('document.detail.compania'+i).value;
			window.opener.document.form0.cliente.value = eval('document.detail.compania_desc'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.cod_medico.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.cliente2.value = '';
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("7")){%>
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = eval('document.detail.contrato'+i).value;
			window.opener.document.form0.tipo_cli_alq.value = eval('document.detail.tipo_cliente'+i).value;
			window.opener.document.form0.cod_empresa.value = eval('document.detail.empresa'+i).value;
			window.opener.document.form0.cod_medico.value = eval('document.detail.medico'+i).value;
			window.opener.document.form0.particular.value = eval('document.detail.particular'+i).value;
			window.opener.document.form0.provincia_emp.value = eval('document.detail.provincia'+i).value;
			window.opener.document.form0.sigla_emp.value = eval('document.detail.sigla'+i).value;
			window.opener.document.form0.tomo_emp.value = eval('document.detail.tomo'+i).value;
			window.opener.document.form0.asiento_emp.value = eval('document.detail.asiento'+i).value;
			window.opener.document.form0.cia_contrato.value = eval('document.detail.compania'+i).value;

			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("8")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("9")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.form0.nombre_paciente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.fecha_nacimiento.value = eval('document.detail.fecha_nacimiento'+i).value;
			window.opener.document.form0.codigo_paciente.value = eval('document.detail.codigo'+i).value;
			window.opener.document.form0.aprobacion_hna.value = eval('document.detail.aprobacion_hna'+i).value;
			window.opener.document.form0.fecha_vencim.value = eval('document.detail.fecha_vencim'+i).value;
			window.opener.document.form0.limite.value = eval('document.detail.limite'+i).value;

			if(eval('document.detail.aprobacion_hna'+i).value==''){
				alert('Debe actualizar la APROBACION DE AXA para este Paciente...');
				window.opener.document.form0.visita.value = 1;
			} else if(eval('document.detail.fecha_vencim'+i).value==''){
				alert('Debe actualizar la FECHA DE VENCIMIENTO DE LA APROBACION DE AXA para este Paciente...');
			}

			window.opener.document.getElementById('pac_data').style.display='none';
		<%} else if(fg.equals("10")){%>
			window.opener.document.form0.cliente.value = eval('document.detail.cliente'+i).value;

			window.opener.document.form0.cod_empresa.value = '';
			window.opener.document.form0.centro_servicio.value = '';
			window.opener.document.form0.icompania.value = '';
			window.opener.document.form0.cliente2.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.contrato.value = '';
			window.opener.document.form0.tipo_cli_alq.value = '';
			window.opener.document.form0.particular.value = '';
			window.opener.document.form0.provincia_emp.value = '';
			window.opener.document.form0.sigla_emp.value = '';
			window.opener.document.form0.tomo_emp.value = '';
			window.opener.document.form0.asiento_emp.value = '';
			window.opener.document.form0.cia_contrato.value = '';
			window.opener.document.form0.cob_tasa_gasnet.value = '';

			window.opener.document.form0.nombre_paciente.value = eval('document.detail.cliente'+i).value;
			window.opener.document.form0.fecha_nacimiento.value = eval('document.detail.fecha_nacimiento'+i).value;
			window.opener.document.form0.codigo_paciente.value = eval('document.detail.codigo'+i).value;
			window.opener.document.form0.aprobacion_hna.value = eval('document.detail.aprobacion_hna'+i).value;
			window.opener.document.form0.fecha_vencim.value = eval('document.detail.fecha_vencim'+i).value;
			window.opener.document.form0.limite.value = eval('document.detail.limite'+i).value;
			window.opener.document.form0.admision.value = eval('document.detail.admision'+i).value;

			window.opener.document.getElementById('pac_data').style.display='none';
	<%
			}
		}
	%>
	window.close();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COMPA&Ntilde;&Iacute;A"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">

<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("compania",compania)%>
				<td width="33%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,30)%>
				</td>
				<td width="34%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("nombre","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("cliente",cliente)%>
				<%=fb.hidden("compania",compania)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("cliente",cliente)%>
				<%=fb.hidden("compania",compania)%>
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
      <%
      if(fp.equals("cargo_dev_oc")){
        if(fg.equals("1")){%>
        <td><cellbytelabel>Nombre</cellbytelabel></td>
        <td><cellbytelabel>C&eacute;dula</cellbytelabel></td>
      <%} else if(fg.equals("2")){%>
        <td><cellbytelabel>Nombre</cellbytelabel></td>
        <td><cellbytelabel>Cod. Empresa</cellbytelabel></td>
        <td><cellbytelabel>D&iacute;gito Verificador</cellbytelabel></td>
      <%} else if(fg.equals("3")){%>
        <td><cellbytelabel>Nombre</cellbytelabel></td>
        <td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
        <td><cellbytelabel>Identificaci&oacute;n</cellbytelabel></td>
      <%} else if(fg.equals("4")){%>
        <td><cellbytelabel>Centro Servicio</cellbytelabel></td>
        <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
        <td><cellbytelabel>Tipo CDS</cellbytelabel></td>
      <%} else if(fg.equals("5")){%>
        <td><cellbytelabel>Centro Servicio</cellbytelabel></td>
        <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
      <%} else if(fg.equals("6")){%>
        <td><cellbytelabel>Cod. Compa&ntilde;&iacute;a</cellbytelabel></td>
        <td><cellbytelabel>Nombre</cellbytelabel></td>
      <%} else if(fg.equals("7")){%>
        <td><cellbytelabel>Cliente</cellbytelabel></td>
        <td><cellbytelabel>Cliente No</cellbytelabel>.</td>
        <td><cellbytelabel>Contrato</cellbytelabel></td>
        <td><cellbytelabel>Tipo Cliente</cellbytelabel></td>
        <td><cellbytelabel>Tipo Cliente Desc</cellbytelabel>.</td>
        <td><cellbytelabel>Empresa</cellbytelabel></td>
        <td><cellbytelabel>Empleado</cellbytelabel></td>
        <td><cellbytelabel>M&eacute;dico</cellbytelabel></td>
        <td><cellbytelabel>Particular</cellbytelabel></td>
        <td><cellbytelabel>C&eacute;dula</cellbytelabel></td>
        <td><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
        <td><cellbytelabel>Nombre Cia</cellbytelabel>.</td>
        <td><cellbytelabel>D&iacute;gito Ver</cellbytelabel>.</td>
        <td><cellbytelabel>Nombre M&eacute;dico</cellbytelabel></td>
        <td><cellbytelabel>Identificaci&oacute;n</cellbytelabel></td>
        <td><cellbytelabel>Consultorio</cellbytelabel></td>
      <%} else if(fg.equals("8")){%>
        <td><cellbytelabel>Nombre</cellbytelabel></td>
      <%} else if(fg.equals("9") || fg.equals("10")){%>
        <td><cellbytelabel>Cliente</cellbytelabel></td>
        <td><cellbytelabel># de Paciente</cellbytelabel></td>
        <td><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
        <td><cellbytelabel>C&eacute;dula</cellbytelabel></td>
		<%
        }
      }
    %>
			</tr>
<%
String onSubmit = "";
if(fg.equals("FH")) onSubmit = "onSubmit=\"javascript:return(chkValues())\"";
fb = new FormBean("detail","","post",onSubmit);
%>
	<%=fb.formStart()%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')">
      <%
      if(fp.equals("cargo_dev_oc")){
        if(fg.equals("1")){%>
        <%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
        <%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
        <%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
        <%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
        <%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
        <td><%=cdo.getColValue("cliente")%></td>
        <td><%=cdo.getColValue("codigo")%></td>
      <%} else if(fg.equals("2")){%>
      	<%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
        <%=fb.hidden("cod_empresa"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("cob_tasa_gasnet"+i,cdo.getColValue("cob_tasa_gasnet"))%>
        <td><%=cdo.getColValue("cliente")%></td>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("digito_verificador")%></td>
      <%} else if(fg.equals("3")){%>
      	<%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
        <%=fb.hidden("cod_medico"+i,cdo.getColValue("codigo"))%>
        <td><%=cdo.getColValue("cliente")%></td>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("identificacion")%></td>
      <%} else if(fg.equals("4")){%>
      	<%=fb.hidden("centro_servicio"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("centro_servicio_desc"+i,cdo.getColValue("cliente"))%>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("cliente")%></td>
        <td><%=cdo.getColValue("tipo_cds")%></td>
      <%} else if(fg.equals("5")){%>
      	<%=fb.hidden("centro_servicio"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("centro_servicio_desc"+i,cdo.getColValue("cliente"))%>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("cliente")%></td>
      <%} else if(fg.equals("6")){%>
        <%=fb.hidden("compania"+i,cdo.getColValue("codigo"))%>
      	<%=fb.hidden("compania_desc"+i,cdo.getColValue("cliente"))%>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("cliente")%></td>
      <%} else if(fg.equals("7")){%>
      	<%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
        <%=fb.hidden("contrato"+i,cdo.getColValue("contrato"))%>
        <%=fb.hidden("tipo_cliente"+i,cdo.getColValue("tipo_cliente"))%>
        <%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
        <%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
        <%=fb.hidden("particular"+i,cdo.getColValue("particular"))%>
        <%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
        <%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
        <%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
        <%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
        <%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
        <%//=fb.hidden("digito_verificador"+i,cdo.getColValue("digito_verificador"))%>
        <%//=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
        <%//=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
        <td><%=cdo.getColValue("cliente")%></td>
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("contrato")%></td>
        <td><%=cdo.getColValue("tipo_cliente")%></td>
        <td><%=cdo.getColValue("tipo_cliente_desc")%></td>
        <td><%=cdo.getColValue("empresa")%></td>
        <td><%=cdo.getColValue("empleado")%></td>
        <td><%=cdo.getColValue("medico")%></td>
        <td><%=cdo.getColValue("particular")%></td>
        <td><%=cdo.getColValue("emp_cedula")%></td>
        <td><%=cdo.getColValue("compania")%></td>
        <td><%=cdo.getColValue("desc_cia")%></td>
        <td><%=cdo.getColValue("digito_verificador")%></td>
        <td><%=cdo.getColValue("nombre_medico")%></td>
        <td><%=cdo.getColValue("identificacion")%></td>
        <td><%=cdo.getColValue("consultorio")%></td>
      <%} else if(fg.equals("8")){%>
        <%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
        <td><%=cdo.getColValue("cliente")%></td>
      <%} else if(fg.equals("9") || fg.equals("10")){%>
        <%=fb.hidden("cliente"+i,cdo.getColValue("cliente"))%>
      	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
      	<%=fb.hidden("cedula_pasaporte"+i,cdo.getColValue("cedula_pasaporte"))%>
      	<%=fb.hidden("aprobacion_hna"+i,cdo.getColValue("aprobacion_hna"))%>
      	<%=fb.hidden("limite"+i,cdo.getColValue("limite"))%>
      	<%=fb.hidden("diag_hna"+i,cdo.getColValue("diag_hna"))%>
      	<%=fb.hidden("fecha_vencim"+i,cdo.getColValue("fecha_vencim"))%>
      	<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
        <%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
        <td><%=cdo.getColValue("cliente")%></td>
        <td align="center"><%=cdo.getColValue("codigo")%></td>
        <td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
        <td align="center"><%=cdo.getColValue("cedula_pasaporte")%></td>
		<%
        }
      }
    %>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("cliente",cliente)%>
				<%=fb.hidden("compania",compania)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("cliente",cliente)%>
				<%=fb.hidden("compania",compania)%>
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
