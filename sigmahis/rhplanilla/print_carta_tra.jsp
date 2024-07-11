<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>  
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />  
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Oscar Hawkins        -->
<!-- Reporte: "Informe de Valores del paciente"  -->
<!-- Reporte: ADM3087                         -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 18/10/2010                        -->
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();
String sql = "",sqlt="";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String compania = (String) session.getAttribute("_companyId");

String emp_id       = request.getParameter("emp_id");

 sql = " select b.primer_nombre||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',' '||b.apellido_casada)) nombre, DECODE(b.provincia,0,' ',00,' ',11,'B',12,'C',b.provincia)||RPAD(DECODE(b.sigla,'00','  ','0','  ', b.sigla),2,' ')||'-'||TO_CHAR(b.tomo)||'-'||TO_CHAR(b.asiento) as cedula, b.emp_id as empId, b.num_empleado as numero, nvl(b.num_ssocial,'9999999') as social, (B.SALARIO_BASE + nvl(b.gasto_rep,0)) as saliobru, nvl(b.salario_base,0) as salario_base, nvl(b.gasto_rep,0) as gasto_rep, ((A.SEG_SOC_EMP/100)*B.SALARIO_BASE) as seguro_social, ((A.SEG_EDU_EMP/100)*B.SALARIO_BASE) as seguro_edu, nvl(getcalcular_isr(b.tipo_renta, b.num_dependiente, b.salario_base, b.compania),0) as impuesto_isr, c.denominacion, trim(to_char(to_date('"+fecha+"', 'dd/mm/yyyy'),'DD \" de \"   month\" de \" YYYY', 'NLS_DATE_LANGUAGE=SPANISH')) dia_largo, to_char(b.fecha_ingreso,' DD \" de \" month \" de \" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') fechain, to_char(b.fecha_egreso,'DD \"de\" month \"de\" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') fechafin, nvl(d.firma,' ') firma, nvl(d.cargo_firma,' ') cargo_firma, CASE WHEN (MONTHS_BETWEEN(TO_DATE(sysdate,'DD/MM/YYYY'),TO_DATE(B.fecha_ingreso,'DD/MM/YYYY')) >= 3) THEN '1' ELSE '0' END AS TIPO_estado, b.estado, b.tipo_emple from tbl_pla_parametros a, tbl_pla_empleado b, tbl_pla_cargo c, (SELECT  nvl(INITCAP(E.PRIMER_NOMBRE)||' '||DECODE(E.SEXO,'F',DECODE(E.APELLIDO_CASADA, NULL,INITCAP(E.PRIMER_APELLIDO),DECODE(E.USAR_APELLIDO_CASADA,'S','de '|| INITCAP(E.APELLIDO_CASADA),INITCAP(E.PRIMER_APELLIDO))),INITCAP(E.PRIMER_APELLIDO)),'') firma, nvl(f.DENOMINACION,'') cargo_firma FROM TBL_PLA_EMPLEADO e, TBL_PLA_CARGO f WHERE E.COMPANIA = "+compania+" AND E.ESTADO not in(3,13) AND f.CODIGO(+) = E.CARGO AND f.COMPANIA(+) = E.COMPANIA AND nvl(f.FIRMAR_CARTA_TRABAJO,'N') = 'S' ) d where B.COMPANIA=A.COD_COMPANIA and b.cargo=c.codigo and c.estado='A' and a.cod_compania="+compania+"and b.emp_id="+emp_id; 
cdo = SQLMgr.getData(sql);

sqlt= "select a.estado, a.emp_id, a.descuento_mensual, b.nombre_corto, a.cod_grupo grupo from tbl_pla_descuento a, tbl_pla_acreedor b where a.estado='D' and a.cod_acreedor = b.cod_acreedor  and    a.descuento_mensual > 0  and a.emp_id="+emp_id;
al = SQLMgr.getDataList(sqlt);
 
if (request.getMethod().equalsIgnoreCase("GET"))
{
	 
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
		
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");	
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
//	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";	
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = true;
	String xtraCompanyInfo = "";
	String title = "A QUIEN CONCIERNE";
	String subtitle = "";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 11;
	float cHeight = 12.0f;
	
	String consentimientoGeneral=" Actualmente   ocupa   el   cargo   de   "+(cdo.getColValue("denominacion")==""?"":cdo.getColValue("denominacion"))+"  y   presenta  el  siguiente   estado   de   ingresos   y   deducciones: \n\n\n";
 	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	//imagen
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
	//	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
		pc.addImageCols(companyImageDir+"/"+("blank.gif"),80.0f,1);
		pc.addTable();	
	
	Vector dHeader = new Vector();
	   	dHeader.addElement(".08");
		dHeader.addElement(".09");	
		dHeader.addElement(".10");		
		dHeader.addElement(".11");
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".14");	
		dHeader.addElement(".04");
		
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	// pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	for(int c=0; c<13; c++){
	pc.addCols("", 1, dHeader.size());
	}
	
	    pc.setFont(12, 0);
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,1);	
		pc.addCols("Panamá, " +cdo.getColValue("dia_largo"),0, 9,20.2f);
		pc.addCols("",0,1);	
		pc.setFont(12, 1);
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(subtitle, 1, dHeader.size(),20.2f);
		pc.addCols("", 1, dHeader.size(),10.2f);
	
		pc.setFont(11, 0);
		pc.addCols("",0,1);	
		pc.addCols("Estimados   Señores:",0,9);
		pc.addCols("",0,1);	
		
		pc.addCols("",0,1);	
		pc.addCols("  Por   este  medio  certificamos  que  el  señor(a)",0,5);
		pc.addBorderCols(cdo.getColValue("nombre"),1,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",0,1);	
		
		pc.addCols("",0,1);		
		pc.addCols("con    cédula   de   identidad    personal    No. ",0,4,cHeight);
		pc.addBorderCols(cdo.getColValue("cedula"),1,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" y  seguro  social  No. " ,0,2);
		if(!cdo.getColValue("social").equalsIgnoreCase("9999999"))	
		{
		pc.addBorderCols(cdo.getColValue("social"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",0,1);
		}
		else {
		pc.addBorderCols(cdo.getColValue("cedula"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",0,1);
		}	
		
		pc.addCols("",0,1);	
		pc.addCols("labora    en    esta    empresa   desde   el",0,4);	
		pc.addCols(cdo.getColValue("fechain"),0,4,cHeight);
		pc.addCols("",0,2);
		
		/*if(cdo.getColValue("tipo_estado").equalsIgnoreCase("1") || cdo.getColValue("tipo_emple").equalsIgnoreCase("1"))	*/
		if(cdo.getColValue("tipo_estado").equalsIgnoreCase("1") )
		{
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);	
		pc.addCols("Estado : PERMANENTE",0,9);
		pc.addCols("",0,1);	
		}
			pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);	
		pc.addCols(consentimientoGeneral,0,9);
		pc.addCols("",0,1);	
		
		pc.addCols("",0,dHeader.size());	
		pc.addCols("",0,dHeader.size());
				
		pc.addCols("",0,7);
		pc.addCols("Ingresos",2,1);
		pc.addCols("Retenciones",2,1);
		pc.addCols("Neto",2,1);
		pc.addCols("",0,1);	
		
		pc.addCols("",0,1);	
		pc.addCols("Salario Base Mensual",0,6);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),2,1);
		pc.addCols("",0,3);
		
		if(!cdo.getColValue("gasto_rep").equalsIgnoreCase("0") )
		{
		pc.addCols("",0,1);	
		pc.addCols("Gasto de Representación",0,6);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("gasto_rep")),2,1);
		pc.addCols("",0,3);
		}
		
		pc.addCols("",0,1);	
		pc.addCols("Impuesto Sobre la Renta",0,7);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("impuesto_isr")),2,1);
		pc.addCols("",0,2);
		
		pc.addCols("",0,1);	
		pc.addCols("Seguro Social",0,7);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("seguro_social")),2,1);
		pc.addCols("",0,2);
		
		pc.addCols("",0,1);	
		pc.addCols("Seguro Educativo",0,7);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("seguro_edu")),2,1);
		pc.addCols("",0,2);
		double segSocial =Double.parseDouble(cdo.getColValue("seguro_social"));
		double segEduc =Double.parseDouble(cdo.getColValue("seguro_edu"));
		double impRenta=Double.parseDouble(cdo.getColValue("impuesto_isr"));
		double impLegal=segSocial+segEduc+impRenta;	
		  	
        double descAcr =0.00; 
		int cont = 0; 
		String ahorro = "6"; 
		for(int a=0; a<al.size(); a++){
		cdop= (CommonDataObject)al.get(a);
		
		descAcr +=(Double.parseDouble(cdop.getColValue("descuento_mensual")));   
		
		pc.addCols("",0,1);	
		pc.addCols(cdop.getColValue("nombre_corto"),0,7);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdop.getColValue("descuento_mensual")),2,1);
		pc.addCols("",0,2);
		
		if (ahorro.equalsIgnoreCase(cdop.getColValue("grupo")))
			{
			cont++;
			}
		
		} 
		
		pc.addCols("",0,1);	
		pc.addCols("	     T O T A L E S",0,5);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saliobru")),2,2, 0.0f, 1.0f, 0.0f, 0.0f);				
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(descAcr+impLegal),2,1, 0.0f, 1.0f, 0.0f, 0.0f);	
		pc.addBorderCols(" "+(CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saliobru"))-impLegal-descAcr)),2,1, 0.0f, 1.0f, 0.0f, 0.0f);	
		pc.addCols("",0,1);	
			
		pc.addCols("",0,dHeader.size());
		pc.addCols("",1,dHeader.size());
		
		if (cont!=0)
		{
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		
		pc.addCols("",0,1);	
		pc.addCols("Hacemos   constar   que   el   ahorro   navideño   no   se   considera   para   los   efectos   del   20%  de   descuento   comercial.  ",0,9);
		pc.addCols("",0,1);	
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		}
		
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);
		pc.addCols("Atentamente,",0,6); 	
		pc.addCols("",0,4);
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		
		pc.addCols("",0,1);	
		pc.addBorderCols("",0,4,1f,0.0f,0.0f,0.0f,cHeight);
		pc.addCols("",0,6);
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("firma"),0,10);
		
		pc.addCols("",0,1);	
		pc.addCols(cdo.getColValue("cargo_firma"),0,10);
		
		
		
		
		
	pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>

