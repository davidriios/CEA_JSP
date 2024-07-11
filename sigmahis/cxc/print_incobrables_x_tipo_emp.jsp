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

if (fg == null) fg = "MED";
if (appendFilter == null) appendFilter = "";

if(fg.trim().equals("MED"))
sbSql.append(" select med.primer_apellido||' '||med.segundo_apellido||' '||med.apellido_de_casada||',  '||med.primer_nombre||' '||med.segundo_nombre nombre,med.codigo,");
else if(fg.trim().equals("TER"))  sbSql.append("select cds.descripcion nombre,cds.codigo, ");
else if(fg.trim().equals("EMP"))sbSql.append(" select emp.nombre,emp.codigo, ");


sbSql.append("pac.nombre_paciente,to_char(adm.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento, adm.codigo_paciente, adm.secuencia,fn.factura,fn.referencia, fn.codigo num_ajuste,fn.total,fn.tipo_ajuste,nvl(decode(fdn.lado_mov,'C',fdn.monto, 'D', (fdn.monto * -1)),0) monto from tbl_fac_nota_ajuste fn,tbl_fac_det_nota_ajuste fdn,tbl_fac_factura ff,tbl_adm_admision adm, vw_adm_paciente pac,tbl_cxc_cuentasm m");

if(fg.trim().equals("MED"))sbSql.append(",tbl_adm_medico med ");
else if(fg.trim().equals("TER"))  sbSql.append(",tbl_cds_centro_servicio cds ");
else if(fg.trim().equals("EMP"))sbSql.append(",tbl_adm_empresa emp ");

sbSql.append(" where fn.codigo(+) = fdn.nota_ajuste and fn.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB') and substr(fn.referencia,1,4) =");
sbSql.append(anio);
if(fg.trim().equals("MED"))sbSql.append(" and fdn.medico =  med.codigo and fdn.tipo = 'H'");
else if(fg.trim().equals("TER"))  sbSql.append("and fdn.centro = cds.codigo and cds.tipo_cds = 'T' and fdn.tipo = 'C' ");
else if(fg.trim().equals("EMP"))sbSql.append("and fdn.empresa = emp.codigo  and fdn.tipo = 'E'");



sbSql.append(" and fn.factura = ff.codigo and (adm.pac_id   = ff.pac_id and adm.secuencia = ff.admi_secuencia) and  pac.pac_id = ff.pac_id and  ff.cod_empresa = (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_EMP_INCOB') and  m.factura = fn.factura and  fn.fecha >= to_date(m.fecha_creacion ,'dd/mm/yyyy') group by  ");

if(fg.trim().equals("MED"))sbSql.append(" med.primer_apellido||' '||med.segundo_apellido||' '||med.apellido_de_casada ||',  '||med.primer_nombre||' '||med.segundo_nombre,med.codigo,");
else if(fg.trim().equals("TER"))  sbSql.append(" cds.descripcion,cds.codigo, ");
else if(fg.trim().equals("EMP"))sbSql.append(" emp.nombre,emp.codigo, ");


sbSql.append(" pac.nombre_paciente,adm.fecha_nacimiento,adm.codigo_paciente,adm.secuencia, fn.factura,fn.referencia,fn.codigo,fn.total,fn.tipo_ajuste,decode(fdn.lado_mov,'C',fdn.monto, 'D', (fdn.monto * -1)) order by 1"); 

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new  StringBuffer();

sbSql.append("  select nvl(sum(decode(d.lado_mov,'C',-d.monto,'D',d.monto)),0) totalRev from  tbl_fac_det_nota_ajuste d, tbl_fac_nota_ajuste n");
if(fg.trim().equals("MED"))sbSql.append(",tbl_adm_medico med ");
else if(fg.trim().equals("TER"))  sbSql.append(",tbl_cds_centro_servicio cds ");
else if(fg.trim().equals("EMP"))sbSql.append(",tbl_adm_empresa emp ");
	
sbSql.append(" where n.compania =");
sbSql.append(compId);
sbSql.append(" and substr(n.fecha,7,4) = ");
sbSql.append(anio);
sbSql.append("  and (n.tipo_ajuste in (select param_value from  tbl_sec_comp_param where compania =");
sbSql.append(compId);
sbSql.append(" and param_name ='COD_AJ_INCOB_REV')) and (n.codigo = d.nota_ajuste  and  n.compania = d.compania) ");

if(fg.trim().equals("MED"))sbSql.append(" and d.centro is null  and d.empresa is null and d.medico is not null and d.medico = med.codigo");
else if(fg.trim().equals("TER"))  sbSql.append(" and (d.centro is not null and d.centro = cds.codigo and cds.tipo_cds = 'T')  ");
else if(fg.trim().equals("EMP"))sbSql.append(" and d.empresa  = emp.codigo ");

CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());



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
	String subtitle = "CUENTAS REBAJADAS INCOBRABLES";
	String xtraSubtitle = "";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	if(fg.trim().equals("MED")) xtraSubtitle="HONORARIOS   MEDICOS";
	else if(fg.trim().equals("TER")) xtraSubtitle="CENTROS   TERCEROS";
	else if(fg.trim().equals("EMP")) xtraSubtitle="HONORARIOS   DE   EMPRESAS";
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Paciente",0);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Cod. Pac.",1);
		pc.addBorderCols("Admisión",0);
		pc.addBorderCols("Factura",0);
		pc.addBorderCols("Referencia",0);
		pc.addBorderCols("Monto",1);
	
	pc.setTableHeader(2);//create de table header

	//table body
    double saldo =0, total =0,granTotal=0;
	double terceros=0,centros=0,medicos=0,empresas=0;
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("nombre_paciente"),0,1);
			pc.addCols(" "+cdo1.getColValue("fecha_nacimiento"),0,1);
			pc.addCols(" "+cdo1.getColValue("codigo_paciente"),1,1);
			pc.addCols(" "+cdo1.getColValue("secuencia"),1,1);
			pc.addCols(" "+cdo1.getColValue("factura"),1,1);
			pc.addCols(" "+cdo1.getColValue("referencia"),1,1);
			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")),2,1);
			
			saldo = Double.parseDouble(cdo1.getColValue("monto"));
			total += saldo;
			

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	    
		pc.addCols(" ",1,dHeader.size());
		pc.addCols("TOTAL   DE   " +xtraSubtitle,2,5);
		pc.addCols(""+CmnMgr.getFormattedDecimal(total),2,2);

		//pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalRev")),2,2);
		
		pc.addCols(" ",1,dHeader.size());
		pc.addCols("TOTAL   DE   REVERSIONES    DE " +xtraSubtitle,2,5);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalRev")),2,2);
		
		pc.addCols(" ",1,dHeader.size());
		
		pc.addCols("G R A N      T O T A L      P O R      R E P O R T E ",2,5);
		
		granTotal = total -Double.parseDouble(cdoHeader.getColValue("totalRev"));
		pc.addCols(""+CmnMgr.getFormattedDecimal(""+granTotal),2,2);
		//pc.setNoColumnFixWidth(vHon);
		//pc.createTable("centros",false,0,0.0f,425.5f);
			

		
		

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>