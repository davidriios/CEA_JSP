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

CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String acompaniadoPor = request.getParameter("acompaniadoPor")==null?"":request.getParameter("acompaniadoPor");

ArrayList al = new ArrayList();

if (tipo.trim().equals("")) throw new Exception("No podemos identificar la acción. Contacte un administrador!");

cdo.setTableName("tbl_sal_cons_incap_transf");
cdo.addColValue("pac_id",pacId);
cdo.addColValue("admision",noAdmision);
cdo.addColValue("tipo",tipo);
cdo.addColValue("status","A");
cdo.addColValue("usuario_creacion",userName);
cdo.addColValue("fecha_creacion",cDateTime);
cdo.setAutoIncCol("id");

cdo.addColValue("company_seq","(select nvl(max(company_seq), decode('"+tipo+"','C',get_sec_comp_param(-1,'CONSTANCIA_SEQ'),'I', get_sec_comp_param(-1,'INCAPACIDAD_SEQ'), 'T', get_sec_comp_param(-1,'TRANSFERENCIA_SEQ') )  )+1 from tbl_sal_cons_incap_transf where tipo = '"+tipo+"')");
cdo.setWhereClause("pac_id = "+pacId+" and admision ="+noAdmision+" and tipo = '"+tipo+"'");
al.add(cdo);

SQLMgr.insertList(al);

if (SQLMgr.getErrCode().equals("1")){

	sql = "select lpad((select company_seq from tbl_sal_cons_incap_transf where pac_id=s.pac_id and admision = s.secuencia and tipo = '"+tipo+"'),10,0) as seq, p.nombre_paciente, coalesce(p.id_paciente, p.pasaporte) as id_paciente, to_char(s.diai_incap,'dd') dia, to_char(s.diai_incap,'Month','NLS_DATE_LANGUAGE=Spanish') mes, to_char(s.diai_incap,'yyyy') anio, nvl(s.dia_incap,0) as tot_dia_incap, to_char(s.horai_incap,'hh12:mi am') hora_ini, to_char(s.horaf_incap,'hh12:mi am') as hora_fin, nvl(s.hora_incap,0) as tot_h_incap, to_char(sysdate,'Month','NLS_DATE_LANGUAGE=Spanish') as c_month, to_char(sysdate,'dd') as c_day, to_char(sysdate,'yyyy') as c_year, s.nombre_acompaniante, s.cedula_acompaniante,to_char(s.diaf_incap,'dd') diaf, to_char(s.diaf_incap,'Month','NLS_DATE_LANGUAGE=Spanish') mesf, to_char(s.diaf_incap,'yyyy') aniof from vw_adm_paciente p, tbl_adm_admision a, tbl_sal_adm_salida_datos s where p.pac_id = a.pac_id and s.pac_id = p.pac_id and s.secuencia = a.secuencia and p.pac_id="+pacId+" and a.secuencia="+noAdmision+"";

	cdo = SQLMgr.getData(sql);
}else{cdo = new CommonDataObject();}

if (cdo == null) cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

	float width = 72 * 8.23f;
	float height = 72 * 5.42f;
	boolean isLandscape = false;
	float leftRightMargin = 20.0f;
	float topMargin = 15.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 1f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subTitle = "";
	String xtraSubtitle = "";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector main = new Vector();   		
	main.addElement("1");
	
	Vector header = new Vector();
	header.addElement("20");
	header.addElement("60");
	header.addElement("20");
	
	Vector det = new Vector();
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	det.addElement("5");
	
	pc.setVAlignment(0);		
	pc.setNoColumnFixWidth(main);
	pc.createTable();	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, main.size());
	
	pc.setVAlignment(0);
	pc.setNoColumnFixWidth(header);
	pc.createTable("header");
	    pc.addCols("",1,1);
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),40.0f,1);
		pc.addCols("",1,1);
		
		pc.setFont(12,1);
		pc.addCols(_comp.getNombre(),1,header.size());
		
		pc.setFont(12,0);
		pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,header.size());
		
		pc.addCols("Apdo. "+_comp.getApartadoPostal(),1,header.size());
		pc.addCols("Tels. "+_comp.getTelefono(),1,header.size());
		
		String cTitle = "CONSTANCIA";
		if(tipo.equals("I")) cTitle = "CERTIFICADO DE INCAPACIDAD";
		pc.addCols(cTitle,1,header.size());
		
	pc.setVAlignment(0);
	pc.useTable("main");
	pc.addTableToCols("header",1,main.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	//detail
		
	pc.setNoColumnFixWidth(det);
	pc.createTable("det",false,0,0.0f,(width-leftRightMargin));
	  pc.addCols(" ",0,det.size());
	  
	  String pacTitle = tipo.equals("I")?"el(la) Sr.(A)":"el paciente";
	  
	  pc.addCols("El subscrito médico certifica  que "+pacTitle,0,9);
	  pc.addBorderCols(cdo.getColValue("nombre_paciente"),0,10,0.1f,0.0f,0.0f,0.0f);
	  pc.addCols(" ",0,1);
	  
	  pc.addCols("con CIP",0,2);
	  pc.addBorderCols(cdo.getColValue("id_paciente"),1,5,0.1f,0.0f,0.0f,0.0f,14.0f);
	  if(tipo.equals("C")) pc.addCols(" fue atendido en este centro médico, y estuvo acompañando",0,13);
	  else pc.addCols(" ha sido examinado(a) y considera (ha estado) incapacitado(a)",0,13);
	  
	  if(tipo.equals("I")){
	  
		  if (cdo.getColValue("tot_h_incap")!=null && Integer.parseInt(cdo.getColValue("tot_h_incap"))>0){
		    pc.addCols("por",0,1);
			pc.addBorderCols(cdo.getColValue("tot_h_incap"),1,1,0.1f,0.0f,0.0f,0.0f,14.0f);
		    pc.addCols("hora(s)",0,18);
		  }else if (cdo.getColValue("tot_dia_incap")!=null && Integer.parseInt(cdo.getColValue("tot_dia_incap"))>0){
		    pc.addCols("por",0,1);
			pc.addBorderCols(cdo.getColValue("tot_dia_incap"),1,1,0.1f,0.0f,0.0f,0.0f,14.0f);
		    pc.addCols("día(s)",0,18);
		  }
	  }else{

		  pc.addCols("por",0,1);
		  pc.addBorderCols(cdo.getColValue("nombre_acompaniante"),0,9,0.1f,0.0f,0.0f,0.0f,14.0f);
		  pc.addCols("con CIP",1,2);
		  pc.addBorderCols(cdo.getColValue("cedula_acompaniante"),0,7,0.1f,0.0f,0.0f,0.0f,14.0f);
		  pc.addCols(" ",0,1);
	  }
	  
		pc.addCols(" ",0,det.size(),8.0f);
	  if (cdo.getColValue("tot_h_incap")!=null && Integer.parseInt(cdo.getColValue("tot_h_incap"))>0){
		 pc.addCols("DESDE: ",0,2);
		 pc.addBorderCols(cdo.getColValue("hora_ini"),0,2,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("  ",0,5);
		 pc.addCols("HASTA: ",0,2);
		 pc.addBorderCols(cdo.getColValue("hora_fin"),0,2,0.1f,0.0f,0.0f,0.0f,14.0f);
		 
		 pc.setFont(12,1);
		 pc.addCols(cdo.getColValue("tot_h_incap")+" hora(s)",1,4,14.0f);
		 
		 pc.addCols("  ",0,3);
	  }
	  else if (cdo.getColValue("tot_dia_incap")!=null && Integer.parseInt(cdo.getColValue("tot_dia_incap"))>0){
		 pc.addCols("DEL: ",0,2);
		 pc.addBorderCols(cdo.getColValue("dia"),1,1,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("MES DE",1,2); 
		 pc.addBorderCols(cdo.getColValue("mes"),0,3,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("AÑO",1,2);
		 pc.addBorderCols(cdo.getColValue("anio"),0,2,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("  ",0,8);
		 
		 pc.addCols("HASTA: ",0,2);
		 pc.addBorderCols(cdo.getColValue("diaf"),1,1,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("MES DE",1,2); 
		 pc.addBorderCols(cdo.getColValue("mesf"),0,3,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("AÑO",1,2);
		 pc.addBorderCols(cdo.getColValue("aniof"),0,2,0.1f,0.0f,0.0f,0.0f,14.0f);
		 pc.addCols("",0,3);
		 pc.addCols(cdo.getColValue("tot_dia_incap")+" día(s)",0,5);
	  }
	  
	  pc.setFont(12,0);
	  pc.addCols(" ",0,det.size(),8.0f);
	  
	  // may be from a properties var or session
	  pc.addCols("Panamá",0,2);
	  
	  pc.addBorderCols(cdo.getColValue("c_day"),0,1,0.1f,0.0f,0.0f,0.0f,14.0f);
	  pc.addCols("de",1,1);
	  pc.addBorderCols(cdo.getColValue("c_month"),1,3,0.1f,0.0f,0.0f,0.0f,14.0f);
	  pc.addCols("de",1,1);
	  pc.addBorderCols(cdo.getColValue("c_year"),1,2,0.1f,0.0f,0.0f,0.0f,14.0f);
	  pc.addCols(" ",1,10);
	  
	  pc.addCols(" ",0,det.size(),8.0f);
	  pc.addCols("Atentamente,",0,det.size(),40.0f);
	  
	  pc.addBorderCols("Firma y sello",1,10,0.0f,0.1f,0.0f,0.0f);
	  
	  pc.setFont(12,1,Color.red);
	  pc.addCols("No.: "+cdo.getColValue("seq"),2,8);
	  pc.addCols(" ",1,2);
	  

	
	pc.setVAlignment(0);
	pc.useTable("main");
	pc.addTableToCols("det",1,main.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	    
    
  pc.addTable();  
  pc.close();
  response.sendRedirect(redirectFile);
}//get
%>