<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="FTransMgr" scope="page" class="issi.facturacion.FactTransaccionMgr"/>
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
FTransMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdoDest = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String pacIdDest = request.getParameter("pacIdDest");
String noAdmisionDest = request.getParameter("noAdmisionDest");

String dob = request.getParameter("dob");
String codPac = request.getParameter("codPac");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String colsPan ="";
boolean viewMode = false;
String pasaporte=request.getParameter("pasaporte");
String cedula=request.getParameter("cedula");
String cedulaPasaporte=request.getParameter("cedulaPasaporte");
String noAdmisionMadre = request.getParameter("noAdmisionMadre");
String pacIdMadre = request.getParameter("pacIdMadre");
String fNacMadre = request.getParameter("fNacMadre");
String codPacMadre = request.getParameter("codPacMadre");
String admRoot = request.getParameter("admRoot");
if(fg==null) fg = "";
if(fp==null) fp = "";
if(dob==null) dob = "";
if(codPac==null) codPac = "";
if (admRoot == null) admRoot = "";
if(pacId==null) pacId = "";
if(noAdmision==null) noAdmision = "";
if(pacIdDest==null) pacIdDest = "";
if(noAdmisionDest==null) noAdmisionDest = "";
if (mode == null) mode = "add";
if (mode.equals("view")) viewMode = true;
if(pasaporte == null)pasaporte ="";
if(cedula == null)cedula ="";
if(cedulaPasaporte == null)cedulaPasaporte ="";
if(codPacMadre == null)codPacMadre ="";

if (request.getMethod().equalsIgnoreCase("GET")){

//if (mode.equalsIgnoreCase("add")){

		if(!pacId.trim().equals("") && !noAdmision.trim().equals(""))
	{
		/*if (mode.equalsIgnoreCase("add"))
		{
			sbSql = new StringBuffer();
			sbSql.append("call sp_fac_cargar_transacciones(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",");
			sbSql.append(pacId);
			sbSql.append(",");
			sbSql.append(noAdmision);

			sbSql.append(",'");
			sbSql.append(fg);
			sbSql.append("')");
			SQLMgr.execute(sbSql.toString());
			if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
		}*/

//ADMISION ORIGEN
		sbSql.append("select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula, nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0) as edad, nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0) as edad_mes, (nvl(a.fecha_ingreso,a.fecha_creacion)-add_months(coalesce(p.f_nac,a.fecha_nacimiento),(nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0)*12+nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0)))) as edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr(c.descripcion,0,4)||'.' as categoriadesc, a.centro_servicio , d.descripcion as area_desc2 /*centro_servicio_desc*/ ,p.sexo ,ef.clasificacion, 'N' as descuento, 'N' as cambioPrecio, decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula,p.pasaporte) as cedulaPasaporte, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.secuencia admision ,a.estado estado, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria,  decode(a.estado,'A','ACTIVA','E','ESPERA') as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision,a.mes_cta_bolsa, a.num_factura ,ef.tipo_empresa,ef.empresa,ef.nombre nombre_empresa,a.pac_id_madre,a.cpac_madre,a.admi_madre,to_char(a.fnac_madre,'dd/mm/yyyy')fnac_madre from  vw_adm_paciente p ,tbl_adm_admision a, tbl_adm_tipo_admision_cia ta, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d,( select e.tipo_empresa,e.clasificacion,e.codigo empresa,e.nombre,f.pac_id , f.admision  from tbl_adm_empresa e,tbl_adm_beneficios_x_admision f   where    e.codigo=f.empresa and nvl(f.estado,'A')='A' and f.prioridad=1 ) ef where  a.pac_id = p.pac_id and  ta.categoria = a.categoria and ta.codigo = a.tipo_admision and a.categoria = c.codigo and a.centro_servicio=d.codigo /*and a.estado in('A','E')*/");

		if(fg.trim().equals("CBB"))
		{
				sbFilter.append(" and a.categoria in (select   nvl(substr(param_value,0,1),'') cat from tbl_sec_comp_param where compania in (-1,");
				sbFilter.append(session.getAttribute("_companyId"));
				sbFilter.append(") and param_name ='CT_TP_ADM') and a.tipo_admision in (select  nvl(substr(param_value,3,1),'') neo from tbl_sec_comp_param where compania in(-1,");
				sbFilter.append(session.getAttribute("_companyId"));
				sbFilter.append(") and param_name ='CT_TP_ADM') ");
						sbFilter.append(" and a.estado not in ('N') ");
				if(!cedulaPasaporte.trim().equals(""))
				{
				 sbSql.append("  and decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte) = '");
				 sbSql.append(cedulaPasaporte);
				 sbSql.append("'");
				}

		}

		sbFilter.append(" and a.pac_id =");
		sbFilter.append(pacId);
		sbFilter.append(" and a.secuencia = ");
		sbFilter.append(noAdmision);
		sbSql.append("  and a.pac_id = ef.pac_id(+) and a.secuencia = ef.admision(+)   ");
		//if(fg.trim().equals("CBB")){sbSql.append(sbFilter);}
		//sbSql.append(" order by to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') desc , nombre, a.secuencia ");

		cdo = SQLMgr.getData(sbSql.toString()+sbFilter.toString());

		if (cdo == null)
		{
			cdo = new CommonDataObject();
			cdo.addColValue("fecha_nacimiento","");
		}
		else
		{
			if(fg.trim().equals("CBB"))
			{
				sbFilter = new StringBuffer();
				sbFilter.append(" and a.pac_id =");
				sbFilter.append(cdo.getColValue("pac_id_madre"));
				sbFilter.append(" and a.secuencia = ");
				sbFilter.append(cdo.getColValue("admi_madre"));
				}
			else
			{
				sbFilter = new StringBuffer();
				sbFilter.append(" and a.pac_id =");
				sbFilter.append(pacIdDest);
				sbFilter.append(" and a.secuencia = ");
				sbFilter.append(noAdmisionDest);
			}

				cdoDest = SQLMgr.getData(sbSql.toString()+sbFilter.toString());
			if (cdoDest == null)
			{
				cdoDest = new CommonDataObject();
				cdoDest.addColValue("fecha_nacimiento","");
			}

		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturación - Transferencia de Cargos '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function doAction(){}
function printCargos(fg){var pacId=document.form0.pacId.value;var noAdmision=document.form0.admSecuencia.value;if((pacId == '' || pacId == 0 ) || (noAdmision == '' || noAdmision == 0)) CBMSG.alert('Seleccione paciente!');else abrir_ventana1('../facturacion/print_cargo_dev.jsp?fg='+fg+'&noSecuencia='+noAdmision+'&pacId='+pacId);}
function printCargos2(){var pacId=document.form0.pacId2.value;var noAdmision=document.form0.admSecuencia2.value;if((pacId == '' || pacId == 0 ) || (noAdmision == '' || noAdmision == 0)) CBMSG.alert('Seleccione paciente!');else abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);}
function showPacienteList2(){var pacId=document.form0.pacId.value;var noAdmision=document.form0.admSecuencia.value;var option = '<%=fg%>';var dia =0;
if(option=='TC'){dia=getDBData('<%=request.getContextPath()%>','case when trunc(sysdate)-to_date(\'01/\'||to_char(sysdate,\'mm/yyyy\'),\'dd/mm/yyyy\')<=3 then 0 else 1 end','dual','');}if(dia==0){if(option!='CBB'){abrir_ventana1('../common/sel_paciente.jsp?fp=transferencia2&fg=<%=fg%>&admRoot=<%=admRoot%>&cod_paciente='+pacId+'&noAdmision='+noAdmision);}else{CBMSG.alert('La admision seleccionada no es de Neonatologia!!. Favor Verificar!!');}}else CBMSG.alert('La Fecha Actual debe estar entre los tres (3) primeros días del mes... ');}
function copiarCargos()
{
	var option = '<%=fg%>';
	var pacId=document.form0.pacId.value;
	var pacId2=document.form0.pacId2.value;
	var noAdmision=document.form0.admSecuencia.value;
	var noAdmision2=document.form0.admSecuencia2.value;
	var estadoA=document.form0.estadoA.value;//origen
	var estadoB=document.form0.estadoB.value;//destino
	var tipo_empresa =document.form0.tipo_empresa.value;//origen
	var tipo_empresa2 =document.form0.tipo_empresa2.value;//Destino
	var clasificacion =document.form0.clasificacion.value;//origen
	var clasificacion2 =document.form0.clasificacion2.value;//destino
	var v_empresa =document.form0.empresa.value;//fuente
	var v_empresa2 =document.form0.empresa2.value;//destino
	var v_flag ='';
	var dob=eval('document.form0.fechaNacimiento2').value;
		var codPac=eval('document.form0.codigoPaciente2').value;

	var x=0;
	var msg ='';

				if((pacId == null || pacId =='' || pacId =='0' )&& (noAdmision == null || noAdmision ==''))
				{msg += '\n Los datos de la admisión Origen están incompletos...!';x++;}
				if((pacId2 == null || pacId2 =='' || pacId2 =='0' )&& (noAdmision2 == null || noAdmision2 ==''))
				{msg += '\n Los datos de la admisión Destino están incompletos...!';x++;}
			if(msg =='')
			{
				if(option!='CBB' && msg =='')
				{
					if((pacId != null && pacId !='' && pacId != '0') &&(pacId2 != null && pacId2 !='' && pacId2 != '0') && pacId != pacId2)
					{msg +='\n Los datos de las admisiones no Coinciden con el paciente...!';x++;}
				}
				if( ((pacId != null || pacId !=''|| pacId !='0' )&& (noAdmision2 != null || noAdmision2 !='')) && ( pacId == pacId2 &&  noAdmision == noAdmision2)&&msg =='')
				{msg +='\n No se Puede Transferir los Cargos a la misma admisión...!';x++;}
				if((pacId2 == null || pacId2 ==''|| pacId2 =='0' )&& (noAdmision2 == null || noAdmision2 =='')){msg += '\n Debe seleccionar la Admisión a donde transferira los cargos...!';x++;}
				if(option!='CBB' && msg =='')
				{
					if(estadoA !='E'){msg +='\n La admisión Origen debe estar en ESPERA...!';x++;}
					if(estadoB !='E'){msg +='\n La admisión Destino debe estar en ESPERA...!';x++;}
				}
				if(msg =='')
				{
					if(v_empresa ==''||v_empresa == null){msg +='\n La admisión Origen no Tiene Beneficio Asignado. Verifique....!';x++;}
					if(v_empresa2 ==''||v_empresa2 == null){msg +='\n La admisión Destino no Tiene Beneficio Asignado. Verifique....!';x++;}
				}
				if(option=='TPI' && msg =='')
				{//alert('tipo_empresa = '+tipo_empresa+'  tipo_empresa2 ='+tipo_empresa2+'  clasificacion2 = '+clasificacion2+' clasificacion = '+clasificacion);
					if(tipo_empresa !='5' && tipo_empresa2!='5'){msg +='\n La admisión FUENTE o la admision DESTINO deben ser de tipo INTERNACIONAL......!';x++;}
					//if(tipo_empresa == tipo_empresa2){msg +='\n La admisión FUENTE y la admision DESTINO no pueden ser del mismo TIPO (Nacional, internacional)......!';x++;}
					if(msg =='')if(clasificacion2 !='I'&&clasificacion !='I'){msg +='\n La admisión ORIGEN O DESTINO debe ser  de Tipo INTERNACIONAL......!';x++;}
					//if(v_empresa != v_empresa2){msg +='\n Para poder transferir las transacciones las empresas de las admisiones deben ser iguales.!';x++;}
				}

		if(msg ==''){
		var cargos = getDBData('<%=request.getContextPath()%>','count(*), nvl(sum(decode(tipo_transaccion,\'C\',cantidad*(monto+nvl(recargo,0)))),0) +      nvl(sum(decode(tipo_transaccion,\'H\',cantidad*(monto+nvl(recargo,0)))),0) - nvl(sum(decode(tipo_transaccion,\'D\',cantidad*(monto+nvl(recargo,0)))),0) v_total ','tbl_fac_detalle_transaccion',' compania = <%=(String) session.getAttribute("_companyId")%> and pac_id = '+pacId+' and fac_secuencia = '+noAdmision,'')
		if(cargos.substring(0,cargos.indexOf('|')) ==0 )
		{ msg +='\n La admisión FUENTE No tiene transacciones registradas para transferir......!'; x++;
			CBMSG.alert(' La admisión FUENTE No tiene transacciones registradas para transferir......!');
		}
		if(cargos.substring(0,cargos.indexOf('|')) !=0 && cargos.substring(cargos.lastIndexOf('|')+1) == 0 )
		{  msg +='\n La admisión FUENTE tiene todos los cargos devueltos.  No se podrán transferir los cargos de esta admisión.!'; x++;
			 CBMSG.alert(' La admisión FUENTE tiene todos los cargos devueltos.  No se podrán transferir los cargos de esta admisión.!');
		}
		}
		if(option=='TPI' && msg =='')
		{
			var cargos2 = getDBData('<%=request.getContextPath()%>','count(*), nvl(sum(decode(tipo_transaccion,\'C\',cantidad*(monto+nvl(recargo,0)))),0) +      nvl(sum(decode(tipo_transaccion,\'H\',cantidad*(monto+nvl(recargo,0)))),0) - nvl(sum(decode(tipo_transaccion,\'D\',cantidad*(monto+nvl(recargo,0)))),0) v_total ','tbl_fac_detalle_transaccion',' compania = <%=(String) session.getAttribute("_companyId")%> and pac_id = '+pacId2+' and fac_secuencia = '+noAdmision2,'')
			if(cargos2.substring(0,cargos2.indexOf('|')) !=0 && cargos2.substring(cargos2.lastIndexOf('|')+1) != 0 )
			{  msg +='\n La admisión DESTINO no está completamente devuelta......!'; x++;
				 CBMSG.alert(' La admisión DESTINO no está completamente devuelta.!');
			}
		 }
	 }
		if(x==0)
		{
			CBMSG.confirm(' \nEstá seguro que desea Transferir los Cargos??',{'cb':function(r){
	 if(r=='Si'){

		showPopWin('../common/run_process.jsp?fp=transferir_cargos&actType=51&docType=TRF&docId='+noAdmision+'&docNo='+noAdmision+'&pacId='+pacId+'&compania=<%=(String) session.getAttribute("_companyId")%>&fNacMadre='+dob+'&codPacMadre='+codPac+'&pacIdMadre='+pacId2+'&admMadre='+noAdmision2+'&idPaciente=<%=cedulaPasaporte%>&admRoot=<%=admRoot%>&fg=<%=fg%>',winWidth*.75,winHeight*.20,null,null,'');
			} }});/*}else CBMSG.warning ('Proceso Cancelado ');*/
		}
		else{CBMSG.alert('No se puede Transferir los cargos por las Siguientes razones:   '+msg);}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TRANSFERENCIA DE CARGOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
 <tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("admRoot",admRoot)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("nChange",""+al.size())%>
<%=fb.hidden("estadoA",""+cdo.getColValue("estado"))%>
<%=fb.hidden("clasificacion",cdo.getColValue("clasificacion"))%>
<%=fb.hidden("clasificacion2","")%>
<%=fb.hidden("empresa",cdo.getColValue("empresa"))%>
<%=fb.hidden("empresa2",""+cdoDest.getColValue("empresa"))%>
<%=fb.hidden("tipo_empresa",cdo.getColValue("tipo_empresa"))%>
<%=fb.hidden("tipo_empresa2","")%>
<%String className="Text12Bold RedText";%>
	<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%" align="center">&nbsp;TRANSFERENCIA DE CARGOS </td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
				</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader01" align="center">
							<td>A  D  M  I  S  I  O  N&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;O  R  I  G  E  N</td>
						<td>A  D  M  I  S  I  O  N&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;D  E  S  T  I  N  O</td>
				</tr>

				<tr class="TextRow02">
					<td width="50%">
					<table width="100%" cellpadding="0" cellspacing="1">
						<tr>
							<td>Categoría</td>
						<td><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion,codigo from tbl_adm_categoria_admision  order by 1","categoria",cdo.getColValue("categoria"),false,true,0,"")%></td>
						<td>Estado</td>
						<td><%=fb.select("estado","A=ACTIVA,E=ESPERA,I=INACTIVO,N=ANULADA",cdo.getColValue("estado"),false,true,0,"Text10",null,null,"","S")%></td>
					</tr>
					<tr>
							<td>ID. Pac.:</td>
						<td><%=fb.textBox("pacId",cdo.getColValue("pac_id"),false,false,true,10,"Text10",null,null)%>
							<%=fb.hidden("fechaNacimiento",cdo.getColValue("fecha_nacimiento"))%>
							<%=fb.hidden("codigoPaciente",cdo.getColValue("codigo_paciente"))%></td>
						<td>No. Admisi&oacute;n</td>
						<td><%=fb.intBox("admSecuencia",cdo.getColValue("admision"),false,false,true,3,"Text10",null,null)%>
						<%=fb.button("btnPaciente","...",true,true,null,"Text10","onClick=\"javascript:showPacienteList()\"")%></td>
					</tr>
					<tr>
							<td>Nombre:</td>
						<td colspan="3"><%=fb.textBox("nombrePaciente",cdo.getColValue("nombre"),viewMode,false,true,55,className,null,null)%></td>
					</tr>
					<tr>
							<td>Fecha Ingreso.</td>
						<td><%=fb.textBox("fechaIngreso",cdo.getColValue("fecha_ingreso"),false,false,true,10,"Text10",null,null)%></td>
						<td>Fecha Egreso.</td>
						<td><%=fb.textBox("fechaEgreso",cdo.getColValue("fecha_egreso"),false,false,true,10,"Text10",null,null)%></td>
					</tr>
					<tr>
						<td>C&eacute;dula / Pasaporte</td>
						<td><%=fb.textBox("cedulaPasaporte",cdo.getColValue("cedulaPasaporte"),false,false,true,25,className,null,null)%></td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
							<td>Beneficio</td>
						<td colspan="3"><%=fb.textBox("desc_empresa",cdo.getColValue("nombre_empresa"),false,false,true,40,"Text10",null,null)%></td>
					</tr>
					</table>
					</td>
					<td width="50%" valign="top">
					<table width="100%" cellpadding="0" cellspacing="1">
					<tr>
							<td>Categoría</td>
						<td><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||'-'||descripcion,codigo from tbl_adm_categoria_admision   order by 1","categoria2",cdoDest.getColValue("categoria"),false,true,0,"S")%></td>
						<td>Estado</td>
						<td><%=fb.select("estadoB","A=ACTIVA,E=ESPERA,I=INACTIVO,N=ANULADA",cdoDest.getColValue("estado"),false,true,0,"Text10",null,null,"","S")%></td>
					</tr>
					<tr>
							<td>ID. Pac.:</td>
						<td><%=fb.textBox("pacId2",cdoDest.getColValue("pac_id"),false,false,true,10,"Text10",null,null)%>
							<%=fb.hidden("fechaNacimiento2",cdoDest.getColValue("fecha_nacimiento"))%>
							<%=fb.hidden("codigoPaciente2",cdoDest.getColValue("codigo_paciente"))%>
						</td>
						<td>No. Admisi&oacute;n</td>
						<td><%=fb.intBox("admSecuencia2",cdoDest.getColValue("admision"),false,false,true,3,"Text10",null,null)%>
						<%=fb.button("btnPaciente2","...",true,viewMode,null,"Text10","onClick=\"javascript:showPacienteList2()\"")%></td>
					</tr>
					<tr>
							<td>Nombre:</td>
						<td colspan="3"><%=fb.textBox("nombrePaciente2",cdoDest.getColValue("nombre"),viewMode,false,true,55,className,null,null)%></td>
					</tr>
					<tr>
							<td>Fecha Ingreso.</td>
						<td><%=fb.textBox("fechaIngreso2",cdoDest.getColValue("fecha_ingreso"),false,false,true,10,"Text10",null,null)%></td>
						<td>Fecha Egreso.</td>
						<td><%=fb.textBox("fechaEgreso2",cdoDest.getColValue("fecha_egreso"),false,false,true,10,"Text10",null,null)%></td>
					</tr>
					<tr>
						<td>C&eacute;dula / Pasaporte</td>
						<td><%=fb.textBox("cedulaPasaporte2",cdoDest.getColValue("cedulaPasaporte"),false,false,true,25,className,null,null)%></td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
							<td>Beneficio</td>
						<td colspan="3"><%=fb.textBox("desc_empresa2",cdoDest.getColValue("nombre_empresa"),false,false,true,40,"Text10",null,null)%></td>
					</tr>
					</table>
					</td>
				</tr>
				<tr class="TextRow02" align="center">
							<td><%=fb.button("btnCargos","Ver Cargos",true,viewMode,null,"Text10","onClick=\"javascript:printCargos()\"")%></td>
						<td><%=fb.button("btnCargos2","Ver Cargos",true,viewMode,null,"Text10","onClick=\"javascript:printCargos2()\"")%></td>
				</tr>
				</table>
					</td>
				</tr>
		</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="center">
					<%=fb.button("save","Transferir",true,viewMode,null,"","onClick=\"javascript:copiarCargos()\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
	 </tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
	</td>
 </tr>
</table>
</body>
</html>
<%
}//GET
%>
