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
CommonDataObject cdoHeader = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");
String anio = request.getParameter("anio");
String id = request.getParameter("id");
String anioEntrega = request.getParameter("anioEntrega");
String codigo = request.getParameter("codigo");
String pac_id = request.getParameter("pac_id");
String admi_secuencia = request.getParameter("adm_secuencia");
if(id== null) id = "";
if(anio== null) anio = "";
if(codigo== null) codigo = "_____________";
if(anioEntrega== null) anioEntrega = "";
if (appendFilter == null) appendFilter = "";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select d.compania, d.renglon, d.cod_familia, d.cod_clase, decode(d.tipo, 'I', d.cod_articulo, 'U', d.cod_uso) cod_articulo, d.cod_uso, d.tipo, d.cantidad_uso cantidad, d.cantidad_uso entregas, 0 pendiente, d.precio, d.costo, d.estado, d.anio, d.dev, d.articulo_desc desc_articulo, d.devolver, d.devolver_todo, d.devuelto, d.transito, d.cantidad2, d.cod_paciente, d.secuencia, d.pac_id, 'USO' unidad_medida_desc from TBL_SAL_TRANSACC_DET_DEV d where d.compania = ");
sbSql.append(compania);
sbSql.append(" and dev = ");
sbSql.append(id);
sbSql.append(" and pac_id = ");
sbSql.append(pac_id);
sbSql.append(" and secuencia = ");
sbSql.append(admi_secuencia);
al = SQLMgr.getDataList(sbSql.toString());
sbSql = new StringBuffer();
sbSql.append("select compania, fec_nacimiento, cod_paciente, secuencia, centro_servicio, codigo_almacen, anio, estado, dev, tipo, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modifica, fecha_modifica, pac_id, (select p.nombre_paciente from vw_adm_paciente p where p.pac_id = d.pac_id) paciente, d.pac_id||'-'||d.secuencia llave_pac,(select descripcion from tbl_cds_centro_servicio where codigo = d.centro_servicio) desc_sala, nvl((select 'Cama: '||habitacion||' ('||cama||')' from tbl_adm_atencion_cu where pac_id=d.pac_id and secuencia =d.secuencia ),'No tiene habitacion') cama, ' ' observacion from TBL_SAL_TRANSACC_DEV d where compania = ");
sbSql.append(compania);
sbSql.append(" and dev = ");
sbSql.append(id);
sbSql.append(" and pac_id = ");
sbSql.append(pac_id);
sbSql.append(" and secuencia = ");
sbSql.append(admi_secuencia);
cdoHeader = SQLMgr.getData(sbSql.toString());
System.out.println("...........sql"+sbSql.toString());

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
	String title = "INVENTARIO";
	String subtitle = "SOLICITUD DE MATERIALES PARA PACIENTES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".12");
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".13");
		setDetail.addElement(".08");
		setDetail.addElement(".09");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());
		
		
		pc.setFont(9, 1,Color.blue);
		pc.addCols("Paciente",0,1);
		pc.addCols(cdoHeader.getColValue("paciente"),0,3);
		pc.addCols(cdoHeader.getColValue("llave_pac"),0,4);
		
		pc.addCols("Sala: "+cdoHeader.getColValue("desc_sala"),0,4);
		pc.setFont(9, 1,Color.red);
		pc.addCols(" "+cdoHeader.getColValue("cama"),0,4);
		
		pc.setFont(9, 1,Color.blue);		
		pc.addCols("Solicitud # :",0,1);
		pc.addCols(""+codigo,0,1);
		pc.addCols("Cargo/Devolucion # :"+id,0,3);
		pc.addCols("Fecha:   "+cdoHeader.getColValue("fecha_creacion"),0,3);
		
		
		pc.addCols("Observacion: "+cdoHeader.getColValue("observacion"),0,setDetail.size());
		pc.setFont(7, 1);
					
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0,2);
		pc.addBorderCols("UNIDAD MED.",1);
		pc.addBorderCols("PEDIDO",1);
		pc.addBorderCols("ENTREGADO",1);
		pc.addBorderCols("PENDIENTE",1);
		pc.addBorderCols("RECIBIDO",1);
		pc.setTableHeader(5);//create de table header
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (i == 0)
			{
					
			}

			pc.setFont(9, 0);
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,2);
			pc.addCols(""+cdo.getColValue("unidad_medida_desc"),0,1);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("entregas")),1,1);
			pc.addCols(""+cdo.getColValue("pendiente"),1,1);
			pc.addCols("___________________",1,1,cHeight);
	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,setDetail.size());
	}
	

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>