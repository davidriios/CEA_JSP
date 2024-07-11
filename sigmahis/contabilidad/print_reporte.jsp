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
ArrayList alT = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoTitle = new CommonDataObject();

String sql = "";
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fg = request.getParameter("fg");
String repCode = request.getParameter("repCode");
String tipoRep = request.getParameter("tipoRep");
String level = request.getParameter("nivel");
String mostrarDetalle = request.getParameter("mostrarDetalle");

if(anio == null || anio=="") anio = CmnMgr.getCurrentDate("yyyy");
if(mes == null || mes=="") mes = CmnMgr.getCurrentDate("mm");
if (fg == null) fg = "";
if (mostrarDetalle == null) mostrarDetalle = "";


if (tipoRep == null || tipoRep=="") tipoRep = "D";
cdo1 = SQLMgr.getData("select 'AL ' || to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DEL "+anio+"' fecha from dual");
cdoTitle = SQLMgr.getData("select descripcion from tbl_con_reporte where compania = "+(String) session.getAttribute("_companyId")+" and codigo = "+repCode);

sql = "select g.orden, g.codigo, g.descripcion nombre_grupo, g.nota, decode(nvl(d.cod_grupo_rel, 0), 0, c.descripcion, (select descripcion from vw_con_catalogo_gral where num_cuenta = d.cuenta)) nombre_cta, c.lado_movim, decode(nvl(d.cod_grupo_rel, 0), 0, c.nivel, (select b.nivel from vw_con_catalogo_gral b where d.cuenta = b.num_cuenta)) nivel, d.nota, d.cod_grupo, nvl(g.aum_dis, '.') aum_dis, decode(nvl(d.cod_grupo_rel, 0), 0, c.num_cuenta, d.cuenta) num_cuenta, d.cod_rep, round(decode(nvl(d.cod_grupo_rel, 0), 0, c.balance_corriente, nvl(getbalancectas (d.compania, "+anio+", "+mes+", d.cod_rep, d.cod_grupo_rel, d.cuenta), 0)), 2) * (decode(c.lado_movim, 'DB', 1, -1)) saldo, nvl(substr (c.cta1, 1, 1), '0') cta, g.es_total tipo_linea, c.cuentas, decode(d.cuenta, c.num_cuenta, 'S', decode(nvl(d.cod_grupo_rel, 0), 0, 'N', 'S')) acumular from tbl_con_grupos_rep g, tbl_con_detalle_rep d, vw_con_catalogo_gral_bal c where g.cod_rep = d.cod_rep(+) and g.codigo = d.cod_grupo(+) and g.compania = d.compania(+) and g.compania = "+(String) session.getAttribute("_companyId") +" and c.ea_ano(+) = "+anio+" and c.mes(+) = "+mes+" and g.cod_rep = "+repCode+" and c.num_cuenta(+) like d.cuenta"+(mostrarDetalle.equals("S")?" || '%'":"")+" and c.compania(+) = d.compania and g.secuencia_rel = 0 "+(tipoRep.equals("R")?"":" /*and c.nivel(+) <= "+level+"*/")+" order by g.orden, c.num_cuenta, g.descripcion";

if(tipoRep.equals("R")){
	sql = "select   orden, codigo, nombre_grupo, tipo_linea, aum_dis, nvl(sum(saldo), 0) saldo from ("+sql+") group by orden, codigo, nombre_grupo, tipo_linea, aum_dis order by orden";
}

al = SQLMgr.getDataList(sql);

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
	String title = cdoTitle.getColValue("descripcion");
	String subtitle = cdo1.getColValue("fecha");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".13");
		infoCol.addElement(".36");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".08");
		infoCol.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	String descTotal = "";
	pc.setVAlignment(0);
	boolean printTotal = true, printMontoTotal = false, printPasivo = true, printPasivoCapital = true, printSubTotal = false;
	double saldo = 0.00, saldoGrupo = 0.00, saldoTotales = 0.00, tnivel1=0.00, tnivel2=0.00, tnivel3=0.00, tnivel4=0.00, tnivel5=0.00, tnivel6=0.00;
	int nivel = 0;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(cdo.getColValue("tipo_linea").equals("S")){
			pc.setFont(7, 0);

			if(tipoRep.equals("D")){
			pc.addBorderCols("",2,2,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel6),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel5),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel4),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel3),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel2),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel1),2,1,0.0f,0.1f,0.0f,0.0f);
			} else {
			pc.addBorderCols("",2,8,0.0f,0.1f,0.0f,0.0f);
			}
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldoGrupo),2,1,0.0f,0.1f,0.0f,0.0f);
			printSubTotal = false;

			pc.addCols(cdo.getColValue("nombre_grupo"),0,7);
			pc.setFont(7, 1);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo),2,2,0.0f,0.0f,0.0f,0.0f);
			saldo = 0.00;

			saldoTotales += (saldoGrupo*(cdo.getColValue("aum_dis").equals("-")?-1:1));

			saldoGrupo = 0.00;
			tnivel1 = 0.00;
			tnivel2 = 0.00;
			tnivel3 = 0.00;
			tnivel4 = 0.00;
			tnivel5 = 0.00;
			tnivel6 = 0.00;
		} else if(cdo.getColValue("tipo_linea").equals("T")){
			pc.setFont(7, 1);
			
			if(i!=0 && printSubTotal){
				if(tipoRep.equals("D")){
					pc.addBorderCols(" ",2,2,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel6),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel5),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel4),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel3),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel2),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel1),2,1,0.0f,0.1f,0.0f,0.0f);
				} else {
				pc.addBorderCols("",2,8,0.0f,0.1f,0.0f,0.0f);
				}
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldoGrupo),2,1,0.0f,0.1f,0.0f,0.0f);
					
				pc.addCols(" ",0,infoCol.size());
				saldoTotales += (saldoGrupo*(cdo.getColValue("aum_dis").equals("-")?-1:1));
				saldoGrupo = 0.00;
				tnivel1 = 0.00;
				tnivel2 = 0.00;
				tnivel3 = 0.00;
				tnivel4 = 0.00;
				tnivel5 = 0.00;
				tnivel6 = 0.00;
				printSubTotal=false;
			}
			if(printMontoTotal) {
				pc.addCols("TOTAL "+descTotal+ " = "+CmnMgr.getFormattedDecimal(saldoTotales),0,infoCol.size());
				saldoTotales = 0.00;
			}
			pc.addCols(cdo.getColValue("nombre_grupo"),1,infoCol.size());
			descTotal = cdo.getColValue("nombre_grupo");
			printMontoTotal = true;
		} else {
			
			if((tipoRep.equals("D") && cdo.getColValue("acumular")!=null && cdo.getColValue("acumular").equals("S") && cdo.getColValue("saldo")!=null && !cdo.getColValue("saldo").equals("")) || (tipoRep.equals("R") && cdo.getColValue("saldo")!=null && !cdo.getColValue("saldo").equals(""))) saldo += Double.parseDouble(cdo.getColValue("saldo"));
			
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codigo"))){ // groupBy
				pc.setFont(7, 0);
				if(i!=0 && printSubTotal){
					if(tipoRep.equals("D")){
						pc.addBorderCols(" ",2,2,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel6),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel5),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel4),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel3),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel2),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel1),2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldoGrupo),2,1,0.0f,0.1f,0.0f,0.0f);
					} else {
					pc.addBorderCols("",2,9,0.0f,0.1f,0.0f,0.0f);
					}
					
					saldoTotales += (saldoGrupo*(cdo.getColValue("aum_dis").equals("-")?-1:1));
					saldoGrupo = 0.00;
					tnivel1 = 0.00;
					tnivel2 = 0.00;
					tnivel3 = 0.00;
					tnivel4 = 0.00;
					tnivel5 = 0.00;
					tnivel6 = 0.00;
				}
				if(tipoRep.equals("D")) printSubTotal = true;

				pc.addCols(" ",0,1,cHeight);
				pc.addCols(cdo.getColValue("nombre_grupo"),0,8);
				pc.addCols(" ",0,infoCol.size());
			}
	
			if(tipoRep.equals("D")){
				pc.setFont(6, 0);
				if(cdo.getColValue("nivel")!=null && !cdo.getColValue("nivel").equals("")) nivel = Integer.parseInt(cdo.getColValue("nivel"));
				else nivel = 0;
				pc.addCols(cdo.getColValue("num_cuenta"),0,1);
				pc.addCols(cdo.getColValue("nombre_cta"),0,1);
				if(nivel!=0){
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,(7-nivel));
				if(nivel>1)pc.addCols(" ",0,(nivel-1));
				} else pc.addCols(" ",0,6);
				pc.addCols(" ",0,1);
				//pc.addCols(" ",0,0);
			}
	
			groupBy = cdo.getColValue("codigo");
			if(tipoRep.equals("D") && cdo.getColValue("acumular")!=null && cdo.getColValue("acumular").equals("S") /*cdo.getColValue("nivel")!=null && cdo.getColValue("nivel").equals("1")*/){
				saldoGrupo += Double.parseDouble(cdo.getColValue("saldo"));
				//saldoTotales += Double.parseDouble(cdo.getColValue("saldo"));
			} else if(tipoRep.equals("R") && cdo.getColValue("saldo")!=null && !cdo.getColValue("saldo").equals("")){
				saldoGrupo += Double.parseDouble(cdo.getColValue("saldo"));
				//saldoTotales += Double.parseDouble(cdo.getColValue("saldo"));
			}
			if(cdo.getColValue("nivel")!=null && !cdo.getColValue("nivel").equals("")){
				if(cdo.getColValue("nivel").equals("1")) tnivel1 += Double.parseDouble(cdo.getColValue("saldo"));
				else if(cdo.getColValue("nivel").equals("2")) tnivel2 += Double.parseDouble(cdo.getColValue("saldo"));
				else if(cdo.getColValue("nivel").equals("3")) tnivel3 += Double.parseDouble(cdo.getColValue("saldo"));
				else if(cdo.getColValue("nivel").equals("4")) tnivel4 += Double.parseDouble(cdo.getColValue("saldo"));
				else if(cdo.getColValue("nivel").equals("5")) tnivel5 += Double.parseDouble(cdo.getColValue("saldo"));
				else if(cdo.getColValue("nivel").equals("6")) tnivel6 += Double.parseDouble(cdo.getColValue("saldo"));
			}
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	if(al.size()>0){
	
	if(tipoRep.equals("R"))
	{
		if(printSubTotal)
		{
			//pc.addBorderCols(" ",2,4,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(" ",2,2,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel6),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel5),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel4),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel3),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel2),2,1,0.0f,0.1f,0.0f,0.0f);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(tnivel1),2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldoGrupo),2,1,0.0f,0.1f,0.0f,0.0f);
			//pc.addCols(""+CmnMgr.getFormattedDecimal(saldoGrupo),2,1);
			//pc.addCols(" ",0,1);
			
			pc.addCols(" ",0,infoCol.size());
			saldoGrupo = 0.00;
		}
	}
		if(printMontoTotal) {
			pc.setFont(7, 1);
			pc.addCols("TOTAL "+descTotal+ " = "+CmnMgr.getFormattedDecimal(saldoTotales),0,infoCol.size());
			saldoTotales = 0.00;
		}
		
		
	}
	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>