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
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String index = request.getParameter("index");
String cod_honorario = request.getParameter("cod_honorario");
String ref_type = request.getParameter("ref_type");
String tipo_ref="";
if(cod_honorario==null)cod_honorario="";
if(ref_type==null)ref_type="";

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
  String codigo="",paciente="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(f.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("paciente") != null  && !request.getParameter("paciente").trim().equals(""))
  {
     appendFilter += " and upper(m.nombre_paciente) like '%"+request.getParameter("paciente").toUpperCase()+"%'";
		 
    paciente = request.getParameter("paciente");
  }
if(request.getParameter("codigo") != null){

 if(ref_type.trim().equals("H")){tipo_ref="M"; appendFilter += " and nvl(getsaldoFactHon(f.compania,'"+cod_honorario+"','M',f.codigo),0)  <> 0"; /*appendFilter += " and det.medico= '"+cod_honorario+"'";*/}
 else  if(ref_type.trim().equals("E")){tipo_ref="E";appendFilter += " and nvl(getsaldoFactHon(f.compania,'"+cod_honorario+"','E',f.codigo),0)  <> 0"; /*appendFilter += " and det.med_empresa ="+cod_honorario;*/}

sql="select e.nombre as emp_nombre,m.nombre_paciente as pac_nombre,decode(f.facturar_a,'P', 'PACIENTE', 'E','EMPRESA', 'O','OTROS') as fact_a, f.codigo,  coalesce(e.nombre, m.nombre_paciente)as descripcion,nvl(getsaldoFactHon(f.compania,'"+cod_honorario+"','"+tipo_ref+"',f.codigo),0) as saldo  from tbl_fac_factura f,tbl_adm_empresa e,vw_adm_paciente m /*,tbl_fac_detalle_factura det*/  where facturar_a<>'O' and f.cod_empresa= e.codigo(+) and f.pac_id= m.pac_id(+) and f.estatus <> 'A' /* and f.compania = det.compania and f.codigo = det.fac_codigo and det.centro_servicio =0*/ and f.compania = "+(String) session.getAttribute("_companyId")+appendFilter;

sql +=" union all select 'SALDO INICAL' as emp_nombre,'SALDO INICIAL' as pac_nombre,'S/I' as fact_a, 'S/I',  'SALDO INICIAL AL INICIAR SISTEMA'as descripcion,nvl(getsaldoFactHon(1,id_cliente,tipo_cliente,'S/I'),0) as saldo  from tbl_cxc_saldo_inicial s where id_cliente ='"+cod_honorario+"' and nvl(getsaldoFactHon(1,id_cliente,tipo_cliente,'S/I'),0)<> 0 and tipo_cliente = "+((ref_type.trim().equals("H"))?"'M'":"'S' ");  
	


al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
   rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Facturas - '+document.title;
function returnValue(k)
{
<%if(fp != null && (fp.trim().equals("notas")||fp.trim().equals("notasEnc"))){%>
window.opener.document.form0.factura.value = eval('document.form0.codigo'+k).value;
<%}else if(fp.trim().equals("ajuste_cxp")){%>
if(eval('document.form0.saldo'+k).value !=0){
	window.opener.document.form1.numero_factura.value = eval('document.form0.codigo'+k).value;
	//window.opener.document.form1.monto.value = eval('document.form0.saldo'+k).value;
	if(window.opener.document.form1.montoFact)window.opener.document.form1.montoFact.value = eval('document.form0.saldo'+k).value;
	}
	else alert('LA FACTURA SELECCIONADA NO TIENE SALDO PENDIENTE');
<%}else{%>
window.opener.document.form1.factura<%=index%>.value = eval('document.form0.codigo'+k).value;
				
if(eval('document.form0.paciente'+k).value != "")
window.opener.document.form1.paciente<%=index%>.value=eval('document.form0.paciente'+k).value;
if(eval('document.form0.amision'+k).value != "")
window.opener.document.form1.amision<%=index%>.value=eval('document.form0.amision'+k).value;
if(eval('document.form0.fecha_nacimiento'+k).value != "")
window.opener.document.form1.fecha_nacimiento<%=index%>.value=eval('document.form0.fecha_nacimiento'+k).value;
if(eval('document.form0.pac_id'+k).value != "")
window.opener.document.form1.pac_id<%=index%>.value=eval('document.form0.pac_id'+k).value;
<%}%>
window.close();		
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("cod_honorario",cod_honorario)%>
				<%=fb.hidden("ref_type",ref_type)%>
				<td width="50%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel>
							<%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
				</td>
				<td width="50%">&nbsp;<cellbytelabel>Paciente</cellbytelabel>
							<%=fb.textBox("paciente","",false,false,false,30,null,null,null)%>
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
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("cod_honorario",cod_honorario)%>
					<%=fb.hidden("ref_type",ref_type)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("cod_honorario",cod_honorario)%>
					<%=fb.hidden("ref_type",ref_type)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="dirc">
	<tr class="TextHeader">
	  <td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
	  <td width="20%">&nbsp;<cellbytelabel>Facturar a</cellbytelabel> </td>	
	  <td width="30%">&nbsp;<cellbytelabel>Empresa/Paciente</cellbytelabel> </td>	
	  <td width="25%">&nbsp;<cellbytelabel>Paciente</cellbytelabel> </td>
	  <td width="15%">&nbsp;<cellbytelabel>Monto</cellbytelabel> </td>
	</tr>
	<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	
%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
	<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
	<%=fb.hidden("fact_a"+i,cdo.getColValue("fact_a"))%>
	<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
	<%=fb.hidden("paciente"+i,cdo.getColValue("paciente"))%>
	<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
	<%=fb.hidden("amision"+i,cdo.getColValue("admision"))%>
	<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>	
	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer">
		<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
		<td>&nbsp;<%=cdo.getColValue("fact_a")%></td>
		<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
		<td>&nbsp;<%=cdo.getColValue("pac_nombre")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%></td><!---->
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
					<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("cod_honorario",cod_honorario)%>
					<%=fb.hidden("ref_type",ref_type)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("paciente",paciente)%>
					<%=fb.hidden("cod_honorario",cod_honorario)%>
					<%=fb.hidden("ref_type",ref_type)%>
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