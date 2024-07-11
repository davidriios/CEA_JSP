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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");

boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql="select periodo, to_char(trans_desde,'dd/mm/yyyy') as trans_desde, to_char(trans_hasta,'dd/mm/yyyy') as trans_hasta, to_char(fecha_cierre,'dd/mm/yyyy') as fechaCierre, to_char(fecha_final,'dd/mm/yyyy') as fechaFinal, to_char(fecha_inicial,'dd/mm/yyyy') as fechaInicial, to_char(fecha_inicial,'FMMONTH','NLS_DATE_LANGUAGE = SPANISH') as mes, decode(mod(periodo,2),'0','2da','1ra')||' '|| to_char(to_date(fecha_inicial,'dd/mm/yyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') quincena, to_char(fecha_cierre + 1,'dd/mm/yyyy') fechaEntrega, to_char(fecha_inicial,'yyyy') anio from tbl_pla_calendario where  fecha_cierre < to_date('"+cDateTime+"','dd/mm/yyyy') and tipopla=1 order by periodo desc";
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

function selTurno(name){
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_turno.jsp?fp=programa_turno_borrador&index='+name);
	<%
	}
	%>
}

function selUbicacion(name){
	var quincena = parent.document.form1.quincena.value;
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_area.jsp?fp=programa_turno_borrador&index='+name+'&quincena='+quincena);
	<%
	}
	%>
}

function chkNumEmpleado(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true && eval('document.form.num_empleado'+i).value==''){
			alert('Esta acción de ingreso no le ha registrado el número de empleado, esta es una información de vital importancia por lo que no podrá actualizar la acción!!!');
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}

function chkSelected(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

function chkValue() {
var size = <%=alTPR.size()%>;
var count = 0;
	for (i=0;i<size;i++){
			if (eval('document.form.chk'+i).checked == true){
				 	count++;
			}
	  }
		
	  if (count>1){      
			unCheckAll('1');
		} else if (count==0 ){
			alert('Por favor seleccione al menos un empleado !');
			return false;
		}	 
}

function unCheckAll(op) {
  var size = <%=alTPR.size()%>;
   if (op == '1')
   {
      alert('No es permitido seleccionar más de 1 Calendario a la vez !');
   }
   for (i=0;i<size;i++)
   {
      eval("document.form.chk"+i).checked = false;
   }
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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>

<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="6%">Periodo</td>
          <td align="center" width="15%">Quincena</td>
          <td align="center" width="15%">Fecha Inicio</td>
          <td align="center" width="15%">FechaFinal</td>
          <td align="center" width="15%">Fecha Inicio</td>
          <td align="center" width="15%">Fecha Final</td>
          <td align="center" width="15%">FechaEntrega</td>
					<td align="center" width="4%">&nbsp;</td>
		
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
        <%=fb.hidden("anio"+i, cdo.getColValue("anio"))%>
        <%=fb.hidden("periodo"+i, cdo.getColValue("periodo"))%>
        <%=fb.hidden("quincena"+i, cdo.getColValue("quincena"))%>
        <%=fb.hidden("fechaInicial"+i, cdo.getColValue("fechaInicial"))%>
        <%=fb.hidden("fechaFinal"+i, cdo.getColValue("fechaFinal"))%>
        <%=fb.hidden("fechaDesde"+i, cdo.getColValue("trans_desde"))%>
        <%=fb.hidden("fechaHasta"+i, cdo.getColValue("trans_hasta"))%>
        <%=fb.hidden("fechaEntrega"+i, cdo.getColValue("fechaEntrega"))%>
       
        <tr class="<%=color%>" align="center">
       
        <td align="left"><%=cdo.getColValue("periodo")%></td>
        <td align="left"><%=cdo.getColValue("quincena")%></td>
        <td align="center"><%=cdo.getColValue("fechaInicial")%></td>
        <td align="center"><%=cdo.getColValue("fechaFinal")%></td>
        <td align="center"><%=cdo.getColValue("trans_desde")%></td>
				<td align="center"><%=cdo.getColValue("trans_hasta")%></td>
        <td align="center"><%=cdo.getColValue("fechaEntrega")%></td>
        <td align="center"><%=fb.checkbox("chk"+i, ""+i, false, false, "Text10", "", "onClick=\"javascript:chkValue("+i+");\"")%></td>
         
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
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	emp.clear();
	lineNo = 0;
	
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=AEmpMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=AEmpMgr.getErrMsg()%>';
parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>