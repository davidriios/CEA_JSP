<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CamaNota"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CtrCMgr" scope="page" class="issi.admision.ControlCamaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" 			scope="page" 		class="issi.admin.CommonDataObject" />

<br>
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
CtrCMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");

String pacienteId = request.getParameter("pacienteId");
String cod_paciente = request.getParameter("cod_paciente");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String noAdmision = request.getParameter("noAdmision");
String cama = request.getParameter("cama");
String habitacion = request.getParameter("habitacion");
String centro_servicio = request.getParameter("centro_servicio");

String change = request.getParameter("change");
String fg = request.getParameter("fg");
if(fg==null) fg = "";
String fp = request.getParameter("fp");
if(fp==null) fp = "";

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
boolean viewMode = false;
int lineNo = 0;

if (mode == null) mode = "add";
if (mode.equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){
  if (mode.equalsIgnoreCase("add")){
    if(change==null){
      if(request.getParameter("pacienteId")==null) pacienteId = "0";
			if(request.getParameter("noAdmision")==null) noAdmision = "0";
			System.out.println("cleanning htMot...");
			sql = "select nota from tbl_sal_cama_nota where adm_secuencia = "+noAdmision+" and pac_id = "+pacienteId+" and habitacion = '"+habitacion+"' and cama = '"+cama+"'";
			cdo = SQLMgr.getData(sql);
			if(cdo==null) cdo = new CommonDataObject();
    }
  } else {
    if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
    if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");
  }
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function setBAction(fName,actionValue){
  document.form0.baction.value = actionValue;
  doSubmit();
}

function selMD(i){
  abrir_ventana1('../common/sel_mot_demora.jsp?fp=reg_mot_demora&index='+i);
}

function doAction(){
}

function doSubmit(){
/*
  document.form0.fechaNacimiento.value    = document.paciente.fechaNacimiento.value;
  document.form0.codigoPaciente.value     = document.paciente.codigoPaciente.value;
  document.form0.pacienteId.value         = document.paciente.pacienteId.value;
  document.form0.admSecuencia.value       = document.paciente.admSecuencia.value;
*/  

  if (!form0Validation()){
    //return false;
  } else{
    //return true;
    if(document.form0.baction.value != 'Guardar') form0BlockButtons(false);
    document.form0.submit();
  }
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="ANALISIS Y FACTURACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableBorder">
    <table align="center" width="100%" cellpadding="5" cellspacing="0">
    <tr>
      <td>
        <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextRow02">
          <td>&nbsp;</td>
        </tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("cod_paciente",cod_paciente)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("centro_servicio",centro_servicio)%>
<%=fb.hidden("cama",cama)%>
<%=fb.hidden("habitacion",habitacion)%>

        <tr>
          <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
            <table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">Notas</td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
            </tr>
            </table>
          </td>
        </tr>
        <tr id="panel0">
          <td>
            <table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
              <td colspan="3"><%=fb.textarea("nota",cdo.getColValue("nota"),true,false,false,70,3, 2000)%></td>
            </tr>
            </table>
          </td>
        </tr>
        <tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

        </table>
      </td>
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
	CamaNota cn = new CamaNota();
	
	cn.setAdmSecuencia(request.getParameter("noAdmision"));
	cn.setCama(request.getParameter("cama"));
	cn.setCentroServicio(request.getParameter("centro_servicio"));
	cn.setCodigoPaciente(request.getParameter("cod_paciente"));
	cn.setCompania((String) session.getAttribute("_companyId"));
	cn.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
	cn.setHabitacion(request.getParameter("habitacion"));
	cn.setPacId(request.getParameter("pacienteId"));
	cn.setUsuarioCreacion((String) session.getAttribute("_userName"));
	cn.setFecha(fecha);
	cn.setNota(request.getParameter("nota"));
		
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

  if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
    CtrCMgr.addNote(cn);
  }

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CtrCMgr.getErrCode().equals("1")){
%>
  alert('<%=CtrCMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
  setTimeout('addMode()',500);
<%
  } else {
	%>
	window.close();
	<%
	}
} else throw new Exception(CtrCMgr.getErrMsg());
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&fp=<%=fp%>&cama=<%=cama%>&habitacion=<%=habitacion%>&pacienteId=<%=pacienteId%>&cod_paciente=<%=cod_paciente%>&fecha_nacimiento=<%=fecha_nacimiento%>&noAdmision=<%=noAdmision%>&centro_servicio=<%=centro_servicio%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>