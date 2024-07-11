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
<jsp:useBean id="ItemMgr" scope="page" class="issi.inventory.ItemMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashFlia" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCtaFlia" scope="session" class="java.util.Vector" />
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
ItemMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String compId = request.getParameter("compId");
String unidadId = request.getParameter("unidadId");
String change = request.getParameter("change");
String activacion = request.getParameter("act");
String key = "";
String sql = "";
int lastLineNo = 0;
int rowCount = 0;


if (request.getParameter("change") == null) change = "0";
if (request.getParameter("act") == null) activacion = "0";

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
  
if (request.getMethod().equalsIgnoreCase("GET"))
{   
    if (compId == null) throw new Exception("La Compa&ntilde;ia no es válida. Por favor intente nuevamente!");
	if (unidadId == null) throw new Exception("La Unidad no es válida. Por favor intente nuevamente!");
		
	sql = "SELECT descripcion as unidad FROM tbl_sec_unidad_ejec WHERE codigo="+unidadId+" and compania="+compId;
	cdo = SQLMgr.getData(sql);
	
	if (change.equals("0"))	
	{  
	   HashFlia.clear();
	   vCtaFlia.clear();
 	   sql = "select a.familia as fliaCode, b.nombre as flia, a.cia, a.unid_adm, a.familia||'¦'||a.cia as keyFlia,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6,(select descripcion from tbl_con_catalogo_gral where cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6 and compania=a.cia ) cuenta,'U' action from tbl_inv_unidad_costos a, tbl_inv_familia_articulo b where a.familia=b.cod_flia(+) and a.cia=b.compania(+) and a.cia="+compId+" and a.unid_adm="+unidadId;

	   al = SQLMgr.getDataList(sql);
	   
	   for (int i = 0; i < al.size(); i++)
	   {
		  CommonDataObject cdo2 = (CommonDataObject) al.get(i);
		  cdo2.setKey(i);
		  cdo2.setAction("U");
		  
		  HashFlia.put(cdo2.getKey(),cdo2);
		  vCtaFlia.add(cdo2.getColValue("fliaCode"));
	   }	   
	}	

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Clasificación Gasto x Unid. Adm. y Flia. de Artículo - '+document.title;
function addFamilia(){abrir_ventana1('../common/check_familia.jsp?fp=gastoUnd&compId=<%=compId%>&id=<%=unidadId%>');}
function addCuenta(id){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=gastoUnidad&index='+id);}
function doAction(){<%if(activacion.trim().equals("2")){%>addFamilia()<%}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>		
			<%=fb.hidden("compId",compId)%>
			<%=fb.hidden("unidadId",unidadId)%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("keySize",""+HashFlia.size())%>
			<%=fb.hidden("baction","")%>

				<tr class="TextRow02">
				    <td colspan="3"><%=unidadId%> - <%=cdo.getColValue("unidad")%></td>
					<td align="right" colspan="2"><%=fb.submit("btnagregar","Agregar Familia",false,false)%></td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="5%">Id Flia.</td>
					<td width="30%">Nombre</td>	
                    <td width="55%">Cuenta</td>				
					<td width="5%">&nbsp;</td>
				</tr>			
				<%			  
				  if (HashFlia.size() > 0) 
				  {  
				    al = CmnMgr.reverseRecords(HashFlia);				
				    for (int i = 0; i <HashFlia.size(); i++)
				    {
					  key = al.get(i).toString();									  
				   	  CommonDataObject cdo2 = (CommonDataObject) HashFlia.get(key);
					  String style = (cdo2.getAction().trim().equals("D"))?" style=\"display:'none'\"":"";
				%>					  
					  <%=fb.hidden("fliaCode"+i,cdo2.getColValue("fliaCode"))%>	
					  <%=fb.hidden("flia"+i,cdo2.getColValue("flia"))%>					  
					  <%=fb.hidden("remove"+i,"")%>
					  <%=fb.hidden("action"+i,cdo2.getAction())%>
					  <%=fb.hidden("key"+i,cdo2.getKey())%>                    
				<%if((!cdo2.getAction().trim().equals("D"))){%>					
                 <tr class="TextRow01"<%=style%>>
					 <td align="right"><%=i%>&nbsp;</td>
					 <td><%=cdo2.getColValue("fliaCode")%></td>
				     <td><%=cdo2.getColValue("flia")%></td>
                     <td><%=fb.textBox("cta1"+i,cdo2.getColValue("cta1"),true,false,true,3)%>
					 <%=fb.textBox("cta2"+i,cdo2.getColValue("cta2"),true,false,true,3)%>
					 <%=fb.textBox("cta3"+i,cdo2.getColValue("cta3"),true,false,true,3)%>
					 <%=fb.textBox("cta4"+i,cdo2.getColValue("cta4"),true,false,true,3)%>
					 <%=fb.textBox("cta5"+i,cdo2.getColValue("cta5"),true,false,true,3)%>
					 <%=fb.textBox("cta6"+i,cdo2.getColValue("cta6"),true,false,true,3)%>
                     <%=fb.textBox("cuenta"+i,cdo2.getColValue("cuenta"),true,false,true,30)%>                     
					 <%=fb.button("btncuenta"+i,"...",true,false,null,null,"onClick=\"javascript:addCuenta("+i+")\"","Agregar Cuenta")%> </td>				    			 
					 <td align="right"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>		
				 </tr>															
				<%}	
				    }				  
				  }	
				%>  	
            			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
	<tr class="TextRow02">
	    <td align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		                  <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
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
   String baction = request.getParameter("baction");
   int size = Integer.parseInt(request.getParameter("keySize"));	  
   String itemRemoved="";

   compId = request.getParameter("compId");
   unidadId = request.getParameter("unidadId");
   HashFlia.clear();
   vCtaFlia.clear();
   list.clear();
				
   for (int i=0; i<size; i++)
   {   	
	  CommonDataObject cdo3 = new CommonDataObject();
					 
	  cdo3.setTableName("tbl_inv_unidad_costos");
	  cdo3.setWhereClause("cia="+compId+" and unid_adm="+unidadId+" and familia="+request.getParameter("fliaCode"+i));	 
	  
	   
	  cdo3.addColValue("cia",compId);
	  cdo3.addColValue("unid_adm",unidadId);
	  cdo3.addColValue("familia",request.getParameter("fliaCode"+i));
	  cdo3.addColValue("fliaCode",request.getParameter("fliaCode"+i));
	  cdo3.addColValue("flia",request.getParameter("flia"+i));	  
	  cdo3.addColValue("cta1",request.getParameter("cta1"+i));	 
	  cdo3.addColValue("cta2",request.getParameter("cta2"+i));
	  cdo3.addColValue("cta3",request.getParameter("cta3"+i));	 	 
	  cdo3.addColValue("cta4",request.getParameter("cta4"+i));	 	 
	  cdo3.addColValue("cta5",request.getParameter("cta5"+i));	 	 
	  cdo3.addColValue("cta6",request.getParameter("cta6"+i));
	  cdo3.addColValue("cuenta",request.getParameter("cuenta"+i));
	  cdo3.setKey(i);
  	  cdo3.setAction(request.getParameter("action"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo3.getColValue("familia");
			if (cdo3.getAction().equalsIgnoreCase("I")) cdo3.setAction("X");//if it is not in DB then remove it
			else cdo3.setAction("D");
		}
	System.out.println(" ACCION   ====== "+cdo3.getAction());
		if (!cdo3.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				HashFlia.put(cdo3.getKey(),cdo3);
				vCtaFlia.add(cdo3.getColValue("familia"));
				list.add(cdo3);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}	 	
   }
   if(!itemRemoved.equals(""))
	{
	//iDesc.remove(itemRemoved);
	 response.sendRedirect("../inventario/clasificacion_gasto_config.jsp?unidadId="+unidadId+"&compId="+compId+"&change=1&act=0");
	return;
	}
	if(request.getParameter("btnagregar")!=null)
	{
	 response.sendRedirect("../inventario/clasificacion_gasto_config.jsp?unidadId="+unidadId+"&compId="+compId+"&change=1&act=2");
	 return;
	}
	if(list.size()==0){
	CommonDataObject cdo1 = new CommonDataObject();
	cdo1.setTableName("tbl_inv_unidad_costos");
	cdo1.setWhereClause("cia="+(String) session.getAttribute("_companyId")+" and unid_adm="+unidadId);
	cdo1.setKey(HashFlia.size() + 1);
	cdo1.setAction("I");
	list.add(cdo1);
	}
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	 SQLMgr.saveList(list,true);
	ConMgr.clearAppCtx(null);
   				 
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/clasificacion_gasto_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/clasificacion_gasto_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/clasificacion_gasto_list.jsp';
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
