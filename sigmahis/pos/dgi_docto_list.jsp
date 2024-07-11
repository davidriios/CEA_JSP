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
/*------------------------------------------------------------------------------------------------*/
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
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
String id = request.getParameter("id");
String fp= request.getParameter("fp");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String tipo_docto = request.getParameter("tipo_docto");
String codigo = request.getParameter("codigo");
String paciente = request.getParameter("paciente");
String impreso = request.getParameter("impreso");
String client_id = request.getParameter("client_id");
String ref_id = request.getParameter("ref_id");
String no_referencia = request.getParameter("no_referencia");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

String docType = request.getParameter("docType");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

int iconHeight = 20;
int iconWidth = 20;

if(fecha_ini==null) fecha_ini = "";
if(fecha_fin==null) fecha_fin = "";
if(tipo_docto==null) tipo_docto = "FAC";
if(codigo==null) codigo = "";
if(paciente==null) paciente = "";
if(impreso==null) impreso = "N";
if(client_id==null) client_id = "";
if(ref_id==null) ref_id = "";
if(no_referencia==null) no_referencia = "";
if(docType==null) docType = "";

String table =" tbl_fac_trx ";
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

  if (!codigo.trim().equals("")){
    sbFilter.append(" and a.printed_no like'%");
		sbFilter.append(codigo);
		sbFilter.append("%'");
  }
  if (!no_referencia.trim().equals("")){
    sbFilter.append(" and a.other3 like'%");
		sbFilter.append(no_referencia);
		sbFilter.append("%'");
  }
  if (!paciente.trim().equals("")){
    sbFilter.append(" and upper(a.client_name) like '%");
		sbFilter.append(paciente);
		sbFilter.append("%'");
  }
  if (!fecha_ini.trim().equals("")){
    sbFilter.append(" and trunc(a.doc_date) >= to_date('");
		sbFilter.append(fecha_ini);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!fecha_fin.trim().equals("")){
    sbFilter.append(" and trunc(a.doc_date) <= to_date('");
		sbFilter.append(fecha_fin);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
	if (!tipo_docto.trim().equals("")){
    sbFilter.append(" and doc_type = '");
		sbFilter.append(tipo_docto);
		sbFilter.append("'");
  }
	if (!ref_id.trim().equals("")){
    sbFilter.append(" and client_ref_id = ");
		sbFilter.append(ref_id);
  }
	if (!client_id.trim().equals("")){
    sbFilter.append(" and client_id = '");
		sbFilter.append(client_id);
		sbFilter.append("'");
  }
	/*
	if (!impreso.trim().equals("")){
    sbFilter.append(" and nvl(impreso, 0) = ");
		sbFilter.append(impreso);
  }
	*/
	
	if(docType.trim().equals("PRO")) table=" tbl_fac_proforma "; 
	sbSql.append("select ruc, dv, client_ref_id, cod_caja, turno, centro_servicio, tipo_factura, cod_cajero, doc_id, doc_no, to_char(doc_date, 'dd/mm/yyyy') docto_date, doc_type, reference_id, reference_no, to_char(expiration, 'dd/mm/yyyy') expiration, delivery_address, client_id, client_name, company_id, status, observations, gross_amount, gross_amount_gravable, total_discount, total_discount_gravable, sub_total, sub_total_gravable, pay_tax, tax_percent, tax_amount, total_charges, net_amount, created_by, to_char(sys_date, 'dd/mm/yyyy') sys_date, modified_by, to_char(modified_date, 'dd/mm/yyyy') modified_date, printed, printed_no, printed_by, to_char(printed_date, 'dd/mm/yyyy') printed_date, other1, other2, other3 no_referencia, other4, other5, client_type from ");
	sbSql.append(table);
    sbSql.append("a where a.company_id = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(!docType.trim().equals("PRO")) sbSql.append(" and nvl(printed, '0') = 1");
	if(docType.trim().equals("PRO")) sbSql.append(" and nvl(status, 'O') ='O'");
		
		sbSql.append(sbFilter.toString());

		sbSql.append(" order by doc_date desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	System.out.println("sbFilter.toString()="+sbFilter.toString());

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
document.title = 'Facturas - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printFact(i, flag)
{
}

function setArt(i){
	parent.document.form0._tipo_factura.value = eval('document.form0.tipo_factura'+i).value;
	parent.document.form0.tipo_factura.value = eval('document.form0.tipo_factura'+i).value;
	<%if(docType.trim().equals("PRO")){%>
	 parent.document.form0.tipo_docto_ref.value='<%=docType%>';
	// $("#btn_fac").addClass("btn_red_link").removeClass("CellbyteBtn");
	<%}%>
	parent.setArt(eval('document.form0.id'+i).value, eval('document.form0.printed_no'+i).value);
	parent.hidePopWin(false);
}


window.onbeforeunload = function() { if(document.search01.use_filtro.value=='N' && parent.document.form0.reference_no.value=='') parent.document.form0.tipo_docto.value='FAC';};

</script>

<% if(touch.trim().equalsIgnoreCase("Y")){%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
    display:none; 
    margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>

<script>
$(document).ready(function(){
  <%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
      var opts ={
        keypadOnly: false, 
        layout: [
        '1234567890-', 
        'qwertyuiop' + $.keypad.CLOSE, 
        'asdfghjkl' + $.keypad.CLEAR, 
        'zxcvbnm' + 
        $.keypad.SPACE_BAR + $.keypad.BACK]
      };
      $('#paciente, #no_referencia, #codigo').keypad(opts);
      
      $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('#paciente, #codigo, #no_referencia, #fecha_ini, #fecha_fin').keypad("hide");
        }
      });
  <%}%>
});
</script>

<%}%>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
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
				<%=fb.hidden("nt",nt)%>
				<%=fb.hidden("use_filtro","N")%>
				<%=fb.hidden("client_id",client_id)%>
				<%=fb.hidden("ref_id",ref_id)%>
                <%=fb.hidden("useKeypad",useKeypad)%>
                <%=fb.hidden("touch",touch)%>
                <%=fb.hidden("docType",docType)%>
				<td>No. Factura:
							<%=fb.textBox("codigo",codigo,false,false,false,6,null,null,null)%>
						No. Referencia:
							<%=fb.textBox("no_referencia",no_referencia,false,false,false,7,null,null,null)%>	
							Cliente:<%=fb.textBox("paciente","",false,false,false,15,null,null,null)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_ini" />
								<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
								<jsp:param name="nameOfTBox2" value="fecha_fin" />
								<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
								</jsp:include>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.submit("go","Ir", true, false, "", "", "onClick=\"javascript:document.search01.use_filtro.value='S';\"")%>
				</td>
				<%=fb.formEnd()%>
			</tr>

			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td>
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
							<%=fb.hidden("nt",nt)%>
							<%=fb.hidden("codigo",""+codigo)%>
							<%=fb.hidden("paciente",""+paciente)%>
							<%=fb.hidden("tipo_docto",""+tipo_docto)%>
							<%=fb.hidden("impreso",""+impreso)%>
							<%=fb.hidden("fecha_ini",""+fecha_ini)%>
							<%=fb.hidden("fecha_fin",""+fecha_fin)%>
							<%=fb.hidden("no_referencia",""+no_referencia)%>
							<%=fb.hidden("ref_id",ref_id)%>
                            <%=fb.hidden("client_id",client_id)%>
                            <%=fb.hidden("useKeypad",useKeypad)%>
                            <%=fb.hidden("touch",touch)%>
							<%=fb.hidden("docType",docType)%>
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
							<%=fb.hidden("fp",fp)%>
							<%=fb.hidden("index",index)%>
							<%=fb.hidden("nt",nt)%>
							<%=fb.hidden("codigo",""+codigo)%>
							<%=fb.hidden("paciente",""+paciente)%>
							<%=fb.hidden("tipo_docto",""+tipo_docto)%>
							<%=fb.hidden("impreso",""+impreso)%>
							<%=fb.hidden("fecha_ini",""+fecha_ini)%>
							<%=fb.hidden("fecha_fin",""+fecha_fin)%>
							<%=fb.hidden("no_referencia",""+no_referencia)%>
							<%=fb.hidden("ref_id",ref_id)%>
                            <%=fb.hidden("useKeypad",useKeypad)%>
                            <%=fb.hidden("touch",touch)%>
                            <%=fb.hidden("client_id",client_id)%>
							<%=fb.hidden("docType",docType)%>
							<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
							<%=fb.formEnd()%>
						</tr>
					</table>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<tr>
		<td>
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
				<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
				<tr>
					<td class="TableLeftBorder TableRightBorder">
						<!---->
						<div id="_cMain" class="Container">
						<div id="_cContent" class="ContainerContent">
						
						<table align="center" width="100%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"8":"0"%>" cellspacing="1" class="sortable">
							<tr class="TextHeader" align="center">
								<td width="25%">&nbsp;C&oacute;digo DGI</td>
								<td width="10%">&nbsp;C&oacute;digo</td>
								<td width="10%">&nbsp;No. Referencia</td>
								<td width="8%">&nbsp;Fecha </td>
								<td width="8%">&nbsp;Tipo Docto. </td>
								<td width="31%">&nbsp;Cliente </td>
								<td width="10%">&nbsp;RUC </td>
								<td width="8%" align="right">Monto</td>
							</tr>
							<%
							for (int i=0; i<al.size(); i++)
							{
							 CommonDataObject cdo = (CommonDataObject) al.get(i);
							 String color = "TextRow02";
							 if (i % 2 == 0) color = "TextRow01";

						%>
							<%=fb.hidden("id"+i,cdo.getColValue("doc_id"))%>
							<%=fb.hidden("ruc_cedula"+i,cdo.getColValue("ruc"))%>
							<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
							<%=fb.hidden("codigo"+i,cdo.getColValue("doc_no"))%>
							<%=fb.hidden("tipo_docto"+i,cdo.getColValue("doc_type"))%>
							<%=fb.hidden("printed_no"+i,cdo.getColValue("printed_no"))%>
							<%=fb.hidden("tipo_factura"+i,cdo.getColValue("tipo_factura"))%>
							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onDblClick="javascript:setArt(<%=i%>);">
								<td><%=cdo.getColValue("printed_no")%></td>
								<td><%=cdo.getColValue("doc_no")%></td>
								<td><%=cdo.getColValue("no_referencia")%></td>
								<td><%=cdo.getColValue("docto_date")%></td>
								<td><%=cdo.getColValue("doc_type")%></td>
								<td><%=cdo.getColValue("client_name")%></td>
								<td><%=cdo.getColValue("ruc")%></td>
								<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
							</tr>
							<%
							}
							%>

						</table>
						<!---->
						</div>
						</div>
						
		<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
					</td>
				</tr>
		<%=fb.formEnd()%>
			</table>
		</td>
	</tr>
	<tr>
		<td>
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
								<%=fb.hidden("index",index)%>
								<%=fb.hidden("nt",nt)%>
								<%=fb.hidden("codigo",""+codigo)%>
								<%=fb.hidden("paciente",""+paciente)%>
								<%=fb.hidden("tipo_docto",""+tipo_docto)%>
								<%=fb.hidden("impreso",""+impreso)%>
								<%=fb.hidden("fecha_ini",""+fecha_ini)%>
								<%=fb.hidden("fecha_fin",""+fecha_fin)%>
								<%=fb.hidden("no_referencia",""+no_referencia)%>
								<%=fb.hidden("client_id",client_id)%>
								<%=fb.hidden("ref_id",ref_id)%>
                                <%=fb.hidden("useKeypad",useKeypad)%>
                                <%=fb.hidden("touch",touch)%>
								<%=fb.hidden("docType",docType)%>
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
								<%=fb.hidden("index",index)%>
								<%=fb.hidden("nt",nt)%>
								<%=fb.hidden("codigo",""+codigo)%>
								<%=fb.hidden("paciente",""+paciente)%>
								<%=fb.hidden("tipo_docto",""+tipo_docto)%>
								<%=fb.hidden("impreso",""+impreso)%>
								<%=fb.hidden("fecha_ini",""+fecha_ini)%>
								<%=fb.hidden("fecha_fin",""+fecha_fin)%>
								<%=fb.hidden("no_referencia",""+no_referencia)%>								
								<%=fb.hidden("ref_id",ref_id)%>
                                <%=fb.hidden("client_id",client_id)%>
                                <%=fb.hidden("useKeypad",useKeypad)%>
                                <%=fb.hidden("touch",touch)%>
								<%=fb.hidden("docType",docType)%>
								<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
								<%=fb.formEnd()%>
							</tr>
						</table>
					</td>
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