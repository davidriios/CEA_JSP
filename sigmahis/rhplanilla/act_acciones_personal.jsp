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
document.title = 'PLANILLA - '+document.title;

function doSubmit(value){
	document.form1.baction.value = value;
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function printEnvios()
{
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var quincena = document.form1.quincena.value;

	abrir_ventana('../rhplanilla/print_envio_solicitud_vac.jsp?quincena='+quincena+'&anio='+anio+'&mes='+mes);
}


function doAction(){
	setHeight('itemFrame',document.body.scrollHeight);
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

function addSolEmp(){
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?tab=4&mode=add&fp=ingreso&tipo_accion=1');
}

function setValues(){
	var type = document.form1.codigo.value;

	if(type!=''){
		window.frames['itemFrame'].location = '../rhplanilla/act_acciones_personal_det.jsp?type='+type+'&fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>';
	}
}




</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ACTUALIZACION DE ACCIONES DE PERSONAL"></jsp:param>
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
                            <td colspan="3">&nbsp;</td>
                          </tr>
                          <tr class="TextPanel">
                            <td>&nbsp; TIPO DE ACCION :
                          	 <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pla_ap_tipo_accion","codigo","","S")%>
														 <%=fb.button("ir","Ir",false,false,"text10","","onClick=\"javascript:setValues();\"")%>
													  </td>
														 <td align="right">
                            <%=fb.button("app","Aplicar Acciones Seleccionadas",false,false,"text10","","onClick=\"javascript:doSubmit(this.value);\"")%>
                            </td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="210" scrolling="yes" src="../rhplanilla/act_acciones_personal_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right"><%=fb.button("app2","Aplicar Acciones Seleccionadas",false,false,"text10","","onClick=\"javascript:doSubmit(this.value);\"")%>
                      <%//=fb.button("sel_all","Selecc. Todos",true,false,"","","onClick=\"javascript:selAll();\"")%>
                      <%//=fb.button("desel_all","Desel. Todos",true,false,"","","onClick=\"javascript:deselAll();\"")%>
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
	if (request.getParameter("baction").equalsIgnoreCase("Aplicar Acciones Seleccionadas")){
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
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
