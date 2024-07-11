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
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
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
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");

boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && quincena != null && change == null){
		sql = "select a.codigo, a.emp_id, b.num_empleado, to_char(periodof_inicio, 'dd/mm/yyyy') periodof_inicio, a.dias_tiempo, a.dias_dinero, b.primer_nombre||' '||decode(b.sexo, 'F', decode(b.apellido_casada, null, b.primer_apellido, decode(b.usar_apellido_casada, 'S', 'DE' || b.apellido_casada, b.primer_apellido)), b.primer_apellido) nombre_empleado, b.unidad_organi, to_char(b.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, decode(b.provincia, 0, ' ', 00, ' ', 10, '0', 11, 'B', 12, 'C', b.provincia) || rpad(decode(b.sigla, '00', '  ', '0', '  ', b.sigla), 2, '  ') || '-'|| lpad(to_char(b.tomo), 5, '0')||'-' || lpad(to_char(b.asiento), 6, '0') dsp_cedula, c.descripcion dsp_depto,a.anio from tbl_pla_sol_vacacion a, tbl_pla_empleado b, tbl_sec_unidad_ejec c where a.emp_id = b.emp_id and a.compania = b.compania and b.compania = c.compania and b.unidad_organi = c.codigo and a.estado = 'AP' and (a.enviar_planilla_estado = 'N' or a.enviar_planilla_estado is null) and to_date(to_char(periodof_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= decode("+quincena+", 1, to_date('15/'||"+mes+"||'/'||"+anio+", 'dd/mm/yyyy'), 2, last_day(to_date('01/'||"+mes+"||'/'||"+anio+", 'dd/mm/yyyy')), 3, last_day(to_date('01/'||"+mes+"||'/'||"+anio+", 'dd/mm/yyyy')))";
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
	if(action == 'Enviar a planilla' || action == 'Anular'){
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
	var anio 		= document.form.anio.value;
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
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center">C&eacute;dula</td>
          <td align="center">No. Empleado</td>
          <td align="center">Nombre Empleado</td>
          <td align="center">Depto al que Pertenece</td>
          <td align="center">Fecha Inicio Vacaci&oacute;n</td>
          <td align="center">Dias Tomar Tiempo</td>
          <td align="center">Dias Tomar Dinero</td>
          <td align="center">&nbsp;</td>
          <td align="center"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','chk',"+emp.size()+",this,0)\"","Seleccionar todos los Registros listados!")%></td>
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
        <%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
        <%=fb.hidden("dsp_cedula"+i, cdo.getColValue("dsp_cedula"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>
        <%=fb.hidden("dsp_depto"+i, cdo.getColValue("dsp_depto"))%>
        <%=fb.hidden("periodof_inicio"+i, cdo.getColValue("periodof_inicio"))%>
        <%=fb.hidden("dias_tiempo"+i, cdo.getColValue("dias_tiempo"))%>
        <%=fb.hidden("dias_dinero"+i, cdo.getColValue("dias_dinero"))%>
        <%=fb.hidden("unidad_organi"+i, cdo.getColValue("unidad_organi"))%>
        <%=fb.hidden("fecha_ingreso"+i, cdo.getColValue("fecha_ingreso"))%>
        <%=fb.hidden("anio"+i, cdo.getColValue("anio"))%>
        <tr class="<%=color%>" align="center">
          <td align="left"><%=cdo.getColValue("dsp_cedula")%></td>
          <td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre_empleado")%></td>
          <td align="left"><%=cdo.getColValue("dsp_depto")%></td>
          <td align="center"><%=cdo.getColValue("periodof_inicio")%></td>
          <td align="center"><%=cdo.getColValue("dias_tiempo")%></td>
          <td align="center"><%=cdo.getColValue("dias_dinero")%></td>
          <td align="center"><a href="javascript:openSolVac(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16"></a></td>
          <!--checkbox(String objName, String objValue, boolean isChecked, boolean isDisabled, String className, String style, String event)-->
          <td align="center"><%=fb.checkbox("chk"+i,""+i, false, false, "text10", "", "")%></td>
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="left" colspan="9">Total Solicitudes:&nbsp;<font class="RedTextBold"><%=alTPR.size()%></font></td>
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
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("codigo", request.getParameter("codigo"+i));
			cdo.addColValue("usuario_modifica", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			alTPR.add(cdo);
		}
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Enviar a planilla")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		VacMgr.enviarSolToPlanilla(alTPR);
		ConMgr.clearAppCtx(null);
	} else if (request.getParameter("baction").equalsIgnoreCase("Anular")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		VacMgr.anularSolicitud(alTPR);
		ConMgr.clearAppCtx(null);
	}
	
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../build/web/js/capslock.js"></script>
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