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
CommonDataObject cdoTotXdir= new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alTotXdir = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
String sql = "";

String _option = request.getParameter("opt");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String subTitle = "";
String filter = "", filter2 = "";
String cargo = (request.getParameter("cargo")==null?"":request.getParameter("cargo"));
String sec = (request.getParameter("sec")==null?"":request.getParameter("sec"));
String dept = (request.getParameter("dept")==null?"":request.getParameter("dept"));

Hashtable _mes = new Hashtable();

if (mes != null ){
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
if (anio == null || anio.equals("") || mes == null || mes.equals("")) throw new Exception("El año o el mes no es válido!");

if (_option.equalsIgnoreCase("rpt_res_x_pla8x11")) {
     subTitle = "INFORME DE ACUMULADOS (8.5 X 11))";
	 if ( !cargo.equals("") )  {
	      filter += " AND EM.CARGO = "+cargo+"";
		  filter2 += " AND E.CARGO = "+cargo+"";
	 }
	 if ( !sec.equals("") ){
	    filter += " AND EM.UNIDAD_ORGANI = "+sec+"";
		filter2 += " AND TE.UNIDAD = "+sec+"";
	 }
	 if ( !dept.equals("") ){
	    filter += " AND EM.UBIC_DEPTO = "+dept+"";
	 }
}

sql = "SELECT x.type, x.dpto_desc, x.sec_desc, x.a_ubic_depto, x.a_ubic_seccion, SUM(x.a_sal_bruto) a_sal_bruto, SUM(x.a_extra) a_extra, SUM(x.a_otros_ing) a_otros_ing, SUM(x.A_decimo) a_decimo, SUM(x.a_vacaciones) a_vacaciones, SUM(x.a_preaviso) a_preaviso, SUM(x.A_INDEMNIZACION) A_INDEMNIZACION, SUM(x.A_GASTO_REP) A_GASTO_REP, SUM(x.A_PRIMA_PRODUCCION) A_PRIMA_PRODUCCION, SUM(x.A_INCENTIVO) A_INCENTIVO, SUM(x.A_BONIFICACION) A_BONIFICACION, SUM(x.A_PARTICIPACION) A_PARTICIPACION, SUM(x.A_PRIMA_ANTIGUEDAD) A_PRIMA_ANTIGUEDAD, SUM(x.a_sal_bruto+x.a_extra+x.a_otros_ing+x.a_decimo+x.a_vacaciones+x.a_preaviso+x.A_INDEMNIZACION+x.A_GASTO_REP+x.A_PARTICIPACION+x.A_PRIMA_ANTIGUEDAD) subtotal  FROM((SELECT 'A' TYPE, AE.ANIO A_ANIO, '-' T_MES, EM.PROVINCIA  A_PROVINCIA, EM.SIGLA A_SIGLA, EM.TOMO A_TOMO, EM.ASIENTO A_ASIENTO, AE.NUM_EMPLEADO A_NUM_EMPLEADO,DECODE(EM.PROVINCIA,0,' ',00,' ',11,'B',12,'C',EM.PROVINCIA)||RPAD(DECODE(EM.SIGLA,'00','  ','0','  ',EM.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(EM.TOMO),3,'0')||'-'||LPAD(TO_CHAR(EM.ASIENTO),5,'0')A_CEDULA,EM.PRIMER_NOMBRE||' '||EM.PRIMER_APELLIDO||' '||	   DECODE(EM.SEXO,'F',DECODE(EM.APELLIDO_CASADA,NULL,EM.SEGUNDO_APELLIDO,EM.APELLIDO_CASADA), 'M',EM.SEGUNDO_APELLIDO)  A_NOMBRE,EM.COMPANIA A_COMPANIA, EM.UBIC_DEPTO A_UBIC_DEPTO , D.DESCRIPCION DPTO_DESC  ,S.DESCRIPCION SEC_DESC,  EM.UBIC_SECCION  A_UBIC_SECCION, (NVL(AE.SAL_BRUTO,0)-(NVL(AE.DECIMO,0)+ NVL(AE.BONIFICACION,0)+ NVL(AE.PARTICIPACION_UTILIDADES,0)+ NVL(AE.INCENTIVO,0)+ NVL(AE.VACACIONES,0)+NVL(AE.OTROS_ING,0)+NVL(AE.OTROS_ING_FIJOS,0)+NVL(AE.ALTO_RIESGO,0)+ NVL(AE.PRIMA_ANTIGUEDAD,0)+ NVL(AE.INDEMNIZACION,0)+NVL(AE.PREAVISO,0)+ NVL(AE.EXTRA,0))) A_SAL_BRUTO, NVL(AE.EXTRA,0) A_EXTRA, NVL(AE.OTROS_ING,0)+NVL(AE.ALTO_RIESGO,0) A_OTROS_ING, NVL(AE.DECIMO,0)  A_DECIMO, NVL(AE.VACACIONES,0) A_VACACIONES, NVL(AE.PREAVISO,0) A_PREAVISO, NVL(AE.INDEMNIZACION,0)  A_INDEMNIZACION, NVL(AE.G_REPRESENTACION,0) A_GASTO_REP, NVL(AE.PRIMA_PRODUCCION,0) A_PRIMA_PRODUCCION, NVL(AE.INCENTIVO,0)  A_INCENTIVO, NVL(AE.BONIFICACION,0) A_BONIFICACION,NVL(AE.PARTICIPACION_UTILIDADES,0)  A_PARTICIPACION, NVL(AE.PRIMA_ANTIGUEDAD,0) A_PRIMA_ANTIGUEDAD, TO_CHAR(AE.PERIODOS) A_PERIODOS FROM TBL_PLA_EMPLEADO EM, TBL_PLA_ACUMULADO_EMPLEADO AE, TBL_SEC_UNIDAD_EJEC D , TBL_SEC_UNIDAD_EJEC S WHERE EM.EMP_ID = AE.EMP_ID  AND EM.COMPANIA = AE.COD_COMPANIA AND AE.ANIO = "+anio+" AND  AE.COD_COMPANIA= "+compania+" AND ((  EM.ESTADO = 3 ) OR (  EM.ESTADO <> 3 AND (  EM.FECHA_EGRESO IS NULL  OR TO_NUMBER(TO_CHAR(EM.FECHA_EGRESO,'YYYY'))<= "+anio+"))) "+filter+" AND EM.UBIC_DEPTO = D.CODIGO AND EM.UBIC_SECCION = S.CODIGO AND D.COMPANIA = EM.COMPANIA AND S.COMPANIA = EM.COMPANIA)x) GROUP BY  x.dpto_desc, x.sec_desc,x.a_ubic_depto,x.a_ubic_seccion UNION ALL SELECT y.type, y.dpto_desc, y.sec_desc, y.ubic_dept, y.unidad, SUM( y.SAL_BRUTO),SUM(y.a_extras) ,SUM(y.a_otros_ing), SUM(y.a_decimo), SUM(y.a_VACACIONES), SUM(y.a_PREAVISO),SUM(y.A_INDEMNIZACION) A_INDEMNIZACION, SUM(y.A_GASTO_REP) A_GASTO_REP, SUM(y.A_PRIMA_PRODUCCION) A_PRIMA_PRODUCCION, SUM(y.A_INCENTIVO) A_INCENTIVO, SUM(y.A_BONIFICACION) A_BONIFICACION, SUM(y.A_PARTICIPACION) A_PARTICIPACION, SUM(y.A_PRIMA_ANTIGUEDAD) A_PRIMA_ANTIGUEDAD, SUM(y.sal_bruto+y.a_extras+y.a_otros_ing+y.a_decimo+y.a_vacaciones+y.a_preaviso+y.A_INDEMNIZACION+y.A_GASTO_REP+y.A_PRIMA_PRODUCCION+y.A_INCENTIVO+A_BONIFICACION+y.A_PARTICIPACION+y.A_PRIMA_ANTIGUEDAD) Tot  FROM((SELECT 'M' TYPE,TE.ANIO, TO_CHAR(TE.MES), TE.PROVINCIA  , TE.SIGLA , TE.TOMO , TE.ASIENTO , TE.NUM_EMPLEADO, DECODE(TE.PROVINCIA,0,' ',00,' ',11,'B',12,'C',TE.PROVINCIA)||RPAD(DECODE(TE.SIGLA,'00','  ','0','  ',TE.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(TE.TOMO),3,'0')||'-'||LPAD(TO_CHAR(TE.ASIENTO),5,'0'), '-',TE.COD_COMPANIA , E.UBIC_DEPTO UBIC_DEPT,D.descripcion dpto_desc,S.descripcion sec_desc,TE.UNIDAD UNIDAD,(NVL(TE.SAL_BRUTO,0))-(NVL(te.ausencias,0)+NVL(te.tardanzas,0)+NVL(te.otros_egresos,0)) SAL_BRUTO, NVL(TE.HORAS_EXTRAS,0) a_extras, NVL(TE.OTROS_INGRESOS,0) a_otros_ing,  NVL(TE.XIII_MES,0) a_decimo, NVL(TE.VACACIONES,0) a_vacaciones, NVL(TE.PREAVISO,0) a_preaviso, NVL(TE.INDEMNIZACION,0) a_INDEMNIZACION, NVL(TE.GASTO_REP,0) A_GASTO_REP ,NVL(TE.PRIMA_PRODUCCION,0)A_PRIMA_PRODUCCION , NVL(TE.INCENTIVO,0) A_INCENTIVO, NVL(TE.BONIFICACION,0) A_BONIFICACION , NVL(TE.PARTICIPACION_UTILIDADES,0) A_PARTICIPACION, NVL(TE.PRIMA_ANTIGUEDAD,0) A_PRIMA_ANTIGUEDAD,'0' FROM TBL_PLA_ACUMULADO_MENSUAL  TE, TBL_PLA_EMPLEADO E, TBL_SEC_UNIDAD_EJEC S, TBL_SEC_UNIDAD_EJEC D WHERE TE.COD_COMPANIA = "+compania+" AND TE.ANIO = "+anio+" AND TE.MES = "+mes+filter2+" AND E.EMP_ID = TE.EMP_ID AND E.COMPANIA = TE.COD_COMPANIA AND S.CODIGO = TE.UNIDAD AND D.CODIGO = E.UBIC_DEPTO AND d.compania = TE.COD_COMPANIA AND S.COMPANIA = TE.COD_COMPANIA )y) GROUP BY y.dpto_desc, y.sec_desc, ubic_dept,y.unidad ORDER BY  4, 5, 1 desc";


al = SQLMgr.getDataList(sql);

sql = "SELECT t.TYPE, t.a_ubic_depto, SUM(t.a_sal_bruto) t_sal_bruto, SUM(t.a_extra) t_extra, SUM(t.a_otros_ing) t_otros_ing, SUM(t.a_decimo) t_decimo, SUM(t.a_vacaciones) t_vacaciones, SUM(t.a_preaviso) t_preaviso, SUM(t.A_INDEMNIZACION) t_INDEMNIZACION, SUM(t.A_GASTO_REP) T_GASTO_REP, SUM(t.A_PRIMA_PRODUCCION) T_PRIMA_PRODUCCION, SUM(t.A_INCENTIVO) T_INCENTIVO, SUM(t.A_BONIFICACION) T_BONIFICACION, SUM(t.A_PARTICIPACION) T_PARTICIPACION, SUM(t.A_PRIMA_ANTIGUEDAD) T_PRIMA_ANTIGUEDAD, SUM(t.subtotal) t_tot_final   FROM (("+sql+")t ) GROUP BY t.a_ubic_depto, t.TYPE ORDER BY t.a_ubic_depto, 1 DESC";


alTotXdir = SQLMgr.getDataList(sql);

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
	float height = 72 * 11f;//1008
	boolean isLandscape = true;
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
	String xtraSubtitle = "CORRENPONDIENTE AL MES DE "+_mes.get(mes)+" DE "+anio ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
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
	dHeader.addElement(".10");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	if ( al.size() == 0 ){
	    pc.setFont(8,1);
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols("****** NO EXISTEN REGISTROS! ******",1,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	}else{

		 String groupDpt = "";
		 String groupSec = "";
		 String dptName = "";
		 String secName = "";
		 double totF_sb_a = 0.0, totF_sb_m = 0.0, totF_se_a =0.0, totF_se_m=0.0;
		 double totF_oi_a = 0.0, totF_oi_m = 0.0, totF_xiii_a =0.0, totF_xiii_m=0.0;
		 double totF_vac_a = 0.0, totF_vac_m = 0.0, totF_preav_a =0.0, totF_preav_m=0.0;
		 double totF_idem_a = 0.0, totF_idem_m = 0.0, totF_gr_a =0.0, totF_gr_m=0.0;
		 double totF_pp_a = 0.0, totF_pp_m = 0.0, totF_inc_a =0.0, totF_inc_m=0.0;
		 double totF_bo_a = 0.0, totF_bo_m = 0.0, totF_pu_a =0.0, totF_pu_m=0.0;
		 double totF_pa_a = 0.0, totF_pa_m = 0.0, totF_sub_a =0.0, totF_sub_m=0.0;
		 String groupTot = "";

		 String tot_sb_a = "0", tot_sb_m = "0", tot_se_a ="0", tot_se_m="0";
		 String tot_oi_a = "0", tot_oi_m = "0", tot_xiii_a ="0", tot_xiii_m="0";
		 String tot_vac_a = "0", tot_vac_m = "0", tot_preav_a ="0", tot_preav_m="0";
		 String tot_idem_a = "0", tot_idem_m = "0", tot_gr_a ="0", tot_gr_m="0";
		 String tot_pp_a = "0", tot_pp_m = "0", tot_inc_a ="0", tot_inc_m="0";
		 String tot_bo_a = "0", tot_bo_m = "0", tot_pu_a ="0", tot_pu_m="0";
		 String tot_pa_a = "0", tot_pa_m = "0", tot_sub_a ="0", tot_sub_m="0";

		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());

		pc.addCols("#",2,1);
		pc.addCols("Sueldo Regular",2,1);
		pc.addCols("Sueldo Extra",2,1);
		pc.addCols("Otros ing.",2,1);
		pc.addCols("XIII Mes",2,1);
		pc.addCols("Vacaciones",2,1);
		pc.addCols("Preaviso",2,1);
		pc.addCols("Idemnización",2,1);
		pc.addCols("Gastos Rep.",2,1);
		pc.addCols("Prima Producc.",2,1);
		pc.addCols("Incentivo",2,1);
		pc.addCols("Bonificación",2,1);
		pc.addCols("Particip. Util",2,1);
		pc.addCols("Prima Antigu.",2,1);
		pc.addCols("Subtotal",2,1);

		pc.addCols("===================================================================================================================================================================================================================================================",1,dHeader.size(),15f);

		pc.setTableHeader(4);

		for ( int i = 0; i<al.size();i++){

		   cdo = (CommonDataObject)al.get(i);

			   if ( !groupDpt.equals(cdo.getColValue("A_UBIC_DEPTO")) ){

			        if ( !groupSec.equals(cdo.getColValue("A_UBIC_SECCION")) ){
					    if ( i!=0){
					        pc.addCols(" ",0,1);
							pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size()-1,15f);

							pc.addCols("               *** TOTALES DE: "+dptName+" ***",0,dHeader.size());

						for ( int t = 0; t<alTotXdir.size(); t++ ){

							    cdoTotXdir = (CommonDataObject)alTotXdir.get(t);
								if ( cdoTotXdir.getColValue("A_UBIC_DEPTO").equals(groupDpt) ){


								   pc.addCols(" "+cdoTotXdir.getColValue("type"),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_SAL_BRUTO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_EXTRA")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_OTROS_ING")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_DECIMO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_VACACIONES")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PREAVISO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_INDEMNIZACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_GASTO_REP")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PRIMA_PRODUCCION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_INCENTIVO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_BONIFICACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PARTICIPACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_TOT_FINAL")),2,1);

								}else{


								if ( cdoTotXdir.getColValue("type").equals("A") ){
										tot_sb_a = cdoTotXdir.getColValue("T_SAL_BRUTO");
										tot_se_a = cdoTotXdir.getColValue("T_EXTRA");
										tot_oi_a = cdoTotXdir.getColValue("T_OTROS_ING");
										tot_xiii_a = cdoTotXdir.getColValue("T_DECIMO");
										tot_vac_a =  cdoTotXdir.getColValue("T_VACACIONES");
										tot_preav_a = cdoTotXdir.getColValue("T_PREAVISO") ;
										tot_idem_a = cdoTotXdir.getColValue("T_INDEMNIZACION") ;
										tot_gr_a =  cdoTotXdir.getColValue("T_GASTO_REP");
										tot_pp_a = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_inc_a = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_bo_a = cdoTotXdir.getColValue("T_BONIFICACION") ;
										tot_pu_a = cdoTotXdir.getColValue("T_PARTICIPACION")  ;
										tot_pa_a = cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD") ;
										tot_sub_a =  cdoTotXdir.getColValue("T_TOT_FINAL");

								}else{
										tot_sb_m = cdoTotXdir.getColValue("T_SAL_BRUTO");
										tot_se_m = cdoTotXdir.getColValue("T_EXTRA");
										tot_oi_m = cdoTotXdir.getColValue("T_OTROS_ING");
										tot_xiii_m = cdoTotXdir.getColValue("T_DECIMO");
										tot_vac_m =  cdoTotXdir.getColValue("T_VACACIONES");
										tot_preav_m = cdoTotXdir.getColValue("T_PREAVISO") ;
										tot_idem_m = cdoTotXdir.getColValue("T_INDEMNIZACION") ;
										tot_gr_m =  cdoTotXdir.getColValue("T_GASTO_REP");
										tot_pp_m = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_inc_m = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_bo_m = cdoTotXdir.getColValue("T_BONIFICACION") ;
										tot_pu_m = cdoTotXdir.getColValue("T_PARTICIPACION")  ;
										tot_pa_m = cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD") ;
										tot_sub_m =  cdoTotXdir.getColValue("T_TOT_FINAL");
								}

							}

								groupTot = cdoTotXdir.getColValue("A_UBIC_DEPTO");
						}//for t


								pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);


						}else{

						    for ( int t = 0; t<alTotXdir.size(); t++ ){

							    cdoTotXdir = (CommonDataObject)alTotXdir.get(t);
								if ( cdoTotXdir.getColValue("A_UBIC_DEPTO").equals(groupDpt) ){


								   pc.addCols(" "+cdoTotXdir.getColValue("type"),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_SAL_BRUTO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_EXTRA")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_OTROS_ING")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_DECIMO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_VACACIONES")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PREAVISO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_INDEMNIZACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_GASTO_REP")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PRIMA_PRODUCCION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_INCENTIVO")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_BONIFICACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PARTICIPACION")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD")),2,1);
								   pc.addCols(CmnMgr.getFormattedDecimal(cdoTotXdir.getColValue("T_TOT_FINAL")),2,1);

								}else{


								if ( cdoTotXdir.getColValue("type").equals("A") ){
										tot_sb_a = cdoTotXdir.getColValue("T_SAL_BRUTO");
										tot_se_a = cdoTotXdir.getColValue("T_EXTRA");
										tot_oi_a = cdoTotXdir.getColValue("T_OTROS_ING");
										tot_xiii_a = cdoTotXdir.getColValue("T_DECIMO");
										tot_vac_a =  cdoTotXdir.getColValue("T_VACACIONES");
										tot_preav_a = cdoTotXdir.getColValue("T_PREAVISO") ;
										tot_idem_a = cdoTotXdir.getColValue("T_INDEMNIZACION") ;
										tot_gr_a =  cdoTotXdir.getColValue("T_GASTO_REP");
										tot_pp_a = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_inc_a = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_bo_a = cdoTotXdir.getColValue("T_BONIFICACION") ;
										tot_pu_a = cdoTotXdir.getColValue("T_PARTICIPACION")  ;
										tot_pa_a = cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD") ;
										tot_sub_a =  cdoTotXdir.getColValue("T_TOT_FINAL");

								}else{
										tot_sb_m = cdoTotXdir.getColValue("T_SAL_BRUTO");
										tot_se_m = cdoTotXdir.getColValue("T_EXTRA");
										tot_oi_m = cdoTotXdir.getColValue("T_OTROS_ING");
										tot_xiii_m = cdoTotXdir.getColValue("T_DECIMO");
										tot_vac_m =  cdoTotXdir.getColValue("T_VACACIONES");
										tot_preav_m = cdoTotXdir.getColValue("T_PREAVISO") ;
										tot_idem_m = cdoTotXdir.getColValue("T_INDEMNIZACION") ;
										tot_gr_m =  cdoTotXdir.getColValue("T_GASTO_REP");
										tot_pp_m = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_inc_m = cdoTotXdir.getColValue("T_INCENTIVO") ;
										tot_bo_m = cdoTotXdir.getColValue("T_BONIFICACION") ;
										tot_pu_m = cdoTotXdir.getColValue("T_PARTICIPACION")  ;
										tot_pa_m = cdoTotXdir.getColValue("T_PRIMA_ANTIGUEDAD") ;
										tot_sub_m =  cdoTotXdir.getColValue("T_TOT_FINAL");
								}

							    }

								groupTot = cdoTotXdir.getColValue("A_UBIC_DEPTO");
						    }//for t
					    }

			        }//groupSec

			        pc.setFont(8,1);
					pc.addCols(cdo.getColValue("A_UBIC_DEPTO")+"        "+cdo.getColValue("DPTO_DESC"),0,dHeader.size());
					pc.setFont(7,0);

			    }//groupDpt

			   if ( !groupSec.equals(cdo.getColValue("A_UBIC_SECCION")) ){


					if (groupDpt.equals(cdo.getColValue("A_UBIC_DEPTO"))){

					   if ( i!=0){
					        pc.addCols(" ",0,1);
							pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size()-1,15f);
						}

					}

				    pc.addCols("",0,dHeader.size());
					pc.addCols(cdo.getColValue("A_UBIC_SECCION"),1,1);
					pc.addCols(cdo.getColValue("SEC_DESC"),0,14);



			   }//groupSec


			   pc.addCols(" "+cdo.getColValue("type"),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_SAL_BRUTO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_EXTRA")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_OTROS_ING")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_DECIMO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_VACACIONES")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_PREAVISO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_INDEMNIZACION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_GASTO_REP")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_PRIMA_PRODUCCION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_INCENTIVO")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_BONIFICACION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_PARTICIPACION")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("A_PRIMA_ANTIGUEDAD")),2,1);
			   pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("Subtotal")),2,1);


			   if (cdo.getColValue("type").equals("A")){
				   totF_sb_a +=Double.parseDouble(cdo.getColValue("A_SAL_BRUTO"));
				   totF_se_a +=Double.parseDouble(cdo.getColValue("A_EXTRA"));
				   totF_oi_a +=Double.parseDouble(cdo.getColValue("A_OTROS_ING"));
				   totF_xiii_a +=Double.parseDouble(cdo.getColValue("A_DECIMO"));
				   totF_vac_a +=Double.parseDouble(cdo.getColValue("A_VACACIONES"));
				   totF_preav_a +=Double.parseDouble(cdo.getColValue("A_PREAVISO"));
				   totF_idem_a +=Double.parseDouble(cdo.getColValue("A_INDEMNIZACION"));
				   totF_gr_a +=Double.parseDouble(cdo.getColValue("A_GASTO_REP"));
				   totF_pp_a +=Double.parseDouble(cdo.getColValue("A_PRIMA_PRODUCCION"));
				   totF_inc_a +=Double.parseDouble(cdo.getColValue("A_INCENTIVO"));
				   totF_bo_a +=Double.parseDouble(cdo.getColValue("A_BONIFICACION"));
				   totF_pu_a +=Double.parseDouble(cdo.getColValue("A_PARTICIPACION"));
				   totF_pa_a +=Double.parseDouble(cdo.getColValue("A_PRIMA_ANTIGUEDAD"));
				   totF_sub_a +=Double.parseDouble(cdo.getColValue("Subtotal"));

			   }else{
				   totF_sb_m +=Double.parseDouble(cdo.getColValue("A_SAL_BRUTO"));
				   totF_se_m +=Double.parseDouble(cdo.getColValue("A_EXTRA"));
				   totF_oi_m +=Double.parseDouble(cdo.getColValue("A_OTROS_ING"));
				   totF_xiii_m +=Double.parseDouble(cdo.getColValue("A_DECIMO"));
				   totF_vac_m +=Double.parseDouble(cdo.getColValue("A_VACACIONES"));
				   totF_preav_m +=Double.parseDouble(cdo.getColValue("A_PREAVISO"));
				   totF_idem_m +=Double.parseDouble(cdo.getColValue("A_INDEMNIZACION"));
				   totF_gr_m +=Double.parseDouble(cdo.getColValue("A_GASTO_REP"));
				   totF_pp_m +=Double.parseDouble(cdo.getColValue("A_PRIMA_PRODUCCION"));
				   totF_inc_m +=Double.parseDouble(cdo.getColValue("A_INCENTIVO"));
				   totF_bo_m +=Double.parseDouble(cdo.getColValue("A_BONIFICACION"));
				   totF_pu_m +=Double.parseDouble(cdo.getColValue("A_PARTICIPACION"));
				   totF_pa_m +=Double.parseDouble(cdo.getColValue("A_PRIMA_ANTIGUEDAD"));
				   totF_sub_m +=Double.parseDouble(cdo.getColValue("Subtotal"));

			   }

			   pc.addCols("",0,dHeader.size());

			   groupDpt = cdo.getColValue("A_UBIC_DEPTO");
			   groupSec = cdo.getColValue("a_ubic_seccion");
			   dptName = cdo.getColValue("DPTO_DESC");
			   secName = cdo.getColValue("SEC_DESC");

		}//for i


		pc.addCols("               *** TOTALES DE: "+dptName+" T= "+tot_sb_m+" ***",0,dHeader.size());

		pc.addCols(" M ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_sb_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_se_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_oi_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_xiii_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_vac_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_preav_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_idem_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_gr_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pp_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_inc_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_bo_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pu_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pa_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_sub_m),2,1);


		pc.addCols(" A ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_sb_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_se_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_oi_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_xiii_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_vac_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_preav_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_idem_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_gr_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pp_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_inc_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_bo_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pu_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_pa_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tot_sub_a),2,1);





		pc.addCols("===================================================================================================================================================================================================================================================",1,dHeader.size(),15f);

		pc.setFont(8,1);
		pc.addCols(" ",1,dHeader.size());
		pc.addCols("****** TOTALES FINALES ******",1,dHeader.size());

		pc.addCols(" M ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_sb_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_se_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_oi_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_xiii_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_vac_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_preav_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_idem_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_gr_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pp_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_inc_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_bo_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pu_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pa_m),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_sub_m),2,1);


		pc.addCols(" A ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_sb_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_se_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_oi_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_xiii_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_vac_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_preav_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_idem_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_gr_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pp_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_inc_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_bo_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pu_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_pa_a),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totF_sub_a),2,1);



	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
