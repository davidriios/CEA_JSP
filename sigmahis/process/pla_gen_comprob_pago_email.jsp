<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
String fg = request.getParameter("fg");
String cod = request.getParameter("cod");
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String empId = request.getParameter("empId");
String appendFilter = request.getParameter("appendFilter");
if (fg == null) fg = "";
if (cod == null) cod = "";
if (anio == null) anio = "";
if (num == null) num = "";
if (empId == null) empId = "";
if (appendFilter == null) appendFilter = "";

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'PLA_COMPROB_ATTACHMENT_PATH'),'-') as attachment_path, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'PLA_COMPROB_NOTE'),'-') as note from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p.getColValue("attachment_path").equals("-")) throw new Exception("El parámetro de la Ruta de Comprobantes de Planilla [PLA_COMPROB_ATTACHMENT_PATH] no está definida!");
else if (CmnMgr.createFolderDos(p.getColValue("attachment_path"),"").equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta "+p.getColValue("attachment_path")+"! Intente nuevamente.");

sbSql = new StringBuffer();
sbSql.append("select to_char(a.sal_bruto,'999,999,990.00') as salBruto, to_char(a.sal_neto,'999,999,990.00') as salNeto, to_char(decode(a.salario_base,0,e.salario_base,nvl(a.sal_ausencia,0)+nvl(a.ausencia,0)+nvl(a.tardanza,0)),'999,999,990.00') salario_quinc, to_char(a.sal_ausencia,'999,999,990.00') as salAus, nvl(a.extra,00) extra, to_char(nvl(a.seg_social,0),'999,990.00') as segSoc, to_char(nvl(a.seg_educativo,0),'999,990.00') as segEdu, to_char(nvl(a.imp_renta,0),'999,990.00') as impRen, to_char(nvl(a.fondo_com,0),'999,990.00') as fonCom, to_char(nvl(a.tardanza,0),'999,990.00') tardanza, to_char(nvl(a.ausencia,0),'999,990.00') ausencia, nvl(a.otras_ded,0) as deduc, to_char(nvl(a.total_ded,0) /*+ nvl(a.otros_egr,0)*/,'999,999,990.00') as totDed, to_char(a.dev_multa,'999,990.00') as devMul, to_char(a.comision,'999,990.00'), to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gasRep, to_char(nvl(a.ayuda_mortuoria,0),'999,990.00') as aMor, to_char(nvl(a.otros_ing,0),'999,999,990.00') as otroIng, to_char(nvl(a.otros_egr,0),'999,999,990.00') as otroEg, to_char(nvl(a.alto_riesgo,0),'999,990.00') as altRiesgo, to_char(nvl(a.bonificacion,0),'999,990.00'), to_char(nvl(a.extra,0),'999,999,990.00') as extra, to_char(nvl(a.prima_produccion,0),'999,999,990.00') as prima, to_char(nvl(a.aguinaldo_gasto,0),'999,990.00') as aguiGas, to_char(nvl(a.imp_renta_gasto,0),'999,990.00') as impGasto, a.cheque_pago as cheque, to_char(nvl(a.seg_social_gasto,0),'999,990.00') as ssGasto, to_char(to_number(nvl(a.sal_ausencia,0.00))+to_number(nvl(a.gasto_rep,0.00))+to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00))- nvl(a.otros_egr,0),'999,999,990.00') as ingTot, to_char(to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00)),'999,999,990.00') as ingTotComp, to_char(to_number(nvl(a.seg_educativo,0.00)) + to_number(nvl(a.otros_egr,0.00)) +to_number(nvl(a.otras_ded,0.00)),'999,999,990.00') as egrTotComp,to_char(nvl(a.salario_especie,0),'999,999,990.00') as salEsp, to_char(nvl(a.seg_social_especie,0),'999,990.00') as ssEsp, periodo_xiiimes as decimo, a.num_empleado as numEmpleado, to_char(a.num_cheque,'00000000000') as numCheque, f.descripcion seccion, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd/mm/yyyy') as fechaInicial, e.cedula1 cedula, f.codigo, e.num_ssocial, to_char(c.fecha_final,'dd/mm/yyyy') as fechaFinal, c.estado, e.nombre_empleado as nomEmpleado, g.denominacion cargo, to_char(nvl(a.rata_hora,0),'999,990.00') as rataHora, e.tipo_renta||'-'||to_char(e.num_dependiente,'990') as tipoRenta, ltrim(d.nombre,18)||' del '||to_char(c.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(c.fecha_final,'dd/mm/yyyy') as descripcion, e.num_cuenta, to_char(a.salario_base/2,'999,999,990.00') salarioBase, e.emp_id, round(MONTHS_BETWEEN (to_date(c.fecha_final,'dd/mm/yyyy') , to_date(e.fecha_ingreso,'dd/mm/yyyy')) * 1.5  ) as vac, a.cod_planilla codigoPla, nvl(e.email,' ') as email from tbl_pla_pago_empleado a, vw_pla_empleado e, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo g, tbl_sec_unidad_ejec f where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.cod_compania = c.cod_compania and a.anio = c.anio and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and e.compania = f.compania and nvl(e.seccion,e.ubic_seccion) = f.codigo and e.compania = g.compania and e.cargo = g.codigo and a.cod_compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.cod_planilla=");
sbSql.append(cod);
sbSql.append(" and a.num_planilla = ");
sbSql.append(num);
if (!empId.trim().equals("")) { sbSql.append(" and a.emp_id = "); sbSql.append(empId); }
sbSql.append(appendFilter);
if (request.getParameter("regen") == null) sbSql.append(" and not exists (select null from tbl_sec_mail_q where msg_ref = 'PLA_EMPL_COMPROB' and ref_key = a.emp_id||'_'||a.cod_compania||'_'||a.anio||'_'||a.cod_planilla||'_'||a.num_planilla)");
sbSql.append(" order by f.codigo, nomEmpleado");
al = SQLMgr.getDataList(sbSql.toString());
System.out.println(".............................................................."+al.size());
if(request.getMethod().equalsIgnoreCase("GET")) {

	int nMail = 0;
	int nNoMail = 0;
	for(int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (cdo.getColValue("email") != null && !cdo.getColValue("email").trim().equals("")) {

			StringBuffer sbRef = new StringBuffer();
			sbRef.append(cdo.getColValue("emp_id"));
			sbRef.append("_");
			sbRef.append(session.getAttribute("_companyId"));
			sbRef.append("_");
			sbRef.append(anio);
			sbRef.append("_");
			sbRef.append(cod);
			sbRef.append("_");
			sbRef.append(num);

			StringBuffer sbSubject = new StringBuffer();
			sbSubject.append("COMPROBANTE PAGO - ").append(cdo.getColValue("nomEmpleado")).append(" (").append(cdo.getColValue("numEmpleado")).append(")");

			StringBuffer sbMsg = new StringBuffer();
			sbMsg.append("ESTIMADO COLABORADOR, ADJUNTO SE ENCUENTRA SU COMPROBANTE DE PAGO: ").append(cdo.getColValue("descripcion"));
			//Additional Notes
			if (!p.getColValue("note").trim().equals("") && !p.getColValue("note").equals("-")) sbMsg.append("\n\n").append(p.getColValue("note"));

			StringBuffer sbPath = new StringBuffer(p.getColValue("attachment_path"));
			sbPath.append(sbRef);
			sbPath.append(".pdf");
//try {
%>
			<jsp:include page="../rhplanilla/print_list_comp_pago_emp.jsp">
				<jsp:param name="email" value=""></jsp:param>
				<jsp:param name="fg" value="<%=fg%>"></jsp:param>
				<jsp:param name="anio" value="<%=anio%>"></jsp:param>
				<jsp:param name="cod" value="<%=cod%>"></jsp:param>
				<jsp:param name="num" value="<%=num%>"></jsp:param>
				<jsp:param name="empId" value="<%=cdo.getColValue("emp_id")%>"></jsp:param>
				<jsp:param name="appendFilter" value="<%=appendFilter%>"></jsp:param>
				<jsp:param name="pdfPath" value="<%=sbPath.toString()%>"></jsp:param>
			</jsp:include>
<%
//} catch (Exception ex) {}

			CommonDataObject cdoM = new CommonDataObject();
			cdoM.setTableName("tbl_sec_mail_q");
			cdoM.addSeqColValue("msg_id","seq_secmail_q");
			cdoM.addColValue("msg_type","EMAIL");
			cdoM.addColValue("msg_ref","PLA_EMPL_COMPROB");
			cdoM.addColValue("msg_from","PLANILLA");
			cdoM.addColValue("msg_to",cdo.getColValue("email"));
			//cdoM.addColValue("msg_to","jacinto@issi-panama.com");
			cdoM.addColValue("msg_subject",sbSubject.toString());
			cdoM.addColValue("msg_text",sbMsg.toString());
			cdoM.addColValue("msg_status","A");
			cdoM.addColValue("msg_attach_flag","Y");
			cdoM.addColValue("msg_attach_file_path",sbPath.toString());
			cdoM.addColValue("ref_key",sbRef.toString());
			cdoM.addColValue("msg_sent_flag","N");
			cdoM.addColValue("msg_date","sysdate");
			SQLMgr.insert(cdoM,false);
			if (SQLMgr.getErrCode().equals("1")) nMail++;

		} else nNoMail++;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Planilla - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - CALCULO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="1">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellspacing="0">
		<tr class="TextHeader">
			<td width="60%" align="right">Total de comprobantes a generar:&nbsp;</td>
			<td width="40%">&nbsp;<%=al.size()%></td>
		</tr>
		<tr class="TextHeader">
			<td align="right">Total de empleados sin correo:&nbsp;</td>
			<td>&nbsp;<%=nNoMail%></td>
		</tr>
		<tr class="TextHeader">
			<td align="right">Total de comprobantes y correos generados:&nbsp;</td>
			<td>&nbsp;<%=nMail%></td>
		</tr>
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
		<%=fb.formStart()%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("cod",cod)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("num",num)%>
		<%=fb.hidden("empId",empId)%>
		<%=fb.hidden("appendFilter",appendFilter)%>
		<tr class="TextPager">
			<td align="center" colspan="2">
				<%//=fb.submit("regen","Regenerar Comprobantes",true,false,null,null,null)%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>