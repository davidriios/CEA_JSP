<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
String userName = UserDet.getUserName();

	sbSql.append("select a.enviado, decode(a.enviado, 'S', 'SI', 'N0') enviado_desc, to_char(a.fecha_recibido, 'dd/mm/yyyy') fecha_recibido, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_modificacion, to_char(a.system_date, 'dd/mm/yyyy') system_date, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_creacion, a.enviado_por, a.comentario, a.lista, a.aseguradora, (select nombre from tbl_adm_empresa e where e.codigo = a.aseguradora) aseguradora_desc, to_char(a.fecha_envio, 'dd/mm/yyyy') fecha_envio, a.compania, a.id, a.estado, to_char(a.fecha_recibido, 'dd/mm/yyyy') as fecha_recibido, get_sec_comp_param(a.compania,'FAC_SHOW_MONTO_GLOBAL') as show_monto_gloabl, get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'LISTA_ENVIO_MOSTRAR_FACT_ANULADA') show_fac_del from tbl_fac_lista_envio a where a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.id = ");
	sbSql.append(id);
	cdo = SQLMgr.getData(sbSql.toString());
    
    boolean showMontoGlobal = ((cdo.getColValue("show_monto_gloabl","N")).equals("S") || (cdo.getColValue("show_monto_gloabl","N")).equals("Y"));

	sbSql = new StringBuffer();
    
	sbSql.append("select estado, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, factura, lista, lista_old, categoria, aseguradora, facturar_a, compania, secuencia, id, (select descripcion from tbl_adm_categoria_admision ca where ca.codigo = a.categoria) categoria_nombre, a.nombre_paciente, nvl(a.monto,0) as monto, a.pac_id||' - '||a.admision as id_paciente, (select poliza from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admision and empresa = a.aseguradora and estado = 'A' and rownum = 1) as poliza, (select certificado from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admision and empresa = a.aseguradora and estado = 'A' and rownum = 1) as certificado ");
	
	if (showMontoGlobal){
    sbSql.append(", nvl( (select nvl(f.grang_total,0) + nvl(f.monto_descuento2,0) + case when trunc(f.fecha) >= to_date('13/06/2012','dd/mm/yyyy') then nvl(f.monto_descuento,0) - nvl(f.total_honorarios,0) - decode(f.nueva_formula,'S',0,nvl(getCopagoDet(f.compania,a.factura,null,null,f.pac_id,f.admi_secuencia,'FTOT'),0)) else nvl(-f.monto_descuento,0) end - nvl((select sum(monto) from tbl_fac_detalle_factura where compania = f.compania and fac_codigo = f.codigo and imprimir_sino = 'S' and centro_servicio = (select get_sec_comp_param(a.compania,'CDS_PAQ_PER') from dual)   ),0) from tbl_fac_factura f where f.facturar_a = 'P' and f.estatus <> 'A' and f.admi_secuencia = a.admision and f.pac_id = a.pac_id and f.compania = a.compania),0) - decode( nvl( (select aplica_copago from tbl_adm_beneficios_acum where pac_id = a.pac_id AND admision = a.admision and rownum = 1),'E') ,'A' , (nvl( (select sum(decode(tipo,'COP',monto,0)) as  monto_copago from tbl_fac_estado_cargos_det where pac_id = a.pac_id and admi_secuencia = a.admision and monto > 0),0)),0) pago_pte ");
    }else{
      sbSql.append(", (select to_char(fecha_ingreso,'dd/mm/yyyy') from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admision ) as fecha_ingreso , (select to_char(fecha_egreso,'dd/mm/yyyy') from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admision ) as fecha_egreso ");
    }
	
	sbSql.append(", decode(estado, 'A', 'Activa', 'I', 'Inactiva') estado_desc from tbl_fac_lista_envio_det a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.id = ");
	sbSql.append(id);
	if(cdo.getColValue("show_fac_del").equals("N")) sbSql.append(" and a.estado != 'I'");
	else {
		if(cdo.getColValue("enviado").equals("N")) sbSql.append(" and a.estado != 'I'");
	}
	al = SQLMgr.getDataList(sbSql.toString());

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "LISTA DE ENVIO";
	String subtitle = cdo.getColValue("aseguradora_desc");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	int footerFontSize = 7;
	
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin * 2);
	footer.setFont(footerFontSize,0);
	footer.setNoColumn(3);
	footer.createTable();
		footer.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		footer.addCols("",0,1);
		footer.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		
		footer.addCols("Preparado por",1,1);
		footer.addCols("",1,1);
		footer.addCols("Autorizado por",1,1);

		//footerHeight = footer.getTableHeight();

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".05");
	dHeader.addElement(".15");
	dHeader.addElement(".60");
	dHeader.addElement(".05");
	dHeader.addElement(".10");

	Vector dDetail = new Vector();
	dDetail.addElement(".06");
	dDetail.addElement(".06");
	dDetail.addElement(".19");
	
	dDetail.addElement(".06"); // Monto
	
	dDetail.addElement(".07"); // Monto Paciente / Fecha Ingreso
	dDetail.addElement(".07"); // Monto Global / Fecha Egreso

	dDetail.addElement(".08");
	dDetail.addElement(".08");
	dDetail.addElement(".06");
	dDetail.addElement(".07");
	dDetail.addElement(".06");
	dDetail.addElement(".14");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable("header");

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Id:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("id"),0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Aseguradora:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("aseguradora_desc"),0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha_creacion"),0,1,0.0f,0.5f,0.0f,0.0f);

		pc.addBorderCols("Lista:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("lista"),0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Enviado:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("enviado_desc"),0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Fecha Envio:",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("fecha_envio"),0,1,0.0f,0.0f,0.0f,0.0f);

		pc.addBorderCols("Comentario:",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("comentario"),0,2,0.5f,0.0f,0.0f,0.0f);
		
		pc.addBorderCols("F. Recibido: "+cdo.getColValue("fecha_recibido"),0,2,0.5f,0.0f,0.0f,0.0f);

	//table header
	pc.setNoColumnFixWidth(dDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetail.size());
		pc.addTableToCols("header", 1, dDetail.size());
		//second row
		pc.setFont(8, 1);
		pc.setNoColumnFixWidth(dDetail);
		pc.addBorderCols("Factura",1,1);
		pc.addBorderCols("Admisión",1,1);
		pc.addBorderCols("Paciente",1,1);
		pc.addBorderCols("Monto Aseg.",1,1);
        
		pc.addBorderCols(!showMontoGlobal?"F.Ingreso":"Monto Paciente",1,1);
		pc.addBorderCols(!showMontoGlobal?"F.Egreso":"Monto Global",1,1);
        
		pc.addBorderCols("Póliza",1,1);
		pc.addBorderCols("Certificado",1,1);
		pc.addBorderCols("Usuario Crea.",1,1);
		pc.addBorderCols("Fecha Crea.",1,1);
		pc.addBorderCols("Estado",1,1);
		pc.addBorderCols("Categoría Admisión",1,1);

		pc.setTableHeader(3);//create de table header (2 rows) and add header to the table


	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	
	double montoTot = 0.0, montoPac = 0.0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cd = (CommonDataObject) al.get(i);
		System.out.println("i="+i);
		pc.addCols(cd.getColValue("factura"),1,1);
		pc.addCols(cd.getColValue("id_paciente"),0,1);
		pc.addCols(cd.getColValue("nombre_paciente"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cd.getColValue("monto")),2,1);
        
        if (showMontoGlobal){
		  pc.addCols(CmnMgr.getFormattedDecimal(cd.getColValue("pago_pte")),2,1);
		  pc.addCols(CmnMgr.getFormattedDecimal( Double.parseDouble(cd.getColValue("monto")) + Double.parseDouble(cd.getColValue("pago_pte")) ),2,1);
        }else{
          pc.addCols(cd.getColValue("fecha_ingreso"),2,1);
		  pc.addCols(cd.getColValue("fecha_egreso"),2,1);
        }
        
		pc.addCols(cd.getColValue("poliza"),1,1);
		pc.addCols(cd.getColValue("certificado"),1,1);
		pc.addCols(cd.getColValue("usuario_creacion"),1,1);
		pc.addCols(cd.getColValue("fecha_creacion"),1,1);
		pc.addCols(cd.getColValue("estado_desc"),1,1);
		pc.addCols(cd.getColValue("categoria_nombre"),1,1);
		
		montoTot += Double.parseDouble(cd.getColValue("monto"));
        if(showMontoGlobal && !cd.getColValue("estado").equals("I")){
		montoPac += Double.parseDouble(cd.getColValue("pago_pte"));
		}
	}
	//pc.flushTableBody(true);
	
	pc.setFont(8, 1);
	pc.addCols("Monto Total",2,3);
	pc.addCols(CmnMgr.getFormattedDecimal(""+montoTot),2,1);
    if (showMontoGlobal){
	pc.addCols(CmnMgr.getFormattedDecimal(""+montoPac),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(""+(montoTot+montoPac)),2,1);
    }else{
      pc.addCols("",2,1);
	  pc.addCols("",2,1);
    }
	
	pc.addCols("",2,6);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>