
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashFlia" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="VKey" scope="session" class="java.util.Vector" />
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

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
int rowCount = 0;
String sql = "";
String almaId = null;
String appendFilter = "";

int lastLineNo = 0;
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

if(request.getMethod().equalsIgnoreCase("GET")) {
    String nextVal="100", previousVal="1", searchQuery, searchOn="SO", searchVal="Todos", searchType="ST", searchDisp="SD", searchValDisp="Todos";
    if (request.getParameter("searchQuery")!=null) {
        nextVal=request.getParameter("nextVal");
        previousVal=request.getParameter("previousVal");
        if(request.getParameter("searchOn")!="SO") searchOn=request.getParameter("searchOn");
        if(request.getParameter("searchVal")!="Todos") searchVal=request.getParameter("searchVal");
        if(request.getParameter("searchType")!="ST") searchType=request.getParameter("searchType");
        if(request.getParameter("searchDisp")!="SD") searchDisp=request.getParameter("searchDisp");
    }
    try{        
		if(request.getParameter("almaId")!=null) almaId=request.getParameter("almaId");
        else throw new Exception("El Almacen no es inválido. Por favor intente nuevamente!");
    } catch (Exception e){
        System.err.println(e.getMessage());
    }
	
	if (request.getParameter("codigo") != null)
    {
      appendFilter += " and upper(cod_flia) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
      searchOn = "cod_flia";
      searchVal = request.getParameter("codigo");
      searchType = "1";
      searchDisp = "Codigo";
    }else if (request.getParameter("descripcion") != null)
	      {
			appendFilter += " and upper(nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
			searchOn = "nombre";
			searchVal = request.getParameter("descripcion");
			searchType = "1";
			searchDisp = "Nombre";
          }else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
				            {
							   if (searchType.equals("1"))
							   {
								  appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
							   }
							}else{
								   searchOn="SO";
								   searchVal="Todos";
								   searchType="ST";
								   searchDisp="Listado";
								 }
  
	sql = "SELECT cod_flia as fliaCode, nombre as flia, compania, cod_flia||'¦'||compania as keyFlia FROM tbl_inv_familia_articulo WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by nombre";	
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_inv_familia_articulo WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter);

	if(searchDisp!=null) searchDisp=searchDisp;
    else searchDisp = "Listado";
    
	if(!searchVal.equals("")) searchValDisp=searchVal;
    else searchValDisp="Todos";
    
    int nVal, pVal;
    int preVal=Integer.parseInt(previousVal);
    int nxtVal=Integer.parseInt(nextVal);
    
	if (nxtVal<=rowCount) nVal=nxtVal;
    else nVal=rowCount;
	
    if(rowCount==0) pVal=0;
    else pVal=preVal;
	
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Cuentas Intercompañías por Familia de Almacen - Edición - "+document.title;
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - CUENTAS DE INTERCOMPANÍAS"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="1" cellspacing="0">
 	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="0" cellspacing="0">
			    <tr class="TextFilter">		
                    <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("almaId",almaId)%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
					
				    <td width="50%">C&oacute;digo					
					<%=fb.textBox("codigo","",false,false,false,40)%>					
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
					
					<%
					  fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("almaId",almaId)%>
					<%=fb.hidden("lastLineNo",""+lastLineNo)%>
				    <td width="50%">Descripci&oacute;n
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>			
			    </tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr> 
</table>

<table width="100%"  border="0" cellspacing="0" cellpadding="0">
<% fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%> 
<%=fb.formStart(true)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("almaId",almaId)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
	<tr>
		<td>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0">
				<tr class="TextRow02">
					<td align="right"><%=fb.submit("add","Agregar",true,false)%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%"  border="0" cellspacing="0" cellpadding="0">
				<tr class="TextPager">
					<td width="32%" class="TitulosdeTablas">Total de Registro(s) encontrado: <%=rowCount%></td>
					<td width="32%" class="TitulosdeTablas">Registro(s) listado desde <%=pVal%> hasta <%=nVal%></td>
					<td width="36%" class="TitulosdeTablas">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%"  border="0" cellspacing="0" cellpadding="0">
				<tr class="TextPager">
					<td width="9%">
					<%
					   if(preVal!=1)
					   {
					%>
						 <%=fb.hidden("nextVal1",""+(nxtVal-100))%>
						 <%=fb.hidden("previousVal1",""+(preVal-100))%>
						 <%=fb.hidden("searchOn1",searchOn)%>
						 <%=fb.hidden("searchVal1",searchVal)%>
						 <%=fb.hidden("searchType1",searchType)%>
						 <%=fb.hidden("searchDisp1",searchDisp)%>					   
						 <%=fb.hidden("searchQuery1","sQ")%>
						 <%=fb.submit("previous1","Anterior")%>										
					<%
					   }
					%>
					</td>
					<td width="82%">&nbsp;</td>
					<td width="9%" align="right">
					<%
					   if(!(rowCount<=nxtVal))
					   {
					%>
						 <%=fb.hidden("nextVal2",""+(nxtVal+100))%>
						 <%=fb.hidden("previousVal2",""+(preVal+100))%>
						 <%=fb.hidden("searchOn2",searchOn)%>
						 <%=fb.hidden("searchVal2",searchVal)%>
						 <%=fb.hidden("searchType2",searchType)%>
						 <%=fb.hidden("searchDisp2",searchDisp)%>			   
						 <%=fb.hidden("searchQuery2","sQ")%>
						 <%=fb.submit("next2","Siguiente")%>                    
					<%
					   }
					%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" border="0">
			    <tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="30%">C&oacute;digo</td>					
					<td width="58%">Descripci&oacute;n</td>					
					<td width="7%">&nbsp;</td>
				</tr>	                          
				<%  				 
				   for(int i=0; i<al.size();i++)
				   {
					  CommonDataObject cdo = (CommonDataObject) al.get(i);
					  String color = "TextRow02";
					  if (i % 2 == 0) color = "TextRow01"; 								   
				%>	  					  						      
					  <%=fb.hidden("keyFlia"+i,cdo.getColValue("keyFlia"))%>
					  <%=fb.hidden("fliaCode"+i,cdo.getColValue("fliaCode"))%>						      
					  <%=fb.hidden("flia"+i,cdo.getColValue("flia"))%>								  
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("fliaCode")%></td>
					<td><%=cdo.getColValue("flia")%></td>
					<td><%=(VKey.contains(cdo.getColValue("keyFlia")))?"Elegido":fb.checkbox("check"+i,"S",false,false)%></td>
					<%                                
						}
					%>                            		
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%"  border="0" cellspacing="0" cellpadding="0">
				<tr class="TextPager">
					<td width="9%">
					<%
					   if(preVal!=1)
					   {
					%>
						 <%=fb.hidden("nextVal3",""+(nxtVal-100))%>
						 <%=fb.hidden("previousVal3",""+(preVal-100))%>
						 <%=fb.hidden("searchOn3",searchOn)%>
						 <%=fb.hidden("searchVal3",searchVal)%>
						 <%=fb.hidden("searchType3",searchType)%>
						 <%=fb.hidden("searchDisp3",searchDisp)%>
						 <%=fb.hidden("searchQuery3","sQ")%>
						 <%=fb.submit("previous3","Anterior")%>					
					<%
					   }
					%>
					</td>
					<td width="82%">&nbsp;</td>
					<td width="9%" align="right">
					<%
					   if(!(rowCount<=nxtVal))
					   {
					%>
						 <%=fb.hidden("nextVal4",""+(nxtVal+100))%> 
						 <%=fb.hidden("previousVal4",""+(preVal+100))%>
						 <%=fb.hidden("searchOn4",searchOn)%>
						 <%=fb.hidden("searchVal4",searchVal)%>
						 <%=fb.hidden("searchType4",searchType)%>
						 <%=fb.hidden("searchDisp4",searchDisp)%>
						 <%=fb.hidden("searchQuery4","sQ")%>
						 <%=fb.submit("next4","Siguiente")%>			
					<%
					   }
					%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td><div align="right"><span class="TitlesBendigo">
		<%=fb.submit("add","Agregar",true,false)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>               
		</span></div></td>
	</tr>
	<%=fb.formEnd()%>	
</table>	

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{ 
  int size = Integer.parseInt(request.getParameter("size"));
  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
  almaId = request.getParameter("almaId");
  
  for (int i=0; i<size; i++)
  {	 
	 if (request.getParameter("check"+i)!= null)
	 {  
	    CommonDataObject cdo3 = new CommonDataObject();
		
		cdo3.setTableName("tbl_inv_parametro_inv");
		cdo3.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and almacen="+almaId);
		cdo3.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo3.addColValue("almacen",almaId);
		cdo3.addColValue("fliaCode",request.getParameter("fliaCode"+i));
		cdo3.addColValue("flia",request.getParameter("flia"+i));
		cdo3.addColValue("keyFlia",request.getParameter("keyFlia"+i));		
		
		String key = "";
		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;

		HashFlia.put(key,cdo3);
		VKey.addElement(cdo3.getColValue("keyFlia"));
	 }
  }		
  
        if(request.getParameter("previous1")!=null)
        {
          response.sendRedirect("ctas_familia_inventario2_config.jsp?nextVal="+request.getParameter("nextVal1")+"&previousVal="+request.getParameter("previousVal1")+"&searchOn="+request.getParameter("searchOn1")+"&searchVal="+request.getParameter("searchVal1")+"&searchType="+request.getParameter("searchType1")+"&searchDisp="+request.getParameter("searchDisp1")+"&searchQuery="+request.getParameter("searchQuery1")+"&almaId="+almaId+"&lastLineNo="+lastLineNo);
          return;
        }else if(request.getParameter("next2")!=null)
              {
                response.sendRedirect("ctas_familia_inventario2_config.jsp?nextVal="+request.getParameter("nextVal2")+"&previousVal="+request.getParameter("previousVal2")+"&searchOn="+request.getParameter("searchOn2")+"&searchVal="+request.getParameter("searchVal2")+"&searchType="+request.getParameter("searchType2")+"&searchDisp="+request.getParameter("searchDisp2")+"&searchQuery="+request.getParameter("searchQuery2")+"&almaId="+almaId+"&lastLineNo="+lastLineNo);
                return;
              }else if(request.getParameter("previous3")!=null)
		            {
                      response.sendRedirect("ctas_familia_inventario2_config.jsp?nextVal="+request.getParameter("nextVal3")+"&previousVal="+request.getParameter("previousVal3")+"&searchOn="+request.getParameter("searchOn3")+"&searchVal="+request.getParameter("searchVal3")+"&searchType="+request.getParameter("searchType3")+"&searchDisp="+request.getParameter("searchDisp3")+"&searchQuery="+request.getParameter("searchQuery3")+"&almaId="+almaId+"&lastLineNo="+lastLineNo);
                      return;
                    }else if(request.getParameter("next4")!=null)
			              {
                            response.sendRedirect("ctas_familia_inventario2_config.jsp?nextVal="+request.getParameter("nextVal4")+"&previousVal="+request.getParameter("previousVal4")+"&searchOn="+request.getParameter("searchOn4")+"&searchVal="+request.getParameter("searchVal4")+"&searchType="+request.getParameter("searchType4")+"&searchDisp="+request.getParameter("searchDisp4")+"&searchQuery="+request.getParameter("searchQuery4")+"&almaId="+almaId+"&lastLineNo="+lastLineNo);
                            return;
                          }	
						 
%>
<html>
<head>
<script language="javascript">
function closeWindow()			
{
	window.opener.location = 'ctas_familia_inventario_config.jsp?almaId=<%=almaId%>&lastLineNo=<%=lastLineNo%>&change=1';
	//alert()
	window.close(almaId);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
