<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
		REPORTE:		INV0073.RDF     REQUISICIONES DE UNIDADES ADMINISTRATIVAS
						INV0045.RDF     REQUISICION DE UNIDADES DESDE LS ENTREGAS    TR = RQ
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
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String estado = request.getParameter("estado");
String tipo = request.getParameter("tipo");// tipo solicitud
String tr = request.getParameter("tr");//
String fg= request.getParameter("fg");//

int nGroup =0,nSubGroup =0;

if (appendFilter == null) appendFilter = "";
if (almacen == null) almacen = "";
if (estado == null) estado = "";
if (anio == null) anio = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (depto == null) depto = "";
if (cod_req == null) cod_req = "";
if (tr == null) tr = "";
if (fg == null) fg = "";
if (tipo == null) tipo = "";

if (almacen == null) throw new Exception("Seleccione Parametros de busqueda (almacen)!!!");

if(!estado.trim().equals("")) appendFilter += " and ds.estado_renglon='"+estado+"'";
//else appendFilter += " and ds.estado_renglon='P'";
if(!anio.trim().equals("")) appendFilter   += " and sr.anio="+anio;
if(!depto.trim().equals("")) appendFilter  += " and ue.codigo="+depto;
if(!cod_req.trim().equals("")) appendFilter+= " and sr.solicitud_no="+cod_req;
if(!tipo.trim().equals("")) appendFilter+= " and sr.tipo_solicitud='"+tipo+"'";

if(!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter+= " and to_date(to_char(sr.fecha_modificacion,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";

if(fg.trim().equals("RUA") &&  !tr.trim().equals("RQ"))
{
 appendFilter+= " and sr.tipo_transferencia = 'U' and sr.estado_solicitud = 'A'  /* and  sr.activa = 'S' and ds.estado_renglon = 'P' */";
if(estado.trim().equals("")) appendFilter += " and ds.estado_renglon = 'P' ";

}
sql = "select all    decode(sr.tipo_solicitud,'D','DIARIA','S','SEMANAL','M','MENSUAL')  req_tipo,   nvl(ds.cantidad,0) cantidad, nvl(ds.despachado,0) recibidos, decode(ds.estado_renglon,'R',0,nvl(ds.cantidad,0) - nvl(ds.despachado,0)) pendiente, sr.anio||'-'||sr.solicitud_no cod_solicitud, to_char(sr.fecha_modificacion,'dd/mm/yyyy') fecha_pedido, to_char(sr.fecha_modificacion,'hh12:mi:ss am') horaAprob, ue.descripcion departamento, ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo cod_articulo, ds.art_familia familia, ds.art_clase clase, ds.cod_articulo articulo, a.descripcion descArticulo, nvl(sr.observacion,' ')  observaciones, sr.usuario_aprob usuario, nvl(ds.estado_renglon,' ') estado, nvl(to_char(i.disponible),'No Inv ') disponible, sr.unidad_administrativa unidad,al.descripcion desc_almacen,decode(ds.estado_renglon,'R',(nvl(ds.cantidad,0) - nvl(ds.despachado,0)),0) as rechazado from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_sec_unidad_ejec ue, tbl_inv_inventario i,tbl_inv_almacen al where (ds.compania_sol=a.compania and ds.art_familia=a.cod_flia and   ds.art_clase=a.cod_clase and ds.cod_articulo=a.cod_articulo) and (ds.compania=sr.compania and ds.solicitud_no=sr.solicitud_no and ds.tipo_solicitud=sr.tipo_solicitud and ds.req_anio=sr.anio) and (sr.compania_sol=ue.compania and sr.unidad_administrativa=ue.codigo) /*and ue.codigo>=1 and ue.codigo<=100 and ue.nivel=3*/ and sr.codigo_almacen="+almacen+" and sr.compania="+compania+appendFilter+" and (i.compania(+)="+compania+" and i.art_familia(+)=ds.art_familia and i.art_clase(+)=ds.art_clase and i.cod_articulo(+)=ds.cod_articulo and i.codigo_almacen(+)="+almacen+") and sr.codigo_almacen = al.codigo_almacen(+) and sr.compania = al.compania(+) order by ue.descripcion, sr.anio desc, sr.solicitud_no desc, a.descripcion";

al = SQLMgr.getDataList(sql);
if(!tr.trim().equals("RQ"))
{
sql = "select count(*) from (select distinct sr.unidad_administrativa from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_sec_unidad_ejec ue, tbl_inv_inventario i,tbl_inv_almacen al where (ds.compania_sol=a.compania and ds.art_familia=a.cod_flia and   ds.art_clase=a.cod_clase and ds.cod_articulo=a.cod_articulo) and (ds.compania=sr.compania and ds.solicitud_no=sr.solicitud_no and ds.tipo_solicitud=sr.tipo_solicitud and ds.req_anio=sr.anio) and (sr.compania=ue.compania and sr.unidad_administrativa=ue.codigo) /*and ue.codigo>=1 and ue.codigo<=100 and ue.nivel=3*/ and sr.codigo_almacen="+almacen+" and sr.compania="+compania+appendFilter+" and (i.compania(+)="+compania+" and i.art_familia(+)=ds.art_familia and i.art_clase(+)=ds.art_clase and i.cod_articulo(+)=ds.cod_articulo and i.codigo_almacen(+)="+almacen+") and sr.codigo_almacen = al.codigo_almacen(+) and sr.compania = al.compania(+) group by sr.unidad_administrativa)";
 nGroup = CmnMgr.getCount(sql);

sql = "select count(*) from (select distinct sr.anio, sr.solicitud_no, sr.unidad_administrativa from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_sec_unidad_ejec ue, tbl_inv_inventario i ,tbl_inv_almacen al where (ds.compania_sol=a.compania and ds.art_familia=a.cod_flia and   ds.art_clase=a.cod_clase and ds.cod_articulo=a.cod_articulo) and (ds.compania=sr.compania and ds.solicitud_no=sr.solicitud_no and ds.tipo_solicitud=sr.tipo_solicitud and ds.req_anio=sr.anio) and (sr.compania=ue.compania and sr.unidad_administrativa=ue.codigo) /*and ue.codigo>=1 and ue.codigo<=100 and ue.nivel=3*/ and sr.codigo_almacen="+almacen+" and sr.compania="+compania+appendFilter+" and (i.compania(+)="+compania+" and i.art_familia(+)=ds.art_familia and i.art_clase(+)=ds.art_clase and i.cod_articulo(+)=ds.cod_articulo and i.codigo_almacen(+)="+almacen+") and sr.codigo_almacen = al.codigo_almacen(+) and sr.compania = al.compania(+) group by sr.anio, sr.solicitud_no, sr.unidad_administrativa)";
 nSubGroup = CmnMgr.getCount(sql);

}
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 0, nItems = 0;
	if(tr.trim().equals("RQ"))
	 maxLines= 48; //max lines of items
	else  maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if(!tr.trim().equals("RQ"))
		nItems = al.size() + (nGroup * 3) + (nSubGroup * 2);
	else nItems = al.size();
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_requisiciones_unidades_adm";
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
		setDetail.addElement(".10");
		setDetail.addElement(".38");
		setDetail.addElement(".10");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
		setDetail.addElement(".10");
		setDetail.addElement(".08");

	Vector setDetail1 = new Vector();
		setDetail1.addElement(".25");
		setDetail1.addElement(".50");
		setDetail1.addElement(".25");


	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	double pendiente = 0.00;
	String title ="";
	if (tr.trim().equals("RQ"))title = "DEPARTAMENTO DE ALMACEN";
	else  title = "PRODUCTOS POR REQUISICION";
	String subtitle = "REQUISICIONES DE UNIDADES ADMINISTRATIVAS";

	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("ESTADO",1);
		pc.addBorderCols("PEDIDO",1);
		pc.addBorderCols("RECIBIDO",1);
		pc.addBorderCols("RECHAZADO",1);
		pc.addBorderCols("PENDIENTE",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_solicitud")))
		{
			if (!tr.trim().equals("RQ"))
			{
				if (i != 0)
				{
					pc.setFont(6, 1,Color.red);
					pc.createTable();
						pc.addCols("OBSERVACION: "+observ,0,setDetail.size(),cHeight);
					pc.addTable();
					lCounter++;
				}
			}
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")))
		{
			if (i != 0 && !tr.trim().equals("RQ"))
			{
				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols("  ",0,setDetail.size());
				pc.addTable();
				lCounter++;
			}

			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("PEDIDO EN:  "+cdo.getColValue("departamento"),0,setDetail.size(),cHeight);
			pc.addTable();
			if(tr.trim().equals("RQ"))
			{
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("DESPACHADO DESDE:  "+cdo.getColValue("desc_almacen"),0,setDetail.size(),cHeight);
				pc.addTable();

				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("REQUISICION NO :",0,1,cHeight);
					pc.addCols(""+cdo.getColValue("cod_solicitud"),0,2,cHeight);
					pc.addCols("TIPO SOLICITUD     "+cdo.getColValue("req_tipo"),1,5,cHeight);

				pc.addTable();

			}else lCounter+=2;

			pc.addCopiedTable("detailHeader");

		}
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_solicitud")))
		{
			if (!tr.trim().equals("RQ"))
			{
					//pc.setNoColumnFixWidth(setDetail1);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("REQUISICION NO :",2,1,cHeight);
					pc.addCols(""+cdo.getColValue("cod_solicitud"),0,1,cHeight);
					pc.addCols("USUARIO APROB. "+cdo.getColValue("usuario"),0,2,cHeight);
					pc.addCols("FECHA APROB.  "+cdo.getColValue("fecha_pedido"),1,2,cHeight);
					pc.addCols(" "+cdo.getColValue("horaAprob"),0,1,cHeight);
				pc.addTable();
				lCounter++;
			}
		}
		pendiente    = Double.parseDouble(cdo.getColValue("pendiente"));

		pc.setFont(6, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("descArticulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("disponible"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("estado"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("recibidos"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("rechazado"),1,1,cHeight);
			if(pendiente >0)
			pc.addCols(""+cdo.getColValue("pendiente"),1,1,cHeight);
			else pc.addCols(" ",1,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			if(tr.trim().equals("RQ"))
			{
			pc.setNoColumnFixWidth(setDetail1);
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" IMPRESO POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" "+userName ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();

			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" DESPACHADO EN ALMACEN POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" ENTREGADO EN DEPARTAMENTO POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" RECIBIDO EN UNIDAD SOLICITANTE POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();
			}
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("PEDIDO EN:  "+cdo.getColValue("departamento"),0,setDetail.size(),cHeight);
			pc.addTable();
			if(tr.trim().equals("RQ"))
			{
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("DESPACHADO DESDE:  "+cdo.getColValue("desc_almacen"),0,setDetail.size(),cHeight);
				pc.addTable();

				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("REQUISICION NO :",0,1,cHeight);
					pc.addCols(""+cdo.getColValue("cod_solicitud"),0,2,cHeight);
					pc.addCols("TIPO SOLICITUD     "+cdo.getColValue("req_tipo"),1,5,cHeight);

				pc.addTable();

			}
			pc.addCopiedTable("detailHeader");

			if(!tr.trim().equals("RQ"))
			{
			//pc.setNoColumnFixWidth(setDetail1);
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("REQUISICION NO :",2,1,cHeight);
				pc.addCols(""+cdo.getColValue("cod_solicitud"),0,1,cHeight);
				pc.addCols("USUARIO APROB. "+cdo.getColValue("usuario"),0,2,cHeight);
				pc.addCols("FECHA APROB.  "+cdo.getColValue("fecha_pedido"),1,3,cHeight);
				pc.addCols(" "+cdo.getColValue("horaAprob"),0,1,cHeight);
			pc.addTable();
			}
		}

		groupBy    = cdo.getColValue("unidad");
		subGroupBy = cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_solicitud");
		observ     = cdo.getColValue("observaciones");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		if (!tr.trim().equals("RQ"))
		{
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(6, 1,Color.red);
			pc.createTable();
				pc.addCols("OBSERVACION: "+observ,0,setDetail.size(),cHeight);
			pc.addTable();
		}
		else
		{

			for(int x =0; x <= maxLines-lCounter; x++)
			{
				pc.setNoColumnFixWidth(setDetail1);
				pc.setFont(7, 1);
				pc.createTable();
				pc.addCols(" ",0,setDetail.size() ,cHeight);
				pc.addTable();
			}

			pc.setNoColumnFixWidth(setDetail1);
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" IMPRESO POR : ",0, 1,cHeight);
				pc.addBorderCols(" "+userName ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight*2);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();

			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" DESPACHADO EN ALMACEN POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" ENTREGADO EN DEPARTAMENTO POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();
			pc.setFont(6, 1);
			pc.createTable();
				pc.addCols(" RECIBIDO EN UNIDAD SOLICITANTE POR : ",0, 1,cHeight*2);
				pc.addBorderCols(" " ,0, 1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addCols(" ",0,1,cHeight);
			pc.addTable();

		}

	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>