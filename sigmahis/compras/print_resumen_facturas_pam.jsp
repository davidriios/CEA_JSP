<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
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
/**
==================================================================================
		REPORTE:		INVP_0032.RDF    issue 333
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String cod_prov = request.getParameter("cod_prov");
String appendFilter1 ="" , appendFilter2 = "",filter="";
String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");
String descAlm = request.getParameter("descAlm");


if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_prov== null) cod_prov = "";
if(titulo== null) titulo = "";
if(depto== null) depto = "";
if(descAlm== null) descAlm = "";


if(!fDate.trim().equals(""))
{
appendFilter  +=" and  to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";//recepciones
appendFilter1 +=" and  to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";//devoluciones de provedores
appendFilter2 +=" and  to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";//ajustes

}
if(!tDate.trim().equals(""))
{
appendFilter  +=" and  to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
appendFilter1 +=" and  to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
appendFilter2 +=" and  to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
}

if(!cod_prov.trim().equals(""))
{
 filter  +=" and  a.cod_proveedor = "+cod_prov;
 appendFilter1 +=" and  a.cod_provedor  = "+cod_prov;
}
if(!almacen.trim().equals(""))
{
	filter  +=" and  a.codigo_almacen = "+almacen;
	appendFilter1  +=" and  a.codigo_almacen = "+almacen;
}
/*else
{
filter  +="  and a.codigo_almacen is not null  ";
appendFilter1 +=" and a.codigo_almacen is not null  ";
}*/


sql=" select 'FC' tipo_fac, to_char(a.fecha_documento,'dd/mm/yyyy') fecha , a.numero_factura documento, nvl(a.monto_total,0) monto , a.cod_proveedor cod_prov_fac, prov.nombre_proveedor desc_proveedor, a.codigo_almacen alm_fac,  decode(a.rec_sop_pamd,'S','SALON DE OPERACIONES','H','H.N.A.','P','P.A.M.D.',null,'P.A.M.D.') facturado_a , al.descripcion desc_almacen from tbl_inv_recepcion_material  a, tbl_com_proveedor prov,tbl_inv_almacen al  where a.compania  =  "+compania+appendFilter+filter+" and (a.cod_proveedor =  prov.cod_provedor) and a.fre_documento in ( 'OC', 'FR' ) and a.estado ='R' and a.codigo_almacen = al.codigo_almacen and a.compania = al.compania ";

sql +=" union select 'NC' tipo_dev , to_char(a.fecha,'dd/mm/yyyy') fecha_dev , a.nota_credito documento_dev , a.monto*-1 monto_dev , a.cod_provedor cod_prov_dev, prov.nombre_proveedor desc_prov_dev, a.codigo_almacen alm_dev, null ,al.descripcion desc_almacen from tbl_inv_devolucion_prov a, tbl_com_proveedor prov ,tbl_inv_almacen al  where a.compania = "+compania+" and a.anulado_sino = 'N' and (a.tipo_dev = 'N' or a.tipo_dev is null) and (a.cod_provedor =  prov.cod_provedor) and a.codigo_almacen = al.codigo_almacen and a.compania = al.compania "+ appendFilter1;


sql +=" union select 'ND' tipo_nd , to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_nd, a.n_d documento_nd , nvl(a.total,0) monto_nd , a.cod_proveedor cod_prov_nd , prov.nombre_proveedor desc_prov_nd, a.codigo_almacen alm_nd, null ,al.descripcion desc_almacen from tbl_com_proveedor prov , tbl_inv_ajustes a ,tbl_inv_almacen al  where a.compania = "+compania+appendFilter2+filter+" and a.codigo_ajuste = 3 and ( a.cod_proveedor= prov.cod_provedor)  and a.codigo_almacen = al.codigo_almacen and a.compania = al.compania  order by 7,8,5,6 asc,1,2 asc";

al = SQLMgr.getDataList(sql);

sql= " select distinct nvl(facturado_a,'x') facturado_a , alm_fac ,cod_prov_fac from (  "+sql+" )  order by 2,1";

alTotal = SQLMgr.getDataList(sql);



if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00,total_nivel = 0.00,total_fecha = 0.00;
	Hashtable htProv = new Hashtable();
	int maxLines = 49; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	int nWh = 0,nProv =0 ,nFact=0;
	String descWh = "",descProv ="" ,descFact="";

	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);

		if (!descWh.equalsIgnoreCase(cdo.getColValue("alm_fac")))
		nWh++;
		if (!descFact.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")))
		nFact++;
		if (!descProv.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")+"-"+cdo.getColValue("cod_prov_fac")))
		nProv++;

		descWh   = cdo.getColValue("alm_fac");
		descFact = cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a");
		descProv = cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")+"-"+cdo.getColValue("cod_prov_fac");

	}


	int nItems = al.size() + (nWh*3)+ (nFact*3)+(nProv*5);
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "compras";
	String fileNamePrefix = "print_resumen_facturas_pam";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";
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
		setDetail.addElement(".25");
		setDetail.addElement(".25");
		setDetail.addElement(".25");
		setDetail.addElement(".25");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".10");
		setDetail0.addElement(".25");
		setDetail0.addElement(".25");
		setDetail0.addElement(".35");

	String groupBy = "",subGroupBy = "",provGoupBy ="";
	double  mTotal = 0.00,mWh = 0.00 ,mProv = 0.00,mFact = 0.00;
	int nTotal =0;
	nWh =0;
	nProv =0;
	nFact =0 ;

	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS ", " "+fDate+"       A       "+tDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("TIPO",1,1);
		pc.addCols("FECHA",1,1);
		pc.addCols("DOCUMENTO",0,1);
		pc.addCols("MONTO",2,1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			if (!provGoupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")+"-"+cdo.getColValue("cod_prov_fac")))//totales por facturado a
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("SUB TOTAL POR PROVEEDOR :......"+CmnMgr.getFormattedDecimal(""+mProv),0,4,cHeight);
					pc.addTable();
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("TOTAL DE FACTURAS POR PROVEEDOR :  $ "+nProv,0,4,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("  ",1,4,cHeight);
					pc.addTable();

					lCounter+= 3;
					mProv = 0;
					nProv = 0;
				}
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")))//totales por facturado a
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("CANTIDAD DE FACTURAS POR COMPRA :   "+nFact,0,2,cHeight);
						pc.addCols("SUB TOTAL FACTURADO :  $ "+CmnMgr.getFormattedDecimal(mFact),0,2,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("  ",1,4,cHeight);
					pc.addTable();

					lCounter+=2;
					mFact = 0;
					nFact = 0;
				}
			}


			if (!groupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")))// totales por almacen
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("CANTIDAD DE FACTURAS POR ALMACEN :   "+nWh,0,2,cHeight);
						pc.addCols("TOTAL FACTURADO POR ALMACEN :  $ "+CmnMgr.getFormattedDecimal(mWh),0,2,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("  ",1,4,cHeight);
					pc.addTable();

					lCounter+=2;
					mWh = 0;
					nWh = 0;
				}
			}




			if (!groupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")))// totales por almacen
			{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("ALMACEN :           "+cdo.getColValue("alm_fac")+"        "+cdo.getColValue("desc_almacen"),0,4,cHeight);
					pc.addTable();
					lCounter++;
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")))
			{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("COMPRAS A :        "+cdo.getColValue("facturado_a"),0,4,cHeight);
					pc.addTable();
					lCounter++;
			}
			if (!provGoupBy.equalsIgnoreCase(cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")+"-"+cdo.getColValue("cod_prov_fac")))
			{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("PROVEEDOR :       "+cdo.getColValue("cod_prov_fac")+"    "+cdo.getColValue("desc_proveedor"),0,4,cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");
					lCounter+=2;
			}





		pc.setFont(7, 0);
		pc.createTable();
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+cdo.getColValue("tipo_fac"),1,1,cHeight);
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("documento"),0,1,cHeight);
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addTable();
		lCounter++;
		pc.setFont(7, 0);

		mWh += Double.parseDouble(cdo.getColValue("monto"));
		nWh ++;
		mProv += Double.parseDouble(cdo.getColValue("monto"));
		nProv ++;
		mFact += Double.parseDouble(cdo.getColValue("monto"));
		nFact ++;
		mTotal += Double.parseDouble(cdo.getColValue("monto"));
		nTotal ++;


		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS ", " DESDE "+fDate+"       HASTA      "+tDate, userName, fecha);

				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("ALMACEN :           "+cdo.getColValue("alm_fac")+"        "+cdo.getColValue("desc_almacen"),0,4,cHeight);
					pc.addTable();
					pc.createTable();
						pc.addCols("COMPRAS A :        "+cdo.getColValue("facturado_a"),0,4,cHeight);
					pc.addTable();
					pc.createTable();
						pc.addCols("PROVEEDOR :       "+cdo.getColValue("cod_prov_fac")+"    "+cdo.getColValue("desc_proveedor"),0,4,cHeight);
					pc.addTable();

				pc.addCopiedTable("detailHeader");



		}


		groupBy   = cdo.getColValue("alm_fac");
		subGroupBy = cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a");
		provGoupBy = cdo.getColValue("alm_fac")+"-"+cdo.getColValue("facturado_a")+"-"+cdo.getColValue("cod_prov_fac");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("SUB TOTAL POR PROVEEDOR :......"+CmnMgr.getFormattedDecimal(""+mProv),0,4,cHeight);
					pc.addTable();
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("TOTAL DE FACTURAS POR PROVEEDOR :  $ "+nProv,0,4,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("  ",1,4,cHeight);
					pc.addTable();

					lCounter+= 3;

					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("CANTIDAD DE FACTURAS POR COMPRA :   "+nFact,0,2,cHeight);
						pc.addCols("SUB TOTAL FACTURADO :  $ "+CmnMgr.getFormattedDecimal(mFact),0,2,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("  ",1,4,cHeight);
					pc.addTable();

					lCounter+=2;

					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("CANTIDAD DE FACTURAS POR ALMACEN :   "+nWh,0,2,cHeight);
						pc.addCols("TOTAL FACTURADO POR ALMACEN :  $ "+CmnMgr.getFormattedDecimal(mWh),1,2,cHeight);
					pc.addTable();

					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("CANTIDAD DE FACTURAS POR REPORTE :   "+nTotal,0,2,cHeight);
						pc.addCols("TOTAL FACTURADO POR REPORTE :  $ "+CmnMgr.getFormattedDecimal(mTotal),1,2,cHeight);
					pc.addTable();



	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>