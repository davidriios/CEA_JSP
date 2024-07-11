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
		REPORTE:		 inv0031, inv0031_cont, inv0031_hist, inv00119, inv00119_cont, inv00119_hist
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
String sql = "",sql2 = "";
String appendFilter ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");

String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");

String almacen = request.getParameter("almacen");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String tipo = request.getParameter("tipo");
String existencia = request.getParameter("existencia");

String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String reporte = request.getParameter("reporte");
String descripcion = request.getParameter("descripcion");
String consignacion = request.getParameter("consignacion");
String anaquel = request.getParameter("anaquel");
String anaquelHasta = request.getParameter("anaquelHasta");

String fg = request.getParameter("fg");
String fp = "",tr="",type="",descTitulo="" ;
String tables = "";

if(almacen== null) almacen = "";
if(familia== null) familia = "";
if(clase== null) clase = "";
if(articulo== null) articulo = "";
if(tipo== null) tipo = "";
if(existencia== null) existencia = "";
if(anio== null) anio = "";
if(mes== null) mes = "";
if(reporte== null) reporte = "";
if(descripcion== null) descripcion = "";
if(consignacion== null) consignacion = "";
if(anaquel==null)anaquel="";
if(anaquelHasta==null)anaquelHasta="";

/*
existencia   FP    Tipo reporte  reporte         Resumen           TR
-----------------------------------------------------------------------
 S           CE    C             inv0031         flia nivel        CN   --
 S           CEC   F             inv0031_cont    centro servicio   CCS  --
 N           SE    C             inv00119        no tiene          ---  --
 N           SEC   F             inv00119_cont   centro servicio   CCS  --
 S           CEH   C             inv0031_hist    flia nivel        CN
 N           SEH   C             inv00119_hist   no tiene          ---
-----------------------------------------------------------------------
*/
			 if(fg.trim().equals("RI") && existencia.trim().equals("S")) fp ="CE";
	else if(fg.trim().equals("RI") && existencia.trim().equals("N")) fp ="SE";
	else if(fg.trim().equals("RC") && existencia.trim().equals("S")) fp ="CEC";
	else if(fg.trim().equals("RC") && existencia.trim().equals("N")) fp ="SEC";
	else if(fg.trim().equals("RH") && existencia.trim().equals("S")) fp ="CEH";
	else if(fg.trim().equals("RH") && existencia.trim().equals("N")) fp ="SEH";


	if(fp.trim().equals("CE") || fp.trim().equals("CEH")) tr = "CN";
	else if(fp.trim().equals("CEC") || fp.trim().equals("SEC")) tr = "CCS";

	if(existencia.trim().equals("S") && reporte.trim().equals("C")) appendFilter += " and i.disponible > 0 /*and consignacion_sino = 'N'*/";
	else if(existencia.trim().equals("S") && reporte.trim().equals("F")) appendFilter += " and i.disponible > 0 and exists (select null from tbl_inv_familia_articulo fa where fa.compania = ar.compania and fa.cod_flia = ar.cod_flia and fa.tipo_servicio in ('02','03','04')) /*and  fa.nivel in (041,042,040,044) and consignacion_sino = 'N'*/ ";
	else if(existencia.trim().equals("N")) appendFilter += " and i.disponible <= 0  and  ar.tipo not like 'A' and ar.estado like 'A' /*and ar.cod_flia not in (31)*/ ";

	if(existencia.trim().equals("N") && reporte.trim().equals("F")) appendFilter += " and exists (select null from tbl_inv_familia_articulo fa where fa.compania = ar.compania and fa.cod_flia = ar.cod_flia and fa.tipo_servicio in ('02','03','04')) /*and fa.nivel in (041,042,040,044)*/  ";


	if(!almacen.trim().equals("")) appendFilter += " and i.codigo_almacen = "+almacen;
	if(!familia.trim().equals("")) appendFilter += " and i.art_familia = "+familia;
	if(!clase.trim().equals(""))   appendFilter += " and i.art_clase = "+clase;
	if(!articulo.trim().equals(""))appendFilter += " and i.cod_articulo = "+articulo;
	if(!anaquel.trim().equals(""))appendFilter += " and i.codigo_anaquel >= "+anaquel;
	if(!anaquelHasta.trim().equals(""))appendFilter += " and i.codigo_anaquel <= "+anaquelHasta;

	if(!tipo.trim().equals(""))    appendFilter += " and ar.tipo = '"+tipo+"'";
	if(!consignacion.trim().equals(""))    appendFilter += " and ar.consignacion_sino = '"+consignacion+"'";
	if(fp.trim().equals("CEH") || fp.trim().equals("SEH"))
	{
	 tables = " tbl_inv_inventario_hist i ,";
	 if(!mes.trim().equals(""))    appendFilter += "and i.mes = "+mes;
	 if(!anio.trim().equals(""))   appendFilter += "and i.anio = "+anio;
	 if(existencia.trim().equals("S")) descTitulo ="REPORTE FINAL DE ARTICULOS CON EXISTENCIA AL MES  "+mes+"   --  "+anio;
		else descTitulo ="REPORTE FINAL DE ARTICULOS SIN EXISTENCIA AL MES  "+mes+"   --  "+anio;
	}else tables = " tbl_inv_inventario i ,";


sql = "select 'A' type, al.codigo_almacen , al.descripcion desc_almacen, ar.cod_flia , (select fa.nombre from tbl_inv_familia_articulo fa where ar.compania = fa.compania AND ar.cod_flia = fa.cod_flia) desc_familia, ar.cod_clase , (select cla.descripcion from tbl_inv_clase_articulo cla where ar.compania = cla.compania and ar.cod_flia = cla.cod_flia AND ar.cod_clase = cla.cod_clase) desc_clase, ar.cod_articulo cod_articulo, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo codigo, ar.descripcion desc_articulo, nvl(i.disponible,0) existencia, nvl(i.precio,0) costo, nvl(i.ultimo_precio,0) ultimo_costo, nvl(i.disponible,0)*nvl(i.precio,0) total_articulo from "+tables+"  tbl_inv_articulo ar, /*tbl_inv_clase_articulo cla, tbl_inv_familia_articulo fa,*/ tbl_inv_almacen al where ((i.compania = ar.compania /*and i.art_familia = ar.cod_flia and i.art_clase = ar.cod_clase*/ and i.cod_articulo = ar.cod_articulo) /*and (ar.compania = cla.compania and ar.cod_flia = cla.cod_flia and ar.cod_clase = cla.cod_clase) and (ar.compania = fa.compania and ar.cod_flia = fa.cod_flia)*/ and (i.compania = al.compania and i.codigo_almacen    = al.codigo_almacen))   and i.compania ="+compania+"                          "+appendFilter+"                                          ";

sql2 =" select 'FA' type,codigo_almacen ,  desc_almacen, codigo_almacen||'-'||cod_flia codigo,  desc_familia, sum(nvl(total_articulo,0)) total  from( "+sql+") group by codigo_almacen ,  desc_almacen, codigo_almacen||'-'||cod_flia ,  desc_familia   union select 'CL'type, codigo_almacen ,  desc_almacen, codigo_almacen||'-'||cod_clase ,  desc_clase, sum(nvl(total_articulo,0)) total  from( "+sql+") group by codigo_almacen ,  desc_almacen, codigo_almacen||'-'||cod_clase ,  desc_clase   	union  select 'AL' type, codigo_almacen ,  desc_almacen, ''||codigo_almacen , ' ', sum(nvl(total_articulo,0)) total  from( "+sql+") group by codigo_almacen ,  desc_almacen  order by 1 ";
if(tr.trim().equals("CN"))
sql += " union select 'B' type,0,' ',0,' ',0,' ',0,'0',' ',0,0,0,0 from dual  union  select 'C' type,0,' ',0,' ',0,' ',0, (select to_char(fa.nivel) from tbl_inv_familia_articulo fa where ar.compania = fa.compania AND ar.cod_flia = fa.cod_flia) nivel,' ',0,0,0, sum(nvl(i.disponible,0)*nvl(i.precio,0)) costototal  from "+tables+"  tbl_inv_articulo ar , /*tbl_inv_clase_articulo cla , tbl_inv_familia_articulo fa ,*/ tbl_inv_almacen al where ((i.compania = ar.compania /*and i.art_familia = ar.cod_flia and i.art_clase = ar.cod_clase*/ and i.cod_articulo = ar.cod_articulo) /*and (ar.compania = cla.compania and ar.cod_flia = cla.cod_flia and ar.cod_clase = cla.cod_clase) and (ar.compania = fa.compania and ar.cod_flia = fa.cod_flia)*/ and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen))  and i.compania = "+compania+appendFilter+" group by ar.compania, ar.cod_flia ";

else if(tr.trim().equals("CCS"))
sql +=" union  select 'B' type,0 almacen,' 'desc_almacen,0 flia,'  'desflia,0 clase,' ' des_cla,0 articulo,'0' codigo,' ' desc_tipo ,0,0,0,0 from dual union select 'D' type, al.codigo_almacen cod_almacen, al.descripcion,0,' ',0,' ',0, (select fa.tipo_servicio from tbl_inv_familia_articulo fa where ar.compania = fa.compania AND ar.cod_flia = fa.cod_flia) tipo_servicio, (select (select cs.descripcion from tbl_cds_tipo_servicio cs where fa.tipo_servicio  = cs.codigo) from tbl_inv_familia_articulo fa where ar.compania = fa.compania AND ar.cod_flia = fa.cod_flia) desc_tipo_serv,0,0,0, sum(nvl(i.disponible,0)*nvl(i.precio,0)) existencia from  "+tables+" tbl_inv_articulo ar, tbl_inv_almacen al where  ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) ) and (i.compania = al.compania and i.codigo_almacen = al.codigo_almacen) and i.compania ="+compania+appendFilter+"  /*and i.codigo_almacen = nvl ( :p_cod_almacen, al.compania) and i.art_familia = nvl ( :pcod_familia, fa.cod_flia) and i.art_clase = nvl ( :pcod_clase, cla.cod_clase) and i.cod_articulo = nvl ( :p_codarticulo, ar.cod_articulo) and ar.tipo = nvl ( :p_cod_tipo, ar.tipo))*/  group by al.codigo_almacen , /*cs.descripcion,*/al.descripcion, ar.compania, ar.cod_flia ";


sql +=" order by 1,2,3,5,7,10 ";

al = SQLMgr.getDataList(sql);


alTotal = SQLMgr.getDataList(sql2);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double total_nivel = 0.00;
	Hashtable htWh = new Hashtable();
	Hashtable htFamily = new Hashtable();

	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);

		if(cdo.getColValue("type").trim().equals("AL"))
		{
			htWh.put(cdo.getColValue("codigo"),cdo.getColValue("total"));
			lineFill+=4;
		}
		else if(cdo.getColValue("type").trim().equals("FA"))
		{
			htFamily.put(cdo.getColValue("codigo"),cdo.getColValue("total"));
			lineFill+=3;
		}
		else if(cdo.getColValue("type").trim().equals("CL"))
		{
			lineFill++;
		}
	}

	int nItems = al.size() + lineFill;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;
System.out.println("nItems == "+nItems+" nPage ="+nPages+"  lineFill  "+lineFill);

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_articulos_c_S_existencia";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+System.currentTimeMillis()+".pdf";
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
		setDetail.addElement(".10");
		setDetail.addElement(".30");
		setDetail.addElement(".15");
		setDetail.addElement(".15");
		setDetail.addElement(".15");
		setDetail.addElement(".15");

	String groupBy = "",subGroupBy = "",groupByClass ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, " "+depto, " "+titulo, userName, fecha);


	if(fp.trim().equals("CEH") ||fp.trim().equals("SEH"))
	{

		pc.createTable();
			pc.setFont(7, 1);
			pc.addCols(" "+descripcion,1,6);
		pc.addTable();
		pc.copyTable("detailHeader2");

		pc.createTable();
			pc.setFont(7, 1);
			pc.addCols(" "+descTitulo,1,6);
		pc.addTable();
		pc.copyTable("detailHeader3");
	}


	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("COSTO",1);
		pc.addBorderCols("ULTIMO COSTO",1);
		pc.addBorderCols("TOTAL",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("TIPO DE SERVICIO",1);
		pc.addBorderCols("DESCRIPCION",0);
		pc.addBorderCols("TOTAL",1);
		pc.addCols(" ",1,3);
	//pc.addTable();
	pc.copyTable("detailHeader4");


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
			if(cdo.getColValue("type").trim().equals("A"))
			{
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")))
			{

				if (i != 0)
				{
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("SubTotal por Familia:  $"+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,setDetail.size());
					pc.addTable();
					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("  ",0,setDetail.size());
					pc.addTable();
					lCounter+=2;
				}

			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
			{

				if (i != 0)
				{
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("Total por almacen:  $"+CmnMgr.getFormattedDecimal((String) htWh.get(groupBy)),2,setDetail.size());
					pc.addTable();
					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("  ",0,setDetail.size());
					pc.addTable();
					lCounter+=2;
				}
			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen"))&& lCounter+2 <= maxLines)
			{
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("[ "+cdo.getColValue("desc_almacen")+" ] ",1,setDetail.size(),cHeight);
				pc.addTable();
				pc.addCopiedTable("detailHeader");

				lCounter+=2;

			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia"))&& lCounter+1 <= maxLines )
			{
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
					pc.addCols(" "+cdo.getColValue("desc_familia"),1,setDetail.size(),cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
					pc.addTable();

					lCounter++;
			}
			if (!groupByClass.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase"))&& lCounter+1 <= maxLines)
			{
					pc.setFont(7, 1,Color.red);
					pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,setDetail.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
					pc.addTable();//cHeight);

					lCounter++;
			}
		}

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+depto, " "+titulo, userName, fecha);

			if(fp.trim().equals("CEH") ||fp.trim().equals("SEH"))
			{
				pc.addCopiedTable("detailHeader2");
				pc.addCopiedTable("detailHeader3");
			}

			pc.setNoColumnFixWidth(setDetail);
			if(cdo.getColValue("type").trim().equals("A"))
		  {
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("[ "+cdo.getColValue("desc_almacen")+" ] ",1,setDetail.size(),cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols(" "+cdo.getColValue("desc_familia"),1,setDetail.size(),cHeight);
					pc.addTable();
					pc.setFont(7, 1,Color.red);
						pc.createTable();
						pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,setDetail.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
					pc.addTable();//cHeight);
			  }
				else if(cdo.getColValue("type").trim().equals("C"))
		  	{

					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("[ RESUMEN DE EXISTENCIA POR NIVEL ] ",1,2,cHeight);
						pc.addCols(" ",1,4,cHeight);
					pc.addTable();

				}
				else  if(cdo.getColValue("type").trim().equals("D"))
				{
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("[ RESUMEN DE EXISTENCIA POR SERVICIOS ] ",1,3,cHeight);
						pc.addCols(" ",1,3,cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader4");

				}
		}
		if(cdo.getColValue("type").trim().equals("A"))
		{
				pc.setFont(6, 0);
				pc.createTable();
					pc.addCols(""+cdo.getColValue("codigo"),1,1,cHeight);
					pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
					pc.addCols(""+cdo.getColValue("existencia"),1,1,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo")),2,1,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("ultimo_costo")),2,1,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("total_articulo")),2,1,cHeight);
				pc.addTable();
				lCounter++;
				groupBy      = cdo.getColValue("codigo_almacen");
				subGroupBy   = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia");
				groupByClass = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase");

			}
			else if(cdo.getColValue("type").trim().equals("B"))
			{
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("SubTotal por Familia:  $"+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,setDetail.size());
					pc.addTable();
					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("  ",0,setDetail.size());
					pc.addTable();
					lCounter+=2;

					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("Total por almacen:  $"+CmnMgr.getFormattedDecimal((String) htWh.get(groupBy)),2,setDetail.size());
					pc.addTable();
					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("  ",0,setDetail.size());
					pc.addTable();
					lCounter+=3;
					type=cdo.getColValue("type");
			}else if(cdo.getColValue("type").trim().equals("C"))
			{
				if(type.trim().equals("B"))
				{
					pc.createTable();
						pc.setFont(7, 1,Color.blue);
						pc.addCols("[ RESUMEN DE EXISTENCIA POR NIVEL ] ",1,2,cHeight);
						pc.addCols(" ",1,4,cHeight);
					pc.addTable();
				}
				pc.setFont(6, 0);
				pc.createTable();
					pc.addCols(""+cdo.getColValue("codigo"),1,1,cHeight);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_articulo")),2,1,cHeight);
					pc.addCols(" ",1,4,cHeight);
				pc.addTable();
				lCounter++;
				total_nivel += Double.parseDouble(cdo.getColValue("total_articulo"));

			}
		  else if(cdo.getColValue("type").trim().equals("D"))
			{
				if(type.trim().equals("B"))
				{
						pc.createTable();
							pc.setFont(7, 1,Color.blue);
							pc.addCols("[ RESUMEN DE EXISTENCIA POR SERVICIOS ] ",1,3,cHeight);
						pc.addCols(" ",1,3,cHeight);
						pc.addTable();
						pc.addCopiedTable("detailHeader4");
				}
						pc.setFont(6, 0);
						pc.createTable();
							pc.addCols(""+cdo.getColValue("codigo"),1,1,cHeight);
							pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
							pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_articulo")),2,1,cHeight);
							pc.addCols(" ",1,3,cHeight);
						pc.addTable();
						lCounter++;
						total_nivel += Double.parseDouble(cdo.getColValue("total_articulo"));

			}

		type = cdo.getColValue("type");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		     if(type.trim().equals("A"))
			   {
					 pc.createTable();
							pc.setFont(7, 1,Color.blue);
							pc.addCols("SubTotal por Familia :  "+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,setDetail.size());
						pc.addTable();
						pc.createTable();
							pc.setFont(7, 1,Color.blue);
							pc.addCols("Total por almacen:  "+CmnMgr.getFormattedDecimal((String) htWh.get(groupBy)),2,setDetail.size());
						pc.addTable();
						lCounter+=2;
				 }
				 else if(type.trim().equals("C"))
			   {
						pc.createTable();
							pc.setFont(7, 1,Color.blue);
							pc.addCols("Gran Total :  ",2,1,cHeight);
							pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total_nivel),2,1,cHeight);
							pc.addCols(" ",2,4,cHeight);
						pc.addTable();
					}
					else if(type.trim().equals("D"))
			    {
						pc.createTable();
							pc.setFont(7, 1,Color.blue);
							pc.addCols("Gran Total :  ",2,1,cHeight);
							pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.000",""+total_nivel),2,2,cHeight);
							pc.addCols(" ",2,3,cHeight);
						pc.addTable();
					}


		}




	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>