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
Reporte   cja20020.rdf
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
  if(appendFilter== null)appendFilter="";
  String caja = request.getParameter("caja");
  String turno = request.getParameter("turno");
  String compania = request.getParameter("compania");
  String fecha_ini = request.getParameter("fechaini");
  String fecha_fin = request.getParameter("fechafin");
  String descCaja = request.getParameter("descCaja");
  String observacion = request.getParameter("observacion");
  String secuencia = request.getParameter("secuencia");
  String tipoCliente = request.getParameter("tipoCliente");
  String periodo = "";
  String fg = request.getParameter("fg");

  String sql = "", appendOrder="";
  String tipoCode = request.getParameter("tipoCode");
  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
  String userName = UserDet.getUserName();
  ArrayList al   = new ArrayList();
  ArrayList al2   = new ArrayList();
  ArrayList alNC   = new ArrayList();
  StringBuffer sbSql = new StringBuffer();

  if (observacion==null) observacion="";

  if (fecha_ini==null) fecha_ini = "";
  if (fecha_fin==null) fecha_fin = "";
  if (turno==null) turno = "";
  if (secuencia==null) secuencia = "";
  if (tipoCliente==null) tipoCliente = "";
  if (fg==null) fg = "";

  if (!fecha_ini.trim().equals("") ) periodo = "DESDE  "+fecha_ini;
  if (!fecha_fin.trim().equals("") ) periodo += "    HASTA  "+fecha_fin;
  if (caja==null) caja = "";
  if (!caja.trim().equals("")) appendFilter +=" and ctp.caja ="+caja;
  if (!turno.trim().equals("")) appendFilter +=" and ctp.turno ="+turno;
  if (!tipoCliente.trim().equals("")) appendFilter += " and ctp.tipo_cliente = '"+tipoCliente+"'";
  if (!secuencia.trim().equals("") )
  {
  	appendFilter += " and ctp.xtra1 is not null ";
  	appendOrder = " order by ctp.caja, ctp.xtra1";
  } else appendOrder = " order by ctp.caja, ctp.recibo";

	sbSql.append("select ctp.codigo_paciente, ctp.fecha_nacimiento, ctp.codigo_empresa empresa, ctp.xtra1 recibo_manual, to_char(:p_fecha, 'dd/mm/yyyy') as fecha, ctp.caja, decode(ctp.tipo_cliente, 'P', 'PACIENTE', 'E', 'EMPRESA', 'O', 'OTROS') tipo_cliente, ctp.pago_total as monto_pagado, :p_user as usuario, c.descripcion as nombre_caja, r.codigo as recibo,decode(ctp.tipo_cliente, 'P', p.nombre_paciente, 'E', e.nombre, 'O', ctp.nombre_adicional)||decode(ctp.rec_status, 'I', ' (ANULADO)','') as nombre, fn_cja_getFormaPago(ctp.compania, ctp.anio, ctp.codigo) as forma_pago, (select tp.rec_no from tbl_cja_trans_forma_pagos fp , tbl_cja_transaccion_pago tp where fp.no_referencia is not null and fp.fp_codigo = '0' and tp.compania = fp.compania and tp.anio = fp.tran_anio and tp.codigo = fp.tran_codigo and no_referencia = ctp.recibo and rownum = 1) remp_por from tbl_cja_cajas c, tbl_cja_transaccion_pago ctp, tbl_cja_recibos r,vw_adm_paciente p,tbl_adm_empresa e");
		
  if(fg.trim().equals("CONT"))
  {
  	sbSql.append(",tbl_cja_turnos_x_cajas ctu");
  }
	 sbSql.append(" where c.compania = ");
	 sbSql.append(compania);
	  
	   if(fg.trim().equals("CONT")){
			sbSql.append(" and ctu.compania = ctp.compania  and ctu.cod_turno = ctp.turno and ctu.cod_caja = ctp.caja ");
			
			if(!fecha_ini.trim().equals("")){ sbSql.append(" and trunc(ctu.fecha_creacion)  >= to_date('");
			sbSql.append(fecha_ini);
			sbSql.append("', 'dd/mm/yyyy') ");}
			if(!fecha_fin.trim().equals("")){
			sbSql.append(" and  trunc(ctu.fecha_creacion) <= to_date('");
			sbSql.append(fecha_fin);
			sbSql.append("', 'dd/mm/yyyy')");}
	   } else {
			if(!fecha_ini.trim().equals("")){
			sbSql.append(" and trunc(ctp.fecha_creacion) >= to_date('");
			sbSql.append(fecha_ini);
			sbSql.append("', 'dd/mm/yyyy')");}
			if(!fecha_fin.trim().equals("")){
			sbSql.append(" and  trunc(ctp.fecha_creacion) <= to_date('");
			sbSql.append(fecha_fin);
			sbSql.append("', 'dd/mm/yyyy') ");}
		 }
  
	  sbSql.append(appendFilter.toString());
	  sbSql.append(" and ctp.compania = c.compania and ctp.caja = c.codigo and r.ctp_anio = ctp.anio and r.compania = ctp.compania and r.ctp_codigo = ctp.codigo and ctp.pac_id= p.pac_id(+) and ctp.codigo_empresa = e.codigo(+) :p_status ");


	sbSql.append(appendOrder.toString());
	al = SQLMgr.getDataList(sbSql.toString().replaceAll( ":p_status"," and nvl(ctp.rec_status,'A') <> 'I' " ).replaceAll(":p_fecha"," ctp.fecha_creacion ").replaceAll(":p_user"," ctp.usuario_creacion "));
	
	ArrayList alAnul = SQLMgr.getDataList(sbSql.toString().replaceAll( ":p_status"," and ctp.rec_status = 'I' " ).replaceAll(":p_fecha"," ctp.fecha_anulacion ").replaceAll(":p_user"," ctp.usuario_anulacion "));

	sbSql = new StringBuffer();
	sbSql.append("select 0 codigo_paciente, sysdate fecha_nacimiento, 0 empresa, 0 recibo_manual, to_char(ctp.doc_date, 'dd/mm/yyyy') as fecha, ctp.cod_caja caja, 'OTROS' tipo_cliente, -ctp.net_amount as monto_pagado, ctp.created_by as usuario, c.descripcion as nombre_caja, to_char(ctp.doc_id) as recibo, ctp.client_name as nombre, fn_cja_getformapago_nc(ctp.company_id, ctp.doc_id) as forma_pago from tbl_cja_cajas c, tbl_fac_trx ctp where c.compania = ");
	sbSql.append(compania);
	if (!fecha_ini.trim().equals("")){
	sbSql.append(" and trunc (ctp.doc_date) >= to_date ('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') ");}
	if (!fecha_fin.trim().equals("")){
	sbSql.append(" and trunc(ctp.doc_date) <= to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy') "); }
	
	sbSql.append(" and cTP.doc_type = 'NCR' and ctp.tipo_factura='CO' and ctp.company_id = c.compania and ctp.cod_caja = c.codigo");
  if (!caja.trim().equals("")){
		sbSql.append(" and ctp.cod_caja = ");
		sbSql.append(caja);
  }
	if (!turno.trim().equals("")){
		sbSql.append(" and ctp.turno = ");
		sbSql.append(turno);
	}
	sbSql.append(" order by ctp.cod_caja, ctp.doc_id");
	alNC = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	 sbSql.append(" select cf.codigo, cf.descripcion descForma, sum(ctfp.monto) monto from tbl_cja_cajas c, tbl_cja_transaccion_pago ctp, tbl_cja_recibos r,tbl_adm_paciente p,tbl_adm_empresa e,tbl_cja_trans_forma_pagos ctfp,tbl_cja_forma_pago cf");
  if(fg.trim().equals("CONT"))
  {
  	sbSql.append(",tbl_cja_turnos_x_cajas ctu");
  }
	 sbSql.append(" where  c.compania = ");
	 sbSql.append(compania);
	   if(fg.trim().equals("CONT"))
	   { 	   
	     sbSql.append(" and ctu.compania = ctp.compania  and ctu.cod_turno = ctp.turno and ctu.cod_caja = ctp.caja ");
	     if (!fecha_ini.trim().equals("")){sbSql.append(" and trunc(ctu.fecha_creacion)  >= to_date('"+fecha_ini+"','dd/mm/yyyy') ");}
		 if (!fecha_fin.trim().equals("")){sbSql.append("and  trunc(ctu.fecha_creacion) <= to_date('"+fecha_fin+"','dd/mm/yyyy') ");}
	   }
	   else
	   {
	     if (!fecha_ini.trim().equals("")){sbSql.append(" and trunc(ctp.fecha_creacion) >= to_date('"+fecha_ini+"','dd/mm/yyyy') ");}
		 if (!fecha_fin.trim().equals("")){sbSql.append(" and trunc(ctp.fecha_creacion) <= to_date('"+fecha_fin+"','dd/mm/yyyy') ");}
	   }
	  sbSql.append(appendFilter.toString());
	  sbSql.append(" and ctp.compania = c.compania and ctp.caja = c.codigo and r.ctp_anio = ctp.anio and r.compania = ctp.compania and r.ctp_codigo = ctp.codigo and ctp.pac_id= p.pac_id(+) and ctp.codigo_empresa = e.codigo(+) and (ctfp.tran_anio =ctp.anio and ctfp.compania =ctp.compania and ctfp.tran_codigo =ctp.codigo) and cf.codigo(+) = ctfp.fp_codigo  and nvl(ctp.rec_status,'A') <> 'I' group by cf.descripcion,cf.codigo /*order by cf.codigo*/ ");
		sbSql.append(" union ");
		sbSql.append("select a.fp_codigo, (select descripcion from tbl_cja_forma_pago fp where fp.codigo = a.fp_codigo)||' NC' descripcion, a.monto from (select tfp.fp_codigo, sum(-tfp.monto) as monto from tbl_fac_trx_forma_pagos tfp where exists (select null from tbl_fac_trx f where f.doc_id = tfp.doc_id and f.company_id = tfp.compania ");
		
		 if (!fecha_ini.trim().equals("")){sbSql.append(" and trunc(f.doc_date)  >= to_date('"+fecha_ini+"','dd/mm/yyyy') ");}
		 if (!fecha_fin.trim().equals("")){sbSql.append("and  trunc(f.doc_date) <= to_date('"+fecha_fin+"','dd/mm/yyyy') ");}
	  
	  sbSql.append(" and f.company_id = ");
	  sbSql.append(compania);
	  sbSql.append(" and f.doc_type = 'NCR'");
		if (!caja.trim().equals("")){
			sbSql.append(" and f.cod_caja = ");
			sbSql.append(caja);
		}
		if (!turno.trim().equals("")){
			sbSql.append(" and f.turno = ");
			sbSql.append(turno);
		}
		sbSql.append(") and to_char(tfp.fp_codigo) != get_sec_comp_param(tfp.compania, 'FORMA_PAGO_CREDITO') group by tfp.fp_codigo) a order by 1");
	al2 = SQLMgr.getDataList(sbSql.toString());

  if(request.getMethod().equalsIgnoreCase("GET")) {

    double montoTotal = 0.00,subTotalCja=0.00,totalAn=0.00;
    double subTotal = 0.00;
    double pendiente = 0.00;
    String r_caja = "";
    String descripcion = "";
    int recibo = 0, reciboCaja = 0;

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CAJA";
	String subtitle = "RECIBOS PAGADOS POR CAJA"+(!turno.equals("")?" - TURNO #"+turno:"");
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
		dHeader.addElement(".35");
		dHeader.addElement(".09");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

		footer.setNoColumnFixWidth(dHeader);
		footer.createTable();
		footer.setFont(8, 0);
		footer.addCols("Observaciones: "+observacion,0,dHeader.size());
		footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("Recibo No.",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Referencia",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Nombre",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Pago",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Forma Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Monto Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Usuario Creacion",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);

	String groupByCaja	 = "";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja")))
		{
							pc.setFont(8, 1,Color.black);
							if (i != 0)  // imprime total la caja
							{
								pc.addCols("Monto total pagado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
								//pc.addCols(String.valueOf(subTotal),1,3);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotal)),2,1);
								pc.addCols(" Cantidad:"+String.valueOf(reciboCaja),2,1);

								pc.addCols(" ",0,dHeader.size(),cHeight);
								subTotal= 0.00;
								reciboCaja = 0;
						  }

							//1ra linea: caja
							pc.addCols("Caja:",0,1);
							pc.addCols(cdo1.getColValue("caja")+" - "+cdo1.getColValue("nombre_caja"),0,6);
							// titulo de columnas

		}

		// contenido
    pc.setFont(7, 0);
    pc.addCols(cdo1.getColValue("recibo"), 0,1);
    pc.addCols(cdo1.getColValue("recibo_manual"), 0,1);
    pc.addCols(cdo1.getColValue("nombre"), 0,1);
    pc.addCols(cdo1.getColValue("fecha"), 0,1);
    pc.setFont(6, 0);
    pc.addCols(cdo1.getColValue("forma_pago"),2,1);
    pc.setFont(7, 0);
    pc.addCols("$"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("monto_pagado")), 2,1);
    pc.addCols(cdo1.getColValue("usuario"), 0,1);
    //pc.addTable();
    montoTotal += Double.parseDouble(cdo1.getColValue("monto_pagado"));
    subTotal   += Double.parseDouble(cdo1.getColValue("monto_pagado"));
    recibo++;
    reciboCaja++;
    groupByCaja = cdo1.getColValue("caja");

	} // fin del ciclo for
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(8, 1,Color.black);
			pc.addCols("Monto total pagado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotal)),2,1);
			pc.addCols(" Cantidad:"+String.valueOf(reciboCaja),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	}

	groupByCaja	 = "";
	subTotal =0.00;
	reciboCaja = 0;
	if(alNC.size()>0)pc.addCols("N O T A S   D E   C R E D I T O   ( P O S )",1,7);
	for (int i=0; i<alNC.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) alNC.get(i);

		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja")))
		{
							pc.setFont(8, 1,Color.black);
							if (i != 0)  // imprime total la caja
							{
								pc.addCols("Monto total pagado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
								//pc.addCols(String.valueOf(subTotal),1,3);
								pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotal)),2,1);
								pc.addCols(" Cantidad:"+String.valueOf(reciboCaja),2,1);

								pc.addCols(" ",0,dHeader.size(),cHeight);
								subTotal= 0.00;
								reciboCaja = 0;
						  }

							//1ra linea: caja
							pc.addCols("Caja:",0,1);
							pc.addCols(cdo1.getColValue("caja")+" - "+cdo1.getColValue("nombre_caja"),0,6);
							// titulo de columnas

		}

		// contenido
    pc.setFont(7, 0);
    pc.addCols(cdo1.getColValue("recibo"), 0,1);
    pc.addCols(cdo1.getColValue("recibo_manual"), 0,1);
    pc.addCols(cdo1.getColValue("nombre"), 0,1);
    pc.addCols(cdo1.getColValue("fecha"), 0,1);
    pc.setFont(6, 0);
    pc.addCols(cdo1.getColValue("forma_pago"),2,1);
    pc.setFont(7, 0);
    pc.addCols("$"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("monto_pagado")), 2,1);
    pc.addCols(cdo1.getColValue("usuario"), 0,1);
    //pc.addTable();
    montoTotal += Double.parseDouble(cdo1.getColValue("monto_pagado"));
    subTotal   += Double.parseDouble(cdo1.getColValue("monto_pagado"));
    recibo++;
    reciboCaja++;
    groupByCaja = cdo1.getColValue("caja");

	} // fin del ciclo for


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(8, 1,Color.black);
			pc.addCols("Monto total pagado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotal)),2,1);
			pc.addCols(" Cantidad:"+String.valueOf(reciboCaja),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			pc.addCols("Total pagado   .   .   .   .   .   .   .   .   .   .   ",2,5);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(montoTotal)), 2,1);
			pc.addCols("Cantidad:"+String.valueOf(recibo),2,1);


			pc.addCols(" ",1,dHeader.size());
			pc.addBorderCols("TOTAL RESUMIDO",1,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
			montoTotal =0.00;

			for (int i=0; i<al2.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al2.get(i);
				pc.addCols(cdo.getColValue("descForma"),0,4);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
				pc.addCols("",1,2);
				montoTotal += Double.parseDouble(cdo.getColValue("monto"));
			}
			pc.addBorderCols("",0,4,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(montoTotal),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols("",1,2,0.0f,0.0f,0.0f,0.0f);
	}
	pc.setVAlignment(0);
	pc.addCols("  ",1,7);
	pc.addCols(" RECIBOS ANULADOS ",1,7);
	pc.useTable("main");
	pc.flushTableBody(true);
	//delete previous rows
	pc.deleteRows(-1);
	
	pc.addBorderCols("Recibo No.",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Referencia",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Nombre",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Forma Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Monto Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("U. Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	
	pc.addBorderCols("Recibo No.",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Referencia",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
	pc.addBorderCols("Nombre",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Fecha Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Forma Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("Monto Pagado",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	pc.addBorderCols("U. Anul.",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
	//pc.setTableHeader(1);
	groupByCaja	 = "";
	
	for (int a = 0; a<alAnul.size(); a++){
		CommonDataObject cdo1 = (CommonDataObject) alAnul.get(a);
		if (!groupByCaja.trim().equalsIgnoreCase(cdo1.getColValue("caja")))
		{
			if(a!=0)
			{
				pc.setFont(8, 1,Color.black);
				pc.addCols("Monto Anulado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
				pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja)),2,1);
				pc.addCols(" ",2,1);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				subTotalCja =0.00;
			}
			pc.setFont(8, 1,Color.black);
			pc.addCols("Caja:",0,1);
			pc.addCols(cdo1.getColValue("caja")+" - "+cdo1.getColValue("nombre_caja"),0,7);
		}
		// contenido
		pc.setFont(7, 0);
		pc.addCols(cdo1.getColValue("recibo"), 0,1);
		pc.addCols(cdo1.getColValue("recibo_manual"), 0,1);
		pc.addCols(cdo1.getColValue("nombre")+( cdo1.getColValue("remp_por")!=null && !cdo1.getColValue("remp_por").equals("")?" - REEMPLAZADO POR: "+cdo1.getColValue("remp_por"):"" ), 0,1);
		pc.addCols(cdo1.getColValue("fecha"), 0,1);
		pc.setFont(6, 0);
		pc.addCols(cdo1.getColValue("forma_pago"),2,1);
		pc.setFont(7, 0);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,##0.00", cdo1.getColValue("monto_pagado")), 2,1);
		pc.addCols(cdo1.getColValue("usuario"), 0,1);
		
		subTotalCja +=Double.parseDouble(cdo1.getColValue("monto_pagado"));
		totalAn += Double.parseDouble(cdo1.getColValue("monto_pagado"));
		
		groupByCaja = cdo1.getColValue("caja");
	
	}//for a

	if (alAnul.size() != 0)
	{
			pc.setFont(8, 1,Color.black);
			pc.addCols("Monto Anulado por caja  .   .   .   .   .   .   .   .   .   .   ",2,5);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(subTotalCja)),2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight); 

			pc.addCols("Total Anulado   .   .   .   .   .   .   .   .   .   .   ",2,5);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal("###,##0.00", String.valueOf(totalAn)), 2,1);
			pc.addCols(" ",2,1);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

 }//GET
%>