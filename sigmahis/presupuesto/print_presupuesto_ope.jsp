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
/** SFPRES006 Presupuesto/Transacciones/Presupuesto Operativo
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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoUE = new CommonDataObject();

String sql = "", appendFilter = "", xtraQuery1 = "", xtraQuery2 = "";
String tableUE = "", appendFilter2 = "", xtraGroupBy = "", xtraOrderBy = "";
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");
String compania = (String)session.getAttribute("_companyId");

if (anio == null ) anio = "";
if (unidad == null ) unidad = "";

if (!unidad.equals("")) {
   appendFilter += " and ACA.unidad = to_number("+unidad+")";
   cdoUE = SQLMgr.getData("select descripcion v_unidad from tbl_sec_unidad_ejec where codigo = TO_NUMBER("+unidad+")and compania = "+compania+"");
}else{
   xtraQuery1 = "aca.unidad, UE.DESCRIPCION unidadEjec, ";
   xtraQuery2 = "xx.unidad, xx.unidadEjec, ";
   tableUE = " , tbl_sec_unidad_ejec UE";
   appendFilter2 = " and aca.unidad = UE.codigo";
   xtraGroupBy = "xx.unidad, xx.unidadEjec, ";
   xtraOrderBy = " xx.unidad, ";
}

if (anio.equals("")) throw new Exception("No pudimos encontar un año válido, Por favor contacte un administrador!");
sql = "select "+xtraQuery2+" xx.tipo_cuenta, xx.dsc_cuenta, xx.dsp_tipo_cuenta, xx.codigo_prin, xx.justificacion, sum(xx.enero) t_enero, sum(xx.febrero) t_febrero, sum(xx.marzo) t_marzo, sum(xx.abril) t_abril, sum(xx.mayo) t_mayo, sum(xx.junio) t_junio, sum(xx.julio) t_julio, sum(xx.agosto) t_agosto, sum(xx.septiembre) t_septiembre, sum(xx.octubre) t_octubre, sum(xx.noviembre) t_noviembre,sum(xx.diciembre) t_diciembre, sum(xx.enero+xx.febrero+xx.marzo+xx.abril+xx.mayo+xx.junio+xx.julio+xx.agosto+xx.septiembre+xx.octubre+xx.noviembre+xx.diciembre) total_reng,sum(xx.ene_subtotal_ing) t_i_enero, sum(xx.feb_subtotal_ing) t_i_febrero, sum(xx.mar_subtotal_ing) t_i_marzo, sum(xx.abr_subtotal_ing) t_i_abril, sum(xx.may_subtotal_ing) t_i_mayo, sum(xx.jun_subtotal_ing) t_i_junio, sum(xx.jul_subtotal_ing) t_i_julio, sum(xx.ago_subtotal_ing) t_i_agosto, sum(xx.sep_subtotal_ing) t_i_septiembre, sum(xx.oct_subtotal_ing) t_i_octubre, sum(xx.nov_subtotal_ing) t_i_noviembre,sum(xx.dic_subtotal_ing) t_i_diciembre,xx.cta1, xx.cta2, xx.cta3, xx.cta4, xx.cta5, xx.cta6 from(select "+xtraQuery1+" aca.mes, cp.codigo_prin, cg.tipo_cuenta,decode(cp.codigo_prin,'4','INGRESOS','5','COSTOS','6','GASTOS','')DSP_TIPO_CUENTA,decode(cp.codigo_prin,'4',1,'5',2,'6',3)Dsp_orden, cc.descripcion, cg.descripcion DSC_CUENTA, nvl(to_number(decode(to_number(aca.mes),1,nvl(ASIGNACION,0))),0) enero, nvl(to_number(decode(to_number(aca.mes),1,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) ene_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),1,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) ene_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),2,nvl(ASIGNACION,0))),0) febrero, nvl(to_number(decode(to_number(aca.mes),2,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) feb_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),2,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) feb_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),3,nvl(ASIGNACION,0))),0) marzo, nvl(to_number(decode(to_number(aca.mes),3,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) mar_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),3,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) mar_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),4,nvl(ASIGNACION,0))),0) abril, nvl(to_number(decode(to_number(aca.mes),4,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) abr_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),4,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) abr_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),5,nvl(ASIGNACION,0))),0) mayo, nvl(to_number(decode(to_number(aca.mes),5,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) may_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),5,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) may_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),6,nvl(ASIGNACION,0))),0) junio, nvl(to_number(decode(to_number(aca.mes),6,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) jun_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),6,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) jun_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),7,nvl(ASIGNACION,0))),0) julio, nvl(to_number(decode(to_number(aca.mes),7,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) jul_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),7,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )) ,0) jul_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),8,nvl(ASIGNACION,0))),0) agosto, nvl(to_number(decode(to_number(aca.mes),8,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) ago_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),8,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) ago_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),9,nvl(ASIGNACION,0))),0) septiembre, nvl(to_number(decode(to_number(aca.mes),9,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )),0) sep_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),9,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) sep_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),10,nvl(ASIGNACION,0))),0) octubre, nvl(to_number(decode(to_number(aca.mes),10,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) oct_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),10,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) oct_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),11,nvl(ASIGNACION,0))),0) noviembre, nvl(to_number(decode(to_number(aca.mes),11,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) nov_subtotal_ing, nvl(to_number(decode(to_number(aca.mes),11,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) nov_subtotal_desctos, nvl(to_number(decode(to_number(aca.mes),12,nvl(ASIGNACION,0))),0) diciembre, nvl(to_number(decode(to_number(aca.mes),12,nvl( decode(substr(aca.cta1,1,2),'41',ASIGNACION,0),0) )) ,0) dic_subtotal_ing , nvl(to_number(decode(to_number(aca.mes),12,nvl( decode(substr(aca.cta1,1,2),'42',ASIGNACION,0),0) )),0) dic_subtotal_desctos, AcA.ANIO, cG.CTA1, cG.CTA2, cG.CTA3, cG.CTA4, cG.CTA5, cG.CTA6 ,cg.cta1||cg.cta2||cg.cta3||cg.cta4||cg.cta5||cg.cta6 cuenta , aca.COMPANIA CIA , nvl(aca.compania_origen,aca.compania)   compania_origen , C.NOMBRE, (select justificacion from tbl_con_ante_cuenta_anual where anio = "+anio+" and compania = "+compania+appendFilter+"  and aca.unidad = unidad and compania = aca.compania and CTA1 = aca.cta1 and CTA2  = aca.cta2 and CTA3 = aca.cta3 and CTA4 = aca.cta4 and CTA5  = aca.cta5 and CTA6  = aca.cta6 ) justificacion from tbl_con_ante_cuenta_mensual aca, tbl_con_ctas_prin cp, tbl_con_cla_ctas cc, tbl_con_catalogo_gral cg , tbl_sec_COMPANIA C "+tableUE+" where cg.CTA1 = aca.cta1 and cg.CTA2  = aca.cta2 and cg.CTA3 = aca.cta3 and cg.CTA4 = aca.cta4 and cg.CTA5  = aca.cta5 and cg.CTA6  = aca.cta6 and cg.COMPANIA  = nvl(aca.compania_origen,aca.compania) and cp.codigo_prin  in ('4','5','6') and cc.codigo_prin  = cp.codigo_prin AND cg.tipo_cuenta  = cc.codigo_clase   AND C.CODIGO = aca.COMPANIA  AND CG.RECIBE_MOV = 'S' "+appendFilter+appendFilter2+"  AND ACA.ANIO = "+anio+" and aca.compania = "+compania+" order by cg.tipo_cuenta,decode(cp.codigo_prin,'4',1,'5',2,'6',3),cg.tipo_cuenta, cg.cta1, cg.cta2, cg.cta3, cg.cta4, cg.cta5, cg.cta6)xx group by "+xtraGroupBy+" xx.tipo_cuenta,  xx.dsc_cuenta, xx.dsp_tipo_cuenta, xx.codigo_prin, xx.justificacion,xx.cta1, xx.cta2, xx.cta3, xx.cta4, xx.cta5, xx.cta6 order by "+xtraOrderBy+" xx.tipo_cuenta,xx.codigo_prin,xx.cta1, xx.cta2";


//, decode(cp.codigo_prin,'IN',1,'CO',2,'GA',3),cg.cta1, cg.cta2, cg.cta3, cg.cta4, cg.cta5, cg.cta6";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PRESUPUESTO OPERATIVO PRELIMINAR "+anio;
	String subtitle = "En Balboas";
	String xtraSubtitle = (cdoUE.getColValue("v_unidad")==null?"":cdoUE.getColValue("v_unidad"));
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
	infoCol.addElement(".30");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");
	infoCol.addElement(".10");

	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

	pc.setVAlignment(0);

	pc.setFont(7,1);
	pc.addBorderCols("DETALLE",1,1);
	pc.addBorderCols("ENE",1,1);
	pc.addBorderCols("FEB",1,1);
	pc.addBorderCols("MAR",1,1);
	pc.addBorderCols("ABR",1,1);
	pc.addBorderCols("MAY",1,1);
	pc.addBorderCols("JUN",1,1);
	pc.addBorderCols("JUL",1,1);
	pc.addBorderCols("AGO",1,1);
	pc.addBorderCols("SEP",1,1);
	pc.addBorderCols("OCT",1,1);
	pc.addBorderCols("NOV",1,1);
	pc.addBorderCols("DIC",1,1);
	pc.addBorderCols("TOTALES",1,1);

	pc.setTableHeader(2);
	//System.out.println("::::::::::::: The Brain ::::::::::::::::::::"+al.size());

	String tipoCuenta = "", codPrin = "", unidaGroup = "", just = "";
	double t_enero = 0.0, t_febrero = 0.0, t_marzo = 0.0, t_abril = 0.0, t_mayo = 0.0, t_junio = 0.0, t_julio = 0.0, t_agosto = 0.0, t_septiembre = 0.0, t_octubre = 0.0, t_noviembre = 0.0, t_diciembre = 0.0, total_reng = 0.0,t_i_enero = 0.0, t_i_febrero = 0.0, t_i_marzo = 0.0, t_i_abril = 0.0, t_i_mayo = 0.0, t_i_junio = 0.0, t_i_julio = 0.0, t_i_agosto = 0.0, t_i_septiembre = 0.0, t_i_octubre = 0.0, t_i_noviembre = 0.0, t_i_diciembre = 0.0, total_i_reng = 0.0, t_ing_enero = 0.0, t_ing_febrero = 0.0, t_ing_marzo = 0.0, t_ing_abril = 0.0, t_ing_mayo = 0.0, t_ing_junio = 0.0, t_ing_julio = 0.0, t_ing_agosto = 0.0, t_ing_septiembre = 0.0, t_ing_octubre = 0.0, t_ing_noviembre = 0.0, t_ing_diciembre = 0.0, t_ing_reng = 0.0, t_desc_enero = 0.0, t_desc_febrero = 0.0, t_desc_marzo = 0.0, t_desc_abril = 0.0, t_desc_mayo = 0.0, t_desc_junio = 0.0, t_desc_julio = 0.0, t_desc_agosto = 0.0, t_desc_septiembre = 0.0, t_desc_octubre = 0.0, t_desc_noviembre = 0.0, t_desc_diciembre = 0.0, t_desc_reng = 0.0, t_ga_enero = 0.0, t_ga_febrero = 0.0, t_ga_marzo = 0.0, t_ga_abril = 0.0, t_ga_mayo = 0.0, t_ga_junio = 0.0, t_ga_julio = 0.0, t_ga_agosto = 0.0, t_ga_septiembre = 0.0, t_ga_octubre = 0.0, t_ga_noviembre = 0.0, t_ga_diciembre = 0.0, t_ga_reng = 0.0, t_co_enero = 0.0, t_co_febrero = 0.0, t_co_marzo = 0.0, t_co_abril = 0.0, t_co_mayo = 0.0, t_co_junio = 0.0, t_co_julio = 0.0, t_co_agosto = 0.0, t_co_septiembre = 0.0, t_co_octubre = 0.0, t_co_noviembre = 0.0, t_co_diciembre = 0.0, t_co_reng = 0.0, tot_ing_enero = 0.0, tot_ing_febrero = 0.0, tot_ing_marzo = 0.0, tot_ing_abril = 0.0, tot_ing_mayo = 0.0, tot_ing_junio = 0.0, tot_ing_julio = 0.0, tot_ing_agosto = 0.0, tot_ing_septiembre = 0.0, tot_ing_octubre = 0.0, tot_ing_noviembre = 0.0, tot_ing_diciembre = 0.0, tot_ing_reng = 0.0;

	pc.setFont(7,0);

	for ( int i = 0; i<al.size(); i++ ){
	    cdo = (CommonDataObject)al.get(i);

		if (cdo.getColValue("unidadEjec") !=null ){
			if (!unidaGroup.trim().equals(cdo.getColValue("unidadEjec"))){
			    pc.setFont(7,1);
			    pc.addBorderCols("Unidad: "+cdo.getColValue("unidadEjec"),0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
				pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

				pc.setFont(7,0);
			}
		}
		if (!codPrin.trim().equals(cdo.getColValue("codigo_prin"))){
			pc.setFont(7,1);
			if ( i != 0 ){
			if ( codPrin.equals("4")){
		       pc.addBorderCols("      Subtotal de Ingresos ..........................",0,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_enero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_febrero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_marzo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_abril),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_mayo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_junio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_julio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_agosto),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_septiembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_octubre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_noviembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_diciembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_ing_reng),2,1,0f,0f,0.1f,0.1f);

			   pc.addBorderCols("      Subtotal de Descuentos .....................",0,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_enero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_febrero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_marzo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_abril),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_mayo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_junio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_julio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_agosto),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_septiembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_octubre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_noviembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_diciembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_desc_reng),2,1,0f,0f,0.1f,0.1f);

			   pc.addBorderCols("      Total de Ingresos ................................",0,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_enero+t_desc_enero)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_febrero+t_desc_febrero)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_marzo+t_desc_marzo)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_abril+t_desc_abril)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_mayo+t_desc_mayo)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_junio+t_desc_junio)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_julio+t_desc_julio)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_agosto+t_desc_agosto)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_septiembre+t_desc_septiembre)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_octubre+t_desc_octubre)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_noviembre+t_desc_noviembre)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_diciembre+t_desc_diciembre)),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ing_reng+t_desc_reng)),2,1,0f,0f,0.1f,0.1f);

			   tot_ing_enero += t_ing_enero+t_desc_enero;
			   tot_ing_febrero += t_ing_febrero+t_desc_febrero;
			   tot_ing_marzo += t_ing_marzo+t_desc_marzo;
			   tot_ing_abril += t_ing_abril+t_desc_abril;
			   tot_ing_mayo += t_ing_mayo+t_desc_mayo;
			   tot_ing_junio += t_ing_junio+t_desc_junio;
			   tot_ing_julio += t_ing_julio+t_desc_julio;
			   tot_ing_agosto += t_ing_agosto+t_desc_agosto;
			   tot_ing_septiembre += t_ing_septiembre+t_desc_septiembre;
			   tot_ing_octubre += t_ing_octubre+t_desc_octubre;
			   tot_ing_noviembre += t_ing_noviembre+t_desc_noviembre;
			   tot_ing_diciembre += t_ing_diciembre+t_desc_diciembre;
			   tot_ing_reng += t_ing_reng+t_desc_reng;

			  }
			  if ( codPrin.equals("5")){
			   pc.addBorderCols("      Total de Costos ..........................",0,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_enero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_febrero),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_marzo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_abril),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_mayo),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_junio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_julio),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_agosto),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_septiembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_octubre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_noviembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_diciembre),2,1,0f,0f,0.1f,0.1f);
			   pc.addBorderCols(CmnMgr.getFormattedDecimal(t_co_reng),2,1,0f,0f,0.1f,0.1f);
			  }

			   t_ing_enero = 0.0; t_ing_febrero = 0.0; t_ing_marzo = 0.0; t_ing_abril = 0.0; t_ing_mayo = 0.0; t_ing_junio = 0.0; t_ing_julio = 0.0; t_ing_agosto = 0.0; t_ing_septiembre = 0.0; t_ing_octubre = 0.0; t_ing_noviembre = 0.0; t_ing_diciembre = 0.0; t_ing_reng = 0.0; t_desc_enero = 0.0; t_desc_febrero = 0.0; t_desc_marzo = 0.0; t_desc_abril = 0.0; t_desc_mayo = 0.0; t_desc_junio = 0.0; t_desc_julio = 0.0; t_desc_agosto = 0.0; t_desc_septiembre = 0.0; t_desc_octubre = 0.0; t_desc_noviembre = 0.0; t_desc_diciembre = 0.0; t_desc_reng = 0.0;

			}

			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

		    pc.addBorderCols("     "+cdo.getColValue("dsp_tipo_cuenta"),0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
			pc.setFont(7,0);
		}

		if (cdo.getColValue("justificacion")!=null && !cdo.getColValue("justificacion").equals("")){ just = "\n>>>";}
		else{just="";}

			pc.addBorderCols(cdo.getColValue("dsc_cuenta")+just+cdo.getColValue("justificacion"),0,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_enero")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_febrero")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_marzo")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_abril")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_mayo")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_junio")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_julio")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_agosto")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_septiembre")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_octubre")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_noviembre")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("t_diciembre")),2,1,0f,0f,0.1f,0.1f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("total_reng")),2,1,0f,0f,0.1f,0.1f);

			t_enero += Double.parseDouble(cdo.getColValue("t_enero"));
			t_febrero += Double.parseDouble(cdo.getColValue("t_febrero"));
			t_marzo += Double.parseDouble(cdo.getColValue("t_marzo"));
			t_abril += Double.parseDouble(cdo.getColValue("t_abril"));
			t_mayo += Double.parseDouble(cdo.getColValue("t_mayo"));
			t_junio += Double.parseDouble(cdo.getColValue("t_junio"));
			t_julio += Double.parseDouble(cdo.getColValue("t_julio"));
			t_agosto += Double.parseDouble(cdo.getColValue("t_agosto"));
			t_septiembre += Double.parseDouble(cdo.getColValue("t_septiembre"));
			t_octubre += Double.parseDouble(cdo.getColValue("t_octubre"));
			t_noviembre += Double.parseDouble(cdo.getColValue("t_noviembre"));
			t_diciembre += Double.parseDouble(cdo.getColValue("t_diciembre"));
			total_reng += Double.parseDouble(cdo.getColValue("total_reng"));

			t_i_enero += Double.parseDouble(cdo.getColValue("t_i_enero"));
			t_i_febrero += Double.parseDouble(cdo.getColValue("t_i_febrero"));
			t_i_marzo += Double.parseDouble(cdo.getColValue("t_i_marzo"));
			t_i_abril += Double.parseDouble(cdo.getColValue("t_i_abril"));
			t_i_mayo += Double.parseDouble(cdo.getColValue("t_i_mayo"));
			t_i_junio += Double.parseDouble(cdo.getColValue("t_i_junio"));
			t_i_julio += Double.parseDouble(cdo.getColValue("t_i_julio"));
			t_i_agosto += Double.parseDouble(cdo.getColValue("t_i_agosto"));
			t_i_septiembre += Double.parseDouble(cdo.getColValue("t_i_septiembre"));
			t_i_octubre += Double.parseDouble(cdo.getColValue("t_i_octubre"));
			t_i_noviembre += Double.parseDouble(cdo.getColValue("t_i_noviembre"));
			t_i_diciembre += Double.parseDouble(cdo.getColValue("t_i_diciembre"));

			if ( cdo.getColValue("codigo_prin").equals("4")){
			   if (cdo.getColValue("tipo_cuenta").substring(0,2).equals("41")){
			    t_ing_enero += Double.parseDouble(cdo.getColValue("t_i_enero"));
				t_ing_febrero += Double.parseDouble(cdo.getColValue("t_i_febrero"));
				t_ing_marzo += Double.parseDouble(cdo.getColValue("t_i_marzo"));
				t_ing_abril+= Double.parseDouble(cdo.getColValue("t_i_abril"));
				t_ing_mayo += Double.parseDouble(cdo.getColValue("t_i_mayo"));
				t_ing_junio += Double.parseDouble(cdo.getColValue("t_i_junio"));
				t_ing_julio += Double.parseDouble(cdo.getColValue("t_i_julio"));
				t_ing_agosto += Double.parseDouble(cdo.getColValue("t_i_agosto"));
				t_ing_septiembre += Double.parseDouble(cdo.getColValue("t_i_septiembre"));
				t_ing_octubre += Double.parseDouble(cdo.getColValue("t_i_octubre"));
				t_ing_noviembre += Double.parseDouble(cdo.getColValue("t_i_noviembre"));
				t_ing_diciembre += Double.parseDouble(cdo.getColValue("t_i_diciembre"));
				t_ing_reng += Double.parseDouble(cdo.getColValue("total_reng"));
			  }else
			  if (cdo.getColValue("tipo_cuenta").substring(0,2).equals("42")){
			    t_desc_enero += Double.parseDouble(cdo.getColValue("t_enero"));
				t_desc_febrero += Double.parseDouble(cdo.getColValue("t_febrero"));
				t_desc_marzo += Double.parseDouble(cdo.getColValue("t_marzo"));
				t_desc_abril+= Double.parseDouble(cdo.getColValue("t_abril"));
				t_desc_mayo += Double.parseDouble(cdo.getColValue("t_mayo"));
				t_desc_junio += Double.parseDouble(cdo.getColValue("t_junio"));
				t_desc_julio += Double.parseDouble(cdo.getColValue("t_julio"));
				t_desc_agosto += Double.parseDouble(cdo.getColValue("t_agosto"));
				t_desc_septiembre += Double.parseDouble(cdo.getColValue("t_septiembre"));
				t_desc_octubre += Double.parseDouble(cdo.getColValue("t_octubre"));
				t_desc_noviembre += Double.parseDouble(cdo.getColValue("t_noviembre"));
				t_desc_diciembre += Double.parseDouble(cdo.getColValue("t_diciembre"));
				t_desc_reng += Double.parseDouble(cdo.getColValue("total_reng"));
			}
		  }else{
		     if ( cdo.getColValue("codigo_prin").equals("5")){
			 //Sobreecribiendo las variables para no declarar otras :)
			    t_co_enero += Double.parseDouble(cdo.getColValue("t_enero"));
				t_co_febrero += Double.parseDouble(cdo.getColValue("t_febrero"));
				t_co_marzo += Double.parseDouble(cdo.getColValue("t_marzo"));
				t_co_abril+= Double.parseDouble(cdo.getColValue("t_abril"));
				t_co_mayo += Double.parseDouble(cdo.getColValue("t_mayo"));
				t_co_junio += Double.parseDouble(cdo.getColValue("t_junio"));
				t_co_julio += Double.parseDouble(cdo.getColValue("t_julio"));
				t_co_agosto += Double.parseDouble(cdo.getColValue("t_agosto"));
				t_co_septiembre += Double.parseDouble(cdo.getColValue("t_septiembre"));
				t_co_octubre += Double.parseDouble(cdo.getColValue("t_octubre"));
				t_co_noviembre += Double.parseDouble(cdo.getColValue("t_noviembre"));
				t_co_diciembre += Double.parseDouble(cdo.getColValue("t_diciembre"));
				t_co_reng += Double.parseDouble(cdo.getColValue("total_reng"));
			 }
			  if ( cdo.getColValue("codigo_prin").equals("6")){
			 	t_ga_enero += Double.parseDouble(cdo.getColValue("t_enero"));
				t_ga_febrero += Double.parseDouble(cdo.getColValue("t_febrero"));
				t_ga_marzo += Double.parseDouble(cdo.getColValue("t_marzo"));
				t_ga_abril+= Double.parseDouble(cdo.getColValue("t_abril"));
				t_ga_mayo += Double.parseDouble(cdo.getColValue("t_mayo"));
				t_ga_junio += Double.parseDouble(cdo.getColValue("t_junio"));
				t_ga_julio += Double.parseDouble(cdo.getColValue("t_julio"));
				t_ga_agosto += Double.parseDouble(cdo.getColValue("t_agosto"));
				t_ga_septiembre += Double.parseDouble(cdo.getColValue("t_septiembre"));
				t_ga_octubre += Double.parseDouble(cdo.getColValue("t_octubre"));
				t_ga_noviembre += Double.parseDouble(cdo.getColValue("t_noviembre"));
				t_ga_diciembre += Double.parseDouble(cdo.getColValue("t_diciembre"));
				t_ga_reng += Double.parseDouble(cdo.getColValue("total_reng"));
			 }

			}

			codPrin = cdo.getColValue("codigo_prin");
			unidaGroup = cdo.getColValue("unidadEjec");

	}//for

	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

	pc.setFont(7,1);
	pc.addBorderCols("     Total de Gastos: ..........................",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_enero),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_febrero),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_marzo),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_abril),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_mayo),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_junio),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_julio),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_agosto),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_septiembre),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_octubre),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_noviembre),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_diciembre),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+t_ga_reng),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(" ",0,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols("Total de Costos y Gastos:",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_enero+t_co_enero)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_febrero+t_co_febrero)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_marzo+t_co_marzo)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_abril+t_co_abril)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_mayo+t_co_mayo)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_junio+t_co_junio)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_julio+t_co_julio)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_agosto+t_co_agosto)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_septiembre+t_co_septiembre)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_octubre+t_co_octubre)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_noviembre+t_co_noviembre)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_diciembre+t_co_diciembre)),2,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(""+(t_ga_reng+t_co_reng)),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols("Ganancia (Pérdida) Neta: ",0,1,0f,0f,0.1f,0.1f);
	pc.addBorderCols(((tot_ing_enero-(t_ga_enero+t_co_enero))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_enero-(t_ga_enero+t_co_enero)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_enero-(t_ga_enero+t_co_enero))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_febrero-(t_ga_febrero+t_co_febrero))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_febrero-(t_ga_febrero+t_co_febrero)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_febrero-(t_ga_febrero+t_co_febrero))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_marzo-(t_ga_marzo+t_co_marzo))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_marzo-(t_ga_marzo+t_co_marzo)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_marzo-(t_ga_marzo+t_co_marzo))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_abril-(t_ga_abril+t_co_abril))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_abril-(t_ga_abril+t_co_abril)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_abril-(t_ga_abril+t_co_abril))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_mayo-(t_ga_mayo+t_co_mayo))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_mayo-(t_ga_mayo+t_co_mayo)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_mayo-(t_ga_mayo+t_co_mayo))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_junio-(t_ga_junio+t_co_junio))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_junio-(t_ga_junio+t_co_junio)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_junio-(t_ga_junio+t_co_junio))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_julio-(t_ga_julio+t_co_julio))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_julio-(t_ga_julio+t_co_julio)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_julio-(t_ga_julio+t_co_julio))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_agosto-(t_ga_agosto+t_co_agosto))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_agosto-(t_ga_agosto+t_co_agosto)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_agosto-(t_ga_agosto+t_co_agosto))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_septiembre-(t_ga_septiembre+t_co_septiembre))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_septiembre-(t_ga_septiembre+t_co_septiembre)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_septiembre-(t_ga_septiembre+t_co_septiembre))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_octubre-(t_ga_octubre+t_co_octubre))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_octubre-(t_ga_octubre+t_co_octubre)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_octubre-(t_ga_octubre+t_co_octubre))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_noviembre-(t_co_noviembre+t_ga_noviembre))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_noviembre-(t_co_noviembre+t_ga_noviembre)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_noviembre-(t_co_noviembre+t_ga_noviembre))),2,1,0f,0f,0.1f,0.1f);

	pc.addBorderCols(((tot_ing_diciembre-(t_co_diciembre+t_ga_diciembre))<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(tot_ing_diciembre-(t_co_diciembre+t_ga_diciembre)))+")":CmnMgr.getFormattedDecimal(""+(tot_ing_diciembre-(t_co_diciembre+t_ga_diciembre))),2,1,0f,0f,0.1f,0.1f);

	total_i_reng = tot_ing_reng - (t_co_reng+t_ga_reng);

	pc.addBorderCols((total_i_reng<0.0)?"("+CmnMgr.getFormattedDecimal(""+(-1.0)*(total_i_reng))+")":CmnMgr.getFormattedDecimal(""+(total_i_reng)),2,1,0f,0f,0.1f,0.1f);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>