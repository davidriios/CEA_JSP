<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

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
ArrayList al2 = new ArrayList();
ArrayList alDev = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");
String fechaFin = request.getParameter("fechaFin");
String fechaIni = request.getParameter("fechaIni");

String noAdmision = request.getParameter("noAdmision");
String pacId = request.getParameter("pacId");
String factId = request.getParameter("factId");
String fp = request.getParameter("fp");
String usuario = request.getParameter("usuario");
String tipoUsuario = request.getParameter("tipoUsuario");

String cds = request.getParameter("cds");
String tipoAj = request.getParameter("tipoAj");
String tipoFecha =request.getParameter("tipoFecha");
String libro =request.getParameter("libro");
String aseguradora =request.getParameter("aseguradora");
String aseguradoraDesc =request.getParameter("aseguradoraDesc");
String grupo =request.getParameter("grupo");
String factA =request.getParameter("factA");

if (appendFilter == null) appendFilter = "";
if (fg == null||fg.trim().equals("")) fg = "";// AJUSTES A FACTURAS, REC  AJUSTES A RECIBOS
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (factId == null) factId = "";
if (fp == null) fp = "";
if (usuario == null) usuario = "";
if (tipoUsuario == null) tipoUsuario = "";
if (cds == null) cds = "";
if (tipoAj == null) tipoAj = "";
if (tipoFecha == null) tipoFecha = "";
if (libro == null) libro = "";
if (aseguradora==null)aseguradora="";
if (aseguradoraDesc==null)aseguradoraDesc="";
if (grupo==null)grupo="";
if (factA== null)factA="";
sql.append("select decode(det.tipo,'C',''||det.centro,'E',''||det.empresa,'H',''||det.medico,'P','COPAGO','M','PERDIEM','D','DIALISIS') as v_codigo, decode(det.tipo,'C',c.descripcion,'E','HONORARIOS','H','HONORARIOS', 'P', 'COPAGO') as descripcion, det.lado_mov, decode(det.lado_mov,'D','DEBITO','C','CREDITO') lado_m, sum(decode(det.lado_mov,'D',nvl(det.monto,0),0)) montoDebito, sum(decode(det.lado_mov,'C', nvl(det.monto,0),0)) montoCredito, det.nota_ajuste codigo, det.usuario_creacion, to_char(det.fecha,'dd/mm/yyyy')as fecha, t.descripcion as descAjuste, det.recibo, det.total, nvl((select p.nombre_paciente from vw_adm_paciente p, tbl_fac_factura f where f.codigo = det.factura and f.compania = det.compania and f.pac_id = p.pac_id ),'S/N') nombrepaciente, det.secuencia, det.tipo, det.medico, det.factura, decode(det.empresa,0,null,det.empresa) as cod_empresa, det.explicacion, det.referencia, det.data_refer, ts.descripcion serviceDesc, det.tipo_ajuste, nvl(to_char(det.centro),'SIN CENTRO') centro, det.usuario_aprob, to_char(det.fecha_aprob,'dd/mm/yyyy') fecha_aprob, nvl((select id_paciente from vw_adm_paciente p, tbl_fac_factura f where f.codigo = det.factura and f.compania = det.compania and f.pac_id = p.pac_id), 'S/C') identificacion, to_char(det.fecha_creacion, 'dd/mm/yyyy') fecha_creacion,(select description from tbl_fac_adjustment_group where id=t.group_type) descGrupo from vw_con_adjustment_gral det, tbl_cds_centro_servicio c, tbl_adm_medico m, tbl_fac_tipo_ajuste t, tbl_adm_empresa e, tbl_cds_tipo_servicio ts where det.compania= ");
sql.append(compania);


if(!fechaIni.trim().equals(""))
{
	if(tipoFecha.trim().equals("A"))
	sql.append(" and trunc(det.fecha_aprob) >= to_date('");
	else sql.append(" and trunc(det.fecha) >= to_date('");

	sql.append(fechaIni);
	sql.append("','dd/mm/yyyy')");
}
if(!fechaFin.trim().equals(""))
{
	if(tipoFecha.trim().equals("A"))
	sql.append(" and trunc(det.fecha_aprob) <= to_date('");
	else sql.append(" and trunc(det.fecha) <= to_date('");
	sql.append(fechaFin);
	sql.append("','dd/mm/yyyy')");
}
if(!pacId.trim().equals(""))
{
	sql.append(" and det.ref_id = ");
	sql.append(pacId);

	if(!noAdmision.trim().equals(""))
	{
		sql.append(" and det.amision = ");
		sql.append(noAdmision);
	}

}

if(!factId.trim().equals(""))
{
	sql.append(" and det.factura = '");
	sql.append(factId);
	sql.append("'");
}

if(!fg.trim().equals(""))
{
	sql.append(" and det.tipo_doc = '");
	sql.append(fg);
	sql.append("'");
}
if(!tipoUsuario.trim().equals(""))
{
	if(tipoUsuario.trim().equals("C"))
sql.append(" and lower(det.usuario_creacion) = lower('");
else sql.append(" and lower(det.usuario_aprob) = lower('");

	sql.append(usuario);
	sql.append("')");
}
if(fp.trim().equals("T"))
{
	//sql.append(" and ( det.referencia <> 99 or det.referencia is null )");
}
if(!tipoAj.trim().equals(""))
{
	sql.append(" and det.tipo_ajuste = '");
	sql.append(tipoAj);
	sql.append("'");
}
if(!cds.trim().equals(""))
{
	sql.append(" and det.centro = ");
	sql.append(cds);
	sql.append("");
}
if(!libro.trim().equals(""))
{
	if(!grupo.trim().equals("")){sql.append(" and t.group_type='");sql.append(grupo);sql.append("'");}
	else sql.append(" and t.group_type in ( 'A','F','G') ");
}
if(!aseguradora.trim().equals("")||!factA.trim().equals(""))
{
	sql.append(" and exists (select 1 from tbl_fac_factura f where f.codigo = det.factura and f.compania = det.compania ");
	if(!aseguradora.trim().equals("")){
	 sql.append("and f.cod_empresa =");
	sql.append(aseguradora);}
	if(!factA.trim().equals("")){
	 sql.append("and f.facturar_a ='");
	sql.append(factA);sql.append("'");}
	
	sql.append(")");
}


sql.append(" and det.centro=c.codigo(+) and det.medico=m.codigo(+) and det.empresa = e.codigo(+)and det.compania =t.compania and det.tipo_ajuste=t.codigo  and det.service_type = ts.codigo(+) group by t.group_type,det.pac_id,det.centro,decode(det.tipo,'C',''||det.centro,'E',''||det.empresa,'H',''||det.medico,'P','COPAGO','M','PERDIEM','D','DIALISIS'),decode(det.tipo,'C',c.descripcion,'E','HONORARIOS','H','HONORARIOS', 'P', 'COPAGO') ,det.lado_mov,decode(det.lado_mov,'D','DEBITO','C','CREDITO'), det.nota_ajuste,det.usuario_creacion,det.usuario_aprob, to_char(det.fecha,'dd/mm/yyyy'), t.descripcion, det.recibo, det.total, det.secuencia, det.tipo, det.medico, det.factura, det.compania, decode(det.empresa,0,null,det.empresa), det.explicacion, det.referencia, det.data_refer, ts.descripcion, det.lado_mov, det.tipo_ajuste, det.usuario_aprob, to_char(det.fecha_aprob,'dd/mm/yyyy'), to_char(det.fecha_creacion, 'dd/mm/yyyy') ");
if(fg.trim().equals("F"))sql.append(" having sum(decode(det.lado_mov,'D',nvl(det.monto,0),0)) <> 0 or sum(decode(det.lado_mov,'C',nvl(det.monto,0),0)) <> 0 ");
sql.append(" order by det.tipo_ajuste, det.centro, det.data_refer, det.tipo, det.nota_ajuste, det.secuencia asc ");



al = SQLMgr.getDataList(sql.toString());
al2 = SQLMgr.getDataList("select sum(montoDebito) as montoDebito, sum(montoCredito) as montoCredito,descGrupo from("+sql.toString()+") group by descGrupo");


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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 6;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACIÓN";
	String subtitle = "NOTAS DE AJUSTES"+(!aseguradoraDesc.trim().equals("")?"   POR ASEG. ( "+aseguradora+" - "+aseguradoraDesc+" )":"");
	String xtraSubtitle = ""+((!fechaIni.trim().equals("")&&!fechaFin.trim().equals(""))?" DEL  "+fechaIni+"  AL  "+fechaFin:" ");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".09");
		dHeader.addElement(".23");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".08");
		dHeader.addElement(".08");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Tipo/ID",1);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Fecha Crea.",1);
		pc.addBorderCols("U. Crea.",1);
		pc.addBorderCols("U. Aprob.",1);
		pc.addBorderCols("Referencia",1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Recibo",1);
		pc.addBorderCols("Débito",1);
		pc.addBorderCols("Crédito",1);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "", groupBy2 = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00,totalCrCentro=0.00,totalDbCentro =0.00,totalCrAjuste=0.00,totalDbAjuste=0.00 ;
	double res = 0.00;

	String descripcion = "";
	String v_codigo = "";
	String v_monto = "";
	String v_descripcion = "";
	String v_factura = "",descCentro="",descAjuste="";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(fp.trim().equals("T"))
		{
			if (!groupBy2.equalsIgnoreCase(cdo.getColValue("centro")))
			{

				//Encabezado
				if(i!=0)
				{
					pc.addCols(" ", 0, dHeader.size());
					pc.setFont(8, 1);
					pc.addCols("Total por "+descCentro, 2,8);
					pc.addCols(""+CmnMgr.getFormattedDecimal(totalDbCentro), 2,1);

					pc.addCols(""+CmnMgr.getFormattedDecimal(totalCrCentro), 2,1);
					descCentro = "";
					totalCrCentro=0.00;
					totalDbCentro =0.00;
				}

				if (!groupBy.equalsIgnoreCase(cdo.getColValue("tipo_ajuste")))
				{

					if(i!=0)
					{
						pc.addCols(" ", 0, dHeader.size());
						pc.setFont(8, 1);
						pc.addCols("Total por Ajuste "+descAjuste, 2,8);
						pc.addCols(""+CmnMgr.getFormattedDecimal(totalDbAjuste), 2,1);

						pc.addCols(""+CmnMgr.getFormattedDecimal(totalCrAjuste), 2,1);
						totalDbAjuste=0.00;
						totalCrAjuste =0.00;
					}
					//Encabezado
					if(i!=0) pc.addCols(" ", 0, dHeader.size());
						pc.setFont(groupFontSize, 1);
						pc.addCols(""+cdo.getColValue("tipo_ajuste")+" - "+cdo.getColValue("descAjuste"), 0,10);
						pc.setFont(groupFontSize, 0);
						descAjuste = cdo.getColValue("descAjuste");

				}
					pc.setFont(groupFontSize, 1);
					pc.addCols(" "+cdo.getColValue("centro"), 0,1);
					pc.addCols(""+cdo.getColValue("descripcion"), 0,9);
					pc.setFont(groupFontSize, 0);

					descCentro = cdo.getColValue("descripcion");
			}
		}
		else
		{
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("tipo_ajuste")))
			{

				//Encabezado
				if(i!=0) pc.addCols(" ", 0, dHeader.size());
					pc.setFont(groupFontSize, 1);
					pc.addCols(""+cdo.getColValue("tipo_ajuste")+" - "+cdo.getColValue("descAjuste"), 0,10);
					pc.setFont(groupFontSize, 0);

			}
		}

				pc.setFont(contentFontSize, 0);
				pc.addCols(""+cdo.getColValue("identificacion"), 1,1);
				if(!fp.trim().equals("T")){ pc.setFont(6, 0);pc.addCols(""+cdo.getColValue("descripcion")+(((cdo.getColValue("serviceDesc") !=null && !cdo.getColValue("serviceDesc").trim().equals("")))?" ["+cdo.getColValue("serviceDesc")+" ]":""), 0,1);}
				else pc.addCols(""+cdo.getColValue("nombrePaciente"), 0,1);
				//pc.addCols(""+cdo.getColValue("v_codigo"), 1,1);
				pc.addCols(""+cdo.getColValue("fecha_creacion"), 1,1);
				pc.addCols(""+cdo.getColValue("usuario_creacion"), 1,1);
				pc.addCols(""+cdo.getColValue("usuario_aprob"), 1,1);
				pc.addCols(""+cdo.getColValue("referencia"), 1,1);
				pc.addCols(""+cdo.getColValue("factura"), 1,1);
				pc.addCols(""+cdo.getColValue("recibo"), 1,1);

				if(cdo.getColValue("lado_mov").trim().equals("D"))
				{
						pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("montoDebito")), 2,1);
						pc.addCols(" ", 2,1);
						totalDb += Double.parseDouble(cdo.getColValue("montoDebito"));
						totalDbCentro += Double.parseDouble(cdo.getColValue("montoDebito"));
						totalDbAjuste += Double.parseDouble(cdo.getColValue("montoDebito"));

				}
				else
				{
						pc.addCols(" ", 2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("montoCredito")), 2,1);
						totalCr += Double.parseDouble(cdo.getColValue("montoCredito"));
						totalCrCentro += Double.parseDouble(cdo.getColValue("montoCredito"));
						totalCrAjuste += Double.parseDouble(cdo.getColValue("montoCredito"));

				}


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		descripcion = cdo.getColValue("nombrePaciente");
		groupBy =cdo.getColValue("tipo_ajuste");
		groupBy2 =cdo.getColValue("centro");
		descCentro = cdo.getColValue("descripcion");

}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			if(fp.trim().equals("T")){
			pc.addCols(" ", 0, dHeader.size());
			pc.setFont(8, 1);
			pc.addCols("Total por "+descCentro, 2,8);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDbCentro), 2,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCrCentro), 2,1);
			descCentro = "";

			pc.addCols(" ", 0, dHeader.size());
			pc.setFont(8, 1);
			pc.addCols("Total por Ajuste "+descAjuste, 2,8);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDbAjuste), 2,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCrAjuste), 2,1);
			}
			pc.addCols(" ", 1,dHeader.size());
			pc.setFont(8, 1);
			pc.addCols("Total", 2,8);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb), 2,1);

			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCr), 2,1);
			
			pc.addCols("Saldo == ", 2,8);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb-totalCr), 2,2); 
			/*pc.addCols(" ", 1,dHeader.size());
			pc.addCols("Total Ajuste a  Factura", 1,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb- totalCr),0,4);*/
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>