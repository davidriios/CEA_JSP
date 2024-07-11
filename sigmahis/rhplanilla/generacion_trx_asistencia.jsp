<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
FORMA											NOMBRE EN FORMA
SCT0490						GENERACION DE TRANSACCIONES DE ASISTENCIA (Tardanzas, Horas Extras, Ausencias)
======================================================================================================================================================
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
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String grupo = request.getParameter("grupo");
if(fg==null) fg = "";
if(grupo==null) grupo = "";
if(fp==null) fp = "cod_axa";
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'RRHH - '+document.title;

function doSubmit(){
}

function doAction(){
	getAusTarTrxDsp();
	eval('document.form1.cb_t').checked = true;
	eval('document.form1.cb_s').checked = true;
	eval('document.form1.cb_a').checked = true;			
	
}

function getAusTarTrxDsp(){
	var grupo = document.form1.grupo.value;
	sql = 	getDBData('<%=request.getContextPath()%>','getAusTarTrxDsp('+grupo+', \'<%=(String) session.getAttribute("_userName")%>\')','dual','','');
	var arr_cursor = new Array();
	if(sql!=''){
		arr_cursor = splitCols(sql);
		document.form1.fecha_inicio.value = arr_cursor[0];
		document.form1.fecha_final.value = arr_cursor[1];
		document.form1.fi.value = arr_cursor[0];
		document.form1.ff.value = arr_cursor[1];
		document.getElementById('fecha_cierre').innerHTML = arr_cursor[2];
		document.getElementById('dsp_transacciones').innerHTML = arr_cursor[3];
		document.getElementById('dsp_periodo_activo').innerHTML = arr_cursor[4]
	}
}

function chkFechas(flag){
	var fecha = '';
	if(flag==1) fecha = document.form1.fecha_inicio.value;
	else if(flag==2) fecha = document.form1.fecha_final.value;
	var fi = document.form1.fi.value;
	var ff = document.form1.ff.value;
	var sql = 	getDBData('<%=request.getContextPath()%>','1','dual','to_date(\''+fecha+'\', \'dd/mm/yyyy\') not between to_date(\''+fi+'\', \'dd/mm/yyyy\') and to_date(\''+ff+'\', \'dd/mm/yyyy\')','');
	if(sql=='1'){
	<%
	if(UserDet.getUserTypeCode()!=null && !UserDet.getUserTypeCode().equals("PL")){
	%>
		if(flag==1) document.form1.fecha_inicio.value = fi;
		else if(flag==2) document.form1.fecha_final.value = ff;
		alert('La fecha seleccionada NO PUEDE estar fuera del rango de las fechas establecidas por el Calendario de Planilla...');
	<%
	} else {
	%>
		alert('La fecha seleccionada esta fuera del rango de las fechas establecidas por el Calendario de Planilla...');
	<%
	}
	%>
	} 
}


function selEmpleado(){
	var fecha_inicio = document.form1.fecha_inicio.value;
	var fecha_final = document.form1.fecha_final.value;
	var grupo = document.form1.grupo.value;
	if(fecha_inicio == '' || fecha_final == '') alert('Seleccione Fecha Inicio/Final!');
	else if(grupo == '') alert('Seleccione Grupo!');
	else abrir_ventana1('../common/search_empleado.jsp?fp=generar_trx&fecha_inicio='+fecha_inicio+'&fecha_final='+fecha_final+'&grupo='+grupo);
}

function clearTextBox(){
	document.form1.num_empleado.value = '';
	document.form1.provincia.value = '';
	document.form1.sigla.value = '';
	document.form1.tomo.value = '';
	document.form1.asiento.value = '';
	document.form1.emp_id.value = '';
	document.form1.nombre_empleado.value = '';
}

function generarTrx(){
	var v_compania = <%=(String) session.getAttribute("_companyId")%>;
	var p_fechaini = document.form1.fecha_inicio.value;
	var p_fechafin = document.form1.fecha_final.value;
	var v_numempleado = document.form1.num_empleado.value;
	var v_provincia = document.form1.provincia.value;
	var v_sigla = document.form1.sigla.value;
	var v_tomo = document.form1.tomo.value;
	var v_asiento = document.form1.asiento.value;
	var v_grupo = document.form1.grupo.value;
	var v_tar = 'N', v_hext = 'N', v_aus = 'N';
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var p_emp_id = document.form1.emp_id.value;
	var generar = false;
	var generarA = false;
	var generarT = false;
	var generarE = false;
	form1BlockButtons(true);
	if(document.form1.cb_t.checked) v_tar = 'S';
	if(document.form1.cb_s.checked) v_hext = 'S';
	if(document.form1.cb_a.checked) v_aus = 'S';
	if(p_emp_id == ''){
		p_emp_id = 'null';
		v_provincia = 'null';
		v_sigla = 'null';
		v_tomo = 'null';
		v_asiento = 'null';
		p_numempleado = 'null';
		v_numempleado = '';
	} else v_sigla = '\''+v_sigla+'\'';
	
	
	

	generar = confirm('Desea Generar las Transacciones de Asistencia?');
	if(generar){
		if(p_emp_id == 'null') 
		{
		generar = confirm('Desea Generar las Transacciones de Asistencia para TODOS los Empleados?');
		p_emp_id = 'null';
		v_numempleado = null;
		}
	}
	if(v_tar!='S')  generarT += confirm('No se procesaran las Transacciones de Tradanzas');
	if(v_hext!='S') generarE += confirm('No se procesaran las Transacciones de Extras');
	if(v_aus!='S')  generarA += confirm('No se procesaran las Transacciones de Ausencias');
	
	if(generar){
	
		if(executeDB('<%=request.getContextPath()%>', 'call sp_pla_genera_trx(' + v_compania + ', \'' + p_fechaini + '\', \'' + p_fechafin + '\', ' + p_numempleado + ', ' + v_provincia + ', ' + v_sigla + ', ' + v_tomo + ', ' + v_asiento + ', ' + v_grupo + ', \'' + v_tar + '\', \'' + v_aus + '\', \'' + v_hext + '\', \'' + v_user + '\', ' + p_emp_id + ')', '', '')){
			alert('Generado Satisfactoriamente!');
		} else alert('NO Generado Satisfactoriamente!');
	}
	form1BlockButtons(false);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%>
		    <%=fb.hidden("mode",mode)%>
		    <%=fb.hidden("errCode","")%>
		    <%=fb.hidden("errMsg","")%>
		    <%=fb.hidden("baction","")%>
		    <%=fb.hidden("fg",fg)%>
		    <%=fb.hidden("fp",fp)%>
		    <%=fb.hidden("clearHT","")%>
		    <%=fb.hidden("saveOption","")%>
		    <%=fb.hidden("fi","")%>
                    <%=fb.hidden("ff","")%>
										<%=fb.hidden("saveOption","")%>
                    <tr>
                      <td align="center"><table width="100%" cellpadding="1" cellspacing="0" align="center">
                          <tr class="TextPanel">
                          	<td colspan="4" align="center"><label id="dsp_periodo_activo"></label>&nbsp;</td>
                          </tr>
                          <tr class="TextPanel">
                          	<td width="20%" align="right">Fecha Cierre:</td>
                            <td><label id="fecha_cierre"></label></td>
                            <td><label id="dsp_transacciones"></label></td>
                          	<td></td>
                          </tr>
                          <tr class="TextPanel02">
                          	<td width="20%">&nbsp;</td>
                            <td align="right">&nbsp;Fecha Inicial:</td>
                            <td>
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="clearOption" value="true" />
                            <jsp:param name="nameOfTBox1" value="fecha_inicio"/>
                            <jsp:param name="valueOfTBox1" value="" />
                            <jsp:param name="jsEvent" value="chkFechas(1)" />
                            <jsp:param name="onChange" value="chkFechas(1)" />
                            </jsp:include>
                            &nbsp;Fecha Final:
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="clearOption" value="true" />
                            <jsp:param name="nameOfTBox1" value="fecha_final"/>
                            <jsp:param name="valueOfTBox1" value="" />
                            <jsp:param name="jsEvent" value="chkFechas(2)" />
                            <jsp:param name="onChange" value="chkFechas(2)" />
                            </jsp:include>
                            </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td align="right">Grupo a Generar:</td>
                            <td>
                            	<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion from tbl_pla_ct_grupo where compania = "+(String) session.getAttribute("_companyId")+" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '"+((String) session.getAttribute("_userName"))+"')","grupo",grupo,false,false,0,null,null,"onChange=\"javascript:clearTextBox();\"")%>
                            </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td align="right">
                            	<font class="RedText">Empleado a Generar:</font></td>
                            <td>
								<%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","onDblClick=\"javascript:clearTextBox();\"")%>-
	                            <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","onDblClick=\"javascript:clearTextBox();\"")%>-
	                            <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","onDblClick=\"javascript:clearTextBox();\"")%>-
	                            <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,6,"text10","","onDblClick=\"javascript:clearTextBox();\"")%>
	                            <%=fb.textBox("nombre_empleado",cdo.getColValue("nombre_empleado"),false,false,true,50,"text10","","onDblClick=\"javascript:clearTextBox();\"")%>
	                            <%=fb.button("buscar","...",false,false,"text10","","onClick=\"javascript:selEmpleado()\"")%>
	                            <%=fb.hidden("emp_id","")%>
	                            <%=fb.hidden("num_empleado","")%>
                            </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td>&nbsp;</td>
                            <td><font class="RedText">Dejar en blanco para todos los empleados</font></td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr align="center" class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td colspan="2">T r a n s a c c i o n e s   a   G e n e r a r </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr align="center" class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td colspan="2">
                            <!--checkbox(String objName, String objValue, boolean isChecked, boolean isDisabled, String className, String style, String event)-->
                            <%=fb.checkbox("cb_t", "t", false, false, "text10", "", "")%>&nbsp;Tardanzas
                            <%=fb.checkbox("cb_s", "s", false, false, "text10", "", "")%>&nbsp;Sobretiempos
                            <%=fb.checkbox("cb_a", "a", false, false, "text10", "", "")%>&nbsp;Ausencias
                            </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr align="center" class="TextRow01">
                          	<td  colspan="4">&nbsp;</td>
                          </tr>
                          <tr align="center" class="TextRow01">
                          	<td width="20%">&nbsp;</td>
                            <td colspan="2">
                            <%=fb.button("generar_trx", "\n GENERAR TRANSACCIONES DE ASISTENCIA \n ", true, false, "text10", "", "onClick=\"javascript:generarTrx()\"")%>
                            </td>
                          	<td width="20%">&nbsp;</td>
                          </tr>
                          <tr align="center" class="TextRow01">
                          	<td  colspan="4">&nbsp;</td>
                          </tr>
                        </table></td>
                    </tr>
                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
