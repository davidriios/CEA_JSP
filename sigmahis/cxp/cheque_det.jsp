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
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ckDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ckDetKey" scope="session" class="java.util.Hashtable" />
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
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String documento = request.getParameter("documento");
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) ckDet.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}


function _doSubmit(valor){
	document.cheque_det.action.value = valor;
	document.cheque_det.clearHT.value = 'N';
	if(parent.doSubmit(valor)) doSubmit(valor);
}

function doSubmit(valor){
	document.cheque_det.action.value = valor;
	document.cheque_det.cod_banco.value 					= parent.document.cheque.cod_banco.value;
	document.cheque_det.cuenta_banco.value 				= parent.document.cheque.cuenta_banco.value;
	document.cheque_det.num_cheque.value 					= parent.document.cheque.num_cheque.value;
	document.cheque_det.f_emision.value 					= parent.document.cheque.f_emision.value;
	document.cheque_det.num_new_ck.value 					= parent.document.cheque.num_new_ck.value;
	document.cheque_det.fecha_new_emision.value 	= parent.document.cheque.fecha_new_emision.value;
	document.cheque_det.cod_tipo_orden_pago.value = parent.document.cheque.cod_tipo_orden_pago.value;
	document.cheque_det.tipo_orden.value 					= parent.document.cheque.tipo_orden.value;
	document.cheque_det.anio_op.value 						= parent.document.cheque.anio_op.value;
	document.cheque_det.num_orden_pago.value 			= parent.document.cheque.num_orden_pago.value;
	document.cheque_det.estado_cheque.value 			= parent.document.cheque.estado_cheque.value;
	document.cheque_det.descripcion_a.value 			= parent.document.cheque.descripcion_a.value;
	if(parent.document.cheque.f_anulacion)  document.cheque_det.f_anulacion.value 				= parent.document.cheque.f_anulacion.value;
	if (!parent.chequeValidation()){
		 parent.chequeBlockButtons(false);
		 return false;
	} else if (document.cheque_det.action.value == 'Guardar'){
		if (!cheque_detValidation()){
			cheque_detBlockButtons(false);
			return false;
		} else document.cheque_det.submit();
	} else{
		if(document.cheque_det.action.value != 'Guardar') cheque_detBlockButtons(false);
		document.cheque_det.submit();
	}

}

function chkFechaEmision(){
	if(parent.document.cheque.fecha_new_emision.value==''){
		top.CBMSG.error('Introduzca fecha de emisión');
		return false;
	} else return true;
}

function chkFechaAnulacion(){
	if(parent.document.cheque.f_anulacion.value==''){
		top.CBMSG.error('Introduzca fecha de Anulacion');
		return false;
	} else return true;
} 
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("cheque_det",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("cod_banco","")%>
<%=fb.hidden("cuenta_banco","")%>
<%=fb.hidden("num_cheque","")%>
<%=fb.hidden("f_emision","")%>
<%=fb.hidden("num_new_ck","")%>
<%=fb.hidden("fecha_new_emision","")%>
<%=fb.hidden("cod_tipo_orden_pago","")%>
<%=fb.hidden("tipo_orden","")%>
<%=fb.hidden("anio_op","")%>
<%=fb.hidden("num_orden_pago","")%>
<%=fb.hidden("estado_cheque","")%>
<%=fb.hidden("descripcion_a","")%>
<%=fb.hidden("f_anulacion","")%>
<table width="100%" align="center">
  <tr>
    <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader">
          <td width="10%" align="center"><cellbytelabel>No</cellbytelabel>.</td>
          <td width="10%" align="center"><cellbytelabel>No. Factura</cellbytelabel></td>
          <td width="35%" align="center"><cellbytelabel>Cuenta Financiera</cellbytelabel></td>
          <td width="35%" align="center"><cellbytelabel>Descripción</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
        </tr>
        <%
				double totCK = 0.00;
				key = "";
				if (ckDet.size() != 0) al = CmnMgr.reverseRecords(ckDet);
				for (int i=0; i<ckDet.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) ckDet.get(key);
					totCK += Double.parseDouble(cdo.getColValue("monto_renglon"));
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <tr class="<%=color%>" >
          <td align="center"><%=cdo.getColValue("num_renglon")%></td>
          <td align="center"><%=cdo.getColValue("num_factura")%></td>
          <td><%=cdo.getColValue("cuenta_financiera")%></td>
          <td><%=cdo.getColValue("descripcion")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_renglon"))%>&nbsp;</td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="4" align="right">&nbsp;<cellbytelabel>Valor del Cheque</cellbytelabel>:</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totCK)%>&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+ckDet.size())%>
        <tr class="TextRow02">
          <td colspan="5" align="right">
					<%if(mode.equals("edit")){%>
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: _doSubmit(this.value);\"")%>
          <%}%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
          </td>
        </tr>
      </table></td>
  </tr>
</table>
<%if(mode.equals("edit")){fb.appendJsValidation("\n\tif (!chkFechaEmision()) error++;\n");}%>
<%if(mode.equals("edit")){fb.appendJsValidation("\n\tif (!chkFechaAnulacion()) error++;\n");}%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	//String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");

	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	OP.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("cod_banco", request.getParameter("cod_banco"));
	OP.addColValue("cuenta_banco", request.getParameter("cuenta_banco"));
	OP.addColValue("num_cheque", request.getParameter("num_cheque"));
	OP.addColValue("fecha_emision", request.getParameter("f_emision"));

	if(request.getParameter("num_new_ck")!=null && !request.getParameter("num_new_ck").equals("num_new_cheque")) OP.addColValue("num_new_cheque", request.getParameter("num_new_ck"));
	if(request.getParameter("fecha_new_emision")!=null && !request.getParameter("fecha_new_emision").equals("")) OP.addColValue("fecha_new_emision", request.getParameter("fecha_new_emision"));
	OP.addColValue("cod_tipo_orden_pago", request.getParameter("cod_tipo_orden_pago"));
	OP.addColValue("tipo_orden", request.getParameter("tipo_orden"));
	if(request.getParameter("estado_cheque").equals("A") || mode.equals("edit")) OP.addColValue("reemplazar", "S");
	else OP.addColValue("reemplazar", "N");
	if(request.getParameter("descripcion_a")!=null && !request.getParameter("descripcion_a").equals("")) OP.addColValue("descripcion_a", request.getParameter("descripcion_a"));
	OP.addColValue("anio_op", request.getParameter("anio_op"));
	OP.addColValue("num_orden_pago", request.getParameter("num_orden_pago"));
	OP.addColValue("usuario", (String) session.getAttribute("_userName"));
	if(request.getParameter("f_anulacion")!=null && !request.getParameter("f_anulacion").equals("")) OP.addColValue("f_anulacion", request.getParameter("f_anulacion"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES," mode="+mode+" fp ="+fp);
	if (mode.equalsIgnoreCase("anular")&& request.getParameter("action")!=null && request.getParameter("action").equals("Anular")){
		OrdPagoMgr.anulaCK(OP);
	} else if (mode.equalsIgnoreCase("edit") && fp.equalsIgnoreCase("cxp") && request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		OrdPagoMgr.actualizaCK(OP);
	} else if (mode.equalsIgnoreCase("edit") && fp.equalsIgnoreCase("conciliacion") && request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		OrdPagoMgr.anulaCKConc(OP);
	}
	ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.cheque.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.cheque.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			//parent.document.cheque.saveOption.value = '<%//=saveOption%>';
			parent.document.cheque.submit();
	<%} else throw new Exception(OrdPagoMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

