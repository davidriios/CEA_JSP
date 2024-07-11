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
StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noSecuencia = request.getParameter("noSecuencia");
String fp = request.getParameter("fp");
String yearList = request.getParameter("yearList");
String mesList = request.getParameter("mesList");
String categoria = request.getParameter("categoria");
String categoria_desc = request.getParameter("categoria_desc");
if (fp == null) fp = "";
if (yearList == null) yearList = "0";
if (mesList == null) mesList = "";
if (categoria == null) categoria = "";
if (categoria_desc == null) categoria_desc = "";
if (pacId == null || noSecuencia == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
CommonDataObject cdoPacData = SQLMgr.getPacData(pacId, noSecuencia);

sbSql = new StringBuffer();
sbSql.append("select count(*) from tbl_fac_estado_cargos where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admi_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" and cds_lim is not null");
int nLimit = CmnMgr.getCount(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select descripcion, monto_cargo, 0 as monto_descuento, 0 as monto_clinica, decode(aplicar_a,'A',dist_pac,'P',monto_cargo,0) as monto_paciente, decode(aplicar_a,'A',dist_emp,'E',monto_cargo,0) as monto_empresa, decode(rownum,1,nvl((select sum(monto) from tbl_fac_estado_cargos_det where pac_id = z.pac_id and admi_secuencia = z.admi_secuencia and tipo = 'COP'),0),0) as monto_copago, ' ' as benef_copago, 0 as montoPacienteCubierto from (");
sbSql.append("select a.pac_id, a.admi_secuencia, a.descripcion_lim as descripcion, a.monto_lim as monto_cargo, a.aplicar_a_lim as aplicar_a, a.lim_dist_pac as dist_pac, a.lim_dist_emp as dist_emp, sum(nvl(round(a.monto_descuento,2),0)) as monto_descuento, sum(nvl(round(a.monto_clinica,2),0)) as monto_clinica, nvl(sum(round(a.monto_paciente,2)),0) as monto_paciente, nvl(sum(a.monto_empresa),0) as monto_empresa from tbl_fac_estado_cargos a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" and a.cds_lim is not null group by a.pac_id, a.admi_secuencia, a.descripcion_lim, a.monto_lim, a.aplicar_a_lim, a.lim_dist_pac, a.lim_dist_emp) z");

sbSql.append(" union all ");

sbSql.append("select (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio)||' ['||a.centro_servicio||']' as descripcion, nvl(sum(round(a.monto_cargos,2)),0) as monto_cargo, sum(nvl(round(a.monto_descuento,2),0)) as monto_descuento, sum(nvl(round(a.monto_clinica,2),0)) as monto_clinica, nvl(sum(round(a.monto_paciente,2)),0) as monto_paciente, nvl(sum(a.monto_empresa),0) as monto_empresa");
//se agrega de esta manera ya que el límite ya tiene el monto de copago en el primer registro
if (nLimit == 0) sbSql.append(", nvl((select sum(monto) from tbl_fac_estado_cargos_det where pac_id = a.pac_id and admi_secuencia = a.admi_secuencia and centro_servicio = a.centro_servicio and tipo = 'COP'),0) as monto_copago");
else sbSql.append(", 0 as monto_copago");
sbSql.append(", (select nvl(benef_copago,'P') as benef_copago from tbl_adm_beneficios_acum where pac_id = a.pac_id and admision = a.admi_secuencia) as benef_copago, nvl((select nvl(sum(round(nvl(monto_paciente,0),2)),0) as montoPacienteCubierto from tbl_fac_estado_cargos where pac_id = a.pac_id and admi_secuencia = a.admi_secuencia and no_cubierto = 'N'),0) as montoPacienteCubierto from tbl_fac_estado_cargos a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" and a.cds_lim is null group by a.pac_id, a.admi_secuencia, a.centro_servicio order by 1");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	if(fp.equals("lista_envio_aseg") && !yearList.equals("0")) year = yearList;
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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

	if(!mesList.equals("")) month = mesList;
	
	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String subFolderName = "archivos";
	if(fp.equals("lista_envio_aseg")){
		if(fp.equals("lista_envio_aseg"))directory = ResourceBundle.getBundle("path").getString("docs.files_aseg")+"/";
		folderName=categoria_desc;
		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	} else  if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
		
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 9;
	int groupFontSize = 9;
	int contentFontSize = 8;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ANALISIS DE LA CUENTA";
	String subtitle = "";
	String xtraSubtitle = "ANALISIS";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	if(fp.equals("lista_envio_aseg")) fileName=pacId+noSecuencia+"_FACT.pdf"; 
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".85");
		dHeader.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(headerFontSize,0);
		pc.addBorderCols(". . : :   D E T A L L E   D E L   C O N S U M O   : : . .",1,2);
	pc.setTableHeader(2);//create de table header

	//table body
	double monto_cargo = 0.00;
	double monto_descuento = 0.00;
	double monto_paciente = 0.00,montoPacienteCubierto  = 0;
	boolean gnc = false;
	double total_cargo = 0.00;
	double total_descuento = 0.00;
	double total_clinica = 0.00;
	double total_paciente = 0.00;
	double total_empresa = 0.00;
	double copago = 0.00;//Double.parseDouble(acum.getColValue("monto_copago"));
	double cargosNc = 0.00;
	String benef_copago ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(benef_copago.trim().equals(""))benef_copago =cdo.getColValue("benef_copago");
		if(montoPacienteCubierto==0)montoPacienteCubierto = Double.parseDouble(cdo.getColValue("montoPacienteCubierto"));
		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cargo")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		monto_cargo = Double.parseDouble(cdo.getColValue("monto_cargo"));
		monto_descuento = Double.parseDouble(cdo.getColValue("monto_descuento"));
		monto_paciente = Double.parseDouble(cdo.getColValue("monto_paciente"));
		//monto_clinica = Double.parseDouble(cdo.getColValue("monto_clinica"));

		total_cargo += monto_cargo;
		total_descuento += monto_descuento;
		total_clinica += Double.parseDouble(cdo.getColValue("monto_clinica"));
		total_paciente += monto_paciente;
		total_empresa += Double.parseDouble(cdo.getColValue("monto_empresa"));
		copago += Double.parseDouble(cdo.getColValue("monto_copago"));
		/*
		if(monto_descuento+monto_clinica+monto_paciente==monto_cargo)
		cargosNc += monto_cargo;
		 if(monto_descuento+monto_clinica+monto_paciente!=monto_cargo)
		 if(Double.parseDouble(cdo.getColValue("monto_copago")) >= monto_paciente)
			copagoPaciente += Double.parseDouble(cdo.getColValue("monto_copago"));
		 	*/

		//montoPacienteCubierto += Double.parseDouble(cdo.getColValue("montoPacienteCubierto"));
	}
	//System.out.println("..............................................."+total_paciente);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		gnc = (total_descuento + total_paciente == total_cargo);
		pc.setFont(groupFontSize,1);
		pc.addBorderCols("CONSUMO TOTAL",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(total_cargo),2,1,0.0f,0.5f,0.0f,0.0f);

		pc.setFont(headerFontSize,0);
		pc.addCols(" ",1,2);
		pc.addBorderCols(". . : :   A N A L I S I S   F I N A L   : : . .",1,2);
		pc.setFont(groupFontSize,0);
		pc.addCols("DESCUENTO",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(total_descuento + total_clinica),2,1);

		if(benef_copago.trim().equals("E")){
		total_paciente += copago;
		total_empresa  = total_cargo -(total_descuento + total_clinica + total_paciente);}
		else{
		//System.out.println("========================= total_cargo = "+total_cargo);
		//System.out.println("========================= total descuento = "+(total_descuento + total_clinica));
		//System.out.println("========================= copago = "+copago);
		//System.out.println("========================= total_paciente = "+total_paciente);
		//System.out.println("========================= montoPacienteCubierto = "+montoPacienteCubierto);
		//temp =  total_paciente - montoPacienteCubierto ;
		 //total_paciente += copago;
		 if(copago > 0)
		 if(montoPacienteCubierto > copago)total_paciente -= copago;
		 else { total_paciente -= montoPacienteCubierto;}
		//if((copago - montoPacienteCubierto )> 0)total_paciente -= (copago - montoPacienteCubierto);
		//else  total_paciente= total_paciente -
		total_paciente += copago;
			//total_paciente -=  (copago - montoPacienteCubierto );
			total_empresa  = total_cargo -(total_descuento + total_clinica + total_paciente);
		 }

		/*if (total_paciente == 0 || gnc )
		{

			//total_empresa -= copago-cargosNc;
			total_cargo += copago;
		}
		else
		{
			//total_paciente += copago;
			//if(copago >total_paciente)total_paciente=copago;
			System.out.println(" cargosNc 2  === "+cargosNc+" ");
			if(copago >(total_paciente-cargosNc))total_paciente=copago+cargosNc;

			//total_empresa -= (total_paciente - cargosNc);
			//total_cargo += copago;
		}*/
		//100>(476.01-100)-100)

		//if(copago > ((total_paciente - cargosNc) -copago)){//System.out.println("total_empresa  en el if de copago=== "+total_empresa+" ");

		//total_empresa  = total_cargo -(total_descuento + total_clinica + total_paciente);

		//if(copago >total_paciente-cargosNc)total_empresa = total_empresa + (copago-(total_paciente-cargosNc));

		//}

		//if(copago >total_paciente)total_paciente=copago;

		pc.addCols("PAGO PACIENTE",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(total_paciente),2,1);

		pc.addCols("PAGO ASEGURADORA",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(total_empresa),2,1);

		pc.setFont(groupFontSize,1);
		pc.addBorderCols("TOTAL",2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(total_descuento + total_clinica + total_paciente + total_empresa),2,1,0.0f,0.5f,0.0f,0.0f);

		pc.setFont(groupFontSize,1,Color.RED);
		pc.addCols("Nota: 'Sr. paciente, este SALDO es al momento de su facturación, En caso de CARGOS ADICIONALES a esta fecha, le será notificado oportunamente'", 0,dHeader.size());
	}

	pc.flushTableBody(true);
	pc.close();
	if(!fp.equals("lista_envio_aseg") )response.sendRedirect(redirectFile);
}//GET
%>