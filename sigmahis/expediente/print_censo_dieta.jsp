<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="alOM" scope="session" class="java.util.ArrayList" />
<%@ include file="../common/pdf_header.jsp"%>
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
ArrayList al2 = new ArrayList();
CommonDataObject cdo, cdo2 = new CommonDataObject();
String sql = "", sql2 = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String noOrden = request.getParameter("noOrden");
String tipoComida = request.getParameter("tipoComida");
String compania = (String) session.getAttribute("_companyId");
String time = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");
String descComida = "";
if(tipoComida==null) tipoComida = "";
else if(tipoComida.equals("1")) descComida = "DESAYUNO";
else if(tipoComida.equals("2")) descComida = "ALMUERZO";
else if(tipoComida.equals("3")) descComida = "CENA";
else if(tipoComida.equals("4")) descComida = "MERIENDA AM";
else if(tipoComida.equals("5")) descComida = "MERIENDA PM";
else if(tipoComida.equals("6")) descComida = "MERIENDA NOCHE";

sql = "select aca.cds cds, b.nombre_paciente, b.id_paciente, b.edad, b.sexo, gettipodieta(z.secuencia, z.pac_id) dietas, getsubtipodieta(z.secuencia, z.pac_id) observacion, (select codigo||' - '||descripcion from tbl_cds_centro_servicio  where codigo = aca.cds) desc_cds ,aca.habitacion||' - '||aca.cama hab_cama, aca.habitacion, aca.cama from vw_adm_paciente b, tbl_adm_atencion_cu aca, tbl_adm_admision z where z.pac_id = b.pac_id and z.estado in ('A') and aca.pac_id = z.pac_id and aca.secuencia = z.secuencia and z.categoria in (1, 4, 5) and z.compania = "+(String) session.getAttribute("_companyId")+" and exists (select 1 from tbl_sal_detalle_orden_med where omitir_orden = 'N' and tipo_orden = 3 and estado_orden = 'A' and pac_id = z.pac_id and secuencia = z.secuencia) order by desc_cds, hab_cama";

sql2 = " select distinct x.descripcion dietas, count(*) cant from tbl_sal_detalle_orden_med a, tbl_cds_tipo_dieta x where a.estado_orden = 'A' and a.omitir_orden = 'N' and a.tipo_dieta = x.codigo(+) and a.tipo_orden = 3 and a.tipo_dieta is not null group by x.descripcion";

al = SQLMgr.getDataList(sql);
al2 = SQLMgr.getDataList(sql2);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CENSO DIETAS";
	String subTitle = descComida;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------
 PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".05"); //no	
		dHeader.addElement(".10"); //Cuarto	
		dHeader.addElement(".30");	//Nombre
		dHeader.addElement(".05"); //sxo
		dHeader.addElement(".10"); //edad	
		dHeader.addElement(".15"); //dieta	
		dHeader.addElement(".25"); //caracteristicas
		
		Vector header = new Vector();
		header.addElement("30");
		header.addElement("40");
		header.addElement("30");
				
	    pc.setVAlignment(0);		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();	
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.addBorderCols("Cama",0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Nombre",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Sexo",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Edad",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Dieta",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Características",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addCols("",1,dHeader.size(),10f);
		
		//pc.setTableHeader(2);
	
		String paciente = "", hab_cama = "", centroServicio = "";
		int total = 0;
		pc.setVAlignment(0);	
		for ( int i = 0; i<al.size(); i++){
		
		   cdo = (CommonDataObject)al.get(i);
		
		 if(!centroServicio.equals(cdo.getColValue("cds"))){
			   pc.setFont(8,1,Color.white);
               pc.addCols("Centro de Servicio:  "+cdo.getColValue("desc_cds"),0,dHeader.size(),Color.lightGray);
		    }
		  
		pc.setFont(8,0); 
		
		if ( !hab_cama.equals(cdo.getColValue("hab_cama")) ){
			pc.addCols(""+(i+1),0,1);
			pc.addCols(cdo.getColValue("cama"),0,1);
			pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
			pc.addCols(cdo.getColValue("sexo"),1,1);
			pc.addCols(cdo.getColValue("edad")+" Año(s)",0,1);

		}else{
		    pc.addCols(""+(i+1),0,1);
		  	pc.addCols("-",0,1);
		   	pc.addCols("-",0,1);
			pc.addCols("-",1,1);
			pc.addCols("-",0,1);
		}
		
		 pc.addCols(cdo.getColValue("dietas"),0,1);
		 pc.addCols(cdo.getColValue("observacion"),0,1);
		 pc.addBorderCols("",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		  
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
		centroServicio = cdo.getColValue("cds");
		
		hab_cama = cdo.getColValue("hab_cama");
		}//for
		
		if (al.size() < 1 ){
			pc.addCols("No existen registros!",1,dHeader.size());
		}else{

		pc.setFont(9,1);
		pc.addCols("",0,dHeader.size(),10f);
		pc.addCols("Total de Ordenes: "+al.size(),1,dHeader.size());
		pc.addCols("",0,dHeader.size(),20f);
		
		pc.setNoColumnFixWidth(header);
		pc.createTable("resumen",false,0,0.0f,(width-leftRightMargin));
		
		pc.setFont(9,1);
		pc.addCols("Resumen por Tipo de Dietas",1,header.size());
		
		pc.setFont(8,0);
		for ( int r = 0; r<al2.size(); r++){
		  cdo2 = (CommonDataObject)al2.get(r);
		  pc.addCols(cdo2.getColValue("dietas"),0,1);
		  pc.addCols(cdo2.getColValue("cant"),0,2);
			total += Integer.parseInt(cdo2.getColValue("cant"));
		}
		
		pc.setFont(9,1);
		pc.addCols("Total: ",2,1);
		pc.addCols(""+total,0,2);
		
		pc.useTable("main");
		pc.addTableToCols("resumen",1,dHeader.size(),0,null,null,0.1f,0.1f,0.1f,0.1f);
  }//else

    pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>


