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
String fecha_inicio = request.getParameter("fecha_inicio");
String fecha_final = request.getParameter("fecha_final");
String emp_id = request.getParameter("emp_id");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdo = new CommonDataObject();
int cont = 0;
if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if(emp_id != null && fecha_inicio != null && fecha_final != null && change == null){
		sql = "select a.motivo, a.total_horas, b.descripcion, a.total_horas * d.rata_hora monto_pagar from (select a.emp_id, a.motivo, sum(case when a.motivo <> 99999 and nvl(a.cantidad, 0) > 0 then a.cantidad else 0 end) total_horas from tbl_pla_at_det_dist a where a.emp_id = "+emp_id+" and a.compania = "+(String) session.getAttribute("_companyId")+" and to_date(to_char (a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date ('"+fecha_inicio+"', 'dd/mm/yyyy') and to_date(to_char (a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date ('"+fecha_final+"', 'dd/mm/yyyy') and a.motivo <> 99999 group by a.emp_id, a.motivo) a, tbl_pla_empleado d, tbl_pla_motivo_falta b where a.emp_id = d.emp_id and a.motivo = b.codigo(+) union select 99999 motivo, 0 total_horas, 'DESCUENTO POR AJUSTE' descripcion, 0 monto_pagar from dual";
		System.out.println("SQL TIPO MOTIVO\n"+sql);
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
	parent.window.setDiasDetOnLoad();
}

function setDiasValues(i){
	checkRadioButton(document.form.rb, i);
	parent.window.setDiasDet(i);
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
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("quincena","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="6">Detalle de Ausencias / Tardanzas Generadas por Tipo de Motivo</td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center">Cod.</td>
          <td align="center">Descripci&oacute;n del Tipo</td>
          <td align="center">Total Hrs.</td>
          <td align="center">Monto</td>
          <td align="center">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<alTPR.size(); i++){
					CommonDataObject cd = (CommonDataObject) alTPR.get(i); 
          String color = "";
					String hora_desde = "hora_desde"+i, hora_hasta = "hora_hasta"+i;
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center" onClick="javascript:setDiasValues(<%=i%>)" style="cursor:pointer">
          <td align="center">
					<%=fb.textBox("motivo"+i,cd.getColValue("motivo"),false,false,true,10,"text10","","")%>
          </td>
          <td align="center">
					<%=fb.textBox("descripcion"+i,cd.getColValue("descripcion"),false,false,true,50,"text10","","")%>
          </td>
          <td align="center"><%=fb.intBox("total_horas"+i,CmnMgr.getFormattedDecimal(cd.getColValue("total_horas")),false,false,true,10,"text10","","")%></td>
          <td align="center"><%=fb.decBox("monto_pagar"+i,CmnMgr.getFormattedDecimal(cd.getColValue("monto_pagar")),false,false,true,10,"text10","","")%></td>
          <td align="left"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:parent.window.setDiasValuesOnLoad()\"")%></td>
        </tr>
        <%}%>
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