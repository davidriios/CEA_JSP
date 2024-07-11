<//%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr"/>
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
VacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
emp.clear();
empKey.clear();
String key = "";
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String quincena = request.getParameter("quincena");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String nombre = request.getParameter("nombre");
String numEmpleado = request.getParameter("numEmpleado");
String cedula = request.getParameter("cedula");
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
//cDateTime = "01/01/2010";
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "select ue.descripcion nombre_unidad, ue.codigo ue_codigo, ca.periodo, decode(mod(ca.periodo,2),'0','2da QUINCENA DE ','1ra QUINCENA DE ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' DE '||to_char(ca.fecha_inicial,'yyyy') quincena, 'PERIODO DEL '||'"+cDateTime+"'|| ' AL '||'"+cDateTime+"' as titulo, to_char(ca.fecha_cierre,'dd/mm/yyyy') fecha_cierre, to_char(ca.fecha_inicial,'dd/mm/yyyy') fecha_inicial, to_char(ca.fecha_final,'dd/mm/yyyy') fecha_final, to_char(ca.trans_desde,'dd/mm/yyyy') desde, to_char(ca.trans_hasta,'dd/mm/yyyy') hasta from tbl_pla_calendario ca, tbl_pla_ct_grupo ue where ue.codigo="+grupo+" and ue.compania = "+session.getAttribute("_companyId")+" and (trunc(ca.fecha_cierre+2) >= to_date('"+cDateTime+"','dd/mm/yyyy')) and ca.tipopla = 1 and (trunc(ca.fecha_inicial) <= to_date('"+cDateTime+"','dd/mm/yyyy')  and trunc(ca.fecha_final) >= to_date('"+cDateTime+"','dd/mm/yyyy') ) ";
	cdo = SQLMgr.getData(sql);
String inicio = cdo.getColValue("fecha_inicial");
String fin = cdo.getColValue("fecha_final");
String desde = cdo.getColValue("desde");
String hasta = cdo.getColValue("hasta");
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

function selAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = true;
	}
}

function selEmp(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
	 if(eval('window.frames[\'itemFrame\'].document.form.nombre'+i).value = document.form1.nombre.value);
	}
}

function deselAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = false;
	}
}

function addNotif(){
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
	var emp_id = "";
	var cadena = "";
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){

		emp_id = eval('window.frames[\'itemFrame\'].document.form.emp_id'+i).value;
	  cadena = ""+cadena+" "+emp_id+", ";
		}
}  cadena = "("+cadena+" "+emp_id+")";

if (emp_id!='') {

		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){

					var desde 						= eval('window.frames[\'itemFrame\'].document.form.fechaDesde'+i).value;
					var hasta							= eval('window.frames[\'itemFrame\'].document.form.fechaHasta'+i).value;
					var periodo 					= eval('window.frames[\'itemFrame\'].document.form.periodo'+i).value;
					var unidad	  					= window.frames['itemFrame'].document.form.area.value;
					//		var grupo							= window.frames['itemFrame'].document.form.grupo.value;
					var grupo							= document.form1.grupo.value;
		if(i==0){
		if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_temporal_asistencia where trunc(fecha)>=to_date(\''+desde+'\',\'dd/mm/yyyy\') and trunc(fecha)<=to_date(\''+hasta+'\',\'dd/mm/yyyy\') and compania = <%=cia%> and ue_codigo = nvl(\''+grupo+'\',ue_codigo)',''))
		}
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_ausencias_bor( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_incapacidad_bor( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_permisos_bor( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
						if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_tardanzas_bor( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
	//	alert('sali  '+desde+'//'+hasta+'///'+grupo);
		abrir_ventana('../rhplanilla/print_list_notificacion.jsp?fg=borrador&desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&area='+unidad+'&cadena='+cadena);
	}
}

  } else {
alert('Selleccione al menos un Empleado');
 }
}


function addNotifRep(){
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
	var emp_id = "";
	var cadena = "";
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){

		emp_id = eval('window.frames[\'itemFrame\'].document.form.emp_id'+i).value;
	  cadena = ""+cadena+" "+emp_id+", ";
		}
}  cadena = "("+cadena+" "+emp_id+")";
if (emp_id!='') {
		for(i=0;i<size;i++){
			if(eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked == true){

					var desde 						= eval('window.frames[\'itemFrame\'].document.form.fechaDesde'+i).value;
					var hasta							= eval('window.frames[\'itemFrame\'].document.form.fechaHasta'+i).value;
					var periodo 					= eval('window.frames[\'itemFrame\'].document.form.periodo'+i).value;
					var unidad	  					= window.frames['itemFrame'].document.form.area.value;
					//		var grupo							= window.frames['itemFrame'].document.form.grupo.value;
					var grupo							= document.form1.grupo.value;
		if(i==0){
		if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_temporal_asistencia where trunc(fecha)>=to_date(\''+desde+'\',\'dd/mm/yyyy\') and trunc(fecha)<=to_date(\''+hasta+'\',\'dd/mm/yyyy\') and compania = <%=cia%> and ue_codigo = nvl(\''+grupo+'\',ue_codigo)',''))
		}
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_ausencias( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_incapacidad( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
					if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_permisos( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+user+'\')'));
						if(executeDB('<%=request.getContextPath()%>','call sp_pla_cargar_tardanzas( \''+desde+'\', \''+hasta+'\',<%=cia%>,'+grupo+',\''+unidad+'\')'));
	//	alert('sali  '+desde+'//'+hasta+'///'+grupo);
		abrir_ventana('../rhplanilla/print_list_notificacion.jsp?fg=reporte&desde='+desde+'&hasta='+hasta+'&grupo='+grupo+'&area='+unidad+'&cadena='+cadena);
	}
 }
 } else {
alert('Selleccione al menos un Empleado');
 }
}

function addOverTime() {
	var user = document.form1.usuario.value;
	var size = window.frames['itemFrame'].document.form.keySize.value;
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

function validateUnit(value){

	var grupo							= document.form1.grupo.value;

	}



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RRHH - Notificaciones"></jsp:param>
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
										<%=fb.hidden("inicio",cdo.getColValue("fechaInicial"))%>
										<%=fb.hidden("fin",cdo.getColValue("fechaFinal"))%>
										<%=fb.hidden("desde",cdo.getColValue("desde"))%>
										<%=fb.hidden("hasta",cdo.getColValue("hasta"))%>

                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextFilter">
                            <td colspan="3">&nbsp;</td>
                          </tr>

													<tr class="TextFilter">
                            <td colspan="2">&nbsp;GRUPO DE TRABAJO : &nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pla_ct_grupo where compania = "+session.getAttribute("_companyId")+" order by descripcion","grupo",grupo,false,false,0,null,null,"onChange=\"javascript:validateUnit(this)\"","","")%></td>
														 <td colspan="1" align="center">&nbsp; &nbsp;<%=cdo.getColValue("quincena")%></td>
												  </tr>

													<tr class="TextFilter">
                            <td colspan="2">&nbsp;UBICACION O AREA : &nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_pla_ct_area_x_grupo where compania = "+session.getAttribute("_companyId")+" and grupo = "+grupo+" order by nombre","area",area,"T")%> </td>
														 <td colspan="1" align="center">&nbsp;FECHA DE CIERRE : &nbsp;<%=cdo.getColValue("fecha_cierre")%></td>
                          </tr>

													<tr class="TextFilter">
                            <td colspan="3">&nbsp;</td>
                          </tr>

                     		<tr class="TextFilter">
													<td>&nbsp;Nombre del Empleado:&nbsp;<%=fb.textBox("nombre","",false,false,false,25,null,null,null)%></td>
													<td>&nbsp;Num Empleado:&nbsp;<%=fb.textBox("numEmpleado","",false,false,false,10,null,null,null)%></td>
													<td>&nbsp;Cedula:&nbsp;<%=fb.textBox("cedula","",false,false,false,10,null,null,null)%><%=fb.submit("go","Ir",true,true)%></td>
												</tr>



                          <tr class="TextPanel">
                            <td><authtype type='50'>&nbsp;
                            <%=fb.button("add","NOTIFICACIONES BORRADOR",false,false,"text10","","onClick=\"javascript:addNotif();\"")%>
                            </authtype>
                            </td>
                            <td>
                            <authtype type='51'>
                             <%=fb.button("otro","NOTIFICACIONES REPORTES",false,false,"text10","","onClick=\"javascript:addNotifRep();\"")%>
                            </authtype>
                            </td>
                            <td align="right">
                            <authtype type='52'>
                              <%=fb.button("Aprobacion","Aprobacion",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
                            </authtype></td>
                          </tr>

                          <tr class="TextFilter">
													<td colspan="3" class="Text10" align="center" >

				Estado de las Notificaciones       <!-- Atenci&oacute;n-->:
				 <img src="../images/lampara_roja.gif" alt="Notificaciones Pendientes"> Notificaciones Pendientes
				 <img src="../images/lampara_verde.gif" alt="Notificaciones Aprobadas"> Notificaciones Aprobadas

													</td>
													</tr>
                       </table>
                     </td>
                    </tr>

                    <tr class="TextRow02">
										                      <td align="right"> &nbsp;&nbsp;&nbsp;
																					<%// Buscar Nombre del Empleado : =fb.textBox("nombre","",false,false,false,45)%>
																					<%//=fb.button("buscar","Buscar",false,false,null,null,"onClick=\"javascript:selEmp()\"")%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

																				  <%=fb.button("sel_all","Selecc. Todos",true,false,"","","onClick=\"javascript:selAll();\"")%>&nbsp;&nbsp;&nbsp;
										                      <%=fb.button("desel_all","Desel. Todos",true,false,"","","onClick=\"javascript:deselAll();\"")%>
										                      </td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/empl_notificacion_det.jsp?fp=<%=fp%>&fg=<%=fg%>&grupo=<%=grupo%>&area=<%=area%>&inicio=<%=desde%>&fin=<%=hasta%>&mode=<%=mode%>"></iframe></td>
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
	} else	if (request.getParameter("baction").equalsIgnoreCase("Aprobacion")){
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?grupo=<%=grupo%>&area=<%=area%>';
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
