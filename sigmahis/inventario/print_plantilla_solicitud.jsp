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
		REPORTE:		INV00137.RDF     REQUISICIONES DE  MATERIALES NUTRICION
								INV00138.RDF     REQUISICIONES DE  MATERIALES NUTRICION TIPO 3 NUTRICION GRANDE

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
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String semana = request.getParameter("semana");
String tipo  = request.getParameter("tipo");
String familyCode ="",classCode ="";
String titulo="";


if(almacen == null) almacen = "4";
if(semana  == null) semana = "1";
if(tipo    == null) tipo = "1";

if(tipo.trim().equals("3"))
	titulo = "CANTIDADES APROXIMADAS PARA REQUISICION DE MATERIALES";
else titulo = "REQUISICION DE MATERIALES";

if (appendFilter == null) appendFilter = "";


 sql="select all ssp.compania, ssp.codigo_almacen, alm.descripcion desc_almacen, ssp.semana,  ssp.cod_familia, ssp.cod_clase, ssp.cod_articulo, ssp.cod_familia||'-'||ssp.cod_clase||'-'||ssp.cod_articulo codigo_articulo,nvl(ssp.cantidad_dia1,0) cantidad_dia1, nvl(ssp.cantidad_dia2,0) cantidad_dia2, nvl(ssp.cantidad_dia3,0) cantidad_dia3, nvl(ssp.cantidad_dia4,0) cantidad_dia4, nvl(ssp.cantidad_dia5,0) cantidad_dia5, nvl(ssp.cantidad_dia6,0) cantidad_dia6, nvl(ssp.cantidad_dia7,0) cantidad_dia7,nvl(ssp.cantidad_dia1,0) + nvl(ssp.cantidad_dia2,0) + nvl(ssp.cantidad_dia3,0) + nvl(ssp.cantidad_dia4,0) + nvl(ssp.cantidad_dia5,0) + nvl(ssp.cantidad_dia6,0) + nvl(ssp.cantidad_dia7,0)  total ,  art.descripcion desc_articulo, initcap(art.cod_medida)  cod_medida, cla.descripcion  desc_clase, fam.nombre  desc_familia,'SOLICITUD PARA '||sst.descripcion dsp_tipo_solicitud,ssp.tipo_solicitud, ssp.cod_familia||'-'||ssp.cod_clase classCode,ssp.codigo_almacen||'-'||ssp.tipo_solicitud keyType  from solicitud_semanal_plantilla ssp, tbl_inv_almacen alm, tbl_inv_articulo art, tbl_inv_familia_articulo fam, tbl_inv_clase_articulo cla,solicitud_semanal_tipo sst where ((ssp.compania=alm.compania)  and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=alm.compania) and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=art.compania) and (ssp.cod_familia=art.cod_flia) and (ssp.cod_clase=art.cod_clase) and (ssp.cod_articulo=art.cod_articulo) and (ssp.tipo_solicitud=sst.codigo) and (ssp.codigo_almacen=sst.codigo_almacen) and (ssp.compania=sst.compania) and (art.compania=cla.compania and art.cod_flia=cla.cod_flia and art.cod_clase=cla.cod_clase) and (cla.compania=fam.compania and cla.cod_flia=fam.cod_flia)) and ssp.compania  = "+compania+"  and ssp.codigo_almacen =  "+almacen+"  and ssp.tipo_solicitud = "+tipo+"  and ssp.semana = "+semana+" order by ssp.compania asc, ssp.codigo_almacen asc, alm.descripcion asc,ssp.cod_familia, ssp.cod_clase, ssp.cod_articulo ";

al = SQLMgr.getDataList(sql);
sql="select count(*) from (  ";

sql +="select distinct 'F' type,ssp.cod_familia,fam.nombre from solicitud_semanal_plantilla ssp, tbl_inv_almacen alm, tbl_inv_articulo art, tbl_inv_familia_articulo fam, tbl_inv_clase_articulo cla,solicitud_semanal_tipo sst where ((ssp.compania=alm.compania)  and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=alm.compania) and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=art.compania) and (ssp.cod_familia=art.cod_flia) and (ssp.cod_clase=art.cod_clase) and (ssp.cod_articulo=art.cod_articulo) and (ssp.tipo_solicitud=sst.codigo) and (ssp.codigo_almacen=sst.codigo_almacen) and (ssp.compania=sst.compania) and (art.compania=cla.compania and art.cod_flia=cla.cod_flia and art.cod_clase=cla.cod_clase) and (cla.compania=fam.compania and cla.cod_flia=fam.cod_flia)) and ssp.compania  = "+compania+" and ssp.codigo_almacen = "+almacen+" and ssp.tipo_solicitud ="+tipo+" and ssp.semana = "+semana+" ";
sql +=" union select  distinct 'C' type, ssp.cod_clase, cla.descripcion  desc_clase from solicitud_semanal_plantilla ssp, tbl_inv_almacen alm, tbl_inv_articulo art, tbl_inv_familia_articulo fam, tbl_inv_clase_articulo cla,solicitud_semanal_tipo sst where ((ssp.compania=alm.compania)  and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=alm.compania) and (ssp.codigo_almacen=alm.codigo_almacen) and (ssp.compania=art.compania) and (ssp.cod_familia=art.cod_flia) and (ssp.cod_clase=art.cod_clase) and (ssp.cod_articulo=art.cod_articulo) and (ssp.tipo_solicitud=sst.codigo) and (ssp.codigo_almacen=sst.codigo_almacen) and (ssp.compania=sst.compania) and (art.compania=cla.compania and art.cod_flia=cla.cod_flia and art.cod_clase=cla.cod_clase) and (cla.compania=fam.compania and cla.cod_flia=fam.cod_flia)) and ssp.compania  = "+compania+" and ssp.codigo_almacen =  "+almacen+"  and ssp.tipo_solicitud = "+tipo+"  and ssp.semana =  "+semana+" ) ";


//


int nGroup = CmnMgr.getCount(sql);
System.out.println("al.size = "+al.size()+ "   nGroup    ="+nGroup);
//alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{

	int maxLines = 48; //max lines of items

	if(!tipo.trim().equals("3"))
		maxLines = 35;

	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() + nGroup;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_plantilla";
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
	boolean isLandscape = true;
	if(tipo.trim().equals("3"))isLandscape = false;
	fecha =   CmnMgr.getCurrentDate("DD-MON-RRRR HH24:MI:SS am");
	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail1 = new Vector();
		setDetail1.addElement(".25");
		setDetail1.addElement(".50");
		setDetail1.addElement(".25");

	Vector setDetail = new Vector();
		setDetail.addElement(".07");
		setDetail.addElement(".29");
		setDetail.addElement(".05");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".05");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");
		setDetail.addElement(".04");


	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, ""+titulo,"", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("UNID. MED",0,1);
		pc.addBorderCols("LUNES",1,2);
		pc.addBorderCols("MARTES",1,2);
		pc.addBorderCols("MIERCOLES",1,2);
		pc.addBorderCols("JUEVES",1,2);
		pc.addBorderCols("VIERNES",1,2);
		pc.addBorderCols("SABADO",1,2);
		pc.addBorderCols("DOMINGO",1,2);
		pc.addBorderCols("TOTAL",1,2);


	//pc.addTable();
	pc.copyTable("detailHeader");

	if(!tipo.trim().equals("3")){
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",0);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
		pc.addBorderCols("S",1);
		pc.addBorderCols("D",1);
	}else
	{

	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",0);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);
		pc.addBorderCols("S",1,2);
		//pc.addBorderCols("D",1);

	}
	pc.copyTable("detailHeader1");


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
			{
				pc.setNoColumnFixWidth(setDetail1);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
				if(!tipo.trim().equals("3"))
					pc.addCols("MES ------------------------------- ",0,1,cHeight);
					else pc.addCols("  ",0,1,cHeight);
					pc.addCols(" "+cdo.getColValue("desc_almacen"),1,1,cHeight);
					pc.addCols("SEMANA # "+semana,2,1,cHeight);
				pc.addTable();
				//pc.addCopiedTable("detailHeader");
				//lCounter++;
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("keyType")))
			{
					pc.setNoColumnFixWidth(setDetail1);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
					if(!tipo.trim().equals("3"))
						pc.addCols("DEL----------------- AL ----------------",0,1,cHeight);
					else pc.addCols("  ",0,1,cHeight);
						pc.addCols(" "+cdo.getColValue("dsp_tipo_solicitud"),1,1,cHeight);
						pc.addCols(" ",2,1,cHeight);
					pc.addTable();
					pc.setNoColumnFixWidth(setDetail);
					if(i==0)
					{
						pc.addCopiedTable("detailHeader");
						pc.addCopiedTable("detailHeader1");
					}
			}
			if (!familyCode.equalsIgnoreCase(cdo.getColValue("cod_familia")))
			{
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addBorderCols(" "+cdo.getColValue("desc_familia"),0,setDetail.size(),cHeight);
					pc.addTable();
					lCounter++;
			}
			if (!classCode.equalsIgnoreCase(cdo.getColValue("classCode")))
			{
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,setDetail.size(),cHeight);
					pc.addTable();
					lCounter++;
			}


			if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "REQUISICION DE MATERIALES", "", userName, fecha);

			pc.setNoColumnFixWidth(setDetail1);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					if(!tipo.trim().equals("3"))
					pc.addCols("MES ------------------------------- ",0,1,cHeight);
					else pc.addCols(" ",0,1,cHeight);
					pc.addCols(" "+cdo.getColValue("desc_almacen"),1,1,cHeight);
					pc.addCols("SEMANA # "+semana,2,1,cHeight);
				pc.addTable();

			  pc.setNoColumnFixWidth(setDetail1);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
					if(!tipo.trim().equals("3"))
						pc.addCols("DEL----------------- AL ----------------",0,1,cHeight);
						else pc.addCols(" ",0,1,cHeight);
						pc.addCols(" "+cdo.getColValue("dsp_tipo_solicitud"),1,1,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();
					pc.setNoColumnFixWidth(setDetail);

				pc.addCopiedTable("detailHeader");
				pc.addCopiedTable("detailHeader1");

				pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("desc_familia"),0,setDetail.size(),cHeight);
				pc.addTable();
				pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,setDetail.size(),cHeight);
				pc.addTable();
		}



		pc.setNoColumnFixWidth(setDetail);
		pc.setFont(6, 0);


		if(!tipo.trim().equals("3")){
		pc.createTable();
			pc.addBorderCols(""+cdo.getColValue("codigo_articulo"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cod_medida"),1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia1")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia2")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia3")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia4")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia5")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia6")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia7")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),1,1,cHeight);
			pc.addBorderCols(" ",1,1,cHeight);
			pc.addTable();
		}
		else
		{
			pc.createTable();
			pc.addBorderCols(""+cdo.getColValue("codigo_articulo"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cod_medida"),1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia1")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia2")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia3")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia4")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia5")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia6")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad_dia7")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),1,2,cHeight);
			//pc.addBorderCols(" ",1,1,cHeight);
			pc.addTable();
		}

		lCounter++;

		groupBy     = cdo.getColValue("codigo_almacen");
		subGroupBy  = cdo.getColValue("keyType");
		familyCode  = cdo.getColValue("cod_familia");
		classCode   = cdo.getColValue("classCode");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>