<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
CommonDataObject cdoHeader = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String status = request.getParameter("status");
String fg = request.getParameter("fg");
String doc_type = request.getParameter("doc_type");
String rep_type = request.getParameter("rep_type");
String comprobante = request.getParameter("comprobante");
String cds = request.getParameter("cds");
String ts = request.getParameter("ts");
String afectaConta = request.getParameter("afectaConta");
String costoCero = request.getParameter("costoCero");
String codFlia = request.getParameter("codFlia");
String wh = request.getParameter("wh");

if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (appendFilter == null) appendFilter = "";
if (status == null) status = "";
if (fg == null) fg = "";
if (doc_type == null) doc_type = "";
if (rep_type == null) rep_type = "";
if (comprobante == null) comprobante = "";
else if (comprobante.trim().equals("ALL"))comprobante = "";

if (cds == null) cds = "";
if (ts == null) ts = "";
if (afectaConta == null) afectaConta = "";
if (costoCero == null) costoCero = "N";
if (codFlia == null)     codFlia       = "";
if (wh == null)     wh       = "";

sbSql = new StringBuffer();

if (rep_type.trim().equals("R")){sbSql.append(" select cds,tipo_cargo,descTs,descripcion,sum(montoCosto) montoCosto,sum(cantTransaccion) cantTransaccion ,sum(montoCargo) montoCargo");
if (fg.trim().equals("CDS"))sbSql.append(",cuenta ");
else sbSql.append(", descctawh ");
sbSql.append(" from (");
}

sbSql.append("select fdt.centro_servicio cds,fdt.client_name cliente,fdt.tipo_cargo , fdt.codigo_almacen ,sum(round(decode(fdt.tipo_transaccion,'NCR',-1* (fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.codigo_almacen,fdt.inv_articulo,to_char(fdt.doc_date,'mm'),to_char(fdt.doc_date,'yyyy'),nvl(fdt.costo_art,0),null) from dual))),(fdt.cantidad*abs((select getCostoComprob(fdt.compania,fdt.codigo_almacen,fdt.inv_articulo,to_char(fdt.doc_date,'mm'),to_char(fdt.doc_date,'yyyy'),nvl(fdt.costo_art,0),null) from dual)))),2)) montoCosto ,nvl((select getMapingCta('CARGDEVCOST',fdt.compania,fdt.centro_servicio,fdt.tipo_cargo,'-','-','T') from dual),'S/C') as cuenta,cds.descripcion ,(select descripcion from tbl_cds_tipo_servicio where codigo = fdt.tipo_cargo) descTs,fdt.descCargo,fdt.afectaConta ,sum(round(decode(fdt.tipo_transaccion,'NCR',-1* (fdt.cantidad),fdt.cantidad),2)) cantTransaccion,sum(round(decode(fdt.tipo_transaccion,'NCR',-1* (fdt.total),fdt.total),2)) montoCargo,to_char(fdt.doc_date,'dd/mm/yyyy') fecha,fdt.doc_date,fdt.nivel,( select nvl(getCtaFlia(al.compania,al.codigo_almacen,fdt.cod_flia,-1), al.cg_cta1||'.'||al.cg_cta2||'.'||nvl(fdt.nivel,al.cg_cta3)||'.'||al.cg_cta4||'.'||al.cg_cta5||'.'||al.cg_cta6) cuenta from tbl_inv_almacen al where codigo_almacen = fdt.codigo_almacen and al.compania = fdt.compania) descctawh ,fdt.doc_typedesc,fdt.anio_cargo, fdt.numero_factura, fdt.usuario_creacion,fdt.codigo_cargo, fdt.clienteRef,(select descripcion from tbl_fac_tipo_cliente where codigo = fdt.clienteRef and compania =fdt.compania) descTipoCliente from (select dt.tipo_servicio tipo_cargo, dt.almacen codigo_almacen , ft.doc_type tipo_transaccion,dt.cantidad,dt.costo costo_art,dt.codigo inv_articulo,ft.company_id compania,ft.centro_servicio,dt.total, ft.client_name,dt.descripcion desccargo,ar.other4 afectaconta,ft.doc_date,ff.nivel ,decode(ft.doc_type,'FAC',ft.other3,ft.doc_id) numero_factura, ft.created_by usuario_creacion, to_char(ft.doc_date,'yyyy')anio_cargo, ft.doc_id codigo_cargo,decode(ft.doc_type,'FAC','FACTURA','NCR','NOTA CREDITO','NDC','NOTA DEBITO',ft.doc_type) doc_typedesc,ft.client_ref_id clienteRef,ar.cod_flia from tbl_fac_trxitems dt, tbl_fac_trx ft,tbl_inv_inventario inv,tbl_inv_articulo ar,tbl_inv_familia_articulo ff  where dt.doc_id = ft.doc_id ");
if (!fechaIni.trim().equals(""))
{
	sbSql.append(" and dt.fecha >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
}
if (!fechaFin.trim().equals(""))
{
	sbSql.append(" and dt.fecha <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
}
if(!wh.trim().equals("")){sbSql.append(" and dt.almacen = ");sbSql.append(wh);}
if(!codFlia.trim().equals("")){sbSql.append(" and ar.cod_flia  = ");sbSql.append(codFlia);}

 

sbSql.append(" and ft.company_id=");
sbSql.append(session.getAttribute("_companyId")); 
if(!costoCero.trim().equals("S")) sbSql.append("  and nvl(dt.costo,0) <> 0");
else sbSql.append(" and nvl(dt.costo,0) = 0");

if (!comprobante.trim().equals(""))
{
sbSql.append(" and nvl(dt.comprobante,'N')='");
sbSql.append(comprobante);
sbSql.append("' ");
}
if (!doc_type.trim().equals(""))
{
sbSql.append(" and ft.doc_type='");
sbSql.append(doc_type);
sbSql.append("' ");
}
if (!cds.trim().equals(""))
{
sbSql.append(" and ft.centro_servicio=");
sbSql.append(cds);
}
if (!ts.trim().equals(""))
{
sbSql.append(" and dt.tipo_servicio='");
sbSql.append(ts);
sbSql.append("' ");
}
if(!afectaConta.trim().equals("")){sbSql.append(" and dt.afecta_conta = '");sbSql.append(afectaConta);sbSql.append("'");}

sbSql.append(" and dt.other3 ='I' and inv.compania = ft.company_id and inv.codigo_almacen = dt.almacen and inv.cod_articulo = dt.codigo and ar.cod_articulo = dt.codigo and ar.compania =ft.company_id and ff.cod_flia = ar.cod_flia and ff.compania = ar.compania ");
sbSql.append(" union all ");
sbSql.append("  select dt.tipo_servicio tipo_cargo, dt.almacen codigo_almacen , ft.doc_type tipo_transaccion,dt.cantidad,dt.costo costo_art,dt.codigo inv_articulo,ft.company_id compania,ft.centro_servicio,dt.total,ft.client_name,dt.descripcion desccargo,b.other4 afectaconta,ft.doc_date,ff.nivel ,decode(ft.doc_type,'FAC',ft.other3,ft.doc_id) numero_factura, ft.created_by usuario_creacion, to_char(ft.doc_date,'yyyy')anio_cargo, ft.doc_id codigo_cargo,decode(ft.doc_type,'FAC','FACTURA','NCR','NOTA CREDITO','NDC','NOTA DEBITO',ft.doc_type) doc_typedesc,ft.client_ref_id clienteRef,b.cod_flia from tbl_fac_trxitems dt, tbl_fac_trx ft, tbl_caf_menu_det a, tbl_inv_articulo b,tbl_inv_familia_articulo ff where dt.doc_id = ft.doc_id ");
if (!fechaIni.trim().equals(""))
{
	sbSql.append(" and dt.fecha >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
}
if (!fechaFin.trim().equals(""))
{
	sbSql.append(" and dt.fecha <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
}

sbSql.append(" and ft.company_id=");
sbSql.append(session.getAttribute("_companyId")); 
if (!comprobante.trim().equals(""))
{
sbSql.append(" and nvl(dt.comprobante,'N')='");
sbSql.append(comprobante);
sbSql.append("' ");
}
if (!doc_type.trim().equals(""))
{
sbSql.append(" and ft.doc_type='");
sbSql.append(doc_type);
sbSql.append("' ");
}
if (!cds.trim().equals(""))
{
sbSql.append(" and ft.centro_servicio=");
sbSql.append(cds);
}
if (!ts.trim().equals(""))
{
sbSql.append(" and dt.tipo_servicio='");
sbSql.append(ts);
sbSql.append("' ");
}
if(!wh.trim().equals("")){sbSql.append(" and dt.almacen = ");sbSql.append(wh);}
if(!codFlia.trim().equals("")){sbSql.append(" and ar.cod_flia  = ");sbSql.append(codFlia);}
if(!afectaConta.trim().equals("")){sbSql.append(" and b.other4 = '");sbSql.append(afectaConta);sbSql.append("'");}
sbSql.append(" and dt.other3 ='C' and a.id_articulo = b.cod_articulo and b.compania = ft.company_id and a.id_menu = dt.codigo and ff.cod_flia = b.cod_flia and ff.compania = b.compania )fdt,tbl_cds_centro_servicio cds where fdt.centro_servicio = cds.codigo and fdt.compania = cds.compania_unorg");

if(!costoCero.trim().equals("S")) sbSql.append(" having sum(round(decode(fdt.tipo_transaccion,'NCR',-1* (fdt.cantidad*nvl(fdt.costo_art,0)),(fdt.cantidad*nvl(fdt.costo_art,0))),2))<>0 ");
else sbSql.append(" and nvl(fdt.costo_art,0) =0");

sbSql.append(" group by fdt.cod_flia,fdt.tipo_cargo,fdt.codigo_almacen,cds.descripcion ,fdt.centro_servicio,fdt.compania, fdt.client_name, fdt.desccargo,fdt.afectaconta,to_date(fdt.doc_date,'dd/mm/yyyy'),fdt.doc_date,fdt.nivel ,fdt.doc_typedesc,fdt.anio_cargo, fdt.numero_factura, fdt.usuario_creacion, fdt.codigo_cargo ,fdt.clienteRef ");
sbSql.append(" order by fdt.centro_servicio,fdt.clienteRef,fdt.doc_date");

if (rep_type.trim().equals("R")){sbSql.append(") group by cds,tipo_cargo,descTs,descripcion");
if (fg.trim().equals("CDS"))sbSql.append(",cuenta ");
else sbSql.append(",descctawh");  sbSql.append(" order by cds,tipo_cargo ");}

al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COSTOS  (OTROS CLIENTES)"+((fg.trim().equals("CDS"))?" - CUENTAS POR CENTRO DE SERVICIO":" - CUENTAS DE INVENTARIO");
	String subtitle = "DEL "+fechaIni+"  AL "+fechaFin;
	String xtraSubtitle = ""+((rep_type.trim().equals("R"))?" REPORTE RESUMIDO ":"REPORTE DETALLADO");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".20");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".04");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".15");
	
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		if(rep_type.trim().equals("R"))
		{
			pc.addBorderCols("CENTRO",0,2);
			pc.addBorderCols("TIPO SERVICIO",0,3);
			pc.addBorderCols("MONTO CARGO",1,1);
			pc.addBorderCols("CANTIDAD",1,1);
			pc.addBorderCols("COSTO",1,1);
			pc.addBorderCols("CUENTA",1,2);
		}
		else{
		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("CLIENTE",1);
		pc.addBorderCols("TIPO CARGO",1);
		pc.addBorderCols("NO. DOC.",1);
		pc.addBorderCols("AÑO",1);
		pc.addBorderCols("CARGO",1,1);
		pc.addBorderCols("MONTO CARGO",1);
		pc.addBorderCols("CANTIDAD",1);
		pc.addBorderCols("COSTO",1,1);
		pc.addBorderCols("CUENTA",1,1);}
	 pc.setTableHeader(2);//create de table header
	
	//table body
	String groupBy = "",groupBy2 = "";
	String groupTitleCds = "",groupTitle2="";
	double totalCargo = 0.00,cantTotal =0.00,total = 0.00;
	double totalCargoCds = 0.00,cantTotalCds =0.00,totalCds = 0.00;
	double totalCargoTot = 0.00,cantTotalTot =0.00,totalTot = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setVAlignment(0);
		if(!rep_type.trim().equals("R"))
		{
		if(!groupBy2.equals(cdo.getColValue("tipo_cargo"))||!groupBy.equals(cdo.getColValue("cds")))
		{
			pc.setFont(groupFontSize,1,Color.blue);
			if(i!=0)
			{
				pc.addBorderCols("TOTAL POR TIPO SERVICIO: "+groupTitle2,2,6,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCargo),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cantTotal),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
				totalCargo = 0.00;
				cantTotal =0.00;
	 			total = 0.00;
				pc.addCols(" ",1,dHeader.size());
			}
		}
		if(!groupBy.equals(cdo.getColValue("cds")))
		{
			pc.setFont(groupFontSize,1,Color.blue);
			if(i!=0)
			{
				pc.addBorderCols("TOTAL POR CENTRO: "+groupTitleCds,2,6,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCargoCds),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cantTotalCds),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCds),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
				totalCargoCds = 0.00;
				cantTotalCds =0.00;
	 			totalCds = 0.00;
				pc.addCols(" ",1,dHeader.size());
			}
			pc.addCols(" CENTRO DE SERVICIO: "+cdo.getColValue("cds")+" - "+cdo.getColValue("descripcion"),0,dHeader.size());
		}
		if(!groupBy2.equals(cdo.getColValue("tipo_cargo"))||!groupBy.equals(cdo.getColValue("cds")))
		{
			pc.addCols(" TIPO SERVICIO: "+cdo.getColValue("descTs"),0,dHeader.size());
		}
		}//end detallado
		pc.setFont(contentFontSize,0);
		if(rep_type.trim().equals("R"))
		{
			pc.addCols(cdo.getColValue("cds")+" - "+cdo.getColValue("descripcion"),0,2);
			pc.addCols(cdo.getColValue("descTs"),0,3);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("montoCargo")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("cantTransaccion")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("montoCosto")),2,1);
			if(fg.trim().equals("CDS"))pc.addCols(cdo.getColValue("cuenta"),2,2);
			else pc.addCols(cdo.getColValue("descctawh"),2,2);
		}
		else
		{
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("cliente"),0,1);
		pc.addCols(cdo.getColValue("doc_typedesc"),1,1);
		pc.addCols(cdo.getColValue("numero_factura"),0,1);
		pc.addCols(cdo.getColValue("anio_cargo"),1,1);
		pc.addCols(cdo.getColValue("codigo_cargo"),0,1);
				
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("montoCargo")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("cantTransaccion")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("montoCosto")),2,1);
		if(fg.trim().equals("CDS"))pc.addCols(cdo.getColValue("cuenta"),2,1);
		else pc.addCols(cdo.getColValue("descctawh"),2,1);
		
		groupBy  = cdo.getColValue("cds");
		groupBy2  = cdo.getColValue("tipo_cargo");
		groupTitleCds = cdo.getColValue("cds")+"-"+cdo.getColValue("descripcion");
		groupTitle2 = cdo.getColValue("descTs");
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		total += Double.parseDouble(cdo.getColValue("montoCosto"));
		totalCargo += Double.parseDouble(cdo.getColValue("montoCargo"));
		cantTotal += Double.parseDouble(cdo.getColValue("cantTransaccion"));
		totalCds += Double.parseDouble(cdo.getColValue("montoCosto"));
		totalCargoCds += Double.parseDouble(cdo.getColValue("montoCargo"));
		cantTotalCds += Double.parseDouble(cdo.getColValue("cantTransaccion"));
		
		totalTot += Double.parseDouble(cdo.getColValue("montoCosto"));
		totalCargoTot += Double.parseDouble(cdo.getColValue("montoCargo"));
		cantTotalTot += Double.parseDouble(cdo.getColValue("cantTransaccion"));
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1,Color.blue);
		if(!rep_type.trim().equals("R"))
		{
			pc.addBorderCols("TOTAL POR TIPO SERVICIO: "+groupTitle2,2,6,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCargo),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cantTotal),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
			
			pc.addBorderCols("TOTAL POR CENTRO: "+groupTitleCds,2,6,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCargoCds),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cantTotalCds),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCds),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
		}
		if(rep_type.trim().equals("R"))pc.addBorderCols("TOTAL: ",2,5,0.0f,0.5f,0.0f,0.0f);
		else pc.addBorderCols("TOTAL: ",2,6,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totalCargoTot),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cantTotalTot),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totalTot),2,1,0.0f,0.5f,0.0f,0.0f);
		if(rep_type.trim().equals("R"))pc.addBorderCols(" ",2,2,0.0f,0.5f,0.0f,0.0f);
		else pc.addBorderCols(" ",2,1,0.0f,0.5f,0.0f,0.0f);
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>