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
FORMA								MENU																					NOMBRE EN FORMA
SCT0060							RRHH\APROBACIONES\TRX. DE ASISTENCIA\					APROBACION DE PROGRAMA DE TURNOS
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
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
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
System.out.println("area="+area);
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
document.title = 'Rrhh - '+document.title;

function doSubmit(){
}

function doAction(){
}

function printRpt()
{
var grupo=document.form1.grupo.value;
var area=document.form1.uf_codigo.value;
var anio=document.form1.anio.value;
var mes=document.form1.mes.value;
if(anio == '' || mes == '') alert('Seleccione Año/Mes!');
	else if(grupo == '') alert('Seleccione Grupo!');
abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/programa_turno.rptdesign&cpGrupo='+grupo+'&cpArea='+area+'&pAnio='+anio+'&pMonthId='+mes+'&pAprobado=N');
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

function aprobar(){
	var v_compania	= <%=(String) session.getAttribute("_companyId")%>;
	var v_grupo 		= document.form1.grupo.value;
	var uf_codigo 	= document.form1.uf_codigo.value;
	var anio 				= document.form1.anio.value;
	var mes 				= document.form1.mes.value;
	var v_user 			= '<%=(String) session.getAttribute("_userName")%>';
	var generar 		= false;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	form1BlockButtons(true);
	var msg = '';
	generar = confirm('Seguro que desea aprobar el Programa de Turnos?');
	if(generar){
		if(executeDB('<%=request.getContextPath()%>', 'call sp_pla_aprobar_prog_turno('+v_compania+', '+v_grupo+', \''+uf_codigo+'\', '+anio +', '+mes+', \''+v_user+'\')', '', '')){
			msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		} else msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		alert(msg);
	}
	form1BlockButtons(false);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="APROBACION DE PROGRAMA DE TURNOS"></jsp:param>
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
                    <tr>
                      <td align="center"><table width="100%" cellpadding="1" cellspacing="0" align="center">
                          <tr class="TextPanel">
                            <td colspan="3">&nbsp;Programa de Turnos</td>
                          </tr>
                          <tr class="TextPanel">
                            <td colspan="3">&nbsp;Introduzca el A&ntilde;o y Mes del Programa de turnos que desea Imprimir y/o Actualizar</td>
                          </tr>
                          <tr class="TextRow02">
                            <td width="25%">Grupo de Trabajo:</td>
                            <td width="65%">
														<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion from tbl_pla_ct_grupo where compania = "+(String) session.getAttribute("_companyId")+" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '"+(String) session.getAttribute("_userName")+"')","grupo",grupo,false,false,0,"text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','uf_codigo','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
                            </td>
                            <td width="10%">&nbsp;</td>
                          </tr>
                          <tr class="TextRow01">
                            <td>
                            Ubic. o Area de Trab.
                            </td>
                            <td>
                            <%=fb.select("uf_codigo","","",false,false,0, "text10", "", "")%>
														<script language="javascript">
														loadXML('../xml/areaXGrupo.xml','uf_codigo','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','T');
                          </script>
                          	</td>
                            <td>&nbsp;</td>
                          </tr>
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                            <td>&nbsp;
                            A&ntilde;o
														<%=fb.textBox("anio","",false,false,false,4,"text10","","")%>
                            Mes
														<%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre","", false, false, 0, "text10", "", "")%>
                            </td>
                            <td>&nbsp;</td>
                          </tr>
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                            <td>
							 <%=fb.button("btnImprimir","Imprimir Programa de Turno",false,false,"text10","","onClick=\"javascript:printRpt();\"")%>
                            <%=fb.button("btnAprobar","Aprobar Programa de Turno",false,false,"text10","","onClick=\"javascript:aprobar();\"")%>
                            </td>
                            <td>&nbsp;</td>
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
