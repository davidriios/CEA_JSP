<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
	CommonDataObject cdo=new CommonDataObject();
	ArrayList al = new ArrayList();
	ArrayList alE = new ArrayList();

	
	String sql = "", appendFilter = "";
	
	String p_dia  	= "01";   //-- valor fijo para el primer día de cada mes.
	String p_mes  	= request.getParameter("mes1");
	String p_anio 	= request.getParameter("anio");
	
if (p_mes==null) p_mes = "";
if (p_anio == null) p_anio = "";
if (appendFilter == null) appendFilter = "";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "REPORTE DE LABORATORIO ";
	String xtraSubtitle = "AL AÑO "+p_anio;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".50");
		setDetail.addElement(".50");
	
		

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		//second row
		pc.setFont(10, 1);
		pc.addBorderCols("MES",0,1);
		pc.addBorderCols("LABORATORIO",1,1);
		
		
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	
	     if (p_mes.trim().equals("01")) month = "ENERO";
	else if (p_mes.trim().equals("02")) month = "FEBRERO";
	else if (p_mes.trim().equals("03")) month = "MARZO";
	else if (p_mes.trim().equals("04")) month = "ABRIL";
	else if (p_mes.trim().equals("05")) month = "MAYO";
	else if (p_mes.trim().equals("06")) month = "JUNIO";
	else if (p_mes.trim().equals("07")) month = "JULIO";
	else if (p_mes.trim().equals("08")) month = "AGOSTO";
	else if (p_mes.trim().equals("09")) month = "SEPTIEMBRE";
	else if (p_mes.trim().equals("10")) month = "OCTUBRE";
	else if (p_mes.trim().equals("11")) month = "NOVIEMBRE";
	else if (p_mes.trim().equals("12")) month = "DICIEMBRE";
	
			 
	//table body
	int total=0, totales=0,totalfem =0, totalmas =0;
	
	if (p_mes.trim().equals("")){
for (int i=1; i<=12; i++){ 
 
	sql = "Select count(*) admision from (select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as pasaporte, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte)  cedulaPamd, a.compania, a.pac_id as pacId, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido, null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F', decode (b.estado_civil, 'CS', ' ' || nvl(b.apellido_de_casada, ' '), '')) as nombrePaciente, c.nombre_corto as categoriaDesc, a.centro_servicio as centroServicio, d.descripcion as centroServicioDesc, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cdsCama,a.centro_servicio) else a.centro_servicio end as area/*es el cds para expediente*/, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cama,' ') else ' ' end as cama, a.medico, nvl(trunc(months_between(sysdate,a.fecha_nacimiento)/12),0) as key from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d, (select distinct g.pac_id, g.admision, g.cama, f.unidad_admin as cdsCama from tbl_adm_cama_admision g,tbl_sal_cama e, tbl_sal_habitacion f where g.compania=e.compania and g.cama=e.codigo and g.habitacion=e.habitacion and e.habitacion=f.codigo and e.compania=f.compania and g.fecha_final is null and g.hora_final is null) x where  trunc(a.fecha_ingreso)>= to_date('01/'||lpad("+i+",2,0)||'/"+p_anio+"','dd/mm/yyyy')and trunc(a.fecha_ingreso)<=last_day (to_date('01/'||lpad("+i+",2,0)||'/"+p_anio+"','dd/mm/yyyy')) and a.pac_id=b.pac_id and a.categoria=c.codigo and a.centro_servicio=d.codigo and a.compania=1 and a.pac_id=x.pac_id(+) and a.secuencia=x.admision(+)  and a.centro_servicio=16 order by nvl(a.fecha_ingreso,a.fecha_creacion) desc, nombrePaciente, a.secuencia) ";
		
	cdo = SQLMgr.getData(sql);
	
	
	if (i == 1) month = "ENERO";
	else if (i == 2) month = "FEBRERO";
	else if (i == 3) month = "MARZO";
	else if (i == 4) month = "ABRIL";
	else if (i == 5) month = "MAYO";
	else if (i == 6) month = "JUNIO";
	else if (i == 7) month = "JULIO";
	else if (i == 8) month = "AGOSTO";
	else if (i == 9) month = "SEPTIEMBRE";
	else if (i == 10) month = "OCTUBRE";
	else if (i == 11) month = "NOVIEMBRE";
	else if (i == 12) month = "DICIEMBRE";
	
if (cdo == null) cdo = new CommonDataObject();
if (cdo.getColValue("admision")!= null && !cdo.getColValue("admision").trim().equals("")){
  total += Integer.parseInt(cdo.getColValue("admision"));
  totalmas += Integer.parseInt(cdo.getColValue("admision"));
  totales += Integer.parseInt(cdo.getColValue("admision"));
  }


			 
			pc.addCols(" "+month,0,1);
	  		pc.addCols(" "+cdo.getColValue("admision"),1,1);
		
			
	   
	total = 0;		
	//if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
}
}else
{
	sql = "select (select count(*) from tbl_adm_neonato where  trunc(fecha_nacimiento)>= to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy')and trunc(fecha_nacimiento )<=last_day (to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy')) and sexo='F') femenino,(select count(*) from tbl_adm_neonato where  trunc(fecha_nacimiento)>= to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy') and trunc(fecha_nacimiento) <=last_day (to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy'))and sexo='M') masculino from dual";
	
cdo = SQLMgr.getData(sql);
			 if (cdo == null) cdo = new CommonDataObject();
if (cdo.getColValue("admision")!= null && !cdo.getColValue("admision").trim().equals("")){
  total += Integer.parseInt(cdo.getColValue("admision"));
  totalmas += Integer.parseInt(cdo.getColValue("admision"));
  totales += Integer.parseInt(cdo.getColValue("admision"));
  }
if (cdo.getColValue("admision")!= null && !cdo.getColValue("admision").trim().equals("")){

  total += Integer.parseInt(cdo.getColValue("admision"));
  totalfem += Integer.parseInt(cdo.getColValue("admision"));
  totales += Integer.parseInt(cdo.getColValue("admision"));
}
			pc.addCols(""+month,0,1);
	  		pc.addCols(" "+cdo.getColValue("admision"),1,1);
			
total =0;
} 
	pc.addBorderCols(" TOTAL : ",0,1);
	  		pc.addBorderCols(" "+totalmas,1,1);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>