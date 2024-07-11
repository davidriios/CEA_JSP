<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="tcDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vtcDet" scope="session" class="java.util.Vector"/>
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
SolMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String tipo_trx = request.getParameter("tipo_trx");
String contrato = request.getParameter("num_contrato");
int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) tcDet.clear();
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
	abrir_ventana1('../planmedico/pm_sel_ach_tc.jsp?fp=plan_medico&mode=<%=mode%>&anio=<%=anio%>&mes=<%=mes%>&tipo_trx=<%=tipo_trx%>');

	<%
	}
	%>
	calc();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc(){
	var size = document.form1.keySize.value;
	var monto = 0.00, monto_cont = 0.00;
	for(i=0;i<size;i++){
		//eval('document.form1.monto'+i).value=(parseFloat(eval('document.form1.monto'+i).value)*parseInt(eval('document.form1.num_cuotas'+i).value));
		if(eval('document.form1.estado'+i).value!='R') {
		monto += parseFloat(eval('document.form1.monto'+i).value);
		var periodo = eval('document.form1.periodo'+i).value;
		if(eval('document.form1.tipo_trx'+i).value=='M') {
			periodo = Math.trunc(((parseFloat(eval('document.form1.monto_cont'+i).value)/parseFloat(eval('document.form1.monto'+i).value))*100/100).toFixed(2));
			var rem = (parseFloat(eval('document.form1.monto_cont'+i).value)*100)%(parseFloat(eval('document.form1.monto'+i).value)*100);
			console.log('monto_cont '+parseFloat(eval('document.form1.monto_cont'+i).value));
			console.log('monto '+parseFloat(eval('document.form1.monto'+i).value));
			console.log('periodo '+((parseFloat(eval('document.form1.monto_cont'+i).value)/parseFloat(eval('document.form1.monto'+i).value))*100/100).toFixed(2));
			console.log('rem '+rem);
			if(rem>0) ++periodo;
			eval('document.form1.num_cuotas'+i).value = periodo;
			monto_cont += parseFloat(eval('document.form1.monto_cont'+i).value);
		} else {
		eval('document.form1.monto_cont'+i).value = (parseFloat(parseFloat(eval('document.form1.monto'+i).value))*parseInt(eval('document.form1.num_cuotas'+i).value)).toFixed(2);
		monto_cont += parseFloat(eval('document.form1.monto_cont'+i).value);
		}}
	}
	document.form1.monto_total.value = monto.toFixed(2);
	document.form1.monto_total_cont.value = monto_cont.toFixed(2);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.anio.value = parent.document.contrato.anio.value;
	document.form1.mes.value = parent.document.contrato.mes.value;
	document.form1.tipo_trx.value = parent.document.contrato.tipo_trx.value;
	document.form1.id.value = parent.document.contrato.id.value;

	if (!parent.contratoValidation()){
		 parent.contratoBlockButtons(false);
		 return false;
	} else if (document.form1.action.value == 'Guardar'){
		if (!form1Validation()){
			form1BlockButtons(false);
			parent.contratoBlockButtons(false);
			return false;
		} else document.form1.submit();
	} else{
		if(document.form1.action.value != 'Guardar') {
			form1BlockButtons(false);
			parent.contratoBlockButtons(false);
			}
		document.form1.submit();
	}
}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	var x = size;
	if(x==0) {parent.CBMSG.warning('Seleccione al menos un Contrato!');return false;} 
	else return true;
}

function replica(valor, j){
	var size = document.form1.keySize.value;
	for(i=0;i<size;i++){
		if(i>j) eval('document.form1.referencia'+i).value = valor.toUpperCase();
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 

<%=fb.hidden("id",id)%> 
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("tipo_trx",tipo_trx)%>
        <tr class="TextPanel">
				<td align="center" width="6%"><cellbytelabel>Contrato</cellbytelabel></td>
				<td align="center" width="6%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td align="center" width="24%"><cellbytelabel>Beneficiario</cellbytelabel></td>
				<td align="center" width="23%"><cellbytelabel>Comentario</cellbytelabel></td>
				<td align="center" width="10%"><cellbytelabel>Referencia</cellbytelabel></td>
				<td align="center" width="6%"><cellbytelabel>Num. Cuotas</cellbytelabel></td>
				<td align="center" width="8%"><cellbytelabel>Cuota</cellbytelabel></td>
				<td align="center" width="8%"><cellbytelabel>Monto Pagado</cellbytelabel></td>
				<td align="center" width="6%"><cellbytelabel>Estado</cellbytelabel></td>
        <td width="3%" align="center"><%=fb.button("agrega","Agregar",true,viewMode,"","","onClick=\"javascript: _doSubmit(this.value);\"")%></td>
        </tr>
        <%
				key = "";
				if (tcDet.size() != 0) al = CmnMgr.reverseRecords(tcDet);
				StringBuffer sbEstado = new StringBuffer();
				sbEstado.append("A=Activo,R=Rechazado,P=Pendiente");
				if (viewMode) sbEstado.append(",I=Inactivo");
				for (int i=0; i<tcDet.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) tcDet.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
			<%=fb.hidden("id_cliente"+i,cdo.getColValue("id_cliente"))%>
			<%=fb.hidden("id_corredor"+i,cdo.getColValue("id_corredor"))%>
			<%=fb.hidden("id_contrato"+i,cdo.getColValue("id_contrato"))%>
			<%=fb.hidden("tipo_trx"+i,cdo.getColValue("tipo_trx"))%>
			<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
			<%=fb.hidden("nombre_cliente"+i,cdo.getColValue("nombre_cliente"))%>
			<%=fb.hidden("periodo"+i,cdo.getColValue("periodo"))%>

			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
				<td align="center"><%=cdo.getColValue("id_contrato")%> </td>
				<td align="center"><%=cdo.getColValue("id_cliente")%> </td>
				<td align="left"><%=cdo.getColValue("nombre_cliente")%> </td>
				<td align="left"><%=fb.textBox("comentario"+i,cdo.getColValue("comentario"),tipo_trx.equals("M"),false,viewMode,40,"Text10",null,"")%></td>
				<td align="left"><%=fb.textBox("referencia"+i,cdo.getColValue("referencia"),tipo_trx.equals("M"),false,viewMode,20,"Text10",null,"onChange='javascript:replica(this.value, "+i+")'")%></td>
				<td align="center"><%=fb.intBox("num_cuotas"+i,cdo.getColValue("num_cuotas"),false,false,true,2, "text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calc();\"")%></td>
				<td align="center"><%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calc();\"","Monto",false,"")%></td>
				<td align="center"><%=fb.decPlusBox("monto_cont"+i,cdo.getColValue("monto_app"),tipo_trx.equals("M"),false,(!tipo_trx.equals("M")||viewMode),10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calc();\"","Monto",false,"")%></td>
				<td align="center"><%=fb.select("estado"+i,sbEstado.toString(),cdo.getColValue("estado"),false,false,viewMode,0,"Text10","","",""," ")%></td>
				<td width="3%" align="center">
				<%if(cdo.getColValue("secuencia")!=null && cdo.getColValue("secuencia").equals("0")){%>
				<%=fb.submit("del"+i,"X",false,false, "text10", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
				<%}%>
				</td>
        </tr>
        <%
				}
				%>
        <tr class="TextRow01" >
          <td colspan="6" align="right"><cellbytelabel>Monto Total</cellbytelabel></td>
          <td align="center"><%=fb.decBox("monto_total","0",false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td align="center"><%=fb.decBox("monto_total_cont","0",false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
          <td width="3%" align="center" colspan="2">&nbsp;</td>
        </tr>
        <%=fb.hidden("keySize",""+tcDet.size())%> 
<%
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
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	String fecha_solicitud = CmnMgr.getCurrentDate("dd/mm/yyyy");
	Solicitud sol = new Solicitud();
	CommonDataObject cd = new CommonDataObject();
	if(mode.equals("add")){
		cd.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cd.addColValue("fecha_creacion", "sysdate");
	} else {
		cd.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cd.addColValue("fecha_modificacion", "sysdate");
		cd.addColValue("id", request.getParameter("id"));
	}
	cd.addColValue("anio", request.getParameter("anio"));
	cd.addColValue("mes", request.getParameter("mes"));
	cd.addColValue("tipo_trx", request.getParameter("tipo_trx"));
	cd.addColValue("compania", (String) session.getAttribute("_companyId"));
	sol.setCdo(cd);
	al = new ArrayList();
	
	tcDet.clear();
	vtcDet.clear();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("del"+i)==null){
			CommonDataObject cdo = new CommonDataObject();
			if(request.getParameter("estado"+i)!=null && request.getParameter("estado"+i).equals("")) cdo.addColValue("estado", "P");
			else cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("id_contrato", request.getParameter("id_contrato"+i));
			cdo.addColValue("id_cliente", request.getParameter("id_cliente"+i));
			cdo.addColValue("id_corredor", request.getParameter("id_corredor"+i));
			cdo.addColValue("monto", request.getParameter("monto"+i));
			cdo.addColValue("monto_app", request.getParameter("monto_cont"+i));
			cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"+i));
			cdo.addColValue("nombre_cliente", request.getParameter("nombre_cliente"+i));
			cdo.addColValue("periodo", request.getParameter("periodo"+i));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			else cdo.addColValue("secuencia", "0");
			if(request.getParameter("num_cuotas"+i)!=null && !request.getParameter("num_cuotas"+i).equals("")){
				cdo.addColValue("num_cuotas", request.getParameter("num_cuotas"+i));
				cdo.addColValue("periodo", request.getParameter("num_cuotas"+i));
			} else cdo.addColValue("num_cuotas", "1");
			if(request.getParameter("referencia"+i)!=null && !request.getParameter("referencia"+i).equals("")) cdo.addColValue("referencia", request.getParameter("referencia"+i));
			else cdo.addColValue("referencia", "");
			if(request.getParameter("comentario"+i)!=null && !request.getParameter("comentario"+i).equals("")) cdo.addColValue("comentario", request.getParameter("comentario"+i));
			else cdo.addColValue("comentario", "");
			if(mode.equals("add")){
				cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion","sysdate");
			} else {
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion","sysdate");
			}

			if ((i+1) < 10) key = "00"+(i+1);
			else if ((i+1) < 100) key = "0"+(i+1);
			else key = ""+(i+1);
		
			try {
				tcDet.put(key, cdo);
				vtcDet.addElement(cdo.getColValue("id_contrato")+"_"+cdo.getColValue("id_cliente"));
				al.add(cdo);
				System.out.println("adding item.... "+cdo.getColValue("id_contrato")+"_"+cdo.getColValue("id_cliente"));
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../planmedico/reg_tc_ach_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp+"&anio="+anio+"&mes="+mes+"&tipo_trx="+tipo_trx);
		return;
	}


	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../planmedico/reg_tc_ach_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&anio="+anio+"&mes="+mes+"&tipo_trx="+tipo_trx);
		return;
	}

	sol.setAl(al);
	if (request.getParameter("action").equals("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		if(mode.equals("add")) {
			SolMgr.addTrx(sol);
			id = SolMgr.getPkColValue("id");
		} else SolMgr.updateTrx(sol);
		ConMgr.clearAppCtx(null);
	}
	
	System.out.println("SolMgr.getErrCode().........="+SolMgr.getErrCode());

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (SolMgr.getErrCode().equals("1")){%>
			parent.document.contrato.errCode.value = <%=SolMgr.getErrCode()%>;
			parent.document.contrato.errMsg.value = '<%=SolMgr.getErrMsg()%>';
			parent.document.contrato.id.value = '<%=id%>';
			parent.document.contrato.submit();
	<%} else throw new Exception(SolMgr.getErrMsg());%>
		
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

