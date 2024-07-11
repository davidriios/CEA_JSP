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
<jsp:useBean id="iSoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSoc" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su descripcion de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400005") || SecMgr.checkAccess(session.getId(),"400006") || SecMgr.checkAccess(session.getId(),"400007") || SecMgr.checkAccess(session.getId(),"400008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");

String seccion = request.getParameter("seccion");
String cod_pac = request.getParameter("cod_pac");
String secuencia = request.getParameter("secuencia"); 
String fec_nacimiento = request.getParameter("fec_nacimiento"); 
String pac_id = request.getParameter("pac_id");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String index = request.getParameter("index");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String icd10 = request.getParameter("icd10");
String icdVersion = request.getParameter("icdVersion");
int espLastLineNo = 0;
int socLastLineNo = 0;
int ubiLastLineNo = 0;
if (icdVersion == null) icdVersion = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("espLastLineNo") != null) espLastLineNo = Integer.parseInt(request.getParameter("espLastLineNo"));
if (request.getParameter("socLastLineNo") != null) socLastLineNo = Integer.parseInt(request.getParameter("socLastLineNo"));
if (request.getParameter("ubiLastLineNo") != null) ubiLastLineNo = Integer.parseInt(request.getParameter("ubiLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";
if (codigo == null) codigo = "";
if (descripcion == null) descripcion = "";
if (icd10 == null) icd10 = "";

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
    CommonDataObject v = new CommonDataObject();
   if(request.getParameter("pacId")!=null &&  !request.getParameter("pacId").trim().equals(""))
   {
	sbSql.append("select nvl(max((select icd_version from tbl_adm_empresa where codigo = z.empresa)),-1) as icd_version from tbl_adm_beneficios_x_admision z where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and nvl(estado,'A') = 'A'");
	  v = SQLMgr.getData(sbSql);
  }
  else{   v = new CommonDataObject(); v.addColValue("icd_version","-1");};
  if (v.getColValue("icd_version").equals("-1") && !icdVersion.trim().equals("")) {
		sbFilter.append(" and (");
		//if (icdVersion.equals("10")) sbFilter.append(" (z.icd_version = 9 and y.codigo_icd10 is not null) or ");
		sbFilter.append("z.icd_version = ");
		sbFilter.append(icdVersion);
		sbFilter.append(")");
	} else if (!v.getColValue("icd_version").equals("-1")) {
		icdVersion = v.getColValue("icd_version");
	}
	
	sbSql = new StringBuffer();
  if(!codigo.trim().equals("")) { sbFilter.append(" and upper(z.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'");}
  if(!descripcion.trim().equals("")){sbFilter.append(" and upper(coalesce(z.observacion,z.nombre)) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'");}
  if(!icd10.trim().equals("")) { sbFilter.append(" and upper(y.codigo_icd10) like '%"); sbFilter.append(icd10.toUpperCase()); sbFilter.append("%'");}

	sbSql.append("select z.codigo, coalesce(z.observacion,z.nombre) as nombre, nvl(y.codigo_icd10,' ') as icd10, z.icd_version as icdVersion from tbl_cds_diagnostico z, tbl_cds_diagnostico_icd10map y where z.codigo = y.codigo_icd09(+)");
	sbSql.append(sbFilter);
	sbSql.append(" order by 2,1,3");

	if (request.getParameter("codigo") != null) {

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Diagnosticos - '+document.title;
</script>
<script language="javascript" >
function setLab(k){
	var id = document.empresa.id.value;
	<%if(fp.equals("cargo_oc")){%>
	 eval('window.opener.document.form0.diag_hna'+id).value = eval('document.empresa.codigo'+k).value;
	<%} else if(fp.trim().equals("HC")){%>//Hospitalizacion y cirugias, Eval. Preanestesia
		window.opener.document.form0.codRegistro<%=index%>.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descRegistro<%=index%>.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	<% }else if(fp.trim().equals("protocolo")){%>
	 	window.opener.document.form0.codDiagPre.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descDiagPre.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	 <% }else if(fp.trim().equals("protocoloPost")){%>
	 	window.opener.document.form0.diagPost.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descDiagPost.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	 <%}else if(fp.trim().equals("informes")){%>
	 	window.opener.document.form0.codDiagPre.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descDiagPre.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("notas_enf") || fp.trim().equals("pUniversal")){%>
	 	window.opener.document.form0.codDiag.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descDiag.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("eval_gineco_parto")){%>
	 	if(window.opener.document.form0.diag) window.opener.document.form0.diag.value = eval('document.empresa.codigo'+k).value;
 	 	if(window.opener.document.form0.diag_desc) window.opener.document.form0.diag_desc.value = eval('document.empresa.descripcion'+k).value;  
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("proc_y_cirugia_ambu")){%>
	 	if(window.opener.document.form0.diag) window.opener.document.form0.diag.value = eval('document.empresa.codigo'+k).value;
 	 	if(window.opener.document.form0.diag_desc) window.opener.document.form0.diag_desc.value = eval('document.empresa.descripcion'+k).value;  
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("hist_cli_pre_ope")){%>
	 	if(window.opener.document.form0.diag) window.opener.document.form0.diag.value = eval('document.empresa.codigo'+k).value;
 	 	if(window.opener.document.form0.diag_desc) window.opener.document.form0.diag_desc.value = eval('document.empresa.descripcion'+k).value;  
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("sumario_egreso_med_neo")){%>
	 	if(window.opener.document.form0.diag_ingreso) window.opener.document.form0.diag_ingreso.value = eval('document.empresa.codigo'+k).value;
 	 	if(window.opener.document.form0.diag_ingreso_desc) window.opener.document.form0.diag_ingreso_desc.value = eval('document.empresa.descripcion'+k).value;  
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("rDiag")){%>
	 	window.opener.document.form0.cpt.value         = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form0.descripcion.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;  
	  <%}else if(fp.trim().equals("rondas")){%>
	 	if(window.opener.document.form0.diagnostico<%=index%>)window.opener.document.form0.diagnostico<%=index%>.value = eval('document.empresa.codigo'+k).value;
 	 	if(window.opener.document.form0.diagnostico_desc<%=index%>)window.opener.document.form0.diagnostico_desc<%=index%>.value = eval('document.empresa.descripcion'+k).value;  
		if(window.opener.document.form0.icdVersion)window.opener.document.form0.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form0.icd10)window.opener.document.form0.icd10.value = eval('document.empresa.icd10'+k).value;
	  <%}else if(fp.trim().equals("addDxSalida")){%>
	  
	  if(hasDBData('<%=request.getContextPath()%>','tbl_adm_diagnostico_x_admision','pac_id=<%=pacId%> and admision=<%=noAdmision%> and tipo=\'S\' and diagnostico=\''+eval('document.empresa.codigo'+k).value+'\'','')){
				alert('El diagnostico seleccionado ya existe para este paciente.\n- Verifique su Prioridad, en la Seccion Diasgnotico de Salida!. \n- Solo debe existir un diagnostico con prioridad (1)');
				
		if(confirm('Desea Continuar con la seleccion ?')){		
	 	window.opener.document.form001.dx_id.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form001.dx_descripcion.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form001.version)window.opener.document.form001.version.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form001.icd10)window.opener.document.form001.icd10.value = eval('document.empresa.icd10'+k).value;
		window.close();
		}
		}else{window.opener.document.form001.dx_id.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form001.dx_descripcion.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form001.version)window.opener.document.form001.version.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form001.icd10)window.opener.document.form001.icd10.value = eval('document.empresa.icd10'+k).value;
		 window.close();}
	 <%}else{%>
	 	window.opener.document.form001.dx_id.value = eval('document.empresa.codigo'+k).value;
 	 	window.opener.document.form001.dx_descripcion.value = eval('document.empresa.descripcion'+k).value;
		if(window.opener.document.form001.icdVersion)window.opener.document.form001.icdVersion.value = eval('document.empresa.icdVersion'+k).value;
		if(window.opener.document.form001.icd10)window.opener.document.form001.icd10.value = eval('document.empresa.icd10'+k).value;
	 <%}%>
	  <%if(!fp.trim().equals("addDxSalida")){%>
	 window.close();
	 <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DIAGNOSTICOS"></jsp:param>
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
					<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
					<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
					<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("pacId",pacId)%>
					<%=fb.hidden("noAdmision",noAdmision)%>					
					<td width="30%"><cellbytelabel>ICD<%=(v.getColValue("icd_version").equals("-1"))?fb.select("icdVersion","9,10",icdVersion,false,false,0,null,null,null,null,"T"):fb.hidden("icdVersion",icdVersion)%></cellbytelabel>
					
					<cellbytelabel>ICD09</cellbytelabel><%=fb.textBox("codigo","",false,false,false,20)%></td>
					<td width="30%"><cellbytelabel>ICD10</cellbytelabel><%=fb.textBox("icd10","",false,false,false,20)%></td>
					<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel><%=fb.textBox("descripcion","",false,false,false,40)%>	<%=fb.submit("go","Ir")%>	</td>
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
fb = new FormBean("empresa",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("espLastLineNo",""+espLastLineNo)%>
<%=fb.hidden("socLastLineNo",""+socLastLineNo)%>
<%=fb.hidden("ubiLastLineNo",""+ubiLastLineNo)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",""+codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>	
<%=fb.hidden("icd10",icd10)%>
<%=fb.hidden("icdVersion",icdVersion)%>	
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<td width="15%"><cellbytelabel>ICD09</cellbytelabel></td>
<td width="15%"><cellbytelabel>ICD10</cellbytelabel></td>
<td width="70%"><cellbytelabel>descripcion</cellbytelabel></td>
</tr>				
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("icd10"+i,cdo.getColValue("icd10"))%>
				<%=fb.hidden("icdVersion"+i,cdo.getColValue("icdVersion"))%>
				<tr class="<%=color%>" onClick="javascript:setLab(<%=i%>)" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
					<td align="right"><%=cdo.getColValue("codigo")%></td>
					<td align="right"><%=cdo.getColValue("icd10")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
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
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
{

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValsearchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&fp="+request.getParameter("fp")+"&index="+request.getParameter("index")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&pacId="+request.getParameter("pacId=")+"&noAdmision="+request.getParameter("noAdmision")+"&icd10="+request.getParameter("icd10")); 

		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&espLastLineNo="+espLastLineNo+"&socLastLineNo="+socLastLineNo+"&ubiLastLineNo="+ubiLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValsearchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&fp="+request.getParameter("fp")+"&index="+request.getParameter("index")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion")+"&pacId="+request.getParameter("pacId=")+"&noAdmision="+request.getParameter("noAdmision")+"&icd10="+request.getParameter("icd10"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("medico"))
	{
%>
	window.opener.location = '../expediente/exp_examenes_laboratorio.jsp?mode=<%=mode%>&id_lab=<%=id%>&espLastLineNo=<%=espLastLineNo%>&socLastLineNo=<%=socLastLineNo%>&ubiLastLineNo=<%=ubiLastLineNo%>';
<%
	}
%>
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