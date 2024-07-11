<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iBen" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vBen" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400009") || SecMgr.checkAccess(session.getId(),"400010") || SecMgr.checkAccess(session.getId(),"400011") || SecMgr.checkAccess(session.getId(),"400012"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdoParam = new CommonDataObject();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String tr = request.getParameter("tr");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String getOneOfTheLastBen = request.getParameter("getOneOfTheLastBen");

String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String admKey = request.getParameter("adm_key");
String aseguradora = request.getParameter("aseguradora");
String tipoCta = request.getParameter("tipo_cta");

if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";
if (admKey == null) admKey = "";
if (aseguradora == null) aseguradora = "";
if (tipoCta == null) tipoCta = "";

int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;
String empresa = request.getParameter("empresa");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String oldBenefits = request.getParameter("oldBenefits");
String admCat = request.getParameter("admCat");
String admType = request.getParameter("admType");
String vip = request.getParameter("vip");
String  usaPlanMedico= "N";
String pagado_hasta = "";
String paciente_pm = "N";
try {usaPlanMedico =java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico");}catch(Exception e){ usaPlanMedico = "N";}
CommonDataObject cdPM = new CommonDataObject();
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "";
if (tr == null) tr = "";
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));
if (empresa == null) empresa = "";
if (!empresa.equals("")) { sbFilter.append(" and a.empresa = "); sbFilter.append(empresa); }
if (tipoPoliza == null) tipoPoliza = "";
if (!tipoPoliza.equals("")) { sbFilter.append(" and b.tipo_poliza = "); sbFilter.append(tipoPoliza); }
if (tipoPlan == null) tipoPlan = "";
//if (!tipoPlan.equals("")) { sbFilter.append(" and a.tipo_plan = "); sbFilter.append(tipoPlan); }
if (oldBenefits == null) oldBenefits = "N";
if (admCat == null) admCat = "";
if (!admCat.equals("")) { sbFilter.append(" and a.categoria_admi = "); sbFilter.append(admCat); }
if (admType == null) admType = "";
if (!admType.equals("")) { sbFilter.append(" and a.tipo_admi = "); sbFilter.append(admType); }
if (vip == null) vip = "";
String curCompanyId = (String)session.getAttribute("_companyId");

cdoParam = SQLMgr.getData(" select get_sec_comp_param("+curCompanyId+",'ADM_USA_FIDELIZACION') as fidelizacion, nvl(get_sec_comp_param("+curCompanyId+",'ADM_SHOW_EMPRESA_JUB'),'N') as show_jub from dual");

if (cdoParam.getColValue("fidelizacion").trim().equals("S"))
{
	if(!vip.equals("")) { sbFilter.append(" and b.vip = '"); sbFilter.append(vip); sbFilter.append("'"); }
	else { sbFilter.append(" and b.vip is null"); }

}

boolean showJub = (cdoParam.getColValue("show_jub").equalsIgnoreCase("S") || cdoParam.getColValue("show_jub").equalsIgnoreCase("Y"));
if (!showJub) { sbFilter.append(" and b.empresa > 0"); }

if (getOneOfTheLastBen==null) getOneOfTheLastBen = "";

String catAdm = request.getParameter("cat_adm");
if (catAdm == null) catAdm = "";

if(request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
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
	String plan = request.getParameter("plan");
	String nombre = request.getParameter("nombre");
	String clasif = request.getParameter("clasif");
	String clasifDesc = request.getParameter("clasifDesc");
	if (plan == null) plan = "";
	if (nombre == null) nombre = "";
	if (clasif == null) clasif = "";
	if (clasifDesc == null) clasifDesc = "";
	if (!plan.trim().equals("")) { sbFilter.append(" and upper(a.plan) like '%"); sbFilter.append(plan.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(b.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!clasif.trim().equals("")) { sbFilter.append(" and upper(a.clasif_admi) like '%"); sbFilter.append(clasif.toUpperCase()); sbFilter.append("%'"); }
	if (!clasifDesc.trim().equals("")) { sbFilter.append(" and upper(g.descripcion) like '%"); sbFilter.append(clasifDesc.toUpperCase()); sbFilter.append("%'"); }

	if (fp.equalsIgnoreCase("admision")||fp.equalsIgnoreCase("admision_new"))
	{
		if (oldBenefits.equalsIgnoreCase("Y"))
		{
			sbSql.append("select distinct a.empresa, a.convenio, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc, a.poliza, a.certificado, a.prioridad, a.convenio_sol_emp as convenioSolEmp, a.num_aprobacion as numAprobacion, (case when to_char(a.empresa) in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual))  then 'Y' else 'N' end ) as es_axa, nvl(d.use_employ,'N') as use_employ, ");
			sbSql.append(usaPlanMedico.equals("S")?"(case when to_char(d.grupo_empresa) = get_sec_comp_param(-1, 'LIQ_RECL_TIPO_EMP') then 'S' else 'N' end)":"'N'");
			sbSql.append(" empresa_pm from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=");
			sbSql.append(pacId);
			sbSql.append(") and a.estado='A' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado='A' and c.empresa=d.codigo and c.estatus='A' and d.estado='A' and a.tipo_plan=e.tipo_plan and a.tipo_poliza=e.poliza and a.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo");
			sbSql.append(sbFilter);
			sbSql.append(" order by a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi");
			al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
			rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
		}
		else
		{
			sbSql.append("select a.empresa, a.convenio, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc, ' ' as poliza, ' ' as certificado, ' ' as prioridad, 'N' as convenioSolEmp, ' ' as numAprobacion, (case when to_char(a.empresa) in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual))  then 'Y' else 'N' end )  as es_axa, nvl(d.use_employ,'N') as use_employ, ");
			sbSql.append(usaPlanMedico.equals("S")?"(case when to_char(d.grupo_empresa) = get_sec_comp_param(-1, 'LIQ_RECL_TIPO_EMP') then 'S' else 'N' end)":"'N'");
			sbSql.append(" empresa_pm from tbl_adm_clasif_x_plan_conv a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado='A' and c.empresa=d.codigo and c.estatus='A' and a.estado <> 'I' and b.tipo_plan=e.tipo_plan and b.tipo_poliza=e.poliza and b.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo");
			sbSql.append(sbFilter);
			sbSql.append(" order by a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi");
			al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
			rowCount = CmnMgr.getCount("select count(*) from tbl_adm_clasif_x_plan_conv a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado='A'  and a.estado <> 'I'  and c.empresa=d.codigo and c.estatus='A' and b.tipo_plan=e.tipo_plan and b.tipo_poliza=e.poliza and b.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo"+sbFilter+"");
		}
		if(usaPlanMedico.equals("S")){
			cdPM = SQLMgr.getData("select (select getPagadoHasta (id_solicitud) pagado_hasta from tbl_pm_sol_contrato_det d where exists (select null from tbl_pm_cliente c where c.codigo = d.id_cliente and c.pac_id = "+pacId+") and d.estado = 'A' and rownum = 1) pagado_hasta, nvl((select 'S' from dual where exists (select null from tbl_pm_cliente where pac_id = "+pacId+")), 'N') paciente_pm from dual");
			if(cdPM==null || cdPM.getColValue("pagado_hasta").equals("")) {cdPM = new CommonDataObject(); cdPM.addColValue("pagado_hasta", ""); cdPM.addColValue("paciente_pm", "N");}
			pagado_hasta = cdPM.getColValue("pagado_hasta");
			paciente_pm = cdPM.getColValue("paciente_pm");
		}
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
<script>
document.title = 'Plan Convenio - '+document.title;

function getMain(formX)
{
	formX.empresa.value = document.search00.empresa.value;
	formX.tipoPoliza.value = document.search00.tipoPoliza.value;
	//formX.tipoPlan.value = document.search00.tipoPlan.value;
	formX.admCat.value = document.search00.admCat.value;
	formX.admType.value = document.search00.admType.value;
	return true;
}

function doAction()
{
	loadXML('../xml/itemTipo.xml','admType','<%=admType%>','VALUE_COL','LABEL_COL','<%=admCat%>','KEY_COL','T');
}
//var ignoreSelectAnyWhere;
function chkPagadoHasta(i){
	var pagado_hasta = '<%=pagado_hasta%>';
	var continuar = true;
	if(eval('document.results.check'+i)){
		if(eval('document.results.empresa_pm'+i).value=='S'){
			if('<%=paciente_pm%>'=='N') {
				continuar = confirm('El paciente no pertenece al Plan Medico. ¿Desea Continuar?');
				eval('document.results.check'+i).checked=continuar;
			} else {
			if(eval('document.results.check'+i).checked==true){
				if(confirm('El cliente de Plan Medico tiene las cuotas pagadas hasta '+pagado_hasta+'! Desea continuar?')){
					eval('document.results.check'+i).checked= true;
				} else eval('document.results.check'+i).checked=false;
			}
			}
		}
	}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCIONAR PLAN CONVENIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("oldBenefits",oldBenefits)%>
<%=fb.hidden("getOneOfTheLastBen",getOneOfTheLastBen)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
	<%=fb.hidden("tipo_cta",tipoCta)%>
	<%=fb.hidden("adm_key",admKey)%>
	<%=fb.hidden("aseguradora",aseguradora)%>
	<%=fb.hidden("cat_adm",catAdm)%>
			<td colspan="2">
				<cellbytelabel>Empresa</cellbytelabel>
				<% sbSql = new StringBuffer(); sbSql.append("select distinct a.codigo, a.nombre, a.codigo from tbl_adm_empresa a, tbl_adm_convenio b where a.codigo=b.empresa and b.estatus='A' and a.estado='A' and tipo_empresa in ( select column_value from table( select split((select get_sec_comp_param("+session.getAttribute("_companyId")+",'ADM_TIPO_EMPRESA_CONV') from dual) ,',') from dual  )) "); if (!showJub) sbSql.append(" and a.codigo > 0"); sbSql.append(" order by 2"); %>
				<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"empresa",empresa,false,false,0,"Text10",null,null,"","T")%>
				<cellbytelabel>Tipo P&oacute;liza</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_adm_tipo_poliza order by nombre","tipoPoliza",tipoPoliza,false,false,0,"Text10",null,null,"","T")%>
				<!--Tipo de Plan-->
				<%//=fb.select(ConMgr.getConnection(),"select tipo_plan, nombre, tipo_plan from tbl_adm_tipo_plan order by nombre","tipoPlan",tipoPlan,"T")%>
				<cellbytelabel>Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision order by descripcion","admCat",admCat,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemTipo.xml','admType','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"","","T")%>
				<cellbytelabel>Tipo Admisi&oacute;n</cellbytelabel>
				<%=fb.select("admType","","",false,false,0,"Text10",null,null,"","T")%>
				<script language="javascript">
				loadXML('../xml/itemTipo.xml','admType','<%=admType%>','VALUE_COL','LABEL_COL','<%=admCat%>','KEY_COL','T');
				</script>
			</td>
		</tr>

		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>Plan</cellbytelabel>
				<%=fb.textBox("plan","",false,false,false,5,"Text10",null,null)%>
			</td>

			<td width="50%">
				<cellbytelabel>Clasificaci&oacute;n</cellbytelabel>
				<%=fb.textBox("clasif","",false,false,false,5,"Text10",null,null)%>
			</td>
		</tr>

		<tr class="TextFilter">
			<td>
				<cellbytelabel>Nombre del Plan</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40,"Text10",null,null)%>
			</td>

			<td>
				<cellbytelabel>Descrip. Clasificaci&oacute;n</cellbytelabel>
				<%=fb.textBox("clasifDesc","",false,false,false,40,"Text10",null,null)%>
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
<%fb = new FormBean("results",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tr",tr)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("oldBenefits",oldBenefits)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%//=fb.hidden("tipoPlan",tipoPoliza)%>
<%=fb.hidden("admCat",""+admCat)%>
<%=fb.hidden("admType",""+admType)%>
<%=fb.hidden("plan",plan)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("clasif",clasif)%>
<%=fb.hidden("clasifDesc",clasifDesc)%>
<%=fb.hidden("getOneOfTheLastBen",getOneOfTheLastBen)%>
<%=fb.hidden("vip",vip)%>
<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
	<%=fb.hidden("tipo_cta",tipoCta)%>
	<%=fb.hidden("adm_key",admKey)%>
	<%=fb.hidden("aseguradora",aseguradora)%>
	<%=fb.hidden("cat_adm",catAdm)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td colspan="2"><cellbytelabel>Plan</cellbytelabel></td>
			<td colspan="2"><cellbytelabel>Categor&iacute;a Admisi&oacute;n</cellbytelabel></td>
			<td colspan="2"><cellbytelabel>Tipo Admisi&oacute;n</cellbytelabel></td>
			<td colspan="2"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
			<td rowspan="2" width="4%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los planes listados!")%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="19%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="19%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="19%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
			<td width="19%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		</tr>
<%
String e = "";
String pp = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!e.equalsIgnoreCase(cdo.getColValue("empresa")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="9"><cellbytelabel>EMPRESA</cellbytelabel>: <b>[<%=cdo.getColValue("empresa")%>] <%=cdo.getColValue("nombreEmpresa")%></b></td>
		</tr>
<%
	}

	if (!pp.equalsIgnoreCase(cdo.getColValue("tipoPoliza")+"-"+cdo.getColValue("tipoPlan")))
	{
%>
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel>TIPO DE POLIZA</cellbytelabel>: <b>[<%=cdo.getColValue("tipoPoliza")%>] <%=cdo.getColValue("nombreTipoPoliza")%></b></td>
			<td colspan="5"><cellbytelabel>TIPO DE PLAN</cellbytelabel>: <b>[<%=cdo.getColValue("tipoPlan")%>] <%=cdo.getColValue("nombreTipoPlan")%></b></td>
		</tr>
<%
	}
%>
		<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
		<%=fb.hidden("convenio"+i,cdo.getColValue("convenio"))%>
		<%=fb.hidden("plan"+i,cdo.getColValue("plan"))%>
		<%=fb.hidden("categoriaAdmi"+i,cdo.getColValue("categoriaAdmi"))%>
		<%=fb.hidden("tipoAdmi"+i,cdo.getColValue("tipoAdmi"))%>
		<%=fb.hidden("clasifAdmi"+i,cdo.getColValue("clasifAdmi"))%>
		<%=fb.hidden("tipoPoliza"+i,cdo.getColValue("tipoPoliza"))%>
		<%=fb.hidden("tipoPlan"+i,cdo.getColValue("tipoPlan"))%>
		<%=fb.hidden("nombrePlan"+i,cdo.getColValue("nombrePlan"))%>
		<%=fb.hidden("nombreConvenio"+i,cdo.getColValue("nombreConvenio"))%>
		<%=fb.hidden("nombreEmpresa"+i,cdo.getColValue("nombreEmpresa"))%>
		<%=fb.hidden("nombreTipoPlan"+i,cdo.getColValue("nombreTipoPlan"))%>
		<%=fb.hidden("nombreTipoPoliza"+i,cdo.getColValue("nombreTipoPoliza"))%>
		<%=fb.hidden("clasifAdmiDesc"+i,cdo.getColValue("clasifAdmiDesc"))%>
		<%=fb.hidden("tipoAdmiDesc"+i,cdo.getColValue("tipoAdmiDesc"))%>
		<%=fb.hidden("categoriaAdmiDesc"+i,cdo.getColValue("categoriaAdmiDesc"))%>
		<%=fb.hidden("poliza"+i,cdo.getColValue("poliza").trim())%>
		<%=fb.hidden("certificado"+i,cdo.getColValue("certificado").trim())%>
		<%=fb.hidden("prioridad"+i,cdo.getColValue("prioridad").trim())%>
		<%=fb.hidden("convenioSolEmp"+i,cdo.getColValue("convenioSolEmp").trim())%>
		<%=fb.hidden("numAprobacion"+i,cdo.getColValue("numAprobacion").trim())%>
		<%=fb.hidden("es_axa"+i,cdo.getColValue("es_axa").trim())%>
		<%=fb.hidden("use_employ"+i,cdo.getColValue("use_employ").trim())%>
		<%=fb.hidden("empresa_pm"+i,cdo.getColValue("empresa_pm").trim())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("convenio")%>-<%=cdo.getColValue("plan")%></td>
			<td><%=cdo.getColValue("nombrePlan")%></td>
			<td><%=cdo.getColValue("categoriaAdmi")%></td>
			<td><%=cdo.getColValue("categoriaAdmiDesc")%></td>
			<td><%=cdo.getColValue("tipoAdmi")%></td>
			<td><%=cdo.getColValue("tipoAdmiDesc")%></td>
			<td><%=cdo.getColValue("clasifAdmi")%></td>
			<td><%=cdo.getColValue("clasifAdmiDesc")%></td>
<td align="center"><%=(vBen.contains(cdo.getColValue("empresa")+"-"+cdo.getColValue("convenio")+"-"+cdo.getColValue("plan")+"-"+cdo.getColValue("categoriaAdmi")+"-"+cdo.getColValue("tipoAdmi")+"-"+cdo.getColValue("clasifAdmi")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("empresa")+"-"+cdo.getColValue("convenio")+"-"+cdo.getColValue("plan")+"-"+cdo.getColValue("categoriaAdmi")+"-"+cdo.getColValue("tipoAdmi")+"-"+cdo.getColValue("clasifAdmi"),false,false, "", "", (usaPlanMedico.equals("S")?"onClick=\"javascript:chkPagadoHasta("+i+");\"":""))%></td>
		</tr>
<%
	e = cdo.getColValue("empresa");
	pp = cdo.getColValue("tipoPoliza")+"-"+cdo.getColValue("tipoPlan");
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	int size = Integer.parseInt(request.getParameter("size"));
	if (fp.equalsIgnoreCase("admision_new"))benLastLineNo=iBen.size();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			Admision obj = new Admision();

			obj.setEmpresa(request.getParameter("empresa"+i));
			obj.setConvenio(request.getParameter("convenio"+i));
			obj.setPlan(request.getParameter("plan"+i));
			obj.setCategoriaAdmi(request.getParameter("categoriaAdmi"+i));
			obj.setTipoAdmi(request.getParameter("tipoAdmi"+i));
			obj.setClasifAdmi(request.getParameter("clasifAdmi"+i));
			obj.setTipoPoliza(request.getParameter("tipoPoliza"+i));
			obj.setTipoPlan(request.getParameter("tipoPlan"+i));
			obj.setNombrePlan(request.getParameter("nombrePlan"+i));
			obj.setNombreConvenio(request.getParameter("nombreConvenio"+i));
			obj.setNombreEmpresa(request.getParameter("nombreEmpresa"+i));
			obj.setNombreTipoPlan(request.getParameter("nombreTipoPlan"+i));
			obj.setNombreTipoPoliza(request.getParameter("nombreTipoPoliza"+i));
			obj.setClasifAdmiDesc(request.getParameter("clasifAdmiDesc"+i));
			obj.setTipoAdmiDesc(request.getParameter("tipoAdmiDesc"+i));
			obj.setCategoriaAdmiDesc(request.getParameter("categoriaAdmiDesc"+i));
			obj.setSecuencia("0");
			obj.setConvenioSolicitud("C");
			//obj.setConvenioSolEmp("N");
			//obj.setPrioridad("");
			obj.setFechaIni(cDate.substring(0,10));

			obj.setPoliza(request.getParameter("poliza"+i));
			obj.setCertificado(request.getParameter("certificado"+i));
			obj.setPrioridad(request.getParameter("prioridad"+i));
			obj.setConvenioSolEmp(request.getParameter("convenioSolEmp"+i));
			obj.setNumAprobacion(request.getParameter("numAprobacion"+i));
			if(request.getParameter("es_axa"+i)!=null) obj.setTipo(request.getParameter("es_axa"+i));

			if (obj.getCategoriaAdmi().equals("2")) obj.setFechaFin(cDate.substring(0,10));
			else obj.setFechaFin("");

			obj.setNumEmpleado(request.getParameter("use_employ"+i));
			benLastLineNo++;

			String key = "";
			if (benLastLineNo < 10) key = "00"+benLastLineNo;
			else if (benLastLineNo < 100) key = "0"+benLastLineNo;
			else key = ""+benLastLineNo;
			obj.setKey(key);

			try
			{
				iBen.put(obj.getKey(), obj);
				vBen.add(obj.getEmpresa()+"-"+obj.getConvenio()+"-"+obj.getPlan()+"-"+obj.getCategoriaAdmi()+"-"+obj.getTipoAdmi()+"-"+obj.getClasifAdmi());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&tr="+tr+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&benLastLineNo="+benLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&empresa="+empresa+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&oldBenefits="+oldBenefits+"&admCat="+admCat+"&admType="+admType+"&plan="+request.getParameter("plan")+"&nombre="+request.getParameter("nombre")+"&clasif="+request.getParameter("clasif")+"&clasifDesc="+request.getParameter("clasifDesc")+"&getOneOfTheLastBen="+getOneOfTheLastBen+"&vip="+vip+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente+"&tipo_cta="+tipoCta+"&aseguradora"+aseguradora+"&adm_key="+admKey+"&cat_adm="+catAdm);

		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&tr="+tr+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&benLastLineNo="+benLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&empresa="+empresa+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&oldBenefits="+oldBenefits+"&admCat="+admCat+"&admType="+admType+"&plan="+request.getParameter("plan")+"&nombre="+request.getParameter("nombre")+"&clasif="+request.getParameter("clasif")+"&clasifDesc="+request.getParameter("clasifDesc")+"&getOneOfTheLastBen="+getOneOfTheLastBen+"&vip="+vip+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente+"&tipo_cta="+tipoCta+"&aseguradora"+aseguradora+"&adm_key="+admKey+"&cat_adm="+catAdm);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("admision"))
	{
%>
	window.opener.location = '../admision/admision_config.jsp?change=1&tab=4&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&fg=<%=fg%>&fp=<%=tr%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tipo_cta=<%=tipoCta%>&adm_key=<%=admKey%>&aseguradora=<%=aseguradora%>&cat_adm=<%=catAdm%>';
<%
	} else if (fp.equalsIgnoreCase("admision_new"))
	{
%>
	window.opener.location = '../admision/admision_config_benef.jsp?change=1&tab=4&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&fg=<%=fg%>&fp=<%=tr%>&loadInfo=S&getOneOfTheLastBen=<%=getOneOfTheLastBen%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tipo_cta=<%=tipoCta%>&adm_key=<%=admKey%>&aseguradora=<%=aseguradora%>&cat_adm=<%=catAdm%>';
<%
	}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>