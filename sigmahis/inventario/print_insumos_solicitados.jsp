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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();

String sql = "",filter="",filter1="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String wh = request.getParameter("wh");
String cds = request.getParameter("cds");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if(tDate== null)  tDate="";
if(fDate== null)  fDate="";
if(wh== null)  wh="";
if(cds== null)  cds="";
if(pacId== null)  pacId="";
if(noAdmision== null)  noAdmision=""; 


if(fDate!=""){filter +=" and trunc(a.fecha_documento) >= to_date('"+fDate+"','dd/mm/yyyy') ";filter1 +=" and trunc(a.fecha) >= to_date('"+fDate+"','dd/mm/yyyy') ";}
if(tDate!=""){filter +=" and trunc(a.fecha_documento) <= to_date('"+tDate+"','dd/mm/yyyy') ";filter1 +=" and trunc(a.fecha) <= to_date('"+tDate+"','dd/mm/yyyy') ";}


if(wh!=""){filter +=" and a.codigo_almacen= "+wh;filter1 +=" and a.codigo_almacen= "+wh;}
if(cds!=""){filter +=" and a.centro_servicio= "+cds;filter1 +=" and a.sala_cod= "+cds;}
if(pacId!=""){filter +=" and a.pac_id= "+pacId;filter1 +=" and a.pac_id= "+pacId;}
if(noAdmision!=""){filter +=" and a.adm_secuencia= "+noAdmision;filter1 +=" and a.adm_secuencia= "+noAdmision;}


sql=" select y.* ,nvl(x.cantidad,0) entregado,nvl(x.no_entrega,'--')no_entrega from( select 'S' tipo, a.anio  ,a.solicitud_no ,a.centro_servicio,ds.art_familia cod_familia,ds.art_clase cod_clase,ds.cod_articulo ,ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo articulo,nvl(sum(ds.cantidad),0) solicitado,ds.estado_renglon estado ,a.pac_id,to_char(a.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento,a.paciente,a.adm_secuencia,ar.descripcion desc_articulo,ap.primer_nombre||' '||ap.segundo_nombre||' '||ap.primer_apellido||' '||ap.segundo_apellido nombre_paciente,cc.descripcion desc_centro from tbl_inv_d_sol_pac ds,tbl_inv_solicitud_pac a,tbl_inv_articulo ar, tbl_adm_paciente ap,tbl_cds_centro_servicio cc where a.compania = "+compania+filter;  
 sql+=" and a.compania = ds.compania and a.anio = ds.anio and a.solicitud_no = ds.solicitud_no and ds.compania = ar.compania and ds.cod_articulo = ar.cod_articulo and ap.pac_id = a.pac_id and a.centro_servicio = cc.codigo group by 'S',a.anio,a.solicitud_no,a.centro_servicio,ds.art_familia, ds.art_clase,ds.cod_articulo,ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo, ds.estado_renglon, a.fecha_nacimiento, a.paciente,a.adm_secuencia,ar.descripcion,ap.primer_nombre||' '||ap.segundo_nombre||' '||ap.primer_apellido||' '||ap.segundo_apellido, cc.descripcion ,a.pac_id     ) y, (        select em.anio||'-'||em.no_entrega no_entrega, sum(nvl(de.cantidad,0)) cantidad  ,   em.pac_anio anio ,em.pac_solicitud_no no_solicitud,  de.cod_familia ,de.cod_clase ,de.cod_articulo from tbl_inv_detalle_entrega de, tbl_inv_entrega_material em where em.compania = "+compania+" and de.compania = em.compania and de.anio = em.anio and de.no_entrega = em.no_entrega and em.pac_anio  is not null  and em.pac_solicitud_no is not null group by em.pac_anio ,em.pac_solicitud_no ,  de.cod_familia ,de.cod_clase ,de.cod_articulo , em.anio||'-'||em.no_entrega   )x  where   x.anio (+) = y.anio and x.no_solicitud (+)=  y.solicitud_no and y.cod_articulo = x.cod_articulo(+)  union select  'D' tipo,a.anio anio_sol,a.num_devolucion sol_no,a.sala_cod centro_servicio,dd.cod_familia fam,dd.cod_clase cla,dd.cod_articulo art, dd.cod_familia||'-'||dd.cod_clase||'-'||dd.cod_articulo articulo, -nvl(sum(cantidad),0), 'X' estado ,a.pac_id,to_char(a.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.paciente, a.adm_secuencia, ar.descripcion articulo_desc, ap.primer_nombre||' '||ap.segundo_nombre||' '||ap.primer_apellido||' '||ap.segundo_apellido paciente_nom, cc.descripcion centro_servicio_nom,0,'--' from tbl_inv_detalle_paciente dd, tbl_inv_devolucion_pac a,tbl_inv_articulo ar,tbl_adm_paciente ap,tbl_cds_centro_servicio cc  where  a.compania = "+compania+filter1+" /* and a.codigo_almacen = 7 and a.sala_cod in (10,22)*/ and dd.anio_devolucion = a.anio and dd.num_devolucion = a.num_devolucion and dd.compania = a.compania and ar.compania = dd.compania and ar.cod_articulo = dd.cod_articulo and a.pac_id = ap.pac_id and a.sala_cod = cc.codigo group by 'D',  a.anio,a.num_devolucion, a.sala_cod,dd.cod_familia,dd.cod_clase, dd.cod_articulo, dd.cod_familia||'-'||dd.cod_clase||'-'||dd.cod_articulo,'X',a.fecha_nacimiento,a.paciente,a.adm_secuencia, ar.descripcion, ap.primer_nombre||' '||ap.segundo_nombre||' '||ap.primer_apellido||' '||ap.segundo_apellido, cc.descripcion ,a.pac_id order by 11,14,15 " ;

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
	String title = "INSUMOS SOLICITADOS VS ENTREGADOS";
	String subtitle ="DESDE "+fDate+" HASTA  "+tDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom	
 	float cHeight = 11.0f; 

	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".04");
		setDetail.addElement(".08");
		setDetail.addElement(".11");
		setDetail.addElement(".11");
		setDetail.addElement(".11");
		setDetail.addElement(".39");
		setDetail.addElement(".08");
		setDetail.addElement(".08");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".50");
		setDetail0.addElement(".50");
 
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	    pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());
		pc.setFont(7, 1);
		pc.addBorderCols(" ",1);
		pc.addBorderCols("AÑO",0);
		pc.addBorderCols("SOLICITUD",0);
		pc.addBorderCols("ENTREGA",0);
		pc.addBorderCols("CODIGO",0);
		pc.addBorderCols("DESCRIPCION",0);
		pc.addBorderCols("CANTIDAD",1);
		pc.addBorderCols("ENTREGAS",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
String groupBy ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i); 

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("pac_id")))
			{

						pc.addCols(" ",0,setDetail.size()); 
						pc.setFont(7, 1); 
						pc.addCols(" "+cdo.getColValue("nombre_paciente"),0,5,cHeight);
						pc.addCols(" "+cdo.getColValue("desc_centro"),0,3,cHeight); 					 
			}


		pc.setNoColumnFixWidth(setDetail);
		if(cdo.getColValue("tipo").trim().equals("D"))
		pc.setFont(7, 0,Color.blue);
		else if(cdo.getColValue("entregado").trim().equals("0")&& !cdo.getColValue("tipo").trim().equals("D") )
		pc.setFont(7, 0,Color.red);
		else pc.setFont(7, 0); 
			pc.addCols(""+cdo.getColValue("tipo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("anio"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("solicitud_no"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("no_entrega"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("solicitado"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("entregado"),1,1,cHeight);
		  
		groupBy      = cdo.getColValue("pac_id");

	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{
			pc.setFont(7, 1);
			  pc.addCols("TOTAL DE SOLICITUDES:  "+al.size(),0,setDetail.size()); 
	}
	
pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
