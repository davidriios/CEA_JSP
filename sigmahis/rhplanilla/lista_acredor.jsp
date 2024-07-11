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
<jsp:useBean id="vDesc" scope="session" class="java.util.Vector"/>

<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alcentro = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String empId = request.getParameter("empId");
String codeField = request.getParameter("codeField");
String descField = request.getParameter("descField");
String codeEmp = request.getParameter("code");
String index = request.getParameter("index");

if (codeEmp == null) codeEmp= "";
if (fp == null) fp = "default";

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

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(a.cod_acreedor) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo = request.getParameter("codigo");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");  
  }


  if (fp.equalsIgnoreCase("empleado_desc")) sql="select a.cod_acreedor as codigo, a.nombre, b.nombre grupo, b.cod_grupo  from tbl_pla_acreedor a, tbl_pla_grupo_descuento b  where a.compania ="+(String) session.getAttribute("_companyId")+" and ( (a.cod_acreedor = 87 and b.cod_grupo = 11)  or (a.cod_acreedor =86 and b.cod_grupo in (12,21))) order by a.nombre, a.nombre"; // appendFilter +=" and cod_acreedor in (86,87) ";
  else  if (fp.equalsIgnoreCase("descAjuste")) sql="select a.nombre ,d.cod_acreedor codigo,d.num_descuento num_descto,g.nombre grupo,d.cod_grupo cod_grupo,d.autoriza_descto_cia,d.autoriza_descto_anio,d.autoriza_descto_codigo from tbl_pla_descuento d,tbl_pla_acreedor a,tbl_pla_grupo_descuento g where a.cod_acreedor = d.cod_acreedor and  a.compania = d.cod_compania and  g.cod_grupo = d.cod_grupo and  d.emp_id = "+empId+" and  d.cod_compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.estado = 'D'";
  else  sql="select cod_acreedor as codigo, nombre from tbl_pla_acreedor where compania ="+(String) session.getAttribute("_companyId")+appendFilter+" order by nombre"; 

  alcentro = SQLMgr.getDataList(sql);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
document.title = 'Lista de Acreedores - '+document.title;

function returnValue(k)
{

var code = eval('document.form.codigo'+k).value ;
var name = eval('document.form.nombre'+k).value ;

<%if (fp.equalsIgnoreCase("descuento")){%>
if (eval('window.opener.document.form1.codigo'+k)) eval('window.opener.document.form1.<%=codeField%>').value = eval('window.opener.document.form1.codigo'+k);
if (eval('window.opener.document.form1.nombre'+k)) eval('window.opener.document.form1.<%=descField%>').value = eval('window.opener.document.form1.nombre'+k);
 window.opener.location = '../rhplanilla/reg_autoriza_descuento.jsp?mode=edit&empId=<%=empId%>';

window.close();
<%}else if (fp.equalsIgnoreCase("descAjuste")){%>

eval('window.opener.document.form1.cod_acreedor<%=index%>').value = eval('document.form.codigo'+k).value;
eval('window.opener.document.form1.descAcreedor<%=index%>').value = eval('document.form.nombre'+k).value;
eval('window.opener.document.form1.cod_grupo<%=index%>').value = eval('document.form.cod_grupo'+k).value;
eval('window.opener.document.form1.descGrupo<%=index%>').value = eval('document.form.grupo'+k).value;

eval('window.opener.document.form1.num_descuento<%=index%>').value = eval('document.form.num_descto'+k).value;
eval('window.opener.document.form1.autoriza_descto_cia<%=index%>').value = eval('document.form.autoriza_descto_cia'+k).value;
eval('window.opener.document.form1.autoriza_descto_anio<%=index%>').value = eval('document.form.autoriza_descto_anio'+k).value;
eval('window.opener.document.form1.autoriza_descto_codigo<%=index%>').value = eval('document.form.autoriza_descto_codigo'+k).value;

window.close();
<%}else {%>

 var grupo = eval('document.form.grupo'+k).value ;
 var cod_grupo = eval('document.form.cod_grupo'+k).value ;
 var compania = <%=session.getAttribute("_companyId")%>;
 if(compania != 6){
  var descuentos = splitRowsCols(getDBData('<%=request.getContextPath()%>','a.estado,a.anio,a.codigo,a.num_descuento,getPlaValidaCierre2 valida','tbl_pla_autoriza_desc_enc a,(select b.emp_id, b.cod_compania, b.cod_acreedor,max(to_number(to_char(b.anio, \'FM0009\')||to_char(b.codigo,\'FM000009\'))) maximo_sec from tbl_pla_autoriza_desc_enc b where b.cod_compania ='+compania+' and b.cod_acreedor = '+code+' and b.estado not in (\'R\',\'N\') group by b.emp_id,b.cod_compania, b.cod_acreedor) c','  a.cod_compania ='+compania+' and a.emp_id =<%=empId%> and a.cod_acreedor ='+code+' and a.estado not in (\'R\',\'N\') and (c.emp_id = a.emp_id and c.cod_compania = a.cod_compania and c.cod_acreedor = a.cod_acreedor  and c.maximo_sec = (to_number(to_char(a.anio,\'FM0009\')||to_char(a.codigo,\'FM000009\'))))',''));

 if (descuentos != null && descuentos.length != 0)
 {
	 var estado 	 = descuentos[0][0];
	 var anio 		 = descuentos[0][1];
	 var codigo		 = descuentos[0][2];
	 var noDescuento = descuentos[0][3];
	 var v_valido    = descuentos[0][4];

		if(estado  == null || estado =='' )
		{	//no existen autorizaciones pendientes, aprobadas o en descuento
			window.opener.document.form1.cod_acreedor.value = code;
			window.opener.document.form1.acredorName.value = name;
			window.opener.document.form1.cod_grupo.value = cod_grupo;
			window.opener.document.form1.descGrupo.value = grupo;
			window.close();
		}
		else if (estado == 'C'){
			window.opener.document.form1.numDescuento.value = noDescuento;
			window.opener.document.form1.cod_acreedor.value = code;
			window.opener.document.form1.acredorName.value = name;
			window.opener.document.form1.cod_grupo.value = cod_grupo;
			window.opener.document.form1.descGrupo.value = grupo;
			window.close();
		}
		else if (estado == 'P'){
	alert('Este colaborador tiene registrada una autorización la cual está en estado PENDIENTE,\n- no está permitido registrar otra por lo que debe trabajar sobre la ya existente!!');
					 window.opener.location = '../rhplanilla/reg_autoriza_descuento.jsp?fg=ED&mode=edit&empId=<%=empId%>&anio='+anio+'&codigo='+codigo;
		}
		else if (estado == 'A'){
				alert('Este colaborador tiene registrada una autorización la cual está en estado APROBADA,\n- No está permitido registrar otra, debe solicita a PLANILLA la anulación de la autorización!!');}
				else if (estado == 'E')
				{
					if(v_valido != null && v_valido !='')
					{
						alert(v_valido);
						//alert('El empleado tiene actualmente una autorización activa,  por seguridad no está permitido registrar reemplazos luego del cierre de planilla');
					}
					else
					{
						if( confirm('Este colaborador tiene registrada una autorización la cual está en DESCUENTO, será reemplazada esta nueva autorización?'))
						{
							 window.opener.location = '../rhplanilla/reg_autoriza_descuento.jsp?fg=RAD&mode=add&empId=<%=empId%>&anio='+anio+'&codigo='+codigo;
						}
					}
				}

	 }else{
		window.opener.document.form1.cod_acreedor.value = code;
		window.opener.document.form1.acredorName.value = name;
		window.opener.document.form1.cod_grupo.value = cod_grupo;
		window.opener.document.form1.descGrupo.value = grupo;
		window.close();
	 }
 }
 else
 {
	window.opener.document.form1.cod_acreedor.value = code;
	window.opener.document.form1.acredorName.value = name;
	window.opener.document.form1.cod_grupo.value = cod_grupo;
	window.opener.document.form1.descGrupo.value = grupo;
	window.close();
 }
<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<%--<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>--%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - LISTA DE ACREEDORES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">

	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
				<%=fb.hidden("codeField",codeField)%>
				<%=fb.hidden("descField",descField)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("empId",empId)%>
				
				<td width="50%">&nbsp;C&oacute;digo
							<%=fb.textBox("codigo",codigo,false,false,false,30,null,null,null)%>
				<td width="50%">&nbsp;Descripci&oacute;n
							<%=fb.textBox("nombre",nombre,false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%>	</td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("empId",empId)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
					%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="acr">
<%fb = new FormBean("form",request.getContextPath()+"/common/urlRedirect.jsp");%>

	<%=fb.formStart(true)%>
	<tr class="TextHeader">
	  	<td width="5%">&nbsp;</td>
	  	<%if (fp.equalsIgnoreCase("empleado_desc")||fp.equalsIgnoreCase("descAjuste")) {%>
			<td width="10%">&nbsp;C&oacute;digo</td>
			<td width="50%">&nbsp;Nombre</td>
			<td width="5%">&nbsp;C&oacute;digo</td>
			<td width="30%">&nbsp;Tipo Descuento</td>
	  	<%} else {%>
			<td width="15%">&nbsp;C&oacute;digo</td>
			<td width="75%">&nbsp;Nombre</td>
		<%}%>
	</tr>
	<%
				for (int i=0; i<alcentro.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) alcentro.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
                <%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
                <%=fb.hidden("cod_grupo"+i,cdo.getColValue("cod_grupo"))%>
				<%=fb.hidden("grupo"+i,cdo.getColValue("grupo"))%>
				<%=fb.hidden("num_descto"+i,cdo.getColValue("num_descto"))%>
				<%=fb.hidden("autoriza_descto_cia"+i,cdo.getColValue("autoriza_descto_cia"))%>
				<%=fb.hidden("autoriza_descto_anio"+i,cdo.getColValue("autoriza_descto_anio"))%>
				<%=fb.hidden("autoriza_descto_codigo"+i,cdo.getColValue("autoriza_descto_codigo"))%>
				
				
				<%if (fp.equalsIgnoreCase("descAjuste") && vDesc.contains(cdo.getColValue("codigo")+"-"+cdo.getColValue("cod_grupo"))) {%>
				<tr class="GreenTextBold" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"  style="cursor:pointer">			
				<%}else{%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue('<%=i%>')" style="cursor:pointer">
				<%}%>
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<%if (fp.equalsIgnoreCase("empleado_desc")||fp.equalsIgnoreCase("descAjuste")) {%>
					<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td>&nbsp;<%=cdo.getColValue("cod_grupo")%></td>
					<td>&nbsp;<%=cdo.getColValue("grupo")%><%if (fp.equalsIgnoreCase("descAjuste") && vDesc.contains(cdo.getColValue("codigo")+"-"+cdo.getColValue("cod_grupo"))) {%>&nbsp;&nbsp;&nbsp;YA ESTÁ ELEGIDO <%}%></td>
					<%} else {%>
					<td>&nbsp;<%=cdo.getColValue("codigo")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<%}%>
					
				</tr>
				<%
				}
		%>
 <%=fb.formEnd(true)%>
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
				fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("empId",empId)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
					%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("empId",empId)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
				<tr>
					<td colspan="4" align="right"> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
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