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
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String codCat = request.getParameter("codCat");

if (appendFilter == null) appendFilter = "";

sql = "select decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre nombre, decode(p.f_nac,null,to_char(p.fecha_nacimiento,'dd/mm/yyyy'),to_char(p.f_nac,'dd/mm/yyyy')) fecha_nacimiento, ad.codigo_paciente as codpac,ad.pac_id,ad.secuencia, nvl(ad.corte_cta,0)as corte_cta, decode(p.provincia||p.sigla||p.tomo||p.asiento||p.d_cedula, null, p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||' '||p.d_cedula) cedula, nvl(decode(ad.tipo_cta,'A','ASEGURADO','J','JUBILADO','M','MEDICO','E','EMPLEADO','P','PARTICULAR'),' ')as tipo_cta ,nvl(p.vip,' ')as vip,nvl(decode(ad.corte_cta,null,to_char(ad.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(ad.fecha_ingreso,'dd/mm/yyyy'),ad.secuencia,ad.pac_id)),' ')as fecha_ingreso,nvl((select ae.nombre as e_nombre from tbl_adm_beneficios_x_admision aba ,tbl_adm_empresa ae where aba.pac_id=ad.pac_id and aba.admision=ad.secuencia and aba.empresa=ae.codigo and aba.prioridad=1 and nvl(aba.estado,'A')='A' and rownum=1 ),' ') e_nombre, nvl((select decode(aba.convenio_sol_emp,null,'SIN POLIZA','N', aba.poliza,'S','DOBLE COBERT.') as poliza from tbl_adm_beneficios_x_admision aba where aba.pac_id=ad.pac_id and aba.admision=ad.secuencia and aba.prioridad=1 and nvl(aba.estado,'A')='A' and rownum=1 ),' ') poliza, nvl((select count(*) from tbl_adm_beneficios_x_admision aba where aba.pac_id=ad.pac_id and aba.admision=ad.secuencia and aba.prioridad=1 and nvl(aba.estado,'A')='A' ),0) count ,nvl((select cama as v_cama from tbl_adm_cama_admision where compania = "+ (String) session.getAttribute("_companyId")+" and pac_id=ad.pac_id and admision=ad.secuencia and fecha_final is null),'POR ASIGNAR') v_cama from tbl_adm_admision ad, tbl_adm_paciente p where ( ad.compania = "+ (String) session.getAttribute("_companyId")+" and ad.estado='A' and ad.categoria in (1,5) ) and  (ad.pac_id=p.pac_id) order by decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre" ;
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "admision";
	String fileNamePrefix = "print_pac_activos_global";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".22");
		setDetail.addElement(".03");
		setDetail.addElement(".10");
		setDetail.addElement(".07");
		setDetail.addElement(".05");
		setDetail.addElement(".05");
		setDetail.addElement(".10");
		setDetail.addElement(".07");
		setDetail.addElement(".20");
		setDetail.addElement(".11");
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "ADMISION", "LISTADO DE PACIENTES ACTIVOS AL DIA "+cDateTime.substring(0,10), userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Nombre del Pac.",1);
		pc.addBorderCols("VIP",1);
		pc.addBorderCols("Cama",1);
		pc.addBorderCols("F Nac",1);
		pc.addBorderCols("Pte",1);
		pc.addBorderCols("Adm",1);
		pc.addBorderCols("Cedula",1);
		pc.addBorderCols("Ingreso",1);
		pc.addBorderCols("Ageguradora",1);
		pc.addBorderCols("Poliza",1);
	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.createTable();
			pc.addCols(" "+cdo.getColValue("nombre"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("vip"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("v_cama"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fecha_nacimiento"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("codPac"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("secuencia"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fecha_ingreso"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("e_nombre"),0,1,cHeight);
			pc.addCols(" "+((Integer.parseInt(cdo.getColValue("count")) > 1)?"DOBLE COBERT.":cdo.getColValue("poliza")),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("estado"),1,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "ADMISION", "LISTADO DE PACIENTES ACTIVOS AL DIA "+cDateTime.substring(0,10), userName, fecha);
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
			pc.setFont(8, 1);
			pc.addCols("TOTAL DE PACIENTES ACTIVOS: "+al.size(),0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>