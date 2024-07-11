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
String estado = (request.getParameter("estado")==null?"":request.getParameter("estado"));

String photosFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String imagesFolder = java.util.ResourceBundle.getBundle("path").getString("images");

if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
{
appendFilter += " and trunc(s.fecha_ini_sol) = to_date('"+request.getParameter("fecha")+"','dd/mm/yyyy')";
}
if (!estado.trim().equals("") && !estado.trim().equals("T"))
{
appendFilter += " and s.estado = '"+estado.toUpperCase()+"'";
}
if (request.getParameter("cdsFrom") != null && !request.getParameter("cdsFrom").trim().equals(""))
{
appendFilter += " and s.del_cds in( "+request.getParameter("cdsFrom")+" )";
}
if (request.getParameter("cdsTo") != null && !request.getParameter("cdsTo").trim().equals(""))
{
appendFilter += " and s.al_cds in ( "+request.getParameter("cdsTo")+" )";
}

sql = "select /*<SOL>*/ s.id id_sol, s.escolta_id, s.pac_id, s.admision, s.del_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.del_cds and rownum = 1) del_cds_dsp,  s.al_cds, (select descripcion from tbl_cds_centro_servicio where codigo = s.al_cds and rownum = 1) al_cds_dsp, s.cama_origen, s.cama_destino, s.observacion, to_char(s.fecha_ini_sol,'dd/mm/yyyy hh12:mi:ss am') f_ini_sol, to_char(s.fecha_fin_sol,'dd/mm/yyyy hh12:mi:ss am') f_fin_sol, s.usuario_creacion, to_char(s.fecha_creacion,'dd/mm/yyyy') f_crea, to_char(s.fecha_modificacion,'dd/mm/yyyy') f_mod, s.usuario_modificacion, s.estado, s.cat_admision, s.observ, to_char(s.fecha_ini_ejec,'dd/mm/yyyy hh12:mi:ss am') fechaIncioAtencion, s.tipo_sol, decode(s.tipo_sol,'T','TEMPORAL','PERMAMENTE') tipoSolDesc/*</SOL>*/ , /*<PAC>*/ p.nombre_paciente, p.id_paciente ced_pac /*</PAC>*/  ,/*<ESC>*/  '['||decode(e.emp_id,null,'EXTERNO','INTERNO')||']' tipo_esc, e.id id_esc, e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.segundo_apellido nombre_esc , coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento) ced_esc, e.emp_id, image_path as foto /*</ESC>*/ from tbl_esc_sol_escolta s, vw_adm_paciente p, tbl_adm_admision a, tbl_esc_escolta e where s.pac_id = p.pac_id and p.pac_id = a.pac_id and s.admision = a.secuencia and a.pac_id = s.pac_id and s.escolta_id = e.id /*<FILTRO>*/ "+appendFilter+" /*</FILTRO>*/";

System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::");
System.out.println(sql);
System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::");

cdo = SQLMgr.getData(sql);

if (cdo==null) cdo = new CommonDataObject();

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
	String title = "SOLICITUD DE ANFITRION ESCOLTA";
	String subtitle = (estado.equals("E")?"EJECUTADA":"FINALIZADA");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblMain = new Vector();
	tblMain.addElement("30");
	tblMain.addElement("10");
	tblMain.addElement("10");
	tblMain.addElement("10");
	tblMain.addElement("10");
	tblMain.addElement("10");
	tblMain.addElement("10");
	tblMain.addElement("10");

	Vector tblDetail = new Vector();
	tblDetail.addElement("13");
	tblDetail.addElement("7");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");
	tblDetail.addElement("10");

	pc.setNoColumnFixWidth(tblMain);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblMain.size());

	if (cdo.getColValue("foto") != null && !cdo.getColValue("foto").trim().equals("")){
		pc.addImageCols(photosFolder+"/"+cdo.getColValue("foto"),120.0f,0);
	}else{
		pc.addImageCols(imagesFolder+"/image_not_found.jpg",120.0f,0);
	}

	pc.setVAlignment(0);

	pc.setNoColumnFixWidth(tblDetail);
	//String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth
	pc.createTable("detail",false,0,0.0f,410.0f);

	//Escolta
	pc.setFont(9,1);
	pc.addCols("ANFITRION O ESCOLTA  "+cdo.getColValue("tipo_esc"),0,tblDetail.size(),Color.lightGray);
	pc.addCols("Nombre:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("nombre_esc"),0,6);
	pc.setFont(9,1);
	pc.addCols("Cédula:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("ced_esc"),0,2);

	pc.addCols(" ",0,tblDetail.size());

	//Solicitud . paciente
	pc.setFont(9,1);
	pc.addCols("PACIENTE - SOLICITUD",0,tblDetail.size(),Color.lightGray);
	pc.addCols("#Solicitud:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("id_sol"),0,1);

	pc.setFont(9,1);
	pc.addCols("PID-ADM:",0,2);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision"),0,2);
	pc.setFont(9,1);
	pc.addCols("Tipo:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("tipoSolDesc"),0,3);

	pc.setFont(8,1);
	pc.addCols("Fecha.Sol:",0,1);
	pc.setFont(8,0);
	pc.addCols(cdo.getColValue("f_ini_sol"),0,4);

	pc.setFont(8,1);
	pc.addCols("F.Ejec.:",0,1);
	pc.setFont(8,0);
	pc.addCols(cdo.getColValue("fechaIncioAtencion"),0,4);

	pc.setFont(9,1);
	pc.addCols("Nombre:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("nombre_paciente"),0,6);
	pc.setFont(9,1);
	pc.addCols("Cédula:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("ced_pac"),0,2);

	pc.setFont(9,1);
	pc.addCols("Origen:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("del_cds_dsp"),0,7);
	pc.setFont(9,1);
	pc.addCols("Cama:",0,1);
	pc.setFont(9,0);
	pc.addCols(cdo.getColValue("cama_origen"),0,1);

	if (cdo.getColValue("al_cds_dsp")!=null && !cdo.getColValue("al_cds_dsp").trim().equals("")){
		pc.setFont(9,1);
		pc.addCols("Destino:",0,1);
		pc.setFont(9,0);
		pc.addCols(cdo.getColValue("al_cds_dsp"),0,7);
		pc.setFont(9,1);
		pc.addCols("Cama:",0,1);
		pc.setFont(9,0);
		pc.addCols(cdo.getColValue("cama_destino"),0,1);
	}else{
		pc.setFont(9,1);
		pc.addCols("N/A Destino:",0,2);
		pc.setFont(9,0);
		pc.addCols(cdo.getColValue("observacion")+" dfdfdhg dgfhdgf djhfjdh djfhdjhf ddjhfjdfjdhjfd jhsjdgsjdg jsdjsgdjs dgsjd jhgdjhsgdsdgsjhdgs dsj",0,8);
    }



	pc.useTable("main");
	pc.addTableToCols("detail",1,7,0.0f);

	pc.addCols("\n(1)...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
	pc.addCols("Escolta sale del centro Anfitrión:",0,tblMain.size());

	pc.addCols("\n",0,tblMain.size());
	pc.addBorderCols("Centro",1,1,0.0f,0.1f,0.0f,0.0f);
	pc.addCols("",1,4);
	pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);

	pc.addCols("\n(2)...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
	pc.addCols("Escolta llega al centro origen:",0,tblMain.size());

	pc.addCols("\n\n",0,tblMain.size());
	pc.addBorderCols("Centro origen",1,1,0.0f,0.1f,0.0f,0.0f);
	pc.addCols("",1,4);
	pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);

	int numbering = 2;

	//Temporal
	if (cdo.getColValue("tipo_sol") != null && cdo.getColValue("tipo_sol").equals("T")){
		numbering+=1;
		if(cdo.getColValue("al_cds") != null && !cdo.getColValue("al_cds").equals("")){
			pc.addCols("\n("+numbering+")...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
			pc.addCols("Escolta llega al centro Destino:",0,tblMain.size());

			pc.addCols("\n\n",0,tblMain.size());
			pc.addBorderCols("Centro Destino",1,1,0.0f,0.1f,0.0f,0.0f);
			pc.addCols("",1,4);
			pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);
			numbering+=1;
		}

		//ecolta regresa al cds destino
		pc.addCols("\n("+numbering+")...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
		pc.addCols("Escolta regresa al centro origen:",0,tblMain.size());

		pc.addCols("\n\n",0,tblMain.size());
		pc.addBorderCols("Centro origen",1,1,0.0f,0.1f,0.0f,0.0f);
		pc.addCols("",1,4);
		pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);

		numbering+=1;

	}
   else
	//Permanente
	if (cdo.getColValue("tipo_sol") != null && cdo.getColValue("tipo_sol").equals("P")){
		numbering+=1;
		if(cdo.getColValue("al_cds") != null && !cdo.getColValue("al_cds").equals("")){
			pc.addCols("\n("+numbering+")...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
			pc.addCols("Escolta llega al centro Destino:",0,tblMain.size());

			pc.addCols("\n\n",0,tblMain.size());
			pc.addBorderCols("Centro Destino",1,1,0.0f,0.1f,0.0f,0.0f);
			pc.addCols("",1,4);
			pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);
			numbering+=1;
		}
	}

	//numbering+=1;

	pc.addCols("\n("+numbering+")...........................................................................................................................................................................................................................................................",0,tblMain.size(),25f);
	pc.addCols("Escolta regresa al centro Anfitrión:",0,tblMain.size());

	pc.addCols("\n\n",0,tblMain.size());
	pc.addBorderCols("Centro",1,1,0.0f,0.1f,0.0f,0.0f);
	pc.addCols("",1,1);
	pc.addBorderCols("Fecha/Hora Finalizada",1,3,0.0f,0.1f,0.0f,0.0f);
	pc.addCols("",1,1);
	pc.addBorderCols("Anfitrión",1,3,0.0f,0.1f,0.0f,0.0f);


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>