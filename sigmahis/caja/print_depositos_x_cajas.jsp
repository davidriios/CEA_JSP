<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
Reporte cja71010.rdf
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
String fecha_ini = request.getParameter("xDate");
String fechafin = request.getParameter("fechafin");

if (appendFilter == null) appendFilter = "";
if (fechafin == null) fechafin = "";
if (fecha_ini == null) fecha_ini = "";

sbSql.append("select rep.fecha,rep.caja,rep.usuario cjausuario,rep.turno cod_turno,rep.cta1,rep.cta2,rep.cta3,rep.cta4,rep.cta5,rep.cta6,rep.lado lado, g.descripcion, sum(nvl(nvl(rep.totales_new,rep.totales),0) )  monto,nvl(c.descripcion,'S/C') desccaja,nvl((select to_char(tc.fecha_creacion,'DD/MM/YYYY') from tbl_cja_turnos_x_cajas tc where tc.compania=rep.compania  and tc.cod_caja =rep.caja and tc.cod_turno =rep.turno),' ') f_turno from tbl_con_replibros rep,tbl_con_catalogo_gral g,tbl_cja_cajas c where rep.compania = ");
sbSql.append(session.getAttribute("_companyId"));

if(!fecha_ini.trim().equals("")){sbSql.append(" and trunc(rep.fecha) >= to_date('");sbSql.append(fecha_ini);sbSql.append("','dd/mm/yyyy')");}
if(!fechafin.trim().equals("")){sbSql.append(" and trunc(rep.fecha) <= to_date('");sbSql.append(fechafin);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and rep.compania = g.compania and rep.cta1= g.cta1 and rep.cta2 = g.cta2 and rep.cta3 = g.cta3 and rep.cta4 = g.cta4 and rep.cta5 = g.cta5 and rep.cta6 = g.cta6 and rep.caja = c.codigo(+) and rep.compania = c.compania(+) group by  rep.fecha,rep.caja,rep.turno,rep.usuario,rep.cta1,rep.cta2, rep.cta3,rep.cta4,rep.cta5,rep.cta6,rep.lado,g.descripcion,nvl(c.descripcion,'S/C'),rep.compania order by rep.caja,rep.turno,rep.fecha");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

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
	String title = "LIBRO DE CAJA POR CUENTA";
	String subtitle = "DEL:   "+fecha_ini+"   AL   "+fechafin;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".04");
					dHeader.addElement(".04");
					dHeader.addElement(".04");
					dHeader.addElement(".04");
					dHeader.addElement(".04");
					dHeader.addElement(".04");

					dHeader.addElement(".32");
					dHeader.addElement(".15");
					dHeader.addElement(".15");
					dHeader.addElement(".14");



	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	String lado = "CR";
	Double monto =0.0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")+"-"+cdo.getColValue("cod_turno")))
			{
				pc.addCols("CAJA:   "+cdo.getColValue("caja")+"   "+cdo.getColValue("descCaja"),0,7);
				pc.addCols("TURNO:  "+cdo.getColValue("cod_turno")+"  - Fecha: "+cdo.getColValue("f_turno") ,0,3);
				//pc.addCols("",0,dHeader.size());

				pc.addBorderCols("CUENTA",0,6);
				pc.addBorderCols("DESCRIPCION",0,1);
				pc.addBorderCols("TOTALES DB",2,1);
				pc.addBorderCols("TOTALES CR",2,1);
				pc.addBorderCols("USUARIO",1,1);

			//print_depositos_x_cajas.jsp
			}

			monto = Double.parseDouble(cdo.getColValue("monto"));
			if (monto<0 )monto = monto *-1;
			pc.addCols(""+cdo.getColValue("cta1"),0,1);
			pc.addCols(""+cdo.getColValue("cta2"),0,1);
			pc.addCols(""+cdo.getColValue("cta3"),0,1);
			pc.addCols(""+cdo.getColValue("cta4"),0,1);
			pc.addCols(""+cdo.getColValue("cta5"),0,1);
			pc.addCols(""+cdo.getColValue("cta6"),0,1);

			pc.addCols(""+cdo.getColValue("descripcion"),0,1);
			
			if (lado.equalsIgnoreCase(cdo.getColValue("lado")))
			{
			pc.addCols("",2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);
			} else {
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);
			pc.addCols("",2,1);
			}
			pc.addCols(""+cdo.getColValue("cjausuario"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("caja")+"-"+cdo.getColValue("cod_turno");
	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>