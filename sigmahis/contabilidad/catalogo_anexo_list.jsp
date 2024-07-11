<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="_companyId" scope="session" class="java.lang.String" />
<%
/*
==========================================================================================
fg = RE --> registro y edicion de cuentas.
fg = CS --> Consulta de movimiento de Cuentas.
==========================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al94 = new ArrayList();
ArrayList al72 = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String nivel = request.getParameter("nivel");
String estado = request.getParameter("estado");
if(nivel==null) nivel = "";
if(fg == null) fg = "";
String cta1=request.getParameter("cta1");
String cta2=request.getParameter("cta2");
String cta3=request.getParameter("cta3");
String cta4=request.getParameter("cta4");
String cta5=request.getParameter("cta5");
String cta6=request.getParameter("cta6");
String descripcion =  request.getParameter("descripcion");
String recibeMov=request.getParameter("recibeMov");
String clase=request.getParameter("clase");
String tipo=request.getParameter("tipo");

if(cta1 == null) cta1 = "";
if(cta2 == null) cta2 = "";
if(cta3 == null) cta3 = "";
if(cta4 == null) cta4 = "";
if(cta5 == null) cta5 = "";
if(cta6 == null) cta6 = "";

if(descripcion == null) descripcion = "";
if(recibeMov == null) recibeMov = "";
if(clase == null) clase = "";
if(tipo == null) tipo = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 200;
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
	
	StringBuffer sbFilter = new StringBuffer();

  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
		sbFilter.append(" and upper(a.descripcion) like '%");
		sbFilter.append(request.getParameter("descripcion").toUpperCase());
		sbFilter.append("%'");
   
  }
  if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals("")){
		sbFilter.append(" and a.cta1 like '%");
		sbFilter.append(request.getParameter("cta1").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals("")){
		sbFilter.append(" and a.cta2 like '%");
		sbFilter.append(request.getParameter("cta2").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals("")){
		sbFilter.append(" and a.cta3 like '%");
		sbFilter.append(request.getParameter("cta3").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals("")){
		sbFilter.append(" and a.cta4 like '%");
		sbFilter.append(request.getParameter("cta4").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals("")){
		sbFilter.append(" and a.cta5 like '%");
		sbFilter.append(request.getParameter("cta5").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals("")){
		sbFilter.append(" and a.cta6 like '%");
		sbFilter.append(request.getParameter("cta6").toUpperCase());
		sbFilter.append("%'");
   }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals("")){
		sbFilter.append(" and a.status='");
		sbFilter.append(request.getParameter("estado"));
		sbFilter.append("'");
   }
  if (request.getParameter("recibeMov") != null && !request.getParameter("recibeMov").trim().equals("")){
		sbFilter.append(" and a.recibe_mov='");
		sbFilter.append(request.getParameter("recibeMov"));
		sbFilter.append("'");
   }
  if (request.getParameter("clase") != null && !request.getParameter("clase").trim().equals("")){
		sbFilter.append(" and a.tipo_cuenta=");
		sbFilter.append(request.getParameter("clase")); 
   }
   if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals("")){
		sbFilter.append(" and b.codigo_prin=");
		sbFilter.append(request.getParameter("tipo")); 
   }  
  
  if (!nivel.trim().equals("") && !nivel.equals("T"))
  {
		sbFilter.append(" and nivel >= ");
		sbFilter.append(nivel);
  }    
  
	StringBuffer sbSql = new StringBuffer();
  sbSql.append("SELECT a.nivel, cuentas as ctaFinanciera, cta1, cta2, cta3, cta4, cta5, cta6, a.descripcion, compania, lado_movim, recibe_mov, b.descripcion as clasDesc, a.status, num_cuenta dsp_cuenta, cta1||'.'||cta2 ||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 as cuenta,(select cod_72 from tbl_con_catalogo_anexomef where cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6 and compania = a.compania ) cod72,(select cod_94 from tbl_con_catalogo_anexomef where cta1=a.cta1 and cta2=a.cta2 and cta3=a.cta3 and cta4=a.cta4 and cta5=a.cta5 and cta6=a.cta6 and compania = a.compania ) cod94 from vw_con_catalogo_gral a, tbl_con_cla_ctas b where compania=");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(sbFilter.toString());
	sbSql.append(" and a.tipo_cuenta=b.codigo_clase order by cuentas");
	
	StringBuffer sbSqlT = new StringBuffer();
  sbSqlT.append("select * from (select rownum as rn, a.* from (");
	sbSqlT.append(sbSql.toString());
	sbSqlT.append(") a) where rn between ");
	sbSqlT.append(previousVal);
	sbSqlT.append(" and ");
	sbSqlT.append(nextVal);
  al = SQLMgr.getDataList(sbSqlT.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
   
   sbSql = new StringBuffer();
   sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_con_conceptos_mef where informe=94 and estado='A' order by codigo"); 
   System.out.println("SQL ========== "+sbSql);
   al94 = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
   sbSql = new StringBuffer();
   sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_con_conceptos_mef where informe=72 and estado='A'  order by codigo"); 
   System.out.println("SQL ========== "+sbSql);
   al72 = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
   
	
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Catalogo General - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();checkObser();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 <jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CERRAR ORDEN DE COMPRA"></jsp:param>
</jsp:include> 
<table align="center" width="99%" cellpadding="1" cellspacing="1" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<tr class="TextFilter">
	<td>Cuenta: 
					<%=fb.textBox("cta1",cta1,false,false,false,3,3)%> 
					<%=fb.textBox("cta2",cta2,false,false,false,3,3)%> 
					<%=fb.textBox("cta3",cta3,false,false,false,3,3)%> 
					<%=fb.textBox("cta4",cta4,false,false,false,3,3)%> 
					<%=fb.textBox("cta5",cta5,false,false,false,3,3)%> 
					<%=fb.textBox("cta6",cta6,false,false,false,3,3)%> 
					Descripci&oacute;n 
					<%=fb.textBox("descripcion",descripcion,false,false,false,40)%> &nbsp;&nbsp; 
					Recibe Mov:<%=fb.select("recibeMov","S=SI,N=NO",recibeMov,false,false,0,"Text10",null,null,"","S")%>
					&nbsp;&nbsp;Estado<%=fb.select("estado","A=ACTIVA,I=INACTIVA",estado,false,false,0,"Text10",null,null,"","S")%>
					Desde Nivel:
					<%=fb.select("nivel","T=Todos,1=1,2=2,3=3,4=4,5=5,6=6",nivel,false,false,0,"Text10",null,"")%> 

 	</td>
</tr>
<tr class="TextFilter">
	<td> 
	Cuenta Principal:&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo_prin as codigo, descripcion cta_dsp from tbl_con_ctas_prin  order by descripcion","tipo",tipo,false,false,0,"Text10",null,"",null,"T")%>&nbsp;&nbsp;&nbsp;&nbsp;
	Clase Cuenta:&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo_clase, descripcion clase_dsp from tbl_con_cla_ctas order by descripcion","clase",clase,false,false,0,"Text10",null,"",null,"T")%>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>

<%=fb.formEnd()%>
<tr>
	<td align="right">&nbsp;</td>
</tr>
 <tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("cta1",cta1)%>
				<%=fb.hidden("cta2",cta2)%>
				<%=fb.hidden("cta3",cta3)%>
				<%=fb.hidden("cta4",cta4)%>
				<%=fb.hidden("cta5",cta5)%>
				<%=fb.hidden("cta6",cta6)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("recibeMov",recibeMov)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nivel",nivel)%>
				<%=fb.hidden("descripcion",descripcion)%>
				
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("cta1",cta1)%>
				<%=fb.hidden("cta2",cta2)%>
				<%=fb.hidden("cta3",cta3)%>
				<%=fb.hidden("cta4",cta4)%>
				<%=fb.hidden("cta5",cta5)%>
				<%=fb.hidden("cta6",cta6)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("recibeMov",recibeMov)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nivel",nivel)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableBorder">
	<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
	<table align="center" width="100%" cellpadding="0" cellspacing="1">
				
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("change","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("recibeMov",recibeMov)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("nivel",nivel)%>
<%=fb.hidden("descripcion",descripcion)%>
				<tr class="TextRow02">
					<td colspan="7" align="right"><%=fb.submit("saveU","Guardar",true,false)%></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="18%"><cellbytelabel>Cuenta</cellbytelabel></td>
					<td width="32%"><cellbytelabel>Descripcion</cellbytelabel></td>
					<td width="10%">Lado Mov.</td>
          			<td width="10%">Recibe Mov.</td>
					<td width="14%"><cellbytelabel>Concepto MEF: 72</cellbytelabel></td>
					<td width="14%"><cellbytelabel>Concepto MEF: 94</cellbytelabel></td> 
					<td width="2%">&nbsp;</td> 
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
 				<%=fb.hidden("cta1_"+i,cdo.getColValue("cta1"))%>
				<%=fb.hidden("cta2_"+i,cdo.getColValue("cta2"))%>
				<%=fb.hidden("cta3_"+i,cdo.getColValue("cta3"))%>
				<%=fb.hidden("cta4_"+i,cdo.getColValue("cta4"))%>
				<%=fb.hidden("cta5_"+i,cdo.getColValue("cta5"))%>
				<%=fb.hidden("cta6_"+i,cdo.getColValue("cta6"))%>
				
				<tr class="TextRow01" align="center">
					<td align="left">&nbsp;&nbsp;&nbsp; <font class="Text10Bold"><%=cdo.getColValue("dsp_cuenta")%></font></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=cdo.getColValue("lado_movim")%></td>
					<td align="center"><%=cdo.getColValue("recibe_mov")%></td>
	   
					<td><%=fb.select("cod_72"+i,al72,""+cdo.getColValue("cod72"),false,false,false,0,"Text10",null,null,"","S")%></td>
					<td><%=fb.select("cod_94"+i,al94,""+cdo.getColValue("cod94"),false,false,false,0,"Text10",null,null,"","S")%></td>  
					<td>&nbsp;</td>  
				</tr>
<%
}
%>
				<tr class="TextRow02">
					<td colspan="7" align="right"><%=fb.submit("saveB","Guardar",true,false)%></td>
				</tr>
	<%=fb.formEnd(true)%>
				</table>
 </div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("cta1",cta1)%>
				<%=fb.hidden("cta2",cta2)%>
				<%=fb.hidden("cta3",cta3)%>
				<%=fb.hidden("cta4",cta4)%>
				<%=fb.hidden("cta5",cta5)%>
				<%=fb.hidden("cta6",cta6)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("recibeMov",recibeMov)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nivel",nivel)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%> 
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("cta1",cta1)%>
				<%=fb.hidden("cta2",cta2)%>
				<%=fb.hidden("cta3",cta3)%>
				<%=fb.hidden("cta4",cta4)%>
				<%=fb.hidden("cta5",cta5)%>
				<%=fb.hidden("cta6",cta6)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("clase",clase)%>
				<%=fb.hidden("recibeMov",recibeMov)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nivel",nivel)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
    al.clear();
	int size = Integer.parseInt(request.getParameter("size"));
	
	System.out.println("DESCRIPCION ==");
  	for (int i=0; i<size; i++)
	{
	  /*if ((request.getParameter("cod_72"+i) != null && request.getParameter("cod_72"+i).trim().equals(""))|| (request.getParameter("cod_94"+i) != null && request.getParameter("cod_94"+i).trim().equals(""))) 
	  {	*/
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_con_catalogo_anexomef");   
     	cdo.setWhereClause("cta1='"+request.getParameter("cta1_"+i)+"' and cta2='"+request.getParameter("cta2_"+i)+"' and cta3='"+request.getParameter("cta3_"+i)+"' and cta4='"+request.getParameter("cta4_"+i)+"' and cta5='"+request.getParameter("cta5_"+i)+"' and cta6='"+request.getParameter("cta6_"+i)+"' and compania="+(String) session.getAttribute("_companyId"));   
	
		cdo.addColValue("cod_72",request.getParameter("cod_72"+i));
  		cdo.addColValue("cod_94",request.getParameter("cod_94"+i));
  		if (request.getParameter("cod_20"+i) != null)cdo.addColValue("cod_20",request.getParameter("cod_20"+i)); 
	    
		cdo.setKey(i);
		cdo.setAction("U"); 
		//cdo.addColValue("fecha_mod","sysdate");	 
		//cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
		//cdo.addColValue("motivo",request.getParameter("comments"+i));
		
		al.add(cdo);
	  //}
 	}
	
	if (al.size() == 0)
	{
		CommonDataObject cdo = new CommonDataObject();
		
		cdo.setTableName("tbl_con_catalogo_anexomef");
		cdo.setWhereClause("cta=-1 and compania="+(String) session.getAttribute("_companyId"));

		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true,false);
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
	window.location = '../contabilidad/catalogo_anexo_list.jsp?fg=<%=fg%>&tipo=<%=tipo%>&estado=<%=estado%>&cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&nivel=<%=nivel%>&recibeMov=<%=recibeMov%>&descripcion=<%=descripcion%>&clase=<%=clase%>';
<%
}
else throw new Exception(SQLMgr.getErrMsg());
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
