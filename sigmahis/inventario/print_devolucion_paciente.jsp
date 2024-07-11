.<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String id = request.getParameter("id");

String compania = request.getParameter("compania");
if (compania == null ) compania = (String) session.getAttribute("_companyId");
if(id == null) id ="";

if (appendFilter == null) appendFilter = "";

sql="select  p.pac_id pacId,dp.adm_secuencia as admision, p.primer_apellido||' '|| p.segundo_apellido||' '||p.apellido_de_casada||', '||p.primer_nombre||' '||p.segundo_nombre nombre , dp.anio||dp.num_devolucion numDev ,to_char(dp.fecha,'dd/mm/yyyy')  fechaDev , dtp.cod_familia familia , dtp.cod_clase clase, dtp.cod_articulo  articulo, a.descripcion  , nvl(decode(dp.estado,'R',dtp.cantidad),0)as recibido, dtp.cantidad as devuelto, dtp.precio precio, dp.monto total, dp.observacion , dp.sala_cod sala_cod, cd.descripcion salaDesc, nvl(dp.usuario_creacion,' ') usuarioCreacion, nvl(to_char(dp.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am'), ' ') fechaCreacion, nvl(dp.usuario_modif,' ') usuarioModif, nvl(to_char(dp.fecha_modif, 'dd/mm/yyyy hh12:mi:ss am'), ' ') fechaModif from vw_adm_paciente p , tbl_inv_articulo a, tbl_inv_devolucion_pac dp , tbl_inv_detalle_paciente dtp, tbl_cds_centro_servicio cd where  (dp.compania = "+(String) session.getAttribute("_companyId") +" and dp.anio||dp.num_devolucion  = nvl('"+id+"', dp.anio||dp.num_devolucion)) and dp.pac_id = p.pac_id and (dtp.compania = dp.compania and dtp.num_devolucion = dp.num_devolucion and dtp.anio_devolucion = dp.anio) and (dtp.cod_familia = a.cod_flia and dtp.cod_clase = a.cod_clase and dtp.cod_articulo = a.cod_articulo and dtp.compania = a.compania) and dp.sala_cod = cd.codigo(+)";

al = SQLMgr.getDataList(sql);

sql=" select count(*) from( select distinct  p.pac_id pacId,dp.adm_secuencia as admision, p.primer_apellido||' '|| p.segundo_apellido||' '||p.apellido_de_casada||', '||p.primer_nombre||' '||p.segundo_nombre nombre , dp.anio||dp.num_devolucion numDev   from vw_adm_paciente p , tbl_inv_articulo a, tbl_inv_devolucion_pac dp , tbl_inv_detalle_paciente dtp, tbl_cds_centro_servicio cd where  (dp.compania = "+(String) session.getAttribute("_companyId") +" and dp.anio||dp.num_devolucion  = nvl('"+id+"', dp.anio||dp.num_devolucion)) and dp.pac_id = p.pac_id and (dtp.compania = dp.compania and dtp.num_devolucion = dp.num_devolucion and dtp.anio_devolucion = dp.anio) and (dtp.cod_familia = a.cod_flia and dtp.cod_clase = a.cod_clase and dtp.cod_articulo = a.cod_articulo and dtp.compania = a.compania) and dp.sala_cod = cd.codigo(+))";

int nGroup = CmnMgr.getCount(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {

	int maxLines = 55; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size()+(nGroup*5);
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_devolucion_paciente";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);


	Vector setDetail = new Vector();//setCol
	setDetail.addElement(".20");
	setDetail.addElement(".08");
	setDetail.addElement(".37");
	setDetail.addElement(".05");
	setDetail.addElement(".30");

	Vector setDetail1=new Vector();
	setDetail1.addElement(".10");
	setDetail1.addElement(".10");
	setDetail1.addElement(".10");
	setDetail1.addElement(".46");
	setDetail1.addElement(".12");
	setDetail1.addElement(".12");


	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","SOLICITUD DE DEVOLUCION DE MATERIALES PARA PACIENTE", userName, fecha);

	pc.setNoColumnFixWidth(setDetail1);
	pc.createTable();
	pc.setFont(7, 1);
		pc.addBorderCols("Familia",1);
		pc.addBorderCols("Clase",1);
		pc.addBorderCols("Articulo",1);
		pc.addBorderCols("Descripciòn",0);
		pc.addBorderCols("Devuelto",1);
		pc.addBorderCols("Recibido",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	if (!groupBy.equalsIgnoreCase(cdo.getColValue("pacId")))
	{
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("PAC: "+cdo.getColValue("pacId")+" - "+cdo.getColValue("admision"), 0,1,cHeight);
		pc.addCols("Paciente: ", 0,1,cHeight);
		pc.addCols(""+cdo.getColValue("nombre"), 0,1,cHeight);
		pc.addCols("Sala: ", 0,1,cHeight);
		pc.addCols(""+cdo.getColValue("salaDesc"), 0,1,cHeight);
	pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("Devolucion #: ", 0,1,cHeight);
		pc.addCols(""+cdo.getColValue("numDev"), 0,2,cHeight);
		pc.addCols("Fecha", 0,1,cHeight);
		pc.addCols(""+cdo.getColValue("fechaDev"), 0,1,cHeight);
	pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("Observaciòn: "+cdo.getColValue("observacion"), 0,5,cHeight);
	pc.addTable();
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("Creacion:  "+cdo.getColValue("usuarioCreacion")+" - "+cdo.getColValue("fechaCreacion"), 0,2,cHeight);
		pc.addCols("Modificacion: "+cdo.getColValue("usuarioModif")+" - "+cdo.getColValue("fechaModif"), 0,3,cHeight);
	pc.addTable();
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("  ", 0,5);
	pc.addTable();
	pc.addCopiedTable("detailHeader");
	lCounter+=5;
	}
	pc.setNoColumnFixWidth(setDetail1);
	pc.setFont(7, 0);
	pc.createTable();
		pc.addCols(""+cdo.getColValue("familia"),1,1,cHeight);
		pc.addCols(""+cdo.getColValue("clase"),1,1,cHeight);
		pc.addCols(""+cdo.getColValue("articulo"),1,1,cHeight);
		pc.addCols(""+cdo.getColValue("descripcion"),0,1,cHeight);
		pc.addCols(""+cdo.getColValue("devuelto"),1,1,cHeight);
		pc.addCols(""+cdo.getColValue("recibido"),1,1,cHeight);
	pc.addTable();
	lCounter++;

	if (lCounter >= maxLines &&(((pCounter -1)* maxLines)+lCounter < nItems))
	{
		lCounter = lCounter - maxLines;
		pCounter++;
		pc.addNewPage();

		pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","SOLICITUD DE DEVOLUCION DE MATERIALES PARA PACIENTE", userName, fecha);

		pc.setNoColumnFixWidth(setDetail);
		pc.addCopiedTable("detailHeader");
	}
	groupBy	= cdo.getColValue("pacId");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>