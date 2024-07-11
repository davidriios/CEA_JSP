<%//@ page errorPage="../error.jsp"%>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject desc = new CommonDataObject();
CommonDataObject cdo3 = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList al3 = new ArrayList();

String userName = UserDet.getUserName();
String sql = "";
String empId = request.getParameter("empId");
String print = request.getParameter("print");
String newSalBase = (request.getParameter("nsb")==null?"0":request.getParameter("nsb"));
String xtra = (request.getParameter("xt")==null?"0":request.getParameter("xt"));
String otrosIngresos = (request.getParameter("oi")==null?"0":request.getParameter("oi"));
String ausenciaTardanza = (request.getParameter("at")==null?"0":request.getParameter("at"));
String otrosEngresos = (request.getParameter("oe")==null?"0":request.getParameter("oe"));


boolean printPla_q = false;
boolean printPla_v = false;

if ( empId == null || empId.equals("")  ) throw new Exception("El id del empleado no es válido!");
if ( newSalBase.equals("0")  ) throw new Exception("El salario base no es válido!");
if ( print == null || print.equals("") ) print = "all";

if ( print.equals("all") ){
     printPla_q = true;
     printPla_v = true;
}

if ( print.equals("pla_q") ){ //planilla quincenal
	 printPla_q = true;
     printPla_v = false;
}

if ( print.equals("pla_v") ){ //'planilla vacacional
	 printPla_q = false;
     printPla_v = true;
}


//'saca datos para el encabezado
sql = "SELECT e.num_empleado,TO_CHAR(e.provincia,'09') AS primero, e.sigla AS segundo, TO_CHAR(e.tomo,'09999') AS tercero, TO_CHAR(e.asiento,'099999') AS cuarto, e.primer_nombre AS nameprimer, e.primer_apellido AS Apellido, e.unidad_organi, TO_CHAR(e.salario_base,'999,999,990.00') AS salario, TO_CHAR(e.rata_hora,'990.00') AS rata, u.descripcion AS unidad, uf.descripcion ubic_fisica, NVL(e.gasto_rep,0) gasto_rep  FROM TBL_PLA_EMPLEADO e, TBL_SEC_UNIDAD_EJEC u, TBL_SEC_UNIDAD_EJEC uf  WHERE e.unidad_organi=u.codigo(+) AND e.compania=u.compania(+) AND e.compania = "+(String) session.getAttribute("_companyId")+" AND e.emp_id = "+empId+" AND uf.codigo = e.ubic_fisica AND e.compania = uf.compania(+)";

desc = (SQLMgr.getData(sql)==null?new CommonDataObject():SQLMgr.getData(sql));

//'saca datos de los descuentos, los porcentajes 

sql = "SELECT e.emp_id,p.seg_soc_emp seguro_social, p.seg_soc_grep_emp seguro_social_grep,  p.seg_edu_emp seguro_edu, e.tipo_pla, d.cod_acreedor, d.descuento_mensual, d.descuento1, a.nombre_corto, a.tipo_cuenta, Get_Valor_Deuda_Porc(e.emp_id)AS porc_deuda, c.clave, c.pago_base, Getcalcular_Isr(c.clave,e.num_dependiente,e.salario_base,e.compania) impuesto_sr   FROM TBL_PLA_DESCUENTO d, TBL_PLA_ACREEDOR a, TBL_PLA_EMPLEADO e, TBL_PLA_PARAMETROS p, TBL_PLA_CLAVE_RENTA c WHERE e.compania = "+(String) session.getAttribute("_companyId")+" AND e.tipo_pla = 1  AND e.emp_id = "+empId+" AND e.estado <> 3 AND d.cod_compania = e.compania AND e.emp_id = d.emp_id AND a.cod_acreedor = d.cod_acreedor AND d.estado = 'D' AND p.cod_compania = e.compania and e.tipo_renta = c.clave";

al = SQLMgr.getDataList(sql);

cdoTot = SQLMgr.getData("SELECT NVL(SUM(x.descuento_mensual),0) tot_desc_mes, NVL(SUM(x.descuento1),0) tot_desc_quin FROM (("+sql+")x)");

al3 = SQLMgr.getDataList("SELECT rango_inicial_real ri, rango_final rf, porcentaje porc, cargo_fijo cf FROM TBL_PLA_RANGO_RENTA");



if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
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
	String title = "PLANILLA";
	String subtitle = "DETALLE PAGO EMPLEADO";
	String xtraSubtitle = "";
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
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	pc.setFont(8,1,Color.white);
	pc.addCols("GENERALES DEL EMPLEADO",0,dHeader.size(),Color.gray);
	
	pc.setFont(8, 1);
	pc.addCols("Cédula:",0,1);
	pc.setFont(8,0);
	pc.addCols(desc.getColValue("primero")+" - "+desc.getColValue("segundo")+" - "+desc.getColValue("tercero")+" - "+desc.getColValue("cuarto"),0,9);
	
	pc.setFont(8, 1);
	pc.addCols("Nombre:",0,1);
	pc.setFont(8,0);
	pc.addCols(desc.getColValue("namePrimer")+" "+desc.getColValue("Apellido"),0,9);
	
	pc.setFont(8, 1);
	pc.addCols("Unidad Adm.:",0,1);
	pc.setFont(8,0);
	pc.addCols(desc.getColValue("unidad"),0,4);
	
	pc.setFont(8, 1);
	pc.addCols("Salario base:",0,1);
	pc.setFont(8, 1,Color.red);
	pc.addCols(desc.getColValue("Salario"),0,4);
	
	pc.setFont(8, 1);
	pc.addCols("Ubicación:",0,1);
	pc.setFont(8,0);
	pc.addCols(desc.getColValue("ubic_fisica"),0,4);
	
	pc.setFont(8, 1);
	pc.addCols("Gasto rep.:",0,1);
    pc.setFont(8,0);
	pc.addCols(CmnMgr.getFormattedDecimal(desc.getColValue("gasto_rep")),0,4);
		
	pc.addCols(" ",0,dHeader.size());
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	
	// '**** ********************     PLANILLA QUINCENAL *************************** //
			
	if ( printPla_q ){
	
	   String groupByPerc = "";
	   CommonDataObject cdo2 = new CommonDataObject();	
	   double tipo_renta = 0.00;
	   double seg_soc = 0.00;
	   double seg_edu  = 0.00;
	   double seg_soc_gr = 0.00;
	   String formula = "";
	   String resaltar2 = "", asterisco2 = "";
	   
	   pc.setFont(8,1,Color.white);
	   pc.addCols("PLANILLA QUINCENAL",1,dHeader.size(),Color.blue);
	   pc.addCols(" ",1,dHeader.size());
	   
	   pc.setFont(8,1,Color.white);
	   pc.addCols("Datos extras (afectan al salario bruto)",0,dHeader.size(),Color.gray);
	   
	   pc.setFont(8,1);
	   pc.addBorderCols("Extra:",0,2);
	   pc.addBorderCols("Otros ingresos:",0,2);
	   pc.addBorderCols("Ausencia/tardanza:",0,2);
	   pc.addBorderCols("Otros engresos:",0,2);
	   pc.addBorderCols("Nuevo salario base",0,2);
		
	   pc.setFont(8,0);		
	   pc.addCols(CmnMgr.getFormattedDecimal(xtra),0,2);
	   pc.addCols(CmnMgr.getFormattedDecimal(otrosIngresos),0,2);
	   pc.addCols(CmnMgr.getFormattedDecimal(ausenciaTardanza),0,2);
	   pc.addCols(CmnMgr.getFormattedDecimal(otrosEngresos),0,2);
	   pc.addCols(CmnMgr.getFormattedDecimal(newSalBase),0,2);
		
	   pc.addCols(" ",0,dHeader.size());	
	   
	   pc.setFont(8,1,Color.white);
	   pc.addCols("Descuentos legales",0,dHeader.size(),Color.gray);
	   
	   double seguroSocial = 0.0;
	   double seguroEducativo = 0.0;
	   double impuestoSobreRenta = Double.parseDouble((request.getParameter("isr")==null?"0.00":request.getParameter("isr")));

	   double seguroSocialGastoRep = 0.0; 	
	   double isrGastoRep = 0.0;
	   String cae_en1 = "";
	   String cae_en2 = "";
	   
	   for ( int p = 0; p<al.size(); p++ ){
		    
			cdo2 = (CommonDataObject)al.get(p);
			
			if ( !groupByPerc.equals(cdo2.getColValue("emp_id")) ){ 
			
				  seguroSocial = (Double.parseDouble(cdo2.getColValue("seguro_social"))/100)*(Double.parseDouble(newSalBase));
				  seguroEducativo = (Double.parseDouble(cdo2.getColValue("seguro_edu"))/100)*(Double.parseDouble(newSalBase));	
			  
			      pc.setFont(8,1);
				  pc.addBorderCols("Seguro Social",0,2);
				  pc.addBorderCols(" ",0,2);
				  pc.addBorderCols("Mensual",0,2);
				  pc.addBorderCols("Quincenal",0,2);
				  pc.addBorderCols(" ",0,2);
				  
				  pc.setFont(8,0);
				  pc.addCols(cdo2.getColValue("seguro_social")+"%",0,2);
				  pc.addCols(" ",0,2);
			      pc.addCols(CmnMgr.getFormattedDecimal(seguroSocial),0,2);
				  pc.addCols(CmnMgr.getFormattedDecimal(seguroSocial/2),0,2);
				  pc.addCols(" ",0,2);
				  
				  pc.addBorderCols("          Mensual = (9/100) * salario base\n          Quincenal = ((9/100) * salario base) / 2",6,dHeader.size());
				  
				  pc.addCols(" ",0,dHeader.size());
				  
				  Color c2 = Color.white;
				  Color c3= Color.white;
					  
				  if ( Double.parseDouble(desc.getColValue("gasto_rep")) > 0 ){
					  
					  
					  if ( (Double.parseDouble(desc.getColValue("gasto_rep"))*13) > 0 && (Double.parseDouble(desc.getColValue("gasto_rep"))*13) <= 25000 ){
					      seguroSocialGastoRep = (Double.parseDouble(desc.getColValue("gasto_rep"))*Double.parseDouble(cdo2.getColValue("seguro_social_grep")))/100;
						  isrGastoRep = (Double.parseDouble(desc.getColValue("gasto_rep"))*10)/100;
						  
						  formula = "Mensual   = (gasto rep. * 9)/100  \n          Quincenal   = [(gasto rep. * 9)/100]/2";
						  cae_en1 = "****************** SU GASTO REPRESENTACIÓN ESTÁ EN ESE RANGO ********************";
						  cae_en2 = "";
						  c2 = Color.yellow;
						  c3 = Color.white;
					  }else
					  if ( (Double.parseDouble(desc.getColValue("gasto_rep"))*13) > 25000 && (Double.parseDouble(desc.getColValue("gasto_rep"))*13) <= 99999999 ){
					      seguroSocialGastoRep = (Double.parseDouble(desc.getColValue("gasto_rep"))*Double.parseDouble(cdo2.getColValue("seguro_social_grep")))/100;
						  isrGastoRep = (Double.parseDouble(desc.getColValue("gasto_rep"))*15)/100;
						  
						  formula = "Mensual   = (gasto rep. * (15/100)) * (9/100) \n          Quincenal   = [(gasto rep. * (15/100)) * (9/100)]/2";
						cae_en2 = "****************** SU GASTO REPRESENTACIÓN ESTÁ EN ESE RANGO ********************";
						cae_en1 = "";
						c2 = Color.white;
						c3 = Color.yellow;
					  }
					  
					 pc.setFont(8,1);
				 	 pc.addBorderCols("Seguro Social en base del gasto rep.",0,4);
				 	 pc.addBorderCols("Mensual",0,2);
				 	 pc.addBorderCols("Quincenal",0,2);
				  	 pc.addBorderCols(" ",0,2);
					  
					 pc.setFont(8,0);
				     pc.addCols(cdo2.getColValue("seguro_social")+"%",0,2);
				     pc.addCols(" ",0,2);
			      	 pc.addCols(CmnMgr.getFormattedDecimal(seguroSocialGastoRep),0,2);
				     pc.addCols(CmnMgr.getFormattedDecimal(seguroSocialGastoRep/2),0,2);
				     pc.addCols(" ",0,2);
					 pc.addBorderCols("          "+formula,6,dHeader.size());
					 pc.addCols(" ",0,dHeader.size());
					  
				  }
				  
				  pc.setFont(8,1);
				  pc.addBorderCols("Seguro Educativo",0,2);
				  pc.addBorderCols(" ",0,2);
				  pc.addBorderCols("Mensual",0,2);
				  pc.addBorderCols("Quincenal",0,2);
				  pc.addBorderCols(" ",0,2);
				  
				  pc.setFont(8,0);
				  pc.addCols(cdo2.getColValue("seguro_edu")+"%",0,2);
				  pc.addCols(" ",0,2);
			      pc.addCols(CmnMgr.getFormattedDecimal(seguroEducativo),0,2);
				  pc.addCols(CmnMgr.getFormattedDecimal(seguroEducativo/2),0,2);
				  pc.addCols(" ",0,2);
				  
				  pc.addBorderCols("          Mensual = (1.25/100) * salario base\n          Quincenal = ((1.25/100) * salario base) / 2",6,dHeader.size());
				  
				  pc.addCols(" ",0,dHeader.size());
				  
				  pc.setFont(8,1,Color.black);
				  pc.addCols("Impuesto sobre la renta",0,2,Color.lightGray);
				  pc.addCols(" ",0,2,Color.lightGray);
				  pc.addCols("Mensual",0,2,Color.lightGray);
				  pc.addCols("Quincenal",0,2,Color.lightGray);
				  pc.addCols(" ",0,2,Color.lightGray);
				  
				  pc.setFont(8,0);
				  pc.addCols(" ",0,4);
			      pc.addCols(CmnMgr.getFormattedDecimal(impuestoSobreRenta),0,2);
				  pc.addCols(CmnMgr.getFormattedDecimal(impuestoSobreRenta/2),0,2);
				  pc.addCols(" ",0,2);
				  pc.addBorderCols("           Mensual = (((Monto anual - Rango inicial) * (porcentaje/100)) + Cargo fijo) / 13\n           Quincenal = Mensual / 2",6,dHeader.size());
				  pc.addCols(" ",6,dHeader.size());
				  
				  tipo_renta = Double.parseDouble(newSalBase)*13-(Double.parseDouble(cdo2.getColValue("pago_base")));
				  
				  pc.setFont(8,1);
				  pc.addCols("Tipo renta:   "+cdo2.getColValue("clave")+ " 0 (Valor dependiente)      -      Pago base:   "+cdo2.getColValue("pago_base"),0,5);
				  pc.addCols("Monto anual:   "+CmnMgr.getFormattedDecimal(tipo_renta),0,5);
				  pc.setFont(8,0);
				  pc.addBorderCols("          Monto anual = (salario base * 13 ) - pago base",6,dHeader.size(),0.1f,0.1f,0.1f,0.1f);

				  pc.addCols("*** RANGO RENTA ***",1,dHeader.size());
				  
				  pc.addBorderCols("Rango Inicial",0,1);
				  pc.addBorderCols("Rango Final",0,1);
				  pc.addBorderCols("Porcentaje",0,1);
				  pc.addBorderCols("Cargo Fijo",0,1);
				  pc.addBorderCols(" ",0,6,0.1f,0.1f,0.1f,0.1f);
				  
				  String this_rango = "";
				  Color c = Color.white;
				  
				  for ( int r = 0; r<al3.size(); r++ ){
				       cdo3 = (CommonDataObject)al3.get(r);
				       if ( tipo_renta>Double.parseDouble(cdo3.getColValue("ri")) && tipo_renta < Double.parseDouble(cdo3.getColValue("rf"))){
					   
					          this_rango =  "<<== ************************* MONTO ANUAL ESTA EN ESE RANGO *************************";
							  c = Color.yellow;
					   }else{c=Color.white; this_rango = "";}
					   
					   pc.addBorderCols(cdo3.getColValue("ri"),0,1,c);
				 	   pc.addBorderCols(cdo3.getColValue("rf"),0,1,c);
				  	   pc.addBorderCols(cdo3.getColValue("porc"),0,1,c);
				       pc.addBorderCols(cdo3.getColValue("cf"),0,1,c);
					   pc.setFont(8,1);
				       pc.addBorderCols(this_rango,1,6,c);
				  }//'for r
				  
				  if ( Double.parseDouble(desc.getColValue("gasto_rep")) > 0 ){
				        pc.addCols(" ",0,dHeader.size()); 
						pc.setFont(8,1,Color.black);
						pc.addCols("Impuesto sobre la renta (Gasto rep.)",0,2,Color.lightGray);
						pc.addCols(" ",0,2,Color.lightGray);
						pc.addCols("Mensual",0,2,Color.lightGray);
						pc.addCols("Quincenal",0,2,Color.lightGray);
						pc.addCols(" ",0,2,Color.lightGray);
						
						pc.setFont(8,0);
						pc.addCols(" ",0,4);
						pc.addCols(CmnMgr.getFormattedDecimal(isrGastoRep),0,2);
						pc.addCols(CmnMgr.getFormattedDecimal(isrGastoRep/2),0,2);
						pc.addCols(" ",0,2);
						pc.addBorderCols("           Mensual = (Gasto rep. * 10) / 100\n           Quincenal = Mensual / 2",6,dHeader.size());
						pc.addCols(" ",6,dHeader.size());
						  
						tipo_renta = Double.parseDouble(newSalBase)*13-(Double.parseDouble(cdo2.getColValue("pago_base")));
				  
				        pc.addCols("*** TARIFA DE ISR DEL GASTO DE REPRESENTACIÓN ***",1,dHeader.size()); 
						
				     	pc.addBorderCols("Rango Inicial",0,1,0.1f,0.1f,0.1f,0.1f);
				  		pc.addBorderCols("Rango Final",0,1,0.1f,0.1f,0.1f,0.1f);
				  		pc.addBorderCols("Porcentaje",0,1,0.1f,0.1f,0.1f,0.1f);
				  		pc.addBorderCols("Cargo Fijo",0,1,0.1f,0.1f,0.1f,0.1f);
				  		pc.addBorderCols(" ",0,6,0.1f,0.1f,0.1f,0.1f);
				
						pc.addBorderCols("0.00",0,1,c2);
				  		pc.addBorderCols("25,000.00",0,1,c2);
				  		pc.addBorderCols("10%",0,1,c2);
				  		pc.addBorderCols("0.00",0,1,c2);
				  		pc.addBorderCols(cae_en1,0,6,c2);
						pc.addBorderCols("25,000.00",0,1,c3);
				  		pc.addBorderCols("y más",0,1,c3);
				  		pc.addBorderCols("15%",0,1,c3);
				  		pc.addBorderCols("2,500.00",0,1,c3);
				  		pc.addBorderCols(cae_en2,0,6,c3);
				  }
				  
				 pc.addCols(" ",0,dHeader.size()); 
				 pc.setFont(8,1,Color.white);
				 pc.addCols("Descuentos voluntarios",0,dHeader.size(),Color.gray);
				 pc.setFont(8,1);
				 pc.addCols("    Porcentaje de endeudamiento: [ "+cdo2.getColValue("porc_deuda")+" ]",0,dHeader.size());
				  pc.addCols("  ",0,dHeader.size());
				 pc.addBorderCols("Acreedor",0,4);
				 pc.addBorderCols("Mensual",0,1);
				 pc.addBorderCols("Quincenal",0,1);
				 pc.addBorderCols(" ",0,4);
	     }//'groupByPerc
				
				pc.addCols(cdo2.getColValue("nombre_corto")+" [ "+cdo2.getColValue("cod_acreedor")+" ]",0,4);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo2.getColValue("descuento_mensual")),0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo2.getColValue("descuento1")),0,1);
				pc.addCols(" ",0,4);
			
	   groupByPerc = cdo2.getColValue("emp_id");	
     }//'for
	
	 pc.addCols(" ",0,dHeader.size()); 
	 pc.setFont(8,1);
	 double tot_neto = Double.parseDouble(newSalBase) - seguroSocial - seguroEducativo - impuestoSobreRenta - Double.parseDouble(cdoTot.getColValue("tot_desc_mes"));
	 pc.addCols("Salario aprox. en base del salario bruto ("+CmnMgr.getFormattedDecimal(newSalBase)+"):   ",0,4,Color.lightGray);
	 pc.addCols("Mensual",0,1,Color.lightGray);
	 pc.addCols("Quincenal",0,1,Color.lightGray);
	 pc.addCols(" ",0,4,Color.lightGray);
	 
	 pc.setFont(8,0);
	 pc.addCols(" ",0,4);
	 pc.addCols(CmnMgr.getFormattedDecimal(tot_neto),0,1);
	 pc.addCols(CmnMgr.getFormattedDecimal((tot_neto/2)),0,1);
	 pc.addCols(" ",0,4);
	 pc.addBorderCols("           Mensual  =  salario base - seguro social - seguro social gasto rep - seguro educativo - impuesto sobre la renta - descuentos voluntarios\n           Quincenal  = (salario base - seguro social - seguro social gasto rep - seguro educativo - impuesto sobre la renta - descuentos voluntarios) / 2",6,dHeader.size());

	
	
} // 'printPla_q

	// '**** ********************  END PLANILLA QUINCENAL *************************** //	
	
	// '**** ********************  PLANILLA VACACIONAL *************************** //	
	
if (printPla_v){

       pc.setFont(8,1,Color.white);
	   pc.addCols(" ",1,dHeader.size());
	   pc.addCols("PLANILLA VACACIONAL",1,dHeader.size(),Color.blue);
	   pc.addCols(" ",1,dHeader.size());
	   
} //'printPla_v	
	
	// '**** ******************** END PLANILLA VACACIONAL *************************** //	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>