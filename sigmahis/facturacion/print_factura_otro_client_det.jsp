<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.facturacion.TipoServicio"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cServ" scope="page" class="java.util.Hashtable" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0 ADMINISTRADOR
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
  UserDet=SecMgr.getUserDetails(session.getId());
  session.setAttribute("UserDet",UserDet);
  issi.admin.ISSILogger.setSession(session);

  CmnMgr.setConnection(ConMgr);
  SQLMgr.setConnection(ConMgr);

  UserDet = SecMgr.getUserDetails(session.getId());
	String userName = UserDet.getUserName();

  String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh:mi:ss am");
  String mon = fecha.substring(3, 5);
  String year = fecha.substring(6, 10);
  String date = fecha.substring(0, 10);
  String time = fecha.substring(11);
  String month = "";
  String tf = "";
  if (mon.equals("01")) month = "january";
  else if (mon.equals("02")) month = "february";
  else if (mon.equals("03")) month = "march";
  else if (mon.equals("04")) month = "april";
  else if (mon.equals("05")) month = "may";
  else if (mon.equals("06")) month = "june";
  else if (mon.equals("07")) month = "july";
  else if (mon.equals("08")) month = "august";
  else if (mon.equals("09")) month = "september";
  else if (mon.equals("10")) month = "october";
  else if (mon.equals("11")) month = "november";
  else if (mon.equals("12")) month = "december";

  String query = "";
  SQL2BeanBuilder sbb = new SQL2BeanBuilder();
  ArrayList al = new ArrayList();

  int nDetail = 0;
  int nHeader = 0;
  String compId = (String) session.getAttribute("_companyId");
  String factId = request.getParameter("factId");
	System.out.println("factId = "+factId);

  query="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1, nvl(fax, ' ') compFax1, digito_verificador other1, nvl(substr(replace(logo,'\\','/'),instr(replace(logo,'\\','/'),'/',-1)+1,length(replace(logo,'\\','/'))-instr(replace(logo,'\\','/'),'/',-1)),'NA') compLogo from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
  System.out.println("company query = \n"+query);
  Company com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),query,Company.class);
  String logo = "lgc.jpg";
  if(!com.getCompLogo().equals("NA")) logo = com.getCompLogo();

  CommonDataObject cdoHeader = new CommonDataObject();

  query = "select f.codigo, (f.monto_total-nvl(f.monto_descuento,0)) monto_total, f.subtotal, f.grang_total, to_char(f.fecha, 'dd/mm/yyyy') fecha, c.cliente, c.cliente2, c.codigo cargo, c.no_cargo_appx, c.codigo_devol, c.anio_devol, nvl(c.descuento, 0) descuento, decode(nvl(c.cliente_alq, 'N'), 'S', decode(c.tipo_cliente, 9, 'CLIENTE DE ALQUILER CONTRATO NO.:'||c.alquiler, null), ' ') nota, nvl(a.almacen, ' ') almacen, nvl(i.itbm, 0) itbm, (f.subtotal - nvl(c.descuento, 0) + nvl(i.itbm, 0)) total from tbl_fac_cargo_cliente c, tbl_fac_factura f, (select distinct f.codigo, a.descripcion almacen from tbl_fac_detalle_factura df, tbl_fac_factura f, tbl_fac_cargo_cliente c, tbl_fac_detc_cliente dc, tbl_inv_almacen a where df.compania = f.compania and df.fac_codigo = f.codigo and f.facturar_a = 'O' and dc.inv_almacen = a.codigo_almacen and dc.compania = a.compania and c.anio = f.anio_cargo and c.codigo = f.codigo_cargo and c.tipo_transaccion = f.tipo_cargo and c.compania = f.compania and f.codigo = '"+factId+"' and f.compania = "+compId+" and (df.compania = f.compania and df.fac_codigo = f.codigo) and c.codigo = dc.cargo and c.compania = dc.compania and c.anio = dc.anio and c.tipo_transaccion = dc.tipo_transaccion) a, (select sum(nvl(dc.itbm_x_item, 0)) itbm from tbl_fac_cargo_cliente c, tbl_fac_detc_cliente dc where c.compania = "+compId+" and c.num_factura = '"+factId+"' and c.codigo = dc.cargo and c.tipo_transaccion = dc.tipo_transaccion and c.anio = dc.anio and c.compania = dc.compania) i where f.facturar_a = 'O' and c.anio = f.anio_cargo and c.codigo = f.codigo_cargo and c.tipo_transaccion = f.tipo_cargo and c.compania = f.compania and f.codigo = '"+factId+"' and f.compania = "+compId+" and f.codigo = a.codigo(+)";

	cdoHeader = SQLMgr.getData(query);

	String sql = "select getcodigoart(df.descripcion) codigo, df.descripcion, df.cantidad, df.monto  from tbl_fac_cargo_cliente c, tbl_fac_factura f, tbl_fac_detalle_factura df where f.facturar_a = 'O' and c.anio = f.anio_cargo and c.codigo = f.codigo_cargo and c.tipo_transaccion = f.tipo_cargo and c.compania = f.compania and f.compania = df.compania and f.codigo = df.fac_codigo and f.codigo = '"+factId+"' and f.compania = " + compId;

	al = SQLMgr.getDataList(sql);

	int maxLines = 37; //max lines per page
	int nLines = al.size(); //number of lines
	int extraLines = 0;
	int nPages = 0; //number of pages

	//calculating number of page

	extraLines = nLines % maxLines;
	if (extraLines == 0) nPages = nLines / maxLines;
	else nPages = (nLines / maxLines) + 1;

	if(request.getMethod().equalsIgnoreCase("GET")) {

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+logo;
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;

	String folderName = "facturacion";
	String fileNamePrefix = "factura_others"+compId+"_"+factId;
	String fileNameSuffix = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+month;
	String docTitle = "Detalle de Cargos";
	fileName = fileName+fileNameSuffix+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	else {

		String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
		fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

		int headerFooterFont = 4;

		StringBuffer sbFooter = new StringBuffer();
		sbFooter.append("");

		float leftRightMargin = 30.0f;
		float topMargin = 40.0f;
		float bottomMargin = 40.0f;

		issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

		Vector setVal=new Vector();

		int lCounter = 0;
		int pCounter = 0;
		//***************//
		//***************//GENERAL HEADER BEGIN HERE
		//*****************************************//
		Vector setHeader0=new Vector();
		setHeader0.addElement(".75");
		setHeader0.addElement(".25");

		Vector setHeader2=new Vector();
		setHeader2.addElement(".50");
		setHeader2.addElement(".10");
		setHeader2.addElement(".20");
		setHeader2.addElement(".20");

		Vector setHeaderPaciente=new Vector();
		setHeaderPaciente.addElement(".10");
		setHeaderPaciente.addElement(".70");
		setHeaderPaciente.addElement(".10");
		setHeaderPaciente.addElement(".10");

		Vector setInnerVal = new Vector();
		setInnerVal.addElement("130");

		int x = 0;
		int posI=0, posF=0, posIni=0, posFin=0;
		String cond = "1", lext = "";

		for (int j=1; j<=nPages; j++){
			int rows = 0;
			pc.setNoColumnFixWidth(setHeader0);

			pc.createTable();
				pc.setFont(12, 1);
				pc.addImageCols(""+logoPath,30.0f,0);
				pc.setVAlignment(2);

				pc.setNoInnerColumnFixWidth(setInnerVal);
				pc.createInnerTable();
					pc.setFont(7, 0);
					pc.addInnerTableCols("APARTADO "+com.getCompPAddress(), 2, 1);
					pc.addInnerTableCols("PANAMA, REP. DE PANAMA", 2, 1);
					pc.addInnerTableCols("TELEFONO "+com.getCompTel1(), 2, 1);
					pc.addInnerTableCols("FAX "+com.getCompFax1(), 2, 1);
				pc.addInnerTableToCols();

				pc.resetVAlignment();
			pc.addTable();

			pc.setNoColumnFixWidth(setHeader2);

			pc.createTable();
				pc.setFont(7, 0);
				pc.addBorderCols(com.getCompLegalName()+" "+com.getCompRUCNo()+" "+com.getOther1(), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 0);
				pc.addBorderCols("CIA.: "+compId, 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(14, 1);
				pc.addBorderCols("Factura No.:", 0, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(factId, 0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addTable();

			pc.createTable();
				pc.addCols("", 0,4);
			pc.addTable();

			pc.createTable();
				pc.addCols("", 0,4);
			pc.addTable();

			pc.createTable();
				pc.addCols("", 0,4);
			pc.addTable();

			pc.setNoColumnFixWidth(setHeaderPaciente);
			pc.setFont(7, 0);
			String label = "";

			pc.createTable();
				pc.setFont(8, 1);
				pc.addBorderCols("Nombre:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(9, 0);
				pc.addBorderCols(cdoHeader.getColValue("cliente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 1);
				pc.addBorderCols("" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 0);
				pc.addBorderCols("", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addTable();

			pc.createTable();
				pc.setFont(8, 1);
				pc.addBorderCols("Paciente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(9, 0);
				pc.addBorderCols(cdoHeader.getColValue("cliente2"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 1);
				pc.addBorderCols("Fecha:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(9, 0);
				pc.addBorderCols(cdoHeader.getColValue("fecha"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addTable();

			pc.createTable();
				pc.setFont(8, 1);
				pc.addBorderCols("Almac�n:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 0);
				pc.addBorderCols(cdoHeader.getColValue("almacen"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 1);
				pc.addBorderCols("Doc. No.:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(8, 0);
				pc.addBorderCols(cdoHeader.getColValue("no_cargo_appx"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addTable();

			pc.setNoColumnFixWidth(setHeaderPaciente);

			pc.setFont(8, 1);
			pc.createTable();
				pc.addBorderCols("CODIGO", 1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				pc.addBorderCols("D E T A L L E", 1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
				pc.addBorderCols("UDS", 1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
				pc.addBorderCols("MONTO", 1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
			pc.addTable();

			if (al.size() > 0){

				x=0;
				if (cond.equalsIgnoreCase("1")){
					posI = (maxLines * j) - maxLines;
					posF = maxLines * j;
				} else if (cond.equalsIgnoreCase("2")){
					posI = posIni;
					posF = posFin;
				}
%><%

				for (int i=posI; i<posF; i++){
					if (al.size() > 0){
						CommonDataObject cdo = (CommonDataObject) al.get(i);
						rows++;
						pc.setFont(9, 0);    
						pc.createTable();
							pc.addBorderCols(cdo.getColValue("codigo"), 1, 1, 0.0f, 0.0f, 0.5f, 0.5f);
							pc.addBorderCols(cdo.getColValue("descripcion"), 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
							pc.addBorderCols((cdo.getColValue("cantidad")!=null && !cdo.getColValue("cantidad").trim().equals(""))?CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad")):"", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
							pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
						pc.addTable();

						x=x+1;

						if(x==maxLines){
							cond="2";
							posIni=i+1;
							posFin=i+maxLines+1;
							lext = "1";
							break;
						}
					}

					if ((i + 1) == al.size()){
						for(int n=rows;n<25;n++){
							pc.setFont(9, 0);
							pc.createTable();
								pc.addBorderCols(" ", 1, 1, 0.0f, 0.0f, 0.5f, 0.5f);
								pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
								pc.addBorderCols(" ", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
								pc.addBorderCols(" ", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
							pc.addTable();
						}

						pc.setFont(7, 0);
						pc.createTable();
							pc.addBorderCols("FACTURA POR COMPUTADORA AUTORIZADA SEGUN RES. No. 201-1213 del 18 de mayo de 2004", 0, 2, 0.0f, 0.5f, 0.5f, 0.0f);
							pc.setFont(10, 0);
							pc.addBorderCols("Subtotal:", 2, 1, 0.0f, 0.5f, 0.0f, 0.5f);
							pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("subtotal")), 2, 1, 0.5f, 0.5f, 0.0f, 0.5f);
						pc.addTable();
						pc.createTable();
							pc.setFont(7, 0);
							pc.addBorderCols("Timbres que corresponden al presente documento son pagados por declaraci�n segun Ley 61 del 27 de Dic. de 2002", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
							pc.setFont(10, 0);
							pc.addBorderCols("Descuento:", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
							pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("descuento")), 2, 1, 0.5f, 0.5f, 0.0f, 0.5f);
						pc.addTable();
						pc.createTable();
							pc.addBorderCols("I.T.B.M.S.:", 2, 3, 0.0f, 0.0f, 0.5f, 0.5f);
							pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("itbm")), 2, 1, 0.5f, 0.5f, 0.0f, 0.5f);
						pc.addTable();
						pc.createTable();
							pc.addBorderCols("Total:", 2, 3, 0.5f, 0.0f, 0.5f, 0.5f);
							pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("total")), 2, 1, 0.5f, 0.5f, 0.0f, 0.5f);
						pc.addTable();

						break;
					}
				}// for
			}//if (al.size() > 0)

			if (j != nPages ){
			System.out.println("new page.................................");
			pc.addNewPage();
			}
		} //j

	 pc.close();
		//System.err.println(redirectFile);
		response.sendRedirect(redirectFile);
	}
}//get
%>
