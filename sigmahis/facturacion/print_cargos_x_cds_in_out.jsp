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
String admType = request.getParameter("admType");
String tipoFecha = request.getParameter("tipoFecha");
String ts = request.getParameter("ts");
String aseguradora = request.getParameter("aseguradora");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String cargosFact = request.getParameter("cargosFact");
if (appendFilter == null) appendFilter = "";

if (admType == null) admType = "";
if (fecha_ini == null) fecha_ini = "";
if (fecha_fin == null) fecha_fin = "";
if (cds == null) cds = "";
if (ts == null) ts = "";
if (tipoFecha == null) tipoFecha = "";
if (cargosFact == null) cargosFact = "";
if (aseguradora == null) aseguradora = "";

//and cat.adm_type ='I'
sql.append("select (select descripcion from tbl_cds_centro_servicio where codigo=");
if(cdsDet.trim().equals("S"))sql.append(" b.centro_servicio ");
else sql.append(" a.centro_servicio ");
sql.append(") as centro_servicio_desc, b.tipo_cargo, sum(decode(b.tipo_transaccion,'C',b.cantidad*(b.monto+nvl(b.recargo,0)),'D',-1*b.cantidad*(b.monto+nvl(b.recargo,0)),'H',(b.cantidad * b.monto+nvl(b.recargo,0)))) as monto, (select descripcion from tbl_cds_tipo_servicio where codigo=b.tipo_cargo) as descripcion ,cat.adm_type,");
if(cdsDet.trim().equals("S"))sql.append(" b.centro_servicio  ");
else sql.append(" a.centro_servicio  ");
sql.append(" as cds,decode(cat.adm_type,'I','INGRESOS IP','INGRESOS OP')descType,sum( decode(b.tipo_transaccion,'C',b.cantidad,'D',-1*b.cantidad,'H',b.cantidad)   ) cantidad from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b,tbl_adm_admision adm , tbl_adm_categoria_admision cat  where  a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.tipo_transaccion=b.tipo_transaccion and a.compania = ");
sql.append(session.getAttribute("_companyId"));

if(!admType.trim().equals(""))
{
sql.append(" and cat.adm_type ='");
sql.append(admType);
sql.append("'");
}
if(!cds.trim().equals(""))
{
if(cdsDet.trim().equals("S"))sql.append(" and b.centro_servicio=");
else sql.append(" and a.centro_servicio=");
sql.append(cds);
}
if(cargosFact.equals("")){
if(!fecha_ini.trim().equals(""))
{
if(tipoFecha.trim().equals("C"))sql.append(" and trunc(b.fecha_cargo) >= to_date('");
else sql.append(" and b.fecha_creacion  >= to_date('");
sql.append(fecha_ini);
sql.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals(""))
{
if(tipoFecha.trim().equals("C"))sql.append(" and trunc(b.fecha_cargo) <= to_date('");
else sql.append(" and b.fecha_creacion  <= to_date('");
sql.append(fecha_fin);
sql.append("','dd/mm/yyyy')");
}
}
if(!ts.trim().equals(""))
{
  sql.append(" and b.tipo_cargo = '");
  sql.append(ts);
  sql.append("'");
}
if(!cargosFact.equals("")){
	sql.append(" and ");
	sql.append((cargosFact.equals("N")?"not":""));
	sql.append(" exists (select null from tbl_fac_factura f where f.pac_id = adm.pac_id and f.admi_secuencia = adm.secuencia and f.estatus != 'A'  and f.compania = ");
sql.append(session.getAttribute("_companyId"));
	//if(!cargosFact.equals("")){
	 if(!fecha_ini.trim().equals(""))
	 {
		sql.append(" and f.fecha  >= to_date('");
		sql.append(fecha_ini);
		sql.append("','dd/mm/yyyy')");
	 }
	 if(!fecha_fin.trim().equals(""))
	 {
		sql.append(" and f.fecha  <= to_date('");
		sql.append(fecha_fin);
		sql.append("','dd/mm/yyyy')");
	 }
	 
	sql.append(" and facturar_a in ('E', 'P') )");
}

if (!aseguradora.trim().equals("")){
   sql.append(" and exists (select 'x' from tbl_adm_beneficios_x_admision aba where aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' and aba.pac_id = adm.pac_id and aba.admision = adm.secuencia  and rownum = 1 and aba.empresa = ");
   sql.append(aseguradora);   
   
   sql.append(")");
}
sql.append(" and adm.categoria = cat.codigo and a.pac_id = adm.pac_id and a.admi_secuencia = adm.secuencia group by b.tipo_cargo,");
if(cdsDet.trim().equals("S"))sql.append(" b.centro_servicio, ");
else sql.append(" a.centro_servicio, ");

sql.append(" cat.adm_type order by 1,5,2,4");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "FACTURACION";
	String subtitle = "INGRESOS POR CATEGORIA DE ADMISION (IP/OP)";
	String xtraSubtitle = "DEL "+fecha_ini+"  AL "+fecha_fin ;;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".70");
					dHeader.addElement(".15");
					dHeader.addElement(".15");




	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);

	pc.setTableHeader(1);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0;
    int cantidad = 0, cantidadA = 0, cantidadCds = 0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if(i!=0)
			{
				if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("cds")+"-"+cdo.getColValue("adm_type")))
				{
						pc.addBorderCols("TOTALES POR TIPO DE ADMISION",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+cantidadA,1,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalTa),2,1,0.5f,0.0f,0.0f,0.0f);
						totalTa =0.0;
                        cantidadA = 0;
						pc.addCols(" ",0,dHeader.size());
				}
				if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
				{
						//pc.setFont(0,1,Color.blue);
						pc.setFont(fontSize, 0,Color.blue);
						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+cantidadCds,1,1,0.5f,0.0f,0.0f,0.0f);//descType
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,2,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
                        cantidadCds = 0;
						pc.addCols(" ",0,dHeader.size());
						pc.setFont(fontSize, 0);
				}
			}

			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
			{
				pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			}

			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("cds")+"-"+cdo.getColValue("adm_type")))
			{
					pc.addBorderCols(cdo.getColValue("descType"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
							pc.addBorderCols("Tipo De Servicio",0,1);
							pc.addBorderCols("Cantidad",1,1);
							pc.addBorderCols("Monto",2,1);

			}

			totalCds += Double.parseDouble(cdo.getColValue("monto"));
			totalTa  += Double.parseDouble(cdo.getColValue("monto"));
			monto  = Double.parseDouble(cdo.getColValue("monto"));
			total += Double.parseDouble(cdo.getColValue("monto"));
            cantidad += Integer.parseInt(cdo.getColValue("cantidad","0"));
            cantidadA +=Integer.parseInt(cdo.getColValue("cantidad","0"));
            cantidadCds +=Integer.parseInt(cdo.getColValue("cantidad","0"));


			pc.addCols("["+cdo.getColValue("tipo_cargo")+"]    "+"["+cdo.getColValue("descripcion")+"]",0,1);
			pc.addCols(cdo.getColValue("cantidad"),1,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("cds");
			groupBy2 = cdo.getColValue("cds")+"-"+cdo.getColValue("adm_type");
	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
						pc.addBorderCols("TOTALES POR TIPO DE ADMISION",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+cantidadA,1,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalTa),2,1,0.5f,0.0f,0.0f,0.0f);
						totalTa =0.0;
                        cantidadA = 0;
						pc.addCols(" ",0,dHeader.size());

						pc.setFont(fontSize, 0,Color.blue);

						pc.addBorderCols("TOTALES POR CENTRO DE SERVICIOS",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+cantidadCds,1,1,0.5f,0.0f,0.0f,0.0f);//descType
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totalCds),2,1,0.5f,0.0f,0.0f,0.0f);//descType
						totalCds =0.0;
                        cantidadCds = 0;

						pc.addBorderCols("TOTALES FINALES",2,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+cantidad,1,1,0.5f,0.0f,0.0f,0.0f);//descType
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.5f,0.0f,0.0f,0.0f);//descType

						pc.setFont(fontSize, 0);
						pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>