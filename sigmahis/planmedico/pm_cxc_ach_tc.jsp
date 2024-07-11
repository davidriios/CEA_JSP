<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String key = "";
StringBuffer sbSql =new StringBuffer();
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String id = request.getParameter("id");
String change = request.getParameter("change");
String tipo_trx = request.getParameter("tipo_trx");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String contrato = request.getParameter("num_contrato");
String agrupa_hon = request.getParameter("agrupa_hon");
String cDateTime = CmnMgr.getCurrentDate("mm/yyyy");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(mes == null) mes =cDateTime.substring(0, 2);
if(anio == null) anio = cDateTime.substring(3, 7);
if(id==null) id = "";


if(contrato==null) contrato = "";
if(fg==null) fg = "";
if(fp==null) fp = "";
if(id==null) id = "0";
if(tipo_trx==null) tipo_trx = "ACH";
if(agrupa_hon==null) agrupa_hon = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	
	if(mode.equals("add")){
		cdo.addColValue("mes", mes);
		cdo.addColValue("anio", anio);
		cdo.addColValue("id", id);
		cdo.addColValue("tipo_trx", tipo_trx);

	sbSql.append("select id id_contrato, id_cliente, (select nombre_paciente from vw_pm_cliente where codigo = c.id_cliente) nombre_cliente, decode(forma_pago, 1, 'TC', 2, 'ACH') tipo_trx, fecha_ini_plan, cuota_mensual monto, id_corredor, 0 secuencia, 'P' estado, 'Activo' estado_desc, NVL((select periodo from tbl_pm_cta_tarjeta t where t.id_solicitud = c.id and t.estado = 'A'), 1) periodo from tbl_pm_solicitud_contrato c where estado = 'A'");
	sbSql.append(" and trunc(c.fecha_ini_plan) <= to_date(to_char(sysdate, 'dd')||'/'||lpad(");
	sbSql.append(mes);
	sbSql.append(", 2, '0')||'/'||'");
	sbSql.append(anio);
	sbSql.append("', 'dd/mm/yyyy')");
	if(contrato!=null && !contrato.equals("")){
		sbSql.append(" and c.id = ");
		sbSql.append(contrato);
	}
	sbSql.append(" and not exists (select null from tbl_pm_regtran r, tbl_pm_regtran_det rd where r.id = rd.id and rd.id_cliente = c.id_cliente and rd.id_contrato = c.id and r.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and trunc(c.fecha_ini_plan) >= to_date(to_char(sysdate, 'dd')||'/'||'");
	sbSql.append(mes);
	sbSql.append("/");
	sbSql.append(anio);
	sbSql.append("', 'dd/mm/yyyy')");
	
	if(!anio.equals("")){ sbSql.append(" and r.anio = ");sbSql.append(anio);}
	if(!mes.equals("")){ sbSql.append(" and r.mes = ");sbSql.append(mes);}
	sbSql.append(" and r.estado in ('A', 'P') and r.tipo_trx in ('ACH','TC')) and not exists (select null from tbl_pm_factura f where f.id_sol_contrato = c.id and f.anio = ");
	sbSql.append(anio);
	sbSql.append(" and f.mes = ");
	sbSql.append(mes);
	sbSql.append(" and f.id_regtran is not null)");
	if(tipo_trx.equals("ACH")) sbSql.append(" and c.forma_pago = 2");
	else if(tipo_trx.equals("TC")) sbSql.append(" and c.forma_pago = 1");
	else sbSql.append(" and forma_pago in (1, 2)");
	sbSql.append(" order by id_cliente");
	
	al = SQLMgr.getDataList(sbSql.toString());
	} else {
		sbSql.append("select id, anio, mes, tipo_trx, estado from tbl_pm_regtran where id = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
		if(!cdo.getColValue("estado").equals("P")) viewMode = true;
		sbSql = new StringBuffer();
		sbSql.append("select id, secuencia, id_contrato, id_cliente, (select nombre_paciente from vw_pm_cliente where codigo = a.id_cliente) nombre_cliente, estado, tipo_trx, monto, monto_app, id_corredor, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, periodo from tbl_pm_regtran_det a where id = ");
		sbSql.append(id);
		al = SQLMgr.getDataList(sbSql.toString());
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();if(document.contrato.rb){setEncValues(getRadioButtonValue(document.contrato.rb))}}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doSubmit(value){
	document.contrato.action.value = value;var mes = document.contrato.mes.value;var anio = '';if(document.contrato.anio.value!='') anio = document.contrato.anio.value; if(mes==''||anio==''){alert('Introduzca valores en campos de Mes / Año!');}else {
		var size = document.contrato.keySize.value;
		for(i=0;i<size;i++){
			if(eval('document.contrato.generar'+i).checked){
				
			}
		}
		document.contrato.submit();
	}
}
function reloadPage(){var anio = '';var num_contrato = '';if(document.contrato.anio.value!='') anio = document.contrato.anio.value;var mes = document.contrato.mes.value;var tipo = document.contrato.tipo_trx.value; if(document.contrato.num_contrato.value!='') num_contrato = document.contrato.num_contrato.value; var mode=document.contrato.mode.value; window.location = '../planmedico/pm_cxc_ach_tc.jsp?mes='+mes+'&anio='+anio+'&tipo_trx='+tipo+'&mode='+mode;}
function chkRB(i){checkRadioButton(document.contrato.rb, i);}
function calcT(i){
}

function chkCeroRegisters(){var size = document.contrato.keySize.value;var x = 0;if(document.contrato.action.value!='Guardar') return true;else {for(i=0;i<size;i++){if(eval('document.contrato.generar'+i).checked){x++;break;}}if(x==0) {alert('Seleccione al menos un Contrato!');return false;} else return true;}}
function setAll(){var size = document.contrato.keySize.value;for(i=0;i<size;i++){eval('document.contrato.generar'+i).checked = document.contrato.generar.checked;}}
/*
function chkDateHon(){if(confirm('Al cambiar de fecha se Estará actualizando la informacion mostrada en pantalla. Desea Continuar????')){reloadPage();}else{document.contrato.fechaDesde.value='<%//=fechaDesde%>';document.contrato.fecha.value='<%//=fecha%>';}}
*/
/*
function printReport(){
	var fDesde = document.contrato.fechaDesde.value;
	var fHasta = document.contrato.fecha.value;
	var tipo = document.contrato.tipo.value;
	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_detalle_contrato.rptdesign&fDesdeParam="+fDesde+"&fHastaParam="+fHasta+"&tipoBenParam="+tipo);
}
*/
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="HONORARIOS MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0"  id="_tblMain">
	<tr>
		<td class="TableBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td colspan="6" align="right"><authtype type='2'><!--<a href="javascript:printReport()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a>--></authtype>
					</td>
				</tr>
				<tr>
					<td colspan="6"><table align="center" width="100%" cellpadding="0" cellspacing="1">
						<%fb = new FormBean("contrato",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("id",id)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("saveOption","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("codigo","")%>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>REGISTRO TRANSACCIONES DE ACH/TARJETA DE CREDITO</cellbytelabel></td>
							</tr>
							<tr class="TextFilter">
								<td align="left" colspan="8">
								A&ntilde;o: <%=fb.textBox("anio",cdo.getColValue("anio"),false,false,false,5,4,"Text12","","")%>
								Mes: <%=fb.select("mes","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("mes"),false,false,false,0,"Text12","","")%>
								<%=fb.button("consultar","Consultar",true,viewMode,"","","onClick=\"javascript: reloadPage();\"")%>&nbsp;&nbsp;
								Tipo:
								<%=fb.select("tipo_trx","ACH=ACH,TC=TARJETA DE CREDITO",cdo.getColValue("tipo_trx"),false,false,false,0,"Text10","","")%>
								Num. Contrato:
								<%=fb.textBox("num_contrato",contrato,false,false,false,5,4,"Text12","","")%>
								<authtype type='6'>
								<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%></authtype>
								</td>
							</tr>
							<tr class="">
								<td colspan="8">
								<div id="_cMain" class="Container">
								<div id="_cContent" class="ContainerContent">
								<table align="center" width="99%" cellpadding="0" cellspacing="1">
									<tr class="TextHeader02" >
									<td align="center" width="10%"><cellbytelabel>Contrato</cellbytelabel></td>
									<td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
									<td align="center" width="48%"><cellbytelabel>Beneficiario</cellbytelabel></td>
									<td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
									<td align="center" width="10%"><cellbytelabel>Monto Total</cellbytelabel></td>
									<td align="center" width="10%"><cellbytelabel>Estado</cellbytelabel></td>
									<td align="center" width="2%"><%=fb.checkbox("generar","", false, false, "", "", "onClick=\"javascript:setAll();\"")%></td>
									</tr>
							<%
							System.out.println("al.size()="+al.size());
							for (int i=0; i<al.size(); i++){
								CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
							%>
							<%=fb.hidden("id_cliente"+i,OP.getColValue("id_cliente"))%>
							<%=fb.hidden("id_corredor"+i,OP.getColValue("id_corredor"))%>
							<%=fb.hidden("id_contrato"+i,OP.getColValue("id_contrato"))%>
							<%=fb.hidden("tipo_trx"+i,OP.getColValue("tipo_trx"))%>
							<%=fb.hidden("secuencia"+i,OP.getColValue("secuencia"))%>
							<%=fb.hidden("nombre_cliente"+i,OP.getColValue("nombre_cliente"))%>
							<%=fb.hidden("periodo"+i,OP.getColValue("periodo"))%>

							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
								<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_contrato")%> </td>
								<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_cliente")%> </td>
								<td align="left" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("nombre_cliente")%> </td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("monto"+i,OP.getColValue("monto"),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Monto",false,"")%></td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal((Double.parseDouble(OP.getColValue("monto"))*Double.parseDouble(OP.getColValue("periodo")))),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Monto",false,"")%></td>
								<td align="center">
								<%if(mode.equals("edit")){%>
								<%=fb.select("estado"+i,"A=Activo,I=Inactivo",OP.getColValue("estado"),false,false,false,0,"Text10","","")%>
								<%} else {%>
								<%=OP.getColValue("estado_desc")%>
								<%}%>
								</td>
								<td align="center"><%=fb.checkbox("generar"+i,""+i)%></td>
							</tr>
							<%}%>
							<%=fb.hidden("keySize",""+al.size())%>
							</table>
							</div>
							</div>
							</td></tr>

						</table></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="6" align="right"></td>
				</tr>
				<%
				fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
				%>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String fecha_solicitud = CmnMgr.getCurrentDate("dd/mm/yyyy");
	Solicitud sol = new Solicitud();
	CommonDataObject cd = new CommonDataObject();
	if(mode.equals("add")){
		cd.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cd.addColValue("fecha_creacion", "sysdate");
	} else {
		cd.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cd.addColValue("fecha_modificacion", "sysdate");
		cd.addColValue("id", request.getParameter("id"));
	}
	cd.addColValue("anio", request.getParameter("anio"));
	cd.addColValue("mes", request.getParameter("mes"));
	cd.addColValue("tipo_trx", request.getParameter("tipo_trx"));
	cd.addColValue("compania", (String) session.getAttribute("_companyId"));
	sol.setCdo(cd);
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
			if(request.getParameter("estado"+i)!=null && request.getParameter("estado"+i).equals("")) cdo.addColValue("estado", "P");
			else cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("id_contrato", request.getParameter("id_contrato"+i));
			cdo.addColValue("id_cliente", request.getParameter("id_cliente"+i));
			cdo.addColValue("id_corredor", request.getParameter("id_corredor"+i));
			cdo.addColValue("monto", request.getParameter("monto"+i));
			cdo.addColValue("monto_app", request.getParameter("monto"+i));
			cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"+i));
			cdo.addColValue("periodo", request.getParameter("periodo"+i));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			else cdo.addColValue("secuencia", "0");
			if(mode.equals("add")){
				cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion","sysdate");
			} else {
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion","sysdate");
			}
			al.add(cdo);
		}
	}
	sol.setAl(al);
	if (request.getParameter("action").equals("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		if(mode.equals("add")) {
			SolMgr.addTrx(sol);
			id = SolMgr.getPkColValue("id");
		} else SolMgr.updateTrx(sol);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SolMgr.getErrCode().equals("1")){
%>
	alert('<%=SolMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/planmedico/pm_cxc_ach_tc.jsp?id=<%=id%>&mode=edit';
	window.opener.location = '../planmedico/pm_cxc_ach_tc_list.jsp';
<%
} else throw new Exception(SolMgr.getErrException());
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
