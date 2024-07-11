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
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String emp_id = request.getParameter("emp_id");
String fecha_final = request.getParameter("fecha_final");
String fecha_inicio = request.getParameter("fecha_inicio");
String grupo = request.getParameter("grupo");
String uf_codigo = request.getParameter("uf_codigo");
System.out.println("uf_codigo="+uf_codigo);
if(uf_codigo==null) uf_codigo = "";
if(grupo==null){
	CommonDataObject cdo = SQLMgr.getData("select codigo, descripcion from tbl_pla_ct_grupo where compania = "+(String) session.getAttribute("_companyId")+" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '"+(String) session.getAttribute("_userName")+"')");
	if(cdo==null) cdo = new CommonDataObject();
	grupo = cdo.getColValue("codigo");
}
String mode = request.getParameter("mode");
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
else if (fp.equals("emp_otros_pagos") && (fecha_final == null || fecha_inicio == null)) throw new Exception("Fechas de Inicio/Final no válidas!");
else if (fp.equals("cambio_turno") && grupo == null) throw new Exception("Grupo no válido!");
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

	String cedula = request.getParameter("cedula");
	String nombre = request.getParameter("nombre");
	if (cedula == null) cedula = "";
	if (nombre == null) nombre = "";
	if (!cedula.trim().equals("")) appendFilter += " and upper(em.provincia||'-'||em.sigla||'-'||em.tomo||'-'||em.asiento) like '%"+cedula.toUpperCase()+"%'";
	if (!nombre.trim().equals("")) appendFilter += " and upper(em.primer_nombre||decode(em.segundo_nombre,null,'',' '||em.segundo_nombre)||' '||em.primer_apellido||decode(em.segundo_apellido,null,'',' '||em.segundo_apellido)||decode(em.sexo,'F',decode(em.apellido_casada,null,'',' '||em.apellido_casada))) like '%"+nombre.toUpperCase()+"%'";
	String appendTable = "";
	if(fp.equals("emp_otros_pagos")){
	
		sql = "select ce.provincia, ce.sigla, ce.tomo, ce.asiento, ce.provincia||'-'||ce.sigla||'-'||ce.tomo||'-'||ce.asiento as cedula, ce.num_empleado, em.primer_nombre|| ' ' || decode(em.sexo, 'F', decode(em.apellido_casada, null, em.primer_apellido, decode(em.usar_apellido_casada, 'S', 'DE ' || em.apellido_casada, em.primer_apellido)), em.primer_apellido) nombre_empleado, em.estado, em.emp_id from tbl_pla_ct_empleado ce, tbl_pla_empleado em where ce.grupo = " + grupo + " and ce.compania = "+(String) session.getAttribute("_companyId")+" and to_date(to_char(ce.fecha_ingreso_grupo, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fecha_final+"', 'dd/mm/yyyy') and (ce.fecha_egreso_grupo is null or to_date(to_char(ce.fecha_egreso_grupo, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fecha_inicio+"', 'dd/mm/yyyy')) and (ce.emp_id = em.emp_id and ce.num_empleado = em.num_empleado and ce.compania = em.compania) order by em.primer_nombre || ' ' || decode (em.sexo, 'F', decode (em.apellido_casada, null, em.primer_apellido, decode (em.usar_apellido_casada, 'S', 'DE ' || em.apellido_casada, em.primer_apellido)), em.primer_apellido)"+appendFilter;
	
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_pla_ct_empleado ce, tbl_pla_empleado em where ce.grupo = " + grupo + " and ce.compania = "+(String) session.getAttribute("_companyId")+" and to_date(to_char(ce.fecha_ingreso_grupo, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fecha_final+"', 'dd/mm/yyyy') and (ce.fecha_egreso_grupo is null or to_date(to_char(ce.fecha_egreso_grupo, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fecha_inicio+"', 'dd/mm/yyyy')) and (ce.emp_id = em.emp_id and ce.num_empleado = em.num_empleado and ce.compania = em.compania)"+appendFilter+"");
	
	} else if(fp.equals("cambio_turno")){
	
		sql = "select em.emp_id, a.provincia, a.sigla, a.tomo, a.asiento, em.provincia||'-'||em.sigla||'-'||em.tomo||'-'||em.asiento as cedula, a.num_empleado, em.primer_nombre|| ' '|| decode (em.sexo,'F', decode (em.apellido_casada,null, em.primer_apellido,decode (em.usar_apellido_casada, 'S', 'DE ' || em.apellido_casada, em.primer_apellido)), em.primer_apellido) nombre_empleado from tbl_pla_ct_empleado a, tbl_pla_empleado em, tbl_pla_cargo c where em.provincia = a.provincia and em.sigla = a.sigla and em.tomo = a.tomo and em.asiento = a.asiento and em.compania = a.compania and em.num_empleado = a.num_empleado and c.codigo = em.cargo and c.compania = em.compania and a.grupo = "+grupo+" and to_char (a.ubicacion_fisica) like nvl ('"+uf_codigo+"', '%') and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= sysdate) and c.denominacion not like 'GERENTE%' and c.denominacion not like 'DIRECTOR%' and c.denominacion not like 'SUB-DIRECTOR%' and c.denominacion not like 'SUB-JEFE%' and c.denominacion not like 'VICE-PRESID%' and c.denominacion not like 'JEFE DE%' and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by em.primer_nombre|| ' '|| em.primer_apellido|| ' '|| decode (em.sexo,'F', decode (em.apellido_casada,null, em.segundo_apellido,em.apellido_casada),'M', em.segundo_apellido)";
	
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_pla_ct_empleado a, tbl_pla_empleado em, tbl_pla_cargo c where em.provincia = a.provincia and em.sigla = a.sigla and em.tomo = a.tomo and em.asiento = a.asiento and em.compania = a.compania and em.num_empleado = a.num_empleado and c.codigo = em.cargo and c.compania = em.compania and a.grupo = "+grupo+" and to_char (a.ubicacion_fisica) like nvl ('"+uf_codigo+"', '%') and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= sysdate) and c.denominacion not like 'GERENTE%' and c.denominacion not like 'DIRECTOR%' and c.denominacion not like 'SUB-DIRECTOR%' and c.denominacion not like 'SUB-JEFE%' and c.denominacion not like 'VICE-PRESID%' and c.denominacion not like 'JEFE DE%' and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter);
	} else if(fp.equals("cuadro_autorizacion")){
	
		sql = "select em.emp_id, em.num_empleado, em.provincia, em.sigla, em.tomo, em.asiento, em.provincia||'-'||em.sigla||'-'||em.tomo||'-'||em.asiento as cedula, em.primer_nombre|| ' '|| decode (em.sexo,'F', decode (em.apellido_casada,null, em.primer_apellido,decode (em.usar_apellido_casada, 'S', 'DE ' || em.apellido_casada, em.primer_apellido)), em.primer_apellido) nombre_empleado, em.primer_nombre, em.primer_apellido from tbl_pla_empleado em, tbl_pla_cargo c where c.codigo = em.cargo and c.compania = em.compania and em.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by em.primer_nombre|| ' '|| em.primer_apellido|| ' '|| decode (em.sexo,'F', decode (em.apellido_casada,null, em.segundo_apellido,em.apellido_casada),'M', em.segundo_apellido)";
	
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_pla_empleado em, tbl_pla_cargo c where c.codigo = em.cargo and c.compania = em.compania and em.compania = "+(String) session.getAttribute("_companyId")+appendFilter);
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
document.title = 'Empleados - '+document.title;

function setEmpleado(k)
{
<%
	if (fp.equalsIgnoreCase("admision_empleado_ben")){
%>
	window.opener.document.form4.poliza<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form4.certificado<%=index%>.value = eval('document.empleado.cedula'+k).value;
<%
	}
%>

		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("fp",fp)%> 
					<%=fb.hidden("index",index)%> 
					<%=fb.hidden("emp_id",emp_id)%>
          <%=fb.hidden("mode",mode)%>
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
          <%if(!fp.equals("emp_otros_pagos")){%>
          <%=fb.hidden("grupo",grupo)%>
          <%}%>
          <%if(fp.equals("emp_otros_pagos")){%>
          <td width="42"><cellbytelabel>Grupo</cellbytelabel>:
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_pla_ct_grupo where compania = "+(String) session.getAttribute("_companyId")+" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '"+(String) session.getAttribute("_userName")+"')", "grupo", grupo, false, false, 0, "text10", "", "", "", "")%>
					</td>
          <%}%>
          <td width="<%=(fp.equals("cambio_turno") || fp.equals("emp_otros_pagos")?"25":"50")%>%"> C&eacute;dula <%=fb.textBox("cedula","",false,false,false,15)%> </td>
          <td width="<%=(fp.equals("cambio_turno") || fp.equals("emp_otros_pagos")?"33":"50")%>%"> Nombre <%=fb.textBox("nombre","",false,false,false,40)%>
          <%if(fp.equals("emp_otros_pagos") || fp.equals("cuadro_autorizacion")){%>
          <%=fb.submit("go","Ir")%>
          <%}%>
           </td>
          <%if(fp.equals("cambio_turno")){%>
          <td width="42"><cellbytelabel>&Aacute;rea</cellbytelabel>:
					<%=fb.select(ConMgr.getConnection(), "select codigo, nombre descripcion from tbl_pla_ct_area_x_grupo where compania = "+(String) session.getAttribute("_companyId")+" and grupo = "+grupo+" and estado = 1", "uf_codigo", uf_codigo, false, false, 0, "text10", "", "", "", "T")%><%=fb.submit("go","Ir")%>
					</td>
          <%}%>
          <%=fb.formEnd()%> </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("emp_id",emp_id)%> 
          <%=fb.hidden("mode",mode)%>
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
					<%=fb.hidden("cedula",cedula)%> 
					<%=fb.hidden("nombre",nombre)%>
          <%=fb.hidden("grupo",grupo)%>
          <%=fb.hidden("uf_codigo",uf_codigo)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
          <%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("emp_id",emp_id)%> 
          <%=fb.hidden("mode",mode)%>
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
					<%=fb.hidden("cedula",cedula)%> 
					<%=fb.hidden("nombre",nombre)%>
          <%=fb.hidden("grupo",grupo)%>
          <%=fb.hidden("uf_codigo",uf_codigo)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="1" cellspacing="1">
        <tr>
					<%fb = new FormBean("empleados","","post","");%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fp",fp)%> 
					<%=fb.hidden("index",index)%> 
					<%=fb.hidden("emp_id",emp_id)%>
          <%=fb.hidden("mode",mode)%>
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
          <%=fb.hidden("grupo",grupo)%>
          <%=fb.hidden("uf_codigo",uf_codigo)%>
          <td colspan="4" align="right" class="TableRightBorder"><%=fb.submit("add","Aceptar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
        </tr>
        <tr class="TextHeader" align="center">
          <td width="20%"><cellbytelabel>No. Empleado</cellbytelabel></td>
          <td width="27%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
          <td width="50%"><cellbytelabel>Nombre</cellbytelabel></td>
          <td width="3%">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";

					String _key = "";
					String _empKey = cdo.getColValue("emp_id");
					if(empKey.containsKey(_empKey)) _key = (String) empKey.get(_empKey);

				%>
        <%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%> 
				<%=fb.hidden("nombre_empleado"+i,cdo.getColValue("nombre_empleado"))%> 
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%> 
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%> 
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%> 
				<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%> 
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%> 
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%> 
        <%=fb.hidden("estado"+i,cdo.getColValue("estado"))%> 
        <%if(fp.equalsIgnoreCase("cuadro_autorizacion")){
				%>
        <%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%> 
        <%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%> 
        <%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%> 
				<%
				}
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td><%=cdo.getColValue("num_empleado")%></td>
          <td><%=cdo.getColValue("cedula")%></td>
          <td><%=cdo.getColValue("nombre_empleado")%></td>
          <td>
					<%
					if (emp.containsKey(_key) && !fp.equals("cambio_turno")){
					%>
          <cellbytelabel>elegido</cellbytelabel>
          <%
					} else {
					%>
          <%=fb.checkbox("chkEmp"+i,""+i)%>
          <%
					}
					%>
          
          </td>
        </tr>
        <%
}
%>
				<%=fb.hidden("keySize", ""+al.size())%>
        <%=fb.formEnd()%>
      </table>
      <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("fp",fp)%> 
					<%=fb.hidden("index",index)%> 
					<%=fb.hidden("emp_id",emp_id)%> 
          <%=fb.hidden("mode",mode)%>
					<%=fb.hidden("cedula",cedula)%> 
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
					<%=fb.hidden("nombre",nombre)%>
          <%=fb.hidden("grupo",grupo)%>
          <%=fb.hidden("uf_codigo",uf_codigo)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
          <%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("emp_id",emp_id)%> 
          <%=fb.hidden("mode",mode)%>
          <%=fb.hidden("fecha_inicio",fecha_inicio)%>
          <%=fb.hidden("fecha_final",fecha_final)%>
					<%=fb.hidden("cedula",cedula)%> 
					<%=fb.hidden("nombre",nombre)%>
          <%=fb.hidden("grupo",grupo)%>
          <%=fb.hidden("uf_codigo",uf_codigo)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
  int lineNo = emp.size();
  String empDel = "", key = "";;
  int keySize = Integer.parseInt(request.getParameter("keySize"));
  if(fp.equalsIgnoreCase("cuadro_autorizacion")){
		for(int i=0;i<keySize;i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("provincia_empleado", request.getParameter("provincia"+i));
			cdo.addColValue("sigla_empleado", request.getParameter("sigla"+i));
			cdo.addColValue("tomo_empleado", request.getParameter("tomo"+i));
			cdo.addColValue("asiento_empleado", request.getParameter("asiento"+i));
			cdo.addColValue("cedula", request.getParameter("cedula"+i));
			cdo.addColValue("nombre", request.getParameter("nombre_empleado"+i));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("compania_empleado", (String) session.getAttribute("_companyId"));
			if(request.getParameter("primer_nombre"+i)!=null && !request.getParameter("primer_nombre"+i).equals("")) cdo.addColValue("primer_nombre", request.getParameter("primer_nombre"+i));
			if(request.getParameter("primer_apellido"+i)!=null && !request.getParameter("primer_apellido"+i).equals("")) cdo.addColValue("primer_apellido", request.getParameter("primer_apellido"+i));
			cdo.addColValue("cod_autorizacion", "0");
			if(request.getParameter("chkEmp"+i)!=null && request.getParameter("del"+i)==null){
	
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
	
				try {
					emp.put(key, cdo);
					empKey.put(cdo.getColValue("emp_id"), key);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			} else if(request.getParameter("del"+i)!=null){
				empDel = cdo.getColValue("emp_id");
				if (empKey.containsKey(empDel)){
					System.out.println("- remove item "+empDel);
					emp.remove((String) empKey.get(empDel));
					empKey.remove(empDel);
				}
			}
		}
	} else {
		for(int i=0;i<keySize;i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("provincia", request.getParameter("provincia"+i));
			cdo.addColValue("sigla", request.getParameter("sigla"+i));
			cdo.addColValue("tomo", request.getParameter("tomo"+i));
			cdo.addColValue("asiento", request.getParameter("asiento"+i));
			cdo.addColValue("num_empleado", request.getParameter("num_empleado"+i));
			cdo.addColValue("nombre_empleado", request.getParameter("nombre_empleado"+i));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			if(request.getParameter("grupo")!=null && !request.getParameter("grupo").equals("")) cdo.addColValue("grupo", request.getParameter("grupo"));
			if(request.getParameter("primer_nombre"+i)!=null && !request.getParameter("primer_nombre"+i).equals("")) cdo.addColValue("primer_nombre", request.getParameter("primer_nombre"+i));
			if(request.getParameter("primer_apellido"+i)!=null && !request.getParameter("primer_apellido"+i).equals("")) cdo.addColValue("primer_apellido", request.getParameter("primer_apellido"+i));
			if(fp.equalsIgnoreCase("cuadro_autorizacion")) cdo.addColValue("cod_autorizacion", "0");
			if(request.getParameter("chkEmp"+i)!=null && request.getParameter("del"+i)==null){
	
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
	
				try {
					emp.put(key, cdo);
					empKey.put(cdo.getColValue("emp_id"), key);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			} else if(request.getParameter("del"+i)!=null){
				empDel = cdo.getColValue("emp_id");
				if (empKey.containsKey(empDel)){
					System.out.println("- remove item "+empDel);
					emp.remove((String) empKey.get(empDel));
					empKey.remove(empDel);
				}
			}
		}
	}	
  if(request.getParameter("addCont")!=null){
    response.sendRedirect("../common/sel_empleado.jsp?mode="+mode+"&change=1&type=1&fecha_final="+fecha_final+"&fecha_inicio="+fecha_inicio+"&fp="+fp+"&grupo="+grupo+"&uf_codigo="+uf_codigo);
    return;
  }

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  <%if(fp!= null && fp.equals("emp_otros_pagos")){%>
  window.opener.location = '<%=request.getContextPath()+"/rhplanilla/reg_emp_otros_pagos_det.jsp?change=1&mode="+mode+"&fp="+fp+"&fecha_final="+fecha_final+"&fecha_inicio="+fecha_inicio%>';
  <%} else if(fp!= null && fp.equals("cambio_turno")){%>
  window.opener.location = '<%=request.getContextPath()+"/rhplanilla/reg_cambio_turno_det.jsp?change=1&mode="+mode+"&fp="+fp+"&grupo="+grupo%>';
  <%} else if(fp!= null && fp.equals("cuadro_autorizacion")){%>
  window.opener.location = '<%=request.getContextPath()+"/cxp/cuadro_autorizacion_det.jsp?change=1&mode="+mode+"&fp="+fp%>';
  <%}%>
  window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%}%>
