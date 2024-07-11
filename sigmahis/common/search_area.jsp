<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String area = request.getParameter("area");
String grupo = "";
if(fp == null) fp = "";
if(fg == null) fg = "";
if(area == null) area = "";
String codigo = "", nombre = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("grupo")!= null && !request.getParameter("grupo").equalsIgnoreCase(""))
{
    grupo = request.getParameter("grupo");
}

if (request.getMethod().equalsIgnoreCase("GET"))
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

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) = "+request.getParameter("codigo");
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
	codigo =request.getParameter("codigo"); 
  }
  
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(nombre) like upper('%"+request.getParameter("nombre").toUpperCase()+"%')";
    searchOn = "nombre";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre";
	nombre=request.getParameter("nombre");
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

	if (fp.equalsIgnoreCase("empleado_programa") || fp.equalsIgnoreCase("programa_turno_borrador"))
	{
		sql = "SELECT DISTINCT (SELECT MIN(C.CODIGO) FROM TBL_PLA_CT_AREA_X_GRUPO C WHERE C.COMPANIA = A.COMPANIA AND C.GRUPO = A.GRUPO AND C.ABREVIATURA = A.ABREVIATURA) CODIGO,(SELECT DISTINCT RTRIM(LTRIM(SUBSTR(B.NOMBRE,1, DECODE(INSTR(B.NOMBRE,'[')-1,-1,LENGTH(B.NOMBRE),INSTR(B.NOMBRE,'[')-1)))) FROM TBL_PLA_CT_AREA_X_GRUPO B WHERE B.COMPANIA = A.COMPANIA AND B.GRUPO = A.GRUPO AND B.CODIGO = A.CODIGO) NOMBRE FROM TBL_PLA_CT_AREA_X_GRUPO A WHERE A.COMPANIA = "+(String) session.getAttribute("_companyId")+" AND A.GRUPO = "+grupo+appendFilter;
	} else if( fp.equals("ingreso") || fp.equals("ingresoTramite")){
		sql = "select a.codigo, a.nombre from tbl_pla_ct_area_x_grupo a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.grupo = " + grupo + appendFilter+" order by a.grupo, a.nombre";
	}else if( fp.equals("acciones_grupos")){
		if (fg.trim().equals("MOV") || fg.trim().equals("TRANS")){
		   if (!area.trim().equals("") && fg.trim().equals("MOV")) appendFilter+=" and a.codigo <> "+area;
		   sql = "select a.codigo, a.nombre from tbl_pla_ct_area_x_grupo a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.grupo = " + grupo + appendFilter+" order by a.grupo, a.nombre";
		}else 
		sql = "select a.codigo, a.nombre from tbl_pla_ct_area_x_grupo a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.grupo = " + grupo + appendFilter+" and a.estado = 1 /*??*/ order by a.grupo, a.nombre";
	}
	
	if (request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
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
document.title = 'Aréas de Grupo - '+document.title;

function setArea(i)
{
<%
	if (fp.equalsIgnoreCase("empleado_programa"))
	{
%>
		window.opener.document.formTurno.ubicacion_fisica.value = eval('document.formArea.codigo'+i).value;
		window.opener.document.formTurno.ubicacionFisicaDesc.value = eval('document.formArea.nombre'+i).value;
<%
	} else if (fp.equalsIgnoreCase("ingreso"))
	{
%>
		window.opener.document.form1.uFisica.value = eval('document.formArea.codigo'+i).value;
		window.opener.document.form1.ubicFisica.value = eval('document.formArea.nombre'+i).value;
<%
    } else if (fp.equalsIgnoreCase("programa_turno_borrador")){
%>		
		var name = '<%=index%>';
		eval('window.opener.document.form.'+name).value = eval('document.formArea.nombre'+i).value;
		eval('window.opener.document.form.'+name.replace("dsp_","")).value = eval('document.formArea.codigo'+i).value;
<%
		} else if (fp.equalsIgnoreCase("ingresoTramite")){
%>		
		window.opener.document.form1.ubicFisica.value = eval('document.formArea.codigo'+i).value;
		window.opener.document.form1.ubicFisicaDesc.value = eval('document.formArea.nombre'+i).value;
<%
		}else if (fp.equalsIgnoreCase("acciones_grupos")){
		
		   if (fg.trim().equalsIgnoreCase("MOV")){%>
             window.opener.$("#ubicacion_fisica_nueva<%=index%>").val(eval('document.formArea.codigo'+i).value);
			 window.opener.$("#ubicacion_fisica_nueva_desc<%=index%>").val(eval('document.formArea.nombre'+i).value);
			 if (window.opener.$("#num_empleado_a_remplazar<%=index%>").val()) window.opener.$("#checked<%=index%>").val("1");	
		   <%
		   }else if(fg.trim().equalsIgnoreCase("TRANS")){%>
		     window.opener.$("#area_destino<%=index%>").val(eval('document.formArea.codigo'+i).value);
			 window.opener.$("#area_destino_desc<%=index%>").val(eval('document.formArea.nombre'+i).value);
			 if (window.opener.$("#grupo_destino<%=index%>").val()) window.opener.$("#checked<%=index%>").val("1");	
		 <%}else{%>	
		window.opener.document.form0.area.value = eval('document.formArea.codigo'+i).value;
		window.opener.document.form0.areaDesc.value = eval('document.formArea.nombre'+i).value;	
<%
}
}
%>	
		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE AREAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">		
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="100%">&nbsp;C&oacute;digo					
					<%=fb.textBox("codigo",codigo,false,false,false,10)%>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					Nombre
					<%=fb.textBox("nombre",nombre,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>	
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	
		
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%">C&oacute;digo</td>
					<td width="80%">Nombre</td>
				</tr>
				<%
				fb = new FormBean("formArea",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setArea(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
				</tr>
				<%
				}
				%>							
				<%=fb.formEnd()%>						
          </table>	

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	  </td>
   </tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("beginSearch","")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
	