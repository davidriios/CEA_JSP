<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="OMMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />

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

OMMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "", fgSolX = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String compania = (String) session.getAttribute("_companyId");

String area = request.getParameter("area");
String cds = request.getParameter("cds");
String fieldsWhere = "";
String appendFilter ="";
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
if (paciente == null) paciente = "";
if (pacBarcode == null) pacBarcode = "";
if (fechaHasta == null) fechaHasta = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(fg.trim().equals("ME"))//SOLICITUDES DE FARMACIA
{
 		
		fieldsWhere ="  ((	a.cds_recibido = 'N' and a.estado_orden = 'A' and a.omitir_orden = 'N' and trunc(a.fecha_inicio) >= to_date('"+fecha+"','dd/mm/yyyy')";
		if(!fechaHasta.trim().equals("")){fieldsWhere += " and trunc(a.fecha_inicio) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
		fieldsWhere += " ) or (	a.cds_omit_recibido= 'N' and a.estado_orden = 'S' and a.omitir_orden = 'N' and trunc(a.fecha_suspencion) >= to_date('"+fecha+"','dd/mm/yyyy')";
		if(!fechaHasta.trim().equals("")){fieldsWhere += " and trunc(a.fecha_suspencion) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
		  
		fieldsWhere += " )  ) and a.tipo_orden = 2";
	
	appendFilter += "  /* and z.estado in ('A','E') */ and a.omitir_orden = 'N' and a.tipo_orden in(2,13,14) and ((trunc(a.fecha_inicio) >= to_date('"+fecha+"','dd/mm/yyyy')";
	if(!fechaHasta.trim().equals("")){appendFilter += " and trunc(a.fecha_inicio) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
	
	
	appendFilter += ") or ( a.estado_orden = 'S' and trunc(a.fecha_suspencion) >= to_date('"+fecha+"','dd/mm/yyyy')";
	if(!fechaHasta.trim().equals("")){appendFilter += " and trunc(a.fecha_suspencion) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
	
	 appendFilter += "))	";
}
	if (!pacBarcode.trim().equals("")) appendFilter += " and a.pac_id="+pacBarcode.substring(0,10)+" and a.secuencia="+pacBarcode.substring(10);
	if (!paciente.trim().equals("")) appendFilter += " and upper(b.nombre_paciente) like '%"+paciente.toUpperCase()+"%'";

sql = "select nvl(p.pendiente,0) pendiente, a.cds_omit_recibido,(select v.descripcion from tbl_sal_via_admin v where v.codigo=a.via) descVia, a.frecuencia, a.dosis,  nvl(f.observacion_ap,f.observacion) as observacion, decode(a.tipo_tubo, 'G', 'GOTEO', 'N', 'BOLO') tipo_tubo, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss AM') fecha_inicio, decode(estado_orden, 'S', to_char(a.fecha_suspencion, 'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM')) fecha_omitida, to_char(f.fecha_creacion,'dd/mm/yyyy hh12:mi:ss AM') fecha_despacho,   b.id_paciente as identificacion, b.nombre_paciente, (to_number(to_char(sysdate,'YYYY')) - to_number(to_char(b.fecha_nacimiento, 'YYYY'))) as edad, a.secuencia dsp_admision,(select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char(a.fecha_creacion,'hh12:mi:ss AM') hora_solicitud,nvl(a.cds_recibido,'N') cds_recibido ,a.secuencia as secuenciaCorte,a.tipo_orden, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, a.nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noOrden,a.pac_id, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida,(select cama from tbl_adm_atencion_cu where pac_id=a.pac_id and secuencia = a.secuencia) cama, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') as fecha_nacimiento, to_char(z.fecha_ingreso, 'dd/mm/yyyy') as fecha_ingreso, b.sexo, f.codigo_articulo, f.descripcion, f.cantidad, f.estado estado_desp, a.codigo_orden_med,f.id,f.usuario_modificacion as usuario,a.cantidad as cant from vw_adm_paciente b,tbl_sal_detalle_orden_med a, tbl_sal_orden_salida d, tbl_adm_admision z,(select count(*) pendiente,a.pac_id,a.secuencia from tbl_sal_detalle_orden_med a where "+fieldsWhere+" group by a.pac_id,a.secuencia) p, tbl_int_orden_farmacia f where f.cantidad = 0 and f.other1 = 0 and z.pac_id=a.pac_id and z.secuencia=a.secuencia and a.cod_salida=d.codigo(+) and a.pac_id = b.pac_id and a.pac_id = p.pac_id(+) and a.secuencia = p.secuencia(+)  "+appendFilter+" and a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.estado in ('P', 'A','D') order by a.fecha_creacion desc";
al = SQLMgr.getDataList(sql);

cdo = SQLMgr.getData("  select nvl(get_sec_comp_param("+compania+",'FAR_ALERTA_INTERVAL'),'0.5') alerta_interval,nvl(get_sec_comp_param("+compania+",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad from dual ");
if (cdo == null)
    cdo = new CommonDataObject();
String delay = cdo.getColValue("alerta_interval","0.5");
	//if (mode.equalsIgnoreCase("add") && change == null) ajuArt.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	checkPendingOM();
}

function doSubmit(){
	var action = parent.document.form1.baction.value;
	var x = 0;
	var size = <%=al.size()%>;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.submit();
}
function timer()
{
	var sec=180;
	setTimeout('reloadPage()',sec * 1000);/*parseInt(getDBData('<%=request.getContextPath()%>','nvl(tref_frm_tri_msec,5)','tbl_sal_exp_cli_param','',''),10)*/
}
function reloadPage()
{
	window.location.reload(true);
}


function checkPendingOM()
{
	var nOrden =parseInt(document.form1.nOrden.value,10);
	if((nOrden)>0)
	{
		document.getElementById('ordMedMsg').style.display='';
		var delay = parseInt("<%=delay%>" * 60 * 1000,10);
		soundAlert({delay:delay});
	}
}

function isChecked(k)
{
		var tipoOrden = eval('document.form1.tipo_orden'+k).value;
		var codTratamiento = eval('document.form1.cod_tratamiento'+k).value;
		var fg ='<%=fg%>';

		if(tipoOrden == 4 && codTratamiento == 1 &&fg=='ME')
		{		
				eval('document.form1.chkSolicitud'+k).checked = false;
				alert('Las órdenes de inhalotarapias solo pueden ser marcadas por INASA!!!');
		}
		else if(!eval('document.form1.chkSolicitud'+k).checked)
	  {
				eval('document.form1.chkSolicitud'+k).checked = true;
				alert('No es posible quitar la confirmación!!!');
				
		}
}

function edit(pac_id, no_adm, noorden, flag){
	var fecha = parent.document.form1.fecha.value;
	if(flag=='A') abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?mode=aprobar&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&fecha='+fecha);
	else if(flag=='R') abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?mode=recibir&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&fecha='+fecha);
}
function printOrden(pac_id, no_adm, noorden){abrir_ventana('../farmacia/print_ordenes_no_despachadas.jsp?fg=PAC&pacId='+pac_id+'&noAdmision='+no_adm+'&codOrdenMed='+noorden);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table width="100%" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg","")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por","")%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<tr>
	<td height="20">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="15%">&nbsp;</td>
			<td width="70%" align="center"><font size="3" id="ordMedMsg" style="display:none"><cellbytelabel id="1">Hay Ordenes pendientes</cellbytelabel>!</font><!--<embed id="ordMedSound" src="../media/chimes.wav" width="0" height="0" autostart="false" hidden="true" loop="true"></embed>--><script language="javascript">blinkId('ordMedMsg','red','white');</script></td>
			<td width="15%" align="right">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
					<td colspan="8">
						<table width="100%">
							<tr class="TextHeader" align="center">
								<td width="5%"><cellbytelabel id="2">No. Paciente</cellbytelabel></td>
								<td width="28%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
								<td width="10%"><cellbytelabel id="4">C&eacute;d./Pasap</cellbytelabel>.</td>
								<td width="10%"><cellbytelabel id="5">Fecha Nac</cellbytelabel>.</td>
								<td width="5%"><cellbytelabel id="6">Edad</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="7">Sexo</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="8">No. Admi</cellbytelabel>.</td>
								<td width="8%"><cellbytelabel id="9">Fecha Ingreso</cellbytelabel></td>
								<td width="10%"><cellbytelabel id="10">Cama</cellbytelabel></td>
								<td width="3%">&nbsp;</td>
								<td width="3%"><cellbytelabel id="11">Sec. Orden</cellbytelabel></td>
								<td width="8%">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
<%
paciente = "";
int nOrden =0;
for (int i=0; i<al.size(); i++)
{
	//key = al.get(i).toString();
	//AjusteDetails ad = (AjusteDetails) ajuArt.get(key);
	CommonDataObject cdod = (CommonDataObject) al.get(i);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%//=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%//=fb.hidden("fecha_nacimiento"+i,cdod.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("secuenciaCorte"+i,cdod.getColValue("secuenciaCorte"))%>
<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
<%=fb.hidden("orden"+i,cdod.getColValue("noOrden"))%>
<%=fb.hidden("tipo_orden"+i,cdod.getColValue("tipo_orden"))%>
<%=fb.hidden("estado_orden"+i,cdod.getColValue("estado_orden"))%>
<%=fb.hidden("cod_tratamiento"+i,cdod.getColValue("cod_tratamiento"))%>

<%
	if(!paciente.equals(cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med"))){
	String neIcon = "../images/cancel.gif";
	String neIconDesc = "";

%>
<tr>
	<td colspan="8">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel02">
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("pac_id")%></td>
			<td width="28%">&nbsp;<%=cdod.getColValue("nombre_paciente")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("identificacion")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("fecha_nacimiento")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("sexo")%></td>
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("dsp_admision")%></td>
			<td width="8%" align="center"><%=cdod.getColValue("fecha_ingreso")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("cama")%></td>
			<td width="3%" align="center"><img src="<%=neIcon%>" alt="<%=neIconDesc%>" height="20" width="20"></td>
			<td width="3%" align="center"><%=cdod.getColValue("codigo_orden_med")%></td>
      <td width="8%" align="center">
      <%if(cdod.getColValue("estado_desp").equals("P")){%>
			<!--<authtype type='6'><a href="javascript:edit(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("secuenciaCorte")%>,<%=cdod.getColValue("codigo_orden_med")%>,'A')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link03">Aprobar</font></a></authtype>-->
      <%} else if(cdod.getColValue("estado_desp").equals("A")){%>
			
      <%}%>
	  <authtype type='51'><a href="javascript:printOrden(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("secuenciaCorte")%>,<%=cdod.getColValue("codigo_orden_med")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link03">Imprimir</font></a></authtype><!---->
      </td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panel<%=i%>">
	<td colspan="8">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader01">
			<td width="5%"><cellbytelabel id="12">Estado</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="13">Hora Solicitud</cellbytelabel></td>
			<td width="50%" colspan="2"><cellbytelabel id="14">Descripci&oacute;n</cellbytelabel></td>
			<td width="16%"><cellbytelabel id="15">Fecha Inicio</cellbytelabel></td>
			<td width="19%"><cellbytelabel id="16">Fecha Desap.</cellbytelabel></td>
		</tr>
<%
	}
%>
<tr class="<%=color%>">
			<td><%=cdod.getColValue("dsp_estado")%></td>
			<td><%=cdod.getColValue("hora_solicitud")%></td>
			<td colspan="2">
			<%=cdod.getColValue("nombre")%>&nbsp;
      <font class="RedText">&gt;&gt;<cellbytelabel id="17">Cant</cellbytelabel>.=<%=cdod.getColValue("cantidad")%>&nbsp;-&nbsp;<%=cdod.getColValue("codigo_articulo")%>&nbsp;<%=cdod.getColValue("descripcion")%>&lt;&lt;</font>
      </td>
			<td><%=cdod.getColValue("fecha_inicio")%></td>
			<td><%=cdod.getColValue("fecha_despacho")%></td>
		</tr>
		<%if(fg.trim().equals("ME")){%>	
		<tr class="<%=color%>">
			<td colspan="4"><cellbytelabel id="18">Presentaci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("descVia")%>&nbsp;&nbsp;&nbsp;<cellbytelabel id="19">Concentraci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("dosis")%> 
			&nbsp;&nbsp;&nbsp;<cellbytelabel id="20">Frecuencia</cellbytelabel>:&nbsp;<%=cdod.getColValue("frecuencia")%><%if(cdo.getColValue("addCantidad").trim().equals("S")){%>&nbsp;&nbsp;&nbsp;<font class="RedTextBold" size="2">Cantidad Solicitada:<%=cdod.getColValue("cant")%> </font>&nbsp;&nbsp;&nbsp;<%}%></td>
			<td colspan="2"><cellbytelabel id="21">Observaci&oacute;n</cellbytelabel>:<font class="RedText"><%=cdod.getColValue("observacion")%>  </font> &nbsp;- Usuario Desap.:<%=cdod.getColValue("usuario")%></td>
		</tr>
		<%}%>
<%
	paciente = cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med");
	if(!paciente.equals(cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med")) && i>0){
%>
		</table>
	</td>
</tr>
<%
	}
}
%>
<%=fb.hidden("nOrden",""+nOrden)%>
<%=fb.hidden("size",""+al.size())%>
<tr class="TextRow02">
	<td colspan="9" class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="22">Solicitud(es)</cellbytelabel></td>
</tr>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
else
{
	
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		DetalleOrdenMed dom = new DetalleOrdenMed();

		if(request.getParameter("chkSolicitud"+i) != null && !request.getParameter("chkSolicitud"+i).trim().equals(""))
		{
			if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("A"))
		{
					dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
					dom.setCdsRecibidoUser((String) session.getAttribute("_userName"));
		}
		else if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("S"))
		{
			dom.setCdsOmitRecibido(request.getParameter("chkSolicitud"+i));
			dom.setCdsOmitRecibidoUser((String) session.getAttribute("_userName"));
		}
		//dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
		}else	dom.setCdsRecibido("N");
		dom.setEstadoOrden("C");//Para confirmar que se recibio la solicitud de las ordenes.
		dom.setPacId(request.getParameter("pac_id"+i));
		dom.setSecuencia(request.getParameter("secuenciaCorte"+i));
		dom.setTipoOrden(request.getParameter("tipo_orden"+i));
		dom.setOrdenMed(request.getParameter("orden"+i));
		dom.setCodigo(request.getParameter("codigo"+i));

		
		//dom.setEjecutado(request.getParameter("execute"+i));
		
		
		
		/*if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&&(request.getParameter("estado_orden"+i).trim().equals("S") || request.getParameter("estado_orden"+i).trim().equals("F")))
		{	
		
		}*/
		
		
		//dom.setOmitirOrden(request.getParameter("cancel"+i));
		//dom.setUsuarioModificacion((String) session.getAttribute("_userName"));
		//dom.setOmitirUsuario((String) session.getAttribute("_userName"));

		//dom.setObserSuspencion(request.getParameter("observacion"+i));
		//dom.setEstadoOrden(request.getParameter("suspender"+i));
		//dom.setFechaFin(request.getParameter("fechaFin"+i));
		//dom.setCodSalida(request.getParameter("cod_salida"+i));
		//dom.setFechaSuspencion(request.getParameter("fechaSuspencion"+i));

		al.add(dom);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	OMMgr.saveDetails(al);
	ConMgr.clearAppCtx(null);
	
	

	//om.setCompania((String) session.getAttribute("_companyId"));
	//om.setUsuarioCreacion((String) session.getAttribute("_userName"));

	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (OMMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=OMMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=OMMgr.getErrMsg()%>';
	parent.document.form1.submit();
<%} else throw new Exception(OMMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>