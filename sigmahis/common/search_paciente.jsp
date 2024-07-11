<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPac" scope="session" class="java.util.Vector" />
<jsp:useBean id="iETPac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vETPac" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String pac_id = request.getParameter("pac_id");
String id = request.getParameter("id")==null?"":request.getParameter("id");
String catAdm = request.getParameter("cat_adm")==null?"":request.getParameter("cat_adm");
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String context = request.getParameter("context")==null?"":request.getParameter("context");
if (fp == null) throw new Exception("La Localizaci�n Origen no es v�lida. Por favor intente nuevamente!");
if (index == null) index = "";
String usaPlanMedico = java.util.ResourceBundle.getBundle("issi").getString("usaPlanMedico");
if(usaPlanMedico==null) usaPlanMedico="N";

int pacLastLineNo = 0;
if (request.getParameter("pacLastLineNo") != null) pacLastLineNo = Integer.parseInt(request.getParameter("pacLastLineNo"));

if (fp.equals("ENTREGA_TURNO") && cds.trim().equals("")) throw new Exception("El �rea es inv�lida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String status = request.getParameter("status");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String pacId = request.getParameter("pacId");
	String nombre = request.getParameter("nombre");
	String primer_nombre = request.getParameter("primer_nombre");
	String sexo = request.getParameter("sexo");
	String id_paciente = request.getParameter("id_paciente");
	String fecha_nacimiento = request.getParameter("fecha_nacimiento");
	String apellido = request.getParameter("apellido");
	if (status == null) status = "A";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (pacId == null) pacId = "";
	if (nombre == null) nombre = "";
	if (apellido == null) apellido = "";
	if (pac_id == null) pac_id = "";
	if (primer_nombre == null) primer_nombre = "";
	if (sexo == null) sexo = "";
	if (id_paciente == null) id_paciente = "";
	if (fecha_nacimiento == null) fecha_nacimiento = "";
	
	if(!fp.equalsIgnoreCase("trazabilidad")){
	if(!fp.equals("merge")){ if (!status.trim().equals("")) { sbFilter.append(" and estatus='"); sbFilter.append(status); sbFilter.append("'"); }} else sbFilter.append(" and estatus='I'");
	}
	
	if (!dob.trim().equals("")) { sbFilter.append(" and f_nac=to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and codigo like '"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id="); sbFilter.append(pacId); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre_paciente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	//if (!apellido.trim().equals("")) { sbFilter.append(" and upper(decode(primer_apellido,null,'',primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (fp.equalsIgnoreCase("admFP") || (!fp.equalsIgnoreCase("admFP") && request.getParameter("status") != null && !fp.equalsIgnoreCase("ENTREGA_TURNO")&& !fp.equalsIgnoreCase("CONNEX")&& !fp.equalsIgnoreCase("trazabilidad"))||fp.equals("pm_updt_pac_id")) {
	sbSql.append("select pac_id, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, /*coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula*/ id_paciente as cedulaPasaporte, /*primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))*/ nombre_paciente as nombrePaciente, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombre, decode(primer_apellido,null,'',primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as apellido, sexo, estatus, pasaporte, provincia, sigla, tomo, asiento, d_cedula, vip, edad||' a '||edad_mes||' m '||edad_dias || ' d' edad, '' as admision, a.apartado_postal as cod_referencia, to_char(nvl(f_nac,fecha_nacimiento),'dd/mm/yyyy') as f_nac, excluido,(select empresa from  tbl_adm_tipo_paciente where vip= a.vip ) as aseguradora, residencia_direccion, telefono, e_mail, tipo_sangre ");

		if (fp.equalsIgnoreCase("admFP")) {

			sbSql.append(", (select count(*) from tbl_bio_fingerprint where owner_id = pac_id and capture_type = 'PAC') as fpOwner");
			sbSql.append(", (select count(*) from tbl_bio_fingerprint_tmp where session_id = '");
			sbSql.append(session.getId());
			sbSql.append("' and capture_type = 'PAC') as fpSession");

		} 

		sbSql.append(" from vw_adm_paciente a where pac_id is not null");

	sbSql.append(sbFilter);
		if(fp.equals("pm_updt_pac_id")){
			sbSql.append(" and (a.id_paciente = '");
			sbSql.append(id_paciente);
			sbSql.append("' or '");
			sbSql.append(primer_nombre);
			sbSql.append("' like a.primer_nombre ||'%'");
			sbSql.append(" /*or a.sexo = '");
			sbSql.append(sexo);
			sbSql.append("'");
			sbSql.append("*/ or nvl(a.f_nac, a.fecha_nacimiento) = to_date('");
			sbSql.append(fecha_nacimiento);
			sbSql.append("', 'dd/mm/yyyy'))");
			
		}
	if(fp.equals("pm_cliente") || fp.equalsIgnoreCase("plan_medico") || fp.equalsIgnoreCase("adenda")) sbSql.append(" and not exists (select null from tbl_pm_cliente pc where pc.pac_id = a.pac_id)");
	if(fp.equals("merge")){
		sbSql.append(" and nvl(exp_id, 0) != ");
		sbSql.append(pac_id);
	}
	sbSql.append(" order by pac_id desc");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	}
	else if (fp.equalsIgnoreCase("ENTREGA_TURNO")||fp.equalsIgnoreCase("CONNEX")||fp.equalsIgnoreCase("trazabilidad")){
	
		sbSql.append("select distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula, nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0) as edad, nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0) as edad_mes, (nvl(a.fecha_ingreso,a.fecha_creacion)-add_months(coalesce(p.f_nac,a.fecha_nacimiento),(nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0)*12+nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0)))) as edad_dias, a.compania, a.pac_id as pac_id, p.nombre_paciente nombrePaciente,a.medico, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombreMedico, p.id_paciente as cedulaPasaporte, p.sexo, p.estatus, ' ' vip, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, p.codigo, a.secuencia as admision, lpad(a.pac_id,10,'0')||lpad(a.secuencia,3,'0') as barcode, to_char(f_nac,'dd/mm/yyyy') as f_nac from tbl_adm_admision a, tbl_adm_atencion_cu b, vw_adm_paciente p where 1=1 ");
		
		if (fp.equalsIgnoreCase("ENTREGA_TURNO")){
			sbSql.append(" and a.centro_servicio = ");	
			sbSql.append(cds);	
			sbSql.append(" and a.pac_id = b.pac_id and a.secuencia = b.secuencia and p.pac_id = a.pac_id and a.estado <> 'I' and b.estado <> 'F' ");	
		}
		else if (fp.equalsIgnoreCase("trazabilidad")) {
      sbSql.append(" and a.pac_id = b.pac_id and a.secuencia = b.secuencia and p.pac_id = a.pac_id ");
		}
		else sbSql.append(" and a.pac_id = b.pac_id and a.secuencia = b.secuencia and p.pac_id = a.pac_id and a.estado IN ('A','E') and b.estado <> 'F' "); 
		
		
		
		
		sbSql.append(sbFilter);	
		sbSql.append(" order by 15");
		
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	    rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	
	}
	
	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;
    
    String jsContext = "window.opener.";
    if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
     
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Paciente - '+document.title;
function add(){<% if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>if(confirm('No ha verificado si el paciente existe. �Desea continuar?'))<% } %>
<%if(!catAdm.equals("")){%>
abrir_ventana2('../admision/paciente_config.jsp?fp=<%=fp%>&cat_adm=<%=catAdm%>&context=<%=context%>');
<%}else{%>
abrir_ventana2('../admision/paciente_config.jsp?fp=<%=fp%>&context=<%=context%><%=context.equalsIgnoreCase("preventPopupFrame")?"&cat_adm=OPD":""%>');
<%}%>
}
function edit(pacId){abrir_ventana2('../admision/paciente_config.jsp?fp=<%=fp%>&mode=edit&context=<%=context%>&pacId='+pacId);}
function setPacTypeImg(){
	var img='blank.gif';
	var pacType='';
	if(document.form0.key.value=='D'){img='distinguido.gif';pacType='DISTINGUIDO';}
	else if(document.form0.key.value=='S'){img='vip.gif';pacType='V.I.P.';}
	else if(document.form0.key.value=='M'){img='medico.gif';pacType='MEDICO DEL STAFF';}
	else if(document.form0.key.value=='J'){img='junta.gif';pacType='JUNTA DIRECTIVA';}
	else if(document.form0.key.value=='E'){img='empleado.png';pacType='JUNTA DIRECTIVA';}
	
	if(pacType.trim()!='') CBMSG.alert('<%=UserDet.getName()%>:\nRecuerda, este es un cliente '+pacType+', gracias!!');
	document.getElementById('imagen_vip').src='../images/'+img;
}
function pendingBalanceConfirmation(k, fill){
          
          if (fill){
            <%=jsContext%>document.form0.pacId.value = eval('document.result.pacId'+k).value;
			<%=jsContext%>document.form0.codigoPaciente.value = eval('document.result.codigo'+k).value;
			<%=jsContext%>document.form0.provincia.value = eval('document.result.provincia'+k).value;
			<%=jsContext%>document.form0.sigla.value = eval('document.result.sigla'+k).value;
			<%=jsContext%>document.form0.tomo.value = eval('document.result.tomo'+k).value;
			<%=jsContext%>document.form0.asiento.value = eval('document.result.asiento'+k).value;
			<%=jsContext%>document.form0.dCedula.value = eval('document.result.dCedula'+k).value;
			<%=jsContext%>document.form0.dCedulaDisplay.value = eval('document.result.dCedula'+k).value;
			<%=jsContext%>document.form0.pasaporte.value = eval('document.result.pasaporte'+k).value;
			<%=jsContext%>document.form0.nombrePaciente.value = eval('document.result.nombrePaciente'+k).value;
			<%=jsContext%>document.form0.fechaNacimiento.value = eval('document.result.fechaNacimiento'+k).value;
			if(<%=jsContext%>document.form0.f_nac)<%=jsContext%>document.form0.f_nac.value =  eval('document.result.f_nac'+k).value;
			if(<%=jsContext%>document.form0.aseguradora)<%=jsContext%>document.form0.aseguradora.value =  eval('document.result.aseguradora'+k).value;
			if(<%=jsContext%>document.form0.vip)<%=jsContext%>document.form0.vip.value=eval('document.result.vip'+k).value;
			
			if(<%=jsContext%>document.form0.pac_phone)<%=jsContext%>document.form0.pac_phone.value=eval('document.result.telefono'+k).value;
			if(<%=jsContext%>document.form0.pac_email)<%=jsContext%>document.form0.pac_email.value=eval('document.result.e_mail'+k).value;
			if(<%=jsContext%>document.form0.pac_address)<%=jsContext%>document.form0.pac_address.value=eval('document.result.residencia_direccion'+k).value;
			if(<%=jsContext%>document.form0.pac_tipo_sangre)<%=jsContext%>document.form0.pac_tipo_sangre.value=eval('document.result.tipo_sangre'+k).value;
			
			<%=jsContext%>document.form0.key.value=eval('document.result.vip'+k).value;
			<%=jsContext%>document.form0.cod_referencia.value=eval('document.result.cod_referencia'+k).value;
			<%if(!context.equalsIgnoreCase("preventPopupFrame")){%>window.opener.loadXtraInfo();<%}else{%>window.parent.loadXtraInfo();<%if(al.size()==1){%>
			<%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}}%>
            window.close();

          }else{
            <%=jsContext%>document.form0.pacId.value = '';
			<%=jsContext%>document.form0.codigoPaciente.value = '';
			<%=jsContext%>document.form0.provincia.value = '';
			<%=jsContext%>document.form0.sigla.value = '';
			<%=jsContext%>document.form0.tomo.value = '';
			<%=jsContext%>document.form0.asiento.value = '';
			<%=jsContext%>document.form0.dCedula.value = '';
			<%=jsContext%>document.form0.pasaporte.value = '';
			<%=jsContext%>document.form0.nombrePaciente.value = '';
			<%=jsContext%>document.form0.fechaNacimiento.value = '';
			<%=jsContext%>document.form0.key.value='';
			
			if(<%=jsContext%>document.form0.f_nac)<%=jsContext%>document.form0.f_nac.value = '';
			if(<%=jsContext%>document.form0.pac_phone)<%=jsContext%>document.form0.pac_phone.value = '';
			if(<%=jsContext%>document.form0.pac_email)<%=jsContext%>document.form0.pac_email.value = '';
			if(<%=jsContext%>document.form0.pac_address)<%=jsContext%>document.form0.pac_address.value = '';
			
          }
        } 

function createAdm(k, deuda, nFactura){  
    if (deuda > 0){ 
        parent.CBMSG.confirm('El Paciente tiene '+nFactura+' facturas, con saldo pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Cl�nica, �Desea continuar con la admisi�n bajo su responsabilidad?',{
            opacity:.2,btnTxt:'Si,No'
            ,cb: function(r){
                if (r=="Si"){
                   pendingBalanceConfirmation(k,1);
                }else{
                   pendingBalanceConfirmation(k);
                }
           }
        });
    } else pendingBalanceConfirmation(k,1);
}        
        
function setPaciente(k)
{
	if (eval('document.result.estatus'+k).value.toUpperCase() == 'I' && "trazabilidad" != "<%=fp%>" )
	{
		CBMSG.error('No est� permitido seleccionar pacientes inactivos!!');
		return false;
	}
	else
	{
<% if (fp.equalsIgnoreCase("recibos")){  %>
		window.opener.document.form0.codPaciente.value = eval('document.result.codigo'+k).value;
		window.opener.document.form0.pacienteNombre.value = eval('document.result.nombrePaciente'+k).value;
		window.opener.document.form0.fechaNacimiento.value = eval('document.result.fechaNacimiento'+k).value;
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value =  eval('document.result.f_nac'+k).value;
		window.opener.document.form0.pac_id.value = eval('document.result.pacId'+k).value;
<%} else  if (fp.equalsIgnoreCase("pm_cliente") || fp.equalsIgnoreCase("plan_medico") || fp.equalsIgnoreCase("adenda")){  %>
		window.opener.location = '../planmedico/pm_cliente_config.jsp?pac_id='+eval('document.result.pacId'+k).value+'&fp=<%=fp%>&fg=<%=fg%>';
<%} else if (fp.equalsIgnoreCase("consulta_general")){  %>
		window.opener.document.form00.nombrePaciente.value = eval('document.result.nombrePaciente'+k).value;
		window.opener.document.form00.pacId.value = eval('document.result.pacId'+k).value;
		window.opener.document.form00.provincia.value = eval('document.result.provincia'+k).value;
		window.opener.document.form00.sigla.value = eval('document.result.sigla'+k).value;
		window.opener.document.form00.tomo.value = eval('document.result.tomo'+k).value;
		window.opener.document.form00.asiento.value = eval('document.result.asiento'+k).value;
		window.opener.document.form00.dCedula.value = eval('document.result.dCedula'+k).value;
		window.opener.document.form00.pasaporte.value = eval('document.result.pasaporte'+k).value;
		window.opener.document.form00.fechaNacimiento.value = eval('document.result.fechaNacimiento'+k).value;
		if(window.opener.document.form00.f_nac)window.opener.document.form00.f_nac.value =  eval('document.result.f_nac'+k).value;
		window.opener.document.form00.codigoPaciente.value = eval('document.result.codigo'+k).value;
		//window.opener.location='../admision/consulta_general.jsp?mode=view&pacId='+eval('document.result.pacId'+k).value;
		window.opener.setFrameSrc('iAdmHistory','../admision/admision_history.jsp?mode=view&pacId='+eval('document.result.pacId'+k).value);

		window.close();
<% } else if (fp.equalsIgnoreCase("admision")) { %>

        var retVal = getDBData('<%=request.getContextPath()%>','nvl(getDeuda(<%=(String) session.getAttribute("_companyId")%>,\'PAC\','+eval('document.result.pacId'+k).value+'),\'0|0\')','dual','','');
        var deuda = parseFloat(retVal.substring(retVal.indexOf('|')+1));	
        var nFactura = retVal.substring(0,retVal.indexOf('|'));
        var excluido = document.querySelector("#excluido"+k) ? document.querySelector("#excluido"+k).value : 'N';
        
        if (excluido == "S") {
          CBMSG.warning('"NO EXISTE DISPONIBILIDAD DE CAMAS. CONSULTAR CON SU SUPERVISOR"', {
           opacity:1,
           btnTxt: "Ok",
           cb: function(r) {
             if (r == 'Ok') {
               createAdm (k, deuda, nFactura);
             }
             }
           });
        }else createAdm(k, deuda, nFactura);  


<% } else if (fp.equalsIgnoreCase("cita")) { %>
	 
     window.opener.document.form0.pacId.value = eval('document.result.pacId'+k).value;
	 window.opener.document.form0.nombre_paciente.value = eval('document.result.nombrePaciente'+k).value;
	 
	 window.opener.document.form0.provincia.value = eval('document.result.provincia'+k).value;
	 window.opener.document.form0.sigla.value = eval('document.result.sigla'+k).value;
	 window.opener.document.form0.tomo.value = eval('document.result.tomo'+k).value;
	 window.opener.document.form0.asiento.value = eval('document.result.asiento'+k).value;
	 window.opener.document.form0.d_cedula.value = eval('document.result.dCedula'+k).value;

<% } else if (fp.equalsIgnoreCase("edita_cita")){ %>
     window.opener.document.form0.pacId.value = eval('document.result.pacId'+k).value;
	 window.opener.document.form0.nombrePaciente.value = eval('document.result.nombrePaciente'+k).value;
	 
	 window.opener.document.form0.provincia.value = eval('document.result.provincia'+k).value;
	 window.opener.document.form0.sigla.value = eval('document.result.sigla'+k).value;
	 window.opener.document.form0.tomo.value = eval('document.result.tomo'+k).value;
	 window.opener.document.form0.asiento.value = eval('document.result.asiento'+k).value;
	 window.opener.document.form0.d_cedula.value = eval('document.result.dCedula'+k).value;

<% } else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("edit_cita")) { %>
			window.opener.document.form0.pacId.value = eval('document.result.pacId'+k).value;
			window.opener.document.form0.cod_paciente.value = eval('document.result.codigo'+k).value;
			window.opener.document.form0.provincia.value = eval('document.result.provincia'+k).value;
			window.opener.document.form0.sigla.value = eval('document.result.sigla'+k).value;
			window.opener.document.form0.tomo.value = eval('document.result.tomo'+k).value;
			window.opener.document.form0.asiento.value = eval('document.result.asiento'+k).value;
			window.opener.document.form0.d_cedula.value = eval('document.result.dCedula'+k).value;
			if(window.opener.document.form0.d_cedula_view)window.opener.document.form0.d_cedula_view.value = eval('document.result.dCedula'+k).value;
			if(window.opener.document.form0.cedulaPasaporte)window.opener.document.form0.cedulaPasaporte.value = eval('document.result.cedulaPasaporte'+k).value;
			
			$("#cod_ref",window.opener.document).text(eval('document.result.cod_referencia'+k).value);

			<%if(fp.equalsIgnoreCase("citas")|| fp.equalsIgnoreCase("edit_cita")){%>
			if(eval('document.result.pasaporte'+k).value !=''){
			window.opener.document.form0.provincia.value = '';
			window.opener.document.form0.sigla.value = '';
			window.opener.document.form0.tomo.value = '';
			window.opener.document.form0.asiento.value = '';
			if(window.opener.document.form0.d_cedula_view)window.opener.document.form0.d_cedula_view.value ='';
			}
			window.opener.document.form0.pasaporte.value = eval('document.result.pasaporte'+k).value;
			<%}%>
			window.opener.document.form0.nombre_paciente.value = eval('document.result.nombrePaciente'+k).value;
			window.opener.document.form0.fec_nacimiento.value = eval('document.result.fechaNacimiento'+k).value;
			if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value =  eval('document.result.f_nac'+k).value;
			if(window.opener.document.form0.empresa)window.opener.document.form0.empresa.value = '';
			if(window.opener.document.form0.empresa_desc)window.opener.document.form0.empresa_desc.value ='';
			if(window.opener.document.form0.estado_admision)window.opener.document.form0.estado_admision.value ='';
			if(window.opener.document.form0.admision)window.opener.document.form0.admision.value='';
			window.opener.CalculateAge();

<% } else if (fp.equalsIgnoreCase("pm_updt_pac_id")){ %>
		window.opener.document.form1.pac_id.value = eval('document.result.pacId'+k).value;
<% } else if (fp.equalsIgnoreCase("asiento")){ %>
		window.opener.document.form1.refId<%=index%>.value = eval('document.result.pacId'+k).value;
		window.opener.document.form1.refDesc<%=index%>.value = eval('document.result.nombrePaciente'+k).value;
<% } else if (fp.equalsIgnoreCase("cxc")){ %>
		window.opener.document.form1.id_cliente.value = eval('document.result.pacId'+k).value;
		window.opener.document.form1.nombre.value = eval('document.result.nombrePaciente'+k).value;
		if(window.opener.document.form1.id_cliente_view)window.opener.document.form1.id_cliente_view.value = eval('document.result.pacId'+k).value;
<%
	} else if (fp.equalsIgnoreCase("cxc2")){ %>
		window.opener.document.form1.pac_id.value = eval('document.result.pacId'+k).value;
		window.opener.document.form1.nombrePac.value = eval('document.result.nombrePaciente'+k).value;
<% } else if (fp.equalsIgnoreCase("cotizacion")) { %>
			
			window.opener.document.form0.pac_id.value = eval('document.result.pacId'+k).value;
			window.opener.document.form0.esPac.value ='S';
			window.opener.document.form0.nombre.value = eval('document.result.nombrePaciente'+k).value;
			if(window.opener.document.form0.fecha_nac)window.opener.document.form0.fecha_nac.value =  eval('document.result.f_nac'+k).value;
			if(window.opener.document.form0.identificacion)window.opener.document.form0.identificacion.value = eval('document.result.cedulaPasaporte'+k).value;

	<%} else if (fp.equalsIgnoreCase("morosidad") || fp.equalsIgnoreCase("facturacion") || fp.equalsIgnoreCase("reporte_ris_lis") || fp.equalsIgnoreCase("reporte_cpt_cds") ){ %>
		window.opener.document.form0.pacId.value = eval('document.result.pacId'+k).value;
		window.opener.document.form0.nombre.value = eval('document.result.nombrePaciente'+k).value;
	<%}else if (fp.equalsIgnoreCase("secciones_guardadas") ){%>
	   window.opener.document.search01.pacName.value = eval('document.result.nombrePaciente'+k).value;
	   window.opener.document.search01.pacId.value = eval('document.result.pacId'+k).value;
	<%}else if (fp.equalsIgnoreCase("CONNEX") ){%>
	   $("#pacNameLbl<%=index%>", window.opener.document).text(eval('document.result.nombrePaciente'+k).value);
	   $("#pacIdLbl<%=index%>", window.opener.document).text(eval('document.result.pacId'+k).value);
	   $("#noAdmisionLbl<%=index%>", window.opener.document).text(eval('document.result.admision'+k).value);
	   $("#patientid<%=index%>", window.opener.document).val(eval('document.result.barcode'+k).value);
	   $("#pacId<%=index%>", window.opener.document).val(eval('document.result.pacId'+k).value);
	   $("#noAdmision<%=index%>", window.opener.document).val(eval('document.result.admision'+k).value);
	   $("#fecha_nacimiento<%=index%>", window.opener.document).val(eval('document.result.fechaNacimiento'+k).value);
	   $("#cod_paciente<%=index%>", window.opener.document).val(eval('document.result.codigo'+k).value);
	   $("#can_be_sent_to_exp<%=index%>", window.opener.document).val("Y");
	   $("#upt_tmp<%=index%>", window.opener.document).val("Y");
	<%}else if (fp.equalsIgnoreCase("trazabilidad")){ %>
		if(<%=jsContext%>document.search01.pacId)<%=jsContext%>document.search01.pacId.value = eval('document.result.pacId'+k).value;
		if(<%=jsContext%>document.search01.admision)<%=jsContext%>document.search01.admision.value = eval('document.result.admision'+k).value;
		if(<%=jsContext%>document.search01.nombrePaciente)<%=jsContext%>document.search01.nombrePaciente.value = eval('document.result.nombrePaciente'+k).value;
<% }%>

	}
	<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}else{%>
          <%if (!fp.equalsIgnoreCase("admision")){%>window.close();<%}%>
        <%}%>
}
function unload(){<%=(fp.equalsIgnoreCase("admision"))?"closeChild=false;":""%>}
function saveFP(pacId){if(parent.reloadOwner)parent.reloadOwner(pacId);}
function doAction(){
  <% if(context.equalsIgnoreCase("preventPopupFrame") && al.size() == 1) { %>
     setPaciente(0);
  <%} else if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>
        alert('Por favor verifique si el paciente existe antes de registrar uno nuevo!');
  <%} else if (fp.equalsIgnoreCase("admision") && catAdm.equalsIgnoreCase("OPD") && al.size() == 1) {%>
      setPaciente(0);
  <%}%>
}
function selPacPM(){window.location='../common/search_paciente_pm.jsp?fp=admision';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%if(!context.equalsIgnoreCase("preventPopupFrame")){%>
<% if (!fp.equalsIgnoreCase("admFP") ) { %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<% } %>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Paciente</cellbytelabel> ]</a></authtype></td>
</tr>

<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("pacLastLineNo",""+pacLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("primer_nombre",primer_nombre)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("id_paciente",id_paciente)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("context",context)%>

		<tr class="TextFilter">
			<td width="10%">
				<cellbytelabel>Estado</cellbytelabel><br>
				<%if(fp.trim().equals("admision")||fp.trim().equals("ENTREGA_TURNO")){%>
				<%=fb.select("status","A=ACTIVO",status,false,false,0,"Text10",null,null,null,"")%>
				<%}else if(fp.trim().equals("CONNEX")){%>
				   <%=fb.select("status","A=ACTIVO",status,false,false,0,"Text10",null,null,null,"")%>
				<%}else if(fp.equals("merge")){%>
				<%=fb.select("status","I=INACTIVO",status,false,false,0,"Text10",null,null,null,"")%>
				<%}else{%>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%}%>
			</td>
			<td width="15%">
				<cellbytelabel>Fecha Nac</cellbytelabel>.<br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
			</td>
			<td width="8%">
				<cellbytelabel>C&oacute;digo</cellbytelabel><br>
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>
			</td>
			<td width="15%">
				<cellbytelabel>C&eacute;dula / Pasaporte</cellbytelabel><br>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="8%">
				<cellbytelabel>Pac. Id</cellbytelabel><br>
				<%=fb.intBox("pacId","",false,false,false,5,"Text10",null,null)%>
			</td>
			<td width="44%">
				<cellbytelabel>Nombre Paciente</cellbytelabel><br>
				<%=fb.textBox("nombre","",false,false,false,60,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				<%if(usaPlanMedico.equals("S") && fp.equals("admision")){%><%=fb.button("pacPM","Pacientes Plan Medico",true,false,null,null,"onClick=\"javascript:selPacPM()\"")%><%}%>
			</td>

		</tr>
		<%fb.appendJsValidation("if((document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){alert('Formato de fecha inv�lida!');error++;}");%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<%} else {%>

<%}%>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
    <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
    <tr>
      <td colspan="4" align="right">&nbsp;<authtype type='3'><a href="javascript:add(1)" class="Link00">[ <cellbytelabel>Registrar Nuevo Paciente</cellbytelabel> ]</a></authtype></td>
    </tr>
    <%}%>
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("pacLastLineNo",""+pacLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("primer_nombre",primer_nombre)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("id_paciente",id_paciente)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("cat_adm", catAdm)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("pacLastLineNo",""+pacLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("primer_nombre",primer_nombre)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("id_paciente",id_paciente)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("cat_adm", catAdm)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="5" cellspacing="1" class="sortable" id="list" exclude="7">
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
			<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="7%"><cellbytelabel>F.Ingreso</cellbytelabel></td>
			<td width="10%"><cellbytelabel>C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="10%"><cellbytelabel>PID</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Nombre del Paciente</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Sexo</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			
			<td width="14%"><cellbytelabel>#Ref.</cellbytelabel></td>
			
			<td width="5%">&nbsp;</td>
			<%if(!fp.equals("merge")){%><td width="5%">&nbsp;</td><%}%>
		</tr>
		<% if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>
		<tr class="TextRow01" align="center">
			<td colspan="8" class="UpperCaseText SpacingText RedText">Verifique si el paciente existe antes de registrar uno nuevo!</td>
		</tr>
		<% } %>
<%fb = new FormBean("result","","post","");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("cat_adm", catAdm)%>
	<%
	if(fp.equals("merge")||fp.equals("ENTREGA_TURNO")){
	%>
      <tr>
        <td align="right" colspan="9"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%></td>
      </tr>
	<%}%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String evt;
	if (fp.equalsIgnoreCase("admFP")) evt = " ";
	else if (fp.equalsIgnoreCase("ENTREGA_TURNO")||fp.equalsIgnoreCase("merge")) evt = " ";
	else evt = " onClick=\"javascript:setPaciente("+i+")\" style=\"text-decoration:none; cursor:pointer\"";
%>
		<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("dCedula"+i,cdo.getColValue("d_cedula"))%>
		<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombrePaciente"))%>
		<%=fb.hidden("vip"+i,cdo.getColValue("vip"))%>
		<%=fb.hidden("cedulaPasaporte"+i,cdo.getColValue("cedulaPasaporte"))%>
		<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<%=fb.hidden("nombreMedico"+i,cdo.getColValue("nombreMedico"))%>
		<%=fb.hidden("barcode"+i,cdo.getColValue("barcode"))%>
		<%=fb.hidden("cod_referencia"+i,cdo.getColValue("cod_referencia"))%>
		<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
		<%=fb.hidden("excluido"+i,cdo.getColValue("excluido"))%>
		<%=fb.hidden("aseguradora"+i,cdo.getColValue("aseguradora"))%>
		<%=fb.hidden("residencia_direccion"+i,cdo.getColValue("residencia_direccion"))%>
		<%=fb.hidden("tipo_sangre"+i,cdo.getColValue("tipo_sangre"))%>
		<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>
		<%=fb.hidden("e_mail"+i,cdo.getColValue("e_mail"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td <%=evt%> align="center"><%=cdo.getColValue("f_nac")%></td>
			<td <%=evt%> align="center"><%=cdo.getColValue("codigo")%></td>
			<td <%=evt%>><%=cdo.getColValue("fecha_ingreso")%></td>
			<td <%=evt%>><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td <%=evt%> align="center"><%=cdo.getColValue("pac_id")%> - <%=cdo.getColValue("admision")%></td>
			<td <%=evt%>>
			<%
				String idF = cdo.getColValue("vip")==null?"":cdo.getColValue("vip");
				String cssClass = "", title = "";
				if (idF.trim().equals("S")) {cssClass = " vip-vip"; title="VIP";}
				else if (idF.trim().equals("D")) {cssClass = " vip-dis"; title="DISTINGUIDO";}
				else if (idF.trim().equals("J")) {cssClass = " vip-jd"; title="JUNTA DIRECTIVA";}
				else if (idF.trim().equals("M")) {cssClass = " vip-med"; title="STAFF MEDICO";}
				else if (idF.trim().equals("E")) {cssClass = " vip-emp"; title="EMPLEADO";}
				else if (idF.trim().equals("A")) {cssClass = " vip-acc"; title="ACCIONISTA";}
				if (!idF.trim().equals("N") && !fp.equals("ENTREGA_TURNO")){
			%>
			<span title="<%=title%>" class="vip<%=cssClass%>">
			<%=cdo.getColValue("nombrePaciente")%>
			</span>
			<%}else{%>
			<%=cdo.getColValue("nombrePaciente")%>
			<%}%>
			</td>
			<td <%=evt%> align="center"><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
			<td <%=evt%> align="center"><%=(cdo.getColValue("estatus").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td <%=evt%> align="center"><%=cdo.getColValue("cod_referencia")%></td>
			<td align="center">
			<%if(fp.equals("merge")||fp.equals("ENTREGA_TURNO")){%>
			<%if (vPac.contains(cdo.getColValue("pac_id"))|| vETPac.contains(cdo.getColValue("pac_id")) ){%>
			  <cellbytelabel>elegido</cellbytelabel>
			  <%} else {%>
			  <%=fb.checkbox("chk"+i,""+i,(fp.equals("ENTREGA_TURNO")), false, "", "", "")%>
			  <%}%>
			</td>
			<%}else{ if (!context.equalsIgnoreCase("preventPopupFrame")){%>
			<td align="center"><% if (isFpEnabled && fp.equalsIgnoreCase("admFP")) { %><% if (cdo.getColValue("fpSession").equals("0")) { %><img width="16" height="16" src="../images/blank.gif"><% } else if (cdo.getColValue("fpOwner").equals("0")) { %><a href="javascript:saveFP('<%=cdo.getColValue("pac_id")%>');"><img width="16" height="16" src="../images/fingerprint-gray.png"></a><% } else { %><a href="javascript:saveFP('<%=cdo.getColValue("pac_id")%>');"><img width="16" height="16" src="../images/fingerprint-green.png"></a><% } %><% } %><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("pac_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
			<%}}%>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacLastLineNo",""+pacLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("primer_nombre",primer_nombre)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("id_paciente",id_paciente)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("cat_adm", catAdm)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacLastLineNo",""+pacLastLineNo)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("primer_nombre",primer_nombre)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("id_paciente",id_paciente)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("cat_adm", catAdm)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	System.out.println("=====================POST=====================");
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize")), lineNo = htPac.size();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("chk"+i)!=null){
		
		   if (!fp.trim().equals("ENTREGA_TURNO")){
		
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("pac_id",request.getParameter("pacId"+i));
				cdo.addColValue("nombre_paciente",request.getParameter("nombrePaciente"+i));
				cdo.addColValue("sexo",request.getParameter("sexo"+i));
				cdo.addColValue("edad",request.getParameter("edad"+i));
				cdo.addColValue("fecha_nacimiento",request.getParameter("fechaNacimiento"+i));
				cdo.addColValue("f_nac",request.getParameter("f_nac"+i));
				cdo.addColValue("id_paciente",request.getParameter("cedulaPasaporte"+i));
				cdo.addColValue("is_saved","N");
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					htPac.put(key, cdo);
					vPac.add(cdo.getColValue("pac_id"));
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}else{
			   
			   CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("pac_id",request.getParameter("pacId"+i));
				cdo.addColValue("admision",request.getParameter("admision"+i));
				cdo.addColValue("nombrePaciente",request.getParameter("nombrePaciente"+i));
				cdo.addColValue("medico",request.getParameter("medico"+i));
				cdo.addColValue("nombreMedico",request.getParameter("nombreMedico"+i));
				cdo.addColValue("cedulaPasaporte",request.getParameter("cedulaPasaporte"+i));
				cdo.addColValue("situaciones_no_resueltas","EN LA ENTREGA DEL TURNO SE REPORTA VERBALMENTE CUALQUIERA SITUACION NO RESUELTA");
				
				cdo.addColValue("action","I");
				cdo.setAction("I");
				
				pacLastLineNo++;
				
				key = "";	
				if (pacLastLineNo < 10) key = "00"+pacLastLineNo;
				else if (pacLastLineNo < 100) key = "0"+pacLastLineNo;
				else key = ""+pacLastLineNo;
				cdo.addColValue("key",key);
				cdo.setKey(key);

				try {
					iETPac.put(key, cdo);
					vETPac.add(cdo.getColValue("pac_id"));
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			
			}

		}
	}

	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/search_paciente.jsp?change=1&type=1&fp="+fp+"&pac_id="+pac_id+"&id="+id+"&cds="+cds+"&cat_adm="+catAdm+"&context="+context);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("merge")){%>
	window.opener.location = '<%=request.getContextPath()+"/admision/merge_paciente_det.jsp?change=1&fp="+fp%>';
	<%}else if (fp.equals("ENTREGA_TURNO")){%>
	  window.opener.location = '../expediente/entrega_turno_config.jsp?change=1&tab=2&mode=edit&id=<%=id%>&pacLastLineNo=<%=pacLastLineNo%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>