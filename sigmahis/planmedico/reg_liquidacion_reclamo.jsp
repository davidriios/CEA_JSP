<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="vLiqRecl" scope="session" class="java.util.Vector"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iLiqRecl" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String tipoTransaccion = request.getParameter("tipoTransaccion");
String cedulaPasaporte = request.getParameter("cedulaPasaporte");
String nombreCliente = request.getParameter("nombreCliente");
String observacion = request.getParameter("observacion");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();
String noFactura = request.getParameter("no_factura");
String tipoEmpresa = request.getParameter("tipo_empresa");
String sexo = request.getParameter("sexo");
String edad = request.getParameter("edad");
String codigoPaciente = request.getParameter("codigo_paciente");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String direccionResidencial = request.getParameter("direccion_residencial");
String categoria = request.getParameter("categoria");

String fechaIngreso = request.getParameter("fecha_ingreso");
String fechaEgreso = request.getParameter("fecha_egreso");
String poliza = request.getParameter("poliza");
String diasHospitalizados = request.getParameter("dias_hospitalizados");
String noAprob = request.getParameter("no_aprob");
String medico = request.getParameter("medico");
String ICD9 = request.getParameter("icd9");
String total = request.getParameter("total");
String medicoNombre = request.getParameter("medico_nombre");
String status = request.getParameter("status");
String subTotal = request.getParameter("sub_total");
String montoPaciente = request.getParameter("montoPaciente");
String copago = request.getParameter("copago");
String descuento = request.getParameter("descuento");
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String reembolso = request.getParameter("reembolso");
String applyCharges = request.getParameter("apply_charges");
String noAdmision = request.getParameter("admSecuencia");
String pacId = request.getParameter("pacId");
String clientId = request.getParameter("clientId");
String fromCargos = request.getParameter("from_cargos");
String tipo = request.getParameter("tipo");
String noContrato = request.getParameter("no_contrato");
String fechaReclamo = request.getParameter("fecha_reclamo");
String tipoAtencion = request.getParameter("tipo_atencion");
String tipoBeneficio = request.getParameter("tipo_beneficio");
String descDiagnostico = request.getParameter("desc_diagnostico");
String hosp_si_no = request.getParameter("hosp_si_no");
String hosp_tipo_si = request.getParameter("hosp_tipo_si");
String hosp_tipo_no = request.getParameter("hosp_tipo_no");
String tipo_reclamacion = request.getParameter("tipo_reclamacion");
String fecha_ini_plan = request.getParameter("fecha_ini_plan");

ArrayList al = new ArrayList();
ArrayList alCds = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer(); 
StringBuffer sbTSH = new StringBuffer(); 
CommonDataObject cdoH = new CommonDataObject();

int liqReclLastLineNo = 0;

if (mode == null) mode = "add";
if (codigo==null) codigo = "0";
if (tipoTransaccion == null) tipoTransaccion = "";
if (cedulaPasaporte == null) cedulaPasaporte = "";
if (nombreCliente == null) nombreCliente = "";
if (observacion == null) observacion = "";
if (noFactura == null) noFactura = "";
if (tipoEmpresa == null) tipoEmpresa = "";
if (sexo == null) sexo = "";
if (edad == null) edad = "";
if (direccionResidencial == null) direccionResidencial = "";
if (categoria == null) categoria = "";
if (fechaIngreso == null) fechaIngreso = "";
if (fechaEgreso == null) fechaEgreso = "";
if (poliza == null) poliza = "";
if (diasHospitalizados == null) diasHospitalizados = "";
if (noAprob == null) noAprob = "";
if (medico == null) medico = "";
if (ICD9 == null) ICD9 = "";
if (fechaNacimiento==null) fechaNacimiento = "";
if (total==null) total = "0.00";
if (medicoNombre==null) medicoNombre = "";
if (status==null) status = "";
if (subTotal==null) subTotal = "0.00";
if (montoPaciente==null) montoPaciente = "0.00";
if (copago==null) copago = "0.00";
if (descuento==null) descuento = "0.00";
if (tab==null) tab = "0";
if (cds==null) cds = "";
if (reembolso==null) reembolso = "";
if (applyCharges==null) applyCharges = "";
if (pacId==null) pacId = "0";
if (clientId==null) clientId = "0";
if (noAdmision==null) noAdmision = "0";
if (fromCargos==null) fromCargos = "";
if (tipo==null) tipo = "";
if (noContrato==null) noContrato = "";
if (fechaReclamo==null) fechaReclamo = "";
if (tipoAtencion == null) tipoAtencion ="";
if (tipoBeneficio == null) tipoBeneficio = "";
if (descDiagnostico == null) descDiagnostico = "";
if (hosp_si_no == null) hosp_si_no = "";
if (hosp_tipo_si == null) hosp_tipo_si = "";
if (hosp_tipo_no == null) hosp_tipo_no = "";
if (tipo_reclamacion == null) tipo_reclamacion = "";
if (fecha_ini_plan == null) fecha_ini_plan = "";

if (request.getParameter("liqReclLastLineNo") != null) liqReclLastLineNo = Integer.parseInt(request.getParameter("liqReclLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbTSH.append("select get_sec_comp_param(-1, 'COD_TIPO_SERV_HON') COD_TIPO_SERV_HON, trim(replace(get_sec_comp_param(-1, 'EMPRESA_REPLICA_COD_RECLAMO'), ' ', '')) empresa_replica_cod_reclamo from dual");
	CommonDataObject codTSH = SQLMgr.getData(sbTSH.toString());
	
  XMLCreator xml = new XMLCreator(ConMgr);
  
  xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"tipo_serv_x_cds_"+UserDet.getUserId()+".xml","select distinct a.tipo_servicio as value_col, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as label_col, a.centro_servicio as key_col from tbl_cds_servicios_x_centros a where a.visible_centro ='S' and exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio) order by 3");
  
   sql = "  select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where estado = 'A' order by 2";
  
  alCds = sbb.getBeanList(ConMgr.getConnection(), sql, CommonDataObject.class);
  ArrayList alTipoEmp = sbb.getBeanList(ConMgr.getConnection(), "select id as optValueColumn, nombre as optLabelColumn, id||'-'||nombre as optTitleColumn from tbl_pm_centros_atencion "+(mode.equals("add")?" where estado = 'A'":""), CommonDataObject.class);
  
  if (mode.equalsIgnoreCase("view") || mode.equalsIgnoreCase("edit")){
     cdoH = SQLMgr.getData("select l.pac_id, l.admi_secuencia, l.descripcion as observacion, l.nombre_cliente nombreCliente, l.cedula_cliente cedulaPasaporte, l.empresa tipo_empresa, l.num_factura no_factura, get_age(l.admi_fecha_nacimiento,trunc(sysdate),'d') as edad, l.admi_codigo_paciente as codigo_paciente, to_char(l.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,  l.direccion_residencial, l.categoria, l.poliza, l.dias_hospitalizados, l.no_aprob, (select nvl(a.reg_medico,a.codigo) from tbl_adm_medico a where a.codigo =l.med_codigo )as reg_medico,l.med_codigo as medico, l.icd9, nvl(l.total,0.00) total,(select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = l.med_codigo ) medico_nombre, to_char(l.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, to_char(l.fecha_egreso,'dd/mm/yyyy') fecha_egreso, decode(l.pac_id,0,(select sexo from vw_pm_cliente where codigo = admi_codigo_paciente ), (select sexo from tbl_adm_paciente where pac_id = l.pac_id )) as sexo, case when l.no_odp is not null then 'D' else l.status end status, nvl(l.sub_total,0.00) sub_total, nvl(l.monto_paciente,0.00) as monto_pcte, nvl(l.copago,0.00) copago, nvl(l.descuento,0.00) descuento, l.tipo_transaccion, l.reembolso, l.from_cargos, l.tipo, l.id_contrato as no_contrato, to_char(l.fecha_reclamo,'dd/mm/yyyy') fecha_reclamo, l.tipo_atencion, l.tipo_beneficio, l.desc_diagnostico, l.hosp_si_no, l.hosp_tipo_si, l.hosp_tipo_no, l.tipo_reclamacion, l.cat_reclamo, to_char(l.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan from tbl_pm_liquidacion_reclamo l where l.codigo = "+codigo);
  }else{
    
    cdoH.addColValue("nombreCliente", nombreCliente);
    cdoH.addColValue("tipo_transaccion", tipoTransaccion);
    cdoH.addColValue("cedulaPasaporte", cedulaPasaporte);
    cdoH.addColValue("tipo_empresa", tipoEmpresa);
    cdoH.addColValue("no_factura", noFactura);
    cdoH.addColValue("sexo", sexo);
    cdoH.addColValue("edad", edad);
    cdoH.addColValue("codigo_paciente", codigoPaciente);
    cdoH.addColValue("fecha_nacimiento", fechaNacimiento);
    cdoH.addColValue("direccion_residencial", direccionResidencial);
    cdoH.addColValue("categoria", categoria);
    cdoH.addColValue("fecha_ingreso", fechaIngreso);
    cdoH.addColValue("fecha_egreso", fechaEgreso);
    cdoH.addColValue("poliza", poliza);
    cdoH.addColValue("dias_hospitalizados", diasHospitalizados);
    cdoH.addColValue("no_aprob", noAprob);
    cdoH.addColValue("medico", medico);
    cdoH.addColValue("icd9", ICD9);
    cdoH.addColValue("observacion", observacion);
    cdoH.addColValue("total", total);
    cdoH.addColValue("medico_nombre", medicoNombre);
    cdoH.addColValue("status", status);
    cdoH.addColValue("sub_total", subTotal);
    cdoH.addColValue("monto_pcte", montoPaciente);
    cdoH.addColValue("copago", copago);
    cdoH.addColValue("descuento", descuento);
    cdoH.addColValue("reembolso", reembolso);
    cdoH.addColValue("from_cargos", fromCargos);
    cdoH.addColValue("tipo", tipo);
    cdoH.addColValue("no_contrato", noContrato);
    cdoH.addColValue("pac_id", pacId);
    cdoH.addColValue("admi_secuencia", noAdmision);
    cdoH.addColValue("fecha_reclamo", fechaReclamo);
    cdoH.addColValue("tipo_atencion", tipoAtencion);
    cdoH.addColValue("tipo_beneficio", tipoBeneficio);
    cdoH.addColValue("desc_diagnostico", descDiagnostico);
    cdoH.addColValue("hosp_si_no", hosp_si_no);
    cdoH.addColValue("hosp_tipo_si", hosp_tipo_si);
    cdoH.addColValue("hosp_tipo_no", hosp_tipo_no);
    cdoH.addColValue("tipo_reclamacion", tipo_reclamacion);
    cdoH.addColValue("reg_medico", "");
    cdoH.addColValue("fecha_ini_plan", fecha_ini_plan);
	
    if (!applyCharges.trim().equalsIgnoreCase("")){
       CommonDataObject cdoAC = SQLMgr.getData("select nvl(subtotal,0) as subtotal, nvl(monto_descuento,0) as monto_descuento, nvl(monto_paciente,0) as monto_paciente, nvl(monto_total,0) as monto_total, nvl(grang_total,0) as gran_total, getCopago(compania,codigo) as copago, getGastosNoCubiertos(compania,codigo) as gastos_no_cubiertos, nvl((select nvl(grang_total,0) + nvl(monto_descuento2,0) + case when trunc(fecha) >= to_date('13/06/2012','dd/mm/yyyy') then nvl(monto_descuento,0) - nvl(total_honorarios,0) - nvl(getCopagoDet(compania,f.codigo,null,null,pac_id,admi_secuencia,'FTOT'),0) else nvl(-monto_descuento,0) end - nvl((select sum(monto) from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and imprimir_sino = 'S' and centro_servicio = get_sec_comp_param(f.compania,'CDS_PAQ_PER')),0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania),0) as totalPaciente, nvl((select sum(decode(tipo,'COP',monto,0)) as monto_copago from tbl_fac_estado_cargos_det where pac_id = f.pac_id and admi_secuencia = f.admi_secuencia and monto > 0),0) as montoCopago, nvl((select aplica_copago from tbl_adm_beneficios_acum where pac_id = f.pac_id AND admision = f.admi_secuencia and rownum = 1),'E') as aplica_copago from tbl_fac_factura f where codigo = '"+noFactura+"' and compania = "+compania);
       
       double mPac = new Double(cdoAC.getColValue("totalPaciente")).doubleValue();
	   if (cdoAC.getColValue("aplica_copago").equalsIgnoreCase("A")) mPac -= new Double(cdoAC.getColValue("montoCopago")).doubleValue();
       
       cdoH.addColValue("monto_pcte", ""+mPac);
       cdoH.addColValue("copago", cdoAC.getColValue("montoCopago","0.00"));
       cdoH.addColValue("descuento", cdoAC.getColValue("monto_descuento","0.00"));
    }
   
  }
	if (cdoH==null) cdoH = new CommonDataObject();
	CommonDataObject cdo = new CommonDataObject();
	
	if (change == null){
	
	   if(applyCharges.trim().equals(""))iLiqRecl.clear();
	   
       if (mode.equals("view") || mode.equals("edit")){
       sbSql.append(" select d.descripcion, d.centro_servicio, d.monto, d.cantidad, d.tipo_cargo, d.codigo_precio, nvl(d.monto,0)*nvl(d.cantidad,0) total_x_fila, d.medico medicoOrEmpre, decode(d.honorario_por,'M',d.medico,d.empresa)||'-'||decode(d.honorario_por,'M',(select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = d.medico),(select nombre from tbl_adm_empresa where codigo= d.empresa)) nombreMedicoOrEmpre , d.seq_trx, d.honorario_por, d.medico, d.empresa, decode(d.honorario_por,'M','N','Y') pagar_sociedad, d.pac_id, d.fac_secuencia as admi_secuencia, nvl(d.porcentaje_liq_reclamo, 0) porcentaje_liq_reclamo from tbl_pm_det_liq_reclamo d where d.compania = ");
	   sbSql.append(compania);
	   sbSql.append(" and d.secuencia = ");
	   sbSql.append(codigo);
	   sbSql.append(sbFilter.toString());
	   sbSql.append(" order by 1 ");
	   	   
	   al = SQLMgr.getDataList(sbSql.toString());
       }else if (!applyCharges.trim().equalsIgnoreCase("")){}

	   liqReclLastLineNo = al.size();
        
       if(applyCharges.trim().equalsIgnoreCase("") ) {
	   for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			if(!applyCharges.trim().equalsIgnoreCase("") ) {
              cdo.setKey(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")+""+cdo.getColValue("descripcion"));
              cdo.setAction("I");
            }else{
				if (i < 10) key = "00"+i;
				else if (i < 100) key = "0"+i;
				else key = ""+i;
				cdo.setKey(key);
                cdo.setAction("U");
            }

			try
			{
				iLiqRecl.put(cdo.getKey(), cdo);
                vLiqRecl.add(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")+"-"+cdo.getColValue("fac")+"-"+cdo.getColValue("descripcion"));
                System.out.println(":::::::::::::::::::::::: KEY = "+cdo.getKey());
			}
			catch(Exception e)
			{
				System.err.println("Error adding 1 "+e.getMessage());
			}
		}//for i

		
		if (al.size() == 0){
			cdo = new CommonDataObject();

			cdo.addColValue("codigo","0");
			cdo.addColValue("lockedd","0");
			cdo.setKey(iLiqRecl.size()+1);
			cdo.addColValue("key",key);
			cdo.setAction("I");

			try
			{
				iLiqRecl.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
        }
			
	}// change == null
    
    boolean viewMode = mode.equals("view") || (cdoH.getColValue("status")!=null&&(cdoH.getColValue("status").equals("A")||cdoH.getColValue("status").equals("N")||cdoH.getColValue("status").equals("R")));
    boolean isHosp = tipoEmpresa.trim().equals("-1");    
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script>
function doAction(){
  <%if (request.getParameter("type") != null){%>
  <%}%>
  setXtra();
	setCantReadOnly();
	<%if(request.getParameter("cat_reclamo")!=null && request.getParameter("cat_reclamo").equals("HO")){%>
	selectTipoHosp();
	<%}%>
}
$(document).ready(function(){
   $(".btnRem").click(function(c){
	 var i = $(this).data("i");
	 removeItem('form0',i);
	 $("#form0").submit();
   });
   getHospDays();
   
   var $t = $("#tipo");
   if ($t.val() == "0"){ 
	 $("#btnAdd, .btnRem").prop("disabled",true);
	 setHonValue($t.val());
	 }
   
   $t.change(function(c){
     var $that = $(this);
     if ($that.val() == "0") {$("#btnAdd, .btnRem").prop("disabled",true);}
     else $("#btnAdd, .btnRem").prop("disabled",false);
		 setHonValue($t.val());
   });
   
   for (i=0;i<<%=iLiqRecl.size()%>;i++){
     setCds(i);
   }
   
   $(".poliza-secuencia").change(function(c){
     var self = $(this);
     var secuencia = self.find("option:selected").attr('title');
     $("#no_contrato").val(secuencia);
   });
   
   //
   var $pol = $(".poliza-secuencia");
   if( $pol.find("option").length == 2){
        $('.poliza-secuencia option:selected').next().attr('selected', 'selected');
        $("#no_contrato").val($pol.find("option:selected").attr('title'));
   }
   
   <%if(tipoEmpresa.trim().equals("-1")){%>
    $('.tipo_servicio').mousedown(function(e) {
        e.preventDefault();
    });
   <%}%>
   
});
function setHonValue(valor){
	if(valor==0) {
      $("#cds0").val("0");
      for (i=0;i<<%=iLiqRecl.size()%>;i++){
        setCds(i);
      }
    }
	else {$("#cds0").val("");}
	loadXML('../xml/tipo_serv_x_cds_<%=UserDet.getUserId()%>.xml','tipo_servicio0',(valor==0?'<%=codTSH.getColValue("COD_TIPO_SERV_HON")%>':''),'VALUE_COL','LABEL_COL',''+$("#cds0").val(),'KEY_COL','S');
	//if(valor==0) $("#tipo_servicio0").val("15");
	chkHonTS();
}
function chkHonTS(obj){
	if($("#cds0").val()==0) $("#tipo_servicio0").val("<%=codTSH.getColValue("COD_TIPO_SERV_HON")%>");
}
function chkHonCDS(){
	if($("#tipo").val()==0) {setHonValue(0);chkHonTS();}
}
function canSubmit(){
   var s = $("#liqReclSize").val() || 0;
   var tipoTrx = $("#tipoTransaccion").val();
   var tipo = $("#tipo").val();
   var empresa = $("#empresa").val();
   var diasHosp = $.trim($("#dias_hospitalizados").val()) || '0';
   var montoPcte = parseFloat($("#monto_pcte").val() || 0);
   var descuento = parseFloat($("#descuento").val() || 0);
   var __continue = true;
   
   if ( !$.trim($("#cedulaPasaporte").val()) || !$.trim($("#nombreCliente").val()) || !$.trim($("#no_factura").val()) || !$.trim($("#no_aprob").val()) || !$("#poliza").val()|| !$("#desc_diagnostico").val()|| !$("#tipo").val()) {
      CBMSG.error("Todos los campos en amarillo son obligatorios");
      __continue = false;
      return false;
   }
   else if (diasHosp !='0' && parseInt(diasHosp) < 0 ){
        CBMSG.error("El total de días hospitalizados es inválido!");
        __continue = false;
        return false;
   }
   else if (!$("#tipo_empresa").val()){
      CBMSG.error("Por favor seleccione una empresa!");
      __continue = false;
      return false;
   }
   else if (!$("#categoria").val()){
      CBMSG.error("Por favor seleccione una Categoria!");
      __continue = false;
      return false;
   }
   else if (!$("#fecha_reclamo").val()){
      CBMSG.error("Por favor Introduzca Fecha Reclamo!");
      __continue = false;
      return false;
   }
   else if( "<%=mode%>" == "add" && hasDBData('<%=request.getContextPath()%>','tbl_pm_liquidacion_reclamo lr','lr.no_aprob=\''+$("#no_aprob").val()+'\'','') ){
       CBMSG.error("El número de reclamo no puede repetirse!");
       __continue = false;
       return false;
    } 
		else if ($("#hosp_si_no").val()=='S' && !$("#hosp_tipo_si").val()){
      CBMSG.error("Por favor Seleccione opcion en Si se Hospitaliza!");
      __continue = false;
      return false;
   }
		else if ($("#hosp_si_no").val()=='N' && !$("#hosp_tipo_no").val()){
      CBMSG.error("Por favor Seleccione opcion en No se Hospitaliza!");
      __continue = false;
      return false;
   }

   var total = 0;
   for (var i = 0; i<s; i++){
      var desc = $("#descripcion"+i).val();
      var cant = $("#cantidad"+i).val() || "0";
      var monto = $("#monto"+i).val() || '0';
      var cds = $("#cds"+i).val();
      var cdsTxt = $("#cds"+i+" option:selected").text();
      var nombreMedicoOrEmpre = $("#nombreMedicoOrEmpre"+i).val();
      
      if (!$("#fecha_reclamo").val()) {CBMSG.error("Por favor ingrese la fecha de reclamo."); __continue = false;return false;}
      else if (cds=="") {CBMSG.error("Por favor escoge un centro de servicio."); __continue = false; return false;}
      else if (!desc) {CBMSG.error("Por favor ingrese la descripción de la factura."); __continue = false; return false;}
      else if (!cant) {CBMSG.error("Por favor ingrese la cantidad."); __continue = false; return false;}
      else if (!monto) {CBMSG.error("Por favor ingrese el monto. "); __continue = false; return false;}
      else if (tipo == "0") {
         if (cds != "0") {
            CBMSG.error("Por favor escoge el centro de servicio de Honorarios."); __continue = false; return false;
         }
         else if (!$.trim(nombreMedicoOrEmpre)){
            CBMSG.error("Por favor indique el médico o la sociedad!"); __continue = false; return false;
         }
      }
      else if (tipo == "1" || tipo == "2") {
        if (cds == "0") {
           CBMSG.error(cdsTxt + " no está permitido para el tipo 'Empresa/Beneficiario'!"); __continue = false; return false;
        }
      }
      
      else if ("<%=cds%>" == "0"){
         if (!$("#medicoOrEmpre"+i).val()){
            CBMSG.error("Por favor ingrese el médico o la sociedad médica."); __continue = false;
            return false;
         }
      }
      else if (!$("#tipo_atencion").val()){
        CBMSG.error("Por favor seleccione el tipo de atención."); __continue = false;
        return false;
      }
      else if (!$("#tipo_beneficio").val()){
        CBMSG.error("Por favor seleccione el tipo de beneficio."); __continue = false;
        return false;
      }
      total += (parseFloat(monto)*parseInt(cant,10)); 
      
   }//for i
   var subTotal = total;
   if (tipo == 1) total = subTotal - montoPcte - descuento;
   
   if (!total) {CBMSG.error("Por favor revise. El total de factura es 0."); __continue=false;}
   
   $("#total").val(total.toFixed(2));
   $("#sub_total").val(subTotal.toFixed(2));
   if( __continue) {
     $("#baction").val("Guardar");
     $("#form0").submit();
   }
}

function printList(){
  abrir_ventana("../expediente/print_exp_cds_valores_criticos.jsp?compania=<%=compania%>&centroServicio="+$("#centroServicio").val()+"&valoresCriticos="+$("#valoresCriticos").val());
}

function __reload(){
      window.location = "../planmedico/reg_liquidacion_reclamo.jsp?cedulaPasaporte="+$("#cedulaPasaporte").val()+"&nombreCliente="+$("#nombreCliente").val()+"&tipoTransaccion="+$("#tipoTransaccion").val()+"&observacion="+$("#observacion").val()+"&tipo_empresa="+$("#tipo_empresa").val()+"&categoria="+$("#categoria").val()+"&no_factura="+$("#no_factura").val()+"&fecha_nacimiento="+$("#fecha_nacimiento").val()+"&edad="+$("#edad").val()+"&sexo="+$("#sexo").val()+"&codigo_paciente="+$("#codigo_paciente").val()+"&fecha_ingreso="+$("#fecha_ingreso").val()+"&fecha_egreso="+$("#fecha_egreso").val()+"&direccion_residencial="+$("#direccion_residencial").val()+"&poliza="+$("#poliza").val()+"&dias_hospitalizados="+$("#dias_hospitalizados").val()+"&no_aprob="+$("#no_aprob").val()+"&medico="+$("#medico").val()+"&medico_nombre="+$("#medico_nombre").val()+"&icd9="+$("#icd9").val()+"&total="+$("#total").val()+"&status="+$("#status").val()+"&monto_pcte="+$("#monto_pcte").val()+"&sub_total="+$("#sub_total").val()+"&descuento="+$("#descuento").val()+"&copago="+$("#copago").val()+"&reembolso="+$("#reembolso").val()+"&apply_charges="+$("#apply_charges").val()+"&admSecuencia="+$("#admSecuencia").val()+"&pacId="+$("#pacId").val()+"&from_cargos="+$("#from_cargos").val()+"&tipo="+$("#tipo").val()+"&fecha_reclamo="+$("#fecha_reclamo").val()+"&tipo_atencion="+$("#tipo_atencion").val()+"&tipo_beneficio="+$("#tipo_atencion").val()+"&desc_diagnostico="+$("#desc_diagnostico").val()+"&fecha_ini_plan="+$("#fecha_ini_plan").val();
}

function clearDetail(val){
	var size = <%=iLiqRecl.size()%>;
   
    if(parseInt(size)>0){
       CBMSG.confirm('Al cambiar el tipo de transacción se borrarán los registros agregados. \n Desea continuar????',{
         btnTxt:'Si,No',
         cb:function(r){
           if (r=="Si") __reload();
         }
       });
    }
    else __reload();
}

function setCds(i, __clean){
    var cds = $("#cds"+i).val();
    var medico = $("#medico"+i).val();
    var empresa = $("#empresa"+i).val();
    if (cds=='0'){ 
        $("#ps-"+i).show();
        $("#btnMedico"+i).prop("disabled",false);
        $("#btnPrecio"+i).prop("disabled",false);
    }else {
        $("#btnPrecio"+i).prop("disabled",true);
        $("#pagar_sociedad"+i).prop({"disabled":false,"checked":false});
        $("#btnMedico"+i).prop("disabled",true);
    }
    if(__clean) cleanCodPrecio(i);
}

function cleanCodPrecio(i){
  $("#codigo_precio"+i).val("");
  $("#descripcion"+i).val("");
  $("#cantidad"+i).val("");
  $("#codigo_precio"+i).val("");
  $("#monto"+i).val("");
  $("#precio"+i).val("");
  $("#total_x_fila"+i).val("");
  $("#nombreMedicoOrEmpre"+i).val("");
  $("#medico"+i).val("");
  $("#empresa"+i).val("");
}

function searchCliente(opt){
  var cat = $("#categoria").val();
  var tipoEmp = $("#tipo_empresa").val();
  var tipo = $("#tipo").val();
  var tipoAtencion = $("#tipo_atencion").val();
  var tipoBeneficio = $("#tipo_beneficio").val();
  var fechaReclamo = $("#fecha_reclamo").val();
  var descDiagnostico = $("#desc_diagnostico").val();
  var noAprob = $("#no_aprob").val();
  var cat_reclamo = $("#cat_reclamo").val();
	
  var hosp_si_no = $("#hosp_si_no").val();
  var hosp_tipo_si = $("#hosp_tipo_si").val();
  var hosp_tipo_no = $("#hosp_tipo_no").val();
  var tipo_reclamacion = $("#tipo_reclamacion").val();
  
  if (opt==1) abrir_ventana("../common/search_paciente_pm.jsp?fp=liq_recl");
  else{
		if(cat=='')CBMSG.error("Seleccione Categoría");
		else{
		if (opt==2) abrir_ventana("../planmedico/pm_sel_facturas_a_reclamar.jsp?fp=liq_recl&is_det=Y&categoria="+cat+"&tipo_empresa="+tipoEmp+"&tipo="+tipo+"&tipo_atencion="+tipoAtencion+"&tipo_beneficio="+tipoBeneficio+"&fecha_reclamo="+fechaReclamo+"&desc_diagnostico="+descDiagnostico+"&no_aprob="+noAprob+"&cat_reclamo="+cat_reclamo+"&hosp_si_no="+hosp_si_no+"&hosp_tipo_si="+hosp_tipo_si+"&hosp_tipo_no="+hosp_tipo_no+"&tipo_reclamacion="+tipo_reclamacion);
		else if (opt==3) abrir_ventana("../planmedico/pm_sel_facturas_a_reclamar.jsp?fp=liq_recl&categoria="+cat+"&tipo_empresa="+tipoEmp+"&tipo="+tipo+"&tipo_atencion="+tipoAtencion+"&tipo_beneficio="+tipoBeneficio+"&fecha_reclamo="+fechaReclamo+"&desc_diagnostico="+descDiagnostico+"&no_aprob="+noAprob+"&cat_reclamo="+cat_reclamo+"&hosp_si_no="+hosp_si_no+"&hosp_tipo_si="+hosp_tipo_si+"&hosp_tipo_no="+hosp_tipo_no+"&tipo_reclamacion="+tipo_reclamacion);
		}
	}
}

function searchMedicoOrEmpreList(i){
   if (i== undefined) abrir_ventana1('../common/search_medico.jsp?fp=liq_recl');	
   else {
       var isSociedad = $("#pagar_sociedad"+i).is(":checked") || $("#_pagar_sociedad"+i+"Dsp").is(":checked");
       $("#medicoOrEmpre"+i).val("");
       $("#nombreMedicoOrEmpre"+i).val("");
       if (isSociedad) abrir_ventana1('../common/search_empresa.jsp?fp=liq_recl&index='+i);
       else abrir_ventana1('../common/search_medico.jsp?fp=liq_recl&index='+i);
   }   
}

function searchListaPrecio(i){
   var cds = $("#cds"+i).val();
   if (cds == '0'){
     $("#monto"+i).val("").prop("readonly",true);
     abrir_ventana1('../common/search_pm_reclamo_precio.jsp?fp=liq_recl&index='+i);
   }
}

function clearVal(){
	$("#desc_aplicado").val('N');
}
function setXtra(){
  var s = $("#liqReclSize").val() || 0;
  var subTotal = 0;
  var total = 0;
	var desc = 0;
  var montoPcte = parseFloat($("#monto_pcte").val() || 0);
  var descuento = parseFloat($("#descuento").val() || 0);
  var desc_aplicado = $("#desc_aplicado").val();
  var tipo = $("#tipo").val();
  for(i=0;i<s; i++){
    var qty = $("#cantidad"+i).val() || 0;
		if($("#monto_bk"+i).val()!=0 && $("#monto_bk"+i).val()!=$("#monto"+i).val()) $("#monto"+i).val($("#monto_bk"+i).val());
    var monto = $("#monto"+i).val() || 0;
		if(/*$("#codigo_precio"+i).val()=='-01' &&*/ $("#cds"+i).val()== '0' && $("#pagar_sociedad"+i).is(":checked") && $("#porcentaje_liq_reclamo"+i).val()!=0 && desc_aplicado=='N'){
			desc += (parseFloat(monto))*((parseFloat($("#porcentaje_liq_reclamo"+i).val())/100));
			monto = (parseFloat(monto))*(1-(parseFloat($("#porcentaje_liq_reclamo"+i).val())/100));
			$("#monto"+i).val(monto);
			$("#desc_aplicado").val('S');
		}
    $("#total_x_fila"+i).val((parseInt(qty) * parseFloat(monto)));
    subTotal += (parseInt(qty) * parseFloat(monto));
  }
	if(desc!=0) $("#descuento").val(desc.toFixed(2));
	else $("#descuento").val(0.00);
  if(tipo == 1) total = subTotal - montoPcte - descuento; 
  else total = subTotal;
  $("#sub_total").val(subTotal.toFixed(2));
  $("#total").val(total.toFixed(2));
}

function getHospDays(){
  var fi = $("#fecha_ingreso").val();
  var fe = $("#fecha_egreso").val();
  var totD = 0;
  if (fi && fe){
    totD = getDBData('<%=request.getContextPath()%>',"to_date('"+fe+"','dd/mm/yyyy')-to_date('"+fi+"','dd/mm/yyyy')",'dual','','');
  }
  $("#dias_hospitalizados").val(totD);
}

function setPacienteInterno(){
  var tipoEmp = $("#tipo_empresa").val();
  if (tipoEmp == "-1"){
    $("#btn_det_cargos").prop("disabled",false);
    $("#btnCliente1").prop("disabled",true);
    $("#fecha_ingreso").val("").prop("readonly",true);
    $("#fecha_egreso").val("").prop("readonly",true);
    $("#resetfecha_ingreso").prop("disabled",true);
    $("#resetfecha_egreso").prop("disabled",true);
    $("#no_factura").prop("readonly",true);
  }else {
    $("#btn_det_cargos").prop("disabled",true);
    $("#btnCliente1").prop("disabled",false);
    $("#fecha_ingreso").val("").prop("readonly",false);
    $("#fecha_egreso").val("").prop("readonly",false);
     $("#resetfecha_ingreso").prop("disabled",false);
    $("#resetfecha_egreso").prop("disabled",false);
    $("#no_factura").prop("readonly",false);
  }
}

function showInfo(){}
function __print(){
  abrir_ventana("../planmedico/print_liquidacion_reclamo.jsp?codigo=<%=codigo%>");
}

function setPagarA(i){
  var $ps = $("#pagar_sociedad"+i);
  $("#nombreMedicoOrEmpre"+i).val("");
  $("#medico"+i).val("");
  $("#empresa"+i).val("");
    
  if ( $ps.is(":checked") ){
    $ps.val("Y");
  }else{
    $ps.val("N");
  } 
}

function __applyCharges(){
 var noFactura = $.trim($("#no_factura").val());
 if (!noFactura) return CBMSG.error("No pudimos encontrar un número de documento válido!");
 else {
   $("#apply_charges").val("Y");
   __reload();
 }
}

function checkTipoLiq() {
  var empresa = $("#tipo_empresa").val();
  var tipo = $("#tipo").val();
  if (tipo == 2 && empresa == -1){
    CBMSG.error("Ese tipo de liquidación no es válido para Hospital!");
    $("#tipo").val(0);
  }  
	setCantReadOnly();
}

function setCantReadOnly(){
	var tipo = $("#tipo").val();
	var s = $("#liqReclSize").val() || 0;
	if(tipo==0) for(i=0;i<s;i++) {$("#cantidad"+i).prop("readonly",true);}
	else for(i=0;i<s;i++) {$("#cantidad"+i).prop("readonly",false);}	
}

function rplcNo(){
	var empresa = $("#tipo_empresa").val();
	var empresas = splitRows('<%=codTSH.getColValue("empresa_replica_cod_reclamo").replace(',','~')%>');
	for(i=0;i<empresas.length;i++){
		if(empresa==empresas[i]) document.form0.no_factura.value = document.form0.no_aprob.value;
	}	
}

function clearNoRec(){
	<%if(mode.equals("add")){%>
	document.form0.no_factura.value = '';
	document.form0.no_aprob.value='';
	<%}%>
}
function selectTipoHosp(){
	var obj = document.getElementById('hosp_si_no');
	var x = obj[obj.selectedIndex].value;
	if(x=='S') {document.getElementById('hosp_tipo_no').disabled=true; document.getElementById('hosp_tipo_si').disabled=false;}
    if(x=='N') {document.getElementById("hosp_tipo_si").disabled=true; document.getElementById('hosp_tipo_no').disabled=false;}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr class="TextRow02"><td>&nbsp;</td></tr>
    <tr class="TextHeader"><td>LIQUIDACION DE RECLAMO</td></tr>
    <tr class="TextRow02"><td>&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
            <!-- MAIN DIV START HERE -->
            <div id = "dhtmlgoodies_tabView1">

            <!-- TAB0 DIV START HERE-->
            <div class = "dhtmlgoodies_aTab">
        
		  <table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("liqReclSize",""+iLiqRecl.size())%>
			<%=fb.hidden("liqReclLastLineNo",""+liqReclLastLineNo)%>
			<%=fb.hidden("admSecuencia",cdoH.getColValue("admi_secuencia"))%>
			<%=fb.hidden("pacId",cdoH.getColValue("pac_id"))%>
			<%=fb.hidden("tab",tab)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("apply_charges",applyCharges)%>
			<%=fb.hidden("from_cargos",fromCargos)%>
			<%=fb.hidden("cat_reclamo",request.getParameter("cat_reclamo"))%>
			<%=fb.hidden("desc_aplicado","N")%>
            
            <tr class="TextRow01">
                <td colspan='9'>
                  <table width="100%" cellpadding="1" cellspacing="1">
                  
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>No.</cellbytelabel></td>
							<td width="40%"><%=fb.textBox("codigo",codigo,false,false,true,15)%></td>
							<td width="10%" align="right"><cellbytelabel>Tipo Doc.</cellbytelabel>:</td>
							<td width="40%"><%=fb.select("tipoTransaccion","F=FACTURA,N=NOTA DE CREDITO",cdoH.getColValue("tipo_transaccion"), false, viewMode, 0,"","","")%></td>
						</tr>
                        
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Contrato</cellbytelabel></td>
							<td width="40%">
                            <%//=fb.textBox("poliza",cdoH.getColValue("poliza"),false,false,true,15)%>
                            <%
                            String cQry = "";
                            if (cdoH.getColValue("codigo_paciente")!=null && !cdoH.getColValue("codigo_paciente").trim().equals("") && !cdoH.getColValue("codigo_paciente").trim().equals("0") /*&& (codigo.equals("") || codigo.equals("0"))*/) cQry = "select d.id_solicitud, 'Contrato #'||d.id_solicitud||'-'||d.secuencia contrato_desc, d.secuencia from  vw_pm_cliente p, tbl_pm_sol_contrato_det d, tbl_pm_solicitud_contrato s where /*pac_id is not null and*/ d.id_cliente = p.codigo /*and tipo_clte = 'C'*/ and s.fecha_ini_plan is not null and d.estado = 'A' and s.id = d.id_solicitud and p.codigo = "+cdoH.getColValue("codigo_paciente");
                            %>
                            <%=fb.select(ConMgr.getConnection(), cQry, "poliza", cdoH.getColValue("poliza"),true, false,viewMode,0,"poliza-secuencia","width:150px","","","S")%>
                            
                            
                            <cellbytelabel>Secuencia</cellbytelabel>
                            <%=fb.textBox("no_contrato",cdoH.getColValue("no_contrato"),false,false,true,5)%>
														&nbsp;&nbsp;&nbsp;&nbsp;
														Fecha Ini. Cont.:<%=fb.textBox("fecha_ini_plan",cdoH.getColValue("fecha_ini_plan"),false,false,true,10)%>
                            </td>
							<td width="10%" align="right"><cellbytelabel>Tipo Liquidaci&oacute;n</cellbytelabel>:</td>
							<td width="40%"><%=fb.select("tipo","0=Honorario,1=Empresa,2=Beneficiario",cdoH.getColValue("tipo"), true, false, viewMode, 0,"","","onchange=checkTipoLiq()",null,"S")%>&nbsp;
							<cellbytelabel>Categor&iacute;a:</cellbytelabel>
                            <%=fb.select(ConMgr.getConnection(), "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by codigo", "categoria", cdoH.getColValue("categoria"),true, false,viewMode,0,"","width:150px","","","S")%>
                            </td>
						</tr>
						<% if(request.getParameter("cat_reclamo")!=null && request.getParameter("cat_reclamo").equals("CE")){ %>
                        <tr id="CE" class="TextRow01">
							<%=fb.hidden("hosp_si_no","N")%>
							<%=fb.hidden("hosp_tipo_si","-1")%>
							<%=fb.hidden("hosp_tipo_no","-1")%>
							<td width="10%" align="right"><cellbytelabel>Tipo Reclamacion</cellbytelabel></td>
							<td width="40%"><%=fb.select("tipo_reclamacion","1=CONSULTA EXTERNA",cdoH.getColValue("tipo_reclamacion"), true, false, viewMode, 0,"","","onchange=checkTipoLiq()",null,"")%>&nbsp;
							<cellbytelabel><cellbytelabel>Tipo Beneficio</cellbytelabel>:<%=fb.select(ConMgr.getConnection(), "select codigo, nombre from tbl_pm_liq_recl_tipo_ben where estado='A' order by nombre", "tipo_beneficio", cdoH.getColValue("tipo_beneficio"),true, false,viewMode,0,"","width:200px","","","")%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            </td>
							<td width="10%" align="right">Tipo Atenci&oacute;n</cellbytelabel></td>
							<td width="40%"><%=fb.select(ConMgr.getConnection(), "select codigo, nombre from tbl_pm_liq_recl_tipo_atencion where estado='A' order by nombre", "tipo_atencion", cdoH.getColValue("tipo_atencion"),true, false,viewMode,0,"","width:200px","","","")%></td>
						</tr>
                        <% } else if(request.getParameter("cat_reclamo")!=null && request.getParameter("cat_reclamo").equals("HO")){ %>
                            <tr id="HO" class="TextRow01">
							<%=fb.hidden("tipo_atencion","-1")%>
							<%=fb.hidden("tipo_beneficio","-1")%>
							<td width="10%" align="right"><cellbytelabel>Hospitalizacion</cellbytelabel></td>
							<td width="40%"><%=fb.select("hosp_si_no","S=SI,N=NO",cdoH.getColValue("hosp_si_no"), true, false, viewMode, 0,"","","onchange=selectTipoHosp(this)",null,"S")%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <cellbytelabel>Si Se Hospitaliza</cellbytelabel>
                            <%=fb.select("hosp_tipo_si","1=INCAPACIDAD,2=NERVIOSA,3=PARTO NORMAL,4=CESAREA",cdoH.getColValue("hosp_tipo_si"), false, false, viewMode, 0,"FormDataObjectRequired","","onchange=#",null,"S")%>
                            </td>
							<td width="10%" align="right"><cellbytelabel>No Se Hospitaliza</cellbytelabel>:</td>
							<td width="40%"><%=fb.select("hosp_tipo_no","1=URGENCIA MEDICA,2=LABORATORIO/RAYOS-X,3=CIRUGIA AMBULATORIA,4=URGENCIA POR ACCIDENTE,5=RES. MAGNETICA / M.I.B.I.,6=CAT. CARDIACO,7=ANGIOPLASTIA,8=ENDOSCOPIA/CISTOSCOPIA,9=INYECCION,10=FISIOTERAPIA O INHALOTERAPIA,11=PRUEBA DE ESFUERZO /HOLTER /ECO,12=MAMOGRAFIA, CAMPIMETRIA,13=DENSIT. OSEA,14=URODINAMIA,15=QUIMIO/RADIO/HEMODIALISIS,16=MEDICINA NUCLEAR",cdoH.getColValue("hosp_tipo_no"), false, false, viewMode, 0,"FormDataObjectRequired","","onchange=#",null,"S")%></td>
						</tr>
                        <% } %>
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Empresa:</cellbytelabel></td>
							<td width="40%"><%=fb.select("tipo_empresa",alTipoEmp,cdoH.getColValue("tipo_empresa"),false,viewMode,0,"","","onChange='setPacienteInterno(); checkTipoLiq();clearNoRec();'","","S")%>
                            </td>
							<td width="10%" align="right"><cellbytelabel>No. Documento</cellbytelabel>:</td>
							<td width="40%"><%=fb.textBox("no_factura",cdoH.getColValue("no_factura"),true,false,viewMode,15,22)%></td>
						</tr>
                        <tr class="TextRow01">
							<td align="right" ><cellbytelabel>Beneficiario</cellbytelabel>:</td>
							<td colspan="3">
								<%=fb.textBox("cedulaPasaporte",cdoH.getColValue("cedulaPasaporte"),true,false,true,15)%>
								<%=fb.textBox("nombreCliente",cdoH.getColValue("nombreCliente"),true,false,true,50)%>
                                &nbsp;&nbsp;&nbsp;
								<%=fb.button("btnCliente1","...",true, true ,null,null,"onClick=\"javascript:searchCliente(1)\"")%>&nbsp;&nbsp;Fecha Reclamo
                                <jsp:include page="../common/calendar.jsp" flush="true">
                                <jsp:param name="noOfDateTBox" value="1" />
                                <jsp:param name="nameOfTBox1" value="fecha_reclamo" />
                                <jsp:param name="fieldClass" value="FormDataObjectRequired" />
                                <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
                                <jsp:param name="valueOfTBox1" value="<%=(mode.equals("add")?fechaReclamo:cdoH.getColValue("fecha_reclamo"))%>" />
                                </jsp:include>
							</td>
						</tr> 
                        
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Fecha Nacimiento</cellbytelabel>:</td>
							<td width="40%">
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="nameOfTBox1" value="fecha_nacimiento" />
                            <jsp:param name="readonly" value="y" />
                            <jsp:param name="valueOfTBox1" value="<%=cdoH.getColValue("fecha_nacimiento")%>" />
                            </jsp:include>
                            &nbsp;&nbsp;&nbsp;Edad: <%=fb.textBox("edad",cdoH.getColValue("edad"),false,false,true,15)%>&nbsp;&nbsp;&nbsp;Sexo: <%=fb.select("sexo","F=Femenino,M=Masculino",cdoH.getColValue("sexo"), false, false, 0,"","","")%>
                            </td>
							<td width="10%" align="right"><cellbytelabel>C&oacute;digo Beneficiario</cellbytelabel>:</td>
							<td width="40%"><%=fb.textBox("codigo_paciente",cdoH.getColValue("codigo_paciente"),false,false,true,5)%></td>
						</tr>
                        
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Fecha Ingreso</cellbytelabel>:</td>
							<td width="40%">
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="nameOfTBox1" value="fecha_ingreso" />
                            <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
                            <jsp:param name="valueOfTBox1" value="<%=cdoH.getColValue("fecha_ingreso")%>" />
                            <jsp:param name="jsEvent" value="getHospDays()" />
                            </jsp:include>
                            </td>
							<td width="10%" align="right"><cellbytelabel>Fecha Egreso</cellbytelabel>:</td>
							<td width="40%"><jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="nameOfTBox1" value="fecha_egreso" />
                            <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
                            <jsp:param name="valueOfTBox1" value="<%=cdoH.getColValue("fecha_egreso")%>" />
                            <jsp:param name="jsEvent" value="getHospDays()" />
                            </jsp:include></td>
						</tr>
                        
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Direcci&oacute;n</cellbytelabel>:</td>
							<td width="40%"><%=fb.textBox("direccion_residencial",cdoH.getColValue("direccion_residencial","----"),false,false,viewMode,70)%></td>
							<td width="10%" align="right">&nbsp;</td>
							<td width="40%">&nbsp;</td>
						</tr>
                        
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>D&iacute;as Hosp.</cellbytelabel>:</td>
							<td width="40%"><%=fb.textBox("dias_hospitalizados",cdoH.getColValue("dias_hospitalizados"),false,false,viewMode,10)%></td>
							<td width="10%" align="right"><cellbytelabel>No. Reclamo</cellbytelabel>:</td>
							<td width="40%"><%=fb.textBox("no_aprob",cdoH.getColValue("no_aprob"),true,false,viewMode,15, 15, "", "", "onChange=\"javascript:rplcNo();\"")%></td>
						</tr>
                        
                        <tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>M&eacute;dico Cabecera</cellbytelabel>:</td>
							<td width="40%">
							  <%=fb.hidden("medico",cdoH.getColValue("medico"))%> 
                              <%=fb.textBox("reg_medico",cdoH.getColValue("reg_medico"),false,false,viewMode,15)%>
                              <%=fb.textBox("medico_nombre",cdoH.getColValue("medico_nombre"),false,false,viewMode,45)%>
								<%=fb.button("btnMedico","...",true,viewMode,null,null,"onClick=\"javascript:searchMedicoOrEmpreList()\"")%>
                            
                            </td>
							<td width="10%" align="right"><cellbytelabel>Estado</cellbytelabel>:</td>
							<td width="40%">
                            <%
                            String cStatus = cdoH.getColValue("status",""); 
                            String statusOpt = "P=Pendiente";
                            if (cStatus != null && cStatus.equals("P")) statusOpt = "P=Pendiente,A=Aprobada,N=Anulada,R=Rechazada";
                            else if (cStatus != null && cStatus.equals("A")) statusOpt = "A=Aprobada";
                            else if (cStatus != null && cStatus.equals("N")) statusOpt = "N=Anulada";
                            else if (cStatus != null && cStatus.equals("R")) statusOpt = "R=Rechazada";
                            else if (cStatus != null && cStatus.equals("D")) statusOpt = "D=Pagado";
                            %>
                            <%=fb.select("status",statusOpt, cStatus, false, viewMode, 0,"","","")%> 
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <%=fb.button("btn_print","Imprimir",true,(mode.equals("add")),null,null,"onclick=__print()")%>
                            </td>
						</tr>
                        
                        <tr class="TextRow01">
							<td align="right"><cellbytelabel>Descripci&oacute;n Diagn&oacute;stico</cellbytelabel>:</td>
							<td colspan="3">
								<%=fb.textarea("desc_diagnostico",cdoH.getColValue("desc_diagnostico"),true,false,viewMode,100,2, 500)%>
							</td>
						</tr>

                       <tr class="TextRow01">
							<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:</td>
							<td colspan="3">
								<%=fb.textarea("observacion",cdoH.getColValue("observacion"),false,false,viewMode,100,2, 500)%>
                                <%=fb.button("btn_det_cargos","Cargos (det)",true,true,null,null,"onclick=searchCliente(2)")%>
							</td>
						</tr>
                        
                    </table> 
                </td>
            </tr>
     
			 <tr class="TextHeader02">
				<td width='7%'><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width='17%'><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width='13%'><cellbytelabel>Centro de Servicio</cellbytelabel></td>
				<td width='10%'><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
                <td width="25%"><cellbytelabel>M&eacute;dico/Sociedad</cellbytelabel></td>
				<td width="6%" align="center">Cantidad</td>
				<td width='6%' align="right">Monto</td>
				<td width='6%' align="right">Total</td>
				<td width="5%" align="center">
				<% String form = "'"+fb.getFormName()+"'";%>
				<%=fb.submit("btnAdd","+",false,viewMode||isHosp||(cdoH.getColValue("from_cargos")!=null&&cdoH.getColValue("from_cargos").equalsIgnoreCase("Y")),null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Facturas")%>
				</td>
			 </tr>

					<%
						al = CmnMgr.reverseRecords(iLiqRecl);
						for (int i=0; i<iLiqRecl.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoLiqRcl = (CommonDataObject) iLiqRecl.get(key);
							boolean locked = cdoLiqRcl.getColValue("lockedd")!=null && !cdoLiqRcl.getColValue("lockedd").equals("")&& !cdoLiqRcl.getColValue("lockedd").equals("0");
                            
                           // if (cds.equals("0")) cdoLiqRcl.addColValue("centro_servicio","0");
					%>
                        
						<tr class="TextRow01" id="row<%=i%>">
							<td><%=fb.textBox("codigo_precio"+i,cdoLiqRcl.getColValue("codigo_precio"),false,false,true,4,"",null,null)%>
                            <%=fb.button("btnPrecio"+i,"...",true,(viewMode || isHosp || (cdoLiqRcl.getColValue("centro_servicio")!=null&&!cdoLiqRcl.getColValue("centro_servicio").equals("0")) ),null,null,"onClick=\"javascript:searchListaPrecio("+i+")\"")%>
                            </td>
							<td><%=fb.textBox("descripcion"+i,cdoLiqRcl.getColValue("descripcion",cdoLiqRcl.getColValue("centro_servicio")),true,false,viewMode ||isHosp,26,"",null,null)%></td>
							<td><%=fb.select("cds"+i,alCds,cdoLiqRcl.getColValue("centro_servicio"),false,viewMode|| isHosp,0,"","width:150px","onchange=\"loadXML('../xml/tipo_serv_x_cds_"+UserDet.getUserId()+".xml','tipo_servicio"+i+"','','VALUE_COL','LABEL_COL',this.value,'KEY_COL',''); setCds("+i+",1); chkHonCDS();\"","","S")%></td>
							
                            <td>
                            <%=fb.select("tipo_servicio"+i,"","",false,false,0,"tipo_servicio","width:120px","onChange=\"javascript:chkHonTS(this);\"")%>
                            <script>
                                loadXML('../xml/tipo_serv_x_cds_<%=UserDet.getUserId()%>.xml','tipo_servicio<%=i%>','<%=cdoLiqRcl.getColValue("tipo_cargo")%>','VALUE_COL','LABEL_COL','<%=cdoLiqRcl.getColValue("centro_servicio")%>','KEY_COL','S')
                            </script>
                            </td>
                            <%=fb.hidden("medicoOrEmpre"+i,cdoLiqRcl.getColValue("medicoOrEmpre"))%>
                            <%=fb.hidden("medico"+i,cdoLiqRcl.getColValue("medico"))%>
                            <%=fb.hidden("empresa"+i,cdoLiqRcl.getColValue("empresa"))%>
                            <%=fb.hidden("porcentaje_liq_reclamo"+i,cdoLiqRcl.getColValue("porcentaje_liq_reclamo"))%>
                            <td>
                            <span style="display:none" id="ps-<%=i%>">
                            Sociedad?&nbsp;
                            <%=fb.checkbox("pagar_sociedad"+i,cdoLiqRcl.getColValue("pagar_sociedad","N"),(cdoLiqRcl.getColValue("honorario_por")!=null && cdoLiqRcl.getColValue("honorario_por").equals("E")),false,"","","onclick=setPagarA("+i+")")%></span>
                            
                            <%=fb.textBox("nombreMedicoOrEmpre"+i,cdoLiqRcl.getColValue("centro_servicio")!=null&&cdoLiqRcl.getColValue("centro_servicio").equals("0")?cdoLiqRcl.getColValue("nombreMedicoOrEmpre"):"",false,false,(cdoLiqRcl.getAction().equals("I") || viewMode || isHosp || (cdoLiqRcl.getColValue("centro_servicio")!=null&&!cdoLiqRcl.getColValue("centro_servicio").equals("0")) ),26)%>
                            <%=fb.button("btnMedico"+i,"...",true,(cdoLiqRcl.getAction().equals("I") || viewMode || isHosp || (cdoLiqRcl.getColValue("centro_servicio")!=null&&!cdoLiqRcl.getColValue("centro_servicio").equals("0")) ),null,null,"onClick=\"javascript:searchMedicoOrEmpreList("+i+")\"")%>
                            </td>
                            
                            <td align="center"><%=fb.intBox("cantidad"+i,cdoLiqRcl.getColValue("cantidad"),true,false,false,6,null,null,"onblur=setXtra()'")%></td>
                            <td align="right">
														<%=fb.hidden("monto_bk"+i,cdoLiqRcl.getColValue("monto"))%>
														<%=fb.decBox("monto"+i,cdoLiqRcl.getColValue("monto"),true,false,(cdoLiqRcl.getColValue("codigo_precio")!=null&&!cdoLiqRcl.getColValue("codigo_precio").equals("-01")&&!cdoLiqRcl.getColValue("codigo_precio").equals(""))?true:viewMode|| isHosp,6,null,null,"onChange='javascript:clearVal();' onblur=setXtra()")%>
														</td>
                            
                            <td align="right"><%=fb.decBox("total_x_fila"+i,cdoLiqRcl.getColValue("total_x_fila"),true,false,true,6,null,null,"")%></td>
										
							<td align="center"><%=fb.button("rem"+i,"X",true,viewMode|| isHosp,"btnRem",cdoLiqRcl.getAction().equals("D")?"color:red":"","","Eliminar"," data-i='"+i+"'")%></td>
						</tr>
						<%=fb.hidden("key"+i,cdoLiqRcl.getKey())%>
						<%=fb.hidden("remove"+i,"")%>			
						<%=fb.hidden("action"+i,cdoLiqRcl.getAction())%>			
						<%=fb.hidden("codigo"+i,cdoLiqRcl.getColValue("codigo"))%>			
						<%=fb.hidden("lockedd"+i,cdoLiqRcl.getColValue("lockedd"))%>			
						<%=fb.hidden("seq_trx"+i,cdoLiqRcl.getColValue("seq_trx"))%>		
						<%=fb.hidden("pac_id"+i,cdoLiqRcl.getColValue("pac_id"))%>		
						<%=fb.hidden("admi_secuencia"+i,cdoLiqRcl.getColValue("admi_secuencia"))%>		
					 <%}%>


				 <tr class="TextRow01">
				  <td align="center" colspan='5'>
					&nbsp;Copago:<%=fb.decBox("copago",cdoH.getColValue("copago"),false,false,viewMode|| isHosp,8,null,null,"")%>
					&nbsp;Monto Paciente:<%=fb.decBox("monto_pcte",cdoH.getColValue("monto_pcte"),false,false,viewMode|| isHosp,8,null,null,"")%>
					&nbsp;Descuento:<%=fb.decBox("descuento",cdoH.getColValue("descuento"),false,false,viewMode|| isHosp,8,null,null,"")%>
					</td>
					<td align="right" colspan='1'>&nbsp;Sub Total:</td>
                    <td align="right">&nbsp;
                      <%=fb.decBox("sub_total",cdoH.getColValue("sub_total"),false,false,true,8,null,null,"")%>
					</td>
                    <td align="right" colspan="2">&nbsp;</td>
				</tr>
                
                
                <tr class="TextRow01">
					<td align="right" colspan='6'>&nbsp;Total:</td>
                    <td align="right">&nbsp;
                      <%=fb.decBox("total",cdoH.getColValue("total"),false,false,viewMode|| isHosp,8,null,null,"")%>
					</td>
                    <td align="right" colspan="2">&nbsp;</td>
				</tr>
          
                <tr class="TextRow02">
					<td align="right" colspan='9'>&nbsp;
					</td>
				</tr>
                <tr class="TextRow02">
					<td align="right" colspan="9">
                        <%=fb.radio("saveOption","N",true,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
					    <%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
					    <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
                    
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onclick=\"canSubmit()\"")%>
                        &nbsp;&nbsp;&nbsp;
						<%=fb.button("close","Cerrar",true,false,null,null,"onclick=\"window.close()\"")%>
					</td>
				</tr>
			<%=fb.formEnd(true)%>
			</table>
            
            <!-- TAB0 DIV END HERE-->
            </div>
            
            <div class = "dhtmlgoodies_aTab">
               <table align="center" width="100%" cellpadding="0" cellspacing="1">
                  <tr>
                    <td>
                      <iframe id="diagFrame" name="diagFrame" frameborder="0" width="99%" height="400px" src="../planmedico/reg_diag_liq.jsp?codigo=<%=codigo%>&tab=1&mode=<%=(cdoH.getColValue("status")!=null&& (cdoH.getColValue("status").equals("A")||cdoH.getColValue("status").equals("N")) )?"view":mode%>" scroll="no"></iframe>
                    </td>
                  </tr>
               </table>
            </div>
            
            <div class = "dhtmlgoodies_aTab">
               <table align="center" width="100%" cellpadding="0" cellspacing="1">
                  <tr>
                    <td>
                      <iframe id="notaFrame" name="notaFrame" frameborder="0" width="99%" height="400px" src="../planmedico/reg_notas_liq.jsp?codigo=<%=codigo%>&tipo=CLIENTE&tab=2&mode=<%=(cdoH.getColValue("status")!=null&&cdoH.getColValue("status").equals("A")||cdoH.getColValue("status").equals("N"))?"view":mode%>" scroll="no"></iframe>
                    </td>
                  </tr>
               </table>
            </div>
            
            </div>
		</td>
	</tr>
	
</table>

<script>
<%  
String tabLabel = "'Generales'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Diagnóstico','Notas'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("liqReclSize")==null?"0":request.getParameter("liqReclSize"));
	String errCode = "";
	String errMsg = "";
    String saveOption = request.getParameter("saveOption")==null?"":request.getParameter("saveOption");
    
	String itemRemoved = "";
		
	al.clear();
	iLiqRecl.clear();
    vLiqRecl.clear();
    
    String SeqTrx = "";

    cdoH = new CommonDataObject();
    cdoH.setTableName("tbl_pm_liquidacion_reclamo");
    
    if (mode.equals("add")){
    CommonDataObject cdoSeq = SQLMgr.getData("select nvl(max(codigo),0) + 1 codigo from tbl_pm_liquidacion_reclamo where compania = "+compania);
    SeqTrx = cdoSeq.getColValue("codigo","0");
    
    cdoH.addColValue("codigo", SeqTrx);
    cdoH.setAction("I");
    cdoH.addColValue("SEQ_TRX", SeqTrx);
    
    cdoH.addColValue("usuario_creacion", cUserName);
    cdoH.addColValue("usuario_modificacion", cUserName);
    cdoH.addColValue("fecha_modificacion", cDate);
    cdoH.addColValue("fecha_creacion", cDate);
    cdoH.addColValue("fecha", cDate);
    }else{
       cdoH.setWhereClause("codigo = "+codigo);
       cdoH.setAction("U");
       cdoH.addColValue("usuario_modificacion", cUserName);
       cdoH.addColValue("fecha_modificacion", cDate);
    }
    
    cdoH.addColValue("compania", compania);
    
    if (request.getParameter("codigo_paciente").equals("")) cdoH.addColValue("admi_codigo_paciente","0");
    else cdoH.addColValue("admi_codigo_paciente",request.getParameter("codigo_paciente"));
    if (request.getParameter("admSecuencia").equals("")) cdoH.addColValue("admi_secuencia","0");
    else cdoH.addColValue("admi_secuencia",request.getParameter("admSecuencia"));
    if (request.getParameter("fecha_nacimiento").equals("")) cdoH.addColValue("admi_fecha_nacimiento","01/01/1900");
    else cdoH.addColValue("admi_fecha_nacimiento",request.getParameter("fecha_nacimiento"));
    if (request.getParameter("pacId").equals("")) cdoH.addColValue("pac_id","0");
    else cdoH.addColValue("pac_id",request.getParameter("pacId"));
   
    cdoH.addColValue("tipo_transaccion",request.getParameter("tipoTransaccion"));
    
    cdoH.addColValue("descripcion",request.getParameter("observacion"));
    cdoH.addColValue("nombre_cliente",request.getParameter("nombreCliente"));
    cdoH.addColValue("cedula_cliente",request.getParameter("cedulaPasaporte"));
    cdoH.addColValue("fecha_reclamo",request.getParameter("fecha_reclamo"));
    cdoH.addColValue("id_contrato",request.getParameter("no_contrato"));
    
    
    //-------------------
    cdoH.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"));
    cdoH.addColValue("fecha_egreso",request.getParameter("fecha_egreso"));
    
    cdoH.addColValue("med_codigo",request.getParameter("medico"));
    cdoH.addColValue("num_factura",request.getParameter("no_factura"));
    cdoH.addColValue("total",request.getParameter("total"));
    cdoH.addColValue("monto_paciente",request.getParameter("monto_pcte"));
    cdoH.addColValue("sub_total",request.getParameter("sub_total"));
    cdoH.addColValue("copago",request.getParameter("copago"));
    cdoH.addColValue("descuento",request.getParameter("descuento"));
    cdoH.addColValue("empresa",request.getParameter("tipo_empresa"));
    cdoH.addColValue("categoria",request.getParameter("categoria"));
    cdoH.addColValue("poliza",request.getParameter("poliza"));
    cdoH.addColValue("no_aprob",request.getParameter("no_aprob"));
    cdoH.addColValue("icd9",request.getParameter("icd9"));
    cdoH.addColValue("dias_hospitalizados",request.getParameter("dias_hospitalizados"));
    cdoH.addColValue("direccion_residencial",request.getParameter("direccion_residencial"));
    cdoH.addColValue("reembolso",(request.getParameter("reembolso")!=null?"S":"N"));
    cdoH.addColValue("status",request.getParameter("status"));
    cdoH.addColValue("tipo",request.getParameter("tipo"));
    cdoH.addColValue("tipo_atencion",request.getParameter("tipo_atencion"));
    cdoH.addColValue("tipo_beneficio",request.getParameter("tipo_beneficio"));
    cdoH.addColValue("desc_diagnostico",request.getParameter("desc_diagnostico"));
    cdoH.addColValue("hosp_si_no",request.getParameter("hosp_si_no"));
    cdoH.addColValue("hosp_tipo_si",request.getParameter("hosp_tipo_si"));
    cdoH.addColValue("hosp_tipo_no",request.getParameter("hosp_tipo_no"));
    cdoH.addColValue("tipo_reclamacion",request.getParameter("tipo_reclamacion"));
    cdoH.addColValue("cat_reclamo",request.getParameter("cat_reclamo"));
    cdoH.addColValue("fecha_ini_plan",request.getParameter("fecha_ini_plan"));
    
    if (!applyCharges.trim().equals("")) cdoH.addColValue("from_cargos", "Y");
    
	//-------------------
    
    if (mode.equals("add")){
    
    }else{
    
    }
      
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
        cdo.setTableName("tbl_pm_det_liq_reclamo");
        cdo.addColValue("secuencia", SeqTrx.equals("")?codigo:SeqTrx);
        
        if (mode.equals("add")){
            cdo.addColValue("usuario_creacion", cUserName);
            cdo.addColValue("usuario_modificacion", cUserName);
            cdo.addColValue("fecha_modificacion", cDate);
            cdo.addColValue("fecha_creacion", cDate);
        }else{
            cdo.setWhereClause("secuencia = "+codigo+" and compania = "+compania+" and seq_trx = "+request.getParameter("seq_trx"+i));
            cdo.addColValue("fecha_modificacion", cDate);
            cdo.addColValue("fecha_creacion", cDate);
        }
		
		cdo.addColValue("compania",compania);
		cdo.addColValue("fac_codigo","0");
		if(request.getParameter("status").equals("A")){
			cdo.addColValue("reclamo_seq",request.getParameter("no_aprob")+"-"+(i+1));
		}
		
        if (request.getParameter("codigo_paciente").equals("")) cdo.addColValue("fac_codigo_paciente","0");
        else cdo.addColValue("fac_codigo_paciente",request.getParameter("codigo_paciente"));
        if (request.getParameter("admSecuencia").equals("")) cdo.addColValue("fac_secuencia","0");
        else cdo.addColValue("fac_secuencia",request.getParameter("admSecuencia"));
        if (request.getParameter("fecha_nacimiento").equals("")) cdo.addColValue("fac_fecha_nacimiento","01/01/1970");
        else cdo.addColValue("fac_fecha_nacimiento",request.getParameter("fecha_nacimiento"));
        if (request.getParameter("pacId").equals("")) cdo.addColValue("pac_id","0");
        else cdo.addColValue("pac_id",request.getParameter("pacId"));
        
        cdo.addColValue("tipo_transaccion",request.getParameter("tipoTransaccion"));
        cdo.addColValue("tipo_cargo",request.getParameter("tipo_servicio"+i));
        cdo.addColValue("seq_trx",request.getParameter("seq_trx"+i));
        cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
        cdo.addColValue("monto",request.getParameter("monto"+i));
        cdo.addColValue("total_x_fila",request.getParameter("total_x_fila"+i));
        cdo.addColValue("estatus",request.getParameter("status"));
        cdo.addColValue("centro_servicio",request.getParameter("cds"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("codigo_precio",request.getParameter("codigo_precio"+i));
		if(request.getParameter("porcentaje_liq_reclamo")!=null && !request.getParameter("porcentaje_liq_reclamo").equals(""))cdo.addColValue("porcentaje_liq_reclamo",request.getParameter("porcentaje_liq_reclamo"+i));
        
        if(cdo.getColValue("centro_servicio").equals("0")){
            cdo.addColValue("medicoOrEmpre",request.getParameter("medicoOrEmpre"+i));
            cdo.addColValue("nombreMedicoOrEmpre",request.getParameter("nombreMedicoOrEmpre"+i));
            cdo.addColValue("empresa",request.getParameter("empresa"+i));
            cdo.addColValue("medico",request.getParameter("medico"+i));
            if (request.getParameter("pagar_sociedad"+i)!=null && request.getParameter("pagar_sociedad"+i).equals("Y") && request.getParameter("nombreMedicoOrEmpre"+i) != null &&!request.getParameter("nombreMedicoOrEmpre"+i).trim().equals("") ){    
                cdo.addColValue("pagar_sociedad","Y");
                cdo.addColValue("honorario_por","E");
                System.out.println("Y::::::::::::::::::::::::::::::::::::::::::::::::::::: PAGAR SOCIEDAD = "+request.getParameter("pagar_sociedad"+i));
            }else{
                cdo.addColValue("pagar_sociedad","N");
                cdo.addColValue("honorario_por","M");
                
                System.out.println("N::::::::::::::::::::::::::::::::::::::::::::::::::::: PAGAR SOCIEDAD = "+request.getParameter("pagar_sociedad"+i));
            } 
        }
      
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
		    itemRemoved = cdo.getKey();
		    if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
			else cdo.setAction("D");
		}
				
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iLiqRecl.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}
	
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&cedulaPasaporte="+request.getParameter("cedulaPasaporte")+"&nombreCliente="+request.getParameter("nombreCliente")+"&tipoTransaccion="+request.getParameter("tipoTransaccion")+"&observacion="+request.getParameter("observacion")+"&tipo_empresa="+request.getParameter("tipo_empresa")+"&categoria="+request.getParameter("categoria")+"&no_factura="+request.getParameter("no_factura")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&edad="+request.getParameter("edad")+"&sexo="+request.getParameter("sexo")+"&codigo_paciente="+request.getParameter("codigo_paciente")+"&fecha_ingreso="+request.getParameter("fecha_ingreso")+"&fecha_egreso="+request.getParameter("fecha_egreso")+"&direccion_residencial="+request.getParameter("direccion_residencial")+"&poliza="+request.getParameter("poliza")+"&dias_hospitalizados="+request.getParameter("dias_hospitalizados")+"&no_aprob="+request.getParameter("no_aprob")+"&medico="+request.getParameter("medico")+"&medico_nombre="+request.getParameter("medico_nombre")+"&icd9="+request.getParameter("icd9")+"&total="+request.getParameter("total")+"&status="+request.getParameter("status")+"&monto_pcte="+request.getParameter("monto_pcte")+"&sub_total="+request.getParameter("sub_total")+"&descuento="+request.getParameter("descuento")+"&copago="+request.getParameter("copago")+"&cds="+request.getParameter("cds")+"&reembolso="+request.getParameter("reembolso")+"&mode="+request.getParameter("mode")+"&codigo="+request.getParameter("codigo")+"&apply_charges="+request.getParameter("apply_charges")+"&admSecuencia="+request.getParameter("admSecuencia")+"&pacId="+request.getParameter("pacId")+"&from_cargos="+request.getParameter("from_cargos")+"&tipo="+request.getParameter("tipo")+"&tipo_atencion="+request.getParameter("tipo_atencion")+"&tipo_beneficio="+request.getParameter("tipo_beneficio")+"&desc_diagnostico="+request.getParameter("desc_diagnostico")+"&hosp_si_no="+request.getParameter("hosp_si_no")+"&hosp_tipo_si="+request.getParameter("hosp_tipo_si")+"&hosp_tipo_no="+request.getParameter("hosp_tipo_no")+"&tipo_reclamacion="+request.getParameter("tipo_reclamacion")+"&cat_reclamo="+request.getParameter("cat_reclamo")+"&fecha_reclamo="+request.getParameter("fecha_reclamo"));
		return;
	}
	
	if (baction != null && baction.equals("+"))
	{
		CommonDataObject cdo = new CommonDataObject();
		liqReclLastLineNo++;
		
		cdo.setKey(iLiqRecl.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo","0");
		cdo.addColValue("lockedd","0");
		try
		{
			iLiqRecl.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&cedulaPasaporte="+request.getParameter("cedulaPasaporte")+"&nombreCliente="+request.getParameter("nombreCliente")+"&tipoTransaccion="+request.getParameter("tipoTransaccion")+"&observacion="+request.getParameter("observacion")+"&tipo_empresa="+request.getParameter("tipo_empresa")+"&categoria="+request.getParameter("categoria")+"&no_factura="+request.getParameter("no_factura")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&edad="+request.getParameter("edad")+"&sexo="+request.getParameter("sexo")+"&codigo_paciente="+request.getParameter("codigo_paciente")+"&fecha_ingreso="+request.getParameter("fecha_ingreso")+"&fecha_egreso="+request.getParameter("fecha_egreso")+"&direccion_residencial="+request.getParameter("direccion_residencial")+"&poliza="+request.getParameter("poliza")+"&dias_hospitalizados="+request.getParameter("dias_hospitalizados")+"&no_aprob="+request.getParameter("no_aprob")+"&medico="+request.getParameter("medico")+"&medico_nombre="+request.getParameter("medico_nombre")+"&icd9="+request.getParameter("icd9")+"&total="+request.getParameter("total")+"&status="+request.getParameter("status")+"&monto_pcte="+request.getParameter("monto_pcte")+"&sub_total="+request.getParameter("sub_total")+"&descuento="+request.getParameter("descuento")+"&copago="+request.getParameter("copago")+"&cds="+request.getParameter("cds")+"&reembolso="+request.getParameter("reembolso")+"&mode="+request.getParameter("mode")+"&codigo="+request.getParameter("codigo")+"&apply_charges="+request.getParameter("apply_charges")+"&apply_charges="+request.getParameter("apply_charges")+"&admSecuencia="+request.getParameter("admSecuencia")+"&pacId="+request.getParameter("pacId")+"&from_cargos="+request.getParameter("from_cargos")+"&tipo="+request.getParameter("tipo")+"&tipo_atencion="+request.getParameter("tipo_atencion")+"&tipo_beneficio="+request.getParameter("tipo_beneficio")+"&desc_diagnostico="+request.getParameter("desc_diagnostico")+"&hosp_si_no="+request.getParameter("hosp_si_no")+"&hosp_tipo_si="+request.getParameter("hosp_tipo_si")+"&hosp_tipo_no="+request.getParameter("hosp_tipo_no")+"&tipo_reclamacion="+request.getParameter("tipo_reclamacion")+"&cat_reclamo="+request.getParameter("cat_reclamo")+"&fecha_reclamo="+request.getParameter("fecha_reclamo"));
		return;
	}

	if(baction != null && baction.equals("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.save(cdoH,al,true,true,true,true);
        ConMgr.clearAppCtx(null);
	}
%>
<!DOCTYPE html>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert("<%=SQLMgr.getErrMsg()%>");
	window.opener.location = "<%=request.getContextPath()%>/planmedico/liquidacion_reclamo_list.jsp";
<%
if (saveOption.equalsIgnoreCase("N")){%>
setTimeout("addMode()",500);
<%} else if (saveOption.equalsIgnoreCase("O")){%>
setTimeout("editMode()",500);
<%}else if (saveOption.equalsIgnoreCase("C")){%>
window.close();
<%}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode(){
	window.location = "<%=request.getContextPath()+request.getServletPath()%>?mode=add&cat_reclamo=<%=request.getParameter("cat_reclamo")%>";
}

function editMode(){
	window.location = "<%=request.getContextPath()%>/planmedico/reg_liquidacion_reclamo.jsp?mode=edit&codigo=<%=SeqTrx.equals("")?codigo:SeqTrx%>&cat_reclamo=<%=request.getParameter("cat_reclamo")%>";
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>