<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
ArrayList alE = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String appendFilter = request.getParameter("appendFilter");
String mode=request.getParameter("mode");
String anio=request.getParameter("anio");
String fg=request.getParameter("fg");
String fp=request.getParameter("fp");
String no=request.getParameter("no");
String renglon=request.getParameter("renglon");
String tipo=request.getParameter("tipo");
String idTrx =request.getParameter("idTrx"); 
String compania = (String) session.getAttribute("_companyId");
if(fg ==null)fg="";
if(fp ==null)fp="";
if(idTrx ==null)idTrx="";

 		sql.append("select det.ano, det.consecutivo, det.compania, det.renglon, det.ano_cta anocta, det.cta1, det.cta2, det.cta3, det.cta4, det.cta5, det.cta6, det.tipo_mov tipomov, det.valor,det.comentario||decode(det.ref_id,'-',' ',' - '||(det.ref_id ||' - '||det.ref_desc ))as comentario, det.ref_type as refType, det.ref_id as refId, det.ref_desc as refDesc,'U' action,(select cg.descripcion from tbl_con_catalogo_gral cg  where cg.cta1=det.cta1 and cg.cta2 =det.cta2 and cg.cta3 =det.cta3 and cg.cta4 =det.cta4 and cg.cta5=det.cta5 and cg.cta6=det.cta6 and cg.compania=det.compania ) as descCuenta,det.cta1||'.'||det.cta2||'.'||det.cta3||'.'||det.cta4||'.'||det.cta5||'.'||det.cta6 as cuenta ,decode(det.tipo_mov,'DB','DEBITO','CR','CREDITO') as tipoMovDesc,decode(det.ref_type,0,'DIARIO',1,'CXC',2,'CXP') refTypeDesc from tbl_con_detalle_comprob det where det.compania=");
		sql.append(session.getAttribute("_companyId"));
		sql.append(" and det.ano=");
		sql.append(anio);
		if(fg.trim().equals("")){		
		sql.append(" and det.consecutivo=");
		sql.append(no);		
		sql.append(" and det.renglon=");
		sql.append(renglon);
		sql.append(" and det.tipo=");
		sql.append(tipo);
		}else
		{   sql.append(" and exists (select null from tbl_con_registros_auxiliar  where id=");
			sql.append(idTrx);
			sql.append(" and  ref_type =");
			if(fg.trim().equals("CSCXP"))sql.append(" 2 ");
			else if(fg.trim().equals("CSCXC"))sql.append(" 1 ");
			sql.append("  and trans_id=det.consecutivo and trans_anio=det.ano and trans_renglon=det.renglon and trans_tipo=det.tipo  )");
		
		 }
			
		cdo = SQLMgr.getData(sql);
		
	
		sql=new StringBuffer();
sql.append("select id,compania, ref_type, subref_type, ref_id, monto, lado, comentario, usuario_creacion, usuario_modificacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, estado, documento, referencia, afecta_aux, to_char(fecha_doc,'dd/mm/yyyy')fecha_doc, trans_id, trans_anio, trans_renglon, trans_tipo,nombre,reg_sistema,ruc,dv,(select descripcion from tbl_fac_tipo_cliente where compania =a.compania and codigo= a.subref_type) as subref_typeDesc,decode(estado,'A','ACTIVO','I','INACTIVO') estadoDesc from tbl_con_registros_auxiliar a where compania=");
sql.append(session.getAttribute("_companyId"));

 if(fg.trim().equals("")){
 sql.append(" and trans_id =");
sql.append(no);
sql.append(" and trans_anio= ");
sql.append(anio);
sql.append(" and trans_renglon= ");
sql.append(renglon);
sql.append(" and trans_tipo=");
sql.append(tipo); 
}
if(!idTrx.trim().equals("")){sql.append(" and id=");sql.append(idTrx);}


sql.append(" order by id desc ");	
		al=SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "MOVIMIENTO MAYOR - DETALLE AUXILIAR";
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
	dHeader.addElement(".22");
	dHeader.addElement(".10");
	dHeader.addElement(".25");
	dHeader.addElement(".08");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	 

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			
			pc.setFont(7, 1);	
			pc.addCols("GENERALES : ",0, dHeader.size());
			
			pc.addCols("CUENTA : "+cdo.getColValue("cuenta")+" "+cdo.getColValue("descCuenta"),0,3);			
			pc.addCols("LADO : "+cdo.getColValue("tipoMovDesc"),0,1);
			pc.addCols("MONTO : "+cdo.getColValue("valor"),0,3);
			
			
			pc.addCols("Comentario : "+cdo.getColValue("comentario"),0,dHeader.size()-1);
			pc.addCols("TIPO : "+cdo.getColValue("refTypeDesc"),1,2);
					
			pc.addCols(" ",1, dHeader.size());
								
			pc.addBorderCols("TIPO CLIENTE",1,1);
			pc.addBorderCols("CLIENTE",1,1);
			pc.addBorderCols("MONTO",1,1);
			pc.addBorderCols("COMENTARIO",1);
			pc.addBorderCols("FECHA DOC.",1,1);
			pc.addBorderCols("REFERENCIA",1,1);
			pc.addBorderCols("ESTADO",1,1); 	
			
	pc.setTableHeader(5);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	double total = 0.00;  		
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdox = (CommonDataObject) al.get(i);
		 
		 
	
				pc.setFont(7, 0);
				pc.addCols(cdox.getColValue("subref_typeDesc"),0,1);
				pc.addCols(cdox.getColValue("ref_id")+" - "+cdox.getColValue("nombre"),0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdox.getColValue("monto")),2,1);  				
				pc.addCols(""+cdox.getColValue("comentario"),0,1);
				pc.addCols(""+cdox.getColValue("fecha_doc"),1,1);
				pc.addCols(""+cdox.getColValue("referencia"),0,1);
				pc.addCols(""+cdox.getColValue("estadoDesc"),1,1); 
				total 	+= Double.parseDouble(cdox.getColValue("monto"));
				
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true); 
	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
			pc.setFont(7,1);
			pc.addCols("TOTAL :",2,2);
			pc.addCols(CmnMgr.getFormattedDecimal(total),2,1);  	
			pc.addCols(" ",2,4);
			 
			pc.addCols("Preparado por:_________________________________________________________",0,dHeader.size()-1);
			pc.addCols("",2,1);  
			
			 
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>