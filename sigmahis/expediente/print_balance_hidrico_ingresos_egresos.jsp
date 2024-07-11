<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
<!-- Desarrollado por: José A. Acevedo C.     -->
<!-- EXPEDIENTE                               -->
<!-- Reporte: "BALANCE HIDRICO INGRESOS / EGRESOS" -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 18/05/2010                        -->    

<%
/**
==================================================================================
Reporte sal10080
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);  

ArrayList al  = new ArrayList();
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

ArrayList alTi = new ArrayList();
ArrayList alTe = new ArrayList();
ArrayList alHi = new ArrayList();
ArrayList alHe = new ArrayList();

ArrayList alHitt = new ArrayList();
ArrayList alHett = new ArrayList();

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaEval = request.getParameter("fecha");
String fg = request.getParameter("fg");
String cds = request.getParameter("cds");

String descSala ="",filter="";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am"); 

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

//filter= " and to_date(to_char(a.fecha_orden,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha.substring(0,10)+"','dd/mm/yyyy')";
if (appendFilter == null) appendFilter = "";
if (fechaEval == null) fechaEval = "";

if (!fechaEval.trim().equals(""))
appendFilter += " and to_date(to_char(b.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaEval+"', 'dd/mm/yyyy')" ;

/*-----Query para Obtener los Datos de Ingresos(fluidos) Aplicados al Paciente-----*/
sql = " select codigo codVia, substr(descripcion,0,8)||'.' descVia "
+" from tbl_sal_via_admin v "
+" where tipo_liquido in('I') order by tipo_liquido desc,codigo ";
al3 = SQLMgr.getDataList(sql);


/*-----Query para Obtener los Datos de Egresos(fluidos) del Paciente-----*/
sql = " select codigo codVia, substr(descripcion,0,8)||'.' descVia "
+" from tbl_sal_via_admin v "
+" where tipo_liquido in('E') order by tipo_liquido desc,codigo ";
al4 = SQLMgr.getDataList(sql);

/***********************************************************************/
/*-----Query para Obtener los Titulos de las columnas   INGRESOS  -----*/
sql = " select rownum colNum, codigo as codVia, descripcion as via_admin"
+"  from tbl_sal_via_admin "
+"  where tipo_liquido = 'I' order by rownum ";
alTi = SQLMgr.getDataList(sql);

/*-----Hora y Cantidad suministrada  INGRESOS -----*/
sql= "select to_char (b.fecha,'dd/mm/yyyy') fecha, to_char(b.hora,'hh12:mi am') as hora, /*b.fluido,*/ c.colNum, b.via_administracion, sum(cantidad*1) as cantidad  "
+ " from tbl_sal_detalle_balance b, (select rownum colNum, codigo as codVia, descripcion as via_admin  from tbl_sal_via_admin  where tipo_liquido = 'I'  order by rownum) c "
+ " where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter+" and b.via_administracion = c.codVia "
+ " group by  to_char (b.fecha,'dd/mm/yyyy'), to_char(b.hora,'hh12:mi am'),  c.colNum, /*b.fluido  , */ b.via_administracion order by /*to_char(b.hora,'hh12 am') asc*/ 2 asc,  c.colNum/*, b.fluido*/ asc ";
alHi = SQLMgr.getDataList(sql);

/*-----Totales  INGRESOS x columna-----*/
sql = " select  colNum, a.codVia, a.via_admin, sum(b.cantidad) cantidad "
+" from (select rownum colNum, codigo as codVia, descripcion as via_admin, tipo_liquido "
+" from tbl_sal_via_admin where tipo_liquido = 'I' order by rownum) a, "
+" (select  b.via_administracion, sum(cantidad*1) as cantidad from tbl_sal_detalle_balance b "
+" where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter
+" group by   b.via_administracion) b "
+" where a.tipo_liquido = 'I' and a.codVia = b.via_administracion(+) "
+" group by a.colNum, a.codVia, a.via_admin "
+"order by  a.colNum ";
alHitt = SQLMgr.getDataList(sql);

/************************************************************************************************************/
/*-----Query para Obtener los Titulos de las columnas   EGRESOS  ------------------------------------------*/
sql = " select rownum colNum, codigo as codVia, descripcion as via_admin"
+"  from tbl_sal_via_admin "
+"  where tipo_liquido = 'E' order by rownum ";
alTe = SQLMgr.getDataList(sql);

/*-----Hora y Cantidad suministrada  EGRESOS -----*/
sql= "select to_char (b.fecha,'dd/mm/yyyy') fecha, to_char(b.hora,'hh12:mi am') as hora, /*b.fluido,*/ c.colNum, b.via_administracion, sum(cantidad * -1) as cantidad  "
+ " from tbl_sal_detalle_balance b, (select rownum colNum, codigo as codVia, descripcion as via_admin  from tbl_sal_via_admin  where tipo_liquido = 'E'  order by rownum) c "
+ " where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter+" and b.via_administracion = c.codVia "
+ " group by  to_char (b.fecha,'dd/mm/yyyy'), to_char(b.hora,'hh12:mi am'),  c.colNum, /*b.fluido  , */ b.via_administracion order by /*to_char(b.hora,'hh12 am')*/  2 asc,  c.colNum/*, b.fluido*/ asc ";
alHe = SQLMgr.getDataList(sql);


/*sql = " select rownum colNum, a.codigo as codVia, a.descripcion as via_admin, (b.cantidad * -1) cantidad"
+" from tbl_sal_via_admin a, (select  b.via_administracion, sum(cantidad*1) as cantidad from tbl_sal_detalle_balance b "
+" where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter
+" group by b.via_administracion) b "
+" where a.tipo_liquido = 'E' and a.codigo = b.via_administracion(+) "
+" order by   a.codigo asc ";
alHett = SQLMgr.getDataList(sql); */

/*-----Totales  EGRESOS x columna-----*/
sql = " select  colNum, a.codVia, a.via_admin, sum(b.cantidad * -1) cantidad "
+" from (select rownum colNum, codigo as codVia, descripcion as via_admin, tipo_liquido "
+" from tbl_sal_via_admin where tipo_liquido = 'E' order by rownum) a, "
+" (select  b.via_administracion, sum(cantidad*1) as cantidad from tbl_sal_detalle_balance b "
+" where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter
+" group by   b.via_administracion) b "
+" where a.tipo_liquido = 'E' and a.codVia = b.via_administracion(+) "
+" group by a.colNum, a.codVia, a.via_admin "
+"order by  a.colNum ";
alHett = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float height = 72 * 14f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "BALANCE HIDRICO";
	String subtitle = "INGRESOS / EGRESOS";
	String xtraSubtitle = "(8.5 x 14)";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	int num = 0;
	if (al3.size() >= al4.size()) 
	       num = al3.size();
	  else num= al4.size();
	 
	float column = (100f-((num+1) / 4))/ (num+1);
	
	Vector dHeader = new Vector();
	
	for (int j=0; j<num+1; j++) 
	{
		dHeader.addElement(""+column);
		dHeader.addElement("0.01");
	}
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);
	
	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");
	
	Vector detCol = new Vector();
		detCol.addElement(".04");
		detCol.addElement(".32");
		detCol.addElement(".04");
	Vector detCol1 = new Vector();
		detCol1.addElement(".40");
	Vector detCol2 = new Vector();
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");

      Vector infoCol2 = new Vector();
		infoCol2.addElement(".70");
		infoCol2.addElement(".30");
		
	  Vector infoCol3 = new Vector();
		infoCol3.addElement(".80");
		infoCol3.addElement(".20");
		
double totalIngresos = 0;	
double totalEgresos  = 0;
double totalBalance  = 0;		


/*---Ciclo que Muestra los INGRESOS(fluidos)---*/
for (int j=0; j<al3.size(); j++) 
{ //Inicio -INGRESOS-	
	 CommonDataObject cdo3 = (CommonDataObject) al3.get(j);
  sql = 
   " select sum(cantidad) as cantidad, to_char (b.fecha,'dd/mm/yyyy') fecha, to_char(b.hora,'hh12:mi am') as hora, b.fluido "
   +" from tbl_sal_detalle_balance b "
   +" where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter+ " and "
   +" b.via_administracion = "+cdo3.getColValue("codVia")
   +" group by  to_char (b.fecha,'dd/mm/yyyy'), to_char(b.hora,'hh12:mi am'), b.fluido "
   +" order by to_char(b.hora,'hh12:mi am') asc ";
		
	al2 = SQLMgr.getDataList(sql);

	 pc.resetVAlignment();
	 pc.setNoColumnFixWidth(infoCol2);
	 pc.createTable("ingresos"+cdo3.getColValue("codVia"),false,0,900);
	 pc.addBorderCols(""+cdo3.getColValue("descVia"),1,2,Color.lightGray);
	 pc.setFont(6, 0);
	 pc.addBorderCols("HORA",1,1); //FECHA
	 pc.addBorderCols("CANT",1,1);
				
	  for (int i=0; i<al2.size(); i++) 
		{	
		  CommonDataObject cdo2 = (CommonDataObject) al2.get(i);
			pc.setFont(7, 0);
			pc.addBorderCols(""+cdo2.getColValue("hora")+" "+cdo2.getColValue("fluido"),0,1);
			pc.addBorderCols(""+cdo2.getColValue("cantidad"),1,1);			

			totalIngresos += Double.parseDouble(cdo2.getColValue("cantidad"));
		}		
		
} //Fin -INGRESOS-


/*---Ciclo que Muestra los EGRESOS(fluidos)---*/
for (int j=0; j<al4.size(); j++) 
{//Inicio -EGRESOS-	
	 CommonDataObject cdo4 = (CommonDataObject) al4.get(j);
	sql = 
	" select sum(cantidad*-1) as cantidad, to_char (b.fecha,'dd/mm/yyyy') fecha, to_char(b.hora,'hh12:mi am') as hora, b.fluido "
		+" from tbl_sal_detalle_balance b "
		+" where b.pac_id = "+pacId+" and b.adm_secuencia = "+noAdmision+appendFilter+ " and "		
		+" b.via_administracion = "+cdo4.getColValue("codVia")
		+" group by  to_char (b.fecha,'dd/mm/yyyy'), to_char(b.hora,'hh12:mi am'), b.fluido "
		+" order by to_char(b.hora,'hh12:mi am') asc ";
		
		al5 = SQLMgr.getDataList(sql);

	pc.resetVAlignment();
	pc.setNoColumnFixWidth(infoCol2);
	pc.createTable("egresos"+cdo4.getColValue("codVia"),false,0,900);
	pc.addBorderCols(""+cdo4.getColValue("descVia"),1,2,Color.lightGray);
	pc.setFont(6, 0);
	pc.addBorderCols("HORA",1,1); //FECHA
	pc.addBorderCols("CANT",1,1);
							
		for (int i=0; i<al5.size(); i++) 
		{	
	      CommonDataObject cdo5 = (CommonDataObject) al5.get(i);
		    pc.setFont(7, 0);
		    pc.addBorderCols(""+cdo5.getColValue("hora")+" "+cdo5.getColValue("fluido"),1,1);
		    pc.addBorderCols(""+cdo5.getColValue("cantidad"),1,1);
			
			totalEgresos += Double.parseDouble(cdo5.getColValue("cantidad"));
		}		   
} //Fin -EGRESOS-	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
    pc.setVAlignment(0);								
	
		//second row
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table		


//*************************************************************//
//********************** INGRESOS ******************************//		
	pc.setFont(9, 1);
	pc.addBorderCols("INGRESOS",1,dHeader.size(),Color.lightGray);

	// TITULOS
	pc.addBorderCols(" HORA ",1,1);
	pc.addBorderCols(" ",1,1);
	for (int t=0; t<num; t++) 
	{
		CommonDataObject cdoTi = (CommonDataObject) alTi.get(t);
		 pc.setFont(6, 0);
		 if (t<alTi.size())
		 {
			pc.addBorderCols(cdoTi.getColValue("via_admin"),1,1); //FECHA
			pc.addBorderCols(" ",1,1);
		 } 
		 else 
		 {
			pc.addBorderCols(" ",1,1); //FECHA
			pc.addBorderCols(" ",1,1);
		 }
	 }
	
	// DETALLE
	String groupBy = " ";
	int colX = 2;
	int colY = 0;
	int totalAdminis = 0;		
	for (int h=0; h<alHi.size(); h++) 
	{
		CommonDataObject cdoHi = (CommonDataObject) alHi.get(h);
		 pc.setFont(7, 0);
		 
		 if (!groupBy.trim().equalsIgnoreCase(cdoHi.getColValue("hora")))
		 {
		 	// imprimir espacios en blanco al final de una hora			
			if ((!groupBy.trim().equals(" ")) && (!groupBy.trim().equalsIgnoreCase(cdoHi.getColValue("hora"))) && ((colY+2)<= num+1) && (colY > 0) )
			{							
				for (int f=((colY+1)+1); f<=num+1; f++)
				{
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
				}
			}
			
			// imprimir columna de hora
			pc.setFont(9, 0);
			pc.addBorderCols(cdoHi.getColValue("fecha")+" "+cdoHi.getColValue("hora"),1,1);
			pc.addBorderCols(" ",1,1);
			colX=2;
		 } 
		 
		 colY = Integer.parseInt(cdoHi.getColValue("colNum"));
		 // ciclo para imprimir las cantidad en la columna que corresponde
		 
		 for (int c=colX; c<=(colY+1); c++ )
		 {
		 	if (c == (colY+1) )
			{
			    pc.setFont(9, 0);
				pc.addBorderCols(cdoHi.getColValue("cantidad"),1,1);
				pc.addBorderCols(" ",1,1);	
				//totalAdminis = totalAdminis + Integer.parseInt(cdoHi.getColValue("cantidad"));			
			} else 
			{
				pc.addBorderCols(" ",1,1);
				pc.addBorderCols(" ",1,1);
			}
			
		 }
		
		colX = ((colY+1)+1);
		
		groupBy = cdoHi.getColValue("hora");	 		
	}
	
	// rellenar columnas en blanco para el ultimo registro del arreglo alH
	if (((colY+2)<= num+1) && (colY > 0))
	{							
		for (int f=((colY+1)+1); f<=num+1; f++)
		{
			pc.addBorderCols(" ",1,1);
			pc.addBorderCols(" ",1,1);
		}
	}
	// fin del ciclo que imprime los ingresos
	

//**************************** TOTALES INGRESOS ****************************//
pc.setFont(8, 1);
pc.addBorderCols("TOTALES",1,1);   
pc.addBorderCols(" ",1,1);
colX = 2; 
colY = 0;
for (int t=0; t<alHitt.size(); t++) 
	{
		CommonDataObject cdoTit = (CommonDataObject) alHitt.get(t);
		 pc.setFont(6, 0);		 		 
		 //System.out.println("colY ...."+colY+"  ;  colX....."+colX);				 
				
		 if (t<alHitt.size())		 
		 {	
		    pc.setFont(9, 1);	
			pc.addBorderCols(cdoTit.getColValue("cantidad"),1,1); 		
			pc.addBorderCols(" ",1,1);  
		 } 
		 else 
		 {
			pc.addBorderCols(" ",1,1); 
			pc.addBorderCols(" ",1,1);
		 }	 		
	 }
	
		

//*************************************************************//
//********************** EGRESOS ******************************//
	pc.setFont(9, 1);
	pc.addCols("  ",0,dHeader.size());
	pc.addBorderCols("EGRESOS",1,dHeader.size(),Color.lightGray);

	// TITULOS
	pc.addBorderCols(" HORA ",1,1);
	pc.addBorderCols(" ",1,1);
	for (int t=0; t<alTe.size(); t++) 
	{
		CommonDataObject cdoTe = (CommonDataObject) alTe.get(t);
		 pc.setFont(6, 0);
		 if (t<alTe.size())
		 {
			pc.addBorderCols(cdoTe.getColValue("via_admin"),1,1); //FECHA
			pc.addBorderCols(" ",1,1);
		 } 
		 else 
		 {
			pc.addBorderCols(" ",1,1); 
			pc.addBorderCols(" ",1,1);
		 }
	}
	
	// validar la cantidad de columna de egresos vs ingresos, si es menor rellenar con espacios en blanco	
	if (alTi.size() > alTe.size())
	{
		for ( int i=alTe.size(); i<alTi.size(); i++)
		{
			pc.addBorderCols(" ",1,1); 
			pc.addBorderCols(" ",1,1);
		}
	}
		
	
	// DETALLE
	groupBy = " ";
	colX = 2;
	colY = 0;
	for (int h=0; h<alHe.size(); h++) 
	{
		CommonDataObject cdoHe = (CommonDataObject) alHe.get(h);
		 pc.setFont(6, 0);
		 
		 if (!groupBy.trim().equalsIgnoreCase(cdoHe.getColValue("hora")))
		 {
		 	// imprimir espacios en blanco al final de una hora
			//System.out.println("Group by ...."+groupBy+"  ;  colY....."+colY+"  ;  num ..."+num);
			if ((!groupBy.trim().equals(" ")) && (!groupBy.trim().equalsIgnoreCase(cdoHe.getColValue("hora"))) && ((colY+2)<= num+1) && (colY > 0) )
			{							
				for (int f=((colY+1)+1); f<=num+1; f++)
				{
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
				}
			}
			
			// imprimir columna de hora
			pc.setFont(9, 0);
			pc.addBorderCols(cdoHe.getColValue("fecha")+" "+cdoHe.getColValue("hora"),1,1);
			pc.addBorderCols(" ",1,1);
			colX=2;
		 } 
		 
		 colY = Integer.parseInt(cdoHe.getColValue("colNum"));
		 // ciclo para imprimir las cantidad en la columna que corresponde
		 
		 for (int c=colX; c<=(colY+1); c++ )
		 {
		 	if (c == (colY+1) )
			{
			    pc.setFont(9, 0);
				pc.addBorderCols(cdoHe.getColValue("cantidad"),1,1);
				pc.addBorderCols(" ",1,1);
			} else 
			{
				pc.addBorderCols(" ",1,1);
				pc.addBorderCols(" ",1,1);
			}
			
		 }
		
		colX = ((colY+1)+1);
		
		groupBy = cdoHe.getColValue("hora");		
		
	}
	
	// rellenar columnas en blanco para el ultimo registro del arreglo alH
	if (((colY+2)<= num+1) && (colY > 0))
	{							
		for (int f=((colY+1)+1); f<=num+1; f++)
		{
			pc.addBorderCols(" ",1,1);
			pc.addBorderCols(" ",1,1);
		}
	}
	// fin del ciclo que imprime los egresos
	


//**************************** TOTALES EGRESOS ****************************//
pc.setFont(8, 1);
pc.addBorderCols("TOTALES",1,1);   
pc.addBorderCols(" ",1,1);
colX = 2; 
colY = 0;
for (int t=0; t<alHett.size(); t++) 
	{
		CommonDataObject cdoTet = (CommonDataObject) alHett.get(t);
		 pc.setFont(6, 0);		 		 
		 //System.out.println("t ...."+t+"  ;  num....."+num);
		 colY = Integer.parseInt(cdoTet.getColValue("colNum"));		
				
		 if (t<alHett.size())		 
		 {	
		    pc.setFont(9, 1);	
			pc.addBorderCols(cdoTet.getColValue("cantidad"),1,1); 		
			pc.addBorderCols(" ",1,1);  
		 } 
		 else 
		 {
			pc.addBorderCols(" ",1,1); 
			pc.addBorderCols(" ",1,1);
		 }			
	 }
	
	// rellenar columnas en blanco para el ultimo registro del arreglo alH
	if (((colY+2)<= num+1) && (colY > 0))
	{							
		for (int f=((colY+1)+1); f<=num+1; f++)
		{
			pc.addBorderCols(" ",1,1);
			pc.addBorderCols(" ",1,1);
		}
	}
	// fin del ciclo que imprime los egresos




//******************************************************************************************			
/*

	for (int k=0; k<al3.size(); k++) 
	  {	
		CommonDataObject cdo3 = (CommonDataObject) al3.get(k);		
		 pc.resetVAlignment();
		 pc.setFont(9, 1);
		 pc.addTableToCols("ingresos"+cdo3.getColValue("codVia"),0,1);					
		 pc.addCols(" ",0,1);
		 pc.setVAlignment(0);
	  }
	  
	pc.addCols("  ",0,dHeader.size());			
	pc.setFont(9, 1);
	pc.addBorderCols("EGRESOS",1,dHeader.size(),Color.lightGray);
		
	 for (int k=0; k<al4.size(); k++) 
	  {	
		CommonDataObject cdo4 = (CommonDataObject) al4.get(k);	
		  pc.resetVAlignment();
		  pc.setFont(9, 1);
		  pc.addTableToCols("egresos"+cdo4.getColValue("codVia"),0,1);					
		  pc.addCols(" ",0,1);
		  pc.setVAlignment(0);
	   }
*/	   
	totalBalance = totalIngresos + totalEgresos;
	   
	pc.addCols("  ",0,dHeader.size());  			
	pc.setFont(10, 1);
	pc.addCols("  ",0,dHeader.size());
	pc.addCols("Total Ingresos:  "+totalIngresos,0,dHeader.size()); 
	pc.addCols("Total Egresos:   "+totalEgresos,0,dHeader.size()); 
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addCols("B A L A N C E:  "+totalBalance,0,dHeader.size(),Color.lightGray,0.0f,0.5f,0.0f,0.0f); 

	pc.addCols("  ",0,dHeader.size());	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

