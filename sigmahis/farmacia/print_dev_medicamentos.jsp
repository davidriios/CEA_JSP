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

StringBuffer sbSql = new StringBuffer(); 
String appendFilter = request.getParameter("appendFilter"); 
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String docId = request.getParameter("docId");
String estado = request.getParameter("estado");
String admCargo = request.getParameter("admCargo");
String noDev = request.getParameter("noDev");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (docId == null) docId = "";
if (estado == null) estado = "D";
if (admCargo == null) admCargo = "";
if (noDev == null) noDev = "";

cdop = SQLMgr.getPacData(pacId, noAdmision); 

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'FAR_GENERAR_TRX_POS'),'N') as v_far_generar_pos from dual ");


sbSql.append(" select f.id,f.cod_paciente,to_char(f.fec_nacimiento, 'dd/mm/yyyy')fecha_nacimiento,f.admision,f.pac_id,nvl(f.cantidad_dev,0)cantidadDev, f.cantidad as cantidadRec,f.codigo_articulo,f.descripcion,f.precio_unitario,f.orden_med,f.orden_med  as noOrden,f.compania_ref,f.cds_cargo,f.costo, to_char(f.fecha_cargo,'dd/mm/yyyy')as fec_cargo,trunc(f.fecha_cargo)as fecha_cargo,b.nombre_paciente,b.id_paciente as identificacion,z.fecha_ingreso,b.sexo,z.adm_root,f.compania,f.almacen,f.observacion,f.estado,f.other1,f.fg,f.recargo,decode(f.estado,'R',to_char(f.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am'),'') as fecha_modificacion ,f.usuario_creacion usuario_sol, decode(f.estado,'R',f.usuario_modificacion,'') as usuario_rec,f.no_dev,f.precio_venta_pos from tbl_int_dev_farmacia f ,vw_adm_paciente b,tbl_adm_admision z where  f.pac_id =b.pac_id  and f.pac_id =z.pac_id and f.admision=z.secuencia ");

//and f.fecha_cargo >= to_date('30/09/2012','dd/mm/yyyy')  and f.fecha_cargo <= to_date('30/09/2013','dd/mm/yyyy')
	sbSql.append(" and f.pac_id=");
	sbSql.append(pacId);
	sbSql.append(" and f.admision=");
	sbSql.append(noAdmision);
	
	if(estado.trim().equals("D")){sbSql.append("  and z.estado not in ('I','N') ");}
	
	if(fg.trim().equals("FAR")){if(!estado.trim().equals("")){sbSql.append(" and f.estado ='");sbSql.append(estado);sbSql.append("'");}else sbSql.append(" and f.estado ='D' ");}
	else if(fg.trim().equals("CONF")){sbSql.append(" and f.estado ='R'  and f.other1=1 ");}
	
	if(!fg.trim().equals("FAR"))
	{
	   if(!docId.trim().equals("")){sbSql.append(" and f.doc_id ="); sbSql.append(docId);}
	   if(!noDev.trim().equals("")){sbSql.append(" and f.no_dev ="); sbSql.append(noDev);}
	}
	else{ if(!docId.trim().equals("")){sbSql.append(" and f.no_dev ="); sbSql.append(docId);}}
	/*if(!noOrden.trim().equals("")){sbSql.append(" and f.orden_med = ");
	sbSql.append(noOrden);}*/
	if(!admCargo.trim().equals("")){sbSql.append(" and f.adm_cargo=");sbSql.append(admCargo);}

	sbSql.append("  order by f.id ");
 
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	boolean isLandscape = false;
	if(!fg.trim().equals("FAR"))isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (fg.trim().equals("FAR"))?"SOLICITUD DE DEVOLUCION DE MEDICAMENTOS":"CONFIRMACION DE DEVOLUCION DE MEDICAMENTOS";
	String subtitle = "";
	if(!docId.trim().equals("")) subtitle = "DEVOLUCION NO:  "+docId;
	if(fg.trim().equals("FAR")){if(estado.trim().equals("D"))title += " - POR CONFIRMAR";else if(estado.trim().equals("R"))title += " - RECIBIDA";else if(estado.trim().equals("I"))title += " - RECHAZADA";}
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
		dHeader.addElement(".05");
		dHeader.addElement(".09");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		
		if(!fg.trim().equals("FAR")||estado.trim().equals("R")){dHeader.addElement(".17");
			dHeader.addElement(".06");}
		else dHeader.addElement(".23");
		
		dHeader.addElement(".23");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

		footer.setNoColumn(3);
		footer.createTable("footer",false,0,0.0f,width);
		footer.setVAlignment(2);
		footer.setFont(7, 1);/*
		footer.addBorderCols("Solicitado por",1,1,0.0f,0.5f,0.0f,0.0f);
		footer.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
		footer.addBorderCols("Recibido por",1,1,0.0f,0.5f,0.0f,0.0f);*/

		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("NO. DEV",1,1);
		pc.addBorderCols("FECHA CARGO",1,1);
		pc.addBorderCols("CANT. DEV",1,1);
		pc.addBorderCols("CANT. REC.",1,1);
		pc.addBorderCols("MEDICAMENTO",1,1);		
		if(!fg.trim().equals("FAR")||estado.trim().equals("R"))pc.addBorderCols("PRECIO",1,1);
		pc.addBorderCols("OBSERVACION",1,1);
		pc.addBorderCols("USUARIO SOL.",1,1);
		pc.addBorderCols("USUARIO REC.",1,1);
		pc.addBorderCols("FECHA REC.",1,1);	
		

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
 		pc.setFont(7, 0);
      
	    pc.addCols(cdo.getColValue("no_dev"),1,1);
		pc.addCols(cdo.getColValue("fec_cargo"),1,1);
		pc.addCols(cdo.getColValue("cantidadDev"),1,1);
		/*if(fg.trim().equals("FAR"))pc.addCols("",1,1);
		else*/ pc.addCols(cdo.getColValue("cantidadRec"),1,1);
		
		pc.addCols(cdo.getColValue("codigo_articulo")+" - "+cdo.getColValue("descripcion"),0,1);
		if(!fg.trim().equals("FAR")||estado.trim().equals("R"))pc.addCols(cdo.getColValue("precio_venta_pos"),1,1); 
		
		pc.addCols(cdo.getColValue("observacion"),1,1);
		pc.addCols(cdo.getColValue("usuario_sol"),1,1);
		pc.addCols(cdo.getColValue("usuario_rec"),1,1);
		pc.addCols(cdo.getColValue("fecha_modificacion"),1,1);
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>