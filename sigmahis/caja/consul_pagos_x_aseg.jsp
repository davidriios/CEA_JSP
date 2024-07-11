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
String key = "";
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String documento = request.getParameter("documento");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String cod_empresa = request.getParameter("cod_empresa");

String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(fecha == null) fecha = "";
if(documento==null) documento = "";
if(cod_empresa==null || cod_empresa.equals("")) cod_empresa = "null";

if(fg==null) fg = "";
if(fp==null) fp = "";
if(pac_id==null) pac_id = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	if(!cod_empresa.equals("") || !pac_id.equals("")){
		sql.append("select distinct a.anio, a.codigo, a.recibo, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.caja, b.descripcion caja_nombre, a.descripcion, a.usuario_creacion, a.pago_total, nvl((select to_char(max(num_cheque)) from tbl_cja_trans_forma_pagos where compania = a.compania and tran_codigo = a.codigo and tran_anio = a.anio), ' ') cheque from tbl_cja_transaccion_pago a, tbl_cja_cajas b,tbl_cja_detalle_pago dp where a.compania = b.compania and a.caja = b.codigo and a.compania = ");
		sql.append(session.getAttribute("_companyId"));
		if(fg.equals("empresa")){sql.append(" and a.codigo_empresa = ");sql.append(cod_empresa);}
		else {sql.append(" and a.pac_id = ");sql.append(pac_id);}
		sql.append(" and a.codigo=dp.codigo_transaccion(+) and a.compania=dp.compania(+) and a.anio=dp.tran_anio(+) and a.rec_status <> 'I' ");
		
		if(fp.trim().equals("CXPHON")){sql.append(" and dp.fac_codigo = '");sql.append(documento);sql.append("'");}
		al = SQLMgr.getDataList(sql.toString());
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
	if(document.pagos.rb){
		setDetValues();
	}
}

function reloadPage(cod_empresa){
	window.location = '../caja/consul_pagos_x_aseg.jsp?cod_empresa='+cod_empresa;
}

function chkRB(i){
	checkRadioButton(document.pagos.rb, i);
	setDetValues();
}

function setDetValues(){
	var index = 	getRadioButtonValue(document.pagos.rb);
	var anio = eval('document.pagos.anio'+index).value;
	var codigo = eval('document.pagos.codigo'+index).value;
	var compania = '<%=(String) session.getAttribute("_companyId")%>';
	if(anio!='' && codigo !=''){
		window.frames['itemFrame'].location = '../caja/consul_pagos_x_aseg_det.jsp?anio='+anio+'&codigo='+codigo+'&fg=<%=fg%>';
	}
}

function setDistValues(url){
		window.frames['itemFrame2'].location = url;
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
						fb = new FormBean("pagos","","post");
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
                <td colspan="7"><%=(fg.equals("empresa")?"PAGOS REALIZADOS POR LA ASEGURADORA":"PAGOS DEL PACIENTE")%></td>
              </tr>
              <tr class="">
              	<td colspan="7">
		<div id="list_opMain" width="100%" style="overflow:scroll;position:static;height:140">
		<div id="list_op" width="100%" style="overflow;position:relative">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="8%"><cellbytelabel>Recibo</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
                <td align="center" width="24%"><cellbytelabel>Caja</cellbytelabel></td>
                <%if(fg.equals("empresa")){%>
                <td align="center" width="8%"><cellbytelabel>Cheque</cellbytelabel></td>
                <%} else if(fg.equals("paciente")){%>
                <td align="center" width="8%"><cellbytelabel>Trans.</cellbytelabel></td>
                <%}%>
                <td align="center" width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>Usuario</cellbytelabel></td>
                <td align="center" width="10%"><cellbytelabel>Pago Total</cellbytelabel></td>
                <td align="center" width="2%">&nbsp;</td>
              </tr>
              <%
              for (int i=0; i<al.size(); i++){
                CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
              %>
							<%=fb.hidden("anio"+i,OP.getColValue("anio"))%>
							<%=fb.hidden("codigo"+i,OP.getColValue("codigo"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("recibo")%> </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha")%> </td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("caja")%>-<%=OP.getColValue("caja_nombre")%></td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=(fg.equals("empresa")?OP.getColValue("cheque"):OP.getColValue("codigo"))%> </td>
                <td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=OP.getColValue("descripcion")%> </td>
                <td align="right" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("usuario_creacion")%></td>
                <td align="right" onClick="javascript:chkRB(<%=i%>);"><%=CmnMgr.getFormattedDecimal(OP.getColValue("pago_total"))%></td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
              </tr>
							<%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr class="TextRow02">
                <td align="right" colspan="7">&nbsp;</td></tr>
              <tr>
                <td colspan="7"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../caja/consul_pagos_x_aseg_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&cod_empresa=<%=cod_empresa%>"></iframe></td>
              </tr>
              <tr>
                <td colspan="7"><iframe name="itemFrame2" id="itemFrame2" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../caja/consul_pagos_x_aseg_det_dist.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&cod_empresa=<%=cod_empresa%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
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
%>
