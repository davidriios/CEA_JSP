<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList alRefType = new ArrayList();
ArrayList alRefType2 = new ArrayList();

String key = "";
String sql = "";
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String com = request.getParameter("com");
String fp = request.getParameter("fp");
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (com == null) com = (String) session.getAttribute("_companyId");

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{

sbSql.append("select get_sec_comp_param(-1, 'TP_CLIENTE_OTROS') TP_CLIENTE_OTROS, NVL(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'MOROSIDAD_EXC_REF_TYPE'), 'NA') MOROSIDAD_EXC_REF_TYPE, NVL(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'MOROSIDAD_EXC_SUB_ID_OC'), 'NA') MOROSIDAD_EXC_SUB_ID_OC,NVL(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'CXC_PROC_MOROSIDAD'), 'MOR') as proc_morosidad from dual");
CommonDataObject _cd = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = ");
sbSql.append(com);

if(_comp.getHospital().trim().equals("S")){
sbSql.append(" and (resp_pac='S' or refer_to = 'CXCO' or (get_sec_comp_param(");
sbSql.append(com);
sbSql.append(", 'MOR_CXC_USA_SM') = 'S' and to_char(codigo) = get_sec_comp_param(");
sbSql.append(com);
sbSql.append(", 'TIPO_CLIENTE_SOC_MED')))");
sbSql.append(" and codigo != get_sec_comp_param(");
sbSql.append(com);
sbSql.append(", 'TP_CLIENTE_PAC')");}
sbSql.append(" and activo_inactivo = 'A' order by 2 ");
System.out.println("SQL: "+sbSql);
alRefType = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
alRefType2 = sbb.getBeanList(ConMgr.getConnection(),"select id as optValueColumn, descripcion as optLabelColumn, descripcion as optTitleColumn from tbl_cxc_tipo_otro_cliente where compania ="+session.getAttribute("_companyId")+" and estado ='A' order by 2",CommonDataObject.class);

	  sql = "select 'Ultimo registro de Morosidad Generado hasta el dia '||fecha||' generado por el usuario: '||upper(usuario_generacion)||' el dia '||to_char(max(fecha_generacion) ,'dd/mm/yyyy hh12:mi am') msg from  tbl_cxc_morosidades where  cia= "+(String) session.getAttribute("_companyId")+" group by 'Ultimo registro de Morosidad Generado hasta el dia '||fecha||' generado por el usuario: '||upper(usuario_generacion)||' el dia ' ";
	cdo = SQLMgr.getData(sql);
	if(cdo ==null){cdo = new CommonDataObject(); cdo.addColValue("msg","");}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Reporte de Morosidad- '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function doAction()
{
}
function showReporte(tipo)
{
var msg='';
var fecha=document.form0.fecha.value;
var categoria='';if(document.form0.categoria)categoria=document.form0.categoria.value;
var aseguradora='';if(document.form0.aseguradora)aseguradora=document.form0.aseguradora.value;
var ex_tipo_clte='';if(document.form0.ex_tipo_clte)ex_tipo_clte=document.form0.ex_tipo_clte.value;
var ex_sub_tipo_clte='';if(document.form0.ex_sub_tipo_clte)ex_sub_tipo_clte=document.form0.ex_sub_tipo_clte.value;
var tipo_cta=document.form0.tipoCuenta.value;
var pacId=document.form0.pacId.value;
var refType=document.form0.refType.value;
var subRefType=document.form0.subRefType.value;
var mostrar_facturas=document.form0.mostrar_facturas.value;
var fact_apli=document.form0.fact_apli.value;
//var forBI = (eval('document.form0.pOption').checked);
var pCtrlHeader = $("#pCtrlHeader").is(":checked");
if(fecha == "")msg = 'Fecha';
if(msg == ""){

if (tipo=="DE"){
	var gCat=$('#groupCat').is(":checked")?'Y':'N';
  abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc20040tcopy.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader+'&tipoClteOtrosParam=<%=_cd.getColValue("TP_CLIENTE_OTROS")%>&exRefTypeParam='+(ex_tipo_clte||'ALL')+'&exSubRefTypeParam='+(ex_sub_tipo_clte||'ALL')+'&factApliParam='+(fact_apli||'ALL')+'&pGroupCat='+gCat);
}
else if (tipo=="RE"){
  abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_morosidad_resumida.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader+'&tipoClteOtrosParam=<%=_cd.getColValue("TP_CLIENTE_OTROS")%>&exRefTypeParam='+(ex_tipo_clte||'ALL')+'&exSubRefTypeParam='+(ex_sub_tipo_clte||'ALL')+'&factApliParam='+(fact_apli||'ALL'));
}else if (tipo=="UB"){
  abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_morosidad_unbill_resumida.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader);
}
else if (tipo=="UBD"){
  abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_morosidad_unbill_detallada.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader);
}
else if (tipo=="C"){
	if(tipo_cta=='A' || tipo_cta=='E') abrir_ventana2('../cxc/print_morosidad_res_consolidada.jsp?fecha='+fecha+'&categoria='+categoria+'&aseguradora='+aseguradora+'&tipo_cta='+tipo_cta+'&pacId='+pacId+'&refType='+refType+'&subRefType='+subRefType+'&mostrar_factura='+mostrar_facturas);
	else alert('Solo para Aseguradoras!');
	//abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_morosidad_res_consolidada.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader);
}else if (tipo=="CBNF"){
	if(tipo_cta=='A' || tipo_cta=='E') abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc_morosidad_res_cons_nf.rptdesign&fechaParam='+fecha+'&aseguradoraParam='+(aseguradora||'ALL')+'&pCtrlHeader='+pCtrlHeader);
	else alert('Solo para Aseguradoras!');
	//abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_morosidad_res_consolidada.rptdesign&pFecha='+fecha+'&pCategoria='+(categoria||'ALL')+'&pAseguradora='+(aseguradora||'ALL')+'&pTipoCta='+(tipo_cta||'ALL')+'&pPacId='+(pacId||'ALL')+'&pRefType='+(refType||'ALL')+'&pSubRefType='+(subRefType||'ALL')+'&pMostrarFactura='+(mostrar_facturas||'ALL')+'&pCtrlHeader='+pCtrlHeader);
}
else if (tipo=="CB"){
	if(tipo_cta=='A' || tipo_cta=='E') abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_cxc_morosidad_res_cons.rptdesign&fechaParam='+fecha+'&aseguradoraParam='+(aseguradora||'ALL')+'&pCtrlHeader='+pCtrlHeader);
	else alert('Solo para Aseguradoras!');
	
}
else
if(tipo=='D') abrir_ventana2('../cxc/print_cxc20040tcopy.jsp?fecha='+fecha+'&categoria='+categoria+'&aseguradora='+aseguradora+'&tipo_cta='+tipo_cta+'&pacId='+pacId+'&refType='+refType+'&subRefType='+subRefType+'&mostrar_factura='+mostrar_facturas+'&ex_tipo_clte='+ex_tipo_clte+'&ex_sub_tipo_clte='+ex_sub_tipo_clte);
else if(tipo=='R') abrir_ventana2('../cxc/print_morosidad_resumida.jsp?fecha='+fecha+'&categoria='+categoria+'&aseguradora='+aseguradora+'&tipo_cta='+tipo_cta+'&pacId='+pacId+'&refType='+refType+'&subRefType='+subRefType+'&mostrar_factura='+mostrar_facturas+'&ex_tipo_clte='+ex_tipo_clte+'&ex_sub_tipo_clte='+ex_sub_tipo_clte);
else if(tipo=='UD') abrir_ventana2('../cxc/print_unbill_detallada.jsp?fecha='+fecha+'&categoria='+categoria+'&aseguradora='+aseguradora+'&tipo_cta='+tipo_cta+'&pacId='+pacId);
else abrir_ventana2('../cxc/print_unbill_resumida.jsp?fecha='+fecha+'&categoria='+categoria+'&aseguradora='+aseguradora+'&tipo_cta='+tipo_cta+'&pacId='+pacId);
}else alert('Introduzca Valor en el campo Fecha' );
}

function showEmpresaList(){if(document.form0.tipoCuenta.value!='O')abrir_ventana1('../common/search_empresa.jsp?fp=morosidad');else alert('Tipo de Cuenta invalida!!!');}
function showPacienteList(){var tipoCta=document.form0.tipoCuenta.value;var subRefType=document.form0.subRefType.value;if(tipoCta!=''){if(tipoCta=='O'){if(document.form0.refType.value!='')abrir_ventana1('../pos/sel_otros_cliente.jsp?fp=morosidad&tipo_factura=&ref_id='+document.form0.refType.value+'&Refer_To='+getSelectedOptionTitle(document.form0.refType,'CXCO')+'&subRefType='+subRefType);}else abrir_ventana1('../common/search_paciente.jsp?fp=morosidad');}else alert('Seleccione Tipo de Cuenta');}

function genMorosidad(){var fecha=document.form0.fecha.value;if(fecha.trim()==''){CBMSG.warning('Introduzca una Fecha válida!');return false;}var tipoCuenta=document.form0.tipoCuenta.value;if(tipoCuenta=='')tipoCuenta='T';var aseguradora='';if(document.form0.aseguradora)aseguradora=document.form0.aseguradora.value;var categoria='';if(document.form0.categoria)categoria=document.form0.categoria.value;

var msg2 = getDBData('<%=request.getContextPath()%>',"(select count(*) from v$locked_object a, all_objects b where a.object_id = b.object_id and b.object_name= 'tbl_cxc_morosidades') ",'dual','');

if(msg2=='0')generar ='S';
else{ CBMSG.warning(' \nExiste otro usuario generando el proceso de  morosidad. !!');generar ='N';}

if(generar=='S'){
var msg = getDBData('<%=request.getContextPath()%>','(select \'Existen registros de Morosidad Generado hasta el dia \'||fecha||\' generados por el usuario: \'||upper(usuario_generacion)||\' el dia \'||to_char(max(fecha_generacion) ,\'dd/mm/yyyy hh12:mi am\') msg from  tbl_cxc_morosidades where  cia= <%=(String) session.getAttribute("_companyId")%> group by \'Existen registros de Morosidad Generado hasta el dia \'||fecha||\' generados por el usuario: \'||upper(usuario_generacion)||\' el dia \')','dual','');
var generar ='';
var tipoFecha = document.form0.tipo_fecha.value;

if(msg!=''){CBMSG.confirm(""+msg+' \nDesea Generar la Morosidad nuevamente!!',{'cb':function(r){
   if(r=='Si'){
   showPopWin('../common/run_process.jsp?fp=MOR&actType=50&docType=<%=_cd.getColValue("proc_morosidad")%>&fecha='+fecha+'&tipoCuenta='+tipoCuenta+'&aseguradora='+aseguradora+'&categoria='+categoria+'&compania=<%=session.getAttribute("_companyId")%>&tipo='+tipoFecha,winWidth*.75,winHeight*.65,null,null,'');
}
}});
}else generar ='S';

/*
//if(msg!='')if(!confirm(msg+'  \nDesea Generar la Morosidad nuevamente!!')){generar='N';}
alert('2');
CBMSG.confirm("fffdfdfdfd");
alert('3');*/
if(generar=='S'){
showPopWin('../common/run_process.jsp?fp=MOR&actType=50&docType=MOR&fecha='+fecha+'&tipoCuenta='+tipoCuenta+'&aseguradora='+aseguradora+'&categoria='+categoria+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');}
}
}
function checkTipo(obj)
{
	var tipoCuenta=document.form0.tipoCuenta.value;
	if(tipoCuenta!='O'){alert("Valido Solo para 'OTROS CLIENTES'");obj.blur();}

}
function checkTipoRef(obj)
{
	if(getSelectedOptionTitle(document.form0.refType,'')!='CXCO'){alert("Valido Solo para 'CTAS X COBRAR OTROS'");obj.blur();}

}

function clearReType(value){if(document.form0.aseguradora)document.form0.aseguradora.value='';if(document.form0.aseguradoraDesc)document.form0.aseguradoraDesc.value='';if(document.form0.pacId)document.form0.pacId.value='';if(document.form0.nombre)document.form0.nombre.value='';if(value!='O'){document.form0.refType.value='';}if(getSelectedOptionTitle(document.form0.refType,'')!='CXCO'){document.form0.subRefType.value='';}
if(document.form0.tipoCuenta.value=='A'){
	document.getElementById("lbl_filtro_fecha").style.display='';
	document.getElementById("lbl_tr_filtro_fecha").style.display='';
} else {
	document.getElementById("lbl_filtro_fecha").style.display='none';
	document.getElementById("lbl_tr_filtro_fecha").style.display='none';
	document.form0.tipo_fecha.value='FF';
	document.form0.mostrar_facturas.value='';
	}
}
function clearSubReType(){if(getSelectedOptionTitle(document.form0.refType,'')!='CXCO'){document.form0.subRefType.value='';}document.form0.pacId.value='';
	document.form0.nombre.value='';}
function getRes(r){debug(">>> "+r);}


$(document).ready(function(){

  $("#addReporteXcel").click(function(c){
    showReporte('DE');
  });
  $("#addReporteRXcel").click(function(c){
    showReporte('RE');
  });
  $("#addReporteUXcel").click(function(c){
    showReporte('UB');
  });
  $("#addReporteUXDcel").click(function(c){
    showReporte('UBD');
  });
	  $("#addReporteCXcel").click(function(c){
    showReporte('CB');
  });
    $("#addReporteCXNFcel").click(function(c){
    showReporte('CBNF');
  });
  
  
  
  $("#rptAnalisis").click(function(c){
    var fechaHasta = $("#fecha").toRptFormat() || '';
    var aseguradora = $("#aseguradora").val() || 'ALL' ;
    var tipoCta = $("#tipoCuenta").val() || 'ALL' ;
	var pCtrlHeader = $("#pCtrlHeader").is(":checked");
	var pExcludeZero = $("#pExcludeZero").is(":checked");
	
	if (!fechaHasta) alert('Por favor provee la fecha "Hasta el día"!');
	else {
	   var rpt = $(this).attr('id');
	   
	   switch (rpt){
	     case 'rptAnalisis' :
		   abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=cxc/rpt_analisis_cxc.rptdesign&fHasta='+fechaHasta+'&pAseguradora='+aseguradora+'&pTipoCta='+tipoCta+'&pCtrlHeader='+pCtrlHeader+'&pExcludeZero='+pExcludeZero);
		 break;
	     default: alert("No encontramos el reporte!");
	   }

	
	}
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE MOROSIDAD"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>

		<table align="center" width="75%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
				<tr class="TextHeader">
							<td colspan="3"><cellbytelabel><%=fp.equalsIgnoreCase("analisis_cxc")?"Análisis de Cuenta Por Cobrar":"Reporte de Morosidad"%></cellbytelabel></td>
				</tr>
				<%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
				<tr class="TextRow02">
                    <td colspan="3" class="Link05"><font size="+1"><%=cdo.getColValue("msg")%></font></td>
                </tr>
				<%}%>
				<tr class="TextRow01">
					<td width="20%"><cellbytelabel>Hasta el d&iacute;a</cellbytelabel></td>
					<td width="55%">
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="clearOption" value="true"/>
						<jsp:param name="nameOfTBox1" value="fecha"/>
						<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>"/>
					</jsp:include>
					</td>
					<td width="30%"  align="center" valign="middle">
					<%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
					<authtype type='50'><%=fb.button("ejecutar","Generacion",true,false,"Text10",null,"onClick=\"javascript:genMorosidad()\"")%></authtype>
					<%}%>
					</td>
				</tr>


				<%
				String tipoCta="";
				if(_comp.getHospital().trim().equals("S")){
					tipoCta="A=ASEGURADORA,P=PARTICULAR,J=JUBILADO,";
				}
				tipoCta+="O=OTROS CLIENTES";
				if (fp.equalsIgnoreCase("analisis_cxc") ){
				   tipoCta="E=ASEGURADORA";
				}
				%>

				<tr class="TextRow01">
					<td><cellbytelabel>Tipo de cuenta</cellbytelabel></td>
					<td><%=fb.select("tipoCuenta",tipoCta,"",false,false,0,"Text10",null,(!fp.equalsIgnoreCase("analisis_cxc")?"onChange=\"javascript:clearReType(this.value)\"":""),null,!fp.equalsIgnoreCase("analisis_cxc")
					?"T":"")%>
					
					<%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
					<label id="lbl_filtro_fecha" style="display:none">Calcular Morosidad en base a <%=fb.select("tipo_fecha","FF=FECHA FACTURA, FE=FECHA DE ENVIO","",false,false,0,"Text10",null,"",null,"")%></label>
					<br>
					&nbsp;&nbsp;Tipo Otros Cliente<%=fb.select("refType",alRefType,cdo.getColValue("refType"),false,false,0,"Text10",null,"onFocus=\"javascript:checkTipo(this)\" onChange=\"javascript:clearSubReType(this)\"",null,"S")%><br>
					&nbsp;&nbsp;Sub Tipo Otros<%=fb.select("subRefType",alRefType2,cdo.getColValue("refType2"),false,false,0,"Text10",null,"onFocus=\"javascript:checkTipoRef(this)\"",null,"S")%>
					<%}%>
					</td>
					<td width="25%" rowspan="6" align="center" valign="middle">
          	<table width="100%">
			<tr><td colspan="2">
				<input type="checkbox" id="pCtrlHeader" name="pCtrlHeader">
				<label for="pCtrlHeader">Esconder cabecera (Excel)</label>
				<%if (fp.equalsIgnoreCase("analisis_cxc") ){%>
					<br />
					<input type="checkbox" id="pExcludeZero" name="pExcludeZero">
					<label for="pExcludeZero">Excluir 0?</label>
				<%}%>
			</td></br />
			    <%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
          		<tr>
          			<td width="85%"><%=fb.button("addReporteC","CONSOLIDADO PDF",false,false,null,null,"onClick=\"javascript:showReporte('C')\"","Reporte de Morosidad Resumido")%>
					<br>
					<%=fb.button("addReporteCXNFcel","CONSOLIDADO Excel NF ",false,false,null,null,"","")%>
					
					</td>
					<td><%=fb.button("addReporteCXcel","Excel",false,false,null,null,"","")%></td>
          		</tr>
          		<tr>
          			<td width="85%" align="right"><%=fb.checkbox("groupCat","Y",true,false,null,null,null)%><label for="groupCat">Agrupar por Categor&iacute;a</label><%//=fb.button("addReporte","Reporte Detallado",false,false,null,null,"onClick=\"javascript:showReporte('D')\"","Reporte de Morosidad Detallado")%></td>
					<td><%=fb.button("addReporteXcel","Excel Detallado",false,false,null,null,"","")%></td>
          		</tr>
          		<tr>
          			<td align="left"><%//=fb.button("addReporteR","Reporte Resumido",false,false,null,null,"onClick=\"javascript:showReporte('R')\"","Reporte de Morosidad Resumido")%></td>
					<td><%=fb.button("addReporteRXcel","Excel Resumido",false,false,null,null,"","")%></td>
          		</tr>
          		<tr>
          			<td align="left"><%=fb.button("addReporteU","Reporte No Facturadas Resumido",false,false,null,null,"onClick=\"javascript:showReporte('U')\"","Reporte No Facturadas Resumido")%></td>
					<td><%=fb.button("addReporteUXcel","Excel",false,false,null,null,"","")%></td>
          		</tr>
				<tr>
          			<td align="left"><%=fb.button("addReporteUD","Reporte No Facturadas Detallado",false,false,null,null,"onClick=\"javascript:showReporte('UD')\"","Reporte No Facturadas Detallado")%></td>
					<td><%=fb.button("addReporteUXDcel","Excel",false,false,null,null,"","")%></td>
          		</tr>
				<%}else{%>
				 <tr>
          			<td align="left"><%=fb.button("rptAnalisis","Reporte Detallado",false,false,null,null,"","Reporte de Unbill Resumido")%></td>
					<td><%//=fb.button("rptAnalisisXcel","Excel",false,false,null,null,"","")%></td>
          		  </tr>
				<%}%>
          	</table>
					</td>
				</tr>
				<tr id="lbl_tr_filtro_fecha" style="display:none"class="TextRow01">
					<td><cellbytelabel>Mostrar Facturas</cellbytelabel></td>
					<td><%=fb.select("mostrar_facturas","E=ENVIADAS, N=NO ENVIADAS","",false,false,0,"Text10",null,"",null,"T")%>&nbsp;&nbsp;&nbsp;Aplicadas?<%=fb.select("fact_apli","S=Si, N=NO","",false,false,0,"Text10",null,"",null,"T")%></td>
					<td><cellbytelabel>&nbsp;</cellbytelabel></td>
				</tr>	
				<%if(_comp.getHospital().trim().equals("S")){%>
				<%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
				<tr class="TextRow01">
					<td><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(), "select to_char(codigo),descripcion from tbl_adm_categoria_admision union select '-1','SIN CATEGORIA' from dual  ", "categoria", "",false,false,0,"T")%></td>
				</tr>
				<%}%>
				<tr class="TextRow01">
					<td><cellbytelabel>Aseguradora</cellbytelabel></td>
					<td><%=fb.textBox("aseguradora","",false,false,false,10,"Text10",null,null)%>
				<%=fb.textBox("aseguradoraDesc","",false,false,true,40,"Text10",null,null)%>
				<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%></td>
				</tr>
				<%}%>

				<%if (!fp.equalsIgnoreCase("analisis_cxc") ){%>
				<tr class="TextRow01">
					<td><cellbytelabel><%=(_comp.getHospital().trim().equals("S"))?"Paciente/Cliente":"Clientes"%></cellbytelabel></td>
					<td><%=fb.textBox("pacId","",false,false,false,10,"Text10",null,null)%>
				<%=fb.textBox("nombre","",false,false,true,40,"Text10",null,null)%>
				<%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%></td>
				</tr>
				<%}%>
				<%if(_cd!=null && _cd.getColValue("MOROSIDAD_EXC_REF_TYPE")!=null && !_cd.getColValue("MOROSIDAD_EXC_REF_TYPE").equals("NA")){%>
				<%=fb.hidden("ex_tipo_clte",_cd.getColValue("MOROSIDAD_EXC_REF_TYPE"))%>
				<%}%>
				<%if(_cd!=null && _cd.getColValue("MOROSIDAD_EXC_SUB_ID_OC")!=null && !_cd.getColValue("MOROSIDAD_EXC_SUB_ID_OC").equals("NA")){%>
				<%=fb.hidden("ex_sub_tipo_clte",_cd.getColValue("MOROSIDAD_EXC_SUB_ID_OC"))%>
				<%}%>



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
%>