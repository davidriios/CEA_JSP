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
String lqs = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codOrdenMed = request.getParameter("codOrdenMed");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
boolean isLandscape = false;

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (id == null) id = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);
cdop = SQLMgr.getPacData(pacId, noAdmision);
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }

  sbSql.append("  select a.cds_omit_recibido, (select v.descripcion from tbl_sal_via_admin v where v.codigo=a.via) descvia, a.frecuencia, a.dosis, f.observacion, decode (a.tipo_tubo,'G','GOTEO','N','BOLO') tipo_tubo, to_char (a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss AM') fecha_inicio, decode (estado_orden,'S',to_char (a.fecha_suspencion, 'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char (a.fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss AM')) fecha_omitida, to_char (f.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss AM') fecha_despacho, a.secuencia dsp_admision, (select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char (a.fecha_creacion, 'hh12:mi:ss AM') hora_solicitud, nvl (a.cds_recibido, 'N') cds_recibido, a.secuencia as secuenciacorte, a.tipo_orden, to_char (a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') as fechasolicitud, a.nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noorden, a.pac_id, a.estado_orden, to_char (a.fecha_fin, 'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char (a.fecha_suspencion, 'dd/mm/yyyy hh12:mi am') as fechasuspencion, nvl (a.cod_salida, 0) as cod_salida,nvl((select cama from tbl_adm_atencion_cu where pac_id=a.pac_id and secuencia=a.secuencia),'S/C') cama, to_char (z.fecha_ingreso, 'dd/mm/yyyy') as fecha_ingreso, f.codigo_articulo, f.descripcion, f.cantidad, f.estado estado_desp, a.codigo_orden_med,f.fg from tbl_sal_detalle_orden_med a, tbl_adm_admision z,tbl_int_orden_farmacia f where z.pac_id = a.pac_id and z.secuencia = a.secuencia and a.omitir_orden = 'N' and a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.estado in ('P', 'A','R') and f.no_cargo is not null and f.pac_id = ");
  sbSql.append(pacId);
  sbSql.append(" and f.admision = ");
  sbSql.append(noAdmision);
  sbSql.append(" and f.codigo_orden_med = ");
  sbSql.append(codOrdenMed);
  //if(!id.trim().equals("")){sbSql.append(" and f.id = "); sbSql.append(id);}
  sbSql.append(" order by a.fecha_creacion desc");
  
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select d.descripcion, d.cantidad from tbl_fac_detalle_transaccion d where d.ref_type = 'FARINSUMOS' and compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and d.fac_secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and d.ref_id = '");
sbSql.append(codOrdenMed);
sbSql.append("' and d.pac_id = ");
sbSql.append(pacId);

ArrayList alInsumos = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ENTREGA DE ORDEN MEDICA";
	String subtitle = "";
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
		dHeader.addElement(".09");
		dHeader.addElement(".11");
		dHeader.addElement(".10");
		dHeader.addElement(".03");
		dHeader.addElement(".08");
		dHeader.addElement(".13");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".14");
		dHeader.addElement(".14");

		footer.setNoColumn(3);
		footer.createTable("footer",false,0,0.0f,width);
		footer.setVAlignment(2);
		footer.setFont(7, 1);
		footer.addBorderCols("Recibido por",1,1,0.0f,0.5f,0.0f,0.0f);
		footer.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
		footer.addBorderCols("Despachado por",1,1,0.0f,0.5f,0.0f,0.0f);

		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("ESTADO",1,1);
		pc.addBorderCols("HORA SOL.",1,2);
		pc.addBorderCols("DESCRIPCION",1,5);		
		pc.addBorderCols("FECHA INI.",1,1);
		pc.addBorderCols("FECHA DESP.",1,1);
		

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
 		pc.setFont(7, 0);
      
		pc.addCols(cdo.getColValue("dsp_estado"),1,1);
		pc.addCols(cdo.getColValue("hora_solicitud"),1,2);
		if(cdo.getColValue("fg").trim().equals("BM"))pc.setFont(7, 0,Color.red);
		pc.addCols(cdo.getColValue("nombre")+" Cant.="+cdo.getColValue("cantidad")+" - "+cdo.getColValue("codigo_articulo")+" "+cdo.getColValue("descripcion"),0,5);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_despacho"),1,1);
		pc.setFont(7, 1);
		pc.addBorderCols("Presentación:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("descVia"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Concentración:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("dosis"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Frecuencia:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("frecuencia"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Observación:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("observacion"),0,3,0.5f,0.0f,0.0f,0.0f);
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
    
       if (alInsumos.size() > 0) {
         pc.setFont(10,1,Color.black);
         pc.addCols(" ",1,dHeader.size());
         pc.addCols("Insumos/Servicios",0,dHeader.size(),Color.lightGray);
         
         pc.setFont(7, 1);
         pc.addBorderCols("Descripción",0,6);
		 pc.addBorderCols("Cantidad",1,1);
		 pc.addCols("",1,dHeader.size()-7);
         
         for (int i=0; i<alInsumos.size(); i++){
           CommonDataObject cdo = (CommonDataObject) al.get(i);
 		   pc.setFont(7, 0);
      
		   pc.addCols(cdo.getColValue("descripcion"),0,6);
		   pc.addCols(cdo.getColValue("cantidad"),1,1);
		   pc.addCols("",1,dHeader.size()-7);
         }
       }
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>