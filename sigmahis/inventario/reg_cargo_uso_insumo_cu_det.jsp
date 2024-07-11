<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
SAL310004						INVENTARIO (CUARTO DE URGENCIA)\TRANSACCIONES\INVENTARIO (CU/EXPEDIENTE).		CUARTO DE URGENCIAS-ADULTO.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new  StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fechai = request.getParameter("fechai");
String fechaf = request.getParameter("fechaf");
String pacId = request.getParameter("pacId");
String paciente = request.getParameter("paciente");
String codAlmacen = request.getParameter("codAlmacen");
String cds = request.getParameter("cds");

boolean viewMode = false;
if(mode == null) mode = "add";
if(fp==null) fp="cargo_dev_so";
if(mode.equals("view")) viewMode = true;
if(type==null) type = "";
if(cds==null) cds = "";
if (fechai == null) fechai = "";
if (fechaf == null) fechaf = "";
if (pacId == null) pacId = "";
if (paciente == null) paciente = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(codAlmacen != null && !codAlmacen.trim().equals(""))
	{
	if(type.equals("SP")){
		sbSql = new  StringBuffer();
		sbSql.append("select a.anio, a.solicitud_no codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, b.nombre_paciente, b.id_paciente identificacion, getaseguradora(a.adm_secuencia, a.pac_id, null) aseguradora, a.pac_id from tbl_inv_solicitud_pac a, vw_adm_paciente b where a.pac_id = b.pac_id and a.estado = 'P' and a.codigo_almacen = ");
		sbSql.append(codAlmacen);
		if(!cds.trim().equals("")){sbSql.append(" and a.centro_servicio =");sbSql.append(cds);}
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(a.fecha_documento) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(a.fecha_documento) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		if (!pacId.trim().equals("")) { sbSql.append(" and a.pac_id = "); sbSql.append(pacId); }
		if (!paciente.trim().equals("")) { sbSql.append(" and b.nombre_paciente like '%"); sbSql.append(paciente); sbSql.append("%'"); }
		sbSql.append(" order by a.solicitud_no asc");
	} else if(type.equals("CU")){
		sbSql = new  StringBuffer();
		sbSql.append("select a.anio, a.secuencia codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, b.nombre_paciente, b.id_paciente identificacion, decode(a.tipo, 'C', 'CARGO', 'D', 'DEVOLUCION') tipo_solicitud, a.empresa_desc aseguradora, a.pac_id from tbl_sal_cargos_usos a, vw_adm_paciente b where a.pac_id = b.pac_id and a.estado = 'P' and a.codigo_almacen = ");
		sbSql.append(codAlmacen);
		if(!cds.trim().equals("")){sbSql.append(" and a.centro_servicio =");sbSql.append(cds);}
		sbSql.append(" and a.tipo in ('C', 'D')");
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(a.fecha) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(a.fecha) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		if (!pacId.trim().equals("")) { sbSql.append(" and a.pac_id = "); sbSql.append(pacId); }
		if (!paciente.trim().equals("")) { sbSql.append(" and b.nombre_paciente like '%"); sbSql.append(paciente); sbSql.append("%'"); }
		sbSql.append(" and a.sop='N' order by a.secuencia asc");
	} else if(type.equals("DP")){
		sbSql = new  StringBuffer();
		sbSql.append("select a.anio, a.num_devolucion codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, b.nombre_paciente, b.id_paciente identificacion, getaseguradora(a.adm_secuencia, a.pac_id, null) aseguradora, a.pac_id from tbl_inv_devolucion_pac a, vw_adm_paciente b where a.pac_id = b.pac_id and a.estado = 'T' and codigo_almacen = ");
		sbSql.append(codAlmacen);
		if(!cds.trim().equals("")){sbSql.append(" and a.sala_cod =");sbSql.append(cds);}
		if (!fechai.trim().equals("")) { sbSql.append(" and trunc(a.fecha) >= to_date('"); sbSql.append(fechai); sbSql.append("','dd/mm/yyyy')"); }
		if (!fechaf.trim().equals("")) { sbSql.append(" and trunc(a.fecha) <= to_date('"); sbSql.append(fechaf); sbSql.append("','dd/mm/yyyy')"); }
		if (!pacId.trim().equals("")) { sbSql.append(" and a.pac_id = "); sbSql.append(pacId); }
		if (!paciente.trim().equals("")) { sbSql.append(" and b.nombre_paciente like '%"); sbSql.append(paciente); sbSql.append("%'"); }
		sbSql.append(" order by a.num_devolucion");
	}

	al = SQLMgr.getDataList(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){
	var fg				= document.form<%=type%>.fg.value;
	//newHeight();
	<%if(type.equals("SP")){%>
	//parent.setHeight('itemFrame0',document.body.scrollHeight);
	<%} else if(type.equals("CU")){%>
	//parent.setHeight('itemFrame1',document.body.scrollHeight);
	<%} else if(type.equals("DP")){%>
	//parent.setHeight('itemFrame2',document.body.scrollHeight);
	<%}%>
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function getDetalle(i){
	var fecha = eval('document.form<%=type%>.fecha_documento'+i).value;
	var codAlmacen = document.form<%=type%>.codAlmacen.value;
	var pac_id = eval('document.form<%=type%>.pac_id'+i).value;
	var codigo = eval('document.form<%=type%>.codigo'+i).value;
	var anio = eval('document.form<%=type%>.anio'+i).value;
	var adm_secuencia = eval('document.form<%=type%>.adm_secuencia'+i).value;
	<%if(fg.equals("CB")){%>
	abrir_ventana('../inventario/detalle_insumos_usos_bc.jsp?type=<%=type%>&fecha='+fecha+'&codAlmacen='+codAlmacen+'&pac_id='+pac_id+'&codigo='+codigo+'&anio='+anio+'&adm_secuencia='+adm_secuencia+'&fg=<%=fg%>');
	<%} else {%>
	abrir_ventana('../inventario/detalle_insumos_usos.jsp?type=<%=type%>&fecha='+fecha+'&codAlmacen='+codAlmacen+'&pac_id='+pac_id+'&codigo='+codigo+'&anio='+anio+'&adm_secuencia='+adm_secuencia);
	<%}%>
}

function cancelTrx<%=type%>(i){
	var p_pac_id   					= eval('document.form<%=type%>.pac_id'+i).value;
	var p_admision    		= eval('document.form<%=type%>.adm_secuencia'+i).value;
	var p_anio   					= eval('document.form<%=type%>.anio'+i).value;
	var p_no_doc   				= eval('document.form<%=type%>.codigo'+i).value;
	var p_fecha_doc   		= eval('document.form<%=type%>.fecha_documento'+i).value;
	var p_cod_almacen			= '<%=codAlmacen%>';
	var p_bloque					= '<%=type%>';

	if(p_bloque=='DP'){
		var estado=getDBData('<%=request.getContextPath()%>','\'N\'','tbl_fac_transaccion ft, tbl_inv_devolucion_pac dp','(ft.pac_id = dp.pac_id and ft.admi_secuencia = dp.adm_secuencia) and ft.num_solicitud = ltrim(rtrim(to_char (dp.anio))) || ltrim(rtrim(to_char(dp.num_devolucion))) and ft.tipo_transaccion = \'D\' and dp.anio = ' + p_anio + ' and dp.num_devolucion = ' + p_no_doc + ' and dp.compania = <%=(String) session.getAttribute("_companyId")%>','');
		if(estado!='') alert('Sr. Usuario: se cambiará el estado de la devolucion a procesada porque hay una Devolución en la cta del paciente que hace referencia a esta transacción!');
	}

	if(executeDB('<%=request.getContextPath()%>','call sp_sal_cancel_trx(<%=(String) session.getAttribute("_companyId")%>,'+p_pac_id+','+p_admision+','+p_anio+','+p_no_doc+',\''+p_fecha_doc+'\','+p_cod_almacen+',\''+p_bloque+'\',\'<%=(String) session.getAttribute("_userName")%>\')','')){
		alert('Cancelado satisfactoriamente!');
		window.location = '../inventario/reg_cargo_uso_insumo_cu_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fechai=<%=fechai%>&fechaf=<%=fechaf%>&pacId=<%=pacId%>&paciente=<%=paciente%>&codAlmacen=<%=codAlmacen%>&type=<%=type%>';
	}	else alert('Error al cancelar!');

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form"+type,request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("type",type)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fechai",fechai)%>
<%=fb.hidden("fechaf",fechaf)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("codAlmacen",codAlmacen)%>
<%
int colspan = 12;
if(type.equals("SP") || type.equals("DP")) colspan = 11;
%>
<tr class="TextHeader02">
	<td align="center">A&ntilde;o</td>
	<td align="center">Solicitud #</td>
	<td align="center">Fecha Nac.</td>
	<td align="center"># Pac.</td>
	<td align="center">#Adm.</td>
	<td align="center">Fecha</td>
	<td align="center">Nombre del Paciente</td>
	<td align="center">Identificaci&oacute;n</td>
	<%if(type.equals("CU")){%>
	<td align="center">Tipo de Solicitud</td>
	<%}%>
	<td align="center">Aseguradora</td>
	<td align="center">&nbsp;</td>
	<td align="center">&nbsp;</td>
</tr>
<%
for (int i=0; i<al.size(); i++){
	CommonDataObject ad = (CommonDataObject) al.get(i);
	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	boolean readonly = true;
%>
<%=fb.hidden("codigo"+i, ad.getColValue("codigo"))%>
<%=fb.hidden("anio"+i, ad.getColValue("anio"))%>
<%=fb.hidden("pac_id"+i, ad.getColValue("pac_id"))%>
<%=fb.hidden("adm_secuencia"+i, ad.getColValue("adm_secuencia"))%>
<%=fb.hidden("fecha_documento"+i, ad.getColValue("fecha_documento"))%>
<tr class="<%=color%>" align="center">
	<td><%=ad.getColValue("anio")%></td>
	<td><%=ad.getColValue("codigo")%></td>
	<td><%=ad.getColValue("fecha_nacimiento")%></td>
	<td><%=ad.getColValue("pac_id")%></td>
	<td><%=ad.getColValue("adm_secuencia")%></td>
	<td><%=ad.getColValue("fecha_documento")%></td>
	<td><%=ad.getColValue("nombre_paciente")%></td>
	<td><%=ad.getColValue("identificacion")%></td>
	<%if(type.equals("CU")){%>
	<td><%=ad.getColValue("tipo_solicitud")%></td>
	<%}%>
	<td><%=ad.getColValue("aseguradora")%></td>
	<td>
	<a href="javascript:getDetalle(<%=i%>);" class="BottonTrasl" title="Detalle">Detalle</a>
	</td>
	<td align="center">
			<%=fb.button("cancel"+i,"x",false,false,"text10", "", "onClick=\"javascript:cancelTrx"+type+"("+i+")\"")%>
	</td>
</tr>
<% } %>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	var closed = false;
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>