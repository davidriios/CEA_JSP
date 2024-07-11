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
String fg = request.getParameter("fg");
if(fg==null) fg = "AUD"; 
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
function doAction(){}
function viewReports(fg){
	var fDesde	= document.form1.fecha_desde.value;
	var	fHasta= document.form1.fecha_hasta.value;
	var pType = '';
	var pCtrlHeader = document.form1.pCtrlHeader.checked;
	var noCuenta ='';
	var fdArray = fDesde.split("/");
	var fhArray = fHasta.split("/");
	fIni = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fFin = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];
	var tipoComprob = '';
	var ctaPrincipal = '';
	var tipoCuenta = '';
	var colDebCre='N';
	var showHeader='N';
	var excluCheque='N';
	var pMes13='N';
	var pRegManual='N';
	
	if(document.form1.tipoComprob)tipoComprob= document.form1.tipoComprob.value;
	if(document.form1.ctaPrin)ctaPrincipal= document.form1.ctaPrin.value;
	if(document.form1.claseCta)tipoCuenta= document.form1.claseCta.value;
	if(document.form1.colDebCre)if(document.form1.colDebCre.checked)colDebCre= 'S';
	if(document.form1.showHeader)if(document.form1.showHeader.checked)showHeader= 'S';
	if(document.form1.excluCheque)if(document.form1.excluCheque.checked)excluCheque= 'S';
	if(document.form1.pMes13)if(document.form1.pMes13.checked)pMes13= 'S';
	if(document.form1.pRegManual)if(document.form1.pRegManual.checked)pRegManual= 'S';

	if(document.form1.cta1){
	var pAccount1 = document.form1.cta1.value;
	var pAccount2 = document.form1.cta2.value;
	var pAccount3 = document.form1.cta3.value;
	var pAccount4 = document.form1.cta4.value;
	var pAccount5 = document.form1.cta5.value;
	var pAccount6 = document.form1.cta6.value;
	
	
	if (pAccount1!="") noCuenta +=pAccount1;
	if (pAccount2!="") noCuenta +='.'+pAccount2;
	if (pAccount3!="") noCuenta +='.'+pAccount3;
	if (pAccount4!="") noCuenta +='.'+pAccount4;
	if (pAccount5!="") noCuenta +='.'+pAccount5;
	if (pAccount6!="") noCuenta +='.'+pAccount6; 
	if (noCuenta=='')noCuenta='0';}
	
	if(fDesde!=''&&fHasta!=''){
	if(fg=='REP1') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_transacciones_aud.rptdesign&fDesde='+fIni+'&fHasta='+fFin+'&pAccount='+noCuenta+'&pCtrlHeader='+pCtrlHeader+'&tipoComprob='+tipoComprob+'&pCuentaPrincipal='+ctaPrincipal+'&pTipoCuenta='+tipoCuenta+'&pMes13='+pMes13+'&pRegManual='+pRegManual);
	else if(fg=='REP2') showPopWin('../common/generate_file.jsp?fp=AUDTRX&docType=AUDTRX&fDesde='+fDesde+'&fHasta='+fHasta+'&noCuenta='+noCuenta+'&tipoComprob='+tipoComprob+'&cuentaPrincipal='+ctaPrincipal+'&tipoCuenta='+tipoCuenta+'&pMes13='+pMes13+'&pRegManual='+pRegManual,winWidth*.75,winHeight*.65,null,null,'');
	else if(fg=='REP2-R') showPopWin('../common/generate_file.jsp?fp=AUDTRXRES&docType=AUDTRXRES&fDesde='+fDesde+'&fHasta='+fHasta+'&noCuenta='+noCuenta+'&tipoComprob='+tipoComprob+'&cuentaPrincipal='+ctaPrincipal+'&tipoCuenta='+tipoCuenta+'&pMes13='+pMes13+'&pRegManual='+pRegManual,winWidth*.75,winHeight*.65,null,null,'');
	else if(fg=='REP2-1') showPopWin('../common/generate_file.jsp?fp=AUDTRX2&docType=AUDTRX2&fDesde='+fDesde+'&fHasta='+fHasta+'&noCuenta='+noCuenta+'&tipoComprob='+tipoComprob+'&cuentaPrincipal='+ctaPrincipal+'&tipoCuenta='+tipoCuenta+'&colDebCre='+colDebCre+'&showHeader='+showHeader+'&pMes13='+pMes13+'&pRegManual='+pRegManual,winWidth*.75,winHeight*.65,null,null,'');
	else if(fg=='REP3') showPopWin('../common/generate_file.jsp?fp=MEF72&docType=MEF72&fDesde='+fDesde+'&fHasta='+fHasta+'&pExcluyeCheque='+excluCheque,winWidth*.75,winHeight*.65,null,null,'');
	else if(fg=='REP4') showPopWin('../common/generate_file.jsp?fp=MEF94&docType=MEF94&fDesde='+fDesde+'&fHasta='+fHasta+'&pExcluyeCheque='+excluCheque,winWidth*.75,winHeight*.65,null,null,'');
	else if(fg=='REP5') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_informes_mef_72_94.rptdesign&fDesde='+fIni+'&fHasta='+fFin+'&pCtrlHeader='+pCtrlHeader+'&pConcepto=72&pExcluyeCheque='+excluCheque);
	else if(fg=='REP6') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_informes_mef_72_94.rptdesign&fDesde='+fIni+'&fHasta='+fFin+'&pCtrlHeader='+pCtrlHeader+'&pConcepto=94&pExcluyeCheque='+excluCheque);

	}
	else CBMSG.warning('INTRODUZCA VALORES EN CAMPOS DE FECHA');

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generar Comprobante"></jsp:param>
</jsp:include> 
<table align="center" width="95%" cellpadding="0" cellspacing="0"> 
  <tr align="center"> 
    <td class="TableBorder">
	<table align="center" width="100%" cellpadding="5" cellspacing="0"> 
        <tr> 
          <td class="TableBorder">
		  <table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td>
				 <table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%> 
						<%=fb.hidden("fg",fg)%>  
                    <tr class="TextRow02">
                      <td>
                        <table width="100%" cellpadding="1" cellspacing="1" align="center">
                          <tr class="TextHeader">
                            <td align="left">Fecha para el proceso</td>
                            <td colspan="2" align="left">
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fecha_desde" />
                            <jsp:param name="valueOfTBox1" value="" />
                            <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                            <jsp:param name="valueOfTBox2" value="" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include>
                            </td>
                          </tr>
						  
						  <tr class="TextFilter" align="left">
                            <td width="25%" rowspan="8">Parametros Para reportes</td>
                             <%if(fg.trim().equals("AUD")){%>
							 
							<td width="15%">Cuenta Principal:&nbsp;</td>							
							<td width="60%" align="left"><%=fb.select(ConMgr.getConnection(),"select codigo_prin as codigo, descripcion cta_dsp from tbl_con_ctas_prin  order by descripcion","ctaPrin","",false,false,0,"Text10",null,"",null,"T")%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
							
							</tr>
							<tr class="TextFilter" align="left">
								<td width="15%">Clase Cuenta:&nbsp;</td>							
								<td width="60%" align="left"><%=fb.select(ConMgr.getConnection(),"select codigo_clase, descripcion clase_dsp from tbl_con_cla_ctas order by descripcion","claseCta","",false,false,0,"Text10",null,"",null,"T")%></td> 
						    </tr>
							<tr class="TextFilter" align="left">
								<td width="15%">Cuenta:&nbsp;</td>							
								<td width="60%" align="left">
								   <%=fb.textBox("cta1","",false,false,false,3,3,"Text10",null,null)%>
								   <%=fb.textBox("cta2","",false,false,false,3,2,"Text10",null,null)%>
								   <%=fb.textBox("cta3","",false,false,false,3,3,"Text10",null,null)%>
								   <%=fb.textBox("cta4","",false,false,false,3,3,"Text10",null,null)%>
								   <%=fb.textBox("cta5","",false,false,false,3,3,"Text10",null,null)%>
								   <%=fb.textBox("cta6","",false,false,false,3,3,"Text10",null,null)%>
								  </td>
							   </tr>
							   <tr class="TextFilter" align="left">
								<td> Tipo Comprob. :&nbsp;</td>							
								<td align="left"> 
								  <%=fb.select(ConMgr.getConnection(), "select codigo_comprob,codigo_comprob||' - '||substr(descripcion,1,65) as descripcion from tbl_con_clases_comprob where tipo='C'","tipoComprob","",false,false,0,"Text10",null,null,null,"S")%>
								   
								   </td>
							   </tr>
							   <tr class="TextFilter" align="left">
								<td> Solo Mes Cierre:&nbsp;</td>							
								<td align="left"> 
								  <%=fb.checkbox("pMes13","false")%>
								   &nbsp;&nbsp;&nbsp;&nbsp; Solo Registros Manuales:  <%=fb.checkbox("pRegManual","false")%>
								   </td>
							   </tr>
							   <%}else{%>
							   <td width="15%">&nbsp;</td>							
							    <td width="60%" align="left">&nbsp;</td>	
								</tr>
							   <%}%>
							   
                          
						  <!--<tr class="TextFilter" align="left">
                            <td width="15%">Comprobante:</td>
							<td width="60%"><%//=fb.textBox("noComprob","",false,false,false,5,30,"Text10",null,null)%></td>
                          </tr>-->
						  <tr class="TextFilter" align="left">
                            <td width="15%">Esconder Cabecera?</td>
							<td width="60%"><%=fb.checkbox("pCtrlHeader","false")%></td>
                          </tr> 
						  <%if(fg.trim().equals("AUD")){%>
						   <tr class="TextFilter" align="left">
                            <td><authtype type='50'><%=fb.button("mov_trx","Rep. Movimiento Transac. x Cuenta",false,false,"text10","","onClick=\"javascript:viewReports('REP1');\"")%></authtype>
							    </td>
							<td><authtype type='51'><%=fb.button("mov_trx_aud","Transaccional por Cuenta (Auditoria) - ARCHIVO TXT",false,false,"text10","","onClick=\"javascript:viewReports('REP2');\"")%></authtype>
							<br>
							<authtype type='54'><%=fb.button("mov_trx_aud","Transaccional por Cuenta (Auditoria) Detallada - ARCHIVO TXT",false,false,"text10","","onClick=\"javascript:viewReports('REP2-1');\"")%>Mostrar Col. DEB|CRE <%=fb.checkbox("colDebCre","false")%>&nbsp;&nbsp;Mostrar Titulo<%=fb.checkbox("showHeader","false")%></authtype>
							
							<br>
							<authtype type='55'><%=fb.button("mov_trx_aud_res","Transaccional por Cuenta (Auditoria) Resumida - ARCHIVO TXT",false,false,"text10","","onClick=\"javascript:viewReports('REP2-R');\"")%></authtype>
							
							</td>
                          </tr> 
						  <%}%>
						  <%if(fg.trim().equals("MEF")){%>
						   <tr class="TextFilter" align="left">
						    <td colspan="2"> Excluir Cheques:<%=fb.checkbox("excluCheque","false")%> </td>
						   </tr>
						   
						   <tr class="TextFilter" align="left">
                            <td><authtype type='52'><%=fb.button("informe72","INFORME 72 - ARCHIVO TXT",false,false,"text10","","onClick=\"javascript:viewReports('REP3');\"")%>
							<br><%=fb.button("rep72","REPORTE",false,false,"text10","","onClick=\"javascript:viewReports('REP5');\"")%></authtype>
							
							</td>
							<td><authtype type='53'><%=fb.button("informe94","INFORME 94 - ARCHIVO TXT",false,false,"text10","","onClick=\"javascript:viewReports('REP4');\"")%><br>
							<%=fb.button("rep94","REPORTE",false,false,"text10","","onClick=\"javascript:viewReports('REP6');\"")%></authtype>
							</td>
                          </tr> 
						  <%}%>
   						</table>
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
         <!-- ================================   F O R M   E N D   H E R E   ================================ -->
   </table>
      </td> 
  </tr> 
</table>  
</body>
</html>
<%
}//GET
%>
