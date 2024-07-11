<%@ page errorPage="../error.jsp"%>
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

	
	sql="select a.provincia||decode(a.sigla,'00','','-'||a.sigla)||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, p.denominacion cargoDesc, nvl(c.ubic_rhseccion_dest,a.ubic_seccion) as seccion, b.descripcion as descripcion, C.TIPO_ACCION tipo, c.sub_t_accion sub, to_char(c.fecha_doc,'dd-mm-yyyy') fecha, t.descripcion tipoDesc, s.descripcion subDesc , to_char(c.fecha_efectiva,'dd-mm-yyyy') as fechaEfectiva, decode(e.estado,'T','TRAMITE','A','APROBADA','P','APLICADA','N','ANULADA','R','R','E','E') as estado, c.cargo, nvl(c.salario,0) as salario, nvl(c.salario_dest,0) as salario_dest, c.comentarios_rrhh||' '||c.comentarios_pla as comentarios, (select denominacion||' ('||codigo||')'  from tbl_pla_cargo where codigo = c.cargo_insti_dest and compania = c.compania) as nuevo_cargo from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ap_accion_per c, tbl_pla_ap_accion_enc e , tbl_pla_ap_tipo_accion t, tbl_pla_ap_sub_tipo s, tbl_pla_cargo p where a.compania = b.compania and a.emp_id = c.emp_id and c.fecha_doc = e.fecha_doc and c.compania = e.compania and e.tipo_accion = c.tipo_accion and e.sub_t_accion = c.sub_t_accion and  a.cargo = p.codigo and  a.compania = p.compania and nvl(c.ubic_rhseccion_dest,a.ubic_seccion) = b.codigo and t.codigo = s.tipo_accion and c.tipo_accion = t.codigo and c.sub_t_accion = s.codigo and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by c.tipo_accion, c.sub_t_accion, a.ubic_seccion, a.primer_apellido";

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

	float width = 72 * 14f;//612
	float height = 72 * 8.5f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO DE ACCIONES A EMPLEADOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 13.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".12");
		dHeader.addElement(".07");
		dHeader.addElement(".12");
		dHeader.addElement(".07");
		dHeader.addElement(".12");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Cedula ",0);	
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Fecha ",1);	
		pc.addBorderCols("Departamento",1);
		pc.addBorderCols("Fecha Inicial ",1);	
		pc.addBorderCols("Cargo ",1);	
		pc.addBorderCols("Estado",1);
	    pc.addBorderCols("Sal. Actual ",1);	
		pc.addBorderCols("Sal. Ajustado",1);	
		pc.addBorderCols("Nuevo Cargo",1);
		pc.addBorderCols("Comentarios",1);
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String  tipo = "";
			String  sub = "";
			
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
   		if (!tipo.equalsIgnoreCase(cdo.getColValue("tipo")))
			{
			pc.setFont(7, 4);
			pc.addCols(" "+cdo.getColValue("tipo")+" - "+cdo.getColValue("tipoDesc"),0,dHeader.size());
			sub ="";
			}
			 if (!sub.equalsIgnoreCase(cdo.getColValue("sub")))
			{
			
			pc.setFont(7, 1);
			pc.addCols("   [ "+cdo.getColValue("sub")+" ]   "+cdo.getColValue("subDesc"),0,dHeader.size());
			}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		 
		pc.addCols(" "+cdo.getColValue("cedula"),1,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);	
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);	
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);	
			pc.addCols(" "+cdo.getColValue("fechaEfectiva"),1,1);	
			pc.addCols(" "+cdo.getColValue("cargoDesc"),0,1);	
			pc.addCols(" "+cdo.getColValue("estado"),1,1);	
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario")),1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_dest")),1,1);
			pc.addCols(" "+cdo.getColValue("nuevo_cargo"),1,1);		
		pc.addCols(" "+cdo.getColValue("comentarios"),1,1);		
	tipo=cdo.getColValue("tipo");	
		sub=cdo.getColValue("sub");	
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>