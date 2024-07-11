<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.StringTokenizer" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String codigo = request.getParameter("codigo");
String codDet = request.getParameter("codDet");  
String compania = (String) session.getAttribute("_companyId");
String wh = request.getParameter("wh");  
String tipo = request.getParameter("tipo");  
if(codigo==null) codigo="";
if(codDet==null) codDet="";
if(wh==null) wh=""; 
if(tipo==null) tipo=""; 

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (codDet.trim().equals("") || codigo.trim().equals("")) throw new Exception("Parametros invalidos para actualizar Ajuste !. Por favor verifique e intente nuevamente!"); 

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACION - ACTUALIZACION DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("codDet",codDet)%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("wh",wh)%> 
			<%=fb.hidden("tipo",tipo)%> 
				<tr class="TextHeader" align="center">
					<td colspan="2">ACTUALIZAR AJUSTE DE FACTURACION Y ACTUALIZAR INVENTARIO</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de actualizar ajustes?</font></cellbytelabel></td>
				</tr>
                 
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>    
	</tr>
</table>		

</body>
</html>
<%
}//GET
else
{   
			 
			
			 
	sbSql = new StringBuffer();
	String refer_no1 = "0";
	String refer_no2 = "0";
    String docId = "", docNo = "", trxId = "", ruc = "",nombre="";
     
  
  sbSql.append("call sp_fac_detalle_aj_upd_inv(?,?,?,?,?,?,?,?)");
  CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	  param.setSql(sbSql.toString());
	    param.addInNumberStmtParam(1,compania);
		param.addInNumberStmtParam(2,request.getParameter("codigo"));
		param.addInNumberStmtParam(3,request.getParameter("codDet"));
		param.addInNumberStmtParam(4,request.getParameter("wh"));
		param.addInStringStmtParam(5,(String) session.getAttribute("_userName")); 
		param.addInStringStmtParam(6,request.getParameter("tipo"));
		
		param.addOutStringStmtParam(7);
		param.addOutStringStmtParam(8); 

		param = SQLMgr.executeCallable(param); 
		/*for (int i=0; i<param.getStmtParams().size(); i++) {
			CommonDataObject.StatementParam pp = param.getStmtParam(i);		
			if (pp.getType().contains("o")) {		
				if (pp.getIndex() == 7) if(pp.getData()!= null)refer_no1 = pp.getData().toString();
				if (pp.getIndex() == 8) if(pp.getData()!= null)refer_no2 = pp.getData().toString();		
			}		
		}
System.out.println("refer_no1 ==="+refer_no1 );
System.out.println("refer_no2 ==="+refer_no2 ); */
  
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	//parent.printDgiFact(0,0,0,0,'<%=nombre%>');
	<%//if(refer_no1 != "0"){%>//parent.printDgiFact(<%=docId%>,<%=docNo%>,<%=trxId%>,<%=ruc%>);<%//}%>
	parent.hidePopWin(false);
	//parent.window.location.reload(false);
<%
	
} else throw new Exception(SQLMgr.getErrException());
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