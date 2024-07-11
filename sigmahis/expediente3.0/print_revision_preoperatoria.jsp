<%//@ page errorPage="../error.jsp"%>
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
Reporte sal10080
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
CommonDataObject cdo1,cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaRev = request.getParameter("fecha");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mode = request.getParameter("mode");
String desc = request.getParameter("desc");
String seccion = request.getParameter("seccion");
if (mode == null) mode = "add";
if (appendFilter == null) appendFilter = "";
if (fechaRev== null) fechaRev = "";
if (fg== null) fg = "A";

if (!fechaRev.trim().equals(""))appendFilter +=" and to_date(to_char(b.fecha_revision(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') =  to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') "; 

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

mode = "edit";

sql = "select  nvl(rp.observacion,' ') observacion, rp.cirugia, nvl(rp.desc_cirugia, rp.cirugia) desc_cirugia, rp.medico_cirujano as cirujano, nvl(rp.desc_medico_cirujano,rp.medico_cirujano) desc_medico_cirujano, to_char(fecha,'dd/mm/yyyy') as fecha, to_char(fecha,'hh12:mi am') as hora, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi am') fc, get_idoneidad(usuario_creacion, 1) usuario_creacion, to_char(fecha_modif,'dd/mm/yyyy hh12:mi am') fm, get_idoneidad(usuario_modif, 1) usuario_modif from tbl_sal_revision_preoperatoria rp, tbl_adm_medico m where rp.pac_id = "+pacId+" and rp.secuencia = "+noAdmision+" and rp.medico_cirujano = m.codigo(+) and to_date(to_char(rp.fecha(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') =  to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') and grupo = '"+fg+"'";
cdo1 = SQLMgr.getData(sql);

if(cdo1 == null) cdo1 = new CommonDataObject();

ArrayList alVP = SQLMgr.getDataList("select a.codigo, a.descripcion, b.verificado, b.observacion, decode(b.codigo_param,null,'I','U') action from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'VP' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+) and a.grupo = '"+fg+"' order by a.orden");
        
ArrayList alTO = SQLMgr.getDataList("select a.codigo, a.descripcion, b.identificacion_pac, b.proc_correcto, b.sitio_correcto, decode(b.codigo_param,null,'I','U') action from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'TO' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+) and a.grupo = '"+fg+"' order by a.orden");
        
ArrayList alSO = SQLMgr.getDataList("select a.codigo, a.descripcion, b.verificado, b.observacion, decode(b.codigo_param,null,'I','U') action from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'SO' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+) and a.grupo = '"+fg+"'  order by a.orden");

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	Vector dHeader = new Vector();
		dHeader.addElement(".60");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
        dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		
	
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
		footer.setFont(3, 0);
		footer.addCols(" ",0,dHeader.size());
		footer.setFont(9, 0);
		footer.addBorderCols("OBSERVACION: "+cdo1.getColValue("observacion"," "),0,dHeader.size());
		footer.addBorderCols("FIRME DEL EVALUADOR: ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
	if(pc==null){pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());
	isUnifiedExp=true;}
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp,cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

    //second row
    
    pc.setFont(9, 1);
    pc.addCols("Creado el: "+cdo1.getColValue("fc"," "),0,1);
    pc.addCols("Creado por: "+cdo1.getColValue("usuario_creacion"," "),0,dHeader.size()-1);
	
	if (!cdo1.getColValue("usuario_modif"," ").trim().equals("")) {
		pc.addCols("Modificado el: "+cdo1.getColValue("fm"," "),0,1);
		pc.addCols("Modificado por: "+cdo1.getColValue("usuario_modif"," "),0,dHeader.size()-1);
	}

    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9, 1);
    pc.addCols("GENERALES",0,dHeader.size(),Color.lightGray);
    pc.addCols("Cirugía: "+cdo1.getColValue("desc_cirugia"," "),0,dHeader.size());
    pc.addCols("Doctor/Cirujano: "+cdo1.getColValue("desc_medico_cirujano"," "),0,dHeader.size());
    pc.addCols("Fecha de Revisión: "+cdo1.getColValue("fecha"," "),0,1);
    pc.addCols("Hora de Revisión: "+cdo1.getColValue("hora"," "),0,dHeader.size()-1);

    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9, 1);
    pc.addCols("VERIFICACION PRE-OPERATORIA",0,dHeader.size(),Color.lightGray);
		
	pc.setFont(8, 1);
    pc.addBorderCols("FACTORES",0,4);
    pc.addBorderCols("SI",1,1);
    pc.addBorderCols("NO",1,1);
    pc.addBorderCols("NO APLICA",1,1);
	pc.setVAlignment(0);
	pc.setTableHeader(5);
	
	for (int i=0; i<alVP.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) alVP.get(i);

		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("descripcion"),0,4);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("S")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("N")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("X")?"x":"",1,1);
	}
    
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9, 1);
    pc.addCols("PAUSA DE SEGURIDAD (TIME OUT)",0,dHeader.size(),Color.lightGray);
    
    pc.setFont(8, 1);
    pc.addBorderCols("",0,1);
    pc.addBorderCols("Indentificación correcta del paciente",1,2);
    pc.addBorderCols("Procedimiento Correcto a realizar",1,2);
    pc.addBorderCols("Sitio Correcto del procedimiento invasivo o quirúrgico",1,2);
    
    pc.addBorderCols("FACTORES",0,1);
    pc.addBorderCols("SI",1,1);
    pc.addBorderCols("NO",1,1);
    pc.addBorderCols("SI",1,1);
    pc.addBorderCols("NO",1,1);
    pc.addBorderCols("SI",1,1);
    pc.addBorderCols("NO",1,1);
	pc.setVAlignment(0);
    
    for (int i=0; i<alTO.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) alTO.get(i);

		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
		pc.addBorderCols(cdo.getColValue("identificacion_pac"," ").equalsIgnoreCase("S")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("identificacion_pac"," ").equalsIgnoreCase("N")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("proc_correcto"," ").equalsIgnoreCase("S")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("proc_correcto"," ").equalsIgnoreCase("N")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("sitio_correcto"," ").equalsIgnoreCase("S")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("sitio_correcto"," ").equalsIgnoreCase("N")?"x":"",1,1);

	}
    
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9, 1);
    pc.addCols("VERIFICACION POST-OPERATORIA",0,dHeader.size(),Color.lightGray);
		
	pc.setFont(8, 1);
    pc.addBorderCols("FACTORES",0,4);
    pc.addBorderCols("SI",1,1);
    pc.addBorderCols("NO",1,1);
    pc.addBorderCols("NO APLICA",1,1);
	pc.setVAlignment(0);
	pc.setTableHeader(5);
	
	for (int i=0; i<alSO.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) alSO.get(i);

		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("descripcion"),0,4);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("S")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("N")?"x":"",1,1);
		pc.addBorderCols(cdo.getColValue("verificado"," ").equalsIgnoreCase("X")?"x":"",1,1);

	}
    
    

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}

	
//}//GET
%>