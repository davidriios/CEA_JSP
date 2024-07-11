<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" /> 
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" /> 
<jsp:useBean id="vCentro" scope="session" class="java.util.Vector" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/**
=============================================================== 
INV00140.RDF    DETALLE DE CARGOS DE LECHES POR UNIDAD A PACIENTES   FG = CD
INV00125.RDF    CARGOS DE LECHES POR UNIDAD A PACIENTES				 FG = CP
=============================================================== 
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
CommonDataObject cd1 = null;
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String fg = request.getParameter("fg");
String compania =  compania = (String) session.getAttribute("_companyId");
String titulo ="", appendFilter1 ="";

if (fDate == null) fDate = "";
if (tDate == null) tDate = "";
if (fg == null) fg = "CP";

if (appendFilter == null) appendFilter = "";

if(!fDate.trim().equals("")) 
appendFilter += " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fDate+"','dd/mm/yyyy')";
if(!tDate.trim().equals("")) 
appendFilter += " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+tDate+"','dd/mm/yyyy')";



if(fg.trim().equals("CP")) 
{
titulo =" CARGOS DE LECHES POR UNIDAD A PACIENTES ";
appendFilter += " and de.cod_familia in (27, 28)";


sql="select em.unidad_administrativa as codUnidad, cs.descripcion as descUnidad, ar.descripcion descArticulo, sum(de.cantidad) as unidades, sum(nvl(de.cantidad,0) * nvl(de.precio,0)) as totales from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo ar, tbl_cds_centro_servicio cs where em.req_anio is  null and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = ar.cod_flia and de.cod_clase = ar.cod_clase and de.cod_articulo = ar.cod_articulo) and (em.unidad_administrativa = cs.codigo and em.compania_sol = cs.compania_unorg) and em.compania = "+compania+appendFilter+"  group by em.unidad_administrativa, cs.descripcion, ar.descripcion order by em.unidad_administrativa asc, cs.descripcion asc, ar.descripcion asc";

al = SQLMgr.getDataList(sql);

sql="select em.unidad_administrativa as codUnidad, cs.descripcion as descUnidad, sum(nvl(de.cantidad,0) * nvl(de.precio,0)) as totales,0 total_calculado  from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo ar, tbl_cds_centro_servicio cs where em.req_anio is  null and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = ar.cod_flia and de.cod_clase = ar.cod_clase and de.cod_articulo = ar.cod_articulo) and (em.unidad_administrativa = cs.codigo and em.compania_sol = cs.compania_unorg) and em.compania = "+compania+appendFilter+" group by em.unidad_administrativa, cs.descripcion order by em.unidad_administrativa asc, cs.descripcion asc";


alTotal = SQLMgr.getDataList(sql);
}
else if(fg.trim().equals("CD"))
{ 
titulo =" DETALLE DE CARGOS DE LECHES POR UNIDAD A PACIENTES  ";
if(!fDate.trim().equals("")) 
appendFilter1 += " and to_date(to_char(dev.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fDate+"','dd/mm/yyyy')";
if(!tDate.trim().equals("")) 
appendFilter1 += " and to_date(to_char(dev.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+tDate+"','dd/mm/yyyy')";

sql=" select x.* from (  select 'C' type, em.unidad_administrativa as codUnidad, cs.descripcion as descUnidad, ar.descripcion descArticulo, em.pac_id, ap.primer_nombre||' '||NVL(ap.primer_apellido,ap.apellido_de_casada)  as nombre, sum(de.cantidad) as unidades, sum(nvl(de.cantidad,0) * nvl(de.precio,0)) as totales, sum( nvl(de.cantidad,0) * nvl((de.precio*100)/120,0) ) total_calculado ,0  totalCosto  from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo ar, tbl_cds_centro_servicio cs, tbl_adm_paciente ap where em.req_anio is  null and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = ar.cod_flia and de.cod_clase = ar.cod_clase and de.cod_articulo = ar.cod_articulo) and (em.unidad_administrativa = cs.codigo and em.compania_sol = cs.compania_unorg) and em.compania = "+compania+appendFilter+" and  de.cod_familia in (27, 28,36) and em.pac_id=ap.pac_id(+) group by 'C', em.unidad_administrativa, cs.descripcion, ar.descripcion, em.pac_id, ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada),0       union              select 'D' type, dev.sala_cod,          cs.descripcion,  ar.descripcion desc_articulo,  dev.pac_id, ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada) nombre,sum(dp.cantidad) *-1 unidades, sum( nvl(dp.cantidad,0)*-1 * nvl(dp.precio,0) ) totales, trunc(sum(dp.cantidad *-1* nvl((dp.precio*100)/120, 0)) ,2) totalcalculado, sum( nvl(dp.cantidad,0)*-1 * nvl(dp.costo,0) ) totalcosto from   tbl_inv_devolucion_pac dev , tbl_inv_detalle_paciente dp , tbl_inv_inventario i , tbl_inv_articulo ar , tbl_cds_centro_servicio cs , tbl_adm_paciente ap where  dev.codigo_almacen  = 4 and dev.compania = "+compania+appendFilter1+" and dp.cod_familia in (27, 28 , 36)   and dev.sala_cod <>3 and (dev.anio = dp.anio_devolucion and dev.num_devolucion = dp.num_devolucion and dev.compania = dp.compania) and (dp.compania = i.compania and dp.cod_familia = i.art_familia and dp.cod_clase = i.art_clase and dp.cod_articulo = i.cod_articulo) and i.codigo_almacen   = dev.codigo_almacen and (dp.cod_familia = ar.cod_flia and dp.cod_clase = ar.cod_clase and dp.cod_articulo = ar.cod_articulo) and (dev.sala_cod  = cs.codigo and dev.compania= cs.compania_unorg) and dev.pac_id = ap.pac_id group by dev.sala_cod, cs.descripcion,   ar.descripcion, dev.pac_id,ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada) order by  1, 2, 3,4  ) x order by x.codUnidad,x.descunidad,x.type, descArticulo"; 
					   
al = SQLMgr.getDataList(sql);

sql=" select x.codUnidad,x.descUnidad ,sum(x.totales) totales, sum(x.total_calculado) total_calculado from (  select 'C' type, em.unidad_administrativa as codUnidad, cs.descripcion as descUnidad, ar.descripcion descArticulo, em.pac_id, ap.primer_nombre||' '||NVL(ap.primer_apellido,ap.apellido_de_casada)  as nombre, sum(de.cantidad) as unidades, sum(nvl(de.cantidad,0) * nvl(de.precio,0)) as totales, sum( nvl(de.cantidad,0) * nvl((de.precio*100)/120,0) ) total_calculado ,0  totalCosto  from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo ar, tbl_cds_centro_servicio cs, tbl_adm_paciente ap where em.req_anio is  null and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = ar.cod_flia and de.cod_clase = ar.cod_clase and de.cod_articulo = ar.cod_articulo) and (em.unidad_administrativa = cs.codigo and em.compania_sol = cs.compania_unorg) and em.compania = "+compania+appendFilter+" and  de.cod_familia in (27, 28,36) and em.pac_id=ap.pac_id(+) group by 'C', em.unidad_administrativa, cs.descripcion, ar.descripcion, em.pac_id, ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada),0       union              select 'D' type, dev.sala_cod,          cs.descripcion,  ar.descripcion desc_articulo,  dev.pac_id, ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada) nombre,sum(dp.cantidad) *-1 unidades, sum( nvl(dp.cantidad,0)*-1 * nvl(dp.precio,0) ) totales, trunc(sum(dp.cantidad *-1* nvl((dp.precio*100)/120, 0)) ,2) totalcalculado, sum( nvl(dp.cantidad,0)*-1 * nvl(dp.costo,0) ) totalcosto from   tbl_inv_devolucion_pac dev , tbl_inv_detalle_paciente dp , tbl_inv_inventario i , tbl_inv_articulo ar , tbl_cds_centro_servicio cs , tbl_adm_paciente ap where  dev.codigo_almacen  = 4 and dev.compania = "+compania+appendFilter1+" and dp.cod_familia in (27, 28 , 36)   and dev.sala_cod <>3 and (dev.anio = dp.anio_devolucion and dev.num_devolucion = dp.num_devolucion and dev.compania = dp.compania) and (dp.compania = i.compania and dp.cod_familia = i.art_familia and dp.cod_clase = i.art_clase and dp.cod_articulo = i.cod_articulo) and i.codigo_almacen   = dev.codigo_almacen and (dp.cod_familia = ar.cod_flia and dp.cod_clase = ar.cod_clase and dp.cod_articulo = ar.cod_articulo) and (dev.sala_cod  = cs.codigo and dev.compania= cs.compania_unorg) and dev.pac_id = ap.pac_id group by dev.sala_cod, cs.descripcion,   ar.descripcion, dev.pac_id,ap.primer_nombre||' '||nvl(ap.primer_apellido,ap.apellido_de_casada) order by  1, 2, 3,4  ) x group by x.codUnidad,x.descUnidad order by x.codUnidad,x.descunidad  ";


alTotal = SQLMgr.getDataList(sql);

}





if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 50; //max lines of items
	int nItems = al.size() + alTotal.size()*4; //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";  
	String fileNamePrefix = "print_list_cargo_paciente";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
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
	
	Hashtable htCentro = new Hashtable();
	Hashtable htInsumo = new Hashtable();
	
	vCentro.clear();
	double totRep =0.00 ;
    double totPago =0 ;
    double totInsumo =0 ;
    double totales =0.00 ,totales_costo =0.00;
    String centro="";
    String codIns="";
		int cInsumo =0;
		int cantidad =0;
	
	for(int z=0;z<alTotal.size();z++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(z);
		
			htCentro.put(cdo.getColValue("codUnidad"),cdo);
			totRep += Double.parseDouble(cdo.getColValue("totales"));
			totales_costo += Double.parseDouble(cdo.getColValue("total_calculado"));
	}
	
		
		
	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".33");
		setDetail.addElement(".33");
		setDetail.addElement(".10");
		setDetail.addElement(".12");
		setDetail.addElement(".12");
	
				
	String groupBy = "";
	String paciente = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, ""+titulo,"DEL "+fDate+ " AL "+tDate, userName, fecha);
	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols("",0,setDetail.size());
	pc.addTable();
			
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	pc.setFont(8, 3, Color.blue);
	if(fg.trim().equals("CP")) 
	{
	pc.addBorderCols("Descripción",0,2);
	pc.addBorderCols("Unidades",1,1);
	pc.addBorderCols("Monto",2,2);
	
	}
	else
	{
	pc.addBorderCols("Nombre del Paciente",0,1);
	pc.addBorderCols("Descripción",0,1);
	pc.addBorderCols("Unidades",1,1);
	pc.addBorderCols("Monto",2,1);
	pc.addBorderCols("Costo*",2,1);
	
	}
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codUnidad")))
			{
					
			if (i != 0)
				{
				cd1 = (CommonDataObject) htCentro.get(groupBy);
							
				if (fg.trim().equals("CP"))
				{
					pc.createTable();
					pc.setFont(8,1, Color.blue);
						pc.addCols("Sub-Total :  ",2,3);
						pc.setFont(8, 4, Color.blue);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("totales")),2,2);
					pc.addTable();
				}
				else
				{
					pc.createTable();
					pc.setFont(8,1, Color.blue);
						pc.addCols("Sub-Total :  ",2,3);
						pc.setFont(8, 4, Color.blue);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("totales")),2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("total_calculado")),2,1);
					pc.addTable();
				}
				
				pc.createTable();
				pc.setFont(9, 1);
				pc.addCols("",0,setDetail.size());
				pc.addTable();
				
				
				lCounter+=2;
				}
			}
			
			
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codUnidad")))
			{
			pc.setFont(8, 1, Color.blue);
			pc.createTable();
			pc.addCols(""+cdo.getColValue("codUnidad")+"     "+cdo.getColValue("descUnidad"),0,5);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			lCounter+=2;
			}
			
		pc.setFont(7, 0);
		pc.createTable();
			if (fg.trim().equals("CP"))
			{
			pc.addCols(""+cdo.getColValue("descArticulo"),0,2,cHeight);
			pc.addCols(""+cdo.getColValue("unidades"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totales")),2,2,cHeight);
			}
			else
			{
			paciente = cdo.getColValue("nombre");
			if (paciente.trim().equals(""))  paciente = "PACIENTE"; 
			//if (cdo.getColValue("nombre") == "")  paciente = "Paciente"; 
			pc.addCols(""+paciente,0,1,cHeight);
		    pc.addCols(""+cdo.getColValue("descArticulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("unidades"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("totales")),2,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total_calculado")),2,1,cHeight);
			}
		
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			if (fg.trim().equals("CD"))
			{
			pc.setFont(5, 3);
			pc.createTable();
			pc.addCols("",0,setDetail.size());
			pc.addTable();
			
			pc.setFont(5, 3,Color.blue);
			pc.createTable();
			pc.addCols(" *  Costo calculado a partir del precio",0,setDetail.size());
			pc.addTable();
			}
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();
       	pdfHeader(pc, _comp, pCounter, nPages, ""+titulo,"DEL "+fDate+ " AL "+tDate, userName, fecha);
 		pc.setNoColumnFixWidth(setDetail);
	
			pc.createTable();
			pc.setFont(9, 1);
			pc.addCols("",0,setDetail.size());
			pc.addTable();
	
			pc.setFont(9, 1, Color.blue);
			pc.createTable();
			pc.addCols(""+cdo.getColValue("codUnidad")+"     "+cdo.getColValue("descUnidad"),0,5);
			pc.addTable();
	
			pc.addCopiedTable("detailHeader");
		}

		groupBy = cdo.getColValue("codUnidad");

		
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		
		cd1 = (CommonDataObject) htCentro.get(groupBy);
							
				if (fg.trim().equals("CP"))
				{
					pc.createTable();
					pc.setFont(8,1, Color.blue);
						pc.addCols("Sub-Total :  ",2,3);
						pc.setFont(8, 4, Color.blue);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("totales")),2,2);
					pc.addTable();
				}
				else
				{
					pc.createTable();
					pc.setFont(8,1, Color.blue);
						pc.addCols("Sub-Total :  ",2,3);
						pc.setFont(8, 4, Color.blue);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("totales")),2,1);
						pc.addCols(""+CmnMgr.getFormattedDecimal(cd1.getColValue("total_calculado")),2,1);
					pc.addTable();
				}
		
		pc.createTable();
				pc.setFont(9, 1);
				pc.addCols("",0,setDetail.size());
			pc.addTable();
		if (fg.trim().equals("CP"))
		{
			pc.createTable();
				pc.setFont(8, 1);
				pc.addCols("TOTAL :    ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totRep),2,2);
			pc.addTable();
		}
		else
		{
		
			pc.createTable();
				pc.setFont(8, 1);
				pc.addCols("TOTAL :    ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totRep),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totales_costo),2,1);
			pc.addTable();
		
		}

		
		
		
		
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>