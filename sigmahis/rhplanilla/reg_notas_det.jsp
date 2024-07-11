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
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String emp_id = request.getParameter("emp_id");
int lineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
boolean viewMode = false;

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		String sqlNotas = "select compania, provincia, sigla, tomo, asiento, codigo, to_char(fecha, 'dd/mm/yyyy') fecha, descripcion, emp_id from tbl_pla_notas where emp_id = "+emp_id;
		ArrayList alNotas = SQLMgr.getDataList(sqlNotas);
		for(int i = 0; i<alNotas.size(); i++){
			CommonDataObject cdo = (CommonDataObject) alNotas.get(i);
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try{
				emp.put(key, cdo);
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
	newHeight();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function getCodigo(i){
	abrir_ventana('../common/sel_cod_axa.jsp?fp=<%=fp%>&index='+i);
}

function doSubmit(action){
	var x = 0;
	document.form.baction.value 			= action;
	document.form.provincia.value 				= parent.document.form1.provincia.value;
	document.form.sigla.value 				= parent.document.form1.sigla.value;
	document.form.tomo.value 		= parent.document.form1.tomo.value;
	document.form.asiento.value 	= parent.document.form1.asiento.value;
	document.form.emp_id.value 	= parent.document.form1.emp_id.value;

	if(!parent.form1Validation()){}
	else {
		if(action != 'Guardar') parent.form1BlockButtons(false);
		if(action == 'Guardar' && !formValidation()){parent.form1BlockButtons(false);}
		if(action == 'Guardar' && !chkValues()){
			parent.form1BlockButtons(false);
			alert('Descripción en blanco no permitida!');
		} else {
			formBlockButtons(false);
			document.form.submit();
		}
		//else if(action == 'Guardar' && formValidation()) document.form.submit();
	}
}


function chkValues(){
	var size = <%=emp.size()%>;
	x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.descripcion'+i).value==''){
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}

function calcMonto(i){
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
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("emp_id",emp_id)%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="8" align="right"><%=fb.button("AddEmploys","+",false,false,"", "", "onClick=\"javascript:doSubmit(this.value)\"")%></td>
</tr>
  <tr class="TextHeader02">
    <td align="center">&nbsp;C&oacute;digo</td>
    <td align="center">&nbsp;Fecha</td>
    <td align="center">&nbsp;Descripci&oacute;n</td>
    <td align="center">&nbsp;</td>
  </tr>
  <%
	if (emp.size() > 0) al = CmnMgr.reverseRecords(emp);
	for (int i=0; i<emp.size(); i++){
		key = al.get(i).toString();
		CommonDataObject ad = (CommonDataObject) emp.get(key);
	
		String color = "";
		String fecha_nota= "fecha"+i;
		if (i%2 == 0) color = "TextRow02";
		else color = "TextRow01";
		boolean readonly = true;
	%>
	
	<%=fb.hidden("emp_id"+i, ad.getColValue("emp_id"))%>
  <%=fb.hidden("provincia"+i, ad.getColValue("provincia"))%>
  <%=fb.hidden("sigla"+i, ad.getColValue("sigla"))%>
  <%=fb.hidden("tomo"+i, ad.getColValue("tomo"))%>
  <%=fb.hidden("asiento"+i, ad.getColValue("asiento"))%>
  <%=fb.hidden("estado"+i, ad.getColValue("estado"))%>
  <tr class="<%=color%>" align="center">
    <td>
		<%=fb.intBox("codigo"+i,ad.getColValue("codigo"),false,false,true,5,5,"Text10",null,"")%>
    </td>
    <td>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="<%=fecha_nota%>"/>						
      <jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha")==null)?fecha:ad.getColValue("fecha")%>" />
      </jsp:include>
    </td>
    <td>Observaci&oacute;n:<%=fb.textarea("descripcion"+i,ad.getColValue("descripcion"),false,false,false,77,1)%></td>
    <td align="center"><%=fb.submit("del"+i, "x", false, false, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%></td>
  </tr>
  <%
}
%>
</table>
<%=fb.hidden("keySize",""+emp.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	System.out.println("-----------------------POST-----------------------1");
	
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	emp.clear();
	al.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("provincia", request.getParameter("provincia"+i));
			cdo.addColValue("sigla", request.getParameter("sigla"+i));
			cdo.addColValue("tomo", request.getParameter("tomo"+i));
			cdo.addColValue("asiento", request.getParameter("asiento"+i));
			cdo.addColValue("fecha", request.getParameter("fecha"+i));
			cdo.addColValue("codigo", request.getParameter("codigo"+i));
			cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try{
				emp.put(key, cdo);
				al.add(cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else {
			System.out.println("-----------------------POST-----------------------5");
			dl = "1";
		}
	}
	lineNo = emp.size();
	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("+")){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("emp_id", request.getParameter("emp_id"));
		cdo.addColValue("provincia", request.getParameter("provincia"));
		cdo.addColValue("sigla", request.getParameter("sigla"));
		cdo.addColValue("tomo", request.getParameter("tomo"));
		cdo.addColValue("asiento", request.getParameter("asiento"));
		cdo.addColValue("fecha", fecha);
		cdo.addColValue("descripcion", "");
		cdo.addColValue("codigo", "0");
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		try{
			emp.put(key, cdo);
			al.add(cdo);
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../rhplanilla/reg_notas_det.jsp?mode="+mode+"&change=1&type=2&emp_id="+emp_id);
		return;
	}

	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("+")){
		response.sendRedirect("../rhplanilla/reg_notas_det.jsp?mode="+mode+"&change=1&type=1&emp_id="+emp_id);
		return;
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AEmpMgr.addNotas(al);
		ConMgr.clearAppCtx(null);
	}
	
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (AEmpMgr.getErrCode().equals("1"))
{
%>
	alert('<%=AEmpMgr.getErrMsg()%>');
	parent.window.location='<%=request.getContextPath()%>/rhplanilla/reg_notas.jsp?emp_id=<%=emp_id%>';
	
<%
} else throw new Exception(AEmpMgr.getErrMsg());
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