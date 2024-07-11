<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%@ include file="../common/pdf_header.jsp"%>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String usuario = request.getParameter("usuario");
String compania = request.getParameter("compania");
String fg = request.getParameter("fg");
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String consecutivo = request.getParameter("consecutivo");

if(appendFilter== null)appendFilter="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
ArrayList al   = new ArrayList();
ArrayList alTot   = new ArrayList();
StringBuffer sbSql = new StringBuffer();

if (usuario==null) usuario = "";
if (compania==null) compania = (String) session.getAttribute("_companyId");
if (turno==null) turno = "";
if (caja==null) caja = "";
if (fechaini==null) fechaini = "";
if (fechafin==null) fechafin = "";
if (fg==null) fg = "";
if (banco==null) banco = "";
if (cuenta==null) cuenta = "";
if (consecutivo==null) consecutivo = "";

sbSql.append(" select a.turno,a.caja,nvl(sum(decode(b.fp_codigo,'1',nvl(b.monto,0),0)),0)as monto_efectivo,nvl(sum(decode(b.fp_codigo,'5',nvl(b.monto,0),0)),0)as monto_ach,nvl(sum(decode(b.fp_codigo,'2',nvl(b.monto,0),0)),0)as monto_cheque, nvl(sum(decode(b.fp_codigo,'6', nvl(b.monto,0),0)),0) as monto_debito ,nvl(sum(decode(b.fp_codigo,'3',nvl(b.monto,0),0)),0)as tarjeta_credito from tbl_cja_transaccion_pago a, tbl_cja_trans_forma_pagos b ,tbl_cja_turnos_x_cajas ctu where ctu.compania = a.compania  and ctu.cod_turno = a.turno and ctu.cod_caja = a.caja ");

sbSql.append("  and a.compania = ");
sbSql.append(compania);
if(!turno.trim().equals("")){sbSql.append(" and a.turno in(");sbSql.append(turno);sbSql.append(")");}
if(!usuario.trim().equals("")&&!fg.trim().equals("CONTA")){sbSql.append(" and a.usuario_creacion = '");sbSql.append(usuario);sbSql.append("'");}
if(!fechaini.trim().equals("")){sbSql.append(" and trunc(ctu.fecha_creacion) >= to_date('");sbSql.append(fechaini);sbSql.append("','dd/mm/yyyy')");}
if(!fechafin.trim().equals("")){sbSql.append(" and trunc(ctu.fecha_creacion) <= to_date('");sbSql.append(fechafin);sbSql.append("','dd/mm/yyyy')");}
sbSql.append(" and (b.tran_anio=a.anio and b.compania=a.compania and b.tran_codigo=a.codigo) and (b.tran_anio=a.anio and b.compania=a.compania and b.tran_codigo=a.codigo) and a.rec_status <> 'I' group by a.turno,a.caja order by a.caja,a.turno asc ");
if(!fg.trim().equals("BANCO"))alTot = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select m.consecutivo_ag as codigo, to_char(m.f_movimiento,'dd/mm/yyyy') as fecha ,m.descripcion, to_char(m.fecha_creacion,'dd/mm/yyyy')as fecha_creacion, nvl(m.monto,0) as monto, m.observacion, m.cuenta_banco,m.banco, m.caja,m.compania,to_char(m.turno)as turno, nvl(m.mto_tot_tarjeta,0)as mto_tot_tarjeta, m.tipo_tarjeta, nvl(m.comision,0) as comision, nvl(m.devoluc_tarj,0) as devoluc_tarj, m.num_documento, decode(m.tipo_dep,'5',5,1) as tipo_dep, ban.nombre as nombrebanco");
if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA"))sbSql.append(", ca.descripcion as nombrecaja");
sbSql.append(" ,m.usuario_creacion usuario,1 ord ,nvl(m.itbms,0) as itbms from tbl_con_movim_bancario m, tbl_con_banco ban");
if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA"))sbSql.append(" ,tbl_cja_cajas ca");

sbSql.append("  where m.compania = ");
sbSql.append(compania);

if(!fechaini.trim().equals("")){sbSql.append(" and trunc(m.f_movimiento) >= to_date('");sbSql.append(fechaini);sbSql.append("','dd/mm/yyyy')");}
if(!fechafin.trim().equals("")){sbSql.append(" and trunc(m.f_movimiento) <= to_date('");sbSql.append(fechafin);sbSql.append("','dd/mm/yyyy')");}
if(!usuario.trim().equals("")&&!fg.trim().equals("CONTA")){sbSql.append(" and m.usuario_creacion = '");sbSql.append(usuario);sbSql.append("'");}
if(!turno.trim().equals("")&&!fg.trim().equals("CONTA")){sbSql.append(" and m.turno in(");sbSql.append(turno);sbSql.append(")");}
if(!caja.trim().equals("")&&!fg.trim().equals("BANCO")){sbSql.append(" and m.caja = ");sbSql.append(caja);}
sbSql.append(" and m.compania = ban.compania and m.banco = ban.cod_banco");
if(!banco.trim().equals("")){sbSql.append(" and m.banco ='");sbSql.append(banco);sbSql.append("'");}
if(!cuenta.trim().equals("")){sbSql.append(" and m.cuenta_banco ='");sbSql.append(cuenta);sbSql.append("'");}
if(!consecutivo.trim().equals("")){sbSql.append(" and m.consecutivo_ag =");sbSql.append(consecutivo);}


if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA"))sbSql.append(" and m.caja=ca.codigo and m.compania=ca.compania");
else sbSql.append(" and m.caja is null ");

if(fg.trim().equals("CONTA"))sbSql.append(" and m.dep_conta='S' ");

if(fg.trim().equals("CONT")){sbSql.append(" union all ");
sbSql.append("select m.consecutivo_ag as codigo, to_char(m.f_movimiento,'dd/mm/yyyy') as fecha ,m.descripcion, to_char(m.fecha_creacion,'dd/mm/yyyy')as fecha_creacion, nvl(m.monto,0) as monto, m.observacion, m.cuenta_banco,m.banco, m.caja,m.compania,replace(m.turnos_cierre,'|',',') , nvl(m.mto_tot_tarjeta,0)as mto_tot_tarjeta, m.tipo_tarjeta, nvl(m.comision,0) as comision, nvl(m.devoluc_tarj,0) as devoluc_tarj, m.num_documento, decode(m.tipo_dep,'5',5,1) as tipo_dep, ban.nombre as nombrebanco");
sbSql.append(", '' as nombrecaja");
sbSql.append(" ,m.usuario_creacion usuario,2 ord,nvl(m.itbms,0) as itbms  from tbl_con_movim_bancario m, tbl_con_banco ban");
if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA")&&!fg.trim().equals("CONT"))sbSql.append(" ,tbl_cja_cajas ca");

sbSql.append("  where m.compania = ");
sbSql.append(compania);

if(!fechaini.trim().equals("")){sbSql.append(" and trunc(m.f_movimiento) >= to_date('");sbSql.append(fechaini);sbSql.append("','dd/mm/yyyy')");}
if(!fechafin.trim().equals("")){sbSql.append(" and trunc(m.f_movimiento) <= to_date('");sbSql.append(fechafin);sbSql.append("','dd/mm/yyyy')");}
if(!usuario.trim().equals("")){sbSql.append(" and m.usuario_creacion = '");sbSql.append(usuario);sbSql.append("'");}
if(!turno.trim().equals("")&&!fg.trim().equals("CONTA")&&!fg.trim().equals("CONT")){sbSql.append(" and m.turno in(");sbSql.append(turno);sbSql.append(")");}
if(!caja.trim().equals("")&&!fg.trim().equals("BANCO")){sbSql.append(" and m.caja = ");sbSql.append(caja);}
sbSql.append(" and m.compania = ban.compania and m.banco = ban.cod_banco");
if(!banco.trim().equals("")){sbSql.append(" and m.banco ='");sbSql.append(banco);sbSql.append("'");}
if(!cuenta.trim().equals("")){sbSql.append(" and m.cuenta_banco ='");sbSql.append(cuenta);sbSql.append("'");}
if(!consecutivo.trim().equals("")){sbSql.append(" and m.consecutivo_ag =");sbSql.append(consecutivo);}


if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA")&&!fg.trim().equals("CONT"))sbSql.append(" and m.caja=ca.codigo and m.compania=ca.compania");
else sbSql.append(" and m.caja is null ");

//solo los depositos con multiles turnos
sbSql.append(" and m.dep_conta='S' ");


}


if(fg.trim().equals("CONT"))sbSql.append(" order by 21,9,11,8,17,1,21");
else sbSql.append(" order by m.banco, m.tipo_dep,m.consecutivo_ag");
			al = SQLMgr.getDataList(sbSql.toString());

	if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

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
	String title = "CAJA/BANCO";
	String subtitle = "REGISTRO DE DEPOSITOS";
	String xtraSubtitle = (!fg.trim().equals("CONT")&&!fg.trim().equals("BANCO"))?" Turno: "+turno:"  DEL  "+fechaini+"  AL  "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;
	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".07");
	dHeader.addElement(".11");
	dHeader.addElement(".09");
	dHeader.addElement(".09");
	dHeader.addElement(".12");
	dHeader.addElement(".08");
	dHeader.addElement(".08");
	dHeader.addElement(".05");
	dHeader.addElement(".26");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("código",1);
	pc.addBorderCols("Fecha",1);
	pc.addBorderCols("Fecha Creación",1);
	pc.addBorderCols("No. de Cierre",1);
	if(fg.trim().equals("CONTA"))
	{
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Observación",1,5);

	}
	else{
	pc.addBorderCols("Monto Final",1);
	pc.addBorderCols("Monto de Tarjeta",1);
	pc.addBorderCols("Devolución",1);
	pc.addBorderCols("Comisión",1);
	pc.addBorderCols("Itbms",1);
	pc.addBorderCols("Observación",1);}

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);

	String groupByCaja= "",groupByTurno= "",groupByBan= "";
	String groupBy="";
	double monto_tot_turno =0.00 ,monto_tarjeta_turno =0.00,monto_dev_turno =0.00,monto_comision_turno=0.00,monto_itbms_turno=0.00;
	double monto_tot_cja =0.00 ,monto_tarjeta_cja =0.00,monto_dev_cja =0.00,monto_comision_cja=0.00,monto_itbms_cja=0.00;
	double monto_prueba =0.00,monto_tot_rep =0.00,monto_tarjeta_rep =0.00,monto_dev_rep =0.00,monto_comision_rep = 0.00,monto_total_caja = 0.00,monto_itbms_rep=0.00;
	double monto_total = 0.00,monto_tarjeta =  0.00,monto_comision =  0.00,monto_dev =  0.00,monto_itbms=0.00;
	double monto_dev_ban =  0.00,monto_tot_ban = 0.00,monto_tarjeta_ban =  0.00,monto_comision_ban=  0.00,monto_itbms_ban=0.00;
    double totEfectivo=0.00,totAch=0.00,totCheque=0.00,totTarj6=0.00,totTarjeta=0.00,totalRep=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		if(i!=0)
		{
			if(!groupByBan.equalsIgnoreCase(cdo1.getColValue("banco"))||!groupByTurno.equalsIgnoreCase(cdo1.getColValue("turno"))||!groupByCaja.equalsIgnoreCase(cdo1.getColValue("caja")))
			{
				pc.addCols(" ", 2,dHeader.size());
				pc.setFont(7, 1);
				pc.addCols("Total Depósitado por Banco: ", 2, 4);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_ban), 2, 1);
				if(!fg.trim().equals("CONTA"))
				{
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_ban), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_ban), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_ban), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_ban), 2, 1);
				}
				else pc.addCols(" ", 2, 4);
				pc.addCols("", 2, 1);

				pc.setFont(7, 1);
				pc.addCols(" ", 2,dHeader.size());

				monto_tot_ban =0.00 ;
				monto_tarjeta_ban =0.00;
				monto_dev_ban =0.00;
				monto_comision_ban=0.00;
				monto_itbms_ban=0.00;
				monto_total = 0.00;
			}
			if(!groupByTurno.equalsIgnoreCase(cdo1.getColValue("turno"))||!groupByCaja.equalsIgnoreCase(cdo1.getColValue("caja")))
			{
				pc.setFont(7, 1);
				pc.addCols("Total Depósitado por turno: ", 2, 4);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_turno), 2, 1);
				if(!fg.trim().equals("CONTA"))
				{pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_turno), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_turno), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_turno), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_turno), 2, 1);
				}

				else pc.addCols("", 2, 1);
				pc.addCols("", 2, 1);
				pc.addCols(" ", 2,dHeader.size());

				monto_tot_turno =0.00 ;
				monto_tarjeta_turno =0.00;
				monto_dev_turno =0.00;
				monto_comision_turno=0.00;
				monto_itbms_turno=0.00;
			}
			if(!groupByCaja.equalsIgnoreCase(cdo1.getColValue("caja")))
			{
				pc.setFont(7, 1);
				pc.addCols("Total Depósitado por Caja: ", 2, 4);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_cja), 2, 1);
				if(!fg.trim().equals("CONTA"))
				{pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_cja), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_cja), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_cja), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_cja), 2, 1);}
				else pc.addCols("", 2, 4);
				pc.addCols("", 2, 1);
				pc.addCols(" ", 2,dHeader.size());

				monto_tot_cja =0.00 ;
				monto_tarjeta_cja =0.00;
				monto_dev_cja =0.00;
				monto_comision_cja=0.00;
				monto_itbms_cja=0.00;
			}
		}
		if(!groupByCaja.equalsIgnoreCase(cdo1.getColValue("caja"))||!groupByTurno.equalsIgnoreCase(cdo1.getColValue("turno")))
		{
			pc.setFont(7, 1);
			pc.addCols("Caja  ", 0,1);
			pc.addCols(""+cdo1.getColValue("caja"), 0,1);
			pc.addCols(""+cdo1.getColValue("nombrecaja"), 0,4);
			pc.addCols("  TURNO : "+cdo1.getColValue("turno")+" - "+cdo1.getColValue("usuario"), 0,4);
		}
		if(!groupByCaja.equalsIgnoreCase(cdo1.getColValue("caja"))||!groupByTurno.equalsIgnoreCase(cdo1.getColValue("turno"))||!groupByCaja.equalsIgnoreCase(cdo1.getColValue("banco")))
		{
			pc.setFont(7, 1);
			pc.addCols("Banco  ", 0,1);
			pc.addCols(""+cdo1.getColValue("banco"), 0,1);
			pc.addCols(""+cdo1.getColValue("nombrebanco"), 0,8);
		}

		if(!cdo1.getColValue("tipo_dep").trim().equals("5"))
		{
				monto_tot_rep += Double.parseDouble(cdo1.getColValue("monto"));
				monto_tarjeta_rep += Double.parseDouble(cdo1.getColValue("mto_tot_tarjeta"));
				monto_comision_rep += Double.parseDouble(cdo1.getColValue("comision"));
				monto_dev_rep +=  Double.parseDouble(cdo1.getColValue("devoluc_tarj"));
				monto_itbms_rep += Double.parseDouble(cdo1.getColValue("itbms"));

				monto_tot_ban += Double.parseDouble(cdo1.getColValue("monto"));
				monto_tarjeta_ban += Double.parseDouble(cdo1.getColValue("mto_tot_tarjeta"));
				monto_comision_ban += Double.parseDouble(cdo1.getColValue("comision"));
				monto_itbms_ban += Double.parseDouble(cdo1.getColValue("itbms"));
				monto_dev_ban +=  Double.parseDouble(cdo1.getColValue("devoluc_tarj"));

				monto_tot_turno += Double.parseDouble(cdo1.getColValue("monto"));
				monto_tarjeta_turno += Double.parseDouble(cdo1.getColValue("mto_tot_tarjeta"));
				monto_comision_turno += Double.parseDouble(cdo1.getColValue("comision"));
				monto_itbms_turno += Double.parseDouble(cdo1.getColValue("itbms"));
				monto_dev_turno +=  Double.parseDouble(cdo1.getColValue("devoluc_tarj"));

				monto_tot_cja += Double.parseDouble(cdo1.getColValue("monto"));
				monto_tarjeta_cja += Double.parseDouble(cdo1.getColValue("mto_tot_tarjeta"));
				monto_comision_cja += Double.parseDouble(cdo1.getColValue("comision"));
				monto_itbms_cja += Double.parseDouble(cdo1.getColValue("itbms"));
				monto_dev_cja +=  Double.parseDouble(cdo1.getColValue("devoluc_tarj"));

				monto_total_caja += Double.parseDouble(cdo1.getColValue("monto"));
				monto_total +=  Double.parseDouble(cdo1.getColValue("monto"));
		}

		pc.setFont(7, 0);
		pc.addCols(""+cdo1.getColValue("codigo"), 1,1);
		pc.addCols(""+cdo1.getColValue("fecha"), 1,1);
		pc.addCols(""+cdo1.getColValue("fecha_creacion"), 1,1);
		pc.addCols(""+cdo1.getColValue("num_documento"), 1,1);
		pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")), 2,1);
		if(!fg.trim().equals("CONTA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("mto_tot_tarjeta")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("devoluc_tarj")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("comision")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("itbms")), 2,1);
		pc.addCols(""+cdo1.getColValue("observacion"), 0,1);}
		else
		{
		pc.addCols(""+cdo1.getColValue("observacion"), 0,5);
		}

		monto_tarjeta = monto_tarjeta + Double.parseDouble(cdo1.getColValue("mto_tot_tarjeta"));
		monto_comision = monto_comision + Double.parseDouble(cdo1.getColValue("comision"));
		monto_dev = monto_dev + Double.parseDouble(cdo1.getColValue("devoluc_tarj"));
		monto_itbms = monto_itbms + Double.parseDouble(cdo1.getColValue("itbms"));

		groupByCaja=cdo1.getColValue("caja");
		groupByTurno=cdo1.getColValue("turno");
		groupByBan=cdo1.getColValue("banco");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
}

if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.addCols(" ", 2,dHeader.size());
		pc.setFont(7, 1);
		pc.addCols("Total Depósitado por Banco: ", 2, 4);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_ban), 2, 1);
		if(!fg.trim().equals("CONTA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_ban), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_ban), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_ban), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_ban), 2, 1);
		pc.addCols(" ", 2, 1); }
		else pc.addCols("", 2, 5);

		pc.setFont(7, 1);
		pc.addCols("Total Depósitado por turno: ", 2, 4);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_turno), 2, 1);
		if(!fg.trim().equals("CONTA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_turno), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_turno), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_turno), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_turno), 2, 1);
		pc.addCols(" ", 2, 1);  }
		else pc.addCols("", 2, 5);

		pc.addCols("Total Depósitado por Caja: ", 2, 4);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tot_cja), 2, 1);
		if(!fg.trim().equals("CONTA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_cja), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_cja), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_cja), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_cja), 2, 1);
		pc.addCols(" ", 2, 1);}
		else pc.addCols("", 2, 5);

		pc.addCols(" ", 2,dHeader.size());

		pc.setFont(9, 1);
		pc.addCols("Gran Total Depositado por Reporte: ", 2, 4);
		pc.addCols("$"+CmnMgr.getFormattedDecimal(monto_tot_rep), 2, 1);
		if(!fg.trim().equals("CONTA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_tarjeta_rep), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_dev_rep), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_comision_rep), 2, 1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_itbms_rep), 2, 1);
		pc.addCols("", 2, 1);
		}
		else pc.addCols("", 2, 5);
	}

	if(!fg.trim().equals("BANCO")&&!fg.trim().equals("CONTA")){
	pc.setFont(7, 1);
	pc.addCols(" ", 2,dHeader.size());
	pc.addCols("TOTALES POR TURNOS DE CAJER@ PARA DEPOSITOS DEL "+fechaini+"  AL  "+fechafin+"",0,dHeader.size());
	
	pc.addBorderCols("Caja",1);
	pc.addBorderCols("Turno",1);
	pc.addBorderCols("Efectivo",1);
	pc.addBorderCols("Ach",1);
	pc.addBorderCols("Cheque",1);
	pc.addBorderCols("Tarjeta Deb.",1);
	pc.addBorderCols("Tarjeta Cre.",1);
	pc.addBorderCols("Totales",2,2);
	pc.addBorderCols(" ",2,1);
	
	for (int i=0; i<alTot.size(); i++)
	{
		CommonDataObject cdoTotal = (CommonDataObject) alTot.get(i);
		double t_monto = 0.00;
	 t_monto = Double.parseDouble(cdoTotal.getColValue("monto_efectivo"))+ Double.parseDouble(cdoTotal.getColValue("monto_ach"))+Double.parseDouble(cdoTotal.getColValue("monto_cheque"))+ Double.parseDouble(cdoTotal.getColValue("monto_debito"))+ Double.parseDouble(cdoTotal.getColValue("tarjeta_credito"));

		pc.setFont(7, 0);
		pc.addCols(""+cdoTotal.getColValue("caja"), 1,1);
		pc.addCols(""+cdoTotal.getColValue("turno"), 1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_efectivo")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_ach")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_cheque")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_debito")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("tarjeta_credito")), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(t_monto), 2,2);
		pc.addCols(" ", 2,1);
		totEfectivo += Double.parseDouble(cdoTotal.getColValue("monto_efectivo"));
		totAch += Double.parseDouble(cdoTotal.getColValue("monto_ach"));
		totCheque += Double.parseDouble(cdoTotal.getColValue("monto_cheque"));
		totTarj6 += Double.parseDouble(cdoTotal.getColValue("monto_debito"));
		totTarjeta += Double.parseDouble(cdoTotal.getColValue("tarjeta_credito"));
		totalRep +=t_monto;

	}

		pc.addCols(" ", 2,dHeader.size());
		pc.setFont(7, 0);
		pc.addCols(" TOTALES ", 1,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totEfectivo), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totAch), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totCheque), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totTarj6), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totTarjeta), 2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totalRep), 2,2);
		pc.addCols(" ", 2,1);
		pc.addCols(" ", 2,dHeader.size());
		if(!fg.trim().equals("CONTA"))pc.addCols("Nota: Los totales no toman en cuenta los monto de la caja-cambio ni de redepositos en caso de que se aplique a estos Turnos",0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

 }//GET

%>



