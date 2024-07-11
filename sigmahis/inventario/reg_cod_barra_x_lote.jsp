
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Recepcion"%>
<%@ page import="issi.inventory.RecDetails"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
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
String appendFilter = "", appendFilter2 = "  and a.cod_barra is null";
String compania = (String) session.getAttribute("_companyId");
String minCarBarCode = "8";
try {minCarBarCode =java.util.ResourceBundle.getBundle("issi").getString("minCharBarCode");}catch(Exception e){ minCarBarCode = "8";}
if(minCarBarCode == null || minCarBarCode.trim().equals("")) minCarBarCode = "8";
String maxCharBarCode = "35";
try {maxCharBarCode =java.util.ResourceBundle.getBundle("issi").getString("maxCharBarCode");}catch(Exception e){ maxCharBarCode = "35";}
if(maxCharBarCode == null || maxCharBarCode.trim().equals("")) maxCharBarCode = "35";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
if(fp==null) fp = "";

String codProveedor = request.getParameter("codProveedor");
if(codProveedor==null) codProveedor = "";
String codAlmacen = request.getParameter("codAlmacen");
String familia ="",clase="",articulo="",descripcion="";
String tipo = request.getParameter("tipo");

if (tipo == null) tipo = "S";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 20;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	if (request.getParameter("art_familia") != null && !request.getParameter("art_familia").equals(""))
	{
		appendFilter += " and a.cod_flia = "+request.getParameter("art_familia");
		familia = request.getParameter("art_familia");
	}
	if (request.getParameter("art_clase") != null && !request.getParameter("art_clase").equals(""))
	{
		appendFilter += " and a.cod_clase = "+request.getParameter("art_clase");
		clase = request.getParameter("art_clase");
	}
	if (request.getParameter("cod_articulo") != null && !request.getParameter("cod_articulo").equals(""))
	{
		appendFilter += " and a.cod_articulo = "+request.getParameter("cod_articulo");
		articulo = request.getParameter("cod_articulo");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	}
	if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("C")){
	  appendFilter2 = " and a.cod_barra is not null";
	  tipo = request.getParameter("tipo");
	}
	
	System.out.println(" thebrain: >>>>>>>>>>>>>>>>>>>> TIPO = "+tipo+" appendFilter2 = "+appendFilter2);
	
	sql = "select a.cod_articulo, a.cod_clase, a.cod_subclase, a.cod_flia, a.descripcion art_Desc, a.cod_barra from tbl_inv_articulo a where a.estado = 'A' and a.compania = "+compania+appendFilter+appendFilter2+" order by a.cod_flia, a.cod_clase, a.cod_articulo, a.descripcion";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sql+")");

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
document.title = 'Inventario - '+document.title;
</script>
<jsp:include page="../common/inc_func_cod_barra.jsp" flush="true">
<jsp:param name="msgMenor8Car" value="El código de barra es menor a <%=minCarBarCode%> carácteres!"></jsp:param>
<jsp:param name="msgMismoCod" value="Esta tratando de guardar el mismo código!"></jsp:param>
<jsp:param name="msgCBExiste" value="El codigo de barra ya está registrado para otro articulo!"></jsp:param>
<jsp:param name="dispBarCode" value="n"></jsp:param>
<jsp:param name="substrType" value="01"></jsp:param>
</jsp:include>

<script>
$(document).on("keypress", ":input:not(textarea)", function(event) {
    return event.keyCode != 13;
});
</script>
<style type="text/css">
.alert{border: #ca0616 2px solid; font-weight:bold; font-size:13px; padding:2px 10px; 2px 0}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ÁRTICULOS - ACTUALIZACIÓN DE CÓDIGOS DE BARRA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>

<!-- =====================   S E A R C H   E N G I N E S   S T A R T   H E R E   ===================== -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">

			    <% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("codAlmacen",""+codAlmacen)%>
				<%=fb.hidden("codProveedor",""+codProveedor)%>
				<%=fb.hidden("alSize",""+al.size())%>
				<%//=fb.hidden("tipo",tipo)%>
				<td width="15%">
					Familia
					<%=fb.intBox("art_familia",familia,false,false,false,15)%>
				</td>
				<td width="15%">
					Clase
					<%=fb.intBox("art_clase",clase,false,false,false,15)%>
				</td>
				<td width="15%">
					Art&iacute;culo
					<%=fb.intBox("cod_articulo","",false,false,false,15)%>
				</td>
				<td width="25%">
					Tipo:<%=fb.select("tipo","S=SIN CÓDIGO BARRA,C=CON CÓDIGO BARRA",tipo)%>
				</td>
				<td width="35%">
					Descripci&oacute;n
					<%=fb.textBox("descripcion","",false,false,false,20)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("codAlmacen",""+codAlmacen)%>
				<%=fb.hidden("art_familia",""+familia)%>
				<%=fb.hidden("art_clase",""+clase)%>
				<%=fb.hidden("cod_articulo",""+articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("codProveedor",""+codProveedor)%>
				<%=fb.hidden("alSize",""+al.size())%>
				<%=fb.hidden("tipo",tipo)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("codAlmacen",""+codAlmacen)%>
				<%=fb.hidden("art_familia",""+familia)%>
				<%=fb.hidden("art_clase",""+clase)%>
				<%=fb.hidden("cod_articulo",""+articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("codProveedor",""+codProveedor)%>
				<%=fb.hidden("alSize",""+al.size())%>
				<%=fb.hidden("tipo",tipo)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
			<tr>
				<td class="alert" colspan="4" align="right">
				  [Advertencia] : Se guadar&aacute; el C&oacute;digo de barra autom&aacute;ticamente, después de quitar el puntero
				</td>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<%fb = new FormBean("articles",request.getContextPath()+request.getServletPath(),"post","");%>
		<%=fb.formStart()%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("id",id)%>
		<%=fb.hidden("fp",""+fp)%>
		<%=fb.hidden("codAlmacen",""+codAlmacen)%>
		<%=fb.hidden("alSize",""+al.size())%>
		<%=fb.hidden("baction","")%>
    </tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder" colspan="2">

<!-- ==========================   R E S U L T S   S T A R T   H E R E   ============================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="20%" align="center" colspan="4">C&oacute;digo</td>
					<td width="51%" align="center" rowspan="2">Descripci&oacute;n</td>
					<td width="33%" align="center" rowspan="2">C&oacute;digo barra</td>
				</tr>
				<tr class="TextHeader">
					<td width="6%" align="center">Familia</td>
					<td width="6%" align="center">Clase</td>
					<td width="6%" align="center">subClase</td>
					<td width="8%" align="center">Art&iacute;culo</td>
				</tr>
			<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";


			%>
					<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
					<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
					<%=fb.hidden("cod_subclase"+i,cdo.getColValue("cod_subclase"))%>
					<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
					<%=fb.hidden("art_desc"+i,cdo.getColValue("art_desc"))%>
					<%=fb.hidden("cod_barra"+i,cdo.getColValue("cod_barra"))%>
					
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("cod_flia")%></td>
			<td><%=cdo.getColValue("cod_clase")%></td>
			<td><%=cdo.getColValue("cod_subclase")%></td>
			<td><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("art_desc")%></td>
			<td>
			  <table>
			    <tr>
				   <td>
				       <%=fb.textBox("barCode"+i,cdo.getColValue("cod_barra"),false, false, false,20, Integer.parseInt(maxCharBarCode), null, null, "onChange=\"doUpdateBC("+i+",this)\"", "Código de barra", false, "tabindex="+(i+1)+"")%>
					   <%=fb.hidden("oldBarCode"+i,""+cdo.getColValue("cod_barra")) %>   
			  	       <%=fb.hidden("barCodeExists"+i,(cdo.getColValue("cod_barra")!=null && !cdo.getColValue("cod_barra").equals("")?"y":"n") ) %>
				   </td>
				   <td>
				     <span style="display:;" id="saving<%=i%>">&nbsp;</span>
				   </td>
				</tr>
			  </table>
			</td>
		</tr>
<%
}
if(al.size()==0){
%>
		<tr><td align="center" colspan="6">No registros encontrados.</td></tr>
<%}%>
		</table>

<!-- ============================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>

<tr>
   <td align="right" class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
      <%//fb.appendJsValidation("alert('Validation'); return false;");%>
      <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
</td>
</tr>
<%=fb.formEnd(true)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("codAlmacen",""+codAlmacen)%>
				<%=fb.hidden("art_familia",""+familia)%>
				<%=fb.hidden("art_clase",""+clase)%>
				<%=fb.hidden("cod_articulo",""+articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("codProveedor",""+codProveedor)%>
				<%=fb.hidden("alSize",""+al.size())%>
				<%=fb.hidden("tipo",tipo)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",""+fp)%>
				<%=fb.hidden("codAlmacen",""+codAlmacen)%>
				<%=fb.hidden("art_familia",""+familia)%>
				<%=fb.hidden("art_clase",""+clase)%>
				<%=fb.hidden("cod_articulo",""+articulo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("codProveedor",""+codProveedor)%>
				<%=fb.hidden("alSize",""+al.size())%>
				<%=fb.hidden("tipo",tipo)%>
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
else
{
    System.out.println("thebrain =====================POST=====================");

	int alSize = Integer.parseInt(request.getParameter("alSize"));
	ArrayList alBC = new ArrayList();
    CommonDataObject cdoBC = new CommonDataObject();
    String codArticulo = "", codClase = "", codFlia = ""; 
    String baction = request.getParameter("baction");
	String errCode 	= "", errMsg = "";	

System.out.println("thebrain =====================IF BACTION = GUARDAR=====================");
	
	if (alSize > 0){
	
	System.out.println("thebrain =====================ALSIZE >0 =====================");
	   
	  for (int i = 0; i<alSize; i++){
	  
	      if (request.getParameter("barCode"+i) != null && !request.getParameter("barCode"+i).equals("")){
		  
		      codArticulo = request.getParameter("cod_articulo"+i);
			  codClase = request.getParameter("cod_clase"+i);
			  codFlia = request.getParameter("cod_flia"+i);
			  
			  cdoBC = new CommonDataObject();
			  
			  cdoBC.setTableName("tbl_inv_articulo");
			  cdoBC.addColValue("cod_barra",request.getParameter("barCode"+i));
			  cdoBC.setWhereClause(" cod_articuo = "+codArticulo+" and cod_flia = "+codFlia+" and cod_clase = "+codClase+" ");
			  
			  System.out.println("thebrain ===================== UPDATING  ====================="+i+" "+codArticulo);
			  
			  alBC.add(cdoBC);
		  }
		  
	  }//for
	  
	  if (alBC.size() == 0){
	      cdoBC.setTableName("tbl_inv_articulo");
		  cdoBC.setWhereClause("cod_articulo is null");
		  alBC.add(cdoBC);
	  }
	  if (baction != null && baction.equals("Guardar")){
		  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		  SQLMgr.updateList(alBC);
		  ConMgr.clearAppCtx(null);
		  errCode = SQLMgr.getErrCode();
		  errMsg = SQLMgr.getErrMsg();
	 }
}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	
	<%if (SQLMgr.getErrCode().equals("1")){%>
		window.location = '<%=request.getContextPath()+request.getServletPath()%>';
	<%} else throw new Exception(SQLMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
