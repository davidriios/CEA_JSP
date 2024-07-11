<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEMgr" scope="page" class="issi.rhplanilla.AsistenciaEmpMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="falHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fal" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");

String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String empId = request.getParameter("empId");
String numEmpleado = request.getParameter("numEmpleado");

String seccion = "";
String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
int falLastLineNo = 0;
int count = 0;
CommonDataObject pac = new CommonDataObject();

if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("falLastLineNo") != null && !request.getParameter("falLastLineNo").equals("")) falLastLineNo = Integer.parseInt(request.getParameter("falLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET")){
   if (change == null){
			if(empId != null && !empId.equals("")){
				sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre||' '||a.primer_apellido as nombre, a.primer_nombre, a.primer_apellido, nvl(a.ubic_seccion,a.seccion) as seccion, b.descripcion, a.emp_id, a.estado, a.num_empleado from tbl_pla_empleado a, tbl_sec_unidad_ejec b where a.compania = b.compania and nvl(a.ubic_seccion, a.seccion) = b.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id = "+empId+"";
				pac = SQLMgr.getData(sql);

			 falHash.clear();
			 falLastLineNo ++;

			 date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

			 fal = new CommonDataObject();
			 fal.addColValue("fecha","");
			 fal.addColValue("desde","");
			 fal.addColValue("hasta","");
			 falHash.put(key,fal);
		 }
   }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Fallecimiento Del Empleado - '+document.title;

function doSubmit(){
	 document.formFallecimiento.save.disableOnSubmit = true;
	 if(formFallecimientoValidation()){
		 if(document.formFallecimiento.fecha.value != ''){
				document.formFallecimiento.submit();
		 } else {
		 	alert('Introduzca Fecha de Fallecimiento');
			formFallecimientoBlockButtons(false);
		}
	 }
}
function doAction(){
}

function addPariente(){
	var empId = document.formFallecimiento.empId.value;
  abrir_ventana1("../common/search_pariente.jsp?fp=fallecimiento_empleado&empId="+empId);
}

function addPais(){
	abrir_ventana1("../common/search_ubicacion_geo.jsp?fp=fallecimiento_empleado");
}

function setValor(){
	document.formFallecimiento.desde.value = document.formFallecimiento.fecha.value;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
            <%fb = new FormBean("formFallecimiento",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("falLastLineNo",""+falLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("grupo",grupo)%>

			<%=fb.hidden("provincia",pac.getColValue("provincia"))%>
      <%=fb.hidden("sigla",pac.getColValue("sigla"))%>
      <%=fb.hidden("tomo",pac.getColValue("tomo"))%>
      <%=fb.hidden("asiento",pac.getColValue("asiento"))%>
      <%=fb.hidden("numEmpleado",pac.getColValue("num_empleado"))%>
      <%=fb.hidden("empId",empId)%>

			<tr>
      	<td colspan="4">
        	<table width="100%">
          	<tr class="TextPanel">
              <td align="right">C&eacute;d.:&nbsp;</td>
              <td><%=pac.getColValue("cedula")%></td>
              <td align="right">Nombre:&nbsp;</td>
              <td><%=pac.getColValue("nombre")%></td>
              <td align="right">Ubicaci&oacute;n:&nbsp;</td>
              <td><%=pac.getColValue("descripcion")%></td>
             </tr></table></td>
			</tr>
			<tr class="TextRow01">
        <td width="14%"> </td>
        <td width="38%"> REGISTRO DE FALLECIMIENTOS Y SUBSIDIOS </td>
        <td width="14%"> </td>
        <td width="34"> </td>
			</tr>

				<tr class="TextRow02">
					<td width="14%">Pariente</td>
				  <td width="38%"><%=fb.intBox("pariente",fal.getColValue("pariente"),true,false,true,5,2)%><%=fb.textBox("parienteDesc",fal.getColValue("parienteDesc"),true,false,true,25,61)%><%=fb.button("btnpariente","...",true,false,null,null,"onClick=\"javascript:addPariente()\"")%></td>
					<td width="14%">F. Fallecimiento</td>
					<td width="34%"><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha"/>
						<jsp:param name="valueOfTBox1" value="<%=(fal.getColValue("fecha")==null)?"":fal.getColValue("fecha")%>" />
            <jsp:param name="jsEvent" value="setValor();"/>
						</jsp:include>					</td>
				</tr>
				<tr class="TextRow01">
				    <td>Parentesco</td>
					<td><%=fb.textBox("parentesco",fal.getColValue("parentesco"),false,false,true,20,60)%></td>
					<td>País</td>
					<td><%=fb.intBox("pais_en",fal.getColValue("pais_en"),true,false,true,3,4)%><%=fb.textBox("paisDesc",fal.getColValue("paisDesc"),false,false,true,23,100)%><%=fb.button("btnpais","...",true,false,null,null,"onClick=\"javascript:addPais()\"")%></td>
			    </tr>
				<tr class="TextRow02">
				    <td>Subsidio</td>
					<td><%=fb.checkbox("recibe_subsidio","S",(fal.getColValue("recibe_subsidio")!=null && fal.getColValue("recibe_subsidio").equalsIgnoreCase("S")),false)%>&nbsp;&nbsp;Valor Subsidio&nbsp;&nbsp;<%=fb.decBox("valor_subsidio",fal.getColValue("valor_subsidio"),false,false,false,10,8.2)%></td>
					<td>Provincia</td>
					<td><%=fb.intBox("provincia_en",fal.getColValue("provincia_en"),true,false,true,3,2)%><%=fb.textBox("provinciaDesc",fal.getColValue("provinciaDesc"),false,false,true,23,25)%></td>
				</tr>
				<tr class="TextRow01">
				    <td>Descto x Duelo</td>
					<td><%=fb.checkbox("descto_x_duelo","S",(fal.getColValue("descto_x_duelo")!=null && fal.getColValue("descto_x_duelo").equalsIgnoreCase("S")),false)%>&nbsp;&nbsp;Total Emp. Activos&nbsp;&nbsp;<%=fb.intBox("total_empleados","",false,false,false,5,4)%></td>
					<td>Distrito</td>
          <td><%=fb.intBox("distrito_en",fal.getColValue("distrito_en"),true,false,true,3,3)%><%=fb.textBox("distritoDesc",fal.getColValue("distritoDesc"),false,false,true,23,150)%></td>
				</tr>
				<tr class="TextRow02">
				    <td>Monto Total x Descto x Duelo</td>
					<td><%=fb.decBox("totalDescto","",false,false,true,10,10)%></td>
					<td colspan="2">
                  <jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="2" />
									<jsp:param name="nameOfTBox1" value="desde" />
									<jsp:param name="valueOfTBox1" value="<%=fal.getColValue("desde")%>" />
									<jsp:param name="nameOfTBox2" value="hasta" />
									<jsp:param name="valueOfTBox2" value="<%=fal.getColValue("hasta")%>" />

									</jsp:include>					</td>
				</tr>
				<tr class="TextRow01">
				    <td>Comentario</td>
					<td colspan="2"><%=fb.textarea("comentario",fal.getColValue("comentario"),false,false,false,30,3)%></td>
					<td>Estado&nbsp;&nbsp;<%=fb.select("estado","PE=Pendiente,PA=Actualizado",fal.getColValue("estado"))%></td>
				</tr>
			<!--	<tr class="TextRow01">
					<td align="right"><%//=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
				</tr> -->
				<tr class="TextRow02" >
&nbsp;&nbsp;&nbsp;			    </tr>
				<%
				     //Si error--, quita el error. Si error++, agrega el error.
				    // js += "if(document."+fb.getFormName()+".valor"+i+".value=='')error--;";
					//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");
				%>
				<tr class="TextRow01">
					<td align="right" colspan="4"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close();\"")%>					</td>
				</tr>
            <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{

		CommonDataObject cdo = new CommonDataObject();
    area = request.getParameter("area");
		//cdo.setTableName("tbl_pla_pariente_muerte");
    //cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area);
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("provincia",request.getParameter("provincia"));
		cdo.addColValue("sigla",request.getParameter("sigla"));
		cdo.addColValue("tomo",request.getParameter("tomo"));
		cdo.addColValue("asiento",request.getParameter("asiento"));
    cdo.addColValue("pariente",request.getParameter("pariente"));
		cdo.addColValue("fecha",request.getParameter("fecha"));
		cdo.addColValue("pais_en",request.getParameter("pais_en"));
		cdo.addColValue("provincia_en",request.getParameter("provincia_en"));
		cdo.addColValue("distrito_en",request.getParameter("distrito_en"));
		if(request.getParameter("recibe_subsidio")!=null && !request.getParameter("recibe_subsidio").equals("")) cdo.addColValue("recibe_subsidio","S");
		else cdo.addColValue("recibe_subsidio","N");
		if(request.getParameter("descto_x_duelo")!=null && !request.getParameter("descto_x_duelo").equals("")) cdo.addColValue("descto_x_duelo","S");
		else cdo.addColValue("descto_x_duelo","N");
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("estado_descto","PE");
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		cdo.addColValue("emp_id",request.getParameter("empId"));
		if(request.getParameter("desde")!=null && !request.getParameter("desde").equals("")) cdo.addColValue("fecha_salida",request.getParameter("desde"));
		if(request.getParameter("hasta")!=null && !request.getParameter("hasta").equals("")) cdo.addColValue("fecha_regreso",request.getParameter("hasta"));
		if(request.getParameter("valor_subsidio")!=null && !request.getParameter("valor_subsidio").equals("")) cdo.addColValue("valor_subsidio",request.getParameter("valor_subsidio"));
		if(request.getParameter("total_empleados")!=null && !request.getParameter("total_empleados").equals("")) cdo.addColValue("total_empleados",request.getParameter("total_empleados"));
		if(request.getParameter("comentario")!=null && !request.getParameter("comentario").equals("")) cdo.addColValue("comentario",request.getParameter("comentario"));

		//cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and pariente="+request.getParameter("pariente")+" and emp_id="+request.getParameter("empId"));
		//list.add(cdo);
		//SQLMgr.insertList(list,true,false);
		AEMgr.add(cdo);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (AEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=AEMgr.getErrMsg()%>');
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empleado_list.jsp';
	window.close();
<%
} else throw new Exception(AEMgr.getErrMsg());
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