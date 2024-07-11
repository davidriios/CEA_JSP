<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iAseg" scope="session" class="java.util.Hashtable" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String docId = "";
String fp = request.getParameter("fp");
String change = request.getParameter("change");

String key = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if (change == null) iAseg.clear();

System.out.println("change = "+change);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Facturacion - Corte Cuenta - "+document.title;


function doAction()
{
  //setHeight('secciones',document.body.scrollHeight);
}
function generar()
{
var codPac = eval('document.paciente.codigoPaciente').value ;
var pac_id = eval('document.paciente.pacienteId').value ;
var fecha_nac = eval('document.paciente.fechaNacimiento').value ;
var secuencia = eval('document.paciente.admSecuencia').value ;
var empresa = eval('document.paciente.empresa').value ;

var compania = '<%=(String) session.getAttribute("_companyId")%>';
var user = '<%=session.getAttribute("_userName")%>';

	if(pac_id !='' && secuencia!='')
	{
		if(confirm('Desea Generar Corte Cuenta??'))
		{
			
			showPopWin('../common/run_process.jsp?fp=ADM&actType=51&docType=CORTE&docId='+secuencia+'&docNo='+secuencia+'&compania='+compania+'&fecha='+fecha_nac+'&pacId='+pac_id+'&noAdmision='+secuencia+'&codigoPaciente='+codPac+'&aseguradora='+empresa,winWidth*.75,winHeight*.65,null,null,'');

			/*if(executeDB('<%=request.getContextPath()%>','call sp_fac_corte_cuenta_manual('+compania+',\''+fecha_nac+'\','+codPac+','+secuencia+',\''+user+'\','+empresa+','+pac_id+')',''))
			CBMSG.warning('PROCESO FINALIZADO');
			window.location='../facturacion/fac_corte_cuenta_manual.jsp';
			*/
		}//else{ alert('PROCESO CANCELADO';}
	}
	else alert('No existe Paciente Seleccionado!');

}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="FACTURACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableBorder">
    <table align="center"  width="100%" cellpadding="5" cellspacing="0">
    <tr>
      <td class="TableBorder">
        <table width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextRow02">
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td width="85%">
<jsp:include page="../common/paciente.jsp" flush="true">
  <jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
  <jsp:param name="fp" value="corte_manual"></jsp:param>
  <jsp:param name="mode" value="<%=mode%>"></jsp:param>
  <jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
</jsp:include>
          </td>
					 <td width="15%" class="TextRow01" align="center"><%=fb.button("generar","Generar",false,false,null,null,"onClick=\"javascript:generar()\"")%></td>
        </tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("action","")%>
        <tr class="TextRow01">
          <td width="29%" class="TableBorder TextRow01" valign="top" colspan="2">
            <table width="100%" cellpadding="1" cellspacing="0" align="center">
						<tr class="TextRow01" align="center">
							<td colspan="3">&nbsp;</td>
						</tr>  
						<tr class="TextHeader" align="center">
							<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="60%"><cellbytelabel>Nombre De la compañia de Seguros</cellbytelabel></td>
							<td width="20%"><cellbytelabel>Prioridad</cellbytelabel></td>
						</tr>
						          
						
            <%
						al = CmnMgr.reverseRecords(iAseg);	
for (int i=0; i<iAseg.size(); i++)
{
	key = al.get(i).toString();		
	cdo = (CommonDataObject) iAseg.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%>
			<tr class="<%=color%>" align="center">
				<td><%=fb.textBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,15,"Text10",null,null)%>	</td>
				<td><%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),false,false,true,60,"Text10",null,null)%>	</td>
				<td><%=fb.textBox("priorida"+i,cdo.getColValue("prioridad"),false,false,true,5,"Text10",null,null)%>	</td>
      </tr>      
  <%}%>         
            </table>
           
          </td>
         
        </tr>
        
<%=fb.formEnd(true)%>

        </table>
      </td>
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
%>
