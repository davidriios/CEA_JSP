<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Reporte: Admisiones sin Facturar             -->
<!-- Reporte: HOSP_EN_ESPERA                      -->
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");
String compania = (String) session.getAttribute("_companyId");

String categoria = request.getParameter("categoria");
String tipoAdmision = request.getParameter("tipoAdmision");
String centroServicio = request.getParameter("area");
String codAseguradora = request.getParameter("aseguradora");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String estadoAdm = request.getParameter("estado_adm");
String admType = request.getParameter("admType");

if (categoria == null) categoria = "";
if (tipoAdmision == null) tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (sala == null) sala = "";
if (estadoAdm == null) estadoAdm = "";
if (admType == null) admType = "";

String appendFilter1 = "", appendFilter2 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and a.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and trunc(a.fecha_ingreso) >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and trunc(a.fecha_ingreso) <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }
if (!categoria.equals(""))
   {
   appendFilter1 += " and a.categoria = "+categoria;
   }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and a.tipo_admision = "+tipoAdmision;
   }
if (!codAseguradora.equals(""))
    {
	 appendFilter1 += " and b.empresa = "+codAseguradora;
	}
if (!estadoAdm.equals(""))
    {
	 appendFilter1 += " and a.estado = '"+estadoAdm+"'";
	} else appendFilter1 += " and a.estado in ('A', 'E')";
if (!admType.equals(""))
    {
	 appendFilter1 += " and a.adm_type = '"+admType+"'";
	}


sql = "select distinct xx.* ,nvl((select sum(decode(bb.tipo_transaccion,'C',bb.cantidad*(bb.monto+nvl(bb.recargo,0)),'D',-1*bb.cantidad*(bb.monto+nvl(bb.recargo,0)),'H',bb.cantidad *(bb.monto+nvl(bb.recargo,0)))) as monto from tbl_fac_detalle_transaccion bb where  bb.pac_id = xx.pac_id and bb.fac_secuencia = xx.secuencia),0) as monto, nvl((select sum(dp.monto) from tbl_cja_transaccion_pago p, tbl_cja_detalle_pago dp where p.codigo = dp.codigo_transaccion and p.compania = dp.compania and p.anio = dp.tran_anio and p.rec_status = 'A' and p.pac_id = xx.pac_id and dp.admi_secuencia = xx.secuencia), 0) abono,(select nombre_corto from tbl_adm_categoria_admision where codigo=xx.categoria) as descCategoria from ( select all cds.descripcion desc_centros,  a.centro_servicio cds, to_char(a.fecha_ingreso,'dd/mm/yyyy') fecha_admision, to_char(a.fecha_egreso,'dd/mm/yyyy') fecha_egreso, '[' || a.pac_id ||' - ' || a.secuencia || ' ]' adm,  p.nombre_paciente nombre_pac,  e.nombre aseguradora, m.primer_apellido||', '||m.primer_nombre medico ,f.codigo, a.pac_id, a.secuencia,a.categoria from tbl_adm_admision a, tbl_cds_centro_servicio cds, vw_adm_paciente p, tbl_adm_beneficios_x_admision b, tbl_adm_empresa e, tbl_adm_medico m ,tbl_fac_factura f where a.centro_servicio = cds.codigo  and a.pac_id = p.pac_id  and b.pac_id(+) = a.pac_id  and b.admision(+) = a.secuencia  and a.medico = m.codigo  and b.prioridad(+) = 1  and nvl(b.estado(+), 'A') = 'A' /*and a.fecha_egreso is not null*/ and e.codigo(+) = b.empresa "+ appendFilter1+ " and a.pac_id = f.pac_id(+) and a.secuencia = f.admi_secuencia(+) and a.compania = f.compania(+) and f.estatus(+) <> 'A' ) xx where codigo is null order by desc_centros, to_date(fecha_admision,'dd/mm/yyyy'), to_date(fecha_egreso,'dd/mm/yyyy') ";
al = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "ADMISIONES EN ESPERA SIN FACTURAR";
	String xtraSubtitle = "DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".07");//
		dHeader.addElement(".18");//
		dHeader.addElement(".07");//
		dHeader.addElement(".06");//
		dHeader.addElement(".06");//
		dHeader.addElement(".19");//
		dHeader.addElement(".13");//
		dHeader.addElement(".08");// monto
		dHeader.addElement(".08");// abono
		dHeader.addElement(".08");// saldo

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(2);

	pc.addBorderCols("Admisión",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Paciente",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("CAT.",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("F.Ing.",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("F.Egr.",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Aseguradora",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Médico",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Cargos",2,1,cHeight,Color.lightGray);
	pc.addBorderCols("Abonos",2,1,cHeight,Color.lightGray);
	pc.addBorderCols("Saldo",2,1,cHeight,Color.lightGray);

	String groupBy = "";		// para agrupar por centro
	int aCounter = 0;				// para la cantidad de pacientes por centro
	int	tCounter = 0;				// para la cantidad total de pacientes
	double saldo = 0.0, totMonto = 0.0, totAbono = 0.0, totSaldo = 0.0, totMontoFinal = 0.0, totAbonoFinal = 0.0, totSaldoFinal = 0.0;
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por Centro de admision
		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("cds")))
		{
					pc.setFont(9, 1,Color.black);
					if (i != 0)  // imprime total de pactes por centro
					{
						pc.addCols("Total de Pacientes en "+groupBy+":   "+String.valueOf(aCounter),0,4,cHeight*2);

						pc.addCols("Total de Monto: ",2,3,cHeight*2);
						pc.addCols(CmnMgr.getFormattedDecimal(totMonto),2,1,cHeight*2);
						pc.addCols(CmnMgr.getFormattedDecimal(totAbono),2,1,cHeight*2);
						pc.addCols(CmnMgr.getFormattedDecimal(totSaldo),2,1,cHeight*2);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					pc.addCols("Centro de Servicio :"+cdo.getColValue("desc_centros"),0,dHeader.size(),cHeight*2);
					aCounter = 0;
					totMonto = 0.0;
					totAbono = 0.0;
					totSaldo = 0.0;

		}
		saldo = Double.parseDouble(cdo.getColValue("monto"))-Double.parseDouble(cdo.getColValue("abono"));
		pc.setFont(7, 0);
		pc.addCols(" "+cdo.getColValue("adm"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombre_pac"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("descCategoria"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fecha_admision"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fecha_egreso"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("aseguradora"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("medico"),0,1,cHeight);
		pc.addCols(" "+ CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addCols(" "+ CmnMgr.getFormattedDecimal(cdo.getColValue("abono")),2,1,cHeight);
		pc.addCols(" "+ CmnMgr.getFormattedDecimal(saldo),2,1,cHeight);

		aCounter++;
		tCounter++;

		totMonto += Double.parseDouble(cdo.getColValue("monto"));
		totAbono += Double.parseDouble(cdo.getColValue("abono"));
		totSaldo += saldo;
		totMontoFinal += Double.parseDouble(cdo.getColValue("monto"));
		totAbonoFinal += Double.parseDouble(cdo.getColValue("abono"));
		totSaldoFinal += saldo;

		groupBy = cdo.getColValue("cds");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(9, 1,Color.black);
			pc.addCols("Total de Pacientes en "+groupBy+":   "+String.valueOf(aCounter),0,4,cHeight*2);

			pc.addCols("Total de Monto: ",2,3,cHeight*2);
			pc.addCols(CmnMgr.getFormattedDecimal(totMonto),2,1,cHeight*2);
			pc.addCols(CmnMgr.getFormattedDecimal(totAbono),2,1,cHeight*2);
			pc.addCols(CmnMgr.getFormattedDecimal(totSaldo),2,1,cHeight*2);

			pc.addCols(" ",0,dHeader.size(),cHeight);


	  //Totales Finales
		  pc.addCols(" ",0,dHeader.size(),cHeight);
		  pc.addCols(" TOTAL FINAL DE PACIENTES:   "+String.valueOf(tCounter),0,4,cHeight*2);

		  pc.addCols("Total Final de Monto: ",2,3,cHeight*2);
		  pc.addCols(CmnMgr.getFormattedDecimal(totMontoFinal),2,1,cHeight*2);
		  pc.addCols(CmnMgr.getFormattedDecimal(totAbonoFinal),2,1,cHeight*2);
		  pc.addCols(CmnMgr.getFormattedDecimal(totSaldoFinal),2,1,cHeight*2);

		  pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
