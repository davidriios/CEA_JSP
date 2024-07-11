<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.rhplanilla.FactoresEval"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iFact" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFact" scope="session" class="java.util.Vector" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500021") || SecMgr.checkAccess(session.getId(),"500022") || SecMgr.checkAccess(session.getId(),"500023") || SecMgr.checkAccess(session.getId(),"500024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String empId = request.getParameter("empId");
String check1 = "";
String prov = request.getParameter("prov");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
int factLastLineNo = 0;



if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("factLastLineNo") != null) factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("get"))
{ 
  int recsPerPage = 60;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("codigo") != null)
  {
		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
		appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  
  if(rowCount==0) pVal=0;
  else pVal=preVal;
  
  sql = "select * from tbl_pla_empleado a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and emp_id = "+empId;
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		
		
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Carpetas - '+document.title;
function  imprime(empId)
{
var sw = "0";
var size = 9;
var x = 0;
	for (i=1; i<=9; i++)
		{
			x++;
						if (eval("document.form1.check"+i).checked)
     				{
        eval("document.form1.check"+i).value = 'S'; 
     				}
     else
    		 {
        eval("document.form1.check"+i).value = 'N';
    		 }   

				if(eval('document.form1.check'+i).value=='S' )
				
				{
	  			size = x;
				//	size = document.form1.check+i.value;
					sw=sw+","+size;
  			}
		}
abrir_ventana('../rhplanilla/print_exp_empleado.jsp?p='+sw+'&empId='+empId);
}

function verifyCheck(j)
{
 if (eval("document.form1.check"+j).checked)
     {
        eval("document.form1.check"+j).value = 'S'; 
     }
     else
     {
        eval("document.form1.check"+j).value = 'N';
     }   

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CARPETAS DEL EXPEDIENTE"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">		
					<%
					fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
				    <%=fb.formEnd()%>		
                    
					<%
					fb = new FormBean("search02",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
				 	<%=fb.formEnd()%>		
			  </tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
</table>

<table align="center" width="75%" cellpadding="0" cellspacing="0">

	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						
						<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>

</table>	

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<%	fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
  <%=fb.formStart()%>
	
	<tr>
		<td id= "form1" class="TableLeftBorder TableRightBorder">

<!-- ==============   R E S U L T S   S T A R T   H E R E   ================== -->
			<table align="center" width="75%" cellpadding="1" cellspacing="1">
      
				<tr class="TextHeader" align="center">
					<td width="20%">Carpeta</td>
					<td width="60%">Descripci&oacute;n</td>
					<td width="20%">Selección</td>
				</tr>	
				
				<%
					for (int i=0; i<al.size(); i++)
					{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
	         <%=fb.hidden("empId",cdo.getColValue("emp_id"))%>
           <%=fb.hidden("sw","")%>
        
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		
					<td width="20%">Tab. 1</td>
					<td width="60%">Generales del Empleado y Datos del Puesto</td>
						<td align="center"><%=fb.checkbox("check0","S",true,true)%></td>
          			
				</tr>
					<% color = "TextRow01";
					 %>
					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 2</td>
					<td width="60%">Educación</td>
						<td align="center"><%=fb.checkbox("check1","S",false,false)%></td>
				</tr>
					<% color = "TextRow02";  %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 3</td>
					<td width="60%">Cursos</td>
						<td align="center"><%=fb.checkbox("check2","S",false,false)%></td>
				</tr>
					<% color = "TextRow01"; %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 4</td>
					<td width="60%">Habilidades</td>
					<td align="center"><%=fb.checkbox("check3","S",false,false)%></td>
				</tr>
				<% color = "TextRow02"; %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 5</td>
					<td width="60%">Entretenimientos</td>
					<td align="center"><%=fb.checkbox("check4","S",false,false)%></td>
				</tr>
				<% color = "TextRow01"; %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 6</td>
					<td width="60%">Idiomas</td>
					<td align="center"><%=fb.checkbox("check5","S",false,false)%></td>
					
				</tr>
				<% color = "TextRow02";%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 7</td>
					<td width="60%">Enfermedades</td>
					<td align="center"><%=fb.checkbox("check6","S",false,false)%></td>
				</tr>
				<% color = "TextRow01"; %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 8</td>
					<td width="60%">Medidas Disciplinarias</td>
					<td align="center"><%=fb.checkbox("check7","S",false,false)%></td>
				</tr>
				<% color = "TextRow02"; %>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 9</td>
					<td width="60%">Reconocimientos</td>
					<td align="center"><%=fb.checkbox("check8","S",false,false)%></td>
				</tr>
				<% color = "TextRow01";%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				
					<td width="20%">Tab. 10</td>
					<td width="60%">Parientes</td>
					<td align="center"><%=fb.checkbox("check9","S",false,false)%></td>
				</tr>
				
				
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
		</td>
	</tr>
</table>				

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="75%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right"><%=fb.button("imprimir","Imprimir",true,false,null,null,"onClick=\"javascript:imprime('"+empId+"')\"")%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					
					
				  </td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));
	id = request.getParameter("id");
	


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{

	window.opener.location = '../rhplanilla/empleado_list.jsp?change=1&mode=<%=mode%>&id=<%=id%>&prov=<%=prov%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&factLastLineNo=<%=factLastLineNo%>';

	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>