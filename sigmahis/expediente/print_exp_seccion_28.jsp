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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String change = request.getParameter("change");
String observacion = request.getParameter("observacion");
String cda = request.getParameter("cda");
String cds = request.getParameter("cds");
String type = request.getParameter("type");
String pacId = request.getParameter("pacId");
String seccion = request.getParameter("seccion");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");

if (appendFilter == null) appendFilter = "";
if (desc == null) desc = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (codCita == null) codCita = "";
if (fechaCita == null) fechaCita = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

  sql.append("select distinct P.solicitud_no, a.almacen, b.descripcion||' - '||a.almacen as almacen_desc, to_char(p.fecha_documento, 'dd/mm/yyyy') fecha, to_char(p.fecha_documento, 'hh12:mi am') hora, t.art_familia, t.art_clase, t.cod_articulo, t.cantidad, ar.descripcion, p.observaciones, p.usuario_creacion uc,p.anio,p.adm_secuencia admision,p.estado,decode(p.estado,'N','-RECHAZADA','')descEstado FROM tbl_sec_cds_almacen a, ( select * from tbl_inv_almacen where compania = "+session.getAttribute("_companyId")+" ) b, tbl_inv_d_sol_pac T, tbl_inv_solicitud_pac p,tbl_inv_articulo ar where p.compania = t.compania and p.solicitud_no = t.solicitud_no and p.anio = t.anio and p.codigo_almacen = b.codigo_almacen and a.almacen = b.codigo_almacen and p.pac_id=");
  sql.append(pacId);
  sql.append(" and p.adm_secuencia = ");
  //sql.append(" and p.adm_secuencia in (select secuencia from tbl_adm_admision where pac_id= p.pac_id and adm_root=");
  sql.append(noAdmision);
  //sql.append(")");
    
  sql.append(" and p.compania = ");
  sql.append(session.getAttribute("_companyId"));
  sql.append(" and p.origen ='EXP' and t.art_familia =ar.cod_flia and t.art_clase=ar.cod_clase and t.cod_articulo=ar.cod_articulo and t.compania=ar.compania order by p.anio,p.adm_secuencia,p.SOLICITUD_NO");

if(fg.trim().equals("USOS"))
{
sql = new StringBuffer();
sql.append("select to_char(cu.fecha,'dd/mm/yyyy') fecha,to_char(cu.fecha, 'hh12:mi am') hora,dcu.cod_uso, su.descripcion, dcu.cantidad_uso cantidad, dcu.precio, dcu.secuencia_uso solicitud_no, dcu.renglon, su.tipo_servicio,cu.codigo_almacen,cu.usuario_creacion uc,cu.observaciones,cu.anio,cu.adm_secuencia admision,'' as descEstado,cu.estado from tbl_sal_cargos_usos cu, tbl_sal_cargos_det_usos dcu, tbl_sal_uso su where cu.compania = ");
sql.append(session.getAttribute("_companyId"));
sql.append("and cu.pac_id = ");
sql.append(pacId);
sql.append(" and cu.adm_secuencia = ");
sql.append(noAdmision);
sql.append(" and (su.codigo = dcu.cod_uso and su.compania = dcu.compania) and dcu.compania = cu.compania and dcu.anio = cu.anio and dcu.secuencia_uso = cu.secuencia");
if(fp.trim().equals("SOP")) sql.append(" and dcu.estado_renglon = 'A' and cu.estado = 'A'");
sql.append(" and cu.tipo = 'C' and cu.sop ="); 
if(fp.trim().equals("SOP")) 
sql.append("'S'");
else sql.append("'N'");
sql.append("order by cu.anio,dcu.secuencia_uso,dcu.cod_uso");

}
al = SQLMgr.getDataList(sql.toString());
		
//if (request.getMethod().equalsIgnoreCase("GET"))  
//{
    int maxLines = 35; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

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
	String title = (fp.trim().equals("SOP"))?"FACTURACION":"EXPEDIENTE";
	String subtitle = (fp.trim().equals("SOP"))?"SOLICITUD DE USOS - CITAS":desc;
	String xtraSubtitle = (fp.trim().equals("SOP"))?" CITA  # "+codCita+"  FECHA "+fechaCita:"";
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
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".09"); 
		dHeader.addElement(".10");
		dHeader.addElement(".22");
		dHeader.addElement(".10");
		dHeader.addElement(".12"); // REG. BY
		dHeader.addElement(".30");
		
String groupBy = "",groupByAdm="";
	int lCounter = 0;
	int pCounter = 1;
    
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

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("FECHA",0,1);
		pc.addBorderCols("HORA",1,1);
		if(!fp.trim().equals("SOP")){pc.addBorderCols("FAMILIA",1,1);
		pc.addBorderCols("CLASE",1,1);
		pc.addBorderCols("ARTICULO",1,1);}
		else pc.addBorderCols("CODIGO",1,1);
		if(fp.trim().equals("SOP"))pc.addBorderCols("DESCRIPCION",1,3);
		else pc.addBorderCols("DESCRIPCION",1,1);
		pc.addBorderCols("CANTIDAD",1,1);
		pc.addBorderCols("REG. POR",1,1);
		if(!fp.trim().equals("SOP"))pc.addBorderCols("OBSERVACION",1,1);
		else pc.addBorderCols(" ",1,1);
		if(fp.trim().equals("SOP")||fp.trim().equals("SEC"))pc.setTableHeader(2);
	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//pc.setVAlignment(0);
	System.out.println(" al size ============"+al.size());
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if( !groupByAdm.equals(cdo.getColValue("admision")) ){
			if ( i != 0 ){
				pc.addCols(" ",0,dHeader.size());
			}
			pc.setFont(9,1);
			pc.addCols("ADMISION #:  "+cdo.getColValue("admision"),0,3);
			pc.addCols(" ",0,6);
		}
		if( !groupBy.equals(cdo.getColValue("solicitud_no")) ){
			if ( i != 0 ){
				pc.addCols(" ",0,dHeader.size());
			}
			if(cdo.getColValue("estado").trim().equals("N"))pc.setFont(9,1,Color.red);
			else pc.setFont(9,1);
			pc.addCols("SOLICITUD #: "+cdo.getColValue("solicitud_no")+" "+cdo.getColValue("descEstado"),0,3);
			pc.setFont(9,1);
			pc.addCols(""+cdo.getColValue("observaciones"),0,6);
		}

		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols(cdo.getColValue("hora"),1,1);
		if(!fp.trim().equals("SOP")){pc.addCols(cdo.getColValue("art_familia"),1,1);
		pc.addCols(cdo.getColValue("art_clase"),1,1);
		pc.addCols(cdo.getColValue("cod_articulo"),1,1);}
		else pc.addCols(cdo.getColValue("cod_uso"),1,1);
		if(fp.trim().equals("SOP"))pc.addCols(cdo.getColValue("descripcion"),0,3);
		else pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("uc"),1,1);
		pc.addCols(" ",0,1);
		
		groupBy = cdo.getColValue("solicitud_no");
		groupByAdm = cdo.getColValue("admision");
		
	}//for i

	if (al.size() == 0)
	{
		//pc.createTable();
			pc.addCols("No existen registros",1,dHeader.size());
		//pc.addTable();
	}
	else
	{
		//pc.createTable();
		//	pc.addCols(al.size()+" Registros en total",0,dHeader.size());
		//pc.addTable();
	}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>