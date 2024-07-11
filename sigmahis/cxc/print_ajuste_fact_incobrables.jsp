<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
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

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String compId = (String) session.getAttribute("_companyId");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String fg  = request.getParameter("fg");
String lista  = request.getParameter("lista");
String anio  = request.getParameter("anio");
String referencia  = request.getParameter("referencia");
String fechaHora  = request.getParameter("fecha");
CommonDataObject cdoXtra = new CommonDataObject();
if (fg == null) fg = "FI";
if (appendFilter == null) appendFilter = "";

sbSql.append("select distinct ( select nombre_paciente as nombre_paciente from vw_adm_paciente where pac_id = c.pac_id)nombre_paciente, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = c.pac_id) as fechaNacimiento, c.paciente codigo_paciente, c.amision secuencia, c.factura,/*c.empresa,*/c.pac_id,c.compania,nvl((select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d, tbl_cds_centro_servicio cds where d.nota_ajuste = n.codigo and d.compania = n.compania and d.factura = c.factura and ( d.centro is not null  and d.centro = cds.codigo and cds.tipo_cds in ('I','E')) ),0)+nvl((select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d where d.nota_ajuste = n.codigo and d.compania = n.compania and d.factura = c.factura and ( d.centro is null and d.medico is null and d.empresa is null) ),0) centros, nvl((select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d, tbl_cds_centro_servicio cds where d.nota_ajuste = n.codigo and d.compania = n.compania and d.factura = c.factura and ( d.centro is not null  and d.centro = cds.codigo and cds.tipo_cds in ('T') and d.medico is null and d.empresa is null) ),0)terceros ,nvl((select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d where d.nota_ajuste = n.codigo and d.compania = n.compania and d.factura = c.factura and  d.medico is not null ),0) medicos,nvl((select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)) monto from  tbl_fac_det_nota_ajuste d where  d.nota_ajuste = n.codigo and d.compania = n.compania and d.factura = c.factura and d.empresa is not null ),0) empresas ,(select id_responsable from tbl_adm_admision where pac_id = c.pac_id and secuencia =c.amision )id_responsable,(select descripcion from tbl_fac_tipo_ajuste where codigo =n.tipo_ajuste and compania=n.compania ) descAjuste  from tbl_fac_nota_ajuste n, tbl_fac_det_nota_ajuste c where n.compania = ");
sbSql.append(compId);
sbSql.append(" and n.referencia =");
sbSql.append(referencia);
sbSql.append(" and n.codigo = c.nota_ajuste and n.compania = c.compania order by 1  ");

al = SQLMgr.getDataList(sbSql.toString());


sbSql = new  StringBuffer();
sbSql.append("select decode(to_char(x.empresa),null, decode(x.medico,null,decode(x.tipo_cds,'I','A','E','A','T','B'),'C'),'D') orden , decode(to_char(x.empresa),null, decode(x.medico,null,to_char(x.centro),x.medico),to_char(x.empresa)) codigo_cs,x.monto,decode(to_char(x.empresa),null, decode(x.medico,null,descCds,x.nom_med),x.nombre) descripcion from ( select det.centro,det.medico,det.empresa ,sum(nvl(det.monto,0) )monto, cds.descripcion descCds , med.primer_nombre||' '||med.primer_apellido||' '||decode(med.sexo,'F',decode(med.apellido_de_casada,null,med.segundo_apellido,med.apellido_de_casada),'M',med.segundo_apellido) nom_med ,e.nombre,nvl(cds.tipo_cds,'I') tipo_cds from  tbl_fac_nota_ajuste cm, tbl_fac_det_nota_ajuste det,tbl_cds_centro_servicio cds,tbl_adm_medico med,tbl_adm_empresa e where  cm.compania = "+compId+" and  cm.referencia =");
sbSql.append(referencia);
 sbSql.append(" and (cm.codigo = det.nota_ajuste and  cm.compania = det.compania) and det.centro = cds.codigo(+) and det.medico = med.codigo(+) and det.empresa = e.codigo(+) group by det.centro,det.medico,det.empresa,cds.descripcion,med.primer_nombre||' '||med.primer_apellido||' '||decode(med.sexo,'F',decode(med.apellido_de_casada,null,med.segundo_apellido,med.apellido_de_casada),'M',med.segundo_apellido),e.nombre,nvl(cds.tipo_cds,'I') ) x order by 1,2  ");

al2 = SQLMgr.getDataList(sbSql.toString());

sbSql = new  StringBuffer();

sbSql.append(" select nvl(z.montoClinica,0)montoClinica, nvl(z.montoTerceros,0)montoTerceros,nvl(z.montoMedicos,0)montoMedicos,nvl(z.montoEmpresas,0)montoEmpresas, nvl(z.montoClinica,0)+nvl(z.montoTerceros,0)+nvl(z.montoMedicos,0)+nvl(z.montoEmpresas,0) totalAnual, nvl(z.revCentros,0)revCentros,nvl(z.revTerceros,0) revTerceros,nvl(z.revMedicos,0)revMedicos,nvl(z.revEmpresas,0) revEmpresas, nvl(z.revCentros,0)+nvl(z.revTerceros,0)+nvl(z.revMedicos,0)+nvl(z.revEmpresas,0) totalRev  from ( select (select sum(monto) from ( select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))   monto  from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds,tbl_cxc_cuentasm m where ( m.lista  <= ");
sbSql.append(lista);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and (m.factura = n.factura) and  n.fecha >= to_date(m.fecha_creacion,'DD-MM-YYYY') and (d.centro is not null and d.centro <> 0 and  d.centro = cds.codigo and cds.tipo_cds in ('I','E'))    union   select nvl(sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto)),0)   monto from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cxc_cuentasm m where ( m.lista  <= ");
sbSql.append(lista);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania)  and (m.factura = n.factura) and  n.fecha   >= to_date(m.fecha_creacion,'DD-MM-YYYY') and (d.centro is  null and  d.medico is null and  d.empresa is null)))  montoClinica,(select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))  monto_terceros from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds, tbl_cxc_cuentasm m where (m.lista  <= ");
sbSql.append(lista);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia)and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and (m.factura = n.factura) and n.fecha >= to_date(m.fecha_creacion,'DD/MM/YYYY') and (d.centro is not null and d.centro = cds.codigo and cds.tipo_cds = 'T')) montoTerceros,(  select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))   monto_medico from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_adm_medico med,tbl_cxc_cuentasm m where (m.lista  <= ");
sbSql.append(lista);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo    = d.nota_ajuste and  n.compania  = d.compania) and d.medico  = med.codigo and (m.factura = n.factura) and n.fecha >= to_date(m.fecha_creacion,'DD/MM/YYYY') ) montoMedicos,( select sum(decode(d.lado_mov,'C',d.monto,'D',-d.monto))   monto_empresas from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_adm_empresa emp,tbl_cxc_cuentasm m where (m.lista <= ");
sbSql.append(lista);
sbSql.append(" and m.anio = ");
sbSql.append(anio);
sbSql.append(" and n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB')) and (ltrim(rtrim(to_char(m.anio)))||ltrim(rtrim(to_char(m.lista))) = n.referencia) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and d.empresa  = emp.codigo and (m.factura = n.factura) and n.fecha >= to_date(m.fecha_creacion,'dd/mm/yyyy')  )montoEmpresas,(select  sum(nvl(revCentros,0))revCentros from ( select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto))   revCentros from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds where (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV')) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania) and substr(n.fecha,7,4) =");
sbSql.append(anio);
sbSql.append(" and  n.fecha_creacion <= to_date('");
sbSql.append(fechaHora);
//sbSql.append("||' '||");
//sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi am') and (d.centro is not null and  d.centro= cds.codigo and  d.centro <> 0 and  cds .tipo_cds in ('I','E'))  union    select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto))   revCentros from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n where (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV') ) and (n.codigo = d.nota_ajuste and  n.compania  = d.compania)  and substr(n.fecha,7,4) =");
sbSql.append(anio);
sbSql.append(" and n.fecha_creacion <= nvl(to_date('");
sbSql.append(fechaHora);
//sbSql.append("||' '||");
//sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi am'), n.fecha_creacion) and (d.descripcion like '%COPAGO%'  or  d.descripcion like '%PERDIEM%' or d.descripcion like '%PEDIEM%' or d.descripcion like '%PAQUETE DE DIALISIS%' )) ) revCentros , ( select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)) revTerceros from  tbl_fac_det_nota_ajuste d,tbl_fac_nota_ajuste n,tbl_cds_centro_servicio cds where (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV') ) and (n.codigo = d.nota_ajuste and  n.compania = d.compania) and substr(n.fecha,7,4) = ");
sbSql.append(anio);
sbSql.append(" and n.fecha_creacion <= to_date('");
sbSql.append(fechaHora);
//sbSql.append("||' '||");
//sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi am') and (d.centro is not null and d.centro = cds.codigo and cds.tipo_cds = 'T'))revterceros ,(select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto))  monto_med from  tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n, tbl_adm_medico med where  substr(n.fecha,7,4) = ");
sbSql.append(anio);
sbSql.append(" and  n.fecha_creacion <= to_date('");
sbSql.append(fechaHora);
//sbSql.append("||' '||");
//sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi am') and (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV') ) and (n.codigo = d.nota_ajuste and  n.compania = d.compania) and (d.centro is null or d.centro = 0) and d.empresa is null and d.medico is not null and d.medico = med.codigo) revMedicos , ( select sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto))   revEmpresa from  tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n,tbl_adm_empresa emp where (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV') ) and  substr(n.fecha,7,4) = ");
sbSql.append(anio);
sbSql.append(" and  n.fecha_creacion <= to_date('");
sbSql.append(fechaHora);
//sbSql.append("||' '||");
//sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi am') and (n.codigo    = d.nota_ajuste and  n.compania  = d.compania) and d.empresa  = emp.codigo ) revEmpresas from dual ) z");

CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());
if(al.size() !=0)cdoXtra = (CommonDataObject) al.get(0);
else cdoXtra.addColValue("descAjuste","");
if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "ENVIO DE CUENTAS INCOBRABLES - "+cdoXtra.getColValue("descAjuste");
	String xtraSubtitle = " LISTA  NO:  "+anio+"   -   "+lista;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".10");

		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Paciente",0);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Cod. Pac.",1);
		pc.addBorderCols("Admisión",0);
		pc.addBorderCols("Factura",0);
		pc.addBorderCols("Responsable",0);
		pc.addBorderCols("Terceros",0);
		pc.addBorderCols("Clínica",1);
		pc.addBorderCols("Médicos",1);
		pc.addBorderCols("Empresas",1);
		pc.addBorderCols("Total",1);

	pc.setTableHeader(2);//create de table header

	//table body
    double saldo =0, total =0,granTotal=0;
	double terceros=0,centros=0,medicos=0,empresas=0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("nombre_paciente"),0,1);
			pc.addCols(" "+cdo1.getColValue("fechaNacimiento"),0,1);
			pc.addCols(" "+cdo1.getColValue("codigo_paciente"),1,1);
			pc.addCols(" "+cdo1.getColValue("secuencia"),1,1);
			pc.addCols(" "+cdo1.getColValue("factura"),1,1);
			pc.addCols(" "+cdo1.getColValue("id_responsable"),1,1);

			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("terceros")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("centros")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("medicos")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("empresas")),2,1);

			saldo = Double.parseDouble(cdo1.getColValue("terceros")) + Double.parseDouble(cdo1.getColValue("centros")) +Double.parseDouble(cdo1.getColValue("medicos"))+Double.parseDouble(cdo1.getColValue("empresas"));
			total += saldo;
			terceros += Double.parseDouble(cdo1.getColValue("terceros"));
			centros  += Double.parseDouble(cdo1.getColValue("centros"));
			medicos  += Double.parseDouble(cdo1.getColValue("medicos"));
			empresas += Double.parseDouble(cdo1.getColValue("empresas"));

			pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	    pc.addCols(" ",0,dHeader.size());
		pc.addCols(" Acumulado por Año Fiscal ",1,4);
		pc.addCols(" Monto de la Lista ",2,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total),2,3);

		pc.addCols(" ",1,1);
		pc.addCols("MONTO",2,2);
		pc.addCols("MONTO REVERSIÓN",2,2);
		pc.addCols(" ",1,6);

		pc.addCols("Clínica:      B/.",0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoClinica")),2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revCentros")),2,2);

		pc.addCols(" ",0,1);
		pc.addCols("Monto Clínica:      B/.",0,3);
		pc.addCols(""+CmnMgr.getFormattedDecimal(centros),2,2);



		pc.addCols("Terceros:   B/.",0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoTerceros")),2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revTerceros")),2,2);

		pc.addCols(" ",0,1);
		pc.addCols("Monto Terceros:   B/.",0,3);
		pc.addCols(""+CmnMgr.getFormattedDecimal(terceros),2,2);


		pc.addCols("Médicos:    B/.",0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoMedicos")),2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revMedicos")),2,2);

		pc.addCols(" ",0,1);
		pc.addCols("Monto Médicos:    B/.",0,3);
		pc.addCols(""+CmnMgr.getFormattedDecimal(medicos),2,2);


		pc.addCols("Empresa:   B/.",0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("montoempresas")),2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("revEmpresas")),2,2);

		pc.addCols(" ",0,1);
		pc.addCols("Monto Empresa:   B/.",0,3);
		pc.addCols(""+CmnMgr.getFormattedDecimal(empresas),2,2);



		pc.addCols("TOTAL ",2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalAnual")),2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalRev")),2,2);

		pc.addCols(" ",0,1);
		pc.addCols(" Facturas ",0,3);
		pc.addCols(" "+al.size(),2,2);

		pc.addCols(" ",1,dHeader.size());

		pc.addCols("GRAN   TOTAL ",2,1);

		granTotal = Double.parseDouble(cdoHeader.getColValue("totalAnual")) -Double.parseDouble(cdoHeader.getColValue("totalRev"));
		pc.addCols(""+CmnMgr.getFormattedDecimal(""+granTotal),2,3);
		pc.addCols(" ",0,6);
		//pc.setNoColumnFixWidth(vHon);
		//pc.createTable("centros",false,0,0.0f,425.5f);


		double tClinica = 0.00;
		double tDesc = 0.00;
		double tNeto = 0.00;
		int key =0,x=0;
		String groupBy ="";
		pc.addCols(" ",1,dHeader.size());
		pc.flushTableBody(true);
				//delete previous cds
				pc.deleteRows(-1);


		pc.addCols(" ",1,dHeader.size());

		for (int j=0; j<al2.size(); j++)
		{
			CommonDataObject cli = (CommonDataObject) al2.get(j);

			if(!groupBy.trim().equals(cli.getColValue("orden"))){
			pc.setFont(headerFontSize,1);
			if( j!=0)
			{
				pc.addCols(" ",1,dHeader.size());

				if(groupBy.trim().equals("A"))
					pc.addCols("TOTAL CLÍNICA",0,3);
				else if(groupBy.trim().equals("B"))
					pc.addCols("TOTAL CENTROS TERCEROS",0,3);
				else if(groupBy.trim().equals("C"))
					pc.addCols("TOTAL MÉDICOS",0,3);
				else if(groupBy.trim().equals("D"))
					pc.addCols("TOTAL EMPRESAS",0,3);


					pc.addCols(CmnMgr.getFormattedDecimal(tClinica),2,2);
					pc.addCols(" ",1,6);
					pc.addCols(" ",1,dHeader.size());

			}
				if(cli.getColValue("orden").trim().equals("A")) pc.addCols("MONTO CLINICA DETALLADO",0,dHeader.size());
				else if(cli.getColValue("orden").trim().equals("B")) pc.addCols("MONTO CENTROS TERCEROS ",0,dHeader.size());
				else if(cli.getColValue("orden").trim().equals("C")) pc.addCols("MONTO MÉDICOS DETALLADO",0,dHeader.size());
				else if(cli.getColValue("orden").trim().equals("D")) pc.addCols("MONTO EMPRESAS DETALLADO",0,dHeader.size());

				pc.addBorderCols("DESCRIPCIÓN",1,3);
				pc.addBorderCols("MONTO",1,2);
				pc.addCols(" ",1,6);
				tClinica =0;
			}

			pc.setFont(contentFontSize,0);
			pc.addCols(cli.getColValue("descripcion"),0,3);
			pc.addCols(CmnMgr.getFormattedDecimal(cli.getColValue("monto")),2,2);
			pc.addCols(" ",1,6);

			tClinica += Double.parseDouble(cli.getColValue("monto"));
			groupBy = cli.getColValue("orden");

		}
			pc.addCols(" ",1,dHeader.size());
			pc.setFont(headerFontSize,1);
				if(groupBy.trim().equals("A"))
					pc.addCols("TOTAL CLÍNICA",0,3);
				else if(groupBy.trim().equals("B"))
					pc.addCols("TOTAL CENTROS TERCEROS",0,3);
				else if(groupBy.trim().equals("C"))
					pc.addCols("TOTAL MÉDICOS",0,3);
				else if(groupBy.trim().equals("D"))
					pc.addCols("TOTAL EMPRESAS",0,3);

					pc.addCols(CmnMgr.getFormattedDecimal(tClinica),2,2);
					pc.addCols(" ",1,6);

		  //pc.addCols("Recibido por:  ______________________________________________",0,5);
		  //pc.addCols("Fecha:         ______________________________________________",0,6);

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>