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
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
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
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alM = new ArrayList();
ArrayList alCT = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String grupo = request.getParameter("grupo");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String dia = request.getParameter("dia");
String emp_id = request.getParameter("emp_id");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && change == null){
		sql = "select compania, emp_id, num_empleado, anio, mes, dia, to_char(entrada, 'hh:mi am') entrada, to_char(salida_com, 'hh:mi am') salida_com, to_char(entrada_com, 'hh:mi am') entrada_com, to_char(salida, 'hh:mi am') salida from tbl_pla_marcacion where compania = "+(String) session.getAttribute("_companyId")+" and emp_id = " + emp_id + " and anio = "+anio + " and mes = " + mes + " and dia = " + dia;
		alM = SQLMgr.getDataList(sql);
		sql = "select to_char(a.fecha_tasignado, 'dd/mm/yyyy') fecha_tasignado, a.turno_asignado, a.turno_nuevo, a.observaciones, b.descripcion dsp_tasignado, c.descripcion dsp_tnuevo, a.motivo_cambio from tbl_pla_ct_det_cambio_programa a, tbl_pla_ct_turno b, tbl_pla_ct_turno c where a.compania = "+(String) session.getAttribute("_companyId")+" and a.grupo = "+grupo+" and a.emp_id = "+emp_id+" and to_number(to_char(a.fecha_tasignado, 'yyyy')) = "+anio+" and to_number(to_char(a.fecha_tasignado, 'mm')) = "+mes+" and to_number(to_char(a.fecha_tasignado, 'dd')) = "+dia+" and a.aprobado <> 'A' and a.turno_asignado = b.codigo and a.compania = b.compania and a.turno_nuevo = c.codigo and a.compania = c.compania";
		alCT = SQLMgr.getDataList(sql);
		sql = "select nvl(to_char(to_date('"+dia+"/"+mes+"/"+anio+"', 'dd/mm/yyyy'), 'FMDAY DD \"DE\" MONTH \"DE\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH'), ' ') dia from dual";
		cdoDM = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	var fg				= document.form.fg.value;
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function doSubmit(action){
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
<%=fb.hidden("anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("grupo","")%>
<%=fb.hidden("uf_codigo","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="35%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02">
          <td colspan="4" align="center">&nbsp;MARCACION</td>
        </tr>
        <tr class="TextHeader01">
          <td colspan="4" align="center"><%=(cdoDM.getColValue("dia") != null?cdoDM.getColValue("dia"):"")%></td>
        </tr>
        <tr class="TextHeader02">
        	<td>ENTRADA</td>
        	<td>SALIDA</td>
        	<td>ENTRADA</td>
        	<td>SALIDA</td>
        </tr>
        <%
				for (int i=0; i<alM.size(); i++){
          CommonDataObject cdo = (CommonDataObject) alM.get(i);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center" height="21">
        	<td><%=fb.textBox("entrada"+i,cdo.getColValue("entrada"),false,false,true,10,"text09","","")%></td>
        	<td><%=fb.textBox("salida_com"+i,cdo.getColValue("salida_com"),false,false,true,10,"text09","","")%></td>
        	<td><%=fb.textBox("entrada_com"+i,cdo.getColValue("entrada_com"),false,false,true,10,"text09","","")%></td>
          <td><%=fb.textBox("salida"+i,cdo.getColValue("salida"),false,false,true,10,"text09","","")%></td>
        </tr>
        <%}%>
      </table>
    </td>
    <td width="65%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02">
          <td align="center" colspan="4">CAMBIOS DE TURNO</td>
        </tr>
        <tr class="TextHeader02">
          <td align="center">FECHA</td>
          <td align="center">TURNO PROGRAMADO</td>
          <td align="center">TURNO A REALIZAR</td>
          <td align="center">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<alCT.size(); i++){
          CommonDataObject cdo = (CommonDataObject) alCT.get(i);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("fecha_tasignado"+i,cdo.getColValue("fecha_tasignado"),false,false,true,10,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_tasignado"+i,cdo.getColValue("dsp_tasignado"),false,false,true,30,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_tnuevo"+i,cdo.getColValue("dsp_tnuevo"),false,false,true,30,"text09","","")%></td>
          <td><%=(cdo.getColValue("motivo_cambio").equals("4") || cdo.getColValue("motivo_cambio").equals("5")?"==> ADICIONAL AL PROGRAMADO":"==> EN VEZ DEL PROGRAMADO")%></td>
        </tr>
       <%}%>
      </table>
    </td>
  </tr>
  <tr class="TextHeader01" align="center">
    <td align="center" colspan="2">&nbsp;</td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>
