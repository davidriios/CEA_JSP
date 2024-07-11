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

StringBuffer sbSql  = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String tipo_doc = request.getParameter("tipo_doc");
String fg = request.getParameter("fg");

if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(tipo_doc==null) tipo_doc="";
if(fg==null) fg="";

if (appendFilter == null) appendFilter = "";
if(!fechaini.equals("")) appendFilter += " and trunc(mb.f_movimiento)>= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if(!fechafin.equals("")) appendFilter += " and trunc(mb.f_movimiento)<= to_date('"+fechafin+"', 'dd/mm/yyyy')";

//Depositos desde Banco
sbSql.append("select  mb.num_documento,1 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_doc, mb.caja,mb.compania,mb.usuario_creacion, mb.turno,cb.cg_1_cta1 as cta1, cb.cg_1_cta2 as cta2,cb.cg_1_cta3 as cta3,cb.cg_1_cta4 as cta4,cb.cg_1_cta5 as cta5,cb.cg_1_cta6 as cta6,sum (nvl (mb.monto, 0)) debito,0 as credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans = 'C' and mb.tipo_movimiento in(select column_value from table( select split((get_sec_comp_param(mb.compania,'CJA_TP_MOV_DEP')),',') from dual)) and mb.caja is null and mb.turno is null having   sum (nvl (mb.monto, 0)) > 0 group by mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania,cb.cg_1_cta1,cb.cg_1_cta2,cb.cg_1_cta3,cb.cg_1_cta4,cb.cg_1_cta5,cb.cg_1_cta6,mb.num_documento,mb.tipo_movimiento,cb.descripcion,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6");
sbSql.append("  union all ");//CONTRA CUENTA DE DEPOSITOS
sbSql.append(" select  mb.num_documento,1.5 orden,mb.f_movimiento, mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento,mb.caja,mb.compania,mb.usuario_creacion,mb.turno,getCta(mb.compania,'CTA_CJA_GENERAL',1)cta1,getCta(mb.compania,'CTA_CJA_GENERAL',2)cta2,getCta(mb.compania,'CTA_CJA_GENERAL',3)cta3,getCta(mb.compania,'CTA_CJA_GENERAL',4)cta4,getCta(mb.compania,'CTA_CJA_GENERAL',5)cta5,getCta(mb.compania,'CTA_CJA_GENERAL',6)cta6,0 debito,sum (nvl (mb.monto, 0)) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,nvl(get_sec_comp_param(mb.compania,'CTA_CJA_GENERAL'),' ') cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb  where mb.compania = "); 
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans = 'C' and mb.tipo_movimiento in(select column_value from table( select split((get_sec_comp_param(mb.compania,'CJA_TP_MOV_DEP')),',') from dual)) and mb.caja is null and mb.turno is null having   sum (nvl (mb.monto, 0)) > 0 group by   mb.caja,mb.usuario_creacion,mb.turno, mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania, mb.num_documento, mb.tipo_movimiento,cb.descripcion ");
sbSql.append(" union  all ");//NOTAS DE CREDITO CUENTA DE BANCO
sbSql.append(" select  mb.num_documento,2 orden,mb.f_movimiento, mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento, mb.caja,mb.compania, mb.usuario_creacion,mb.turno,cb.cg_1_cta1,cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,decode(t.tipo_mov,'CR', sum(nvl (mb.monto, 0)),0) debito, decode(t.tipo_mov,'DB', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.lado = decode(t.tipo_mov, 'CR', 'DB', 'CR') and mb.tipo_movimiento = '2'  group by   mb.caja,mb.usuario_creacion,mb.turno, mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento,mb.compania,mb.num_documento,mb.tipo_movimiento,cb.descripcion,cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,t.tipo_mov,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6");
sbSql.append(" union all ");//NOTAS DE CREDITO CONTRA CUENTA
sbSql.append(" select  mb.num_documento,2.5 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento,mb.caja,mb.compania,mb.usuario_creacion,mb.turno,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,decode(t.tipo_mov,'DB', sum(nvl (mb.monto, 0)),0) debito,decode(t.tipo_mov,'CR', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.lado = decode(t.tipo_mov, 'CR', 'DB', 'CR') and mb.tipo_movimiento = '2' group by   mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento,mb.compania,mb.num_documento,mb.tipo_movimiento,cb.descripcion,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,t.tipo_mov ,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 ");
sbSql.append(" union all ");//NOTAS DE DEBITO CUENTA DE BANCO
sbSql.append(" select  mb.num_documento,3 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento, mb.caja,mb.compania,mb.usuario_creacion,mb.turno,cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,decode(t.tipo_mov,'CR', sum(nvl (mb.monto, 0)),0) debito,decode(t.tipo_mov,'DB', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco ,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.lado = decode(t.tipo_mov, 'CR', 'DB', 'CR') and mb.tipo_movimiento = '3' group by  mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania,mb.num_documento, mb.tipo_movimiento, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,t.tipo_mov,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6,cb.descripcion ");
sbSql.append(" union all  ");//NOTAS DE DEBITO CONTRACUENTA
sbSql.append(" select  mb.num_documento,3.5 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy') f_movimiento,mb.caja, mb.compania,mb.usuario_creacion,mb.turno,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,decode(t.tipo_mov,'DB', sum(nvl (mb.monto, 0)),0) debito,decode(t.tipo_mov,'CR', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco ,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 cuenta from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString()); 
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.lado = decode(t.tipo_mov, 'CR', 'DB', 'CR') and mb.tipo_movimiento = '3' group by   mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento,mb.compania,mb.num_documento,mb.tipo_movimiento,cb.descripcion,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,t.tipo_mov,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 order by 5,4,1,2,3 asc ");
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
	String subtitle = "MOVIMIENTO BANCARIO (EN LIBRO DE CAJA/BANCO)";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".40");
			dHeader.addElement(".15");
			dHeader.addElement(".15"); 

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);			
			pc.addBorderCols("TIPO DOC.",0);
			pc.addBorderCols("No. DOC.",1);
			pc.addBorderCols("FECHA",1);
			pc.addBorderCols("CUENTA",1);
			pc.addBorderCols("DEBITO",1);
			pc.addBorderCols("CREDITO",0);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	String groupBy = "",groupBy2="",groupBy3="";
	double saldo = 0.00,totalDb = 0.00, totalCr = 0.00,totalDbBanco= 0.00,totalCrBanco = 0.00,totDbBanco= 0.00,totCrBanco = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(!groupBy.trim().equals(cdo.getColValue("banco")+"-"+cdo.getColValue("cuenta_banco")))
		{	pc.setFont(8, 1);
			if(i!=0)
			{
				pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,4);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbBanco),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrBanco),2,1);

				totalDbBanco = 0.00;
				totalCrBanco = 0.00;
			}
			
			if(!groupBy2.trim().equals(cdo.getColValue("banco")))
			{	pc.setFont(8, 1);
				if(i!=0)
				{
					pc.addCols("TOTAL POR BANCO : ",1,4);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);
					totDbBanco = 0.00;
					totCrBanco = 0.00;
				}
	
				if(i!=0)pc.addCols(" ",1,dHeader.size());
			}
			
			pc.addCols("BANCO: ",1,1);
			pc.addCols(""+cdo.getColValue("descBanco"),0,2);
			pc.addCols("CUENTA BANCARIA: "+cdo.getColValue("descCuenta"),0,3);
			if(i!=0)pc.addCols(" ",1,dHeader.size());
		}
		if(!groupBy3.trim().equals(cdo.getColValue("descmov"))){if(i!=0)pc.addCols(" ",1,dHeader.size());}
		
 			pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("descmov"),1,1);
			pc.addCols(" "+cdo.getColValue("num_documento"),1,1);
			pc.addCols(" "+cdo.getColValue("f_doc"),1,1);
			pc.addCols(" "+cdo.getColValue("cuenta"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1); 
			totalDb += Double.parseDouble(cdo.getColValue("debito"));
			totalCr += Double.parseDouble(cdo.getColValue("credito"));
			totalDbBanco += Double.parseDouble(cdo.getColValue("debito"));
			totalCrBanco += Double.parseDouble(cdo.getColValue("credito"));
			
			totDbBanco += Double.parseDouble(cdo.getColValue("debito"));
			totCrBanco += Double.parseDouble(cdo.getColValue("credito"));
			
			groupBy = cdo.getColValue("banco")+"-"+cdo.getColValue("cuenta_banco");
			groupBy2 =cdo.getColValue("banco");
			groupBy3 =cdo.getColValue("descmov");
 		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
 	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(8, 1);
		pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbBanco),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrBanco),2,1);

		pc.addCols(" ",1,dHeader.size());
		pc.addCols("TOTAL POR BANCO : ",1,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);

		pc.addCols(" ",1,dHeader.size());

		pc.addCols(" TOTAL POR REPORTE ",2,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDb),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCr),2,1);
	 
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
