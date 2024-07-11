<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
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
==============================================================================
==============================================================================
**/
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
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String curSelEqui = request.getParameter("curSelEqui");
String toIndex = request.getParameter("cInd");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";
if (id == null) id = "";
if (curSelEqui==null) curSelEqui = "";
if (toIndex == null) toIndex = "";

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
  String codigo="",descripcion="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
		appendFilter += " and no_equipo= "+request.getParameter("codigo")+"";
   		codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
		appendFilter += " and upper(nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	    descripcion = request.getParameter("descripcion");
  }
 
  if (fp.equalsIgnoreCase("equipos_medicos")) {
  
		sql = "select decode(a.tipo_equipo,'CO','COMODATO','SF','SIN FACTURAR') tipo_equipo, a.no_equipo, a.nombre, a.unidad_adm, a.estado, a.modelo, a.serie,(select descripcion from tbl_sec_unidad_ejec where codigo = a.unidad_adm and compania=a.compania )desc_unidad,a.referencia  from tbl_inv_comodato_equipos a where a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+"  and a.visible_en_exp = 'S' and a.estado = 'A' and a.estado_uso ='D' and referencia is not null order by a.no_equipo desc";
		
		al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
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
document.title = 'Equipos Médicos - '+document.title;

function setEqM(cInd){
  <% if (fp.equalsIgnoreCase("equipos_medicos")){%>
    if (eval('document.details.ignoreClick'+cInd) == null){
		window.opener.document.getElementById("no_equipo<%=toIndex%>").value=eval('document.details.codigo'+cInd).value;
		window.opener.document.getElementById("equipo_desc<%=toIndex%>").value=eval('document.details.descripcion'+cInd).value;
		window.opener.document.getElementById("modelo<%=toIndex%>").value=eval('document.details.modelo'+cInd).value;
		window.opener.document.getElementById("serie<%=toIndex%>").value=eval('document.details.serie'+cInd).value;
		window.opener.document.getElementById("chkSol<%=toIndex%>").checked = true;
		window.opener.document.getElementById("cod_ref<%=toIndex%>").value=eval('document.details.referencia'+cInd).value;
		window.close();
	}
  <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EQUIPOS MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("curSelEqui",curSelEqui)%>
					<td width="50%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,30)%>
					</td>
					
					<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",descripcion,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
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

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("details",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("curSelEqui",curSelEqui)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager" style="display:<%=fp.equals("equipos_medicos")?"none":"block"%>">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%><%=fb.submit("addCont","Agregar y Continuar")%>
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
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Unidad Ejec.</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Modelo</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Serie</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,(fp.equals("equipos_medicos")),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los uso listados!")%></td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("no_equipo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("serie"+i,cdo.getColValue("serie"))%>
				<%=fb.hidden("modelo"+i,cdo.getColValue("modelo"))%>
				<%=fb.hidden("referencia"+i,cdo.getColValue("referencia"))%>
				<%if(fp.equalsIgnoreCase("equipos_medicos")){%>
				  <%if(curSelEqui.equals(cdo.getColValue("no_equipo"))){%>
				     <%=fb.hidden("ignoreClick"+i,"S")%>
				  <%}%>
				<%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="setEqM(<%=i%>)">
					<td align="center"><%=cdo.getColValue("no_equipo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("desc_unidad")%></td>
					<td align="center"><%=cdo.getColValue("modelo")%></td>
					<td align="center"><%=cdo.getColValue("serie")%></td>
					<%System.out.println("::::::::::::::::::::::::::::::::::::"+curSelEqui+" <> "+cdo.getColValue("no_equipo") );%>
					<td align="center"><%=( curSelEqui.equals(cdo.getColValue("no_equipo")) )?"Elegido":fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"setEqM("+i+")\"","")%></td>
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
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager" style="display:<%=fp.equals("equipos_medicos")?"none":"block"%>">
					<td align="right">
						<%=fb.submit("save2","Guardar",true,false)%><%=fb.submit("addCont2","Agregar y Continuar")%>
						<%=fb.button("cancel2","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<%
}
%>