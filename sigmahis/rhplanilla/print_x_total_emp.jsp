<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
PLANILLA: PLA0124
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
String sql = "", sql2 = "";

String _option = request.getParameter("opt");
String anio_ini = request.getParameter("anio_i");
String mes_ini = request.getParameter("mes_i");
String anio_fin = request.getParameter("anio_f");
String mes_fin = request.getParameter("mes_f");
String subTitle = "";

Hashtable _mes = new Hashtable();

if (mes_ini != null ){
  _mes.put("01","Enero");
  _mes.put("02","Febrero");
  _mes.put("03","Marzo");
  _mes.put("04","Abril");
  _mes.put("05","Mayo");
  _mes.put("06","Junio");
  _mes.put("07","Julio");
  _mes.put("08","Agosto");
  _mes.put("09","Septiembre");
  _mes.put("10","Octubre");
  _mes.put("11","Noviembre");
  _mes.put("12","Diciembre");
 }

if (_option == null || _option.equals("")) throw new Exception("La opción de impresión no es válida!");
if (anio_ini == null || anio_ini.equals("") || mes_ini == null || mes_ini.equals("") || anio_fin == null || anio_fin.equals("") || mes_fin == null || mes_fin.equals("")) throw new Exception("El año o el mes no es válido!");

StringBuffer sbSql  = new StringBuffer();
StringBuffer sbSql2 = new StringBuffer(); 

if (_option.equalsIgnoreCase("x_tot_emp")) {
	String comma = " ,";
     subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS - GENERAL";

		sbSql.append( "SELECT D.NOMBRE, a.anio , ");
		for ( int m = 1; m<=12; m++ ){	
			 if ( m==12) {comma = "";}
			 sbSql.append(" count( decode(a.mes, "+m+",to_char(to_date(a.mes,'mm'),'FMMonth','NLS_DATE_LANGUAGE=SPANISH') ,'')) "+_mes.get((m>=10?""+m:"0"+m))+comma+"");
		}//for	 

		sbSql.append( " FROM tbl_pla_emp_estadist_mes a, tbl_sec_COMPANIA D WHERE (D.CODIGO = A.COMPANIA) AND (A.COMPANIA = "+compania+") and (to_date(a.anio||'-'||a.mes,'yyyy-mm') >= to_date("+anio_ini+"||'-'||"+mes_ini+",'yyyy-mm')) and (to_date(a.anio||'-'||a.mes,'yyyy-mm') <= to_date("+anio_fin+"||'-'||"+mes_fin+",'yyyy-mm'))  group  by D.NOMBRE, a.anio order by anio");
}else{
//x_tot_emp_dept
String comma = " ,";
		subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS POR SECCIÓN";

		sbSql.append( "SELECT a.anio , d.descripcion , ");
		for ( int m = 1; m<=12; m++ ){	
			 if ( m==12) {comma = "";}
			 sbSql.append(" count( decode(a.mes, "+m+",to_char(to_date(a.mes,'mm'),'FMMonth','NLS_DATE_LANGUAGE=SPANISH') ,'')) "+_mes.get((m>=10?""+m:"0"+m))+comma+"");
		}//for	 

		sbSql.append( " from tbl_pla_emp_estadist_mes a, tbl_sec_unidad_ejec d where (a.compania = "+compania+") and (a.unidad = d.codigo) and a.compania =  d.compania and (to_date(a.anio||'-'||a.mes,'yyyy-mm') >= to_date("+anio_ini+"||'-'||"+mes_ini+",'yyyy-mm')) and (to_date(a.anio||'-'||a.mes,'yyyy-mm') <= to_date("+anio_fin+"||'-'||"+mes_fin+",'yyyy-mm')) group by a.anio, d.descripcion order by anio, descripcion");

}


al = SQLMgr.getDataList(sbSql.toString());

String mas = "+";
ArrayList al2 =  new ArrayList();
Hashtable iTot = new Hashtable();
int totFinal = 0;

if (_option.equalsIgnoreCase("x_tot_emp")) {
	sbSql2.append( "select anio, sum(");
	for ( int t = 1; t<=12; t++ ){	
	  if ( t==12){mas="";}
	  sbSql2.append(""+_mes.get((t>=10?""+t:"0"+t))+mas+" ");
	}   
	sbSql2.append( " ) totxmes from( "+sbSql.toString()+") group by anio order by anio");
}else{
String comma = " ,";
	sbSql2.append( "select anio, ");
	for ( int t = 1; t<=12; t++ ){	
	  if ( t==12){comma = "";}
	  sbSql2.append(" sum( "+_mes.get((t>=10?""+t:"0"+t))+"");
	  sbSql2.append(" ) "+_mes.get((t>=10?""+t:"0"+t))+"");
	  sbSql2.append(comma);  
	}
	
	sbSql2.append(" from( "+sbSql.toString()+") group by anio order by anio");
}

al2 = SQLMgr.getDataList(sbSql2.toString());

if (_option.equalsIgnoreCase("x_tot_emp")) {
	for ( int tot = 0; tot<al2.size(); tot++ ){
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2 = (CommonDataObject)al2.get(tot);
		iTot.put(cdo2.getColValue("anio"),cdo2.getColValue("totxmes"));
		totFinal += Integer.parseInt(cdo2.getColValue("totxmes"));	
	}
}else{

}	

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
	float height = 72 *14f;//1008
	boolean isLandscape = true;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	boolean logoMark = true;
	boolean statusMark = false;
	StringBuffer sbFooter = new StringBuffer();
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = "DE "+""+_mes.get(mes_ini).toString().toUpperCase()+" DE "+anio_ini+" A "+""+_mes.get(mes_fin).toString().toUpperCase()+" DE  "+anio_fin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".30");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	String anio = "";
	String groupAnio = "";
	String nMes = "";
	int totXmes = 0;
	int enero = 0, febrero = 0, marzo = 0, abril = 0, mayo = 0, junio = 0, julio = 0, agosto = 0, sept = 0, oct = 0, nov = 0, dic = 0;

	
	if ( al.size() == 0 ) { 
	
	   pc.setFont(9,0);
	   pc.addCols("No hemos encontrado registros!!! ",1,dHeader.size());
	
	}else{
	   pc.setFont(9,0);
	   
	   if (!_option.equalsIgnoreCase("x_tot_emp")) {
			pc.setTableHeader(2);
		}
	   
		        for ( int i = 0; i<al.size(); i++ ){
	                  cdo = (CommonDataObject)al.get(i);
					  
					  if ( !anio.equals(cdo.getColValue("anio")) ){
							for ( int m = 1; m<=12; m++ ){
									if ( m == 1 ){
										pc.addCols((_option.equals("x_tot_emp")?"Compañia":"Unidad Admin."),0,1);
									}
									pc.addCols(""+_mes.get((m<=9?"0"+m:""+m)),0,1);
							}
							pc.addCols((_option.equals("x_tot_emp")?"T.Mes":""),0,1);
							
							if (!_option.equalsIgnoreCase("x_tot_emp")) {
								pc.addCols("    Año  : "+cdo.getColValue("anio"),2,1,Color.lightGray);
								pc.addCols("  ",0,dHeader.size()-1,Color.lightGray);
							}
							
							pc.addNewPage();
					  }
					  
							 pc.addCols((_option.equals("x_tot_emp")?""+cdo.getColValue("nombre")+" [ "+cdo.getColValue("anio")+"]":""+cdo.getColValue("descripcion")),0,1);
							 pc.addCols(""+cdo.getColValue("enero"),0,1);
							 pc.addCols(""+cdo.getColValue("febrero"),0,1);
							 pc.addCols(""+cdo.getColValue("marzo"),0,1);
							 pc.addCols(""+cdo.getColValue("abril"),0,1);
							 pc.addCols(""+cdo.getColValue("mayo"),0,1);
							 pc.addCols(""+cdo.getColValue("junio"),0,1);
							 pc.addCols(""+cdo.getColValue("julio"),0,1);
							 pc.addCols(""+cdo.getColValue("agosto"),0,1);
							 pc.addCols(""+cdo.getColValue("septiembre"),0,1);
							 pc.addCols(""+cdo.getColValue("octubre"),0,1);
							 pc.addCols(""+cdo.getColValue("noviembre"),0,1);
							 pc.addCols(""+cdo.getColValue("diciembre"),0,1);
							 pc.addCols((_option.equals("x_tot_emp")?""+iTot.get(cdo.getColValue("anio")):""));
					         pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",1,dHeader.size(),15f);
				anio = cdo.getColValue("anio");
				
				if (!_option.equalsIgnoreCase("x_tot_emp")) {
				   enero += Integer.parseInt(cdo.getColValue("enero"));
				   febrero += Integer.parseInt(cdo.getColValue("febrero"));
				   marzo += Integer.parseInt(cdo.getColValue("marzo"));
				   abril += Integer.parseInt(cdo.getColValue("abril"));
				   mayo += Integer.parseInt(cdo.getColValue("mayo"));
				   junio += Integer.parseInt(cdo.getColValue("junio"));
				   julio += Integer.parseInt(cdo.getColValue("julio"));
				   agosto += Integer.parseInt(cdo.getColValue("agosto"));
				   sept += Integer.parseInt(cdo.getColValue("septiembre"));
				   oct += Integer.parseInt(cdo.getColValue("octubre"));
				   nov += Integer.parseInt(cdo.getColValue("noviembre"));
				   dic += Integer.parseInt(cdo.getColValue("diciembre"));
				}
				pc.addNewPage();
				} //for   
				
				pc.addNewPage();
				pc.setFont(9,1);
				
				if ( _option.equals("x_tot_emp") ){
					pc.addCols("Total Final: ",2,13);
					pc.addCols(""+totFinal,1,dHeader.size()-13);
				}else{
				    pc.addCols("Totales Finales: ",2,1);
					pc.addCols(""+enero,0,1);
					pc.addCols(""+febrero,0,1);
					pc.addCols(""+marzo,0,1);
					pc.addCols(""+abril,0,1);
					pc.addCols(""+mayo,0,1);
					pc.addCols(""+junio,0,1);
					pc.addCols(""+julio,0,1);
					pc.addCols(""+agosto,0,1);
					pc.addCols(""+sept,0,1);
					pc.addCols(""+oct,0,1);
					pc.addCols(""+nov,0,1);
					pc.addCols(""+dic,0,1);
					pc.addCols(" ",0,1);
				}
			
			
			
	}//else
	
	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
