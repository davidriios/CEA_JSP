<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");

if(fg==null) fg = "";
if(fp==null) fp = "";
if (cod_banco == null) throw new Exception("El Banco no es válido. Por favor intente nuevamente!");
if (cuenta_banco == null) cuenta_banco = "";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select nombre nombre, '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" and cod_banco = '" + cod_banco + "'";
	cdo = SQLMgr.getData(sql);
	if(fechaini==null) fechaini = cdo.getColValue("fecha_ini");
	if(fechafin==null) fechafin = cdo.getColValue("fecha_fin");

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'BANCOS - '+document.title;
function doAction(){}
function setValues(){
var fechaini = document.form1.fechaini.value;
var fechafin = document.form1.fechafin.value;
var cuenta_banco = document.form1.cuenta_banco.value;
var tipo_doc = document.form1.tipo_doc.value;
var consecutivo = document.form1.consecutivo.value;
var voucher = document.form1.voucher.value;
var lib_cheque = document.form1.lib_cheque.value;

if(cuenta_banco.trim()=='')alert('Por favor seleccione la Cuenta Bancaria!');
else window.frames['itemFrame'].location = '../bancos/ver_mov_banco_det.jsp?cod_banco=<%=cod_banco%>&cuenta_banco='+cuenta_banco+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipo_doc='+tipo_doc+'&consecutivo='+consecutivo+'&voucher='+voucher+'&lib_cheque='+lib_cheque;
}

function printList(opt)
{
//var anio = document.form1.anio.value;
var fechaini = document.form1.fechaini.value;
var fechafin = document.form1.fechafin.value;
var cuenta_banco = document.form1.cuenta_banco.value;
var tipo_doc = document.form1.tipo_doc.value;
var lib_cheque = document.form1.lib_cheque.value;

if(cuenta_banco.trim()=='')alert('Por favor seleccione la Cuenta Bancaria!');
else {
  if(!opt) abrir_ventana('../bancos/print_banco_resumen.jsp?cod_banco=<%=cod_banco%>&cuenta_banco='+cuenta_banco+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipo_doc='+tipo_doc+'&lib_cheque='+lib_cheque);
  else {
    cod_banco = '<%=cod_banco%>' || 'NA';
    fechaini = fechaini || 'NA';
    fechafin = fechafin || 'NA';
    tipo_doc = tipo_doc || 'NA';
    lib_cheque = lib_cheque || 'NA';
    
    abrir_ventana('../cellbyteWV/report_container.jsp?reportName=banco/print_banco_resumen.rptdesign&pCtrlHeader=true&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipo_doc='+tipo_doc+'&lib_cheque='+lib_cheque);
  }
}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javacript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="BANCOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
							<tr>
								<td><table align="center" width="100%" cellpadding="0" cellspacing="1">
										<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
										<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
										<%=fb.formStart(true)%>
										<%=fb.hidden("mode",mode)%>
										<%=fb.hidden("errCode","")%>
										<%=fb.hidden("errMsg","")%>
										<%=fb.hidden("baction","")%>
										<%=fb.hidden("fg",fg)%>
										<%=fb.hidden("fp",fp)%>
										<%=fb.hidden("clearHT","")%>
										<tr>
											<td><table width="100%" cellpadding="1" cellspacing="0">


														<tr>
													<td colspan="2" align="right">&nbsp;</td>
													</tr>
													<tr class="TextPanel">
														<td colspan="1">Fecha
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="2"/>
														<jsp:param name="clearOption" value="true"/>
														<jsp:param name="nameOfTBox1" value="fechaini"/>
														<jsp:param name="valueOfTBox1" value="<%=fechaini%>"/>
														<jsp:param name="nameOfTBox2" value="fechafin"/>
														<jsp:param name="valueOfTBox2" value="<%=fechafin%>"/>
														<jsp:param name="fieldClass" value="text10"/>
														<jsp:param name="buttonClass" value="text10"/>
														</jsp:include>
														&nbsp;
														Tipo Docto.
														<%=fb.select("tipo_doc","DEP=DEPOSITO (BANCOS),DEPCAJA=DEPOSITO (CAJAS), ND=NOTA DE DEBITO, NC=NOTA DE CREDITO, CHK=CHEQUE,ACH=ACH,TRANSF=TRANSFERENCIAS,BAN=OTRAS TRANSACCIONES DE BANCOS,DEV=DEVOLUCIONES DE TARJETAS","",false,false,0, "text10", "", "", "", "T")%>
														</td>

																<td>Cuenta Bancaria
														<%=fb.select(ConMgr.getConnection(),"select cuenta_banco, cuenta_banco||' - '||descripcion from tbl_con_cuenta_bancaria where cod_banco = '"+cod_banco+"' and compania="+(String) session.getAttribute("_companyId")+"  order by descripcion","cuenta_banco",cuenta_banco,false,false,0, "text10", "", "", "", "S")%>

														</td>

													</tr>
							<tr class="TextPanel">
														<td colspan="1">Consecutivo<%=fb.textBox("consecutivo","",false,false,false,15,null,null,null)%>&nbsp;&nbsp;
														Libro Cheque:<%=fb.select("lib_cheque","S=SI,N=NO","",false,false,0, "text10", "", "", "", "T")%>
														
														</td>
														<td>No. Documento<%=fb.textBox("voucher","",false,false,false,15,null,null,null)%><%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:setValues();\"")%></td>

													</tr>
													
													<tr>
																<td align="right" colspan="2">
														<authtype type='0'>
														<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
														<a href="javascript:printList(1)" class="Link00">[ Excel ]</a>
														</authtype></td>
													</tr>

													<tr class="TextRow02" height="21">
														<td>C&oacute;digo de Banco:&nbsp;&nbsp;<%=cod_banco%></td>
														<td>Nombre del Banco:&nbsp;&nbsp;<%=cdo.getColValue("nombre")%></td>
													</tr>
												</table></td>
										</tr>
										<tr>
											<td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="400" scrolling="yes" src="../bancos/ver_mov_banco_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&cod_banco=<%=cod_banco%>&cuenta_banco=<%=cuenta_banco%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>"></iframe></td>
										</tr>
										<%=fb.formEnd(true)%>
										<!-- ================================   F O R M   E N D   H E R E   ================================ -->
									</table></td>
							</tr>
						</table></td>
				</tr>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Aplicar Accion de Ingreso") || request.getParameter("baction").equalsIgnoreCase("Anular Accion de Ingreso")){
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
<%
} else throw new Exception(errMsg);
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
