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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator" />
<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
sct0200_rrhh				RECURSOS HUMANOS\TRANSACCIONES\Aprobar/Rechazar Sol. Vacaciones
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
IXml.setConnection(ConMgr); 
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

if(fg==null) fg = "anio";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		sql = "select distinct a.lista value_col, a.lista label_col, to_char(a.fecha, 'dd/mm/yyyy')||'-'||a.cod_empresa||'-'||a.facturar_a||'-'||b.categoria key_col from   tbl_fac_factura a, tbl_adm_admision b where a.pac_id = b.pac_id and a.admi_secuencia = b.secuencia and a.usuario_creacion = '"+(String) session.getAttribute("_userName")+"'/*and b.categoria in (1, 5)*/";
		//IXml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+"/listEnvio_"+(String) session.getAttribute("_userName")+".xml", sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;
function doSubmit(value){document.form1.baction.value = value;}
function doAction(){}
function eject(){
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	var aseguradora = document.form1.aseguradora.value;
	var facturas_a = document.form1.facturas_a.value;
	var lista = document.form1.lista.value;
	var fecha_envio = document.form1.fecha_envio.value;
	var categoria = document.form1.categoria.value;
	var comentario = document.form1.comentario.value;
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var enviado_por = document.form1.enviado_por.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var reloadPage = false;
	if(lista !='' ){
	if(confirm('¿Está seguro que desea ejecutar el proceso marcado?')){
		if(executeDB('<%=request.getContextPath()%>','call sp_fact_envia_lista(' + compania + ', ' + aseguradora + ',\'' + facturas_a + '\', ' + lista + ', \'' + fecha_envio + '\', ' + categoria + ', \'' + comentario + '\', \'' + v_user + '\', \''+enviado_por+'\')')){
			abrir_ventana('../facturacion/print_list_envia_aseg.jsp?cod_empresa='+aseguradora+'&facturas_a='+facturas_a+'&lista='+lista+'&fecha_envio='+fecha_envio+'&categoria='+categoria);	
		}	
	  }//CBMSG.warning('Proceso cancelado !');
	}else alert('No ha Seleccionado lista.');
}

function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=rep_list_aseg');}
function inactivar(){abrir_ventana1('../facturacion/inactiva_lista_envio.jsp');}
function editar(){abrir_ventana1('../facturacion/editar_lista_envio.jsp');}
function creaXML(){var fecha_envio = document.form1.fecha_envio.value;	var aseguradora = document.form1.aseguradora.value;	var facturas_a = document.form1.facturas_a.value;	var categoria = document.form1.categoria.value;	if(fecha_envio != '' && aseguradora != '' && facturas_a != '' && categoria != '')document.form1.lista.value=''; /*loadXML('../xml/listEnvio_<%=(String) session.getAttribute("_userName")%>.xml','lista','','VALUE_COL','LABEL_COL',fecha_envio+'-'+aseguradora+'-'+facturas_a+'-'+categoria,'KEY_COL','');*/}
function showLista()
{
 var fecha = document.form1.fecha_envio.value;
 var categoria = document.form1.categoria.value;
 var facturado_a = document.form1.facturas_a.value;
 var empresa = document.form1.aseguradora.value;
 var aseguradoraDesc = document.form1.aseguradoraDesc.value;
 var fp ='';
  abrir_ventana1('../facturacion/sel_list_envio.jsp?fp='+fp+'&fechaDesde='+fecha+'&fechaHasta='+fecha+'&categoria='+categoria+'&facturado_a='+facturado_a+'&empresa='+empresa+'&aseguradoraDesc='+aseguradoraDesc);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="70%" cellpadding="0" cellspacing="0">
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
										<%=fb.hidden("clearHT","")%>
										<%=fb.hidden("existe","")%>
                    <tr>
                      <td><table width="100%" cellpadding="1" cellspacing="0">
                          <tr class="TextPanel">
                            <td colspan="4" align="center"> <cellbytelabel>LISTA DE ENVIO</cellbytelabel> </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td><cellbytelabel>Fecha de env&iacute;o</cellbytelabel>:</td>
                            <td>
                              <jsp:include page="../common/calendar.jsp" flush="true">
                                <jsp:param name="noOfDateTBox" value="1"/>
                                <jsp:param name="format" value="dd/mm/yyyy"/>
                                <jsp:param name="nameOfTBox1" value="fecha_envio" />
                                <jsp:param name="valueOfTBox1" value="" />
                                <jsp:param name="jsEvent" value="creaXML()" />
                              </jsp:include>
                            </td>
                            <td><cellbytelabel>Facturas a</cellbytelabel>:</td>
                            <td>
														<%=fb.select("facturas_a","E=Empresa,P=Paciente","",false,viewMode,0,null,null,"onChange=\"javascript:creaXML();\"","","S")%> </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td>
                            <cellbytelabel>C&iacute;a. de Seguros</cellbytelabel>: </td>
														<td colspan="3">
														<%=fb.intBox("aseguradora","",false,false,false,5,"Text10",null,"onChange=\"javascript:creaXML();\"")%> 
														<%=fb.textBox("aseguradoraDesc","",false,false,true,30,"Text10",null,null)%> 
														<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%> 
                            </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td><cellbytelabel>Categor&iacute;a</cellbytelabel>:</td>
                            <td>
														<%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion descripcion from tbl_adm_categoria_admision order by codigo","categoria","",false,false,0,"Text10",null,"onChange=\"javascript:creaXML();\"","","")%>
														<%//=fb.select("categoria","1=Pacientes Hospitalizados,2=Pacientes Ambulatorios,3=Especial,4=Geriatria","",false,viewMode,0,null,null,"onChange=\"javascript:creaXML();\"","","S")%> 
                            </td>
                            <td> 
                            Listas: 
                            </td>
                            <td><%=fb.textBox("lista","",true,false,true,15,"Text10",null,null)%> <%=fb.button("btnLista","...",true,false,null,null,"onClick=\"javascript:showLista();\"")%>
														<!--<%//=fb.select("lista","","",false,viewMode,0,null,null,null,"","")%>
														<script language="javascript">
															loadXML('../xml/listaEnvio_<%=(String) session.getAttribute("_userName")%>.xml','lista','','VALUE_COL','LABEL_COL','','KEY_COL','');
														</script>-->
                            </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td><cellbytelabel>Comentario</cellbytelabel>: </td>
														<td colspan="3"><%=fb.textarea("comentario","",false,false,viewMode,80,5)%>
                            </td>
                          </tr>
                          <tr class="TextHeader02">
                            <td><cellbytelabel>Enviado por</cellbytelabel>: </td>
														<td colspan="3"><%=fb.textBox("enviado_por",(String)session.getAttribute("_userName"),false,false,false,30,"Text10",null,null)%> 
                            </td>
                          </tr>
                          <tr class="TextPanel">
                            <td colspan="4" align="center"><%=fb.button("add","Guardar Lista",false,false,"text10","","onClick=\"javascript:eject();\"")%><%=fb.button("inac","Inactivar Lista",false,false,"text10","","onClick=\"javascript:inactivar();\"")%><authtype type='50'><%=fb.button("edi","Editar Lista",false,false,"text10","","onClick=\"javascript:editar();\"")%></authtype></td>
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
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
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
