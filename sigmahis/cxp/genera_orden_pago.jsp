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
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(fecha == null) fecha = "";
if(documento==null) documento = "";
if(unidad_adm==null || unidad_adm.equals("")) unidad_adm = "null";

if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	cdo = SQLMgr.getData("select desde_cantidad, hasta_cantidad from tbl_cxp_autorizacion where usuario = '" + (String) session.getAttribute("_userName")+"'");
	if(cdo!=null){
		v_desde = cdo.getColValue("desde_cantidad");
		v_hasta = cdo.getColValue("hasta_cantidad");
	} else error_en_permiso = "S";
	/*
	encabezado
	*/
	if(!unidad_adm.equals("")){
	sql="select a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, a.unidad_adm1, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, nvl(a.estado_final, 'Z') estado_final, a.observacion, b.descripcion unidad_desc, c.nombre nom_beneficiario, nvl(c.ruc, ' ') ruc, nvl(to_char(c.digito_verificador), ' ') dv, a.tipo_persona, decode(a.tipo_persona, 1, 'NATURAL', 2, 'JURIDICA') tipo_persona_desc, d.descripcion clasificacion_desc, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy hh:mi am') fecha_creacion, a.usuario_unidad1, to_char(a.fecha_aprobacion1, 'dd/mm/yyyy hh:mi am') fecha_aprobacion1, a.usuario_aprobacion2, to_char(a.fecha_aprobacion2, 'dd/mm/yyyy hh:mi am') fecha_aprobacion2 from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c, tbl_cxp_orden_clasificacion d where a.estado1 in ('T') and a.estado_final = 'S' and unidad_adm1 = nvl("+unidad_adm+", unidad_adm1)  and a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.clasificacion = d.codigo and a.compania = "+(String) session.getAttribute("_companyId") + (!documento.equals("") && !fecha.equals("")?" and a.documento = "+documento+" and trunc(a.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')":"") + "order by a.monto desc, a.fecha asc";
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
	if(document.orden_pago.rb){
		setEncValues(getRadioButtonValue(document.orden_pago.rb))
		setDetValues();
	}
}

function doSubmit(value){
	document.orden_pago.action.value = value;
}

function reloadPage(unidad_adm){
	window.location = '../cxp/genera_orden_pago.jsp?unidad_adm='+unidad_adm;
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
	document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;
	document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;
	document.orden_pago.tipo_persona_desc.value = 	eval('document.orden_pago.tipo_persona_desc'+i).value;
	document.orden_pago.clasificacion.value = 	eval('document.orden_pago.clasificacion_desc'+i).value;
	document.orden_pago.observacion.value = 	eval('document.orden_pago.observacion'+i).value;
	document.orden_pago.usuario_creacion.value = 	eval('document.orden_pago.usuario_creacion'+i).value;
	document.orden_pago.fecha_creacion.value = 	eval('document.orden_pago.fecha_creacion'+i).value;
	document.orden_pago.usuario_unidad1.value = 	eval('document.orden_pago.usuario_unidad1'+i).value;
	document.orden_pago.fecha_aprobacion1_.value = 	eval('document.orden_pago.fecha_aprobacion1'+i).value;
	document.orden_pago.usuario_aprobacion2.value = 	eval('document.orden_pago.usuario_aprobacion2_'+i).value;
	document.orden_pago.fecha_aprobacion2.value = 	eval('document.orden_pago.fecha_aprobacion2_'+i).value;
}

function setDetValues(){
	var index = 	getRadioButtonValue(document.orden_pago.rb);
	var documento = eval('document.orden_pago.documento'+index).value;
	var fecha = eval('document.orden_pago.fecha'+index).value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	if(documento!='' && fecha !=''){
		window.frames['itemFrame'].location = '../cxp/genera_orden_pago_det.jsp?documento='+documento+'&fecha='+fecha;
	}
}

function setMotivoRechazo(i, valor){
	if(valor=='X'){
		document.getElementById("tr"+i).style.display = '';
	} else {
		document.getElementById("tr"+i).style.display = 'none';
		eval('document.orden_pago.motivo_rechazado'+i).value = '';
	}
}

function chkMotivoRechazo(){
	var size = parseInt(document.orden_pago.keySize.value);
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.estado1_'+i).value=='X' && eval('document.orden_pago.motivo_rechazado'+i).value==''){
			alert('Introduzca Motivo de Rechazo!');
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}

function chkMonto(){
	var size = parseInt(document.orden_pago.keySize.value);
	var x = 0;
	var v_desde = <%=v_desde%>;
	var v_hasta = <%=v_hasta%>;
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.estado1_'+i).value=='T' && eval('document.orden_pago.estado_ini'+i).value=='A'){
			if('<%=error_en_permiso%>' == 'S'){
				alert('Error en Permiso');
				x++;
				break;
			} else {
				var monto = parseFloat(eval('document.orden_pago.monto'+i).value);
				if(monto > v_desde && monto <= v_hasta) null
				else {
					alert('No puede realizar la autorización, su usuario no tiene permiso!');
					x++;
					break;
				}
			}
		}
	}
	if(x==0) return true;
	else return false;
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
              	<td colspan="8"><cellbytelabel>Unidad Adm</cellbytelabel>.&nbsp;<%=fb.select(ConMgr.getConnection(), "select distinct a.unidad_adm, lpad(a.unidad_adm, 4, '0')||' - '||b.descripcion descripcion, b.descripcion x from tbl_cxp_usuario_x_unidad a, tbl_sec_unidad_ejec b where a.orden_pago in (2, 3) "+(UserDet.getUserProfile().contains("0")?"":" and a.usuario = '" + (String) session.getAttribute("_userName") +"'")+" and a.compania = " + (String) session.getAttribute("_companyId") +" and a.unidad_adm = b.codigo and a.compania = b.compania order by b.descripcion", "unidad_adm", unidad_adm, false, false, 0, "text10", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "T")%></td>
              </tr>
              <tr class="">
              	<td colspan="8">
		<div id="list_opMain" width="100%" class="exp h260">
		<div id="list_op" width="100%" class="child">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="8%"><cellbytelabel>Documento</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
                <td align="center" width="28%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
                <td align="center" width="28%"><cellbytelabel>Beneficiario</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Monto</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Agrupar</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Generar</cellbytelabel></td>
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
              <%=fb.hidden("tipo_persona_desc"+i,OP.getColValue("tipo_persona_desc"))%>
							<%=fb.hidden("usuario_creacion"+i,OP.getColValue("usuario_creacion"))%>
							<%=fb.hidden("fecha_creacion"+i,OP.getColValue("fecha_creacion"))%>
							<%=fb.hidden("usuario_unidad1"+i,OP.getColValue("usuario_unidad1"))%>
							<%=fb.hidden("fecha_aprobacion1"+i,OP.getColValue("fecha_aprobacion1"))%>
							<%=fb.hidden("usuario_aprobacion2_"+i,OP.getColValue("usuario_aprobacion2"))%>
							<%=fb.hidden("fecha_aprobacion2_"+i,OP.getColValue("fecha_aprobacion2"))%>
              <%=fb.hidden("estado_ini"+i,OP.getColValue("estado1"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("documento")%> </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("unidad_desc")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("nom_beneficiario")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("monto")%> </td>
                <td align="center"><%=fb.checkbox("agrupar"+i,""+i)%></td>
                <td align="center"><%=fb.checkbox("generar"+i,""+i)%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
              </tr>
              <tr id="tr<%=i%>" class="TextRow01" style="display:none">
                <td colspan="7">Motivo del Rechazo:<%=fb.textarea("motivo_rechazado"+i,OP.getColValue("motivo_rechazado"),false,false,false,90,2,"text10",null,"")%></td>
              </tr>
							<%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr class="TextRow02">
                <td align="right" colspan="7">&nbsp;</td></tr>
              <tr class="" >
                <td colspan="8">
                	<table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <tr class="TextHeader02" >
											<td width="65%"><cellbytelabel>Datos del Beneficiario</cellbytelabel>:<br>
                      <cellbytelabel>R.U.C</cellbytelabel>.&nbsp;<%=fb.textBox("ruc","",false,false,true,30,"text10",null,"")%>&nbsp;
                      <cellbytelabel>D.V</cellbytelabel>.<%=fb.textBox("dv","",false,false,true,10,"text10",null,"")%>
                      <cellbytelabel>Tipo Persona</cellbytelabel>:<%=fb.textBox("tipo_persona_desc","",false,false,true,20,"text10",null,"")%>
                      </td>
											<td width="35%">
                      <cellbytelabel>Clasif</cellbytelabel>.
											<%=fb.textBox("clasificacion","",false,false,true,50,"text10",null,"")%>
                      </td>
                    </tr>
                    <tr class="TextHeader02" >
                      <td><%=fb.textarea("observacion","",false,false,true,93,5,"text10",null,"")%> </td>
                      <td>&nbsp;</td>
                    </tr>
                  </table>
              	</td>
              </tr>
              <tr class="TextHeader02" >
                <td colspan="8">
                	<table align="center" width="99%" cellpadding="0" cellspacing="1">
                    <tr class="TextHeader02" >
                      <td align="right"><cellbytelabel>Creado Por</cellbytelabel>:&nbsp;
											<%=fb.textBox("usuario_creacion","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_creacion","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="right"><cellbytelabel>Aprobaci&oacute;n Depto</cellbytelabel>.:&nbsp;
											<%=fb.textBox("usuario_unidad1","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_aprobacion1_","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="right"><cellbytelabel>Segunda Aprob</cellbytelabel>.:&nbsp;
											<%=fb.textBox("usuario_aprobacion2","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_aprobacion2","",false,false,true,18,"text10",null,"")%>
                      </td>
                    </tr>
                  </table>
              	</td>
              </tr>
              <tr>
                <td colspan="8"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/genera_orden_pago_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&documento=<%=documento%>"></iframe></td>
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
        <%
        fb.appendJsValidation("\n\tif (!chkMotivoRechazo()) error++;\n");
        fb.appendJsValidation("\n\tif (!chkMonto()) error++;\n");
				%>
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
		if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
				cdo.addColValue("documento", request.getParameter("documento"+i));
			cdo.addColValue("fecha", request.getParameter("fecha"+i));
			cdo.addColValue("usuario", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			if(request.getParameter("agrupar"+i)!=null) cdo.addColValue("agrupar", "S");
			else cdo.addColValue("agrupar", "N");
			cdo.addColValue("generar", "S");
			al.add(cdo);
		}
	}
 	if (request.getParameter("action").equals("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OrdPagoMgr.generaOrdenPago(al);
		ConMgr.clearAppCtx(null);
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
	window.location = '<%=request.getContextPath()%>/cxp/genera_orden_pago.jsp?unidad_adm=<%=request.getParameter("unidad_adm")%>';
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
