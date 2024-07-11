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
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector" />
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
String numero_documento = request.getParameter("numero_documento");
String anio_recepcion = request.getParameter("anio_recepcion");
int lineNo = 0;
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htCtas.clear();
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
	abrir_ventana1('../common/check_cuentas.jsp?fp=fact_prov&mode=<%=mode%>&numero_documento=<%=numero_documento%>');

	<%
	}
	%>
	verValues();
	newHeight();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	//parent.doAction();
}

function _doSubmit(valor){
	document.fact_prov.action.value = valor;
	document.fact_prov.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.fact_prov.numero_documento.value = parent.document.fact_prov.numero_documento.value;
	document.fact_prov.anio_recepcion.value = parent.document.fact_prov.anio_recepcion.value;
	document.fact_prov.estado.value = parent.document.fact_prov.estado.value;
	document.fact_prov.fecha_sistema.value = parent.document.fact_prov.fecha_sistema.value;
	document.fact_prov.correccion.value = parent.document.fact_prov.correccion.value;
	document.fact_prov.fecha_documento.value = parent.document.fact_prov.fecha_documento.value;
	document.fact_prov.numero_factura.value = parent.document.fact_prov.numero_factura.value;

	document.fact_prov.parent_monto_total.value = parent.document.fact_prov.monto_total.value;
	document.fact_prov.itbm.value = parent.document.fact_prov.itbm.value;
	document.fact_prov.subtotal.value = parent.document.fact_prov.subtotal.value;
	document.fact_prov.cod_proveedor.value = parent.document.fact_prov.cod_proveedor.value;
	document.fact_prov.desc_proveedor.value = parent.document.fact_prov.desc_proveedor.value;
	document.fact_prov.explicacion.value = parent.document.fact_prov.explicacion.value;
	document.fact_prov.cod_concepto.value = parent.document.fact_prov.cod_concepto.value;
	document.fact_prov.ref_cheque.value = parent.document.fact_prov.ref_cheque.value;

	if (!parent.fact_provValidation()){
		 parent.fact_provBlockButtons(false);
		 return false;
	} else if (document.fact_prov.action.value == 'Guardar'){
		if (!fact_provValidation()){
			fact_provBlockButtons(false);
			parent.fact_provBlockButtons(false);
			return false;
		} else document.fact_prov.submit();
	} else {
		if(document.fact_prov.action.value != 'Guardar'){
			parent.fact_provBlockButtons(false);
			fact_provBlockButtons(false);
		}	
		document.fact_prov.submit();
	}
	
}


function selRecepcion(i){
	var codProveedor = parent.document.fact_prov.num_id_beneficiario.value;
	abrir_ventana1('../inventario/sel_recepcion.jsp?fp=fact_prov&index='+i+'&codProveedor='+codProveedor);
}


function chkCeroValues(){
	var size = document.fact_prov.keySize.value;
	var x = 0;
	var monto = 0.00;
	var parentMonto = parseFloat(parent.document.fact_prov.monto_total.value);
	if(document.fact_prov.action.value=="Guardar"){
		for(i=0;i<size;i++){
			if(eval('document.fact_prov.monto'+i).value<=0){
			
				top.CBMSG.warning('El monto no puede ser menor o igual a 0!');
				eval('document.fact_prov.monto'+i).focus();
				x++;
				break;
			} else{
			 monto += parseFloat(eval('document.fact_prov.monto'+i).value);
			}
		}
	}
	if(x==0){
		document.fact_prov.monto_total.value = monto.toFixed(2);
	if(document.fact_prov.action.value=="Guardar" && monto.toFixed(2) != parentMonto){
			top.CBMSG.warning('Valor de factura Incorrecto!'+monto +'-----'+parentMonto);
		return false;
		} else return true;
	} else return false;
}

function verValues(){
	var size = document.fact_prov.keySize.value;
	var monto = 0.00;
	for(i=0;i<size;i++){
		if(eval('document.fact_prov.monto'+i).value>0){
		 monto += parseFloat(eval('document.fact_prov.monto'+i).value);
		}
	}
	document.fact_prov.monto_total.value = monto.toFixed(2);
}

function chkCeroRegisters(){
	var size = document.fact_prov.keySize.value;
	if(size>0) return true;
	else{
		if(document.fact_prov.action.value!='Guardar') return true;
		else {
			top.CBMSG.warning('Seleccione al menos una Cuenta!');
			document.fact_prov.action.value = '';
			return false;
		}
	}
}
function setCuentas(k){abrir_ventana('../common/search_catalogo_gral.jsp?fp=factProv&index='+k);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("fact_prov",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 

<%=fb.hidden("anio_recepcion",anio_recepcion)%> 
<%=fb.hidden("numero_documento",numero_documento)%> 
<%=fb.hidden("estado","")%> 
<%=fb.hidden("fecha_sistema","")%> 
<%=fb.hidden("correccion","")%> 
<%=fb.hidden("fecha_documento","")%> 
<%=fb.hidden("numero_factura","")%> 
<%=fb.hidden("parent_monto_total","")%> 
<%=fb.hidden("itbm","")%> 
<%=fb.hidden("subtotal","")%> 
<%=fb.hidden("cod_proveedor","")%> 
<%=fb.hidden("desc_proveedor","")%> 
<%=fb.hidden("explicacion","")%> 
<%=fb.hidden("cod_concepto","")%> 
<%=fb.hidden("ref_cheque","")%> 
<table width="100%" align="center">
  <tr>
    <td><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <%
				int colspan = 5;
				%>
        <tr class="TextPanel">
          <td colspan="<%=colspan-2%>"><cellbytelabel>Detalle</cellbytelabel></td>
          <td colspan="2" align="right"><%=fb.button("addCuentas","Agregar Cuentas",false,viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <tr class="TextHeader">
          <td width="15%" align="center"><cellbytelabel>No</cellbytelabel>.</td>
          <td width="30%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="32%" align="center"><cellbytelabel>N&uacute;mero de Cuenta</cellbytelabel></td>
          <td width="3%" align="center">&nbsp;</td>
        </tr>
        <%
				key = "";
				if (htCtas.size() != 0) al = CmnMgr.reverseRecords(htCtas);
				for (int i=0; i<htCtas.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htCtas.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
        <%=fb.hidden("anio_recepcion"+i,cdo.getColValue("anio_recepcion"))%>
        <%=fb.hidden("numero_documento"+i,cdo.getColValue("numero_documento"))%>
				<%=fb.hidden("cta1_"+i,cdo.getColValue("cg_1_cta1"))%>
        <%=fb.hidden("cta2_"+i,cdo.getColValue("cg_1_cta2"))%>
        <%=fb.hidden("cta3_"+i,cdo.getColValue("cg_1_cta3"))%>
        <%=fb.hidden("cta4_"+i,cdo.getColValue("cg_1_cta4"))%>
        <%=fb.hidden("cta5_"+i,cdo.getColValue("cg_1_cta5"))%>
        <%=fb.hidden("cta6_"+i,cdo.getColValue("cg_1_cta6"))%>
        <%=fb.hidden("descripcion_cuenta"+i,cdo.getColValue("descripcion_cuenta"))%>
        <tr class="<%=color%>" >
          <td align="center">
					<%=fb.textBox("renglon"+i,cdo.getColValue("renglon"),false,false,true,5,"text10",null,"onFocus=\"this.select();\"")%></td>
          <td align="center"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,viewMode,60, "text10",null,"onFocus=\"this.select();\"")%></td>
          <td align="center"><%=fb.decBox("monto"+i,cdo.getColValue("monto"),false,false,viewMode,10, 8.2,"text10",null,"onFocus=\"this.select();\"" + "onChange = \"javascript:verValues();\"","Cantidad",false,"")%></td>
          <td><%=fb.textBox("descCta"+i,cdo.getColValue("descCta"),false,false,true,60, "text10",null,"")%>
		  	  <%=fb.button("btnCtas"+i,"...",true,viewMode,null,null,"onClick=\"javascript:setCuentas("+i+")\"")%>
		  </td>
          <td width="3%" align="center"><%=fb.submit("del"+i,"X",false,viewMode,"text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="2" align="right">&nbsp;<cellbytelabel>Valor del Cheque</cellbytelabel></td>
          <td align="center"><%=fb.decBox("monto_total","0",true,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td colspan="2" width="3%" align="center">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+htCtas.size())%> 
      </table></td>
  </tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
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

	OP.addColValue("anio_recepcion", request.getParameter("anio_recepcion"));
	OP.addColValue("numero_documento", request.getParameter("numero_documento"));
	OP.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("estado")!=null && request.getParameter("estado").equals("A")){ OP.addColValue("fecha_anulacion",cDate);
	OP.addColValue("usuario_anulacion", (String) session.getAttribute("_userName"));
	}
	
	OP.addColValue("fecha_sistema", request.getParameter("fecha_sistema"));
	if(request.getParameter("correccion")!=null && !request.getParameter("correccion").equals("OTROS")) OP.addColValue("correccion", request.getParameter("correccion"));
	OP.addColValue("fecha_documento", request.getParameter("fecha_documento"));
	OP.addColValue("numero_factura", request.getParameter("numero_factura"));
	OP.addColValue("monto_total", request.getParameter("parent_monto_total"));
	OP.addColValue("itbm", request.getParameter("itbm"));
	OP.addColValue("subtotal", request.getParameter("subtotal"));
	OP.addColValue("cod_proveedor", request.getParameter("cod_proveedor"));
	OP.addColValue("desc_proveedor", request.getParameter("desc_proveedor"));
	if(request.getParameter("explicacion")!=null && !request.getParameter("explicacion").equals("")) OP.addColValue("explicacion", request.getParameter("explicacion"));
	OP.addColValue("cod_concepto", request.getParameter("cod_concepto"));
	if(request.getParameter("ref_cheque")!=null && !request.getParameter("ref_cheque").equals("")) OP.addColValue("ref_cheque", request.getParameter("ref_cheque"));
	
	OP.addColValue("tipo_factura", "S");
	OP.addColValue("fre_documento", "FR");
	OP.addColValue("asiento_sino", "N");
	
	OP.addColValue("compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	OP.addColValue("usuario_mod", (String) session.getAttribute("_userName"));
	OP.addColValue("user_creacion", (String) session.getAttribute("_userName"));

	htCtas.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("renglon",request.getParameter("renglon"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("cg_1_cta1",request.getParameter("cta1_"+i));
		cdo.addColValue("cg_1_cta2",request.getParameter("cta2_"+i));
		cdo.addColValue("cg_1_cta3",request.getParameter("cta3_"+i));
		cdo.addColValue("cg_1_cta4",request.getParameter("cta4_"+i));
		cdo.addColValue("cg_1_cta5",request.getParameter("cta5_"+i));
		cdo.addColValue("cg_1_cta6",request.getParameter("cta6_"+i));
		cdo.addColValue("descripcion_cuenta",request.getParameter("descripcion_cuenta"+i));
		cdo.addColValue("descCta",request.getParameter("descCta"+i)); 
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("anio_recepcion", request.getParameter("anio_recepcion"));
		cdo.addColValue("numero_documento", request.getParameter("numero_documento"));
		if(request.getParameter("monto"+i)!= null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));
		
		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("del"+i)==null){
			try {
				htCtas.put(key, cdo);
				String ctas = cdo.getColValue("cg_cta1")+"_"+cdo.getColValue("cg_cta2")+"_"+cdo.getColValue("cg_cta3")+"_"+cdo.getColValue("cg_cta4")+"_"+cdo.getColValue("cg_cta5")+"_"+cdo.getColValue("cg_cta6");
				vCtas.add(ctas);
				al.add(cdo);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}
     
	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../cxp/fact_prov_det.jsp?mode="+mode+"&numero_documento="+numero_documento+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar Cuentas")){
		response.sendRedirect("../cxp/fact_prov_det.jsp?mode="+mode+"&numero_documento="+numero_documento+"&change=1&type=1&fg="+fg);
		return;
	}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode);
	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.addFactProv(OrdPago);
		numero_documento = OrdPagoMgr.getPkColValue("numero_documento");
	} else {
		OrdPago.setCdo(OP);
		OrdPago.setAlDet(al);
		OrdPagoMgr.updtFactProv(OrdPago);  
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%//if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.fact_prov.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.fact_prov.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			parent.document.fact_prov.errException.value = '<%=OrdPagoMgr.getErrException()%>';
			parent.document.fact_prov.numero_documento.value = '<%=numero_documento%>';
			parent.document.fact_prov.submit();
	<%//} else throw new Exception(OrdPagoMgr.getErrException());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

