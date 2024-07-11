<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
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
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String compania = (String) session.getAttribute("_companyId");
String fechafin = request.getParameter("fDate");
String fechaini = request.getParameter("tDate");
String user = request.getParameter("user");
String titulo = request.getParameter("titulo");
String area = request.getParameter("area");
String descFecha ="";
if (appendFilter == null) appendFilter = "";
if (fechafin == null) fechafin = "";
if (fechaini == null) fechaini = "";
if (area == null) area = "";
if (titulo == null) titulo = "";
if(!fechaini.trim().equals("")){appendFilter += "and trunc(sr.fecha_creacion) >= to_date('"+fechaini+"','dd/mm/yyyy') ";}

if(!fechafin.trim().equals("")){
appendFilter += "and trunc(sr.fecha_creacion) <= to_date('"+fechafin+"','dd/mm/yyyy') ";
descFecha = CmnMgr.getFormattedDate(fechafin,"FMDAY dd, MONTH yyyy"); 
}
if(!area.trim().equals("")) appendFilter += "  and sr.unidad_administrativa  = "+area;
    sql = " select to_char(to_date(to_char(sr.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy'),'dd/MON/yyyy', 'NLS_DATE_LANGUAGE=SPANISH')  fecha, sr.unidad_administrativa unidad, ds.req_anio anio, ds.solicitud_no ,ds.art_familia, ds.art_clase, ds.cod_articulo,nvl(ds.cantidad,0) cantidad, ds.despachado, ds.estado_renglon, ue.descripcion desc_unidad, ar.descripcion desc_articulo,nvl(getproveedor(ds.cod_articulo,ds.compania),' ') proveedor from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds, tbl_sec_unidad_ejec ue, tbl_inv_articulo ar where (sr.compania = "+compania+" and sr.compania_sol = "+compania+ appendFilter +"  and  sr.estado_solicitud in ('T','A') and ds.estado_renglon = 'P') and  ((ds.compania = sr.compania and ds.solicitud_no = sr.solicitud_no and ds.tipo_solicitud = sr.tipo_solicitud and ds.req_anio = sr.anio) and (sr.unidad_administrativa = ue.codigo) and (sr.compania_sol = ue.compania) and (ds.compania_sol = ar.compania and ds.art_familia = ar.cod_flia and ds.art_clase = ar.cod_clase and ds.cod_articulo = ar.cod_articulo)) order by sr.unidad_administrativa asc,   ds.req_anio asc, ds.solicitud_no asc";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PEDIDO PENDIENTE - "+titulo;
	String subtitle ="DESDE "+fechaini+" HASTA  "+fechafin;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".35");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".10");
		dHeader.addElement(".30");

	 

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
 		pc.setFont(7, 1);
		pc.addBorderCols("Artículo",0);
		pc.addBorderCols("Requisicion",1,2);
		//pc.addBorderCols(" ",1);
		pc.addBorderCols("Fecha",1);
		//pc.addBorderCols("Año",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Despachado",1);
		pc.addBorderCols("Proveedor",1);
        // begin table detail 
       
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
 	pc.setFont(headerFontSize,1);
 	//table body
	String groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00; 
	boolean delPacDet = true;
 	float cHeight = 11.0f;
	int cantArea = 0,total =0;
 	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.trim().equals(cdo.getColValue("unidad")))
		{
			if (i != 0)
			{
 				pc.setFont(7, 1);
				pc.addCols(" ",0,dHeader.size());
 					pc.setFont(8, 0);
					pc.addCols("Total por Area : "+cantArea,0,dHeader.size());
 					cantArea = 0;
 			}
			
 			pc.setFont(7, 0,Color.blue);
			pc.addCols("Area         "+cdo.getColValue("unidad")+"             "+cdo.getColValue("desc_unidad"),0,dHeader.size(),cHeight);
 			
 				pc.setFont(7, 1);
				pc.addCols(" ",0,dHeader.size());
 		}

			pc.setFont(7,0); 
			pc.addBorderCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("anio"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("solicitud_no"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("despachado"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("proveedor"),0,1,cHeight);
		 	cantArea ++;
			total ++;
			groupBy = cdo.getColValue("unidad");
		
	}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(8, 0);
			pc.addCols("Total por Area : "+cantArea,0,dHeader.size());
			pc.setFont(8, 1);
			pc.addCols("",0,dHeader.size());
 			pc.setFont(9, 1,Color.blue);
			pc.addCols("Gran Total : "+total,1,dHeader.size());
 
	}
pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
