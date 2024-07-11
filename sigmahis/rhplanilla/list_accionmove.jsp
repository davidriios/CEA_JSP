
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
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
int iconHeight = 40;
int iconWidth = 40;
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String sqlTipo = "select codigo, descripcion from tbl_pla_estado_emp order by codigo";
String tipoA = request.getParameter("tipoA");
String cedula = request.getParameter("cedula");
String nombre = request.getParameter("nombre");
String ubic_seccion = request.getParameter("ubic_seccion");
String numEmpleado = request.getParameter("numEmpleado");
String empId = "";

if (codigo == null) codigo = "";
if (!codigo.equals(""))
{
	appendFilter = " and codigo="+codigo;

}

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
	
  if (request.getParameter("cedula") != null  && !request.getParameter("cedula").equals(""))
  {
    appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
  }

  if (request.getParameter("nombre") != null && !request.getParameter("nombre").equals(""))
  {
    appendFilter += " and upper(a.primer_nombre||' '||a.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
  }

  if (request.getParameter("ubic_seccion") != null && !request.getParameter("ubic_seccion").equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
  }
  if (request.getParameter("tipoA") != null && !request.getParameter("tipoA").equals(""))
  {
	    appendFilter += " and upper(a.estado) = '"+request.getParameter("tipoA")+"'";
  }
  if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").trim().equals(""))
  {
    appendFilter += " and upper(a.num_empleado) like '%"+request.getParameter("numEmpleado").toUpperCase()+"%'";
  }
  if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
  {
    appendFilter += " and upper(a.emp_id) like '%"+request.getParameter("empId").toUpperCase()+"%'";
	empId = request.getParameter("empId");
  }
	sql="select distinct a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania,  a.nombre_empleado  as nombre ,a.primer_nombre, a.primer_apellido, a.unidad_organi as seccion, b.descripcion as descripcion, d.emp_id as accion, e.descripcion as estado, f.denominacion cargo,a.num_empleado numEmpleado,a.estado status from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per d , tbl_pla_estado_emp e, tbl_pla_cargo f where a.compania = f.compania(+) and a.cargo = f.codigo(+) and a.compania = b.compania  and a.unidad_organi = b.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.compania = d.compania(+) and a.emp_id = d.emp_id(+) and a.estado = e.codigo order by a.nombre_empleado";
	/*
		sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, nvl(c.ubic_rhseccion_dest,a.ubic_seccion) as seccion, b.descripcion as descripcion from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per c where a.compania = b.compania and a.emp_id = c.emp_id(+) and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ubic_seccion, a.primer_apellido";
	*/
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

  rowCount = CmnMgr.getCount("SELECT count(*) from ("+sql+")");


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
document.title = 'Recursos Humanos - Acción de Movilidad - '+document.title;

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Acción de Ingreso';break;
		case 1:msg='Acción de Movilidad';break;
		case 2:msg='Acción de Egreso';break;
		case 3:msg='Consultar Acciones';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}

function setIndex(k)
{
	document.form0.index.value=k;
}

function goOption(option)
{
	var k=document.form0.index.value;
	var empId='';
	if(option==undefined) alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0){	
		if(k !=''){
		var status =eval('document.form0.status'+k).value;
		if(status =='3')empId=eval('document.form0.emp_id'+k).value;
		else alert('Accion permitida para Empleados Inactivos Solamente.!!!');
		}
		 abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion=1&tab=4&emp_id='+empId);}
	else
	{
		
		if(k=='')alert('Por favor seleccione una solicitud antes de ejecutar una acción!');
		else
		{
			var msg='';
			empId=eval('document.form0.emp_id'+k).value;

			if (option==1)	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=new&tipo_accion=2&mode=add&emp_id='+empId+'&tab=0');
			else if (option==2) abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&tipo_accion=3&emp_id='+empId+'&tab=3');
			else if (option==3) abrir_ventana('../rhplanilla/list_accionmove_view.jsp?fp=e&accion=2&tab=3&emp_id='+empId);

		}
	}
}




function Movilidad(tab,empId,accion)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=new&tipo_accion=2&mode=add&emp_id='+empId+'&tab='+tab);
}

function VerMovilidad(tab,empId,accion)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&tipo_accion=2&mode=view&emp_id='+empId+'&sub_tipo_accion='+accion+'&tab='+tab);
}
function Ingreso()
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion=1&tab=4');
}

function Egreso(tab,empId)
{
abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=e&tipo_accion=3&emp_id='+empId+'&tab='+tab);
}

function Ver(tab,empId)
{
abrir_ventana('../rhplanilla/list_accionmove_view.jsp?fp=e&accion=2&emp_id='+empId+'&tab='+tab);
}
function  printList()
{
abrir_ventana('../rhplanilla/print_list_accionmove.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - ACCION DE MOVILIDAD "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right" colspan="6">
			<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
			<authtype type='50'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/plus_green.gif"></a></authtype>
			<authtype type='51'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/actualizar.gif"></a></authtype>
			<authtype type='52'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/minus_red.gif"></a></authtype>
		 	<authtype type='53'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/search.gif"></a></authtype>
		 </td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(true)%>
		<tr class="TextFilter">
		<!-- ================= S E A R C H   E N G I N E S   S T A R T   H E R E   ================ -->
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="30%">Departamento:&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("ubic_seccion","",false,false,false,30,null,null,null)%>
				</td>
				<td width="70%">Estado:&nbsp;&nbsp;&nbsp;
					<%=fb.select(ConMgr.getConnection(), sqlTipo, "tipoA",tipoA,false,false,0,"",null,null,null,"T")%>
				</td>
		</tr>

		<tr class="TextFilter">
			<td>Cédula:&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("cedula","",false,false,false,30,null,null,null)%>
			</td>
			<td colspan="2">Nombre:&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
					Num Empleado<%=fb.textBox("numEmpleado","",false,false,false,10,null,null,null)%>
					ID Empleado<%=fb.intBox("empId","",false,false,false,10,null,null,null)%>
					<%=fb.submit("go","Ir")%>
			</td>
	<!-- =============   S E A R C H   E N G I N E S   E N D   H E R E   ===================== -->
	</tr>
	<%=fb.formEnd(true)%>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type="0">	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("tipoA",tipoA)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>	
				<%=fb.hidden("empId",empId)%>
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
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("tipoA",tipoA)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");	%>
<%=fb.formStart()%>
<!-- =========================   R E S U L T S   S T A R T   H E R E   ===================== -->

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
	<tr class="TextHeader" align="center">
	    <td width="3%">&nbsp;</td>
		<td width="10%">&nbsp;C&eacute;dula</td>
		<td width="22%">&nbsp;Nombre</td>
		<td width="7%">&nbsp;Num. Empleado</td>
		<td width="22%">Cargo</td>
		<td width="21%">Departamento</td>
		<td width="10%">&nbsp;Estado</td>
		<td width="5%">&nbsp;</td>
	</tr>
		<%=fb.hidden("index","")%>
   	<%	String descripcion = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				 <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				 <%=fb.hidden("status"+i,cdo.getColValue("status"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>
					<td><%=cdo.getColValue("cargo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">	&nbsp;<%=cdo.getColValue("estado")%>	</td>
					<td width="5%" align="center">
							<%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
					</td>
				</tr>
<%}%>

</table>
<%=fb.formEnd()%>

<!-- =====================   R E S U L T S   E N D   H E R E   ===================== -->

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
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("tipoA",tipoA)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>	
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
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("tipoA",tipoA)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("empId",empId)%>	
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
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
