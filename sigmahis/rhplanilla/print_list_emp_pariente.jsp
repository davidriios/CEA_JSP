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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList alMadre = new ArrayList();
ArrayList alPadre = new ArrayList();
ArrayList alHijo = new ArrayList();
ArrayList alOtro = new ArrayList();
ArrayList alCony = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

String cargo = request.getParameter("cargo");
String depto = request.getParameter("depto");
String seccion = request.getParameter("sec");


if (appendFilter == null) appendFilter = "";

if (depto == null) depto = "";
if (seccion == null) seccion = "";

 if (depto != "")   appendFilter = " and  a.unidad_organi = "+depto;
 if (seccion != "") appendFilter = " and  a.seccion = "+seccion;

	sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,   a.primer_nombre||' '||a.primer_apellido||' '||a.segundo_apellido as nombre , a.ubic_seccion as seccion, ' [ '||a.ubic_seccion||' ] '||b.descripcion as descripcion, a.emp_id as empId, a.num_empleado as numero, a.num_ssocial as social,  to_char(a.gasto_rep,'99,999,990.00') as gasto, a.tipo_renta||'-'||nvl(a.num_dependiente,'0') renta, to_char(a.salario_base,'99,999,990.00') as salario, to_char(a.rata_hora,'99,990.00') as rata, to_char(a.fecha_nacimiento,'dd-mm-yyyy') nacimiento, to_char(a.fecha_ingreso,'dd-mm-yyyy') ingreso, a.horas_base horas, a.estado, e.descripcion estadoDesc, d.denominacion as cargo, x.nombre_madre madre, y.nombre_padre padre, z.nombre_conyuge conyuge, a.emp_id from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo d, tbl_pla_estado_emp e, (select a.nombre||' '||a.apellido nombre_madre, a.emp_id from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.parentesco = 3 ) x, (select a.nombre||' '||a.apellido nombre_padre, a.emp_id from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.parentesco = 2 ) y, (select a.nombre||' '||a.apellido nombre_conyuge, a.emp_id from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.parentesco in (4,15,11) ) z where a.compania = b.compania and a.ubic_seccion = b.codigo and a.estado = e.codigo and a.cargo = d.codigo and a.compania = d.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+"  and a.emp_id = x.emp_id(+) and a.emp_id = y.emp_id(+) and a.emp_id = z.emp_id(+) order by a.ubic_seccion, a.primer_apellido";
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
	String title = "PLANILLA ";
	String subtitle = " LISTADO DE DEPENDIENTES POR EMPLEADOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  	dHeader.addElement(".07");
	  	dHeader.addElement(".18");
		dHeader.addElement(".09");
		dHeader.addElement(".14");
		dHeader.addElement(".14");
		dHeader.addElement(".14");
		dHeader.addElement(".14");
		dHeader.addElement(".10");
		
			Vector infoCol = new Vector();
	  	infoCol.addElement(".14");
		
				
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(6, 1);
		pc.addCols("# Empleado",0,1);
		pc.addCols("Nombre",1,1);		
		pc.addCols("C�dula",1,1);
		pc.addCols("Nombre de la Madre",1,1);		
		pc.addCols("Nombre del Padre",1,1);
		pc.addCols("Nombre del Conyuge",1,1);
		pc.addCols("Nombrre de los Hijos",1,1);
		pc.addCols("Otros Parientes",1,1);	
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String sec = "";
	
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!sec.equalsIgnoreCase(cdo.getColValue("seccion")))
			{
			
			pc.setFont(6, 1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,dHeader.size());
			}
			
		pc.setFont(6, 0);
		pc.setVAlignment(0);
			pc.addBorderCols(" "+cdo.getColValue("numero"),0,1);
			pc.addBorderCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addBorderCols(" "+cdo.getColValue("cedula"),0,1);	
			/*
			sql = "select a.nombre||' '||a.apellido madre from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+cdo.getColValue("emp_id")+" and a.parentesco = 3";
			alMadre = SQLMgr.getDataList(sql);
			
			sql = "select a.nombre||' '||a.apellido padre from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+cdo.getColValue("emp_id")+" and a.parentesco = 2";
			alPadre = SQLMgr.getDataList(sql);
			
			sql = "select a.nombre||' '||a.apellido hijo from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+cdo.getColValue("emp_id")+" and a.parentesco = 5";
			alHijo = SQLMgr.getDataList(sql);
			
			sql = "select a.nombre||' '||a.apellido conyuge from tbl_pla_pariente a where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+cdo.getColValue("emp_id")+" and a.parentesco in (4,15,11)";
			alCony = SQLMgr.getDataList(sql);
			
			sql = "select a.nombre||' '||a.apellido||' ('||SUBSTR(pc.descripcion,1,3)||')' otro from tbl_pla_pariente a, tbl_pla_parentesco pc  where a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.parentesco = pc.codigo and a.emp_id="+cdo.getColValue("emp_id")+" and a.parentesco not in (2,3,4,5,11,15)";
			alOtro = SQLMgr.getDataList(sql);
			
			if(alMadre.size()==0 && alPadre.size()==0 && alHijo.size()==0 && alCony.size()==0 && alOtro.size()==0){
				System.err.println("Nada que hacer");
				}else{
				
				for(int madreI=0;madreI<alMadre.size();madreI++){
				CommonDataObject cdoMadre=null,cdoPadre=null, cdoCony=null;
				if(madreI<alMadre.size()) {cdoMadre=(CommonDataObject) alMadre.get(madreI); 
				}
				if(madreI<alPadre.size())  {cdoPadre=(CommonDataObject) alPadre.get(madreI); 
				}
				if(madreI<alCony.size())  {cdoCony=(CommonDataObject) alCony.get(madreI); 
				}
				//if(madreI>=alExtra.size() && madreI>=alDesc.size()) break;
				pc.createTable();	
					pc.addCols((cdoMadre==null) ? "":cdoMadre.getColValue("madre"),0,1);
					pc.addCols((cdoPadre==null) ? "":cdoPadre.getColValue("padre"),0,1);		
					pc.addCols((cdoCony==null) ? "":cdoCony.getColValue("conyuge"),0,1);													
					pc.addCols("",1,1);
				  pc.addCols("",1,1);
				pc.addTable();	
				} // for ends here
				}//else ends here
				
				*/
				pc.addBorderCols(" "+cdo.getColValue("madre"),0,1);
				pc.addBorderCols(" "+cdo.getColValue("padre"),0,1);
				pc.addBorderCols(" "+cdo.getColValue("conyuge"),0,1);	
				
				/*
				if(alHijo.size()==0)
				{
			    pc.setNoInnerColumnFixWidth(infoCol);
					pc.setVAlignment(1);
				  pc.setFont(6, 0);
					pc.addInnerTableBorderCols("",0,1);
				}else{
						pc.setNoInnerColumnFixWidth(infoCol);
						pc.setVAlignment(1);
				for (int j=0; j<alHijo.size(); j++)
			{
				CommonDataObject cdo2 = (CommonDataObject) alHijo.get(j);
				
				//	pc.resetVAlignment();
				//		pc.addInnerTableToCols(1);
					
				
					pc.setFont(6, 0);
					pc.addInnerTableBorderCols(""+cdo2.getColValue("hijo"),0,1);
						
				}	
				}
				
					pc.setNoInnerColumnFixWidth(infoCol);
						pc.setVAlignment(1);
				 pc.setFont(6, 0);
					pc.addInnerTableBorderCols("",0,1);
					*/
		//		pc.addTable();	
				pc.addBorderCols("",1,1);
				pc.addBorderCols("",1,1);
				
		sec=cdo.getColValue("seccion");	
	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>