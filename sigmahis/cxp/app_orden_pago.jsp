<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
String fecha = request.getParameter("fecha");
String documento = request.getParameter("documento");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String unidad_adm = request.getParameter("unidad_adm");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;

if(fecha == null) fecha = "";
if(documento==null) documento = "";
if(unidad_adm==null) unidad_adm = "";

if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	/*
	encabezado
	*/
	if(!unidad_adm.equals("")){
	sql="select a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, a.unidad_adm1, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, nvl(a.estado_final, 'N') estado_final, a.observacion, b.descripcion unidad_desc, c.nombre nom_beneficiario, nvl(c.ruc, ' ') ruc, nvl(to_char(c.digito_verificador), ' ') dv, d.descripcion clasificacion_desc, nvl(e.nivel_vobo, 'N') nivel_vobo from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c, tbl_cxp_orden_clasificacion d, tbl_cxp_usuario_x_unidad_clasi e where a.estado1 in ('A', 'P') and nvl(a.estado_final, 'N') <> 'S' "+/*(UserDet.getUserProfile().contains("0")?"":*/" and unidad_adm1 in (select unidad_adm from tbl_cxp_usuario_x_unidad where usuario = '"+(String) session.getAttribute("_userName")+"' and orden_pago in (2, 3) and unidad_adm1 = nvl("+unidad_adm+", unidad_adm1))"+ /*)*/ " and a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.clasificacion = d.codigo and a.compania = "+(String) session.getAttribute("_companyId") + (!documento.equals("") && !fecha.equals("")?" and a.documento = "+documento+" and trunc(a.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')":"")+" and a.compania = e.compania(+) and a.unidad_adm1 = e.unidad_adm(+) and a.clasificacion = e.clasificacion(+) and e.usuario = '"+(String) session.getAttribute("_userName")+"'";
	al = SQLMgr.getDataList(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;

function doAction(){
	if(document.orden_pago.rb) setDetValues();
}

function doSubmit(value){
	document.orden_pago.action.value = value;
}

function reloadPage(unidad_adm){
	window.location = '../cxp/app_orden_pago.jsp?unidad_adm='+unidad_adm;
}

function selOtros(){
	abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');
}

function addFacturas(){
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago');
}

function chkRB(i){
	checkRadioButton(document.orden_pago.rb, i);
	setEncValues(i);
	setDetValues();
}

function setEncValues(i){
	document.orden_pago.beneficiario.value = 	eval('document.orden_pago.beneficiario'+i).value;
	document.orden_pago.nom_beneficiario.value = 	eval('document.orden_pago.nom_beneficiario'+i).value;
	document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;
	document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;
	document.orden_pago.observacion.value = 	eval('document.orden_pago.observacion'+i).value;
}

function setDetValues(){
	var index = 	getRadioButtonValue(document.orden_pago.rb);
	var documento = eval('document.orden_pago.documento'+index).value;
	var fecha = eval('document.orden_pago.fecha'+index).value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	if(documento!='' && fecha !=''){
		window.frames['itemFrame'].location = '../cxp/app_orden_pago_det.jsp?documento='+documento+'&fecha='+fecha;
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("orden_pago","","post");
						%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("documento",documento)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
              <%=fb.hidden("saveOption","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <tr class="TextPanel">
                <td colspan="8"><cellbytelabel>Aprobaci&oacute;n Solicitudes de Orden de Pago UNIDAD QUE SOLICITA</cellbytelabel></td>
              </tr>
              <tr class="TextPanel">
              	<td colspan="8"><table align="center" width="99%" cellpadding="0" cellspacing="1"><tr class="TextPanel">
                <td width="10%"><cellbytelabel>Unidad Adm</cellbytelabel>.</td>

                <td colspan="4" width="50%"><%=fb.select(ConMgr.getConnection(), "select distinct a.unidad_adm, lpad(a.unidad_adm, 4, '0')||' - '||b.descripcion descripcion, b.descripcion x from tbl_cxp_usuario_x_unidad a, tbl_sec_unidad_ejec b where a.orden_pago in (2, 3) "+(UserDet.getUserProfile().contains("0")?"":" and a.usuario = '" + (String) session.getAttribute("_userName") +"'")+" and a.compania = " + (String) session.getAttribute("_companyId") +" and a.unidad_adm = b.codigo and a.compania = b.compania order by b.descripcion", "unidad_adm", unidad_adm, false, false, 0, "text10", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "S")%></td>
                <td colspan="3" width="20%" align="center"><img src="../images/lampara_verde.gif" width="<%=iconSize%>" height="<%=iconSize%>">&nbsp;<cellbytelabel>Parcialmente Aprobadas</cellbytelabel></td></tr></table></td>
              </tr>
              <tr class="">
              	<td colspan="8">
		<div id="list_opMain" width="100%" class="exp h260">
		<div id="list_op" width="100%" class="child">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="8%"><cellbytelabel>Documento</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
                <td align="center" width="30%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
                <td align="center" width="30%"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Monto</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>Estado</cellbytelabel></td>
                <td align="center" width="2%"><cellbytelabel>VoBo</cellbytelabel></td>
                <td align="center" width="2%">&nbsp;</td>
                <td align="center" width="2%">&nbsp;</td>
              </tr>
              <%
              for (int i=0; i<al.size(); i++){
                CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
              %>
              <%=fb.hidden("documento"+i,OP.getColValue("documento"))%>
              <%=fb.hidden("fecha"+i,OP.getColValue("fecha"))%>
              <%=fb.hidden("unidad_desc"+i,OP.getColValue("unidad_desc"))%>
              <%=fb.hidden("clasificacion_desc"+i,OP.getColValue("clasificacion_desc"))%>
              <%=fb.hidden("monto"+i,OP.getColValue("monto"))%>
              <%=fb.hidden("beneficiario"+i,OP.getColValue("beneficiario"))%>
              <%=fb.hidden("nom_beneficiario"+i,OP.getColValue("nom_beneficiario"))%>
              <%=fb.hidden("ruc"+i,OP.getColValue("ruc"))%>
              <%=fb.hidden("dv"+i,OP.getColValue("dv"))%>
              <%=fb.hidden("observacion"+i,OP.getColValue("observacion"))%>
              <%=fb.hidden("estado_final"+i,OP.getColValue("estado_final"))%>
              <%=fb.hidden("nivel_vobo"+i,OP.getColValue("nivel_vobo"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("documento")%> </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("unidad_desc")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("clasificacion_desc")%> </td>
                <td align="right" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("monto")%></td>
                <td align="center"><%=fb.select("estado1_"+i,"A=Aprobado,P=Pendiente,N=Anulada", OP.getColValue("estado1"), false, false,0,"text10",null,"")%> </td>
                <td align="center">
                <%=fb.checkbox("chkNivelVobo"+i,OP.getColValue("nivel_vobo"),false,(OP.getColValue("nivel_vobo").equalsIgnoreCase("S") && OP.getColValue("estado_final").equals("I")?false:true))%>
                </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
                <td align="center">
                <img src="../images/<%=(OP.getColValue("estado1").equals("A")?(OP.getColValue("estado_final").equals("I")?"lampara_amarilla":"lampara_verde"):(OP.getColValue("estado1").equals("P")?"lampara_blanca":"blank"))%>.gif" width="<%=iconSize%>" height="<%=iconSize%>">
                </td>
              </tr>
							<%}%>
              </table>
              </div>
              </div>
              </td></tr>
              <%=fb.hidden("keySize",""+al.size())%>
              <tr class="TextRow02">
                <td align="right" colspan="8">&nbsp;</td></tr>
              <tr class="TextHeader02" >
                <td align="right"><cellbytelabel>Beneficiario</cellbytelabel>:</td>
                <td colspan="7">
								<%=fb.textBox("beneficiario","",false,false,true,20,"text10",null,"")%>
								<%=fb.textBox("nom_beneficiario","",false,false,true,80,"text10",null,"")%>
                R.U.C.&nbsp;<%=fb.textBox("ruc","",false,false,true,30,"text10",null,"")%>&nbsp;
								D.V.<%=fb.textBox("dv","",false,false,true,10,"text10",null,"")%>
								</td>
              </tr>
              <tr class="TextHeader02" >
                <td align="right"><cellbytelabel>En Concepto de</cellbytelabel>:</td>
                <td colspan="7"><%=fb.textarea("observacion","",false,false,true,93,5,"text10",null,"")%> </td>
              </tr>
              <tr>
                <td colspan="8"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/app_orden_pago_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&documento=<%=documento%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="6" align="right">
					<%=fb.submit("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
          </td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
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
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		cdo = new CommonDataObject();
		cdo.addColValue("documento", request.getParameter("documento"+i));
		cdo.addColValue("fecha", request.getParameter("fecha"+i));
		cdo.addColValue("estado1", request.getParameter("estado1_"+i));
		cdo.addColValue("nivel_vobo", request.getParameter("nivel_vobo"+i));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		if(request.getParameter("chkNivelVobo"+i)!=null) cdo.addColValue("estado_aprobacion2","S");
		else cdo.addColValue("estado_aprobacion2","N");
		al.add(cdo);
	}
 	if (request.getParameter("action").equals("Guardar")){
		OrdPagoMgr.aprobarEnc(al);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (OrdPagoMgr.getErrCode().equals("1")){
%>
	alert('<%=OrdPagoMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/cxp/app_orden_pago.jsp?unidad_adm=<%=request.getParameter("unidad_adm")%>';
<%
} else throw new Exception(OrdPagoMgr.getErrMsg());
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
