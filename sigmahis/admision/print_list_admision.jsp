<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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
CommonDataObject cdo1 = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String dobleCob = request.getParameter("dobleCob");

if (appendFilter == null) appendFilter = "";
if (dobleCob == null) dobleCob = "";
if (fp == null) fp = "";

sbSql = new StringBuffer();
sbSql.append("select nvl(a.fecha_ingreso,a.fecha_creacion) as sort_date, to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, /*to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy')*/nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, b.id_paciente as pasaporte, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte) as cedulaPamd, a.compania, a.pac_id as pacId, b.nombre_paciente as nombrePaciente, (select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria) as categoriaDesc, a.centro_servicio as centroServicio, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as centroServicioDesc, (select cds from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1) as area/*es el cds para expediente*/, nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.adm_root and rownum = 1),' ') as cama, nvl((select estado from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1),'X') as status, a.medico, a.conta_cred as contaCred, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as key ,nvl((select y.nombre from tbl_adm_beneficios_x_admision be,tbl_adm_empresa y where be.pac_id=a.pac_id and be.admision=a.secuencia and be.prioridad=1 and nvl(be.estado,'A')='A' and be.empresa=y.codigo and rownum = 1),' ') as nombreEmpresa, nvl((select poliza from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and nvl(estado,'A') = 'A' and rownum = 1),' ') as poliza, nvl((select certificado from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and nvl(estado,'A') = 'A' and rownum = 1),' ') as certificado, nvl(to_char(a.am_pm,'hh12:mi am'),' ') as amPm, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, nvl(a.motivo_Anulacion,' ') as motivoAnulacion, nvl(a.usuario_anulacion,' ') as usuarioAnulacion, nvl(to_char(a.fecha_anulacion,'dd/mm/yyyy hh12:mi:ss am'),' ') as fechaAnulacion ");
sbSql.append(" from tbl_adm_admision a, vw_adm_paciente b");
sbSql.append(" where a.pac_id = b.pac_id and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(appendFilter);
sbSql.append(" order by 1 desc, 14 asc, 4");
System.out.println("SQL====="+sbSql.toString());
al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "LISTADO DE ADMISIONES"+((!dobleCob.trim().equals(""))?" DOBLE COBERTURA":" ");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector setDetail = new Vector();
		setDetail.addElement(".20");
		setDetail.addElement(".04");
		setDetail.addElement(".055");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".20");
		setDetail.addElement(".055");
		setDetail.addElement(".055");
		setDetail.addElement(".04");
		setDetail.addElement(".16");
		setDetail.addElement(".115");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Centro que Admite",1);
		pc.addBorderCols("Cat.",1);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Pac. ID",1);
		pc.addBorderCols("Adm.",1);
		pc.addBorderCols("Nombre Paciente",1);
		pc.addBorderCols("Fecha Ingreso",1);
		pc.addBorderCols("Fecha Egreso",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Aseguradora",1);
		pc.addBorderCols("Póliza/Cert.",1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

	for (int i=0; i<al.size(); i++)
	{
		Admision adm = (Admision) al.get(i);

		pc.setFont(7, 0);
						pc.addCols(" "+adm.getCentroServicioDesc(),0,1);
			pc.addCols(adm.getCategoriaDesc(),1,1,cHeight);
			pc.addCols(adm.getFechaNacimiento(),1,1,cHeight);
			pc.addCols(adm.getPacId(),1,1,cHeight);
			pc.addCols(adm.getNoAdmision(),1,1,cHeight);
			pc.addCols(adm.getNombrePaciente(),0,1);
			pc.addCols(adm.getFechaIngreso()+(fp.equalsIgnoreCase("CUSTOM")?" "+adm.getAmPm():""),1,1);
			pc.addCols(adm.getFechaEgreso()+(fp.equalsIgnoreCase("CUSTOM")?" "+adm.getAmPm2():""),1,1);
			pc.addCols(adm.getEstado(),1,1,cHeight);

			//pc.addCols(" ",0,1);
			/*pc.setFont(3, 0);
			pc.addCols(" A ",0,setDetail.size());
			pc.setFont(7, 0);*/
			pc.addCols(adm.getNombreEmpresa(),0,1,cHeight);
			pc.addCols(adm.getPoliza()+"/"+adm.getCertificado(),0,1,cHeight);
			/*pc.setFont(3, 0);
			pc.addCols(" ",0,setDetail.size());*/

		if (adm.getEstado().equalsIgnoreCase("N")) {
			pc.addCols("ANULADO POR: "+adm.getUsuarioAnulacion()+" "+adm.getFechaAnulacion(),2,4);
			pc.addCols("",0,1);
			pc.addCols("MOTIVO: "+adm.getMotivoAnulacion(),0,6);
		}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{
			pc.addCols(al.size()+" Registros en total ",0,setDetail.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>