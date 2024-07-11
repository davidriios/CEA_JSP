<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================================================
==================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();

String key = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String compId = (String) session.getAttribute("_companyId");

if(fg==null) fg = "mes";
if(fp==null) fp ="INV";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha = request.getParameter("fecha");
String mes  ="";
String anio  =request.getParameter("anio");
String lista  =request.getParameter("lista");
String anioLista  ="";
String listaAnterior  ="";

String referencia = "";
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";
if(anio == null)anio="";
if(lista == null)lista="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select anio , to_char(fecha_creacion,'dd/mm/yyyy') fecha_creacion, usuario_creacion ,(select nvl(max(lista),0) from tbl_cxc_cuentasm where compania =");
	sbSql.append(compId);
	sbSql.append(" and anio = (select max(anio) from tbl_cxc_cuentasm where compania =");
	sbSql.append(compId);
	sbSql.append("))lista,(select max(anio) from tbl_cxc_cuentasm where compania =");
	sbSql.append(compId);
	sbSql.append(" ) anioLista  from tbl_cxc_param_cuentasm where anio = (select max(nvl(anio,0)) from tbl_cxc_param_cuentasm) ");
	cdo = SQLMgr.getData(sbSql.toString());
	if(!anio.trim().equals("") && !lista.trim().equals("")) referencia = anio+lista;
	
	if(cdo != null)
	{
		if(referencia.trim().equals("")) referencia = cdo.getColValue("anioLista") + cdo.getColValue("lista");
		anio  = cdo.getColValue("anioLista") ;
		lista = cdo.getColValue("lista");
		anioLista  = cdo.getColValue("anio") ;
		listaAnterior = cdo.getColValue("lista");
		
		sbSql = new StringBuffer();
sbSql.append(" select nvl(z.montoClinica,0)montoClinica, nvl(z.montoTerceros,0)montoTerceros,nvl(z.montoMedicos,0)montoMedicos,nvl(z.montoEmpresas,0)montoEmpresas, nvl(z.montoClinica,0)+nvl(z.montoTerceros,0)+nvl(z.montoMedicos,0)+nvl(z.montoEmpresas,0) total from ( select (select sum(monto) from ( select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds, tbl_cxc_cuentasm m where ( n.compania =");
sbSql.append(compId);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and m.lista <= ");
sbSql.append(lista);
sbSql.append(" and n.estatus ='A' and   n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania in(-1,");
sbSql.append(compId);
sbSql.append(") and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania)  and (m.factura = n.factura) and  trunc(n.fecha) >= to_date(m.fecha_creacion,'dd/mm/yyyy') and (d.centro is not null and  d.centro = cds.codigo and cds.tipo_cds in ('I','E')) union all select nvl(sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)),0)   monto from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cxc_cuentasm m where (n.compania =");
sbSql.append(compId);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and m.lista <= ");
sbSql.append(lista);
sbSql.append(" and n.estatus ='A' and  n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania in(-1,");
sbSql.append(compId);
sbSql.append(")  and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo    = d.nota_ajuste and  n.compania  = d.compania)  and (m.factura = n.factura) and  trunc(n.fecha)   >= to_date(m.fecha_creacion,'dd/mm/yyyy') and (d.centro is  null and  d.medico is null and  d.empresa is null )))  montoClinica  ,(select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))  monto_terceros from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds,tbl_cxc_cuentasm m where ( n.compania = ");
sbSql.append(compId);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and m.lista <= ");
sbSql.append(lista);
sbSql.append(" and n.estatus ='A' and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append("  and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and (m.factura = n.factura) and trunc(n.fecha) >= to_date(m.fecha_creacion,'dd/mm/yyyy') and (d.centro is not null and d.centro = cds.codigo and cds.tipo_cds = 'T') ) montoTerceros, (  select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto_medico from tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_adm_medico med,tbl_cxc_cuentasm m where (n.compania = ");
sbSql.append(compId);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and m.lista <= ");
sbSql.append(lista);
sbSql.append(" and n.estatus ='A' and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania in(-1,");
sbSql.append(compId);
sbSql.append(") and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and d.medico  = med.codigo and (m.factura = n.factura) and n.fecha >= to_date(m.fecha_creacion,'dd/mm/yyyy') ) montoMedicos,(select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))   monto_empresas from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_adm_empresa emp,tbl_cxc_cuentasm m where (n.compania = ");
sbSql.append(compId);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and m.lista <= ");
sbSql.append(lista);
sbSql.append(" and n.estatus ='A' and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania in(-1,");
sbSql.append(compId);
sbSql.append(") and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and d.empresa  = emp.codigo and (m.factura = n.factura) and trunc(n.fecha) >= to_date(m.fecha_creacion,'dd/mm/yyyy') )montoEmpresas from dual ) z  ");
cdo2 = SQLMgr.getData(sbSql.toString());
	}
	else 
	{
		cdo = new CommonDataObject();
		cdo.addColValue("fecha_creacion","");
		cdo.addColValue("anio","");
		
		cdo2 = new CommonDataObject();
		cdo2.addColValue("montoClinica","0");
		cdo2.addColValue("montoTerceros","0");
		cdo2.addColValue("montoMedicos","0");
		cdo2.addColValue("montoEmpresas","0");
		cdo2.addColValue("total","0");

	}
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'cxc - '+document.title;

function doSubmit(){
	document.form1.baction.value = 'Guardar';
	var anio = document.form1.anioCerrar.value; 
	var anioCerrado = document.form1.anio.value; 
	var total = parseFloat(document.form1.total.value); 
	
	if(anio !='' && anioCerrado !='')
	{
		anio = parseInt(anio);
		anioCerrado = parseInt(anioCerrado);
		
		if(total !=0)
		{
			if(anio <= anioCerrado)
			{
			  alert('No puede Ejecutar este Proceso. El Año '+anio+' ya fue Cerrado');
			}
			else
			{
				if(confirm('¿Está Seguro de Cerrar el año para las Cuentas Incobrables ????')){
				document.form1.submit();}
				else {alert('Proceso cancelado');}
			}
		}
		else alert('Debe generar los montos, presione el botón Calcular Montos...')
		
	}
}

function doAction(){

}
function verMontos(){
var anio   = document.form1.anioCerrar.value; 
var lista  = document.form1.lista.value; 
window.location = '../cxc/param_cierre_incobrables.jsp?anio='+anio+'&lista='+lista;
}


function printReportes()
{
	var anio		= document.form1.anioCerrar.value;
	var p_compania  = '<%=(String) session.getAttribute("_companyId")%>';
	abrir_ventana('../cxc/print_incobrables_x_tipo_med.jsp?fg=MED&anio='+anio+'&compania='+p_compania);
	abrir_ventana2('../cxc/print_incobrables_x_tipo_emp.jsp?fg=EMP&anio='+anio+'&compania='+p_compania);
	abrir_ventana3('../cxc/print_incobrables_x_tipo.jsp?fg=TER&anio='+anio+'&compania='+p_compania);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generación de Cargos de Alquiler"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="0" cellspacing="0">
	<tr align="center">
		<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
				<tr>
					<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
							<tr>
								<td><table align="center" width="100%" cellpadding="0" cellspacing="1">
										<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
										<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
										<%=fb.formStart(true)%>
										<%=fb.hidden("mode",mode)%>
										<%=fb.hidden("errCode","")%>
										<%=fb.hidden("errMsg","")%>
										<%=fb.hidden("baction","")%>
										<%=fb.hidden("banco","")%>
										<%=fb.hidden("fg",fg)%>
										<%=fb.hidden("fp",fp)%>
										<%=fb.hidden("clearHT","")%>
										<tr class="TextRow02">
											<td>

											<table width="100%" cellpadding="1" cellspacing="1" align="center">
													<tr class="TextHeader">
														<td colspan="3">Datos del Ultimo Cierre</td>
													</tr>
							<tr class="textRow01">
									<td align="right">Año <%=fb.intBox("anio",cdo.getColValue("anio"),false,false,true,10, 4, null,null,"")%></td>
									<td align="right">Usuario <%=fb.textBox("usuario",cdo.getColValue("usuario_creacion"),false,false,true,25, null,null,"")%></td>
									<td>Fecha<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fecha" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_creacion")%>" />
									<jsp:param name="fieldClass" value="text10" />
									<jsp:param name="buttonClass" value="text10" />
									<jsp:param name="readonly" value="y"/>
									</jsp:include>
								</td>
							</tr>
							<tr class="TextHeader">
								<td colspan="3">Proceso de Cierre Anual</td>
							</tr>
							<tr class="TextRow01">
								<td>
									<table width="100%" cellpadding="1" cellspacing="1" align="center">
										<tr class="TextHeader01">
											<td colspan="2">Cálculos</td>
										</tr>
										<tr class="TextRow01">
											<td>Año a Cerrar:<%=fb.intBox("anioCerrar",anio,true,false,(!mode.trim().equals("add")),10, 4, null,null,"")%> </td>
											<td>Lista: <%=fb.intBox("lista",lista,true,false,(!mode.trim().equals("add")),10,null,null,"")%> </td>
										</tr>
										<tr class="TextRow01">
											<td colspan="2" align="center"><authtype type='50'><%=fb.button("ver","Calcular",false,(!mode.trim().equals("add")),"text10","","onClick=\"javascript:verMontos();\"")%></authtype></td>
										</tr>
										<tr class="TextRow01">
											<td>Clínica</td>
											<td><%=fb.intBox("clinica",cdo2.getColValue("montoClinica"),false,false,true,10,null,null,"")%> </td>
										</tr>
										<tr class="TextRow01">
											<td>Terceros</td>
											<td><%=fb.intBox("terceros",cdo2.getColValue("montoTerceros"),false,false,true,10,null,null,"")%> </td>
										</tr>
										<tr class="TextRow01">
											<td>Médicos</td>
											<td><%=fb.intBox("medicos",cdo2.getColValue("montoMedicos"),false,false,true,10,null,null,"")%> </td>
										</tr>
										<tr class="TextRow01">
											<td>Empresas</td>
											<td><%=fb.intBox("empresas",cdo2.getColValue("montoEmpresas"),false,false,true,10,null,null,"")%> </td>
										</tr>
										<tr class="TextRow01">
											<td>Total</td>
											<td><%=fb.intBox("total",cdo2.getColValue("total"),false,false,true,10,null,null,"")%> </td>
										</tr>
									</table>
								</td>
								<td valign="top"><table width="100%" cellpadding="1" cellspacing="1" align="center">
										<tr class="TextHeader01">
											<td colspan="2">Generar Reportes</td>
										</tr>
										<tr class="TextRow01">
											<td><authtype type='51'><%=fb.button("reporte","Generar Reportes",false,false,"text10","","onClick=\"javascript:printReportes();\"")%></authtype></td>
										</tr>
										<tr class="TextRow01">
											<td>Reportes detallados de Terceros, Médicos y Empresas</td>
										</tr>
										
									</table>
								</td>
								<td valign="top">
								<table width="100%" cellpadding="1" cellspacing="1" align="center">
										<tr class="TextHeader01">
											<td>Actualización</td>
										</tr>
																			
										<tr class="TextRow01">
											<td><authtype type='52'><%=fb.button("act","Actualizar",false,(!mode.trim().equals("add")),"text10","","onClick=\"javascript:doSubmit();\"")%></authtype></td>
										</tr>
										<tr class="TextRow01">
											<td>Si terminó de Imprimir,presione "Actualizar" para terminar.</td>
										</tr>
									</table>

								</td>
							</tr>
							
							
							

						 <tr class="textRow02" >
														<td colspan="2" align="center"></td>
													</tr>


												</table>
												</td>
										</tr>
										<%=fb.formEnd(true)%>
										<!-- ================================   F O R M   E N D   H E R E   ================================ -->
									</table></td>
							</tr>
						</table></td>
				</tr>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();
	
	cdo.setTableName("tbl_cxc_param_cuentasm");
	cdo.addColValue("anio",request.getParameter("anioCerrar"));
	cdo.addColValue("contador_listas",request.getParameter("lista"));
	cdo.addColValue("total_rebajado",request.getParameter("total"));
	cdo.addColValue("monto_clinica",request.getParameter("clinica"));
	cdo.addColValue("monto_terceros",request.getParameter("terceros"));
	cdo.addColValue("monto_honorarios",request.getParameter("medicos"));
	cdo.addColValue("monto_empresa",request.getParameter("empresas"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion",cDateTime);
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add"))
	{
		SQLMgr.insert(cdo);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/param_cierre_incobrables.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/param_cierre_incobrables.jsp")%>&mode=edit';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/cxc/param_cierre_incobrables.jsp?mode=edit';
<%
	}
%>
	//window.close();
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