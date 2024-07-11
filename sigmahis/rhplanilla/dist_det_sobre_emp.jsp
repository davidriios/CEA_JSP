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
String appendFilter = "";
boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
 if (request.getParameter("grupo") != null && !request.getParameter("grupo").trim().equals(""))
  {
    appendFilter += " and a.ue_codigo = c.grupo and c.grupo = "+request.getParameter("grupo");
	grupo = request.getParameter("grupo");
  }
 if (request.getParameter("area") != null && !request.getParameter("area").trim().equals(""))
  {
    appendFilter += " and c.ubicacion_fisica = "+request.getParameter("area");
	area = request.getParameter("area");
  }

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && quincena != null && change == null && grupo != null ){
		sql = "select distinct a.provincia, a.sigla, a.tomo, a.asiento, b.num_empleado, b.primer_nombre || ' ' || decode(b.sexo, 'F', decode(b.apellido_casada, null, b.primer_apellido, decode(b.usar_apellido_casada, 'S', 'DE ' || b.apellido_casada, b.primer_apellido)), b.primer_apellido) nombre_empleado, a.compania, b.rata_hora, decode(a.provincia, 0, ' ', 00, ' ', 10, '0', 11, 'B', 12, 'C', a.provincia) || rpad(decode(a.sigla, '00', '  ', '0', '  ', a.sigla), 2, ' ')|| '-'|| lpad(to_char(a.tomo), 3, '0')|| '-'|| lpad(to_char(a.asiento), 6, '0') cedula, b.emp_id, d.total_horas, e.total_horas_aprob from tbl_pla_st_det_disttur a, tbl_pla_empleado b, tbl_pla_ct_empleado c, (select emp_id, sum(nvl(cantidad, 0)) total_horas from tbl_pla_st_det_disttur where compania = "+(String) session.getAttribute("_companyId")+" and (generado = 'N' or generado is null) and anio_pago = "+anio+" and periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) group by emp_id) d, (select emp_id, count(*) total_horas_aprob from tbl_pla_st_det_turext where compania = "+(String) session.getAttribute("_companyId")+" and aprobado = 'S' and anio_pago = "+anio+" and periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) group by emp_id) e where  a.anio_pago = "+anio+" and a.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and b.emp_id = a.emp_id and b.compania = a.compania and c.emp_id = a.emp_id and c.compania = a.compania "+appendFilter+" and b.emp_id = d.emp_id(+) and b.emp_id = e.emp_id(+) order by b.num_empleado";

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

function doSubmit(action){
}

function setDiasValues(i){
	checkRadioButton(document.form.rb, i);
	parent.window.setDiasValuesOnLoad();
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
          <td align="center">C&eacute;dula</td>
          <td align="center">No. Empl.</td>
          <td align="center">Nombre Empleado</td>
          <td align="center">Cant.</td>
          <td align="center">Total Hras</td>
          <td align="center">&nbsp;</td>
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
        <%=fb.hidden("cedula"+i, cdo.getColValue("cedula"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>
        <%=fb.hidden("rata_hora"+i, cdo.getColValue("rata_hora"))%>
        <%=fb.hidden("total_horas"+i, cdo.getColValue("total_horas"))%>
        <%=fb.hidden("total_hras_aprob"+i, cdo.getColValue("total_hras_aprob"))%>
        <tr class="<%=color%>" align="center" onClick="javascript:setDiasValues(<%=i%>)" style="cursor:pointer">
          <td align="left"><%=cdo.getColValue("cedula")%></td>
          <td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre_empleado")%></td>
          <td align="center"><%=cdo.getColValue("total_horas_aprob")%></td>
          <td align="center"><%=cdo.getColValue("total_horas")%></td>
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