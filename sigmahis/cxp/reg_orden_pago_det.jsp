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
<jsp:useBean id="opDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="opDetKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable" />
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
	if (mode.equalsIgnoreCase("add") && change == null) opDet.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../common/check_unidad_adm.jsp?fp=orden_pago&mode=<%=mode%>&documento=<%=documento%>');

	<%
	}
	%>
	calc();
	verValues();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc(){
	var iCounter = 0;
	if (iCounter > 0) return true;
	else return false;
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
	document.form1.documento.value = parent.document.orden_pago.documento.value;
	document.form1.tipo_orden.value = parent.document.orden_pago.tipo_orden.value;
	document.form1.fecha.value = parent.document.orden_pago.fecha.value;
	document.form1.unidad_adm1.value = parent.document.orden_pago.unidad_adm1.value;
	document.form1.estado1.value = parent.document.orden_pago.estado1.value;
	document.form1.clasificacion.value = parent.document.orden_pago.clasificacion.value;
	document.form1.beneficiario.value = parent.document.orden_pago.beneficiario.value;
	document.form1.nom_beneficiario.value = parent.document.orden_pago.nom_beneficiario.value;
	document.form1.ruc.value = parent.document.orden_pago.ruc.value;
	document.form1.dv.value = parent.document.orden_pago.dv.value;
	document.form1.tipo_persona.value = parent.document.orden_pago.tipo_persona.value;
	document.form1.monto.value = parent.document.orden_pago.monto.value;
	document.form1.observacion.value = parent.document.orden_pago.observacion.value;
	if(parent.document.orden_pago.motivo_rechazado) document.form1.motivo_rechazado.value = parent.document.orden_pago.motivo_rechazado.value;

	if (!parent.orden_pagoValidation()){
		 parent.orden_pagoBlockButtons(false);
		 return false;
	} else if (document.form1.action.value == 'Guardar'){
		if (!form1Validation()){
			form1BlockButtons(false);
			return false;
		} else document.form1.submit();
	} else{
		if(document.form1.action.value != 'Guardar') form1BlockButtons(false);
		document.form1.submit();
	}
	
}

function chkCeroValues(){
	var size = document.form1.keySize.value;
	var x = 0;
	var monto = 0.00;
	var parentMonto = parseFloat(parent.document.orden_pago.monto.value);
	if(document.form1.action.value=="Guardar"){
		for(i=0;i<size;i++){
			if(eval('document.form1.observacion2'+i).value==''){
				alert('Introduzca observacion del detalle!');
				eval('document.form1.observacion2'+i).focus();
				x++;
				break;
			}
			if(eval('document.form1.monto'+i).value<=0){
				alert('El monto no puede ser menor o igual a 0!');
				eval('document.form1.monto'+i).focus();
				x++;
				break;
			} else{
			 monto += parseFloat(eval('document.form1.monto'+i).value);
			}
		}
	}
	if(x==0){
		document.form1.monto_total.value = monto;
		if(document.form1.action.value=="Guardar" && monto != parentMonto){
			alert('El Total por las Unidades Afectadas no coincide con el Monto de la Solicitud!')
			return false;
		} else return true;
	} else return false;
}

function verValues(){
	var size = document.form1.keySize.value;
	var monto = 0.00;
	for(i=0;i<size;i++){
		if(eval('document.form1.monto'+i).value>0){
		 monto += parseFloat(eval('document.form1.monto'+i).value);
		}
	}
	document.form1.monto_total.value = monto;
}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	if(size>0) return true;
	else{
		if(document.form1.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos una Unidad!');
			document.form1.action.value = '';
			return false;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("documento",documento)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 

<%=fb.hidden("tipo_orden","")%> 
<%=fb.hidden("fecha","")%> 
<%=fb.hidden("unidad_adm1","")%> 
<%=fb.hidden("estado1","")%> 
<%=fb.hidden("clasificacion","")%> 
<%=fb.hidden("beneficiario","")%> 
<%=fb.hidden("nom_beneficiario","")%> 
<%=fb.hidden("ruc","")%> 
<%=fb.hidden("dv","")%> 
<%=fb.hidden("tipo_persona","")%> 
<%=fb.hidden("monto","")%> 
<%=fb.hidden("observacion","")%> 
<%=fb.hidden("motivo_rechazado","")%> 
<table width="100%" align="center">
  <tr>
    <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <%
				int colspan = 5;
				%>
        <tr class="TextPanel">
          <td colspan="<%=colspan-2%>"><cellbytelabel>Afecta el Gasto de</cellbytelabel>:</td>
          <td colspan="2" align="right"><%=fb.button("addUnidades","Agregar Unidad",false,viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td width="37%" align="center" colspan="2"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
          <td width="50%" align="center"><cellbytelabel>Detalle</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="3%" align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				if (opDet.size() != 0) al = CmnMgr.reverseRecords(opDet);
				for (int i=0; i<opDet.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) opDet.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("unidad_adm_"+i,cdo.getColValue("unidad_adm"))%>
        <%=fb.hidden("nombre_unidad"+i,cdo.getColValue("nombre_unidad"))%>
        <tr class="<%=color%>" >
          <td><%=cdo.getColValue("unidad_adm")%></td>
          <td><%=cdo.getColValue("nombre_unidad")%></td>
          <td><%=fb.textBox("observacion2"+i,cdo.getColValue("observacion2"),false,false,false,80,"text10",null,"")%></td>
          <td align="center"><%=fb.decBox("monto"+i,cdo.getColValue("monto"),false,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"" + "onChange = \"javascript:verValues();\"","Cantidad",false,"")%></td>
          <td width="3%" align="center"><%=fb.submit("del"+i,"X",false,false, "text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="3" align="right">&nbsp;<cellbytelabel>Monto Total</cellbytelabel></td>
          <td align="center"><%=fb.decBox("monto_total","0",true,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td width="3%" align="center">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+opDet.size())%> 
        <tr class="TextRow02">
          <td colspan="<%=colspan%>" align="right"> 
          Opciones de Guardar: 
					<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel> 
					<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel> 
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: _doSubmit(this.value);\"")%> 
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%> 
          </td>
        </tr>
      </table></td>
  </tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{

	String companyId = (String) session.getAttribute("_companyId");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	OP.addColValue("documento", request.getParameter("documento"));
	OP.addColValue("tipo_orden", request.getParameter("tipo_orden"));
	OP.addColValue("fecha", request.getParameter("fecha"));
	OP.addColValue("unidad_adm1", request.getParameter("unidad_adm1"));
	OP.addColValue("estado1", request.getParameter("estado1"));
	OP.addColValue("clasificacion", request.getParameter("clasificacion"));
	OP.addColValue("beneficiario", request.getParameter("beneficiario"));
	OP.addColValue("nom_beneficiario", request.getParameter("nom_beneficiario"));
	OP.addColValue("monto", request.getParameter("monto"));
	OP.addColValue("compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	OP.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	if(mode.equals("add")) OP.addColValue("estado1", "P");
	if(request.getParameter("ruc")!= null && !request.getParameter("ruc").equals("")) OP.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("dv")!= null && !request.getParameter("dv").equals("")) OP.addColValue("dv", request.getParameter("dv"));
	if(request.getParameter("tipo_persona")!= null && !request.getParameter("tipo_persona").equals("")) OP.addColValue("tipo_persona", request.getParameter("tipo_persona"));
	if(request.getParameter("observacion")!= null && !request.getParameter("observacion").equals("")) OP.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("motivo_rechazado")!= null && !request.getParameter("motivo_rechazado").equals("")) OP.addColValue("motivo_rechazado", request.getParameter("motivo_rechazado"));
	opDet.clear();
	opDetKey.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("unidad_adm", request.getParameter("unidad_adm_"+i));
		cdo.addColValue("nombre_unidad", request.getParameter("nombre_unidad"+i));
		if(mode.equals("add")) cdo.addColValue("estado", "P");
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		if(request.getParameter("observacion2"+i)!= null && !request.getParameter("observacion2"+i).equals("")) cdo.addColValue("observacion2", request.getParameter("observacion2"+i));
		if(request.getParameter("monto"+i)!= null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));
		
		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("del"+i)==null){
			try {
				opDet.put(key, cdo);
				opDetKey.put(cdo.getColValue("unidad_adm"), key);
				al.add(cdo);
				System.out.println("adding item.... "+cdo.getColValue("unidad_adm"));
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../cxp/reg_orden_pago_det.jsp?mode="+mode+"&documento="+documento+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar Unidad")){
		response.sendRedirect("../cxp/reg_orden_pago_det.jsp?mode="+mode+"&documento="+documento+"&change=1&type=1&fg="+fg);
		return;
	}

	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.add(OrdPago);
	} else if (mode.equalsIgnoreCase("edit")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){    
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.updateSolOP(OrdPago);  
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.orden_pago.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.orden_pago.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			parent.document.orden_pago.documento.value = '<%=documento%>';
			parent.document.orden_pago.saveOption.value = '<%=saveOption%>';
			parent.document.orden_pago.submit();
	<%} else throw new Exception(OrdPagoMgr.getErrMsg());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

