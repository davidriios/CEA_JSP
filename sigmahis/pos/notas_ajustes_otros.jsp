<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.pos.Factura"%>
<%@ page import="java.util.StringTokenizer"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNotas" scope="session" class="java.util.Vector" />
<jsp:useBean id="FAC" scope="session" class="issi.pos.Factura"/>
<jsp:useBean id="CafMgr" scope="session" class="issi.pos.CafeteriaMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CafMgr.setConnection(ConMgr);
CommonDataObject cdo = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String compania = request.getParameter("compania");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String codigo = request.getParameter("codigo");
String ref_id = request.getParameter("ref_id");
String ref_type = request.getParameter("ref_type");

boolean viewMode = false;
boolean flag = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
if (fp == null) fp = "";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (compania == null) compania = (String) session.getAttribute("_companyId");
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET")){

	if (mode.equalsIgnoreCase("add")){
		sql.append("select doc_id reference_id, printed_no reference_no, getNombreCliente(company_id,client_ref_id,client_id) AS client_name, to_char(sysdate, 'dd/mm/yyyy') fecha_factura, dv, ruc, centro_servicio from tbl_fac_trx where other3 = '");
		sql.append(codigo);
		sql.append("' and company_id = ");
		sql.append(compania);
		cdo = SQLMgr.getData(sql.toString());
		cdo.addColValue("observacion", "");
		cdo.addColValue("factura", codigo);
		cdo.addColValue("ref_id", ref_id);
		cdo.addColValue("ref_type", ref_type);
		cdo.addColValue("cantidad", "1");
		cdo.addColValue("monto", "0.00");
	} else {

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Notas de Ajuste Otros - '+document.title;
function doAction(){}

function doSubmit(){
	if(form0Validation()) document.form0.submit();
}
function checkEstado(){
var fecha= document.form0.fecha_factura.value;
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form0.fecha_factura.value='';return false;}else return true;}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="NOTAS DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
	 		<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("tipo_factura","CR")%>
			<%=fb.hidden("client_id",ref_id)%>
			<%=fb.hidden("client_ref_id",ref_type)%>
			<tr class="TextHeader">
				<td colspan="4">Notas de Ajustes</td>
			</tr>
			<%=fb.hidden("reference_id", cdo.getColValue("reference_id"))%>
			<%=fb.hidden("centro_servicio", cdo.getColValue("centro_servicio"))%>
			<tr class="TextRow01">
				<td><cellbytelabel>Factura</cellbytelabel>:</td>
				<td><%=fb.textBox("factura",cdo.getColValue("factura"),true,false,true,20,12)%><%=fb.textBox("reference_no",cdo.getColValue("reference_no"),false,false,true,10,10,null,null,"")%></td>
				<td><cellbytelabel>Cliente</cellbytelabel>:</td>
				<td><%=fb.textBox("client_name",cdo.getColValue("client_name"),false,false,true,60,60,null,null,"")%>
				RUC.:<%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,true,30,30,null,null,"")%>
				D.V.:<%=fb.textBox("dv",cdo.getColValue("dv"),false,false,true,2,2,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Tipo Documento</cellbytelabel>:</td>
				<td><%=fb.select("tipo_docto","NCR=Nota de Credito",cdo.getColValue("tipo_docto"),true,false,viewMode,0,"","","")%></td>
				<td><cellbytelabel>Fecha</cellbytelabel>:</td>
				<td><%String checkEstado = "javascript:checkEstado();newHeight();";%>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha_factura" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_factura")%>" />
					<jsp:param name="fieldClass" value="text10" />
					<jsp:param name="buttonClass" value="text10" />
					<jsp:param name="jsEvent" value="<%=checkEstado%>" />
					<jsp:param name="onChange" value="<%=checkEstado%>" />
					<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
					</jsp:include>
				</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">Observaci&oacute;n<br><%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,viewMode,80,2,200,"","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">
					<table width="100%">
						<tr class="TextHeader" align="center">
							<td>CANTIDAD</td>
							<td>DESCRIPCI&Oacute;N</td>
							<td>MONTO</td>
						</tr>
						<tr align="center">
							<td><%=fb.intBox("cantidad",cdo.getColValue("cantidad"),false,false,true,5,10,null,null,"")%></td>
							<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,80,100)%></td>
							<td><%=fb.decBox("monto",CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),true,false,false,15,8.2)%></td>
						</tr>
					</table>
				</td>
			</tr>
	<%//fb.appendJsValidation("\n\tif (!CheckMonto()) error++;\n");%>
	<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
						<%=fb.button("save","Guardar",(!viewMode),viewMode,null,null,"onClick=\"javascript:doSubmit()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>
<%fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");%>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();
	if(request.getParameter("fecha_factura")!=null) cdo.addColValue("doc_date", request.getParameter("fecha_factura"));
	if(request.getParameter("tipo_docto")!=null) cdo.addColValue("doc_type", request.getParameter("tipo_docto"));
	if(request.getParameter("client_id")!=null) cdo.addColValue("client_id", request.getParameter("client_id"));
	if(request.getParameter("client_name")!=null) cdo.addColValue("client_name", request.getParameter("client_name"));
	if(request.getParameter("client_ref_id")!=null) cdo.addColValue("client_ref_id", request.getParameter("client_ref_id"));
	if(request.getParameter("ruc")!=null) cdo.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("dv")!=null) cdo.addColValue("dv", request.getParameter("dv"));
	if(request.getParameter("centro_servicio")!=null) cdo.addColValue("centro_servicio", request.getParameter("centro_servicio"));
	cdo.addColValue("company_id", (String) session.getAttribute("_companyId"));
	if(request.getParameter("tipo_docto").equals("NCR") || request.getParameter("tipo_docto").equals("NDB")){
		cdo.addColValue("reference_id", request.getParameter("reference_id"));
		cdo.addColValue("reference_no", request.getParameter("reference_no"));
	}
	if(request.getParameter("comentario")!=null) cdo.addColValue("observations", request.getParameter("comentario"));
	cdo.addColValue("gross_amount", request.getParameter("monto"));
	cdo.addColValue("sub_total", request.getParameter("monto"));
	cdo.addColValue("net_amount", request.getParameter("monto"));
	cdo.addColValue("tipo_factura", "CR");
	cdo.addColValue("cod_caja","-2");
	if(request.getParameter("cds")!=null) cdo.addColValue("centro_servicio", request.getParameter("cds"));
	cdo.addColValue("turno","-2");
	if(request.getParameter("cod_cajera")!=null) cdo.addColValue("cod_cajero", request.getParameter("cod_cajera"));
	cdo.addColValue("created_by", (String) session.getAttribute("_userName"));
	cdo.addColValue("modified_by", (String) session.getAttribute("_userName"));
	cdo.addColValue("page_name", "notas_ajustes_otros.jsp");
	cdo.addColValue("other4", "1");//Diferencia los documentos generados desde el POS donde el valor es 0.
	FAC.setCdo(cdo);
	FAC.getAlDet().clear();
	if(request.getParameter("tipo_factura")!=null && request.getParameter("tipo_factura").equals("CR")){
		CommonDataObject _cdoFP = new CommonDataObject();
		_cdoFP.addColValue("Fp_Codigo", "get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'FORMA_PAGO_CREDITO')");
		_cdoFP.addColValue("monto", request.getParameter("monto"));
		FAC.getAlFormaPago().clear();
		FAC.getAlFormaPago().add(_cdoFP);
	}

	CommonDataObject cd = new CommonDataObject();

	cd.addColValue("almacen", "0");
	cd.addColValue("codigo", "0");
	cd.addColValue("descripcion", request.getParameter("descripcion"));
	cd.addColValue("tipo_art", "O");
	cd.addColValue("precio", request.getParameter("monto"));
	cd.addColValue("cantidad", request.getParameter("cantidad"));
	cd.addColValue("total", request.getParameter("monto"));
	//if(request.getParameter("tipo_servicio"+i)!=null) cd.addColValue("tipo_servicio", request.getParameter("tipo_servicio"+i));
	cd.addColValue("other3", "O");
	cd.addColValue("compania", (String)session.getAttribute("_companyId"));
	FAC.getAlDet().add(cd);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	CafMgr.addFactura(FAC);
	ConMgr.clearAppCtx(null);
	String docId = CafMgr.getPkColValue("doc_id");
	%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function printFact()
{   var tipoDocto='';
	var tipo = '<%=request.getParameter("tipo_docto")%>';
	if(tipo=='NCR'){ tipo = 'NC';tipoDocto='NCP';}
	else if(tipo=='NDB'){ tipo = 'ND';tipoDocto='NDP';}
	 
	var x = splitCols(getDBData('<%=request.getContextPath()%>','id, codigo', 'tbl_fac_dgi_documents d',' exists (select null from tbl_fac_trx t where t.other3 = d.codigo and t.company_id = d.compania and t.doc_id = <%=docId%>) and tipo_docto=\''+tipoDocto+'\''));
	showPopWin('../common/run_process.jsp?fp=nota_ajuste_otros&actType=2&docType=DGI&docId='+x[0]+'&docNo='+x[1]+'&tipo='+tipo+'&ruc=<%=request.getParameter("ruc")%>',winWidth*.75,winHeight*.80,null,null,'');
}

function closeWindow()
{
<%
if (CafMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CafMgr.getErrMsg()%>');
	printFact();
	//window.close();
<%
} else throw new Exception(CafMgr.getErrMsg());
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>