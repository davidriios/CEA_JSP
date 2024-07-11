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
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String nombre = request.getParameter("nombre");
String cia = (String) session.getAttribute("_companyId"); 
String usuario = (String) session.getAttribute("_userName"); 

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
	document.form1.baction.value = value;
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function doAction(){
	setHeight('itemFrame',document.body.scrollHeight);
}

function checkItem(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	var count=0;
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){ count++;
}
} 
if (count==0) alert("Seleccione un Periodo");
}

function addNotif(){
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
	checkItem();
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){
		
		var desde 						= eval('window.frames[\'itemFrame\'].document.form.fechaDesde'+i).value;
		var hasta							= eval('window.frames[\'itemFrame\'].document.form.fechaHasta'+i).value;
		var periodo 					= eval('window.frames[\'itemFrame\'].document.form.periodo'+i).value;
		var unidad	  					= window.frames['itemFrame'].document.form.area.value;
//		var grupo							= window.frames['itemFrame'].document.form.grupo.value;
		var grupo							= document.form1.grupo.value;
		if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_temporal_asistencia where trunc(fecha)>=to_date(\''+desde+'\',\'dd/mm/yyyy\') and trunc(fecha)<=to_date(\''+hasta+'\',\'dd/mm/yyyy\') and compania = <%=cia%> and ue_codigo = nvl(\''+grupo+'\',ue_codigo)',''))
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_ausencias( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_incapacidad( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_permisos( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
						if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_tardanzas( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
	//	alert('sali  '+desde+'//'+hasta+'///'+grupo);
		abrir_ventana('../rhplanilla/print_list_notificacion.jsp?desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&area='+unidad);
	}
}
}

function addOverTime() {
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
	checkItem();
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){
		
		var desde 						= eval('window.frames[\'itemFrame\'].document.form.fechaDesde'+i).value;
		var hasta							= eval('window.frames[\'itemFrame\'].document.form.fechaHasta'+i).value;
		var periodo 					= eval('window.frames[\'itemFrame\'].document.form.periodo'+i).value;
		var anio		 					= eval('window.frames[\'itemFrame\'].document.form.anio'+i).value;
		var unidad	  				= window.frames['itemFrame'].document.form.area.value;
	//	var grupo							= window.frames['itemFrame'].document.form.grupo.value;
		var grupo							= document.form1.grupo.value;
abrir_ventana('../rhplanilla/print_list_sobretiempo.jsp?desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&periodo='+periodo+'&anio='+anio+'&area='+unidad);
}
}
}

function addOtroPago() {
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
	checkItem();
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){
		
		var desde 						= eval('window.frames[\'itemFrame\'].document.form.fechaDesde'+i).value;
		var hasta							= eval('window.frames[\'itemFrame\'].document.form.fechaHasta'+i).value;
		var periodo 					= eval('window.frames[\'itemFrame\'].document.form.periodo'+i).value;
		var anio		 					= eval('window.frames[\'itemFrame\'].document.form.anio'+i).value;
		var unidad	  				= window.frames['itemFrame'].document.form.area.value;
//		var grupo							= window.frames['itemFrame'].document.form.grupo.value;
		var grupo							= document.form1.grupo.value;
abrir_ventana('../rhplanilla/print_list_otros_pagos.jsp?desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&periodo='+periodo+'&anio='+anio+'&area='+unidad);
}
}
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
										<%=fb.hidden("area",area)%>
										
										<%=fb.hidden("usuario",usuario)%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="3">&nbsp;</td>
                          </tr>
													<tr class="TextPanel">
                            <td colspan="3">&nbsp;GRUPO DE TRABAJO : &nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pla_ct_grupo where compania = "+session.getAttribute("_companyId")+" order by descripcion","grupo",grupo,"+grupo+")%></td>
                          </tr>
                          <tr class="TextPanel">
                            <td>&nbsp;
                            <%=fb.button("add","NOTIFICACIONES",false,false,"text10","","onClick=\"javascript:addNotif();\"")%>
                            </td>
                            <td>
                            <%=fb.button("sob","SOBRETIEMPO",false,false,"text10","","onClick=\"javascript:addOverTime();\"")%>
                            </td>
                            <td>
                            <%=fb.button("otro","OTROS PAGOS",false,false,"text10","","onClick=\"javascript:addOtroPago();\"")%>
                            </td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/transacciones_planilla_det.jsp?fp=<%=fp%>&fg=<%=fg%>&grupo=<%=grupo%>&area=<%=area%>&mode=<%=mode%>"></iframe></td>
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
	if (request.getParameter("baction").equalsIgnoreCase("Notificacion")){
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
