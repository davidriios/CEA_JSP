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
CommonDataObject cdoN = new CommonDataObject();

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String empId = request.getParameter("empId");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String sw = "S";
String compania = (String) session.getAttribute("_companyId");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
	if (grupo == null) throw new Exception("El Código del Grupo no es válido. Por favor intente nuevamente!");


  if (desde==null)
  {
	sql = "select to_char(trans_desde,'dd/mm/yyyy') trans_desde, to_char(trans_hasta,'dd/mm/yyyy') trans_hasta, periodo from tbl_pla_calendario where tipopla = 1 and trunc(sysdate) BETWEEN trunc(fecha_inicial) AND trunc(fecha_final)";
	cdoN = SQLMgr.getData(sql);

	if(cdoN==null) cdoN = new CommonDataObject();
		desde = cdoN.getColValue("trans_desde");
		hasta = cdoN.getColValue("trans_hasta");
	}
  if (desde!=null) appendFilter += " and trunc(a.fecha) BETWEEN to_date('"+desde+"','dd/mm/yyyy') AND to_date('"+hasta+"','dd/mm/yyyy')";


	int recsPerPage=6;
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

///	sql= "SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.te_hent,'hh:mi am') as horaEnt, to_char(a.te_hsal,'hh:mi am') as horaSal, a.codigo, a.emp_id, c.primer_nombre||' '||c.primer_apellido as nombre,  a.aprobado, a.observaciones,d.ta_a, d.tp_a, d.ta_libre, nvl(d.codigo_turno_asignado,'1') te, nvl(d.codigo_turno_posterior,'1') tp, to_char(s.trans_desde,'dd/mm/yyyy') desde, to_char(s.trans_hasta,'dd/mm/yyyy') hasta, s.periodo, to_char(s.trans_desde,'yyyy') anio, nvl(x.turent,d.codigo_turno_asignado) turent, nvl(y.tursal,d.codigo_turno_posterior) tursal from tbl_pla_st_det_turext a, tbl_pla_empleado c, tbl_pla_st_det_empleado d, tbl_pla_calendario s,  (select to_char(to_char(hora_entrada,'HH')||' / '||to_char(hora_salida,'HH')) turent, compania, codigo from tbl_pla_ct_turno) x,  (select to_char(to_char(hora_entrada,'HH')||' / '||to_char(hora_salida,'HH')) tursal, compania cia, codigo cod from tbl_pla_ct_turno) y WHERE  a.compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = c.emp_id and a.compania = c.compania  and a.emp_id = "+empId+" and a.ue_codigo = "+grupo+" and a.ue_codigo = d.ue_codigo and (a.actualizado = 'N' or a.actualizado is null) and a.emp_id = d.emp_id and a.compania = d.compania and trunc(a.fecha) = d.fecha and trunc(sysdate) BETWEEN to_date(to_char(s.fecha_inicial,'dd/mm/yyyy'),'dd/mm/yyyy') AND to_date(to_char(s.fecha_final,'dd/mm/yyyy'),'dd/mm/yyyy') and s.tipopla = 1 and decode(d.codigo_turno_asignado,'LS','','V','','N','',d.codigo_turno_asignado) = x.codigo(+) and d.compania = x.compania(+) and decode(d.codigo_turno_posterior,'LS','','V','','N','',d.codigo_turno_posterior) = to_char(y.cod(+))  and d.compania = y.cia(+) order by a.fecha desc";

 sql= "select zz.*, to_char(yy.trans_desde,'dd/mm/yyyy') desde, to_char(yy.trans_hasta,'dd/mm/yyyy') hasta,yy.periodo, to_char(yy.trans_desde,'yyyy') anio from (SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.te_hent,'hh:mi am') as horaEnt, to_char(a.te_hsal,'hh:mi am') as horaSal, a.codigo, a.emp_id,  a.aprobado, a.observaciones, (select primer_nombre||' '||primer_apellido from tbl_pla_empleado where emp_id = a.emp_id) as nombre, (select ta_a from tbl_pla_st_det_empleado where ue_codigo = a.ue_codigo and emp_id = a.emp_id and compania = a.compania and fecha = trunc(a.fecha)) as ta_a, (select tp_a from tbl_pla_st_det_empleado where ue_codigo = a.ue_codigo and emp_id = a.emp_id and compania = a.compania and fecha = trunc(a.fecha)) as tp_a, (select ta_libre from tbl_pla_st_det_empleado where ue_codigo = a.ue_codigo and emp_id = a.emp_id and compania = a.compania and fecha = trunc(a.fecha)) as ta_libre, (select nvl(codigo_turno_asignado,'1') te from tbl_pla_st_det_empleado where ue_codigo = a.ue_codigo and emp_id = a.emp_id and compania = a.compania and fecha = trunc(a.fecha)) as te, (select nvl(codigo_turno_posterior,'1') tp from tbl_pla_st_det_empleado where ue_codigo = a.ue_codigo and emp_id = a.emp_id and compania = a.compania and fecha = trunc(a.fecha)) as tp, (select case when z.codigo_turno_asignado between 'A' and 'Z' then z.codigo_turno_asignado else nvl((select to_char(to_char(hora_entrada,'HH')||' / '||to_char(hora_salida,'HH')) from tbl_pla_ct_turno where codigo = z.codigo_turno_asignado and compania = z.compania),' ') end from tbl_pla_st_det_empleado z where z.ue_codigo = a.ue_codigo and z.emp_id = a.emp_id and z.compania = a.compania and z.fecha = trunc(a.fecha)) as turent, (select case when z.codigo_turno_posterior between 'A' and 'Z' then z.codigo_turno_posterior else nvl((select to_char(to_char(hora_entrada,'HH')||' / '||to_char(hora_salida,'HH')) from tbl_pla_ct_turno where codigo = z.codigo_turno_posterior and compania = z.compania),' ')  end from tbl_pla_st_det_empleado z where z.ue_codigo = a.ue_codigo and z.emp_id = a.emp_id and z.compania = a.compania and z.fecha = trunc(a.fecha)) as tursal from tbl_pla_st_det_turext a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.ue_codigo = "+grupo+" and a.emp_id = "+empId+" "+appendFilter+" and (a.actualizado = 'N' or a.actualizado is null) order by 1 desc) zz, (select trans_desde, trans_hasta, periodo from tbl_pla_calendario where tipopla = 1 and trunc(sysdate) BETWEEN trunc(fecha_inicial) AND trunc(fecha_final)) yy";

  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	System.err.println(sql);





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
<%@ include file="../common/tab.jsp" %>
<script language="javascript">


function doAction()
{
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
}

function edit(k)
{
   var empId;
   var grupo;
   var codi;

   empId = eval('document.formSobretiempo.emp_id'+k).value;
   grupo = document.formSobretiempo.grupo.value;
   codi  = eval('document.formSobretiempo.cod'+k).value;

   abrir_ventana1('../rhplanilla/empl_sobretiempo_config.jsp?mode=edit&empId='+empId+'&grupo='+grupo+'&cod='+codi);
}

function aprueba(k)
{
   var empId;
   var grupo;
   var codi;

   empId = eval('document.formSobretiempo.emp_id'+k).value;
   grupo = document.formSobretiempo.grupo.value;
   codi = eval('document.formSobretiempo.cod'+k).value;

   abrir_ventana1('../rhplanilla/empl_sobretiempo_config.jsp?empId='+empId+'&grupo='+grupo+'&cod='+codi);
}

function ver(k)
{
   var empId;
   var grupo;
   var codi;

   empId = eval('document.formSobretiempo.emp_id'+k).value;
   grupo = document.formSobretiempo.grupo.value;
   codi = eval('document.formSobretiempo.cod'+k).value;

   abrir_ventana1('../rhplanilla/empl_sobretiempo_config.jsp?mode=view&empId='+empId+'&grupo='+grupo+'&cod='+codi);
}

function checkAll()
{
	var size = document.formSobretiempo.size.value;

	for (i=0; i<size; i++)
	{
		if (eval(document.formSobretiempo.modular).checked)
		{
			 eval('document.formSobretiempo.aprobado'+i).checked=true;
		}

		else
		{

		eval("document.formSobretiempo.aprobado"+i).checked = false;

		}
	}
}


function imprimir(k)
{
   var empId;
   var grupo;
   var codi;
    var desde;
   var hasta;
   var anio;
   var area;
   var periodo;

   empId = eval('document.formSobretiempo.emp_id'+k).value;
   grupo = eval('document.formSobretiempo.grupo'+k).value;
   area = eval('document.formSobretiempo.area'+k).value;
   codi  = eval('document.formSobretiempo.cod'+k).value;
   desde  = eval('document.formSobretiempo.desde'+k).value;
   hasta  = eval('document.formSobretiempo.hasta'+k).value;
   anio  = eval('document.formSobretiempo.anio'+k).value;
   periodo  = eval('document.formSobretiempo.periodo'+k).value;

   abrir_ventana1('../rhplanilla/print_list_sobretiempo.jsp?desde='+desde+'&hasta='+hasta+'&anio='+anio+'&periodo='+periodo+'&empId='+empId+'&grupo='+grupo+'&area='+area);
}

function aprobar()
{
	var size = document.formSobretiempo.size.value;
  var check = 'S';
	var cont=0;
	var empId;
	var codigo;
	var fecha;
	var observacion;
	for (i=0; i<size; i++)
		{
			 empId  = eval('document.formSobretiempo.emp_id'+i).value;
			 codigo = eval('document.formSobretiempo.cod'+i).value;
			 fecha  = eval('document.formSobretiempo.fecha'+i).value;
		/*	 observacion  = eval('document.formSobretiempo.observaciones'+i).value;*/
			 observacion = document.getElementById('observacion'+i).value

					if (eval('document.formSobretiempo.aprobado'+i).checked)
					{
						if(executeDB('<%=request.getContextPath()%>','call sp_pla_aprobar_sobretiempo(<%=compania%>,'+empId+','+codigo+',\''+fecha+'\',\''+check+'\',\''+observacion+'\')'))
							cont++;
							else alert('Extras No se Procesaron las Extras....!');
					}
		}
		alert('Extras Aprobadas....!');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">	</td>
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
				<%=fb.hidden("grupo",grupo)%>
				  <%=fb.hidden("area",area)%>
				  <%=fb.hidden("empId",empId)%>
					<%=fb.hidden("size",""+al.size())%>
					 <%=fb.hidden("desde",desde)%>
					<%=fb.hidden("hasta",hasta)%>
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
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("size",""+al.size())%>
					<%=fb.hidden("desde",desde)%>
					<%=fb.hidden("hasta",hasta)%>
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

  <% fb = new FormBean("formSobretiempo",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
  <%=fb.hidden("grupo",grupo)%>
  <%=fb.hidden("area",area)%>
  <%=fb.hidden("empId",empId)%>
	<%=fb.hidden("size",""+al.size())%>
	 <%=fb.hidden("desde",desde)%>
	<%=fb.hidden("hasta",hasta)%>



	<% if (al.size() > 0)
    {
	CommonDataObject cdo1 = (CommonDataObject) al.get(0);

	%>

		 <tr>

		      <td colspan="7" align="center"><table width="100%" cellpadding="1" cellspacing="0" align="center">
		          <tr class="TextPanel">
		            <td colspan="7" align="center"><label id="dsp_periodo_activo"></label>&nbsp;</td>
		          </tr>
		          <tr class="TextPanel">
		            <td colspan="2" align="center">Fecha Cierre:</td>
		            <td colspan="2"><label id="fecha_cierre"></label></td>
		            <td colspan="3"><label id="dsp_transacciones"></label></td>

		          </tr>
		          <tr class="TextPanel02">
		            <td colspan="2" align="right">&nbsp;Fecha Inicial:</td>
		            <td colspan="5">
		            <jsp:include page="../common/calendar.jsp" flush="true">
		            <jsp:param name="noOfDateTBox" value="1" />
		            <jsp:param name="clearOption" value="true" />
		            <jsp:param name="nameOfTBox1" value="fecha_inicio"/>
		            <jsp:param name="valueOfTBox1" value="" />
		            <jsp:param name="jsEvent" value="chkFechas(1)" />
		            <jsp:param name="onChange" value="chkFechas(1)" />
		            </jsp:include>
		            &nbsp;Fecha Final:
		            <jsp:include page="../common/calendar.jsp" flush="true">
		            <jsp:param name="noOfDateTBox" value="1" />
		            <jsp:param name="clearOption" value="true" />
		            <jsp:param name="nameOfTBox1" value="fecha_final"/>
		            <jsp:param name="valueOfTBox1" value="" />
		            <jsp:param name="jsEvent" value="chkFechas(2)" />
		            <jsp:param name="onChange" value="chkFechas(2)" />
		            </jsp:include>
		            <%=fb.submit("go","Ir",false,false,"Text10","","")%>
		            </td>

		          </tr>

		          <tr>
		              <td colspan="1" align="left">Grupo a Generar:</td>
		              <td colspan="6" align="left">
		              <%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion from tbl_pla_ct_grupo where compania = "+(String) session.getAttribute("_companyId")+" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where grupo = "+grupo+")","grupo",grupo,false,false,0,null,null,"onChange=\"javascript:clearTextBox();\"")%>
		              </td>

		          </tr>
		       </table>
		     </td>
	   </tr>



		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextHeader" align="center">
			<td colspan="2">Sobretiempo de:</td>
			<td colspan="3"><%=cdo1.getColValue("Nombre")%></td>
			<td align="center" colspan="2"><%=fb.button("Aprobar","Aprobar",true,false,null,null,"onClick=\"javascript:aprobar()\"")%> &nbsp;<%=fb.button("Imprimir","Imprimir",true,false,null,null,"onClick=\"javascript:imprimir(0)\"")%></td>
		</tr>

			<tr class="TextHeader" align="center">
					<td colspan="3" align="left">Fechas   a   Processar   segun    Calendario   de   Planilla:</td>
					<td colspan="2" align="center">Desde :<%=cdo1.getColValue("desde")%></td>
					<td align="center" colspan="2">Hasta :<%=cdo1.getColValue("hasta")%></td>
		</tr>
	<%

			}
	%>
		<tr class="TextHeader" align="center">
			<td width="10%">Fecha</td>
			<td width="10%">Turno Asignado</td>
			<td width="20%">Día/Hora Inicio</td>
			<td width="20%">Día/Hora Final</td>
			<td width="10%">Turno Posterior</td>
			<td width="25%">Observación</td>
			<td width="05%">&nbsp;<%
			//fb.checkbox("modular","",false,false,null,null,"onClick=\"javascript:checkAll()\"")%>
				</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";

	if (i % 2 == 0) color = "TextRow01";
%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<%=fb.hidden("cod"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
				<%=fb.hidden("desde"+i,cdo.getColValue("desde"))%>
				<%=fb.hidden("hasta"+i,cdo.getColValue("hasta"))%>
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
				<%=fb.hidden("periodo"+i,cdo.getColValue("periodo"))%>

				<%=fb.hidden("grupo"+i,grupo)%>
				<%=fb.hidden("area"+i,area)%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("fecha")%></td>
			<td align="center"><%=cdo.getColValue("turent")%></td>
			<td><%=cdo.getColValue("horaEnt")%></td>
			<td><%=cdo.getColValue("horaSal")%></td>
			<td align="center"><%=cdo.getColValue("tursal")%></td>
			<td><%=fb.textBox("observaciones",cdo.getColValue("observaciones"),false,false,false,35,80)%></td>

			<td align="center"><%=fb.checkbox("aprobado"+i,"S",(cdo.getColValue("aprobado").equalsIgnoreCase("S")),false)%></td>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observaciones"))%>
		</tr>
<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
        <%=fb.formEnd()%>
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
				<%=fb.hidden("grupo",grupo)%>
				  <%=fb.hidden("area",area)%>
				  <%=fb.hidden("empId",empId)%>
					<%=fb.hidden("size",""+al.size())%>
					 <%=fb.hidden("desde",desde)%>
	<%=fb.hidden("hasta",hasta)%>
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
					<%=fb.hidden("grupo",grupo)%>
					  <%=fb.hidden("area",area)%>
					  <%=fb.hidden("empId",empId)%>
						<%=fb.hidden("size",""+al.size())%>
						 <%=fb.hidden("desde",desde)%>
	<%=fb.hidden("hasta",hasta)%>
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
