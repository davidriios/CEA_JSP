<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="java.util.ArrayList" %>
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

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
Company com= new Company ();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String estadoPaquete = "";  //variable que guarda el estado del Paquete A=activo I=inactivo
String fg = request.getParameter("fg");
if(fg==null) fg ="";

if (appendFilter == null) appendFilter = "";

if(fg != null && fg.trim().equals("RSP")){
	if(appendFilter != null && !appendFilter.trim().equals(""))
	sql = "select distinct a.compania, a.anio, a.solicitud_no, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado, a.paciente, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia,a.pac_id, a.centro_servicio ||' '|| d.descripcion area_desc,a.usuario_creacion FROM tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d,tbl_inv_d_sol_pac ds  where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo and a.estado in ('T','A') and a.solicitud_no = ds.solicitud_no and a.anio=ds.anio and a.compania =ds.compania and ds.estado_renglon = 'P'  and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter;
	sql += " union all select distinct a.compania, a.anio, a.solicitud_no, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado, a.paciente, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia,a.pac_id, a.centro_servicio ||' '|| d.descripcion area_desc,a.usuario_creacion FROM tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d  where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo and a.estado in ('T','A') and not exists(select null from tbl_inv_d_sol_pac ds where a.solicitud_no = ds.solicitud_no and a.anio=ds.anio and a.compania =ds.compania )	and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter;
	
	sql += " order by 2 desc, 3 desc  ";
}else
sql= "select a.*, to_char(a.fecha_docto, 'dd/mm/yyyy') fecha_documento, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento from (select a.codigo_almacen ,a.centro_servicio, a.compania, a.anio, a.solicitud_no, a.fecha_documento fecha_docto, a.estado, DECODE(a.estado,'A','APROBADO','P','PENDIENTE','R','RECHAZADO','N','ANULADO','T','TRAMITE','E','ENTREGADO') desc_estado, a.paciente, a.fecha_nacimiento fecha_nac, a.codigo_almacen || ' ' || b.descripcion almacen_desc, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_paciente, a.adm_secuencia, a.centro_servicio ||' '|| d.descripcion area_desc,a.usuario_creacion ,(select case when sum(spd.cantidad) > sum(de.cantidad_entregada) then '*' end from tbl_inv_detalle_entrega de, tbl_inv_entrega_material em, tbl_inv_d_sol_pac spd where de.anio = em.anio and de.no_entrega = em.no_entrega and de.compania = em.compania and em.pac_anio = a.anio and em.pac_solicitud_no = a.solicitud_no and em.compania = a.compania and a.anio = spd.anio and a.solicitud_no = spd.solicitud_no and a.compania = spd.compania) as parcial FROM tbl_inv_solicitud_pac a, tbl_inv_almacen b, tbl_adm_paciente c, tbl_cds_centro_servicio d where a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.pac_id = c.pac_id and a.centro_servicio = d.codigo order by a.fecha_creacion desc) a where compania = "+(String) session.getAttribute("_companyId")+appendFilter;
if(sql != null && !sql.trim().equals(""))
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 40; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;

	String folderName = "inventario";
		String fileNamePrefix = "print_list_sol_mat_pac";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+System.currentTimeMillis()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = true;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".05");
		setDetail.addElement(".07");
		setDetail.addElement(".08");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".30");
		setDetail.addElement(".23");
		setDetail.addElement(".23");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "REQUISICIÓN - MATERIALES Y MED. PARA PACIENTES ", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("", 0,4);
	pc.addTable();

	pc.createTable();
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No. Solicitud",1);
		pc.addBorderCols("Fecha Doc.",1);
		pc.addBorderCols("Cód. Paciente",0);
		pc.addBorderCols("Fecha Nac.",0);
		pc.addBorderCols("Nombre Pac.",1);
		pc.addBorderCols("Almacén",1);
		pc.addBorderCols("Área",1);
	pc.addTable();
	pc.copyTable("detailHeader");


	for (int i=0; i<al.size(); i++)
	{
		 CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(cdo1.getColValue("parcial")+" "+cdo1.getColValue("anio"),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("solicitud_no"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("fecha_documento"),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("paciente"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("fecha_nacimiento"),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("nombre_paciente"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("almacen_desc"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("area_desc"),0,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "REQUISICIÓN - MATERIALES Y MED. PARA PACIENTES", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
			//groupBy = "";//if this segment is uncommented then reset lCounter to 0 instead of the printed extra line (lCounter -  maxLines)
		}
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		pc.createTable();
			pc.addCols(al.size()+" Registros en total",0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>