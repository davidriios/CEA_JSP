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
String sql = "";

String _option = request.getParameter("opt");
String anio_ini = request.getParameter("anio_i");
String mes_ini = request.getParameter("mes_i");
String anio_fin = request.getParameter("anio_f");
String mes_fin = request.getParameter("mes_f");
String subTitle = "";

Hashtable _mes = new Hashtable();

if (mes_ini != null ){
  _mes.put("01","ENERO");
  _mes.put("02","FEBRERO");
  _mes.put("03","MARZO");
  _mes.put("04","ABRIL");
  _mes.put("05","MAYO");
  _mes.put("06","JUNIO");
  _mes.put("07","JULIO");
  _mes.put("08","AGOSTO");
  _mes.put("09","SEPTIEMBRE");
  _mes.put("10","OCTUBRE");
  _mes.put("11","NOVIEMBRE");
  _mes.put("12","DICIEMBRE");
 }

if (_option == null || _option.equals("")) throw new Exception("La opción de impresión no es válida!");
if (anio_ini == null || anio_ini.equals("") || mes_ini == null || mes_ini.equals("") || anio_fin == null || anio_fin.equals("") || mes_fin == null || mes_fin.equals("")) throw new Exception("El año o el mes no es válido!");

if (_option.equalsIgnoreCase("x_est_dept")) {
     subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS POR SECCIÓN";
	
	sql = "SELECT X.UNIDAD, X.DESCRIPCION, COUNT(x.comp) COMP, COUNT(x.MEDIO) MEDIO, COUNT(x.DEF) DEF, COUNT(X.TRAB) TRAB, COUNT(X.AUS) AUS, COUNT(X.VAC) VAC, COUNT(X.LSS) LSS,count(x.lxg) lxg, count(rpr) rpr, count(*) tot_x_mes from((SELECT ALL a.compania, a.anio, a.mes, a.estado, a.unidad, c.descripcion, TO_CHAR(TO_DATE(A.MES,'mm'),'FMMonth','NLS_DATE_LANGUAGE=SPANISH')  NOMBRE_MES, DECODE(A.ESTADO,1,'TRAB','') TRAB, DECODE(A.ESTADO,2,'VAC','') VAC, DECODE(A.ESTADO,4,'LSS','') LSS, DECODE(A.ESTADO,7,'LXG','') LXG, DECODE(A.ESTADO,8,'RPR','') RPR, DECODE(A.ESTADO,12,'AUS','') AUS, SUBSTR(B.DESCRIPCION,1,4) DSP_ESTADO, DECODE(d.cant_horas,8,'COMP','') COMP, DECODE(d.cant_horas,4,'MEDIO','') MEDIO, DECODE(d.cant_horas,8,'',4,'','DEF') DEF FROM tbl_pla_EMP_ESTADIST_MES A, TBL_SEC_UNIDAD_EJEC C, TBL_PLA_ESTADO_EMP B, TBL_PLA_HORARIO_TRAB D  WHERE (A.COMPANIA = C.COMPANIA) AND (A.unidad = C.CODIGO) AND (A.ESTADO = B.CODIGO) AND (A.COMPANIA = "+compania+") and  (to_date(a.anio||'-'||a.mes,'yyyy-mm')    >=  to_date("+anio_ini+"||'-'||"+mes_ini+",'yyyy-mm')) and  (to_date(a.anio||'-'||a.mes,'yyyy-mm')     <=  to_date("+anio_fin+"||'-'||"+mes_ini+",'yyyy-mm')) and a.horario = d.codigo(+) and a.compania = d.compania(+) order by C.DESCRIPCION, a.ESTADO )X) group by unidad,descripcion order by unidad";
}
else
{
	subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS";
	
	sql = "SELECT x.anio, x.mes, x.nombre_mes, COUNT(x.comp) COMP, COUNT(x.MEDIO) MEDIO, COUNT(x.DEF) DEF, COUNT(X.TRAB) TRAB, COUNT(X.AUS) AUS, COUNT(X.VAC) VAC, COUNT(X.LSS) LSS, COUNT(x.lxg) lxg, COUNT(rpr) rpr, COUNT(*) tot_x_mes FROM(( SELECT ALL A.COMPANIA, a.anio, a.mes, a.estado, TO_CHAR(TO_DATE(A.MES,'mm'),'FMMonth','NLS_DATE_LANGUAGE=SPANISH')  NOMBRE_MES, DECODE(A.ESTADO,1,'TRAB','') TRAB, DECODE(A.ESTADO,2,'VAC','') VAC, DECODE(A.ESTADO,4,'LSS','') LSS, DECODE(A.ESTADO,7,'LXG','') LXG, DECODE(A.ESTADO,8,'RPR','') RPR, DECODE(A.ESTADO,12,'AUS','') AUS, DECODE(b.cant_horas,8,'COMP','') COMP, DECODE(b.cant_horas,4,'MEDIO','') MEDIO, DECODE(b.cant_horas,8,'',4,'','DEF') DEF FROM cellbytedump.TBL_PLA_EMP_ESTADIST_MES A, TBL_PLA_HORARIO_TRAB b WHERE (A.COMPANIA = "+compania+") AND  (TO_DATE(A.ANIO||'-'||A.MES,'yyyy-mm')    >=  TO_DATE("+anio_ini+"||'-'||"+mes_ini+",'yyyy-mm')) AND  (TO_DATE(a.anio||'-'||a.mes,'yyyy-mm')  <=  TO_DATE("+anio_fin+"||'-'||"+mes_fin+",'yyyy-mm'))  AND a.horario = b.codigo(+) AND a.compania = b.compania(+) ORDER BY a.anio, a.mes )X) GROUP BY  anio, mes, nombre_mes ORDER BY anio, mes";
	
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
	float height = 72 *11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = "DE "+_mes.get(mes_ini)+" DE "+anio_ini+" A "+_mes.get(mes_fin)+" DE  "+anio_fin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".07");
	dHeader.addElement(".23");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	dHeader.addElement(".07");
	
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	int comp = 0, medio = 0, def = 0, trab = 0, aus = 0, vac = 0, lss = 0, lxg = 0, rpr = 0, tot_x_mes = 0;
	String anio = "";	
	
	
	if ( al.size() == 0 ){
		pc.setFont(9,1);
		pc.addCols("No hemos encontrado datos!!!",1,dHeader.size());
	}else{
		pc.setFont(8,0);
		
	    if ( _option.equalsIgnoreCase("x_est_dept") ){	
			pc.addBorderCols(" ",0,2,0.0f,0.1f,0.1f,0.0f);
			pc.addBorderCols("Año\nMes :  "+"DE "+_mes.get(mes_ini)+" DE "+anio_ini,0,10,0.1f,0.1f,0.1f,0.1f);
			
			pc.addBorderCols("Unidad",0,1,0.1f,0.0f,0.1f,0.0f);
			pc.addBorderCols("Departamento",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("T/Comp.",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("1/2 Tiempo",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("T/Defin",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("TRAB",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("AUSE",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("VAC",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("LSS",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("LXG",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("RPR",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("Tot Mes",1,1,0.1f,0.1f,0.1f,0.1f);
		
		}else{
			
			pc.addBorderCols("Año   /    Mes",0,2,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("T/Comp.",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("1/2 Tiempo",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("T/Defin",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("TRAB",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("AUSE",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("VAC",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("LSS",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("LXG",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("RPR",1,1,0.1f,0.1f,0.1f,0.1f);
			pc.addBorderCols("Tot Mes",1,1,0.1f,0.1f,0.1f,0.1f);
			
		}
		
		for ( int i = 0; i<al.size(); i++ ){
			
			cdo = (CommonDataObject)al.get(i);
			
			if ( !_option.equalsIgnoreCase("x_est_dept") ){	
				
				if ( !cdo.getColValue("anio").equals(anio) ){
				    if ( i != 0 ){
				        pc.addCols(" ",1,dHeader.size());
					}
				}
				
				pc.addCols(""+(!cdo.getColValue("anio").equals(anio)?cdo.getColValue("anio")+"   /  ":"              ")+cdo.getColValue("nombre_mes"),0,2);
				pc.addCols(""+cdo.getColValue("comp"),1,1);
				pc.addCols(""+cdo.getColValue("medio"),1,1);
				pc.addCols(""+cdo.getColValue("def"),1,1);
				pc.addCols(""+cdo.getColValue("trab"),1,1);
				pc.addCols(""+cdo.getColValue("aus"),1,1);
				pc.addCols(""+cdo.getColValue("vac"),1,1);
				pc.addCols(""+cdo.getColValue("lss"),1,1);
				pc.addCols(""+cdo.getColValue("lxg"),1,1);
				pc.addCols(""+cdo.getColValue("rpr"),1,1);
				pc.addCols(""+cdo.getColValue("tot_x_mes"),1,1);
		
			}else{
			    pc.addCols(""+cdo.getColValue("unidad"),0,1);
				pc.addCols(""+cdo.getColValue("descripcion"),0,1);
				pc.addCols(""+cdo.getColValue("comp"),1,1);
				pc.addCols(""+cdo.getColValue("medio"),1,1);
				pc.addCols(""+cdo.getColValue("def"),1,1);
				pc.addCols(""+cdo.getColValue("trab"),1,1);
				pc.addCols(""+cdo.getColValue("aus"),1,1);
				pc.addCols(""+cdo.getColValue("vac"),1,1);
				pc.addCols(""+cdo.getColValue("lss"),1,1);
				pc.addCols(""+cdo.getColValue("lxg"),1,1);
				pc.addCols(""+cdo.getColValue("rpr"),1,1);
				pc.addCols(""+cdo.getColValue("tot_x_mes"),1,1);
			}
			comp += Integer.parseInt(cdo.getColValue("comp"));
			medio += Integer.parseInt(cdo.getColValue("medio"));
			def += Integer.parseInt(cdo.getColValue("def"));
			trab += Integer.parseInt(cdo.getColValue("trab"));
			aus += Integer.parseInt(cdo.getColValue("aus"));
			vac += Integer.parseInt(cdo.getColValue("vac"));
			lss += Integer.parseInt(cdo.getColValue("lss"));
			lxg += Integer.parseInt(cdo.getColValue("lxg"));
			rpr += Integer.parseInt(cdo.getColValue("rpr"));
			tot_x_mes += Integer.parseInt(cdo.getColValue("tot_x_mes"));
			
			anio = cdo.getColValue("anio");
			
		}//for i
	
	    pc.addCols(" ",1,dHeader.size());
	    pc.setFont(8,1);
		pc.addCols("TOTALES FINALES",0,2);
		pc.addCols(""+comp,1,1);
		pc.addCols(""+medio,1,1);
		pc.addCols(""+def,1,1);
		pc.addCols(""+trab,1,1);
		pc.addCols(""+aus,1,1);
		pc.addCols(""+vac,1,1);
		pc.addCols(""+lss,1,1);
		pc.addCols(""+lxg,1,1);
		pc.addCols(""+rpr,1,1);
		pc.addCols(""+tot_x_mes,1,1);
	
	
	
	}//else
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
