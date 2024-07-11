<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String admision = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String empresa = request.getParameter("aseguradora");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String fg = request.getParameter("fg");
String factId = request.getParameter("factId");
String tipoFecha =request.getParameter("tipoFecha");
String aseguradora =request.getParameter("aseguradora");
String aseguradoraDesc =request.getParameter("aseguradoraDesc");

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (empresa == null) empresa = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (factId == null) factId = "";
if (tipoFecha == null) tipoFecha = "";
if (aseguradora==null)aseguradora="";
if (aseguradoraDesc==null)aseguradoraDesc="";

sbSql = new StringBuffer();
sbSql.append("select a.centro cds,a.service_type tipo_cargo, (select descripcion from tbl_cds_tipo_servicio where codigo = a.service_type and compania = a.compania) descripcion, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro)centro_servicio_desc, sum(decode(a.lado_mov,'D',nvl(a.monto,0),'C',-nvl(a.monto,0)))  monto,a.compania, nvl(nvl((select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =4 and acc.ref_table = '-' and acc.ref_pk = '-' and acc.cds = a.centro and acc.service_type =a.service_type and acc.compania = a.compania and acc.status ='A' and acc.adm_type in(f.adm_type)),(select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =4 and acc.ref_table = '-' and acc.ref_pk = '-' and acc.cds = a.centro and acc.service_type =a.service_type and acc.compania = a.compania and acc.status ='A' and acc.adm_type in('T'))),'S/C')cuenta,decode(f.adm_type,'I','IP','OP')descAdmType from vw_con_adjustment_gral a, tbl_fac_tipo_ajuste c,tbl_fac_factura f where a.compania=");
sbSql.append(session.getAttribute("_companyId"));


sbSql.append(" and a.tipo_ajuste = c.codigo and a.compania = c.compania and c.group_type in ('A') and a.centro is not null ");
 

	if (!fechaIni.trim().equals(""))
	{
	if(tipoFecha.trim().equals("A"))
	sbSql.append(" and trunc(a.fecha_aprob) >= to_date('");
	else sbSql.append(" and trunc(a.fecha) >= to_date('");
	
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
	}
	if (!fechaFin.trim().equals(""))
	{
	if(tipoFecha.trim().equals("A"))
	sbSql.append(" and trunc(a.fecha_aprob) <= to_date('");
	else sbSql.append(" and trunc(a.fecha) <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
	}
	if(!factId.trim().equals(""))
	{
		sbSql.append(" and a.factura = '");
		sbSql.append(factId);
		sbSql.append("'");
	}
	sbSql.append(" and a.factura = f.codigo and a.compania = f.compania");

if(!fg.trim().equals(""))
{
	sbSql.append(" and a.tipo_doc = '");
	sbSql.append(fg);
	sbSql.append("'");
}
if(!aseguradora.trim().equals(""))
{
	sbSql.append(" and f.cod_empresa =");
	sbSql.append(aseguradora);
}

sbSql.append(" group by  a.centro,a.service_type,a.compania,f.adm_type,decode(f.adm_type,'I','IP','OP') having sum(decode(a.lado_mov,'D',nvl(a.monto,0),'C',-nvl(a.monto,0))) <> 0");
sbSql.append(" order by a.centro ");



al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "AJUSTES X CENTROS DE SERVICIOS(INGRESOS) "+(!aseguradoraDesc.trim().equals("")?"   Y ASEG. ( "+aseguradora+" - "+aseguradoraDesc+" )":"");;
	String xtraSubtitle = "DEL "+fechaIni+"  AL "+fechaFin ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

					
				Vector dHeader=new Vector();
					dHeader.addElement(".50");
					dHeader.addElement(".10");
					dHeader.addElement(".20");					
					dHeader.addElement(".20");
					

	

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("Tipo De Servicio",0,1);
		pc.addBorderCols("Tipo Adm",1,1);
		pc.addBorderCols("Cuenta",2,1);
		pc.addBorderCols("Monto",2,1);
	pc.setTableHeader(2);
			
			

	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0,totalCdsRecargo=0.0,totalRecargo=0.0;
	int totalCantidad = 0, totalCantidadCds =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(i!=0)
			{
				if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
				{
						//pc.setFont(0,1,Color.blue);
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(" ",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,1,0.5f,0.0f,0.0f,0.0f);
						totalCds =0.0;
						totalCantidadCds=0;
						pc.addCols(" ",0,dHeader.size());
						pc.setFont(fontSize, 0);
				}
			}
			
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
			{
				pc.setFont(fontSize, 0,Color.blue);
				pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				pc.setFont(fontSize, 0);
							

			}
			
			totalCds += Double.parseDouble(cdo.getColValue("monto"));
			totalTa  += Double.parseDouble(cdo.getColValue("monto"));
			monto  = Double.parseDouble(cdo.getColValue("monto"));
			total  += Double.parseDouble(cdo.getColValue("monto"));
			//totalCantidad  += Integer.parseInt(cdo.getColValue("cantidad"));
			//totalCantidadCds  += Integer.parseInt(cdo.getColValue("cantidad"));
			
			//pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] [ "+cdo.getColValue("cuenta")+" ]",0,1);
			pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] ",0,1);
			pc.addCols(""+cdo.getColValue("descAdmType"),1,1);
			pc.addCols(""+cdo.getColValue("cuenta"),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);
			
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("cds");
			//groupBy2 = cdo.getColValue("cds")+"-"+cdo.getColValue("adm_type");
	}

	

	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols("",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,1,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
						pc.addCols(" ",0,dHeader.size());
						
						pc.addBorderCols("TOTAL",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols("",2,1,0.5f,0.0f,0.0f,0.0f);//
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.5f,0.0f,0.0f,0.0f);//
						totalCds =0.0;
						
						
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>