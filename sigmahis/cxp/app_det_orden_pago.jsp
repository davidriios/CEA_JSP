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

if(fecha == null) fecha = "";
if(documento==null) documento = "";
if(unidad_adm==null) unidad_adm = "";

if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
cdo = SQLMgr.getData("select nombre from tbl_sec_compania where codigo = " + (String) session.getAttribute("_companyId"));
/*
encabezado
*/
//	to_char(a.monto,'999,999,999.00') monto, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc

if(!unidad_adm.equals("")){

	sql = "select o.documento, to_char(o.fecha, 'dd/mm/yyyy') fecha, o.beneficiario, o.unidad_adm1, nvl(o.estado_final, 'Z') estado_final, b.descripcion desc_unidad_adm1, c.nombre nom_beneficiario, nvl(c.ruc, ' ') ruc, nvl(to_char(c.digito_verificador), ' ') dv, cl.descripcion clasificacion_desc, nvl(cl.nivel_vobo, 'N') nivel_vobo, to_char(o.fecha, 'dd/mm/yyyy') fecha, to_char(d.monto, '999,999,999.00') monto, o.beneficiario, o.estado1, d.unidad_adm, d.estado, d.usuario_creacion, to_char(d.fecha_creacion, 'dd/mm/yyyy hh:mi am') fecha_creacion, d.usuario_modificacion, to_char(d.fecha_modificacion, 'dd/mm/yyyy hh:mi am') fecha_modificacion, d.usuario_aprobacion, to_char(d.fecha_aprobacion, 'dd/mm/yyyy hh:mi am') fecha_aprobacion, o.usuario_unidad1, to_char(o.fecha_aprobacion1, 'dd/mm/yyyy hh:mi am') fecha_aprobacion1, d.observacion2, o.observacion, o.clasificacion, f.descripcion unidad_adm2_desc from tbl_cxp_orden_unidad_det d, tbl_cxp_orden_unidad o, tbl_cxp_usuario_x_unidad u, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c, tbl_cxp_orden_clasificacion cl, tbl_sec_unidad_ejec f where d.compania = "+(String) session.getAttribute("_companyId") + " and d.unidad_adm = nvl("+unidad_adm+", d.unidad_adm) and d.estado = 'P' and (o.compania = d.compania and o.documento = d.documento and o.fecha = d.fecha and o.estado1 = 'A') and (u.compania = d.compania and u.unidad_adm = d.unidad_adm and u.usuario = '"+(String) session.getAttribute("_userName")+"' and u.orden_pago in (2, 3)) and exists (select 'x' from tbl_cxp_usuario_x_unidad_clasi x where x.usuario = u.usuario and x.unidad_adm = u.unidad_adm and x.compania = u.compania and x.clasificacion = o.clasificacion and x.nivel_aprobar = 'S') and o.compania = b.compania and o.unidad_adm1 = b.codigo and o.compania = c.compania and o.beneficiario = c.codigo and o.clasificacion = cl.codigo and o.compania = "+(String) session.getAttribute("_companyId") + (!documento.equals("") && !fecha.equals("")?" and o.documento = "+documento+" and trunc(o.fecha) = to_date('"+fecha+"', 'dd/mm/yyyy')":"") + " and o.documento = d.documento and o.fecha = d.fecha and o.compania = d.compania and d.compania = f.compania and d.unidad_adm = f.codigo";
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
}

function doSubmit(value){
document.orden_pago.action.value = value;
}

function reloadPage(unidad_adm){
window.location = '../cxp/app_det_orden_pago.jsp?unidad_adm='+unidad_adm;
}

function selOtros(){
abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');
}

function setDetValues(i){
	document.orden_pago.desc_unidad_adm1.value = 	eval('document.orden_pago.desc_unidad_adm1_'+i).value;
	document.orden_pago.clasificacion_desc.value = 	eval('document.orden_pago.clasificacion_desc'+i).value;
	document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;
	document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;
	document.orden_pago.observacion.value = 	eval('document.orden_pago.observacion'+i).value;
	document.orden_pago.observacion2_.value = 	eval('document.orden_pago.observacion2_'+i).value;

	document.orden_pago.usuario_creacion.value = 	eval('document.orden_pago.usuario_creacion'+i).value;
	document.orden_pago.fecha_creacion.value = 	eval('document.orden_pago.fecha_creacion'+i).value;
	document.orden_pago.usuario_unidad1.value = 	eval('document.orden_pago.usuario_unidad1'+i).value;
	document.orden_pago.fecha_aprobacion1_.value = 	eval('document.orden_pago.fecha_aprobacion1'+i).value;
	document.orden_pago.usuario_aprobacion.value = 	eval('document.orden_pago.usuario_aprobacion'+i).value;
	document.orden_pago.fecha_aprobacion.value = 	eval('document.orden_pago.fecha_aprobacion'+i).value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
    	<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td>
          	<table align="center" width="99%" cellpadding="0" cellspacing="1">
              <%
							fb = new FormBean("orden_pago","","post");
							%>
              <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("documento",documento)%> <%=fb.hidden("errCode","")%> <%=fb.hidden("errMsg","")%> <%=fb.hidden("saveOption","")%> <%=fb.hidden("clearHT","")%> <%=fb.hidden("action","")%> <%=fb.hidden("fg",fg)%>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Aprobaci&oacute;n Solicitudes de Orden de Pago UNIDADES AFECTADAS</cellbytelabel></td>
              </tr>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Unidad Adm</cellbytelabel>.
                <%=fb.select(ConMgr.getConnection(), "select distinct a.unidad_adm, lpad(a.unidad_adm, 4, '0')||' - '||b.descripcion descripcion, b.descripcion x from tbl_cxp_usuario_x_unidad a, tbl_sec_unidad_ejec b where a.orden_pago in (2, 3) "+(UserDet.getUserProfile().contains("0")?"":" and a.usuario = '" + (String) session.getAttribute("_userName") +"'")+" and a.compania = " + (String) session.getAttribute("_companyId") +" and a.unidad_adm = b.codigo and a.compania = b.compania order by b.descripcion", "unidad_adm", unidad_adm, false, false, 0, "text10", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "S")%>
                 </td>
              </tr>
              <tr class="">
              	<td colspan="6">
		<div id="list_opMain" width="100%" class="exp h260">
		<div id="list_op" width="100%" class="child">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="8%"><cellbytelabel>Documento</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
                <td align="center" width="31%"><cellbytelabel>Unidad Afectada</cellbytelabel></td>
                <td align="center" width="31%"><cellbytelabel>Beneficiario</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Monto</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>Estado</cellbytelabel></td>
              </tr>
              <%
							for (int i=0; i<al.size(); i++){
								CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
              <%=fb.hidden("documento"+i,OP.getColValue("documento"))%>
							<%=fb.hidden("fecha"+i,OP.getColValue("fecha"))%>
							<%=fb.hidden("desc_unidad_adm1_"+i,OP.getColValue("desc_unidad_adm1"))%>
							<%=fb.hidden("clasificacion_desc"+i,OP.getColValue("clasificacion_desc"))%>
							<%=fb.hidden("monto"+i,OP.getColValue("monto"))%>
							<%=fb.hidden("beneficiario"+i,OP.getColValue("beneficiario"))%>
							<%=fb.hidden("nom_beneficiario"+i,OP.getColValue("nom_beneficiario"))%>
							<%=fb.hidden("ruc"+i,OP.getColValue("ruc"))%>
							<%=fb.hidden("dv"+i,OP.getColValue("dv"))%>
							<%=fb.hidden("observacion"+i,OP.getColValue("observacion"))%>
							<%=fb.hidden("observacion2_"+i,OP.getColValue("observacion2"))%>
							<%=fb.hidden("usuario_creacion"+i,OP.getColValue("usuario_creacion"))%>
							<%=fb.hidden("fecha_creacion"+i,OP.getColValue("fecha_creacion"))%>
							<%=fb.hidden("usuario_unidad1"+i,OP.getColValue("usuario_unidad1"))%>
							<%=fb.hidden("fecha_aprobacion1"+i,OP.getColValue("fecha_aprobacion1"))%>
							<%=fb.hidden("usuario_aprobacion"+i,OP.getColValue("usuario_aprobacion"))%>
							<%=fb.hidden("fecha_aprobacion"+i,OP.getColValue("fecha_aprobacion"))%>
							<%=fb.hidden("nivel_vobo"+i,OP.getColValue("nivel_vobo"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center" onClick="javascript:setDetValues(<%=i%>);"><%=OP.getColValue("documento")%> </td>
                <td align="center" onClick="javascript:setDetValues(<%=i%>);"><%=OP.getColValue("fecha")%> </td>
                <td onClick="javascript:setDetValues(<%=i%>);"><%=OP.getColValue("unidad_adm2_desc")%> </td>
                <td onClick="javascript:setDetValues(<%=i%>);"><%=OP.getColValue("nom_beneficiario")%> </td>
                <td align="right" onClick="javascript:setDetValues(<%=i%>);"><%=OP.getColValue("monto")%></td>
                <td align="center"><%=fb.select("estado"+i,"A=Aprobado,P=Pendiente,N=Anulada", OP.getColValue("estado"), false, false,0,"text10",null,"")%> </td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr class="TextRow02">
                <td colspan="6">Detalle de la Solicitud</td>
              </tr>
              <tr class="TextHeader02" >
                <td colspan="6">
                	<table align="center" width="99%" cellpadding="0" cellspacing="1">
                    <tr class="TextHeader02" >
                      <td align="right"><cellbytelabel>R.U.C</cellbytelabel>.</td>
                      <td><%=fb.textBox("ruc","",false,false,true,30,"text10",null,"")%></td>
                      <td align="right"><cellbytelabel>Solicitado por</cellbytelabel>:</td>
                      <td><%=fb.textBox("desc_unidad_adm1","",false,false,true,50,"text10",null,"")%></td>
                    </tr>
                    <tr class="TextHeader02" >
                      <td align="right"><cellbytelabel>D.V</cellbytelabel>.</td>
                      <td><%=fb.textBox("dv","",false,false,true,30,"text10",null,"")%></td>
                      <td align="right"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel>:</td>
                      <td><%=fb.textBox("clasificacion_desc","",false,false,true,50,"text10",null,"")%></td>
                    </tr>
                    <tr class="TextHeader02" >
                      <td align="right"><cellbytelabel>En Concepto de</cellbytelabel>:</td>
                      <td><%=fb.textarea("observacion","",false,false,true,50,5,"text10",null,"")%> </td>
                      <td align="right"><cellbytelabel>Detalle</cellbytelabel>:</td>
                      <td><%=fb.textarea("observacion2_","",false,false,true,50,5,"text10",null,"")%> </td>
                    </tr>
                  </table>
              	</td>
              </tr>
              <tr class="TextHeader01" >
                <td colspan="6">
                	<table align="center" width="99%" cellpadding="0" cellspacing="1">
                    <tr class="TextHeader01" >
                      <td align="right"><cellbytelabel>Creado Por</cellbytelabel>:&nbsp;
											<%=fb.textBox("usuario_creacion","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_creacion","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="right"><cellbytelabel>Aprob. Sol</cellbytelabel>.:&nbsp;
											<%=fb.textBox("usuario_unidad1","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_aprobacion1_","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="right"><cellbytelabel>Aprob. Unidad</cellbytelabel>:&nbsp;
											<%=fb.textBox("usuario_aprobacion","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_aprobacion","",false,false,true,18,"text10",null,"")%>
                      </td>
                    </tr>
                  </table>
              	</td>
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
            </table>
          </td>
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
int keySize = Integer.parseInt(request.getParameter("keySize"));

al = new ArrayList();
for(int i=0;i<keySize;i++){
	cdo = new CommonDataObject();
	cdo.addColValue("documento", request.getParameter("documento"+i));
	cdo.addColValue("fecha", request.getParameter("fecha"+i));
	cdo.addColValue("estado", request.getParameter("estado"+i));
	cdo.addColValue("nivel_vobo", request.getParameter("nivel_vobo"+i));
	cdo.addColValue("unidad_adm", request.getParameter("unidad_adm"));
	cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	al.add(cdo);
}
System.out.println("action......="+request.getParameter("action"));
if (request.getParameter("action").equals("Guardar")){
	OrdPagoMgr.aprobarDet(al);
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
window.location = '<%=request.getContextPath()%>/cxp/app_det_orden_pago.jsp?unidad_adm=<%=request.getParameter("unidad_adm")%>';
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
