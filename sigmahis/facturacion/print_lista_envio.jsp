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
Reporte FAC70596.rdf
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
ArrayList al2= new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String fg=request.getParameter("fg");
String empresa=request.getParameter("empresa");
String fechaEnvio=request.getParameter("fecha");
String lista=request.getParameter("lista");
String categoria=request.getParameter("categoria");
String facturar=request.getParameter("tipo");
String existe=request.getParameter("existe");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";


sql = "select decode('"+fg+"','FAC','FACTURACION','') departamento,(select descripcion from tbl_adm_categoria_admision where codigo = "+categoria+") descCategoria,(select nombre from tbl_adm_empresa where codigo ="+empresa+") descEmpresa,nvl((select comentario from sfclinico.fac_lista where compania    = "+compania+" and to_date(to_char(fecha_envio,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEnvio+"','dd/mm/yyyy') and aseguradora = "+empresa+" and categoria   = "+categoria+" and lista = "+lista+" ),'') comentario from dual ";
cdo1 = SQLMgr.getData(sql);


if (!categoria.trim().equals("1"))appendFilter +=" and  b.categoria = "+categoria;//
else appendFilter +=" and  b.categoria in(1,5) ";


sql = " select a.codigo factura, to_char(a.fecha,'dd/mm/yyyy') fecha_factura,to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') fnac,a.admi_codigo_paciente codpac, a.admi_secuencia admision,to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy')||'-'||a.admi_codigo_paciente||'-'||a.admi_secuencia  cod_paciente,nvl(a.grang_total,0) totalfactura, a.cod_empresa aseguradora,b.centro_servicio centro,(select descripcion from tbl_adm_categoria_admision where codigo = b.categoria) descCategoria , b.dias_hospitalizados, to_char(b.fecha_egreso,'dd/mm/yyyy') fecha_egreso, to_char(b.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, (select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' '||apellido_de_casada nombre from tbl_adm_paciente where pac_id = b.pac_id ) nombre_paciente ,c.certificado,c.poliza,(select descripcion from tbl_cds_centro_servicio where codigo = b.centro_servicio) descCentro from tbl_fac_factura a,tbl_adm_admision b,(select pac_id,admision, certificado,poliza ,min(prioridad) from tbl_adm_beneficios_x_admision where empresa = "+empresa+" group by pac_id,admision, certificado,poliza )c where ((a.facturar_a = '"+facturar+"' or a.cod_empresa in (81,94,95,96,99,120)) and a.estatus in ('P','C') and a.fecha= to_date('"+fechaEnvio+"','dd/mm/yyyy')) and a.cod_empresa = "+empresa+" and a.lista = "+lista+" and (a.pac_id = b.pac_id and  a.admi_secuencia = b.secuencia)   and c.pac_id(+) = b.pac_id and c.admision(+)=b.secuencia order by a.cod_empresa,b.categoria,b.centro_servicio,   a.fecha asc";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "FACTURACIÓN";
	String subtitle = "LISTA DE ENVIO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".30");
		dHeader.addElement(".15");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".05");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
	

		
		

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,null);

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

		pc.setVAlignment(0);
		pc.setNoColumnFixWidth(dHeader);
		//pc.createTable("header1",true,0,0);
		pc.createTable("header1",true,0,0.0f,pc.getWidth() - (pc.getLeftRightMargin() * 2));
			
		pc.setFont(fontSize, 1);
		pc.addBorderCols("ASEGURADO O DEPENDIENTE",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("CODIGO PACIENTE",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("F. INGRESO",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("F. EGRESO",1,1,Color.LIGHT_GRAY,null);

		pc.addBorderCols("DIAS",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("POLIZA",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("CERT.",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("FACTURA",1,1,Color.LIGHT_GRAY,null);
		pc.addBorderCols("TOTAL",1,1,Color.LIGHT_GRAY,null);
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.addCols("DEPARTAMENTO:    "+cdo1.getColValue("departamento"),0,2,cHeight);
		pc.addCols("LISTA NO.:       "+lista,0,7,cHeight);
		
		pc.addCols("COMPAÑIA:    "+cdo1.getColValue("descEmpresa"),0,2,cHeight);
		pc.addCols("CATEGORIA.:       "+cdo1.getColValue("descCategoria"),0,7,cHeight);
		
		pc.setTableHeader(3);//create de table header (1 rows) and add header to the table
		
		
		

	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	int totalPacCentro =0;
	int totalPac =0;
	double montoPacCentro =0.0,montoTotal =0.0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("centro")/*+'-'+cdo.getColValue("centro")*/))
			{
				pc.setFont(fontSize, 1);
				pc.addBorderCols("CENTRO:  "+cdo.getColValue("descCentro"),1,dHeader.size(),0.5f,0.5f,0.5f,0.5f);
				pc.addTableToCols("header1",0,dHeader.size());
				//pc.addCols(" no_hemodialisis: "+ cdo.getColValue("no_hemodialisis"),0,dHeader.size(),cHeight);
				
				if(i != 0)
				{
					pc.addBorderCols("T. PACIENTES POR CENTRO:         "+totalPacCentro,1,2,0.5f,0.5f,0.5f,0.5f);
					pc.addBorderCols("TOTAL:         "+montoPacCentro,2,7,0.5f,0.5f,0.5f,0.5f);
					totalPacCentro=0;
					montoPacCentro=0;
				}
			}// groupBy2
		montoPacCentro +=  Double.parseDouble(cdo.getColValue("totalFactura"));
		totalPacCentro ++;
		montoTotal +=  Double.parseDouble(cdo.getColValue("totalFactura"));
		totalPac ++;
		pc.setFont(fontSize,0);
		pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(cdo.getColValue("cod_paciente"),1,1);
		pc.addCols(cdo.getColValue("fecha_ingreso"),1,1);
		pc.addCols(cdo.getColValue("fecha_egreso"),1,1);
		pc.addCols(cdo.getColValue("dias_hospitalizados"),1,1);
		pc.addCols(cdo.getColValue("poliza"),2,1);
		pc.addCols(cdo.getColValue("certificado"),2,1);
		pc.addCols(cdo.getColValue("factura"),2,1);
		pc.addCols(cdo.getColValue("totalFactura"),2,1);		

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("centro");
	}
	
	pc.setFont(fontSize,1);
	pc.addCols("T. PACIENTES POR CENTRO:            "+totalPacCentro,1,2,cHeight,Color.LIGHT_GRAY); 

	pc.addCols("TOTAL:         "+montoPacCentro,2,7,cHeight,Color.LIGHT_GRAY);
	
	pc.setFont(3,1);
	pc.addCols(" ",1,dHeader.size());
	pc.setFont(fontSize,1);
	pc.addCols("GRAN TOTAL DE PACIENTES:            "+totalPac,1,2,cHeight,Color.LIGHT_GRAY);
	pc.addCols("TOTAL:         "+montoTotal,2,7,cHeight,Color.LIGHT_GRAY);
	
	pc.setFont(fontSize,1);
	pc.addCols("OBSERVACIONES",0,dHeader.size());
	pc.setFont(fontSize,0);
	pc.addBorderCols(" "+cdo1.getColValue("comentario"),0,dHeader.size(),0.5f,0.5f,0.5f,0.5f);
	
	pc.addCols(" ",1,dHeader.size());
	pc.addBorderCols(" ",1,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Enviado por: ",0,2,0.0f,0.0f,0.5f,0.0f);
	pc.addBorderCols("Recibido por: ",0,2,0.0f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,4,0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f);
	
	pc.addBorderCols("Fecha de Envío : "+fechaEnvio,0,2,0.0f,0.0f,0.5f,0.0f);
	pc.addBorderCols("Fecha de Recibido : ",0,7,0.0f,0.0f,0.0f,0.5f);
	//pc.addBorderCols(" ",0,6,0.5f,0.0f,0.0f,0.5f);
	
	pc.addBorderCols(" ",1,dHeader.size(),0.5f,0.0f,0.5f,0.5f);
	//pc.addBorderCols(" ",1,dHeader.size(),0.0f,0.5f,0.5f,0.5f);

	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>