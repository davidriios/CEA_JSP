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
String fechaIni = request.getParameter("fechaIni");
String fechafin = request.getParameter("fechafin");
String companiaHosp = request.getParameter("companiaHosp");
String compFar = request.getParameter("compFar");
String compania = (String) session.getAttribute("_companyId");
String tipo = request.getParameter("tipo");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
String validaCja = request.getParameter("validaCja");

String cajaTrx = request.getParameter("cajaTrx");
String turnoTrx = request.getParameter("turnoTrx");

if(turno==null) turno="";
if(caja==null) caja="";
if(validaCja==null) validaCja="";
if(cajaTrx==null) cajaTrx="";
if(turnoTrx==null) turnoTrx="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (fechaIni == null) throw new Exception("Parametros invalidos para generar Factura !. Por favor intente nuevamente!");
		if(!compania.trim().equals(compFar))throw new Exception("Proceso solo para compañia definida para Interfaz Farmacia!");
if(validaCja.trim().equals("S") && turno.trim().equals(""))throw new Exception("No ha Definido Caja O No tiene turno Creado. Por Favor Consulte con su administrador !");
if(validaCja.trim().equals("S") && caja.trim().equals("")) throw new Exception("No ha Definido Caja O No tiene turno Creado. Por Favor Consulte con su administrador !");

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
	<jsp:param name="title" value="CXC - PROCESOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("fechaIni",fechaIni)%>
			<%=fb.hidden("fechafin",fechafin)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("companiaHosp",companiaHosp)%>
			<%=fb.hidden("compFar",compFar)%>
			<%=fb.hidden("turno",turno)%>
			<%=fb.hidden("caja",caja)%>
			<%=fb.hidden("cajaTrx",cajaTrx)%>
			<%=fb.hidden("turnoTrx",turnoTrx)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Generar Facturas al POS</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de generar FACTURA DESDE <%=fechaIni%>&nbsp;&nbsp;HASTA&nbsp;&nbsp;<%=fechafin%></font></cellbytelabel></td>
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

	sbSql.append("call sp_far_facturar_cargo_pos(?,?,?,?,?,?,?,?,?,?,?,?)");
	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
		param.setSql(sbSql.toString());
		param.addInNumberStmtParam(1,companiaHosp);
		param.addInStringStmtParam(2,request.getParameter("fechaIni"));
		param.addInStringStmtParam(3,request.getParameter("fechafin"));
		param.addInNumberStmtParam(4,compFar);
		param.addInStringStmtParam(5,(String) session.getAttribute("_userName"));
		param.addInStringStmtParam(6,"ME");
		if(validaCja.trim().equals("S"))param.addInNumberStmtParam(7,request.getParameter("turno"));
		else param.addInNumberStmtParam(7,0);

		if (validaCja.equalsIgnoreCase("S") && caja != null && !caja.trim().equals("")) {
			if (caja.contains(",")) param.addInNumberStmtParam(8,caja.substring(0,caja.indexOf(",")));//if multiple then select the first one
			else param.addInNumberStmtParam(8,caja);
		} else param.addInNumberStmtParam(8,0);

		if(request.getParameter("cajaTrx") !=null && !request.getParameter("cajaTrx").trim().equals("")){
		param.addInNumberStmtParam(9,request.getParameter("cajaTrx"));
		}else param.addInNumberStmtParam(9,-100);

		if(request.getParameter("turnoTrx") !=null && !request.getParameter("turnoTrx").trim().equals("")){
		param.addInNumberStmtParam(10,request.getParameter("turnoTrx"));  }
		else  param.addInNumberStmtParam(10,-100);

		param.addOutStringStmtParam(11);//facturas
		param.addOutStringStmtParam(12);//notas credito

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"companiaHosp="+companiaHosp+" fechaIni="+request.getParameter("fechaIni")+" fechaFin="+request.getParameter("fechafin")+" compFar="+compFar+" validaCja="+validaCja+" turno="+request.getParameter("turno")+" caja="+request.getParameter("caja")+" cajaTrx="+request.getParameter("cajaTrx")+" turnoTrx="+request.getParameter("turnoTrx"));
		param = SQLMgr.executeCallable(param);
	ConMgr.clearAppCtx(null);

		for (int i=0; i<param.getStmtParams().size(); i++) {
			CommonDataObject.StatementParam pp = param.getStmtParam(i);
			if (pp.getType().contains("o")) {
				if (pp.getIndex() == 11) if(pp.getData()!= null)refer_no1 = pp.getData().toString();
				if (pp.getIndex() == 12) if(pp.getData()!= null)refer_no2 = pp.getData().toString();
			}
		}
System.out.println("refer_no1 ==="+refer_no1 );//937584|201917830|2764181|99999-999-999999|UAT - HOSPITAL
System.out.println("refer_no2 ==="+refer_no2 );//937585|2764227|NA|99999-999-999999|UAT - HOSPITAL

		if (!refer_no1.equals("0")) {
			try{
				StringTokenizer st = new StringTokenizer(refer_no1,"|");
				docId = st.nextToken();
				docNo = st.nextToken();
				trxId=st.nextToken();
				ruc=st.nextToken();
				nombre=st.nextToken();
			}catch(Exception e){System.out.println("Error while processing the DGI ID ["+refer_no1+"]. Caused by: "+e.toString());e.printStackTrace();}
		} else if (!refer_no2.equals("0")) {
			try{
				StringTokenizer st = new StringTokenizer(refer_no2,"|");
				docId = st.nextToken();
				docNo = st.nextToken();
				trxId=st.nextToken();
				ruc=st.nextToken();
				nombre=st.nextToken();
			}catch(Exception e){System.out.println("Error while processing the DGI ID ["+refer_no2+"]. Caused by: "+e.toString());e.printStackTrace();}
		}
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
	//alert('refer_no1=<%=refer_no1%>');
	//alert('refer_no2=<%=refer_no2%>');
	<% if (!refer_no1.equals("0") || !refer_no2.equals("0")) { %>
	parent.printDgiFact(<%=docId%>,<%=docNo%>,'<%=trxId%>','<%=ruc%>');
	<% } else { %>
	parent.hidePopWin(false);
	<% } %>
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
