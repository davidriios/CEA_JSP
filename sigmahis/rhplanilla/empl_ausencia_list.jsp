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
==========================================================================================

==========================================================================================
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
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String grupo = (request.getParameter("grupo")==null?"":request.getParameter("grupo"));
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String anio = (request.getParameter("anio")==null?"":request.getParameter("anio"));
String mes = (request.getParameter("mes")==null?"":request.getParameter("mes"));
String desde = (request.getParameter("desde")==null?"":request.getParameter("desde"));
String hasta = (request.getParameter("hasta")==null?"":request.getParameter("hasta"));
String motivoFalta = (request.getParameter("motivoFalta")==null?"":request.getParameter("motivoFalta"));
String tipoLugar = (request.getParameter("tipoLugar")==null?"":request.getParameter("tipoLugar"));
String accion = (request.getParameter("accion")==null?"":request.getParameter("accion"));
String compId = (String) session.getAttribute("_companyId");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (grupo.trim().equals("")) throw new Exception("El Código del Grupo no es válido. Por favor intente nuevamente!");
	if ( !desde.trim().equals("") && !hasta.trim().equals("") ) appendFilter = " and a.fecha between to_date('"+desde+"','dd/mm/yyyy') and to_date('"+hasta+"','dd/mm/yyyy')" ;
	appendFilter += " and a.ue_codigo = "+grupo;
	if (!empId.trim().equals("")) appendFilter += " and a.emp_id = "+empId;
	if (!motivoFalta.trim().equals("")) appendFilter += " and a.mfalta = "+motivoFalta;
	if (!accion.trim().equals("")) appendFilter += " and a.estado = '"+accion+"'";

	sql.append(" SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, b.descripcion as mfaltaDesc, decode(a.estado,'ND','No Descontar','DS','Descontar', 'EL','Eliminada') as estado, a.estado as estatus, a.emp_id, a.mfalta, c.primer_nombre||' '||c.primer_apellido as nombre, nvl(a.ue_codigo,'0') grupo, a.aprobacion FROM tbl_pla_inasistencia_emp a, tbl_pla_motivo_falta b, tbl_pla_empleado c WHERE a.mfalta=b.codigo and a.mfalta <> 36 and a.compania = "+compId+appendFilter+" and a.emp_id = c.emp_id ");

	if (!anio.trim().equals("")) sql.append(" and (to_char(a.fecha,'YYYY') = "+anio+" or to_char(a.fecha_dev,'YYYY')="+anio+" ) ");
	if (mes != null && !mes.trim().equals(""))
	sql.append(" and (to_char(a.fecha,'mm') = "+mes+" or to_char(a.fecha_dev,'mm')="+mes+" ) ");
	sql.append(" and  ((aprobacion is null or aprobacion = 'N') or   aprobacion = 'S') ");
	sql.append(" order by a.fecha desc");

	al = SQLMgr.getDataList(sql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function edit(k)
{
   var empId;
   var grupo;
   var motivo;
   var desde;
   var hasta;

   empId = eval('document.formAusencia.emp_id'+k).value;
   grupo = document.formAusencia.grupo.value;
    desde = document.formAusencia.desde.value;
	 hasta = document.formAusencia.hasta.value;
   fech = eval('document.formAusencia.fech'+k).value;
   motivo = eval('document.formAusencia.mot'+k).value;
   
   
   abrir_ventana1("../rhplanilla/empl_ausencia_config.jsp?empId="+empId+"&grupo="+grupo+"&motivo="+motivo+"&fech='"+fech+"'&desde="+desde+"&hasta="+hasta+"&mode=edit");
}

function ver(k)
{
   var empId;
   var grupo;
   var motivo;

   empId = eval('document.formAusencia.emp_id'+k).value;
   grupo = document.formAusencia.grupo.value;
   fech = eval('document.formAusencia.fech'+k).value;
   motivo = eval('document.formAusencia.mot'+k).value;
   abrir_ventana1("../rhplanilla/empl_ausencia_config.jsp?empId="+empId+"&grupo="+grupo+"&motivo="+motivo+"&fech='"+fech+"'&mode=view");
}

function add(){
    var empDet;
    var grupo = document.formAusencia.grupo.value;
    if(parent.getEmpDet()){
	   empDet = parent.getEmpDet();
	}

	if (!empDet) alert("Perdona, pero usted tiene que chequear un empleado!");
	else abrir_ventana("../rhplanilla/empl_ausencias_detail.jsp?grupo="+grupo+empDet);
}

function doSearch(){
  var from = document.getElementById("fFechaIni").value;
  var to = document.getElementById("fFechaFin").value;
  var motivoFalta = document.getElementById("fMotivoFalta").value;
  var accion = document.getElementById("fAccion").value;
  document.location = "../rhplanilla/empl_ausencia_list.jsp?grupo=<%=grupo%>&empId=<%=empId%>&desde="+from+"&hasta="+to+"&accion="+accion+"&motivoFalta="+motivoFalta;
}
</script>
</head>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
	<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right" colspan="5"><authtype type='3'>[<a href="javascript:add()" class="Link00">Registrar Ausencias</a>]</authtype>&nbsp;</td>
	</tr>

	<tr class="TextFilter">
		<td colspan="5">
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="fFechaIni"/>
			<jsp:param name="valueOfTBox1" value="<%=desde%>"/>
			<jsp:param name="nameOfTBox2" value="fFechaFin"/>
			<jsp:param name="valueOfTBox2" value="<%=hasta%>"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			</jsp:include>&nbsp;&nbsp;
			Motivo&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_motivo_falta where codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'AUSENCIAS' ))","fMotivoFalta",motivoFalta,false,false,0,"Text10","width:80",null,"Motivo falta","T")%>
			&nbsp;&nbsp;
			Acci&oacute;n&nbsp;<%=fb.select("fAccion","ND=No Descontar,DS=Descontar,EL=Eliminada",accion,false,false,0,"Text10",null,null)%>&nbsp;&nbsp;
			<%=fb.button("go","Ir",false,false,null,null,"onClick=\"javascript:doSearch()\"")%></td>
		</td>
	</tr>



<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
        <% fb = new FormBean("formAusencia",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
   		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("desde",desde)%>
		<%=fb.hidden("hasta",hasta)%>

<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("fech"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("mot"+i,cdo.getColValue("mfalta"))%>


		<% if (!empId.trim().equals("") && i == 0){%>
			<tr class="TextHeader" align="center">
				<td width="15%">Ausencias de:</td>
				<td width="50%"><%=cdo.getColValue("Nombre")%></td>
				<td width="15%"></td>
				<td width="10%">Grupo : <%=cdo.getColValue("Grupo")%></td>
				<td width="10%">&nbsp;</td>
		    </tr>
		<%}%>
		<% if (i == 0){%>
			<tr class="TextHeader">
				<td width="15%">Fecha</td>
				<td width="50%">Motivo</td>
				<td width="15%">Acci&oacute;n</td>
				<td width="10%">Devoluci&oacute;n</td>
				<td width="10%">&nbsp;</td>
			</tr>
		<%}%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("Fecha")%></td>
			<td><%=cdo.getColValue("mfaltaDesc")%></td>
			<td><%=cdo.getColValue("estado")%></td>
			<td>&nbsp;</td>
			<td align="center"><%if (cdo.getColValue("estatus").trim().equals("EL")) {%><a href="javascript:ver(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a><%} else {%><a href="javascript:edit(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a><%}%></td>
		</tr>
<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    <%=fb.formEnd()%>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
