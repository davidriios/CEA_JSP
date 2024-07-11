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
<jsp:useBean id="AccMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
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
AccMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String tipo_he = request.getParameter("tipo_he");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String emp_id = request.getParameter("emp_id");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
int cont = 0;
if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(emp_id != null && change == null){
		sql = "select a.compania, a.ue_codigo, a.anio, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.codigo, a.secuencia, a.tipo_he, a.cantidad, a.generado, to_char(a.fecha_generado, 'dd/mm/yyyy') fecha_generado, to_char(a.hora_desde, 'HH12:MI am') hora_desde, to_char(a.hora_hasta, 'HH12:MI am') hora_hasta, a.semana, a.trx_generada, a.trx_usuario, to_char(a.trx_fecha, 'dd/mm/yyyy') trx_fecha, a.anio_pago, a.periodo_pago, a.tipo_detalle, a.emp_id from tbl_pla_st_det_disttur a where a.emp_id = "+emp_id+" and a.compania = "+(String) session.getAttribute("_companyId")+" and a.anio_pago = "+anio+" and a.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and a.tipo_he = "+tipo_he;
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
}

function doSubmit(action){
	document.form.baction.value 			= action;
	if(action == 'Guardar'){
		formBlockButtons(true);
		if(formValidation()) document.form.submit();
		formBlockButtons(false);
	}
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
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("quincena","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="5">Detalle de Sobretiempo Generado por D&iacute;a</td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center">Fecha</td>
          <td align="center">Hora Inicio</td>
          <td align="center">Hora Final</td>
          <td align="center">Cant.</td>
        </tr>
        <%
				double total = 0.00;
				for (int i=0; i<alTPR.size(); i++){
					CommonDataObject cd = (CommonDataObject) alTPR.get(i); 
          String color = "";
					String hora_desde = "hora_desde"+i, hora_hasta = "hora_hasta"+i;
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center">
          <td align="center">
          <%=fb.textBox("fecha"+i,cd.getColValue("fecha"),false,false,true,10,"text10","","")%>
          </td>
          <td align="center">
          <%=fb.textBox("hora_desde"+i,cd.getColValue("hora_desde"),false,false,true,10,"text10","","")%>
          </td>
          <td align="center">
					<%=fb.textBox("hora_hasta"+i,cd.getColValue("hora_hasta"),false,false,true,10,"text10","","")%>
          </td>
          <td align="right"><%=fb.intBox("cantidad"+i,cd.getColValue("cantidad"),false,false,true,4,"text10","","")%></td>
        </tr>
        <%
					total += Double.parseDouble(cd.getColValue("cantidad"));
					}
				%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="3">Totales=</td>
          <td align="right">
          <%=fb.intBox("total",""+total,false,false,true,4,"text10","","")%>
          </td>
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
%>