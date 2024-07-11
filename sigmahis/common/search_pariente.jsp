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
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500029") || SecMgr.checkAccess(session.getId(),"500030") || SecMgr.checkAccess(session.getId(),"500031") || SecMgr.checkAccess(session.getId(),"500032"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList emp = new ArrayList();
int rowCount = 0;
int total = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String empId = request.getParameter("empId");
String dateRec = CmnMgr.getCurrentDate("yyyy");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
//if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");

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

  if (request.getParameter("cedula") != null)
  {
    appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    searchOn = "a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento";
    searchVal = request.getParameter("cedula");
    searchType = "1";
    searchDisp = "Cédula";
  }
  else if (request.getParameter("nombre") != null)
  {
    appendFilter += " and upper(a.nombre||' '||a.apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "a.nombre||' '||a.apellido";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

  if (fp.equalsIgnoreCase("fallecimiento_empleado"))
  {

	 sql = "SELECT a.codigo, a.nombre||' '||a.apellido as nombre, decode(a.sexo,'M','Masculino','F','Femenino') as sexo, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, b.descripcion as parentescoDesc, a.parentesco, to_char(a.fecha_nacimiento,'yyyy') as fecha_nacimiento, a.estudia, a.trabaja, a.invalido, a.proteg_por_riesgo, a.dependiente, a.vive_con_empleado, b.ayuda_mortuoria, e.sindicato from vw_pla_empleado e, tbl_pla_pariente a, tbl_pla_parentesco b where e.emp_id = a.emp_id and e.compania = a.cod_compania and a.parentesco = b.codigo and a.emp_id = "+empId+""+appendFilter+" and a.vive = 'S' order by a.nombre, a.apellido";
	 al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
	 rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_pariente a, tbl_pla_parentesco b WHERE a.parentesco=b.codigo and a.vive = 'S' and a.emp_id = "+empId+""+appendFilter);


	 sql = "select estado from tbl_pla_empleado where compania="+(String) session.getAttribute("_companyId")+" and estado = 1 and  sindicato = 'S'";
 		emp=SQLMgr.getDataList(sql);


		total = CmnMgr.getCount("select count(*) from tbl_pla_empleado where compania="+(String) session.getAttribute("_companyId")+" and estado = 1 and  sindicato = 'S'");


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
document.title = 'Pariente - '+document.title;

function returnValue(k,p,anio)
{
	var codigo = eval('document.form1.codigo'+k).value;
	var nombre = eval('document.form1.nombre'+k).value;
	var pariente = eval('document.form1.pariente'+k).value;
	var estudia = eval('document.form1.estudia'+k).value;
	var invalido = eval('document.form1.invalido'+k).value;
	var trabaja = eval('document.form1.trabaja'+k).value;
	var protegido = eval('document.form1.riesgo'+k).value;
	var vive_con_emp = eval('document.form1.vive'+k).value;
	var ayudaMor = eval('document.form1.ayudaMor'+k).value;
	var sindicato = eval('document.form1.sindicato'+k).value;
	var edad =  anio - eval('document.form1.fechaNac'+k).value;

	<%
	if (fp.equalsIgnoreCase("fallecimiento_empleado")){
	%>

    alert('Sindicato='+sindicato+'  .. .. ..  Ayuda Mortuoria='+ayudaMor);

	window.opener.document.formFallecimiento.total_empleados.value = p;

	if(pariente == 6){
		if (edad < 18 || (edad>=18 && edad < 25 && estudia=='S')  && trabaja == 'N' && vive_con_emp == 'S')
		{
			window.opener.document.formFallecimiento.recibe_subsidio.checked = true;
			window.opener.document.formFallecimiento.valor_subsidio.readOnly = false;
			if (sindicato='S')
			{
				window.opener.document.formFallecimiento.totalDescto.value = p * 2;
				window.opener.document.formFallecimiento.descto_x_duelo.value = "S";
				window.opener.document.formFallecimiento.descto_x_duelo.checked = true;
			} else {
				window.opener.document.formFallecimiento.descto_x_duelo.value = "N";
				window.opener.document.formFallecimiento.descto_x_duelo.checked = false;
			}
		} else {
			window.opener.document.formFallecimiento.descto_x_duelo.value = "N";
			window.opener.document.formFallecimiento.descto_x_duelo.checked = false;
			alert('No tiene derecho a recibir Ayuda Mortuoria, para recibirla debe: 1) Tener 18años o menos; o hasta 25años y estar estudiando; 2) No estar trabajando; 3) Vivir con el empleado');
		}
	} else {
		if (ayudaMor == 'S')
		{
			window.opener.document.formFallecimiento.recibe_subsidio.checked = true;
			window.opener.document.formFallecimiento.valor_subsidio.readOnly = false;
			if (sindicato=='S')
			{
	  	    	window.opener.document.formFallecimiento.totalDescto.value = p * 2;
				window.opener.document.formFallecimiento.descto_x_duelo.value = "S";
				window.opener.document.formFallecimiento.descto_x_duelo.checked = true;
			} else {

				window.opener.document.formFallecimiento.descto_x_duelo.value = "N";
				window.opener.document.formFallecimiento.descto_x_duelo.checked = false;
				alert('No tiene derecho a recibir Ayuda Mortuoria porque el colaborador no pertenece a un Sindicato');
			}
		} else {
			window.opener.document.formFallecimiento.descto_x_duelo.value = "N";
			window.opener.document.formFallecimiento.descto_x_duelo.checked = false;
		}
	}

	window.opener.document.formFallecimiento.pariente.value =eval('document.form1.codigo'+k).value;
	window.opener.document.formFallecimiento.parienteDesc.value = eval('document.form1.nombre'+k).value;
	window.opener.document.formFallecimiento.parentesco.value = eval('document.form1.parentescoDesc'+k).value;
	<%
	}
	%>

    window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PARIENTES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("empId",empId)%>
					<td width="50%">
					C&eacute;dula
					<%=fb.textBox("cedula","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
<%=fb.formEnd()%>

<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("empId",empId)%>
					<td width="50%">
					Nombre
					<%=fb.textBox("nombre","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
<%=fb.formEnd()%>
			    </tr>
			</table>
		</td>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
				<tr class="TextHeader" align="center">
					<td width="20%">C&eacute;dula</td>
					<td width="45%">Nombre</td>
					<td width="10%">Sexo</td>
					<td width="25%">Parentesco</td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	int  empl= emp.size();
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("parentescoDesc"+i,cdo.getColValue("parentescoDesc"))%>
				<%=fb.hidden("pariente"+i,cdo.getColValue("parentesco"))%>
				<%=fb.hidden("fechaNac"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("estudia"+i,cdo.getColValue("estudia"))%>
				<%=fb.hidden("trabaja"+i,cdo.getColValue("trabaja"))%>
				<%=fb.hidden("invalido"+i,cdo.getColValue("invalido"))%>
				<%=fb.hidden("riesgo"+i,cdo.getColValue("proteg_por_riesgo"))%>
				<%=fb.hidden("vive"+i,cdo.getColValue("vive_con_empleado"))%>
				<%=fb.hidden("ayudaMor"+i,cdo.getColValue("ayuda_mortuoria"))%>
				<%=fb.hidden("sindicato"+i,cdo.getColValue("sindicato"))%>
				<%=fb.hidden("emp",""+total)%>


				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>,<%=total%>,<%=dateRec%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("sexo")%></td>
					<td><%=cdo.getColValue("parentescoDesc")%></td>
				</tr>
<%
}
%>
<%=fb.formEnd(true)%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
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