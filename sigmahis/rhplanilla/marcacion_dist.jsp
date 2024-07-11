<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();

String mode = request.getParameter("mode");
String lote = request.getParameter("lote");
String secuencia = request.getParameter("secuencia");
String factor = request.getParameter("factor");
String grupo = request.getParameter("grupo");
String empId = request.getParameter("empId");
String nombre_empleado = request.getParameter("nombre");
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String cedula = request.getParameter("cedula");
String fechaMarc = request.getParameter("fecha");
String compania = (String) session.getAttribute("_companyId");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (lote == null) lote = "";
if (secuencia == null) secuencia = "";
if (factor == null) factor = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (grupo == null) grupo = "";
if (empId == null) empId = "";
if (fechaMarc == null) fechaMarc = "";

boolean viewMode = false;
if(mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
	sbSql.append("select  to_char(d.fecha, 'dd/mm/yyyy') fecha, d.cod_secuencia, d.codigo_marc_dist, d.marc_secuencia, d.emp_id, d.cantidad, d.factor, round(d.cantidad * d.factor * (select e.rata_hora from vw_pla_empleado e where e.emp_id = d.emp_id and e.estado = 1 and e.compania = d.compania ), 2) total, d.estado ,(select e.rata_hora from vw_pla_empleado e where e.emp_id = d.emp_id and e.estado = 1 and e.compania = d.compania ) rata from TBL_PLA_MARC_DIST_DET d where ");
	sbSql.append(" d.lote = ");
	sbSql.append(lote);
	sbSql.append(" and d.compania = ");
	sbSql.append(compania);
	sbSql.append(" and d.emp_id = ");
	sbSql.append(empId);
	if (!factor.equals("")) {
	sbSql.append(" and d.detalle_factor = '");
	sbSql.append(factor);
	sbSql.append("'");
	}
	if (!fechaMarc.equals("")) {
		sbSql.append(" and trunc(d.fecha) = ");
		sbSql.append(" to_date('");
		sbSql.append(fechaMarc);
		sbSql.append("','dd/mm/yyyy')");
		}
	sbSql.append(" order by 1,7 asc");
  
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Marcación - '+document.title;

function doAction(){}

function calcular() {
  for (i = 0; i<<%=al.size()%>; i++) {	
	  var cantidad = $("#cantidad"+i).val() || 0;
	  var factor = $("#factor_multi"+i).val() || 0;
	  var rata = $("#rata"+i).val() || 0;
	  total = 0;
	  
	  console.log(cantidad, factor, rata);
	  
	  if (cantidad && factor && rata) {
		  total = cantidad * factor * rata;
	  }
	  
	  $("#total"+i).val(total.toFixed(2));
  }
}

$(function() {
  $("input[name*='cantidad'], input[name*='factor_multi']").blur(function() {
      calcular();
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - DETALLE MARCACION"></jsp:param>
</jsp:include>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("lote",lote)%>
<%=fb.hidden("factor",factor)%>
<%=fb.hidden("fechaMarc",fechaMarc)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("size",""+al.size())%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1">
	  
	    <tr class="TextHeader01">
          <td align="center" colspan="4"> Nombre del Empleado : <%=fb.textBox("nombre_empleado",nombre_empleado,false,false,true,50,"text10","","")%> </td>
          <td align="center" colspan="2"> Cédula del Empleado : <%=fb.textBox("cedula",cedula,false,false,true,15,"text10","","")%> </td>
        </tr>
        
        <tr class="TextHeader02">
          <td align="center" width="15%">Fecha</td>
          <td align="center" width="15%">Cantidad</td>
          <td align="center" width="15%">Factor</td>
          <td align="center" width="15%">Rata por hora</td>
          <td align="center" width="15%">Total</td>
          <td align="center" width="20%">Estado</td>
        </tr>
		
		<%for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		%>
        <tr class="TextRow01">
          <td><%=fb.textBox("fecha"+i,cdo.getColValue("fecha"),false,false,true,10,"text10","","")%></td>
          <td><%=fb.decBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,10,10.5)%></td>
          <td><%=fb.decBox("factor_multi"+i,cdo.getColValue("factor"),false,false,false,10,10.5)%></td>
          <td><%=fb.decBox("rata"+i,cdo.getColValue("rata"),false,false,true,10,10.5)%></td>
          <td><%=fb.decBox("total"+i,cdo.getColValue("total"),false,false,true,10,10.2)%></td>
          <td>
          <%=fb.select("estado"+i,"A=Aprobado,P=Pendiente",cdo.getColValue("estado"),false,false,0,"",null,null,null,"")%>
          </td>
        </tr>
        
        <%=fb.hidden("cod_secuencia"+i,cdo.getColValue("cod_secuencia"))%>
        <%=fb.hidden("codigo_marc_dist"+i,cdo.getColValue("codigo_marc_dist"))%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
        <%=fb.hidden("marc_secuencia"+i,cdo.getColValue("marc_secuencia"))%>
		
		<%}%>
        
        <tr class="TextRow02">
          <td colspan="6"></td>
        </tr>
        <tr class="TextRow02">
          <td colspan="6" align="right">
            
            <%=fb.submit("save","Guardar",true,viewMode)%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin()\"")%>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>
</body>
</html>
<%
}//GET
else
{
  int size = Integer.parseInt(request.getParameter("size"));
  
  al.clear();
  
  for (int i = 0; i< size; i++) {
  
	  cdo = new CommonDataObject();
	  
	  cdo.setTableName("TBL_PLA_MARC_DIST_DET");
	  cdo.setWhereClause("cod_secuencia = "+request.getParameter("cod_secuencia"+i)+" and codigo_marc_dist = "+request.getParameter("codigo_marc_dist"+i)+" and emp_id = "+request.getParameter("emp_id"+i)+" and marc_secuencia = "+request.getParameter("marc_secuencia"+i));
	  cdo.setAction("U");
	  
	  cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
	  cdo.addColValue("estado", request.getParameter("estado"+i));
	  cdo.addColValue("total", request.getParameter("total"+i));
	  
      cdo.addColValue("fecha_modificacion", cDateTime);
      cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));

	  al.add(cdo);
  }
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
  SQLMgr.saveList(al,false);
  ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow(){
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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