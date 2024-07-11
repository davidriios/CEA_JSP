<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
ArrayList alCaja = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String change = request.getParameter("change");
String key = "";
String sql = "", fgSolX = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String area = request.getParameter("area");
String solicitado_por = request.getParameter("solicitado_por");
String cds = request.getParameter("cds");
String fieldsWhere = "";
String appendFilter ="";
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
String compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");
String compReplica = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");
String compania=(String)session.getAttribute("_companyId");
String fp = request.getParameter("fp");
String orden = request.getParameter("orden");
String estado = request.getParameter("estado");

StringBuffer sbSql = new StringBuffer();

if(compFar == null || compFar.trim().equals("")) compFar = "";

if (paciente == null) paciente = "";
if (pacBarcode == null) pacBarcode = "";

if (mode == null) mode = "add";
if (fecha == null) fecha = "";
if (fechaHasta == null) fechaHasta = "";
if (fp == null) fp = "";
if (cds == null) cds = "";
if (orden == null) orden = "D";
if (estado == null) estado = "D";
if (cds == "null" || cds.trim().equals("")) cds = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
 	if (!pacBarcode.trim().equals("")) appendFilter += " and f.pac_id="+pacBarcode.substring(0,10)+" and nvl(f.adm_cargo,f.admision)="+pacBarcode.substring(10);
	if (!paciente.trim().equals("")) appendFilter += " and upper(b.nombre_paciente) like '%"+paciente.toUpperCase()+"%'";
	
sbSql.append("select distinct null noOrden, f.pac_id,f.admision,b.nombre_paciente,b.edad as edad,to_char(f.fec_nacimiento, 'dd/mm/yyyy') as fecha_nacimiento,to_char(z.fecha_ingreso, 'dd/mm/yyyy') as fecha_ingreso,b.id_paciente as identificacion, b.sexo,nvl((select ca.cama  from tbl_adm_atencion_cu ca where ca.pac_id = z.pac_id and ca.secuencia = z.adm_root),f.cds_cargo)  cama ,f.no_dev, z.centro_servicio cds,f.adm_cargo,z.adm_root from tbl_int_dev_farmacia f,vw_adm_paciente b,tbl_adm_admision z where  f.pac_id =b.pac_id  and f.pac_id =z.pac_id and nvl(f.adm_cargo,f.admision) = z.secuencia ");
	if(!fecha.trim().equals("")){sbSql.append(" and trunc(f.fecha_cargo) >= to_date('");sbSql.append(fecha);sbSql.append("','dd/mm/yyyy') ");}
	if(!fechaHasta.trim().equals("")) {sbSql.append(" and trunc(f.fecha_cargo) <= to_date('");sbSql.append(fechaHasta);sbSql.append("','dd/mm/yyyy') ");}
    if(!estado.trim().equals("")) {sbSql.append(" and f.estado ='");sbSql.append(estado);sbSql.append("' ");}
	if(estado.trim().equals("D")) {sbSql.append(" and f.no_cargo is  null  and f.other1 = 1 and z.estado not in ('I','N') ");}
	if(!cds.trim().equals("")&&!cds.trim().equals("null")) {sbSql.append(" and z.centro_servicio ='");sbSql.append(cds);sbSql.append("' ");}
	
 sbSql.append("    ");
sbSql.append(appendFilter);
sbSql.append(" order by f.no_dev "+((orden.trim().equals("D"))?"desc":" asc ")+", pac_id,nvl(f.adm_cargo,f.admision)");
al = SQLMgr.getDataList(sbSql.toString());

cdo = SQLMgr.getData("  select nvl(get_sec_comp_param("+compania+",'FAR_ALERTA_INTERVAL'),'0.5') alerta_interval,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_USA_CAJA_TURNO'),'N') as validaCja,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_FAR_USA_TURNO'),'N') as validaTurno from dual ");

if (cdo == null)
    cdo = new CommonDataObject();
String delay = cdo.getColValue("alerta_interval","0.5");

if(cdo.getColValue("validaCja").trim().equals("S")){
	  sbSql =  new StringBuffer();

	sbSql.append("select trim(to_char(z.codigo,'009')) as optValueColumn, z.codigo||' - '||z.descripcion as optLabelColumn, trim(to_char(z.no_recibo + 1,'00000009')) as optTitleColumn from tbl_cja_cajas z where z.compania = ");
	sbSql.append(compania);
	if (UserDet.getUserProfile().contains("0")) sbSql.append(" and z.estado = 'A'");
	else {
		sbSql.append(" and z.codigo in (");
		sbSql.append((String) session.getAttribute("_codCaja"));//cajas matriculadas en el IP de la PC que el usuario está conectado
		sbSql.append(") and z.ip = '");
		sbSql.append(request.getRemoteAddr());//muestre solo las que tengan registrado el IP
		sbSql.append("' and z.estado = 'A'");
		sbSql.append(" and exists (select null from tbl_cja_cajas_x_cajero y where compania_caja = z.compania and cod_caja = z.codigo and exists (select null from tbl_cja_cajera where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("' and estado = 'A' and cod_cajera = y.cod_cajero))");// and tipo in ('S','A')
	}
	sbSql.append(" order by z.descripcion");
	System.out.println("S Q L   CAJA =\n"+sbSql);
	alCaja = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	if (alCaja.size() == 0) throw new Exception("Este equipo no está definido como una Caja. Por favor consulte con su Administrador!");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){checkPendingOM();}
function doSubmit(){var action = parent.document.form1.baction.value;var x = 0;var size = <%=al.size()%>;document.form1.baction.value = parent.document.form1.baction.value;
document.form1.submit();}
function timer(){var sec=180;setTimeout('reloadPage()',sec * 1000);}
function reloadPage(){window.location.reload(true);}
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
function edit(k,flag,fp){//pac_id, no_adm, noorden, flag,fp,id){
var pac_id = eval('document.form1.pac_id'+k).value;
var no_adm = eval('document.form1.admision'+k).value;
var noorden = eval('document.form1.orden'+k).value;
var noDev   = eval('document.form1.noDev'+k).value;
var id = eval('document.form1.id'+k).value;
var admCargo = eval('document.form1.admCargo'+k).value;
var fecha = parent.document.form1.fecha.value;
var dsp ='S';
var validaCja ='<%=cdo.getColValue("validaCja","N")%>';
var validaTurno ='<%=cdo.getColValue("validaTurno","N")%>';
	<%if(!fg.trim().equals("REC")){%>
	if(flag=='D') abrir_ventana2('../farmacia/exp_orden_medicamentos_dev.jsp?mode=aprobar&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&id='+id+'&fecha='+fecha+'&fg=<%=fg%>&fp='+fp);
	<%}else{%>
	 
	    if((validaCja=='S'||validaTurno=='S'))
		{
			   var sizeCja = document.form1.sizeCja.value;
			  setTurno();
			 if(document.form1.turno.value!='')dsp='S';
			 else dsp='N'; 
		}
	if(dsp=='S'){
	abrir_ventana2('../farmacia/exp_orden_med_confirm.jsp?mode=aprobar&pacId='+pac_id+'&noAdmision='+no_adm+'&admCargo='+admCargo+'&tipo=A&noOrden='+noorden+'&id='+id+'&fecha='+fecha+'&fg=<%=fg%>&fp='+fp+'&noDev='+noDev+'&turno='+document.form1.turno.value+'&caja='+document.form1.caja.value+'&validaCja='+validaCja);
	}
	<%}%>
	//else if(flag=='PR')imprimir(pac_id, no_adm, noorden,id);
	//else if(flag=='PO')imprimirOrden(pac_id, no_adm, noorden);
}

function imprimir(k){
var pac_id = eval('document.form1.pac_id'+k).value;
var no_adm = eval('document.form1.admision'+k).value;
var noDev = eval('document.form1.noDev'+k).value;
abrir_ventana2('../farmacia/print_dev_medicamentos.jsp?pacId='+pac_id+'&noAdmision='+no_adm+'&fg=FAR&estado=<%=estado%>&docId='+noDev);
}
function imprimirOrden(pacId,adm,noOrden){abrir_ventana('../expediente/print_exp_seccion_5.jsp?fg=FARpacId='+pacId+'&noAdmision='+adm+'&noOrden='+noOrden+'&desc=O/M MEDICAMENTOS');}
function setTurno(){ var turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=compania%> and a.cod_caja in(<%=(String) session.getAttribute("_codCaja")%>)  and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%> <%=(cdo.getColValue("validaTurno").trim().equals("S"))?" and a.cod_turno in (select codigo from tbl_cja_turnos where cja_cajera_cod_cajera in (select cod_cajera from tbl_cja_cajera where usuario = \\\'"+(String) session.getAttribute("_userName")+"\\\'))":""%>');if(turno==undefined||turno==null||turno.trim()==''){document.form1.turno.value='';CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');return false;}else{document.form1.turno.value=turno;}return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("estado",""+estado)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("sizeCja",""+alCaja.size())%>
<%=fb.hidden("caja",""+(String) session.getAttribute("_codCaja"))%>
<%=fb.hidden("turno","")%>
<table width="100%" align="center">
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
					<td>
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
								<td width="10%"><cellbytelabel id="10">Cama/cds</cellbytelabel></td>
								<td width="3%">No. DEV</td>
								<td width="3%"><cellbytelabel id="11">&nbsp;</cellbytelabel></td>
								<td width="8%">&nbsp;</td>
							</tr>
<%
paciente = "";
String neIconDesc = "";
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
<%=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%=fb.hidden("id"+i,cdod.getColValue("id"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdod.getColValue("admision"))%>
<%=fb.hidden("orden"+i,cdod.getColValue("noOrden"))%>
<%=fb.hidden("noDev"+i,cdod.getColValue("no_dev"))%>
<%=fb.hidden("cds"+i,cdod.getColValue("cds"))%>
<%=fb.hidden("admCargo"+i,cdod.getColValue("adm_cargo"))%>

  		<tr class="<%=color%>">
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("pac_id")%></td>
			<td width="28%">&nbsp;<%=cdod.getColValue("nombre_paciente")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("identificacion")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("fecha_nacimiento")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("sexo")%></td>
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("admision")%><%=(!cdod.getColValue("admision").equals(cdod.getColValue("adm_cargo")))?" - ["+cdod.getColValue("adm_cargo")+" ] ":""%></td>
			<td width="8%" align="center"><%=cdod.getColValue("fecha_ingreso")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("cama")%></td>
			<td width="3%" align="center"><%=cdod.getColValue("no_dev")%></td>
			<td width="3%" align="center"><a href="javascript:imprimir(<%=i%>)"><img src="../images/printer.gif" alt="<%=neIconDesc%>" height="20" width="20" border="0" title="Orden medica"></a><!----></td>
	        <td width="8%" align="center"> 
    <%if(estado.trim().equals("D")){%>
	  <authtype type='50'>
      <a href="javascript:edit(<%=i%>,'D','')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><img src="../images/drug-basket.jpg" alt="<%=neIconDesc%>" height="20" width="20" border="0" title="Ordenes Aprobadas/despachadas"></a></authtype> <%}%>
	        </td>
		</tr>
		 
   <%
	}
%>
 		 
<%=fb.hidden("nOrden",""+nOrden)%>
<%=fb.hidden("size",""+al.size())%>
		</table>
	
					</td>
				</tr>


 <tr class="TextRow02">
	<td class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="24">Solicitud(es)</cellbytelabel></td>
</tr>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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