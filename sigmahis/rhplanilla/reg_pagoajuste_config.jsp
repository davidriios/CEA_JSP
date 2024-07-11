<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%--<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />--%>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector"/>

<%

SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject desc= new CommonDataObject();
StringBuffer sql= new StringBuffer();
String key="";
String emp_id= request.getParameter("emp_id");
String secuencia=request.getParameter("secuencia");
String anio =request.getParameter("anio");
String noPlanilla =request.getParameter("noPlanilla");
String codPlanilla =request.getParameter("codPlanilla");
String fg =request.getParameter("fg");

ArrayList al= new ArrayList();
ArrayList alPla= new ArrayList();
String change= request.getParameter("change");
int ajLastLineNo =0;
String mode =  request.getParameter("mode");
boolean viewMode= false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
int descLastLineNo = 0;

if(request.getParameter("ajLastLineNo")!=null && ! request.getParameter("ajLastLineNo").equals(""))ajLastLineNo=Integer.parseInt(request.getParameter("ajLastLineNo"));
if (mode == null ) mode="add";
if (emp_id == null ) emp_id="";
if(secuencia==null)secuencia="";
if(anio==null)anio="";
if(codPlanilla==null)codPlanilla="";
if(noPlanilla==null)noPlanilla="";
if(fg==null)fg="";

if(mode.trim().equals("view"))viewMode=true;

alPla = sbb.getBeanList(ConMgr.getConnection(),"select cod_planilla as optValueColumn,cod_planilla||' - '||nombre  optLabelColumn from tbl_pla_planilla where cod_planilla <> 4 and compania="+(String) session.getAttribute("_companyId")+" order by 1",CommonDataObject.class);

if (request.getMethod().equalsIgnoreCase("GET"))
{
desc.addColValue("fecha",cDateTime);


sql.append("select p.seg_soc_emp, p.seg_edu_emp,nvl(p.seg_soc_grep_emp,0) v_ssocial_grep, nvl(p.gr_porc_no_ssocial,0) v_porc_grep_no_ssocial,nvl(p.gr_porc_no_renta,0)gr_porc_no_renta,nvl(p.ssoc_xiiim_emp,0)ssoc_xiiim_emp from tbl_pla_parametros p where p.cod_compania=");
sql.append((String) session.getAttribute("_companyId"));
sql.append(" and p.estado ='A'");
desc = SQLMgr.getData(sql.toString());

if(mode.trim().equals("add")){
	if(change==null){
	iEmp.clear();
	vEmp.clear();}

}
else {
if(change==null)
{
		iEmp.clear();
		vEmp.clear();

sql= new StringBuffer();
sql.append("select a.anio, a.cod_planilla as codPlanilla, a.num_planilla as noPlanilla, a.provincia, a.sigla, a.tomo, a.asiento, a.secuencia, nvl(a.sal_bruto,0) as salBruto, nvl(a.vacacion,0) as vacacion,  nvl(a.sal_neto,0) salNeto, nvl(a.ausencia,0) ausencia, nvl(a.sal_ausencia,0) salAusencia, nvl(a.extra,0) extra, nvl(a.seg_social,0) segSocial, nvl(a.seg_educativo,0) segEducativo, nvl(a.imp_renta,0) impRenta, nvl(a.fondo_com,0) fondoCom, nvl(a.tardanza,0) tardanza, nvl(a.otras_ded,0) otrasDed,  nvl(a.total_ded,0) totalDed, nvl(a.dev_multa,0) devMulta, a.num_cheque as numCheque, nvl(a.comision,0) comision, nvl(a.gasto_rep,0) gastoRep, nvl(a.ayuda_mortuoria,0) ayudaMortuoria, nvl(a.otros_ing,0) otrosIng, nvl(a.otros_egr,0) otrosEgr, nvl(a.otros_ing_fijos,0) otrosFijos,  nvl(a.alto_riesgo,0) altoRiesgo, a.periodo, nvl(a.indemnizacion,0) indemnizacion, nvl(a.preaviso,0) preaviso, nvl(a.xiii_mes,0) decimo, nvl(a.prima_antiguedad,0) prima, nvl(a.bonificacion,0) bonificacion,  nvl(a.incentivo,0) incentivo, to_char(a.fecha_cheque,'dd/mm/yyyy') as fecha_cheque, a.estado, to_char(a.fecha_aplicado,'dd/mm/yyyy') as fechaAplicado, a.cheque_impreso, a.explicacion, a.num_periodo as numPeriodo, b.num_empleado as num_empleado, a.reg_periodo regPeriodo, a.reg_anio as  regAnio, a.acc_estado, a.acc_usuario, to_char(a.acc_fecha,'dd/mm/yyyy') as accFecha, a.forma_pago as fPago, a.num_ach, a.ach_generada, a.ach_usuario, to_char(a.ach_fecha,'dd/mm/yyyy') as achFecha, nvl(a.imp_renta_gasto,0) impRentaGasto, a.vobo_estado, a.vobo_usuario, to_char(a.vobo_fecha,'dd/mm/yyyy') as voboFecha,  nvl(a.pago_40porc,0) pago40Porc, nvl(a.seg_social_gasto,0) segSocialGasto, nvl(a.prima_produccion,0) primaProduccion, b.nombre_empleado, b.primer_apellido, b.unidad_organi unidad, ( select descripcion  from tbl_sec_unidad_ejec where codigo = b.unidad_organi and compania = b.compania) as descUnidad, b.salario_base salario, b.rata_hora as rataHora,  b.emp_id, d.nombre as codDesc,b.cedula1 as cedula,nvl((select count(*) from tbl_pla_descuento_ajuste t where emp_id = a.emp_id and t.anio   =a.anio and t.cod_planilla =a.cod_planilla and t.num_planilla =a.num_planilla and t.secuencia =a.secuencia),0)descuentos from tbl_pla_pago_ajuste a, vw_pla_empleado b, tbl_pla_planilla d where a.emp_id=b.emp_id and a.cod_compania=b.compania and a.cod_planilla = d.cod_planilla and a.cod_compania = d.compania and a.cod_compania=");
sql.append((String) session.getAttribute("_companyId"));
	if(mode.trim().equals("view")&& fg.trim().equals("CS")){sql.append(" and a.estado not in('PE')  and a.acc_estado = 'N' ");}
	else {sql.append(" and a.estado in('PE')  and a.acc_estado = 'N' ");}
	if(mode.trim().equals("edit")){sql.append(" and a.estado in('PE')  and a.acc_estado = 'N' and nvl(a.actualizar,'N') ='N' and a.vobo_estado ='N' ");}
	if(!emp_id.trim().equals("")){sql.append(" and a.emp_id=");sql.append(emp_id);}
	if(!secuencia.trim().equals("")){sql.append(" and a.secuencia=");sql.append(secuencia);}
	if(!codPlanilla.trim().equals("")){sql.append(" and a.cod_planilla=");sql.append(codPlanilla);}
	if(!noPlanilla.trim().equals("")){sql.append(" and a.num_planilla=");sql.append(noPlanilla);}
	if(!anio.trim().equals("")){sql.append(" and a.anio=");sql.append(anio);}


sql.append(" order by a.num_empleado,a.secuencia asc ");


	al=SQLMgr.getDataList(sql.toString());
ajLastLineNo=al.size();
			for(int h=0;h<al.size();h++)
			{
			CommonDataObject cdo = (CommonDataObject) al.get(h);
			cdo.setKey(h);
			cdo.setAction("U");

			iEmp.put(cdo.getKey(),cdo);
			vEmp.add(cdo.getColValue("emp_id"));

			}
			/*if(iEmp.size()==0)
			{
				CommonDataObject cdo = new CommonDataObject();
				cdo.addColValue("secuencia","0");
				cdo.addColValue("fecha_cheque","");
				cdo.addColValue("fPago","1");
				cdo.addColValue("fecha_cheque",cDateTime.substring(0,10));
				ajLastLineNo++;

				if(ajLastLineNo<10)key="00" + ajLastLineNo;
				else if(ajLastLineNo<100)key="0"+ajLastLineNo;
				else key=""+ajLastLineNo;
				iEmp.put(key,cdo);

			}*/


}
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<script language="javascript">
document.title="Registro de Transacciones de Ajuste - Agregar - "+document.title;

function validaCampo(ref)
{
var cont = eval('document.form0.keySize').value;
<%if(!mode.trim().equals("view")){%>
var planilla = eval('document.form0.codPlanilla').value;
if(ref=='US'){eval('document.form0.anio').value='';eval('document.form0.noPlanilla').value='';eval('document.form0.numPeriodo').value='';}

for (i=0;i<parseInt(cont);i++)
	{
		
		eval('document.form0.periodo'+i).readOnly=true;
		eval('document.form0.salBruto'+i).readOnly=false;
		eval('document.form0.ausencia'+i).readOnly=false;
		eval('document.form0.tardanza'+i).readOnly=false;
		eval('document.form0.extra'+i).readOnly=false;
		eval('document.form0.otrosIng'+i).readOnly=false;
		eval('document.form0.otrosEgr'+i).readOnly=false;
		eval('document.form0.gastoRep'+i).readOnly=false;
		eval('document.form0.vacacion'+i).readOnly=false;
		eval('document.form0.decimo'+i).readOnly=false;
		eval('document.form0.primaProduccion'+i).readOnly=false;
		eval('document.form0.prima'+i).readOnly=false;
		eval('document.form0.indemnizacion'+i).readOnly=false;
		eval('document.form0.preaviso'+i).readOnly=false;
		eval('document.form0.bonificacion'+i).readOnly=false;
		eval('document.form0.incentivo'+i).readOnly=false;
		//eval('document.form0.pago40Porc'+i).readOnly=false;
		eval('document.form0.otras_ded'+i).readOnly=false;
		eval('document.form0.periodo'+i).className='FormDataObjectEnabled';
		eval('document.form0.vacacion'+i).className='FormDataObjectEnabled';
		eval('document.form0.decimo'+i).className='FormDataObjectEnabled';
		eval('document.form0.prima'+i).className='FormDataObjectEnabled';
		eval('document.form0.indemnizacion'+i).className='FormDataObjectEnabled';
		eval('document.form0.preaviso'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.ausencia'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.tardanza'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.extra'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.otrosIng'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.otrosEgr'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.gastoRep'+i).className='FormDataObjectEnabled'; 
		eval('document.form0.primaProduccion'+i).className='FormDataObjectEnabled';
		eval('document.form0.bonificacion'+i).className='FormDataObjectEnabled';
		eval('document.form0.incentivo'+i).className='FormDataObjectEnabled';
		//eval('document.form0.bonificacion'+i).className='FormDataObjectEnabled' 
		eval('document.form0.salBruto'+i).className='FormDataObjectEnabled';
		eval('document.form0.otras_ded'+i).className='FormDataObjectEnabled';
		eval('document.form0.periodo'+i).className='FormDataObjectDisabled';
		if('<%=mode%>'=='add'||ref=='US'){
		eval('document.form0.salBruto'+i).value='0.00';
		eval('document.form0.vacacion'+i).value='0.00';
		eval('document.form0.decimo'+i).value='0.00';
		eval('document.form0.prima'+i).value='0.00';
		eval('document.form0.indemnizacion'+i).value='0.00';
		eval('document.form0.preaviso'+i).value='0.00';
		eval('document.form0.ausencia'+i).value='0.00';
		eval('document.form0.tardanza'+i).value='0.00';
		eval('document.form0.extra'+i).value='0.00';
		eval('document.form0.otrosIng'+i).value='0.00';
		eval('document.form0.otrosEgr'+i).value='0.00';
		eval('document.form0.vacacion'+i).value='0.00';
		eval('document.form0.primaProduccion'+i).value='0.00';
		eval('document.form0.otras_ded'+i).value='0.00';
		eval('document.form0.bonificacion'+i).value='0.00';
		eval('document.form0.incentivo'+i).value='0.00';
		eval('document.form0.gastoRep'+i).value='0.00';
		eval('document.form0.periodo'+i).value='';
		
		document.getElementById("segSocial"+i).value='0.00';
		document.getElementById("segEducativo"+i).value='0.00';
		document.getElementById("segSocialGasto"+i).value='0.00';
		document.getElementById("impRentaGasto"+i).value='0.00';
		document.getElementById("totalDed"+i).value='0.00';
		document.getElementById("totBruto"+i).value='0.00';
		document.getElementById("salNeto"+i).value='0.00';}
		
		if(planilla=='1')
		{
		eval('document.form0.vacacion'+i).readOnly=true;
		eval('document.form0.vacacion'+i).className='FormDataObjectDisabled';
		eval('document.form0.decimo'+i).readOnly=true;
		eval('document.form0.decimo'+i).className='FormDataObjectDisabled';
		eval('document.form0.prima'+i).readOnly=true;
		eval('document.form0.prima'+i).className='FormDataObjectDisabled';
		eval('document.form0.indemnizacion'+i).readOnly=true;
		eval('document.form0.indemnizacion'+i).className='FormDataObjectDisabled';
		eval('document.form0.preaviso'+i).readOnly=true;
		eval('document.form0.preaviso'+i).className='FormDataObjectDisabled';
		eval('document.form0.incentivo'+i).readOnly=true;
		eval('document.form0.incentivo'+i).className='FormDataObjectDisabled';
		eval('document.form0.periodo'+i).readOnly=false;
		eval('document.form0.periodo'+i).className='FormDataObjectEnabled';
		}
		 else if(planilla=='2')
		{
		//eval('document.form0.salBruto'+i).readOnly=true;
		eval('document.form0.ausencia'+i).readOnly=true;
		eval('document.form0.tardanza'+i).readOnly=true;
		eval('document.form0.extra'+i).readOnly=true;
		eval('document.form0.otrosIng'+i).readOnly=true;
		eval('document.form0.otrosEgr'+i).readOnly=true;
		eval('document.form0.vacacion'+i).readOnly=true;
		eval('document.form0.primaProduccion'+i).readOnly=true;
		eval('document.form0.prima'+i).readOnly=true;
		eval('document.form0.indemnizacion'+i).readOnly=true;
		eval('document.form0.preaviso'+i).readOnly=true;
		eval('document.form0.otras_ded'+i).readOnly=true;
		eval('document.form0.bonificacion'+i).readOnly=true;
		eval('document.form0.gastoRep'+i).readOnly=true;
		eval('document.form0.incentivo'+i).readOnly=true;
		eval('document.form0.incentivo'+i).className='FormDataObjectDisabled';		
		//eval('document.form0.pago40Porc'+i).readOnly=true;
		eval('document.form0.salBruto'+i).className='FormDataObjectDisabled';
		eval('document.form0.ausencia'+i).className='FormDataObjectDisabled';
		eval('document.form0.tardanza'+i).className='FormDataObjectDisabled';
		eval('document.form0.extra'+i).className='FormDataObjectDisabled';
		eval('document.form0.otrosIng'+i).className='FormDataObjectDisabled';
		eval('document.form0.otrosEgr'+i).className='FormDataObjectDisabled';
		eval('document.form0.vacacion'+i).className='FormDataObjectDisabled';
		eval('document.form0.primaProduccion'+i).className='FormDataObjectDisabled';
		eval('document.form0.prima'+i).className='FormDataObjectDisabled';
		eval('document.form0.indemnizacion'+i).className='FormDataObjectDisabled';
		eval('document.form0.preaviso'+i).className='FormDataObjectDisabled';
		eval('document.form0.bonificacion'+i).className='FormDataObjectDisabled'; 
		eval('document.form0.gastoRep'+i).className='FormDataObjectDisabled';
		eval('document.form0.otras_ded'+i).className='FormDataObjectDisabled';
		
		}
		else if(planilla=='3')
		{
		eval('document.form0.salBruto'+i).readOnly=true;
		eval('document.form0.ausencia'+i).readOnly=true;
		eval('document.form0.tardanza'+i).readOnly=true;
		eval('document.form0.extra'+i).readOnly=true;
		eval('document.form0.otrosIng'+i).readOnly=true;
		eval('document.form0.otrosEgr'+i).readOnly=true;
		eval('document.form0.decimo'+i).readOnly=true;
		eval('document.form0.primaProduccion'+i).readOnly=true;
		eval('document.form0.prima'+i).readOnly=true;
		eval('document.form0.indemnizacion'+i).readOnly=true;
		eval('document.form0.preaviso'+i).readOnly=true;
		eval('document.form0.bonificacion'+i).readOnly=true;
		eval('document.form0.incentivo'+i).readOnly=true;
		eval('document.form0.periodo'+i).readOnly=false;
		eval('document.form0.periodo'+i).className='FormDataObjectEnabled';
		<%if(mode.trim().equals("add")){%>
		eval('document.form0.salBruto'+i).value='0.00';
		eval('document.form0.ausencia'+i).value='0.00';
		eval('document.form0.tardanza'+i).value='0.00';
		eval('document.form0.extra'+i).value='0.00';
		eval('document.form0.otrosIng'+i).value='0.00';
		eval('document.form0.otrosEgr'+i).value='0.00';
		eval('document.form0.decimo'+i).value='0.00';
		eval('document.form0.primaProduccion'+i).value='0.00';
		eval('document.form0.prima'+i).value='0.00';
		eval('document.form0.indemnizacion'+i).value='0.00';
		eval('document.form0.preaviso'+i).value='0.00';
		eval('document.form0.bonificacion'+i).value='0.00';
		eval('document.form0.periodo'+i).value='';
		//eval('document.form0.pago40Porc'+i).readOnly=true;
		<%}%>
		
		eval('document.form0.incentivo'+i).className='FormDataObjectDisabled';
		eval('document.form0.salBruto'+i).className='FormDataObjectDisabled';
		eval('document.form0.ausencia'+i).className='FormDataObjectDisabled';
		eval('document.form0.tardanza'+i).className='FormDataObjectDisabled';
		eval('document.form0.extra'+i).className='FormDataObjectDisabled';
		eval('document.form0.otrosIng'+i).className='FormDataObjectDisabled';
		eval('document.form0.otrosEgr'+i).className='FormDataObjectDisabled';
		eval('document.form0.decimo'+i).className='FormDataObjectDisabled';
		eval('document.form0.primaProduccion'+i).className='FormDataObjectDisabled';
		eval('document.form0.prima'+i).className='FormDataObjectDisabled';
		eval('document.form0.indemnizacion'+i).className='FormDataObjectDisabled';
		eval('document.form0.preaviso'+i).className='FormDataObjectDisabled';
		eval('document.form0.bonificacion'+i).className='FormDataObjectDisabled'; 
		
		}
		 else if(planilla=='5')
		{
		eval('document.form0.salBruto'+i).readOnly=true;
		eval('document.form0.ausencia'+i).readOnly=true;
		eval('document.form0.tardanza'+i).readOnly=true;
		eval('document.form0.extra'+i).readOnly=true;
		eval('document.form0.otrosIng'+i).readOnly=true;
		eval('document.form0.otrosEgr'+i).readOnly=true;
		eval('document.form0.vacacion'+i).readOnly=true;
		eval('document.form0.decimo'+i).readOnly=true;
		eval('document.form0.bonificacion'+i).readOnly=true;
		eval('document.form0.prima'+i).readOnly=true;
		eval('document.form0.indemnizacion'+i).readOnly=true;
		eval('document.form0.preaviso'+i).readOnly=true;
		eval('document.form0.gastoRep'+i).readOnly=true;
		eval('document.form0.otras_ded'+i).readOnly=true;
		eval('document.form0.incentivo'+i).readOnly=true;
		<%if(mode.trim().equals("add")){%>
		eval('document.form0.salBruto'+i).value='0.00';
		eval('document.form0.ausencia'+i).value='0.00';
		eval('document.form0.tardanza'+i).value='0.00';
		eval('document.form0.extra'+i).value='0.00';
		eval('document.form0.otrosIng'+i).value='0.00';
		eval('document.form0.otrosEgr'+i).value='0.00';
		eval('document.form0.vacacion'+i).value='0.00';
		eval('document.form0.decimo'+i).value='0.00';
		eval('document.form0.bonificacion'+i).value='0.00';
		eval('document.form0.prima'+i).value='0.00';
		eval('document.form0.indemnizacion'+i).value='0.00';
		eval('document.form0.preaviso'+i).value='0.00';
		eval('document.form0.gastoRep'+i).value='0.00';
		eval('document.form0.otras_ded'+i).value='0.00';<%}%>
			eval('document.form0.incentivo'+i).className='FormDataObjectDisabled';
			eval('document.form0.salBruto'+i).className='FormDataObjectDisabled';
			eval('document.form0.ausencia'+i).className='FormDataObjectDisabled';
			eval('document.form0.tardanza'+i).className='FormDataObjectDisabled';
			eval('document.form0.extra'+i).className='FormDataObjectDisabled';
			eval('document.form0.otrosIng'+i).className='FormDataObjectDisabled';
			eval('document.form0.otrosEgr'+i).className='FormDataObjectDisabled';
			eval('document.form0.vacacion'+i).className='FormDataObjectDisabled';
			eval('document.form0.bonificacion'+i).className='FormDataObjectDisabled';
			eval('document.form0.prima'+i).className='FormDataObjectDisabled';
			eval('document.form0.indemnizacion'+i).className='FormDataObjectDisabled';
			eval('document.form0.preaviso'+i).className='FormDataObjectDisabled';
			eval('document.form0.decimo'+i).className='FormDataObjectDisabled'; 
			eval('document.form0.gastoRep'+i).className='FormDataObjectDisabled';
			eval('document.form0.otras_ded'+i).className='FormDataObjectDisabled';
		//eval('document.form0.pago40Porc'+i).readOnly=true;
		}
		 else if(planilla=='6')
		{
			eval('document.form0.ausencia'+i).readOnly=true;
			eval('document.form0.tardanza'+i).readOnly=true;
			eval('document.form0.extra'+i).readOnly=true;
			eval('document.form0.otrosIng'+i).readOnly=true;
			eval('document.form0.otrosEgr'+i).readOnly=true;
			eval('document.form0.vacacion'+i).readOnly=true;
			eval('document.form0.primaProduccion'+i).readOnly=true;
			eval('document.form0.prima'+i).readOnly=true;
			eval('document.form0.indemnizacion'+i).readOnly=true;
			eval('document.form0.preaviso'+i).readOnly=true;
			eval('document.form0.otras_ded'+i).readOnly=true;
			eval('document.form0.decimo'+i).readOnly=true;
			eval('document.form0.gastoRep'+i).readOnly=true;
			eval('document.form0.bonificacion'+i).readOnly=true;
			eval('document.form0.bonificacion'+i).className='FormDataObjectDisabled';
			//eval('document.form0.pago40Porc'+i).readOnly=true;
			eval('document.form0.salBruto'+i).className='FormDataObjectDisabled';
			eval('document.form0.ausencia'+i).className='FormDataObjectDisabled';
			eval('document.form0.tardanza'+i).className='FormDataObjectDisabled';
			eval('document.form0.extra'+i).className='FormDataObjectDisabled';
			eval('document.form0.otrosIng'+i).className='FormDataObjectDisabled';
			eval('document.form0.otrosEgr'+i).className='FormDataObjectDisabled';
			eval('document.form0.vacacion'+i).className='FormDataObjectDisabled';
			eval('document.form0.primaProduccion'+i).className='FormDataObjectDisabled';
			eval('document.form0.prima'+i).className='FormDataObjectDisabled';
			eval('document.form0.indemnizacion'+i).className='FormDataObjectDisabled';
			eval('document.form0.preaviso'+i).className='FormDataObjectDisabled';
			eval('document.form0.decimo'+i).className='FormDataObjectDisabled'; 
			eval('document.form0.gastoRep'+i).className='FormDataObjectDisabled';
			eval('document.form0.otras_ded'+i).className='FormDataObjectDisabled';
		}
}
<%}%>
}

function doAction()
{
	validaCampo('');
	calMontoBruto();
	<%if(request.getParameter("type") != null && !request.getParameter("type").trim().equals("")){%>
	var anio = document.form0.anio.value;
	var noPlanilla = document.form0.noPlanilla.value;
	var codPlanilla = document.form0.codPlanilla.value;
	abrir_ventana1('../common/check_empleado.jsp?fp=planillaAjuste&anio='+anio+'&noPlanilla='+noPlanilla+'&codPlanilla='+codPlanilla+'&mode=<%=mode%>&fg=<%=fg%>');
	<%}%>

}

function calMontoBruto()
{

var size = eval('document.form0.keySize').value;
var totalBruto = 0.00;
var totalNeto = 0.00;
var totalSoc = 0.00;
var totalEdu = 0.00;
var totalIsr = 0.00;
var totalSsocGrp =0.00;
var v_imp_renta_grep =0.00;
var v_ssocial_grep	 = parseFloat(eval('document.form0.v_ssocial_grep').value);
var v_porc_grep_no_ssocial	 = parseFloat(eval('document.form0.v_porc_grep_no_ssocial').value);
var gr_porc_no_renta = parseFloat(eval('document.form0.gr_porc_no_renta').value);
var totalSocDec = 0.00;

for (i=0;i<parseInt(size);i++)
	{


	totalBruto =  parseFloat(eval('document.form0.salBruto'+i).value) +
			parseFloat(eval('document.form0.extra'+i).value) +
			parseFloat(eval('document.form0.otrosIng'+i).value) +
			parseFloat(eval('document.form0.gastoRep'+i).value) +
			parseFloat(eval('document.form0.vacacion'+i).value) +
			parseFloat(eval('document.form0.decimo'+i).value) +
			parseFloat(eval('document.form0.prima'+i).value) +
			parseFloat(eval('document.form0.primaProduccion'+i).value) +
			parseFloat(eval('document.form0.indemnizacion'+i).value) +
			parseFloat(eval('document.form0.preaviso'+i).value) +
			parseFloat(eval('document.form0.bonificacion'+i).value) +
			parseFloat(eval('document.form0.incentivo'+i).value) +
			//parseFloat(eval('document.form0.pago40Porc'+i).value) -
			parseFloat(eval('document.form0.ausencia'+i).value) -
			parseFloat(eval('document.form0.tardanza'+i).value) -
			parseFloat(eval('document.form0.otrosEgr'+i).value);

totalSoc = ((parseFloat(eval('document.form0.salBruto'+i).value) +
			parseFloat(eval('document.form0.extra'+i).value) +
			parseFloat(eval('document.form0.otrosIng'+i).value)+
			parseFloat(eval('document.form0.bonificacion'+i).value)+
			/*parseFloat(eval('document.form0.incentivo'+i).value)+*/
			parseFloat(eval('document.form0.vacacion'+i).value) -
			parseFloat(eval('document.form0.ausencia'+i).value) -
			parseFloat(eval('document.form0.tardanza'+i).value) -
			parseFloat(eval('document.form0.otrosEgr'+i).value)) *
			parseFloat(eval('document.form0.ssocial').value)) / 100;
			
totalSocDec = ((parseFloat(eval('document.form0.decimo'+i).value)) *
			parseFloat(eval('document.form0.ssoc_xiiim_emp').value)) / 100;
            
			v_imp_renta_grep = 0.00;
			totalSsocGrp = 0.00;
			if(parseFloat(eval('document.form0.gastoRep'+i).value) !=0 )
			{	totalSsocGrp =  (parseFloat(eval('document.form0.gastoRep'+i).value) * ((100-v_porc_grep_no_ssocial)/100)).toFixed(2)* (v_ssocial_grep/100);
				//select  getImpuestosIsr(-100,0,0, 0,'G','N') from dual

				var p_flag ='';
				if(parseFloat(eval('document.form0.gastoRep'+i).value) > 0 )p_flag='N';
				else p_flag='S';
				v_imp_renta_grep = getDBData('<%=request.getContextPath()%>','nvl(getImpuestosIsr('+parseFloat(eval('document.form0.gastoRep'+i).value)+','+gr_porc_no_renta+',0, 0,\'G\',\''+p_flag+'\'),0)','dual','','');
				//v_imp_renta_grep	=	(parseFloat(eval('document.form0.gastoRep'+i).value) * ((100 - gr_porc_no_renta)/100) ).toFixed(2);
// ROUND(:PA.GASTO_REP * ((100 -V_GR_PORC_NO_RENTA)/100),2);

			}

totalEdu = ((parseFloat(eval('document.form0.salBruto'+i).value) +
			parseFloat(eval('document.form0.extra'+i).value) +
			parseFloat(eval('document.form0.otrosIng'+i).value) +
			parseFloat(eval('document.form0.vacacion'+i).value) -
			parseFloat(eval('document.form0.ausencia'+i).value) -
			parseFloat(eval('document.form0.tardanza'+i).value) -
			parseFloat(eval('document.form0.otrosEgr'+i).value)) *
			parseFloat(eval('document.form0.seducativo').value)) / 100;

//v_otras_ded //descuentos de acreedores
var v_total_ded = (parseFloat((totalSoc+totalSocDec+totalSsocGrp).toFixed(2)) + parseFloat(totalEdu.toFixed(2))+ parseFloat(v_imp_renta_grep) + parseFloat(eval('document.form0.impRenta'+i).value)+parseFloat(eval('document.form0.otras_ded'+i).value)).toFixed(2) ;


	document.getElementById("segSocial"+i).value=(totalSoc+totalSocDec).toFixed(2);
	document.getElementById("segEducativo"+i).value=totalEdu.toFixed(2);
	document.getElementById("segSocialGasto"+i).value=totalSsocGrp.toFixed(2);
	document.getElementById("impRentaGasto"+i).value=v_imp_renta_grep;
	document.getElementById("totalDed"+i).value=v_total_ded;

	totalNeto = totalBruto -(
			parseFloat(eval('document.form0.segSocial'+i).value) +
			parseFloat(eval('document.form0.segSocialGasto'+i).value) +
			parseFloat(eval('document.form0.segEducativo'+i).value) +
			parseFloat(eval('document.form0.impRenta'+i).value) +
			parseFloat(eval('document.form0.impRentaGasto'+i).value)+
			parseFloat(eval('document.form0.otras_ded'+i).value)) ;

	document.getElementById("totBruto"+i).value=totalBruto.toFixed(2);
	document.getElementById("salNeto"+i).value=totalNeto.toFixed(2);
}
}
function addPla(){var anio = eval('document.form0.anio').value;abrir_ventana1('../common/search_planilla.jsp?fp=planillaAjuste&anio='+anio);}
function printAjuste(fg){var anio = eval('document.form0.anio').value;var codPlanilla = eval('document.form0.codPlanilla').value;var numPlanilla = eval('document.form0.noPlanilla').value;abrir_ventana1('../rhplanilla/print_comprob_ajustes_det.jsp?fp=REG&anio='+anio+'&numPlanilla='+numPlanilla+'&codPlanilla='+codPlanilla+'&fg='+fg);}
function printComprobante(secuencia,empId){var sec ='<%=secuencia%>';if(sec == '')sec = secuencia;var emp_id ='<%=emp_id%>';if(emp_id == '')emp_id = empId;var anio = eval('document.form0.anio').value;var codPlanilla = eval('document.form0.codPlanilla').value;var numPlanilla = eval('document.form0.noPlanilla').value;abrir_ventana('../rhplanilla/print_list_comp_pago_emp.jsp?fg=AJ&anio='+anio+'&cod='+codPlanilla+'&num='+numPlanilla+'&secuencia='+sec+'&empId='+emp_id+'&fp=<%=fg%>&mode=<%=mode%>');
}
function regDescuentos(k){
var anio = eval('document.form0.anio').value;
var codPlanilla = eval('document.form0.codPlanilla').value;
var numPlanilla = eval('document.form0.noPlanilla').value;
var secuencia = eval('document.form0.secuencia'+k).value;
var empId = eval('document.form0.emp_id'+k).value;
var otrasDed = eval('document.form0.otras_ded'+k).value;
var otrasDedOld = eval('document.form0.otrasDedOld'+k).value;
var descuentos = eval('document.form0.descuentos'+k).value;

var descAcr = -1;
if('<%=mode%>' != 'view')descAcr =getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_descuento d','d.emp_id = '+empId+' and  d.cod_compania = <%=(String) session.getAttribute("_companyId")%> and d.estado = \'D\'','');
if((descAcr !='' && descAcr !='0')|| '<%=mode%>' == 'view'){if(otrasDed !=''  &&(otrasDedOld !='' && otrasDedOld !='0')||(descuentos !='' && descuentos !='0' )){ otrasDed = parseFloat(eval('document.form0.otras_ded'+k).value);if(otrasDed > 0 ||(otrasDedOld !='' && otrasDedOld !='0')||(descuentos !='' && descuentos !='0' )){if((otrasDedOld =='' || otrasDedOld =='0') &&(otrasDed !='' && otrasDed !='0'))
{alert('Guarde los cambios antes de Registrar los Ajustes a los Descuentos de Acreedores');}
else{ abrir_ventana('../rhplanilla/descuento_ajuste.jsp?fg=AJ&anio='+anio+'&codPlanilla='+codPlanilla+'&noPlanilla='+numPlanilla+'&secuencia='+secuencia+'&empId='+empId+'&mode=<%=mode%>&monto='+otrasDed+'&secuenciaTrx=<%=secuencia%>&fp=<%=fg%>&empIdTrx=<%=emp_id%>');}
}}else if((otrasDedOld =='' || otrasDedOld =='0') &&(otrasDed !='' && otrasDed !='0')){alert('Guarde los cambios antes de Registrar los Ajustes a los Descuentos de Acreedores')}else{ alert('No se ha registrado descuentos de Acreedores en este Ajuste...');}}else { alert('El Empleado no tiene descuentos de Acreedores Registrados Para Descontar...');}}
function validaDescuentos(k){
var montoDescuentos = eval('document.form0.otras_ded'+k).value;
var montoDescuentosOld = eval('document.form0.otrasDedOld'+k).value;
var descuento = eval('document.form0.descuentos'+k).value;
if(isNaN(montoDescuentos)){alert('Valor Invalido');}else{if(descuento != 0 && (parseFloat(montoDescuentos)!=parseFloat(montoDescuentosOld))){alert('Favor revisar los Descuentos De Acreedores Registrados..');}var empId = eval('document.form0.emp_id'+k).value;var descAcr =getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_descuento d','d.emp_id = '+empId+' and  d.cod_compania = <%=(String) session.getAttribute("_companyId")%> and d.estado = \'D\'','');if(descAcr !='' && descAcr !='0'){calMontoBruto();}else { alert('El Empleado no tiene descuentos de Acreedores Registrados Para Descontar...');eval('document.form0.otras_ded'+k).value=0;}}}

</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE TRANSACCIONES DE AJUSTE"></jsp:param>
	</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td>
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- =========================   F O R M   S T A R T   H E R E   ==================== -->
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("emp_id",emp_id)%>
	<%=fb.hidden("ajLastLineNo",""+ajLastLineNo)%>
	<%=fb.hidden("keySize",""+iEmp.size())%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("mb","0")%>
	<%=fb.hidden("mn","0")%>
	<%=fb.hidden("mode",""+mode)%>
    <%=fb.hidden("ssocial",desc.getColValue("seg_soc_emp"))%>
	<%=fb.hidden("ssoc_xiiim_emp",desc.getColValue("ssoc_xiiim_emp"))%>	
    <%=fb.hidden("seducativo",desc.getColValue("seg_edu_emp"))%>
    <%=fb.hidden("v_ssocial_grep",desc.getColValue("v_ssocial_grep"))%>
    <%=fb.hidden("v_porc_grep_no_ssocial",desc.getColValue("v_porc_grep_no_ssocial"))%>
    <%=fb.hidden("gr_porc_no_renta",desc.getColValue("gr_porc_no_renta"))%>
    <%=fb.hidden("secuencia",secuencia)%>
	<%=fb.hidden("fg",fg)%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>

	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>

	<tr class="TextHeader">
		<td colspan="4">&nbsp;<cellbytelabel>Registro de Ajustes</cellbytelabel></td>
	</tr>
	<tr class="TextRow01">
		<td colspan="2"><cellbytelabel>Tipo Planilla</cellbytelabel>: <%=fb.select("codPlanilla",alPla,codPlanilla,false,viewMode,0,"","Text10","onChange=\"javascript:validaCampo('US')\"")%>
			<cellbytelabel>A&ntilde;o</cellbytelabel> <%=fb.intBox("anio",anio,true,false,true,5,4,"Text12",null,null)%>
			<cellbytelabel>No</cellbytelabel>. Planilla<%=fb.intBox("noPlanilla",noPlanilla,true,false,true,5,4,"Text12",null,null)%><%=fb.button("btnper","...",true,viewMode,null,null,"onClick=\"javascript:addPla()\"","")%>
			<%=fb.textBox("numPeriodo","",false,false,true,5,2,"Text12",null,null)%></td>
			<td colspan="2"><%=fb.button("print","REPORTE",true,false,null,"","onClick=\"javascript:printAjuste('D')\"")%>
			<%=fb.button("printComp","COMPROBANTES",true,false,null,"","onClick=\"javascript:printComprobante('','')\"")%>
			</td>
	</tr>
	<tr>
    <td colspan="4">
	<table width="100%">
    <tr class="TextHeader" align="center">
		<td width="15%" ><cellbytelabel>No. Empleado</cellbytelabel></td>
    	<td width="15%" align="center"><cellbytelabel>Nombre</cellbytelabel> </td>
		<td width="15%" align="center"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
		<td width="15%" align="center"><cellbytelabel>Salario</cellbytelabel></td>
		<td width="15%" align="center">&nbsp;</td>
		<td width="20%"><cellbytelabel>Unidad</cellbytelabel></td>
 		<td width="5%"><%=fb.submit("btnagregar","+",false,viewMode)%></td>
	</tr>

  	 <%
	String codigo="0";
	if(iEmp.size()>0)al=CmnMgr.reverseRecords(iEmp);
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos=(CommonDataObject) iEmp.get(key);
		String style = (cdos.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";

		String color="";

		if(i%2 == 0) color ="TextRow02";
		else color="TextRow01";
	%>
	<%=fb.hidden("formaPago"+i,cdos.getColValue("fPago"))%>
    <%=fb.hidden("unidad_organi"+i,cdos.getColValue("unidad_organi"))%>
	<%=fb.hidden("provincia"+i,cdos.getColValue("provincia"))%>
	<%=fb.hidden("sigla"+i,cdos.getColValue("sigla"))%>
	<%=fb.hidden("tomo"+i,cdos.getColValue("tomo"))%>
	<%=fb.hidden("asiento"+i,cdos.getColValue("asiento"))%>
	<%=fb.hidden("num_empleado"+i,cdos.getColValue("num_empleado"))%>
	<%=fb.hidden("salario"+i,cdos.getColValue("salario"))%>
	<%=fb.hidden("nombre_empleado"+i,cdos.getColValue("nombre_empleado"))%>
	<%=fb.hidden("unidad"+i,cdos.getColValue("unidad"))%>
    <%=fb.hidden("descUnidad"+i,cdos.getColValue("descUnidad"))%>
	<%=fb.hidden("secuencia"+i,cdos.getColValue("secuencia"))%>
	<%=fb.hidden("emp_id"+i,cdos.getColValue("emp_id"))%>
	<%=fb.hidden("fecha_cheque"+i,cdos.getColValue("fecha_cheque"))%>
    <%=fb.hidden("cedula"+i,cdos.getColValue("cedula"))%>
	<%=fb.hidden("descuentos"+i,cdos.getColValue("descuentos"))%>
	<%=fb.hidden("otrasDedOld"+i,((cdos.getColValue("otrasDed")!=null && !cdos.getColValue("otrasDed").trim().equals(""))?cdos.getColValue("otrasDed"):"0"))%>
    <%=fb.hidden("remove"+i,"")%>
	<%=fb.hidden("action"+i,cdos.getAction())%>
	<%=fb.hidden("key"+i,cdos.getKey())%>
	<%=fb.hidden("montoDescuentosOld"+i,((cdos.getColValue("otrasDed")!=null && !cdos.getColValue("otrasDed").trim().equals(""))?cdos.getColValue("otrasDed"):"0"))%>

	<tr class="<%=color%>"<%=style%>>
			<td align="center"><%=cdos.getColValue("num_empleado")%></td>
			<td align="center"><%=cdos.getColValue("nombre_empleado")%></td>
			<td align="center"><%=cdos.getColValue("cedula")%>
			<%//=fb.button("btnper"+i,"...",true,viewMode,null,null,"onClick=\"javascript:addPla("+i+")\"","")%></td>
			<td align="center"><%=cdos.getColValue("salario")%></td>
		    <td align="center">&nbsp;</td>
			<td><%=cdos.getColValue("descUnidad")%></td>
 		<td align="center">&nbsp;
		<%//=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>
		<%=fb.submit("rem"+i,"X",false,(viewMode || !cdos.getColValue("descuentos").trim().equals("0")),"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"",(!cdos.getColValue("descuentos").trim().equals("0"))?"El Ajuste tiene descuentos registrados":"Eliminar ajuste")%></td>
	</tr>
	<tr class="TextHeader" <%=style%>>
		<td colspan="5">&nbsp;<cellbytelabel>Detalle del Ajustes</cellbytelabel></td>
		<td colspan="2">
					<%=fb.button("printComp"+i,"COMPROBANTE",true,false,null,"","onClick=\"javascript:printComprobante("+cdos.getColValue("secuencia")+","+cdos.getColValue("emp_id")+")\"")%>

		<%=fb.button("btnAjuste"+i,"Descuentos",true,(cdos.getColValue("secuencia") == null || cdos.getColValue("secuencia").trim().equals("")|| cdos.getColValue("secuencia").trim().equals("0")),"Text10", null,"onClick=\"javascript:regDescuentos("+i+");\"" )%></td>
	</tr>
	<tr class="TextRow01" <%=style%>>
	    <td> <cellbytelabel>Salario Regular</cellbytelabel></td>
		<td align="center"><%=fb.decBox("salBruto"+i,(cdos.getColValue("salBruto")!=null && !cdos.getColValue("salBruto").equals("") && !cdos.getColValue("salBruto").equals(" ")?cdos.getColValue("salBruto"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	    <td> <cellbytelabel>Otros Egresos</cellbytelabel></td>
		<td align="center"><%=fb.decBox("otrosEgr"+i,(cdos.getColValue("otrosEgr")!=null && !cdos.getColValue("otrosEgr").equals("") && !cdos.getColValue("otrosEgr").equals(" ")?cdos.getColValue("otrosEgr"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
			<td> <cellbytelabel>Prima Antiguedad</cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.decBox("prima"+i,(cdos.getColValue("prima")!=null && !cdos.getColValue("prima").equals("") && !cdos.getColValue("prima").equals(" ")?cdos.getColValue("prima"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	 </tr>
	<tr class="TextRow02" <%=style%>>
	    <td> <cellbytelabel>Ausencias</cellbytelabel></td>
		<td align="center"><%=fb.decBox("ausencia"+i,(cdos.getColValue("ausencia")!=null && !cdos.getColValue("ausencia").equals("") && !cdos.getColValue("ausencia").equals(" ")?cdos.getColValue("ausencia"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	    <td> <cellbytelabel>Gasto de Rep</cellbytelabel>.</td>
		<td align="center"><%=fb.decBox("gastoRep"+i,(cdos.getColValue("gastoRep")!=null && !cdos.getColValue("gastoRep").equals("") && !cdos.getColValue("gastoRep").equals(" ")?cdos.getColValue("gastoRep"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td> <cellbytelabel>Indemnizaci&oacute;n</cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.decBox("indemnizacion"+i,(cdos.getColValue("indemnizacion")!=null && !cdos.getColValue("indemnizacion").equals("") && !cdos.getColValue("indemnizacion").equals(" ")?cdos.getColValue("indemnizacion"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>					    </tr>
	<tr class="TextRow01" <%=style%> >
	    <td> <cellbytelabel>Tardanzas</cellbytelabel></td>
		<td align="center"><%=fb.decBox("tardanza"+i,(cdos.getColValue("tardanza")!=null && !cdos.getColValue("tardanza").equals("") && !cdos.getColValue("tardanza").equals(" ")?cdos.getColValue("tardanza"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	    <td> <cellbytelabel>Vacaciones</cellbytelabel></td>
		<td align="center"><%=fb.decBox("vacacion"+i,(cdos.getColValue("vacacion")!=null && !cdos.getColValue("vacacion").equals("") && !cdos.getColValue("vacacion").equals(" ")?cdos.getColValue("vacacion"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
			<td> <cellbytelabel>Preaviso</cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.decBox("preaviso"+i,(cdos.getColValue("preaviso")!=null && !cdos.getColValue("preaviso").equals("") && !cdos.getColValue("preaviso").equals(" ")?cdos.getColValue("preaviso"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	  </tr>
	<tr class="TextRow02"  <%=style%>>
	    <td> <cellbytelabel>Sobretiempo</cellbytelabel></td>
		<td align="center"><%=fb.decBox("extra"+i,(cdos.getColValue("extra")!=null && !cdos.getColValue("extra").equals("") && !cdos.getColValue("extra").equals(" ")?cdos.getColValue("extra"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	    <td> <cellbytelabel>XIII Mes</cellbytelabel>.</td>
		<td align="center"><%=fb.decBox("decimo"+i,(cdos.getColValue("decimo")!=null && !cdos.getColValue("decimo").equals("") && !cdos.getColValue("decimo").equals(" ")?cdos.getColValue("decimo"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
			<td> <cellbytelabel>Bonificaci&oacute;n</cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.decBox("bonificacion"+i,(cdos.getColValue("bonificacion")!=null && !cdos.getColValue("bonificacion").equals("") && !cdos.getColValue("bonificacion").equals(" ")?cdos.getColValue("bonificacion"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>					     </tr>
	<tr class="TextRow01" <%=style%>>
	    <td> <cellbytelabel>Otros Ingresos</cellbytelabel></td>
		<td align="center"><%=fb.decBox("otrosIng"+i,(cdos.getColValue("otrosIng")!=null && !cdos.getColValue("otrosIng").equals("") && !cdos.getColValue("otrosIng").equals(" ")?cdos.getColValue("otrosIng"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	    <td> <cellbytelabel>Prima de Producci&oacute;n</cellbytelabel></td>
		<td align="center"><%=fb.decBox("primaProduccion"+i,(cdos.getColValue("primaProduccion")!=null && !cdos.getColValue("primaProduccion").equals("") && !cdos.getColValue("primaProduccion").equals(" ")?cdos.getColValue("primaProduccion"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td> <cellbytelabel>Incentivo<!--40% de Salario--></cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.hidden("pago40Porc"+i,(cdos.getColValue("pago40Porc")!=null && !cdos.getColValue("pago40Porc").equals("") && !cdos.getColValue("pago40Porc").equals(" ")?cdos.getColValue("pago40Porc"):"0.00"))%>
		<%=fb.decBox("incentivo"+i,(cdos.getColValue("incentivo")!=null && !cdos.getColValue("incentivo").equals("") && !cdos.getColValue("incentivo").equals(" ")?cdos.getColValue("incentivo"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%>
		<%//=fb.decBox("pago40Porc"+i,(cdos.getColValue("pago40Porc")!=null && !cdos.getColValue("pago40Porc").equals("") && !cdos.getColValue("pago40Porc").equals(" ")?cdos.getColValue("pago40Porc"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
	</tr>
	<tr <%=style%>>
		<tr class="TextRow01" <%=style%> >
	    <td colspan="4">&nbsp;</td>
		<td > <cellbytelabel>Otras Ded. (Acreedores)</cellbytelabel></td>
		<td colspan="2" align="center"><%=fb.decBox("otras_ded"+i,((cdos.getColValue("otrasDed")!=null && !cdos.getColValue("otrasDed").trim().equals(""))?cdos.getColValue("otrasDed"):"0"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:validaDescuentos("+i+")\"")%></td>
	<tr>
	<tr class="TextRow01" <%=style%>>
	   	<td colspan="4">
	   	<table>
		<tr>
	  	 	<td><cellbytelabel>Explicaci&oacute;n del Ajuste</cellbytelabel></td>
			<td><%=fb.textarea("explicacion"+i,cdos.getColValue("explicacion"),false,false,viewMode,50,3,"Text12",null,null)%></td>
		</tr>
		</table>
		</td>

    	<td colspan="3">&nbsp;
	   	<table>
	 	<tr>
	   	  	<td width="45%"><cellbytelabel>Reportar a Contabilidad</cellbytelabel>: &nbsp;</td>
	   		<td width="55%"><cellbytelabel>A&ntilde;o</cellbytelabel>: <%=fb.intBox("regAnio"+i,cdos.getColValue("regAnio"),false,false,true,4,4,"Text12",null,null)%> &nbsp; <cellbytelabel>Periodo</cellbytelabel>: &nbsp;<%=fb.intBox("regPeriodo"+i,cdos.getColValue("regPeriodo"),false,false,true,3,2,"Text12",null,null)%></td>
		</tr>

		<tr>
	 	 	<td><cellbytelabel>Forma de Pago</cellbytelabel></td>
	   		<td><cellbytelabel>Cheque</cellbytelabel><%=fb.radio("fPago"+i,"1",((cdos.getColValue("fPago")!=null && (cdos.getColValue("fPago").equals("") || cdos.getColValue("fPago").equals("1")))?true:false),true,false).replaceAll(" id=\"fPago\"","")%><cellbytelabel>Ach</cellbytelabel><%=fb.radio("fPago"+i,"2",((cdos.getColValue("fPago")!=null && cdos.getColValue("fPago").equals("2"))?true:false),true,true).replaceAll(" id=\"fPago\"","")%></td>
		</tr>

        <tr>
		 	<td><cellbytelabel>No.Cheque/Talonario</cellbytelabel>:</td>
           	<td>&nbsp;<%=fb.textBox("numCheque"+i,cdos.getColValue("numCheque"),false,false,true,5,11,"Text12",null,null)%></td>
		</tr>
	</table>
		</td>
	 </tr>
<tr <%=style%>>
  <td colspan="7">
	<table width="100%">
	<tr class="TextRow01" >
				    &nbsp;&nbsp;&nbsp;
	</tr>
	<tr class="TextRow02" align="center">
		<td align="center"><cellbytelabel>Salario Bruto</cellbytelabel> </td>
		<td align="center"><cellbytelabel>Seg. Social</cellbytelabel> </td>
		<td align="center"><cellbytelabel>Seg. Social Gasto</cellbytelabel></td>
		<td align="center"><cellbytelabel>Seg. Educativo</cellbytelabel></td>
		<td align="center"><cellbytelabel>Imp. Renta</cellbytelabel></td>
		<td align="center"><cellbytelabel>Imp. Renta Gasto Rep</cellbytelabel></td>
		<td><cellbytelabel>Total Ded</cellbytelabel>.</td>
 		<td><cellbytelabel>Monto Neto</cellbytelabel>.</td>
		<td><cellbytelabel>Periodos Trab</cellbytelabel>.</td>
	</tr>
	<tr class="TextRow01"  >
	    <td align="center"><%=fb.decBox("totBruto"+i,cdos.getColValue("totBruto"),false,false,true,8,10.2,"Text12",null,null)%></td>
		<td align="center"><%=fb.decBox("segSocial"+i,(cdos.getColValue("segSocial")!=null && !cdos.getColValue("segSocial").equals("") && !cdos.getColValue("segSocial").equals(" ")?cdos.getColValue("segSocial"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td align="center"><%=fb.decBox("segSocialGasto"+i,(cdos.getColValue("segSocialGasto")!=null && !cdos.getColValue("segSocialGasto").equals("") && !cdos.getColValue("segSocialGasto").equals(" ")?cdos.getColValue("segSocialGasto"):"0.00"),false,false,true,8,10.2,null,null,"")%></td>
	    <td align="center"><%=fb.decBox("segEducativo"+i,(cdos.getColValue("segEducativo")!=null && !cdos.getColValue("segEducativo").equals("") && !cdos.getColValue("segEducativo").equals(" ")?cdos.getColValue("segEducativo"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td align="center"><%=fb.decBox("impRenta"+i,(cdos.getColValue("impRenta")!=null && !cdos.getColValue("impRenta").equals("") && !cdos.getColValue("impRenta").equals(" ")?cdos.getColValue("impRenta"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td align="center"><%=fb.decBox("impRentaGasto"+i,(cdos.getColValue("impRentaGasto")!=null && !cdos.getColValue("impRentaGasto").equals("") && !cdos.getColValue("impRentaGasto").equals(" ")?cdos.getColValue("impRentaGasto"):"0.00"),false,false,true,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td align="center"><%=fb.decBox("totalDed"+i,(cdos.getColValue("totalDed")!=null && !cdos.getColValue("totalDed").equals("") && !cdos.getColValue("totalDed").equals(" ")?cdos.getColValue("totalDed"):"0.00"),false,false,viewMode,8,10.2,null,null,"onChange=\"javascript:calMontoBruto()\"")%></td>
		<td  align="center"><%=fb.decBox("salNeto"+i,(cdos.getColValue("salNeto")!=null && !cdos.getColValue("salNeto").equals("") && !cdos.getColValue("salNeto").equals(" ")?cdos.getColValue("salNeto"):"0.00"),false,false,true,8,10.2,"Text12",null,null)%></td>
		<td  align="center"><%=fb.textBox("periodo"+i,cdos.getColValue("periodo"),false,false,viewMode,3,2,"Text12",null,null)%></td>
    <tr>
	<tr class="TextHeader">
		<td colspan="9">&nbsp;</td>
	</tr>
	</table>
  </td>
</tr>


	<%  } %>
	</table>
 </td>
 </tr>
 	 <% fb.appendJsValidation("if(error>0)doAction();"); %>
	<tr class="TextRow02">
        <td align="right" colspan="4"> <cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
		<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
		<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
    </tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
		 <%=fb.formEnd(true)%>
<!-- ========================   F O R M   E N D   H E R E  ========================= -->
	</table>
	<!-- TAB0 DIV END HERE-->

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
ajLastLineNo= Integer.parseInt(request.getParameter("ajLastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";

  noPlanilla =request.getParameter("noPlanilla");
  codPlanilla =request.getParameter("codPlanilla");
  anio =request.getParameter("anio");
  iEmp.clear();
  vEmp.clear();

for(int a=0; a<keySize; a++)
{
 CommonDataObject cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_pago_ajuste");
  cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id"+a)+" and num_empleado="+request.getParameter("num_empleado"+a)+" and anio="+anio+" and cod_planilla="+codPlanilla+" and num_planilla="+noPlanilla+" and secuencia="+request.getParameter("secuencia"+a)+"  and estado in('PE')  and acc_estado = 'N' ");


  cdo.addColValue("emp_id",request.getParameter("emp_id"+a));
  cdo.addColValue("provincia",request.getParameter("provincia"+a));
  cdo.addColValue("sigla",request.getParameter("sigla"+a));
  cdo.addColValue("tomo",request.getParameter("tomo"+a));
  cdo.addColValue("asiento",request.getParameter("asiento"+a));
  cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("anio",request.getParameter("anio"));
  cdo.addColValue("cod_planilla", request.getParameter("codPlanilla"));
  cdo.addColValue("codPlanilla", request.getParameter("codPlanilla"));
  cdo.addColValue("num_planilla",request.getParameter("noPlanilla"));
  cdo.addColValue("noPlanilla",request.getParameter("noPlanilla"));
  cdo.addColValue("nombre_empleado",request.getParameter("nombre_empleado"+a));
  cdo.addColValue("salario",request.getParameter("salario"+a));
  cdo.addColValue("unidad",request.getParameter("unidad"+a));
  cdo.addColValue("descUnidad",request.getParameter("descUnidad"+a));

	cdo.addColValue("periodo", request.getParameter("periodo"+a));
	cdo.addColValue("num_periodo", request.getParameter("numPeriodo"));
	cdo.addColValue("numPeriodo", request.getParameter("numPeriodo"));
	cdo.addColValue("fecha_cheque", request.getParameter("fecha_cheque"+a));
	cdo.addColValue("sal_bruto",request.getParameter("salBruto"+a));
	cdo.addColValue("salBruto",request.getParameter("salBruto"+a));
	cdo.addColValue("ausencia", request.getParameter("ausencia"+a));
	cdo.addColValue("tardanza", request.getParameter("tardanza"+a));
	cdo.addColValue("extra", request.getParameter("extra"+a));
	cdo.addColValue("otros_ing", request.getParameter("otrosIng"+a));
	cdo.addColValue("otrosIng", request.getParameter("otrosIng"+a));
	cdo.addColValue("otros_egr", request.getParameter("otrosEgr"+a));
	cdo.addColValue("otrosEgr", request.getParameter("otrosEgr"+a));
	cdo.addColValue("gasto_rep", request.getParameter("gastoRep"+a));
	cdo.addColValue("gastoRep", request.getParameter("gastoRep"+a));
	cdo.addColValue("vacacion", request.getParameter("vacacion"+a));

	cdo.addColValue("xiii_mes", request.getParameter("decimo"+a));
	cdo.addColValue("decimo", request.getParameter("decimo"+a));
	cdo.addColValue("prima_produccion",request.getParameter("primaProduccion"+a));
	cdo.addColValue("primaProduccion",request.getParameter("primaProduccion"+a));
	cdo.addColValue("prima_antiguedad", request.getParameter("prima"+a));
	cdo.addColValue("prima", request.getParameter("prima"+a));
	cdo.addColValue("indemnizacion", request.getParameter("indemnizacion"+a));
	cdo.addColValue("preaviso", request.getParameter("preaviso"+a));
	cdo.addColValue("bonificacion", request.getParameter("bonificacion"+a));
	cdo.addColValue("pago_40porc", request.getParameter("pago40Porc"+a));
	cdo.addColValue("pago40Porc", request.getParameter("pago40Porc"+a));
	cdo.addColValue("explicacion", request.getParameter("explicacion"+a));
	cdo.addColValue("reg_periodo", request.getParameter("regPeriodo"+a));
	cdo.addColValue("regPeriodo", request.getParameter("regPeriodo"+a));
	cdo.addColValue("reg_anio", request.getParameter("regAnio"+a));
	cdo.addColValue("regAnio", request.getParameter("regAnio"+a));
	//cdo.addColValue("forma_pago", request.getParameter("fPago"+a));

	//cdo.addColValue("fPago", request.getParameter("fPago"+a));
	cdo.addColValue("num_cheque", request.getParameter("numCheque"+a));
	cdo.addColValue("numCheque", request.getParameter("numCheque"+a));
	cdo.addColValue("num_empleado", request.getParameter("num_empleado"+a));
	cdo.addColValue("unidad_organi", request.getParameter("unidad_organi"+a));
	cdo.addColValue("seg_social",request.getParameter("segSocial"+a));
	cdo.addColValue("segSocial",request.getParameter("segSocial"+a));
	cdo.addColValue("seg_educativo", request.getParameter("segEducativo"+a));
	cdo.addColValue("segEducativo", request.getParameter("segEducativo"+a));
	cdo.addColValue("imp_renta", request.getParameter("impRenta"+a));
	cdo.addColValue("impRenta", request.getParameter("impRenta"+a));
	cdo.addColValue("imp_renta_gasto", request.getParameter("impRentaGasto"+a));
	cdo.addColValue("impRentaGasto", request.getParameter("impRentaGasto"+a));
	cdo.addColValue("total_ded", request.getParameter("totalDed"+a));
	cdo.addColValue("totalDed", request.getParameter("totalDed"+a));
	cdo.addColValue("sal_neto", request.getParameter("salNeto"+a));
	cdo.addColValue("salNeto", request.getParameter("salNeto"+a));
	cdo.addColValue("estado","PE");
	//cdo.addColValue("dev_multa", request.getParameter("devMulta"+a));
	cdo.addColValue("otras_ded", request.getParameter("otras_ded"+a));
	//cdo.addColValue("comision", request.getParameter("comision"+a));
	//cdo.addColValue("ayuda_mortuoria", request.getParameter("ayudaMortuoria"+a));
	//cdo.addColValue("otros_ing_fijos",request.getParameter("otrosFijos"+a));
	//cdo.addColValue("alto_riesgo", request.getParameter("altoRiesgo"+a));
	cdo.addColValue("incentivo", request.getParameter("incentivo"+a));
	cdo.addColValue("descuentos",request.getParameter("descuentos"+a));
	cdo.addColValue("seg_social_gasto",request.getParameter("segSocialGasto"+a));
	cdo.addColValue("segSocialGasto",request.getParameter("segSocialGasto"+a));
	cdo.addColValue("cedula",request.getParameter("cedula"+a));


  cdo.addColValue("secuencia",request.getParameter("secuencia"+a));
  cdo.setAutoIncWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("emp_id"+a) );
  cdo.setAutoIncCol("secuencia");

  cdo.setKey(a);
  cdo.setAction(request.getParameter("action"+a));

    if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{
		itemRemoved = cdo.getColValue("emp_id");
		if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
		else cdo.setAction("D");
	}

	if (!cdo.getAction().equalsIgnoreCase("X"))
	{
		try
		{
			iEmp.put(cdo.getKey(),cdo);
			vEmp.add(cdo.getColValue("emp_id"));
			list.add(cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
 }//End For

if(!itemRemoved.equals(""))
{
//iEmp.remove(key);
//vEmp.remove(emp_id);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&emp_id="+emp_id+"&ajLastLineNo="+ajLastLineNo+"&mode="+mode+"&anio="+anio+"&noPlanilla="+noPlanilla+"&codPlanilla="+codPlanilla+"&secuencia="+secuencia+"&fg="+fg);
//response.sendRedirect("../rhplanilla/descuento_config.jsp?change=1&ajLastLineNo="+ajLastLineNo+"&emp_id="+emp_id);
return;
}

if(request.getParameter("btnagregar")!=null)
{
 response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&emp_id="+emp_id+"&ajLastLineNo="+ajLastLineNo+"&mode="+mode+"&anio="+anio+"&noPlanilla="+noPlanilla+"&codPlanilla="+codPlanilla+"&secuencia="+secuencia+"&fg="+fg);
 return;
}
if(list.size()==0){
CommonDataObject cdo1 = new CommonDataObject();
cdo1.setTableName("tbl_pla_pago_ajuste");
cdo1.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+emp_id+" and anio="+anio+" and cod_planilla="+codPlanilla+" and num_planilla="+noPlanilla+" and secuencia=-1");
cdo1.setKey(iEmp.size() + 1);
cdo1.setAction("I");
list.add(cdo1);
}
ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 SQLMgr.saveList(list,true);
ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_planilla_ajustes.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_planilla_ajustes.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_planilla_ajustes.jsp';
<%
		}
	//}
	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?emp_id=<%=emp_id%>&mode=edit&anio=<%=anio%>&noPlanilla=<%=noPlanilla%>&codPlanilla=<%=codPlanilla%>&secuencia=<%=secuencia%>&fg=<%=fg%>';
}
</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
