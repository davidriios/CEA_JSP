<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
String key = "";
String sql = "";
String change = request.getParameter("change");
int lastLineNo = 0;

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	    HashDet.clear();
		sql = "";
		cdo = SQLMgr.getData(sql);

		if (change == null)
		{
			sql = "";
            al = SQLMgr.getDataList(sql);

            HashDet.clear(); 
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, al.get(i-1));			
		    }  	 			
		}
%>
<html>   
<head>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title="Depósitos por Caja - "+document.title;

function saveMethod()
{
  if (formDepositoValidation())
  {  
     window.frames['itemFrame'].formRecibo.baction.value = "Guardar";
     window.frames['itemFrame'].doSubmit();
  }  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - CONSULTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("formRecibo",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Dep&oacute;sitos por Caja</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="8%"><cellbytelabel>Caja</cellbytelabel></td>
							    <td width="38%"><%=fb.intBox("codCaja","",false,false,true,5,2)%><%=fb.textBox("cajaDesc","",false,false,true,40,40)%><%=fb.button("btnCaja","...",false,false,null,null,"onClick=\"javascript:addCaja()\"")%></td>	
								<td width="15%"><cellbytelabel>Descripci&oacute;n del Dep&oacute;sito</cellbytelabel></td>
								<td width="39%"><%=fb.textarea("descripcion","",false,false,false,40,3)%></td>																													
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel>Detalle de D&eacute;positos por Caja</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../caja/depositos_x_caja_detail.jsp"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
else
{
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.location = '<%=request.getContextPath()%>/caja/depositos_x_caja.jsp'
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>