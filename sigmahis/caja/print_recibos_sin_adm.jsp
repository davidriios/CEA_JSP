<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
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
/*
=======================================================================================================
Reporte   depositos_sin_adm.rdf
=======================================================================================================
*/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
  UserDet=SecMgr.getUserDetails(session.getId());
  session.setAttribute("UserDet",UserDet);
  issi.admin.ISSILogger.setSession(session);

  CmnMgr.setConnection(ConMgr);
  SQLMgr.setConnection(ConMgr);


  //SQL2BeanBuilder sbb = new SQL2BeanBuilder();
  String strCondicion = "";
  String appendFilter = request.getParameter("appendFilter");
  String appendFilter2 = request.getParameter("appendFilter2");
  String caja = request.getParameter("caja");
  String turno = request.getParameter("turno");
  String compania = (String) session.getAttribute("_companyId");  //request.getParameter("compania");
  String fecha_ini = request.getParameter("fechaini");
  String fecha_fin = request.getParameter("fechafin");
  String descCaja = request.getParameter("descCaja");
  String observacion = request.getParameter("observacion");
  String periodo = "";
  String fg = request.getParameter("fg");

  StringBuffer sql = new StringBuffer();
  String tipoCode = request.getParameter("tipoCode");
  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String userName = UserDet.getUserName();
  ArrayList alTipo = new ArrayList();
  ArrayList list   = new ArrayList();
  ArrayList al   = new ArrayList();
  //Company com= new Company();

  if (observacion==null) 	observacion="";
  if (compania==null) 		compania = "";
  if (fecha_ini==null) 		fecha_ini = "";
  if (fecha_fin==null) 		fecha_fin = "";
  if (caja==null)  				caja = "";
  if (turno==null) 				turno = "";
  if (fg==null) 				fg = "ADM";

	if (appendFilter==null)  appendFilter  = "";
  if (appendFilter2==null) appendFilter2 = "";

  if (!compania.trim().equals(""))
  {
  	appendFilter  += "  and a.compania = "+compania;
  	appendFilter2 += "  and b.compania = "+compania;
  }

  if (!caja.trim().equals("") )  appendFilter += "  and a.caja = "+caja;

  if (!turno.trim().equals("") )  appendFilter += "  and a.turno = "+turno;

  if (!fecha_ini.trim().equals("") )
  {
  	periodo = "DESDE  "+fecha_ini;
  	appendFilter += "  and trunc(a.fecha) >= to_date('"+fecha_ini+"','dd/mm/yyyy') ";
  }

  if (!fecha_fin.trim().equals("") )
  {
  		periodo += "    HASTA  "+fecha_fin;
  		appendFilter += "  and trunc(a.fecha) <= to_date('"+fecha_fin+"','dd/mm/yyyy') ";
  }
sql.append("select yy.*, yy.saldo - yy.aplicado porAplicar from (");
	sql.append(" select all c.codigo||' - '||c.descripcion caja, a.codigo||'-'||a.anio transaccion, pac.pac_id codPaciente, pac.id_paciente as idPaciente, decode (a.tipo_cliente, 'P', pac.nombre_paciente, 'E', e.nombre, '') as nombre, x.codigo as recibo, to_char (a.fecha, 'dd/mm/yyyy') as fechaPago, a.descripcion descPago, nvl(a.pago_total,0) as recibido, nvl(aj.monto_ajustado, 0) ajuste, (nvl(a.pago_total, 0)+nvl(aj.monto_ajustado, 0)) as saldo, (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado ,a.fecha, decode(a.tipo_cliente,'O','Otros','E','Emp.','P','Pac.')tipo_cliente from tbl_cja_transaccion_pago a, tbl_cja_recibos x, vw_adm_paciente pac, tbl_adm_empresa e,  (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as monto_ajustado,z.recibo,z.compania from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.factura is null and z.tipo_doc = 'R' and z.recibo is not null and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D') group by z.recibo,z.compania) aj, tbl_cja_cajas c  where a.codigo = x.ctp_codigo  and a.anio = x.ctp_anio  and a.compania = x.compania  and c.compania = a.compania and c.codigo = a.caja  ");
	sql.append(appendFilter);
	sql.append(" and a.rec_status <> 'I' and a.pac_id = pac.pac_id(+)  and a.tipo_cliente in ('P', 'E')  and a.codigo_empresa = e.codigo(+)  and x.codigo = aj.recibo(+) and x.compania=aj.compania(+) ");
	 
	  sql.append(" and  (nvl(a.pago_total, 0)+nvl(aj.monto_ajustado, 0)) > 0   order by c.codigo||' - '||c.descripcion, a.fecha asc ");
	  sql.append(")yy where  ");
	  if (fg.trim().equals("SALDO"))sql.append(" yy.saldo - yy.aplicado  > 0");
	  else sql.append(" yy.aplicado  = 0"); 
	  sql.append(" order by yy.caja,yy.fecha asc"); 
	  
	  
	al = SQLMgr.getDataList(sql.toString());

  if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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

	float dispHeight = 0.0f;//altura disponible para el ciclo for
	float headerHeight = 0.0f;//tamaño del encabezado
	float innerHeight = 0.0f;//tamaño del detalle
	float footerHeight = 0.0f;//tamaño del footer
	float modHeight = 0.0f;//tamaño del relleno en blanco
	float antHeight = 0.0f;//
	float finHeight = 0.0f;//
	float extra = 0.0f;//
	float total = 0.0f;//
	float innerTableHeight = 0.0f;
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
	String title = "CAJA";
	String subtitle = ""+((fg.trim().equals("ADM"))?"RECIBOS PENDIENTES POR APLICAR A UNA ADMISION O FACTURA (SIN DETALLE)":"RECIBOS CON SALDO POR APLICAR");
	String xtraSubtitle = periodo;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;
	int  j = 0;

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".10");
		dHeader.addElement(".21");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".15");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");

		footer.setNoColumnFixWidth(dHeader);
		footer.createTable();
		footer.setFont(8, 0);
		footer.addCols("Observaciones: "+observacion,0,dHeader.size());
		footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.resetVAlignment();
	pc.setFont(8, 1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	headerHeight =  pc.getTableHeight();

	// titulo de columnas
	pc.setFont(7, 1,Color.black);
	pc.addBorderCols("No.Trx",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Codigo Pacte",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Cedula / Pasap.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Nombre del Paciente",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Recibo",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Pago",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Descripcion Pago",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Recibido",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Ajustado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Aplicado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	if (fg.trim().equals("ADM"))pc.addBorderCols("Saldo",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	else pc.addBorderCols("Por aplicar",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);


	String groupByCaja	 = "";
	double totalRecibido= 0.00, totalAjuste=0.00, totalSaldo=0.00,totalAplicado=0.00;
	double subTotalRecibido= 0.00, subTotalAjuste=0.00, subTotalSaldo=0.00,subTotalAplicado=0.00;
	double pendiente = 0.00;
	String r_caja = "",saldo="0";
	String descripcion = "";
	int recibo = 0, reciboCaja = 0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja")))
		{
							if (i != 0)  // imprime total la caja
							{
								pc.setFont(7, 1,Color.black);
								pc.addCols("Total de Recibos  .  .  .  ."+String.valueOf(reciboCaja),0,3);
								pc.addCols("Totales por caja  .   .   .   .   .   .   ",2,4);
								//pc.addCols(String.valueOf(subTotal),1,3);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalRecibido)),2,1);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalAjuste)),2,1);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalAplicado)),2,1);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalSaldo)),2,1);

								pc.addCols(" ",0,dHeader.size(),cHeight);
								subTotalRecibido= 0.00;
								subTotalAjuste=0.00;
								subTotalSaldo=0.00;
								reciboCaja = 0;
						  }

							//1ra linea: caja
							pc.setFont(9, 1,Color.black);
							pc.addCols("Caja:",0,1);
							pc.addCols(cdo1.getColValue("caja"),0,10);

		}

		// contenido
    pc.setFont(7, 0);
    pc.addCols(" "+cdo1.getColValue("transaccion"), 0,1);
    pc.addCols(" "+cdo1.getColValue("codPaciente"), 0,1);
    pc.addCols(" "+cdo1.getColValue("idPaciente"), 0,1);
    pc.addCols(" "+cdo1.getColValue("nombre"), 0,1);
    pc.addCols(" "+cdo1.getColValue("recibo"), 2,1);
    pc.addCols(" "+cdo1.getColValue("fechaPago"), 1,1);
    pc.addCols(" "+cdo1.getColValue("descPago"), 0,1);
    pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("recibido")), 2,1);
    pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("ajuste")), 2,1);
	pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("aplicado")), 2,1);
    
	if (fg.trim().equals("ADM")) saldo = cdo1.getColValue("saldo");
	else  saldo = cdo1.getColValue("porAplicar");
	pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", saldo), 2,1);
	
    //pc.addTable();
    // totales por caja
    subTotalRecibido += Double.parseDouble(cdo1.getColValue("recibido"));
		subTotalAjuste+= Double.parseDouble(cdo1.getColValue("ajuste"));
		subTotalAplicado+= Double.parseDouble(cdo1.getColValue("aplicado"));
		subTotalSaldo+= Double.parseDouble(saldo);
		// totales finales
    totalRecibido += Double.parseDouble(cdo1.getColValue("recibido"));
		totalAjuste+= Double.parseDouble(cdo1.getColValue("ajuste"));
		totalAplicado+= Double.parseDouble(cdo1.getColValue("aplicado"));
		totalSaldo+= Double.parseDouble(saldo);
    recibo++;
    reciboCaja++;
    groupByCaja = cdo1.getColValue("caja");

	} // fin del ciclo for

	pc.setFont(9, 1,Color.black);
	if (al.size()==0)	pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		// totales de la ultima caja procesada
		pc.setFont(7, 1,Color.black);
		pc.addCols("Total de Recibos  .  .  .  ."+String.valueOf(reciboCaja),0,3);
		pc.addCols("Totales por caja  .   .   .   .   .   .   ",2,4);
		//pc.addCols(String.valueOf(subTotal),1,3);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalRecibido)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalAjuste)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalAplicado)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalSaldo)),2,1);

		pc.addCols(" ",0,dHeader.size(),cHeight);

		// totales finalez
		pc.addCols("Total de Recibos  .  .  .  ."+String.valueOf(recibo),0,3);
		pc.addCols("Totales Finales   .   .   .   .   .   .   ",2,4);
		//pc.addCols(String.valueOf(subTotal),1,3);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalRecibido)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalAjuste)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalAplicado)),2,1);
		pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalSaldo)),2,1);

	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

 }//GET

%>






