<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
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
CommonDataObject cdo, cdoDet = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
boolean isEmail = (request.getParameter("email") != null);
String curCompany = request.getParameter("curCompany");
String orderYear = request.getParameter("orderYear");
String noOrder = request.getParameter("noOrder");

//for the order header
sbSql.append("select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha_solicitud, decode(a.estado,'P','PENDIENTE','A', 'APROBADO','R','RECHAZADO','N','ANULADO',a.estado) as estado, a.nom_beneficiario,decode(a.generado,'H',nvl((select reg_medico from tbl_adm_medico where codigo=a.cod_medico),a.num_id_beneficiario),nvl(a.num_id_beneficiario, ' ')) as num_id_beneficiario, a.user_creacion, (select descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (1, 2, 3) and cod_tipo_orden_pago = a.cod_tipo_orden_pago ) cod_tipo_orden_pago, a.monto, a.observacion, a.doc_fuente, to_char(a.fecha_nacimiento_paciente, 'dd/mm/yyyy') fecha_nacimiento_paciente, a.cod_paciente, a.cod_medico, (select descripcion from tbl_cxp_clasif_hacienda where cod_hacienda = a.cod_hacienda) cod_hacienda, a.provincia_empleado, a.sigla_empleado, a.tomo_empleado, a.asiento_empleado, a.cod_unidad_ejecutora, a.cod_provedor, a.compania_prov, a.cod_empresa, a.cod_compania_empleado, a.cod_autorizacion, a.cheque_girado, decode(a.tipo_orden,'E','Empresa','P','Paciente','L','Liquidacion','D','Dividendo','O','Otros','C','Contratos','M','Medico') tipo_orden, a.solicitado_por, a.admision, a.ruc, a.dv, a.hacer, a.telepago, a.ach, a.beneficiario2, a.cod_banco, a.cuenta_banco, a.codigo_aux, a.tipo_persona, a.anio_doc_fuente, a.cod_concepto,a.generado from tbl_cxp_orden_de_pago a where a.cod_compania = ")
	.append(curCompany)
	.append(" and a.num_orden_pago = ")
	.append(noOrder)
	.append(" and a.anio = ")
	.append(orderYear);
cdo = SQLMgr.getData(sbSql.toString());

//detail
sbSql = new StringBuffer();
sbSql.append("select rownum renglon, a.* from (select a.anio, a.num_orden_pago, a.cod_compania, a.num_factura, sum(a.monto_a_pagar) monto_a_pagar, a.cg_1_cta1||'.'||a.cg_1_cta2||'.'||a.cg_1_cta3||'.'||a.cg_1_cta4||'.'||a.cg_1_cta5||'.'||a.cg_1_cta6||' - '||b.descripcion num_cuenta, a.descripcion, b.descripcion descripcion_cuenta,case when a.anio_recepcion is not null then substr(a.descripcion,1,10)  else '' end as ord ,decode('")
	.append(cdo.getColValue("generado"))
	.append("' ,'H',(select 'REC:'||tp.recibo||' del '||to_char(tp.fecha,'dd/mm/yyyy')||' por: '||nvl(nombre_adicional,nombre) from tbl_cja_transaccion_pago tp where tp.codigo=a.codigo_transaccion and  tp.compania=a.cod_compania and anio=a.tran_anio  ),'')  as pagado_por from tbl_cxp_detalle_orden_pago a, tbl_con_catalogo_gral b where a.cod_compania = ")
	.append(curCompany)
	.append(" and a.num_orden_pago = ")
	.append(noOrder)
	.append(" and a.anio = ")
	.append(orderYear)
	.append(" and a.cod_compania = b.compania and a.cg_1_cta1 = b.cta1 and a.cg_1_cta2 = b.cta2 and a.cg_1_cta3 = b.cta3 and a.cg_1_cta4 = b.cta4 and a.cg_1_cta5 = b.cta5 and a.cg_1_cta6 = b.cta6 group by a.codigo_transaccion,a.cod_compania,a.tran_anio,a.anio, a.num_orden_pago, a.cod_compania, a.num_factura, a.cg_1_cta1||'.'||a.cg_1_cta2||'.'||a.cg_1_cta3||'.'||a.cg_1_cta4||'.'||a.cg_1_cta5||'.'||a.cg_1_cta6||' - '||b.descripcion, a.descripcion, b.descripcion,a.anio_recepcion) a order by ord");
al = SQLMgr.getDataList(sbSql.toString());

//System.out.println("thebrain > :::::::::::::::::::::::::::::::::::::::::: "+noOrder);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12miam")+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	String pdfPath = directory+folderName+"/"+year+"/"+month+"/"+fileName;

	if (isEmail) {
		pdfPath = request.getParameter("pdfPath");
		create = "1";//validated on previous jsp
	}

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String title = "ORDENES DE PAGO";
	String subtitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(pdfPath, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 0);
		pc.addCols("Orden No.:   "+orderYear+" - "+noOrder ,0,2);
		pc.addCols("Estado:   "+cdo.getColValue("estado"),0,2);
		pc.addCols("Fecha:   "+cdo.getColValue("fecha_solicitud"),0,2);
		pc.addCols("",0,4);

		pc.addCols("Tipo Orden Pago:   "+cdo.getColValue("cod_tipo_orden_pago"),0,4);
		pc.addCols("Pagos Otros:   "+cdo.getColValue("tipo_orden"),0,2);
		pc.addCols("",0,4);

		pc.addCols("Cod. Econ. y Fin.:   "+cdo.getColValue("cod_hacienda"),0,dHeader.size());

		pc.addCols("A Favor de: ["+cdo.getColValue("num_id_beneficiario")+"] "+cdo.getColValue("nom_beneficiario")+"",0,6);
		pc.addCols("RUC:   "+cdo.getColValue("ruc"),0,2);
		pc.addCols("DV:   "+cdo.getColValue("dv"),0,2);

		pc.addCols("Otro Beneficiario (Caja Men., J. Direc.):   "+cdo.getColValue("beneficiario2"),0,8);
		pc.addCols("Monto:   "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),0,2);

		pc.addCols(" ",0,dHeader.size());
		pc.setFont(7, 1,Color.white);
		pc.addCols("DETALLE",0,dHeader.size(),Color.lightGray);
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(7, 0);

	if (al.size() == 0){
		pc.addCols("No existen registros!",1,dHeader.size());
	}	else {

	    double montoTotal = 0.0;

	    pc.setFont(7, 1,Color.white);
	    pc.addCols("Fact./Rec.",1,2,Color.lightGray);
		if(cdo.getColValue("generado").trim().equals("H"))pc.addCols("Descripción:",1,4,Color.lightGray);
		else pc.addCols("Descripción:",1,3,Color.lightGray);
		pc.addCols("Monto:",2,1,Color.lightGray);
		if(!cdo.getColValue("generado").trim().equals("H"))pc.addCols(" ",1,1,Color.lightGray);
		pc.addCols("Número de Cuenta:",1,3,Color.lightGray);
		pc.setFont(7, 0);

        for(int d = 0; d<al.size(); d++){
            cdoDet = (CommonDataObject)al.get(d);
			
            pc.addCols(cdoDet.getColValue("num_factura"),1,2);
			if(cdo.getColValue("generado").trim().equals("H")) pc.addCols(cdoDet.getColValue("pagado_por")+" "+cdoDet.getColValue("descripcion"),0,4);
			else pc.addCols(cdoDet.getColValue("descripcion"),0,3);
			
			pc.addCols(CmnMgr.getFormattedDecimal(cdoDet.getColValue("monto_a_pagar")),2,1);
			if(!cdo.getColValue("generado").trim().equals("H"))pc.addCols(" ",1,1);
			pc.addCols(" "+cdoDet.getColValue("num_cuenta"),0,3);

			montoTotal += Double.parseDouble( (cdoDet.getColValue("monto_a_pagar")==null?"0":cdoDet.getColValue("monto_a_pagar")));
        }

        pc.setFont(7, 1);
        if(!cdo.getColValue("generado").trim().equals("H"))pc.addCols("Valor del Cheque",2,5);
		else pc.addCols("Valor del Cheque",2,6);
        pc.addCols(CmnMgr.getFormattedDecimal(montoTotal),2,1);
        pc.addCols(" ",1,4);


	}

	pc.addTable();
	pc.close();
	if (!isEmail) response.sendRedirect(redirectFile);
}//get
%>

