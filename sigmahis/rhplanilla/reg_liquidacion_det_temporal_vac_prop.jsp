
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" 						scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" 						scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" 					scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" 						scope="page" 		class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" 								scope="page" 		class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" 						scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="del" 							scope="page" 		class="issi.rhplanilla.Empleado" />
<jsp:useBean id="htTempVacProp" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htTempVacPropKey" 	scope="session" class="java.util.Hashtable" />
<jsp:useBean id="AEmpMgr" 					scope="page" 		class="issi.rhplanilla.AccionesEmpleadoMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String fg = request.getParameter("fg");
String emp_id = request.getParameter("emp_id");
String fecha_egreso = request.getParameter("fecha_egreso");
String id ="";
String anio ="";
boolean viewMode = false;

if (mode == null) mode = "add";
if (fg == null) fg = "";
if (fecha_egreso == null) fecha_egreso = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoT = new CommonDataObject();


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	calcTotales();
	parent.newHeight();
}

function calcTotales(a)
{
	var iCounter = 0;
	var size = parseInt(document.form1.keySize.value);
	var sal_bruto = 0.00, gasto_rep = 0.00, prima_produccion = 0.00, xiii_mes = 0.00, vacaciones = 0.00, incentivo = 0.00, bonificacion = 0.00, otros = 0.00;
	var t_sal_bruto = 0.00, t_gasto_rep = 0.00, t_prima_produccion = 0.00, t_xiii_mes = 0.00, t_vacaciones = 0.00, t_incentivo = 0.00, t_bonificacion = 0.00, t_otros = 0.00;
	for(i=0;i<size;i++){
		sal_bruto 				= eval('document.form1.sal_bruto'+i).value;
		gasto_rep 				= eval('document.form1.gasto_rep'+i).value;
		if(!isNaN(sal_bruto) && sal_bruto!='') t_sal_bruto += parseFloat(sal_bruto);
		if(!isNaN(gasto_rep) && gasto_rep!='') t_gasto_rep += parseFloat(gasto_rep);
	}
	///t_sal_bruto += parent.window.buscaAcumulado(0);
	//alert(t_sal_bruto);
	var vp_salario = t_sal_bruto/11;
	var vp_gastorep = t_gasto_rep/11;
	document.form1.sal_bruto.value 					= t_sal_bruto.toFixed(2);
	document.form1.gasto_rep.value 					= t_gasto_rep.toFixed(2);
	parent.document.form4.vac_prop_sal.value 	= vp_salario.toFixed(2);
	
	parent.document.form3.vacp_salario.value 	= vp_salario.toFixed(2);
	parent.document.form3.vp_salario.value 	= vp_salario.toFixed(2);
	parent.document.form3.vp_gastorep.value	= vp_gastorep.toFixed(2);
	
	if (iCounter > 0) return true;
	else return false;
}

function calcThis(i){
	var salario=0.00, gasto_rep = 0.00, s_especie = 0.00;
	salario = eval('document.form1.sal_bruto'+i).value;
	gasto_rep = eval('document.form1.gasto_rep'+i).value;
	s_especie = eval('document.form1.salario_especie'+i).value;
	if(!isNaN(salario) && salario!='') calc();
	else if(salario != '' && isNaN(salario)){
		alert('Introduzca valores numéricos1');
		eval('document.form1.sal_bruto'+i).value = '';
	}
	if(!isNaN(gasto_rep) && gasto_rep!='') calc();
	else if(gasto_rep != '' && isNaN(gasto_rep)){
		alert('Introduzca valores numéricos2');
		eval('document.form1.gasto_rep'+i).value = '';
	}
	if(!isNaN(s_especie) && s_especie!='') calc();
	else if(s_especie != '' && isNaN(s_especie)){
		alert('Introduzca valores numéricos3');
		eval('document.form1.salario_especie'+i).value = '';
	}
}

function doSubmit(value)
{
	var fg = '<%=fg%>';
	document.form1.baction.value = value;
	document.form1.emp_id.value = parent.document.form0.emp_id.value;
	document.form1.segundo_nombre.value = parent.document.form0.segundo_nombre.value;
	document.form1.segundo_apellido.value = parent.document.form0.segundo_apellido.value;
	document.form1.primer_nombre.value = parent.document.form0.primer_nombre.value;
	document.form1.primer_apellido.value = parent.document.form0.primer_apellido.value;
	document.form1.provincia.value = parent.document.form0.provincia.value;
	document.form1.sigla.value = parent.document.form0.sigla.value;
	document.form1.tomo.value = parent.document.form0.tomo.value;
	document.form1.asiento.value = parent.document.form0.asiento.value;
	document.form1.num_empleado.value = parent.document.form0.num_empleado.value;

	if (!form1Validation()) return false;
  else document.form1.submit();
}

function setPerDetail(i){
	var periodo = eval('document.form1.periodo'+i).value;
	var x = getDBData('<%=request.getContextPath()%>', 'descripcion, decode(quincena1, '+periodo+', \'PRIMERA\', \'SEGUNDA\')','tbl_pla_vac_parametro','quincena1 = '+periodo+' or quincena2 = '+periodo,'');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		eval('document.form1.mes'+i).value	= arr_cursor[0];
		eval('document.form1.quincena'+i).value	= arr_cursor[1];
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%//=fb.hidden("size",""+DI.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fecha_egreso",fecha_egreso)%>

<%=fb.hidden("emp_id","")%>
<%=fb.hidden("segundo_nombre","")%>
<%=fb.hidden("segundo_apellido","")%>
<%=fb.hidden("primer_nombre","")%>
<%=fb.hidden("primer_apellido","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("num_empleado","")%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td>Secuencia</td>
	<td>A&ntilde;o</td>
	<td>Periodo</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>Salario</td>
	<td>Gasto de Rep.</td>
	<td>
	<%=fb.submit("btnagregar","+",false,viewMode,"","","onClick=\"javascript:document.form1.baction.value=this.value\"")%>
  </td>
</tr>
<%
if (htTempVacProp.size() > 0) al = CmnMgr.reverseRecords(htTempVacProp);

for (int i=0; i<htTempVacProp.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) htTempVacProp.get(key);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>
<tr class="<%=color%>" align="center">
  <td>
	<%=fb.intBox("secuencia"+i,cdo.getColValue("secuencia"),false,false,true,4)%>
  </td>
  <td>
	<%=fb.intBox("anio"+i,cdo.getColValue("anio"),false,false,false,4)%>
  </td>
  <td>
	<%=fb.intBox("periodo"+i,cdo.getColValue("periodo"),false,false,false,4,null,null,"onChange=\"javascript:setPerDetail("+i+")\"")%>
  </td>
  <td>
	<%=fb.textBox("mes"+i,cdo.getColValue("mes"),false,false,true,30,"text10","","")%>
  </td>
  <td>
	<%=fb.textBox("quincena"+i,cdo.getColValue("quincena"),false,false,true,30,"text10","","")%>
  </td>
	<td>
	<%=fb.decBox("sal_bruto"+i,cdo.getColValue("sal_bruto"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcTotales('sb')\"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("gasto_rep"+i,cdo.getColValue("gasto_rep"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcTotales('gr')\"","",false,"")%>
  </td>
	<td><%=fb.submit("del"+i,"x",false,viewMode)%></td>
</tr>
<%
}
%>
<tr class="textHeader02" align="center">
  <td colspan="5">
  </td>
	<td>
	<%=fb.decBox("sal_bruto","",false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("gasto_rep","",false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow02">
  <td colspan="8" align="right"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%></td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{

	System.out.println("_________________________________________________________________");
	String dl = "", close = "true";
	
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	
	int ln = 0;
	htTempVacProp.clear();
	htTempVacPropKey.clear();
	ArrayList alTVP = new ArrayList();
	for (int i=0; i<keySize; i++){
		if(request.getParameter("del"+i) == null){
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("emp_id", request.getParameter("emp_id"));
			if (request.getParameter("fecha_inicio"+i) != null && !request.getParameter("fecha_inicio"+i).equals("")) cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+i));
			if (request.getParameter("anio"+i) != null && !request.getParameter("anio"+i).equals("")) cdo.addColValue("anio", request.getParameter("anio"+i));
			if (request.getParameter("secuencia"+i) != null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			if (request.getParameter("periodo"+i) != null && !request.getParameter("periodo"+i).equals("")) cdo.addColValue("periodo", request.getParameter("periodo"+i));
			if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals("")) cdo.addColValue("emp_id", request.getParameter("emp_id"));
			
			if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) cdo.addColValue("provincia", request.getParameter("provincia"));
			
			if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) cdo.addColValue("sigla", request.getParameter("sigla"));
			
			if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) cdo.addColValue("tomo", request.getParameter("tomo"));
			
			if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) cdo.addColValue("asiento", request.getParameter("asiento"));
			if (request.getParameter("mes"+i) != null && !request.getParameter("mes"+i).equals("")) cdo.addColValue("mes", request.getParameter("mes"+i));
			if (request.getParameter("quincena"+i) != null && !request.getParameter("quincena"+i).equals("")) cdo.addColValue("quincena", request.getParameter("quincena"+i));
			
			if (request.getParameter("sal_bruto"+i) != null && !request.getParameter("sal_bruto"+i).equals("")) cdo.addColValue("sal_bruto", request.getParameter("sal_bruto"+i));
			
			if (request.getParameter("gasto_rep"+i) != null && !request.getParameter("gasto_rep"+i).equals("")) cdo.addColValue("gasto_rep", request.getParameter("gasto_rep"+i));

			
			try{
				ln++;
				if (ln < 10) key = "00"+ln;
				else if (ln < 100) key = "0"+ln;
				else key = ""+ln;

				htTempVacProp.put(key,cdo);
				htTempVacPropKey.put(cdo.getColValue("secuencia"),key);
				alTVP.add(cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else dl = "1";
	}
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("+")){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("fecha_inicio", request.getParameter("fecha_egreso"));
		cdo.addColValue("anio", "");
		cdo.addColValue("secuencia", "0");
		cdo.addColValue("periodo", "");
		if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals("")) cdo.addColValue("emp_id", request.getParameter("emp_id"));
		
		if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("")) cdo.addColValue("provincia", request.getParameter("provincia"));
		
		if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) cdo.addColValue("sigla", request.getParameter("sigla"));
		
		if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) cdo.addColValue("tomo", request.getParameter("tomo"));
		
		if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) cdo.addColValue("asiento", request.getParameter("asiento"));
		
		cdo.addColValue("sal_bruto", "0");
		
		cdo.addColValue("gasto_rep", "0");
		
		try{
			ln++;
			if (ln < 10) key = "00"+ln;
			else if (ln < 100) key = "0"+ln;
			else key = ""+ln;

			htTempVacProp.put(key,cdo);
			htTempVacPropKey.put(cdo.getColValue("secuencia"),key);
			//System.out.println("Adding item...");
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	if(!dl.equals("") || clearHT.equals("S") || (request.getParameter("baction")!=null && request.getParameter("baction").equals("+"))){
		response.sendRedirect("../rhplanilla/reg_liquidacion_det_temporal_vac_prop.jsp?mode="+mode+ "&change=1&type=2&emp_id="+emp_id+"&fecha_egreso="+request.getParameter("fecha_egreso"));
		return;
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		AEmpMgr.saveTemporalVacProp(alTVP);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%
	if(AEmpMgr.getErrCode().equals("1")){
	%>
		alert('<%=AEmpMgr.getErrMsg()%>');
		window.location = '../rhplanilla/reg_liquidacion_det_temporal_vac_prop.jsp?emp_id=<%=request.getParameter("emp_id")%>&fecha_egreso=<%=request.getParameter("fecha_egreso")%>';
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
