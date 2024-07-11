<%//@ page errorPage="../error.jsp"%>
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
==============================================================================================

==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String userName = request.getParameter("userName")==null?(String)session.getAttribute("_userName"):request.getParameter("userName");
String fDate = request.getParameter("fDate")==null?"":request.getParameter("fDate");
String tDate = request.getParameter("tDate")==null?"":request.getParameter("tDate");

String estado = "", cargo="", ubic_seccion="", numero="", cedula="", nombre="",descripcion="", rath ="", emp="";
String id = request.getParameter("id");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
boolean runQry = false;

if(request.getMethod().equalsIgnoreCase("GET"))
{
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
  
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").equals("")){
      appendFilter += " and b.nombre_empleado like '%"+request.getParameter("nombre").toUpperCase()+"%'";
      nombre = request.getParameter("nombre");
  }
  
  if (request.getParameter("numero") != null && !request.getParameter("numero").equals("")){
      appendFilter += " and b.num_empleado like '%"+request.getParameter("numero").toUpperCase()+"%'";
      numero = request.getParameter("numero");
  }
  
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").equals("")) {
	     appendFilter += " and nvl(b.cedula1, b.pasaporte) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	     cedula = request.getParameter("cedula");
  }
  
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals("")) {
      appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
      descripcion = request.getParameter("descripcion");
  }
  
  if (request.getParameter("cargo") != null && !request.getParameter("cargo").equals("")) {
       appendFilter += " and upper(c.denominacion) like '%"+request.getParameter("cargo").toUpperCase()+"%'";
       cargo = request.getParameter("cargo");
  }
  
  if (request.getParameter("fDate") != null && request.getParameter("tDate") != null && !request.getParameter("fDate").equals("") && !request.getParameter("tDate").equals("")) {
       appendFilter += " and trunc(m.fecha_marcacion) between to_date('"+request.getParameter("fDate")+"','dd/mm/yyyy') and to_date('"+request.getParameter("tDate")+"','dd/mm/yyyy') ";
       fDate = request.getParameter("fDate");
       tDate = request.getParameter("tDate");
       runQry = true;
  } else {
       fDate =  cDate;
       tDate = cDate;
  }
  
	sql="select to_char(m.fecha_marcacion, 'dd/mm/yyyy') fm, to_char(m.fecha_marcacion, 'hh:mi:ss am') hm , m.tipo_marcacion, m.ip, decode(m.tipo_marcacion,1,'Entrada',2,'Salida Almuerzo',3,'Entrada Almuerzo',4,'Salida') tipo_marcacion_desc, b.nombre_empleado, b.cedula1, b.num_empleado from tbl_pla_temp_marcacion m, vw_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c where m.emp_id = b.emp_id and m.compania = b.compania and b.compania = f.compania AND  b.ubic_seccion = f.codigo AND   b.compania = c.compania AND b.cargo = c.codigo and b.compania ="+(String) session.getAttribute("_companyId")+appendFilter+" order by m.fecha_marcacion ";
	
	if (runQry) {
    al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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
<script>
document.title = 'Planilla - Registro de Transacciones Ausencias y Tardanzas - '+document.title;

function addNew(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_tran_list.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}

function add(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_asistencia.jsp?fp=ausencia&emp_id='+empId);
}

function  printList()
{
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/print_fg_marcacion_list.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&pCtrlHeader=true');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - TRANSACCION - REGISTRO DE AUSENCIAS Y TARDANZAS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("beginSearch","")%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			
			
			
	<tr class="TextFilter">
    <td>
        <cellbytelabel>Fecha</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
        <jsp:param name="clearOption" value="true"/>
				</jsp:include>
				
				&nbsp;Nombre del Empleado&nbsp;
				<%=fb.textBox("nombre",nombre,false,false,false,20,null,null,null)%>
				&nbsp;#Empleado&nbsp;
				<%=fb.textBox("numero",numero,false,false,false,5,null,null,null)%>
				
				&nbsp;Cédula&nbsp;
				<%=fb.textBox("cedula",cedula,false,false,false,10,null,null,null)%> <br>
				Descripción de la Secci&oacute;n
				<%=fb.textBox("descripcion", descripcion,false,false,false,30,null,null,null)%>
				&nbsp;Descripción del Cargo &nbsp;
				<%=fb.textBox("cargo",cargo,false,false,false,30,null,null,null)%>
				
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.submit("go","Ir")%>
    </td>
 	<%=fb.formEnd()%>  </tr>

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800058"))
{
%>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir ]</a></authtype>
<%
}
%>
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
				<%=fb.hidden("userName",userName)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("numero",""+numero)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("cargo",""+cargo)%>
				<%=fb.hidden("fDate",""+fDate)%>
				<%=fb.hidden("tDate",""+tDate)%>
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
					<%=fb.hidden("userName",userName)%>
					<%=fb.hidden("beginSearch","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("numero",""+numero)%>
					<%=fb.hidden("cedula",""+cedula)%>
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("estado",""+estado)%>
					<%=fb.hidden("cargo",""+cargo)%>
					<%=fb.hidden("fDate",""+fDate)%>
					<%=fb.hidden("tDate",""+tDate)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder"><%fb = new FormBean("form01",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%=fb.formStart()%>

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
		<tbody id="list">
  <tr class="TextHeader" align="center">
		<td width="10%">&nbsp;C&eacute;dula</td>
		<td width="33%">&nbsp;Nombre</td>
		<td width="12%">&nbsp;#Emp.</td>
		<td width="10%">&nbsp;F.Marcación</td>
		<td width="10%">&nbsp;H.Marcación</td>
		<td width="12%">&nbsp;Marcación</td>
		<td width="13%">IP</td>
	</tr>
        <%
			descripcion = "";
			emp ="";
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
				%>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("cedula1")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre_empleado")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("num_empleado")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fm")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("hm")%></td>
					<td>&nbsp;<%=cdo.getColValue("tipo_marcacion_desc")%></td>
					<td align="center"><%=cdo.getColValue("ip")%></td>
				</tr>
          <%}%>
	 </tbody>
</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
<%=fb.formEnd()%> </td>
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
				<%=fb.hidden("userName",""+userName)%>
				<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("numero",""+numero)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("cargo",""+cargo)%>
			    <%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",""+fDate)%>
				<%=fb.hidden("tDate",""+tDate)%>
-      	
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
					<%=fb.hidden("ubic_seccion",""+ubic_seccion)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("numero",""+numero)%>
					<%=fb.hidden("cedula",""+cedula)%>
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("estado",""+estado)%>
					<%=fb.hidden("cargo",""+cargo)%>
					<%=fb.hidden("userName",""+userName)%>
					<%=fb.hidden("beginSearch","")%>
					<%=fb.hidden("fDate",""+fDate)%>
					<%=fb.hidden("tDate",""+tDate)%>
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
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
	