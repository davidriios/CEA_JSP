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
Reporte
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
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();

String sql = "";
String lqs = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (appendFilter == null) appendFilter = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

  //noAdmision = "2";
  sql = "SELECT A.RENGLON, nvl(A.DESCRIPCION,' ') as descripcion, nvl(A.DOSIS,' ') as dosis, nvl(A.OBSERVACION,' ') as observacion, A.USUARIO_CREAC UC, to_char(A.FECHA_CREAC,'dd/mm/yyyy hh12:mi am') as FECHA_CREAC, A.USUARIO_MODIF, to_char(A.FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, decode(A.VIA_ADMIN,null,' ',''||A.via_admin) as via_admin, decode(A.COD_GRUPO_DOSIS,null,' ',''||A.cod_grupo_dosis) as cod_grupo_dosis, nvl(A.COD_FRECUENCIA,' ') as cod_frecuencia, decode(A.CADA,null,' ',''||A.cada) as cada, nvl(A.TIEMPO,' ') as tiempo, nvl(A.FRECUENCIA,' ') as frecuencia, B.DESCRIPCION as desp, C.DESCRIPCION AS FORMA FROM TBL_SAL_ANTECEDENT_MEDICAMENTO A , TBL_SAL_VIA_ADMIN B, TBL_SAL_GRUPO_DOSIS C  where C.CODIGO(+)=A.COD_GRUPO_DOSIS AND B.CODIGO(+)=A.VIA_ADMIN and pac_id="+pacId+" and nvl(admision,"+noAdmision+") < "+noAdmision+" ORDER BY A.FECHA_CREAC DESC";
 al = SQLMgr.getDataList(sql);
 
 sql = " select a.fec_nacimiento,a.cod_paciente, a.secuencia, to_char(a.fecha_medica,'dd/mm/yyyy') fecha_medica, to_char( a.hora,'hh12:mi am') hora, to_char(a.hora_medica,'hh12:mi am') hora_medica, a.medicamento, a.dosis, b.descripcion as via , a.frecuencia, a.observacion, c.usuario_creacion,  to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion from tbl_sal_medicamento_admision c, tbl_sal_detalle_medicamento a, tbl_sal_via_admin b where c.pac_id = a.pac_id and c.secuencia = a.secuencia and c.fecha = a.fecha_medica and c.hora = a.hora_medica and  a.pac_id = "+pacId+" and a.secuencia =  "+noAdmision+" and a.via = b.codigo order by  to_date(a.fecha_medica,'dd/mm/yyyy') asc, to_date(to_char(a.hora_medica,'hh12:mi am'),'hh12:mi am') asc ";
 ArrayList al2 = SQLMgr.getDataList(sql);
 
//MEDICAMENTOS RECETADOS
sql = "select pac_id, admision, secuencia,medicamento, indicacion, dosis, duracion, to_char(fecha_creacion,'dd/mm/yyyy') as fecha_creacion, usuario_creacion from tbl_sal_salida_medicamento where pac_id = "+pacId+" and admision = "+noAdmision;
ArrayList al3 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	if(desc == null) desc = " ";
	
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

	float width = 82 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "CONCILIACION DE MEDICAMENTOS";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
	
		dHeader.addElement(".28");
		dHeader.addElement(".19");
		dHeader.addElement(".14");
		dHeader.addElement(".14");
		dHeader.addElement(".18");
		dHeader.addElement(".35");
		dHeader.addElement(".14");
        dHeader.addElement(".13");
        
        Vector tblAM = new Vector();
		tblAM.addElement(".08");
		tblAM.addElement(".20");
		tblAM.addElement(".08");
		tblAM.addElement(".13");
		tblAM.addElement(".13");
		tblAM.addElement(".25");
		tblAM.addElement(".13");
        
        Vector tblM = new Vector();
        tblM.addElement(".25");
        tblM.addElement(".25");
        tblM.addElement(".25");
        tblM.addElement(".15");
        tblM.addElement(".10");
        
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
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
        
        pc.setFont(8, 1,Color.black);
        pc.addCols("ANTECEDENTES DE MEDICAMENTOS",1,dHeader.size());
        
		//second row
		pc.setFont(7, 1);

		pc.addCols("",0,dHeader.size());
		pc.addBorderCols("MEDICAMENTOS",1,1);
		pc.addBorderCols("CONCENTRACIÓN",1,1); //5
		pc.addBorderCols("FORMA",1,1);
		pc.addBorderCols("FRECUENCIAS",1,1); // 2
		pc.addBorderCols("VIA. ADMIN",1,1);
		pc.addBorderCols("OBSERVACIÓN",1,1); //5
		pc.addBorderCols("CREADO POR",1,1);
		pc.addBorderCols("F. CREACIÓN",1,1);

	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setFont(7,0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("dosis"),0,1);
		pc.addCols(cdo.getColValue("FORMA"),0,1);
		pc.addCols(cdo.getColValue("frecuencia"),0,1);
		pc.addCols(cdo.getColValue("desp"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("UC"),0,1);
		pc.addCols(cdo.getColValue("FECHA_CREAC"),0,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
    /*if (al2.size() > 0) {
        pc.flushTableBody(true);
        pc.addNewPage();
    } */
    pc.addCols(" ",1,dHeader.size());
    pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(8, 1,Color.black);
    pc.addCols("MEDICAMENTOS ADMINISTRADOS",1,dHeader.size());
    
    
    pc.setNoColumnFixWidth(tblAM);
	pc.createTable("adm", false);
    
    String groupBy = "";
	pc.setVAlignment(0);
	for (int i=0; i<al2.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al2.get(i);

 		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha_medica"))){ 
		  	if (i != 0){
                pc.addCols(" ",0,tblAM.size(),cHeight);
                pc.addCols(" ",0,tblAM.size(),cHeight);
		     }

            pc.setFont(8, 1);
            pc.addBorderCols("Fecha: "+cdo.getColValue("fecha_medica"),0,8);

            pc.setFont(7, 1);
            pc.addBorderCols("HORA",1);
            pc.addBorderCols("MEDICAMENTOS",1);
            pc.addBorderCols("DOSIS",1);
            pc.addBorderCols("VIA",1);
            pc.addBorderCols("FRECUENCIA",1);
            pc.addBorderCols("OBSERVACION",1);
            pc.addBorderCols("APLICADO POR",1);
		}

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("hora_medica"),1,0);
		pc.addCols(cdo.getColValue("medicamento"),0,0);
		pc.addCols(cdo.getColValue("dosis"),1,0);
		pc.addCols(cdo.getColValue("via"),1,0);
		pc.addCols(cdo.getColValue("frecuencia"),0,0);
		pc.addCols(cdo.getColValue("observacion"),0,0);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,0);

		groupBy = cdo.getColValue("fecha_medica");

		//if ((i % 50 == 0) || ((i + 1) == al2.size())) pc.flushTableBody(true);
	}
	pc.addBorderCols("",0,tblAM.size(),0.5f,0.0f,0.0f,0.0f);

	if (al2.size() == 0) {pc.setFont(8,1); pc.addCols("No existen registros",1,tblAM.size());}
    
    pc.useTable("main");
	pc.addTableToCols("adm",0,dHeader.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);

    pc.addCols(" ",1,dHeader.size());
    pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(8, 1,Color.black);
    pc.addCols("MEDICAMENTOS RECETADOS",1,dHeader.size());
    
    pc.setNoColumnFixWidth(tblM);
	pc.createTable("med", false);
    
    pc.addBorderCols("MEDICAMENTO",1,1);
	pc.addBorderCols("INDICACION",1,1);
	pc.addBorderCols("DOSIS",1,1);
	pc.addBorderCols("DURACION",1,1);
	pc.addBorderCols("USER - FECHA",1,1);
    
    for (int i=0; i<al3.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al3.get(i);

		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("medicamento"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("indicacion"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("dosis"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("duracion"),1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("usuario_creacion")+" - "+cdo.getColValue("fecha_creacion"),0,1,0.5f,0.0f,0.0f,0.0f);
	}
    
    pc.useTable("main");
	pc.addTableToCols("med",0,dHeader.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
    
    
    
    
	pc.addTable();
if(isUnifiedExp){pc.close();response.sendRedirect(redirectFile);}
}//GET
%>