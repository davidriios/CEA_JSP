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
String fecha_inicio = request.getParameter("fecha_inicio");
String fecha_final = request.getParameter("fecha_final");
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
	if(anio != null && mes != null && quincena != null && change == null && grupo != null){
	
	//	sql = " select b.semana,  b.anio, decode(b.anio,'2013', to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy','NLS_DATE_LANGUAGE=SPANISH') + ((b.semana - 2 ) * 7), 2), 'dd/mm/yyyy'),  to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 2), 'dd/mm/yyyy')) as ini_week, decode(b.anio,'2013',to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 1) , 'dd/mm/yyyy'), to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 2) + 6, 'dd/mm/yyyy')) as end_week from (select distinct (to_number(to_char(fecha, 'IW')))semana, decode(to_char(to_date(fecha,'dd/mm/yyyy'),'dd/mm'),'31/12',to_number(to_char(fecha, 'IYYY')),to_number(to_char(fecha, 'IYYY'))) anio from tbl_pla_st_det_turext where ue_codigo = "+grupo+" and anio_pago = "+anio+" and periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and fecha  <= to_date('"+fecha_final+"','dd/mm/yyyy') and compania = "+(String) session.getAttribute("_companyId")+") b order by b.semana";
		sql = " select x.semana, x.anio, x.ini_week, decode(sign(to_date('"+fecha_final+"','dd/mm/yyyy') - to_date(x.end_week,'dd/mm/yyyy')),1,x.end_week,to_char(to_date('"+fecha_final+"','dd/mm/yyyy'),'dd/mm/yyyy')) end_week from (select b.semana,  b.anio, decode(b.anio,'2013', to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy','NLS_DATE_LANGUAGE=SPANISH') + ((b.semana - 2 ) * 7), 2), 'dd/mm/yyyy'),  to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 2), 'dd/mm/yyyy')) as ini_week, decode(b.anio,'2013',to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 1) , 'dd/mm/yyyy'), to_char(next_day(to_date('01/01/' || b.anio, 'dd/mm/yy') + ((b.semana - 1) * 7), 2) + 6, 'dd/mm/yyyy')) as end_week from (select distinct (to_number(to_char(fecha, 'IW')))semana, decode(to_char(to_date(fecha,'dd/mm/yyyy'),'dd/mm'),'31/12',to_number(to_char(fecha, 'IYYY')),to_number(to_char(fecha, 'IYYY'))) anio from tbl_pla_st_det_turext where ue_codigo = "+grupo+" and anio_pago = "+anio+" and periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and fecha  <= to_date('"+fecha_final+"','dd/mm/yyyy') and compania = "+(String) session.getAttribute("_companyId")+") b order by b.semana) x";
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
	parent.window.setDiasValuesOnLoad();
}

function doSubmit(action){
}

function setDiasValues(i){
	checkRadioButton(document.form.rb, i);
	parent.window.setDiasValues(i);
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
          <td align="center">Num.</td>
          <td align="center">Desde</td>
          <td align="center">Hasta</td>
          <td align="center">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<alTPR.size(); i++){
					CommonDataObject cd = (CommonDataObject) alTPR.get(i);
          String color = "";
		  String fecha =cd.getColValue("end_week");
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
	
        <tr class="<%=color%>" align="center" onClick="javascript:setDiasValues(<%=i%>)" style="cursor:pointer">
          <td align="center"><%=fb.textBox("semana"+i,cd.getColValue("semana"),false,false,true,4,"text10","","")%></td>
          <td align="center"><%=fb.textBox("ini_week"+i,cd.getColValue("ini_week"),false,false,true,10,"text10","","")%></td>
		  <td align="center"><%=fb.textBox("end_week"+i,cd.getColValue("end_week"),false,false,true,10,"text10","","")%></td>
		  <td align="left"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDiasValues("+i+")\"")%></td>
        </tr>
        <% }
		%>
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