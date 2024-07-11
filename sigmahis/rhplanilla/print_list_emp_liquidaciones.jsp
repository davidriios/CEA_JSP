<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
<jsp:useBean id="cdo1" scope="page" class="issi.admin.CommonDataObject" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==========================================================================
==========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String acr        = request.getParameter("acr");
String grupoDesc  = request.getParameter("grupoDesc");
String descontar  = request.getParameter("descontar");
String pendiente  = request.getParameter("pendiente");
String eliminar   = request.getParameter("eliminar");
String noDescontar = request.getParameter("noDescontar");
String anio  = request.getParameter("anio");
String fecha_inicial = request.getParameter("fecha_inicial");
String fecha_final 	= request.getParameter("fecha_final");
String fp  = request.getParameter("fp");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (anio        == null) anio        = "";
if (fecha_inicial  == null) fecha_inicial  = "";
if (fecha_final  == null) fecha_final  = "";


if (!anio.equals(""))   
 {
  appendFilter += " and b.anio = "+anio;
 } 

 
if (!fecha_inicial.equals(""))
   {
  appendFilter += " and to_date(to_char(a.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fecha_inicial+"', 'dd/mm/yyyy')";
   }

if (!fecha_final.equals(""))
   {
   appendFilter += " and to_date(to_char(a.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fecha_final+"', 'dd/mm/yyyy')" ;   
   }
 
sql= "SELECT ALL a.num_empleado, a.rata_hora, b.anio, a.primer_nombre||' '||a.segundo_nombre||' '|| decode(a.sexo,'f',decode(a.apellido_casada, null,a.primer_apellido, decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) nombre, decode(a.provincia,0,' ',00,' ',11,'B',12,'C',a.provincia)||decode(a.sigla,'00','  ','0','  ', a.sigla) ||'-'||to_char(a.tomo)|| '-' ||to_char(a.asiento) cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.cod_compania, a.fecha_egreso, a.ubic_fisica unidad_adm, c.descripcion dsp_unidad, SUM(NVL(b.salario,0)) sal_bruto, SUM(NVL(b.vacacion,0)) vacacion, SUM(NVL(b.ausencia,0) + NVL(b.tardanza,0)) ayt, SUM(NVL(b.sal_neto,0)) sal_neto, SUM(NVL(b.extra,0)) extra, SUM(NVL(b.seg_social,0)) seg_social, SUM(NVL(b.seg_educativo,0)) seg_educativo, SUM(NVL(b.imp_renta,0)) imp_renta, SUM(NVL(b.otras_ded,0)) otras_ded, SUM(NVL(b.total_ded,0)) total_ded, SUM(NVL(b.gasto_rep,0)) gasto_rep, SUM(NVL(b.otros_ing,0)) otros_ing, SUM(NVL(b.otros_egr,0))  otros_egr, SUM(NVL(b.indemnizacion,0)) indemnizacion, SUM(NVL(b.preaviso,0)) preaviso, SUM(NVL(b.xiii_mes,0)) xiii_mes, SUM(NVL(b.prima_antiguedad,0)) prima_antiguedad, SUM(NVL(b.bonificacion,0)) bonificacion, SUM(NVL(b.prima_produccion,0)) incentivo, ' Pago de Liquidación generado el : '|| TO_CHAR(TO_DATE(d.fecha_pago,'dd/mm/yyyy'),'DD')||' de '||UPPER(RTRIM(LTRIM( TO_CHAR(TO_DATE(d.fecha_pago,'dd/mm/yyyy'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))))||' de '||TO_CHAR(d.fecha_pago,'yyyy') fecha, d.fecha_pago, g.denominacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') ingreso, a.salario_base salario FROM tbl_pla_empleado a, tbl_pla_pago_liquidacion b, tbl_sec_unidad_ejec c, tbl_pla_planilla_encabezado d, tbl_pla_cargo g WHERE b.emp_id = a.emp_id AND b.cod_compania = a.compania  AND c.codigo = a.ubic_fisica AND c.compania = b.cod_compania AND b.cod_planilla = 8 AND b.cod_compania = d.cod_compania AND b.cod_planilla = d.cod_planilla AND b.num_planilla = d.num_planilla  and a.cargo = g.codigo and a.compania = g.compania AND b.cod_compania ="+(String) session.getAttribute("_companyId")+appendFilter+" GROUP BY a.ubic_fisica, c.descripcion, a.num_empleado, a.rata_hora, a.fecha_egreso, b.anio,  b.provincia, b.sigla, b.tomo, b.asiento, b.cod_compania, a.primer_nombre||' '||a.segundo_nombre||' '|| decode(a.sexo,'f',decode(a.apellido_casada, null,a.primer_apellido, decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido), decode(a.provincia,0,' ',00,' ',11,'B',12,'C',a.provincia)||decode(a.sigla,'00','  ','0','  ', a.sigla) ||'-'||to_char(a.tomo)|| '-' ||to_char(a.asiento),' Pago de Liquidación generado el : '|| TO_CHAR(TO_DATE(d.fecha_pago,'dd/mm/yyyy'),'DD')||' de '||UPPER(RTRIM(LTRIM( TO_CHAR(TO_DATE(d.fecha_pago,'dd/mm/yyyy'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))))||' de '||TO_CHAR(d.fecha_pago,'yyyy'),d.fecha_pago, g.denominacion, to_char(a.fecha_ingreso,'dd/mm/yyyy'), a.salario_base";
   al = SQLMgr.getDataList(sql);  
 
sql= "SELECT SUM(NVL(b.salario,0)) tsal_bruto, SUM(NVL(b.vacacion,0)) tvacacion, SUM(NVL(b.ausencia,0) + NVL(b.tardanza,0)) tayt, SUM(NVL(b.sal_neto,0)) tsal_neto, SUM(NVL(b.extra,0)) textra, SUM(NVL(b.seg_social,0)) tseg_social, SUM(NVL(b.seg_educativo,0)) tseg_educativo, SUM(NVL(b.imp_renta,0)) timp_renta, SUM(NVL(b.otras_ded,0)) totras_ded, SUM(NVL(b.total_ded,0)) ttotal_ded, SUM(NVL(b.gasto_rep,0)) tgasto_rep, SUM(NVL(b.otros_ing,0)) totros_ing, SUM(NVL(b.otros_egr,0)) totros_egr, SUM(NVL(b.indemnizacion,0)) tindemnizacion, SUM(NVL(b.preaviso,0)) tpreaviso, SUM(NVL(b.xiii_mes,0)) txiii_mes, SUM(NVL(b.prima_antiguedad,0)) tprima_antiguedad, SUM(NVL(b.bonificacion,0)) tbonificacion, SUM(NVL(b.prima_produccion,0)) tincentivo FROM tbl_pla_empleado a, tbl_pla_pago_liquidacion b, tbl_sec_unidad_ejec c WHERE b.emp_id = a.emp_id AND b.cod_compania = a.compania  AND c.codigo = a.ubic_fisica AND c.compania = b.cod_compania AND b.cod_planilla = 8 AND b.cod_compania ="+(String) session.getAttribute("_companyId")+appendFilter;
   cdo1 = SQLMgr.getData(sql);  

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();
	Hashtable htSec = new Hashtable();

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	float headerFooterFont = 8f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = " CESANTIAS del "+fecha_inicial+" al "+fecha_final;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector infoCol2 = new Vector();
		infoCol2.addElement(".15");
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");		
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");
		infoCol2.addElement(".02");
		infoCol2.addElement(".11");
		infoCol2.addElement(".39");

	Vector dHeader = new Vector();
		dHeader.addElement(".08");		
		dHeader.addElement(".07");				
		dHeader.addElement(".07");			
		dHeader.addElement(".07");	
		dHeader.addElement(".07");
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
		dHeader.addElement(".08");
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
		dHeader.addElement(".07");	
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 
		float cHeight = 12.0f;
		
		pc.setVAlignment(0);
		pc.setNoColumnFixWidth(dHeader);
   
	pc.setFont(8, 1);
	pc.addBorderCols("Fecha Cesantía.",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("Salario Regular.",2,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("Ausencia + Tardanza",2,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("Vacaciones",2,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("XIII Mes",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Prima de Antiguedad",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Preaviso",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Indemnizacion",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Otros Egresos",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Impuesto S/Renta",2,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("Seguro Social",2,1,1.0f,1.0f,0.0f,0.0f);	
		pc.addBorderCols("Seguro Educativo",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("Otras Deducciones",2,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("Total",1,1,1.0f,1.0f,0.0f,0.0f);  
   
	String groupBy = "";
	int pxu = 0, pxs = 0, pxg = 0;
	double sal = 0;
	double ayt = 0, vac = 0, xii = 0, prm = 0, pre = 0, ind = 0, ote = 0;
	double imp = 0, ssc = 0, sse = 0, ode = 0, san = 0;
	
	double total = 0, totSaldo = 0, totDescontado = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad_admin")))
		{ 
		
		if (i != 0)
			  {
			    pc.setFont(7, 1);
				pc.addCols("Total x Unidad",0,1);
		       	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(sal),2,1,0.0f,1.0f,0.0f,0.0f);							
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ayt),2,1,0.0f,1.0f,0.0f,0.0f);							
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(vac),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(xii),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(prm),2,1,0.0f,1.0f,0.0f,0.0f);														
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(pre),2,1,0.0f,1.0f,0.0f,0.0f);							
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ind),2,1,0.0f,1.0f,0.0f,0.0f);								
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ote),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(imp),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ssc),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(sse),2,1,0.0f,1.0f,0.0f,0.0f);	
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ode),2,1,0.0f,1.0f,0.0f,0.0f);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(san),2,1,0.0f,1.0f,0.0f,0.0f);					
				pc.addCols(" ",0,dHeader.size());
					pxu = 0;	
					sal = 0; ayt = 0; vac = 0; xii = 0; prm = 0; pre = 0; ind = 0; ote = 0;
					imp = 0; ssc = 0; sse = 0; ode = 0; san = 0;
					
			   }//i-1 
			  
			pc.setFont(8, 1);					
		pc.addBorderCols(" "+cdo.getColValue("dsp_unidad"),0,dHeader.size(),cHeight * 1,Color.lightGray);
		
		
		}	
	    // Listado de Descuentos por Acreedor
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
		    pc.addCols(" "+cdo.getColValue("fecha_egreso"),0,1);					
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("sal_bruto"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("ayt"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("vacacion"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("xiii_mes"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("prima_antiguedad"))),2,1);														
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("preaviso"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("indemnizacion"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("otros_egr"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("imp_renta"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("seg_social"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("seg_educativo"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("otras_ded"))),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("sal_neto"))),2,1);						
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());	
			
	 	 	pxu++;	
	   		groupBy = cdo.getColValue("unidad_admin"); 
			
			
			sal += (Double.parseDouble(cdo.getColValue("sal_bruto")));
			ayt += (Double.parseDouble(cdo.getColValue("ayt")));
			vac += (Double.parseDouble(cdo.getColValue("vacacion")));
			xii += (Double.parseDouble(cdo.getColValue("xiii_mes")));
			prm += (Double.parseDouble(cdo.getColValue("prima_antiguedad")));
			pre += (Double.parseDouble(cdo.getColValue("preaviso")));
			ind += (Double.parseDouble(cdo.getColValue("indemnizacion")));
			ote += (Double.parseDouble(cdo.getColValue("otros_egr")));
			imp += (Double.parseDouble(cdo.getColValue("imp_renta")));
			ssc += (Double.parseDouble(cdo.getColValue("seg_social")));
			sse += (Double.parseDouble(cdo.getColValue("seg_educativo")));
			ode += (Double.parseDouble(cdo.getColValue("otras_ded")));
			san += (Double.parseDouble(cdo.getColValue("sal_neto")));
			
	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}// final del for
	
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size()); 		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{	
	    pc.setFont(7, 1);
		 
			pc.addCols("Total x Unidad",0,1);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(sal),2,1,0.0f,1.0f,0.0f,0.0f);							
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ayt),2,1,0.0f,1.0f,0.0f,0.0f);							
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(vac),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(xii),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(prm),2,1,0.0f,1.0f,0.0f,0.0f);														
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(pre),2,1,0.0f,1.0f,0.0f,0.0f);							
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ind),2,1,0.0f,1.0f,0.0f,0.0f);								
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ote),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(imp),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ssc),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(sse),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(ode),2,1,0.0f,1.0f,0.0f,0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(san),2,1,0.0f,1.0f,0.0f,0.0f);	
			pc.addCols(" ",0,dHeader.size());	
			
			
				
	 pc.setFont(7, 1);
		 
	pc.addCols("TOTALES FINALES ",0,1,cHeight * 2,Color.lightGray);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tsal_bruto"))),2,1,cHeight * 1,Color.lightGray);							
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tayt"))),2,1,cHeight * 1,Color.lightGray);						
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tvacacion"))),2,1,cHeight * 1,Color.lightGray);	
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("txiii_mes"))),2,1,cHeight * 1,Color.lightGray);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tprima_antiguedad"))),2,1,cHeight * 1,Color.lightGray);														
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tpreaviso"))),2,1,cHeight * 1,Color.lightGray);						
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tindemnizacion"))),2,1,cHeight * 1,Color.lightGray);							
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("totros_egr"))),2,1,cHeight * 1,Color.lightGray);	
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("timp_renta"))),2,1,cHeight * 1,Color.lightGray);	
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tseg_social"))),2,1,cHeight * 1,Color.lightGray);	
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tseg_educativo"))),2,1,cHeight * 1,Color.lightGray);	
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("totras_ded"))),2,1,cHeight * 1,Color.lightGray);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo1.getColValue("tsal_neto"))),2,1,cHeight * 1,Color.lightGray);
				
		pc.addCols(" ",0,dHeader.size());	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>





