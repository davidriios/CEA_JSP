<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
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
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String tipo_orden = request.getParameter("tipo_orden");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String mis_cheques = request.getParameter("mis_cheques");
String noCheque = request.getParameter("noCheque");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String agrupa_hon = request.getParameter("agrupa_hon");
if(agrupa_hon==null) agrupa_hon = "";
String appendFilter ="";
String fecha_ach = CmnMgr.getCurrentDate("dd/mm/yyyy");
String solicitadoPor = request.getParameter("solicitadoPor");
boolean viewMode = false;
int iconSize = 18;

if(fg==null) fg = "";
if(fp==null) fp = "";
if(mis_cheques==null) mis_cheques = "N";

if(anio==null) anio = CmnMgr.getCurrentDate("yyyy");
if(cod_tipo_orden_pago==null) cod_tipo_orden_pago = "";
if(tipo_orden==null) tipo_orden = "";
if(cod_banco==null) cod_banco = "";
if(cuenta_banco==null) cuenta_banco = "";
if(noCheque==null) noCheque = "";
if(fDate==null) fDate = "";
if(tDate==null) tDate = "";
if(solicitadoPor==null) solicitadoPor = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){


	if(agrupa_hon.equals("")){
		CommonDataObject cd = new CommonDataObject();
		cd = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'LIQ_RECL_AGRUPAR_HON') agrupa_hon from dual");
		agrupa_hon = cd.getColValue("agrupa_hon");
	}
	if(!anio.equals("")) appendFilter = " and a.anio = " + anio;
	if(!cod_tipo_orden_pago.equals("")) appendFilter += " and a.cod_tipo_orden_pago = " + cod_tipo_orden_pago;
	if(!tipo_orden.equals("")) appendFilter += (agrupa_hon.equals("Y")?" and decode(a.tipo_orden, 'S', 'H', 'M', 'H', a.tipo_orden)":" and a.tipo_orden ") +" = '" + tipo_orden + "'";
	if(!cod_banco.equals("")) appendFilter += " and e.cod_banco = '" + cod_banco + "'";
	if(!cuenta_banco.equals("")) appendFilter += " and e.cuenta_banco = '" + cuenta_banco + "'";
	if(!noCheque.equals("")) appendFilter += " and e.num_cheque = '" + noCheque + "'";
	if(!fDate.equals("")) appendFilter += " and trunc(e.f_emision) >= to_date('"+fDate+"','dd/mm/yyyy')";
	if(!tDate.equals("")) appendFilter += " and trunc(e.f_emision) <= to_date('"+tDate+"','dd/mm/yyyy')";
	if(mis_cheques.equals("S")) appendFilter += " and e.usuario_creacion = '" + (String) session.getAttribute("_userName") + "'";
	if(!solicitadoPor.trim().equals("")) appendFilter += " and a.solicitado_por = '"+solicitadoPor+"'";

	if(request.getParameter("fDate") != null){
		sql = "select a.compania, a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha_solicitud, a.estado, decode(a.estado, 'A', 'Aprobado', 'R', 'Rechazado', 'P', 'Pendiente') estado_desc, a.nom_beneficiario, a.num_id_beneficiario, a.user_creacion, a.cod_tipo_orden_pago, a.monto, to_char(a.fecha_aprobado, 'dd/mm/yyyy') fecha_aprobado, a.user_aprobado, a.cod_hacienda, a.cod_provedor, a.cod_empresa, a.cod_autorizacion, a.tipo_orden, a.solicitado_por, a.ruc, a.dv, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_crecion, a.beneficiario2, e.cod_banco, e.cuenta_banco, f.descripcion nombre_cuenta, nvl(b.descripcion, ' ') hacienda_nombre, nvl((select nombre from tbl_con_banco where compania = e.cod_compania and cod_banco = e.cod_banco), ' ') banco_nombre, getVerAch(a.cod_tipo_orden_pago, a.tipo_orden, num_id_beneficiario) ver_ach, nvl(d.descripcion, ' ') solicitadoDesc, e.num_cheque, to_char(e.f_emision, 'dd/mm/yyyy') f_emision from tbl_cxp_orden_de_pago a, tbl_cxp_clasif_hacienda b, tbl_sec_unidad_ejec d, tbl_con_cheque e, tbl_con_cuenta_bancaria f where e.estado_impresion = 'P' and a.cheque_impreso = 'S' and a.estado = 'A' and (a.ach='N' or a.ach is null) "+appendFilter+" and a.num_orden_pago = e.num_orden_pago and a.cod_compania = e.cod_compania_odp and a.anio = e.anio and a.cod_hacienda = b.cod_hacienda(+) and a.cod_unidad_ejecutora = d.codigo(+) and a.compania = d.compania(+) and e.cod_compania = f.compania and e.cod_banco = f.cod_banco and e.cuenta_banco = f.cuenta_banco and e.estado_cheque != 'A' and a.compania = "+(String) session.getAttribute("_companyId")+" order by a.fecha_solicitud desc";
		al = SQLMgr.getDataList(sql);
	}
	System.out.println(" al.size() === "+ al.size());

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
var xHeight=0;
function doAction(){
	setDetValues();
	xHeight=objHeight('_tblMain');resizeFrame();
}

function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200,3/5);resetFrameHeight(document.getElementById('itemFrame'),xHeight,100,2/5);}

function doSubmit(value){
	document.orden_pago.action.value = value;
	if(chkCuentas()){
		document.orden_pago.submit();
	}
}

function reloadPage(){
	var anio = document.orden_pago.anio.value;
	var cod_tipo_orden_pago = document.orden_pago.cod_tipo_orden_pago.value;
	var tipo_orden = document.orden_pago.tipo_orden.value;
	var cod_banco = document.orden_pago.cod_banco.value;
	var noCheque = document.orden_pago.noCheque.value;
	var fDate = document.orden_pago.fDate.value;
	var tDate = document.orden_pago.tDate.value;
	var fg = document.orden_pago.fg.value;
	var mis_cheques = 'N';
	if(document.orden_pago.mis_cheques.checked) mis_cheques = 'S';
	
	window.location = '../cxp/cerrar_cheque.jsp?anio='+anio+'&cod_tipo_orden_pago='+cod_tipo_orden_pago+'&tipo_orden='+tipo_orden+'&cod_banco='+cod_banco+'&mis_cheques='+mis_cheques+'&noCheque='+noCheque+'&fDate='+fDate+'&tDate='+tDate+'&solicitadoPor=<%=solicitadoPor%>&agrupa_hon=<%=agrupa_hon%>&fg='+fg;
}

function printCK(i){
	
	var cod_banco = eval('document.orden_pago.cod_banco'+i).value;
	var cuenta_banco = eval('document.orden_pago.cuenta_banco'+i).value;
	var cod_compania = eval('document.orden_pago.cod_compania'+i).value;
	var fecha_emi = '';//eval('document.orden_pago.f_emision'+i).value;
	var num_ck = eval('document.orden_pago.num_cheque'+i).value;
	abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&cod_compania='+cod_compania+'&num_ck='+num_ck+'&fg=solo');
		
}

function chkRB(i){
	checkRadioButton(document.orden_pago.rb, i);
	setDetValues();
}

function setDetValues(){
	if(document.orden_pago.rb){
		var index = 	getRadioButtonValue(document.orden_pago.rb);
		var num_orden_pago = eval('document.orden_pago.num_orden_pago'+index).value;
		var anio = eval('document.orden_pago.anio'+index).value;
		if(num_orden_pago!='' && anio !=''){
			window.frames['itemFrame'].location = '../cxp/cerrar_cheque_det.jsp?num_orden_pago='+num_orden_pago+'&anio='+anio+'&index='+index;
		}
	}
}

function cierre(){
		//orden_pagoBlockButtons(true);
	doSubmit('Cierre');
	//orden_pagoBlockButtons(false);
}

function chkCuentas(){
	var size = <%=al.size()%>
	var x = 0, y = 0;
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.chk'+i).checked){
			y++;
		}
	}
	if(y==0){
		alert('Seleccione al menos una Orden de Pago!');
		return false;
	} else return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("orden_pago","","post");%>
            <%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("errCode","")%> 
			<%=fb.hidden("errMsg","")%> 
            <%=fb.hidden("saveOption","")%> 
			<%=fb.hidden("clearHT","")%> 
			<%=fb.hidden("action","")%> 
            <%=fb.hidden("fg",fg)%> 
			<%=fb.hidden("solicitadoPor",solicitadoPor)%> 
              <tr class="Text01">
                <td colspan="7">&nbsp;</td>
              </tr>
              <tr class="TextPanel">
                <td colspan="7"><cellbytelabel>Generaci&oacute;n de Pagos</cellbytelabel></td>
              </tr>
              <tr class="TextPanel">
              	<td colspan="4">
                <cellbytelabel>A&ntilde;o</cellbytelabel>:
                <%=fb.intBox("anio",anio,false,false,false,6,"text10","","")%>
                <cellbytelabel>Tipo Orden</cellbytelabel>:
                 <%if(fg.equals("PM")){%>
							 <%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago = 4 order by cod_tipo_orden_pago","cod_tipo_orden_pago","",false,false,0, "text10", "", "", "", "S")%>
               <cellbytelabel>Pagos Otros</cellbytelabel>:
								 <%=fb.select("tipo_orden","E=Empresa,B=Beneficiario,C=Corredor,"+(agrupa_hon.equals("Y")?"H=Honorarios":"M=Medico,S=Sociedad Medica"), "", false, false,0,"text10",null,"", "", "S")%>
								<%} else {%>
                <%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (1, 2, 3) order by cod_tipo_orden_pago","cod_tipo_orden_pago","",false,false,0, "text10", "", "", "", "S")%>
                <cellbytelabel>Pagos Otros</cellbytelabel>:
                <%=fb.select("tipo_orden","E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos,M=Medico,N=Ninguno", "", false, false,0,"text10",null,"", "", "S")%>
								<%}%>
								<%=fb.checkbox("mis_cheques","S",(mis_cheques.equals("S")),false,null,null,"")%> Mis cheques
								No. Doc:<%=fb.textBox("noCheque",noCheque,false,false,false,6,"text10","","")%>
								Fecha:<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2"/>
						<jsp:param name="nameOfTBox1" value="fDate"/>
						<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
						<jsp:param name="nameOfTBox2" value="tDate"/>
						<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
						<jsp:param name="fieldClass" value="Text10"/>
						<jsp:param name="buttonClass" value="Text10"/>
						<jsp:param name="clearOption" value="true"/>
						</jsp:include>
								<%=fb.button("if","Ir",false, viewMode,"text10","","onClick=\"javascript:reloadPage()\"")%>
                </td>
                <td colspan="3"><%=fb.submit("cerrar","Cerrar",true,viewMode,"text10","","onClick=\"javascript:cierre()\"")%><!--<a href="javascript:cierre();"><img src="../images/lock.gif" border="0" height="24" width="24" title="Cierre"></a>-->&nbsp;
                </td>
              </tr>
              <tr class="TextPanel">
              	<td colspan="7">
                <cellbytelabel>Banco</cellbytelabel>:
								<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+"order by nombre","cod_banco",cod_banco,false,false,0, "text10", "", "", "", "S")%>
                </td>
              </tr>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Ordenes de Pagos</cellbytelabel></td>
                <td colspan="1" align="right"></td>
              </tr>
              <tr>
              	<td colspan="7">
								<div id="_cMain" class="Container">
								<div id="_cContent" class="ContainerContent">
                <table align="center" width="100%" cellpadding="0" cellspacing="1">
                	<tr class="TextHeader02">
                    <td align="center" width="2%"><cellbytelabel>Sel</cellbytelabel>.</td>
                    <td align="center" width="2%"><cellbytelabel>No</cellbytelabel>.</td>
                    <td align="center" width="7%"><cellbytelabel>Fecha Sol</cellbytelabel>.</td>
                    <td align="center" width="18%" colspan="2"><cellbytelabel>Beneficiario</cellbytelabel></td>
                    <td align="center" width="6%"><cellbytelabel>Monto</cellbytelabel></td>
                    <td align="center" width="3%"><cellbytelabel>Ruta</cellbytelabel><br><cellbytelabel>Trn</cellbytelabel>.</td>
                    <td align="center" width="7%"><cellbytelabel>Ruc</cellbytelabel></td>
                    <td align="center" width="2%"><cellbytelabel>DV</cellbytelabel></td>
                    <td align="center" width="10%"><cellbytelabel>Hacienda</cellbytelabel></td>
                    <td align="center" width="10%"><cellbytelabel>Otro Benef</cellbytelabel>.</td>
                    <td align="center" width="10%">Solicitado<br><cellbytelabel>Por</cellbytelabel>.</td>
										<td align="center" width="8%"><cellbytelabel>Aprobado</cellbytelabel><br><cellbytelabel>Por</cellbytelabel>.</td>
                    <td align="center" width="6%"><cellbytelabel>Estado</cellbytelabel></td>
                    <td align="center" width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
                    <td align="center" width="2%"><cellbytelabel>Det</cellbytelabel>.</td>
                  </tr>

              <%
              for (int i=0; i<al.size(); i++){
                CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
              %>
              <%=fb.hidden("anio"+i,OP.getColValue("anio"))%>
			  <%=fb.hidden("num_orden_pago"+i,OP.getColValue("num_orden_pago"))%>
              <%=fb.hidden("cuenta_banco"+i,OP.getColValue("cuenta_banco"))%>
              <%=fb.hidden("cod_banco"+i,OP.getColValue("cod_banco"))%>
			  <%=fb.hidden("num_cheque"+i,OP.getColValue("num_cheque"))%>
              <%=fb.hidden("cod_tipo_orden_pago"+i,OP.getColValue("cod_tipo_orden_pago"))%>
              <%=fb.hidden("tipo_orden"+i,OP.getColValue("tipo_orden"))%>
              <%=fb.hidden("num_id_beneficiario"+i,OP.getColValue("num_id_beneficiario"))%>
              <%=fb.hidden("usuario_creacion"+i,OP.getColValue("usuario_creacion"))%>
              <%=fb.hidden("compania"+i,OP.getColValue("compania"))%>
              <%=fb.hidden("cod_compania"+i,OP.getColValue("cod_compania"))%>  
			    
               <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center">
								<%=fb.checkbox("chk"+i,""+i, false, false, "", "", "")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("num_orden_pago")%> </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha_solicitud")%> </td>
                <td width="2%" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("num_id_beneficiario")%> </td>
                <td width="16%" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("nom_beneficiario")%> </td>
                <td align="right" onClick="javascript:chkRB(<%=i%>);"><%=CmnMgr.getFormattedDecimal("###,###,###.99", OP.getColValue("monto"))%>&nbsp;</td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("ver_ach")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("ruc")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("dv")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("hacienda_nombre")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("beneficiario2")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("solicitadoDesc")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("user_aprobado")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("estado_desc")%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha_aprobado")%></td>
                <td align="center" rowspan="2" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
              </tr>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" height="20">
                <td colspan="4"><cellbytelabel>No.Cheque</cellbytelabel>:&nbsp;&nbsp;<font class="RedTextBold"><%=OP.getColValue("num_cheque")%></font>
                </td>
                <td align="center">
                <authtype type='51'>
								<a href="javascript:printCK(<%=i%>)" class="FormDataObject"><cellbytelabel>Reimprimir Cheque</cellbytelabel></a>
                </authtype>
                </td>
                <td align="left" colspan="5">
								<cellbytelabel>Banco</cellbytelabel>:&nbsp;&nbsp;<%=OP.getColValue("cod_banco")+"-"+OP.getColValue("banco_nombre")%>
								</td>
                <td align="left" colspan="5">
                <cellbytelabel>Cta</cellbytelabel>.:&nbsp;&nbsp;<%=OP.getColValue("cuenta_banco")+"-"+OP.getColValue("nombre_cuenta")%>
								</td>
              </tr>
							<%}%>
                </table>
              </div>
              </div>
                </td>
              </tr>
              <%=fb.hidden("keySize",""+al.size())%>
              <tr class="TextRow02">
                <td align="right" colspan="7">&nbsp;</td>
              </tr>
              <tr>
                <td colspan="7"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="0" scrolling="yes" src="../cxp/cerrar_cheque_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&agrupa_hon=<%=agrupa_hon%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("chk"+i)!=null){
			cdo = new CommonDataObject();
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("num_orden_pago", request.getParameter("num_orden_pago"+i));
			cdo.addColValue("cuenta_banco", request.getParameter("cuenta_banco"+i));
			cdo.addColValue("cod_banco", request.getParameter("cod_banco"+i));
			cdo.addColValue("num_cheque", request.getParameter("num_cheque"+i));
			cdo.addColValue("cod_tipo_orden_pago", request.getParameter("cod_tipo_orden_pago"+i));
			cdo.addColValue("tipo_orden", request.getParameter("tipo_orden"+i));
			cdo.addColValue("num_id_beneficiario", request.getParameter("num_id_beneficiario"+i));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("cod_compania", request.getParameter("cod_compania"+i));
			al.add(cdo);
		}
	}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES," mode="+mode+" fg ="+fg);
	if (request.getParameter("action").equalsIgnoreCase("Cierre")){
		OrdPagoMgr.cierreCK(al);
	} 	
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
<%
if (OrdPagoMgr.getErrCode().equals("1")){
%>
	alert('<%=OrdPagoMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/cxp/cerrar_cheque.jsp?anio=<%=request.getParameter("anio")%>&cod_tipo_orden_pago=<%=request.getParameter("cod_tipo_orden_pago")%>&tipo_orden=<%=request.getParameter("tipo_orden")%>&solicitadoPor=<%=request.getParameter("solicitadoPor")%>&fg=<%=request.getParameter("fg")%>';
<%
} else throw new Exception(OrdPagoMgr.getErrException());
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
