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
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alRef = new ArrayList();
ArrayList alPla = new ArrayList();
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

String periodo = request.getParameter("anio");
String quincena = request.getParameter("mes");
String cierre = request.getParameter("cierre");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String cia = (String) session.getAttribute("_companyId");
String usuario = (String) session.getAttribute("_userName");

if(fg==null) fg = "";
if(grupo==null) grupo = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";
if(fecha_desde==null) fecha_desde = "";
if(fecha_hasta==null) fecha_hasta = "";

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
    sql = "select 'Marcacion generada hasta el dia '||to_char(x.marcacion,'dd/mm/yyyy hh12:mi:ss am') ||' generado por el usuario: '||upper(x.usuario_procesa)||' el dia '||to_char(x.fecha_procesa ,'dd/mm/yyyy hh12:mi am') msg,to_char(x.marcacion ,'dd/mm/yyyy') as f_cierre   from (select max(marcacion) as marcacion, max(fecha_procesa) as fecha_procesa,usuario_procesa  from  tbl_pla_temporal_marcacion x where compania=  "+(String) session.getAttribute("_companyId")+" and accion ='PR' and id_lote is not null group by usuario_procesa order by 1 desc ) x ";
	cdo = SQLMgr.getData(sql);
	if(cdo ==null){cdo = new CommonDataObject(); cdo.addColValue("msg","");cdo.addColValue("f_cierre","");}
	else{/*fecha_desde=cdo.getColValue("f_cierre","");*/}
	
	alRef = sbb.getBeanList(ConMgr.getConnection(),"select distinct a.id_lote as optValueColumn,a.observacion as optLabelColumn, a.observacion as optTitleColumn from tbl_pla_temporal_marcacion a where a.compania ="+session.getAttribute("_companyId")+" and /*not*/ exists(select null from tbl_pla_marcacion b where a.id_lote=b.id_lote /*and b.gen_ausencia='S'*/) and accion ='PR' order by a.id_lote desc ",CommonDataObject.class);
	
	
	alPla = sbb.getBeanList(ConMgr.getConnection(),"select a.PERIODO as optValueColumn, ' Planilla No. ( '||a.periodo||' )'|| decode(mod(a.periodo,2),0,'SEGUNDA','PRIMERA')||' QUINCENA  DEL MES DE '||to_char(to_date(a.FECHA_FINAL, 'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' DEL '||to_char(a.FECHA_INICIAL, 'dd/mm/yyyy')|| '  AL  '|| to_char(a.FECHA_FINAL, 'dd/mm/yyyy') as optLabelColumn, to_char(a.TRANS_DESDE,'dd/mm/yyyy') as transdesde, to_char(a.TRANS_HASTA,'dd/mm/yyyy') as transhasta from tbl_pla_calendario a, tbl_pla_tipo_planilla b where a.TIPOPLA=b.tipopla and  a.periodo!=0 and a.tipopla=1 order by  a.periodo ",CommonDataObject.class);

	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'PLANILLA - '+document.title;
function doAction(){}

function ejecutar()
{
var msg='';
var desde = document.form1.fecha_desde.value;
var hasta = document.form1.fecha_hasta.value;
if(desde == "" || hasta == "")msg = 'Introduzca Fecha';
if(msg==''){CBMSG.confirm(' \nDesea Generar la Marcacion para la fecha Seleccionada!!',{'cb':function(r){
   if(r=='Si'){showPopWin('../process/pla_gen_marcacion.jsp?fp=MARC&actType=50&docType=MARC&fechaIni='+desde+'&fechaFin='+hasta+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');}}});
}else CBMSG.alert(""+msg);
} 

function reversar()
{
var msg='';
var id = document.form1.id.value; 
var comment = getSelectedOptionLabel(document.form1.id,'');

if(id == "")msg = 'Seleccione Parametros';

if(msg==''){CBMSG.confirm(' \nDesea Eliminar los registros de Marcacion para la fecha Seleccionada!!',{'cb':function(r){
   if(r=='Si'){showPopWin('../process/pla_gen_marcacion.jsp?fp=DELMARC&actType=51&docType=MARC&id='+id+'&comment='+comment+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');}}});
}else CBMSG.alert(""+msg);
}

function addPer(index)
{
abrir_ventana('../common/search_calendario.jsp?fp=marcacion&tipoPla=1');
}

function marcacion(){
   var desde = document.form1.fecha_desde.value;
   var hasta = document.form1.fecha_hasta.value;
   var periodo = document.form1.periodo.value;
   var id = document.form1.id.value; 
   
   if (id) {
      var title = $('#id').find(":selected").text();
      var titleArray = title.split("GENERADA DESDE");
      var fechaArray = titleArray[1].split("-");
      desde = $.trim(fechaArray[0]);
      hasta = $.trim(fechaArray[1]);
   }
   
   if(desde && hasta) abrir_ventana('../rhplanilla/list_marcacion_nv.jsp?grupo=&fecha='+desde+'&fechaHasta='+hasta+'&periodo='+periodo+'&id_lote='+id+'&incompletos=X');
   else alert("Por favor escoger el lote de marcación.");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="GENERACION DE MARCACIONES"></jsp:param>
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
                            <td colspan="2">&nbsp;Parametros para Generacion de MARCACIONES </td>
                          </tr>
						  <tr class="TextRow02">
							<td colspan="2" class="Link05"><font size="+1"><%=cdo.getColValue("msg")%></font></td>
						  </tr>
						  
						  <tr class="TextHeader">
							<td colspan="2" align="center">PLANILLA A PROCESAR : Calendario de Planilla <%=fb.button("btnper","...",true,false,null,null,"onClick=\"javascript:addPer()\"")%></td>
						  </td>
						  
						    <tr class="TextRow02">
							<td colspan="2" align="center" class="Link05"><font size="+.5">&nbsp;Fecha de Marcaciones a Generar</font></td>
						  </tr>
												  
						 
						<tr class="TextHeader">
						  <td colspan="2" align="center">&nbsp;
						  Fecha Inicial:  &nbsp;&nbsp;  <%=fb.textBox("fecha_desde",fecha_desde,false,false,true,10,10)%>
						   &nbsp;&nbsp;&nbsp;&nbsp;          Fecha Final : &nbsp;&nbsp;&nbsp;<%=fb.textBox("fecha_hasta",fecha_hasta,false,false,true,10,10)%>
						   &nbsp;&nbsp;&nbsp;&nbsp;         Periodo : &nbsp;&nbsp;&nbsp;<%=fb.textBox("periodo",periodo,false,false,true,3,3)%>
						   </td>
						</tr>
						  

													 <tr class="TextRow01">
                            <td colspan="2" align="center">&nbsp;
										 				<authtype type='50'><%=fb.button("ir","  EJECUTAR PROCESO PARA GENERAR MARCACION  ",false,false,"Text10","","onClick=\"javascript:ejecutar();\"")%></authtype><authtype type='52'><%=fb.button("view"," VER MARCACIONES ",false,false,"Text10","","onClick=\"javascript:marcacion();\"")%></authtype>

                            </td>

                          </tr>
													<tr class="TextRow02">
                            <td colspan="2" align="center">&nbsp;
										 				<authtype type='51'><%=fb.select("id",alRef,"",false,false,0,"Text10",null,"",null,"S")%>
														<%=fb.button("del","ELIMINAR MARCACION GENERADAS",false,false,"Text10","","onClick=\"javascript:reversar();\"")%></authtype>

                            </td>

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

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
