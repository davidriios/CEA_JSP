<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CdcSolicitud"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA							MENU																																																										NOMBRE EN FORMA
CDC100120					INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS\SOLICITUD INSUMOS QUIRURGICOS		SOLICITUD PREVIA DE MAT. Y MED. PARA PACIENTES EN SALON DE OPERACIONES.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id = request.getParameter("id");
boolean viewMode = false;
System.out.println("fg........="+fg);


if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) fTranCarg.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	var almacenSOP = '0';
	var tipoSolicitud = parent.document.form0.tipoSolicitud.value;
	if(parent.document.form0.almacenSOP.value!='') almacenSOP = parent.document.form0.almacenSOP.value;
	<%
	if(type!=null && type.equals("1")){
	%>
	var fg				= document.form1.fg.value;

	abrir_ventana1('../common/sel_otros_cargos.jsp?mode=<%=mode%>&fg='+fg+'&fp=cargo_dev_so&inv_almacen='+almacenSOP+'&tipoTransaccion=C&tipoSolicitud='+tipoSolicitud);
	<%
	}
	%>
	calc();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function getComp(key){
	var fg				= document.form1.fg.value;
	var cs				= parent.document.form0.centroServicio.value;
	var empresa		= parent.document.paciente.empresa.value;
	var edad			= parent.document.paciente.edad.value;
	abrir_ventana1('../common/sel_componentes.jsp?mode=<%=mode%>&fg='+fg+'&fp=cargo_dev_pac&keyNPT='+key+'&v_empresa='+empresa+'&edad='+edad);
}

function calc(){
}

function _doSubmit(valor){
	parent.document.form0.baction.value = valor;
	parent.document.form0.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.baction.value 						= parent.document.form0.baction.value;
	document.form1.saveOption.value 				= parent.document.form0.saveOption.value;
	//document.form1.fg.value 								= parent.document.form0.fg.value;
	document.form1.clearHT.value 						= parent.document.form0.clearHT.value;

	document.form1.codCita.value 						= parent.document.form0.codCita.value;
	document.form1.fechaCita.value 					= parent.document.form0.fechaCita.value;
	document.form1.secuencia.value 					= parent.document.form0.secuencia.value;
	document.form1.codAlmacen.value 				= parent.document.form0.codAlmacen.value;
	document.form1.centroServicio.value 		= parent.document.form0.centroServicio.value;
	document.form1.tipoSolicitud.value 			= parent.document.form0.tipoSolicitud.value;
	document.form1.copiarInsumos.value 			= parent.document.form0.copiarInsumos.value;
	document.form1.habitacion.value 				= parent.document.form0.habitacion.value;
	if(parent.document.form0.chkSentSolAlm.checked) document.form1.sentSolAlmacen.value = 'S';
	//document.form1.centro_servicio.value 		= parent.document.form0.centro_servicio.value;

	if (!parent.form0Validation()){
		//return false;
	} else{
		//return true;
		if (document.form1.baction.value != 'Guardar')parent.form0BlockButtons(false);

		if (document.form1.baction.value == 'Guardar' && <%=fTranCarg.size()%> == 0)
		{
			top.CBMSG.warning('Por favor agregue por lo menos un cargo antes de guardar!');
			parent.form0BlockButtons(false);
		}
		else if(calc())
		{
		}
			document.form1.submit();
	}
	
}


function calMonto(j, k){
	var cantidad					= parseInt(eval('document.form1.cantidad'+j).value,10);
	var cant_cargo				= 0;
	var cant_devolucion		= 0;
	var monto 						= eval('document.form1.monto'+j).value;
	var tipoTransaccion		= parent.document.form0.tipoTransaccion.value;
	var fg 								= '<%=fg%>';

	if(isNaN(cantidad) || isNaN(monto)){
		top.CBMSG.warning('Introduzca valores numéricos!');
		if(x=='c')eval('document.form1.cantidad'+j).value = 0;
		else if(x=='p')eval('document.form1.monto'+j).value = 0;
		return false;
	} else {
		if(tipoTransaccion=='D' && cantidad > (cant_cargo-cant_devolucion)){
			top.CBMSG.warning('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');
			eval('document.form1.cantidad'+j).value = 0;
			eval('document.form1.cantidad'+j).select();
			return false;
		} else {
			eval('document.form1.monto_total'+j).value = (cantidad * monto).toFixed(2);
			calc();
			return true;
		}
	}
}


function chkPac(){
	var x = 0;
	if(x==0) return true;
	else return false;
}

function chkNumDoc(){
	/*
	var tipo_cliente = parent.document.form0.tipo_cliente.value;
	var centro_servicio = parent.document.form0.centro_servicio.value;
	var baction = document.form1.baction.value;
	if((tipo_cliente=='5' && centro_servicio == '123' && no_cargo_apps == '') || baction != 'Guardar') return true;
	else return false;
	*/
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+fTranCarg.size())%>

<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%//=fb.hidden("fPage",fPage)%>
<%=fb.hidden("codCita","")%>
<%=fb.hidden("fechaCita","")%>
<%=fb.hidden("secuencia","")%>
<%=fb.hidden("codAlmacen","")%>
<%=fb.hidden("centroServicio","")%>
<%=fb.hidden("tipoSolicitud","")%>
<%=fb.hidden("copiarInsumos","")%>
<%=fb.hidden("habitacion","")%>
<%=fb.hidden("sentSolAlmacen","N")%>
<%
String colspan = "8";
if(fg.equals("yyy")) colspan = "10";
%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="<%=colspan%>" align="right">
	<%=fb.button("addCargos", "Agregar Cargos", false, viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
</tr>
<%
if(fg.equals("zzz")){
%>
<tr class="TextHeader" align="center">
  <td width="15%" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
  <td width="33%" rowspan="2"><cellbytelabel>Nombre del Art&iacute;culo</cellbytelabel></td>
  <td width="10%" rowspan="2"><cellbytelabel>Unid</cellbytelabel>.</td>
  <td width="10%" rowspan="2"><cellbytelabel>Cant</cellbytelabel>.</td>
  <td width="3%" rowspan="2">&nbsp;</td>
</tr>
<tr class="TextHeader" align="center">
  <td><cellbytelabel>Flia</cellbytelabel>.</td>
  <td><cellbytelabel>Clase</cellbytelabel></td>
  <td><cellbytelabel>Cod</cellbytelabel>.</td>
</tr>
<%}%>
<%
if (fTranCarg.size() > 0) al = CmnMgr.reverseRecords(fTranCarg);

for (int i=0; i<fTranCarg.size(); i++)
{
	key = al.get(i).toString();									  

	CdcSolicitudDet ad = (CdcSolicitudDet) fTranCarg.get(key);

	String color = "";
	
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	String fecha = "fecha_cargo"+i;
	String setValidDate = "javascript:setValidDate("+i+");newHeight();";
	String fdtc = "";
	boolean readonly = true;
if(fg.equals("zzz")){
%>
<%=fb.hidden("art_familia"+i,ad.getArtFamilia())%>
<%=fb.hidden("art_clase"+i,ad.getArtClase())%>
<%=fb.hidden("cod_articulo"+i,ad.getCodArticulo())%>
<%=fb.hidden("descripcion"+i,ad.getDescripcion())%>
<%=fb.hidden("configCpt"+i,ad.getConfiguradoCpt())%>

<tr class="<%=color%>" align="center">
	<td><%=ad.getArtFamilia()%></td>
	<td><%=ad.getArtClase()%></td>
	<td><%=ad.getCodArticulo()%></td>
	<td align="left"><%=ad.getDescripcion()%></td>
	<td><%=fb.textBox("unidad"+i,ad.getUnidad(),false,false,true,6)%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidad(),false,false,viewMode,5,null,null,"")%></td>
	<td align="center"><%=fb.submit("del"+i,"x",false,viewMode)%></td>
</tr>
<%}%>
	<%
}
%>
<%=fb.hidden("keySize",""+fTranCarg.size())%>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	String dl = "";
	//Ajuste CdcSol = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	String anio = CmnMgr.getCurrentDate("yyyy");
	
	CdcSol.setCompania(request.getParameter("compania"));
	CdcSol.setCitaCodigo(request.getParameter("codCita"));
	CdcSol.setCitaFechaReg(request.getParameter("fechaCita"));
	CdcSol.setCodigoAlmacen(request.getParameter("codAlmacen"));
	CdcSol.setCentroServicio(request.getParameter("centroServicio"));
	CdcSol.setTipoSolicitud(request.getParameter("tipoSolicitud"));
	//CdcSol.setCopiarInsumos(request.getParameter("copiarInsumos"));
	CdcSol.setCopiarInsumos("N");
	CdcSol.setSentSolAlmacen(request.getParameter("sentSolAlmacen"));
	CdcSol.setEstado("P");	
	System.out.println("sentSolAlmacen="+request.getParameter("sentSolAlmacen"));
	if(CdcSol.getTipoSolicitud()!=null && CdcSol.getTipoSolicitud().equals("A")) CdcSol.setDescricion("ANESTESIA");
	else if(CdcSol.getTipoSolicitud()!=null && CdcSol.getTipoSolicitud().equals("Q")) CdcSol.setDescricion("QUIRURGICO");

	if(request.getParameter("secuencia") !=null && !request.getParameter("secuencia").equals("")) CdcSol.setSecuencia(request.getParameter("secuencia"));
	
	int size = Integer.parseInt(request.getParameter("size"));
	CdcSol.getCdcSolicitudDetail().clear();
	fTranCarg.clear();
	int lineNo = 0, _lineNo = 0;
	String _key = "", okey = "";
	
	for (int i=0; i<keySize; i++){
		CdcSolicitudDet det = new CdcSolicitudDet();
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setEstadoRenglon("Q");
		det.setPaquete("N");
		//det.setDescuento(request.getParameter("desc"+i));
		det.setConfiguradoCpt(request.getParameter("configCpt"+i)); 

		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));
		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));
		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));
		if(request.getParameter("unidad"+i)!=null && !request.getParameter("unidad"+i).equals("null") && !request.getParameter("unidad"+i).equals("")) det.setUnidad(request.getParameter("unidad"+i));

		String fck = CdcSol.getTipoSolicitud()+"_"+det.getCodArticulo();
		if(request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				fTranCarg.put(key,det);
				fTranCargKey.put(fck, key);
				CdcSol.getCdcSolicitudDetail().add(det);
				System.out.println("Adding item... "+key +"_"+fck);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}

		} else {
			dl = fck;
			if (fTranCargKey.containsKey(dl)){
				System.out.println("- remove item "+dl);
				System.out.println("- item "+(String) fTranCargKey.get(dl));
				fTranCarg.remove((String) fTranCargKey.get(dl));
				fTranCargKey.remove(dl);
			}
			//CdcSol.getCdcSolail().remove(i);
		}
	}
	System.out.println("dl......="+dl);
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so.jsp?mode="+mode+ "&change=1&type=2&fg="+fg);
		return;
	}

	System.out.println("baction="+request.getParameter("baction"));
	
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Agregar Cargos")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_so.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg);
		return;
	}
	
	System.out.println("request.getParameter(addCargos)="+request.getParameter("addCargos"));

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		CdcSol.setCompania((String) session.getAttribute("_companyId"));
		CdcSol.setUsuarioCreacion((String) session.getAttribute("_userName"));
		CdcSol.setUsuarioModif((String) session.getAttribute("_userName"));
		//CdcSol.setEmpreCodigo("");
		CdcSolMgr.add(CdcSol);
	}
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (CdcSolMgr.getErrCode().equals("1")){%>
			parent.document.form0.errCode.value = <%=CdcSolMgr.getErrCode()%>;
			parent.document.form0.errMsg.value = '<%=CdcSolMgr.getErrMsg()%>';
			parent.document.form0.sentSolAlmacen.value = '<%=CdcSol.getSentSolAlmacen()%>';
			parent.document.form0.submit();
	<%} else throw new Exception(CdcSolMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
