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
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								
INF800982						CLASIFICACION DE ORDENES DE PAGO
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String compania = request.getParameter("compania");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="orden_pago";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		sql = "select a.cod_autorizacion, a.provincia_empleado, a.sigla_empleado, a.tomo_empleado, a.asiento_empleado, a.compania_empleado, a.cod_compania_autoriza, a.desde_cantidad, a.hasta_cantidad, a.usuario, a.emp_id, b.primer_nombre, b.primer_apellido, b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento cedula, b.primer_nombre||' '||b.primer_apellido nombre from tbl_cxp_autorizacion a, tbl_pla_empleado b where a.cod_compania_autoriza = " + compania + " and a.emp_id = b.emp_id";
			alTPR = SQLMgr.getDataList(sql);
			emp.clear();
			for(int i=0;i<alTPR.size();i++){
				CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					emp.put(key, cdo);
					empKey.put(cdo.getColValue("usuario"), key);
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
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/sel_empleado.jsp?fp=cuadro_autorizacion&mode=<%=mode%>&compania=<%=compania%>');

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


function doSubmit(action){
	document.form.baction.value 			= action;
	document.form.compania.value = parent.document.form1.compania.value;
	if(!formValidation()){
		formBlockButtons(fasle);
		return false
	} else {
		document.form.submit();
	}
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

function selUsuario(i){
	abrir_ventana('../common/check_user.jsp?fp=cuadro_autorizacion&id='+i);
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
<%=fb.hidden("compania",compania)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="5%">No.</td>
          <td align="center" width="18%"><cellbytelabel>C&eacute;dula</cellbytelabel> </td>
          <td align="center" width="10%"><cellbytelabel>C&iacute;a</cellbytelabel>.</td>
          <td align="center" width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Desde</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Hasta</cellbytelabel></td>
          <td align="center" width="17%" colspan="2"><%=fb.button("addClasic","Agregar",false,viewMode, "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
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
        <%=fb.hidden("cod_autorizacion"+i,cdo.getColValue("cod_autorizacion"))%>
        <%=fb.hidden("provincia_empleado"+i,cdo.getColValue("provincia_empleado"))%>
        <%=fb.hidden("sigla_empleado"+i,cdo.getColValue("sigla_empleado"))%>
        <%=fb.hidden("tomo_empleado"+i,cdo.getColValue("tomo_empleado"))%>
        <%=fb.hidden("asiento_empleado"+i,cdo.getColValue("asiento_empleado"))%>
        <%=fb.hidden("compania_empleado"+i,cdo.getColValue("compania_empleado"))%>
        <%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
        <%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
        <%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
        <%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
        <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=cdo.getColValue("cod_autorizacion")%></td>
          <td align="center"><%=cdo.getColValue("cedula")%></td>
          <td align="center"><%=cdo.getColValue("compania_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre")%></td>
          <td align="center"><%=fb.decBox("desde_cantidad"+i,cdo.getColValue("desde_cantidad"),true,false,false,10,10.2,"text10",null,"")%></td>
          <td align="center"><%=fb.decBox("hasta_cantidad"+i,cdo.getColValue("hasta_cantidad"),true,false,false,10,10.2,"text10",null,"")%></td>
          <td align="center">
					<%=fb.textBox("usuario"+i,cdo.getColValue("usuario"),true,false,true,15,"text10",null,"")%>
          <%=fb.button("addUsuario"+i,"...",false,viewMode, "", "", "onClick=\"javascript: selUsuario("+i+");\"")%>
          </td>
        </tr>
        <%}%>
      </table>
    </td>
  </tr>
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
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	emp.clear();
	empKey.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("usuario", request.getParameter("usuario"+i));
			cdo.addColValue("nombre", request.getParameter("nombre"+i));
			cdo.addColValue("cod_autorizacion", request.getParameter("cod_autorizacion"+i));
			cdo.addColValue("provincia_empleado", request.getParameter("provincia_empleado"+i));
			cdo.addColValue("sigla_empleado", request.getParameter("sigla_empleado"+i));
			cdo.addColValue("tomo_empleado", request.getParameter("tomo_empleado"+i));
			cdo.addColValue("asiento_empleado", request.getParameter("asiento_empleado"+i));
			cdo.addColValue("compania_empleado", request.getParameter("compania_empleado"+i));
			cdo.addColValue("primer_nombre", request.getParameter("primer_nombre"+i));
			cdo.addColValue("primer_apellido", request.getParameter("primer_apellido"+i));
			cdo.addColValue("desde_cantidad", request.getParameter("desde_cantidad"+i));
			cdo.addColValue("hasta_cantidad", request.getParameter("hasta_cantidad"+i));
			cdo.addColValue("cedula", request.getParameter("cedula"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("cod_compania_autoriza", request.getParameter("compania"));

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
			alTPR.add(cdo);
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../cxp/cuadro_autorizacion_det.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&compania="+compania);
		return;
	}
	

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OrdPagoMgr.saveCuadroAutorizacion(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=OrdPagoMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=OrdPagoMgr.getErrMsg()%>';
parent.document.form1.baction.value='<%=request.getParameter("baction")%>';
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