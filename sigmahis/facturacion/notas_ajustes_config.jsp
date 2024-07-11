<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.facturacion.NotasAjustes"%>
<%@ page import="issi.facturacion.NotasAjustesDet"%>
<%@ page import="java.util.StringTokenizer"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNotas" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NotasAjustes ajuste = new NotasAjustes();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
CommonDataObject cdoParam = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania");
String caja = request.getParameter("caja");
String banco = request.getParameter("banco");
String codigo = request.getParameter("codigo");
String cuenta = request.getParameter("cuenta");
String fp = request.getParameter("fp");
String change = request.getParameter("change");
String fact = request.getParameter("factura");
String cod = request.getParameter("cod");
String fg = request.getParameter("fg");
String recibo = request.getParameter("recibo");
String ref_id = request.getParameter("ref_id");
String ref_type = request.getParameter("ref_type");
String isAjusteAut = request.getParameter("isAjusteAut")==null?"":request.getParameter("isAjusteAut");
String sqlStatus ="";
String pValidaSaldo ="N";

boolean viewMode = false;
boolean flag = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int notasLastLineNo =0;
if (mode == null) mode = "add";
if (fp == null) fp = "deposito";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (compania == null) compania = (String) session.getAttribute("_companyId");
if (cod == null) cod = "";
if (fg == null) fg = "";
if (ref_type == null) ref_type = "";
if (ref_id == null) ref_id = "";
String  docAjFisico= "N";
try {docAjFisico =java.util.ResourceBundle.getBundle("issi").getString("docAjFisico");}catch(Exception e){ docAjFisico = "N";}

if (fact == null || fact.trim().equals("null")) fact = "";
cod = cod.replace("~",",");
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");sbSql.append(session.getAttribute("_companyId"));sbSql.append(",'FACT_AJ_VALIDA_SALDO'),'N') as pValidaSaldo from dual");
	cdoParam = SQLMgr.getData(sbSql);
	if(cdoParam!=null && !cdoParam.getColValue("pValidaSaldo").equals("")) pValidaSaldo = cdoParam.getColValue("pValidaSaldo");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	StringTokenizer st = new StringTokenizer(cod,",");
		while (st.hasMoreTokens()){
			if(flag && (codigo==null || codigo.equals(""))){
				codigo = st.nextToken();
			} else break;
		}

if (mode.equalsIgnoreCase("add"))
	{
		iNotas.clear();
		vNotas.clear();
		codigo = "0";
		ajuste = new NotasAjustes();
		ajuste.setFecha(cDateTime.substring(0,10));
		ajuste.setFechaCreacion(cDateTime);
		ajuste.setUsuarioCreacion((String) session.getAttribute("_userName"));
		ajuste.setCtrlAjuste("N");
		ajuste.setFactura("");
		//if(docAjFisico.trim().equals("N")&&!fg.trim().equals("AR"))ajuste.setReferencia("0");
		if (!viewMode) mode = "add";
		sqlStatus = "O=ABIERTO";
		if(fg.equals("AF")) ajuste.setFactura(fact);
		
		sbSql = new StringBuffer();
		if (isAjusteAut.equals("Y") && !viewMode){
		  
		  sbSql = new StringBuffer();

		  sbSql.append("select nvl(z.codigo_cs, ' ') descCentro, nvl(z.descripcion_cs, ' ') descAjusteDet, nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.credit,0) monto_total , nvl(z.monto,0) monto_fact, nvl(z.debit,0) debit, nvl(z.pagos,0) pagos, nvl(z.credit,0) credit, nvl(z.descuento,0) descuentos, nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)-nvl(z.descuento,0) monto, 0 as secuencia ,'N' farhosp,nvl(z.tipo,'') as tipo,decode(z.tipo,'C',z.codigo_cs,'H',0,'E',0,'M',z.codigo_cs,'P',z.codigo_cs)centro, decode(z.tipo,'H',to_char(z.codigo_cs),null) medico ,decode(z.tipo,'E',to_number(z.codigo_cs),null) empresa,'N' pagado from ( select getcoddetecf_new (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) codigo_cs, getdescdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) descripcion_cs, f.monto,  getdebitdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) debit,  getpagosdetecf (f.pac_id,f.compania,f.admi_secuencia,f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.cod_empresa) pagos, getcreditdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) credit, f.descuento, f.saldo,f.tipo from ( select f.pac_id, f.codigo, f.fecha, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.cod_empresa, f.usuario_creacion, d.tipo, d.med_empresa, d.medico, d.centro_servicio, sum(nvl(d.monto, 0) + nvl(d.descuento, 0)+ nvl (d.descuento2, 0) /* -- se comenta por que en consulta general y factura este monto sale diferente . Se agrego filtro por fecha para tomar los que son mayores a junio*/ /* - nvl((select sum(nvl(df.monto,0)) from tbl_fac_factura ff, tbl_fac_detalle_factura df where ff.codigo = df.fac_codigo and ff.compania = df.compania and ff.pac_id = f.pac_id and ff.admi_secuencia = f.admi_secuencia and ff.facturar_a = 'P' and ff.estatus = 'P' and f.codigo != ff.codigo and substr(df.descripcion, 10, length(df.descripcion)-9) = cds.descripcion and df.tipo_cobertura = 'CO' and trunc(ff.fecha) >= to_date('01/10/2011','dd/mm/yyyy')), 0) */ -decode(f.nueva_formula,'S',0,decode(f.tipo_cobertura,'S',0,nvl(getCopagoDet(f.compania,f.codigo,nvl(to_char(d.med_empresa),d.medico),cds.descripcion,f.pac_id,f.admi_secuencia,null ),0)))) monto, sum (nvl (d.monto, 0)) saldo, sum (nvl (d.descuento, 0) + nvl (d.descuento2, 0)) descuento, f.facturar_a, f.estatus, f.compania, f.cuenta_i from tbl_fac_factura f, tbl_fac_detalle_factura d, tbl_cds_centro_servicio cds where f.codigo = '");
		 
		 sbSql.append(fact);
		 sbSql.append("' and f.compania = ");
		 sbSql.append(compania);
		 sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and d.imprimir_sino='S' and (d.centro_servicio = cds.codigo(+)) group by f.nueva_formula,f.pac_id,f.codigo,f.fecha,f.admi_fecha_nacimiento,f.admi_codigo_paciente,f.admi_secuencia,f.cod_empresa,f.usuario_creacion,d.tipo, d.med_empresa,d.medico,d.centro_servicio,f.facturar_a,f.estatus,f.compania,f.cuenta_i order by d.centro_servicio asc ) f  ");

		sbSql.append(" union all ");

		sbSql.append(" select to_char(a.centro) codigo_cs,decode(a.tipo,'C',(select descripcion from tbl_cds_centro_servicio where codigo=a.centro),'P','COPAGO','M','PERDIEM') descripcion_cs,0 monto, a.debit, nvl (a.pagos, 0) pagos, a.credit, 0 descuento, (a.debit - nvl (a.pagos, 0) - a.credit) saldo,a.tipo from (select   f.codigo, n.centro, nvl(sum (nvl (decode (n.lado_mov, 'D', n.monto), 0)),0) debit, nvl(sum (nvl (decode (n.lado_mov, 'C', n.monto), 0)),0) credit,n.tipo ,getPagosCNF(f.codigo,n.centro,f.compania,n.tipo) pagos    from tbl_fac_factura f, vw_con_adjustment_gral n where  f.compania = n.compania and f.compania =");
		sbSql.append(compania);
		sbSql.append(" and f.codigo = n.factura and f.codigo = '");
		sbSql.append(fact);
		sbSql.append("' and nvl(n.centro,-1) <> 0 and n.monto <> 0 and nvl(n.centro,-1) not in (select distinct nvl (b.centro_servicio,-1) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania = ");
		sbSql.append(compania);
		sbSql.append(" and a.codigo = b.fac_codigo and a.codigo ='");
		sbSql.append(fact);
		sbSql.append("' and nvl(b.centro_servicio,-1) <> 0 and b.imprimir_sino='S') group by f.codigo, n.centro,n.tipo,f.compania ) a "); 

		sbSql.append(" union all ");

		sbSql.append(" select coalesce (a.cod_medico, to_char (a.cod_empresa), ' ') codigo_cs, coalesce (b.nombre_medico, c.nombre_empresa, ' ') descripcion_cs, 0 monto, a.debit, nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
		
		sbSql.append(compania);
		sbSql.append("), 0) pagos, a.credit, 0 descuentos, (a.debit - nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
		sbSql.append(compania);
		sbSql.append("), 0) - a.credit) saldo,a.tipo from (select distinct f.codigo, nvl (n.centro, 0) centro_servicio, nvl(sum (decode (n.lado_mov, 'D', n.monto)),0) debit, nvl(sum (decode (n.lado_mov, 'C', n.monto)),0) credit, n.empresa cod_empresa, n.medico cod_medico,n.tipo from tbl_fac_factura f, vw_con_adjustment_gral n where f.compania = n.compania and f.compania = ");
		sbSql.append(compania);
		sbSql.append(" and f.codigo = n.factura and f.codigo = '");
		sbSql.append(fact);
		sbSql.append("' and n.monto <> 0 and (n.centro = 0) and ((n.medico not in (select distinct nvl (b.medico, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
		sbSql.append(compania);
		sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
		sbSql.append(fact);
		sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and b.imprimir_sino='S' and (b.medico is not null or b.med_empresa is not null))) or (n.empresa not in (select distinct nvl (b.med_empresa, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
		sbSql.append(compania);
		sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
		sbSql.append(fact);
		sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and b.imprimir_sino='S' and (b.medico is not null or b.med_empresa is not null)))) group by n.tipo,f.codigo, n.centro, n.empresa, n.medico) a,    (select codigo, primer_nombre || ' '|| segundo_nombre|| ' '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada nombre_medico from tbl_adm_medico) b, (select codigo, nombre nombre_empresa from tbl_adm_empresa) c where a.cod_medico = b.codigo(+) and a.cod_empresa = c.codigo(+) ) z where nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)-nvl(z.descuento,0) > 0 order by lpad(z.codigo_cs,5,'0') ");
		  
		  al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),NotasAjustesDet.class);
		  notasLastLineNo = al.size();
		  for (int i=0; i<al.size(); i++){
			NotasAjustesDet dp = (NotasAjustesDet) al.get(i);
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			iNotas.put(key,dp);
		  }
		  
		  System.out.println(":::::::::::::::::::::::::: "+sbSql.toString());

	   }
	
	}
	else
	{
			//if (codigo == null) throw new Exception("El codigo de la nota de ajuste no es válido. Por favor intente nuevamente!");

sql="select a.compania, a.codigo, a.explicacion,to_char(a.fecha,'dd/mm/yyyy')as fecha, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion,to_char(a.fecha_creacion,'dd/mm/yyyy  hh12:mi:ss am')as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy')as fechaModificacion, a.tipo_doc as tipoDoc,a.factura, a.tipo_ajuste as tipoAjuste, nvl(a.recibo,'') as recibo,a.factura_aplic as facturaAplic, a.total, a.estatus,NVL(a.referencia,'') as referencia, a.act_sn as actSn, nvl(a.ctrl_ajuste,'N') as ctrlAjuste,a.pase, a.pase_k as paseK,a.ref_reversion as refReversion, a.provincia, a.sigla, a.tomo,a.asiento, a.anio_parametro as anioParametro,a.mes_parametro as mesParametro, b.descripcion as descAjuste, a.tipo_docto tipoDocto from tbl_fac_nota_ajuste a, tbl_fac_tipo_ajuste b where a.codigo="+codigo+" and a.tipo_ajuste = b.codigo and b.compania = a.compania and a.compania="+compania;

//cdo = SQLMgr.getData(sql);

System.out.println("SQL:\n"+sql);
ajuste = (NotasAjustes) sbb.getSingleRowBean(ConMgr.getConnection(), sql, NotasAjustes.class);
if(change==null)
{
iNotas.clear();
vNotas.clear();
sql="select decode(a.tipo,'C',to_char(a.centro),'E',to_char(a.empresa),'H',a.medico)as descCentro,a.nota_ajuste, a.compania, a.secuencia, a.descripcion, a.monto, a.tipo,a.lado_mov as ladoMov, a.centro, a.empresa, a.medico, a.factura, a.cod_banco as codBanco,decode(a.tipo,'C',c.descripcion,'E',e.nombre,'H',m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||' '||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA))descAjusteDet, a.cuenta_banco as cuentaBanco, nvl(a.pagado,'N')as pagado, a.monto_saldo as montoSaldo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy')as fechaCreacion,to_char(a.fecha_modificacion,'dd/mm/yyyy')as fechaModificacion, a.num_cheque numCheque, paciente, a.amision, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.cliente_emp as clienteEmp,nvl(a.farhosp,'N')farhosp, a.afecta, a.pase,a.pase_k as paseK, a.puntos_sino as puntosSino, a.fact_clinica as factClinica,a.pac_id from tbl_fac_det_nota_ajuste a,tbl_adm_medico m,tbl_cds_centro_servicio c ,tbl_adm_empresa e where nota_ajuste="+codigo+" and a.medico = m.codigo(+) and a.centro=c.codigo(+) and a.empresa= e.codigo(+) and a.compania="+compania;

System.out.println("SQL:\n"+sql);

		al = sbb.getBeanList(ConMgr.getConnection(),sql,NotasAjustesDet.class);
		notasLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			NotasAjustesDet notas = (NotasAjustesDet) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			notas.setKey(key);

			try
			{
				iNotas.put(notas.getKey(), notas);
				if(notas.getCentro()!=null && !notas.getCentro().trim().equals(""))
					vNotas.add(notas.getCentro());
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i

	}//if change
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Notas de Ajustes- '+document.title;
function Recibos(){var pase=""; if(document.form0.ctrlajuste.checked)pase= "S"; else pase = "N";abrir_ventana2('../facturacion/recibos_list.jsp?recibo=<%=recibo%>&pase='+pase);}
function doAction(){<%if(recibo != null && !recibo.trim().equals("")){%>Recibos();<%}%>}
function showAjuste(){var tipoDoc = document.form0.tipo_doc.value;if(tipoDoc =='')CBMSG.warning('Seleccione Tipo De Documento!!');else abrir_ventana('../facturacion/tipo_ajustes_list.jsp?fp=<%=fp%>&tipoDoc='+tipoDoc);}
function saveMethod(){var tipoDoc = document.form0.tipo_doc.value;var factura = document.form0.factura.value; window.frames['itemFrame'].getTotMonto();var saldo =-1.0;var validaSaldo = 'N';var tipoDocto='';var total =document.form0.total.value;if(total!='')total =parseFloat(document.form0.total.value);var codigoAj =eval('document.form0.tipo_ajuste').value;var grupo = getDBData('<%=request.getContextPath()%>','group_type ','tbl_fac_tipo_ajuste','codigo=\''+codigoAj+'\' and compania=<%=(String) session.getAttribute("_companyId")%>');if(document.form0.tipo_docto)tipoDocto =document.form0.tipo_docto.value;if(tipoDocto=='C'&&tipoDoc=='F' && grupo !='E')validaSaldo='S';
<%if(pValidaSaldo.trim().equals("S")){%>if(validaSaldo=='S'){checkPagos();saldo = parseFloat(getDBData('<%=request.getContextPath()%>','nvl(fn_cja_saldo_fact(null,<%=(String) session.getAttribute("_companyId")%>, \'<%=fact%>\',null),0)','dual',''));}if((tipoDocto=='D' ||((tipoDocto=='C' && saldo >= total ))||tipoDoc=='R') || grupo=='E'  ){if (form0Validation()){if(window.frames['itemFrame'].CheckMonto()){document.form0.baction.value = "Guardar";window.frames['itemFrame'].doSubmit();}else window.frames['itemFrame'].BtnAct();}}else CBMSG.warning('Esta factura no tiene Saldo para aplicar nota de Credito! saldo = '+saldo);<%}else{%>if (form0Validation()){if(window.frames['itemFrame'].CheckMonto()){document.form0.baction.value = "Guardar";window.frames['itemFrame'].doSubmit();}else window.frames['itemFrame'].BtnAct();}<%}%>}
function checkReferencia(obj){<%if (!mode.equalsIgnoreCase("view")){%>if(eval('document.form0.tipo_ajuste').value != "1"){var com = '<%=compania%>';if(!isNaN(obj.value)){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_fac_nota_ajuste','referencia=\''+obj.value+'\' and compania='+com+' and referencia <> 99','<%=ajuste.getReferencia().trim()%>')}else CBMSG.warning('Valor Invalido, Solo es permitido valores Numericos!!');}<%}%>}
function showComprobante(){<%if (!mode.equalsIgnoreCase("add")){%>abrir_ventana1('../facturacion/print_nota_ajuste.jsp?compania=<%=compania%>&codigo=<%=codigo%>');<%}else{%>CBMSG.warning('Guarde la nota de ajuste para Generar el Comprobante');<%}%>}
function clearAjuste()
{ document.form0.tipo_ajuste.value ='';document.form0.name_ajuste.value ='';}
function changeCod(codigo){var cod = document.form0.cod.value;	window.location = '../facturacion/notas_ajustes_config.jsp?mode=view&fp=cons_recibo_ajuste&fg=<%=fg%>&codigo='+codigo+'&cod='+cod;}
function selFacturas(){abrir_ventana2('../facturacion/facturas_ajuste_list.jsp?fp=notasEnc');}

function checkPagos(){ <%if(fg.equals("AF")){%>var pagos = getDBData('<%=request.getContextPath()%>','chkPagoFact(<%=(String) session.getAttribute("_companyId")%>,  \'<%=fact%>\')','dual','');if(pagos=='S') CBMSG.warning('Esta factura tiene pagos aplicados, Favor Verifique los centros que tienen Distribuciones!');<%}%>}
function checkEstado(){var fecha = document.form0.fecha.value;var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form0.fecha.value='';return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="NOTAS DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("usuario_creacion",ajuste.getUsuarioCreacion())%>
			<%=fb.hidden("fecha_creacion",ajuste.getFechaCreacion())%>
			<%=fb.hidden("pase",ajuste.getPase())%>
			<%=fb.hidden("pase_k",ajuste.getPaseK())%>
			<%=fb.hidden("act_sn",ajuste.getActSn())%>
			<%=fb.hidden("ref_reversion",ajuste.getRefReversion())%>
			<%=fb.hidden("provincia",ajuste.getProvincia())%>
			<%=fb.hidden("sigla",ajuste.getSigla())%>
			<%=fb.hidden("tomo",ajuste.getTomo())%>
			<%=fb.hidden("asiento",ajuste.getAsiento())%>
			<%=fb.hidden("anio_parametro",ajuste.getAnioParametro())%>
			<%=fb.hidden("mes_parametro",ajuste.getMesParametro())%>
			<%//=fb.hidden("factura",ajuste.getFactura())%>
			<%=fb.hidden("factura_aplic",ajuste.getFacturaAplic())%>
	 		<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("compania",compania)%>
			<%=fb.hidden("totalRecibo",ajuste.getTotal())%>
    		<%=fb.hidden("fecha_nacimiento","")%>
			<%=fb.hidden("pac_id","")%>
			<%=fb.hidden("codigo_paciente","")%>
			<%=fb.hidden("cod",cod)%>
			<%=fb.hidden("ref_type",ref_type)%>
			<%=fb.hidden("ref_id",ref_id)%>
			<%=fb.hidden("isAjusteAut",isAjusteAut)%>

				<tr class="TextHeader">
							<td colspan="4">Notas de Ajustes</td>
				</tr>
				<tr class="TextRow01">
				<td><cellbytelabel>Tipo Doc</cellbytelabel>:</td>
					<td><%=fb.select("tipo_doc",(mode.trim().equals("view"))?"F = FACTURA,R = RECIBO":((fg.equals("AF")?"F = FACTURA":"R = RECIBO")),ajuste.getTipoDoc(),false,viewMode,0,"",null,"onChange=\"javascript:clearAjuste()\"")%></td>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="20%"><cellbytelabel>Tipo de Ajustes</cellbytelabel></td>
					<td>
  				
					
					<%if(isAjusteAut.equals("Y")){%>
					<%=fb.select(ConMgr.getConnection(),"select fta.codigo as codigo,fta.descripcion as descripcion,decode(fta.tipo_doc,'R','RECIBO','FACTURA')||' - '||(select description from tbl_fac_adjustment_group where id = fta.group_type and status ='A')descGrupo from tbl_fac_tipo_ajuste fta where fta.compania = "+compania+" and fta.group_type not in('A','H','D','E','O')  and fta.estatus ='A' and fta.tipo_doc ='F' order by fta.group_type,fta.descripcion ","tipo_ajuste",ajuste.getTipoAjuste(),true,false,viewMode,0,"Text10","",null,null,"")%>
					
					<%}else{%>
					  <%=fb.textBox("tipo_ajuste",ajuste.getTipoAjuste(),true,false,true,10)%>
					  <%=fb.textBox("name_ajuste",ajuste.getDescAjuste(),false,false,true,30)%>
					  <%=fb.button("addAjuste","...",(!viewMode),viewMode,null,null,"onClick=\"javascript:showAjuste()\"","Agregar Ajuste")%>
					<%}%>
					<%String checkEstado = "javascript:checkEstado();newHeight();";%>
					</td>
					<td><cellbytelabel>Fecha</cellbytelabel>:
						<jsp:include page="../common/calendar.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1" />
                        <jsp:param name="nameOfTBox1" value="fecha" />
                        <jsp:param name="valueOfTBox1" value="<%=ajuste.getFecha()%>" />
                        <jsp:param name="fieldClass" value="text10" />
                        <jsp:param name="buttonClass" value="text10" />
						<jsp:param name="jsEvent" value="<%=checkEstado%>" />
                        <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                        </jsp:include>

					<%//=fb.textBox("fecha",ajuste.getFecha(),false,false,true,8,12)%></td>
					<td>Ajuste #: <%if(fp.equalsIgnoreCase("cons_recibo_ajuste")){%>
					<%=fb.select("codigo",cod,codigo,false,false,0,"",null,"onChange=\"javascript:changeCod(this.value);\"")%>
					<%} else {%>
					<%=fb.textBox("codigo",codigo,false,false,true,10)%>
					<%}%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Documento</cellbytelabel> # :</td>
					<td><%=fb.intBox("referencia",(ajuste.getReferencia()!=null && !ajuste.getReferencia().trim().equals(""))?ajuste.getReferencia():"",((docAjFisico.trim().equals("N")&&!fg.trim().equals("AR")))?false:true,false,((docAjFisico.trim().equals("N")&&!fg.trim().equals("AR"))||viewMode),10,10,null,null,"onBlur=\"javascript:checkReferencia(this)\"")%></td>
					<td><cellbytelabel>Estatus</cellbytelabel> <%=fb.select("estatus","P = PENDIENTE"+((viewMode)?",A=APROBADO,R=RECHAZADO":""),ajuste.getEstatus(),false,viewMode,0,"",null,"")%></td>
					<td><cellbytelabel>Factura</cellbytelabel>:<%=fb.textBox("factura",(ajuste.getFactura()!=null && !ajuste.getFactura().trim().equals(""))?ajuste.getFactura():"",(fg.equals("AF")),false,true,20,12)%><%if(fg.equals("AR")){%><%//=fb.button("selFactura","...",true,viewMode,null,null,"onClick=\"javascript:selFacturas()\"","Facturas")%><%}%></td>
				</tr>
				<tr class="TextRow01">
					<td><%if(fg.equals("AR")||(ajuste.getRecibo()!=null && !ajuste.getRecibo().trim().equals(""))){%><cellbytelabel>Recibo</cellbytelabel>:<%}%></td>
					<td><%if(fg.equals("AR")||(ajuste.getRecibo()!=null && !ajuste.getRecibo().trim().equals(""))){%><%=fb.textBox("recibo",(ajuste.getRecibo()!=null && !ajuste.getRecibo().trim().equals(""))?ajuste.getRecibo():"",false,false,true,20,12)%><%}%>
					<%if(fg.trim().equals("AR")){%><%=fb.button("addRecibo","...",(!viewMode),(viewMode || !fg.trim().equals("AR")),null,null,"onClick=\"javascript:Recibos()\"","Agregar Recibo")%><%}%></td>
					<td>Monto<%=fb.decBox("total",ajuste.getTotal(),true,false,viewMode,15,10.2)%>
						 <%if(fg.equals("AR")){%><%=fb.checkbox("ctrlajuste","S",(ajuste.getCtrlAjuste().trim().equals("S")),viewMode,null,null,"")%><cellbytelabel>Cr&eacute;dito</cellbytelabel><%}%></td>
					 <td>
					 <%if(fg.equals("AF")){%>
					 <cellbytelabel>Tipo Documento</cellbytelabel>:<%=fb.select("tipo_docto","C=Nota de Credito"+((isAjusteAut.equals("Y"))?"":", D=Nota de Debito"),ajuste.getTipoDocto(),true,false,viewMode,0,"","","onChange=\"javascript:clearAjuste()\"")%>
					 <%}%>
					 </td>

				</tr>
				<tr class="TextRow01">
						<td>Observación</td>
						<td colspan="2">Observaci&oacute;n<%=fb.textarea("explicacion",ajuste.getExplicacion(),true,false,viewMode,60,3,200,"","width:100%","")%></td>
						<td align="center"><%=fb.button("addComprobante","Comprobante",(!viewMode),false,null,null,"onClick=\"javascript:showComprobante()\"","Imprimir Comprobante de Ajuste")%></td>
				</tr>
				<tr class="TextRow02">
							<td>Fecha Creación</td>
							<td><%=ajuste.getFechaCreacion()%></td>
							<td colspan="2">Usuario Creación: <%=ajuste.getUsuarioCreacion()%></td>
						</tr>
				<tr>
					<td colspan="4">
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../facturacion/notas_ajustes_detail.jsp?mode=<%=mode%>&codigo=<%=codigo%>&compania=<%=compania%>&notasLastLineNo=<%=notasLastLineNo%>&fg=<%=fg%>&isAjusteAut=<%=isAjusteAut%>&factura=<%=fact%>"></iframe>
					</td>
				</tr>
	<%//fb.appendJsValidation("\n\tif (!CheckMonto()) error++;\n");%>
	<%fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");%>
	<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						<!--< ---><%=fb.radio("saveOption","N",true,viewMode,false)%>Crear Otro
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
						<%=fb.button("save","Guardar",(!viewMode),viewMode,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
	%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/notas_ajustes_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/notas_ajustes_list.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/facturacion/list_notas_ajustes.jsp?fp=ajuste';
<%
		}

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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&codigo=<%=codigo%>&compania=<%=compania%>&fg=<%=fg%>&ref_type=<%=ref_type%>&ref_id=<%=ref_id%>&isAjusteAut=<%=isAjusteAut%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>