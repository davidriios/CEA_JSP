<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String clientId = (request.getParameter("clientId")== null?"":request.getParameter("clientId"));
String fechaIni = request.getParameter("fechaIni") == null?"":request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin") == null?"":request.getParameter("fechaFin");
String estadoFact = request.getParameter("estadoFact") == null?"":request.getParameter("estadoFact");

StringBuffer sbSql = new StringBuffer();

	sbSql.append("select f1.id_fac , lpad(f1.id_fac,10,0) id_fac_dsp, f1.id_clie,f1.id_sol_contrato,f1.fecha_ini_plan,f1.monto,f1.fecha_pago,to_char(f1.fecha_creacion,'dd/mm/yyyy') fecha_creacion,'SISTEMA' usuario_creacion,f1.fecha_modificacion,f1.usuario_modificacion,f1.estado,f1.observacion,to_char(f1.fecha_prox_factura,'dd/mm/yyyy') fecha_prox_factura,f1.nombre_cliente,f1.descripcion_factura,f1.id_beneficiario,f1.nombre_beneficiario,f1.tipo , extra.descripcion fac_estado, (select p.descripcion from tbl_pm_afiliado p where p.id = (select afiliados from tbl_pm_solicitud_contrato sc where sc.id = f1.id_sol_contrato)) plan_desc from tbl_pm_factura f1 ");
	
	sbSql.append(" ,(select ttp.codigo, ttp.descripcion, f.codigo_cargo cod_fac from tbl_cja_tipo_transaccion ttp ,tbl_cja_detalle_pago dp , tbl_cja_transaccion_pago tp, tbl_fac_factura f, tbl_fac_detalle_factura fd where ttp.codigo = dp.tipo_transaccion and tp.codigo = dp.codigo_transaccion and tp.compania = dp.compania and tp.anio = dp.tran_anio and tp.tipo_cliente = 'O' and f.facturado_por = 'PLAN_MEDICO' and tp.ref_id = 1 and f.codigo = dp.fac_codigo and fd.fac_codigo = f.codigo and fd.compania = f.compania) extra ");
	
	sbSql.append(" where f1.id_clie = ");
	sbSql.append(clientId);
	
	sbSql.append(" /**/ and f1.id_fac = extra.cod_fac(+) /**/ ");
	
	if (!estadoFact.equals("")) {
		sbSql.append(" and extra.codigo = ");
		sbSql.append(estadoFact);
	}
		
	if (!fechaFin.trim().equals("") && !fechaIni.trim().equals("")){
	   sbSql.append(" and trunc(f1.fecha_creacion) between to_date('");
	   sbSql.append(fechaIni);
	   sbSql.append("','dd/mm/yyyy') and to_date('");
	   sbSql.append(fechaFin);
	   sbSql.append("','dd/mm/yyyy')");
	}
	
	sbSql.append(" order by f1.id_clie, f1.id_sol_contrato ");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "LISTADO DE FACTURAS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".10"); //Factura
	tblContent.addElement(".50"); //Descripción
	tblContent.addElement(".10"); //Monto
	tblContent.addElement(".10"); //Fecha gen
	tblContent.addElement(".20"); //Gen por
	
	String grpByClie = "", grpByPlan = "";
	double totFinal = 0.0;
	
	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addBorderCols("Factura",1,1);
	pc.addBorderCols("Descripción",0,1);
	pc.addBorderCols("Monto",2,1);
	pc.addBorderCols("F.Creac",1,1);
	pc.addBorderCols("Creada por",1,1);

	pc.setTableHeader(2);

	if (al.size()==0) {
		pc.addCols("No existen datos a cerca de planes!",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);
			
			if (!grpByClie.equalsIgnoreCase(cdo1.getColValue("id_clie"))){
			    pc.setFont(8, 1);
			    pc.addCols("Responsable: "+cdo1.getColValue("nombre_cliente"),0,tblContent.size());
			}
			if (!grpByPlan.equalsIgnoreCase(cdo1.getColValue("id_sol_contrato"))){
			    if (i!=0) pc.addCols(" ",0,tblContent.size());
			    pc.setFont(8, 1);
				pc.addCols("Plan: "+cdo1.getColValue("plan_desc"),0,tblContent.size());
			}
			
			pc.setFont(7, 0);
			pc.addCols(cdo1.getColValue("id_fac_dsp"),1,1);
			pc.addCols(cdo1.getColValue("descripcion_factura"),0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")),2,1) ;
			pc.addCols(cdo1.getColValue("fecha_creacion"),1,1) ;
			pc.addCols(cdo1.getColValue("usuario_creacion"),1,1) ;
			
			grpByClie = cdo1.getColValue("id_clie");
			grpByPlan = cdo1.getColValue("id_sol_contrato");
			
			totFinal += Double.parseDouble(cdo1.getColValue("monto"));

		}//End For

		pc.setFont(8,1);
		pc.addCols("Total:",2,2);
		pc.addCols(CmnMgr.getFormattedDecimal(totFinal),2,1);
		pc.addCols("",2,2);

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>