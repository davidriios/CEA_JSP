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
String fecha = request.getParameter("fecha");
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
	if(emp_id != null && fecha != null && change == null){
		sql = "select to_char(a.entrada, 'hh12:mi am') entrada, to_char(a.salida_com, 'hh12:mi am') salida_com, to_char(a.entrada_com, 'hh12:mi am') entrada_com, to_char(a.salida, 'hh12:mi am') salida, decode(a.programa, 'S', (select to_char(hora_entrada, 'hh:mi') || decode(hora_rec_salida, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_rec_salida, 'hh:mi') || ' / ' || to_char(hora_rec_entrada, 'hh:mi') || '-'|| to_char(hora_salida, 'hh:mi')) /*into :mar.dsp_turno*/ from tbl_pla_ct_turno where compania = a.compania and codigo = a.turno), (select to_char(hora_entrada,'hh:mi') || decode(hora_salida_almuerzo, null, ' / ' || to_char(hora_salida, 'hh:mi'), '-' || to_char(hora_salida_almuerzo, 'hh:mi') || ' / ' || to_char(hora_entrada_almuerzo, 'hh:mi') || '-' || to_char(hora_salida, 'hh:mi')) /*into :mar.dsp_turno*/ from tbl_pla_horario_trab where compania = a.compania and codigo = a.turno)) dsp_turno, turno, programa, to_char(to_date('"+fecha+"', 'dd/mm/yyyy'),'FMDAY DD \"DE\" MONTH \"DE\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') dia_largo from tbl_pla_marcacion a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = "+emp_id+" and dia = to_number(to_char(to_date('"+fecha+"', 'dd/mm/yyyy'), 'dd')) and mes = to_number(to_char(to_date('"+fecha+"', 'dd/mm/yyyy'), 'mm')) and anio = to_number(to_char(to_date('"+fecha+"', 'dd/mm/yyyy'), 'yyyy'))";
		System.out.println("SQL MARCACIONES\n"+sql);
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
	<%if(!index.equals("")){%>
	parent.window.setMarPostTurno(<%=index%>);
	<%}%>
	setTurnoValuesOnLoad();
}

function doSubmit(action){
}

function setTurnoValues(i){
	var turno = eval('document.form.turno'+i).value;
	var programa = eval('document.form.programa'+i).value;
	var dsp_turno = eval('document.form.dsp_turno'+i).value;
	var dia_largo = eval('document.form.dia_largo'+i).value;
	if(programa == 'S') document.form.chk_programa.checked = true;
	else document.form.chk_programa.checked = false;
	document.form.turno.value = turno;
	document.form.dsp_turno.value = dsp_turno;
	document.form.dia_largo.value = dia_largo;
}

function setTurnoValuesOnLoad(){
	var size = <%=alTPR.size()%>;
	if(size>0) setTurnoValues(0);
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
          <td align="center" colspan="4"><%=fb.textBox("dia_largo","",false,false,true,40,"text10","","")%></td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="4">Turno Asignado / Marcaci&oacute;n</td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="4">
          <%=fb.checkbox("chk_programa","",false,true)%>
          <%=fb.textBox("turno","",false,false,true,4,"text10","","")%>
          <%=fb.textBox("dsp_turno","",false,false,true,30,"text10","","")%>
          </td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="center">Entrada</td>
          <td align="center">Salida C.</td>
          <td align="center">Entrada C.</td>
          <td align="center">Salida</td>
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
        <%=fb.hidden("programa"+i,cd.getColValue("programa"))%>
        <%=fb.hidden("dsp_turno"+i,cd.getColValue("dsp_turno"))%>
        <%=fb.hidden("dia_largo"+i,cd.getColValue("dia_largo"))%>
        <tr class="<%=color%>" align="center" onClick="javascript:setTurnoValues(<%=i%>);" style="cursor:pointer">
          <td align="center"><%=fb.textBox("entrada"+i,cd.getColValue("entrada"),false,false,true,10,"text10","","")%></td>
          <td align="center"><%=fb.textBox("salida_com"+i,cd.getColValue("salida_com"),false,false,true,10,"text10","","")%></td>
          <td align="center"><%=fb.textBox("entrada_com"+i,cd.getColValue("entrada_com"),false,false,true,10,"text10","","")%></td>
          <td align="center"><%=fb.textBox("salida"+i,cd.getColValue("salida"),false,false,true,10,"text10","","")%></td>
        </tr>
        <%}%>
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="4">Turno Posterior Asignado</td>
        </tr>
        <tr class="TextHeader02" height="21">
          <td align="left" colspan="4">
          <%=fb.checkbox("chk_post_programa","",false,true)%>
          <%=fb.textBox("post_codigo","",false,false,true,4,"text10","","")%>
          <%=fb.textBox("post_turno_descripcion","",false,false,true,30,"text10","","")%>
          </td>
        </tr>
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