<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr"	scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr"	scope="session" class="issi.admin.SecurityMgr"	/>
<jsp:useBean id="UserDet"	scope="session" class="issi.admin.UserDetail"	/>
<jsp:useBean id="CmnMgr"	scope="page"	class="issi.admin.CommonMgr"	/>
<jsp:useBean id="SQLMgr"	scope="page"	class="issi.admin.SQLMgr"		/>
<jsp:useBean id="fb"		scope="page"	class="issi.admin.FormBean"		/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy"); 
if (request.getParameter("currDate")!= null) currDate = request.getParameter("currDate");

String act = "0"; //act=0 add, act=1 edit, act=2 transfer, act=3 cancelation
if (request.getParameter("act")!= null) act = request.getParameter("act");

String from = "img"; //from=img simple.view, from=qui view.for.operating.room 
if (request.getParameter("from")!= null) from = request.getParameter("from");

String Title = "";
if(act.equals("0")) Title="CITAS - NUEVA CITA";
if(act.equals("1")) Title="CITAS - EDITAR CITA";
if(act.equals("2")) Title="CITAS - TRASLADAR CITA";

String display = "inline";
if(from.equals("qui")) display="none";

String tab = "0";
if (request.getParameter("tab")!= null) tab = request.getParameter("tab");


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"		%>
<%@ include file="../common/header_param.jsp"	%>
<%@ include file="../common/calendar_base.jsp" 	%>
<%@ include file="../common/tab.jsp"			%>
<script language="javascript"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">   
	<tr>
		<td width="2%">&nbsp;</td>  
		<td width="96%">   
			<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td>
<!--=========CONTENT BEGIN HERE========================================================================================-->

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
<%fb = new FormBean("frmProcedure",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>		
	<tr>
		<td colspan="4" class="BlueContent">&nbsp;</td>
	</tr>	
	<tr>
		<td class="BlueContent">&nbsp;<cellbytelabel>Quir&oacute;fano</cellbytelabel></td>
		<td class="BlueContent"><%=fb.select("quirofano","QUIROFANO #1,QUIROFANO #2","",false,false,0,"","width:250px;",null)%></td>
		<td class="BlueContent">&nbsp;</td>
		<td class="BlueContent">&nbsp;</td>
	</tr>	
	<tr>
		<td class="BlueContent">&nbsp;<cellbytelabel>Anestesia</cellbytelabel>?</td>
		<td class="BlueContent"><%=fb.select("anestesia","SI,NO","",false,false,0,"","width:250px;",null)%></td>
		<td class="BlueContent">&nbsp;<cellbytelabel>Anestesi&oacute;logo</cellbytelabel></td>
		<td class="BlueContent"><%=fb.hidden("anestesiologo", "")%><%=fb.textBox("danestesiologo", "", false, true, false, 40)%>&nbsp;<%=fb.button("btnanestesiologo", "...", false, false, "", "", "")%></td>
	</tr>
	<tr>
		<td class="BlueContent">&nbsp;<cellbytelabel>Segunda Opinión &nbsp;Aprobada</cellbytelabel>?</td>
		<td class="BlueContent"><%=fb.select("opinion","SI,NO","",false,false,0,"","width:250px;",null)%></td>
		<td class="BlueContent">&nbsp;<cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
		<td class="BlueContent"><%=fb.hidden("clasificacion", "")%><%=fb.textBox("dclasificacion", "", false, true, false, 40)%>&nbsp;<%=fb.button("btnclasificacion", "...", false, false, "", "", "")%></td>
	</tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="4">
		<fieldset>
		<legend><cellbytelabel>Procedimientos a Realizar</cellbytelabel></legend>
			<iframe name="iquirofanodet" id="iquirofanodet" frameborder="0" align="center" width="100%" height="100" scrolling="no" src="cita_add_operation_detail.jsp"></iframe>		
		</fieldset>
		</td>
	</tr>
	
	<%if(act.equals("2")){%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>	
	<tr>
		<td colspan="4">
		<fieldset>
		<legend><cellbytelabel>Informaci&oacute;n del Traslado</cellbytelabel></legend>
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
		<tr>
			<td class="BlueContent">&nbsp;<cellbytelabel>Quir&oacute;fano</cellbytelabel></td>
			<td class="BlueContent"><%=fb.select("tquirofano","QUIROFANO #1,QUIROFANO #2","",false,false,0,"","width:235px;",null)%></td>
		</tr>	
		<tr>
			<td width="20%" class="BlueContent">&nbsp;<cellbytelabel>Fecha</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="nameOfTBox1" value="fecha" />
			<jsp:param name="valueOfTBox1" value="<%=currDate%>"/></jsp:include></td>
			<td width="80%" class="BlueContent">&nbsp;<cellbytelabel>Hora de la Cita</cellbytelabel>&nbsp;<%=fb.select("tqhora","01,02,03,04,05,06,07,08,09,10,11,12","",false,false,0,"","width:40px;",null)%>:<%=fb.select("tqminuto","00,30","",false,false,0,"","width:40px;",null)%>&nbsp;<%=fb.select("tqampm","A.M.,P.M.","",false,false,0,"","width:50px;",null)%></td>
		</tr>	
		<tr>
			<td class="BlueContent" >&nbsp;<cellbytelabel>Motivo del Traslado</cellbytelabel>&nbsp;</td>
			<td class="BlueContent" ><%=fb.textarea("motivotraslada", "", true, false, false, 85, 2)%></td>
		</tr>	
		</table>	
		</fieldset>
		</td>
	</tr>
	<%}%>	
	
	<%if(act.equals("3")){%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>	
	<tr>
		<td colspan="4">
		<fieldset>
		<legend><cellbytelabel>Informaci&oacute;n de la Cancelaci&oacute;n</cellbytelabel></legend>
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
		<tr>
			<td width="20%" class="BlueContent" >&nbsp;<cellbytelabel>Motivo de Cancelaci&oacute;n</cellbytelabel>&nbsp;</td>
			<td width="80%" class="BlueContent" ><%=fb.textarea("motivocancela", "", true, false, false, 85, 2)%></td>
		</tr>	
		</table>	
		</fieldset>
		</td>
	</tr>	
	<%}%>	
		
	<tr>
		<td width="15%" class="BlueContent">&nbsp;</td>
		<td width="35%" class="BlueContent">&nbsp;</td>
		<td width="15%" class="BlueContent">&nbsp;</td>
		<td width="35%" class="BlueContent">&nbsp;</td>
	</tr>
	<tr>
		<td class="BlueContent" colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%>&nbsp;<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>	
<%=fb.formEnd()%>	
</table>
</div>
<!-- TAB0 DIV END HERE-->

<!-- TAB1 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">

</div>
<!-- TAB1 DIV END HERE-->

</div>
<!-- MAIN DIV END HERE -->
<%String tabLabel = "'QUIROFANOS','ADICIONAL'";%>
<script type="text/javascript">initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');</script>

<!--=========CONTENT END HERE==========================================================================================-->
					</td>
				</tr>
			</table>
		</td>
		<td width="2%">&nbsp;</td>  
	</tr>
</table>					

</body>
</html>
<%
}
%>