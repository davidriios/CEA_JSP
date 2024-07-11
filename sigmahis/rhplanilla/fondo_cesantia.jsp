
<%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="FPMgr" scope="page" class="issi.rhplanilla.FilePlanillaMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
FPMgr.setConnection(ConMgr);

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");	
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();
int iconHeight = 20;
int iconWidth = 20;
String anio = request.getParameter("anio");
String trimestre = request.getParameter("trimestre");

if (anio == null) anio = "";
if (trimestre == null) trimestre = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - Fondo de Cesantía - '+document.title;
function doAction()
{setFecha();
}
function setFecha()
{
 var anio = document.form0.anio.value; 
 var trimestre = document.form0.trimestre.value;

	if (anio!=null && anio!='' && trimestre!=null && trimestre!='')
    {
	 		 if(trimestre==1)
			 {
			 document.form0.fecha_inicial.value  = '01/01/'+anio;
			 document.form0.fecha_final.value = '31/03/'+anio;
			 } else if(trimestre==2)
			 {
			 document.form0.fecha_inicial.value = '01/04/'+anio;
			 document.form0.fecha_final.value = '30/06/'+anio;
			 } else if(trimestre==3)
			 {
			 document.form0.fecha_inicial.value = '01/07/'+anio;
			 document.form0.fecha_final.value = '30/09/'+anio;
			 } else if(trimestre==4)
			 {
			 document.form0.fecha_inicial.value = '01/10/'+anio;
			 document.form0.fecha_final.value = '31/12/'+anio;
			 } 
	}
}
function generarFondoCs()
{  
  var anio='';
  var trimestre; 
  var tot = "0.00";
  var dayOfMonth = 0;
  var fecha_inicial = "";
  var fecha_final = "";
  anio = document.form0.anio.value; 
  trimestre = document.form0.trimestre.value;
  if (anio!=null && anio!='' && trimestre!=null && trimestre!='')
  {
	  if(confirm('Está seguro(a) que desea Generar el Fondo de Cesantía para este periodo...?'+anio+' '+trimestre))
	  {
    
	 		setFecha();
			fecha_inicial = document.form0.fecha_inicial.value;
			fecha_final   = document.form0.fecha_final.value;
				showPopWin('../common/run_process.jsp?fp=FCESAN&actType=50&docType=FCESAN&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+trimestre+'&fecha='+fecha_inicial+'&fechaFinal='+fecha_final,winWidth*.75,winHeight*.65,null,null,'');
	
	  }
  }else alert('Introduzca el valores en los campos!');
}
function printCes()
{
	var trimestre=document.form0.trimestre.value;
	var anio=document.form0.anio.value;
	abrir_ventana('../rhplanilla/print_cesantia.jsp?trimestre='+trimestre+'&anio='+anio);
}
function printCesLiq()
{
	var trimestre=document.form0.trimestre.value;
	var anio=document.form0.anio.value;
	if(anio != null && anio !=''){
	setFecha();
	var fecha_inicial=document.form0.fecha_inicial.value;
	var fecha_final=document.form0.fecha_final.value;	
	abrir_ventana('../rhplanilla/print_cesantia_liq.jsp?trimestre='+trimestre+'&anio='+anio+'&fecha_inicio='+fecha_inicial+'&fecha_final='+fecha_final);}
	else alert('Introduzca Valor en Campo Año!');
}
function creaArchivo(fName,value)
{
	setBAction(fName,value);
	var anio=document.form0.anio.value;
	if(anio != null && anio !='')document.form0.submit();
	else alert('Introduzca Valor en Campo Año!');
}
function showFile(){
var anio=document.form0.anio.value;
var trimestre=document.form0.trimestre.value;
				
if(anio.trim()==''){alert('Introduzca Año!');return false;}
if(trimestre.trim()==''){alert('Seleccione el trimestre!');return false;}
showPopWin('../common/generate_file.jsp?fp=FCESAN&docType=FCESAN&trimestre='+trimestre+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="FONDO DE CESANTIA "></jsp:param>
	</jsp:include>

	

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("fecha_final","")%>
			<%=fb.hidden("fecha_inicial","")%>
			<%=fb.hidden("baction","")%>

			
			<tr class="TextHeader">
				<td colspan="8">Fondo de Cesant&iacute;a</td>
			</tr>
						
			<tr class="TextRow02">
				<td colspan="8">Proceso </td>
			</tr>
						
			
	<tr class="TextRow01">
				
	<td rowspan="2" width="20%">Año<br><%=fb.intBox("anio",anio,false,false,false,5,4,null,null,"")%></td>
	<td rowspan="2"  width="20%">Trimestre<br><%=fb.select("trimestre","1=PRIMERO,2=SEGUNDO,3=TERCERO,4=CUARTO",trimestre,false,false,0,"Text10",null,null)%>	</td>
	<td align="left" width="10%">Generar Datos</td>
	<td align="center" width="10%"><authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/proceso.bmp" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:generarFondoCs()"></authtype></td>
	<td align="left" width="10%">Informe #1</td>
	<td align="center" width="10%"><authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:printCes()"></authtype></td>
	<td align="left" width="10%">Informe #2(Liquidaciones)</td>
	<td align="center" width="10%"><authtype type='52'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:printCesLiq()"></authtype>
	</td>
	</tr>
	
	<tr class="TextRow01">
			<td align="left">Crear Disco</td>
			<td align="center"><authtype type='53'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/disc.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Generar Archivo')" onClick="javascript:showFile()"></authtype></td>
			<td colspan="4">&nbsp;</td>		
	</tr>
	<tr class="TextRow01">
		<td colspan="8">&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="8">&nbsp;</td>
	</tr>
	
	
	
	<%=fb.formEnd(true)%>
	<!-- ========================   F O R M   E N D   H E R E   ========================= -->
	</table>
		
</td></tr>
		

</table>
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");

			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("trimestre",request.getParameter("trimestre"));
			cdo.addColValue("anio",request.getParameter("anio"));
			cdo.addColValue("fg","FCESAN");
			cdo.addColValue("name","CESANTIA");
			
			
		
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (baction.equalsIgnoreCase("Generar")) FPMgr.createFile(cdo,"");
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (FPMgr.getErrCode().equals("1")) { %>alert('<%=FPMgr.getErrMsg()%>');window.location= '<%=request.getContextPath()+request.getServletPath()%>?anio=<%=anio%>&trimestre=<%=trimestre%>';
<% } else throw new Exception(FPMgr.getErrException()); %>}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>