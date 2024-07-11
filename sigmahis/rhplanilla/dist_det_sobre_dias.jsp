<//%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
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
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String sem_fecha_inicio = request.getParameter("sem_fecha_inicio");
String sem_fecha_final = request.getParameter("sem_fecha_final");
String emp_id = request.getParameter("emp_id");
String v_finicio = "";
String v_fecha = "";
boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdo = new CommonDataObject();
int cont = 0;
if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && quincena != null && change == null && sem_fecha_inicio != null && sem_fecha_final != null){
		sql = "select distinct a.provincia, a.sigla, a.tomo, a.asiento, a.compania, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.codigo_posterior_programa programado, a.codigo_turno_posterior turno, to_char (a.fecha, 'DAY') dia, /*----decode(a.codigo_posterior_programa, 'S',decode((a.codigo_turno_posterior), 1, (select to_char(hora_entrada, 'hh:mi') || decode(hora_rec_salida, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_rec_salida, 'hh:mi') || ' / ' || to_char(hora_rec_entrada, 'hh:mi') || '-' || to_char(hora_salida, 'hh:mi'))from tbl_pla_ct_turno where compania = a.compania and codigo = a.codigo_turno_posterior), decode(a.codigo_turno_posterior, 'A', 'AUSENCIA','LC', 'LIC. CON SUELDO', 'LS', 'LIBRE SEMANAL', 'LN', 'LIBRE NACIONAL', 'PC', 'PERMISO CON SUELDO', 'PS', 'PERMISO SIN SUELDO', 'HD', 'HORAS DE DESCANSO', 'I', 'INCAPACIDAD', 'LG', 'LIC. POR GRAVIDEZ', 'V', 'VACACIONES', 'RP', 'RIESGO PROFESIONAL', (select to_char(hora_entrada, 'hh:mi') || decode(hora_rec_salida, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_rec_salida, 'hh:mi') || ' / ' || to_char(hora_rec_entrada, 'hh:mi') || '-' || to_char(hora_salida, 'hh:mi'))from tbl_pla_ct_turno where compania = a.compania and codigo = a.codigo_turno_posterior))), decode((a.codigo_turno_posterior), 1, (select to_char(hora_entrada, 'hh:mi') || decode(hora_salida_almuerzo, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_salida_almuerzo, 'hh:mi') || ' / ' || to_char(hora_entrada_almuerzo, 'hh:mi') || '-' || to_char(hora_salida, 'hh:mi')) from tbl_pla_horario_trab where compania = a.compania and codigo = a.codigo_turno_posterior), decode(a.codigo_turno_posterior, 'A', 'AUSENCIA', 'LC', 'LIC. CON SUELDO', 'LS', 'LIBRE SEMANAL', 'LN', 'LIBRE NACIONAL', 'PC', 'PERMISO CON SUELDO', 'PS', 'PERMISO SIN SUELDO', 'HD', 'HORAS DE DESCANSO', 'I', 'INCAPACIDAD', 'LG', 'LIC. POR GRAVIDEZ', 'V', 'VACACIONES', 'RP', 'RIESGO PROFESIONAL', a.codigo_turno_posterior)))-----*/ decode( a.codigo_posterior_programa,'S',  DECODE ( a.codigo_turno_posterior, 'A', 'AUSENCIA', 'LC', 'LIC. CON SUELDO', 'LS', 'LIBRE SEMANAL', 'LN', 'LIBRE NACIONAL', 'PC', 'PERMISO CON SUELDO', 'PS', 'PERMISO SIN SUELDO', 'HD', 'HORAS DE DESCANSO', 'N', 'NACIONAL', 'I', 'INCAPACIDAD', 'LG', 'LIC. POR GRAVIDEZ', 'V', 'VACACIONES', 'RP', 'RIESGO PROFESIONAL', (SELECT    TO_CHAR (hora_entrada, 'hh:mi')|| DECODE ( hora_rec_salida, NULL, ' / ' || TO_CHAR (hora_salida, 'hh:mi'), '-' || TO_CHAR (hora_rec_salida, 'hh:mi') || ' / ' || TO_CHAR (hora_rec_entrada, 'hh:mi') || '-' || TO_CHAR (hora_salida, 'hh:mi')) FROM tbl_pla_ct_turno WHERE  compania = a.compania AND codigo = a.codigo_turno_posterior))   )    post_turno_descripcion, to_char(a.fecha, 'FMDY', 'NLS_DATE_LANGUAGE=SPANISH') nombre_dia, to_char(a.fecha, 'IW') num_semana, nvl(b.v_cantidad_horas, 0) total_horas, nvl(c.v_cantidad_extras, 0) cant_extras from tbl_pla_st_det_empleado a, (select x.compania, x.emp_id, to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha, sum(nvl(x.cantidad, 0)) v_cantidad_horas from tbl_pla_st_det_disttur x where x.emp_id = "+emp_id+" and x.compania = "+(String) session.getAttribute("_companyId")+" and (x.generado = 'N' or x.generado is null) and x.anio_pago = "+anio+" and x.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2) - 1, "+mes+" * 2) /*and to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+sem_fecha_inicio+"', 'dd/mm/yyyy') and to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+sem_fecha_final+"', 'dd/mm/yyyy')*/ group by x.compania, x.emp_id, to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) b, (select x.compania, x.emp_id, to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha, count(*) v_cantidad_extras from tbl_pla_st_det_turext x where x.emp_id = "+emp_id+" and x.compania = "+(String) session.getAttribute("_companyId")+" and x.aprobado = 'S' and x.anio_pago = "+anio+" and x.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2) - 1, "+mes+" * 2) /*and to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+sem_fecha_inicio+"', 'dd/mm/yyyy') and to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+sem_fecha_final+"', 'dd/mm/yyyy')*/ group by x.compania, x.emp_id, to_date(to_char(x.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) c where a.compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = "+emp_id+" and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+sem_fecha_inicio+"', 'dd/mm/yyyy') and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+sem_fecha_final+"', 'dd/mm/yyyy') and (a.compania, a.emp_id, to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) in (select b.compania, b.emp_id, to_date(to_char(b.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') from tbl_pla_st_det_disttur b where b.compania = a.compania and b.emp_id = a.emp_id and b.anio_pago = "+anio+" and b.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2) - 1, "+mes+" * 2) and to_date(to_char(b.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) and a.emp_id = b.emp_id(+) and a.compania = b.compania(+) and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(b.fecha(+), 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.emp_id = c.emp_id(+) and a.compania = c.compania(+) and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(c.fecha(+), 'dd/mm/yyyy'), 'dd/mm/yyyy') order by compania, provincia, sigla, tomo, asiento, to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')";
		alTPR = SQLMgr.getDataList(sql);
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

	parent.window.setMarDetValuesOnLoad();
	parent.window.setMarPostTurnoOnLoad();
}

function doSubmit(action){
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()" style="vertical-align:top">

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
          <td align="center">&nbsp;</td>
          <td align="center">D&iacute;a</td>
          <td align="center">Cant.</td>
          <td align="center">Total Hrs.</td>
          <td align="center">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<alTPR.size(); i++){
					CommonDataObject cd = (CommonDataObject) alTPR.get(i);
          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%=fb.hidden("turno"+i,cd.getColValue("turno"))%>
        <%=fb.hidden("programado"+i,cd.getColValue("programado"))%>
        <%=fb.hidden("post_turno_descripcion"+i,cd.getColValue("post_turno_descripcion"))%>
        <tr class="<%=color%>" align="center" onClick="javascript:parent.window.setMarDetValues(<%=i%>)" style="cursor:pointer">
          <td align="center"><%=fb.textBox("nombre_dia"+i,cd.getColValue("nombre_dia"),false,false,true,4,"text10","","")%></td>
          <td align="center"><%=fb.textBox("fecha"+i,cd.getColValue("fecha"),false,false,true,10,"text10","","")%></td>
          <td align="center"><%=fb.intBox("cant_extras"+i,cd.getColValue("cant_extras"),false,false,true,4,"text10","","")%></td>
          <td align="center"><%=fb.decBox("total_horas"+i,cd.getColValue("total_horas"),false,false,true,4,"text10","","")%></td>
          <td align="left"><%=fb.radio("rb",""+i,(i==0?true:false),false,false, "", "", "onClick=\"javascript:parent.window.setMarDetValues("+i+")\"")%></td>
        </tr>
        <%}%>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+cont)%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
%>