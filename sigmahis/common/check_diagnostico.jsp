<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.CitaProcedimiento"%>
<%@ page import="issi.admision.ProcedDiagnostico"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagPost" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPost" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagPre" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPre" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagNu" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagNu" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagFlujo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagFlujo" scope="session" class="java.util.Vector" />
<jsp:useBean id="vProcDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTempDiag" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagLiq" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDiagLiq" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDiagPostPC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPostPC" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagPrePC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPrePC" scope="session" class="java.util.Vector" />
<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500037") || SecMgr.checkAccess(session.getId(),"500038") || SecMgr.checkAccess(session.getId(),"500039") || SecMgr.checkAccess(session.getId(),"500040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String code = request.getParameter("code");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String idEnfNofif = request.getParameter("id");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String procKey = request.getParameter("procKey");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String icd10 = request.getParameter("icd10");
String from = request.getParameter("from");
String exp = request.getParameter("exp");
String icdVersion = request.getParameter("icdVersion");
String fechaCreacionDiag = request.getParameter("fecha_creacion_diag");
String horaCreacionDiag = request.getParameter("hora_creacion_diag");

String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");

if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";

if ( desc == null ) desc = "";
if (codCita == null) codCita ="";
if (fechaCita == null) fechaCita ="";
if (procKey == null) procKey ="";
if (codigo == null) codigo = "";
if (descripcion == null) descripcion = "";
if (icd10 == null) icd10 = "";
if (from == null) from = "";
if (exp == null) exp = "";
if (icdVersion == null) icdVersion = "";
if (pacId == null || "".equals(pacId)) pacId = "0";
if (noAdmision == null || "".equals(noAdmision)) noAdmision = "0";
if (fechaCreacionDiag == null) fechaCreacionDiag = "";
if (horaCreacionDiag == null) horaCreacionDiag = "";

int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;
int muestraLastLineNo = 0;
int medLastLineNo = 0,dietaLastLineNo = 0,cuidadoLastLineNo = 0;
int procLastLineNo=0,diagPreLastLineNo=0,diagPostLastLineNo=0,especLastLineNo=0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));
if (request.getParameter("diagPostLastLineNo") != null) diagPostLastLineNo = Integer.parseInt(request.getParameter("diagPostLastLineNo"));
if (request.getParameter("muestraLastLineNo")!= null)muestraLastLineNo=Integer.parseInt(request.getParameter("muestraLastLineNo"));
if (request.getParameter("medLastLineNo") != null) medLastLineNo      =Integer.parseInt(request.getParameter("medLastLineNo"));
if (request.getParameter("dietaLastLineNo") != null) dietaLastLineNo  =Integer.parseInt(request.getParameter("dietaLastLineNo"));
if (request.getParameter("cuidadoLastLineNo")!= null)cuidadoLastLineNo=Integer.parseInt(request.getParameter("cuidadoLastLineNo"));
if (request.getParameter("diagPreLastLineNo")!= null)diagPreLastLineNo=Integer.parseInt(request.getParameter("diagPreLastLineNo"));
if (request.getParameter("procLastLineNo")!= null)procLastLineNo=Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("especLastLineNo")!= null)especLastLineNo=Integer.parseInt(request.getParameter("especLastLineNo"));

if (idEnfNofif == null) idEnfNofif = "";

if(request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select nvl(max((select icd_version from tbl_adm_empresa where codigo = z.empresa)),-1) as icd_version from tbl_adm_beneficios_x_admision z where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and nvl(estado,'A') = 'A'");
	CommonDataObject v = SQLMgr.getData(sbSql);

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

  if (!codigo.trim().equals("")) { sbFilter.append(" and upper(z.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
  if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(coalesce(z.observacion,z.nombre)) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!icd10.trim().equals("")) { sbFilter.append(" and upper(y.codigo_icd10) like '%"); sbFilter.append(icd10.toUpperCase()); sbFilter.append("%'"); }
	if (v.getColValue("icd_version").equals("-1") && !icdVersion.trim().equals("")) {
		sbFilter.append(" and (");
		//if (icdVersion.equals("10")) sbFilter.append(" (z.icd_version = 9 and y.codigo_icd10 is not null) or ");
		sbFilter.append("z.icd_version = ");
		sbFilter.append(icdVersion);
		sbFilter.append(")");
	} else if (!v.getColValue("icd_version").equals("-1")) {
		icdVersion = v.getColValue("icd_version");
	}
	if (fp.equalsIgnoreCase("evaluacionNutricional")) sbFilter.append(" and z.categoria = 3");

	sbSql = new StringBuffer();
	sbSql.append("select z.codigo, coalesce(z.observacion,z.nombre) as nombre, z.icd_version as icdVersion, nvl(y.codigo_icd10,' ') as icd10 from tbl_cds_diagnostico z, tbl_cds_diagnostico_icd10map y where z.codigo = y.codigo_icd09(+)");
	sbSql.append(sbFilter);
	sbSql.append(" order by 2,1,3");

	if (request.getParameter("codigo") != null) {

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Diagnóstico - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE DIAGNOSTICO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">

<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<%=fb.hidden("muestraLastLineNo",""+muestraLastLineNo)%>
				<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
				<%=fb.hidden("dietaLastLineNo",""+dietaLastLineNo)%>
				<%=fb.hidden("cuidadoLastLineNo",""+cuidadoLastLineNo)%>
				<%=fb.hidden("diagPreLastLineNo",""+diagPreLastLineNo)%>
				<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
				<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
				<%=fb.hidden("especLastLineNo",""+especLastLineNo)%>
				<%=fb.hidden("fg",""+fg)%>
				<%=fb.hidden("seccion",""+seccion)%>
				<%=fb.hidden("code",""+code)%>
				<%=fb.hidden("tab",""+tab)%>
				<%=fb.hidden("cds",""+cds)%>
        <%=fb.hidden("desc",""+desc)%>
				<%=fb.hidden("id",""+idEnfNofif)%>		
				<%=fb.hidden("codCita",codCita)%>
				<%=fb.hidden("fechaCita",fechaCita)%>
				<%=fb.hidden("procKey",procKey)%> 
				<%=fb.hidden("from",from)%> 
				<%=fb.hidden("exp",exp)%> 
				<%=fb.hidden("fecha_creacion_diag",fechaCreacionDiag)%> 
				<%=fb.hidden("hora_creacion_diag",horaCreacionDiag)%>
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
			
				<td width="30%">
					<cellbytelabel>ICD<%=(v.getColValue("icd_version").equals("-1"))?fb.select("icdVersion","9,10",icdVersion,false,false,0,null,null,null,null,"T"):fb.hidden("icdVersion",icdVersion)%></cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,20)%>
 				</td> 				
				<td width="30%">
					<cellbytelabel>Equivalente ICD10</cellbytelabel>
					<%=fb.textBox("icd10","",false,false,false,20)%>
 				</td> 				
				<td width="40%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
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
<%
fb = new FormBean("cds",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("muestraLastLineNo",""+muestraLastLineNo)%>
<%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
<%=fb.hidden("dietaLastLineNo",""+dietaLastLineNo)%>
<%=fb.hidden("cuidadoLastLineNo",""+cuidadoLastLineNo)%>
<%=fb.hidden("cds","").replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("seccion",""+seccion)%>
<%=fb.hidden("code",""+code)%>
<%=fb.hidden("diagPreLastLineNo",""+diagPreLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
<%=fb.hidden("especLastLineNo",""+especLastLineNo)%>
<%=fb.hidden("tab",""+tab)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("id",""+idEnfNofif)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("procKey",procKey)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("icdVersion",icdVersion)%>
<%=fb.hidden("fecha_creacion_diag",fechaCreacionDiag)%> 
				<%=fb.hidden("hora_creacion_diag",horaCreacionDiag)%> 
				<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
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
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>Versi&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel>ICD</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Equivalente ICD10</cellbytelabel></td>
					<td width="45%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:jqCheckAll(this.form.name,'check',this,true)\"","Seleccionar todas los diagnósticos listados!")%></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("icd10"+i,cdo.getColValue("icd10"))%>
				<%=fb.hidden("icdVersion"+i,cdo.getColValue("icdVersion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("icdVersion")%></td>
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("icd10")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=(((fp.equalsIgnoreCase("admision")||fp.equalsIgnoreCase("admision_new"))&& vDiag.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("informes") && vDiagPost.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("pSalida") && vDiag.contains(cdo.getColValue("codigo")+"-S"))||(fp.equalsIgnoreCase("planSalida") && vDiag.contains(cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("protocoloPost") && vDiagPost.contains(cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("protocoloPre") && vDiagPre.contains(cdo.getColValue("codigo"))|| (fp.equalsIgnoreCase("evaluacionNutricional") && vDiagNu.contains(cdo.getColValue("codigo")))) || (fp.equalsIgnoreCase("ctrlFlujo") && vDiagFlujo.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("pIngreso") && vDiag.contains(cdo.getColValue("codigo")+"-I")) || (fp.equalsIgnoreCase("citas") && vTempDiag.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("liq_recl") && vDiagLiq.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("protocolo_cesarea_pos") && vDiagPostPC.contains(cdo.getColValue("codigo")))|| (fp.equalsIgnoreCase("protocolo_cesarea_pre") && vDiagPrePC.contains(cdo.getColValue("codigo"))   ))?"Elegido":fb.checkbox("check"+cdo.getColValue("codigo").replaceAll("\\.","_")+"__"+i,cdo.getColValue("codigo"),false,false,null,null,"onClick=\"javascript:jqCheckOne(this.form.name,'check"+cdo.getColValue("codigo").replaceAll("\\.","_")+"__',this)\"")%></td>
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
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	if (fp.equalsIgnoreCase("admision_new") || fp.equalsIgnoreCase("citas"))diagLastLineNo=iDiag.size();
	
	CitaProcedimiento diagProc = new CitaProcedimiento();
	if (fp.equalsIgnoreCase("citas")){
		diagProc = (CitaProcedimiento )iProc.get(procKey);
		//diagProc.getProcedDiagnostico().clear();
	}
	
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+request.getParameter("codigo"+i).replaceAll("\\.","_")+"__"+i) != null)
		{
			if (fp.equalsIgnoreCase("admision")||fp.equalsIgnoreCase("admision_new"))
			{
				Admision obj = new Admision();

				obj.setDiagnostico(request.getParameter("codigo"+i));
				obj.setDiagnosticoDesc(request.getParameter("nombre"+i));
				obj.setIcd10(request.getParameter("icd10"+i));
				obj.setIcdVersion(request.getParameter("icdVersion"+i));
				
				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				obj.setKey(key);

				try
				{	System.out.println("adding key..."+key);
					iDiag.put(key, obj);
					vDiag.add(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}else if (fp.equalsIgnoreCase("informes"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagnostico",request.getParameter("nombre"+i));
				cdo.addColValue("observacion","");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));

				diagPostLastLineNo++;

				String key = "";
				if (diagPostLastLineNo < 10) key = "00"+diagPostLastLineNo;
				else if (diagPostLastLineNo < 100) key = "0"+diagPostLastLineNo;
				else key = ""+diagPostLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDiagPost.put(key, cdo);
					vDiagPost.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
			else if (fp.equalsIgnoreCase("pSalida")|| fp.equalsIgnoreCase("planSalida"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("diagnosticoDesc",request.getParameter("nombre"+i));
				cdo.addColValue("usuario_creacion",UserDet.getUserName());
				cdo.addColValue("fecha_creacion",cDateTime);
				cdo.setAction("I");
				cdo.addColValue("icd10",request.getParameter("icd10"+i));
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));


				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDiag.put(key, cdo);
					if(fp.equalsIgnoreCase("pSalida"))
						vDiag.add(cdo.getColValue("diagnostico")+"-S"); 
					else vDiag.add(cdo.getColValue("diagnostico")); 	
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("pIngreso"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("diagnosticoDesc",request.getParameter("nombre"+i));
				cdo.addColValue("usuario_creacion",UserDet.getUserName());
				cdo.addColValue("fecha_creacion",cDateTime);
				cdo.setAction("I");
				cdo.addColValue("icd10",request.getParameter("icd10"+i));
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));


				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDiag.put(key, cdo);
					vDiag.add(cdo.getColValue("diagnostico")+"-I");
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("protocoloPre") || fp.equalsIgnoreCase("patologicoPre"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagPre",request.getParameter("nombre"+i));
				cdo.addColValue("codigo","0");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));
				cdo.setAction("I");
				cdo.setKey(iDiagPre.size()+1);

				try
				{
					//iDiagPre.put(key, cdo);
					iDiagPre.put(cdo.getKey(),cdo);
					vDiagPre.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
            else if (fp.equalsIgnoreCase("protocolo_cesarea_pre"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagPre",request.getParameter("nombre"+i));
				cdo.addColValue("codigo","0");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));
				cdo.setAction("I");
				cdo.setKey(iDiagPrePC.size()+1);

				try
				{
					iDiagPrePC.put(cdo.getKey(),cdo);
					vDiagPrePC.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
			else if (fp.equalsIgnoreCase("protocoloPost") || fp.equalsIgnoreCase("patologicoPost"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagPost",request.getParameter("nombre"+i));
				cdo.addColValue("codigo","0");
				cdo.addColValue("pacId",pacId);
				cdo.addColValue("noAdmision",noAdmision);
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));
				cdo.setAction("I");

				cdo.setKey(iDiagPost.size()+1);

				try
				{
					//iDiagPost.put(key, cdo);
					iDiagPost.put(cdo.getKey(),cdo);
					vDiagPost.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
            
            else if (fp.equalsIgnoreCase("protocolo_cesarea_pos"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagPost",request.getParameter("nombre"+i));
				cdo.addColValue("codigo","0");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));
				cdo.setAction("I");

				cdo.setKey(iDiagPostPC.size()+1);

				try
				{
					iDiagPostPC.put(cdo.getKey(),cdo);
					vDiagPostPC.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}

			else if (fp.equalsIgnoreCase("evaluacionNutricional"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagnostico",request.getParameter("nombre"+i));
				//cdo.addColValue("observacion","");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));

				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDiagNu.put(key, cdo);
					vDiagNu.add(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}

			else if (fp.equalsIgnoreCase("ctrlFlujo"))
			{

				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("id_diag",request.getParameter("codigo"+i));
				cdo.addColValue("descDiagnostico",request.getParameter("nombre"+i));
				//cdo.addColValue("observacion","");
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));

				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iDiagFlujo.put(key, cdo);
					vDiagFlujo.add(cdo.getColValue("id_diag"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
			else if (fp.equalsIgnoreCase("citas")){
			  
			  ProcedDiagnostico det = new ProcedDiagnostico();
			  det.setKey(""+i,3);
			  det.setCodigo("0");
			  det.setStatus("N");
			  det.setDiagnostico(request.getParameter("codigo"+i));
			  det.setDiagnosticoDesc(request.getParameter("nombre"+i));
			  det.setIcdVersion(request.getParameter("icdVersion"+i));
			  try{
				diagProc.addProcedDiagnostico(det);
				vTempDiag.add(det.getDiagnostico());				
			  }catch(Exception e){
				System.out.println("Error while trying to add det to diagProc and vTempDiag ><"+det.getDiagnostico());
				e.printStackTrace();
			  }

			}
            
            
            else if (fp.equalsIgnoreCase("liq_recl"))
			{

				CommonDataObject cdo = new CommonDataObject();
                
                cdo.addColValue("diagnostico",request.getParameter("codigo"+i));
                cdo.addColValue("diagnosticoDesc",request.getParameter("nombre"+i));
				cdo.addColValue("icdVersion",request.getParameter("icdVersion"+i));
			
				diagLastLineNo++;

				String key = "";
				if (diagLastLineNo < 10) key = "00"+diagLastLineNo;
				else if (diagLastLineNo < 100) key = "0"+diagLastLineNo;
				else key = ""+diagLastLineNo;
				cdo.addColValue("key",key);
                cdo.setKey(key);
                cdo.setAction("I");

				try
				{
					iDiagLiq.put(key, cdo);
					vDiagLiq.add(cdo.getColValue("id_diag"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}  

		}// checked
	} // for
	
	if (fp.equalsIgnoreCase("citas")){
	  
	  try{
		 vProcDiag.put(diagProc.getKey(),vTempDiag);
		 iProc.put(procKey, diagProc);
	  }catch(Exception e){
		System.err.println(e.getMessage());
	  }
    }

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&code="+code+"&fg="+fg+"&noAdmision="+noAdmision+"&tab="+tab+"&cds="+cds+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&muestraLastLineNo="+muestraLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&diagPreLastLineNo="+diagPreLastLineNo+"&procLastLineNo="+procLastLineNo+"&especLastLineNo="+especLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&desc="+desc+"&id="+idEnfNofif+"&beginSearch=&codCita="+request.getParameter("codCita")+"&fechaCita="+request.getParameter("fechaCita")+"&procKey="+request.getParameter("procKey")+"&codigo="+request.getParameter("codigo")+"&icd10="+request.getParameter("icd10")+"&icdVersion="+request.getParameter("icdVersion")+"&from="+request.getParameter("from")+"&exp="+request.getParameter("exp")+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
		return;
	}


	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&code="+code+"&fg="+fg+"&noAdmision="+noAdmision+"&tab="+tab+"&cds="+cds+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&muestraLastLineNo="+muestraLastLineNo+"&medLastLineNo="+medLastLineNo+"&dietaLastLineNo="+dietaLastLineNo+"&cuidadoLastLineNo="+cuidadoLastLineNo+"&diagPreLastLineNo="+diagPreLastLineNo+"&procLastLineNo="+procLastLineNo+"&especLastLineNo="+especLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&desc="+desc+"&id="+idEnfNofif+"&beginSearch=&codCita="+request.getParameter("codCita")+"&fechaCita="+request.getParameter("fechaCita")+"&procKey="+request.getParameter("procKey")+"&codigo="+request.getParameter("codigo")+"&icd10="+request.getParameter("icd10")+"&icdVersion="+request.getParameter("icdVersion")+"&from="+request.getParameter("from")+"&exp="+request.getParameter("exp")+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
		return;
	}


%>
<html>
<head>
<script>
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("admision"))
	{
%>
	window.opener.location = '../admision/admision_config.jsp?change=1&tab=2&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&from=<%=from%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
<%
	}else if (fp.equalsIgnoreCase("admision_new"))
	{
%>
	window.opener.location = '../admision/admision_config_diag.jsp?change=1&tab=2&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&loadInfo=S&from=<%=from%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
<%
	}else if (fp.equalsIgnoreCase("informes"))
	{
%>
	window.opener.location = '../expediente/exp_evaluacion_paciente.jsp?change=1&tab=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&muestraLastLineNo=<%=muestraLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&fg=<%=fg%>&from=<%=from%>';
<%
	}else if (fp.equalsIgnoreCase("pSalida"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_diagnostico_salida.jsp?change=1&tab=0&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&medLastLineNo=<%=medLastLineNo%>&dietaLastLineNo=<%=dietaLastLineNo%>&cuidadoLastLineNo=<%=cuidadoLastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>&desc=<%=desc%>&from=<%=from%>&exp=<%=exp%>&fecha_creacion_diag=<%=fechaCreacionDiag%>&hora_creacion_diag=<%=horaCreacionDiag%>';
	<%}
	else if (fp.equalsIgnoreCase("planSalida"))
	{
	%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_plan_salida.jsp?change=1&tab=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&medLastLineNo=<%=medLastLineNo%>&dietaLastLineNo=<%=dietaLastLineNo%>&cuidadoLastLineNo=<%=cuidadoLastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>&from=<%=from%>';
	<%
	}else if (fp.equalsIgnoreCase("pIngreso"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_diagnostico_ingreso.jsp?change=1&tab=0&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&medLastLineNo=<%=medLastLineNo%>&dietaLastLineNo=<%=dietaLastLineNo%>&cuidadoLastLineNo=<%=cuidadoLastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>&desc=<%=desc%>&from=<%=from%>&exp=<%=exp%>&fecha_creacion_diag=<%=fechaCreacionDiag%>&hora_creacion_diag=<%=horaCreacionDiag%>';
	<%
	}
    else if (fp.equalsIgnoreCase("protocoloPre"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_prot_operatorio.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';
<%
	}
    else if (fp.equalsIgnoreCase("protocolo_cesarea_pre"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_protocolo_cesarea.jsp?change=1&tab=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';
<%
	}
    else if (fp.equalsIgnoreCase("protocoloPost"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_prot_operatorio.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';

	<%
	}
    else if (fp.equalsIgnoreCase("protocolo_cesarea_pos"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_protocolo_cesarea.jsp?change=1&tab=2&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';

	<%
	}
	else if (fp.equalsIgnoreCase("patologicoPre"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_historia_patologica.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';
<%
	}else if (fp.equalsIgnoreCase("patologicoPost"))
	{
%>
	window.opener.location = '../<%=exp.equals("3")?"expediente3.0":"expediente"%>/exp_historia_patologica.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&especLastLineNo=<%=especLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&from=<%=from%>';

	<%
	}
	else if (fp.equalsIgnoreCase("evaluacionNutricional"))
	{
%>
	window.opener.location = '../expediente/exp_eval_nutricional.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&diagLastLineNo=<%=diagLastLineNo%>&seccion=<%=seccion%>&code=<%=code%>&tab=<%=tab%>&from=<%=from%>';
<%
	}
	else if(fp.equalsIgnoreCase("ctrlFlujo"))
	{
%>
    window.opener.location = '../admision/enfermedad_notific_config.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=idEnfNofif%>&diagLastLineNo=<%=diagLastLineNo%>';
<%}
else if(fp.equalsIgnoreCase("citas")){%>
   window.opener.location = '../cita/edit_cita.jsp?fp=&change=1&type=&tab=1&mode=edit&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=0&equiLastLineNo=0&procKey=<%=procKey%>&from=<%=from%>';
   <%} else if (fp.equalsIgnoreCase("liq_recl")){ %>
     window.opener.location = '../planmedico/reg_diag_liq.jsp?change=1&tab=1&mode=<%=mode%>&codigo=<%=codigo%>&diagLastLineNo=<%=diagLastLineNo%>&from=<%=from%>';
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