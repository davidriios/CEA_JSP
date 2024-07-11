<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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
ArrayList alB= new ArrayList();
ArrayList alDesc= new ArrayList();


CommonDataObject cdoD = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
//turno ="3";
String showColor = request.getParameter("showColor")==null?"":request.getParameter("showColor");
float recCustomWidth = 0.83f;
//try { recCustomWidth = Float.parseFloat(ResourceBundle.getBundle("issi").getString("recCustomWidth")); } catch(Exception e) { System.out.println("Unable to set WIDTH, using default "+recCustomWidth+"! Error: "+e); }

 
sbSql = new StringBuffer();
sbSql.append("select sum(decode(t.doc_type, 'NCR', 0, net_amount) )+sum(nvl(decode(t.doc_type, 'NCR', 0, nvl(total_discount, 0)+nvl(total_discount_gravable, 0)), 0)) as venta_factura,sum(decode(t.doc_type, 'NCR', net_amount, 0) )+ sum(nvl(decode(t.doc_type, 'NCR',  (nvl(total_discount, 0)+nvl(total_discount_gravable, 0)), 0), 0)) as nota_credito, sum(decode(t.doc_type, 'NCR', 0, net_amount) )as venta_neta_fact,sum(decode(t.doc_type, 'NCR', net_amount, 0) )as venta_ncr,sum(nvl(decode(t.doc_type, 'NCR',0,nvl(total_discount, 0)+nvl(total_discount_gravable, 0)), 0)) as descuento_fac,sum(nvl(decode(t.doc_type, 'NCR',(nvl(total_discount, 0)+nvl(total_discount_gravable, 0)), 0), 0)) descuento_ncr,sum(decode(t.doc_type, 'NCR', 0, tax_amount)) itbm_fac,sum(decode(t.doc_type, 'NCR', tax_amount, 0)) itbm_ncr,sum(decode(t.doc_type, 'NCR', -net_amount, net_amount) ) ventaNeta , cod_caja,turno , company_id,(select nombre from tbl_cja_cajera ca , tbl_cja_turnos ct where ca.cod_cajera=ct.cja_cajera_cod_cajera and ca.compania=ct.compania and ct.compania= t.company_id and ct.codigo=t.turno ) nombre,(select descripcion from tbl_cja_cajas where codigo =cod_caja and compania=company_id) as descCaja,to_char(sysdate,'dd/mm/yyyy') as fecha,to_char(sysdate,'hh12:mi:ss am') as hora from   tbl_fac_trx t where company_id=");

sbSql.append(session.getAttribute("_companyId"));
//sbSql.append(" and cod_caja =1");
//sbSql.append(caja);
sbSql.append(" and turno =");
sbSql.append(turno);

sbSql.append(" group by  cod_caja,turno,company_id"); 

CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

/*
sbSql = new StringBuffer();
sbSql.append("select c.codigo, c.descripcion, nvl(b.monto,0) as monto from tbl_cja_forma_pago c, (select a.fp_codigo, nvl(a.monto,0)-nvl(b.monto,0) monto from (select b.fp_codigo, sum(b.monto) as monto from tbl_cja_transaccion_pago a, tbl_cja_trans_forma_pagos b where b.compania = a.compania and b.tran_anio = a.anio and b.tran_codigo = a.codigo and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.status = 'B' and a.turno = ");
		sbSql.append(turno);
		sbSql.append(" and ((a.rec_status = 'A') or (a.rec_status = 'I' and a.turno = ");
		sbSql.append(turno);
		sbSql.append(" and a.turno <> a.turno_anulacion)) and to_char(a.codigo) != get_sec_comp_param(a.compania, 'FORMA_PAGO_CREDITO')");
		sbSql.append(" group by b.fp_codigo) a, (select f.company_id, fp.fp_codigo, sum (fp.monto) as monto from tbl_fac_trx f, tbl_fac_trx_forma_pagos fp where fp.compania = f.company_id and f.doc_id = fp.doc_id and f.doc_type = 'NCR' and f.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and f.turno = ");
		sbSql.append(turno);
		sbSql.append(" group by f.company_id, fp.fp_codigo) b where a.fp_codigo = b.fp_codigo(+)) b where c.codigo = b.fp_codigo(+)");
		sbSql.append(" union all select -3,  'Recibos Anulados', nvl(sum(nvl(pago_total,0)),0) as monto from tbl_cja_transaccion_pago   where compania = ");
		sbSql.append((String) session.getAttribute("_companyId")); 
   		sbSql.append("and turno_anulacion = ");
		sbSql.append(turno);
		sbSql.append("  and rec_status = 'I'  and turno <> turno_anulacion  and nvl(afectar_saldo,'x')='S' ");
		
al = SQLMgr.getDataList(sbSql.toString());
for(int i = 0; i< al.size(); i++){
	CommonDataObject cdx = (CommonDataObject) al.get(i);
	cdoD.addColValue(cdx.getColValue("codigo"), cdx.getColValue("monto"));
}*/
 sbSql = new StringBuffer();
 
sbSql.append("select sum(decode(ft.doc_type,'NCR',0,abs(nvl(fdt.total_desc,0)))) monto,ds.descripcion,turno FROM tbl_fac_trx ft,tbl_fac_trxitems fdt,tbl_par_descuento ds WHERE   turno=");
sbSql.append(turno);
sbSql.append("  and ft.company_id =");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and fdt.doc_id=ft.doc_id and fdt.id_descuento = ds.id and ds.compania= fdt.compania group by ds.descripcion,turno");
 alDesc = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select sum(monto_pagado) monto, a.forma_pago from (  select  fp.monto monto_pagado ,cfp.descripcion forma_pago,fp.fp_codigo from tbl_cja_transaccion_pago tp,tbl_cja_trans_forma_pagos fp,tbl_cja_forma_pago cfp where tp.compania = fp.compania and tp.anio = fp.tran_anio  and tp.codigo = fp.tran_codigo /*and fp.fp_codigo <> 0*/ and cfp.codigo(+) = fp.fp_codigo and tp.compania=");
sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and tp.turno=");
  sbSql.append(turno);
sbSql.append("  and nvl(tp.rec_status, 'A') <> 'I' )a group by a.forma_pago order by 2");

al = SQLMgr.getDataList(sbSql.toString());
 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+System.currentTimeMillis()+".pdf";

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

	float factor = recCustomWidth;//fue requerido reducir el tamaño de pdf para que se imprimiera correctamente en la impresora con cinta de 3" x N"
	float width = 72 * 3f; //216
	float height = 72 * 11f * factor; //792
	boolean isLandscape = false;
	float leftRightMargin = 0.0f;
	float topMargin = 0.0f * factor;
	float bottomMargin = 0.0f * factor;
	float headerFooterFont = 4f * factor;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE X SISTEMA";
	String subTitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	Vector dHeader = new Vector();
		/*
		//Courier9
		dHeader.addElement(".215");
		dHeader.addElement(".11");
		dHeader.addElement(".05");
		dHeader.addElement(".055");
		dHeader.addElement(".32");
		dHeader.addElement(".25");
		*/
		/*
		//Helvetica8
		dHeader.addElement(".17");
		dHeader.addElement(".10");
		dHeader.addElement(".055");
		dHeader.addElement(".025");
		dHeader.addElement(".40");
		dHeader.addElement(".25");
		*/
		//Helvetica9
		dHeader.addElement(".21");
		dHeader.addElement(".10");
		dHeader.addElement(".075");
		dHeader.addElement(".025");
		dHeader.addElement(".28");
		dHeader.addElement(".31");



	PdfCreator temp = new PdfCreator(width, height, leftRightMargin);
	temp.setNoColumnFixWidth(dHeader);
	temp.createTable();
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(_comp.getNombre(),1,dHeader.size());
  
		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());
		
		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("Caja:",0,1);
		temp.addCols(cdo.getColValue("descCaja"),0,5);

		temp.addCols("Cajer@:",0,1);
		temp.addCols(cdo.getColValue("nombre"),0,5);
		
		temp.addCols("Turno:",0,1);
 		temp.addCols(cdo.getColValue("turno"),0,5);
		temp.addCols("Fecha:",0,1);
		temp.addCols(cdo.getColValue("fecha"),0,5);
		
		temp.addCols("Hora:",0,1);
		temp.addCols(cdo.getColValue("hora"),0,5);
		
		temp.addCols("Usuario:",0,1);
		temp.addCols(UserDet.getUserName(),0,5);
		
		temp.setFont(1,0);
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(" FACTURAS",1,dHeader.size());
		temp.setFont(1,0);
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		temp.setFont(fontFamily,fontSize,0);
		
		temp.addCols("VENTA FACTURA :",0,4);
		temp.addCols(cdo.getColValue("venta_factura"),2,2);
		temp.addCols("DESCUENTOS:",0,4);
		temp.addCols(cdo.getColValue("descuento_fac"),2,2);
		
		temp.setFont(1,0);
		
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f); 
		
		temp.setFont(fontFamily,fontSize,0);
		
		temp.addCols("TOTAL FACTURAS:",0,4);
		temp.addCols(cdo.getColValue("venta_neta_fact"),2,2);

		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f); 
		
		temp.setFont(fontFamily,fontSize,0);
		temp.addBorderCols("D E S C U E N T O S",1,6,0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols("D E S C U E N T O",0,5,0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols("M O N T O",2,1,0.1f,0.0f,0.0f,0.0f);
   
      
 		
		double mTotal = 0.00;
		for (int i=0; i<alDesc.size(); i++)
		{
			CommonDataObject desc = (CommonDataObject) alDesc.get(i);
			mTotal += Double.parseDouble(desc.getColValue("monto"));
		System.out.println("TIPO DESC ====== "+desc.getColValue("descripcion"));
			temp.addCols(desc.getColValue("descripcion"),0,5);
			temp.addCols(CmnMgr.getFormattedDecimal("#.##",desc.getColValue("monto")),2,1);
		}
		
			temp.addCols("TOTAL DESC. ",0,5);
			temp.addCols(CmnMgr.getFormattedDecimal("#.##",mTotal),2,1);

		temp.setFont(fontFamily,fontSize,0);
		
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		
		
		
		temp.setFont(fontFamily,fontSize,0);
		temp.addBorderCols("F O R M A   D E   P A G O",0,5,0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols("M O N T O",2,1,0.1f,0.0f,0.0f,0.0f);
		mTotal=0.0;
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject fpgo = (CommonDataObject) al.get(i);
			mTotal += Double.parseDouble(fpgo.getColValue("monto"));

			temp.addCols(fpgo.getColValue("forma_pago"),0,5);
			temp.addCols(CmnMgr.getFormattedDecimal("#.##",fpgo.getColValue("monto")),2,1);
		}
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		temp.addCols("TOTAL ",0,5);
		temp.addCols(CmnMgr.getFormattedDecimal("#.##",mTotal),2,1);

		temp.setFont(fontFamily,fontSize,0);
		
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(" CREDITO",1,dHeader.size());
		
		temp.addCols("NOTA CREDITO :",0,4);
		temp.addCols(cdo.getColValue("nota_credito"),2,2);
		temp.addCols("DESCUENTOS:",0,4);
		temp.addCols(cdo.getColValue("descuento_ncr"),2,2);
		
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		temp.addCols("TOTAL NCR:",0,4);
		temp.addCols(cdo.getColValue("venta_ncr"),2,2);
		
		temp.addBorderCols(" ",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
		temp.addCols("VENTA NETA:",0,4);
		temp.addCols(cdo.getColValue("ventaNeta"),2,2);
		
		temp.addCols(" ",0,dHeader.size());
		temp.addCols(" ",0,dHeader.size());
	  
  
		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		 
	int allowPrint = 1;
	boolean showUI = true;
	/*
	if (cdo.getColValue("rec_impreso").equalsIgnoreCase("S"))
	{
		allowPrint = 0;
		showUI = false;
	}
	*/
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, (temp.getTableHeight() + (topMargin / factor) + (bottomMargin / factor)), isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, allowPrint, false, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pc.setVAlignment(0);
		pc.addTableToCols(temp.getTable(),1,dHeader.size());
		pc.flushTableBody(true);
	pc.close();
	
	//
	 response.sendRedirect(redirectFile);
	//	 
}
%>