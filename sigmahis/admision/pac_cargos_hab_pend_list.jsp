<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 48;
int iconWidth = 48;
String cds = request.getParameter("cds");
String categoria = request.getParameter("categoria");
String status = request.getParameter("status");
String dateType = request.getParameter("dateType");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String sql = "";
String appendFilter = "",aseguradoraDesc="",aseguradora="",appendFilter2="";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha_cargo = request.getParameter("fecha_cargo");
StringBuffer sbSql = new StringBuffer();
if(fecha_cargo==null || fecha_cargo.equals("")) fecha_cargo = cDate;

if (cds == null) cds = "";
if (cds.trim().equalsIgnoreCase(""))
{
	if (!UserDet.getUserProfile().contains("0"))
		if(session.getAttribute("_cds")!=null) appendFilter += " and a.centro_servicio in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+")";
		else appendFilter += " and a.centro_servicio in (-1)";
}
else appendFilter += " and a.centro_servicio="+cds+"";

if (categoria == null) categoria = "";
if (!categoria.equalsIgnoreCase("")) appendFilter += " and a.categoria="+categoria+"";

if (status == null) status = "";
if (!status.equalsIgnoreCase("")) /*appendFilter += " and a.estado in ('A','P','S','E','I')";
else */ appendFilter += " and a.estado='"+status+"'";

if (dateType == null) dateType = "";
/*
if (dob == null) dob = cDate;
if (fDate == null || tDate == null)
{
	fDate = cDate;
	tDate = cDate;
}*/

if (request.getMethod().equalsIgnoreCase("GET"))
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

String cedulaPasaporte = request.getParameter("cedulaPasaporte");
String dob = request.getParameter("dob");
String codigo = request.getParameter("codigo");
String noAdmision = request.getParameter("noAdmision");
String paciente = request.getParameter("paciente");
String fg =request.getParameter("fg");

String tables ="";
if (cedulaPasaporte == null) cedulaPasaporte = "";
if (dob == null) dob = "";
if (codigo == null) codigo = "";
if (noAdmision == null) noAdmision = "";
if (paciente == null) paciente = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";
if (fg == null) fg = "";


if (!cedulaPasaporte.trim().equals("")) appendFilter += " and upper(coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula) like '%"+request.getParameter("cedulaPasaporte").toUpperCase()+"%'";
if (!dob.trim().equals("")) appendFilter += " and trunc(b.f_nac)=to_date('"+dob+"','dd/mm/yyyy')";
if (!codigo.trim().equals("")) appendFilter += " and a.pac_id="+codigo;
if (!noAdmision.trim().equals("")) appendFilter += " and upper(a.secuencia)="+noAdmision;
if (!paciente.trim().equals("")) appendFilter += " and upper(b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada))) like '%"+paciente.toUpperCase()+"%'";

if (!fDate.trim().equals("") && !tDate.trim().equals("")){//appendFilter += " and a.fecha_ingreso=to_date('"+fDate+"','dd/mm/yyyy')";

	String field = "nvl(a.fecha_ingreso,a.fecha_creacion)";
	String label = "Ingreso";

	if (dateType.equalsIgnoreCase("E"))
		{
			field = "a.fecha_egreso";
			label = "Egreso";
		}
		appendFilter += " and to_date(to_char("+field+",'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";
}
	 if((request.getParameter("aseguradora") != null && !request.getParameter("aseguradora").trim().equals("")) ||(request.getParameter("aseguradoraDesc") != null && !request.getParameter("aseguradoraDesc").trim().equals("")))
	 {

		tables += ", (select empresa,pac_id,admision from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) g, tbl_adm_empresa h";
		//fields = ", ' ' as categoriaSigno, 0 as neIcon, d.cama, nvl(h.nombre,' ') as empresa_nombre, f.unidad_admin as cds";
		appendFilter2 += " and a.pac_id=g.pac_id(+) and a.secuencia=g.admision(+) and g.empresa=h.codigo(+) ";

		if(request.getParameter("aseguradora") != null && !request.getParameter("aseguradora").trim().equals(""))
		{
			//tables += ", (select empresa from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) g ";
			//appendFilter += " and a.pac_id=g.pac_id(+) and a.secuencia=g.admision(+) ";
			appendFilter += " and g.empresa = "+request.getParameter("aseguradora");
			aseguradora = request.getParameter("aseguradora");
		}
		else if(request.getParameter("aseguradoraDesc") != null && !request.getParameter("aseguradoraDesc").trim().equals(""))
		{
			appendFilter += " and upper(h.nombre) like '%"+request.getParameter("aseguradoraDesc").toUpperCase()+"%'";
			aseguradoraDesc = request.getParameter("aseguradoraDesc");
		}
	}
if (request.getParameter("cds") != null)
{
	sql = "select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, b.id_paciente as pasaporte, b.id_paciente  cedulaPamd, a.compania, a.pac_id as pacId, b.nombre_paciente as nombrePaciente, c.nombre_corto as categoriaDesc, a.centro_servicio as centroServicio, d.descripcion as centroServicioDesc, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cdsCama,a.centro_servicio) else a.centro_servicio end as area/*es el cds para expediente*/, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cama,' ') else ' ' end as cama, a.medico, nvl(trunc(months_between(sysdate,a.fecha_nacimiento)/12),0) as key, chkcargohab(a.compania, '"+fecha_cargo+"', a.pac_id, a.secuencia) status, to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimientoAnt from tbl_adm_admision a,vw_adm_paciente b, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d, (select distinct g.compania, g.pac_id, g.admision, g.cama, f.unidad_admin as cdsCama from tbl_adm_cama_admision g, tbl_sal_cama e, tbl_sal_habitacion f where g.compania=e.compania and g.cama=e.codigo and g.habitacion=e.habitacion and e.habitacion=f.codigo and e.compania=f.compania and g.fecha_final is null and g.hora_final is null) x"+tables+" where a.compania="+(String) session.getAttribute("_companyId")+" and a.compania = x.compania(+) and a.pac_id=x.pac_id(+) and a.secuencia=x.admision(+) and a.pac_id=b.pac_id and a.categoria=c.codigo and a.centro_servicio=d.codigo "+appendFilter+appendFilter2+" and chkcargohab(a.compania, '"+fecha_cargo+"', a.pac_id, a.secuencia) in ('S', 'C', 'D') order by nvl(a.fecha_ingreso,a.fecha_creacion) desc, nombrePaciente, a.secuencia";
	System.out.println("SQL=\n"+sql);
	al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, tmp.* from ("+sql+") tmp where rownum <= "+nextVal+") where rn >= "+previousVal,Admision.class);
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function printList(){abrir_ventana('../admision/print_list_admision.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function setIndex(k){document.result.index.value=k;getPatientDetails(k);}
function view(pacId,noAdmision){abrir_ventana('../admision/admision_config.jsp?mode=view&pacId='+pacId+'&noAdmision='+noAdmision);}
function showEmpresaList(){	abrir_ventana1('../common/search_empresa.jsp?fp=admisionSearch');}
function getPatientDetails(k){var pacId=eval('document.result.pacId'+k).value;var noAdmision=eval('document.result.noAdmision'+k).value;var cama=eval('document.result.cama'+k).value;var medico=eval('document.result.medico'+k).value;var asegDesc='';var camaDesc=cama;var medDesc='';if(pacId!=undefined&&noAdmision!=undefined){asegDesc=getDBData('<%=request.getContextPath()%>','y.nombre','(select * from tbl_adm_beneficios_x_admision where pac_id='+pacId+' and admision='+noAdmision+' and prioridad=1 and nvl(estado,\'A\')=\'A\') z, tbl_adm_empresa y','z.empresa=y.codigo','');}if(medico!=undefined)medDesc=getDBData('<%=request.getContextPath()%>','\'[\'||nvl(reg_medico,codigo)||\'] \'||decode(sexo,\'F\',\'DRA. \',\'M\',\'DR. \')||primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico','codigo=\''+medico+'\'','');document.getElementById("asegDesc").innerHTML=asegDesc;if(camaDesc.trim()==''){document.getElementById("camaId").className='TextRow2';document.getElementById("camaLabel").style.display='none';document.getElementById("camaDesc").style.display='none';}else{document.getElementById("camaId").className='TextHeader';document.getElementById("camaLabel").style.display='';document.getElementById("camaDesc").style.display='';document.getElementById("camaDesc").innerHTML=camaDesc;}document.getElementById("medicoDesc").innerHTML=medDesc;}
function generarCargoDev(pac_id, adm, tipo_trx){var cds = document.search00.cds.value;var categoria = document.search00.categoria.value;var status = document.search00.status.value;var dateType = document.search00.dateType.value;var fDate = document.search00.fDate.value;var tDate = document.search00.tDate.value;var cedulaPasaporte = document.search00.cedulaPasaporte.value;var dob = document.search00.dob.value;var codigo = document.search00.codigo.value;var noAdmision = document.search00.noAdmision.value;var paciente = document.search00.paciente.value;var fecha = '<%=fecha_cargo%>';if(confirm('Confirma la generación de '+(tipo_trx=='D'?'Devolución?':'Cargo!'))){if(tipo_trx=='S') tipo_trx = 'C';showPopWin('../common/run_process.jsp?fp=CAMA&actType=3&docType=CAMA&docId='+adm+'&docNo='+adm+'&fecha='+fecha+'&compania=<%=(String) session.getAttribute("_companyId")%>&tipo='+tipo_trx+'&pacId='+pac_id+'&noAdmision='+adm,winWidth*.75,winHeight*.65,null,null,'');}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - TRANSACCIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="3">
			<%sbSql= new StringBuffer();
			if(!UserDet.getUserProfile().contains("0"))
			{
				sbSql.append(" and codigo in (");
					if(session.getAttribute("_cds")!=null)
						sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
					else sbSql.append("-1");
				sbSql.append(")");
			}%>

				Area
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_cds_centro_servicio where estado='A'"+sbSql.toString()+" order by 2 asc","cds",cds,false,false,0,"Text10",null,null,null,"T")%>
				Categoria
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
				Estado
				<%=fb.select("status","A=ACTIVA,P=PRE ADMISIONES,S=ESPECIAL,E=ESPERA,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="25%">
				C&eacute;dula / Pasaporte
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="30%">
				Fecha Nac.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				Id. Pac.
					<%=fb.textBox("codigo",codigo,false,false,false,10,"Text10",null,null)%></td>

<td width="45%">No. Adm.
<%=fb.textBox("noAdmision",noAdmision,false,false,false,5,null,null,"")%> </td>
	</tr>
		<tr class="TextFilter">
			<td  colspan="2">
				Paciente
				<%=fb.textBox("paciente",paciente,false,false,false,40,"Text10",null,null)%>
			</td>
			<td>
				Fecha 
				<%=fb.select("dateType","I=Ingreso,E=Egreso",dateType)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="nameOfTBox2" value="tDate" />
				<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="3">
				Aseguradora
				<%=fb.textBox("aseguradora",aseguradora,false,false,false,10,"Text10",null,null)%>
				<%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,false,40,"Text10",null,null)%>
				<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
        &nbsp;
        Fecha de Cargo:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha_cargo" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_cargo%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
			<%fb.appendJsValidation("if((document.search00.fecha_cargo.value!='' && !isValidateDate(document.search00.fecha_cargo.value))||(document.search00.fDate.value!='' && !isValidateDate(document.search00.fDate.value))||(document.search00.tDate.value!='' && !isValidateDate(document.search00.tDate.value))||(document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){alert('Formato de fecha inválida!');error++;}");%>

<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder" align="center">
		<table width="100%" border="0" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td width="13%" class="TextHeader">Aseguradora</td>
			<td width="25%"><label id="asegDesc"></label><%//=cdo.getColValue("empresa_nombre")%></td>
			<td width="7%" id="camaId"><label id="camaLabel" style="display:none">Cama</label></td>
			<td width="10%"><label id="camaDesc" style="display:none"></label><%//=cdo.getColValue("cama")%></td>
			<td width="8%" class="TextHeader">M&eacute;dico<%//=medicDisplay%></td>
		 <td width="37%"><label id="medicoDesc"></label><!--[ <%//=cdo.getColValue("medico")%> ] <%//=cdo.getColValue("nombreMedico")%>--></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<div id="admisionMain" width="100%" class="adm h300">
<div id="admision" width="98%" class="child">
		<table align="center" width="100%" cellpadding="0" cellspacing="1" height="25">
		<tr class="TextHeader" align="center">
			<td width="15%">Area</td>
			<td width="5%">Cat.</td>
			<td width="7%">Fecha Nac.</td>
			<td width="3%">Edad</td>
			<td width="4%">C&oacute;d. Pac.</td>
			<td width="4%">No. Adm.</td>
			<td width="10%">C&eacute;dula / Pasaporte</td>
			<td width="22%">Paciente</td>
			<td width="7%">Fecha Ingreso</td>
			<td width="7%">Fecha Egreso</td>
			<td width="7%">Estado</td>
			<td width="7%">Generar</td>
			<td width="2%">&nbsp;</td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%
String estado = "";
for (int i=0; i<al.size(); i++)
{
	Admision adm = (Admision) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	estado = adm.getEstado();
	if (adm.getEstado().equalsIgnoreCase("A")) estado = "ACTIVO";
	else if (adm.getEstado().equalsIgnoreCase("P")) estado = "PRE ADMISIONES";
	else if (adm.getEstado().equalsIgnoreCase("S")) estado = "ESPECIAL";
	else if (adm.getEstado().equalsIgnoreCase("E")) estado = "ESPERA";
	else if (adm.getEstado().equalsIgnoreCase("I")) estado = "INACTIVO";
%>
		<%=fb.hidden("estado"+i,adm.getEstado())%>
		<%=fb.hidden("pacId"+i,adm.getPacId())%>
		<%=fb.hidden("noAdmision"+i,adm.getNoAdmision())%>
		<%=fb.hidden("dob"+i,adm.getFechaNacimiento())%>
		<%=fb.hidden("codPac"+i,adm.getCodigoPaciente())%>
		<%=fb.hidden("categoria"+i,adm.getCategoria())%>
		<%=fb.hidden("cds"+i,adm.getArea())%>
		<%=fb.hidden("centroServicio"+i,adm.getCentroServicio())%>
		<%=fb.hidden("medico"+i,adm.getMedico())%>
		<%=fb.hidden("cama"+i,adm.getCama())%>
		<%=fb.hidden("statusAdm"+i,estado)%>
        <%=fb.hidden("cedulaPasaporte"+i,adm.getCedulaPamd())%>
         <%=fb.hidden("pasaporte"+i,adm.getPasaporte())%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=adm.getCentroServicio()%>] <%=adm.getCentroServicioDesc()%></td>
			<td align="center"><%=adm.getCategoriaDesc()%></td>
			<td align="center"><%=adm.getFechaNacimientoAnt()%></td>
			<td align="center"><%=adm.getKey()%></td>
			<td align="center"><%=adm.getPacId()%></td>
			<td align="center"><%=adm.getNoAdmision()%></td>
			<td><%=adm.getPasaporte()%></td>
			<td onMouseOver="javascript:displayElementValue('lblPacId<%=i%>',' [<%=adm.getPacId()%>]');" onMouseOut="javascript:displayElementValue('lblPacId<%=i%>','');"><%=adm.getNombrePaciente()%><label id="lblPacId<%=i%>"></label></td>
			<td align="center"><%=adm.getFechaIngreso()%></td>
			<td align="center"><%=adm.getFechaEgreso()%></td>
			<td align="center"><%=estado%></td>
			<td align="center"><a href="javascript:generarCargoDev(<%=adm.getPacId()%>, <%=adm.getNoAdmision()%>, '<%=adm.getStatus()%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=(adm.getStatus().equals("S") || adm.getStatus().equals("C")?"Cargo":"Devolucion")%></a></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
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
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
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