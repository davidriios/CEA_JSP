<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilterInner = new StringBuffer();
StringBuffer sbFilterOutter = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("hh12mmssam");
String fp = request.getParameter("fp");
String almacen = request.getParameter("almacen");
String almacenDesc = request.getParameter("almacenDesc");
String anaquelx = request.getParameter("anaquelx");
String anaquely = request.getParameter("anaquely");
String anio = request.getParameter("anio");
String consigna = request.getParameter("consigna");
String consecutivo = request.getParameter("consecutivo");
String soloDif = request.getParameter("soloDif");
String estado = request.getParameter("estado");
String estado_art = request.getParameter("estado_art");
if(appendFilter== null)appendFilter="";
if(fp== null)fp="CE";
if(anaquelx== null)anaquelx = "";
if(anaquely== null)anaquely = "";
if(consecutivo== null)consecutivo = "";
if(consigna== null)consigna = "";
if(anio== null)anio = "";
if(almacen== null)almacen = "";
if(almacenDesc== null)almacenDesc = "";
if(soloDif== null)soloDif = "";
if(estado== null)estado = "";
if(estado_art== null)estado_art = "";
String dispoWhere = "";
String companyId = (String) session.getAttribute("_companyId");
boolean isCurrTrx = (request.getParameter("printOF") != null && request.getParameter("printOF").equalsIgnoreCase("S"));

	if(!consigna.trim().equals("")){sbFilter.append(" and c.consignacion_sino = '");sbFilter.append(consigna);sbFilter.append("'");}
	if ( !estado_art.trim().equals("") &&!estado_art.trim().equals("X") ) {
	  sbFilter.append(" and c.estado = '");
	  sbFilter.append(estado_art);
	  sbFilter.append("'");
	}
	if(!almacen.trim().equals("")){sbFilterInner.append(" and cfd.almacen = ");sbFilterInner.append(almacen);}

	if(!anaquelx.trim().equals("")){sbFilter.append(" and b.codigo_anaquel >= ");sbFilter.append(anaquelx);}
	if(!anaquely.trim().equals("")){sbFilter.append(" and b.codigo_anaquel <= ");sbFilter.append(anaquely);}
     
     
	if(!anio.trim().equals("")){sbFilterInner.append(" and cfd.cf1_anio =");sbFilterInner.append(anio);}
	if(!consecutivo.trim().equals("")){sbFilterInner.append(" and cfd.cf1_consecutivo =");sbFilterInner.append(consecutivo);}
	if(soloDif.trim().equals("S")){sbFilterOutter.append(" and z.cantidad_contada - z.cantidad_sistema <> 0 ");}

	if ( !estado.trim().equals("") &&!estado.trim().equals("X") ) {
	  sbFilterInner.append(" and cf.estatus = '");
	  sbFilterInner.append(estado);
	  sbFilterInner.append("'");
	}


	
	CommonDataObject cdoDispo = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'INV_CONTEO_DISPO'),'I') dispoWhere from dual");
	if (cdoDispo==null) {
		cdoDispo = new CommonDataObject();
		cdoDispo.addColValue("dispoWhere","I");
	}

	dispoWhere = cdoDispo.getColValue("dispoWhere");
	
	StringBuffer sbKardex = new StringBuffer();
	
	sbKardex.append(" select zz.*,nvl(qty,0)+nvl(saldo_inicial,0) as existencia from (select sum(qty_in-qty_out+qty_aju) qty, cod_articulo,compania,codigo_almacen,saldo_inicial from vw_inv_mov_item where compania= ");
	sbKardex.append(companyId);
	sbKardex.append(" and codigo_almacen= ");
	sbKardex.append(almacen);
	
	sbKardex.append(" /*and cod_articulo=:p_cod_articulo*/ and (trunc(fecha_docto) <= (select max(fecha_conteo) from tbl_inv_conteo_fisico where compania=");
	sbKardex.append(companyId); 
	sbKardex.append(" and almacen=");
	sbKardex.append(almacen); 
	sbKardex.append(" and anio= ");
	sbKardex.append(anio); 
	
	if ( !estado.trim().equals("") &&!estado.trim().equals("X") ) {
	  sbKardex.append(" and estatus = '");
	  sbKardex.append(estado);
	  sbKardex.append("'");
	}
	if(!consecutivo.trim().equals("")){sbKardex.append(" and consecutivo =");sbKardex.append(consecutivo);}
	
	sbKardex.append(")  or fecha_docto is null) group by compania,codigo_almacen,cod_articulo,saldo_inicial) zz ");
	
	sbSql.append(" select z.*, z.cantidad_contada- z.cantidad_sistema dif_cantidad, (z.cantidad_contada* nvl(z.precio,0)) - (z.cantidad_sistema* nvl(z.precio,0)) diferencia, decode(z.estatus,'C','NUEVA LISTA','P','PENDIENTE (POR ACTUALIZAR)','A','ACTIVO (ULTIMO CONTEO ACTUALIZADO)','I','INACTIVO  (INV.ANTERIORES YA ACTUALIZADOS)','N','ANULADO (ANULAR INVENTARIO FISICO)') estatus_desc from (select a.anio, a.almacen, a.cod_familia, a.cod_clase, a.cod_articulo, a.cantidad_contada, a.fecha_conteo, a.compania,a.estatus,c.descripcion,b.precio,c.cod_barra, c.estado,'"+almacenDesc+"'  desc_almacen, decode(a.tipo,'K',nvl(y.existencia,0),'I',nvl(b.disponible,0),0) as cantidad_sistema /*nvl(get_inv_dispo(a.almacen,a.compania,a.cod_articulo , to_char(a.fecha_conteo,'dd/mm/yyyy'),'"+dispoWhere+"'),0) as cantidad_sistema*/ from (select '"+dispoWhere+"' as tipo, cfd.cf1_anio anio, cfd.almacen, cfd.cod_familia, cfd.cod_clase, cfd.cod_articulo, sum(cfd.cantidad_contada) cantidad_contada, max(cf.fecha_conteo) fecha_conteo, cfd.compania,cf.estatus from tbl_inv_detalle_fisico cfd,tbl_inv_conteo_fisico cf where cfd.cf1_anio = cf.anio and cfd.cf1_consecutivo = cf.consecutivo and cfd.almacen = cf.almacen and cfd.compania = cf.compania ");
	
	sbSql.append(sbFilterInner);

	sbSql.append(" group by cfd.cf1_anio, cfd.almacen, cfd.cod_familia, cfd.cod_clase, cfd.cod_articulo,cfd.compania,cf.estatus) a,tbl_inv_inventario b,tbl_inv_articulo c ");
	sbSql.append(" ,("+sbKardex.toString()+") y where a.cod_articulo=b.cod_articulo and a.cod_articulo=c.cod_articulo and a.compania=c.compania and a.almacen=b.codigo_almacen and a.cod_articulo=y.cod_articulo and a.compania=y.compania ");
		
	sbSql.append(sbFilter);
	
	sbSql.append(") z where 1 = 1 ");
	sbSql.append(sbFilterOutter.toString());
	
	sbSql.append(" order by 2,9,10 " );
	
	al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "INVENTARIO";
	String subtitle = "DIFERENCIA ENTRE INVENTARIO FISICO VS. SISTEMA";
	String xtraSubtitle = "DIFERENCIA AGRUPADO POR ARTICULOS";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row
		
		pc.setFont(fontSize,1);
		pc.addBorderCols("Codigo",0,1);
		pc.addBorderCols("Codigo de Barra",0,1);
		pc.addBorderCols("Articulo",0,1);
		pc.addBorderCols("Sistema",2,1);
		pc.addBorderCols("Conteo",2,1);
		pc.addBorderCols("Dif. Unidades",2,1);
		pc.addBorderCols("Dif. Monto",2,1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	String groupBy="",groupBy2="",groupBy3="";
	double total = 0.00,sub_total = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		if(i==0)
		{
			//pc.setFont(fontSize, 0,Color.blue);
			//pc.addCols(" [ "+cdo1.getColValue("cod_almacen")+" ] "+cdo1.getColValue("desc_almacen"),0,dHeader.size());
		}

		if (!groupBy.equalsIgnoreCase(cdo1.getColValue("almacen")))
	    {
			pc.setFont(8, 0,Color.blue);
			pc.addCols(" [ "+cdo1.getColValue("almacen")+" ] "+cdo1.getColValue("desc_almacen"),0,dHeader.size());
		}
		
		if (!groupBy2.equalsIgnoreCase(cdo1.getColValue("estatus")))
	    {
			//pc.setFont(8, 0,Color.red);
			pc.addCols(cdo1.getColValue("estatus_desc"),0,dHeader.size());
		}
		
		/*if (!groupBy3.equalsIgnoreCase(cdo1.getColValue("cod_articulos")))
	    {
			pc.setFont(8, 0,Color.red);
			pc.addCols(cdo1.getColValue("desc_articulo"),0,dHeader.size());
		}*/
		
		if(!cdo1.getColValue("dif_cantidad").trim().equals("0"))pc.setFont(fontSize-1,0,Color.red);
		else pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo1.getColValue("cod_familia")+"-"+cdo1.getColValue("cod_clase")+"-"+cdo1.getColValue("cod_articulo"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cod_barra"), 0,1);
		pc.addCols(" "+cdo1.getColValue("descripcion"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cantidad_sistema"), 2,1);
		pc.addCols(" "+cdo1.getColValue("cantidad_contada"), 2,1);
		pc.addCols(" "+cdo1.getColValue("dif_cantidad"), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("diferencia")), 2,1);
		
		total +=  Double.parseDouble(cdo1.getColValue("diferencia"));
		groupBy = cdo1.getColValue("almacen");
		groupBy2 = cdo1.getColValue("estatus");
		groupBy3 = cdo1.getColValue("cod_articulos");
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al == null || al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{pc.setFont(8, 1,Color.blue);
		 pc.addCols("Total: ",2,6);
		 pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",total),2,1);}
	pc.addTable();
	pc.close();
    
	if (isCurrTrx) response.sendRedirect(redirectFile);
    else {
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function actualizar(){
	CBMSG.confirm('\u00a1\u00a1Atenci\u00F3n!! El bot\u00F3n EJECUTAR actualizar\u00e1 el inventario de este almac\u00e9n!',{
		btnTxt: "Aceptar,Cerrar",
	  cb:function(r){
		  if (r == "Aceptar") {
			  }
		  if (r == "Cerrar") {
			  	window.self.close()
			  }
	  }
	});
	showPopWin('../common/run_process.jsp?fp=ACTCONTEO&actType=8&docType=ACTCONTEO&estado_art=<%=estado_art%>&consigna=<%=consigna%>&almacen=<%=almacen%>&anio=<%=anio%>&compania=<%=(String) session.getAttribute("_companyId")%>&docId=LOTE&docDesc=LOTE&docNo=LOTE',winWidth*.75,winHeight*.45,null,null,'');
}
</script>
</head>
<body>
<table width="100%" height="100%" cellpadding="5" cellspacing="0" align="center">
<%fb = new FormBean("formPrinted",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<tr class="TextHeader">
	<td align="center" class="TableBorder">
      <authtype type="50">
      <%=fb.button("btn_upd","Actualizar",false,false,null,null,"onClick=actualizar()")%>
      </authtype>
    </td>
</tr>
<tr class="TextHeader">
	<td align="center" class="TableBorder">Actualiza la disponibilidad del art&iacute;culo generando un ajuste por la diferencia.</td>
</tr>
<%=fb.formEnd(true)%>
</table>    


<div>
<iframe name="cargos_det" id="cargos_det" frameborder="0" align="center" width="100%" height="550px" scrolling="no" src="<%=redirectFile%>"></iframe>
</div>
</body>
</html>
<% 
}   
}//GET
%>