<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String nivel = request.getParameter("nivel");
String estado = request.getParameter("estado");
if(nivel==null) nivel = "";
if(fg == null) fg = "RE";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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
	
	String descripcion = "",cta1="",cta2="",cta3="",cta4="",cta5="",cta6="";
	StringBuffer sbFilter = new StringBuffer();

  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
		sbFilter.append(" and upper(a.descripcion) like '%");
		sbFilter.append(request.getParameter("descripcion").toUpperCase());
		sbFilter.append("%'");
    descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals("")){
		sbFilter.append(" and a.cta1 like '%");
		sbFilter.append(request.getParameter("cta1").toUpperCase());
		sbFilter.append("%'");
    cta1 = request.getParameter("cta1");
  }
  if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals("")){
		sbFilter.append(" and a.cta2 like '%");
		sbFilter.append(request.getParameter("cta2").toUpperCase());
		sbFilter.append("%'");
    cta2 = request.getParameter("cta2");
  }
  if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals("")){
		sbFilter.append(" and a.cta3 like '%");
		sbFilter.append(request.getParameter("cta3").toUpperCase());
		sbFilter.append("%'");
    cta3 = request.getParameter("cta3");
  }
  if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals("")){
		sbFilter.append(" and a.cta4 like '%");
		sbFilter.append(request.getParameter("cta4").toUpperCase());
		sbFilter.append("%'");
    cta4 = request.getParameter("cta4");
  }
  if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals("")){
		sbFilter.append(" and a.cta5 like '%");
		sbFilter.append(request.getParameter("cta5").toUpperCase());
		sbFilter.append("%'");
    cta5 = request.getParameter("cta5");
  }
  if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals("")){
		sbFilter.append(" and a.cta6 like '%");
		sbFilter.append(request.getParameter("cta6").toUpperCase());
		sbFilter.append("%'");
    cta6 = request.getParameter("cta6");
  }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals("")){
		sbFilter.append(" and a.status='");
		sbFilter.append(request.getParameter("estado"));
		sbFilter.append("'");
  }
  
  if (!nivel.trim().equals("") && !nivel.equals("T"))
  {
		sbFilter.append(" and nivel <= ");
		sbFilter.append(nivel);
  }    
  
	StringBuffer sbSql = new StringBuffer();
  sbSql.append("SELECT a.nivel, cuentas as ctaFinanciera, cta1, cta2, cta3, cta4, cta5, cta6, a.descripcion, compania, lado_movim, recibe_mov, b.descripcion as clasDesc, a.status, num_cuenta dsp_cuenta, cta1||'.'||cta2 ||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 as cuenta from vw_con_catalogo_gral a, tbl_con_cla_ctas b where compania=");
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
document.title = 'Cuenta Principal - '+document.title;

function add(compId)
{
	abrir_ventana('catalogo_general_config.jsp?compId='+compId+'&nivel=0');
}

function addChild(code1, code2, code3, code4, code5, code6, compId, nivel){
	var url = '../contabilidad/catalogo_general_config.jsp?mode=add&cta1='+code1;
	if(nivel>=2)url+='&cta2='+code2;
	if(nivel>=3)url+='&cta3='+code3;
	if(nivel>=4)url+='&cta4='+code4;
	if(nivel>=5)url+='&cta5='+code5;
	if(nivel>=6)url+='&cta6='+code6;
	abrir_ventana(url+'&compId='+compId+'&nivel='+nivel);
}

function edit(code1,code2,code3,code4,code5,code6,compId, nivel)
{
	abrir_ventana('catalogo_general_config.jsp?mode=edit&cta1='+code1+'&cta2='+code2+'&cta3='+code3+'&cta4='+code4+'&cta5='+code5+'&cta6='+code6+'&compId='+compId+'&nivel='+nivel);
}

function printList(){abrir_ventana('print_list_catalogo_general.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function mayorGeneral(cta1, cta2, cta3, cta4, cta5, cta6, num_cta){abrir_ventana('../contabilidad/ver_mayor.jsp?cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&num_cta='+num_cta);}
function inactivar(cuenta,fg,actType){
	if(fg=='I')msg='INACTIVAR';
	else msg='ACTIVAR';
	if(confirm('Confirma que desea '+msg+' la cuenta '+cuenta)){
	showPopWin('../common/run_process.jsp?fp=CAT&actType='+actType+'&docType=CAT&docId='+cuenta+'&docNo='+cuenta+'&estado='+fg+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.60,null,null,'');}
	else CBMSG.warning('Proceso cancelado');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right"><%if(!fg.trim().equals("CS")){%>
      <authtype type='50'><a href="javascript:add(<%=compId%>)" class="Link00">[ Registrar Nuevo Cat&aacute;logo ]</a></authtype>
      <%}%>
    </td>
  </tr>
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("fg",fg)%>
          <td width="40%">
          Cuenta: 
					<%=fb.textBox("cta1",cta1,false,false,false,3,3)%> 
					<%=fb.textBox("cta2",cta2,false,false,false,3,3)%> 
					<%=fb.textBox("cta3",cta3,false,false,false,3,3)%> 
					<%=fb.textBox("cta4",cta4,false,false,false,3,3)%> 
					<%=fb.textBox("cta5",cta5,false,false,false,3,3)%> 
					<%=fb.textBox("cta6",cta6,false,false,false,3,3)%> 
          </td>
          <td width="40%">
          Descripci&oacute;n 
					<%=fb.textBox("descripcion",descripcion,false,false,false,40)%> &nbsp;&nbsp;Estado 
					<%=fb.select("estado","A=ACTIVA,I=INACTIVA",estado,false,false,0,"Text10",null,null,"","S")%>
          </td>
          <td width="20%">
					
					Hasta Nivel:
					<%=fb.select("nivel","T=Todos,1=1,2=2,3=3,4=4,5=5,6=6",nivel,false,false,0,"Text10",null,"")%> 
					<%=fb.submit("go","Ir")%> 
          </td>
          <%=fb.formEnd()%> 
          </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%> <%=fb.hidden("descripcion",descripcion)%> <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%> <%=fb.hidden("fg",fg)%><%=fb.hidden("estado",estado)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%> <%=fb.hidden("descripcion",descripcion)%> <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%> <%=fb.hidden("fg",fg)%><%=fb.hidden("estado",estado)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
          <!--<td width="22%">Clasificacion</td>-->
          <td width="18%">C&oacute;digo</td>
          <td width="32%">Descripci&oacute;n</td>
          <td width="10%">Lado Mov.</td>
          <td width="10%">Recibe Mov.</td>
          <td width="10%">&nbsp;</td>
          <td width="10%">&nbsp;</td>
          <td width="10%">&nbsp;</td>
        </tr>
        <%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <!--<td align="right"><%=cdo.getColValue("clasDesc")%>&nbsp;</td>-->
          <td align="left">&nbsp;&nbsp;&nbsp; <font class="Text10Bold"><%=cdo.getColValue("dsp_cuenta")%></font>
            <%//=cdo.getColValue("dsp_cuenta_rest")%>
          </td>
          <td><%=cdo.getColValue("descripcion")%></td>
          <td align="center"><%=cdo.getColValue("lado_movim")%></td>
          <td align="center"><%=cdo.getColValue("recibe_mov")%></td>
          <td align="center"><%if(!fg.trim().equals("CS")){%>
            <authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>',<%=compId%>,'<%=cdo.getColValue("nivel")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
            <%}%>
          </td>
          <td align="center"><%if(fg.trim().equals("CS")){%>
            <authtype type='51'><a href="javascript:mayorGeneral('<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>','<%=cdo.getColValue("dsp_cuenta")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Mayor General</a></authtype>
            <%} else if(fg.trim().equals("INAC_CTA") && cdo.getColValue("status").equals("A")){%>
            <authtype type='52'><a href="javascript:inactivar('<%=cdo.getColValue("cuenta")%>','I',7)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Inactivar</a></authtype>
			  <%} else if(fg.trim().equals("INAC_CTA") && cdo.getColValue("status").equals("I")){%>
            <authtype type='52'><a href="javascript:inactivar('<%=cdo.getColValue("cuenta")%>','A',4)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Activar</a></authtype>
            <%}%>
          </td>
          <td align="center"><%if(!fg.trim().equals("CS") && cdo.getColValue("recibe_mov").equals("N")){%>
            <authtype type='4'><a href="javascript:addChild('<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>',<%=compId%>,'<%=cdo.getColValue("nivel")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Agregar</a></authtype>
            <%}%>
          </td>
        </tr>
        <%
				}
				%>
      </table>
      <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%> <%=fb.hidden("descripcion",descripcion)%> <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%> <%=fb.hidden("fg",fg)%><%=fb.hidden("estado",estado)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%> <%=fb.hidden("descripcion",descripcion)%> <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%> <%=fb.hidden("fg",fg)%><%=fb.hidden("estado",estado)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
