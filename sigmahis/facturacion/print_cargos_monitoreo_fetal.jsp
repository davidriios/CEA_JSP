<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Tirza Monteza.                          -->
<!-- Reporte: Pacientes nacionales y no nacionales             -->
<!-- Reporte: ADM3082                                          -->
<!-- Clínica Hospital San Fernando                             -->
<!-- Fecha: 12/07/2010                                         -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String compania 			 = (String) session.getAttribute("_companyId");

String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";
String appendFilter2 = "";
String appendFilter3 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1+= " and x.compania = "+compania;
   appendFilter2+= " and b.compania = "+compania;
   appendFilter3+= " and y.compania = "+compania;
  }
if (!fechaini.equals(""))
   {
    appendFilter1 += " and x.fecha >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
    appendFilter2 += " and b.fecha_creacion >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
    appendFilter3 += " and y.fecha_ingreso >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and x.fecha <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   appendFilter2 += " and b.fecha_creacion <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de admisiones facturadas--------------------------------//
sql = "select s.anio, s.tipo, s.descripcion, s.codigo, s.monto_total, s.cant_item, s.cant_partos from ( /***cargos por uso >>>>***/ select to_char(x.fecha,'YYYY') anio, 'OTROS' tipo , a.descripcion descripcion, a.cod_otro codigo, sum(a.cantidad*a.monto) monto_total,  count(a.cod_otro) cant_item, 0 cant_partos from  tbl_fac_cargo_cliente x, tbl_fac_detc_cliente a where a.cod_otro in (20,49,48) and x.compania = a.compania and x.anio = a.anio  and  x.codigo = a.cargo  and  x.tipo_transaccion = a.tipo_transaccion  "+appendFilter1+"  group by  to_char(x.fecha,'YYYY'),  a.descripcion, a.cod_otro,'OTROS' /* >>> */ union /* <<< */ /*** cargos hospital***/  select to_char(b.fecha_creacion,'YYYY')años, 'ADMISION' , b.descripcion, b.cod_uso codigo, sum(decode(b.tipo_transaccion,'D',-(b.cantidad*b.monto),'C',(b.cantidad*b.monto)))total_transacc, count(b.cod_uso) cant_item, count(atn_mat.fecha_nacimiento||atn_mat.codigo_paciente)cant_partos   from  tbl_fac_detalle_transaccion b , ( select distinct y.fecha_nacimiento ,y.codigo_paciente  from  tbl_adm_admision y  where y.categoria = 1  and  y.tipo_admision = 3  and  y.estado <> 'A'  "+appendFilter3+" ) atn_mat  where  b.cod_uso in (44)  "+appendFilter2+" and  b.fac_fecha_nacimiento = atn_mat.fecha_nacimiento(+)  and   b.fac_codigo_paciente  = atn_mat.codigo_paciente(+) group by to_char(b.fecha_creacion,'YYYY'),  b.descripcion,b.cod_uso,'ADMISION') s  order by s.anio, s.tipo, s.descripcion, s.codigo ";
al = SQLMgr.getDataList(sql);

System.out.println("SQL > > > > > > > >  "+sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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

  String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String title = "FACTURACION";
	String subtitle = "RESUMEN DE CARGOS POR MONITOREO FETAL EN PACIENTES ADMITIDOS Y OTROS";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".45");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");

	Vector infoCol = new Vector();
		infoCol.addElement(".10");
		infoCol.addElement(".45");
		infoCol.addElement(".15");
		infoCol.addElement(".15");
		infoCol.addElement(".15");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(2);

	String groupByAnio	= "";	// para agrupar por tipo de residencia
	String groupByTipo  = "";	// para agrupar por fecha de ingreso
	int cantCodigos = 0;
	int anioCantC = 0,  anioCantPar = 0;				// para la cantidad de pacientes por tipo de residencia
	int	tipoCantC = 0,  tipoCantPar = 0;				// para la cantidad de pacientes por fecha ingreso
	int finCantC = 0,   finCantPar = 0;				// para la cantidad de pacientes por tipo de residencia
	double anioConsumo = 0, tipoConsumo = 0, finConsumo = 0;    // totales por tipo de residencia
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);

		// Agrupar tipo de residencia
		if (!groupByAnio.trim().equalsIgnoreCase(cdo.getColValue("anio")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0)  // imprime total de pactes
					{
						// totales tipo
						pc.setFont(8, 0,Color.black);
						pc.addCols("Cant. de Códigos Utilizados: . . . . . . . "+cantCodigos,0,5);
						pc.setFont(8, 1,Color.black);
						pc.addCols("SubTotal: . . . . ",2,4);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tipoConsumo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);

						// totales por tipo de residencia
						pc.addCols("SUB-TOTALES POR AÑO:",1,2);
						pc.addCols("Total Consumido x Año: . . . . . . ",2,2,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",anioConsumo),2,1);
						pc.addCols("Cat.Total de Cargos: . . . . . . . ",2,4,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0",anioCantC),2,1);
						pc.addCols("Cat.Total de Partos Atendidos:  . . ",2,4,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0",anioCantPar),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols("Año :"+cdo.getColValue("anio"),0,dHeader.size(),cHeight);
					pc.addBorderCols("Código#",1,1);
					pc.addBorderCols("Descripción",1,1);
					pc.addBorderCols("Cant.Cargos",1,1);
					pc.addBorderCols("Partos Atendidos",1,1);
					pc.addBorderCols("Total Consumido",1,1);

					cantCodigos = 0;
					tipoConsumo = 0;
					tipoCantC 	= 0;
				  tipoCantPar = 0;
					anioConsumo = 0;
					anioCantC 	= 0;
					anioCantPar = 0;
		}

		// Agrupar por tipo (otros o admision)
		if (!groupByTipo.trim().equalsIgnoreCase(cdo.getColValue("tipo")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0 && tipoCantC != 0)  // imprime total de pactes por centro
					{
						// totales por tipo
						pc.setFont(8, 0,Color.black);
						pc.addCols("Cant. de Códigos Utilizados: . . . . . . . "+cantCodigos,0,5);
						pc.setFont(8, 1,Color.black);
						pc.addCols("SubTotal: . . . . ",2,4);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tipoConsumo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols("Capturado por: "+cdo.getColValue("tipo"),0,dHeader.size(),cHeight);
					cantCodigos = 0;
					tipoConsumo = 0;
					tipoCantC 	= 0;
				  tipoCantPar = 0;
		}


		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("codigo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0",cdo.getColValue("cant_item")),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0",cdo.getColValue("cant_partos")),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("monto_total")),2,1);

		cantCodigos ++;

		// valores por tipo de atencion (otros o admision)
		tipoConsumo += Double.parseDouble(cdo.getColValue("monto_total"));
		tipoCantC 	+= Integer.parseInt(cdo.getColValue("cant_item"));
	  tipoCantPar += Integer.parseInt(cdo.getColValue("cant_partos"));

		// valores por año
		anioConsumo += Double.parseDouble(cdo.getColValue("monto_total"));
		anioCantC 	+= Integer.parseInt(cdo.getColValue("cant_item"));
	  anioCantPar += Integer.parseInt(cdo.getColValue("cant_partos"));

		// valores finales
		finConsumo += Double.parseDouble(cdo.getColValue("monto_total"));
		finCantC 	 += Integer.parseInt(cdo.getColValue("cant_item"));
	  finCantPar += Integer.parseInt(cdo.getColValue("cant_partos"));

		groupByAnio = cdo.getColValue("anio");
		groupByTipo = cdo.getColValue("tipo");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(8, 1,Color.black);

			// totales por tipo
			pc.setFont(8, 0,Color.black);
			pc.addCols("Cant. de Códigos Utilizados: . . . . . . . "+cantCodigos,0,5);
			pc.setFont(8, 1,Color.black);
			pc.addCols("SubTotal: . . . . "+CmnMgr.getFormattedDecimal("###,##0.00",tipoConsumo),2,4);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tipoConsumo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// totales por tipo de residencia
			pc.addCols("SUB-TOTALES POR AÑO:",1,2);
			pc.addCols("Total Consumido x Año: . . . . . . ",2,2,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",anioConsumo),2,1);
			pc.addCols("Cat.Total de Cargos: . . . . . . . ",2,4,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0",anioCantC),2,1);
			pc.addCols("Cat.Total de Partos Atendidos:  . . ",2,4,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0",anioCantPar),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	    //Totales Finales
			pc.addCols("RESUMEN GENERAL:",1,2);
			pc.addCols("GRAN TOTAL CONSUMIDO: . . . . . . ",2,2,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finConsumo),2,1);
			pc.addCols("GRAN TOTAL DE CARGOS: . . . . . . . ",2,4,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0",finCantC),2,1);
			pc.addCols("GRAN TOTAL DE PARTOS ATENDIDOS:  . . ",2,4,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0",finCantPar),2,1);
	 }

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
