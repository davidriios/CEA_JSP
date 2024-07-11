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

String sql = "", appendFilter = "";;
String userName = UserDet.getUserName();
String anio = request.getParameter("anio")==null?"":request.getParameter("anio");
String anioSaldoIni = request.getParameter("anioSaldoIni")==null?"":request.getParameter("anioSaldoIni");
String mes = request.getParameter("mes")==null?"":request.getParameter("mes");
String num_cta = request.getParameter("num_cta");
String fechaini = request.getParameter("fechaini")==null?"":request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin")==null?"":request.getParameter("fechafin");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String tipoReg = request.getParameter("tipoReg");
String resumen = request.getParameter("resumen");
String tipoComprob = request.getParameter("tipoComprob");

if(tipoReg==null) tipoReg = "";
if(resumen==null) resumen = "";
if(tipoComprob==null) tipoComprob = "";

	if(!fechaini.equals("") && !fechafin.equals(""))
	{ appendFilter += " /*------ RANGO FECHA */ and to_date(to_char(fecha_comp, 'dd/mm/yyyy'), 'dd/mm/yyyy') between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
		//sql = "select nvl(sum(decode(c.tipo_mov, 'DB', valor,'CR',-1*valor)),0) saldo_inicial,d.decripcion from tbl_con_encab_comprob a, tbl_con_clases_comprob b, tbl_con_detalle_comprob c, vw_con_catalogo_gral d where a.status = 'AP' and a.clase_comprob = b.codigo_comprob and b.tipo='C' and a.ea_ano = c.ano and a.consecutivo = c.consecutivo and a.compania = c.compania and a.tipo = c.tipo and c.cta1 = d.cta1 and c.cta2 = d.cta2 and c.cta3 = d.cta3 and c.cta4 = d.cta4 and c.cta5 = d.cta5 and c.cta6 = d.cta6 and c.compania = d.compania and a.compania = " + (String) session.getAttribute("_companyId") + " and d.num_cuenta like '"+num_cta+"%'"+ appendFilter+" group by d.descripcion ";
		sql = "select  nvl(getSiComprobCta (pc_compania,null,null,'"+fechaini+"','"+num_cta+"','"+tipoReg+"'),0) as si_comp, nvl(monto_i, 0) saldo_inicial,(select descripcion from tbl_con_catalogo_gral cg where cg.compania = mm.pc_compania and cg.cta1 = mm.cat_cta1 and cg.cta2 =mm.cat_cta2 and cg.cta3 = mm.cat_cta3 and cg.cta4 =mm.cat_cta4 and cg.cta5 = mm.cat_cta5 and cg.cta6 =mm.cat_cta6) as descripcion from tbl_con_mov_mensual_cta mm where pc_compania = " + (String) session.getAttribute("_companyId") + " and ea_ano = to_char(to_date('" + fechaini+ "','dd/mm/yyyy'),'YYYY') and mes =to_char(to_date('" + fechaini+ "','dd/mm/yyyy'),'MM') and cat_cta1 = '"+cta1+"' and cat_cta2 = '"+cta2+"' and cat_cta3 = '"+cta3+"' and cat_cta4 = '"+cta4+"' and cat_cta5 = '"+cta5+"' and cat_cta6 = '" + cta6 + "'";
		//cdoSI.addColValue("saldo_inicial","0");
		//cdoSI.addColValue("descripcion","");
		cdoSI = SQLMgr.getData(sql);
		
	}
	if (!anio.equals("") && !mes.equals(""))
	{appendFilter += " /*------ AÑO - MES */ and a.ea_ano = "+anio+" and a.mes = "+mes;
 	sql = "select nvl(monto_i, 0) saldo_inicial,(select descripcion from tbl_con_catalogo_gral cg where cg.compania = mm.pc_compania and cg.cta1 = mm.cat_cta1 and cg.cta2 =mm.cat_cta2 and cg.cta3 = mm.cat_cta3 and cg.cta4 =mm.cat_cta4 and cg.cta5 = mm.cat_cta5 and cg.cta6 =mm.cat_cta6) as descripcion,nvl(getSiComprobCta (pc_compania,"+anio+","+mes+",null,'"+num_cta+"','"+tipoReg+"'),0) as si_comp from tbl_con_mov_mensual_cta mm where pc_compania = " + (String) session.getAttribute("_companyId") + " and ea_ano = " + anio+ " and mes ="+mes+" and cat_cta1 = '"+cta1+"' and cat_cta2 = '"+cta2+"' and cat_cta3 = '"+cta3+"' and cat_cta4 = '"+cta4+"' and cat_cta5 = '"+cta5+"' and cat_cta6 = '" + cta6 + "'";
		cdoSI = SQLMgr.getData(sql);
	}
	if(cdoSI == null)
	{
	 cdoSI =new CommonDataObject();
	 cdoSI.addColValue("saldo_inicial","0");
	 cdoSI.addColValue("descripcion","");
	 cdoSI.addColValue("si_comp","0");
	}
		if(!tipoReg.equals(""))appendFilter += " and nvl(a.creado_por,'X')='"+tipoReg+"'";
		if(!tipoComprob.equals(""))appendFilter += " and a.clase_comprob="+tipoComprob;


sbSql.append("select ");
	if(resumen.trim().equals("S"))
	{
		sbSql.append(" c.tipo_mov,a.tipo,'' as consecutivo,'' as ea_ano,a.reg_type,'' as fecha_comp,c.num_cuenta,d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ) nombre_cta,b.nombre_corto as comprob_desc,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6, sum(decode(c.tipo_mov, 'DB', valor)) debito, sum(decode(c.tipo_mov, 'CR', valor)) credito");
	
	}
	else
	{
		sbSql.append(" c.tipo_mov,a.tipo,a.consecutivo,a.ea_ano,a.reg_type,to_char (a.fecha_comp, 'dd/mm/yyyy') as fecha_comp,c.num_cuenta, d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ) nombre_cta,b.nombre_corto as comprob_desc,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6, decode(c.tipo_mov, 'DB', valor) debito, decode(c.tipo_mov, 'CR', valor) credito ");
	}
	sbSql.append("  from tbl_con_encab_comprob a, tbl_con_clases_comprob b, tbl_con_detalle_comprob c, vw_con_catalogo_gral d where a.status = 'AP' and a.estado ='A' and a.clase_comprob = b.codigo_comprob and b.tipo='C' and a.ea_ano = c.ano and a.consecutivo = c.consecutivo and a.compania = c.compania and a.tipo = c.tipo and c.cta1 = d.cta1 and c.cta2 = d.cta2 and c.cta3 = d.cta3 and c.cta4 = d.cta4 and c.cta5 = d.cta5 and c.cta6 = d.cta6 and c.compania = d.compania and a.compania = " + (String) session.getAttribute("_companyId") + " and d.num_cuenta like '");
	sbSql.append(num_cta);
	sbSql.append("%'");
	sbSql.append(appendFilter);
	if(resumen.trim().equals("S")){sbSql.append(" group by  c.tipo_mov,a.tipo,a.reg_type,c.num_cuenta,d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ),b.nombre_corto ,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6 ");}
	if(resumen.trim().equals("S")){sbSql.append(" order by b.nombre_corto ");}
	else sbSql.append(" order by a.ea_ano, a.mes, a.consecutivo,a.tipo");

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
	String title = "MAYOR GENERAL";
	String subtitle = cdoSI.getColValue("descripcion") + " ( " + cta1 + "." + cta2 + "." + cta3 + "." + cta4 + "." + cta5 + "." + cta6 + " )";
	String xtraSubtitle = "";
	if(!fechaini.equals("") && !fechafin.equals("")) xtraSubtitle ="Fecha de Referencia entre " + fechaini + " - " + fechafin;
	else xtraSubtitle ="ANO-MES " + anio + " - " + mes;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".50");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

		//second row
		pc.setVAlignment(0);
		pc.addBorderCols("No.",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Descripción",0,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Débito",2,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Crédito",2,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Saldo",2,1,0.5f,0.5f,0.0f,0.0f);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	
	pc.setVAlignment(0);

	pc.addCols("Rojo = Anulado",0,1,Color.green);
	pc.addCols(" Saldo Inicial",2,3);
	pc.addCols(" ",1,1);
	pc.addCols(CmnMgr.getFormattedDecimal(((!tipoReg.equals(""))?cdoSI.getColValue("si_comp"):cdoSI.getColValue("saldo_inicial"))),2,1);
	double saldo = Double.parseDouble(((!tipoReg.equals(""))?cdoSI.getColValue("si_comp"):cdoSI.getColValue("saldo_inicial")));
	double debito =0.00,credito=0.00;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(cdo.getColValue("tipo_mov").equals("DB")){ saldo += Double.parseDouble(cdo.getColValue("debito")); debito  += Double.parseDouble(cdo.getColValue("debito"));}
		else {saldo -= Double.parseDouble(cdo.getColValue("credito"));
		credito += Double.parseDouble(cdo.getColValue("credito"));}
		

		if(cdo.getColValue("tipo")!=null && cdo.getColValue("tipo").equals("2")) pc.setFont(6, 0,Color.red);
		else pc.setFont(6, 0);
		pc.addCols(cdo.getColValue("consecutivo"),1,1);
		pc.addCols(cdo.getColValue("fecha_comp"),1,1);
		pc.addCols(cdo.getColValue("nombre_cta"),0,1);
		pc.addCols(cdo.getColValue("debito"),2,1);
		pc.addCols(cdo.getColValue("credito"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,0);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.setFont(7, 0);
	pc.addBorderCols("Total",2,3,0.0f,0.0f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(debito),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(credito),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,1,0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>