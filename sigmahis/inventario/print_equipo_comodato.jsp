<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.awt.Color" %>
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
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String unidad = request.getParameter("unidad");

String fg = request.getParameter("fg");
String sql="";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(unidad== null) unidad = "";
if(!tDate.trim().equals(""))  appendFilter  = " and to_date(to_char(ce.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy')";
if(!fDate.trim().equals(""))  appendFilter  += " and to_date(to_char(ce.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy')";
if(!unidad.trim().equals("")) appendFilter  += "  and ce.unidad_adm = "+unidad;

sql="select ce.compania,ce.nombre desc_equipo,ce.unidad_adm unidad ,ue.descripcion desc_unidad,ce.estado,ce.modelo ,ce.serie,nvl(ce.comentarios,' ') comentarios, to_char(ce.fecha_de_entrada ,'dd/mm/yyyy') fecha_entrada ,decode(ce.tipo_equipo,'CO','COMODATO','SF','SIN FACTURAR') as tipo_equipo, ce.no_equipo ,decode(ce.estado,'A','ACTIVO','I','INACTIVO',ce.estado)estadoDesc,decode(ce.estado_uso, 'U','USO','D','DISPONIBLE',ce.estado_uso)estadoUsoDesc from tbl_inv_comodato_equipos ce, tbl_sec_unidad_ejec ue where ce.unidad_adm = ue.codigo and ce.compania = ue.compania   and ue.codigo < 100  and ce.compania = "+compania+appendFilter+" order by ce.unidad_adm asc   ";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE DE EQUIPOS EN COMODATO";
	String subtitle = "DEL  "+tDate+"  Al "+fDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".08");
	setDetail.addElement(".25");
	setDetail.addElement(".12");
	setDetail.addElement(".12");
	setDetail.addElement(".07");
	setDetail.addElement(".09");
	setDetail.addElement(".25");
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());
		pc.setFont(7,1);
		pc.addBorderCols(" NO. EQUIPO"         ,1, 1);
		pc.addBorderCols(" DESC. EQUIPO" ,0, 1);
		pc.addBorderCols(" FECHA DE ENTRADA" ,0, 1);
		pc.addBorderCols(" TIPO DE EQUIPO"      ,1, 1);
		pc.addBorderCols("ESTADO"      ,1, 1);
		pc.addBorderCols(" ESTADO USO"      ,1, 1);
		pc.addBorderCols(" COMENTARIO"          ,1, 1);
		pc.setTableHeader(2);//create de table header
	String groupBy="";
	int total = 0,subTotal = 0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")))
			{
					if (i != 0)
					{
							pc.setFont(7, 1,Color.blue);
								pc.addCols("Cantidad de Equipo por Unidad :      "+subTotal,0,setDetail.size());
								pc.addBorderCols(" ",1, setDetail.size(), 0.0f, 0.5f, 0.0f, 0.0f);
							subTotal = 0;
					}
					pc.setFont(7, 1,Color.blue);
					pc.addCols("UNIDAD ADMINISTRATIVA:      "+cdo.getColValue("unidad")+"      "+cdo.getColValue("desc_unidad"),0,setDetail.size());
			}
		
		pc.setFont(7,0);
			pc.addCols(" "+cdo.getColValue("no_equipo")     ,1, 1);
			pc.addCols(" "+cdo.getColValue("desc_equipo")   ,0, 1);
			pc.addCols(" "+cdo.getColValue("fecha_entrada") ,1, 1);
			pc.addCols(" "+cdo.getColValue("tipo_equipo")   ,0, 1);
			pc.addCols(" "+cdo.getColValue("estadoDesc")   ,0, 1);
			pc.addCols(" "+cdo.getColValue("estadoUsoDesc")   ,0, 1);
			pc.addCols(" "+cdo.getColValue("comentarios")   ,0, 1);
		groupBy = cdo.getColValue("unidad");
		subTotal ++;
		total ++;
	}//for i
	
	pc.setFont(7,1);

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{ 
	  		pc.addCols("Cantidad de Equipo por Unidad :      "+subTotal,0,setDetail.size());
			pc.addBorderCols(" ",1, setDetail.size(), 0.0f, 0.5f, 0.0f, 0.0f);
			pc.addCols(" Total de Equipos:  "+total,0,setDetail.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>