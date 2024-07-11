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
<!-- Desarrollado por: José A. Acevedo C. -->
<!-- Reporte: Registro de Depósitos       -->
<!-- Reporte: CJA_R61002                  -->
<!-- Clínica Hospital San Fernando        -->
<!-- Fecha: 17/03/2011                    -->
<%
/**
==================================================================================
fg = DXT  -----> cja50040m.rdf  desde Pagina de Depositos
fg = CT		-----> informe de cierre de turno
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
CommonDataObject cdoTotal = new CommonDataObject();
CommonDataObject cdoResp = new CommonDataObject();
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");
String acr       = request.getParameter("acr");
String tipoCuenta = request.getParameter("tipoCuenta");
String fg = request.getParameter("fg");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
String usuario = request.getParameter("usuario");
String compania = request.getParameter("compania");
String dspResponsable = "";
String filter = "", titulo = "";
String userName = UserDet.getUserName();
String sqlResp ="";

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini   = "";
if (fechafin   == null) fechafin   = "";
if (compania   == null) compania = (String) session.getAttribute("_companyId");
if (usuario   == null) usuario   = "";
if (caja   == null) caja   = "";
if (turno   == null) turno   = "";
if (fg   == null) fg   = "RN";

if (!compania.equals(""))appendFilter += " and m.compania = "+compania;

if (!fechaini.equals(""))appendFilter += " and to_date(to_char(m.f_movimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if (!fechafin.equals(""))appendFilter += " and to_date(to_char(m.f_movimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";


sql.append(" select m.consecutivo_ag consecutivo, to_char(m.f_movimiento,'dd/mm/yyyy') fechaMovimiento, m.descripcion, nvl(m.monto,0) monto1, m.observacion, m.cuenta_banco ctaBanco, m.banco codBanco, b.nombre descBanco, m.caja codCaja, c.descripcion descCaja, m.compania compania1, m.turno, nvl(m.mto_tot_tarjeta,0) montoTarjeta, m.tipo_tarjeta tipoTarjeta, nvl(m.comision,0) comision, nvl(m.devoluc_tarj,0) devolucionTarjeta, m.num_documento noDocumento, decode(m.tipo_dep,'5',5,1) tipoDeposito, to_char(m.fecha_creacion,'dd/mm/yyyy') fechaCreacion, m.usuario_creacion usuario from vw_con_movim_bancario m, tbl_con_banco b, tbl_cja_cajas c where m.turno is not null and m.compania = b.compania and m.banco = b.cod_banco and m.caja = c.codigo and m.compania = c.compania ");
sql.append(appendFilter.toString());

//if (!usuario.equals("")){sql.append(" and upper(m.usuario_creacion) = upper('");sql.append(usuario);sql.append("')"); }
if (!turno.equals(""))
{
		sql.append(" and m.turno = ");
		sql.append(turno);
		sqlResp = "select  decode(tc.cod_supervisor_cierra, null, 'Abierto por: '||ca.nombre, 'Abierto por: '||ca.nombre||'   /   Cerrado por: '||cc.nombre) responsable  from tbl_cja_turnos tc, tbl_cja_cajera ca, tbl_cja_cajera cc  where tc.cod_supervisor_abre = ca.cod_cajera(+) and tc.compania = ca.compania(+) and tc.cod_supervisor_cierra = cc.cod_cajera(+) and tc.compania = cc.compania(+) and tc.codigo = "+turno+" and compania ="+compania;
		cdoResp = SQLMgr.getData(sqlResp.toString());
}


sql.append(" order by m.caja,m.banco,m.cuenta_banco,m.tipo_dep,m.consecutivo_ag  asc");
al = SQLMgr.getDataList(sql.toString());

if(fg.trim().equals("DXT")){

	sql = new StringBuffer();
sql.append(" select  nvl(sum(decode(b.fp_codigo,1,nvl(b.monto,0),0)),0)as monto_efectivo,nvl(sum(decode(b.fp_codigo,4,nvl(b.monto,0),0)),0)as monto_transf,nvl(sum(decode(b.fp_codigo,5,nvl(b.monto,0),0)),0)as monto_ach,nvl(sum(decode(b.fp_codigo,2,nvl(b.monto,0),0)),0)as monto_cheque, nvl(sum(decode(b.fp_codigo,6,nvl(b.monto,0),0)),0) as monto_tarj6 ,nvl(sum(decode(b.fp_codigo,3,0,nvl(b.monto,0),0)),0) as monto_tarjeta from tbl_cja_transaccion_pago a, tbl_cja_trans_forma_pagos b where a.turno = ");
sql.append(turno);

//sql.append(" and  a.anio =(select distinct a.anio from tbl_cja_transaccion_pago a where ");
//if(!usuario.trim().equals("")){sql.append("  and upper(a.usuario_creacion) = upper('");sql.append(usuario);sql.append("')");}

sql.append(" and a.compania = ");
sql.append(compania);
//sql.append(" and trunc(a.fecha_creacion)>= to_date('");
//sql.append(fechaini);
//sql.append("','dd/mm/yyyy') and trunc(a.fecha_creacion)<=to_date('");
//sql.append(fechafin);
//sql.append("','dd/mm/yyyy'))
sql.append(" and (b.tran_anio=a.anio and b.compania=a.compania and b.tran_codigo=a.codigo) and b.fp_codigo <>0 and (a.rec_status = 'A' or (a.rec_status = 'I' and a.turno_anulacion <> a.turno)) ");
	cdoTotal = SQLMgr.getData(sql.toString());
}


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
	String subtitle = " REGISTRO DE DEPOSITOS ";
	String xtraSubtitle = "";
	if (!turno.equals("")) xtraSubtitle = "TURNO #: "+turno+"  -  "+cdoResp.getColValue("responsable");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".07");
		dHeader.addElement(".19");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = "";
		String sc = "";

    // Listado de Registro de Depósitos
    pc.setFont(7, 1);
	pc.addBorderCols("CONS.",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("FECHA",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("DESC. DEPOSITO",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("NO. CIERRE",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("FECHA CREACION",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("USUARIO CREACION",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("MONTO FINAL",2,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("MONTO TARJ.",2,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("DEVOL.",2,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("COMISION",2,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("OBSERVACION",0,1,1.0f,1.0f,0.0f,0.0f);

	String groupBy = "", groupBy2 = "",groupBy3 = "";
	int pxu = 0, pxs = 0, pxg = 0;

	double totMonto = 0, totMtoTarjeta =0, totDevolucion = 0, totComision = 0;
	double totMontoBanco= 0,totMtoTarjetaBanco = 0,totDevolucionBanco = 0,totComisionBanco   = 0;
	double totMontoBancoRed= 0,totMtoTarjetaBancoRed = 0,totDevolucionBancoRed = 0,totComisionBancoRed   = 0;

	double totalMonto = 0, totalMtoTarjeta =0, totalDevolucion = 0, totalComision = 0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!groupBy3.equalsIgnoreCase(cdo.getColValue("tipoDeposito")) && cdo.getColValue("tipoDeposito").trim().equals("5") && fg.trim().equals("DXT") )
		{ // groupBy
			if (i != 0)
			{
					pc.setFont(7, 1,Color.black);
					pc.addCols(" ",0,3);
					pc.addCols(" TOTAL DEPOSITO . . . . . . . . :",2,3);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMontoBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjetaBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComisionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addCols(" ",0,1);
					pc.addCols(" ",0,dHeader.size());

					//totMontoBanco      = 0;
					//totMtoTarjetaBanco = 0;
					//totDevolucionBanco = 0;
					//totComisionBanco   = 0;

			 }
		}
		if (!groupBy3.equalsIgnoreCase(cdo.getColValue("tipoDeposito")) && groupBy3.equalsIgnoreCase("5") && fg.trim().equals("DXT"))
		{ // groupBy
			if (i != 0)
			{
					pc.setFont(7, 1,Color.black);
					pc.addCols(" ",0,3);
					pc.addCols(" TOTAL DEPOSITO CAJA - CAMBIO / REDEPOSITOS . . . . . . . . :",2,3);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMontoBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjetaBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucionBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComisionBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addCols(" ",0,1);
					pc.addCols(" ",0,dHeader.size());

					totMontoBancoRed       = 0;
					totMtoTarjetaBancoRed  = 0;
					totDevolucionBancoRed  = 0;
					totComisionBancoRed    = 0;

			 }
		}

		if (!groupBy2.equalsIgnoreCase(cdo.getColValue("codCaja")+"-"+cdo.getColValue("codBanco")+"-"+cdo.getColValue("ctaBanco")))
		{ // groupBy
			if (i != 0)
			{
					pc.setFont(7, 1,Color.black);
					pc.addCols(" ",0,3);
					pc.addCols(" TOTAL DEP. POR BANCO . . . . . . . . :",2,3);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMontoBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjetaBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComisionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addCols(" ",0,1);
					pc.addCols(" ",0,dHeader.size());

					totMontoBanco      = 0;
					totMtoTarjetaBanco = 0;
					totDevolucionBanco = 0;
					totComisionBanco   = 0;

			 }
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codCaja")))//&& !groupBy2.equalsIgnoreCase(cdo.getColValue("codBanco")))
		{ // groupBy
			  if (i != 0)
			  {
				    pc.setFont(7, 1,Color.black);
					pc.addCols(" ",0,3);
		            pc.addCols(" TOTAL DEP. POR CAJA . . . . . . . . :",2,3);
		            pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMonto),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjeta),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucion),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComision),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addCols(" ",0,1);
					pc.addCols(" ",0,dHeader.size());
			   }
			pc.setFont(8, 1,Color.black);
			pc.addCols("Caja:  "+"[ "+cdo.getColValue("codCaja")+" ] "+cdo.getColValue("descCaja"),0,dHeader.size(),Color.lightGray);

				totMonto      = 0;
				totMtoTarjeta = 0;
				totDevolucion = 0;
				totComision   = 0;
		}
		if (!groupBy2.equalsIgnoreCase(cdo.getColValue("codCaja")+"-"+cdo.getColValue("codBanco")+"-"+cdo.getColValue("ctaBanco")))
		{
				pc.setFont(7, 1,Color.black);
				pc.addBorderCols("Banco:  "+"[ "+cdo.getColValue("codBanco")+" ] "+cdo.getColValue("descBanco"),0,4,1.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" Cuenta Banco:  "+cdo.getColValue("ctaBanco"),0,7,1.0f,0.0f,0.0f,0.0f);
		}



	    // Listado de Registro de Depósitos
		if(cdo.getColValue("tipoDeposito").trim().equals("5"))
	    pc.setFont(7, 0,Color.darkGray);
		 else pc.setFont(7, 0);

		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("consecutivo"),1,1);
			pc.addCols(" "+cdo.getColValue("fechaMovimiento"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("noDocumento"),0,1);

			pc.addCols(" "+cdo.getColValue("fechaCreacion"),0,1);
			pc.addCols(" "+cdo.getColValue("usuario"),0,1);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal(cdo.getColValue("monto1")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("montoTarjeta")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("devolucionTarjeta")),2,1);
     	pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("comision")),2,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);

			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());


		 if(!cdo.getColValue("tipoDeposito").trim().equals("5") || !fg.trim().equals("DXT")){
		 totMonto      += (Double.parseDouble(cdo.getColValue("monto1")));
 		 totMtoTarjeta += (Double.parseDouble(cdo.getColValue("montoTarjeta")));
 		 totDevolucion += (Double.parseDouble(cdo.getColValue("devolucionTarjeta")));
 		 totComision   += (Double.parseDouble(cdo.getColValue("comision")));


		 totMontoBanco      += Double.parseDouble(cdo.getColValue("monto1"));
 		 totMtoTarjetaBanco += Double.parseDouble(cdo.getColValue("montoTarjeta"));
 		 totDevolucionBanco += Double.parseDouble(cdo.getColValue("devolucionTarjeta"));
 		 totComisionBanco   += Double.parseDouble(cdo.getColValue("comision"));

		 totalMonto      += Double.parseDouble(cdo.getColValue("monto1"));
 		 totalMtoTarjeta += Double.parseDouble(cdo.getColValue("montoTarjeta"));
 		 totalDevolucion += Double.parseDouble(cdo.getColValue("devolucionTarjeta"));
 		 totalComision   += Double.parseDouble(cdo.getColValue("comision"));
		 }

		 if(cdo.getColValue("tipoDeposito").trim().equals("5") && fg.trim().equals("DXT")){
		 totMontoBancoRed      += Double.parseDouble(cdo.getColValue("monto1"));
 		 totMtoTarjetaBancoRed += Double.parseDouble(cdo.getColValue("montoTarjeta"));
 		 totDevolucionBancoRed += Double.parseDouble(cdo.getColValue("devolucionTarjeta"));
 		 totComisionBancoRed   += Double.parseDouble(cdo.getColValue("comision"));	}

	  groupBy  = cdo.getColValue("codCaja");
	  groupBy2 = cdo.getColValue("codCaja")+"-"+cdo.getColValue("codBanco")+"-"+cdo.getColValue("ctaBanco");
	  groupBy3 = cdo.getColValue("tipoDeposito");

	  //pxu++;

	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());

	if (al.size() == 0)
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
	    if (groupBy3.equalsIgnoreCase("5") && fg.trim().equals("DXT"))
		{ // groupBy
					pc.setFont(7, 1,Color.black);
					pc.addCols(" ",0,3);
					pc.addCols(" TOTAL DEPÓSITO CAJA - CAMBIO / REDEPÓSITOS . . . . . . . . :",2,3);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMontoBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjetaBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucionBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComisionBancoRed),2,1,0.0f,1.0f,0.0f,0.0f);
					pc.addCols(" ",0,1);
					pc.addCols(" ",0,dHeader.size());

					totMontoBancoRed       = 0;
					totMtoTarjetaBancoRed  = 0;
					totDevolucionBancoRed  = 0;
					totComisionBancoRed    = 0;

		}

		pc.setFont(7, 1,Color.black);
		pc.addCols(" ",0,3);
		pc.addCols(" TOTAL DEP. POR BANCO . . . . . . . . :",2,3);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMontoBanco),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjetaBanco),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComisionBanco),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);

		pc.addCols(" ",0,3);
		pc.addCols(" TOTAL DEP. POR CAJA . . . . . . . . :",2,3);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMonto),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totMtoTarjeta),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDevolucion),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totComision),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);

		pc.setFont(7, 1, Color.black);
		pc.addCols(" ",0,3);
		pc.addCols(" GRAN TOTAL . . . . . . . . :",2,3);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totalMonto),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totalMtoTarjeta),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totalDevolucion),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totalComision),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);

	  pc.setFont(8,0);
	  //pc.addCols(" ",1,dHeader.size(),Color.lightGray);

	}
	if(fg.trim().equals("DXT"))
	  {

			pc.setFont(8,1);
	  	pc.addCols("TOTALES POR TURNO DE CAJA PARA DEPOSITOS DEL "+fechaini+"  AL  "+fechafin+"",0,dHeader.size());
									pc.setFont(8,0);
									pc.addBorderCols("TURNO",1,2);
									pc.addBorderCols("EFECTIVO",1,1);
									pc.addBorderCols("ACH",1,1);
									pc.addBorderCols("TRANSF.",1,1);
									pc.addBorderCols("CHEQUE",1,2);
									pc.addBorderCols("TARJETA",1,2);
									pc.addBorderCols("DINNER",1,1);
									pc.addBorderCols("TOTALES",1,1);
									double t_monto = 0.00;
									 t_monto = Double.parseDouble(cdoTotal.getColValue("monto_efectivo"))+ Double.parseDouble(cdoTotal.getColValue("monto_transf"))+ Double.parseDouble(cdoTotal.getColValue("monto_ach"))+Double.parseDouble(cdoTotal.getColValue("monto_cheque"))+ Double.parseDouble(cdoTotal.getColValue("monto_tarj6"))+ Double.parseDouble(cdoTotal.getColValue("monto_tarjeta"));
									pc.setFont(8, 1);
									pc.addCols(""+turno, 1,2);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_efectivo")), 1,1);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_ach")), 1,1);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_transf")), 1,1);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_cheque")), 1,2);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_tarjeta")), 1,2);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_tarj6")), 1,1);
									pc.setFont(8,1);
									pc.addCols(""+CmnMgr.getFormattedDecimal(t_monto), 1,1);

					pc.addCols("Nota: Recuerde que los totales no toman en cuenta los monto de la caja-cambio ni de redepositos en caso de que se aplique a este Turno",0,dHeader.size());


	  }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>



