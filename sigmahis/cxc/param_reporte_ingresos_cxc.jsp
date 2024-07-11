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

<%
/**
==================================================================================================================
==================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
StringBuilder sbSql = new StringBuilder();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
 if(fg==null) fg = "mes";
if(fp==null) fp ="INV";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
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
document.title = 'Contabilidad - '+document.title;
function setReferTo(obj){var referTo=getSelectedOptionTitle(obj,'');document.form1.refer_to.value=referTo;chkOther(referTo);}
function doAction(){chkOther('');}
function chkOther(referTo){if(referTo!='CXCO')document.form1.tipoOtro.value=''; document.form1.tipoOtro.disabled=(referTo!='CXCO');}

function viewReports(fg){
	var fDesde	= document.form1.fecha_desde.value;
	var	fHasta= document.form1.fecha_hasta.value;
	var pType = '';
	var pAccount1 = '';
	var pAccount2 = '';
	var pAccount3 = '';
	var pAccount4 = '';
	var pAccount5 = '';
	var pAccount6 = '';
	if(document.form1.account1) pAccount1 = document.form1.account1.value;
	if(document.form1.account2) pAccount2 = document.form1.account2.value;
	if(document.form1.account3) pAccount3 = document.form1.account3.value;
	if(document.form1.account4) pAccount4 = document.form1.account4.value;
	if(document.form1.account5) pAccount5 = document.form1.account5.value;
	if(document.form1.account6) pAccount6 = document.form1.account6.value;
	
	var refId = document.form1.codigo.value;
	var tipoOtro= document.form1.tipoOtro.value;
	var tipo = document.form1.tipo.value;
	var admision =  document.form1.admision.value;
	var facturado = 'ALL';// document.form1.facturado.value;
	
	var pCtrlHeader = document.form1.pCtrlHeader.checked;
    var pTipoAdm =document.form1.categoria.value || 'ALL';
	var pDestino = "";
	var  comprob ='';
	if(document.form1.comprob)comprob=document.form1.comprob.value;
	if(comprob =='')comprob='ALL';
  
	var fdArray = fDesde.split("/");
	var fhArray = fHasta.split("/");
	fDesde = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fHasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];

	if (pAccount1=="") pAccount1 = "000";
	if (pAccount2=="") pAccount2 = "00";
	if (pAccount3=="") pAccount3 = "000";
	if (pAccount4=="") pAccount4 = "000";
	if (pAccount5=="") pAccount5 = "000";
	if (pAccount6=="") pAccount6 = "000";
 
 	var _rpt_name ='rpt_libros_ingresos_det';
	if(fg=='RES')_rpt_name ='rpt_libros_ingresos_trx';
	//if(fHasta!=''&&fHasta!=''){ 
	   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/'+_rpt_name+'.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+(!comprob?'ALL':comprob)+'&pTipoAdm='+pTipoAdm+'&pCentro_servicio=-4&v_usa_cxc_cliente=&pRefId='+refId+'&pTipo='+tipo+'&pTipoOtro='+tipoOtro+'&pAdmision='+admision+'&pFacturado='+facturado);
	   
	//} else alert('Seleccione rango de fecha');

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generar Comprobante"></jsp:param>
</jsp:include>
<table align="center" width="95%" cellpadding="0" cellspacing="0">
  <tr align="center">
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
						<%=fb.hidden("banco","")%>
						<%=fb.hidden("fg",fg)%>
						<%=fb.hidden("fp",fp)%>
						<%=fb.hidden("clearHT","")%>
						<%=fb.hidden("refer_to", "")%>

                    <tr class="TextRow02">
                      <td>

                      <table width="100%" cellpadding="1" cellspacing="1" align="center">
                          <tr class="TextHeader">
                            <td align="left">Fecha para el proceso</td>
                            <td colspan="2" align="left">
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fecha_desde" />
                            <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                            <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                            <jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include>
                            </td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="25%" rowspan="8">Parametros Para reportes</td>
                            <td width="15%">&nbsp;</td>
							<td width="60%" align="left">&nbsp;
							   <%//=fb.textBox("account1","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account2","",false,false,false,3,2,"Text10",null,null)%>
							   <%//=fb.textBox("account3","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account4","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account5","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account6","",false,false,false,3,3,"Text10",null,null)%></td>
                          </tr>
 						  <tr class="TextFilter" align="left">
                            <td width="15%">Comprobante:</td>
							<td width="60%"><%=fb.select("comprob","S=SI,N=NO","","T")%></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Esconder Cabecera?</td>
							<td width="60%"><%=fb.checkbox("pCtrlHeader","false")%></td>
                          </tr>
 						  <tr class="TextFilter" align="left">
                            <td width="15%">Categoria Admisión</td>
							<td width="60%"><span title="" id="container-1">
							 <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria","","T")%>
							   </span></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Tipo Cliente</td>
							<td width="60%"><span title="" id="container-1">
							 <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion,refer_to from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and (activo_inactivo = 'A' or to_char(codigo) = get_sec_comp_param(compania, 'TP_CLIENTE_PAC')) order by descripcion","tipo","",false,false,0,"Text10","","onChange=\"javascript:setReferTo(this);\"","","T")%>&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where estado = 'A' and compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","tipoOtro","",false,false,0,"Text10","","","","T")%>
							   </span></td>
                          </tr>
						   <tr class="TextFilter" align="left">
                            <td width="15%">Paciente/Cliente</td>
							<td width="60%"><span title="" id="container-1">
							 <%=fb.textBox("codigo","",false,false,false,20,"Text10",null,null)%>&nbsp;&nbsp; Admision: <%=fb.textBox("admision","",false,false,false,20,"Text10",null,null)%>
							   </span></td>
                          </tr> 
						   <!--<tr class="TextFilter" align="left">
                            <td width="15%">Cargos Facturados:</td>
							<td width="60%"><%=fb.select("facturado","S=SI,N=NO","","T")%></td>
                          </tr>-->
						  <tr class="TextFilter" align="left">
                            <td  colspan="2" align="center"> <authtype type='59'><%=fb.button("rpt_libro","Rep. Auxiliar",false,false,"Text10","","onClick=\"javascript:viewReports('LIB');\"")%></authtype>
							<authtype type='60'><%=fb.button("rpt_libro","Rep. Auxiliar Por tipo TRX",false,false,"Text10","","onClick=\"javascript:viewReports('RES');\"")%></authtype></td>  
                          </tr> 
 

                        </table>
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
</body>
</html>
<%
}//GET
%>
