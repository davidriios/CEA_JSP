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
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String consecutivo = request.getParameter("consecutivo");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String cuenta = request.getParameter("cuenta");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String ctaCompleta = request.getParameter("ctaCompleta");
String clase = request.getParameter("clase");
String claseText = request.getParameter("claseText");
String descCuenta = request.getParameter("descCuenta");

if(fg==null) fg = "";
if(fp==null) fp ="";
if(consecutivo==null) consecutivo ="";
if(mes==null) mes ="";
if(anio==null) anio ="";
if(cuenta==null) cuenta ="";
if(cta1==null) cta1 ="";
if(cta2==null) cta2 ="";
if(cta3==null) cta3 ="";
if(cta4==null) cta4 ="";
if(cta5==null) cta5 ="";
if(cta6==null) cta6 ="";
if(ctaCompleta==null) ctaCompleta ="";
if(clase==null) clase ="";
if(claseText==null) claseText ="";
if(descCuenta==null) descCuenta ="";

String rptUrl = "&consecutivo="+consecutivo+"&mes="+mes+"&anio="+anio+"&cuenta="+cuenta+"&cta1="+cta1+"&cta2="+cta2+"&cta3="+cta3+"&cta4="+cta4+"&cta5="+cta5+"&cta6="+cta6+"&ctaCompleta="+ctaCompleta+"&clase="+clase+"&claseText="+claseText+"&descCuenta="+descCuenta;

if (request.getMethod().equalsIgnoreCase("GET")){
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script>
document.title = 'Contabilidad - '+document.title;
function doAction(){
$("#loadingmsg").remove();
}

function viewReports(rpt, type){
   var $rptCont = $("#ireports");
   var pCtrlHeader = $("#pCtrlHeader").is(":checked");
   var rptUrls = {
    REP1: {url:'contabilidad/aud_det_transaccional.rptdesign'},
    REP2: {url:'contabilidad/aud_cargos_transaccional.rptdesign'}
   };
   
   if (rptUrls[rpt]['url']){
     var _type = rptUrls[rpt]['type'];
     var _url = rptUrls[rpt]['url'];
     $rptCont.show(0).attr('src','../cellbyteWV/report_container.jsp?reportName='+_url+'<%=rptUrl%>&pCtrlHeader='+pCtrlHeader);
   }    
   
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Auditoría Comprobantes"></jsp:param>
</jsp:include> 
<table align="center" width="99%" cellpadding="0" cellspacing="0"> 
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
						<%=fb.hidden("fp",fp)%>
                    <tr class="TextRow02">
                      <td>
                        <table width="100%" cellpadding="1" cellspacing="1" align="center">
						  <tr class="TextFilter">
                            <td width="30%">Esconder Cabecera?</td>
							<td width="70%"><%=fb.checkbox("pCtrlHeader","false")%></td>
                          </tr> 
						  <tr class="TextFilter">
                            <td>Detalle de comprobantes</td>
							<td>
                                <%=fb.button("btn_aud1","Excel (Res)",false,false,"text10","","onClick=viewReports('REP1');")%>
                                <%if (clase.equals("5") || clase.equals("10")){%>
                                <%=fb.button("btn_aud2","Excel (Detalle Cargos)",false,false,"text10","","onClick=viewReports('REP2','R');")%><%}%>
							</td>
                          </tr>
                          
                          <tr><td colspan="2">&nbsp;</td></tr>
                          
                          <tr>
                            <td colspan="2">
                              <iframe id="ireports" name="ireports" width="100%" height="550px" style="display:none" scrolling="no" frameborder="0" border="0" src="">
                            </td>
                          </tr>

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
