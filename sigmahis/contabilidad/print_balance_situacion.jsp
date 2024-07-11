<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="accTotal" scope="page" class="java.util.Hashtable" />
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

ArrayList alA = new ArrayList();
ArrayList alP = new ArrayList();
CommonDataObject cdoPV = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fg = request.getParameter("fg");


if(anio==null) anio = "";
if(mes==null) mes = "";
sbFilter.append(" and a.compania = ");
sbFilter.append((String) session.getAttribute("_companyId"));
sbFilter.append(" and abs(monto_ini)+abs(monto_db)+abs(monto_cr) <> 0");

if(!anio.equals("")){
	sbFilter.append(" and a.ea_ano = ");
	sbFilter.append(anio);
}
if(!mes.equals("")){
	sbFilter.append(" and a.mes = ");
	sbFilter.append(mes);
}

sbSql.append("select nvl(sum(balance), 0) present_bal_gan_perdida from vw_con_catalogo_gral_bal a, tbl_con_cla_ctas c where a.tipo_cuenta = c.codigo_clase and c.codigo_prin in ('4','5','6') and recibe_mov = 'S'");
sbSql.append(sbFilter.toString());
cdoPV = SQLMgr.getData(sbSql.toString());
if(cdoPV==null){
	cdoPV = new CommonDataObject();
	cdoPV.addColValue("present_bal_gan_perdida", "0");
}
sbSql = new StringBuffer();
sbSql.append("select a.nivel, a.recibe_mov, a.num_cuenta, lpad(a.num_cuenta, length(a.num_cuenta)+nivel*4, ' ') num_cta, a.descripcion, a.balance from vw_con_catalogo_gral_bal a, tbl_con_cla_ctas c where a.tipo_cuenta = c.codigo_clase and c.codigo_prin = '1'");
sbSql.append(sbFilter.toString());
sbSql.append(" order by   a.num_cuenta");
alA = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select * from (select a.nivel, a.recibe_mov, a.num_cuenta, lpad(a.num_cuenta, length(a.num_cuenta)+nivel*4, ' ') num_cta, a.descripcion,balance from vw_con_catalogo_gral_bal a, tbl_con_cla_ctas c where a.tipo_cuenta = c.codigo_clase and c.codigo_prin in ('2', '3')");
sbSql.append(sbFilter.toString());
sbSql.append("union select 3 as nivel,'S' as recibe_mov,nvl(get_sec_comp_param("+((String) session.getAttribute("_companyId"))+", 'CTA_GANANCIAS_PERDIDAS'),'300.00.000') as num_cuenta,nvl(get_sec_comp_param("+((String) session.getAttribute("_companyId"))+", 'CTA_GANANCIAS_PERDIDAS'),'300.00.000') as num_cta,'GANANCIA PERDIDA CALCULADO' AS descripcion,");
sbSql.append(cdoPV.getColValue("present_bal_gan_perdida"));
sbSql.append(" BALANCE FROM DUAL) z");
sbSql.append(" order by num_cuenta");
alP = SQLMgr.getDataList(sbSql.toString());
cdoPV = SQLMgr.getData("select nvl(sum(balance),0) as pasivo_capital from ("+sbSql.toString()+") x where recibe_mov = 'S'");



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

	if (mes.equals("01")) mes = "ENERO";
	else if (mes.equals("02")) mes = "FEBRERO";
	else if (mes.equals("03")) mes = "MARZO";
	else if (mes.equals("04")) mes = "ABRIL";
	else if (mes.equals("05")) mes = "MAYO";
	else if (mes.equals("06")) mes = "JUNIO";
	else if (mes.equals("07")) mes = "JULIO";
	else if (mes.equals("08")) mes = "AGOSTO";
	else if (mes.equals("09")) mes = "SEPTIEMBRE";
	else if (mes.equals("10")) mes = "OCTUBRE";
	else if (mes.equals("11")) mes = "NOVIEMBRE";
	else mes = "DICIEMBRE";

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
	String title = "BALANCE DE SITUACION";
	String subtitle = mes + " de " + anio ;//cdo1.getColValue("fecha");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".30");
		infoCol.addElement(".55");
		infoCol.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table


	//table body
	String groupBy = "";

	pc.setVAlignment(0);

	String spc = "";
	double totActive = 0.00;
	double totPassive = 0.00;
	int levelAcc = 0;

	pc.addBorderCols("ACTIVOS", 1, infoCol.size());

	if (alA.size() > 0){
		for (int i=0; i<alA.size(); i++){
			CommonDataObject acpd = (CommonDataObject) alA.get(i);

			if(levelAcc!=0 && levelAcc >= Integer.parseInt(acpd.getColValue("nivel"))){
				pc.setFont(7, 1);
				for(int k = levelAcc; k >= Integer.parseInt(acpd.getColValue("nivel")); k--){
					if(accTotal.containsKey(""+k)){
						spc="";
						CommonDataObject acpdt = (CommonDataObject) accTotal.get(""+k);
						for(int l=1; l<Integer.parseInt(acpdt.getColValue("nivel")); l++){spc+="  ";}
						pc.addCols(spc + "TOTAL DE "+ acpdt.getColValue("descripcion"), 0, 2);

						pc.addCols((Double.parseDouble(acpdt.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpdt.getColValue("balance")): (Double.parseDouble(acpdt.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpdt.getColValue("balance")) * -1)+")" :"",2,1);

						accTotal.remove(""+k);
					}
				}
			}
			pc.setFont(7, 0);
			spc="";
			if(acpd.getColValue("recibe_mov").equals("N")) pc.setFont(7,1);
				for(int l=1; l<Integer.parseInt(acpd.getColValue("nivel")); l++){spc+="   ";}
				pc.addCols(spc + acpd.getColValue("num_cuenta"), 0, 1);
				pc.addCols(acpd.getColValue("descripcion"), 0, 1);

				if(acpd.getColValue("recibe_mov").equals("S")){
					totActive += Double.parseDouble(acpd.getColValue("balance"));
					pc.addCols((Double.parseDouble(acpd.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpd.getColValue("balance")): (Double.parseDouble(acpd.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpd.getColValue("balance")) * -1)+")" :"",2,1);
				} else {
					pc.addCols("",0,1);
					accTotal.put(acpd.getColValue("nivel"),acpd);
				}

				//pc.addCols(spc + presBal,0,1);
			levelAcc = Integer.parseInt(acpd.getColValue("nivel"));
			if ((i + 1) == alA.size()){
				pc.setFont(7, 1);
				for(int k = 5; k >= 1; k--){
					if(accTotal.containsKey(""+k)){
						spc="";
						CommonDataObject acpdt = (CommonDataObject) accTotal.get(""+k);
							for(int l=1; l<Integer.parseInt(acpdt.getColValue("nivel")); l++){spc+="  ";}
							pc.addCols(spc + "TOTAL DE "+ acpdt.getColValue("descripcion"), 0, 2);
							pc.addCols((Double.parseDouble(acpdt.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpdt.getColValue("balance")): (Double.parseDouble(acpdt.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpdt.getColValue("balance")) * -1)+")" :"",2,1);
						accTotal.remove(""+k);
					}
				}

				break;
			}
			if ((i % 50 == 0) || ((i + 1) == alA.size())) pc.flushTableBody(true);
		}
	}
	pc.addBorderCols("PASIVOS Y CAPITAL", 1, infoCol.size());
	accTotal.clear();
	if (alP.size() > 0){
		for (int i=0; i<alP.size(); i++){
			CommonDataObject acpd = (CommonDataObject) alP.get(i);

			if(levelAcc!=0 && levelAcc >= Integer.parseInt(acpd.getColValue("nivel"))){
				pc.setFont(7, 1);
				for(int k = levelAcc; k >= Integer.parseInt(acpd.getColValue("nivel")); k--){
					if(accTotal.containsKey(""+k)){
						spc="";
						CommonDataObject acpdt = (CommonDataObject) accTotal.get(""+k);
						for(int l=1; l<Integer.parseInt(acpdt.getColValue("nivel")); l++){spc+="  ";}
						pc.addCols(spc + "TOTAL DE "+ acpdt.getColValue("descripcion"), 0, 2);

						pc.addCols((Double.parseDouble(acpdt.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpdt.getColValue("balance")): (Double.parseDouble(acpdt.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpdt.getColValue("balance")) * -1)+")" :"",2,1);

						accTotal.remove(""+k);
					}
				}
			}
			pc.setFont(7, 0);
			spc="";
			if(acpd.getColValue("recibe_mov").equals("N")) pc.setFont(7,1);
				for(int l=1; l<Integer.parseInt(acpd.getColValue("nivel")); l++){spc+="   ";}
				pc.addCols(spc + acpd.getColValue("num_cuenta"), 0, 1);
				pc.addCols(acpd.getColValue("descripcion"), 0, 1);

				if(acpd.getColValue("recibe_mov").equals("S")){
					totActive += Double.parseDouble(acpd.getColValue("balance"));
					pc.addCols((Double.parseDouble(acpd.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpd.getColValue("balance")): (Double.parseDouble(acpd.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpd.getColValue("balance")) * -1)+")" :"",2,1);
				} else {
					pc.addCols("",0,1);
					accTotal.put(acpd.getColValue("nivel"),acpd);
				}

				//pc.addCols(spc + presBal,0,1);
			levelAcc = Integer.parseInt(acpd.getColValue("nivel"));
			if ((i + 1) == alP.size()){
				pc.setFont(7, 1);
				for(int k = 5; k >= 1; k--){
					if(accTotal.containsKey(""+k)){
						spc="";
						CommonDataObject acpdt = (CommonDataObject) accTotal.get(""+k);
							for(int l=1; l<Integer.parseInt(acpdt.getColValue("nivel")); l++){spc+="  ";}
							pc.addCols(spc + "TOTAL DE "+ acpdt.getColValue("descripcion"), 0, 2);
							pc.addCols((Double.parseDouble(acpdt.getColValue("balance")) > 0.00)? CmnMgr.getFormattedDecimal(acpdt.getColValue("balance")): (Double.parseDouble(acpdt.getColValue("balance")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(acpdt.getColValue("balance")) * -1)+")" :"",2,1);
						accTotal.remove(""+k);
					}
				}
				pc.addCols("TOTAL DE PASIVO Y CAPITAL", 0, 2);
				pc.addCols((Double.parseDouble(cdoPV.getColValue("pasivo_capital")) > 0.00)? CmnMgr.getFormattedDecimal(cdoPV.getColValue("pasivo_capital")): (Double.parseDouble(cdoPV.getColValue("pasivo_capital")) < 0.00)? "("+CmnMgr.getFormattedDecimal(Double.parseDouble(cdoPV.getColValue("pasivo_capital")) * -1)+")" :"",2,1);

				break;
			}
			if ((i % 50 == 0) || ((i + 1) == alP.size())) pc.flushTableBody(true);
		}
	}



	if (alA.size() == 0 && alP.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>