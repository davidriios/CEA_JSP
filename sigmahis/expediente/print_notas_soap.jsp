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
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

StringBuffer sql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String id = request.getParameter("id");

CommonDataObject cdop  = SQLMgr.getPacData(pacId, noAdmision);
if ( desc == null ) desc = "";
if ( id == null ) id = "";

	 String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
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
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612 
	float height = 72 * 14f;//792
	boolean isLandscape = true;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	String si,no ;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("25"); 
		dHeader.addElement("25"); 
		dHeader.addElement("25"); 
		dHeader.addElement("25"); 

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setVAlignment(0);
		
		
		
		sql = new StringBuffer();
		
		sql.append(" select d.id, d.nota_s , d.nota_o, d.nota_a, d.nota_p ,'['||d.medico||'] '||primer_nombre|| DECODE (segundo_nombre, NULL, '', ' ' || segundo_nombre)|| DECODE (primer_apellido, NULL, '', ' ' || primer_apellido)|| DECODE (segundo_apellido, NULL, '', ' ' || segundo_apellido)|| DECODE (sexo, 'F', DECODE (apellido_de_casada, NULL, '',' DE ' || apellido_de_casada)) AS nombre_medico, d.medico, d.usuario_creacion, d.usuario_modificacion, to_char(d.FECHA_CREACION, 'dd/mm/yyyy hh12:mi am') fc , to_char(d.FECHA_MODIFICACION, 'dd/mm/yyyy hh12:mi am') fm from TBL_SAL_NOTAS_SOAP d, tbl_adm_medico m where d.pac_id = ");
		sql.append(pacId);
		sql.append(" and d.admision = ");
		sql.append(noAdmision);
		
		if (!id.trim().equals("")) {
       sql.append(" and d.id = ");
       sql.append(id);
		}
		sql.append(" and d.medico = m.codigo order by d.id ");
		
		al = SQLMgr.getDataList(sql.toString());
		
    
		// pc.setTableHeader(2);
		
		for (int i = 0; i < al.size(); i++) {
		 CommonDataObject cdo = (CommonDataObject) al.get(i);  
		 
		 pc.setFont(8, 1);
		pc.addBorderCols("S (Motivo de la visita)",1);
		pc.addBorderCols("O (Evaluación médica)",1);
		pc.addBorderCols("A (Resultados clínicos)",1);
		pc.addBorderCols("P (Plan de acción)",1);
      
      pc.setFont(7, 1);
      pc.addBorderCols("Creado por: "+cdo.getColValue("usuario_creacion"," ")+"          el: "+cdo.getColValue("fc"," "), 0, 2, Color.lightGray);
      pc.addBorderCols("Modificado por: "+cdo.getColValue("usuario_modificacion"," ")+"          el: "+cdo.getColValue("fm"," "), 0, 2, Color.lightGray);
            
      pc.setFont(8, 0);
      pc.addBorderCols("Médico: "+cdo.getColValue("nombre_medico"," "), 0, 4, Color.lightGray);
      pc.addBorderCols(cdo.getColValue("nota_s"),0,1);
      pc.addBorderCols(cdo.getColValue("nota_o"),0,1);	
      pc.addBorderCols(cdo.getColValue("nota_a"),0,1);	
      pc.addBorderCols(cdo.getColValue("nota_p"),0,1);
      
      pc.addCols(" ", 0, 4);
		}
		
    
    
    
  
    
				
    pc.addTable();
    if(isUnifiedExp){
      pc.close();
      response.sendRedirect(redirectFile);
    }
%>