<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
CommonDataObject cdoF = new CommonDataObject();
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String cod = request.getParameter("codPlanilla"); 
String num = request.getParameter("numPlanilla"); 
String anio = request.getParameter("anio");
String compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "N";
if (fp == null) fp = "";


	sql.append("select 'A' type,nvl(a.sal_bruto,0) as salBruto, nvl(a.sal_neto,0) as salNeto, nvl(a.ausencia,0) as ausencia, nvl(a.seg_social,0)/*-nvl(a.seg_social_gasto,0)*/ as segSocial, nvl(a.seg_educativo,0) as segEducativo, nvl(a.imp_renta,0) as impRenta, nvl(a.fondo_com,0) as fonCom, nvl(a.tardanza,0) tardanza, nvl(a.otras_ded,00) as otrasDed, nvl(a.total_ded,0) +  nvl(a.otros_egr,0) as totDed, nvl(a.dev_multa,0) as devMul, nvl(a.comision,0), nvl(a.gasto_rep,0) as gastoRep, nvl(a.ayuda_mortuoria,0) as aMor, nvl(a.otros_ing,0) as otrosIng, nvl(a.otros_egr,0) as otrosEgr, a.alto_riesgo as altRiesgo, nvl(a.bonificacion,0)bonificacion, nvl(a.extra,0) as extra, nvl(a.prima_produccion,0) as prima, nvl(a.indemnizacion,0) indemnizacion, nvl(a.vacacion,0)vacacion,nvl(a.pago_40porc,0)pago_40porc,nvl(a.preaviso,0)preaviso, nvl(a.xiii_mes,0)decimo, nvl(a.prima_antiguedad,0) primaAntiguedad,nvl(a.incentivo,0)incentivo, 0 as aguiGas,nvl(a.imp_renta_gasto,0) as impRentaGasto, '' as cheque, nvl(a.seg_social_gasto,0) as ssGasto, a.cod_planilla codigoPla, (nvl(a.sal_bruto,0) + nvl(a.vacacion,0) + nvl(a.pago_40porc,0) + nvl(a.extra,0) + nvl(a.gasto_rep,0) + nvl(a.otros_ing,0) + nvl(a.otros_ing_fijos,0) + nvl(a.indemnizacion,0) + nvl(a.preaviso,0) + nvl(a.xiii_mes,0) + nvl(a.prima_antiguedad,0) + nvl(a.bonificacion,0) + nvl(a.incentivo,0) + nvl(a.prima_produccion,0)) - (nvl(a.ausencia,0) + nvl(a.tardanza,0))ingTot, 0 as salEsp, 0 as ssEsp, a.num_empleado as numEmpleado, to_char(a.num_cheque,'0000000') as numCheque, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd-mm-yyyy') as fechaInicial, decode(a.provincia,0,' ',00,' ',a.provincia)||rpad(decode(a.sigla,'00','  ','0','  ',a.sigla),2,' ')||'-'||lpad(to_char(a.tomo),5,'0')||'-'|| lpad(to_char(a.asiento),6,'0') cedula, b.num_ssocial, to_char(c.fecha_final,'dd-mm-yyyy') as fechaFinal, c.estado, b.primer_nombre||' '||decode(b.sexo,'F',decode(b.apellido_casada,null,b.primer_apellido,decode(b.usar_apellido_casada,'S','DE '|| b.apellido_casada, b.primer_apellido)), b.primer_apellido) as nomEmpleado, f.denominacion cargo, to_char(b.rata_hora,'999,990.00') as rataHora, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, 'PLANILLA DE AJUSTES A - ' ||ltrim(d.nombre,18)||' del '||to_char(c.fecha_inicial,'dd/mm/yyy')||' al '||to_char(c.fecha_final,'dd/mm/yyy')||' ( ");
	sql.append(anio);
	sql.append(" - ");
	sql.append(num);	
	sql.append(" )' as descripcion, b.num_cuenta, to_char(b.salario_base/2,'999,999,990.00') salarioBase , b.ubic_depto depto, b.ubic_seccion unidad,(select descripcion from tbl_sec_unidad_ejec where codigo = b.ubic_depto and compania =b.compania) descDepto, ( select 	descripcion from tbl_sec_unidad_ejec where codigo = b.ubic_seccion and compania =b.compania) descUnidad ,a.emp_id,a.secuencia, ' ' descDescuento from tbl_pla_pago_ajuste a, tbl_pla_empleado b, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo f where a.emp_id = b.emp_id and a.cod_compania = b.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.cod_compania = f.compania and b.cargo = f.codigo and a.num_planilla=");
	sql.append(num);
	sql.append(" and a.cod_planilla=");
	sql.append(cod);
	sql.append(" and a.anio = ");
	sql.append(anio);
	sql.append( " and a.cod_compania=");
	sql.append( session.getAttribute("_companyId"));
	sql.append("  and a.acc_estado = 'N'  ");
	if(!fp.trim().equals("REG"))sql.append(" and a.estado in('AC') ");
if(!fg.trim().equals("R")){
	sql.append(" union  select 'B' type,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,' ',0,0,0,0,0,' ',' ',' ',' ',' ',' ',' ',' ',' ','' cargo,' ',' ',' ',' ' num_cuenta,' ',b.ubic_depto,b.ubic_seccion unidad,'','',t.emp_id,t.secuencia,t.cod_acreedor||'  -  '||(select nombre from tbl_pla_acreedor where cod_acreedor =t.cod_acreedor and compania=t.cod_compania)||'         -'||t.monto from tbl_pla_descuento_ajuste t ,tbl_pla_empleado b,tbl_pla_pago_ajuste pa  where t.emp_id =b.emp_id and t.cod_compania = b.compania and  t.emp_id = pa.emp_id  and t.anio = pa.anio and t.cod_planilla =pa.cod_planilla and t.num_planilla =pa.num_planilla and t.secuencia = pa.secuencia and t.cod_compania = pa.cod_compania and pa.acc_estado = 'N' and t.cod_compania=");
sql.append((String) session.getAttribute("_companyId"));
	if(!fp.trim().equals("REG"))sql.append(" and pa.estado in('AC') ");
	if(!num.trim().equals("")){sql.append(" and t.num_planilla=");sql.append(num);}
	if(!cod.trim().equals("")){sql.append(" and t.cod_planilla=");sql.append(cod);}
	if(!anio.trim().equals("")){sql.append(" and t.anio=");sql.append(anio);}
}
	sql.append(" order by unidad, depto,emp_id,secuencia,1");

al = SQLMgr.getDataList(sql.toString());

	if(al.size() > 0)cdoF = (CommonDataObject) al.get(0);

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
	String title = "PLANILLA";
	String subtitle = "PLANILLA DE AJUSTE ";
	String xtraSubtitle = ""+cdoF.getColValue("descripcion");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	//if(fg.trim().equals("D"))
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		//dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		
		
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(6, 0);
		if(fg.trim().equals("D")){pc.addBorderCols("EMPLEADO",1);
		pc.addBorderCols("MONTO REG.",1);}
		else pc.addBorderCols("MONTO REG.",1,2);
		pc.addBorderCols("VAC.",1);
		pc.addBorderCols("EXTRAS",1);
		pc.addBorderCols("AUSEN.",1);
		pc.addBorderCols("TARD.",1);			
		pc.addBorderCols("O. ING.",1);
		pc.addBorderCols("INDEN.",1);								
		pc.addBorderCols("PREAVISO",1);	
		pc.addBorderCols("XII MES ",1);	
		pc.addBorderCols("P.PROD.",1);
		pc.addBorderCols("G. REPRE.",1);
		pc.addBorderCols("BONIF.",1);
		pc.addBorderCols("INCENT.",1);
		pc.addBorderCols("P. ANT.",1);
		//pc.addBorderCols("40% DE SAL.",1);		
		pc.addBorderCols("S. SOCIAL.",1);
		pc.addBorderCols("S. EDUC.",1);
		pc.addBorderCols("IMP. RENTA",1);	
		pc.addBorderCols("IMP. GASTO",1);	
		pc.addBorderCols("EGRESOS",1);	
		pc.addBorderCols("NETO",1);	
												
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String unidad = "",depto="",descDepto="",descUnidad="";
		
		double totalDepto =0.00,totalUnidad =0.00;
		
		double salBruto=0.00,vacacion=0.00,  extra=0.00,  ausencia=0.00, tardanza=0.00, otrosIng=0.00, indemnizacion=0.00;
		double preaviso=0.00,  decimo=0.00, prima=0.00, gastoRep=0.00, bonificacion=0.00, incentivo=0.00, primaAntiguedad=0.00, pago_40porc=0.00, segSocial=0.00;
		double segEducativo =0.00, impRenta=0.00, impRentaGasto=0.00, totDed=0.00;
		
		double undsalBruto=0.00,undvacacion=0.00,  undextra=0.00, undausencia=0.00, undtardanza=0.00, undotrosIng=0.00, undindemnizacion=0.00;
		double undpreaviso=0.00,  unddecimo=0.00, undprima=0.00, undgastoRep=0.00, undbonificacion=0.00, undincentivo=0.00, undprimaAntiguedad=0.00, undpago_40porc=0.00; 
		double undsegSocial=0.00,undsegEducativo =0.00, undimpRenta=0.00, undimpRentaGasto=0.00, undtotDed=0.00;
		
		double totalsalBruto=0.00,totalvacacion=0.00,  totalextra=0.00, totalausencia=0.00, totaltardanza=0.00, totalotrosIng=0.00, totalindemnizacion=0.00;
		double totalpreaviso=0.00,totaldecimo=0.00,totalprima=0.00,totalgastoRep=0.00,totalbonificacion=0.00,totalincentivo=0.00,totalprimaAntiguedad=0.00,totalpago_40porc=0.00; 
		double totalsegSocial=0.00,totalsegEducativo =0.00, totalimpRenta=0.00, totalimpRentaGasto=0.00, totaltotDed=0.00, totalNeto=0.00;
		
		
		
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!depto.equalsIgnoreCase(cdo.getColValue("depto")))
			{
				pc.addCols("",0,dHeader.size());
				if(i !=0)
				{
					
					//pc.addCols(" TOT. POR DEPTO ---- "+descDepto+" ============>>> "+CmnMgr.getFormattedDecimal(totalDepto),0,dHeader.size());
					pc.addCols(" TOT. POR DEPTO ---- "+descDepto+" ============>>> ",0,dHeader.size());
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+salBruto),2,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+vacacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+extra),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+ausencia),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+tardanza),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+otrosIng),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+indemnizacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+preaviso),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+decimo),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+prima),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+gastoRep),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+bonificacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+incentivo),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+primaAntiguedad),2,1);	
					//pc.addCols(" "+CmnMgr.getFormattedDecimal(""+pago_40porc),2,1);																		
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+segSocial),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+segEducativo),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+impRenta),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+impRentaGasto),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totDed),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totalDepto),2,1);
				
					pc.addCols(" ",0,dHeader.size());
					totalDepto =0.00;	
					salBruto=0.00;vacacion=0.00;  extra=0.00;  ausencia=0.00; tardanza=0.00; otrosIng=0.00; indemnizacion=0.00;
		 			preaviso=0.00;  decimo=0.00; prima=0.00; gastoRep=0.00; bonificacion=0.00; incentivo=0.00; primaAntiguedad=0.00; pago_40porc=0.00; segSocial=0.00;
		 			segEducativo =0.00; impRenta=0.00; impRentaGasto=0.00; totDed=0.00;
					
					
				}
			}
			if (!unidad.equalsIgnoreCase(cdo.getColValue("unidad")))
			{
				pc.addCols("",0,dHeader.size());
				if(i !=0)
				{
					
					
					//pc.addCols(" TOTALES POR UNIDAD ---- "+descUnidad+" ============>>> "+CmnMgr.getFormattedDecimal(totalUnidad),0,dHeader.size());
					pc.addCols(" TOTALES POR UNIDAD ---- "+descUnidad+" ============>>> ",0,dHeader.size());
					
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsalBruto),2,2);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undvacacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undextra),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undausencia),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undtardanza),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undotrosIng),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undindemnizacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undpreaviso),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+unddecimo),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undprima),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undgastoRep),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undbonificacion),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undincentivo),2,1);
					//pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undprimaAntiguedad),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undpago_40porc),2,1);																		
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsegSocial),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsegEducativo),2,1);	
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undimpRenta),2,1);																			
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undimpRentaGasto),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undtotDed),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totalUnidad),2,1);
					
					pc.addCols(" ",0,dHeader.size());
					totalUnidad =0.00;	
					undsalBruto=0.00;undvacacion=0.00;  undextra=0.00; undausencia=0.00; undtardanza=0.00; undotrosIng=0.00; undindemnizacion=0.00;
			        undpreaviso=0.00;  unddecimo=0.00; undprima=0.00; undgastoRep=0.00; undbonificacion=0.00; undincentivo=0.00;undprimaAntiguedad=0.00; undpago_40porc=0.00; 
		 		    undsegSocial=0.00;undsegEducativo =0.00; undimpRenta=0.00; undimpRentaGasto=0.00; undtotDed=0.00;
				}
				pc.addCols("",0,dHeader.size());
				pc.setFont(7, 4);
				pc.addCols(" "+cdo.getColValue("unidad")+" - "+cdo.getColValue("descUnidad"),0,dHeader.size());
				
			}
			if (!depto.equalsIgnoreCase(cdo.getColValue("depto")))
			{
				pc.addCols("",0,dHeader.size());
				pc.setFont(7, 4);
				pc.addCols(" "+cdo.getColValue("depto")+" - "+cdo.getColValue("descDepto"),0,dHeader.size());
				
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		if(cdo.getColValue("type").trim().equals("A")){		
		if(fg.trim().equals("D")){
		pc.addCols("CED:  "+cdo.getColValue("cedula"),0,4);
		pc.addCols("EMPLEADO:  "+cdo.getColValue("numEmpleado")+" - "+cdo.getColValue("nomEmpleado"),0,18);
		}
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("salBruto")),2,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("vacacion")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("extra")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("ausencia")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("tardanza")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("otrosIng")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("indemnizacion")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("preaviso")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("decimo")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("prima")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("gastoRep")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("bonificacion")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("incentivo")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("primaAntiguedad")),2,1);	
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("pago_40porc")),2,1);																		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("segSocial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("segEducativo")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("impRenta")),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("impRentaGasto")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("totDed")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+cdo.getColValue("salNeto")),2,1);
			
			
		unidad=cdo.getColValue("unidad");
		depto=cdo.getColValue("depto");
		descUnidad = cdo.getColValue("descUnidad");
		descDepto= cdo.getColValue("descDepto");
		
		totalDepto += Double.parseDouble(cdo.getColValue("salNeto"));
		totalUnidad += Double.parseDouble(cdo.getColValue("salNeto"));
		
		 undsalBruto 		+=Double.parseDouble(cdo.getColValue("salBruto"));
		 undvacacion 		+=Double.parseDouble(cdo.getColValue("vacacion"));
  		 undextra 			+=Double.parseDouble(cdo.getColValue("extra"));
		 undausencia		+=Double.parseDouble(cdo.getColValue("ausencia"));
		 undtardanza		+=Double.parseDouble(cdo.getColValue("tardanza"));
		 undotrosIng		+=Double.parseDouble(cdo.getColValue("otrosIng"));
		 undindemnizacion	+=Double.parseDouble(cdo.getColValue("indemnizacion"));
		 undpreaviso	 	+=Double.parseDouble(cdo.getColValue("preaviso"));
		 unddecimo		 	+=Double.parseDouble(cdo.getColValue("decimo"));
		 undprima		  	+=Double.parseDouble(cdo.getColValue("prima"));
		 undgastoRep	 	+=Double.parseDouble(cdo.getColValue("gastoRep"));
		 undbonificacion	+=Double.parseDouble(cdo.getColValue("bonificacion"));
		 undincentivo		+=Double.parseDouble(cdo.getColValue("incentivo"));
		 undprimaAntiguedad +=Double.parseDouble(cdo.getColValue("primaAntiguedad"));
		 undpago_40porc	    +=Double.parseDouble(cdo.getColValue("pago_40porc"));
		 undsegSocial	    +=Double.parseDouble(cdo.getColValue("segSocial"));
		 undsegEducativo    +=Double.parseDouble(cdo.getColValue("segEducativo"));
		 undimpRenta	    +=Double.parseDouble(cdo.getColValue("impRenta"));
		 undimpRentaGasto   +=Double.parseDouble(cdo.getColValue("impRentaGasto"));
		 undtotDed		    +=Double.parseDouble(cdo.getColValue("totDed"));
		
		salBruto +=Double.parseDouble(cdo.getColValue("salBruto"));
		vacacion+=Double.parseDouble(cdo.getColValue("vacacion"));
		extra+=Double.parseDouble(cdo.getColValue("extra"));
		ausencia+=Double.parseDouble(cdo.getColValue("ausencia"));
		tardanza +=Double.parseDouble(cdo.getColValue("tardanza"));
		otrosIng +=Double.parseDouble(cdo.getColValue("otrosIng"));
		indemnizacion+=Double.parseDouble(cdo.getColValue("indemnizacion"));
		preaviso +=Double.parseDouble(cdo.getColValue("preaviso"));
		decimo +=Double.parseDouble(cdo.getColValue("decimo"));
		prima +=Double.parseDouble(cdo.getColValue("prima"));
		gastoRep +=Double.parseDouble(cdo.getColValue("gastoRep"));
		bonificacion +=Double.parseDouble(cdo.getColValue("bonificacion"));
		incentivo +=Double.parseDouble(cdo.getColValue("incentivo"));
		primaAntiguedad +=Double.parseDouble(cdo.getColValue("primaAntiguedad"));
		pago_40porc +=Double.parseDouble(cdo.getColValue("pago_40porc"));
		segSocial +=Double.parseDouble(cdo.getColValue("segSocial"));
		segEducativo  +=Double.parseDouble(cdo.getColValue("segEducativo"));
		impRenta +=Double.parseDouble(cdo.getColValue("impRenta"));
		impRentaGasto +=Double.parseDouble(cdo.getColValue("impRentaGasto"));
		totDed+=Double.parseDouble(cdo.getColValue("totDed"));
		
		totalsalBruto+=Double.parseDouble(cdo.getColValue("salBruto"));
		totalvacacion +=Double.parseDouble(cdo.getColValue("vacacion"));
		  totalextra +=Double.parseDouble(cdo.getColValue("extra"));
		 totalausencia +=Double.parseDouble(cdo.getColValue("ausencia"));
		 totaltardanza +=Double.parseDouble(cdo.getColValue("tardanza"));
		 totalotrosIng +=Double.parseDouble(cdo.getColValue("otrosIng"));
		 totalindemnizacion+=Double.parseDouble(cdo.getColValue("indemnizacion"));
				totalpreaviso +=Double.parseDouble(cdo.getColValue("preaviso"));
		totaldecimo +=Double.parseDouble(cdo.getColValue("decimo"));
		totalprima +=Double.parseDouble(cdo.getColValue("prima"));
		totalgastoRep +=Double.parseDouble(cdo.getColValue("gastoRep"));
		totalbonificacion +=Double.parseDouble(cdo.getColValue("bonificacion"));
		totalincentivo +=Double.parseDouble(cdo.getColValue("incentivo"));
		totalprimaAntiguedad +=Double.parseDouble(cdo.getColValue("primaAntiguedad"));
		totalpago_40porc+=Double.parseDouble(cdo.getColValue("pago_40porc"));
		 
		totalsegSocial +=Double.parseDouble(cdo.getColValue("segSocial"));
		totalsegEducativo  +=Double.parseDouble(cdo.getColValue("segEducativo"));
		 totalimpRenta +=Double.parseDouble(cdo.getColValue("impRenta"));
		 totalimpRentaGasto +=Double.parseDouble(cdo.getColValue("impRentaGasto"));
		 totaltotDed+=Double.parseDouble(cdo.getColValue("totDed"));
		 
		 totalNeto+=Double.parseDouble(cdo.getColValue("salNeto"));
		
				
		}
		
		if(cdo.getColValue("type").trim().equals("B"))
		{		
			pc.setFont(7, 0,Color.blue);
			pc.addCols("   ",0,4);
			pc.addCols("ACREEDOR:    "+cdo.getColValue("descDescuento"),0,17);
			pc.setFont(7, 0);
		}		

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
			pc.addCols(" ",0,dHeader.size());
			//pc.addCols(" TOTALES POR DEPTO ---- "+descDepto+" ============>>> "+CmnMgr.getFormattedDecimal(totalDepto),0,dHeader.size());
			pc.addCols(" TOTAL POR DEPTO ---- "+descDepto+" ============>>> ",0,dHeader.size());
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+salBruto),2,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+vacacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+extra),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+ausencia),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+tardanza),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+otrosIng),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+indemnizacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+preaviso),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+decimo),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+prima),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+gastoRep),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+bonificacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+incentivo),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+primaAntiguedad),2,1);	
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(""+pago_40porc),2,1);																		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+segSocial),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+segEducativo),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+impRenta),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+impRentaGasto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totDed),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totalDepto),2,1);
			pc.addCols(" ",0,dHeader.size());
			
			//pc.addCols(" TOTALES POR UNIDAD ---- "+descUnidad+" ============>>> "+CmnMgr.getFormattedDecimal(totalUnidad),0,dHeader.size());
			pc.addCols(" TOTALES POR UNIDAD ---- "+descUnidad+" ============>>> ",0,dHeader.size());
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsalBruto),2,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undvacacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undextra),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undausencia),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undtardanza),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undotrosIng),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undindemnizacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undpreaviso),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+unddecimo),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undprima),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undgastoRep),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undbonificacion),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undincentivo),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undprimaAntiguedad),2,1);	
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undpago_40porc),2,1);																		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsegSocial),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undsegEducativo),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undimpRenta),2,1);																			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undimpRentaGasto),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+undtotDed),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+totalUnidad),2,1);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" TOTALES FINALES ============>>> ",0,dHeader.size());
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalsalBruto),2,2,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalvacacion),2,1,1.0f, 0.0f, 0.0f, 0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalextra),2,1,1.0f, 0.0f, 0.0f, 0.0f);																			
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalausencia),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totaltardanza),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalotrosIng),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalindemnizacion),2,1,1.0f, 0.0f, 0.0f, 0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalpreaviso),2,1,1.0f, 0.0f, 0.0f, 0.0f);																			
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totaldecimo),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalprima),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalgastoRep),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalbonificacion),2,1,1.0f, 0.0f, 0.0f, 0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalincentivo),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalprimaAntiguedad),2,1,1.0f, 0.0f, 0.0f, 0.0f);	
			//pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalpago_40porc),2,1,1.0f, 0.0f, 0.0f, 0.0f);																		
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalsegSocial),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalsegEducativo),2,1,1.0f, 0.0f, 0.0f, 0.0f);	
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalimpRenta),2,1,1.0f, 0.0f, 0.0f, 0.0f);																			
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalimpRentaGasto),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totaltotDed),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+totalNeto),2,1,1.0f, 0.0f, 0.0f, 0.0f);
			
			
			
			
			
			
	
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
