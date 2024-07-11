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
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
  
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

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

function doSubmit(value){document.form1.baction.value = value;}
function doAction(){} 
function process(fg){
var anio = document.form1.anio.value;
var mes = document.form1.mes.value;
var mesDesc =  getSelectedOptionLabel(document.form1.mes,''); 
var x=0;
if(anio.trim()!='' && mes.trim()!=''){
if(fg=='AUD'){var estado=getDBData('<%=request.getContextPath()%>','trim(estatus)','tbl_con_estado_meses ','ano='+anio+' and mes='+mes+' and cod_cia=<%=(String) session.getAttribute("_companyId")%>'); if(estado!='CER'){x++; CBMSG.warning('EL MES / AÑO  DEBE ESTAR CERRADO. CONSULTE CON EL DEPTO CONTABILIDAD/FINANZAS!');}}

if(x==0)showPopWin('../process/con_upd_mov_mes.jsp?fg='+fg+'&anio='+anio+'&mes='+mes+'&mesDesc='+mesDesc,winWidth*.75,winHeight*.65,null,null,'');

}else CBMSG.warning('Favor seleccionar MES / AÑO!');
}
 
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PROCESOS CONTABILIDAD"></jsp:param>
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
					<%=fb.hidden("errCode","")%>
					<%=fb.hidden("errMsg","")%>
					<%=fb.hidden("baction","")%> 
					<%=fb.hidden("clearHT","")%>
                    <tr>
                      <td>
					   <table width="100%" cellpadding="1" cellspacing="0">  
                          <tr class="TextPanel">
                            <td colspan="4">
                            ACTUALIZAR REGISTROS MENSUALES
                            </td>
                          </tr>
                          <tr class="TextHeader02">
						    <td width="25%">&nbsp;</td>
                            <td width="15%">AÑO:</td>
                            <td width="35%" align="left"><%=fb.textBox("anio",anio,false,false,false,4,4)%></td>
							<td width="25%">&nbsp;</td>
                          </tr>
						  <tr class="TextHeader02">
                            <td>&nbsp;</td>
							<td>MES:</td>
                            <td><%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE,13=CIERRE ANUAL","",false,false,0,"Text10",null,null,"","")%></td>
                            <td>&nbsp;</td>
						  </tr>
						  <tr class="textRow02"> 
                            <td>&nbsp;</td>
							<td colspan="2" align="left"><authtype type='51'><%=fb.button("ad","ACTUALIZAR SALDO INICIAL",false,false,"text10","","onClick=\"javascript:process('SI');\"")%></authtype></td>
							<td>&nbsp;</td>
                          </tr> 
						  <tr class="textRow02">
						  <td>&nbsp;</td>
                           <td colspan="2" align="left"><authtype type='52'><%=fb.button("add","ACTUALIZAR MOV. MENSUAL",false,false,"text10","","onClick=\"javascript:process('MM');\"")%></authtype></td>
						   <td>&nbsp;</td>
                          </tr>
						  <tr class="textRow02">
						  <td>&nbsp;</td>
                           <td colspan="2" align="left"><authtype type='53'><%=fb.button("add2","CREAR CUENTAS",false,false,"text10","","onClick=\"javascript:process('CC');\"")%></authtype></td>
						   <td>&nbsp;</td>
                          </tr>
						  <tr class="textRow02">
						  <td>&nbsp;</td>
                           <td colspan="2" align="left"><authtype type='54'><%=fb.button("add2","GENERAR AUDITORIA",false,false,"text10","","onClick=\"javascript:process('AUD');\"")%></authtype></td>
						   <td>&nbsp;</td>
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
} 
%>
