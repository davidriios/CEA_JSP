<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
CommonDataObject cdo2 = new CommonDataObject();	

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fechaini   = request.getParameter("fechaini");
String fechafin   = request.getParameter("fechafin");
String depto      = request.getParameter("depto");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini   = "";
if (fechafin   == null) fechafin   = "";
if (depto      == null) depto      = "";

if (!compania.equals(""))
  {
   appendFilter += " and e.compania = "+compania;
  }    
if (!depto.equals(""))   
 {
  appendFilter += " and e.unidad_organi = "+depto;
 } 

 
if (!fechaini.equals(""))
   {
  appendFilter += " and to_date(to_char(i.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }

if (!fechafin.equals(""))
   {
   appendFilter += " and to_date(to_char(i.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ; 
     }

sql= " select e.provincia, e.sigla, e.tomo, e.asiento, e.nombre_empleado nombreEmpleado, i.num_empleado numEmpleado,e.emp_id empId, c.denominacion  descCargo, e.unidad_organi grupo, cg.descripcion descGrupo, i.fecha, mf.descripcion, i.motivo comentarios, to_char(i.hora_salida,'HH12:MI AM') ini, to_char(i.hora_entrada,'HH12:MI AM') fin, i.tiempo_horas tiempoHoras, i.tiempo_minutos tiempoMinutos, i.programa, i.turno_asignado, h.cant_horas horasDia from vw_pla_empleado e, tbl_sec_unidad_ejec cg, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h, tbl_pla_cargo c where (h.codigo = e.horario and h.compania = e.compania) and (i.emp_id = e.emp_id and i.num_empleado = e.num_empleado and i.compania = e.compania) and mf.codigo = i.mfalta and (cg.codigo = e.unidad_organi and cg.compania = e.compania) and (c.codigo = e.cargo and c.compania = e.compania) and nvl(i.aprobado,'N') <> 'A' and i.mfalta <> 54 "+appendFilter+" order by cg.descripcion, i.num_empleado , i.fecha ";
														
 al = SQLMgr.getDataList(sql);  	  

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();
	Hashtable htSec = new Hashtable();

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
	String title = "RECURSOS HUMANOS";
	String subtitle = " INFORME DE INCAPACIDADES POR DEPARTAMENTO ";
	String xtraSubtitle = " DEL "+fechaini+" AL "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".12");		
		dHeader.addElement(".25");				
		dHeader.addElement(".23");			
		dHeader.addElement(".10");		
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 
    
    pc.setFont(8, 1);
	pc.addBorderCols("No. EMP.",1,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("CARGO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("HORAS TRAB.",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("TOT. DÍAS",1,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("TOT. HORAS",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("TOT. MIN",1,1,1.0f,1.0f,0.0f,0.0f);	
   
	String groupBy = "", empId = "";
	int pxu = 0, pxs = 0, pxg = 0, totalHoras = 0, totDias = 0, vDias = 0, vHoras = 0, vMinutos = 0, vTotHoras = 0;
	int totalD = 0, totvHoras = 0, totvMinutos = 0;
	
	double totDescuento = 0, totalHoras2 = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);	
		
	sql= "select sum(i.tiempo_horas) horas, sum(i.tiempo_minutos) minutos from vw_pla_empleado e, tbl_sec_unidad_ejec cg, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h, tbl_pla_cargo c where (h.codigo = e.horario and h.compania = e.compania) and(i.emp_id = e.emp_id and i.num_empleado = e.num_empleado and i.compania = e.compania) and mf.codigo = i.mfalta and (cg.codigo = e.unidad_organi and cg.compania = e.compania) and (c.codigo = e.cargo and c.compania = e.compania) and nvl(i.aprobado,'N') <> 'A' and i.mfalta <> 54 "+appendFilter+" and e.num_empleado = "+cdo.getColValue("numEmpleado");	
	
	cdo2 = SQLMgr.getData(sql);
		
	//Inicio --Agrupamiento por Depto
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("grupo")+" ] "+cdo.getColValue("descGrupo")))
		{ // groupBy
			if (i != 0)
			  {//i-1 				   
				    pc.setFont(7, 1,Color.red);
					pc.addCols("CANT. DE EMPLEADOS",1,2);
		            pc.addCols("TOTAL DÍAS",1,1);
		            pc.addCols("TOTAL HORAS",1,2);
		            pc.addCols("TOTAL MINUTOS",1,2);		
		
		            pc.setFont(7, 1);
		            pc.addBorderCols(" "+pxu,1,2,0.5f,0.5f,0.0f,0.0f);
		            pc.addBorderCols(" "+totalD,1,1,0.5f,0.5f,0.0f,0.0f);
		            pc.addBorderCols(" "+totvHoras,1,2,0.5f,0.5f,0.0f,0.0f);
		            pc.addBorderCols(" "+totvMinutos,1,2,0.5f,0.5f,0.0f,0.0f);						
					pc.addCols(" ",0,dHeader.size());
					pxu       = 0;
					totalD    = 0;
					totvHoras = 0;
					totvMinutos = 0;						
			   }//i-1					  
				pc.setFont(8, 1,Color.blue);					
		pc.addCols("Depto:  "+"[ "+cdo.getColValue("grupo")+" ] "+cdo.getColValue("descGrupo"),0,dHeader.size(),Color.lightGray);		
		 pxs++;
		 	
	   }//Final --Agrupamiento por Depto.
	   
	   	totalHoras   = (Integer.parseInt(cdo2.getColValue("horas")) + (Integer.parseInt(cdo2.getColValue("minutos"))/60));		
		totDias      = totalHoras / (Integer.parseInt(cdo.getColValue("horasDia")));
		
	     vDias    = totalHoras / (Integer.parseInt(cdo.getColValue("horasDia")));
		 vHoras   =  (totalHoras - (totDias * (Integer.parseInt(cdo.getColValue("horasDia")))));		 
		 vMinutos = ((totalHoras - ( (totDias * Integer.parseInt(cdo.getColValue("horasDia"))) + vHoras )) * 60 );
	
	    // Listado de Incapacidades por Depto.		
		if (!empId.trim().equals(cdo.getColValue("empId")))
		{		
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("numEmpleado"),1,1);					
			pc.addCols(" "+cdo.getColValue("nombreEmpleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("descCargo"),0,1);									
			pc.addCols(" "+cdo.getColValue("horasDia"),1,1);							
			pc.addCols(" "+totalHoras,1,1);							
			pc.addCols(" "+(((String.valueOf(vHoras).trim().equals("0")))?"":String.valueOf(vHoras)),1,1);		//vHoras					
			pc.addCols(" "+((cdo2.getColValue("minutos").trim().equals("0"))?"":cdo2.getColValue("minutos")),1,1);							
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			pxu++;						 
			totalD      += totDias;
			totvHoras   += vHoras;
			totvMinutos += Integer.parseInt(cdo2.getColValue("minutos"));
		}
		
		empId =  cdo.getColValue("empId");	
	  groupBy = "[ "+cdo.getColValue("grupo")+" ] "+cdo.getColValue("descGrupo");
	 
			
	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}// final del for
	
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size()); 		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{	
	    pc.setFont(7, 1,Color.red);
		pc.addCols("CANT. DE EMPLEADOS",1,2);
		pc.addCols("TOTAL DÍAS",1,1);
		pc.addCols("TOTAL HORAS",1,2);
		pc.addCols("TOTAL MINUTOS",1,2);		
		
		pc.setFont(7, 1);
		pc.addBorderCols(" "+pxu,1,2,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" "+totalD,1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" "+totvHoras,1,2,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" "+totvMinutos,1,2,0.5f,0.5f,0.0f,0.0f);	
		
	  //pc.setFont(9,0); 
	 // pc.addCols("TOTAL DE ACREEDORES "+" . . . "+pxs,1,dHeader.size(),Color.lightGray);	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>



