<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.StringTokenizer" %>
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
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500045") || SecMgr.checkAccess(session.getId(),"500046") || SecMgr.checkAccess(session.getId(),"500047") || SecMgr.checkAccess(session.getId(),"500048"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String status = request.getParameter("status");
String dob = request.getParameter("dob");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (status == null) status = "";
if (!status.equals("")) appendFilter = " ";
if (dob == null) dob = CmnMgr.getCurrentDate("dd/mm/yyyy");

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

  if (request.getParameter("provincia") != null && request.getParameter("sigla") != null && request.getParameter("tomo") != null && request.getParameter("asiento") != null)
  {
    appendFilter += "and upper(pac.provincia) like '"+request.getParameter("provincia").toUpperCase()+"%' and upper(pac.sigla) like '"+request.getParameter("sigla").toUpperCase()+"%' and upper(pac.tomo) like '"+request.getParameter("tomo").toUpperCase()+"%' and upper(pac.asiento) like '"+request.getParameter("asiento").toUpperCase()+"%'";
    searchOn = "pac.cedula";
    searchVal = request.getParameter("provincia")+"|"+request.getParameter("sigla")+"|"+request.getParameter("tomo")+"|"+request.getParameter("asiento");
    searchType = "1";
    searchDisp = "Cédula";
  }
  else if (request.getParameter("pasaporte") != null)
  {
		appendFilter += "and upper(pac.pasaporte) like '%"+request.getParameter("pasaporte").toUpperCase()+"%'";
    searchOn = "pac.pasaporte";
    searchVal = request.getParameter("pasaporte");
    searchType = "2";
    searchDisp = "Pasaporte";
  }
  else if (request.getParameter("nombre") != null)
  {
		appendFilter += "and upper(pac.primer_nombre||decode(pac.segundo_nombre,null,'',' '||pac.segundo_nombre)||decode(pac.primer_apellido,null,'',' '||pac.primer_apellido)||decode(pac.segundo_apellido,null,'',' '||pac.segundo_apellido)||decode(pac.sexo,'F',decode(pac.apellido_de_casada,null,'',' '||pac.apellido_de_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "pac.primer_nombre||decode(pac.segundo_nombre,null,'',' '||pac.segundo_nombre)||decode(pac.primer_apellido,null,'',' '||pac.primer_apellido)||decode(pac.segundo_apellido,null,'',' '||pac.segundo_apellido)||decode(pac.sexo,'F',decode(pac.apellido_de_casada,null,'',' '||pac.apellido_de_casada))";
    searchVal = request.getParameter("nombre");
    searchType = "2";
    searchDisp = "Nombre";
  }
  else if (request.getParameter("dob") != null)
  {
    appendFilter += "and to_char(pac.fecha_nacimiento,'dd/mm/yyyy')='"+dob+"'";
    searchOn = "pac.fecha_nacimiento";
    searchVal = dob;
    searchType = "3";
    searchDisp = "Fecha de Nacimiento";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
  	{
			if (appendFilter.equals("")) appendFilter = " where";
			else appendFilter += " and";
			StringTokenizer st = new StringTokenizer(searchVal,"|");
    	appendFilter += " upper(pac.provincia) like '"+st.nextToken().toUpperCase()+"%' and upper(pac.sigla) like '"+st.nextToken().toUpperCase()+"%' and upper(pac.tomo) like '"+st.nextToken().toUpperCase()+"%' and upper(pac.asiento) like '"+st.nextToken().toUpperCase()+"%'";
  	}
		else if (searchType.equals("2"))
		{
			if (appendFilter.equals("")) appendFilter = " ";
			else appendFilter += " and";
			appendFilter += " upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
		else if (searchType.equals("3"))
		{
			if (appendFilter.equals("")) appendFilter = " ";
			else appendFilter += " and";
			appendFilter += " to_char("+searchOn+",'dd/mm/yyyy')='"+searchVal+"'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	if (fp.equalsIgnoreCase("sol_beneficio"))
	{

		sql="select a.pac_id, a.paciente,to_char(a.FECHA_NACIMIENTO,'dd/mm/yyyy')as FECHA_NACIMIENTO, PAC.PROVINCIA||'-'||PAC.SIGLA||'-'||PAC.TOMO||'-'||PAC.ASIENTO||' -'||PAC.D_CEDULA as cedula,pac.pasaporte, a.admision, PAC.PRIMER_NOMBRE||' '||PAC.SEGUNDO_NOMBRE||' '||DECODE(PAC.APELLIDO_DE_CASADA,NULL,PAC.PRIMER_APELLIDO||' '||PAC.SEGUNDO_APELLIDO,PAC.APELLIDO_DE_CASADA)as nombre, A.EMPRESA, A.POLIZA, A.CERTIFICADO,A.tipo_poliza,a.CONVENIO, a.PLAN,a.CATEGORIA_ADMI, a.TIPO_ADMI,a.CLASIF_ADMI ,adm.categoria,cat.descripcion,B.NOMBRE as NOMBRE_EMPRESA,cds.descripcion centro, adm.dias_hospitalizados as dias_hosp FROM TBL_ADM_BENEFICIOS_X_ADMISION A,TBL_ADM_ADMISION adm,tbl_adm_paciente pac ,TBL_adm_categoria_admision cat, TBL_ADM_EMPRESA B,tBL_cds_centro_servicio cds where a.prioridad = 1 and adm.estado='A'and a.pac_id=adm.pac_id and a.pac_id=pac.pac_id and adm.categoria=cat.CODIGO and a.empresa=b.codigo and adm.centro_servicio=cds.codigo and a.admision=adm.secuencia "+appendFilter+" order by a.admision desc";
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Paciente - '+document.title;

function add()
{
	abrir_ventana2('../admision/paciente_config.jsp?fp=admision');
}

function edit(pcteId)
{
	abrir_ventana2('../admision/paciente_config.jsp?mode=edit&pcteId='+pcteId);
}

function setPaciente(k)
{
	
<%
	if (fp.equalsIgnoreCase("sol_beneficio"))
	{
%>	
		window.opener.document.form0.cod_pac.value = eval('document.paciente.codigo'+k).value;
		window.opener.document.form0.cedula.value = eval('document.paciente.cedula'+k).value;
		window.opener.document.form0.pasaporte.value = eval('document.paciente.pasaporte'+k).value;
		window.opener.document.form0.pac_id.value = eval('document.paciente.pacId'+k).value;
		window.opener.document.form0.nombre.value = eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.fecha_nacimiento.value = eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admision.value = eval('document.paciente.admision'+k).value;
		window.opener.document.form0.categoria.value = eval('document.paciente.descripcion'+k).value;
		window.opener.document.form0.diasHosp.value = eval('document.paciente.dias_hosp'+k).value;
		window.opener.document.form0.nombreEmpresa.value = eval('document.paciente.nombreEmpresa'+k).value;
		window.opener.document.form0.empresa.value = eval('document.paciente.empresa'+k).value;
		window.opener.document.form0.poliza.value = eval('document.paciente.poliza'+k).value;
		window.opener.document.form0.certificado.value = eval('document.paciente.certificado'+k).value;
		window.opener.document.form0.tipo_poliza.value = eval('document.paciente.tipo_poliza'+k).value;
		
				
	<%
	}
%>
		window.close();
}

function getMain(formx)
{
	formx.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500047"))
//{
%>
	      <!--<a href="javascript:add()" class="Link00">[ Registrar Nuevo Paciente ]</a>-->
<%
//}
%>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">		
<%
fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<td colspan="4">
						Estado
						<%=fb.select("status","A=ACTIVO",status,"T")%>
					</td>
					<%=fb.formEnd()%>
				</tr>				
				<tr class="TextFilter">		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("status","").replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
					<td width="50%">
						C&eacute;dula
						<%=fb.textBox("provincia","",false,false,false,2)%>
						<%=fb.textBox("sigla","",false,false,false,2)%>
						<%=fb.textBox("tomo","",false,false,false,4)%>
						<%=fb.textBox("asiento","",false,false,false,5)%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
							
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("status","").replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
					<td width="50%">
						Pasaporte
						<%=fb.textBox("pasaporte","",false,false,false,20)%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>				
				<tr class="TextFilter">		
					
<%
fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("status","").replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
					<td>
						Nombre
						<%=fb.textBox("nombre","",false,false,false,40)%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
					
<%
fb = new FormBean("search04",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("status","").replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
					<td>
						Fecha de Nacimiento
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="dob" />
						<jsp:param name="valueOfTBox1" value="<%=dob%>" />
						</jsp:include>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>			
				</tr>				
			</table>
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
					<%=fb.hidden("status",status).replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
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
					<%=fb.hidden("status",status).replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
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
					<td width="14%">C&eacute;dula</td>
					<td width="14%">admision</td>
					<td width="44%">Nombre</td>
					<td width="14%">Fecha Nac.</td>
					<td width="14%">Categoria</td>
				</tr>				
<%
fb = new FormBean("paciente",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%//=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("paciente"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
				<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
				<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%> 
				<%=fb.hidden("dias_hosp"+i,cdo.getColValue("dias_hosp"))%>
				<%=fb.hidden("nombreEmpresa"+i,cdo.getColValue("nombre_empresa"))%>
				<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
				<%=fb.hidden("poliza"+i,cdo.getColValue("poliza"))%> 
				<%=fb.hidden("certificado"+i,cdo.getColValue("certificado"))%>
				<%=fb.hidden("tipo_poliza"+i,cdo.getColValue("tipo_poliza"))%>
				<%=fb.hidden("plan"+i,cdo.getColValue("plan"))%>
				<%=fb.hidden("convenio"+i,cdo.getColValue("convenio"))%> 
				<%=fb.hidden("categoriaAdmi"+i,cdo.getColValue("categoria_admi"))%>
				<%=fb.hidden("tipoAdmi"+i,cdo.getColValue("tipo_admi"))%>
				<%=fb.hidden("clasifAdmi"+i,cdo.getColValue("clasif_admi"))%>
				
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setPaciente(<%=i%>)" style="text-decoration:none; cursor:pointer">
					<td><%=cdo.getColValue("cedula")%></td>
					<td align="center"><%=cdo.getColValue("admision")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
					<td align="center"><%=cdo.getColValue("descripcion")%></td>
				</tr>				
<%
}
%>							
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
					<%=fb.hidden("status",status).replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
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
					<%=fb.hidden("status",status).replace(" id=\"status\"","")%>
					<%=fb.hidden("fp",fp)%>
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