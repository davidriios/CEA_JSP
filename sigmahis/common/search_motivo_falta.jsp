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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

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

  if (request.getParameter("codigo") != null)
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
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

	if (fp.equalsIgnoreCase("incapacidades_empleado")||fp.equalsIgnoreCase("incapacidad")||fp.equalsIgnoreCase("ausencias_empleado")||fp.equalsIgnoreCase("permisos_empleado")||fp.equalsIgnoreCase("ausencias")||fp.equalsIgnoreCase("tardanzas")||fp.equalsIgnoreCase("ausencia_rrhh"))
	{
		if(fp.equalsIgnoreCase("ausencias")||fp.equalsIgnoreCase("ausencias_empleado")) appendFilter += "and codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'AUSENCIAS' ))";
		if(fp.equalsIgnoreCase("tardanzas")) appendFilter += "and codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'TARDANZAS' ))";   //  se agrega el 55 Problemas de Marcacion para tardanzas y 40 Correo Nesby 29/08/2013
		if(fp.equalsIgnoreCase("permisos_empleado")) appendFilter += "and codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'PERMISOS' ))";
		if(fp.equalsIgnoreCase("incapacidades_empleado")) appendFilter += "and codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'INCAPACIDAD' ))"; // se elimina el 49 correo de nesby 07/08/2012 -- Tirza se activa el codigo 39 x correo nesby 4/9/2012
		if(fp.equalsIgnoreCase("incapacidad")) appendFilter += "and codigo in (select * from table ( select split(param_value) from tbl_sec_comp_param where param_name = 'INCAPACIDAD' ))";
		sql = "SELECT codigo, descripcion, decode(permisible,'S','Si','No') as permisible, decode(permisible,'S','ND','DS') as accion, decode(permisible,'S','NO DESCONTAR','DESCONTAR') accionDesc, signos, nvl(tiempo_des, 0) tiempo_des, decode(descontar,'S','DS','ND') descontar FROM tbl_pla_motivo_falta WHERE codigo<>0 "+appendFilter;
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_motivo_falta WHERE codigo<>0 "+appendFilter);
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
document.title = 'Motivos de Faltas - '+document.title;

function returnValue(k)
{
<%
	if (fp.equalsIgnoreCase("incapacidades_empleado") && index != null)
	{
%>
		eval('window.opener.document.formIncapacidad.mfalta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.formIncapacidad.mfaltaDesc'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
				var motivo = eval('document.motivo.codigo'+k).value;
				eval('window.opener.document.formIncapacidad.estado'+<%=index%>).disabled = false;
 				if(motivo != "13") {
					eval('window.opener.document.formIncapacidad.estado'+<%=index%>).value = "DS"
					eval('window.opener.document.formIncapacidad.estadoInc'+<%=index%>).value = "DS"
					eval('window.opener.document.formIncapacidad.estado'+<%=index%>).disabled = false;

				}

				if(motivo == "13")
				{
					var tiempo = 0, horas=0, mtos=0, tiempoVal=0;
					tiempo = getDBData('<%=request.getContextPath()%>','tiempo_permitido','tbl_pla_motivo_falta','codigo='+motivo,'');
					horas =  eval('window.opener.document.formIncapacidad.tiempoHoras'+<%=index%>).value;
					mtos  =  eval('window.opener.document.formIncapacidad.tiempoMinutos'+<%=index%>).value;
					tiempoVal = Math.round((mtos/60)*100)/100;

					var compara = getDBData('<%=request.getContextPath()%>','sum('+tiempo+' - ('+horas+'+'+tiempoVal+')) compara','dual','','');
					//	eval('window.opener.document.formIncapacidad.motivo'+<%=index%>).value = compara + tiempo;
					if (compara < 0) {
					eval('window.opener.document.formIncapacidad.tiempoHoras'+<%=index%>).value = tiempo;
					eval('window.opener.document.formIncapacidad.tiempoMinutos'+<%=index%>).value = "0";
					} else {
					eval('window.opener.document.formIncapacidad.tiempoHoras'+<%=index%>).value = horas;
					eval('window.opener.document.formIncapacidad.tiempoMinutos'+<%=index%>).value = mtos;
					}
			   }


<%
    }
	else if (fp.equalsIgnoreCase("ausencias_empleado") && index != null)
	{
%>
        eval('window.opener.document.formAusencia.motivo_falta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.formAusencia.mfaltaDesc'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
		eval('window.opener.document.formAusencia.estado'+<%=index%>).value = eval('document.motivo.descontar'+k).value;
		eval('window.opener.document.formAusencia.accion'+<%=index%>).value = eval('document.motivo.descontar'+k).value;


<%
    }
	else if (fp.equalsIgnoreCase("incapacidad") && index != null)
	{
%>

    	eval('window.opener.document.form1.mfalta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.form1.descripcion'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
<%
    }

	else if (fp.equalsIgnoreCase("permisos_empleado") && index != null)
	{
%>

        	eval('window.opener.document.formPermiso.mfalta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.formPermiso.mfaltaDesc'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
		eval('window.opener.document.formPermiso.estado'+<%=index%>).value = eval('document.motivo.accion'+k).value;
	eval('window.opener.document.formPermiso.estadoDesc'+<%=index%>).value = eval('document.motivo.accionDesc'+k).value;



	 	var motivo = eval('document.motivo.codigo'+k).value;
		if(motivo == "40") {
		eval('window.opener.document.formPermiso.btnlicencia'+<%=index%>).disabled = false;
		} else
		{
		eval('window.opener.document.formPermiso.btnlicencia'+<%=index%>).disabled = true;
		eval('window.opener.document.formPermiso.motivo_lic'+<%=index%>).value = "";
		eval('window.opener.document.formPermiso.motivoLicDesc'+<%=index%>).value = "";
		}

		<%
	}
	else if (fp.equalsIgnoreCase("permisos_empleado") && index == null)
	{
%>
    	window.opener.document.formPermiso.mfalta.value = eval('document.motivo.codigo'+k).value;
	window.opener.document.formPermiso.mfaltaDesc.value = eval('document.motivo.descripcion'+k).value;
	eval('window.opener.document.formPermiso.estado').value = eval('document.motivo.accion'+k).value;
	 eval('window.opener.document.formPermiso.estadoDesc').value = eval('document.motivo.accionDesc'+k).value;



	 var motivo = eval('document.motivo.codigo'+k).value;
	 if(motivo == "40") {
	  window.opener.document.formPermiso.btnlicencia.disabled = false;
	 } else
	 {
	 window.opener.document.formPermiso.btnlicencia.disabled = true;
	 window.opener.document.formPermiso.motivo_lic.value = "";
	 window.opener.document.formPermiso.motivoLicDesc.value = "";
	 }

<%
	}
	else if (fp.equalsIgnoreCase("incapacidad") && index == null)
	{
%>
    	window.opener.document.formIncapacidad.mfalta.value = eval('document.motivo.codigo'+k).value;
	window.opener.document.formIncapacidad.mfaltaDesc.value = eval('document.motivo.descripcion'+k).value;
	eval('window.opener.document.formIncapacidad.estado').value = eval('document.motivo.accion'+k).value;


<%
	}
	else if (fp.equalsIgnoreCase("incapacidades_empleado"))
	{
%>
	window.opener.document.formIncapacidad.mfalta.value = eval('document.motivo.codigo'+k).value;
	window.opener.document.formIncapacidad.mfaltaDesc.value = eval('document.motivo.descripcion'+k).value;
<%
    }
	else if (fp.equalsIgnoreCase("ausencias_empleado"))
	{
%>
        	window.opener.document.formAusencia.mfalta.value = eval('document.motivo.codigo'+k).value;
		window.opener.document.formAusencia.mfaltaDesc.value = eval('document.motivo.descripcion'+k).value;
		window.opener.document.formAusencia.estado.value = eval('document.motivo.descontar'+k).value;
		window.opener.document.formAusencia.accion.value = eval('document.motivo.descontar'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("tardanzas"))
	{
%>
       	window.opener.document.formAusencia.mfalta.value = eval('document.motivo.codigo'+k).value;
		window.opener.document.formAusencia.mfaltaDesc.value = eval('document.motivo.descripcion'+k).value;
		window.opener.document.formAusencia.estado.value = eval('document.motivo.descontar'+k).value;
		window.opener.document.formAusencia.accion.value = eval('document.motivo.descontar'+k).value;
<%
	}
		else if (fp.equalsIgnoreCase("ausencias"))
	{
%>
    		eval('window.opener.document.formAusencia.mfalta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.formAusencia.mfaltaDesc'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
		eval('window.opener.document.formAusencia.estado'+<%=index%>).value = eval('document.motivo.descontar'+k).value;
		//eval('window.opener.document.formAusencia.accion'+<%=index%>).value = eval('document.motivo.descontar'+k).value;

<%
	}
		else if (fp.equalsIgnoreCase("ausencia_rrhh"))
	{
%>
		eval('window.opener.document.form.motivo_falta'+<%=index%>).value = eval('document.motivo.codigo'+k).value;
		eval('window.opener.document.form.motivo_falta_desc'+<%=index%>).value = eval('document.motivo.descripcion'+k).value;
		if(eval('document.motivo.tiempo_des'+k).value!='' && eval('document.motivo.tiempo_des'+k).value!='0'){ eval('window.opener.document.form.tiempo'+<%=index%>).value = eval('document.motivo.tiempo_des'+k).value;}
		window.opener.motivoFalta(<%=index%>); 
<%
	}
%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MOTIVOS DE FALTAS"></jsp:param>
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
					<td width="60%">Descripci&oacute;n</td>
					<td width="10%">Permisible</td>
					<td width="10%">Signos</td>
				</tr>
				<%
				fb = new FormBean("motivo",request.getContextPath()+"/common/urlRedirect.jsp");
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
        		<%=fb.hidden("tiempo_des"+i,cdo.getColValue("tiempo_des"))%>
        		<%=fb.hidden("accion"+i,cdo.getColValue("accion"))%>
        		<%=fb.hidden("accionDesc"+i,cdo.getColValue("accionDesc"))%>
				<%=fb.hidden("descontar"+i,cdo.getColValue("descontar"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("permisible")%></td>
					<td><%=cdo.getColValue("signos")%></td>
				</tr>
				<%
				}
				%>
				<tr class="TextPager">
					<td align="right" colspan="4">
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
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
