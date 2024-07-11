<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iObservaciones" scope="session" class="java.util.Hashtable" />
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

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
 
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision"); 
String dob = request.getParameter("dob"); 
String codPac = request.getParameter("codPac"); 
String fp = request.getParameter("fp"); 
if(fp==null) fp="";
String key = "";
int obserLastLineNo = 0;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getParameter("obserLastLineNo") != null) obserLastLineNo = Integer.parseInt(request.getParameter("obserLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{ 
	//System.out.println(" dentro del get   =        "+request.getParameter("pacId"));

		iObservaciones.clear();
		sql = "select 'V' status, paciente, admision, secuencia, observacion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion , usuario_modificacion, to_char(fecha_modificacion ,'dd/mm/yyyy hh12:mi:ss am')fecha_modificacion , estado,pac_id from tbl_adm_admision_nota_admin  where pac_id= "+pacId+"and admision = "+noAdmision;
		
		al = SQLMgr.getDataList(sql);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Observaciones Administrativas - '+document.title;

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<table align="center" width="99%" cellpadding="5" cellspacing="0">  
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
    <tr class="TextHeader" align="center">
      <td width="95%"><cellbytelabel id="1">OBSERVACIONES ADMINISTRATIVAS</cellbytelabel></td>
      <td width="5%"></td>
    </tr>
<%
for (int i=0; i<al.size(); i++)
{
	 cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
%>
    <tr class="<%=color%>" align="center">
      <td align="left"><%=(i+1)%>-<%=cdo.getColValue("observacion")%></td>
    </tr>
<%
}
%>
<%=fb.formEnd(true)%>
    </table>
  </td>
</tr>
</table>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
}
%>