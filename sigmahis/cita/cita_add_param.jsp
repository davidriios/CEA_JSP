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
SQLMgr.setConnection(ConMgr);

String sql = "";

String act = "0"; //act=0 COMPANIA ASEGURADORA, act=1 MEDICO, act=2 PROCEDIMIENTO
if (request.getParameter("act")!= null) act = request.getParameter("act");

String chab = "0"; //codigo del servicio.
if (request.getParameter("chab")!= null) chab = request.getParameter("chab");

if(act.equals("0")) sql="SELECT a.CODIGO, a.NOMBRE FROM TBL_ADM_EMPRESA a WHERE a.ESTADO = 'A'";
if(act.equals("1")) sql="SELECT a.CODIGO,(a.PRIMER_APELLIDO||' '||a.SEGUNDO_APELLIDO||' '||a.APELLIDO_DE_CASADA||' '||a.PRIMER_NOMBRE||' '||a.SEGUNDO_NOMBRE) as NOMBRE, a.IDENTIFICACION, a.NACIONALIDAD, a.SEXO FROM TBL_ADM_MEDICO a WHERE a.ESTADO='A' order by a.primer_nombre";
if(act.equals("2")) sql="SELECT a.CODIGO, NVL(a.observacion, a.DESCRIPCION) AS NOMBRE, nvl(a.tiempo_estimado,0) as HORAS, nvl(a.unidad_tiempo,0) as MINUTOS FROM TBL_CDS_PROCEDIMIENTO a WHERE (a.COD_CDS = DECODE('"+chab+"','I1',885,'I2',885,'I3',17,'I9',17,'I4',18,'I5',26,'I6',16,'I7',67) OR a.COD_CDS2 = DECODE('"+chab+"','I1',885,'I2',885,'I3',17,'I9',17,'I4',18,'I5',26,'I6',16,'I7',67)) ORDER BY NVL(a.observacion,a.DESCRIPCION)";

ArrayList al = new ArrayList();
al = SQLMgr.getDataList(sql);   

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function setIdValue(id,name){
<%if(act.equals("0")){%>
	window.opener.document.frmPatient.ciaseguro.value=id;
	window.opener.document.frmPatient.dciaseguro.value=name;
<%}if(act.equals("1")){%>
	window.opener.document.frmPatient.medico.value=id;
	window.opener.document.frmPatient.dmedico.value=name;
<%}if(act.equals("2")){%>
	window.opener.document.frmPatient.procedure.value=id;
	window.opener.document.frmPatient.dprocedure.value=name;
<%}%>
window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
	<%fb = new FormBean("frmResult",request.getContextPath()+request.getServletPath());%>
	<%=fb.formStart()%>		
    <tr>
        <td width="8%" style="background-color:#CCCCCC; border-top:1.5pt solid #999999; border-bottom:1.5pt solid #999999; border-right:none;border-left:none;">&nbsp;</td>
        <td width="12%" style="background-color:#CCCCCC; border-top:1.5pt solid #999999; border-bottom:1.5pt solid #999999; border-right:1.5pt solid #CCCCCC;border-left:1.5pt solid #FFFFFF;">&nbsp;<cellbytelabel>CODIGO</cellbytelabel></td>
        <td width="80%" style="background-color:#CCCCCC; border-top:1.5pt solid #999999; border-bottom:1.5pt solid #999999; border-right:1.5pt solid #CCCCCC;border-left:1.5pt solid #FFFFFF;">&nbsp;<cellbytelabel>NOMBRE</cellbytelabel></td>
    </tr>
    <%//=fb.hidden("servicio",servicio)%>
	<%//=fb.formEnd()%>

    <%
    for (int i=0; i<al.size(); i++)
    {
        CommonDataObject cdo = (CommonDataObject) al.get(i);
        String color = "TextRow02";
        if (i % 2 == 0) color = "TextRow01";
    %>
    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
        <td >&nbsp;<%=i+1%></td>   
        <td >&nbsp;<a href="javascript:setIdValue('<%=cdo.getColValue("CODIGO")%>','<%=cdo.getColValue("NOMBRE")%>');"><%=cdo.getColValue("CODIGO")%></a></td>
        <td >&nbsp;<a href="javascript:setIdValue('<%=cdo.getColValue("CODIGO")%>','<%=cdo.getColValue("NOMBRE")%>');"><%=cdo.getColValue("NOMBRE")%></a></td>
    </tr>
    <%
    }
    %>
    <tr>
    	<td colspan="3" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>&nbsp;</td>
    </tr>            
	<%=fb.formEnd()%>

</table>
</body>
</html>
<%
}
%>