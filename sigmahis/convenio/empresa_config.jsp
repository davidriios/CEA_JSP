<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";
String tabFunctions = "'1=tabFunctions(1)'";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
		fechaCrea = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userCrea = UserDet.getUserEmpId();
		userMod = UserDet.getUserEmpId();
	}
	else
	{
		if (code == null) throw new Exception("La Empresa no es válida. Por favor intente nuevamente!");

		fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		userMod = UserDet.getUserEmpId();

	/*Este Query no tiene todos los campos completos, razón la cual no se sabe su rol en la pantalla de captura. Campos faltantes: NOMBRE_ABREVIADO, EMP_ALQUILER, LIQUIDABLE_SINO, DESCUENTO, CAMBIO_PRECIO, IMPRIMIR_GNC. Revisar la tabla.*/

		sql = "SELECT a.codigo, a.nombre, a.abreviado as abrev, a.ruc, a.digito_verificador as digito, a.persona_reclamo as reclamo, a.representante_legal as repreLegal, a.persona_contacto as contacto, a.direccion, a.telefono, a.apartado_postal as apartado, a.zona_postal as zona, a.descripcion, a.fax, nvl(a.e_mail,'EMAIL@EMAIL.COM') as e_mail, a.tipo_empresa as tipoEmpCode, (select descripcion from tbl_adm_tipo_empresa where codigo = a.tipo_empresa) as tipoEmp, a.cg_1_cta1 as ctaFin1, a.cg_1_cta2 as ctaFin2, a.cg_1_cta3 as ctaFin3, a.cg_1_cta4 as ctaFin4, a.cg_1_cta5 as ctaFin5, a.cg_1_cta6 as ctaFin6, a.cg_compania as compania, a.contrato, a.porcentaje, a.ing_cta1 as ctaIng1, a.ing_cta2 as ctaIng2, a.ing_cta3 as ctaIng3, a.ing_cta4 as ctaIng4, a.ing_cta5 as ctaIng5, a.ing_cta6 as ctaIng6, a.clasificacion, a.cob_tasa_gasnet as cobrarAnest, a.cuenta_bancaria as ctaBanco, a.ruta_transito as rutaCode, nvl((select nombre_banco from tbl_adm_ruta_transito where ruta = a.ruta_transito),'NA') as ruta, a.tipo_cuenta as tipoCode, a.estado, a.tipo_persona as tipoPers, a.codigo_pais, a.email2, a.printing_flag as printingFlag, a.grupo_empresa, a.icd_version, nvl(a.use_employ,'N') as use_employ, nvl(genera_odp, 'S') genera_odp,a.forma_pago, a.printing_flag_sino, nvl(a.porcentaje_liq_reclamo, 0) porcentaje_liq_reclamo,porc_retencion,cod_ref,codigo_resp,nvl((select nombre from tbl_adm_empresa where codigo=a.codigo_resp),' ') as empresaDesc FROM tbl_adm_empresa a WHERE a.codigo = "+code;

		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>

<script language="javascript">
function listEmpresa(op)
{
	switch(op)
	{
		case 1:abrir_ventana('empresa_tipoempresa.jsp');
	break;

	case 2:abrir_ventana('../contabilidad/ctabancaria_catalogo_list.jsp?id=2');
	break;

	case 3:abrir_ventana('../contabilidad/ctabancaria_catalogo_list.jsp?id=3');
	break;

	case 4:abrir_ventana('empresa_rutatransito_list.jsp?id=1');
	case 5:abrir_ventana('../common/search_empresa.jsp?fp=empresa_config');
	break;
	}
}
function doAction()
{
	showHide(2);
}
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==1) iFrameName='alquilerFrame';
	if(iFrameName!='')window.frames[iFrameName].doAction();
}
</script>
<script language="javascript">
document.title="Empresa - "+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONVENIOS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("compId",cdo.getColValue("compania"))%>
<%=fb.hidden("userCrea",userCrea)%>
<%=fb.hidden("userMod",userMod)%>
<%=fb.hidden("fechaCrea",fechaCrea)%>
<%=fb.hidden("fechaMod",fechaMod)%>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<td id="TPrincipal" align="left" width="100%" onClick="javascript:verocultar(panel0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%" >&nbsp;<cellbytelabel>Generales</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0" style="visibility:visible;">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td>Versi&oacute;n ICD</td>
								<td><%=fb.select("icd_version","9,10",cdo.getColValue("icd_version"))%></td>
								<td><cellbytelabel>Tipo Configuraci&oacute;n</cellbytelabel></td>
								<td><%=fb.select(ConMgr.getConnection(),"select codigo, '['||codigo||'] '||descripcion from tbl_adm_tipo_empresa order by codigo","tipoEmpCode",cdo.getColValue("tipoEmpCode"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Empresa</cellbytelabel></td>
								<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,mode.equals("edit"),true,5)%><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,30,100)%></td>
								<td><cellbytelabel>Tipo de Empresa</cellbytelabel></td>
								<td><%=fb.select(ConMgr.getConnection(),"select codigo, '['||codigo||'] '||descripcion from tbl_adm_grupo_empresa order by codigo","grupo_empresa",cdo.getColValue("grupo_empresa"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Cuenta Contable</cellbytelabel></td>
								<td ><%=fb.textBox("ctaFin1",cdo.getColValue("ctaFin1"),false,false,true,2)%><%=fb.textBox("ctaFin2",cdo.getColValue("ctaFin2"),false,false,true,2)%><%=fb.textBox("ctaFin3",cdo.getColValue("ctaFin3"),false,false,true,2)%><%=fb.textBox("ctaFin4",cdo.getColValue("ctaFin4"),false,false,true,2)%><%=fb.textBox("ctaFin5",cdo.getColValue("ctaFin5"),false,false,true,2)%><%=fb.textBox("ctaFin6",cdo.getColValue("ctaFin6"),false,false,true,2)%>
								<%=fb.button("btnctacontable","...",true,false,null,null,"onClick=\"javascript:listEmpresa(2)\"")%></td>
								<td>Printing Flag</td>
								<td><%=fb.checkbox("printingFlag","S",(cdo.getColValue("printingFlag") != null && cdo.getColValue("printingFlag").equalsIgnoreCase("S")),false)%>Mostrar Nombre Completo en comentario de Impresi&oacute;n Fiscal
								<br><%=fb.checkbox("printingFlag_sino","S",(cdo.getColValue("printing_flag_sino") != null && cdo.getColValue("printing_flag_sino").equalsIgnoreCase("S")),false)%>Mostrar Inf. Centros III?</td>
							</tr>
							<tr class="TextRow01">
								<td width="19%"><cellbytelabel>Cuenta Ingreso</cellbytelabel></td>
								<td width="31%"><%=fb.textBox("ctaIng1",cdo.getColValue("ctaIng1"),false,false,true,2)%><%=fb.textBox("ctaIng2",cdo.getColValue("ctaIng2"),false,false,true,2)%><%=fb.textBox("ctaIng3",cdo.getColValue("ctaIng3"),false,false,true,2)%><%=fb.textBox("ctaIng4",cdo.getColValue("ctaIng4"),false,false,true,2)%><%=fb.textBox("ctaIng5",cdo.getColValue("ctaIng5"),false,false,true,2)%><%=fb.textBox("ctaIng6",cdo.getColValue("ctaIng6"),false,false,true,2)%>
								<%=fb.button("btnctaingreso","...",true,false,null,null,"onClick=\"javascript:listEmpresa(3)\"")%></td>
								<td width="18%"><cellbytelabel>Porcentaje</cellbytelabel></td>
								<td width="32%"><%=fb.decBox("porcentaje",cdo.getColValue("porcentaje"),false,false,false,20,3.2)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Nombre Abreviado</cellbytelabel></td>
								<td><%=fb.textBox("abrev",cdo.getColValue("abrev"),false,false,false,30,20)%></td>
								<td>Digito Verificador</td>
								<td><%=fb.textBox("digito",cdo.getColValue("digito"),false,false,false,20,4)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>RUC</cellbytelabel></td>
								<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,30,50)%></td>
								<td><cellbytelabel>Tipo de Persona</cellbytelabel></td>
								<td><%=fb.select("tipoPers","1=Jurídica,2=Natural",cdo.getColValue("tipoPers"))%><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
								<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,42,100)%></td>
								<td><cellbytelabel>Pa&iacute;s</cellbytelabel></td>
								<td><%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_sec_pais where codigo!=0 order by nombre","CODIGO_PAIS",cdo.getColValue("CODIGO_PAIS"),false,false,0)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
								<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,30,30)%></td>
								<td><cellbytelabel>Fax</cellbytelabel></td>
								<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,30,30)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Apartado Postal</cellbytelabel></td>
								<td><%=fb.textBox("apartado",cdo.getColValue("apartado"),false,false,false,30,50)%></td>
								<td><cellbytelabel>Zona Postal</cellbytelabel></td>
								<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,false,false,30,50)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Correo Electr&oacute;nico</cellbytelabel></td>
								<td><%=fb.emailBox("e_mail",cdo.getColValue("e_mail"),false,false,false,42,100)%></td>
								<td><cellbytelabel>Correo Electr&oacute;nico Segunda</cellbytelabel></td>
									<td><%=fb.emailBox("email2",cdo.getColValue("email2"),false,false,false,42,100)%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Presentar Reclamo a</cellbytelabel>:</td>
								<td><%=fb.textBox("reclamo",cdo.getColValue("reclamo"),false,false,false,42,100)%></td>
								<td><!--<cellbytelabel>Cobrar Tasa de Anestesia</cellbytelabel>--></td>
								<td><%=fb.hidden("cobrarAnest","N")%><%//=fb.select("cobrarAnest","N=No,S=Sí",cdo.getColValue("cobrarAnest"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Representante Legal</cellbytelabel>:</td>
								<td><%=fb.textBox("repreLegal",cdo.getColValue("repreLegal"),false,false,false,42,100)%></td>
								<td>Genera Orden de pago (Plan M&eacute;dico)?</td>
								<td>
								<%=fb.select("genera_odp","S=Si,N=No",cdo.getColValue("genera_odp"))%>
								<%=fb.hidden("contrato","N")%><%//=fb.select("contrato","N=No,S=Sí",cdo.getColValue("contrato"))%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>Contactar a</cellbytelabel>:</td>
								<td><%=fb.textBox("contacto",cdo.getColValue("contacto"),false,false,false,42,100)%></td>
								<td><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
								<td><%=fb.select("clasificacion","N=Nacional,I=Internacional",cdo.getColValue("clasificacion"))%>&nbsp;Liquidable<%=fb.select("liquidable","S=Si,N=No",cdo.getColValue("estado"))%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="4"><cellbytelabel>Utilizar Listado de Empleado en P&oacute;liza (Admisi&oacute;n - Beneficios)</cellbytelabel>: <%=fb.select("use_employ","N=No,Y=Si",cdo.getColValue("use_employ"))%></td>
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel>&nbsp;Forma de Pago (Sociedades Medicas)</cellbytelabel></td>
								<td><%=fb.select("forma_pago","1=CHEQUE,2=ACH",cdo.getColValue("forma_pago"))%></td>
								<td>&nbsp;Porcentaje en Liquidaci&oacute;n Reclamo</td>
								<td>&nbsp;<%=fb.intBox("porcentaje_liq_reclamo",cdo.getColValue("porcentaje_liq_reclamo"),false,false,false,5)%>/100</td>
						 	</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel id="42">Porcentaje de Retencion (Comision por Manejo de Honorarios Medicos en Hospital) % </cellbytelabel></td>
					    		<td><%=fb.decBox("porc_retencion",cdo.getColValue("porc_retencion"),false,false,false,5,"10.2",null,null,"")%>Ejemplo:5,10,15 </td> 
								<td align="right">&nbsp;</td>
								<td align="right">&nbsp;</td>
							</tr>
						 
						 
						 <tr class="TextRow01">
								 <td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
								 <td><%=fb.textBox("ctaBanco",cdo.getColValue("ctaBanco"),false,false,false,50,18)%></td>
							<td colspan="2">&nbsp;</td>
						  </tr>
						  <tr class="TextRow01">	 
								 <td><cellbytelabel>Tipo de Cuenta</cellbytelabel></td>
								 <td><%=fb.select("tipoCode","03=CORRIENTE,04=AHORRO,07=PRESTAMO,43=TARJ. CRÉDITO",cdo.getColValue("tipoCode"))%></td>
								 <td colspan="2">&nbsp;</td>
						 </tr>
						 <tr class="TextRow02">
								 <td><cellbytelabel>Ruta de Tr&aacute;sito</cellbytelabel></td>
								 <td colspan="3"><%=fb.textBox("rutaCode",cdo.getColValue("rutaCode"),false,false,true,5,9)%>
								 <%=fb.textBox("ruta",cdo.getColValue("ruta"),false,false,true,35)%>
																 <%=fb.button("btnruta","...",true,false,null,null,"onClick=\"javascript:listEmpresa(4)\"")%></td>
						 </tr>
						 <tr class="TextRow02">
								 <td><cellbytelabel>Aseguradora Responsable de pagar las Cuentas (Fusiones)</cellbytelabel></td>
								 <td colspan="3"><%=fb.textBox("codigo_resp",cdo.getColValue("codigo_resp"),false,false,true,5,9)%>
								 <%=fb.textBox("empresaDesc",cdo.getColValue("empresaDesc"),false,false,true,35)%>
																 <%=fb.button("btnruta","...",true,false,null,null,"onClick=\"javascript:listEmpresa(5)\"")%></td>
						 </tr>
						  
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr>
					<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="51">Lista De Envios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel3">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="41">Cod. Referencia</cellbytelabel></td>
							<td colspan="3">
							<%=fb.textBox("cod_ref",cdo.getColValue("cod_ref"),false,false,false,50,100)%></td>
						</tr>
						</table>
					</td>
				</tr>
	

	
	<tr>
					<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="41">Comentarios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel2">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="41">Observaciones</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("descripcion",cdo.getColValue("descripcion"),false,false,false,80,5,2000)%></td>
						</tr>
						</table>
					</td>
				</tr>
	

	
		<tr>
		<td>
<jsp:include page="../common/bitacora.jsp" flush="true">
	<jsp:param name="audCollapsed" value="n"></jsp:param>
	<jsp:param name="audTable" value="tbl_adm_empresa"></jsp:param>
	<jsp:param name="audFilter" value="<%="codigo="+cdo.getColValue("codigo")%>"></jsp:param>
</jsp:include>
		</td>
	</tr>
	<tr class="TextRow02">
		<td align="right">
			<%=fb.submit("save","Guardar",true,false)%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>
</table>
<!-- TAB3 DIV END HERE-->
</div>

<!----------------------------------------ALQUILER-------------------------------------------------->
<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",code)%>
<%=fb.hidden("baction","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr id="panel30">
					<td colspan="6"><iframe name="alquilerFrame" id="alquilerFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../admision/reg_alquiler.jsp?mode=<%=mode%>&id_ref=<%=code%>&tipo=S&tab=1"></iframe></td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%

if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Empresa'),0,'100%','');
<%
}
else
{
	String tabs = "'Empresa'";
	if(cdo.getColValue("tipoEmpCode").equals("1")) tabs += ",'Alquiler'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabs%>),0,'100%','',null,null,Array(<%=tabFunctions%>),null);

<%
}
%>
</script>

			</td>
		</tr>
		</table>
	</td>
	<td>&nbsp;</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_adm_empresa");
	cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("abreviado",request.getParameter("abrev"));
	cdo.addColValue("ruc",request.getParameter("ruc"));
	cdo.addColValue("digito_verificador",request.getParameter("digito"));
	cdo.addColValue("persona_reclamo",request.getParameter("reclamo"));
	cdo.addColValue("representante_legal",request.getParameter("repreLegal"));
	cdo.addColValue("persona_contacto",request.getParameter("contacto"));
	cdo.addColValue("direccion",request.getParameter("direccion"));
	cdo.addColValue("telefono",request.getParameter("telefono"));
	cdo.addColValue("apartado_postal",request.getParameter("apartado"));
	cdo.addColValue("zona_postal",request.getParameter("zona"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("fax",request.getParameter("fax"));
	cdo.addColValue("e_mail",request.getParameter("e_mail"));
	cdo.addColValue("tipo_empresa",request.getParameter("tipoEmpCode"));
	cdo.addColValue("cg_1_cta1",request.getParameter("ctaFin1"));
	cdo.addColValue("cg_1_cta2",request.getParameter("ctaFin2"));
	cdo.addColValue("cg_1_cta3",request.getParameter("ctaFin3"));
	cdo.addColValue("cg_1_cta4",request.getParameter("ctaFin4"));
	cdo.addColValue("cg_1_cta5",request.getParameter("ctaFin5"));
	cdo.addColValue("cg_1_cta6",request.getParameter("ctaFin6"));
	cdo.addColValue("grupo_empresa",request.getParameter("grupo_empresa"));
	cdo.addColValue("icd_version",request.getParameter("icd_version"));
	cdo.addColValue("use_employ",request.getParameter("use_employ"));
	cdo.addColValue("genera_odp",request.getParameter("genera_odp"));
	cdo.addColValue("porc_retencion",request.getParameter("porc_retencion"));	


	cdo.addColValue("usuario_modifica", (String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modifica",CmnMgr.getCurrentDate("dd/mm/yyyy"));

	cdo.addColValue("contrato",request.getParameter("contrato"));
	cdo.addColValue("porcentaje",request.getParameter("porcentaje"));
	cdo.addColValue("ing_cta1",request.getParameter("ctaIng1"));
	cdo.addColValue("ing_cta2",request.getParameter("ctaIng2"));
	cdo.addColValue("ing_cta3",request.getParameter("ctaIng3"));
	cdo.addColValue("ing_cta4",request.getParameter("ctaIng4"));
	cdo.addColValue("ing_cta5",request.getParameter("ctaIng5"));
	cdo.addColValue("ing_cta6",request.getParameter("ctaIng6"));
	cdo.addColValue("clasificacion",request.getParameter("clasificacion"));
	cdo.addColValue("cob_tasa_gasnet",request.getParameter("cobrarAnest"));
	cdo.addColValue("cuenta_bancaria",request.getParameter("ctaBanco"));
	cdo.addColValue("ruta_transito",request.getParameter("rutaCode"));
	cdo.addColValue("tipo_cuenta",request.getParameter("tipoCode"));
	cdo.addColValue("estado",request.getParameter("estado"));
	cdo.addColValue("tipo_persona",request.getParameter("tipoPers"));
	cdo.addColValue("cod_ref",request.getParameter("cod_ref"));
	if (request.getParameter("printingFlag") == null) cdo.addColValue("printing_flag","N");
	else cdo.addColValue("printing_flag",request.getParameter("printingFlag"));
	if (request.getParameter("printingFlag_sino") == null) cdo.addColValue("printing_flag_sino","N");
	else cdo.addColValue("printing_flag_sino",request.getParameter("printingFlag_sino"));
	cdo.addColValue("CODIGO_PAIS",request.getParameter("CODIGO_PAIS"));
	cdo.addColValue("email2",request.getParameter("email2"));
	if (request.getParameter("forma_pago") != null) cdo.addColValue("forma_pago",request.getParameter("forma_pago"));
	if (request.getParameter("porcentaje_liq_reclamo") != null) cdo.addColValue("porcentaje_liq_reclamo",request.getParameter("porcentaje_liq_reclamo"));
	
	cdo.addColValue("codigo_resp",request.getParameter("codigo_resp"));
	
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode);

	if (mode.equalsIgnoreCase("add")) {

		cdo.addColValue("user_adiciona", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_adiciona",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.setAutoIncCol("codigo");
		cdo.addColValue("cg_compania",request.getParameter("compId"));
		SQLMgr.insert(cdo);

	} else {

		cdo.setWhereClause("codigo = "+request.getParameter("code"));
		SQLMgr.update(cdo);

	}

	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/convenio/empresa_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/convenio/empresa_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/convenio/empresa_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrException());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>