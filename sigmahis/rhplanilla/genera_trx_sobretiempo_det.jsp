<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%

SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String periodo = request.getParameter("periodo");
String cierre = request.getParameter("cierre");
String grupo = request.getParameter("unidad");
String fechaInicio = request.getParameter("finicio");
String fechaFinal = request.getParameter("ffinal");
String desdeTrx = request.getParameter("desde");
String hastaTrx = request.getParameter("hasta");
String unidad = request.getParameter("unidad");

boolean viewMode = false;
int lineNo = 0;
//System.out.println("grp="+grupo);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(grupo==null) grupo="";
if(fechaInicio==null) fechaInicio="";
if(fechaFinal==null) fechaFinal="";
if(mode.equals("view")) viewMode = true;

 if (request.getParameter("fInicio") != null)
   {
     appendFilter += " and trunc(a.fecha) >= to_date('"+fechaInicio+"', 'dd/mm/yyyy')";
	 }

if (request.getParameter("fFinal") != null)
   {
      appendFilter += " and trunc(a.fecha) <= to_date('"+fechaFinal+"', 'dd/mm/yyyy')";
	 }

if (request.getParameter("unidad") != null)
   {
   appendFilter += " and a.ue_codigo = "+grupo;
	 }
 if (request.getParameter("anio") != null)
	    {
	    appendFilter += "  and a.anio_pago = "+anio;
	 	 }

	 if (request.getParameter("periodo") != null)
	    {
	    appendFilter += " and a.periodo_pago = "+periodo;
	 }



if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(fechaInicio != null && fechaFinal != null && grupo != null ){

		sql="select distinct (e.emp_id), e.provincia, e.sigla, e.tomo, e.asiento, e.unidad_organi ue_codigo, e.primer_nombre||' '||decode(e.sexo, 'F', decode(e.apellido_casada, null, e.primer_apellido, decode(e.usar_apellido_casada, 'S', 'DE '|| e.apellido_casada, e.primer_apellido)), e.primer_apellido) nombre_empleado, e.unidad_organi, to_char(e.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, decode(e.provincia, 0, ' ', 00, ' ', 10, '0', 11, 'B', 12, 'C', e.provincia) || rpad(decode(e.sigla, '00', '  ', '0', '  ', e.sigla), 2, '  ') || '-'|| lpad(to_char(e.tomo), 3, '0')||'-' || lpad(to_char(e.asiento), 6, '0') dsp_cedula, e.estado, e.emp_id, b.descripcion, e.num_empleado , f.emp_id as control, f.fecha_vaca, f.dias_vac,  substr(fn_pla_periodo_pago(e.emp_id,e.compania, "+anio+", "+periodo+", e.estado),1,4) anio_ac,  substr(fn_pla_periodo_pago(e.emp_id,e.compania, "+anio+", "+periodo+", e.estado),5,6) periodo_ac from tbl_pla_estado_emp b, tbl_pla_empleado e, (select  e.emp_id, max(decode(e.estado,'2',to_number(d.anio_ac||to_char(d.periodo_ac,'fm09')),'','')) as fecha_vaca , max(d.dias_vac) dias_vac , max(d.anio_ac) anio_ac_old, max(to_char(d.periodo_ac,'fm09')) periodo_ac_old from  tbl_pla_dist_dias_vac d, tbl_pla_empleado e where e.emp_id = d.emp_id(+)  and e.compania = "+(String) session.getAttribute("_companyId")+" group by e.emp_id ) f where  e.estado = b.codigo and e.emp_id in (select distinct emp_id from tbl_pla_st_det_disttur a where a.compania ="+(String) session.getAttribute("_companyId")+""+appendFilter+" and (a.trx_generada = 'N' or a.trx_generada is null)) and e.emp_id = f.emp_id";

		System.out.println("SQL TPR=\n"+sql);
		alTPR = SQLMgr.getDataList(sql);
		emp.clear();
		empKey.clear();
		for(int i=0;i<alTPR.size();i++){
			CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				emp.put(key, cdo);
				empKey.put(cdo.getColValue("emp_id"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
		var size = <%=alTPR.size()%>;
		var x = 0;
		parent.document.form1.count.value = size;
		for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	parent.document.form1.count1.value = x;
}

function selTurno(name){
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_turno.jsp?fp=programa_turno_borrador&index='+name);
	<%
	}
	%>
}

function selUbicacion(name){
	var quincena = parent.document.form1.quincena.value;
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_area.jsp?fp=programa_turno_borrador&index='+name+'&quincena='+quincena);
	<%
	}
	%>
}


function doSubmit(action){
	document.form.baction.value 			= action;
	document.form.anio.value 				= parent.document.form1.anio.value;
	document.form.mes.value 				= parent.document.form1.mes.value;
	document.form.quincena.value 		= parent.document.form1.quincena.value;
	if(action == 'GENERAR TRANSACCIONES PARA CALCULO DE PLANILLA' ){
		formBlockButtons(true);
		if(chkSelected()) document.form.submit();
		else alert('Seleccione al menos una solicitud!');
		formBlockButtons(false);
	}
}

function chkSelected(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

function openSolVac(i){
	var v_compania	= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 		= eval('document.form.emp_id'+i).value;
	var codigo 		= eval('document.form.codigo'+i).value;
	//var anio 			= document.form.anio.value;
	var anio 			= eval('document.form.anioSol'+i).value;

	abrir_ventana('../rhplanilla/aprobar_rechazar_solicitud_vac.jsp?fp=aprobar_rechazar_solicitud_vac&empId='+emp_id+'&codigo='+codigo+'&anio='+anio);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("periodo",periodo)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
				 <td align="center" width="7%">No. Empl.</td>
          <td align="center" width="13%">C&eacute;dula</td>
          <td align="center" width="25%">Nombre Empleado</td>
          <td align="center" width="25%">Estado</td>
          <td align="center" width="12%">Ultima Vacaciones</td>
          <td align="center" width="7%">Año</td>
          <td align="center" width="7%">Periodo</td>
          <td align="center" width="4%">Sel.</td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();
          CommonDataObject cdo = (CommonDataObject) emp.get(key);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%=fb.hidden("emp_id"+i, cdo.getColValue("emp_id"))%>
        <%=fb.hidden("ue_codigo"+i, cdo.getColValue("ue_codigo"))%>

        <%=fb.hidden("anioPago"+i, cdo.getColValue("anio_ac"))%>
        <%=fb.hidden("dsp_cedula"+i, cdo.getColValue("dsp_cedula"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>

        <%=fb.hidden("unidad_organi"+i, cdo.getColValue("unidad_organi"))%>
        <%=fb.hidden("fecha_ingreso"+i, cdo.getColValue("fecha_ingreso"))%>
		<%=fb.hidden("estado"+i, cdo.getColValue("estado"))%>
		<%=fb.hidden("inicio"+i, fechaInicio)%>
		<%=fb.hidden("final"+i, fechaFinal)%>
		<%=fb.hidden("grupo"+i, grupo)%>
		<%=fb.hidden("quincenaPago"+i, cdo.getColValue("periodo_ac"))%>
        <tr class="<%=color%>" align="center">
				 	<td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("dsp_cedula")%></td>
          <td align="left"><%=cdo.getColValue("nombre_empleado")%></td>
          <td align="left"><%=cdo.getColValue("descripcion")%></td>

					<%if(cdo.getColValue("fecha_vaca").trim().equalsIgnoreCase("")){%>
					<td align="center"><%=cdo.getColValue("fecha_vaca")%></td>
          <td align="center"><%=anio%></td>
          <td align="center"><%=periodo%></td>
         <% } else {%>
				 <td align="center"><%=cdo.getColValue("fecha_vaca")%></td>
          <td align="center"><%=cdo.getColValue("anio_ac")%></td>
          <td align="center"><%=cdo.getColValue("periodo_ac")%></td>
					<% } %>
          <!--checkbox(String objName, String objValue, boolean isChecked, boolean isDisabled, String className, String style, String event)-->
          <td align="center"><%=fb.checkbox("chk"+i, ""+i, false, false, "Text10", "", "onClick=\"javascript:doAction()\"")%></td>
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="left" colspan="9">Total Empleados:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	emp.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("chk"+i)!=null){
			cdo.addColValue("anio", request.getParameter("anio"));
			cdo.addColValue("periodo", request.getParameter("periodo"));
			cdo.addColValue("inicio", request.getParameter("inicio"+i));
			cdo.addColValue("final", request.getParameter("final"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
  		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("unidad_organi", request.getParameter("grupo"+i));
			cdo.addColValue("anioPago", request.getParameter("anioPago"+i));
			cdo.addColValue("quincenaPago", request.getParameter("quincenaPago"+i));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("usuario", (String) session.getAttribute("_userName"));
			alTPR.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("GENERAR TRANSACCIONES PARA CALCULO DE PLANILLA")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		VacMgr.generaSobretiempo(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (VacMgr.getErrCode().equals("1")){
%>
	alert('<%=VacMgr.getErrMsg()%>');
	parent.window.setValues();
<%
} else throw new Exception(VacMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>