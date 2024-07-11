<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="AjuMgr" scope="page" class="issi.planmedico.AjusteMgr"/>
<jsp:useBean id="Aju" scope="session" class="issi.planmedico.Ajuste"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vClt" scope="session" class="java.util.Vector"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
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
AjuMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alPar = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String tipo_aju = request.getParameter("tipo_aju");
int lineNo = 0;
if(fp==null)fp="plan_medico";
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (tipo_aju == null) tipo_aju = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htClt.clear();
	else if (mode.equalsIgnoreCase("edit") && change != null && change.equals("2")) htClt.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	var tipo_aju = parent.document.ajuste.tipo_aju.value;
	var id_solicitud = parent.document.ajuste.id_solicitud.value;
	<%
	if(type!=null && type.equals("1")){
	%>
		if(id_solicitud=='') parent.CBMSG.warning('Seleccione Contrato!');
		else if(tipo_aju=='') parent.CBMSG.warning('Seleccione Tipo de Ajuste!');
		else abrir_ventana1('../planmedico/pm_sel_doctos_ajuste.jsp?fp=<%=fp%>&mode=<%=mode%>&id=<%=id%>&fg=<%=fg%>&tipo_aju='+tipo_aju+'&id_solicitud='+id_solicitud);
	<%
	}
	//if(!mode.equals("view")){
	%>
	calc();
	<%//}%>
	newHeight();
}

function calc(){
	var iCounter = 0;
	var size = <%=htClt.size()%>;
	
	<%//if(mode.equals("view") || mode.equals("edit")){%>
	for(i=0;i<size;i++){calcItbm(i);}
	<%//}%>
	if (iCounter > 0) return true;
	else return false;
}

function doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	var tipo_aju = parent.document.ajuste.tipo_aju.value;
	document.form1.id.value=parent.document.ajuste.id.value;
	if(parent.document.ajuste.observacion) document.form1.observacion.value=parent.document.ajuste.observacion.value;
	document.form1.tipo_aju.value=parent.document.ajuste.tipo_aju.value;
	document.form1.tipo_benef.value=parent.document.ajuste.tipo_ben.value;
	if(parent.document.ajuste.id_referencia) document.form1.id_referencia.value=parent.document.ajuste.id_referencia.value;
	document.form1.id_solicitud.value=parent.document.ajuste.id_solicitud.value;
	if (!form1Validation()){
		form1BlockButtons(false);
		parent.form1BlockButtons(false);
		document.form1.baction.value='';
		return false;
	}
	else if(tipo_aju=='') parent.CBMSG.warning('Seleccione Tipo de Ajuste!');	
	else if(!chkCeroRegisters()) parent.CBMSG.warning('Seleccione almenos un registro!');	
	else if(!chkValues()) parent.CBMSG.warning('Introduzca monto correcto!');	
	else	document.form1.submit();
}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	if(size>0) return true;
	else{
		if(document.form1.action.value!='Guardar' && document.form1.action.value!='Guardar y Aprobar') return true;
		else {
			document.form1.action.value = '';
			return false;
		}
	}
}

function chkValues(){
	var size = document.form1.keySize.value;
	var err=0;
	for(i=0;i<size;i++){
		if(eval('document.form1.monto'+i).value=='' || eval('document.form1.monto'+i).value==0 || isNaN(eval('document.form1.monto'+i).value)) err++;
	}
	if(err>0) return false;
	else return true;
}

function calcItbm(i){
	var size = document.form1.keySize.value;
	var itbm = parent.document.ajuste.itbm.value;
	var monto=0.00, impuesto=0.00, total = 0.00, total_subtotal = 0.00, total_itbm = 0.00, subtotal = 0.00;
	for(i=0;i<size;i++){
		<%if(fg.equals("cxc") && tipo_aju.equals("0")){%>
			monto = parseFloat(eval('document.form1.monto'+i).value);
			subtotal = monto/(1+(itbm/100));
			impuesto = subtotal * itbm/100;
			eval('document.form1.subtotal'+i).value = subtotal.toFixed(2);
			eval('document.form1.impuesto'+i).value = impuesto.toFixed(2);
			total_subtotal += parseFloat(eval('document.form1.subtotal'+i).value);
			total_itbm += impuesto;
		<%} else {%>
		if(eval('document.form1.subtotal'+i) && eval('document.form1.subtotal'+i).value!=0){
			impuesto =parseFloat(eval('document.form1.subtotal'+i).value)*itbm/100;
			if(eval('document.form1.impuesto'+i) && (eval('document.form1.impuesto'+i).value =='' || parseFloat(eval('document.form1.impuesto'+i).value)==0)){ 
				eval('document.form1.impuesto'+i).value=impuesto.toFixed(2);
			} else impuesto = parseFloat(eval('document.form1.impuesto'+i).value);
			monto=parseFloat(eval('document.form1.subtotal'+i).value)+parseFloat(eval('document.form1.impuesto'+i).value);
			total_subtotal += parseFloat(eval('document.form1.subtotal'+i).value);
			total_itbm += impuesto;
		}
		<%}%>
		<%if(fg.equals("cxc") && (tipo_aju.equals("2") || tipo_aju.equals("0"))){%>monto = parseFloat(eval('document.form1.monto'+i).value);<%}%>
		eval('document.form1.monto'+i).value=monto.toFixed(2);
		total += parseFloat(monto);		
	}
	document.form1.total.value = total.toFixed(2);
	if(document.form1.total_itbm) document.form1.total_itbm.value = total_itbm.toFixed(2);
	if(document.form1.total_subtotal)document.form1.total_subtotal.value = total_subtotal.toFixed(2);
}

function reCalcItbm(i){
	var size = document.form1.keySize.value;
	var itbm = parent.document.ajuste.itbm.value;
	var monto=0.00, impuesto=0.00, total = 0.00, total_subtotal = 0.00, total_itbm = 0.00;
	if(eval('document.form1.impuesto'+i) && (isNaN(eval('document.form1.impuesto'+i).value) || eval('document.form1.impuesto'+i).value == '')){
		alert('Introduzca valor correcto en impuesto!');
		eval('document.form1.impuesto'+i).value=0;
	} else {
		for(i=0;i<size;i++){
			if(eval('document.form1.subtotal'+i) && eval('document.form1.subtotal'+i).value!=0){
				monto=parseFloat(eval('document.form1.subtotal'+i).value)+parseFloat(eval('document.form1.impuesto'+i).value);
				impuesto =parseFloat(eval('document.form1.impuesto'+i).value);
				total_subtotal += parseFloat(eval('document.form1.subtotal'+i).value);
				total_itbm += impuesto;
			}
			<%if(fg.equals("cxc") && (tipo_aju.equals("2") || tipo_aju.equals("0"))){%>monto = parseFloat(eval('document.form1.monto'+i).value);<%}%>
			eval('document.form1.monto'+i).value=monto.toFixed(2);
			total += parseFloat(monto);		
		}
	}
	document.form1.total.value = total.toFixed(2);
	if(document.form1.total_itbm) document.form1.total_itbm.value = total_itbm.toFixed(2);
	if(document.form1.total_subtotal)document.form1.total_subtotal.value = total_subtotal.toFixed(2);
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("id_cliente", "")%>
<%=fb.hidden("estado", "")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("observacion","")%>
<%=fb.hidden("tipo_aju","")%>
<%=fb.hidden("tipo_benef","")%>
<%=fb.hidden("id_referencia","")%>
<%=fb.hidden("id_solicitud","")%>

<table width="100%" align="center">
	<tr>
		<td><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<%
				int colspan = 8;
				if(fg.equals("cxp")) colspan = 5;
				%>
				<tr class="TextPanel">
					<td colspan="<%=colspan%>" align="right"><%=fb.button("addClientes","Agregar",false,(!fp.equals("adenda") && viewMode), "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
				</tr>
				
				<tr class="TextHeader">
					<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
					<td width="10%" align="center">A&ntilde;o</td>
					<td width="5%" align="center">Mes</td>
					<td width="10%" align="center">Factura No.</td>
					<%} else if(fg.equals("cxc") && tipo_aju.equals("2")){%>
					<td width="10%" align="center">No. TRX</td>
					<td width="5%" align="center">Tipo TRX</td>
					<%} else {%>
					<td width="10%" align="center">Reclamo</td>
					<%}%>
					<td width="25%" align="center">Descripci&oacute;n</td>
					<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
					<td width="10%" align="center">Monto</td>
					<td width="10%" align="center">Impuesto</td>
					<td width="10%" align="center">Total</td>
					<%} else {%>
					<td width="10%" align="center">Monto</td>
					<%}%>
					<td width="3%" align="center">&nbsp;</td>
				</tr>
				<%
				key = "";
				if (htClt.size() != 0) al = CmnMgr.reverseRecords(htClt);
				for (int i=0; i<htClt.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htClt.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
				<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
				<%=fb.hidden("mes_desc"+i,cdo.getColValue("mes_desc"))%>
				<%=fb.hidden("id_ref"+i,cdo.getColValue("id_ref"))%>
				<%=fb.hidden("tipo_trx"+i,cdo.getColValue("tipo_trx"))%>
				<%=fb.hidden("tipo_trx_desc"+i,cdo.getColValue("tipo_trx_desc"))%>
				<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>
				
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
				<tr class="<%=color%>">
				<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
				<td align="center"><%=cdo.getColValue("anio")%></td>
				<td align="center"><%=cdo.getColValue("mes_desc")%></td>
				<td align="center"><%=cdo.getColValue("id_ref")%></td>
				<%} else if(fg.equals("cxc") && tipo_aju.equals("2")){%>
				<td align="center"><%=cdo.getColValue("id_ref")%></td>
				<td align="center"><%=cdo.getColValue("tipo_trx_desc")%></td>
				<%}%>
				<td align="center"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,50,"Text10",null,null)%></td>
				<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
				<td align="right"><%=fb.decBox("subtotal"+i, cdo.getColValue("subtotal"), true, false, (fg.equals("cxc") && tipo_aju.equals("2")), 3, 12.4, "", "", "onChange='javascript:calcItbm("+i+");'", "", false, "", "")%></td>
				<td align="right"><%=fb.decBox("impuesto"+i, cdo.getColValue("impuesto"), true, false, false, 3, 12.4, "", "", "onChange='javascript:reCalcItbm("+i+");'", "", false, "", "")%></td>
				<td align="right"><%=fb.decBox("monto"+i, cdo.getColValue("monto"), true, false, (fg.equals("cxc") && tipo_aju.equals("0")?false:true), 3, 12.4, "", "", "onChange='javascript:calcItbm("+i+");'", "", false, "", "")%></td>
				<%} else {%>
				<td align="right"><%=fb.decBox("monto"+i, cdo.getColValue("monto"), true, false, (fg.equals("cxc") && tipo_aju.equals("2")), 3, 12.4, "", "", "", "", false, "", "")%></td>
				<%}%>
					<td width="3%" align="center">
					<%=fb.submit("dele"+i,"X",false,false, "text10", "", "onClick=\"javascript: document.form1.action.value=this.value;\"")%>
					</td>
				</tr>
				<%}%>
				<tr>
				<%
				System.out.println("fg="+fg+", tipo_aju="+tipo_aju);
				if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))) colspan=4;
				else if(fg.equals("cxc") && tipo_aju.equals("2")) colspan=3;
				else colspan=2;
				%>
				<td align="right" colspan="<%=colspan%>"><b>TOTAL:</b></td>
				<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
				<td align="right"><%=fb.decBox("total_subtotal", "0.00", true, false, true, 3, 12.4, "", "", "", "", false, "", "")%></td>
				<td align="right"><%=fb.decBox("total_itbm", "0.00", true, false, true, 3, 12.4, "", "", "", "", false, "", "")%></td>
				<%}%>
				<td align="right"><%=fb.decBox("total", "0.00", true, false, true, 3, 12.4, "", "", "", "", false, "", "")%></td>
				<tr><td>&nbsp;</td></tr>
				</tr>
				<%=fb.hidden("keySize",""+htClt.size())%>
			</table></td>
	</tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
fb.appendJsValidation("\n\tif (document.form1.action.value!='Guardar' && document.form1.action.value!='Guardar y Aprobar') return true;\n");
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
	SOL = new CommonDataObject();
	SOL.addColValue("compania", (String) session.getAttribute("_companyId"));
	if(request.getParameter("estado")!=null) SOL.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("observacion")!=null) SOL.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("tipo_aju")!=null) SOL.addColValue("tipo_aju", request.getParameter("tipo_aju"));
	if(request.getParameter("tipo_benef")!=null) SOL.addColValue("tipo_ben", request.getParameter("tipo_benef"));
	if(request.getParameter("id_solicitud")!=null) SOL.addColValue("id_solicitud", request.getParameter("id_solicitud"));
	if(request.getParameter("id_referencia")!=null) SOL.addColValue("id_referencia", request.getParameter("id_referencia"));
	if(request.getParameter("anio")!=null) SOL.addColValue("anio", request.getParameter("anio"));
	if(request.getParameter("mes")!=null) SOL.addColValue("mes", request.getParameter("mes"));
	

	htClt.clear();
	vClt.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cd = new CommonDataObject();
		if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){
			if(request.getParameter("anio"+i)!=null) cd.addColValue("anio", request.getParameter("anio"+i));
			if(request.getParameter("mes"+i)!=null) cd.addColValue("mes", request.getParameter("mes"+i));
			if(request.getParameter("mes_desc"+i)!=null) cd.addColValue("mes_desc", request.getParameter("mes_desc"+i));		
			if(request.getParameter("id_ref"+i)!=null) cd.addColValue("id_ref", request.getParameter("id_ref"+i));
			if(request.getParameter("saldo"+i)!=null) cd.addColValue("saldo", request.getParameter("saldo"+i));
		} else if(fg.equals("cxc") && tipo_aju.equals("2")){
			if(request.getParameter("id_ref"+i)!=null) cd.addColValue("id_ref", request.getParameter("id_ref"+i));
			if(request.getParameter("tipo_trx"+i)!=null) cd.addColValue("tipo_trx", request.getParameter("tipo_trx"+i));
			if(request.getParameter("tipo_trx_desc"+i)!=null) cd.addColValue("tipo_trx_desc", request.getParameter("tipo_trx_desc"+i));
		}
		cd.addColValue("compania", (String) session.getAttribute("_companyId"));
		if(request.getParameter("monto"+i)!=null) cd.addColValue("monto", request.getParameter("monto"+i));
		if(request.getParameter("descripcion"+i)!=null) cd.addColValue("descripcion", request.getParameter("descripcion"+i));
		if(request.getParameter("id"+i)!=null) cd.addColValue("id", request.getParameter("id"+i));
		if(request.getParameter("secuencia"+i)!=null) cd.addColValue("secuencia", request.getParameter("secuencia"+i));
		if(mode.equals("add") && request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")) cd.addColValue("secuencia", "0");	
		if(request.getParameter("estado"+i)!=null) cd.addColValue("estado", request.getParameter("estado"+i));	
		if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
			cd.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		} else {    
			cd.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		}
		if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3"))) {
			cd.addColValue("credito", request.getParameter("monto"+i));
			cd.addColValue("debito", "0");
			cd.addColValue("subtotal", request.getParameter("subtotal"+i));
			cd.addColValue("impuesto", request.getParameter("impuesto"+i));
		} else if(fg.equals("cxc") && tipo_aju.equals("2")) {
			cd.addColValue("debito", request.getParameter("monto"+i));
			cd.addColValue("credito", "0");
		} else if(fg.equals("cxc") && tipo_aju.equals("5")) {
			cd.addColValue("debito", request.getParameter("monto"+i));
			cd.addColValue("credito", "0");
			cd.addColValue("subtotal", request.getParameter("subtotal"+i));
			cd.addColValue("impuesto", request.getParameter("impuesto"+i));
		}

		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("dele"+i)==null){
			try {
				htClt.put(key, cd);
				if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3"))) vClt.add(SOL.getColValue("id_solicitud")+"_"+cd.getColValue("anio")+"_"+cd.getColValue("mes"));
				else if(fg.equals("cxc") && tipo_aju.equals("2")) vClt.add(SOL.getColValue("id_solicitud")+"_"+cd.getColValue("tipo_trx")+"_"+cd.getColValue("id_ref"));
				al.add(cd);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
			vClt.remove(cd.getColValue("id_cliente"));
		}
		System.out.println("..................................del="+request.getParameter("dele"+i)+", i="+i);
	}
System.out.println("action.....................................................="+request.getParameter("action")+", uAdmDel="+uAdmDel);

	if(uAdmDel.equals("1") || clearHT.equals("S")){
		response.sendRedirect("../planmedico/reg_pm_ajuste_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp+"&tipo_aju="+tipo_aju);
		return;
	}

	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../planmedico/reg_pm_ajuste_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fp="+fp+"&fg="+fg+"&tipo_aju="+tipo_aju);
		return;
	}

	Aju.setAl(al);

	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && (request.getParameter("action").equals("Guardar") || request.getParameter("action").equals("Guardar y Aprobar"))){
		SOL.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		SOL.addColValue("estado", "P");
		if(request.getParameter("action").equals("Guardar y Aprobar")) SOL.addColValue("aprobar", "S");
		Aju.setCdo(SOL);
		AjuMgr.add(Aju);
		id = AjuMgr.getPkColValue("id");
	} else if (mode.equalsIgnoreCase("edit")&& request.getParameter("action")!=null && (request.getParameter("action").equals("Guardar") || request.getParameter("action").equals("Guardar y Aprobar"))){    
		Aju.setCdo(SOL);
		SOL.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		AjuMgr.update(Aju);  
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (AjuMgr.getErrCode().equals("1")){%>
			parent.document.ajuste.errCode.value = <%=AjuMgr.getErrCode()%>;
			parent.document.ajuste.errMsg.value = '<%=AjuMgr.getErrMsg()%>';
			parent.document.ajuste.id.value = '<%=id%>';
			parent.document.ajuste.submit();
	<%} else throw new Exception(AjuMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>