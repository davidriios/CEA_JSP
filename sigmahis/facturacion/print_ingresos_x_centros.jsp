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

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha_ini = request.getParameter("xDate");
String fecha_fin = request.getParameter("tDate");
String cds = request.getParameter("cds");
String fg = request.getParameter("fg");
String ts = request.getParameter("ts");
String tipoFecha = request.getParameter("tipoFecha");
String cargosFact = request.getParameter("cargosFact");
String aseguradora = request.getParameter("aseguradora")==null?"":request.getParameter("aseguradora");

String admType = request.getParameter("admType");
String table   ="";
String pWhere  ="";
String fp = request.getParameter("fp");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (ts == null) ts = "";
if (cargosFact == null) cargosFact = "";

if (admType == null) admType = "";
if (fecha_ini == null) fecha_ini = "";
if (fecha_fin == null) fecha_fin = "";
if (cds == null) cds = "";
if (tipoFecha == null) tipoFecha = "";

sql.append("  select decode(a.adm_type,'I','INGRESOS IP','O','INGRESOS OP','T','TODAS') as descAdmType, a.*, nvl(getMapingCta('CARGDEV',a.compania,a.cds,a.tipo_cargo,a.ref_table,a.ref_pk,a.adm_type),'S/C') as cuenta");
if (fp.equalsIgnoreCase("DET")) {
	sql.append(", (select join(cursor(select codigo from tbl_fac_factura where pac_id = a.pac_id and admi_secuencia = a.admi_secuencia and estatus <> 'A'),';') from dual) as facturas, a.pac_id||'-'||a.admi_secuencia as id_paciente, (select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_cargo) as descTipoCargo");
}
sql.append(" from (");

	sql.append("select 4 as acctype_id, (select descripcion from tbl_cds_centro_servicio where codigo = ");
	if (cdsDet.equalsIgnoreCase("S")) sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(") as centro_servicio_desc, b.tipo_cargo, sum(decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad) * (b.monto + nvl(b.recargo,0) - decode((select costo_externo from tbl_cds_tipo_servicio where codigo = b.tipo_cargo),'N',0,nvl(b.costo_art,0)))) as monto, sum(decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad)) as cantidad, (select descripcion from tbl_cds_tipo_servicio where codigo = b.tipo_cargo) as descripcion,");
	if (cdsDet.equalsIgnoreCase("S")) sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(" as cds, c.adm_type, a.compania");
	if (fp.equalsIgnoreCase("DET")) {
		sql.append(", to_char(b.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre_paciente, a.pac_id, a.admi_secuencia, b.descripcion as descCargo");
	}
	sql.append(", case when b.procedimiento is not null then 'TBL_CDS_PROCEDIMIENTO' when b.otros_cargos is not null then 'TBL_FAC_OTROS_CARGOS' when b.cds_producto is not null then 'TBL_CDS_PRODUCTO_X_CDS' when b.habitacion is not null then 'TBL_SAL_HABITACION' when b.inv_almacen is not null and b.art_familia is not null and b.art_clase is not null and b.inv_articulo is not null then 'TBL_INV_ARTICULO' when b.cod_uso is not null then 'TBL_SAL_USO' when b.cod_paq_x_cds is not null then 'TBL_CDS_PRODUCTO_X_CDS' else ' ' end as ref_table");
	sql.append(", case when b.procedimiento is not null then b.procedimiento when b.otros_cargos is not null then ''||b.otros_cargos when b.cds_producto is not null then ''||b.cds_producto when b.habitacion is not null then b.habitacion when b.inv_almacen is not null and b.art_familia is not null and b.art_clase is not null and b.inv_articulo is not null then b.inv_almacen||'-'||b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo when b.cod_uso is not null then ''||b.cod_uso when b.cod_paq_x_cds is not null then ''||b.cod_paq_x_cds else ' ' end as ref_pk");
	sql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_adm_admision adm, tbl_adm_categoria_admision c where a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and a.compania = ");
	sql.append(session.getAttribute("_companyId"));
	if (!ts.trim().equals("")) {
		sql.append(" and b.tipo_cargo = '"+ts+"'");
	}
	if (!fecha_ini.trim().equals("")) {
		if (tipoFecha.equalsIgnoreCase("C")) sql.append(" and trunc(b.fecha_cargo) >= to_date('");
		else sql.append(" and b.fecha_creacion >= to_date('");
		sql.append(fecha_ini);
		sql.append("','dd/mm/yyyy')");
	}
	if(!fecha_fin.trim().equals("")) {
		if (tipoFecha.equalsIgnoreCase("C")) sql.append(" and trunc(b.fecha_cargo) <= to_date('");
		else sql.append(" and b.fecha_creacion <= to_date('");
		sql.append(fecha_fin);
		sql.append("','dd/mm/yyyy')");
	}
	if (!cds.trim().equals("")) {
		if (cdsDet.equalsIgnoreCase("S")) sql.append(" and b.centro_servicio = ");
		else sql.append(" and a.centro_servicio = ");
		sql.append(cds);
	}
	if (!admType.trim().equals("")) {
		sql.append(" and c.adm_type = '");
		sql.append(admType);
		sql.append("'");
	}
	if (fg.equalsIgnoreCase("NF")) {
		//sql.append(" and adm.estado not in ('N','I','C')"); // ANULADA E INACTIVA
		cargosFact = "N";
	}
	if (!cargosFact.trim().equals("")) {
		sql.append(" and ");
		sql.append((cargosFact.equalsIgnoreCase("N")?"not":""));
		sql.append(" exists (select null from tbl_fac_factura f where f.pac_id = adm.pac_id and f.admi_secuencia = adm.secuencia and f.estatus != 'A')");
	}
	
	if (!aseguradora.trim().equals("")){
     sql.append(" and exists (select 'x' from tbl_adm_beneficios_x_admision aba where aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' and aba.pac_id = adm.pac_id and aba.admision = adm.secuencia  and rownum = 1 and aba.empresa = ");
     sql.append(aseguradora);
     sql.append(")");
	 }
	
	sql.append(" and a.pac_id = adm.pac_id and a.admi_secuencia = adm.secuencia and adm.categoria = c.codigo group by b.tipo_cargo, ");
	if (cdsDet.equalsIgnoreCase("S")) sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(", c.adm_type, a.compania");
	if (fp.equalsIgnoreCase("DET")) sql.append(", to_char(b.fecha_creacion,'dd/mm/yyyy'), a.pac_id, a.admi_secuencia, b.descripcion");
	sql.append(", b.procedimiento, b.otros_cargos, b.cds_producto, b.habitacion, b.inv_almacen, b.art_familia, b.art_clase, b.inv_articulo, b.cod_uso, b.cod_paq_x_cds");
	// COSTOS EXTERNOS

	sql.append(" union all select 3 as acctype_id, (select descripcion from tbl_cds_centro_servicio where codigo = ");
	if (cdsDet.equalsIgnoreCase("S")) sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(") as centro_servicio_desc, b.tipo_cargo, sum(decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad) * nvl(b.costo_art,0)) as monto_prov, sum(decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad)) as cantidad, ts.descripcion as descripcion, ");
	if (cdsDet.equalsIgnoreCase("S")) sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(" as cds, c.adm_type, a.compania");
	if (fp.equalsIgnoreCase("DET")) {
		sql.append(", to_char(b.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre_paciente, a.pac_id, a.admi_secuencia, b.descripcion as descCargo");
	}
	sql.append(", case when b.procedimiento is not null then 'TBL_CDS_PROCEDIMIENTO' when b.otros_cargos is not null then 'TBL_FAC_OTROS_CARGOS' when b.cds_producto is not null then 'TBL_CDS_PRODUCTO_X_CDS' when b.habitacion is not null then 'TBL_SAL_HABITACION' when b.inv_almacen is not null and b.art_familia is not null and b.art_clase is not null and b.inv_articulo is not null then 'TBL_INV_ARTICULO' when b.cod_uso is not null then 'TBL_SAL_USO' when b.cod_paq_x_cds is not null then 'TBL_CDS_PRODUCTO_X_CDS' else ' ' end as ref_table");
	sql.append(", case when b.procedimiento is not null then b.procedimiento when b.otros_cargos is not null then ''||b.otros_cargos when b.cds_producto is not null then ''||b.cds_producto when b.habitacion is not null then b.habitacion when b.inv_almacen is not null and b.art_familia is not null and b.art_clase is not null and b.inv_articulo is not null then b.inv_almacen||'-'||b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo when b.cod_uso is not null then ''||b.cod_uso when b.cod_paq_x_cds is not null then ''||b.cod_paq_x_cds else ' ' end as ref_pk");
	sql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_adm_admision adm, tbl_cds_tipo_servicio ts, tbl_adm_categoria_admision c where a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and a.compania = ");
	sql.append(session.getAttribute("_companyId"));
	if (!fecha_ini.trim().equals("")) {
		if (tipoFecha.equalsIgnoreCase("C")) sql.append(" and trunc(b.fecha_cargo) >= to_date('");
		else sql.append(" and b.fecha_creacion >= to_date('");
		sql.append(fecha_ini);
		sql.append("','dd/mm/yyyy')");
	}
	if (!fecha_fin.trim().equals("")) {
		if (tipoFecha.equalsIgnoreCase("C")) sql.append(" and trunc(b.fecha_cargo) <= to_date('");
		else sql.append(" and b.fecha_creacion <= to_date('");
		sql.append(fecha_fin);
		sql.append("','dd/mm/yyyy')");
	}
	if (!cds.trim().equals("")) {
		if (cdsDet.equalsIgnoreCase("S")) sql.append(" and b.centro_servicio = ");
		else sql.append(" and a.centro_servicio = ");
		sql.append(cds);
	}
	if (!admType.trim().equals("")) {
		sql.append(" and c.adm_type = '");
		sql.append(admType);
		sql.append("'");
	}
	if (fg.equalsIgnoreCase("NF")) {
		sql.append(" and adm.estado not in ('N','I','C')"); // ANULADA E INACTIVA
	}
	sql.append(" and b.tipo_cargo = ts.codigo /*and fdt.compania = ts.compania*/ and ts.costo_externo= 'S' and a.pac_id = adm.pac_id and a.admi_secuencia = adm.secuencia and adm.categoria = c.codigo group by b.tipo_cargo, ");
	if (cdsDet.equalsIgnoreCase("S"))sql.append("b.centro_servicio");
	else sql.append("a.centro_servicio");
	sql.append(", c.adm_type, ts.descripcion, a.compania");
	if (fp.equalsIgnoreCase("DET")) sql.append(", to_char(b.fecha_creacion,'dd/mm/yyyy'), a.pac_id, a.admi_secuencia, b.descripcion");
	sql.append(", b.procedimiento, b.otros_cargos, b.cds_producto, b.habitacion, b.inv_almacen, b.art_familia, b.art_clase, b.inv_articulo, b.cod_uso, b.cod_paq_x_cds");

sql.append(") a order by ");
if (fp.equalsIgnoreCase("DET")) sql.append("a.pac_id, a.admi_secuencia, ");
sql.append("a.centro_servicio_desc, a.descripcion, a.tipo_cargo");

// P O S
if (fg.equalsIgnoreCase("POS")) {
	sql = new StringBuffer();
	sql.append("select decode(a.adm_type,'I','INGRESOS IP','INGRESOS OP','T','TODAS')descAdmType, a.*,nvl(nvl((select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =a.cds and acc.service_type = a.tipo_cargo and acc.acctype_id =a.acctype_id and acc.status ='A' and acc.def_type ='S' and acc.adm_type in (a.adm_type) and compania=a.compania),(select acc.cta1||'.'||acc.cta2||'.'||acc.cta3||'.'||acc.cta4||'.'||acc.cta5||'.'||acc.cta6 cuenta from tbl_con_accdef acc where acc.cds =a.cds and acc.service_type = a.tipo_cargo and acc.acctype_id =a.acctype_id and acc.status ='A' and acc.def_type ='S' and acc.adm_type in ('T') and compania=a.compania)),'S/C') cuenta from(select 4 acctype_id,(select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centro_servicio_desc, b.tipo_servicio tipo_cargo, sum(decode(a.doc_type,'NCR',-(b.cantidad*b.precio),(b.cantidad*b.precio))) as monto, sum(decode(a.doc_type,'NCR',-1*b.cantidad,b.cantidad)) cantidad, (select descripcion from tbl_cds_tipo_servicio where codigo=b.tipo_servicio) as descripcion ,a.centro_servicio cds ,'T' adm_type,a.company_id compania from tbl_fac_trx a, tbl_fac_trxitems b where  a.doc_id   = b.doc_id and a.company_id = ");
	sql.append(session.getAttribute("_companyId"));
	
	
	if (!aseguradora.trim().equals("")){
     sql.append(" and exists (select 'x' from tbl_adm_beneficios_x_admision aba where aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' and to_char(aba.empresa) = (select codigo from vw_fac_otros_clientes where to_char(ref_id) = a.client_id and compania = a.company_id and refer_to = 'EMPR') and aba.empresa = ");
     sql.append(aseguradora);
     sql.append(")");
	 }

if (!ts.equals("")){
  sql.append(" and  b.tipo_servicio  = '"+ts+"'");
}
if(!fecha_ini.trim().equals(""))
{
sql.append(" and a.doc_date >= to_date('");

sql.append(fecha_ini);
sql.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals(""))
{
sql.append(" and a.doc_date <= to_date('");
sql.append(fecha_fin);
sql.append("','dd/mm/yyyy')");
}
if(!cds.trim().equals(""))
{
sql.append(" and a.centro_servicio=");
sql.append(cds);
}
 sql.append(" and nvl(b.total_desc,0) = 0 and a.other4 = 0 group by b.tipo_servicio,a.centro_servicio,a.company_id )a where a.monto<>0  order by  a.centro_servicio_desc,a.descripcion,a.tipo_cargo");
}
al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+"_"+fp+".pdf";

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
	boolean isLandscape = (fp.trim().equals("DET"))?true:false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = ((fp.trim().equals("DET"))?"RESUMEN DE CARGOS POR PACIENTE/ TIPO DE SERVICIOS":"RESUMEN DE CARGOS POR CENTROS DE SERVICIOS");
	String xtraSubtitle = "DEL "+fecha_ini+"  AL "+fecha_fin ;
	if(admType.trim().equals("")&&!fg.trim().equals("POS")) xtraSubtitle =xtraSubtitle+"  TODAS LAS CATEGORIAS";
	else if(admType.trim().equals("I")) xtraSubtitle =xtraSubtitle+"  CATEGORIAS - IP";
	else if(admType.trim().equals("O")) xtraSubtitle =xtraSubtitle+"  CATEGORIAS - OP";
	if(fg.trim().equals("POS")) xtraSubtitle =xtraSubtitle+" - TRANSACCIONES DEL POS";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
				if(!fp.trim().equals("DET"))
				{
					dHeader.addElement(".30");
					dHeader.addElement(".10");
					dHeader.addElement(".20");
					dHeader.addElement(".20");
					dHeader.addElement(".20");
				}
				else
				{
					dHeader.addElement(".22");
					dHeader.addElement(".05");
					dHeader.addElement(".12");
					dHeader.addElement(".07");
					dHeader.addElement(".08");
					dHeader.addElement(".17");
					dHeader.addElement(".19");
					dHeader.addElement(".10");
				}





	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);

		if (fp.trim().equals("DET"))
		{
			pc.addBorderCols("Nombre del Paciente",0,1);
			pc.addBorderCols("ID Pac.",1,1);
			pc.addBorderCols("Cuenta",1,1);
			pc.addBorderCols("Facturas",1,1);
			pc.addBorderCols("Fecha",1,1);
			pc.addBorderCols("Tipo Cargo",1,1);
			pc.addBorderCols("Descripcion",1,1);
			pc.addBorderCols("Monto",1,1);
			pc.setTableHeader(2);
		}
		else pc.setTableHeader(1);


	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0;
	int totalCantidad = 0, totalCantidadCds =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if(i!=0)
			{
				if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds"))&&!fp.trim().equals("DET"))
				{
						//pc.setFont(0,1,Color.blue);
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,3,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+totalCantidadCds,2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,1,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
						totalCantidadCds=0;
						pc.addCols(" ",0,dHeader.size());
						pc.setFont(fontSize, 0);
				}
			}

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds"))&&!fp.trim().equals("DET"))
			{
				pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

							pc.addBorderCols("Tipo De Servicio",0,1);
							pc.addBorderCols("Tipo Adm",0,1);
							pc.addBorderCols("Cuenta",0,1);
							pc.addBorderCols("Cantidad",2,1);
							pc.addBorderCols("Monto",2,1);

			}

			//SOLO PARA REPORTE DETALLADO

			if(i!=0)
			{
				if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("id_paciente"))&&fp.trim().equals("DET"))
				{
						//pc.setFont(0,1,Color.blue);
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR PACIENTE",2,6,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,2,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
						totalCantidadCds=0;
						pc.addCols(" ",0,dHeader.size());
						pc.setFont(fontSize, 0);
				}
			}


			totalCds += Double.parseDouble(cdo.getColValue("monto"));
			totalTa  += Double.parseDouble(cdo.getColValue("monto"));
			monto  = Double.parseDouble(cdo.getColValue("monto"));
			total  += Double.parseDouble(cdo.getColValue("monto"));

			totalCantidad  += Integer.parseInt(cdo.getColValue("cantidad"));
			totalCantidadCds  += Integer.parseInt(cdo.getColValue("cantidad"));

			if (fp.trim().equals("DET"))
			{
				pc.addCols(""+cdo.getColValue("nombre_paciente"),0,1);
				pc.addCols(""+cdo.getColValue("id_paciente"),1,1);
				pc.addCols(""+cdo.getColValue("cuenta"),0,1);
				pc.addCols(""+cdo.getColValue("facturas"),0,1);
				pc.addCols(""+cdo.getColValue("fecha_creacion"),1,1);
				pc.addCols(""+cdo.getColValue("descTipoCargo"),0,1);
				pc.addCols(""+cdo.getColValue("descCargo"),0,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);
			}
			else
			{
			//pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] [ "+cdo.getColValue("cuenta")+" ]",0,1);
			pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"] ",0,1);
			pc.addCols(""+cdo.getColValue("descAdmType"),0,1);
			pc.addCols(""+cdo.getColValue("cuenta"),0,1);
			pc.addCols(""+cdo.getColValue("cantidad"),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);
			}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("cds");
			groupBy2 = cdo.getColValue("cds")+"-"+cdo.getColValue("adm_type");
			if (fp.trim().equals("DET"))groupBy=cdo.getColValue("id_paciente");
	}


	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{			if(!fp.trim().equals("DET")){
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,3,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+totalCantidadCds,2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,1,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
						pc.addCols(" ",0,dHeader.size());

						pc.addBorderCols("TOTAL",2,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCantidad),2,2,0.5f,0.0f,0.0f,0.0f);//
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.5f,0.0f,0.0f,0.0f);//
						totalCds =0.0;
						pc.addCols(" ",0,dHeader.size());
				}else
				{
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR PACIENTE",2,6,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,2,0.5f,0.0f,0.0f,0.0f);//descType

						pc.addCols(" ",0,dHeader.size());

						pc.addBorderCols("TOTAL",4,4,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,4,0.5f,0.0f,0.0f,0.0f);//
						totalCds =0.0;
						pc.addCols(" ",0,dHeader.size());
				}
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>