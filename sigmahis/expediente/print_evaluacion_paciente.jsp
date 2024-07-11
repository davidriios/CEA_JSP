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
REPORTE:  EVALUACIONES DE ENDOSCOPIA
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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();


CommonDataObject cdo, cdoPacData, cdoTitle = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String docTitle = "";
String imgDoc ="";
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String totImg = request.getParameter("tot_img");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "PO";
if (totImg == null) totImg = "0";

if (request.getParameter("code") != null && !request.getParameter("code").equals("") && !request.getParameter("code").equals("0")) appendFilter += " and a.codigo = "+request.getParameter("code");

sql=" select a.codigo, a.tipo_evaluacion, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_evaluacion codDiagPre, a.hallazgo, a.observacion, a.recomendacion, a.medico codMedico, a.tecnica, a.premedicacion, a.anestesia, a.indicacion, a.rx_tac_torax ,decode(a.documento,null,'','/'||a.documento ) as documento, decode(a.documento2,null,'','/'||a.documento2 ) as documento2, decode(a.documento3,null,'','/'||a.documento3 ) as documento3, decode(a.documento4,null,'','/'||a.documento4 ) as documento4,  b.descripcion descAnestesia, coalesce(c.observacion,c.nombre) descDiagPre, d.primer_nombre||decode(d.segundo_nombre,null,'',' '||d.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada)) as nombre_medico,nvl(a.sub_tipo,'')sub_tipo, (select nombre  from  tbl_sal_tecnica_evaluacion where status ='A' and id = a.tecnica)descTecnica,nvl(to_char(a.fecha_creacion,'dd/mm/yyyy'),' ')fechaCreacion,nvl(to_char(a.fecha_creacion,'hh12:mi:ss am'),' ')hora, gastroscopia,duodenoscopia,colangio,colonoscopia,recto from tbl_sal_evaluacion a ,tbl_sal_tipo_anestesia b ,tbl_cds_diagnostico c , tbl_adm_medico d  where a.anestesia = b.codigo(+) and a.diag_pre_evaluacion = c.codigo(+) and a.medico = d.codigo(+) and a.tipo_evaluacion = '"+fg+"'  and  a.pac_id="+pacId+" and a.admision="+noAdmision+appendFilter+"  ";
//cdo = SQLMgr.getData(sql);
al = SQLMgr.getDataList(sql);

String imgDocDefault ="";
if (fg.trim().equals("BR"))
{
	docTitle = "EVALUACION - BRONCOSCOPIA";
	imgDocDefault = ResourceBundle.getBundle("path").getString("images")+"/blank.gif";
}
else if (fg.trim().equals("CR"))
{
	docTitle = "EVALUACION - COLONOSCOPIA Y RECTOSCOPIA";
	imgDocDefault = ResourceBundle.getBundle("path").getString("images")+"/colonoscopia.jpg";
}
else if (fg.trim().equals("CI"))
{
	docTitle = "EVALUACION - CISTOSCOPIA";
	imgDocDefault = ResourceBundle.getBundle("path").getString("images")+"/blank.gif";
}
else if (fg.trim().equals("EG"))
{
	docTitle = "EVALUACION - ENDOSCOPIA GASTRODUODENAL";
	imgDocDefault = ResourceBundle.getBundle("path").getString("images")+"/endoscopia.jpg";
}

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	if ( desc == null ) desc = "";

	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "EXPEDIENTE";
	String subtitle = cdoTitle.getColValue("descripcion");
	String xtraSubtitle = ""+docTitle;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	int iconImgSize = 9;
	int imgSize = 10;
	String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
	String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	String iconImg = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
    pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector dHeader = new Vector();
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");

	Vector dHeader1 = new Vector();
	dHeader1.addElement("1");
			
	Vector infoCol = new Vector();
		infoCol.addElement(".17");
		infoCol.addElement(".17");
		infoCol.addElement(".15");
		infoCol.addElement(".15");
		infoCol.addElement(".16");
		infoCol.addElement(".20");

	Vector infoCol2 = new Vector();
		infoCol2.addElement(".18");
		infoCol2.addElement(".05");
		infoCol2.addElement(".18");
		infoCol2.addElement(".05");
		infoCol2.addElement(".47");
		infoCol2.addElement(".05");

	pc.setNoColumn(1);

	//radioChecked table
	pc.createTable("radioChecked",false,0,588);
	pc.addImageCols(iconChecked,imgSize,1);

	//radioUnchecked table
	pc.createTable("radioUnchecked",false,0,588);
	pc.addImageCols(iconUnchecked,imgSize,1);
	
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();			 
		pc.addInnerTableToCols(dHeader.size());
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body

		pc.setFont(fontSize, 1);
		String groupBy  = "";
		for (int a=0; a<al.size(); a++)
		{

			CommonDataObject cdoz = (CommonDataObject) al.get(a);

 			if (!groupBy.trim().equalsIgnoreCase(cdoz.getColValue("codigo")))
		    { // groupBy
		        if (a != 0)
				{
				  pc.flushTableBody(true);
				  pc.addNewPage();
				}
			}
			sql="select a.evaluacion, a.diagnostico, a.observacion,coalesce(b.observacion,b.nombre) descDiagnostico from tbl_sal_evaluacion_diag_post a , tbl_cds_diagnostico b where a.evaluacion = "+cdoz.getColValue("codigo")+" and a.diagnostico = b.codigo ";

al1 = SQLMgr.getDataList(sql);

sql ="  select a.id,/*nvl(b.muestra,0)**/ b.muestra,a.nombre descMuestra, b.evaluacion, b.citologia, b.patologia, b.bacterias, b.baar,b.hongos from tbl_sal_tipo_muestra_eval a, tbl_sal_evaluacion_muestra b  where a.status = 'A' and b.muestra(+) = a.id and b.evaluacion(+)= "+cdoz.getColValue("codigo");
al2 = SQLMgr.getDataList(sql);

			

			//DIAGNOSTICOS PREOPERATORIOS
			String checked="";

			if (fg.trim().equals("EG")||fg.trim().equals("CR"))
			{
					pc.setFont(8, 1);
					pc.addCols("Fecha:  "+cdoz.getColValue("fechaCreacion"),0,1);
		            pc.addCols("Hora: "+cdoz.getColValue("hora"),0,3);
		            pc.addCols("",0,4);
					
					pc.setVAlignment(0);
					pc.setNoInnerColumnFixWidth(infoCol2);
					pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
					pc.createInnerTable();
					/**/
			if (fg.trim().equals("EG"))
			{
				/*
                pc.addInnerTableCols("GASTROSCOPIA",0,1);
				if(cdoz.getColValue("sub_tipo").trim().equals("GC"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("DUODENOSCOPIA",0,1);
				if(cdoz.getColValue("sub_tipo").trim().equals("DC"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("CPRE(COLANGIO-PANCREATOGRAFÍA ENDOSCOPICA)",0,1);
				
				if(cdoz.getColValue("sub_tipo").trim().equals("CP"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
                */
                
                //
                
                pc.addInnerTableCols("GASTROSCOPIA",0,1);
				if(cdoz.getColValue("gastroscopia").trim().equals("GC"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("DUODENOSCOPIA",0,1);
				if(cdoz.getColValue("duodenoscopia").trim().equals("DC"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("CPRE(COLANGIO-PANCREATOGRAFÍA ENDOSCOPICA)",0,1);
				
				if(cdoz.getColValue("colangio").trim().equals("CP"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				
			}
			 if (fg.trim().equals("CR"))
			 {
			 	/*
                pc.addInnerTableCols("COLONOSCOPIA",0,1);
				if(cdoz.getColValue("sub_tipo").trim().equals("CC"))
				pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("RECTOSIGMOIDOSCOPIA",0,1);
				if(cdoz.getColValue("sub_tipo").trim().equals("CR"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
					pc.addInnerTableCols(" ",0,2);
                    */
                    
                //
                pc.addInnerTableCols("COLONOSCOPIA",0,1);
				if(cdoz.getColValue("colonoscopia").trim().equals("CC"))
				pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
				
				pc.addInnerTableCols("RECTOSIGMOIDOSCOPIA",0,1);
				if(cdoz.getColValue("recto").trim().equals("CR"))
					pc.addInnerTableImageCols(iconChecked,8,1);
				else pc.addInnerTableImageCols(iconUnchecked,8,1);
					pc.addInnerTableCols(" ",0,2);    
			 }
			 
					pc.addInnerTableBorderCols(" ",0,infoCol2.size(),0.0f,0.5f,0.0f,0.0f);
					pc.resetVAlignment();
					pc.addInnerTableToCols(dHeader.size());
			 		//pc.addCols(" ",0,dHeader.size());
			 }
			 
			 
			
				pc.setFont(fontSize, 1);
				if(!fg.trim().equals("BR"))
				{
					pc.addBorderCols("DIAGNOSTICO PRE-ENDOSCÓPICO:  "+cdoz.getColValue("descDiagPre"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("TÉCNICA USADA:"+cdoz.getColValue("tecnica"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("HALLAZGO:"+cdoz.getColValue("hallazgo"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("OBSERVACIÓN:"+cdoz.getColValue("observacion"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addCols(" ",0,dHeader.size());
				}
				if(fg.trim().equals("BR"))
				{
					pc.addBorderCols("PREMEDICACIÒN: "+cdoz.getColValue("premedicacion"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("ANESTESIA: "+cdoz.getColValue("descAnestesia"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("INDICACIÓN: "+cdoz.getColValue("indicacion"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("RX O TAC DE TORAX: "+cdoz.getColValue("rx_tac_torax"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

				}
				if(fg.trim().equals("CR") ||fg.trim().equals("EG") )
				{
					pc.addBorderCols("TÈCNICA: "+cdoz.getColValue("descTecnica"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
				if(fg.trim().equals("CI"))
				{
					pc.addBorderCols("RECOMENDACIONES: "+cdoz.getColValue("recomendacion"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols(" ",1,dHeader.size());
				if((fg.equalsIgnoreCase("EG") || fg.equalsIgnoreCase("CR") || fg.equalsIgnoreCase("BR")))
				{
					pc.addBorderCols("DIAGNOSTICO POST-ENDOSCÓPICO",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.setFont(fontSize, 1);
					pc.addBorderCols("DIAGNOSTICO",1,2);
					pc.addBorderCols("OBSERVACIÓN",1,3);
	
					pc.setVAlignment(0);
					
					for (int i=0; i<al1.size(); i++)
					{
						CommonDataObject cdox = (CommonDataObject) al1.get(i);
	
						pc.setFont(fontSize, 0);
						pc.addBorderCols(cdox.getColValue("diagnostico")+" - "+cdox.getColValue("descDiagnostico"),1,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdox.getColValue("observacion"),0,3,0.5f,0.0f,0.0f,0.0f);
					}
					pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.addCols(" ",1,dHeader.size());
				}
				
			    for (int i = 1; i<=Integer.parseInt(totImg); i++){
                  
                  String index = i == 1 ? "" : ""+i;
                  
                  imgDoc = cdoz.getColValue("documento"+index) != null?ResourceBundle.getBundle("path").getString("expedientedocs")+cdoz.getColValue("documento"+index):"";
			  
                  boolean hasImage = imgDoc.toLowerCase().endsWith(".gif") || imgDoc.toLowerCase().endsWith(".jpg") || imgDoc.toLowerCase().endsWith(".jpeg")|| imgDoc.toLowerCase().endsWith(".png") || imgDoc.toLowerCase().endsWith(".bmp") || imgDoc.toLowerCase().endsWith(".tiff");
                  
                  System.out.println(".................................. imgDoc = "+imgDoc);
                  
                  if (!imgDoc.equals("")){
                    pc.setVAlignment(0);
                    pc.setNoColumnFixWidth(dHeader1);
                    pc.createTable("imgIcon"+i,true,0,0.0f,584f);
                        pc.setFont(9,1);
                        pc.addImageCols(imgDoc,0,1);
                    pc.useTable("main");
                    pc.addTableToCols("imgIcon"+i,1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
                  }
                  
                  pc.addCols(" ", 0, dHeader.size());
				}
				
				if(fg.equalsIgnoreCase("BR"))
				{
					pc.addBorderCols("MUESTRAS",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					pc.setFont(fontSize, 1);
					
					
					pc.setVAlignment(0);
					pc.setNoInnerColumnFixWidth(infoCol);
					pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
					pc.createInnerTable();
					
					pc.addInnerTableCols("MUESTRA",0,1);
					pc.addInnerTableCols("CITOLOGIA",1,1);
					pc.addInnerTableCols("PATOLOGIA",1,1);
					pc.addInnerTableCols("BACTERIAS",1,1);
					pc.addInnerTableCols("BAAR",1,1);
					pc.addInnerTableCols("HONGOS",1,1);
					
	
					pc.setVAlignment(0);
					
					for (int i=0; i<al2.size(); i++)
					{
						CommonDataObject cdox = (CommonDataObject) al2.get(i);
						
						pc.setFont(fontSize, 0);
						pc.addInnerTableBorderCols(cdox.getColValue("descMuestra"),0,1);
						pc.addInnerTableBorderCols(cdox.getColValue("citologia"),0,1);
						pc.addInnerTableBorderCols(cdox.getColValue("patologia"),0,1);
						pc.addInnerTableBorderCols(cdox.getColValue("bacterias"),0,1);
						pc.addInnerTableBorderCols(cdox.getColValue("baar"),0,1);
						pc.addInnerTableBorderCols(cdox.getColValue("hongos"),0,1);
						
					
					}
					//pc.addCols(" ",1,dHeader.size());
					
					
					pc.addInnerTableCols(" ",0,infoCol.size());
					pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.10f,0.0f,0.0f,0.0f);
					pc.resetVAlignment();
					pc.addInnerTableToCols(dHeader.size());
					pc.addCols(" ",1,dHeader.size());
					
				}
					
			pc.setVAlignment(0);
			
			pc.setFont(fontSize, 0);
		  	pc.addBorderCols("NOMBRE DEL ENDOSCOPISTA: ",0,1,0.5f,0.0f,0.0f,0.0f);
		  	pc.addBorderCols(" "+cdoz.getColValue("nombre_medico"),0,4,0.5f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,dHeader.size());
		
			pc.addBorderCols("FIRMA: ",0,3,0.10f,0.0f,0.0f,0.0f);
			pc.addBorderCols("REGISTRO: "+cdoz.getColValue("codMedico"),0,2,0.10f,0.0f,0.0f,0.0f);
			
		
	if(al.size()<a)
	pc.addNewPage();

	}
	
	
		pc.addCols("",0,dHeader.size());

	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.useTable("main");
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//GET
%>