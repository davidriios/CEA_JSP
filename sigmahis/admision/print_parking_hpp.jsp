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
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<!-- Desarrollado por: Oscar Hawkins.        -->
<!-- Reporte: "pdf.  -->
<!-- Reporte: ADM3087                         -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 30/10/2010                        -->

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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (sala == null) sala = "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and aa.compania = "+compania;
  }
/*if (!categoria.equals(""))
   {
   appendFilter1 += " and aa.categoria = "+categoria;
   }
  */
if (!centroServicio.equals(""))
   {
        appendFilter1 += " and  cds.codigo = "+centroServicio;
   }
/*if (!codAseguradora.equals(""))
   {
    appendFilter1 += " and ab.empresa = "+codAseguradora;
	}
*/
if (!fechaini.equals(""))
   {
   appendFilter1 += " and to_date(to_char(pac.fecha_fallecido, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
  appendFilter1 += " and to_date(to_char(pac.fecha_fallecido, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Pacientes Fallecidos----------------------------------------//

//cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 8f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "DEMESA";
	String title = "DESARROLLO MÉDICO EMPRESARIAL, S.A";
	String subtitle = "PERMISO DE ESTACIONAMIENTO DE:";
	String xtraSubtitle = " CORTESIA";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 10;
	float cHeight = 12.0f;
	
	String consentimientoGeneral="I, __________________________with identification number or passport Nº_______________________"+
                              "have come to Hospital Punta Pacifica on my own’s volition to do medical test, treatments,"+
                              "procedures and/or surgeries prescribed by the doctor. I also accept to follow all the"+
                              "Institution patient’s rules and regulations.\n\n";	


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	//imagen
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
		pc.addTable();	

	Vector dHeader = new Vector();

		dHeader.addElement("1");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		//dHeader.addElement(".11");
		//dHeader.addElement(".08");
		//dHeader.addElement(".08");
		dHeader.addElement(".50");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	    pc.setFont(10, 1);
		pc.addCols(xtraCompanyInfo, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(subtitle, 1, dHeader.size(),20.2f);
		pc.addCols("", 1, dHeader.size(),4.2f);
		pc.addCols(xtraSubtitle, 1, dHeader.size(),20.2f);
		pc.setFont(8, 0);

							
		//pc.addCols(consentimientoGeneral,1,1);							  
		pc.addCols("                                             Desde: _________________________\n\n\n",0,7,cHeight);
		pc.addCols("",0,7);
		pc.addCols("                                             Hasta: _________________________\n\n\n",0,7,cHeight);
		pc.addCols("",0,7);
		pc.addCols("                                              Firma:__________________________\n\n\n",0,7,cHeight);
		//pc.addBorderCols("F. FALLECE",1,1,cHeight * 2,Color.lightGray);
		//pc.addBorderCols("MEDICOS",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	for (int i=0; i<al.size(); i++)
	{
       cdo = (CommonDataObject) al.get(i);

	   // Inicio --- Agrupamiento x Sala
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala")))
		   { // groupBy
			   if (i != 0)
			     {// i
				   pc.setFont(8, 1,Color.red);
				   //pc.addCols("  TOTAL DE PACIENTES X SALA: "+ pxc,0,dHeader.size(),cHeight);
				   //pc.addCols(" ",0,dHeader.size(),cHeight);
				   //pc.setFont(6, 0,Color.black);
	               //pc.addCols("(AD) - MEDICO QUE ADMITE",0,dHeader.size(),cHeight);
	               //pc.addCols("(HM) - HONORARIO MEDICO ",0,dHeader.size(),cHeight);
	               //pc.addCols("(CJ) - MEDICO CIRUJANO",0,dHeader.size(),cHeight);
				   //pc.addCols(" ",0,dHeader.size(),cHeight);
				   pxc = 0;
	              }// i
				 pc.setFont(8, 1,Color.blue);
				 pc.addCols("SALA:",0,1,cHeight);
		         pc.addCols("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"),0,dHeader.size(),cHeight);
		    }// groupBy
	// Fin --- Agrupamiento x Sala

		   pc.setFont(7, 0);
		   if (!pacId.trim().equals(cdo.getColValue("pacId")))
		   {
		   //pc.addBorderCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("fechaNacimiento"),1,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("codPaciente"),1,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("cedula"),0,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("fechaFallecimiento"),1,1,cHeight);
		   //pc.addBorderCols(" "+cdo.getColValue("medicosHonorarios"),0,1);
		   pxc++;
		   pcant++;
		   }else{
		    //pc.addCols(" ",0,1,cHeight);
		    //pc.addBorderCols(" ",1,1,cHeight);
		    //pc.addBorderCols(" ",0,1,cHeight);
		    //pc.addBorderCols(" ",0,1,cHeight);
		    //pc.addBorderCols(" ",1,1,cHeight);
		    //pc.addBorderCols(" ",1,1,cHeight);
		    //pc.addBorderCols(" "+cdo.getColValue("Firma: _________________________  Fecha: ______________________"),0,1);
		   }
		   pacId=cdo.getColValue("pacId");

	groupBy = "[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala");

	}//for i

	if (al.size() == 0)
	{
		//pc.addCols("No Records",1,dHeader.size());
	}
	else
	{  //Totales Finales
			//pc.setFont(8, 1,Color.red);
			//pc.addCols("  250149 "+ pxc,0,dHeader.size(),cHeight);
			//pc.setFont(6, 0,Color.black);
			//pc.addCols("(AD) - MEDICO QUE ADMITE",0,dHeader.size(),cHeight);
	        //pc.addCols("(HM) - HONORARIO MEDICO ",0,dHeader.size(),cHeight);
	        //pc.addCols("(CJ) - MEDICO CIRUJANO",0,dHeader.size(),cHeight);
			//pc.addCols(" ",0,dHeader.size(),cHeight);
			//pc.setFont(8, 1,Color.black);
			//pc.addCols("  CANT. TOTAL DE PACIENTES:   "+ pcant,0,dHeader.size(),Color.lightGray);
			//pc.addCols(" ",0,dHeader.size(),cHeight);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>



