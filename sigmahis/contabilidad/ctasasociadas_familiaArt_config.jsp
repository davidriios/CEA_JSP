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
<jsp:useBean id="HashCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="VKey" scope="session" class="java.util.Vector" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String compId = request.getParameter("compId");
String fliaId = request.getParameter("fliaId");
String change = request.getParameter("change");
String key = "";
String sql = "";
int lastLineNo = 0;
int rowCount = 0;

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getParameter("change") == null) change = "0";

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{   
	sql = "SELECT nombre as flia FROM tbl_inv_familia_articulo WHERE cod_flia="+fliaId+" and compania="+compId;
	cdo = SQLMgr.getData(sql);
	
	if (change.equals("0"))	
	{   
	   if (compId == null) throw new Exception("La Compa&ntilde;ia no es válida. Por favor intente nuevamente!");
	   if (fliaId == null) throw new Exception("La Familia no es válida. Por favor intente nuevamente!");
	   HashCta.clear();
	   VKey.clear();
 	   sql = "SELECT a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.compania_cg, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cuentaCode, b.descripcion as cuenta, a.cta1||'¦'||a.cta2||'¦'||a.cta3||'¦'||a.cta4||'¦'||a.cta5||'¦'||a.cta6||'¦'||a.compania_cg as keyCta FROM tbl_inv_cta_x_compania a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania_cg=b.compania and a.compania_fa="+compId+" and a.cod_familia="+fliaId;	
	   al = SQLMgr.getDataList(sql);
	   
	   for (int i = 1; i <= al.size(); i++)
	   {
		  if (i < 10) key = "00" + i;
		  else if (i < 100) key = "0" + i;
		  else key = "" + i;
	
		  HashCta.put(key, al.get(i-1));
		  lastLineNo++;
	   }	   
	}	

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cuentas de Intercompañias Asociadas a Familia - '+document.title;

function addCuenta()
{
   abrir_ventana1('ctasasociadas_familiaArt2_config.jsp?compId=<%=compId%>&fliaId=<%=fliaId%>&lastLineNo=<%=lastLineNo%>')
} 
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - CTAS. INTERCOMPAÑIA ASOC. X FAMILIA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>		
			<%=fb.hidden("compId",compId)%>
			<%=fb.hidden("fliaId",fliaId)%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("keySize",""+HashCta.size())%>			
			    
				<tr class="TextRow02">
				    <td colspan="3"><%=fliaId%> - <%=cdo.getColValue("flia")%></td>
					<td align="right">
					<%
						//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"00000"))
						//{
					%>
					     <%=fb.button("btncuenta","+",true,false,null,null,"onClick=\"javascript:addCuenta()\"")%>
					<%
					    //}
					%>
					</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="30%">Cuenta</td>
					<td width="55%">Descripci&oacute;n</td>							
					<td width="10%">&nbsp;</td>
				</tr>			
				<%			  
				  if (HashCta.size() > 0) 
				  {  
				    al = CmnMgr.reverseRecords(HashCta);				
				    for (int i = 1; i <= HashCta.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  CommonDataObject cdo2 = (CommonDataObject) HashCta.get(key);
				%>
					  <%=fb.hidden("cta1"+i,cdo2.getColValue("cta1"))%>
					  <%=fb.hidden("cta2"+i,cdo2.getColValue("cta2"))%>
					  <%=fb.hidden("cta3"+i,cdo2.getColValue("cta3"))%>
					  <%=fb.hidden("cta4"+i,cdo2.getColValue("cta4"))%>
					  <%=fb.hidden("cta5"+i,cdo2.getColValue("cta5"))%>
					  <%=fb.hidden("cta6"+i,cdo2.getColValue("cta6"))%>
					  <%=fb.hidden("compCtaId"+i,cdo2.getColValue("compania_cg"))%>
					  <%=fb.hidden("keyCta"+i,cdo2.getColValue("keyCta"))%>
					  <%=fb.hidden("key"+i,al.get(i - 1).toString())%>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%>
					 <td align="right"><%=i%>&nbsp;</td>
				     <td><%=cdo2.getColValue("cuentaCode")%></td>
				     <td><%=cdo2.getColValue("cuenta")%></td>					 
					 <td align="right"><%=fb.submit("remove"+i,"X",false,false)%></td>		
				 </tr>															
				<%	
				    }				  
				  }	
				%>  	
            			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				<tr class="TextRow02">
					<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%>
									  <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>	
	        <%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{     
   lastLineNo = Integer.parseInt(request.getParameter("lastLineNo")); 
   int size = Integer.parseInt(request.getParameter("keySize"));	  
   compId = request.getParameter("compId");
   fliaId = request.getParameter("fliaId");
   		
   for (int i=1; i<=size; i++)
   {	
	  CommonDataObject cdo3 = new CommonDataObject();
					 
	  cdo3.setTableName("tbl_inv_cta_x_compania");
	  cdo3.setWhereClause("compania_fa="+compId+" and cod_familia="+fliaId);	 
	 
	  cdo3.addColValue("compania_fa",compId);
	  cdo3.addColValue("cod_familia",fliaId);
	  cdo3.addColValue("compania_cg",request.getParameter("compCtaId"+i));
	  cdo3.addColValue("cta1",request.getParameter("cta1"+i));
	  cdo3.addColValue("cta2",request.getParameter("cta2"+i));
	  cdo3.addColValue("cta3",request.getParameter("cta3"+i));
	  cdo3.addColValue("cta4",request.getParameter("cta4"+i));
	  cdo3.addColValue("cta5",request.getParameter("cta5"+i));
	  cdo3.addColValue("cta6",request.getParameter("cta6"+i));	
	  al.add(cdo3);
			 
	  if (request.getParameter("remove"+i)!= null)
	  { 
		 key = request.getParameter("key"+i);
		 HashCta.remove(key);
		 response.sendRedirect("../contabilidad/ctasasociadas_familiaArt_config.jsp?compId="+compId+"&fliaId="+fliaId+"&lastLineNo="+lastLineNo+"&change=1");
		 return;
	  } 					 	
   }
   SQLMgr.insertList(al);				 
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/ctasasociadas_familiaArt_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/ctasasociadas_familiaArt_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/ctasasociadas_familiaArt_list.jsp';
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