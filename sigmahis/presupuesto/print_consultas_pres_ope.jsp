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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoUE = new CommonDataObject();

String appendFilter = "", xtraQuery1 = "", xtraQuery2 = "";
StringBuffer sql = new StringBuffer();
String tableUE = "", appendFilter2 = "", xtraGroupBy = "", xtraOrderBy = "";
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");
String compania = (String)session.getAttribute("_companyId");

if (anio == null ) anio = "";
if (unidad == null ) unidad = "";

if ( anio.equals("") ) throw new Exception("Año Invalido!");

if ( !unidad.trim().equals("") ){
	  appendFilter += " and aca.unidad = "+request.getParameter("unidad");
}

	if (!UserDet.getUserProfile().contains("0")){ 	appendFilter +=" and codigo in(";
			if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua"));
			else appendFilter +="-1";
			appendFilter +=")";
		}

sql.append("select xx.unidad, xx.unidadDesc, xx.tipo_cuenta tipoCuenta, xx.codigo_prin codigoPrin, xx.dsp_tipo_cuenta dspTipoCuenta, xx.dsc_cuenta descTipoCuenta, sum(enero) enero, sum(febrero) febrero, sum(marzo) marzo, sum(abril) abril , sum(mayo) mayo, sum(junio) junio,  sum(julio) julio,  sum(agosto) agosto, sum(septiembre) septiembre, sum(octubre) octubre, sum(noviembre) noviembre, sum(diciembre) diciembre, sum(enero_c) enero_c, sum(febrero_c) febrero_c, sum(marzo_c) marzo_c, sum(abril_c) abril_c , sum(mayo_c) mayo_c, sum(junio_c) junio_c,  sum(julio_c) julio_c,  sum(agosto_c) agosto_c, sum(septiembre_c) septiembre_c, sum(octubre_c) octubre_c, sum(noviembre_c) noviembre_c, sum(diciembre_c) diciembre_c, sum(enero_v) enero_v, sum(febrero_v) febrero_v, sum(marzo_v) marzo_v, sum(abril_v) abril_v , sum(mayo_v) mayo_v, sum(junio_v) junio_v,  sum(julio_v) julio_v,  sum(agosto_v) agosto_v, sum(septiembre_v) septiembre_v, sum(octubre_v) octubre_v, sum(noviembre_v) noviembre_v, sum(diciembre_v) diciembre_v,sum(xx.enero+xx.febrero+xx.marzo+xx.abril+xx.mayo+xx.junio+xx.julio+xx.agosto+xx.septiembre+xx.octubre+xx.noviembre+xx.diciembre) ac_asignacion, sum(xx.enero_c+xx.febrero_c+xx.marzo_c+xx.abril_c+xx.mayo_c+xx.junio_c+xx.julio_c+xx.agosto_c+xx.septiembre_c+xx.octubre_c+xx.noviembre_c+xx.diciembre_c) ac_consumo, sum(xx.enero_v+xx.febrero_v+xx.marzo_v+xx.abril_v+xx.mayo_v+xx.junio_v+xx.julio_v+xx.agosto_v+xx.septiembre_v+xx.octubre_v+xx.noviembre_v+xx.diciembre_v) ac_variacion  from ( ");

sql.append("select ACA.ANIO, ACA.UNIDAD, ue.descripcion unidadDesc, aca.mes, cp.codigo_prin, cg.tipo_cuenta, decode(cp.codigo_prin,'4','INGRESOS','5','COSTOS','6','GASTOS','') DSP_TIPO_CUENTA, decode(cp.codigo_prin,'4',1,'5',2,'6',3) Dsp_orden, cg.descripcion DSC_CUENTA,");
sql.append(" decode(to_number(aca.mes), 1, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) enero, decode(to_number(aca.mes),1, nvl(CONSUMIDO,0),0 )  enero_c,");
sql.append(" decode(to_number(aca.mes), 1,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) enero_v,");
sql.append(" decode(to_number(aca.mes), 2, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) febrero, decode(to_number(aca.mes),2, nvl(CONSUMIDO,0),0 ) febrero_c,");
sql.append(" decode(to_number(aca.mes), 2,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) febrero_v,");
sql.append(" decode(to_number(aca.mes), 3, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) marzo, decode(to_number(aca.mes),3, nvl(CONSUMIDO,0),0 ) marzo_c,");
sql.append(" decode(to_number(aca.mes), 3,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) marzo_v,");
sql.append(" decode(to_number(aca.mes), 4, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) abril, decode(to_number(aca.mes),4, nvl(CONSUMIDO,0),0 ) abril_c,");
sql.append("decode(to_number(aca.mes), 4,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) abril_v,");
sql.append(" decode(to_number(aca.mes), 5, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) mayo, decode(to_number(aca.mes),5, nvl(CONSUMIDO,0),0 ) mayo_c,");
sql.append(" decode(to_number(aca.mes), 5,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) mayo_v,");
sql.append("decode(to_number(aca.mes), 6, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) junio, decode(to_number(aca.mes),6, nvl(CONSUMIDO,0),0 ) junio_c,");
sql.append(" decode(to_number(aca.mes), 6,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) junio_v,");
sql.append(" decode(to_number(aca.mes), 7, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) julio, decode(to_number(aca.mes),7, nvl(CONSUMIDO,0),0 ) julio_c,");
sql.append(" decode(to_number(aca.mes), 7,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) julio_v,");
sql.append(" decode(to_number(aca.mes), 8, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) agosto,decode(to_number(aca.mes),8, nvl(CONSUMIDO,0),0 ) agosto_c,");
sql.append(" decode(to_number(aca.mes), 8,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) agosto_v,");
sql.append(" decode(to_number(aca.mes), 9, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) septiembre,decode(to_number(aca.mes),9, nvl(CONSUMIDO,0),0 ) septiembre_c,");
sql.append(" decode(to_number(aca.mes), 9,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) septiembre_v,");
sql.append(" decode(to_number(aca.mes), 10, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) octubre, decode(to_number(aca.mes),10, nvl(CONSUMIDO,0),0 ) octubre_c,");
sql.append(" decode(to_number(aca.mes), 10,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) octubre_v,");
sql.append(" decode(to_number(aca.mes), 11, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) noviembre, decode(to_number(aca.mes),11, nvl(CONSUMIDO,0),0 ) noviembre_c,");
sql.append(" decode(to_number(aca.mes), 11,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) noviembre_v,");
sql.append(" decode(to_number(aca.mes), 12, nvl(ASIGNACION,0)+nvl(traslado,0)+nvl(redistribuciones,0),0) diciembre, decode(to_number(aca.mes),12, nvl(CONSUMIDO,0),0 ) diciembre_c,");
sql.append(" decode(to_number(aca.mes), 12,decode(cp.codigo_prin,'4',nvl(consumido,0)-(nvl(asignacion,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0)), nvl(CONSUMIDO,0)-(nvl(ASIGNACION,0)+nvl(aca.traslado,0)+nvl(aca.redistribuciones,0))),0) diciembre_v");
sql.append(" from tbl_con_cuenta_mensual aca, tbl_con_ctas_prin cp, tbl_con_cla_ctas cc, tbl_con_catalogo_gral cg, tbl_sec_unidad_ejec ue where  cg.CTA1  = aca.cta1 and cg.CTA2 = aca.cta2 and cg.CTA3 = aca.cta3 and cg.CTA4 = aca.cta4 and cg.CTA5  = aca.cta5 and cg.CTA6  = aca.cta6 and cg.COMPANIA = NVL(ACA.COMPANIA_ORIGEN,ACA.COMPANIA) and cp.codigo_prin    in ('4','5','6') and cc.codigo_prin    = cp.codigo_prin    AND cg.tipo_cuenta    = cc.codigo_clase   AND ACA.CTA1   = CG.CTA1 and ACA.CTA2 = CG.CTA2 and ACA.CTA3 = CG.CTA3 and ACA.CTA4 = CG.CTA4 and ACA.CTA5 = CG.CTA5 and ACA.CTA6  = CG.CTA6  AND CG.RECIBE_MOV = 'S' and ACA.COMPANIA  = ");

sql.append(((String) session.getAttribute("_companyId")));
sql.append(appendFilter);
sql.append(" and aca.anio = ");
sql.append(anio);
sql.append(" and ue.codigo = aca.unidad and aca.compania = ue.compania ORDER by aca.unidad, CG.TIPO_CUENTA, to_number(aca.mes), decode(cp.codigo_prin,'4',1,'5',2,'6',3),CG.CTA1,CG.CTA2");
sql.append(" )xx group by xx.unidad, xx.unidadDesc, xx.tipo_cuenta , xx.codigo_prin, xx.dsp_tipo_cuenta , xx.dsc_cuenta order by xx.unidad, xx.codigo_prin, xx.tipo_cuenta");

al = SQLMgr.getDataList(sql.toString());

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

	pc.setFont(6,1);
	pc.addBorderCols("CUENTA",1,1);
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

	String groupBy ="",descTipoCta="", groupUnidad = "";
	double totalEnero =0,totalFebrero =0,totalMarzo =0,totalAbril =0,totalMayo =0,totalJunio =0,totalJulio =0,totalAgosto=0,totalSeptiembre =0,totalOctubre =0,totalNoviembre =0,totalDiciembre =0, totalAcAsignacion = 0;
	double totalEnero_c =0,totalFebrero_c =0,totalMarzo_c =0,totalAbril_c =0,totalMayo_c =0,totalJunio_c =0,totalJulio_c =0,totalAgosto_c =0,totalSeptiembre_c =0,totalOctubre_c =0,totalNoviembre_c =0,totalDiciembre_c =0, totalAcConsumo = 0;
	double totalEnero_v =0,totalFebrero_v =0,totalMarzo_v =0,totalAbril_v =0,totalMayo_v =0,totalJunio_v =0,totalJulio_v =0,totalAgosto_v =0,totalSeptiembre_v =0,totalOctubre_v =0,totalNoviembre_v =0,totalDiciembre_v =0, totalAcVariacion = 0;

	pc.setTableHeader(2);
	//System.out.println("::::::::::::: The Brain ::::::::::::::::::::"+al.size());

	for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

		if (!groupUnidad.trim().equals(cdo.getColValue("unidad"))){
            if ( i!=0 ){
				pc.setFont(6,1);
				pc.addBorderCols(" ",1,infoCol.size(),0.5f,0f,0f,0f);
				pc.addCols("            Total de: "+descTipoCta,0,1);
				pc.addCols(""+totalEnero,2,1);
				pc.addCols(""+totalFebrero,2,1);
				pc.addCols(""+totalMarzo,2,1);
				pc.addCols(""+totalAbril,2,1);
				pc.addCols(""+totalMayo,2,1);
				pc.addCols(""+totalJunio,2,1);
				pc.addCols(""+totalJulio,2,1);
				pc.addCols(""+totalAgosto,2,1);
				pc.addCols(""+totalSeptiembre,2,1);
				pc.addCols(""+totalOctubre,2,1);
				pc.addCols(""+totalNoviembre,2,1);
				pc.addCols(""+totalDiciembre,2,1);
				pc.addCols(""+totalAcAsignacion,2,1);

				pc.setFont(6,1);
				pc.addCols("Consumo",1,1);
				pc.addCols(""+totalEnero_c,2,1);
				pc.addCols(""+totalFebrero_c,2,1);
				pc.addCols(""+totalMarzo_c,2,1);
				pc.addCols(""+totalAbril_c,2,1);
				pc.addCols(""+totalMayo_c,2,1);
				pc.addCols(""+totalJunio_c,2,1);
				pc.addCols(""+totalJulio_c,2,1);
				pc.addCols(""+totalAgosto_c,2,1);
				pc.addCols(""+totalSeptiembre_c,2,1);
				pc.addCols(""+totalOctubre_c,2,1);
				pc.addCols(""+totalNoviembre_c,2,1);
				pc.addCols(""+totalDiciembre_c,2,1);
				pc.addCols(""+totalAcConsumo,2,1);

				pc.setFont(6,1);
				pc.addCols("Variacion",1,1);
				pc.addCols(""+totalEnero_v,2,1);
				pc.addCols(""+totalFebrero_v,2,1);
				pc.addCols(""+totalMarzo_v,2,1);
				pc.addCols(""+totalAbril_v,2,1);
				pc.addCols(""+totalMayo_v,2,1);
				pc.addCols(""+totalJunio_v,2,1);
				pc.addCols(""+totalJulio_v,2,1);
				pc.addCols(""+totalAgosto_v,2,1);
				pc.addCols(""+totalSeptiembre_v,2,1);
				pc.addCols(""+totalOctubre_v,2,1);
				pc.addCols(""+totalNoviembre_v,2,1);
				pc.addCols(""+totalDiciembre_v,2,1);
				pc.addCols(""+totalAcVariacion,2,1);

				totalEnero =0;totalFebrero =0;totalMarzo =0;totalAbril =0;totalMayo =0;totalJunio =0;totalJulio =0;totalAgosto=0;totalSeptiembre =0;totalOctubre =0;totalNoviembre =0;totalDiciembre =0; totalAcAsignacion = 0;
				totalEnero_c =0;totalFebrero_c =0;totalMarzo_c =0;totalAbril_c =0;totalMayo_c =0;totalJunio_c =0;totalJulio_c =0;totalAgosto_c =0;totalSeptiembre_c =0;totalOctubre_c =0;totalNoviembre_c =0;totalDiciembre_c =0; totalAcConsumo = 0;
				totalEnero_v =0;totalFebrero_v =0;totalMarzo_v =0;totalAbril_v =0;totalMayo_v =0;totalJunio_v =0;totalJulio_v =0;totalAgosto_v =0;totalSeptiembre_v =0;totalOctubre_v =0;totalNoviembre_v =0;totalDiciembre_v =0; totalAcVariacion = 0;

			} //i<>0

			pc.setFont(6,1,Color.white);
			pc.addCols(""+cdo.getColValue("unidadDesc"),0,infoCol.size(),Color.gray);
			pc.addCols(""+cdo.getColValue("dspTipoCuenta"),0,infoCol.size(),Color.lightGray);
			pc.setFont(6,0);

		} //groupUnidad

		pc.setFont(6,0);
		pc.addCols(cdo.getColValue("descTipoCuenta"),0,infoCol.size());

		pc.addCols("Objectivo:",2,1);
		pc.addCols(cdo.getColValue("enero"),2,1);
		pc.addCols(cdo.getColValue("febrero"),2,1);
		pc.addCols(cdo.getColValue("marzo"),2,1);
		pc.addCols(cdo.getColValue("abril"),2,1);
		pc.addCols(cdo.getColValue("mayo"),2,1);
		pc.addCols(cdo.getColValue("junio"),2,1);
		pc.addCols(cdo.getColValue("julio"),2,1);
		pc.addCols(cdo.getColValue("agosto"),2,1);
		pc.addCols(cdo.getColValue("septiembre"),2,1);
		pc.addCols(cdo.getColValue("octubre"),2,1);
		pc.addCols(cdo.getColValue("noviembre"),2,1);
		pc.addCols(cdo.getColValue("diciembre"),2,1);
		pc.addCols(cdo.getColValue("ac_asignacion"),2,1);

		pc.addCols("Consumo:",2,1);
		pc.addCols(cdo.getColValue("enero_c"),2,1);
		pc.addCols(cdo.getColValue("febrero_c"),2,1);
		pc.addCols(cdo.getColValue("marzo_c"),2,1);
		pc.addCols(cdo.getColValue("abril_c"),2,1);
		pc.addCols(cdo.getColValue("mayo_c"),2,1);
		pc.addCols(cdo.getColValue("junio_c"),2,1);
		pc.addCols(cdo.getColValue("julio_c"),2,1);
		pc.addCols(cdo.getColValue("agosto_c"),2,1);
		pc.addCols(cdo.getColValue("septiembre_c"),2,1);
		pc.addCols(cdo.getColValue("octubre_c"),2,1);
		pc.addCols(cdo.getColValue("noviembre_c"),2,1);
		pc.addCols(cdo.getColValue("diciembre_c"),2,1);
		pc.addCols(cdo.getColValue("ac_consumo"),2,1);


		pc.addCols("Variacion:",2,1);
		pc.addCols(cdo.getColValue("enero_v"),2,1);
		pc.addCols(cdo.getColValue("febrero_v"),2,1);
		pc.addCols(cdo.getColValue("marzo_v"),2,1);
		pc.addCols(cdo.getColValue("abril_v"),2,1);
		pc.addCols(cdo.getColValue("mayo_v"),2,1);
		pc.addCols(cdo.getColValue("junio_v"),2,1);
		pc.addCols(cdo.getColValue("julio_v"),2,1);
		pc.addCols(cdo.getColValue("agosto_v"),2,1);
		pc.addCols(cdo.getColValue("septiembre_v"),2,1);
		pc.addCols(cdo.getColValue("octubre_v"),2,1);
		pc.addCols(cdo.getColValue("noviembre_v"),2,1);
		pc.addCols(cdo.getColValue("diciembre_v"),2,1);
		pc.addCols(cdo.getColValue("ac_variacion"),2,1);


		groupBy=cdo.getColValue("codigoPrin");
		descTipoCta=cdo.getColValue("dspTipoCuenta");
		groupUnidad = cdo.getColValue("unidad");

		totalEnero += Double.parseDouble(cdo.getColValue("enero"));
		totalFebrero += Double.parseDouble(cdo.getColValue("febrero"));
		totalMarzo += Double.parseDouble(cdo.getColValue("marzo"));
		totalAbril += Double.parseDouble(cdo.getColValue("abril"));
		totalMayo += Double.parseDouble(cdo.getColValue("mayo"));
		totalJunio += Double.parseDouble(cdo.getColValue("junio"));
		totalJulio += Double.parseDouble(cdo.getColValue("julio"));
		totalAgosto += Double.parseDouble(cdo.getColValue("agosto"));
		totalSeptiembre += Double.parseDouble(cdo.getColValue("septiembre"));
		totalOctubre += Double.parseDouble(cdo.getColValue("octubre"));
		totalNoviembre += Double.parseDouble(cdo.getColValue("noviembre"));
		totalDiciembre += Double.parseDouble(cdo.getColValue("diciembre"));
		totalAcAsignacion += Double.parseDouble(cdo.getColValue("ac_asignacion"));
		totalEnero_c += Double.parseDouble(cdo.getColValue("enero_c"));
		totalFebrero_c += Double.parseDouble(cdo.getColValue("febrero_c"));
		totalMarzo_c += Double.parseDouble(cdo.getColValue("marzo_c"));
		totalAbril_c += Double.parseDouble(cdo.getColValue("abril_c"));
		totalMayo_c += Double.parseDouble(cdo.getColValue("mayo_c"));
		totalJunio_c += Double.parseDouble(cdo.getColValue("junio_c"));
		totalJulio_c += Double.parseDouble(cdo.getColValue("julio_c"));
		totalAgosto_c += Double.parseDouble(cdo.getColValue("agosto_c"));
		totalSeptiembre_c += Double.parseDouble(cdo.getColValue("septiembre_c"));
		totalOctubre_c += Double.parseDouble(cdo.getColValue("octubre_c"));
		totalNoviembre_c += Double.parseDouble(cdo.getColValue("noviembre_c"));
		totalDiciembre_c += Double.parseDouble(cdo.getColValue("diciembre_c"));
		totalAcConsumo += Double.parseDouble(cdo.getColValue("ac_consumo"));
		totalEnero_v += Double.parseDouble(cdo.getColValue("enero_v"));
		totalFebrero_v += Double.parseDouble(cdo.getColValue("febrero_v"));
		totalMarzo_v += Double.parseDouble(cdo.getColValue("marzo_v"));
		totalAbril_v += Double.parseDouble(cdo.getColValue("abril_v"));
		totalMayo_v += Double.parseDouble(cdo.getColValue("mayo_v"));
		totalJunio_v += Double.parseDouble(cdo.getColValue("julio_v"));
		totalJulio_v += Double.parseDouble(cdo.getColValue("julio_v"));
		totalAgosto_v += Double.parseDouble(cdo.getColValue("agosto_v"));
		totalSeptiembre_v += Double.parseDouble(cdo.getColValue("septiembre_v"));
		totalOctubre_v += Double.parseDouble(cdo.getColValue("octubre_v"));
		totalNoviembre_v += Double.parseDouble(cdo.getColValue("noviembre_v"));
		totalDiciembre_v += Double.parseDouble(cdo.getColValue("diciembre_v"));
		totalAcVariacion += Double.parseDouble(cdo.getColValue("ac_variacion"));


	}//for i

	pc.setFont(6,1);
	pc.addCols("            Total de: "+descTipoCta,0,1);
	pc.addCols(""+totalEnero,2,1);
	pc.addCols(""+totalFebrero,2,1);
	pc.addCols(""+totalMarzo,2,1);
	pc.addCols(""+totalAbril,2,1);
	pc.addCols(""+totalMayo,2,1);
	pc.addCols(""+totalJunio,2,1);
	pc.addCols(""+totalJulio,2,1);
	pc.addCols(""+totalAgosto,2,1);
	pc.addCols(""+totalSeptiembre,2,1);
	pc.addCols(""+totalOctubre,2,1);
	pc.addCols(""+totalNoviembre,2,1);
	pc.addCols(""+totalDiciembre,2,1);
	pc.addCols(""+totalAcAsignacion,2,1);

	pc.addCols("Consumo",1,1);
	pc.addCols(""+totalEnero_c,2,1);
	pc.addCols(""+totalFebrero_c,2,1);
	pc.addCols(""+totalMarzo_c,2,1);
	pc.addCols(""+totalAbril_c,2,1);
	pc.addCols(""+totalMayo_c,2,1);
	pc.addCols(""+totalJunio_c,2,1);
	pc.addCols(""+totalJulio_c,2,1);
	pc.addCols(""+totalAgosto_c,2,1);
	pc.addCols(""+totalSeptiembre_c,2,1);
	pc.addCols(""+totalOctubre_c,2,1);
	pc.addCols(""+totalNoviembre_c,2,1);
	pc.addCols(""+totalDiciembre_c,2,1);
	pc.addCols(""+totalAcConsumo,2,1);

	pc.addCols("Variacion",1,1);
	pc.addCols(""+totalEnero_v,2,1);
	pc.addCols(""+totalFebrero_v,2,1);
	pc.addCols(""+totalMarzo_v,2,1);
	pc.addCols(""+totalAbril_v,2,1);
	pc.addCols(""+totalMayo_v,2,1);
	pc.addCols(""+totalJunio_v,2,1);
	pc.addCols(""+totalJulio_v,2,1);
	pc.addCols(""+totalAgosto_v,2,1);
	pc.addCols(""+totalSeptiembre_v,2,1);
	pc.addCols(""+totalOctubre_v,2,1);
	pc.addCols(""+totalNoviembre_v,2,1);
	pc.addCols(""+totalDiciembre_v,2,1);
	pc.addCols(""+totalAcVariacion,2,1);


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>