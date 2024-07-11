<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alSec = new ArrayList();
ArrayList alTipo = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String seccion = request.getParameter("seccion");
String tipo = request.getParameter("tipo");
String cedula = request.getParameter("cedula");
String nombre = request.getParameter("nombre");
String cDate =  CmnMgr.getCurrentDate("dd/mm/yyyy");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");

if (seccion == null) seccion = "";
if (tipo == null) tipo = "";
if (cedula == null) cedula = "";
if (nombre == null) nombre = "";

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

	sbFilter.append(" and c.estado in ('T','A')");
	if (!seccion.trim().equals("")) { sbFilter.append(" and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = "); sbFilter.append(seccion); sbFilter.append(""); }
	if (!tipo.trim().equals("")) { sbFilter.append(" and c.tipo_accion = "); sbFilter.append(tipo); sbFilter.append(""); }
	if (!cedula.trim().equals("")) { sbFilter.append(" and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"); sbFilter.append(cedula.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.primer_nombre||' '||a.primer_apellido) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();
	sbSql.append(" select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.emp_id as empId, a.compania, a.nombre_empleado as nombre, a.primer_nombre, a.primer_apellido, nvl(c.ubic_rhseccion_dest,a.ubic_seccion) as seccion, /*b.descripcion,*/ t.descripcion||' - '||s.descripcion as tipoDesc, c.tipo_accion as tipoAccion, c.sub_t_accion as subAccion, a.num_empleado, c.codigo_estructura, coalesce(c.horario_dest,c.horario,a.horario) as horario, decode(c.tipo_accion,'1','ingreso','2','e','3','e') as fp, decode(c.tipo_accion,'1','INS','2','UPD','3','DEL') as operation, to_char(c.fecha_doc,'dd/mm/yyyy') as fecha_doc, to_char(c.fecha_efectiva,'dd/mm/yyyy') as fecha_efectiva, nvl(c.salario_dest,c.salario) as salario, coalesce(c.gasto_rep_dest,c.gasto_rep,0) as gasto_rep, decode(c.tipo_accion,'1','4','3','3','2',decode(c.sub_t_accion,'1','0','2','1','5','2','3','2')) as tabAccion, to_char(nvl(c.periodo_ini,c.fecha_efectiva),'dd/mm/yyyy') as periodoIni, nvl(c.cargo_insti_dest,c.cargo) as cargo, c.unidad_adm as unidadAdm, t.descripcion as accion, c.estado as estado from vw_pla_empleado a,/* tbl_sec_unidad_ejec b,*/ tbl_pla_ap_accion_per c, tbl_pla_ap_tipo_accion t, tbl_pla_ap_sub_tipo s  where /*a.compania = b.compania and*/ a.emp_id = c.emp_id /*and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo*/ and t.codigo = s.tipo_accion and c.tipo_accion = s.tipo_accion and c.sub_t_accion = s.codigo and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by c.tipo_accion, c.sub_t_accion, a.ubic_seccion, a.primer_apellido");
	al = SQLMgr.getDataList(sbSql.toString());
  rowCount = CmnMgr.getCount("select count(*) from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per c, tbl_pla_ap_tipo_accion t, tbl_pla_ap_sub_tipo s where a.compania = b.compania and a.emp_id = c.emp_id and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo and t.codigo = s.tipo_accion and c.tipo_accion = s.tipo_accion and c.sub_t_accion = s.codigo and a.compania = "+session.getAttribute("_companyId")+sbFilter);

	sbSql = new StringBuffer();
	sbSql.append("select codigo as optValueColumn, descripcion||' - [ '||codigo||' ]' as optLabelColumn from tbl_sec_unidad_ejec where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and nivel = 3 and codigo >= 100 order by 2, 1");
	alSec = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

	sbSql = new StringBuffer();
	sbSql.append("select codigo as optValueColumn, descripcion as optLabelColumn from tbl_pla_ap_tipo_accion order by 2, 1");
	alTipo = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

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
document.title = 'Recursos Humanos - Aprobación de Movilidad - '+document.title;
function printList(){abrir_ventana('../rhplanilla/print_list_accionmove.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function Ver(empId,fp,tipo,tab,subaccion,fecha,fechaEfectiva,i)
{
var fp='';

if(tipo==1)
{
	var prov = eval('document.form0.provincia'+i).value;
	var sigla = eval('document.form0.sigla'+i).value;
	var tomo = eval('document.form0.tomo'+i).value;
	var asiento = eval('document.form0.asiento'+i).value;
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=4&fecha_doc='+fecha+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento);
	fp='ingreso';
	} else if(tipo==2)
	{
	fp='e';

	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=0&fecha_doc='+fecha);
	} else if(tipo==3)
	{
	fp='e';
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=3&fecha_doc='+fecha);
	}
}
function Revisa(empId,fp,tipo,tab,subaccion,fecha,fechaEfectiva,i)
{
var fp='';
if(tipo==1){
	var prov = eval('document.form0.provincia'+i).value;
	var sigla = eval('document.form0.sigla'+i).value;
	var tomo = eval('document.form0.tomo'+i).value;
	var asiento = eval('document.form0.asiento'+i).value;
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&fg=ap&tipo_accion='+tipo+'&mode=edit&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab='+tab+'&fecha_doc='+fecha+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento);
	fp='ingreso';
} else if(tipo==2){
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&fg=ap&tipo_accion='+tipo+'&mode=edit&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=0&fecha_doc='+fecha);
} else if(tipo==3 ) {
	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&fg=ap&tipo_accion='+tipo+'&mode=edit&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab='+tab+'&fecha_doc='+fecha);
}
}

function chkCeroRegisters(){var size = document.form0.size.value;var x=0;for(i=0;i<size;i++){if(eval('document.form0.check'+i) != null && eval('document.form0.check'+i).checked==true){x++;}}if(x>0) return true;else{alert('No existen registros seleccionados!');return false;}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - ACCION DE MOVILIDAD "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<td width="16%">
		Tipo Acci&oacute;n</br>
		<%=fb.select("tipo",alTipo,tipo,false,false,0,"Text10",null,null,null,"T")%>
	</td>
	<td width="40%">
		Secci&oacute;n</br>
		<%=fb.select("seccion",alSec,seccion,false,false,0,"Text10",null,null,null,"T")%>
	</td>
	<td width="15%">
		C&eacute;dula</br>
		<%=fb.textBox("cedula","",false,false,false,15,15,"Text10",null,null)%>
	</td>
	<td width="29%">
		Nombre</br>
		<%=fb.textBox("nombre","",false,false,false,30,30,"Text10",null,null)%>
		<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
	</td>
<%=fb.formEnd()%>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type="0"><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
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
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);	%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>

<tr class="TextPager">
	<td align="right" class="TableLeftBorder TableRightBorder">
		<authtype type="50"><%=fb.submit("save","Aplicar",true,(al.size()>0)?false:true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		<authtype type="7"><%=fb.submit("cancel","Anular",true,(al.size()>0)?false:true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>	</authtype>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ===================   R E S U L T S   S T A R T   H E R E   ==================== -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" >
		<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
			<td width="13%">C&eacute;dula</td>
			<td width="23%">Nombre</td>
			<td width="8%">Fecha Inicio Lab.</td>
			<td width="30%">Descripción de Acci&oacute;n</td>
			<td width="4%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
			<td width="3%"><%=fb.checkbox("check3","",false,(al.size()>0)?false:true,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar Todas!")%>
			</td>
		</tr>
<%
String descripcion = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject codo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("empId"+i,codo.getColValue("empId"))%>
		<%=fb.hidden("tipoAccion"+i,codo.getColValue("tipoAccion"))%>
		<%=fb.hidden("subAccion"+i,codo.getColValue("subAccion"))%>
		<%=fb.hidden("fp"+i,codo.getColValue("fp"))%>
		<%=fb.hidden("tabAccion"+i,codo.getColValue("tabAccion"))%>
		<%=fb.hidden("operation"+i,codo.getColValue("operation"))%>
		<%=fb.hidden("cargo"+i,codo.getColValue("cargo"))%>
		<%=fb.hidden("unidadAdm"+i,codo.getColValue("unidadAdm"))%>
		<%=fb.hidden("seccion"+i,codo.getColValue("seccion"))%>
		<%=fb.hidden("periodoIni"+i,codo.getColValue("periodoIni"))%>
		<%=fb.hidden("provincia"+i,codo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,codo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,codo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,codo.getColValue("asiento"))%>
		<%=fb.hidden("estado"+i,codo.getColValue("estado"))%>
		<%=fb.hidden("fecha"+i,codo.getColValue("fecha_doc"))%>
		<%=fb.hidden("fecha_efectiva"+i,codo.getColValue("fecha_efectiva"))%>
		<%=fb.hidden("num_empleado"+i,codo.getColValue("num_empleado"))%>
		<%=fb.hidden("salario"+i,codo.getColValue("salario"))%>
		<%=fb.hidden("gasto_rep"+i,codo.getColValue("gasto_rep"))%>
		<%=fb.hidden("horario"+i,codo.getColValue("horario"))%>
		<%=fb.hidden("codigo_estructura"+i,codo.getColValue("codigo_estructura"))%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%//=preVal + i%>&nbsp;</td>
			<td><%=codo.getColValue("cedula")%></td>
			<td><%=codo.getColValue("nombre")%></td>
			<td align="center"><%=codo.getColValue("fecha_efectiva")%></td>
			<td><%=codo.getColValue("tipoDesc")%></td>
			<td align="center">&nbsp;<authtype type='1'><a href="javascript:Ver('<%=codo.getColValue("empId")%>','<%=codo.getColValue("fp")%>','<%=codo.getColValue("tipoAccion")%>','<%=codo.getColValue("tabAccion")%>','<%=codo.getColValue("subAccion")%>','<%=codo.getColValue("fecha_doc")%>','<%=codo.getColValue("fecha_efectiva")%>',<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:Revisa('<%=codo.getColValue("empId")%>','<%=codo.getColValue("fp")%>','<%=codo.getColValue("tipoAccion")%>','<%=codo.getColValue("tabAccion")%>','<%=codo.getColValue("subAccion")%>','<%=codo.getColValue("fecha_doc")%>','<%=codo.getColValue("fecha_efectiva")%>',<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Revisar</a></authtype></td>
			<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,null)%></td>
		</tr>
<%}%>
<!-- =====================   R E S U L T S   E N D   H E R E   ==================== -->
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextPager">
	<td align="right" class="TableLeftBorder TableRightBorder">
		&nbsp;
		<authtype type='50'><%=fb.submit("save","Aplicar",true,(al.size()>0)?false:true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		<authtype type='7'><%=fb.submit("cancel","Anular",true,(al.size()>0)?false:true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>	</authtype>
	</td>
</tr>
<%fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");%>
<%=fb.formEnd(true)%>
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
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>

		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("tipo_accion",request.getParameter("tipoAccion"+i));
			cdo.addColValue("sub_t_accion",request.getParameter("subAccion"+i));
			cdo.addColValue("fecha_doc",request.getParameter("fecha"+i));
			cdo.addColValue("emp_id",request.getParameter("empId"+i));
			if (baction.equalsIgnoreCase("Aplicar"))
			{
				cdo.addColValue("fecha_efectiva",request.getParameter("fecha_efectiva"+i));
				cdo.addColValue("cargo",request.getParameter("cargo"+i));
				cdo.addColValue("horario_dest",request.getParameter("horario"+i));
				cdo.addColValue("ubic_rhdepto_dest",request.getParameter("unidadAdm"+i));
				cdo.addColValue("ubic_rhseccion_dest",request.getParameter("seccion"+i));

				//cdo.addColValue("ced_provincia", request.getParameter("provincia"+i));
				//cdo.addColValue("ced_sigla", request.getParameter("sigla"+i));
				//cdo.addColValue("ced_tomo", request.getParameter("tomo"+i));
				//cdo.addColValue("ced_asiento", request.getParameter("asiento"+i));
				//cdo.addColValue("num_empleado", request.getParameter("num_empleado"+i));
				//cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				//cdo.addColValue("salario_dest", request.getParameter("salario"+i));
				//cdo.addColValue("gasto_rep_dest", request.getParameter("gasto_rep"+i));
				//cdo.addColValue("accion", "actualizar");
			}
			else if (baction.equalsIgnoreCase("Anular"))
			{
				cdo.addColValue("estado","N");
				cdo.addColValue("fecha_modificacion","sysdate");
				cdo.addColValue("usuario_modificacion",UserDet.getUserName());
			}

			al.add(cdo);
		}
	}

	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (baction.equalsIgnoreCase("Aplicar")) AEmpMgr.aplicarAccion(al);
	else if (baction.equalsIgnoreCase("Anular")) AEmpMgr.anularAccion(al);
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (AEmpMgr.getErrCode().equals("1")) { %>alert('<%=AEmpMgr.getErrMsg()%>');window.location= '<%=request.getContextPath()+request.getServletPath()%>';<% } else throw new Exception(AEmpMgr.getErrException()); %>}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>