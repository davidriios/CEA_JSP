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
String emp_id = request.getParameter("emp_id");
String index = request.getParameter("index");
boolean viewMode = false;
int lineNo = 0;

CommonDataObject cdo = new CommonDataObject();
int cont = 0;
if(mode == null) mode = "add";
if(index == null) index = "";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(emp_id != null && change == null){
		sql = "select a.tipo_he tipo_hextra, a.descripcion, a.factor_multi, a.total_hrs, a.total_hrs * e.rata_hora * a.factor_multi total_monto from (select d.compania, d.emp_id, d.tipo_he, t.descripcion, t.factor_multi, sum(nvl(cantidad, 0)) total_hrs from tbl_pla_st_det_disttur d, tbl_pla_t_horas_ext t where t.codigo = d.tipo_he and d.anio_pago = "+anio+" and d.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and d.emp_id = "+emp_id+" and d.compania = "+(String) session.getAttribute("_companyId")+" group by d.compania, d.emp_id, d.tipo_he, t.descripcion, t.factor_multi) a, tbl_pla_empleado e where a.emp_id = e.emp_id and a.compania = e.compania";
		
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
	parent.window.setTipoHorasDistOnLoad();
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
<%=fb.hidden("anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("quincena","")%>
<%=fb.hidden("index",index)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="5">Detalle de Sobretiempo Generado por Tipo de Extra</td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center">Cod.</td>
          <td align="center">Descripcion del Tipo</td>
          <td align="center">Total Hras.</td>
          <td align="center">Monto</td>
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
        <tr class="<%=color%>" align="center" onClick="javascript:parent.window.setTipoHorasDist(<%=i%>);" style="cursor:pointer">
          <td align="center"><%=fb.intBox("tipo_hextra"+i,cd.getColValue("tipo_hextra"),false,false,true,5,"text10","","")%></td>
          <td align="center"><%=fb.textBox("descripcion"+i,cd.getColValue("descripcion"),false,false,true,50,"text10","","")%></td>
          <td align="center"><%=fb.intBox("total_hrs"+i,cd.getColValue("total_hrs"),false,false,true,5,"text10","","")%></td>
          <td align="center"><%=fb.decBox("total_monto"+i,cd.getColValue("total_monto"),false,false,true,10,"text10","","")%></td>
          <td align="left"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:parent.window.setTipoHorasDist("+i+")\"")%></td>
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