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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");

//String sqlEstado = "select codigo, descripcion from tbl_pla_estado_emp order by codigo";

String estadoResult="", estado = "", cargo="", ubic_seccion="", cedula="", nombre="",descripcion="", rath ="", emp="";
String id = request.getParameter("id");

estado=request.getParameter("estado");

//al = SQLMgr.getDataList(sqlEstado);
//for(int i=0;i<al.size();i++){
//	CommonDataObject cd = (CommonDataObject) al.get(i);
//	estadoResult = cd.getColValue("codigo");
//	break;
//}

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

  if ((request.getParameter("cedula") != null) && (!request.getParameter("cedula").equals("")))
   {
    appendFilter += " and upper(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
   }


  if ((request.getParameter("nombre") != null) && (!request.getParameter("nombre").equals("")))
   {
    appendFilter += " and upper(b.primer_nombre||' '||b.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
   }


  if ((request.getParameter("ubic_seccion") != null) && (!request.getParameter("ubic_seccion").equals("")))
   {
    appendFilter += " and upper(b.ubic_seccion) like '%"+request.getParameter("ubic_seccion").toUpperCase()+"%'";
   }


   if ((request.getParameter("estado") != null) && (!request.getParameter("estado").equals("")))
   {
    appendFilter += " and (b.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
   }

    if ((request.getParameter("descripcions") != null) && (!request.getParameter("descripcions").equals("")))
   {
    appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("descripcions").toUpperCase()+"%'";
   }

	 if ((request.getParameter("cargo") != null) && (!request.getParameter("cargo").equals("")))
   {
    appendFilter += " and upper(c.denominacion) like '%"+request.getParameter("cargo").toUpperCase()+"%'";
   }

//	sql="SELECT DISTINCT(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) AS cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  AS nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion AS seccion, f.descripcion AS descripcion, b.emp_id AS empId, b.estado, c.denominacion, g.descripcion AS estadodesc, b.num_empleado AS numEmpleado, b.rata_hora AS rata, b.ubic_seccion AS grupo, t.emp_id AS filtro FROM TBL_PLA_EMPLEADO b, TBL_SEC_UNIDAD_EJEC f, TBL_PLA_CARGO c, TBL_PLA_ESTADO_EMP g, TBL_PLA_TRANSAC_EMP t WHERE b.compania = f.compania AND b.ubic_seccion = f.codigo AND b.compania = c.compania AND b.cargo = c.codigo AND b.estado = g.codigo AND b.emp_id = t.emp_id(+) AND b.compania = t.compania(+) AND b.compania="+(String) session.getAttribute("_companyId") +appendFilter+" UNION ALL SELECT DISTINCT(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) AS cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  AS nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion AS seccion, f.descripcion AS descripcion, b.emp_id AS empId, b.estado, c.denominacion, g.descripcion AS estadodesc, b.num_empleado AS numEmpleado, b.rata_hora AS rata, b.ubic_seccion AS grupo, t.emp_id AS filtro FROM TBL_PLA_EMPLEADO b, TBL_SEC_UNIDAD_EJEC f, TBL_PLA_CARGO c, TBL_PLA_ESTADO_EMP g, TBL_PLA_AUS_Y_TARD t WHERE b.compania = f.compania AND b.ubic_seccion = f.codigo AND b.compania = c.compania AND b.cargo = c.codigo AND b.estado = g.codigo AND b.emp_id=t.emp_id AND b.compania = t.compania(+) AND b.compania="+(String) session.getAttribute("_companyId") +appendFilter+" UNION ALL SELECT DISTINCT(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) AS cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  AS nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion AS seccion, f.descripcion AS descripcion, b.emp_id AS empId, b.estado, c.denominacion, g.descripcion AS estadodesc, b.num_empleado AS numEmpleado, b.rata_hora AS rata, b.ubic_seccion AS grupo, t.emp_id AS filtro FROM TBL_PLA_EMPLEADO b, TBL_SEC_UNIDAD_EJEC f, TBL_PLA_CARGO c, TBL_PLA_ESTADO_EMP g, TBL_PLA_T_EXTRAORDINARIO t WHERE b.compania = f.compania AND b.ubic_seccion = f.codigo AND b.compania = c.compania AND b.cargo = c.codigo AND b.estado = g.codigo AND b.emp_id=t.emp_id AND b.compania = t.compania(+) AND b.compania="+(String) session.getAttribute("_companyId") +appendFilter+"  ORDER BY seccion, primer_apellido";

sql="select DISTINCT(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) AS cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  AS nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion AS seccion, f.descripcion AS descripcion, b.emp_id AS empId, b.estado, c.denominacion, g.descripcion AS estadodesc, b.num_empleado AS numEmpleado, b.rata_hora AS rata, b.ubic_seccion AS grupo, b.emp_id AS filtro FROM TBL_PLA_EMPLEADO b, TBL_SEC_UNIDAD_EJEC f, TBL_PLA_CARGO c, TBL_PLA_ESTADO_EMP g, TBL_PLA_AUS_Y_TARD t WHERE b.compania = f.compania AND b.ubic_seccion = f.codigo AND b.compania = c.compania AND b.cargo = c.codigo AND b.estado = g.codigo AND b.emp_id=t.emp_id(+) AND b.compania = t.compania(+) AND b.compania="+(String) session.getAttribute("_companyId") +appendFilter+"  ORDER BY seccion, primer_apellido";


	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

	//	sql="select codigo, descripcion  from  tbl_sec_unidad_ejec where nivel = 3 and compania="+(String) session.getAttribute("_companyId")+" order by codigo";

	//sec = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

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
document.title = 'Planilla - Registro de Transacciones - '+document.title;
function addHoraExtra(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_sobretiempo_config.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}
function addTardanza(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_ausencia_config.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}
function addOtro(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_transac_config.jsp?mode=add&empId='+empId+'&fp=REGTRX');
}
function  printList()
{
  abrir_ventana('../rhplanilla/print_list_tipo_transaccion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - TRANSACCION - REGISTRO DE TRANSACCIONES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td width="50%">&nbsp;C&oacute;digo de Sección&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("ubic_seccion","",false,false,false,30,null,null,null)%>
			</td>

    	<td width="50%">&nbsp;<cellbytelabel>Descripci&oacute;n de la Secci&oacute;n</cellbytelabel>
				 <%=fb.textBox("descripcions","",false,false,false,30,null,null,null)%>
      </td>
  </tr>

  <tr class="TextFilter">
			<td width="50%" height="22">&nbsp;<cellbytelabel>N&uacute;mero de C&eacute;dula</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("cedula",request.getParameter("cedula"),false,false,false,30,null,null,null)%>
		</td>
			<td width="50%">&nbsp;<cellbytelabel>Nombre del Empleado</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("nombre",request.getParameter("nombre"),false,false,false,30,null,null,null)%>
			</td>
	</tr>

  <tr class="TextFilter">
    	<td width="50%">&nbsp;<cellbytelabel>Estado del Empleado</cellbytelabel>&nbsp;
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_pla_estado_emp order by codigo", "estado" ,request.getParameter("estado"), false,false,0,"T")%>
     </td>

			<td width="50%">&nbsp;<cellbytelabel>Cargo del Empleado</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("cargo","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>
      </td>
		<%=fb.formEnd()%>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800058"))
{
%>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cargo",cargo)%>
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
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cargo",cargo)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
		<tbody id="list">
  <tr class="TextHeader" align="center">
		<td width="2%">&nbsp;</td>
		<td width="9%">&nbsp;<cellbytelabel>C&eacute;dula</cellbytelabel></td>
		<td width="25%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="13%">&nbsp;<cellbytelabel>Num. Empleado</cellbytelabel></td>
		<td width="7%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
		<td width="14%">&nbsp;</td>
		<td width="13%">&nbsp;</td>
	</tr>
                <%
				descripcion = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if (!descripcion.equalsIgnoreCase(cdo.getColValue("descripcion")))
				 {
				%>
				   <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="8" class="TitulosdeTablas"> [<%=cdo.getColValue("seccion")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				  %>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>

					<%
					emp = cdo.getColValue("empId");
                 if (!emp.equalsIgnoreCase(cdo.getColValue("filtro")))
                    { %>
					<td>&nbsp;  </td>
					<% } else { %>
			<td align="center"> <cellbytelabel>Ver</cellbytelabel>&nbsp;
			     <img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rs<%=i%>','890','370','0','0','1','DIVExpandRowsScroll',true,'0','../rhplanilla/registro_transacciones_list.jsp?empId=<%=cdo.getColValue("empId")%>&id=<%=i%>',false)" style="cursor:pointer"></td>

            <%
             }
           %>

		  <td align="center">
				<authtype type='3'>	<a href="javascript:addHoraExtra('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("empId")%>','<%=cdo.getColValue("numEmpleado")%>','<%=cdo.getColValue("rata")%>','<%=cdo.getColValue("grupo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Hora Extra</cellbytelabel></a> </authtype>
				  </td>


					<td align="center">
				<authtype type='3'>	<a href="javascript:addTardanza('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("empId")%>','<%=cdo.getColValue("numEmpleado")%>','<%=cdo.getColValue("rata")%>','<%=cdo.getColValue("grupo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ausencia Y Tardanza</cellbytelabel></a> </authtype>
					</td>

					<td width="10%" align="center">
				<authtype type='3'>	<a href="javascript:addOtro('<%=cdo.getColValue("provincia")%>','<%=cdo.getColValue("sigla")%>','<%=cdo.getColValue("tomo")%>','<%=cdo.getColValue("asiento")%>','<%=cdo.getColValue("empId")%>','<%=cdo.getColValue("numEmpleado")%>','<%=cdo.getColValue("rata")%>','<%=cdo.getColValue("grupo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Otras Transacciones</cellbytelabel></a> </authtype>
				  </td>

				</tr>
                            <%
	descripcion = cdo.getColValue("descripcion");
}
%>
	 </tbody>
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
				<%=fb.hidden("ubic_seccion",ubic_seccion)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cargo",cargo)%>
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
					<%=fb.hidden("ubic_seccion",ubic_seccion)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cargo",cargo)%>
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