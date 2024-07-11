<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String banco = request.getParameter("banco");
String nombre = request.getParameter("nombre");
String descripcion = request.getParameter("cuenta");
String cuenta = request.getParameter("cuenta");
String orderBy = request.getParameter("orderBy");

if (appendFilter  == null) appendFilter  = "";


sbSql.append("select x.beneficiario, x.cuentaCode, x.cuenta, x.bancoCode, x.banco, x.f_emision, x.fecha, x.fechaExpira, x.fechaPago, x.codigo_order, x.codigo, x.monto, x.estadoTrx, x.estado, x.tipo_pago, x.tipo_mov, x.docType, x.estado_dep, x.estadoDep from (");
	sbSql.append("select a.beneficiario, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.cod_banco as bancoCode, d.nombre as banco, a.f_emision, to_char(a.f_emision,'dd/mm/yyyy') as fecha, to_char(a.f_expiracion,'dd/mm/yyyy') as fechaExpira, nvl(to_char(a.f_pago_banco,'dd/mm/yyyy'),' ') as fechaPago, (case when instr(a.num_cheque, 'A' ) = 1 then 'A' when instr(a.num_cheque, 'T' ) = 1 then 'T' when instr(a.num_cheque, '-A' ) = 1 then 'A' when instr(a.num_cheque, '-T' ) = 1 then '-T' when instr(a.num_cheque, '-' ) = 1 then '-' else 'C' end) || lpad(trim(TRANSLATE(a.num_cheque, '-AT', '  ')), 10, '0') codigo_order, a.num_cheque as codigo, -a.monto_girado as monto, decode(a.estado_cheque,'G','GIRADO','P','PAGADO','A','ANULADO') as estadoTrx, a.estado_cheque as estado, decode(a.tipo_pago,'1','CHEQUE','2','ACH','3','TRANSF.') as tipo_pago, a.tipo_pago as tipo_mov, 'CHK' as docType, decode(a.tipo_pago,'1','4','2','5','3','6') as tipoTrx, ' ' as estado_dep, ' ' as estadoDep from tbl_con_cheque a, tbl_con_cuenta_bancaria c, tbl_con_banco d where a.cuenta_banco = c.cuenta_banco and a.cod_banco = c.cod_banco and a.cod_compania = d.compania and a.cod_banco = d.cod_banco and a.cod_compania = c.compania and a.cod_compania = ");

	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and upper(a.cod_banco) = '");
	sbSql.append(banco.toUpperCase());
	sbSql.append("' and upper(a.cuenta_banco) = '");
	sbSql.append(cuenta.toUpperCase());
	sbSql.append("'");

	sbSql.append(" union all ");

	sbSql.append("select b.descripcion||decode(e.descripcion,null,'',' - '||e.descripcion) as tipo, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.banco as bancoCode, d.nombre as banco, a.f_movimiento, to_char(a.f_movimiento,'dd/mm/yyyy') as fecha, to_char(a.f_movimiento,'dd/mm/yyyy') as fechaExpira, nvl(to_char(a.fecha_pago,'dd/mm/yyyy'),' ') as fechaPago, lpad(a.consecutivo_ag, 10,'0')codigo_order, to_char(a.consecutivo_ag) as codigo, decode(a.tipo_movimiento,'3',-a.monto,a.monto) as monto, decode(a.estado_trans,'T','TRAMITADA','C','CONCILIADA','A','ANULADA') as estadoTrx, a.estado_trans as estado, decode(a.tipo_movimiento,'1','DEPOSITO','2','N/DEBITO','3','N/CREDITO','OTRAS TRX BANCO') as tipo_pago, to_number(a.tipo_movimiento) as tipo_mov, 'DEP' as docType, decode(a.tipo_movimiento,'1','1','2','2','3','3','7') as tipoTrx, nvl(a.estado_dep,'-') as estado_dep, decode(a.estado_dep,'DT','EN TRANSITO','DN','DEPOSITADO') as estadoDep from tbl_con_movim_bancario a, tbl_con_tipo_movimiento b, tbl_con_cuenta_bancaria c, tbl_con_banco d, tbl_con_tipo_deposito e where a.tipo_dep = e.codigo(+) and nvl(e.mov_banco,'S') = 'S' and a.tipo_movimiento = b.cod_transac and a.cuenta_banco = c.cuenta_banco and a.banco = c.cod_banco and a.compania = c.compania and a.compania = d.compania and a.banco = d.cod_banco and a.compania = ");

	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and upper(a.banco) = '");
	sbSql.append(banco.toUpperCase());
	sbSql.append("'");
	sbSql.append(" and upper(a.cuenta_banco) = '");
	sbSql.append(cuenta.toUpperCase());
	sbSql.append("'");
	sbSql.append(" order by ");
	sbSql.append(orderBy);
sbSql.append(") x");
if (!appendFilter.trim().equals("")) { sbSql.append(" where "); sbSql.append(appendFilter.substring(4)); }

al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String title = "BANCOS";
	String subtitle = "MOVIMIENTO BANCARIO";
	String xtraSubtitle = "TRANSACCIONES A CONCILIAR";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

			dHeader.addElement(".35");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".15");
			dHeader.addElement(".10");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addBorderCols("DESCRIPCION",0);
			pc.addBorderCols("No. DOC",1);
			pc.addBorderCols("FECHA",1);
			pc.addBorderCols("ESTADO",1);
			pc.addBorderCols("ESTADO DEP.",1);
			pc.addBorderCols("TIPO",0);
			pc.addBorderCols("MONTO",2);

			pc.addCols("",1,dHeader.size());

			pc.addCols("BANCO:     "+nombre,0,2);
			pc.addCols("CUENTA BANCARIA: ",1,3);
			pc.addCols(""+descripcion,0,2);

			pc.addCols("",1,dHeader.size());


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	double saldo = 0.00, montoFinal = 0;

//if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		//saldo += Double.parseDouble(cdo.getColValue("debito"));
		//saldo -= Double.parseDouble(cdo.getColValue("credito"));


			pc.addCols(" "+cdo.getColValue("beneficiario"),0,1);

			pc.addCols(" "+cdo.getColValue("codigo"),1,1);

			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" "+cdo.getColValue("estadoTrx"),1,1);
			pc.addCols(" "+cdo.getColValue("estadoDep"),1,1);
			pc.addCols(" "+cdo.getColValue("tipo_pago"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);

			montoFinal += Double.parseDouble(cdo.getColValue("monto"));


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
			pc.addCols("Total Final ",2,6);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoFinal),2,1);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
		}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>