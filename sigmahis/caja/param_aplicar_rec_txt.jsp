<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FPMgr" scope="page" class="issi.admin.FileMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

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
FPMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
Hashtable ht = null;  
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5); 

String compania=(String) session.getAttribute("_companyId");
int iconHeight = 20;
int iconWidth = 20;
//String fileRoot = java.util.ResourceBundle.getBundle("path").getString("docs.asientos")+"/"; 

String tipoCliente = request.getParameter("tipoCliente");
String fp = request.getParameter("fp");
String codigo = request.getParameter("codigo");
String anio = request.getParameter("anio");
String recibo = request.getParameter("recibo");

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{
		//docPath = ResourceBundle.getBundle("path").getString("docs.pagosAseg");//.replace(ResourceBundle.getBundle("path").getString("root"),""); 

	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("docs.pagosAseg"),20,true); 
	 
	 tipoCliente = (String) ht.get("tipoCliente");
	 fp = (String) ht.get("fp");
     codigo = (String) ht.get("codigo");
     anio = (String) ht.get("anio");
     recibo =(String) ht.get("recibo"); 
	
}else{

     tipoCliente = request.getParameter("tipoCliente");
	 fp = request.getParameter("fp");
     codigo = request.getParameter("codigo");
     anio = request.getParameter("anio");
     recibo = request.getParameter("recibo");	 

}

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
function readFile(){
var anio=document.form1.anio.value;
var codigo=document.form1.codigo.value; 
var recibo=document.form1.recibo.value; 
var file=document.form1.archivo.value; 
if(anio.trim()==''){alert('Año Del recibo invalido!');return false;} 
var pos = (document.form1.archivo.value).lastIndexOf('\\');
var nombre = file.substring(file.lastIndexOf('\\')+1); 
if(file!=''){ document.form1.nombreReal.value=nombre; document.form1.submit();}  
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
					<%=fb.hidden("fp",""+fp)%> 
					<%=fb.hidden("tipoCliente",""+tipoCliente)%>  
					<%=fb.hidden("nombreReal","")%>  
					
                    <tr>
                      <td>
					   <table width="100%" cellpadding="1" cellspacing="0">  
                          	<tr class="TextHeader">
								<td colspan="2">Cargar archivo - Pagos de Aseguradoras </td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">Proceso </td>
							</tr>
							<tr class="TextRow02">
				<td width="60%" colspan="2">&nbsp;	
					<table align="center" width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow02">
							<td width="10%">Año</td>
							<td width="10%"><%=fb.intBox("anio",anio,false,false,true,5,4,null,null,"")%></td>
							<td width="10%">Recibo</td>
							<td width="70%"><%=fb.hidden("codigo",codigo)%><%=fb.intBox("recibo",recibo,false,false,true,5,4,null,null,"")%>
							Archivo: <%=fb.fileBox("archivo","",true,false,15,"","","")%>&nbsp;&nbsp; <authtype type='51'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/proceso.bmp" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Cargar File')" onClick="javascript:readFile('<%=fb.getFormName()%>','Generar')">Cargar Archivo</authtype>
							</td>
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
} else{
 
	String procesar="";
	String errorCode = "", errorMsg = "",fileName="",docPath="",nombreReal="";

    fileName   = (String)ht.get("archivo");
	nombreReal = (String)ht.get("nombreReal");
	//FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.pagosAseg");//.replace(ResourceBundle.getBundle("path").getString("root"),""); 
	cdo.addColValue("fileSep","|");	 
	cdo.addColValue("table","tbl_cja_detalle_pago_txt"); 
	cdo.addColValue("archivo",docPath+"/"+fileName);
	cdo.addColValue("checkReg","S");
	cdo.addColValue("checkRegWhere"," where compania="+compania+" and nombre_real='"+nombreReal+"'");
	cdo.addColValue("columns","id,compania,anio,codigo,recibo,fecha_creacion,fecha_modificacion, usuario_creacion,usuario_modificacion,estado,nombre_real,nombre_archivo,other1,other2,monto,factura");
	cdo.addColValue("values","(select nvl(max(id),0)+1 from tbl_cja_detalle_pago_txt),"+compania+","+anio+","+codigo+",'"+recibo+"',sysdate,sysdate,'"+(String) session.getAttribute("_userName")+"','"+(String) session.getAttribute("_userName")+"','C','"+nombreReal+"','"+fileName+"'");
    System.out.println(" error === "+FPMgr.getErrCode());
	
	
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath()); 		
		FPMgr.loadFile(cdo);
		ConMgr.clearAppCtx(null);
		if(!FPMgr.getErrCode().equals("1")){procesar="N";System.out.println("error === "+FPMgr.getErrMsg()); throw new Exception(FPMgr.getErrMsg()+" PUEDE QUE EL ARCHIVO YA FUE CARGADO VERIFIQUE LAS FACTURAS APLICADAS AL RECIBO! ");}
		else procesar="S"; 
	
	
	if (procesar.trim().equals("S"))
	{
		CommonDataObject param = new CommonDataObject();
		
		param.setSql("call sp_cja_aplicar_recibo_txt (?,?,?,?,?)");
		param.addInStringStmtParam(1,compania);
		param.addInStringStmtParam(2,anio);
		param.addInStringStmtParam(3,codigo);
		param.addInStringStmtParam(4,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));  
		param.addInStringStmtParam(5,IBIZEscapeChars.forSingleQuots(nombreReal));  
 		
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"anio="+anio+"&codigo="+codigo);
		param = SQLMgr.executeCallable(param);
		ConMgr.clearAppCtx(null);
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
		
	errorCode = SQLMgr.getErrCode();
	errorMsg  = SQLMgr.getErrCode().equals("1")?"Archivo cargado y aplicado satisfactoriamente !":SQLMgr.getErrCode();

	}
	
	//docDesc="PARA GENERAR APLICACION DE PAGO DE ASEGURADORAS";
	
 %>
 
<html>
<head>
<script type="text/javascript">
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
	//window.location = '<%=request.getContextPath()%>/inventario/cargar_archivo_pdt_config.jsp?mode=edit&archivoId=<%=(String)ht.get("id")%>';
	parent.hidePopWin(true);
<%
} else throw new Exception(errorMsg);
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