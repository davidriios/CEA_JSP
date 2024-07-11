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
String emp_id = request.getParameter("emp_id");
if(fg==null) fg = "";
if(fp==null) fp = "ausencia_rrhh";
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
String anio_pago=request.getParameter("anio_pago");
String quincena_pago=request.getParameter("quincena_pago");
if(anio_pago==null) anio_pago = cDateTime.substring(6, 10);

if(quincena_pago==null) {
int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));
int period=0;
if(fecha==null) fecha = cDateTime;

if (day<=15) {
			period		= (mont * 2)-1;

}	else {
		  period		= (mont * 2);
}
quincena_pago = ""+period;
}
int lineNo = 0;
if (mode == null) mode = "add";
CommonDataObject emple = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		sql = "select a.provincia, a.sigla, a.tomo, a.asiento, a.primer_nombre, a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.unidad_organi, b.descripcion unidad_organi_desc, a.num_empleado, a.cedula1 as cedula, a.nombre_empleado, c.denominacion as cargo, a.rata_hora from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo c where a.compania = b.compania and a.unidad_organi = b.codigo and a.cargo = c.codigo and a.compania= c.compania  and a.emp_id = " + emp_id;
		emple = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;

function doSubmit(value){
	document.form1.baction.value = value;
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}


function doAction(){
}

function imprimir(){
	abrir_ventana('../inventario/print_list_.jsp');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="AUSENCIAS / TARDANZAS"></jsp:param>
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
                    <%=fb.hidden("emp_id",emp_id)%>
                    <%=fb.hidden("anio_pago",anio_pago)%>
                    <%=fb.hidden("quincena_pago",quincena_pago)%>
                    <%=fb.hidden("provincia",emple.getColValue("provincia"))%>
                    <%=fb.hidden("sigla",emple.getColValue("sigla"))%>
                    <%=fb.hidden("tomo",emple.getColValue("tomo"))%>
                    <%=fb.hidden("asiento",emple.getColValue("asiento"))%>
                    <%=fb.hidden("rata_hora",emple.getColValue("rata_hora"))%>
					<tr class="TextHeader">
						<td colspan="4">&nbsp;GENERALES DEL EMPLEADO</td>
					</tr>

					<tr>
					<td><table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextFilter">
							<td width="15%">&nbsp;Nombre Empleado:&nbsp;</td>
							<td width="55%">&nbsp;<%=emple.getColValue("nombre_empleado")%></td>
							<td width="15%" align="right">&nbsp;C&eacute;dula:&nbsp;&nbsp;</td>
							<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
						</tr>

						<tr class="TextFilter">
							<td width="15%">&nbsp;Cargo:&nbsp;</td>
							<td width="55%">&nbsp;<%=emple.getColValue("cargo")%></td>
							<td width="15%" align="right">&nbsp;No.Empleado:&nbsp;&nbsp;</td>
							<td width="15%">&nbsp;<%=emple.getColValue("num_empleado")%></td>
						</tr>

						<tr class="TextFilter">
							<td width="15%">&nbsp;Secci&oacute;n:&nbsp;</td>
							<td width="55%">&nbsp;<%=emple.getColValue("unidad_organi")%>&nbsp; - &nbsp;<%=emple.getColValue("unidad_organi_desc")%></td>
							<td width="15%" align="right">&nbsp;Rata x Hora:&nbsp;&nbsp;</td>
							<td width="15%">&nbsp;<%=emple.getColValue("rata_hora")%></td>
						</tr>
						<tr class="TextRow01">
							<td colspan="4">&nbsp;</td>
						</tr>
					</table>
					</td>
					</tr>

					<tr class="TextHeader">
						<td colspan="4">&nbsp;DETALLE DE TRANSACCIONES</td>
					</tr>

                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/reg_asistencia_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&emp_id=<%=emp_id%>"></iframe></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right">Opciones de Guardar:
											<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
                      <%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
											<%=fb.button("save","Guardar",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
                      </td>
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
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
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
	if (fp.equals("liquidacion")){
	%>
	window.opener.getPlaLiqDLTotales();
<%
	}
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}

} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&emp_id=<%=request.getParameter("emp_id")%>&fp=<%=request.getParameter("fp")%>&anio_pago=<%=request.getParameter("anio_pago")%>&quincena_pago=<%=request.getParameter("quincena_pago")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
