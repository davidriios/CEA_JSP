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
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String cds = request.getParameter("cds");
if (cds == null) cds = "";
String compania = (String) session.getAttribute("_companyId");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fp.equalsIgnoreCase("ENTREGA_TURNO") && cds.trim().equals("")) throw new Exception("Area invalida. Por favor intente nuevamente!");


if (request.getMethod().equalsIgnoreCase("GET"))
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

  if (request.getParameter("codigo") != null )
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		if(fp.equals("programa_turno_borrador")) appendFilter = " where upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
   
		if(fp.equals("programa_turno_borrador") && appendFilter.equals("")) appendFilter = " where upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		else if(fp.equals("programa_turno_borrador") && !appendFilter.equals("")) appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
     appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripcion";
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

	if (fp.equalsIgnoreCase("empleado_programa")) {
		sql = "SELECT to_char(codigo) codigo, descripcion FROM tbl_pla_ct_turno WHERE compania = "+(String) session.getAttribute("_companyId")+" and codigo<>0 "+appendFilter+" union select 'A' codigo,'Ausencia' descripcion from dual union select 'LC' codigo,'Libre Compensatorio' descripcion from dual union select 'LS' codigo,'Libre Semana' descripcion from dual union select 'N' codigo,'Nacional' descripcion from dual union select 'PC' codigo,'Permiso con Sueldo' descripcion from dual union select 'PS' codigo,'Permiso sin Sueldo' descripcion from dual union select 'HD' codigo,'Horas de Descanso' descripcion from dual union select 'I' codigo,'Incapacidad' descripcion from dual union select 'LG' codigo,'Licencia por Gravidez' descripcion from dual union select 'V' codigo,'Vacaciones' descripcion from dual union select 'RP' codigo,'Riesgos Profesionales' descripcion from dual";
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	} else if (fp.equalsIgnoreCase("cambios_empleado"))	{
		sql = "SELECT codigo, descripcion FROM tbl_pla_ct_turno WHERE codigo<>0 "+appendFilter;
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_ct_turno WHERE codigo<>0 "+appendFilter);
	}	else if (fp.equalsIgnoreCase("cambio_turno")){
		sql = "select codigo, descripcion from (select to_char(codigo) codigo, descripcion from tbl_pla_ct_turno where compania = "+(String) session.getAttribute("_companyId")+" union select 'A' codigo,'Ausencia' descripcion from dual union select 'LC' codigo,'Libre Compensatorio' descripcion from dual union select 'LS' codigo,'Libre Semana' descripcion from dual union select 'N' codigo,'Nacional' descripcion from dual union select 'PC' codigo,'Permiso con Sueldo' descripcion from dual union select 'PS' codigo,'Permiso sin Sueldo' descripcion from dual union select 'HD' codigo,'Horas de Descanso' descripcion from dual union select 'I' codigo,'Incapacidad' descripcion from dual union select 'LG' codigo,'Licencia por Gravidez' descripcion from dual union select 'V' codigo,'Vacaciones' descripcion from dual union select 'RP' codigo,'Riesgos Profesionales' descripcion from dual) a where a.codigo is not null "+appendFilter;
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}	else if (fp.equalsIgnoreCase("programa_turno_borrador")){
		sql = "select * from (select to_char (hora_entrada, 'hh:mi am') hora_entrada, to_char(hora_salida, 'hh:mi am') hora_salida, to_char(codigo) codigo, to_char(hora_entrada, 'hh:mi') || decode(hora_rec_salida, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_rec_salida, 'hh:mi') || ' / ' || to_char (hora_rec_entrada, 'hh:mi') || '-' || to_char(hora_salida, 'hh:mi am')) descripcion, to_char(hora_entrada, 'hh:mi am') || decode(hora_rec_salida, null, ' / ' || to_char(hora_salida, 'hh:mi am'), '-' || to_char(hora_rec_salida, 'hh:mi am') || ' / ' || to_char (hora_rec_entrada, 'hh:mi am') || '-' || to_char(hora_salida, 'hh:mi am')) descripcion1, to_char(hora_entrada, 'am')||'-'||to_char(hora_salida, 'am') tipo, to_char(hora_entrada, 'hh:mi') || ' / ' || to_char(hora_salida, 'hh:mi') entrada_salida from tbl_pla_ct_turno where compania = "+(String) session.getAttribute("_companyId")+" union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'A' codigo, 'Ausencia' descripcion, 'Ausencia' descripcion1, 'XX-XX' tipo, 'Ausencia' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'LC' codigo, 'Libre Compensatorio' descripcion, 'Libre Compensatorio' descripcion1, 'XX-XX' tipo, 'Libre Compensatorio' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'LS' codigo, 'Libre Semanal' descripcion, 'Libre Semanal' descripcion1, 'XX-XX' tipo, 'Libre Semanal' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'N' codigo, 'Nacional' descripcion, 'Nacional' descripcion1, 'XX-XX' tipo, 'Nacional' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'PC' codigo, 'Permiso con Sueldo' descripcion, 'Permiso con Sueldo' descripcion1, 'XX-XX' tipo, 'Permiso con Sueldo' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'PS' codigo, 'Permiso sin Sueldo' descripcion, 'Permiso sin Sueldo' descripcion1, 'XX-XX' tipo, 'Permiso sin Sueldo' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'HD' codigo, 'Horas de Descanso' descripcion, 'Horas de Descanso' descripcion1, 'XX-XX' tipo, 'Horas de Descanso' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'I' codigo, 'Incapacidad' descripcion, 'Incapacidad' descripcion1, 'XX-XX' tipo, 'Incapacidad' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'LG' codigo, 'Licencia por Gravidez' descripcion, 'Licencia por Gravidez' descripcion1, 'XX-XX' tipo, 'Licencia por Gravidez' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'V' codigo, 'Vacaciones' descripcion, 'Vacaciones' descripcion1, 'XX-XX' tipo, 'Vacaciones' from dual union select '00:00 PM' hora_entrada, '00:00 PM' hora_salida, 'RP' codigo, 'Riesgos Profesionales' descripcion, 'Riesgos Profesionales' descripcion1, 'XX-XX' tipo, 'Riesgos Profesionales' from dual order by hora_entrada desc, hora_salida desc)" +appendFilter;
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	}
	else if (fp.equalsIgnoreCase("ENTREGA_TURNO")) {
		sql = "SELECT to_char(codigo) codigo, descripcion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_turno, to_char(fecha_creacion,'hh12:mi:ss am') hora_turno FROM tbl_pla_ct_turno WHERE compania = "+(String) session.getAttribute("_companyId")+" and codigo<>0 "+appendFilter+" ";
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
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
<script language="javascript">
document.title = 'Turnos - '+document.title;

function setTurno(i)
{
<%
	if (fp.equalsIgnoreCase("empleado_programa"))
	{
%>
		window.opener.document.formTurno.codTurno.value = eval('document.formTurno.codigo'+i).value;
		window.opener.document.formTurno.turnoDesc.value = eval('document.formTurno.descripcion'+i).value;
<%
    }
	else if (fp.equalsIgnoreCase("cambios_empleado"))
	{
%>
      window.opener.document.formCambio.codTurno.value = eval('document.formTurno.codigo'+i).value;
	  window.opener.document.formCambio.turnoDesc.value = eval('document.formTurno.descripcion'+i).value;
<%}
	else if (fp.equalsIgnoreCase("cambio_turno"))
	{
%>
	
		window.opener.document.form0.turno_nuevo<%=index%>.value=eval('document.formTurno.codigo'+i).value;
	  window.opener.document.form0.turno_nuevo_desc<%=index%>.value=eval('document.formTurno.descripcion'+i).value;
		window.opener.document.form0.tn_programado<%=index%>.value='S';
			/*
			window.opener.document.form.turno_nuevo<%=index%>.value=eval('document.formTurno.codigo'+i).value;
	  window.opener.document.form.turno_nuevo_desc<%=index%>.value=eval('document.formTurno.descripcion'+i).value;
		window.opener.document.form.tn_programado<%=index%>.value='S';
		*/
		
<%
    }
	else if (fp.equalsIgnoreCase("programa_turno_borrador"))
	{
%>	var name = '<%=index%>';
		eval('window.opener.document.form.'+name).value = eval('document.formTurno.descripcion'+i).value;
	  eval('window.opener.document.form.'+name.replace("dsp_","")).value = eval('document.formTurno.codigo'+i).value;
<%
    }else if (fp.equalsIgnoreCase("ENTREGA_TURNO")){%>
	   window.opener.document.form1.id_turno.value = eval('document.formTurno.codigo'+i).value;
	   window.opener.document.form1.desc_turno.value = eval('document.formTurno.descripcion'+i).value;
	   if(!window.opener.document.form1.fecha_turno.value) window.opener.document.form1.fecha_turno.value = eval('document.formTurno.fecha_turno'+i).value;
	   window.opener.document.form1.hora_turno.value = eval('document.formTurno.hora_turno'+i).value;
	   window.opener.document.form1.censo.value = getDBData('<%=request.getContextPath()%>','count(*) as cantidad','tbl_adm_admision a, vw_adm_paciente b, tbl_adm_atencion_cu d, (select pac_id, secuencia, adm_root, estado, categoria, fecha_ingreso, fecha_egreso from tbl_adm_admision where (pac_id, secuencia) in (select pac_id, max(secuencia) from tbl_adm_admision where corte_cta is not null and estado in (\'A\',\'E\',\'I\')  and compania=<%=compania%> group by pac_id, adm_root)) y'," a.compania=<%=compania%> and decode(y.adm_root,null,a.estado,y.estado) in ('A','E') and d.estado in ('E','T','P','F','R') and d.cds =<%=cds%> and a.pac_id=b.pac_id and a.pac_id=d.pac_id and a.secuencia=d.secuencia and a.pac_id=y.pac_id(+) and a.secuencia=y.adm_root(+) ",'');
	<%}%>
	window.close();
}




</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TURNOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cds",cds)%>
					<td width="50%">C&oacute;digo
					<%=fb.textBox("codigo","",false,false,false,40)%>
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
					<%=fb.hidden("cds",cds)%>
					<td width="50%">Descripci&oacute;n
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>

				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
					<%=fb.hidden("cds",cds)%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cds",cds)%>
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

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%">C&oacute;digo</td>
					<td width="80%">Descripci&oacute;n</td>
				</tr>
				<%
				fb = new FormBean("formTurno",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("fecha_turno"+i,cdo.getColValue("fecha_turno"))%>
				<%=fb.hidden("hora_turno"+i,cdo.getColValue("hora_turno"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setTurno(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
				<% if (fp.equalsIgnoreCase("programa_turno_borrador")) 
				{
				%>
					
					<td><%=cdo.getColValue("descripcion1")%></td>
					<% } else { %>
					<td><%=cdo.getColValue("descripcion")%></td>
					<% } %>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("cds",cds)%>
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
					<%=fb.hidden("cds",cds)%>
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
