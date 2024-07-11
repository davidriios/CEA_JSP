<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="hteducacion" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vcteducacion" scope="session" class="java.util.Vector" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String fp = request.getParameter("fp");
String emp_id = request.getParameter("emp_id");
String fg = request.getParameter("fg");
String fg1 = request.getParameter("fg1");

int educaLastLineNo = 0;
int cursoLastLineNo = 0;
int habilidadLastLineNo = 0;
int entrenimientoLastLineNo = 0;
int idiomaLastLineNo = 0;
int enfermedadLastLineNo= 0;
int medidadLastLineNo = 0;
int reconocimientoLastLineNo = 0;
int parienteLastLineNo =0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if(request.getParameter("educaLastLineNo")!= null)
educaLastLineNo = Integer.parseInt(request.getParameter("educaLastLineNo"));

if(request.getParameter("cursoLastLineNo")!=null)
cursoLastLineNo = Integer.parseInt(request.getParameter("cursoLastLineNo"));

if(request.getParameter("habilidadLastLineNo")!=null)
habilidadLastLineNo = Integer.parseInt(request.getParameter("habilidadLastLineNo"));

if(request.getParameter("entrenimientoLastLineNo")!= null)
entrenimientoLastLineNo = Integer.parseInt(request.getParameter("entrenimientoLastLineNo")); 	

if(request.getParameter("idiomaLastLineNo")!=null)
idiomaLastLineNo=Integer.parseInt(request.getParameter("idiomaLastLineNo"));

if(request.getParameter("enfermedadLastLineNo")!= null)
enfermedadLastLineNo = Integer.parseInt(request.getParameter("enfermedadLastLineNo"));

if(request.getParameter("medidadLastLineNo")!=null)
medidadLastLineNo = Integer.parseInt(request.getParameter("medidadLastLineNo"));

if(request.getParameter("reconocimientoLastLineNo")!= null)
reconocimientoLastLineNo = Integer.parseInt(request.getParameter("reconocimientoLastLineNo"));

if(request.getParameter("parienteLastLineNo")!=null)
parienteLastLineNo = Integer.parseInt(request.getParameter("parienteLastLineNo"));

if (request.getParameter("mode") == null) mode = "add";

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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
  String codigo="",descripcion="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
   if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

 if (fp.equalsIgnoreCase("empleado"))
	{
	sql="Select codigo, descripcion from tbl_pla_tipo_educacion where codigo > 0"+appendFilter+"order by descripcion";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Lista de Tipo de Educación - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECURSOS HUMANOS - EXPEDIENTE DEL EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>	
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("prov",prov)%>
				<%=fb.hidden("sig",sig)%>
				<%=fb.hidden("tom",tom)%>
				<%=fb.hidden("asi",asi)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fg1",fg1)%>
				<%=fb.hidden("emp_id",emp_id)%>
				<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
				<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
				<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
				<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
				<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
				<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
				<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
          <td width="50%">&nbsp;C&oacute;digo
		  <%=fb.textBox("codigo","",false,false,false,30,null,null,null)%> 
		  </td>
          <td width="50%">&nbsp;Descripci&oacute;n
		   <%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%> 
		   <%=fb.submit("go","Ir")%> </td>
				<%=fb.formEnd()%> 
		</tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sig",sig)%>
<%=fb.hidden("tom",tom)%>
<%=fb.hidden("asi",asi)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fg1",fg1)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>

<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
		</table>
	</td>
</tr>
	
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
			</tr>
		</table>
	</td>
</tr>			
</table>	

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<TD class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="educ">
			<tr class="TextHeader">
				<td width="10%">&nbsp;</td>
				<td width="20%">&nbsp;C&oacute;digo</td>
				<td width="60%">&nbsp;Nombre</td>	
				<TD width="10%">&nbsp;</TD>
			</tr>
			<%
			for (int i=0; i<al.size(); i++)
			{
			 CommonDataObject cdo = (CommonDataObject) al.get(i);
			 String color = "TextRow02";
			 if (i % 2 == 0) color = "TextRow01";
			%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td align="right"><%=preVal + i%>&nbsp;</td>
				<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
				<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
				<!--<td align="center"><%=(vcteducacion.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>--->
				<td align="center"><%=fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>
			</tr>
			<%
			}
			%>	
								
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->		
			</table>	
		</TD>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
else
{//Post
 int size = Integer.parseInt(request.getParameter("size"));
 for (int i=0; i<size; i++)
 {
 	 if(request.getParameter("check"+i) != null)
	 {
	 CommonDataObject cdo = new CommonDataObject();

	cdo.addColValue("tipo",request.getParameter("codigo"+i));
	cdo.addColValue("educacioName",request.getParameter("descripcion"+i));
	cdo.addColValue("fecha_inicio","");
	cdo.addColValue("fecha_final","");	
	educaLastLineNo++;
	
	String key="";
	if(educaLastLineNo<10)
	key="00"+educaLastLineNo;
	else if(educaLastLineNo<100)
	key="0"+educaLastLineNo;
	else key=""+educaLastLineNo;
	cdo.addColValue("key",key);
	try 
	{
	hteducacion.put(key,cdo);
	vcteducacion.add(cdo.getColValue("tipo"));
	}//end Try
	catch(Exception e)
	{
		System.err.println(e.getMessage());
	}
	 }//End check
 }//End For
 
 if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&emp_id="+emp_id+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&fg="+request.getParameter("fg")+"&fg1="+request.getParameter("fg1")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
		

	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&emp_id="+emp_id+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&fg="+request.getParameter("fg")+"&fg1="+request.getParameter("fg1")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.opener.location = '../rhplanilla/expediente_empleado_config.jsp?change=1&tab=1&mode=<%=mode%>&emp_id=<%=emp_id%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fp=<%=fg1%>';
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