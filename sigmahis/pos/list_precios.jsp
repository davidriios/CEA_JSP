<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CafMgr" scope="session" class="issi.pos.CafeteriaMgr"/>
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
CafMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String refer_to = request.getParameter("refer_to");
String fecha = request.getParameter("fecha");
String ref_id = request.getParameter("ref_id");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (tipoCliente == null) tipoCliente = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

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

	String code = request.getParameter("code");
	String name = request.getParameter("name");
	String dob = request.getParameter("dob");
	String pCode = request.getParameter("pCode");
	String ruc = request.getParameter("ruc");

	if (code == null) code = "";
	if (name == null) name = "";
	if (refer_to == null) refer_to = "";
	if (!code.trim().equals("")) {
		if(refer_to.equals("EMPL")){
			sbFilter.append(" and exists (select null from tbl_pla_empleado e where to_char(emp_id) = a.codigo and num_empleado like '%");
			sbFilter.append(code); 
			sbFilter.append("%')"); 
		} else {
			sbFilter.append(" and codigo like '"); 
			sbFilter.append(code); 
			sbFilter.append("%'"); 
		}
	}
	if (!refer_to.trim().equals("")) {
		sbFilter.append(" and refer_to = '"); 
		sbFilter.append(refer_to); 
		sbFilter.append("'"); 
	}
	if (!name.trim().equals("")) {
		sbFilter.append(" and upper(nombre) like '%"); 
		sbFilter.append(name.toUpperCase()); 
		sbFilter.append("%'"); 
	}
	if (dob == null) dob = "";
	if (pCode == null) pCode = "";
	if (ruc == null) ruc = "";
	if (!ruc.trim().equals("")){
		sbFilter.append(" and ruc like '"); 
		sbFilter.append(ruc); 
		sbFilter.append("%'"); 
	}

	CommonDataObject cdoQry = new CommonDataObject();
	StringBuffer sbQry = new StringBuffer();
	if (!refer_to.trim().equals("")) {
		sbQry.append("select query from tbl_gen_query where id = 1 and refer_to = '");
		sbQry.append(refer_to);
		sbQry.append("'");
		cdoQry=SQLMgr.getData(sbQry.toString());
		if(cdoQry==null) throw new Exception("No Existe un listado para este tipo de cliente!");
		sbSql = new StringBuffer();
		sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, nvl(b.id, 0) id from (");
		sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
		sbSql.append(") a, tbl_clt_lista_precio b where nvl(compania, 1) = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter.toString());
		sbSql.append(" and a.refer_to = b.tipo_clte(+) and a.codigo = b.id_clte(+) and b.ref_id(+) = ");
		sbSql.append(ref_id);
		sbSql.append(" order by nombre");

		if (sbSql.length() > 0){
			al = SQLMgr.getDataList("select * from (select rownum as rn, a.*, "+ref_id+" ref_id from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
			rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
		}
		else System.out.println("* * *   There is not sql statement to execute!   * * *");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Common - '+document.title;

function app(){
	var size = <%=al.size()%>;
	var nivel_precio = document.detail.id_precio.value;
	for(i=0;i<size;i++){
		/*if(eval('document.detail.id_precio'+i).value=='')*/eval('document.detail.id_precio'+i).value=nivel_precio;
	}
}

function doSubmit(val){
	document.detail.baction.value = val;
	document.detail.submit();
}

function printListPrecio(){
	abrir_ventana('../pos/print_list_precios.jsp?appendFilter=<%=issi.admin.IBIZEscapeChars.forURL(sbFilter.toString())%>&refer_to=<%=refer_to%>&ref_id=<%=ref_id%>');
}

function setReferTo(){
	var ref_id = document.search01.ref_id.value;
	document.search01.refer_to.value = getDBData('<%=request.getContextPath()%>', 'refer_to', 'tbl_fac_tipo_cliente', 'codigo='+ref_id+' and compania = <%=(String) session.getAttribute("_companyId")%>');
	if(document.search01.refer_to.value=='EMPO') document.getElementById("colaborador").style.display='';
	else document.getElementById("colaborador").style.display='none';
}

function addColaborador(){
	var ref_id = document.search01.ref_id.value;
	showPopWin('../pos/add_cliente.jsp?fp=lista_precio&ref_id='+ref_id+'&refer_to=EMPO',winWidth*.80,_contentHeight*.60,null,null,'');
}

function reloadPage(ref_id, refer_to){
	window.location = '../pos/list_precios.jsp?ref_id='+ref_id+'&refer_to='+refer_to;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COMPA&Ntilde;&Iacute;A"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("refer_to",refer_to)%>
				<%=fb.hidden("fecha",fecha)%>
				<tr class="TextFilter">
					<td>
					Tipo:
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by descripcion","ref_id",ref_id,false,false,0, "text10", "", "onChange=\"javascript:setReferTo();\"", "", "S")%>
					C&oacute;digo&nbsp;
					<%=fb.textBox("code",code,false,false,false,12,20,"Text10",null,null)%>
					Nombre
					<%=fb.textBox("name",name,false,false,false,34,"Text10",null,null)%>
					RUC:
					<%=fb.textBox("ruc",ruc,false,false,false,10,"Text10",null,null)%>
					Fecha Nac.:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="dd/mm/yyyy"/>
						<jsp:param name="nameOfTBox1" value="dob" />
						<jsp:param name="valueOfTBox1" value="" />
					</jsp:include>
					<authtype type='50'>
					<label id="colaborador" style="display:none"><%=fb.button("addOC","Agregar Colaborador",true,false,null,null,"onClick=\"javascript:addColaborador();\"")%></label>
					</authtype>
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='2'><a href="javascript:printListPrecio()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("refer_to",refer_to)%>
				<%=fb.hidden("ref_id",ref_id)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("refer_to",refer_to)%>
				<%=fb.hidden("ref_id",ref_id)%>
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
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%
			fb = new FormBean("detail","","post","");
			%>
			<%=fb.formStart()%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("baction","")%>
			<tr class="TextHeader" align="center">
				<td width="30%">Nombre</td>
				<td width="10%">C&oacute;digo</td>
				<td width="10%">RUC</td>
				<td width="10%">DV</td>
				<td width="20%">&nbsp;
				<%=fb.select("id_precio","1=NORMAL,2=EJECUTIVO,3=COLABORADOR,4=PRECIO 4,5=PRECIO 5,6=PRECIO 6,7=PRECIO 7,8=PRECIO 8","",false,false,0,"Text10",null,null,null,"S")%>
				<%=fb.button("aplicar","Aplicar",true,false,null,"Text10","onClick=\"javascript:app()\"")%>
				<authtype type='3'>
				<%=fb.button("save","Guardar",true,false,null,"Text10","onClick=\"javascript:doSubmit(this.value)()\"")%>
				</authtype>
				</td>
			</tr>
			<%
			for (int i=0; i<al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
				<%=fb.hidden("refer_to"+i,cdo.getColValue("refer_to"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
				<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">			
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=(cdo.getColValue("refer_to").equals("EMPL")?cdo.getColValue("num_empleado"):cdo.getColValue("codigo"))%></td>
					<td><%=cdo.getColValue("ruc")%></td>
					<td><%=cdo.getColValue("dv")%></td>
					<td align="center"><%=fb.select("id_precio"+i,"1=NORMAL,2=EJECUTIVO,3=COLABORADOR,4=PRECIO 4,5=PRECIO 5,6=PRECIO 6,7=PRECIO 7,8=PRECIO 8",cdo.getColValue("id_precio"),false,false,0,"Text10",null,null,null,"S")%></td>
				</tr>
			<%
			}
			%>
			<%=fb.hidden("keySize",""+al.size())%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("refer_to",refer_to)%>
				<%=fb.hidden("ref_id",ref_id)%>
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
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("refer_to",refer_to)%>
				<%=fb.hidden("ref_id",ref_id)%>
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
} else {
	int size = Integer.parseInt(request.getParameter("keySize"));
	al.clear();
	String baction = request.getParameter("baction");
	if(baction==null) baction="";
	for(int i=0;i<size;i++){
		CommonDataObject det = new CommonDataObject();
		det.addColValue("id", request.getParameter("id"+i));
		det.addColValue("ref_id", request.getParameter("ref_id"+i));
		det.addColValue("tipo_clte", request.getParameter("refer_to"+i));
		det.addColValue("id_clte", request.getParameter("codigo"+i));
		det.addColValue("id_precio", request.getParameter("id_precio"+i));
		if(det.getColValue("id").equals("0")) det.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		if(!det.getColValue("id").equals("0")) det.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		al.add(det);
	}
	if(baction.equals("Guardar")){
		CafMgr.addListaPrecio(al);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<% if (CafMgr.getErrCode().equals("1")) { %>
	alert('<%=CafMgr.getErrMsg()%>');
	window.location = '../pos/list_precios.jsp?ref_id=<%=ref_id%>&refer_to=<%=refer_to%>';
<% } else throw new Exception(CafMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
