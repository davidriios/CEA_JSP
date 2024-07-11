<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="hEmp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector" />
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
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String grupo = "";
String area = "";
String seccion = "";
String date = "";
String key = "";
String change = "";
int empLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("empLastLineNo") != null) empLastLineNo = Integer.parseInt(request.getParameter("empLastLineNo"));
if (request.getParameter("grupo") != null) grupo = request.getParameter("grupo");
if (request.getParameter("area") != null) area = request.getParameter("area");
if (request.getParameter("seccion") != null) seccion = request.getParameter("seccion");
if (request.getParameter("change") != null && !request.getParameter("change").equalsIgnoreCase("")) change = request.getParameter("change");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null || change.equalsIgnoreCase(""))
	{
		 hEmp.clear();
	 vEmp.clear();
	}

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
	String cedula ="",nombre ="";
	if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
	{
	appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
		cedula = request.getParameter("cedula");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
	appendFilter += " and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||decode(a.primer_apellido,null,'',' '||a.primer_apellido)||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}

	if (fp.equalsIgnoreCase("empleado_asistencia"))
	{
		 sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.emp_id, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.num_empleado, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||decode(a.primer_apellido,null,'',' '||a.primer_apellido)||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as nombre, a.primer_nombre, a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.apellido_casada FROM tbl_pla_empleado a, (select DISTINCT emp_id, provincia, sigla, tomo, asiento, num_empleado from tbl_pla_ct_empleado where estado = 1) b where a.emp_id=b.emp_id(+) and b.emp_id is null and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.primer_nombre,a.segundo_nombre,a.primer_apellido,a.segundo_apellido";

		 al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		 rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_empleado a, (select DISTINCT emp_id, provincia, sigla, tomo, asiento, num_empleado from tbl_pla_ct_empleado where estado = 1) b where a.emp_id=b.emp_id(+) and b.emp_id is null and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);
		 date = CmnMgr.getCurrentDate("dd/mm/yyyy");
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
document.title = 'Empleado - '+document.title;
function dateAll()
{
		var size;
	var fechaValue;

	size = parseInt(document.formEmpleado.keySize.value);
	fechaValue = document.formEmpleado.checkFecha.value;

	for (i=1; i<=size; i++)
	{
		 eval('document.formEmpleado.fecha'+i).value = fechaValue;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("seccion",seccion)%>
					<%=fb.hidden("empLastLineNo",""+empLastLineNo)%>
					<td width="50%"><cellbytelabel>C&eacute;dula</cellbytelabel>
					<%=fb.textBox("cedula","",false,false,false,40)%>
					</td>
					<td width="50%"><cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre","",false,false,false,40)%>
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
fb = new FormBean("formEmpleado",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("empLastLineNo",""+empLastLineNo)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>

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
					<td width="15%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="20%"><cellbytelabel>N&uacute;mero de Empleado</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Fecha</cellbytelabel><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="checkFecha"/>
									<jsp:param name="jsEvent" value="dateAll()"/>
									<jsp:param name="valueOfTBox1" value="<%=date%>"/>
									</jsp:include></td>
					<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los empleados listados!")%></td>
				</tr>
<%
	 String fecha = "";
	 for (int i=0; i<al.size(); i++)
	 {
			fecha = "fecha"+i;
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
				<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("num_empleado")%></td>
					<td><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>
						<jsp:param name="valueOfTBox1" value="<%=date%>"/>
						</jsp:include>
					</td>
					<td align="center"><%=(vEmp.contains(cdo.getColValue("cedula")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("cedula"),false,false)%></td>
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

</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("keySize"));
	empLastLineNo = Integer.parseInt(request.getParameter("empLastLineNo"));
	area = request.getParameter("area");
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

						cdo.setTableName("tbl_pla_ct_empleado");
			cdo.addColValue("provincia",request.getParameter("provincia"+i));
			cdo.addColValue("sigla",request.getParameter("sigla"+i));
			cdo.addColValue("tomo",request.getParameter("tomo"+i));
			cdo.addColValue("asiento",request.getParameter("asiento"+i));
			cdo.addColValue("num_empleado",request.getParameter("num_empleado"+i));
			cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("grupo",grupo);
			cdo.addColValue("cedula",request.getParameter("cedula"+i));
			cdo.addColValue("nombre",request.getParameter("nombre"+i));
			cdo.addColValue("fecha_ingreso_grupo",request.getParameter("fecha"+i));

			empLastLineNo++;

			if (empLastLineNo < 10) key = "00"+empLastLineNo;
			else if (empLastLineNo < 100) key = "0"+empLastLineNo;
			else key = ""+empLastLineNo;
			cdo.addColValue("key",key);

			try
			{
				hEmp.put(key,cdo);
				vEmp.add(cdo.getColValue("cedula"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&area="+area+"&grupo="+grupo+"&empLastLineNo="+empLastLineNo+"&change=1&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&nombre="+request.getParameter("nombre")+"&cedula="+request.getParameter("cedula")+"&seccion="+request.getParameter("seccion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&area="+area+"&grupo="+grupo+"&empLastLineNo="+empLastLineNo+"&change=1&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&nombre="+request.getParameter("nombre")+"&cedula="+request.getParameter("cedula")+"&seccion="+request.getParameter("seccion"));
		return;
	}

	al = CmnMgr.reverseRecords(hEmp);
	for (int i=0; i<hEmp.size(); i++)
	{
		key = al.get(i).toString();
		CommonDataObject cdo = (CommonDataObject) hEmp.get(key);

		cdo.setTableName("tbl_pla_ct_empleado");
		list.add(cdo);
	}
	SQLMgr.insertList(list,true,false);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("empleado_asistencia"))
	{
%>
	window.opener.location = '../rhplanilla/check_empleado.jsp?area=<%=area%>&grupo=<%=grupo%>&empLastLineNo=<%=empLastLineNo%>';
	//window.opener.redirect('13','1');
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