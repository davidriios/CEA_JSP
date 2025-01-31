<%@ page errorPage="../error.jsp"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);
	CommonDataObject cdo=new CommonDataObject();
	ArrayList al = new ArrayList();
	ArrayList alE = new ArrayList();

	
	String sql = "", appendFilter = "", sqlAll = "";
	
	String p_dia  	= "01";   //-- valor fijo para el primer d�a de cada mes.
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
	String subtitle = "REPORTE DE PACIENTES POR CATEGORIA";
	String xtraSubtitle = "AL A�O "+p_anio;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".15");
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".25");
	
		

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		//second row
		pc.setFont(10, 1);
		pc.addBorderCols("MES",0,1);
		pc.addBorderCols("Neonatos 0-12 meses",1,1);	
		pc.addBorderCols("Pedriaticos 1-17 a�os",1,1);	
		pc.addBorderCols("Adultos de 18-64 a�os",1,1);
		pc.addBorderCols("Gedriaticos 65 a�os en adelante",1,1);
		
		
	
	
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
	int total=0, totales=0, totalbe =0, totalni =0, totaladu=0, totalabu=0, totalfem=0, totalmas=0;
	
	if (p_mes.trim().equals("")){
	

 sql=" select mes, sum(entre_0_1) entre_0_1, sum(entre_1_17) entre_1_17, sum(entre_18_64) entre_18_64, sum(mayor_65) mayor_65 from (";

for(int i=1;i<13;i++){
    if(i!=1) sql += " union all ";
sql += "select "+i+" mes, (case when nvl(trunc(months_between((LAST_DAY(TO_DATE ('01/2011','mm/yyyy'))),coalesce(b.f_nac,a.fecha_nacimiento))/12),0) < 1 then 1 else 0 end) entre_0_1, (case when nvl(trunc(months_between((LAST_DAY(TO_DATE ('01/2011','mm/yyyy'))),coalesce(b.f_nac,a.fecha_nacimiento))/12),0) between 1 and 17 then 1 else 0 end) entre_1_17, (case when nvl(trunc(months_between((LAST_DAY(TO_DATE ('01/2011','mm/yyyy'))),coalesce(b.f_nac,a.fecha_nacimiento))/12),0) between 18 and 64 then 1 else 0 end) entre_18_64, (case when nvl(trunc(months_between((LAST_DAY(TO_DATE ('01/2011','mm/yyyy'))),coalesce(b.f_nac,a.fecha_nacimiento))/12),0) > 64 then 1 else 0 end) mayor_65  FROM TBL_ADM_ADMISION a, TBL_ADM_PACIENTE b, TBL_ADM_CAMA_ADMISION c, TBL_CDS_CENTRO_SERVICIO d, TBL_SAL_HABITACION e WHERE a.pac_id = b.pac_id AND a.SECUENCIA = c.ADMISION AND c.PAC_ID=b.PAC_ID AND C.HABITACION=E.CODIGO and E.UNIDAD_ADMIN=D.CODIGO and d.FLAG_CDS= 'SAL'AND TO_NUMBER(to_char(a.fecha_ingreso,'mm')) = "+i+" and to_number(to_char(a.fecha_ingreso,'yyyy')) = "+p_anio+"";
}
sql +=") group by mes order by mes";

sqlAll = "select mes, sum(entre_0_1) entre_0_1, sum(entre_1_17) entre_1_17, sum(entre_18_64) entre_18_64, sum(mayor_65) mayor_65 from ("+sql+") group by mes order by mes";

	
	al = SQLMgr.getDataList(sqlAll);
	if (al.size()==0){
	pc.addCols("No tiene Registros",0,5); 
	}else{
	
	
for (int i=1; i<al.size(); i++){
cdo=(CommonDataObject)al.get(i); 	
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
	

if (cdo.getColValue("entre_0_1")!= null && !cdo.getColValue("entre_0_1").trim().equals("")){
  total += Integer.parseInt(cdo.getColValue("entre_0_1"));
  totalbe += Integer.parseInt(cdo.getColValue("entre_0_1"));
  totales += Integer.parseInt(cdo.getColValue("entre_0_1"));
  }
if (cdo.getColValue("entre_1_17")!= null && !cdo.getColValue("entre_1_17").trim().equals("")){

  total += Integer.parseInt(cdo.getColValue("entre_1_17"));
  totalni += Integer.parseInt(cdo.getColValue("entre_1_17"));
  totales += Integer.parseInt(cdo.getColValue("entre_1_17"));
}
if (cdo.getColValue("entre_18_64")!= null && !cdo.getColValue("entre_18_64").trim().equals("")){

  total += Integer.parseInt(cdo.getColValue("entre_18_64"));
  totaladu += Integer.parseInt(cdo.getColValue("entre_18_64"));
  totales += Integer.parseInt(cdo.getColValue("entre_18_64"));
}
if (cdo.getColValue("mayor_65")!= null && !cdo.getColValue("mayor_65").trim().equals("")){

  total += Integer.parseInt(cdo.getColValue("mayor_65"));
  totalabu += Integer.parseInt(cdo.getColValue("mayor_65"));
  totales += Integer.parseInt(cdo.getColValue("mayor_65"));
}
			 
			pc.addCols(" "+month,0,1);
	  		pc.addCols(" "+cdo.getColValue("entre_0_1"),1,1);
			pc.addCols(" "+cdo.getColValue("entre_1_17"),1,1);
			pc.addCols(" "+cdo.getColValue("entre_18_64"),1,1);
			pc.addCols(" "+cdo.getColValue("mayor_65"),1,1);
			
	   
	total = 0;		
	//if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
}
} 
	pc.addBorderCols(" TOTAL : ",0,1);
	  		pc.addBorderCols(" "+totalbe,1,1);
			pc.addBorderCols(" "+totalni,1,1);
			pc.addBorderCols(" "+totaladu,1,1);
			pc.addBorderCols(" "+totalabu,1,1);
}			
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>