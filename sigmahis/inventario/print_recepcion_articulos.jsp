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
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList(); 
CommonDataObject cdoP = new CommonDataObject(); 
StringBuffer sbSql   = new StringBuffer(); 
String  sql  ="",desc ="",pInclTax="";

String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String almacen = request.getParameter("almacen");
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");//(String) session.getAttribute("_companyId");
String anio = request.getParameter("anio");
String numero_ajuste = request.getParameter("numero_ajuste");
String codigo_ajuste = request.getParameter("codigo_ajuste");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String proveedor = request.getParameter("proveedor");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subclase =  request.getParameter("subclase");

if (appendFilter == null) appendFilter = "";
if (almacen == null) almacen = "";
if (!almacen.trim().equals("")) appendFilter += " and rm.codigo_almacen="+almacen+"";
if (anio == null) anio = "";
if (numero_ajuste == null) numero_ajuste = "";
if (codigo_ajuste == null) codigo_ajuste = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter += " and to_date(to_char(rm.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";
if (proveedor == null) proveedor = "";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";
if(subclase == null )   subclase = "";


sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CON_RECEP_INCLU_ITBM'),'N') as inclTax  from dual");
	cdoP = SQLMgr.getData(sbSql.toString());
	if (cdoP == null) {
		cdoP = new CommonDataObject();
		cdoP.addColValue("inclTax","N"); 	
	}
	pInclTax = cdoP.getColValue("inclTax");
	
/**   inv70307 y inv70307_new(total )  */
/*
diferencia selecciona tolales y art_itbm

select ca.* from tbl_inv_clase_articulo ca
*/
//print_recepcion_articulos.jsp


if (fp.trim().equals("RDA") ||fp.trim().equals("RDAN")) //inv70307 y  inv70307_new
{
	desc = " ";
	appendFilter += " and rm.fre_documento not in ('FG','NE') and dr.cantidad>0";

}
else if (fp.trim().equals("FC") || fp.trim().equals("FCN")) //inv70307_fc Y inv70307_new
{
	desc = " (CREDITO)";
	appendFilter += " and rm.fre_documento in ('OC','FC','FR')";// factura credito
	//if (!familyCode.trim().equals("")) appendFilter += " and dr.cod_familia='"+familyCode+"'";
	//if (!classCode.trim().equals("")) appendFilter += " and dr.cod_clase='"+classCode+"'";
	System.out.println("============================================================================");
}
else if (fp.trim().equals("FG") || fp.trim().equals("FGN"))//= 'FG'
{
	desc = " (CONSIGNACION)";
	appendFilter += " and rm.fre_documento='FG' and dr.cantidad>0";// Consignacion
	/*if (fp.trim().equals("FGN"))
	{
		if (!familyCode.trim().equals("")) appendFilter += " and dr.cod_familia='"+familyCode+"'";
		if (!classCode.trim().equals("")) appendFilter += " and dr.cod_clase='"+classCode+"'";

	}*/

}
if(fp.trim().equals("RDAN") || fp.trim().equals("FC") || fp.trim().equals("FCN") || fp.trim().equals("FGN")||fp.trim().equals("RDA")) //--,inv70307_fc Y inv70307_new , inv70307_fg_new
{}
	if (!familyCode.trim().equals("")) appendFilter += " and dr.cod_familia='"+familyCode+"'";
	if (!classCode.trim().equals("")) appendFilter += " and dr.cod_clase='"+classCode+"'";
	if (!subclase.trim().equals(""))    appendFilter += " and dr.subclase_id ="+subclase;
	if (!proveedor.trim().equals("")) appendFilter += " and rm.cod_proveedor='"+proveedor+"'";

  //in ('OC','FC','FR')

sql = "select z.*, z.cod_familia||'-'||z.cod_clase||'-'||z.cod_articulo as codigo, y.descripcion as desc_almacen, x.descripcion as desc_articulo, w.nombre as desc_familia, v.descripcion as desc_clase, u.precio, u.ultimo_precio ultimoPrecio,x.cod_medida from (select rm.compania, rm.codigo_almacen as cod_almacen, dr.cod_familia, dr.cod_clase, dr.cod_articulo, sum(nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) as cantidad,/*sum((nvl(cantidad,0) * nvl(dr.articulo_und,0) * (decode(rm.fre_documento,'FG',nvl(dr.precio,0),nvl(dr.precio,0)-nvl(dr.art_itbm,0)) + nvl(dr.art_itbm,0)))) total,*/ sum((nvl(dr.cantidad,0)*decode(nvl(dr.precio,0),0,0,nvl(dr.precio,0)-decode(rm.fre_documento,'FG',0,decode('"+pInclTax+"','S',0,nvl(dr.art_itbm,0))))*nvl(dr.articulo_und,0)) + decode(rm.fre_documento,'FG',decode('"+pInclTax+"','S',nvl(dr.art_itbm,0),0),0)) as total, sum(nvl(rm.monto_total,0)) as monto_total from tbl_inv_recepcion_material rm, tbl_inv_detalle_recepcion dr where rm.estado='R' and rm.compania="+compania+appendFilter+" and (dr.compania=rm.compania and dr.numero_documento=rm.numero_documento and dr.anio_recepcion=rm.anio_recepcion) group by rm.compania, rm.fre_documento,rm.codigo_almacen, dr.cod_familia, dr.cod_clase, dr.cod_articulo) z, tbl_inv_almacen y, tbl_inv_articulo x, tbl_inv_familia_articulo w, tbl_inv_clase_articulo v, tbl_inv_inventario u where (z.cod_almacen=y.codigo_almacen and z.compania=y.compania) and (z.compania=x.compania and z.cod_articulo=x.cod_articulo) and (z.compania=w.compania and z.cod_familia=w.cod_flia) and (z.compania=v.compania and z.cod_familia=v.cod_flia and z.cod_clase=v.cod_clase) and (z.compania=u.compania and z.cod_almacen=u.codigo_almacen and z.cod_articulo=u.cod_articulo) order by z.compania, z.cod_almacen, z.cod_familia, z.cod_clase, z.cod_articulo";
al = SQLMgr.getDataList(sql);
//al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECEPCION DE ARTICULOS POR DEPOSITO "+desc;
	String subtitle = "DEL "+fDate+" AL "+tDate;
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		 
		dHeader.addElement(".15");
		dHeader.addElement(".45");
		if (fp.equalsIgnoreCase("RDA"))
		{
			dHeader.addElement(".10");
			dHeader.addElement(".10");//0.15
			dHeader.addElement(".10");//0.15
			dHeader.addElement(".10");
		}
		else
		{
			dHeader.addElement(".20");
			dHeader.addElement(".20");
		}

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("CANTIDAD",1);
		if (fp.equalsIgnoreCase("RDA")) 
		   {
		     pc.addBorderCols("COSTO PROM.",1);
			 pc.addBorderCols("ULTIMO PREC.",1);
		   }
		pc.addBorderCols("MONTO",1);
	pc.setTableHeader(2);
	
	double qtyC = 0.00, qtyF = 0.00, qtyT = 0.00;
	double costC = 0.00, costF = 0.00, costT = 0.00;
	double amtC = 0.00, amtF = 0.00, amtT = 0.00,total=0.00;
	String wh = "", groupBy = "",subGroupBy = "";
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!wh.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
		{
			if (fp.equalsIgnoreCase("RDAN") || fp.equalsIgnoreCase("FCN") || fp.equalsIgnoreCase("FGN"))
		   {
		   if (i > 0)
				{

			pc.setFont(7, 1,Color.blue);
			pc.addCols("Subtotal x Clase: ",2,2,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(qtyC),2,1,cHeight);
				if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costC),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(amtC),2,1,cHeight);
			 
			qtyC = 0;
			costC = 0;
			amtC = 0;

			pc.setFont(7, 1,Color.blue);
						pc.addCols("Subtotal x Familia: ",2,2,cHeight);
						pc.addCols(""+CmnMgr.getFormattedDecimal(qtyF),2,1,cHeight);
						if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costF),2,1,cHeight);
						pc.addCols("$"+CmnMgr.getFormattedDecimal(amtF),2,1,cHeight);
					
					 
					qtyF = 0;
					costF = 0;
					amtF = 0;


			pc.setFont(7, 1,Color.blue);
			pc.addCols("A L M A C E N  : "+cdo.getColValue("cod_almacen")+" - "+cdo.getColValue("desc_almacen"),0,dHeader.size(),cHeight);
			
			 
			}
			else
			{

			pc.setFont(7, 1,Color.blue);
			pc.addCols("A L M A C E N :  "+cdo.getColValue("cod_almacen")+" - "+cdo.getColValue("desc_almacen"),0,dHeader.size(),cHeight);
			
 			}
			}
			 else
			{

			pc.setFont(7, 1,Color.blue);
			pc.addCols("A L M A C E N .: "+cdo.getColValue("cod_almacen")+" - "+cdo.getColValue("desc_almacen"),0,dHeader.size(),cHeight);
			
 			}
		}
		if (fp.equalsIgnoreCase("RDAN") || fp.equalsIgnoreCase("FCN") || fp.equalsIgnoreCase("FGN"))
		{
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia")))
			{
				if (i > 0)
				{

					if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia")+"-"+cdo.getColValue("cod_clase")))
					{

						if (qtyC!=0)
						{
						pc.setFont(7, 1,Color.blue);
							pc.addCols("Subtotal x Clase: ",2,2,cHeight);
							pc.addCols(""+CmnMgr.getFormattedDecimal(qtyC),2,1,cHeight);
							if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costC),2,1,cHeight);
							pc.addCols("$"+CmnMgr.getFormattedDecimal(amtC),2,1,cHeight);
						
 						qtyC = 0;
						costC = 0;
						amtC = 0;
						}
					}
					if (qtyF!=0)
					{
					pc.setFont(7, 1,Color.blue);
						pc.addCols("Subtotal x Familia: ",2,2,cHeight);
						pc.addCols(""+CmnMgr.getFormattedDecimal(qtyF),2,1,cHeight);
						if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costF),2,1,cHeight);
						pc.addCols("$"+CmnMgr.getFormattedDecimal(amtF),2,1,cHeight);
					
					qtyF = 0;
					costF = 0;
					amtF = 0;
					}
				}
				pc.setFont(7, 1,Color.blue);
					pc.addCols("F A M I L I A : "+cdo.getColValue("cod_familia")+" - "+cdo.getColValue("desc_familia"),0,dHeader.size(),cHeight);
				
 
				if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia")+"-"+cdo.getColValue("cod_clase")))
				{
					pc.setFont(7, 1,Color.blue);
						pc.addCols("    C L A S E : "+cdo.getColValue("cod_clase")+" - "+cdo.getColValue("desc_clase"),0,dHeader.size(),cHeight);
					
 				}
			}
			else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia")+"-"+cdo.getColValue("cod_clase")))
			{
				if (i > 0)
				{
					pc.setFont(7, 1,Color.blue);
						pc.addCols("Subtotal x Clase: ",2,2,cHeight);
						pc.addCols(""+CmnMgr.getFormattedDecimal(qtyC),2,1,cHeight);
						if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costC),2,1,cHeight);
						pc.addCols("$"+CmnMgr.getFormattedDecimal(amtC),2,1,cHeight);
					
					qtyC = 0;
					costC = 0;
					amtC = 0;
				}

				pc.setFont(7, 1,Color.blue);
					pc.addCols("    C L A S E : "+cdo.getColValue("cod_clase")+" - "+cdo.getColValue("desc_clase"),0,dHeader.size(),cHeight);
				
			}
		}

		pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("codigo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad"))+" -"+cdo.getColValue("cod_medida"),2,1,cHeight);
			if (fp.equalsIgnoreCase("RDA"))
			   {
			    pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("ultimoPrecio")),2,1,cHeight);
				}
			pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1,cHeight);
		
		wh = cdo.getColValue("cod_almacen");
		groupBy  = cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia");
		subGroupBy = cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_familia")+"-"+cdo.getColValue("cod_clase");
		qtyC += Double.parseDouble(cdo.getColValue("cantidad"));
		costC += Double.parseDouble(cdo.getColValue("precio"));
		amtC += Double.parseDouble(cdo.getColValue("total"));
		qtyF += Double.parseDouble(cdo.getColValue("cantidad"));
		costF += Double.parseDouble(cdo.getColValue("precio"));
		amtF += Double.parseDouble(cdo.getColValue("total"));
		qtyT += Double.parseDouble(cdo.getColValue("cantidad"));
		costT += Double.parseDouble(cdo.getColValue("precio"));
		amtT += Double.parseDouble(cdo.getColValue("total"));
		total += Double.parseDouble(cdo.getColValue("total"));
	}//for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
		
	}
	else
	{
		if (fp.equalsIgnoreCase("RDAN") || fp.equalsIgnoreCase("FCN") || fp.equalsIgnoreCase("FGN"))
		{
				pc.setFont(7, 1,Color.blue);
				pc.addCols("Subtotal x Clase: ",2,2,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(qtyC),2,1,cHeight);
				if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costC),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(amtC),2,1,cHeight);
			

				pc.setFont(7, 1,Color.blue);
				pc.addCols("Subtotal x Familia: ",2,2,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(qtyF),2,1,cHeight);
				if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costF),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(amtF),2,1,cHeight);
			

				pc.setFont(7, 1,Color.blue);
				pc.addCols("Gran Total: ",2,2,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(qtyT),2,1,cHeight);
				if (fp.equalsIgnoreCase("RDA")) pc.addCols("$"+CmnMgr.getFormattedDecimal(costT),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(amtT),2,1,cHeight);
			
		}
		if (fp.equalsIgnoreCase("FC") || fp.equalsIgnoreCase("FG"))
		{
				pc.setFont(7, 1,Color.blue);
				pc.addCols("Gran Total: ",2,2,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(""+qtyT),2,1,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal(total),2,1,cHeight);
				//pc.addCols("$"+CmnMgr.getFormattedDecimal(amtT),2,1,cHeight);
		}
	}
	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
