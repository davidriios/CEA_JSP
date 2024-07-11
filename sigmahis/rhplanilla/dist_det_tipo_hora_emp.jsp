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
boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && quincena != null && change == null && grupo != null && area != null){
		sql = "select distinct a.emp_id, a.provincia, a.sigla, a.tomo, a.asiento, b.num_empleado, b.primer_nombre || ' ' || decode (b.sexo,'F', decode (b.apellido_casada,null, b.primer_apellido, decode (b.usar_apellido_casada,'S', 'DE '|| b.apellido_casada,b.primer_apellido)), b.primer_apellido) nombre_empleado, a.compania, b.rata_hora, decode(a.provincia,0, ' ',00, ' ',10, '0',11, 'B',12, 'C',a.provincia) || rpad(decode(a.sigla,'00', '  ','0', '  ',a.sigla), 2,' ') || '-'|| lpad(to_char(a.tomo), 3, '0') || '-' || lpad(to_char (a.asiento), 6, '0') cedula, nvl(d.v_cantidad_horas, 0) total_horas, nvl(d.v_monto_pagar, 0) total_hrs_rec from tbl_pla_st_det_empleado a, tbl_pla_empleado b, tbl_pla_ct_empleado c, (select e.emp_id, sum(nvl(c.cantidad, 0)) v_cantidad_horas, sum(nvl(c.cantidad, 0) * nvl(h.factor_multi, 0)) v_monto_pagar from tbl_pla_st_det_disttur c, tbl_pla_t_horas_ext h, tbl_pla_empleado e where e.compania = "+(String) session.getAttribute("_companyId")+" and e.emp_id = c.emp_id and e.compania = c.compania and h.codigo = c.tipo_he and to_date(to_char(c.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fecha_inicio+"', 'dd/mm/yyyy') and to_date(to_char(c.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fecha_final+"', 'dd/mm/yyyy') group by e.emp_id) d where b.emp_id = a.emp_id and b.compania = a.compania and c.emp_id = a.emp_id and c.compania = a.compania and c.grupo = "+grupo+" and c.ubicacion_fisica = nvl("+area+", c.ubicacion_fisica) and (a.compania, a.emp_id, to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) in (select b.compania, b.emp_id, to_date(to_char(b.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') from tbl_pla_st_det_disttur b where b.compania = a.compania and b.emp_id = a.emp_id and b.anio_pago = "+anio+" and b.periodo_pago = decode("+quincena+", 1, ("+mes+" * 2)-1, "+mes+" * 2) and to_date(to_char(b.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy')) and a.emp_id = d.emp_id(+) order by b.num_empleado";

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
          <td align="center">Rata x Hora</td>
          <td align="center">Total Horas</td>
          <td align="center">&nbsp;</td>
          <td align="center">Total Pagar</td>
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
        <tr class="<%=color%>" align="center" style="cursor:pointer" onClick="javascript:parent.window.setTipoExtraValues(<%=i%>)">
          <td align="left"><%=cdo.getColValue("cedula")%></td>
          <td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre_empleado")%></td>
          <td align="right"><%=cdo.getColValue("rata_hora")%>&nbsp;&nbsp;</td>
          <td align="right"><%=cdo.getColValue("total_horas")%>&nbsp;&nbsp;</td>
          <td align="right"><%=cdo.getColValue("total_hrs_rec")%>&nbsp;&nbsp;</td>
          <td>&nbsp;</td>
          <td align="left"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:parent.window.setTipoExtraValues("+i+")\"")%></td>
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