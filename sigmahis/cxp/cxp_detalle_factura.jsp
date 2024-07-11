<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%

SecMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String empId = request.getParameter("empId");
String prov = request.getParameter("prov"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id"); 
///num="13";

if (anio == null || num == null) throw new Exception("El Número de Factura no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select a.anio_recepcion anio, a.numero_documento num, a.descripcion, a.monto, a.renglon, a.cg_1_cta1 cta1, a.cg_1_cta2 cta2, a.cg_1_cta3 cta3, a.cg_1_cta4 cta4, a.cg_1_cta5 cta5, a.cg_1_cta6 cta6 from tbl_adm_detalle_factura a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.numero_documento="+num+" and a.anio_recepcion = "+anio;
	al = SQLMgr.getDataList(sql);
	System.out.println("sql = "+al.size()+"//"+sql+"//****//"+id);	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle de Factura - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}


function printList(empId,prov,anio,num)
{
	abrir_ventana('../rhplanilla/print_list_comprobante_pago.jsp?empId='+empId+'&prov='+prov+'&anio='+anio+'&num='+num);
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="DETALLE DE FACTURA"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("num",num)%>
<%=fb.hidden("anio",anio)%>
<table width="100%" cellpadding="1" cellspacing="1">
 
  <tr>
    <td align="right" colspan="9">&nbsp;
   </td>
  </tr>
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";	
	
	double 	totExtra = 0.00;
	int 		contExtra = 0;
	int 		contDesc = 0;
	double 	totDesc = 0.00;					
%>

 <tr class="TextHeader">
    <td colspan="2">&nbsp; <cellbytelabel>Proveedor</cellbytelabel> : <%=prov%></td>
    <td colspan="3">&nbsp;<cellbytelabel>A&ntilde;o</cellbytelabel> :<%=cdo.getColValue("anio")%></td>
    <td colspan="4">&nbsp;<cellbytelabel>No. Recepci&oacute;n</cellbytelabel> : <%=cdo.getColValue("num")%></td>
   
 </tr>

 <tr align="center" class="TextHeader">
    <td width="10%"><cellbytelabel>Sec</cellbytelabel>.</td>
    <td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
    <td width="10%">&nbsp;<cellbytelabel>Monto</cellbytelabel></td>
    <td width="5%">&nbsp;</td>
    <td width="5%">&nbsp;</td>
    <td width="5%">&nbsp;</td>
    <td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
    <td width="5%">&nbsp;</td>
 </tr>

  
 <tr class="TextHeader">
    <td align="left">&nbsp; </td>
    <td align="center"><cellbytelabel>Factura</cellbytelabel></td>
		<td align="center">&nbsp;</td>
    <td colspan="6" align="center"><cellbytelabel>Cuenta Afectada</cellbytelabel> </td>
		
 </tr>
  <tr class="TextRow01">
    <td align="left"><%=cdo.getColValue("renglon")%> </td>
    <td><%=cdo.getColValue("descripcion")%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
    <td align="center"><%=cdo.getColValue("cta1")%> </td>
		<td align="center"><%=cdo.getColValue("cta2")%> </td>
		<td align="center"><%=cdo.getColValue("cta3")%> </td>
		<td align="center"><%=cdo.getColValue("cta4")%> </td>
		<td align="center"><%=cdo.getColValue("cta5")%> </td>
		<td align="center"><%=cdo.getColValue("cta6")%> </td>
 </tr>
 
  <%
	}
	%>
	
</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
