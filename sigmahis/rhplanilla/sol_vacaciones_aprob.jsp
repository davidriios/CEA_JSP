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
FORMA								MENU																																				NOMBRE EN FORMA
sct0200_rrhh				RECURSOS HUMANOS\TRANSACCIONES\Aprobar/Rechazar Sol. Vacaciones							
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
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
String quincena = request.getParameter("quincena");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");

if(fg==null) fg = "";
if(quincena==null) quincena = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(anio.equals("") && mes.equals("")){
	anio = cDateTime.substring(6, 10);
	mes = cDateTime.substring(3, 5);
}
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'RRHH - '+document.title;

function doSubmit(value){
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}


function doAction(){
	setHeight('itemFrame',document.body.scrollHeight);
}

function setValues(){
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var quincena = document.form1.quincena.value;
	if(anio!='' && mes !='' && quincena !=''){
		window.frames['itemFrame'].location = '../rhplanilla/sol_vacaciones_aprob_det.jsp?quincena='+quincena+'&anio='+anio+'&mes='+mes+'&fp=<%=fp%>';
	}
}

function selAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = true;
	}
}
function deselAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = false;
	}
}
function printEnvios(){	var mes = document.form1.mes.value;	var anio = document.form1.anio.value;	var quincena = document.form1.quincena.value;abrir_ventana('../rhplanilla/print_envio_solicitud_vac.jsp?quincena='+quincena+'&anio='+anio+'&mes='+mes);}

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
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="2">&nbsp;</td>
                          </tr>
                          <tr class="TextPanel">
                            <td>&nbsp;
                            A&ntilde;o
														<%=fb.textBox("anio",anio,false,false,false,4,"text10","","")%>
                            Mes
														<%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes, false, false, 0, "text10", "", "", "", "S")%>
                            Quincena
														<%=fb.select("quincena","1=PRIMERA,2=SEGUNDA,3=AMBAS",quincena, false, false, 0, "text10", "", "", "", "S")%>
                            <%=fb.button("ir","Ir",false,false,"text10","","onClick=\"javascript:setValues();\"")%>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/sol_vacaciones_aprob_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right">
											<%=fb.button("send_planilla","Enviar a planilla",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
                      <%=fb.button("reporte","Reporte de Env�os",true,false,"","","onClick=\"javascript:printEnvios();\"")%>
                      <%=fb.button("anul","Anular",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&quincena=<%=quincena%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>';
<%
} else throw new Exception(errMsg);
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
