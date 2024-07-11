<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.awt.Color" %>
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


SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();

String sql = "", idSol = (request.getParameter("idSol")==null?"":request.getParameter("idSol"));

String appendFilter = "";
appendFilter += (idSol.equals("")?"": " and s.id = "+idSol);

if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
{
appendFilter += " and trunc(s.fecha_ini_sol) = to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy')";
}
if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
{
appendFilter += " and s.estado = '"+request.getParameter("estado").toUpperCase()+"'";
}
if (request.getParameter("cdsFrom") != null && !request.getParameter("cdsFrom").trim().equals(""))
{
appendFilter += " and s.del_cds in( "+request.getParameter("cdsFrom")+" )";
}
if (request.getParameter("cdsTo") != null && !request.getParameter("cdsTo").trim().equals(""))
{
appendFilter += " and s.al_cds in ( "+request.getParameter("cdsTo")+" )";
}

sql = "select /*<SOL>*/ s.id id_sol, s.escolta_id, s.pac_id, s.admision, s.del_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.del_cds and rownum = 1) del_cds_dsp,  nvl(to_char(s.al_cds),'N/A') al_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.al_cds and rownum = 1) al_cds_dsp, s.cama_origen, s.cama_destino, s.observacion, to_char(s.fecha_ini_sol,'dd/mm/yyyy') f_ini_sol, to_char(s.fecha_fin_sol,'dd/mm/yyyy') f_fin_sol, s.usuario_creacion, to_char(s.fecha_creacion,'dd/mm/yyyy') f_crea, to_char(s.fecha_modificacion,'dd/mm/yyyy') f_mod, s.usuario_modificacion, s.estado, s.cat_admision, s.observ/*</SOL>*/ , /*<PAC>*/ p.nombre_paciente, p.id_paciente ced_pac /*</PAC>*/  ,/*<ESC>*/  decode(e.emp_id,null,'EXT','INT') tipo_esc, e.id id_esc, e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.segundo_apellido nombre_esc , coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento) ced_esc, e.emp_id /*</ESC>*/ from tbl_sal_sol_escolta s, vw_adm_paciente p, tbl_adm_admision a, tbl_adm_escolta e where s.pac_id = p.pac_id and p.pac_id = a.pac_id and s.admision = a.secuencia and a.pac_id = s.pac_id and s.escolta_id = e.id /*<FILTRO>*/ "+appendFilter+" /*</FILTRO>*/";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
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
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "SOLICITUD DE ANFITRION ESCOLTA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".20"); //Nombre Paciente
	setDetail.addElement(".10"); //PID
	setDetail.addElement(".15"); //Cédula
	setDetail.addElement(".20"); //Area actual
	setDetail.addElement(".10"); //cama actual
	setDetail.addElement(".15"); //Area Destino

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

	//second row
	pc.setFont(8, 1);
	pc.addBorderCols("PACIENTE",0,1);
	pc.addBorderCols("PID",1,1);
	pc.addBorderCols("CEDULA",0,1);
	pc.addBorderCols("AREA ACTUAL",0,1);
	pc.addBorderCols("CAMA A",1,1);
	pc.addBorderCols("A. DESTINO",0,1);

	pc.addCols("",0,setDetail.size());

	pc.setFont(7, 0);
	String escortId = "";
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);

		if ( !escortId.equals("escolta_id") ) {
		  pc.setFont(8, 1,Color.white);
		   pc.addCols("ESCOLTA: "+cdo.getColValue("nombre_esc")+" ["+cdo.getColValue("escolta_id")+"]  [  "+cdo.getColValue("ced_esc")+"]",0,setDetail.size(),Color.lightGray);
		}
		pc.setFont(7, 0);

		pc.addCols(cdo.getColValue("nombre_paciente"),0,1);
		pc.addCols(cdo.getColValue("pac_id")+" - "+cdo.getColValue("admision"),1,1);
		pc.addCols(cdo.getColValue("ced_pac"),0,1);
		pc.addCols("["+cdo.getColValue("al_cds")+"] "+cdo.getColValue("al_cds_dsp"),0,1);
		pc.addCols(cdo.getColValue("cama_origen"),1,1);
		pc.addCols("["+cdo.getColValue("del_cds")+"] "+cdo.getColValue("del_cds_dsp"),0,1);

		pc.setFont(8, 1);
		pc.addCols("CAMA DESTINO:"+cdo.getColValue("cama_destino"),0,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("cama_destino"),0,1);

		pc.setFont(8, 1);
		pc.addCols("MOTIVO FALTA CAMA DESTINO:",0,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("observacion"),0,3);

		pc.setFont(8, 1);
		pc.addCols("OBSERVACION:",0,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("observ"),0,5);

		escortId = cdo.getColValue("escolta_id");
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>