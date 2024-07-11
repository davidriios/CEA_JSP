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
<%

SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String appendFilter2 = "";
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CXP_VALIDA_SALDO_FAC'),'S') as validaSaldo  from dual");
CommonDataObject cdoTA = (CommonDataObject) SQLMgr.getData(sbSql.toString());
String validaSaldo = cdoTA.getColValue("validaSaldo");

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

	String codigo  = ""; // variables para mantener el valor de los campos filtrados en la consulta
	String nombre  = "",fechaHasta="",fechaDesde="";
	String estado  = "",tipo  = "",destino="";

  if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
  {
    appendFilter += " and upper(a.id) like '%"+request.getParameter("code").toUpperCase()+"%'";
		codigo     = request.getParameter("code"); // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
  {
    appendFilter2 += " where  upper(nombre) like '%"+request.getParameter("name").toUpperCase()+"%'";
		nombre     = request.getParameter("name"); // utilizada para mantener el nombre del centro educativo que se filtró
  }
	  if (request.getParameter("tipo") != null && !request.getParameter("tipo").trim().equals(""))
  {
    appendFilter += " and upper(a.cod_tipo_ajuste) like '%"+request.getParameter("tipo").toUpperCase()+"%'";
		tipo     = request.getParameter("tipo"); // utilizada para mantener el nombre del centro educativo que se filtró
  }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
  {
    appendFilter += " and upper(a.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
		estado     = request.getParameter("estado"); // utilizada para mantener el nombre del centro educativo que se filtró
  }
  if (request.getParameter("fechaDesde") != null && !request.getParameter("fechaDesde").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha)>=to_date('"+request.getParameter("fechaDesde")+"','dd/mm/yyyy')";
	fechaDesde     = request.getParameter("fechaDesde");
  }
  if (request.getParameter("fechaHasta") != null && !request.getParameter("fechaHasta").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha)<=to_date('"+request.getParameter("fechaHasta")+"','dd/mm/yyyy')";
	fechaHasta     = request.getParameter("fechaHasta");
  }
  if (request.getParameter("destino") != null && !request.getParameter("destino").trim().equals(""))
  {
    appendFilter += " and a.destino_ajuste='"+request.getParameter("destino")+"'";
	destino     = request.getParameter("destino");
  }
if (request.getParameter("fechaHasta") != null ){
if(!appendFilter2.trim().equals("")) sql =" select * from (";
 sql += "select a.anio, a.id, a.cod_tipo_ajuste, a.monto, to_char(a.fecha,'dd/mm/yyyy') fecha, a.observacion, a.ref_id, a.numero_factura, decode(a.estado,'P','PENDIENTE','R','APROBADO','A','ANULADO') estadoDes, a.estado,nvl(decode(a.destino_ajuste,'H',(select m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = to_char(a.ref_id)),'E',(select nombre from tbl_adm_empresa where codigo =a.ref_id),(select c.nombre_proveedor from tbl_com_proveedor c where c.compania=a.compania and c.cod_provedor=to_number(a.ref_id))),'S/NOMBRE') nombre, (select b.descripcion from tbl_cxp_tipo_ajuste b where a.cod_tipo_ajuste = b.cod_tipo_ajuste ) as descripcion, a.destino_ajuste,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fc from tbl_cxp_ajuste_saldo_enc a where compania = "+(String) session.getAttribute("_companyId")+appendFilter;
 if(!appendFilter2.trim().equals("")) sql += ") "+appendFilter2;

  sql += " order by fecha desc, id desc";


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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas por Pagar - '+document.title;
function add(){abrir_ventana('../cxp/nota_ajuste_config.jsp');}
function edit(id, anio){abrir_ventana('../cxp/nota_ajuste_config.jsp?mode=edit&code='+id+'&anio='+anio);}
function anular(id,anio,destino_ajuste,cod_tipo_ajuste,numero_factura){
	var anula = true;
	<%if(validaSaldo.trim().equals("S")){%>
	if((destino_ajuste == 'P' || destino_ajuste == 'G' )&& cod_tipo_ajuste=='1'&&numero_factura!=''){
	var saldo = getDBData('<%=request.getContextPath()%>','getSaldoFactPRov(compania, ref_id, numero_factura, 2)','tbl_cxp_ajuste_saldo_enc a','compania = <%=(String) session.getAttribute("_companyId")%> and id = '+id);
	if(saldo<=0){
		anula = false;
		CBMSG.warning('No puede anular ajuste a factura sin saldo!');
	}}
	<%}%>
	if(anula)abrir_ventana('../cxp/nota_ajuste_config.jsp?mode=anular&code='+id+'&anio='+anio);
}
function ver(id, anio){abrir_ventana('../cxp/nota_ajuste_config.jsp?mode=view&code='+id+'&anio='+anio);}
function  printList(){abrir_ventana('../cxp/print_list_nota_ajuste.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&appendFilter2=<%=IBIZEscapeChars.forURL(appendFilter2)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - TRANSACCIONES - NOTAS DE AJUSTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Ajuste ]</a></authtype></td>
  </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<tr class="TextFilter">
				<td>&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel> <%=fb.textBox("code",codigo,false,false,false,10,"text10",null,null)%>
				&nbsp;<cellbytelabel>Proveedor</cellbytelabel>: <%=fb.textBox("name",nombre,false,false,false,25,"text10",null,null)%>
                 &nbsp;<cellbytelabel>Estado</cellbytelabel> <%=fb.select("estado","P=PENDIENTE,R=APROBADO,A=ANULADO","",false,false,0,"text10", "", "", "", "T")%>

				 &nbsp;<cellbytelabel>Tipo de Ajuste</cellbytelabel> &nbsp;
				<%=fb.select(ConMgr.getConnection(),"select cod_tipo_ajuste codigo, descripcion, cod_tipo_ajuste from tbl_cxp_tipo_ajuste order by cod_tipo_ajuste","tipo",tipo,false,false,0,"text10", "", "", "","S")%>
				 Fecha <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fechaDesde" />
                            <jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
                            <jsp:param name="nameOfTBox2" value="fechaHasta" />
                            <jsp:param name="valueOfTBox2" value="<%=fechaHasta%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
                            </jsp:include>
							Tipo:<%=fb.select("destino","P=PROV. - INVENTARIO,G=PROV. - GASTOS,H=MEDICOS,E=SOCIEDADES MEDICAS",destino,false,false,0,"text10",null,"","","T")%>
							<%=fb.submit("go","Ir")%>	</td>
			</tr>
			<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr>
    <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
  </tr>

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
				<%=fb.hidden("code",""+codigo)%>
				<%=fb.hidden("name",""+nombre)%>
				<%=fb.hidden("destino",""+destino)%>
				<%=fb.hidden("fechaDesde",""+fechaDesde)%>
				<%=fb.hidden("fechaHasta",""+fechaHasta)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("code",""+codigo)%>
					<%=fb.hidden("name",""+nombre)%>
					<%=fb.hidden("destino",""+destino)%>
				<%=fb.hidden("fechaDesde",""+fechaDesde)%>
				<%=fb.hidden("fechaHasta",""+fechaHasta)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>

 <tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
	  <td width="5%">&nbsp;</td>
		<td width="10%"><cellbytelabel>C&oacutedigo (Secuencia - A&ntilde;o)</cellbytelabel></td>
					<td width="23%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
                    <td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Fecha Creac.</cellbytelabel></td>
					<td width="13%"><cellbytelabel>Tipo</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="05%">&nbsp;</td>
					<td width="05%">&nbsp;</td>
					<td width="05%">&nbsp;</td>
	</tr>
	<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
						<td> [ <%=cdo.getColValue("id")%> ] <%=cdo.getColValue("anio")%> </td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("estadoDes")%></td>
                    <td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("fc")%></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center"><authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("id")%>,<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype></td>
					<td align="center"><%if(cdo.getColValue("estado").equals("P")){%>
					<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>,<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype><%}%></td>
					<td align="center"><%if(cdo.getColValue("estado").equals("R")){%>
					<authtype type='7'><a href="javascript:anular(<%=cdo.getColValue("id")%>,<%=cdo.getColValue("anio")%>, '<%=cdo.getColValue("destino_ajuste")%>','<%=cdo.getColValue("cod_tipo_ajuste")%>','<%=cdo.getColValue("numero_factura")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Anular</cellbytelabel></a></authtype><%}%></td>
				</tr>
				<%
				}
		%>
</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
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
				<%=fb.hidden("code",""+codigo)%>
				<%=fb.hidden("name",""+nombre)%>
				<%=fb.hidden("destino",""+destino)%>
				<%=fb.hidden("fechaDesde",""+fechaDesde)%>
				<%=fb.hidden("fechaHasta",""+fechaHasta)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel><%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("code",""+codigo)%>
					<%=fb.hidden("name",""+nombre)%>
					<%=fb.hidden("destino",""+destino)%>
				<%=fb.hidden("fechaDesde",""+fechaDesde)%>
				<%=fb.hidden("fechaHasta",""+fechaHasta)%>
				<%=fb.hidden("estado",""+estado)%>
				<%=fb.hidden("tipo",""+tipo)%>
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
}
%>