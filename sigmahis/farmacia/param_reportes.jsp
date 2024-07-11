
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String wh = request.getParameter("wh");
String fp = request.getParameter("fp");
String familyCode = "";
String classCode = "";
ArrayList alCaja = new ArrayList();

boolean viewMode = false;
if (fp == null) fp = "FAR";
String cDateTime = (fp.trim().equals("FAR"))?CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am"):CmnMgr.getCurrentDate("dd/mm/yyyy");

if (mode == null) mode = "add";
String compania = (String) session.getAttribute("_companyId");
String companiaRef = "";
try {companiaRef =java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){ companiaRef = "";}
if(companiaRef == null || companiaRef.trim().equals("")) companiaRef = "";
String compFar ="";
try {compFar =java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){ compFar = "";}
if(compFar == null || compFar.trim().equals("")) compFar = "";
CommonDataObject cdoP = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_USA_CAJA_TURNO'),'N') as validaCja,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_FAR_USA_TURNO'),'N') as validaTurno from dual");
if (cdoP==null) cdoP = new CommonDataObject();

if(cdoP.getColValue("validaCja").trim().equals("S")&&fp.trim().equals("FACT")){
	StringBuffer sbSql =  new StringBuffer();

	sbSql.append("select trim(to_char(z.codigo,'009')) as optValueColumn, z.codigo||' - '||z.descripcion as optLabelColumn, trim(to_char(z.no_recibo + 1,'00000009')) as optTitleColumn from tbl_cja_cajas z where z.compania = ");
	sbSql.append(compania);
	if (UserDet.getUserProfile().contains("0")) sbSql.append(" and z.estado = 'A'");
	else {
		sbSql.append(" and z.codigo in (");
		sbSql.append((String) session.getAttribute("_codCaja"));//cajas matriculadas en el IP de la PC que el usuario está conectado
		sbSql.append(") and z.ip = '");
		sbSql.append(request.getRemoteAddr());//muestre solo las que tengan registrado el IP
		sbSql.append("' and z.estado = 'A'");
		sbSql.append(" and exists (select null from tbl_cja_cajas_x_cajero y where compania_caja = z.compania and cod_caja = z.codigo and exists (select null from tbl_cja_cajera where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("' and estado = 'A' and cod_cajera = y.cod_cajero))");// and tipo in ('S','A')
	}
	sbSql.append(" order by z.descripcion");
	System.out.println("S Q L   CAJA =\n"+sbSql);
	alCaja = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	if (alCaja.size() == 0) throw new Exception("Este equipo no está definido como una Caja. Por favor consulte con su Administrador!");
	}



if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario Punto de Reorden- '+document.title;
function doAction(){}
function showReporte(value){
	var fechaini = eval('document.form0.fechaini').value;
		var fechafin = eval('document.form0.fechafin').value;
	var paciente = eval('document.form0.pacId').value || '0';
	var pacId = eval('document.form0.pacId').value;
	var admision = eval('document.form0.noAdmision').value || '0';
	var caja = "";
	var turno ="";
	if(eval('document.form0.cajaTrx'))caja=eval('document.form0.cajaTrx').value;
	if(eval('document.form0.turnoTrx'))turno = eval('document.form0.turnoTrx').value;
	var compId = '<%=compFar%>';//eval('document.form0.compId').value;
	var familia = '0';
	var clase = '0';
	if(eval('document.form0.familyCode'))familia = eval('document.form0.familyCode').value || '0';
	if(eval('document.form0.classCode'))clase = eval('document.form0.classCode').value || '0';
	var facturado ='ALL';

	if(value =='2')compId = '<%=compania%>';
	var fg =  ((value=='1'||value=='4'||value=='5')?'ME':'BM');

	if(value =='4')facturado ='N';
		if (value == '5'||value == '6'){
			var cat = document.getElementById("categoria").value;
			if (!pacId || !admision) CBMSG.error('Por favor seleccione un paciente!');
			else{ if (value == '6') fg='BM';
		abrir_ventana2("../farmacia/print_medicamentos_despachados.jsp?pacId="+pacId+"&fg="+fg+"&noAdmision="+admision+"&noOrden=&categoria_adm="+cat+'&fDesde='+fechaini+'&fHasta='+fechafin);}
		}
	else if(value =='7'){
	facturado = eval('document.form0.facturado').value;
	var articulo =  eval('document.form0.articulo').value;
	if (fechaini.trim() && fechafin.trim() )abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_cargos_no_fact.rptdesign&pacId='+paciente+'&noAdmision='+admision+'&fg='+fg+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pFamilia='+familia+'&pClase='+clase+'&pFg='+fg+'&pFacturado='+facturado+'&pCaja='+caja+'&pTurno='+turno+'&pCompId='+compId+'&pCtrlHeader='+document.getElementById("pCtrlHeader").checked+'&pArticulo='+articulo);
	else alert("Por favor indique un rango de fecha!");
	}else if(value =='8'){facturado = eval('document.form0.facturado').value;
	var articulo =  eval('document.form0.articulo').value;
	if (fechaini.trim() && fechafin.trim() )abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_cargos_no_fact_res.rptdesign&pacId='+paciente+'&noAdmision='+admision+'&fg='+fg+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pFamilia='+familia+'&pClase='+clase+'&pFg='+fg+'&pFacturado='+facturado+'&pCaja='+caja+'&pTurno='+turno+'&pCompId='+compId+'&pCtrlHeader='+document.getElementById("pCtrlHeader").checked+'&pArticulo='+articulo);
	else alert("Por favor indique un rango de fecha!");
	}
	else if(value =='9'){facturado = eval('document.form0.facturado').value;
	if (fechaini.trim() && fechafin.trim() )abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_cargos_no_fact_cds.rptdesign&pacId='+paciente+'&noAdmision='+admision+'&fg='+fg+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pFamilia='+familia+'&pClase='+clase+'&pFg='+fg+'&pFacturado='+facturado+'&pCaja='+caja+'&pTurno='+turno+'&pCompId='+compId+'&pCtrlHeader='+document.getElementById("pCtrlHeader").checked);
	else alert("Por favor indique un rango de fecha!");
	}
	else if(value !='3'){
	if (fechaini.trim() && fechafin.trim() ) abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_cargos_ventas.rptdesign&pacId='+paciente+'&noAdmision='+admision+'&fg='+fg+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pFamilia='+familia+'&pClase='+clase+'&pFg='+fg+'&pFacturado='+facturado+'&pCompId='+compId+'&pCtrlHeader='+document.getElementById("pCtrlHeader").checked);
	else alert("Por favor indique un rango de fecha!");}
	else {if(pacId!=''){if(hasDBData('<%=request.getContextPath()%>','tbl_fac_transaccion','pac_id='+paciente+' and admi_secuencia='+admision+' and compania_ref=<%=compania%>',''))abrir_ventana('../facturacion/print_cargo_dev.jsp?fg=FAR&noSecuencia='+admision+'&pacId='+paciente);
				else alert('La admisión no tiene cargos registrados!');}else alert('Seleccione Paciente.!');}

}
function showPacienteList(){document.form0.pacId.value='';document.form0.noAdmision.value='';document.form0.nombre.value='';  abrir_ventana1('../common/sel_paciente.jsp?fp=farmacia');}
function facturar(tipo)
{
var fechaini = eval('document.form0.fechaini').value;
var fechafin = eval('document.form0.fechafin').value;
var validaCja ='<%=cdoP.getColValue("validaCja","N")%>';
var validaTurno ='<%=cdoP.getColValue("validaTurno","N")%>';
var cajaTrx = "";
	var turnoTrx ="";
	if(eval('document.form0.cajaTrx'))cajaTrx=eval('document.form0.cajaTrx').value;
	if(eval('document.form0.turnoTrx'))turnoTrx = eval('document.form0.turnoTrx').value;
var dsp ='S';

if((validaCja=='S'||validaTurno=='S'))
		{
				 var sizeCja = document.form0.sizeCja.value;
				setTurno();
			 if(document.form0.turno.value!=null && document.form0.turno.value!='')dsp='S';
			 else dsp='N';

		}
if(dsp=='S'){
showPopWin('../process/far_gen_facturas.jsp?fp=FACT&fechaIni='+fechaini+'&fechafin='+fechafin+'&companiaHosp=<%=companiaRef%>&compFar=<%=compFar%>&tipo='+tipo+'&turno='+document.form0.turno.value+'&caja='+document.form0.caja.value+'&validaCja='+validaCja+'&turnoTrx='+turnoTrx+'&cajaTrx='+cajaTrx,winWidth*.75,winHeight*.65,null,null,'');}else{CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');}


}
function setTurno(){ var turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=compania%> and a.cod_caja in(<%=(String) session.getAttribute("_codCaja")%>)	and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%> <%=(cdoP.getColValue("validaTurno").trim().equals("S"))?" and a.cod_turno in (select codigo from tbl_cja_turnos where cja_cajera_cod_cajera in (select cod_cajera from tbl_cja_cajera where usuario = \\\'"+(String) session.getAttribute("_userName")+"\\\'))":""%>');if(turno==undefined||turno==null||turno.trim()==''){document.form0.turno.value='';CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');return false;}else{document.form0.turno.value=turno;}return true;}
function showTurno()
{
var cajero = document.form0.cajero.value ;
if(cajero=='') alert('Seleccione Cajero!');
else abrir_ventana2('../caja/turnos_list.jsp?fp=farmacia&cod_cajera='+cajero);
}
function printDgiFact(docId,docNo,trxId,ruc)
{
	//alert("XXXX");
	 showPopWin('../common/run_process.jsp?fp=int_farmacia&actType=2&docType=DGI&docId='+docId+'&docNo='+docNo+'&tipo=FACP&ruc='+ruc,winWidth*.75,winHeight*.65,null,null,'');
}

</script>
<style>
	.shorter{width:142px;}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE INVENTARIO PUNTO DE REORDEN."></jsp:param>
	</jsp:include>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("categoria","")%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("sizeCja",""+alCaja.size())%>
			<%=fb.hidden("caja",""+(String) session.getAttribute("_codCaja"))%>
			<%=fb.hidden("turno","")%>
			<%=fb.hidden("cajaTrx","")%>
			<%=fb.hidden("ruc","")%>


		<tr class="TextFilter" >
					 <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
					 <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
			<jsp:param name="format" value="<%=(fp.trim().equals("FAR"))?"dd/mm/yyyy hh12:mi:ss am":"dd/mm/yyyy"%>" />

					<jsp:param name="nameOfTBox1" value="fechaini" />
					<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
					<jsp:param name="nameOfTBox2" value="fechafin" />
					<jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
					<jsp:param name="fieldClass" value="shorter" />
			</jsp:include>
							 </td>
				</tr>
		<%if(fp.trim().equals("FAR")){%>
		<tr class="TextFilter">
			<td>Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script></td>
		<td>Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?"":"document.form0.familyCode.value"%>,'KEY_COL','T');
		</script></td>
		</tr>
		<tr class="TextFilter"  >
			<td  colspan="2">
				<cellbytelabel>Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,true,15,"Text10",null,null)%>
				<%=fb.intBox("noAdmision","",false,false,true,10,"Text10",null,null)%>
				<%=fb.textBox("nombre","",false,false,true,40,"Text10",null,null)%>
				<%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
			</td>
			</tr>
		<tr class="TextHeader">
			<td colspan="2">Reportes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader" />
			<label for="pCtrlHeader">Esconder cabecera (Excel)</label>
			</td>
		</tr>
		<%}else{%>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,true,15,"Text10",null,null)%>
				<%=fb.intBox("noAdmision","",false,false,true,10,"Text10",null,null)%>
				<%=fb.textBox("nombre","",false,false,true,40,"Text10",null,null)%>
				<%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
			</td>
			<td>
					<!--<cellbytelabel>Cajero</cellbytelabel>
					<%//=fb.select(ConMgr.getConnection(),"select cod_cajera, lpad(cod_cajera, 3, '0') ||' - ' || nombre descripcion from tbl_cja_cajera where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","cajero","",false,false,0,"text10",null,"", "", "S")%>
					<cellbytelabel>Turno</cellbytelabel>
					<%//=fb.textBox("turnoTrx","",false,false,false,5)%>
					<%//=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%>-->
					<cellbytelabel>Facturado</cellbytelabel>
					<%=fb.select("facturado","S=SI,N=NO","N","")%>
			</td>
			</tr>
		<tr class="TextHeader">
			<td width="50%">Reportes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader" />
			<label for="pCtrlHeader">Esconder cabecera (Excel)</label>
			</td>
			<td width="50%" align="center">Proceso</td>


		</tr>
		<%}%>

		<!--<tr class="TextFilter"  >
			<td  colspan="2">
				<cellbytelabel>Compañia</cellbytelabel>
				<%//=fb.select(ConMgr.getConnection(),"select a.codigo, lpad(a.codigo,5,'0')||' - '||a.nombre from tbl_sec_compania a where a.estado = 'A'"+(UserDet.getUserProfile().contains("0")?"":" and exists (select null from tbl_sec_user_comp where user_id = "+UserDet.getUserId()+" and status = 'A' and company_id = a.codigo)")+" order by a.nombre","compId",(String) session.getAttribute("_companyId"),false,false,0,null,null,"")%>
			</td>
			</tr>-->


		<%if(fp.trim().equals("FAR")){%>
		<%//if(compania.trim().equals(compFar)){%>
		<authtype type='50'><tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de cargos(Farmacia)
			</td>
		</tr></authtype>
		<authtype type='52'><tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Detalle de Cargos (Solo Farmacia)
			</td>
		</tr></authtype>
		<authtype type='53'><tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","4",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de cargos No Facturados(Farmacia)
			</td>
		</tr></authtype>
		<%if(compania.trim().equals(companiaRef)){%>
		<authtype type='51'><tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de cargos(Banco de Medicamentos)
			</td>
		</tr></authtype><%}%>

				<authtype type='54'>
				 <tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Medicamentos Despachados
			</td>
				 </tr>
				</authtype>
		 <authtype type='55'>
				 <tr class="TextRow01">
			<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Medicamentos Despachados BM
			</td>
				 </tr>
				</authtype>

		<%}else{%>
		<authtype type='56'>

		 <tr class="TextRow01">
			<td>
			Articulo:<%=fb.intBox("articulo","",false,false,false,10)%><br>
			<%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos  Detallado</td>
			<td width="50%" rowspan="3" align="center">
					<%=fb.button("repRes","GENERAR FACTURA / NOTA CREDITO",true,false,null,null,"onClick=\"javascript:facturar('R')\"")%>&nbsp;
				</td>
		 </tr>
		 <tr class="TextRow01">
			<td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos Resumido</td>
		</tr>
		<tr class="TextRow01">
			<td><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos por CDS</td>
		</tr>



				</authtype>

		<%}%>


		</table>
</td></tr>

		<tr><td>&nbsp;</td></tr>


	<%fb.appendJsValidation("if(error>0)doAction();");%>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>
</body>
</html>
<%
}//GET
%>
