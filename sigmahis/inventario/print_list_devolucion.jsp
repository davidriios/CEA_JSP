<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");

if (fg==null) fg = "";
if (appendFilter==null) appendFilter = "";

String sql = "";

if(fg.equals("DM")||fg.equals("DMA") ||fg.equals("CDM") ){
    sql="SELECT dp.anio anio_devolucion, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, dp.monto, dp.estado, decode(dp.estado,'T','TRAMITE','P','PENDIENTE','R','RECIBIDO') desc_estado,dp.pac_id, dp.adm_secuencia, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as devuelve FROM tbl_inv_devolucion_pac dp, tbl_adm_paciente p ,tbl_adm_admision adm  ,tbl_cds_centro_servicio cs  where dp.compania = "+ (String) session.getAttribute("_companyId") +appendFilter+" and dp.compania = adm.compania  and dp.pac_id = p.pac_id  and (dp.pac_id = adm.pac_id and dp.adm_secuencia = adm.secuencia) and (adm.pac_id= p.pac_id) /* and dp.estado = 'T'*/ and cs.codigo = dp.sala_cod order by  dp.anio desc,dp.num_devolucion desc";
} else if(fg.equals("DP")||fg.equals("DPA")){
    sql = "select dp.anio as anio_devolucion, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, dp.monto,dp.cod_provedor,p.nombre_proveedor as devuelve, decode(dp.tipo_dev,'C','DEV. CONSIGNACION','N','DEV. NORMAL','R','RETIRO (NOTA DE ENTREGA)') as desc_estado FROM tbl_inv_devolucion_prov dp ,tbl_com_proveedor p where dp.compania = "+session.getAttribute("_companyId")+" and dp.cod_provedor= p.cod_provedor(+)"+ appendFilter+" order by dp.anio,dp.num_devolucion desc";
} else {
    sql="SELECT d.anio_devolucion, d.num_devolucion, d.compania, to_char(d.fecha_devolucion,'dd/mm/yyyy') as fecha_devolucion, d.observacion, d.monto, d.estado, decode(d.estado,'A','ANULADO','R','RECIBIDO','','DEVUELTO') as desc_estado, en.anio,en.no_entrega,sr.tipo_transferencia ,decode(sr.tipo_transferencia,'U',decode(sr.codigo_almacen,5,al.descripcion,ue.descripcion),'A',al.descripcion,ue.descripcion) devuelve ,d.codigo_almacen, d.cod_ref  FROM tbl_inv_devolucion d, tbl_inv_entrega_material en, tbl_inv_solicitud_req sr,tbl_sec_unidad_ejec ue ,tbl_inv_almacen al  where d.compania = "+(String) session.getAttribute("_companyId")+" and d.anio_entrega = en.anio(+) and d.no_entrega = en.no_entrega(+) and d.compania_dev = en.compania (+) and en.req_anio = sr.anio(+) and en.req_tipo_solicitud = sr.tipo_solicitud(+) and en.req_solicitud_no = sr.solicitud_no(+) and en.compania_sol = sr.compania(+) and sr.compania = d.compania and al.compania = d.compania and d.codigo_almacen = al.codigo_almacen and ue.codigo(+) = d.unidad_administrativa and ue.compania(+) = d.compania "+appendFilter+" order by d.anio_devolucion desc ";
}

System.out.println("\n\n ddddddddddddddddddsql="+sql+"\n\n");
al = SQLMgr.getDataList(sql);

String titulo = "";
if (fg.equals("UA")){
   titulo = "DEVOLUCIÓN - MATERIALES DE UNIDADES ADM.";
}else if(fg.equals("SM")){
   titulo = "DEVOLUCIÓN - MATERIALES PARA SERVICIOS DE MANTE.";
}else if(fg.equals("EA")){
   titulo = "DEVOLUCIÓN - MATERIALES ENTRE ALMACENES";
}else if(fg.equals("DM")||fg.equals("DMA")){
   titulo = "DEVOLUCIÓN - MATERIALES PARA PACIENTES";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "INVENTARIO";
	String subtitle = titulo;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblDet = new Vector();
		tblDet.addElement(".07");
        tblDet.addElement(".15");
        
        tblDet.addElement(".13");
        
        tblDet.addElement(".30");
        tblDet.addElement(".20");
        tblDet.addElement(".15");

	pc.setNoColumnFixWidth(tblDet);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, tblDet.size());
	pc.setTableHeader(2);
    
    pc.addBorderCols("Año",1,1);
    pc.addBorderCols("No. Recepción",0,1);
    pc.addBorderCols("Cód.Ref.",1,1);
    pc.addBorderCols("Devolución ",0,1);
    pc.addBorderCols("Estado",1,1);
    pc.addBorderCols("Fecha Doc.",1,1);
    
    for (int i=0; i<al.size(); i++){
        CommonDataObject cdo1 = (CommonDataObject) al.get(i);
        pc.setFont(7, 0);
        pc.addCols(" "+cdo1.getColValue("anio_devolucion"),1,1);
        pc.addCols(" "+cdo1.getColValue("num_devolucion"),0,1);
        pc.addCols(" "+cdo1.getColValue("cod_ref",""),1,1);
        pc.addCols(" "+cdo1.getColValue("devuelve"),0,1);
        pc.addCols(" "+cdo1.getColValue("desc_estado"),1,1);
        pc.addCols(" "+cdo1.getColValue("fecha_devolucion"),1,1);						
	}//End For
    
	if (al.size() == 0) pc.addCols("No existen registros",1,tblDet.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>