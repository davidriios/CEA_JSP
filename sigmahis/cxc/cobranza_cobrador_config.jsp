<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
int Tab = 0;
if(request.getParameter("Tab")!=null) 
Tab = Integer.parseInt(request.getParameter("Tab"));

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	
	}
	else
	{
	sql="";
	cdo = SQLMgr.getData(sql);
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Tipos de Cobranza por Cobrador - Edición - "+document.title;
</script>
<script type="text/javascript">
function verocultar(c)
 { 
	if(c.style.display == 'none')
	{       c.style.display = 'inline';    
	}
	else
	{       c.style.display = 'none';   
	}   
 return false; 
 }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">
function bcolor(bcol,d_name)
{
	if (document.all)
	{ var thestyle= eval ('document.all.'+d_name+'.style'); 
		thestyle.backgroundColor=bcol; 
	}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR  - TIPOS DE COBRANZA POR COBRADOR"></jsp:param>
</jsp:include>
<table align="center" width="98%" cellpadding="0" cellspacing="0" style='border-right:1.5pt solid #e6e4e4; border-left:1.5pt solid #e6e4e4; border-bottom:1.5pt solid #FFFFFF; border-top:1.5pt solid #FFFFFF;'>
<tr>
	<td width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>
<!--*************************************************************************************************************-->
<!--STYLE UP-->
<div id="dhtmlgoodies_tabView1">
<!--GENERALES DEL ANALISTA/COBRADORES TAB0-->
<div class="dhtmlgoodies_aTab">
<%fb = new FormBean("generales",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("Tab","0")%>
<table id="tbl_generales" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
			<tr>
				<td id="TSociedad" align="left" width="100%" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TSociedad');" onMouseout="bcolor('#8f9ba9','TSociedad');">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr class="TextHeader">
							<td width="98%" >&nbsp;<cellbytelabel>Analistas/Cobradores</cellbytelabel></td>
							<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;"></font>&nbsp;</td>
						</tr>
					</table>		
				</td>
			</tr>	
			<tr>
				<td>	
				<div id="panel0" style="visibility:visible;">
				<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">									
					<tr class="TextRow01">
						<td>&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
						<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,10)%></td>			
					</tr>							
					<tr class="TextRow01">
						<td width="17%">&nbsp;<cellbytelabel>Tipo</cellbytelabel></td>
						<td width="83%"><%=fb.select("tipo","E=EMPLEADO,M=EMPRESA",cdo.getColValue("TIPO"))%></td>
					</tr>
					<tr class="TextRow01">
						<td>&nbsp;<cellbytelabel>Encargado</cellbytelabel></td>
						<td><%=fb.intBox("code",cdo.getColValue("code"),false,false,false,10)%>
							<%=fb.textBox("encargado",cdo.getColValue("encargado"),false,false,false,30)%></td>
						</td>
					</tr>						
				</table>
				</div>
				</td>
			</tr>
		</table>			
	</td>
</tr>		
<tr class="TextRow02">
	<td align="right">
	<%=fb.submit("save","Guardar",true,false)%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
	</td>
</tr>			
</table>
<%=fb.formEnd(true)%>
<%@ include file="../common/footer.jsp"%>
</div>

<!--CURSOS TIPOS DE COBROS POR COBRADOR TAB1-->
<div class="dhtmlgoodies_aTab">
<%fb = new FormBean("tipos",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("Tab","1")%>
<table id="tbl_curso" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
<tr>
	<td> 
		<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
			<tr>
				<td id="TTipod" align="left" width="100%" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TTipod');" onMouseout="bcolor('#8f9ba9','TTipod');">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr class="TextHeader">
							<td width="98%">&nbsp;<cellbytelabel>Tipos de Cobros por Cobrador</cellbytelabel></td>
							<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;"></font>&nbsp;</td>
						</tr>
					</table>		
				</td>
			</tr>	
			<tr>
				<td> 	
					<div id="panel4" style="display:inline;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
						<tr class="TextRow01">
							<td width="18%">&nbsp;<cellbytelabel>Tipos Analista</cellbytelabel></td>
							<td width="32%"><%=fb.intBox("code",cdo.getColValue("code"),false,false,false,5)%>
											<%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,false,23)%>
											<%=fb.button("btnanalista","IR",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
							</td>
							<td width="18%">&nbsp;<cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td width="32%"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,30,2)%></td>
						</tr>															
					 </table>
					 </div>
				</td> 
			</tr> 
		</table>
	</td> 
</tr> 	
<tr class="TextRow02">
	<td align="right">
	<%=fb.submit("save","Guardar",true,false)%>
	<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
	</td>
</tr>		
</table>
<%=fb.formEnd(true)%>
<%@ include file="../common/footer.jsp"%>		
</div>

</div>
<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Analistas/Cobradores','Tipos de Cobros por Cobrador'),0,'100%','');
</script>

	
<!--STYLE DW-->
<!--*************************************************************************************************************-->
	</td>
</tr>		
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
  cdo = new CommonDataObject();
  
if(Tab==0)
{
} 
 if(Tab==1)
{	

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
	alert('<%//=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/cobranza_cobrador_config.jsp&mode=edit"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/cobranza_cobrador_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/cxc/cobranza_cobrador_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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