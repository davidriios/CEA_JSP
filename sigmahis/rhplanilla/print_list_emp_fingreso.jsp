<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
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
ArrayList almes = new ArrayList();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cargo = request.getParameter("cargo");
String depto = request.getParameter("depto");
String seccion = request.getParameter("sec");
String filter = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
StringBuffer sbSql = new StringBuffer();
if (appendFilter == null) appendFilter = "";
if (cargo == null) cargo = "";
if (depto == null) depto = "";
if (seccion == null) seccion = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";

sbSql.append("select e.nombre_empleado nombre, e.num_empleado, e.num_ssocial  num_ssocial, e.cedula1 cedula, e.cargo, ca.denominacion, e.unidad_organi unidad, e.ubic_seccion useccion, e.seccion seccion, c.nombre  nombre_cia, to_char(e.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, d.descripcion departamento, f.descripcion seccionDesc, e.salario_base as salario, to_char(e.gasto_rep,'99,999,990.00') as gasto, to_char(e.rata_hora,'999,990.00') as rata, to_char(sysdate,'yyyy') - to_char(e.fecha_ingreso,'yyyy') as antiguedad, nvl(trunc(months_between(sysdate,e.fecha_ingreso)/12),0)||'a' as edad, nvl(mod(trunc(months_between(sysdate,e.fecha_ingreso)),12),0)||'m' as edad_mes, trunc(SYSDATE-ADD_MONTHS(e.fecha_ingreso,(NVL(TRUNC(MONTHS_BETWEEN(SYSDATE,e.fecha_ingreso)/12),0)*12+NVL(MOD(TRUNC(MONTHS_BETWEEN(SYSDATE,e.fecha_ingreso)),12),0))))||'d' AS edad_dias,");

if (!fechaIni.trim().equals("") && !fechaFin.trim().equals(""))
{
	
	sbSql.append(" TRUNC(MONTHS_BETWEEN(to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy') ,to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')),0) as ");
	
}else sbSql.append(" 0 as ");

 sbSql.append(" meses,to_char(e.fecha_ingreso,'yyyy') anio_ing,to_char(e.fecha_ingreso,'mm') mes_ing from  vw_pla_empleado e, tbl_sec_compania c, tbl_pla_cargo ca, tbl_sec_unidad_ejec d, tbl_sec_unidad_ejec f where c.codigo = e.compania and ca.codigo = e.cargo and ca.compania = e.compania and (d.codigo = e.unidad_organi and d.compania = e.compania)  and  (f.codigo = nvl(e.seccion,e.ubic_seccion) and f.compania = e.compania ) and e.estado not in (3,13) and e.compania = ");
	sbSql.append(session.getAttribute("_companyId"));

 if (!cargo.trim().equals("")){  sbSql.append(" and  e.cargo = ");sbSql.append(cargo);}
 if (!depto.trim().equals("")){  sbSql.append(" and  e.ubic_depto = ");sbSql.append(depto);}
 if (!seccion.trim().equals("")){  sbSql.append(" and  e.seccion = ");sbSql.append(seccion);}
 if (!fechaIni.trim().equals("")){  sbSql.append(" and  trunc(e.fecha_ingreso) >= to_date('");sbSql.append(fechaIni);sbSql.append("','dd/mm/yyyy')");}
 if (!fechaFin.trim().equals("")){  sbSql.append(" and  trunc(e.fecha_ingreso) <= to_date('");sbSql.append(fechaFin);sbSql.append("','dd/mm/yyyy')");}
 sbSql.append(appendFilter);
 sbSql.append(" order by e.unidad_organi, e.seccion, e.primer_nombre,e.segundo_nombre, e.primer_apellido, e.segundo_apellido");
 al = SQLMgr.getDataList(sbSql.toString());

sql = "select to_number(anio_ing)anio_ing, to_number(mes_ing)mes_ing,count(*) cantidad,to_char(to_date(mes_ing,'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH')desc_mes from ( "+sbSql+") group by to_number(anio_ing),to_number(mes_ing),to_char(to_date(mes_ing,'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH') order by 1,2 ";
if (al.size() != 0) almes = SQLMgr.getDataList(sql);



if (request.getMethod().equalsIgnoreCase("GET"))
{

/*--------------------------------------------------------------------------------------------*/
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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO INGRESO DE EMPLEADOS ";
	String xtraSubtitle = (!fechaIni.trim().equals("") && !fechaFin.trim().equals(""))?"DESDE   "+fechaIni+"   HASTA   "+fechaFin:"";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    //float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector dHeader = new Vector();		
		dHeader.addElement(".12");
		dHeader.addElement(".18");
		dHeader.addElement(".21");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".09");
		dHeader.addElement(".12");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	String groupBy = "",subGroupBy = "";
	int totalSeccion=0,totalUnidad=0;	 
	boolean delSubGrupo = false;
	int meses =0;
	double totSec=0.00,totDepto=0.00,totalRep=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (i == 0)
		{
			if (cdo.getColValue("meses")!= null && !cdo.getColValue("meses").trim().equals("") )
			meses = Integer.parseInt(cdo.getColValue("meses"));
		}
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")))
		{
			if (i != 0)
			{			
			  pc.setFont(9, 1,Color.blue);
			  pc.addCols("   TOTAL  POR  SECCION  ",0,2);
			  pc.addCols(" "+totalSeccion,0,1);
			  pc.addCols(" "+CmnMgr.getFormattedDecimal(totSec),2,1);
			  pc.addCols(" ",0,4);
			   
			  pc.addCols(" ",0,dHeader.size());
			  pc.setFont(9, 1,Color.red);
			  pc.addCols("TOTAL  POR  DEPARTAMENTO  ",0,2);
			  pc.addCols(" "+totalUnidad,0,1);
			  pc.addCols(" "+CmnMgr.getFormattedDecimal(totDepto),2,1);
			  pc.addCols(" ",0,4);
			  
			  totSec=0.00;
			  totDepto=0.00;
			  
			  totalSeccion=0;
			  totalUnidad =0;
			  pc.addCols(" ",0,dHeader.size());
			  pc.flushTableBody(true);
			  if(delSubGrupo)pc.deleteRows(-3);
			  else{delSubGrupo = false; pc.deleteRows(-1);	}
			  
			   //agrega la unidad al encabezado en memoria				
				pc.setFont(9, 1,Color.blue);		
			    pc.addCols("DEPARTAMENTO: ",0,1);
			    pc.addCols(" "+cdo.getColValue("unidad")+"    "+cdo.getColValue("departamento"),0,7);   				
				//agrega la familia al encabezado en memoria										 
				pc.setFont(9, 1,Color.red);
				pc.addCols("   SECCION ",0,1);
				pc.addCols(" "+cdo.getColValue("seccion")+" - "+cdo.getColValue("seccionDesc"),0,7);
				
				
				//pc.setFont(9, 1,Color.blue);
				//pc.addCols(" Entrega x",0,1); 
				
				pc.setFont(7, 1);
				pc.addCols("No",1,1);
				pc.addCols("NOMBRE DEL EMPLEADO",1,1);
				pc.addCols("CARGO O FUNCION",1,1);
				pc.addCols("SALARIO ",1,1);	
				pc.addCols("GASTO DE REP.",1,1);
				pc.addCols("R x H",1,1);
				pc.addCols("FECHA INGRESO",1,1);
				pc.addCols("ANTIGUEDAD AA-MM-DD",1,1);
				
			 }			 
			    
					
				pc.setFont(9, 0,Color.blue);
				pc.addCols("DEPARTAMENTO: ",0,1);		
			    pc.addCols(" "+cdo.getColValue("unidad")+"    "+cdo.getColValue("departamento"),0,7); 
					 
				pc.setFont(9, 1,Color.red);
				pc.addCols("   SECCION ",0,1);
				pc.addCols(" "+cdo.getColValue("seccion")+" - "+cdo.getColValue("seccionDesc"),0,7);
							 
			 	pc.setFont(7, 1);
				pc.addCols("No",1,1);
				pc.addCols("NOMBRE DEL EMPLEADO",1,1);
				pc.addCols("CARGO O FUNCION",1,1);
				pc.addCols("SALARIO ",1,1);	
				pc.addCols("GASTO DE REP.",1,1);
				pc.addCols("R x H",1,1);
				pc.addCols("FECHA INGRESO",1,1);
				pc.addCols("ANTIGUEDAD AA-MM-DD",1,1);	
				pc.setTableHeader(4);		
			/* if  (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+ cdo.getColValue("seccion")))
				{							
					pc.setFont(9, 1,Color.blue);
					pc.addCols(" Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);			
					pc.addCols(" Entrega No :",2,1);
					pc.addCols(""+cdo.getColValue("no_entrega"),0,2);						
				}	*/	 
			 
			}else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+ cdo.getColValue("seccion")))
			 {			 
			    pc.setFont(9, 1,Color.blue);
				pc.addCols("   TOTAL  POR  SECCION  ",0,2);
				pc.addCols(" "+totalSeccion,0,1); 
			  	pc.addCols(" "+CmnMgr.getFormattedDecimal(totSec),2,1);
			 	pc.addCols(" ",0,5);			  
				
				pc.addCols(" ",0,dHeader.size());
				totalSeccion =0;
				totSec=0.00;
			    pc.flushTableBody(true);
			    pc.deleteRows(-3);				
				delSubGrupo = true;				
				
				pc.setFont(9, 0,Color.blue);
				pc.addCols("DEPARTAMENTO: ",0,1);		
			    pc.addCols(" "+cdo.getColValue("unidad")+"    "+cdo.getColValue("departamento"),0,7); 
					 
				pc.setFont(9, 1,Color.red);
				pc.addCols("   SECCION ",0,1);
				pc.addCols(" "+cdo.getColValue("seccion")+" - "+cdo.getColValue("seccionDesc"),0,7);
									 				
				pc.setFont(7, 1);
				pc.addCols("No",1,1);
				pc.addCols("NOMBRE DEL EMPLEADO",1,1);
				pc.addCols("CARGO O FUNCION",1,1);
				pc.addCols("SALARIO ",1,1);	
				pc.addCols("GASTO DE REP.",1,1);
				pc.addCols("R x H",1,1);
				pc.addCols("FECHA INGRESO",1,1);
				pc.addCols("ANTIGUEDAD AA-MM-DD",1,1);		
				//System.out.println(" getTableSize.pdfHeader =="+pc.getTableHeader());
				//System.out.println(" getTableSize =="+pc.getTableSize());
				
				pc.setFont(9, 1,Color.red);
				pc.addCols("   SECCION ",0,1);
				pc.addCols(" "+cdo.getColValue("seccion")+" - "+cdo.getColValue("seccionDesc"),0,7);
									 				
				pc.setFont(7, 1);
				pc.addCols("No",1,1);
				pc.addCols("NOMBRE DEL EMPLEADO",1,1);
				pc.addCols("CARGO O FUNCION",1,1);
				pc.addCols("SALARIO ",1,1);	
				pc.addCols("GASTO DE REP.",1,1);
				pc.addCols("R x H",1,1);
				pc.addCols("FECHA INGRESO",1,1);
				pc.addCols("ANTIGUEDAD AA-MM-DD",1,1);
						
			  }
			  
			pc.setFont(8, 0);  
			pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("num_empleado"),1,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);
	  		pc.addCols(" "+cdo.getColValue("denominacion"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("salario")),1,1);
	    	pc.addCols(" "+cdo.getColValue("gasto"),1,1);
			pc.addCols(" "+cdo.getColValue("rata"),1,1);
	    	pc.addCols(" "+cdo.getColValue("fecha_ingreso"),1,1);
			pc.addCols(" "+cdo.getColValue("edad")+" - "+cdo.getColValue("edad_mes")+" - "+cdo.getColValue("edad_dias"),1,1);
			
			totalSeccion ++;
			totalUnidad ++;
			
			totSec   += Double.parseDouble(cdo.getColValue("salario"));
			totDepto += Double.parseDouble(cdo.getColValue("salario"));
			totalRep += Double.parseDouble(cdo.getColValue("salario"));
			
			subGroupBy = cdo.getColValue("unidad")+"-"+ cdo.getColValue("seccion");
			groupBy    = cdo.getColValue("unidad");
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}//for i
	
	if (al.size() == 0)
	 {
	   pc.addCols("No existen registros",1,dHeader.size());
	  }else{	    
		pc.setFont(9, 0);
		pc.addCols(" ",0,dHeader.size()); 
		pc.setFont(9, 1,Color.blue);
		pc.addCols("   TOTAL  POR  SECCION : ",0,2);
		pc.addCols(" "+totalSeccion,0,1); 
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totSec),2,1);
		pc.addCols(" ",0,4);	
			
		pc.setFont(9, 1,Color.red);			
		pc.addCols("TOTAL  POR  DEPARTAMENTO : ",0,2);
		pc.addCols(" "+totalUnidad,0,1); 
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totDepto),2,1);
		pc.addCols(" ",0,4);
		
		pc.setFont(9, 1,Color.blue);
		pc.addCols(" TOTAL DE EMPLEADOS. . .  "+al.size(),0,2);
		pc.addCols(" ",0,1); 
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalRep),2,1);
		pc.addCols(" ",0,4);
		
		pc.setFont(9, 1,Color.red);
		if(!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) 
		pc.addCols(" TOTAL DE MESES INVOLUCRADOS . . .  "+meses,0,dHeader.size());
		
		if (almes.size() != 0)
		{
			
			pc.flushTableBody(true);
			    pc.deleteRows(-3);		
				
			pc.setFont(9, 1,Color.blue);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" ",0,1);
			pc.addCols(" R E S U M E N ",1,4);
			pc.addCols(" ",0,3);
			
			pc.addCols(" ",0,1);
			pc.addCols("AÑO",0,1);
			pc.addCols("MES ",0,1);
			pc.addCols("INGRESOS ",0,2);
			pc.addCols(" ",0,3);
			
			pc.addCols(" R E S U M E N ",1,dHeader.size());
			pc.setFont(9, 1);
			int totalMes=0;
			for (int i=0; i<almes.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) almes.get(i);
				pc.addCols(" ",0,1);
				pc.addCols(" "+cdo.getColValue("anio_ing"),0,1);				
				pc.addCols(" "+cdo.getColValue("desc_mes"),0,1);
				pc.addCols(" "+cdo.getColValue("cantidad"),0,2);
				pc.addCols(" ",0,3);
				totalMes +=  Integer.parseInt(cdo.getColValue("cantidad"));
			}
				pc.setFont(9, 1,Color.red);
				pc.addCols(" ",0,1);
				pc.addCols(" ",0,1);
				pc.addCols(" TOTAL ===>> ",0,1);
				pc.addCols(" "+totalMes,0,2);
				pc.addCols(" ",0,3);
		
		}
		
		
	  }
		
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);	
	
}//get
%>
