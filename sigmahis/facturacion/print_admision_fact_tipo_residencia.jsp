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
<!-- Reporte: Pacientes nacionales y no nacionales             -->
<!-- Reporte: ADM3082                                          -->

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

String categoria       = request.getParameter("categoria");
String tipoAdmision    = request.getParameter("tipoAdmision");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String tipoResidencia  = request.getParameter("tipoResidencia");

if (categoria == null)     categoria       = "";
if (tipoAdmision == null)  tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (tipoResidencia == null) tipoResidencia = "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and a.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and trunc(a.fecha_ingreso) >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and trunc(a.fecha_ingreso) <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }
if (!categoria.equals(""))
   {
   appendFilter1 += " and a.categoria = "+categoria;
   }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and a.tipo_admision = "+tipoAdmision;
   }
if (!codAseguradora.equals(""))
    {
	 appendFilter1 += " and b.empresa = "+codAseguradora;
	}
if (!tipoResidencia.equals(""))
    {
	 appendFilter1 += " and p.tipo_residencia = '"+tipoResidencia+"'";
	}
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de admisiones facturadas--------------------------------//

sql = "SELECT decode(P.TIPO_RESIDENCIA,'P','PERMANENTE','T','TEMPORAL','','NO DEFINIDA') tipoResidencia, to_char(a.fecha_ingreso,'dd/mm/yyyy') fIngreso, c.descripcion categoria, '['||p.pac_id||'-'||A.SECUENCIA||']' codigoAdmision, P.nombre_paciente nombrePaciente, e.nombre aseguradora, to_char(sum(nvl(f.monto_bruto,0))) montoBruto, to_char(sum(nvl(f.monto_neto,0))) montoNeto, to_char(sum(nvl(f.pagado,0))) montoPagado  FROM vw_ADM_PACIENTE P, tbl_ADM_ADMISION A,  tbl_adm_beneficios_x_admision b, tbl_adm_empresa e, tbl_adm_categoria_Admision c, (select ff.pac_id, ff.admi_secuencia, sum(nvl(ff.grang_total,0)+nvl(ff.monto_descuento,0)) monto_bruto, sum(nvl(ff.grang_total,0)) monto_neto,  sum(nvl((select sum(d.monto) from tbl_cja_transaccion_pago t, tbl_cja_detalle_pago d where D.TRAN_ANIO =T.ANIO AND  D.COMPANIA  =T.COMPANIA AND  D.CODIGO_TRANSACCION = T.CODIGO and d.fac_codigo = ff.codigo and d.compania = ff.compania and t.rec_status <> 'I'),0)) pagado from tbl_fac_factura ff  where ff.estatus <> 'A'    group by ff.pac_id, ff.admi_secuencia ) f WHERE  A.pac_id = P.pac_id AND  A.ESTADO = 'I' and  b.empresa = e.codigo and  a.categoria = c.codigo and  a.pac_id    = f.pac_id(+) and  a.secuencia = f.admi_secuencia(+) and  a.pac_id  =  b.pac_id  and  a.secuencia  =  b.admision and  nvl(b.estado,'A') = 'A' and  b.prioridad = 1 "+appendFilter1+" group by decode(P.TIPO_RESIDENCIA,'P','PERMANENTE','T','TEMPORAL','','NO DEFINIDA'), to_char(a.fecha_ingreso,'dd/mm/yyyy'),a.fecha_ingreso, c.descripcion,'['||p.pac_id||'-'||A.SECUENCIA||']', P.nombre_paciente, e.nombre order by decode(P.TIPO_RESIDENCIA,'P','PERMANENTE','T','TEMPORAL','','NO DEFINIDA'),a.fecha_ingreso, c.descripcion, P.nombre_paciente ";

al = SQLMgr.getDataList(sql);

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
	String subtitle = "ADMISIONES FACTURADAS DE PACIENTES LOCALES E INTERNACIONALES";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".14");
		dHeader.addElement(".25");
		dHeader.addElement(".25");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".12");

	Vector infoCol = new Vector();
		infoCol.addElement(".14");
		infoCol.addElement(".25");
		infoCol.addElement(".25");
		infoCol.addElement(".12");
		infoCol.addElement(".12");
		infoCol.addElement(".12");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(8, 1);
	pc.setTableHeader(2);


	pc.addBorderCols("Admisión",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Nombre",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Aseguradora",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Fact.Bruta",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Fact.Neta",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Pagado",1,1,cHeight,Color.lightGray);


	String groupByRes	 = "";		// para agrupar por tipo de residencia
	String groupByIng = "";		// para agrupar por fecha de ingreso
	String groupByCat = "";		// para agrupar por categoria
	int rCounter = 0;				// para la cantidad de pacientes por tipo de residencia
	int	iCounter = 0;				// para la cantidad de pacientes por fecha ingreso
	int	cCounter = 0;				// para la cantidad total de pacientes por categoria
	int	tCounter = 0;				// para la cantidad total final
	double rBruto = 0, rNeto = 0, rPagado = 0;  // totales por tipo de residencia
	double iBruto = 0, iNeto = 0, iPagado = 0;  // totales por fecha ingreso
	double cBruto = 0, cNeto = 0, cPagado = 0;  // totales por categoria
	double tBruto = 0, tNeto = 0, tPagado = 0;  // totales finales
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);

		// Agrupar tipo de residencia
		if (!groupByRes.trim().equalsIgnoreCase(cdo.getColValue("tipoResidencia")))
		{
					pc.setFont(7, 1,Color.black);
					if (i != 0)  // imprime total de pactes
					{
						// totales por categoria

						pc.addCols("Total de Pacientes "+groupByCat+". . . . . . "+String.valueOf(cCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cPagado),2,1,cHeight);
						//pc.addCols("Total de Pacientes del "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
						//pc.addCols(" ",0,dHeader.size(),cHeight);

						// totales por f.ingreso
						pc.addCols("Total de Pacientes del "+groupByIng+". . . . . . "+String.valueOf(iCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iPagado),2,1,cHeight);
						//pc.addCols("Total de Pacientes del "+groupByIng+":   "+String.valueOf(iCounter),0,dHeader.size(),cHeight*2);
						//pc.addCols(" ",0,dHeader.size(),cHeight);

						// totales por tipo de residencia
						pc.addCols("Total de Pacientes "+groupByRes+":   "+String.valueOf(rCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rPagado),2,1,cHeight);
						//pc.addCols("Total de Pacientes del "+groupByRes+":   "+String.valueOf(rCounter),0,dHeader.size(),cHeight*2);
						pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols("Tipo Residencia :"+cdo.getColValue("tipoResidencia"),0,dHeader.size(),cHeight);
					rCounter = 0;
					iCounter = 0;
					cCounter = 0;

					rBruto  = 0;
					rNeto   = 0;
					rPagado = 0;
					iBruto  = 0;
					iNeto 	= 0;
					iPagado = 0;
					cBruto 	= 0;
					cNeto 	= 0;
					cPagado = 0;

					groupByCat = "";
					groupByIng = "";
					groupByRes = "";
		}

		// Agrupar por Fecha de ingreso
		if (!groupByIng.trim().equalsIgnoreCase(cdo.getColValue("fIngreso")))
		{
					pc.setFont(7, 1,Color.black);
					if (i != 0 && iCounter != 0)  // imprime total de pactes por centro
					{
						// totales por categoria
						//pc.addCols("Total de Pacientes del "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
						pc.addCols("Total de Pacientes "+groupByCat+":   "+String.valueOf(cCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cPagado),2,1,cHeight);
						//pc.addCols(" ",0,dHeader.size(),cHeight);

						// totales por f.ingreso
						//pc.addCols("Total de Pacientes del "+groupByIng+":   "+String.valueOf(iCounter),0,dHeader.size(),cHeight*2);
						pc.addCols("Total de Pacientes del "+groupByIng+":   "+String.valueOf(iCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iPagado),2,1,cHeight);
						//pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols("Fecha Ingreso: "+cdo.getColValue("fIngreso"),0,dHeader.size(),cHeight);

					iBruto  = 0;
					iNeto 	= 0;
					iPagado = 0;
					cBruto 	= 0;
					cNeto 	= 0;
					cPagado = 0;

					iCounter = 0;
					cCounter = 0;

					groupByCat = "";
					groupByIng = "";
		}

		// Agrupar por Categoria admision
		if (!groupByCat.trim().equalsIgnoreCase(cdo.getColValue("categoria")))
		{
					pc.setFont(7, 1,Color.black);
					if (i != 0 && cCounter != 0)  // imprime total de pactes por cat.
					{

						// totales por f.ingreso
						pc.addCols("Total de Pacientes "+groupByCat+":   "+String.valueOf(cCounter),2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cBruto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cNeto),2,1,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cPagado),2,1,cHeight);
						//pc.addCols("Total de Pacientes del "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
						//pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols("Categoría: "+cdo.getColValue("categoria"),0,dHeader.size(),cHeight);

					cBruto 	= 0;
					cNeto 	= 0;
					cPagado = 0;

					cCounter = 0;
		}

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("codigoAdmision"),0,1);
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1);
		pc.addCols(cdo.getColValue("aseguradora"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montoBruto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montoNeto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("montoPagado")),2,1);

		cCounter++;
		iCounter++;
		rCounter++;
		tCounter++;

		// valores por tipo residencia
		rBruto 	+= Double.parseDouble(cdo.getColValue("montoBruto"));
		rNeto 	+= Double.parseDouble(cdo.getColValue("montoNeto"));
		rPagado += Double.parseDouble(cdo.getColValue("montoPagado"));

		// valores por fecha ingreso
		iBruto 	+= Double.parseDouble(cdo.getColValue("montoBruto"));
		iNeto 	+= Double.parseDouble(cdo.getColValue("montoNeto"));
		iPagado += Double.parseDouble(cdo.getColValue("montoPagado"));

		// valores por categoria
		cBruto 	+= Double.parseDouble(cdo.getColValue("montoBruto"));
		cNeto 	+= Double.parseDouble(cdo.getColValue("montoNeto"));
		cPagado += Double.parseDouble(cdo.getColValue("montoPagado"));

		// valores por generales
		tBruto 	+= Double.parseDouble(cdo.getColValue("montoBruto"));
		tNeto 	+= Double.parseDouble(cdo.getColValue("montoNeto"));
		tPagado += Double.parseDouble(cdo.getColValue("montoPagado"));

		groupByCat = cdo.getColValue("categoria");
		groupByIng = cdo.getColValue("fIngreso");
		groupByRes = cdo.getColValue("tipoResidencia");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			// total por categoria
			pc.setFont(7, 1,Color.black);
			pc.addCols("Total de Pacientes "+groupByCat+":   "+String.valueOf(cCounter),2,3,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cBruto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cNeto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",cPagado),2,1,cHeight);
			//pc.addCols("Total de Pacientes del "+groupByCat+":   "+String.valueOf(cCounter),0,dHeader.size(),cHeight*2);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// total por f.ingreso
			pc.setFont(9, 1,Color.black);
			pc.addCols("Total de Pacientes del "+groupByIng+":   "+String.valueOf(iCounter),2,3,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iBruto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iNeto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",iPagado),2,1,cHeight);
			//pc.addCols("Total de Pacientes del "+groupByIng+":   "+String.valueOf(iCounter),0,dHeader.size(),cHeight*2);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			//total por Tipo de residencia
			pc.setFont(9, 1,Color.black);
			pc.addCols("Total de Pacientes "+groupByRes+":   "+String.valueOf(rCounter),2,3,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rBruto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rNeto),2,1,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",rPagado),2,1,cHeight);
			//pc.addCols("Total de Pacientes del "+groupByRes+":   "+String.valueOf(rCounter),0,dHeader.size(),cHeight*2);
			pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,dHeader.size(),cHeight);

	    //Totales Finales
	    pc.setFont(8, 1,Color.black);
		  pc.addCols(" ",0,dHeader.size(),cHeight);
		  pc.addCols(" TOTAL FINAL DE PACIENTES:   "+String.valueOf(tCounter),2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tBruto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tNeto),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",tPagado),2,1);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

