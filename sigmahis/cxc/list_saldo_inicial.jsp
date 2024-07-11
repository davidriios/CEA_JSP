<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
==================================================================================
==================================================================================
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
String tcOpt = "O=OTROS";
if(_comp.getHospital().trim().equals("S")){tcOpt = "P=PACIENTE,A=ASEGURADORA,O=OTROS";}

if (fg == null) fg = "CXC";

String compFar = "";
try { compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar"); } catch(Exception e) {}
if (compFar.equalsIgnoreCase((String) session.getAttribute("_companyId"))&&!fg.equalsIgnoreCase("CXPP")&&!fg.equalsIgnoreCase("CXPH")&&!_comp.getHospital().trim().equals("S")) { tcOpt = "O=OTROS"; sbFilter.append(" and upper(x.tipo_cliente) in ('O')"); }
if (fg.equalsIgnoreCase("CXPH")) { tcOpt = "M=MEDICOS,S=SOCIEDADES MEDICAS"; sbFilter.append(" and upper(x.tipo_cliente) in ('M','S')"); }
else if (fg.equalsIgnoreCase("CXPP")) { tcOpt = "E=PROVEEDORES"; sbFilter.append(" and upper(x.tipo_cliente) in ('E')"); }

String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String nombrePaciente = request.getParameter("nombre_paciente");
String tipo_cliente = request.getParameter("tipo_cliente");
String tipoRef = request.getParameter("tipoRef");
String tipo_prove = request.getParameter("tipo_prove");
String admType = request.getParameter("admType");
String comentarios = request.getParameter("comentarios");
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (nombrePaciente == null) nombrePaciente = "";
if (tipo_cliente == null) tipo_cliente = "";
if (tipoRef == null) tipoRef = "";
if (tipo_prove == null) tipo_prove = "";
if (admType == null) admType = "";
if (comentarios == null) comentarios = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(x.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	
	if (!nombrePaciente.trim().equalsIgnoreCase("")){
	  sbFilter.append(" and upper(x.nombre_paciente) like '%"); sbFilter.append(nombrePaciente.toUpperCase()); sbFilter.append("%'");
	}
	
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(x.id) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!tipo_cliente.trim().equals("")) { sbFilter.append(" and upper(x.tipo_cliente) = '"); sbFilter.append(tipo_cliente.toUpperCase()); sbFilter.append("'"); }
	if (!tipoRef.trim().equals("")) { sbFilter.append(" and x.tipoRef = "); sbFilter.append(tipoRef); }
	if(_comp.getHospital().trim().equals("S")&&!fg.equalsIgnoreCase("CXPH")&&!fg.equalsIgnoreCase("CXPP")){sbFilter.append(" and x.tipo_cliente in ('P','A','O')");}
	if (!tipo_prove.trim().equals("")) { sbFilter.append(" and upper(x.tipo_prov) ='"); sbFilter.append(tipo_prove.toUpperCase()); sbFilter.append("'"); }
	if (!admType.trim().equals("")) { sbFilter.append(" and x.adm_type = '"); sbFilter.append(admType.toUpperCase()); sbFilter.append("'"); }
	if (!comentarios.trim().equals("")) { sbFilter.append(" and upper(x.comentarios) like '%"); sbFilter.append(comentarios.toUpperCase()); sbFilter.append("%'"); }
	sbSql.append("select x.* from (");
		sbSql.append("select s.id, s.tipo_cliente, nvl(s.saldo_actual,0) as saldo_actual, s.compania, s.usuario_creacion, decode(s.tipo_cliente , 'M',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =s.id_cliente ),s.id_cliente) id_cliente_view, s.id_cliente");
		
		if (tipo_cliente.trim().equals("A")) {
		   sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = s.pac_id) as nombre_paciente ");
		   sbSql.append(", case when s.tipo_cliente in ('A') then (select nombre from tbl_adm_empresa where codigo = s.id_cliente)");
		}else{
			sbSql.append(", '' as nombre_paciente, case when s.tipo_cliente in ('P','A') then decode(s.pac_id,null,(select nombre from tbl_adm_empresa where codigo = s.id_cliente),(select nombre_paciente from vw_adm_paciente where pac_id = s.pac_id))");
		}
		
		sbSql.append(" when s.tipo_cliente = 'C' then (select descripcion from tbl_cds_centro_servicio where to_char(codigo) = s.id_cliente)");
		sbSql.append(" when s.tipo_cliente = 'E' then (select nombre_proveedor from tbl_com_proveedor where to_char(cod_provedor) = s.id_cliente)");
		sbSql.append(" when s.tipo_cliente = 'M' then (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = s.id_cliente)");
		sbSql.append(" when s.tipo_cliente = 'S' then (select nombre from tbl_adm_empresa where to_char(codigo) = s.id_cliente)");
		sbSql.append(" when s.tipo_cliente = 'O' then s.nombre");
		sbSql.append(" else ' ' end as nombre, decode(s.tipo_cliente,'P','PACIENTE','A','ASEGURADORA','E','PROVEEDORES','M','MEDICOS','S','SOCIEDADES MEDICAS','O','OTROS') as tipo, s.tipo_ref as tipoRef,decode(s.tipo_cliente,'O',(select descripcion from tbl_fac_tipo_cliente where codigo=s.tipo_ref and compania =s.compania),'E',(select tp.descripcion from tbl_com_tipo_proveedor tp,tbl_com_proveedor p where to_char(cod_provedor) = s.id_cliente and tp.tipo_proveedor=p.tipo_prove and p.compania =s.compania),' ') descTipoClt,	decode(s.tipo_cliente,'E',(select tp.tipo_proveedor from tbl_com_tipo_proveedor tp,tbl_com_proveedor p where to_char(cod_provedor) = s.id_cliente and tp.tipo_proveedor=p.tipo_prove and p.compania =s.compania),' ') as tipo_prov, nvl(s.adm_type,' ') as adm_type, decode(s.adm_type,'T','GRAL','I','IP','O','OP',' ') as adm_type_desc, nvl(s.comentarios,' ') as comentarios from tbl_cxc_saldo_inicial s");
	sbSql.append(") x where x.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	if(request.getParameter("codigo") != null){
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
document.title = 'Saldo Inicial  - '+document.title;
function add(){abrir_ventana('../cxc/saldo_inicial.jsp?mode=add&fg=<%=fg%>');}
function view(id){abrir_ventana('../cxc/saldo_inicial.jsp?id='+id+'&mode=view&fg=<%=fg%>');}
function printList(){abrir_ventana('../cxc/print_list_saldo_inicial.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fg=<%=fg%>&tipoCliente='+$("#tipo_cliente").val());}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();showOtros(document.search00.tipo_cliente.value);}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function showOtros(tp){
   if(tp==undefined||tp==null)tp='P';
   if(tp!='O'){
	 document.search00.tipoRef.style.display='none';
	 if (tp=='A'){$("#xtra_filter, #xtra_filter_t").show(0);
	 }else {$("#xtra_filter, #xtra_filter_t").hide(0);}
   }
   else {$("#xtra_filter, #xtra_filter_t").hide(0);document.search00.tipoRef.style.display='';}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXC - LISTADO DE CLIENTE CON SALDO INICIAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
		<tr>
			<td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Saldo</cellbytelabel> ]</a></authtype>
     		</td>
		</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="0">
			<% fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp"); %>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fg",fg)%>
			<tr class="TextFilter">
				<td><cellbytelabel>Tipo</cellbytelabel>
				<%=fb.select("tipo_cliente",tcOpt,tipo_cliente,false,false,0,null,null,"onChange=\"javascript:showOtros(this.value)\"")%>
				<span id="blkTipoRef"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by descripcion","tipoRef",tipoRef,false,false,false,0,null,null,"onChange=\"javascript:showOtros(document.search00.tipo_cliente.value)\"",null,"S")%></span>
				
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo",codigo,false,false,false,15)%>
					<cellbytelabel>Nombre</cellbytelabel>
					<span id="xtra_filter_t" style="display:none">:&nbsp;&nbsp;&nbsp;Aseguradora</span>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					<span id="xtra_filter" style="display:none">
					  <cellbytelabel>Paciente</cellbytelabel>
					  <%=fb.textBox("nombre_paciente",nombrePaciente,false,false,false,30)%>
					</span>
					<%if(fg.trim().equals("CXPP")){%>Tipo Prov.
					<%=fb.select(ConMgr.getConnection(), "select tipo_proveedor, descripcion||' - '||tipo_proveedor as descripcion from tbl_com_tipo_proveedor", "tipo_prove",tipo_prove,"S")%><%}%>
					<% if (fg.trim().equals("CXC")) { %><cellbytelabel>Categor&iacute;a</cellbytelabel>
					<%=fb.select("admType","T=GENERAL,I=IN-PATIENT (IP),O=OUT-PATIENT (OP)",admType,false,false,false,0,null,null,null,"","T")%><% } %>
					<br>
					<cellbytelabel>Comentarios</cellbytelabel>
					<%=fb.textBox("comentarios",comentarios,false,false,false,50)%>
					<%=fb.submit("go","Ir")%>
				</td>
			</tr>
			<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	 <tr>
		<td align="right"><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("tipo_cliente",tipo_cliente)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("admType",admType)%>
				<%=fb.hidden("comentarios",comentarios)%>

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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("tipo_cliente",tipo_cliente)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("admType",admType)%>
				<%=fb.hidden("comentarios",comentarios)%>
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
			<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
				<tr class="TextHeader" align="center">
					<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<%if (tipo_cliente.trim().equals("A")) {%>
					<td width="15%"><cellbytelabel>Aseguradora</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Paciente</cellbytelabel></td>
					<%}else{%>
					<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
					<%}%>
					<td width="8%"><cellbytelabel>Tipo</cellbytelabel></td>
					<td width="20%"><cellbytelabel><%if (fg.equalsIgnoreCase("CXPP")){%>Tipo Proveedor<%}else if(!fg.trim().equals("CXPH")){%>Tipo Otros<%}%></cellbytelabel></td>
					<% if (fg.equalsIgnoreCase("CXC")) { %>
					<td width="7%"><cellbytelabel>Saldo</cellbytelabel></td>
					<td width="3%"><cellbytelabel>Cat.</cellbytelabel></td>
					<% } else { %>
					<td width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
					<% } %>
					<td width="20%"><cellbytelabel>Comentarios</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%double total = 0.00,totalref=0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 
				 total += Double.parseDouble(cdo.getColValue("saldo_actual"));
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("id")%></td>
					<td>[<%=cdo.getColValue("id_cliente_view")%>]&nbsp;-&nbsp;<%=cdo.getColValue("nombre")%></td>
					
					<%if (tipo_cliente.trim().equals("A")) {%>
					<td><%=cdo.getColValue("nombre_paciente")%></td>
					<%}%>
					<td><%=cdo.getColValue("tipo")%></td>
					<td><%=cdo.getColValue("descTipoClt")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_actual"))%></td>
					<% if (fg.equalsIgnoreCase("CXC")) { %><td align="center"><%=cdo.getColValue("adm_type_desc")%></td><% } %>
					<td><%=cdo.getColValue("comentarios")%></td>
					<td align="center"><authtype type='1'><a href="javascript:view('<%=cdo.getColValue("id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>ver</cellbytelabel></a></authtype></td>
				</tr>
				<%
				}
				%>
				

	<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
			</table>
	</div>
</div>
			
		</td>
	</tr>
	<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow09" align="center">
					<td width="65%" align="right">TOTAL</td>
					<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
					<td width="25%">&nbsp;</td>
				</tr>
				</table>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
					<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("admType",admType)%>
				<%=fb.hidden("comentarios",comentarios)%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("tipo_cliente",tipo_cliente)%>
				<%=fb.hidden("tipoRef",tipoRef)%>
					<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("admType",admType)%>
				<%=fb.hidden("comentarios",comentarios)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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
%>