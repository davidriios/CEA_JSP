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
int iconHeight = 20;
int iconWidth = 20;
//String fileRoot = java.util.ResourceBundle.getBundle("path").getString("docs.asientos")+"/"; 

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
function showReporte()
{
	var anio=document.form1.anio.value;
	var mes=document.form1.mes.value; 
	if(anio != null && anio !='')abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&mes='+mes+'&tipo=&fg=PLA&docType=PLAEXT&regType=')
	else alert('Introduzca Valor en Campo Año!');
}
function readFile(){
var anio=document.form1.anio.value;
var mes=document.form1.mes.value; 
var file=document.form1.archivo.value; 
if(anio.trim()==''){alert('Introduzca Año!');return false;}
if(mes.trim()==''){alert('Seleccione Mes!');return false;} 
var pos = (document.form1.archivo.value).lastIndexOf('\\');
if(file!='') showPopWin('../common/read_file.jsp?fp=FILEPLA&docType=FILEPLA&cargar=S&mes='+mes+'&anio='+anio+'&fileName='+file.substring(file.lastIndexOf('\\')+1),winWidth*.75,winHeight*.45,null,null,'');
else CBMSG.warning('SELECCIONE EL ARCHIVO A PROCESAR');

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
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>

                    <%=fb.formStart(true)%> 
					<%=fb.hidden("errCode","")%>
					<%=fb.hidden("errMsg","")%>
					<%=fb.hidden("baction","")%> 
					<%=fb.hidden("clearHT","")%>
                    <tr>
                      <td>
					   <table width="100%" cellpadding="1" cellspacing="0">  
                          	<tr class="TextHeader">
								<td colspan="2">Cargar archivo - Pagos de Planilla </td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">Proceso </td>
							</tr>
							<tr class="TextRow02">
				<td width="60%">&nbsp;	
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow02">
							<td width="10%">Año</td>
							<td width="10%"><%=fb.intBox("anio",anio,false,false,false,5,4,null,null,"")%></td>
							<td width="10%">Mes</td>
							<td width="70%"><%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,null,null,"")%>
							Archivo: <%=fb.fileBox("archivo","",true,false,15,"","","")%>
							</td>
						</tr>
																							
					</table>
				</td>
				<td width="40%">
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow02">
							<td width="40%">Cargar Archivo</td>
							<td width="60%"><authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/proceso.bmp" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Cargar File')" onClick="javascript:readFile('<%=fb.getFormName()%>','Generar')"></authtype>
							</td>
						</tr>
						<tr class="TextRow02">
							<td>Reporte</td>
							<td><authtype type='52'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:showReporte()"></authtype></td>
						</tr>
						
						
					</table>
				 </td>
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
