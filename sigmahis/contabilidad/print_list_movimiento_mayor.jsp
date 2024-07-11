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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
ArrayList alE = new ArrayList();
CommonDataObject cdoE = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String mesF = request.getParameter("mesF");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta1H = request.getParameter("cta1H");
String cta2H = request.getParameter("cta2H");
String cta3H = request.getParameter("cta3H");
String cta4H = request.getParameter("cta4H");
String ctaDesde = "",ctaDesde2="";
String ctaHasta = "",ctaHasta2="";
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String fp = request.getParameter("fp");
String con_movimiento = request.getParameter("con_movimiento");

String fechaDesc = "";
if(!mes.trim().equals("13"))fechaDesc =  "DE "+CmnMgr.getFormattedDate("01/"+mes+"/"+anio,"FMMONTH")+"  "+anio;
if(!mesF.trim().equals("13"))fechaDesc +=" A "+CmnMgr.getFormattedDate("01/"+mesF+"/"+anio,"FMMONTH")+"  "+anio;
if(mes.trim().equals("13")) fechaDesc = "DE MES CIERRE "+anio;
if(mesF.trim().equals("13"))fechaDesc +=" A MES CIERRE "+anio;

if(fp == null) fp="";


if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(cta1==null) cta1="";
if(cta2==null) cta2="";
if(cta3==null) cta3="";
if(cta4==null) cta4="";

if(cta1H==null) cta1H="";
if(cta2H==null) cta2H="";
if(cta3H==null) cta3H="";
if(cta4H==null) cta4H="";

if (appendFilter == null) appendFilter = "";
if (fp.trim().equals("")) appendFilter = " and a.recibe_mov = 'S'";
else appendFilter = " AND (((nvl(a.ult_mes,0) >= to_number('"+mes+"') AND a.ult_anio >= "+anio+") OR a.recibe_mov = 'S') OR (nvl(a.ult_anio ,0) > "+anio+" AND a.ult_anio is not null)) ";
if(con_movimiento!=null && con_movimiento.equals("S")) appendFilter = " and (nvl(p.debito, 0) != 0 or nvl(p.credito, 0) != 0)";
/*

 AND TO_NUMBER(CTA1||CTA2||CTA3)   >= TO_NUMBER(NVL(:P_CTA1,CTA1)||NVL(:P_CTA2,CTA2)||NVL(:P_CTA3,CTA3))
 AND TO_NUMBER(CTA1||CTA2||CTA3)   <= TO_NUMBER(NVL(:P_CTA4,CTA1)||NVL(:P_CTA5,CTA2)||NVL(:P_CTA6,CTA3))
*/
if (!cta1.trim().equals("")) 
{ 
	ctaDesde   +="a.cta1";
	ctaDesde2  +=cta1;
}
if (!cta2.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||a.cta2";
		ctaDesde2  +=""+cta2;
	}
}
if (!cta3.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||a.cta3";
		ctaDesde2  +=""+cta3;
	}
}
if (!cta4.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||a.cta4";
		ctaDesde2  +=""+cta4;
	}
}
if (!ctaDesde.trim().equals("") && !ctaDesde2.trim().equals("")) appendFilter += " and to_number("+ctaDesde+") >= to_number('"+ctaDesde2+"')";



if (!cta1H.trim().equals("")) 
{ 
	ctaHasta   +="a.cta1";
	ctaHasta2  +=cta1H;
}
if (!cta2H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||a.cta2";
		ctaHasta2  +=""+cta2H;
	}
}
if (!cta3H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||a.cta3";
		ctaHasta2  +=""+cta3H;
	}
}
if (!cta4H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||a.cta4";
		ctaHasta2  +=""+cta4H;
	}
}

if (!ctaHasta.trim().equals("") && !ctaHasta2.trim().equals("")) appendFilter += " and to_number("+ctaHasta+") <= to_number('"+ctaHasta2+"')";


sql="select a.cta1||' '||a.cta2||' '||a.cta3||' '||a.cta4||' '||a.cta5||' '||a.cta6 cuenta,nvl(p.debito,0) debito, nvl(p.credito,0)credito, p.descripcion, p.comentario, nvl(p.consecutivo, 0) as consecutivo , nvl(p.renglon,'')as renglon, a.* ,decode(a.mesm,13,'MES CIERRE',to_char(to_date(a.mesm,'mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH')) mesI from (select to_char(m.fecha_creacion,'dd/mm/yyyy') as fc, m.usuario_creacion as uc, a.compania, a.recibe_mov,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6, a.descripcion nom_cta, m.ea_ano aniom, m.mes mesm, nvl(m.monto_i,0)monto_i,(nvl(m.monto_i,0)+nvl(m.monto_db,0) - nvl(m.monto_cr,0)) as monto_f,decode('"+mesF+"','13','MES CIERRE',to_char(to_date('"+mesF+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH')) mesF,a.ult_mes,a.ult_anio FROM TBL_CON_CATALOGO_GRAL a, TBL_CON_MOV_MENSUAL_CTA m WHERE a.compania = m.pc_compania(+) AND a.cta1 = m.cat_cta1(+) AND a.cta2 = m.cat_cta2(+) AND a.cta3 = m.cat_cta3(+)  AND a.cta4 = m.cat_cta4(+) AND a.cta5 = m.cat_cta5(+) AND a.cta6 = m.cat_cta6(+) and compania= " + (String) session.getAttribute("_companyId") +" ORDER BY  to_number(a.cta1||a.cta2||a.cta3||a.cta4||a.cta5||a.cta6) ) a , (SELECT (DECODE(d.tipo_mov, 'DB',d.valor)) debito, (DECODE(d.tipo_mov,'CR',d.valor)) credito, e.descripcion, d.comentario, d.cta1 ctae1, d.cta2 ctae2, d.cta3 ctae3, d.cta4 ctae4,d.cta5 ctae5, d.cta6 ctae6,d.consecutivo, d.renglon,e.ea_ano,e.mes,e.compania  FROM TBL_CON_ENCAB_COMPROB e, TBL_CON_DETALLE_COMPROB d WHERE d.compania = e.compania AND d.consecutivo=e.consecutivo and d.ano = e.ea_ano AND e.status = 'AP' and e.tipo=d.tipo and e.reg_type=d.reg_type ) p where  a.compania = " + (String) session.getAttribute("_companyId") +" and a.aniom = p.ea_ano(+) and a.compania = p.compania(+) and a.mesm = p.mes(+) AND a.cta1 = p.ctae1(+) AND a.cta2 = p.ctae2(+) AND a.cta3 = p.ctae3(+) AND a.cta4 = p.ctae4(+) and a.cta5 = p.ctae5(+)  and a.cta6 = p.ctae6(+) and a.aniom="+anio+" and a.mesm >= to_number('"+mes+"') AND a.mesm <=to_number('"+mesF+"') "+appendFilter+" ORDER BY a.aniom,to_number(a.cta1),to_number(a.cta2),to_number(a.cta3),to_number(a.cta4),to_number(a.cta5),to_number(a.cta6),a.mesm,p.consecutivo,p.renglon asc ";

	al = SQLMgr.getDataList(sql);
		
		/*if(!mes.trim().equals("13"))cdoSI = SQLMgr.getData("select 'AL ' || to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DE "+anio+"' fecha from dual");
		else cdoSI = SQLMgr.getData("select 'MES CIERRE  "+anio+"' as fecha from dual");
		*/
		

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
	String title = "CONTABILIDAD";
	String subtitle = "MOVIMIENTO MAYOR";
	String xtraSubtitle = ""+fechaDesc;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".04");
	dHeader.addElement(".12");
	dHeader.addElement(".08");
	dHeader.addElement(".07");
	dHeader.addElement(".13");
	dHeader.addElement(".17");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
		

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(7, 1);			
			pc.addBorderCols("AÑO",0,1);
			pc.addBorderCols("CREADO POR",1,1);
			pc.addBorderCols("CREADO EL",1,1);
			pc.addBorderCols("NO. TRX",1);
			pc.addBorderCols("DESCRIPCIÓN",0,2);
			pc.addBorderCols("DÉBITOS",2);
			pc.addBorderCols("CRÉDITOS",2);
			pc.addBorderCols(" ",2);			
			
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "",groupBy1="",groupBy2="",groupBy3 ="";
	String detMov = "",descMes="",descCta="";
	double saldo = 0.00;
	double totdb = 0.00,totcr = 0.00,totdbMes = 0.00,totcrMes = 0.00,totdbCta = 0.00,totcrCta = 0.00,totdbAnio = 0.00,totcrAnio = 0.00;
	double totMes = 0.00,totMesCta = 0.00,totaldb=0.00,totalcr=0.00,saldoI=0.00,saldoITot=0.00,saldoFinCta=0.00;
		
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		//saldo += Double.parseDouble(cdo.getColValue("debito"));
		//saldo -= Double.parseDouble(cdo.getColValue("credito"));
		//grupo por mes		
		
		if (!groupBy3.equalsIgnoreCase(cdo.getColValue("mesm"))||!groupBy1.equalsIgnoreCase(cdo.getColValue("cuenta")))
		{
			if (i!=0)
			{
				pc.setFont(7, 1);
				pc.addCols("Totales por mes: "+descMes,2,5);
				pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totdbMes),2,2);
				pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totcrMes),2,1);
				pc.addCols("S.F: "+CmnMgr.getFormattedDecimal(totdbMes-totcrMes),2,1);
				totdbMes = 0.00;
				totcrMes = 0.00; 
			}
		}
		if (!groupBy1.equalsIgnoreCase(cdo.getColValue("cuenta")))
		{
			if (i!=0)
			{
				pc.setFont(7, 1);
				
				pc.addCols("Totales por Cuenta: "+descCta,2,5);
				pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totdbCta),2,2);
				pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totcrCta),2,1);
				pc.addCols("S.F.C: "+(((saldoFinCta)>=0)?CmnMgr.getFormattedDecimal(saldoFinCta):"("+CmnMgr.getFormattedDecimal((saldoFinCta)*-1)+")"),2,1);
				
				saldoITot += saldoI+totdbCta-totcrCta;
				saldoFinCta =0.00;
				totdbCta = 0.00;
				totcrCta = 0.00;
				saldoI=0.00;
				pc.addCols(" ",1,dHeader.size());
			}
						
			pc.setFont(8, 3);
			pc.addCols(" Cta "+cdo.getColValue("cuenta"),0,5);
			pc.addCols(" "+cdo.getColValue("nom_cta"),0,4);
			//saldoIniCta = Double.parseDouble(cdo.getColValue("monto_i"));
		}	
		if (!groupBy3.equalsIgnoreCase(cdo.getColValue("mesm"))||!groupBy1.equalsIgnoreCase(cdo.getColValue("cuenta")))
		{
				pc.setFont(7, 0);
				//pc.addBorderCols("Año: "+cdo.getColValue("aniom"),0,1);
				pc.addBorderCols("        "+cdo.getColValue("mesI"),0,7);
				pc.addBorderCols("S.I:   "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_i")),2,2);
				saldoI = Double.parseDouble(cdo.getColValue("monto_i"));
				//saldoITot = Double.parseDouble(cdo.getColValue("monto_i"));
		}
	
				pc.setFont(7, 0);
				pc.addCols(cdo.getColValue("aniom"),0,1);
				pc.addCols(cdo.getColValue("uc"),1,1);
				pc.addCols(cdo.getColValue("fc"),1,1);
				if(!cdo.getColValue("consecutivo").trim().equals("0"))pc.addCols("  "+cdo.getColValue("consecutivo")+" - "+cdo.getColValue("renglon"),0,1);
				else pc.addCols("  ",0,1);
				
				pc.addCols("  "+cdo.getColValue("descripcion")+"    "+cdo.getColValue("comentario"),0,2);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
				pc.addCols("  ",0,1);
				totdbMes 	+= Double.parseDouble(cdo.getColValue("debito"));
				totcrMes 	+= Double.parseDouble(cdo.getColValue("credito"));
				totdbAnio 	+= Double.parseDouble(cdo.getColValue("debito"));
				totcrAnio 	+= Double.parseDouble(cdo.getColValue("credito"));
				totdbCta 	+= Double.parseDouble(cdo.getColValue("debito"));
				totcrCta 	+= Double.parseDouble(cdo.getColValue("credito"));
				totaldb 	+= Double.parseDouble(cdo.getColValue("debito"));
				totalcr 	+= Double.parseDouble(cdo.getColValue("credito"));
				saldoFinCta  = Double.parseDouble(cdo.getColValue("monto_f"));
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy1 = cdo.getColValue("cuenta");
		groupBy3 = cdo.getColValue("mesm");
		totMes = Double.parseDouble(cdo.getColValue("monto_f"));
		descMes =cdo.getColValue("mesI");
		descCta =cdo.getColValue("nom_cta");
	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
			pc.setFont(7,1);
			pc.addCols("Totales por mes: "+descMes,2,5);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totdbMes),2,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totcrMes),2,1);
			pc.addCols("S.F: "+CmnMgr.getFormattedDecimal(totdbMes-totcrMes),2,1);
			

			pc.addCols("Totales por Cuenta: "+descCta,2,5);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totdbCta),2,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totcrCta),2,1);
			pc.addCols("S.F.C: "+(((saldoFinCta)>=0)?CmnMgr.getFormattedDecimal(saldoFinCta):"("+CmnMgr.getFormattedDecimal((saldoFinCta)*-1)+")"),2,1);

			pc.addCols(" ",2,dHeader.size());
			
			pc.setFont(8,1);
			pc.addCols("Totales Finales: ",2,5);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totaldb),2,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totalcr),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal("999,999,990.00",totaldb-totalcr),2,1);			
		//	pc.addCols(" S.F..   "+CmnMgr.getFormattedDecimal(saldoITot+totaldb-totalcr),2,1);
		//	pc.addCols(" S..F.   "+(((saldoITot+totaldb-totalcr)>=0)?CmnMgr.getFormattedDecimal(saldoITot+totaldb-totalcr):"("+CmnMgr.getFormattedDecimal((saldoITot+totaldb-totalcr)*-1))+")",2,1);
	
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>