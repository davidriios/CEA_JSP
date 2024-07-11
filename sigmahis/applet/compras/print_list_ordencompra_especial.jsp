<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String desc="";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();


if (appendFilter == null) appendFilter = "";

sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, to_char(a.monto_total,'99,999,999,990.00') as monto_total, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, a.numero_factura, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc"
+ " FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c"
+ " where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and "
+ " a.compania = c.compania and a.tipo_compromiso = 2 and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by a.anio desc, a.num_doc desc  ";


al = SQLMgr.getDataList(sql);
sql ="select count(*) count from (select distinct  '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor  FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b, tbl_inv_almacen c  where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and  a.compania = c.compania and a.tipo_compromiso = 2 and a.compania = "+session.getAttribute("_companyId") + appendFilter+"  ) ";
int nGroup = CmnMgr.getCount(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {
	int maxLines = 55; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	int nItems = al.size()+nGroup;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "compras";
	String fileNamePrefix = "print_list_ordencompra_especial";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

		Vector setDetail = new Vector();
				setDetail.addElement(".04");
				setDetail.addElement(".06");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".30");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "COMPRAS", "ORDEN DE COMPRA ESPECIAL", userName, fecha);

				pc.setNoColumnFixWidth(setDetail);
				pc.createTable();
				pc.addBorderCols("Año",1);
					pc.addBorderCols("No. Solicitud",1);
					pc.addBorderCols("Fecha Documento",1);
					pc.addBorderCols("Fecha Vencimiento",1);
					pc.addBorderCols("Tipo de Pago",0);
					pc.addBorderCols("Almacén",0);
					pc.addBorderCols("No. de Factura",1);
					pc.addBorderCols("Estado",0);
					pc.addBorderCols("Monto",1);
				pc.addTable();
				pc.copyTable("detailHeader");
						//for(int i=0;i<maxLines;i++)
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);

					if (!groupBy.equalsIgnoreCase(cdo.getColValue("nombre_proveedor")))
					{
						pc.createTable();
						pc.setFont(7, 0,Color.blue);
						  pc.addCols("Proveedor: ",1,2);
						  pc.addCols(" "+cdo.getColValue("nombre_proveedor"),0,7,cHeight);
						pc.addTable();
						lCounter++;

					}
								pc.createTable();
								pc.setFont(7, 0);
									pc.addCols(" "+cdo.getColValue("anio"),1,1,cHeight);
									pc.addCols(" "+cdo.getColValue("num_doc"),0,1,cHeight);
									pc.addCols(" "+cdo.getColValue("fecha_documento"),1,1,cHeight);
									pc.addCols(" "+cdo.getColValue("fechaVence"),1,1,cHeight);
									pc.addCols(" "+cdo.getColValue("tipo_pago"),0,1,cHeight);
									pc.addCols(" "+cdo.getColValue("almacen_desc"),0,1,cHeight);
									pc.addCols(" "+cdo.getColValue("numero_factura"),1,1,cHeight);
									pc.addCols(" "+cdo.getColValue("desc_status"),0,1,cHeight);
									pc.addCols(" "+cdo.getColValue("monto_total"),2,1,cHeight);
								pc.addTable();
								lCounter++;





		if (lCounter >= maxLines  && (((pCounter -1)* maxLines)+lCounter < nItems))
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "COMPRAS", "ORDEN DE COMPRA ESPECIAL", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
			pc.setFont(7, 0,Color.blue);
			  pc.addCols("Proveedor: ",1,2);
			  pc.addCols(" "+cdo.getColValue("nombre_proveedor"),0,7,cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
		}
		groupBy=cdo.getColValue("nombre_proveedor");
	}//End For

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();

	}
	else
	{
		pc.setFont(8, 0);
		pc.createTable();
			pc.addCols(al.size()+" Registros en total",0,9);
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
