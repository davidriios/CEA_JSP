<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector"/>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCols = new StringBuffer();
StringBuffer sbTables = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String stype = request.getParameter("stype");//selection type: null or blank = one, cb = multiple
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String ct = request.getParameter("ct");
String idx = request.getParameter("idx");

if (stype == null) stype = "";
if (fp == null) fp = "";
if (fp.trim().equals("")) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (grupo == null) grupo = "";
if (area == null) area = "";
if (ct == null) ct = "";
if (idx == null) idx = "";

String ubic = request.getParameter("ubic");
String empId = request.getParameter("empId");
String numEmpleado = request.getParameter("numEmpleado");
String cedula = request.getParameter("cedula");
String nombre = request.getParameter("nombre");
if (ubic == null) ubic = "";
if (empId == null) empId = "";
if (numEmpleado == null) numEmpleado = "";
if (cedula == null) cedula = "";
if (nombre == null) nombre = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null) {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	sbTables.append("tbl_pla_ct_empleado a, vw_pla_empleado b, tbl_pla_cargo c");
	if (!ubic.trim().equals("")) { sbFilter.append(" and a.ubicacion_fisica = "); sbFilter.append(ubic); }
	if (!empId.trim().equals("")) { sbFilter.append(" and a.emp_id = "); sbFilter.append(empId); }
	if (!numEmpleado.trim().equals("")) { sbFilter.append(" and upper(a.num_empleado) like '%"); sbFilter.append(numEmpleado.toUpperCase()); sbFilter.append("%'"); }
	if (!cedula.trim().equals("")) { sbFilter.append(" and a.provincia||'-'||upper(a.sigla)||'-'||a.tomo||'-'||a.asiento like '%"); sbFilter.append(cedula.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(b.primer_nombre||' '||case when b.sexo = 'F' and b.apellido_casada is not null and b.usar_apellido_casada = 'S' then 'DE '||b.apellido_casada else b.primer_apellido end) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	//if (request.getParameter("empId") != null)
	{
		sbSql = new StringBuffer();
		sbSql.append("select a.emp_id, a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, b.cedula1 as cedula, b.nombre_empleado nombre");
		sbSql.append(sbCols);
		sbSql.append(" from ");
		sbSql.append(sbTables);
		sbSql.append(" where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.grupo = ");
		sbSql.append(grupo);
		sbSql.append(sbFilter);
		sbSql.append(" and a.emp_id = b.emp_id and b.cargo = c.codigo and b.compania = c.compania and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= sysdate) and c.denominacion not like 'GERENTE%' and c.denominacion not like 'DIRECTOR%' and c.denominacion not like 'SUB-DIRECTOR%' and c.denominacion not like 'SUB-JEFE%' and c.denominacion not like 'VICE-PRESID%' and c.denominacion not like 'JEFE%'");
		sbSql.append(" order by 7");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from "+sbTables+" where a.compania = "+session.getAttribute("_companyId")+" and a.grupo = "+grupo+sbFilter+" and a.emp_id = b.emp_id and b.cargo = c.codigo and b.compania = c.compania and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= sysdate) and c.denominacion not like 'GERENTE%' and c.denominacion not like 'DIRECTOR%' and c.denominacion not like 'SUB-DIRECTOR%' and c.denominacion not like 'SUB-JEFE%' and c.denominacion not like 'VICE-PRESID%' and c.denominacion not like 'JEFE%'");
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
document.title = 'Empleado - '+document.title;
function doAction(){}
function setValues(k){
	document.ctEmpleado.sIdx.value=k;
	var empId=eval('document.ctEmpleado.emp_id'+k).value;
	var provincia=eval('document.ctEmpleado.provincia'+k).value;
	var sigla=eval('document.ctEmpleado.sigla'+k).value;
	var tomo=eval('document.ctEmpleado.tomo'+k).value;
	var asiento=eval('document.ctEmpleado.asiento'+k).value;
	var numEmpleado=eval('document.ctEmpleado.num_empleado'+k).value;
	var cedula=eval('document.ctEmpleado.cedula'+k).value;
	var nombre=eval('document.ctEmpleado.nombre'+k).value;
	<% if (fp.equalsIgnoreCase("cambio_turno")) { %>
	window.opener.document.form0.emp_id.value=empId;
	window.opener.document.form0.provincia.value=provincia;
	window.opener.document.form0.sigla.value=sigla;
	window.opener.document.form0.tomo.value=tomo;
	window.opener.document.form0.asiento.value=asiento;
	window.opener.document.form0.num_empleado.value=numEmpleado;
	window.opener.document.form0.nombre.value=nombre;
	document.ctEmpleado.submit();
	<% } else if (fp.equalsIgnoreCase("permiso")) { %>
	window.opener.document.formPermiso.empId.value=empId;
	window.opener.document.formPermiso.provincia.value=provincia;
	window.opener.document.formPermiso.sigla.value=sigla;
	window.opener.document.formPermiso.tomo.value=tomo;
	window.opener.document.formPermiso.asiento.value=asiento;
	window.opener.document.formPermiso.numEmpleado.value=numEmpleado;
	window.opener.document.formPermiso.num_empleado.value=numEmpleado;
	window.opener.document.formPermiso.nombreEmpleado.value=nombre;
	window.opener.document.formPermiso.cedula.value=cedula;
	document.ctEmpleado.submit();
	<% } else if (fp.equalsIgnoreCase("incapacidad")) { %>
	window.opener.document.formIncapacidad.empId.value=empId;
	window.opener.document.formIncapacidad.provincia.value=provincia;
	window.opener.document.formIncapacidad.sigla.value=sigla;
	window.opener.document.formIncapacidad.tomo.value=tomo;
	window.opener.document.formIncapacidad.asiento.value=asiento;
	window.opener.document.formIncapacidad.numEmpleado.value=numEmpleado;
	window.opener.document.formIncapacidad.nombreEmpleado.value=nombre;
	window.opener.document.formIncapacidad.cedula.value=cedula;
	document.ctEmpleado.submit();
	<% }%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("stype",stype)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("ct",ct)%>
<%=fb.hidden("idx",idx)%>
		<tr class="TextFilter">
			<td>
				Area
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_pla_ct_area_x_grupo where grupo = "+grupo+" and compania = "+session.getAttribute("_companyId"),"ubic",ubic,false,false,0,"Text10",null,null,null,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				Empl. ID
				<%=fb.intBox("empId","",false,false,false,10,10,"Text10","","")%>
				No. Empl.
				<%=fb.textBox("numEmpleado","",false,false,false,15,15,"Text10","","")%>
				C&eacute;dula
				<%=fb.textBox("cedula","",false,false,false,15,15,"Text10","","")%>
				Nombre
				<%=fb.textBox("nombre","",false,false,false,40,50,"Text10","","")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("ctEmpleado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+(nxtVal))%>
<%=fb.hidden("previousVal",""+(preVal))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("stype",stype)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("ct",ct)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("ubic",ubic)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("sIdx","")%>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
<% if (stype.equalsIgnoreCase("cb")) { %>
		<tr class="TextPager">
			<td align="right" colspan="4">
				<%=fb.submit("saveT","Agregar",true,false)%>
				<%=fb.submit("continueT","Agregar y Continuar",true,false)%>
			</td>
		</tr>
<% } %>
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">Empl. ID</td>
			<td width="10%">No. Empl.</td>
			<td width="20%">C&eacute;dula</td>
			<td width="57%">Nombre</td>
			<td width="3%"><%=(stype.equalsIgnoreCase("cb"))?fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll(this.form,'check',"+al.size()+",this)\"","Seleccionar todos los empleados listados!"):""%></td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="5" class="TextRow01" align="center"><font color="#FF0000">
			<% if (request.getParameter("empId") == null) { %>
			I N T R O D U Z C A &nbsp; P A R A M E T R O S &nbsp; P A R A &nbsp; B U S Q U E D A
			<% } else { %>
			R E G I S T R O ( S ) &nbsp; N O &nbsp; E N C O N T R A D O ( S )
			<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	StringBuffer sbRowEvent = new StringBuffer();
	if (!stype.equalsIgnoreCase("cb")) {
		sbRowEvent.append(" onClick=\"javascript:setValues(");//"
		sbRowEvent.append(i);
		sbRowEvent.append(")\"");//"
		sbRowEvent.append(" style=\"cursor:pointer\"");
	}
%>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
		<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center"<%=sbRowEvent%>>
			<td><%=cdo.getColValue("emp_id")%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td><%=cdo.getColValue("provincia")%>-<%=cdo.getColValue("sigla")%>-<%=cdo.getColValue("tomo")%>-<%=cdo.getColValue("asiento")%></td>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<td align="center"><% if (stype.equalsIgnoreCase("cb")) { %><%=fb.checkbox("check"+i,cdo.getColValue("emp_id"),false,false,null,null,null)%><% } else { %>&nbsp;<% } %></td>
		</tr>
<% } %>
		</table>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
<% if (stype.equalsIgnoreCase("cb")) { %>
		<tr class="TextPager">
			<td align="right" colspan="4">
				<%=fb.submit("saveB","Agregar",true,false)%>
				<%=fb.submit("continueB","Agregar y Continuar",true,false)%>
			</td>
		</tr>
<% } %>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	if (stype.equalsIgnoreCase("cb")) {
		int size = Integer.parseInt(request.getParameter("size"));
		for (int i=0; i<size; i++) {
			if (request.getParameter("check"+i) != null) {
				CommonDataObject cdo = new CommonDataObject();
				cdo.setKey(iEmp.size() + 1);
				cdo.setAction("I");
				cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
				cdo.addColValue("provincia",request.getParameter("provincia"+i));
				cdo.addColValue("sigla",request.getParameter("sigla"+i));
				cdo.addColValue("tomo",request.getParameter("tomo"+i));
				cdo.addColValue("asiento",request.getParameter("asiento"+i));
				cdo.addColValue("num_empleado",request.getParameter("num_empleado"+i));
				cdo.addColValue("nombre_empleado",request.getParameter("nombre"+i));
				cdo.addColValue("fecha_tasignado","");
				cdo.addColValue("secuencia","0");
				try {
					iEmp.put(cdo.getKey(),cdo);
					vEmp.add(cdo.getColValue("emp_id"));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}// checked
		}
	} else {
		String sIdx = request.getParameter("sIdx");
		iEmp.clear();
		vEmp.clear();
		CommonDataObject cdo = new CommonDataObject();
		cdo.setKey(iEmp.size() + 1);
		cdo.setAction("I");
		cdo.addColValue("emp_id",request.getParameter("emp_id"+sIdx));
		cdo.addColValue("provincia",request.getParameter("provincia"+sIdx));
		cdo.addColValue("sigla",request.getParameter("sigla"+sIdx));
		cdo.addColValue("tomo",request.getParameter("tomo"+sIdx));
		cdo.addColValue("asiento",request.getParameter("asiento"+sIdx));
		cdo.addColValue("num_empleado",request.getParameter("num_empleado"+sIdx));
		cdo.addColValue("nombre_empleado",request.getParameter("nombre"+sIdx));
		cdo.addColValue("fecha_tasignado","");
		cdo.addColValue("secuencia","0");
		try {
			iEmp.put(cdo.getKey(),cdo);
			vEmp.add(cdo.getColValue("emp_id"));
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?stype="+stype+"&fp="+fp+"&mode="+mode+"&anio="+anio+"&mes="+mes+"&grupo="+grupo+"&area="+area+"&ct="+ct+"&idx="+idx+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&ubic="+ubic+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre);
		return;
	} else if (request.getParameter("nextT") != null || request.getParameter("nextB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?stype="+stype+"&fp="+fp+"&mode="+mode+"&anio="+anio+"&mes="+mes+"&grupo="+grupo+"&area="+area+"&ct="+ct+"&idx="+idx+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&ubic="+ubic+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre);
		return;
	} else if (request.getParameter("continueT") != null || request.getParameter("continueB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?stype="+stype+"&fp="+fp+"&mode="+mode+"&anio="+anio+"&mes="+mes+"&grupo="+grupo+"&area="+area+"&ct="+ct+"&idx="+idx+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&ubic="+ubic+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (fp.equalsIgnoreCase("cambio_turno")) { %>
window.opener<%=(stype.equalsIgnoreCase("cb"))?"":".frames['itemFrame']"%>.location='../rhplanilla/reg_cambio_turno_det.jsp?change=1&mode=<%=mode%>&grupo=<%=grupo%>&area=<%=area%>&anio=<%=anio%>&mes=<%=mes%>&codigo=<%=ct%>';
<% } %>
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