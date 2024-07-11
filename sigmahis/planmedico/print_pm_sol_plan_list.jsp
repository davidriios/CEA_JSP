<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fechaIniPlanFrom = (request.getParameter("fechaIniPlanFrom")==null?"":request.getParameter("fechaIniPlanFrom"));
String fechaIniPlanTo = (request.getParameter("fechaIniPlanTo")==null?"":request.getParameter("fechaIniPlanTo"));
String afiliados = (request.getParameter("afiliados")==null?"":request.getParameter("afiliados"));
String estado = (request.getParameter("estado")==null?"":request.getParameter("estado"));
String cuotaMensual = (request.getParameter("cuotaMensual")==null?"":request.getParameter("cuotaMensual"));
String cmOper = (request.getParameter("cmOper")==null?"":request.getParameter("cmOper"));

StringBuffer sbSql = new StringBuffer();

sbSql.append("select estado, id, id_cliente, cobertura_mi, cobertura_cy, cobertura_hi, cobertura_ot, afiliados, forma_pago, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, cuota_mensual, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, observacion, decode(estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo') estado_desc, (select b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre) || ' ' || b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) from tbl_pm_cliente b where b.codigo = a.id_cliente) responsable, (select descripcion from tbl_pm_afiliado c where id = a.afiliados) afiliados_desc, to_char(a.fecha_fin_plan, 'dd/mm/yyyy') fecha_fin_plan from tbl_pm_solicitud_contrato a where 1=1 ");
	if(!fechaIniPlanFrom.equals("")){
		sbSql.append(" and fecha_ini_plan >= to_date('");
		sbSql.append(fechaIniPlanFrom);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fechaIniPlanTo.equals("")){
		sbSql.append(" and fecha_ini_plan <= to_date('");
		sbSql.append(fechaIniPlanTo);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!afiliados.equals("")){
		sbSql.append(" and afiliados = ");
		sbSql.append(afiliados);
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!cuotaMensual.equals("")){
		sbSql.append(" and cuota_mensual ");
		sbSql.append(cmOper);
		sbSql.append(cuotaMensual);
	}
	sbSql.append(" order by id");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

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
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "LISTADO DE SOLICITUD DE PLAN";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".07"); //Código
	tblContent.addElement(".30"); //Nombre
	tblContent.addElement(".15"); //Plan
	tblContent.addElement(".16"); //Cuota Mensual
	tblContent.addElement(".12"); //Estado
	tblContent.addElement(".10"); //Estado
	tblContent.addElement(".10"); //Estado


	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addCols(" ", 0,tblContent.size());

	pc.addBorderCols("Código",1,1);
	pc.addBorderCols("Nombre Responsable",0,1);
	pc.addBorderCols("Plan",1,1);
	pc.addBorderCols("Cuota Mensual",2,1);
	pc.addBorderCols("Estado",1,1);
	pc.addBorderCols("Fecha Ini.",1,1);
	pc.addBorderCols("Fecha Fin",1,1);

	pc.setTableHeader(3);

	if (al.size()==0) {
		pc.addCols("No existen datos a cerca de planes!",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);

        pc.setFont(7, 0);
        pc.addCols(cdo1.getColValue("id"),1,1);
        pc.addCols(cdo1.getColValue("responsable"),0,1);
        pc.addCols(cdo1.getColValue("afiliados_desc"),1,1) ;
        pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("cuota_mensual")),2,1) ;
        pc.addCols(cdo1.getColValue("estado_desc"),1,1) ;
        pc.addCols(cdo1.getColValue("fecha_ini_plan"),1,1) ;
        pc.addCols(cdo1.getColValue("fecha_fin_plan"),1,1) ;

		}//End For

		pc.setFont(10,1);
		pc.addCols(al.size()+" Registro"+(al.size()>1?"s":"")+" en total",0,tblContent.size());

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>