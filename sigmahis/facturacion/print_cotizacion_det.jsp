<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
CommonDataObject cdoEnc = new CommonDataObject();
StringBuffer sbSql = new StringBuffer(); 
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");  
String id = request.getParameter("id"); 
  
if (id == null) id = ""; 

sbSql = new StringBuffer();
 
sbSql.append("select id, decode(esPac,'S',(select nombre_paciente from vw_adm_paciente where pac_id = c.pac_id),nombre) as nombre, estado, observacion, usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion,identificacion, to_char(fecha_nac,'dd/mm/yyyy') as fecha_nac , to_char(fecha,'dd/mm/yyyy')  as fecha,medico,procedimiento,other1,other2,other3,esPac,(select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)  from tbl_adm_medico where codigo=c.medico ) as nombreMedico,cod_proc,pac_id, decode(c.estado,'A','ACTIVO','I','INACTIVO') estadoDesc ,nvl(get_sec_comp_param(c.compania,'FAC_FOOTER_COTIZACION'),' ')as footer,reg_type from tbl_fac_cotizacion c where id=");
sbSql.append(id);

		cdoEnc = SQLMgr.getData(sbSql.toString());
 sbSql = new StringBuffer();		
		   sbSql.append("select pd.id,pd.renglon,pd.descripcion,pd.cantidad,pd.descuento,pd.tipo_des,pd.other1,pd.other2,usuario_creacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, usuario_modificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion,precio, round(cantidad*precio,2) as total,(select descripcion from tbl_fac_cotizacion_det where id=pd.id and renglon=pd.renglon ) as descripcionR from tbl_fac_cotizacion_item pd where id = ");
 sbSql.append(id); /*
 sbSql.append(" and renglon ="); 
 sbSql.append(renglon); */
 sbSql.append("order by pd.renglon asc,codigo"); 
 
al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = ""+_comp.getDireccion();
	String title = (cdoEnc.getColValue("reg_type").trim().equals("COT"))?"PRESUPUESTO DETALLADO":"PAQUETE DETALLADO";
	String subtitle = "NO.  "+id;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	
	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".07");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		
		dHeader.addElement(".08");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		
		dHeader.addElement(".09"); 
		dHeader.addElement(".09");
		dHeader.addElement(".09"); 
		
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(8, 0);
	if(cdoEnc.getColValue("reg_type").trim().equals("COT")){
	footer.addBorderCols("Por el Hospital :",0,dHeader.size()-4,0.1f,0.0f,0.0f,0.0f);
	footer.addBorderCols("Fecha: ",0,4,0.1f,0.0f,0.0f,0.0f);
	footer.addBorderCols("Nota :"+cdoEnc.getColValue("footer"),0,dHeader.size()-3,0.0f,0.1f,0.0f,0.0f);
	}
	else footer.addBorderCols(" ",0,dHeader.size()-3,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols(" "+(String) session.getAttribute("_userName")+"    "+fecha.substring(0, 16)+" "+fecha.substring(19),2,3,0.0f,0.1f,0.0f,0.0f);
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		
		if(cdoEnc.getColValue("reg_type").trim().equals("COT"))
		pc.addCols("PRESENTADO A:",0,1); 
		else pc.addCols("DESCRIPCION:",0,1);
		  
		pc.addCols(" "+cdoEnc.getColValue("nombre"),0,5);		
		pc.addCols("FECHA "+((cdoEnc.getColValue("reg_type").trim().equals("COT"))?"COTIZACIÓN:":":"),2,2);	
		pc.addCols(" "+cdoEnc.getColValue("fecha"),1,3); 
		if(cdoEnc.getColValue("reg_type").trim().equals("COT")){
		pc.addCols("IDENTIFICACION:",0,1);
		pc.addCols(" "+cdoEnc.getColValue("identificacion"),0,5);	
		pc.addCols("FECHA NACIMIENTO:",2,2);		
		pc.addCols(" "+cdoEnc.getColValue("fecha_nac"),1,3);  
		
		pc.addCols("MEDICO:",0,1); 
		pc.addCols(" ["+cdoEnc.getColValue("medico")+"] - "+cdoEnc.getColValue("nombreMedico"),0,8);			
		pc.addCols(" ",0,2); 
		
		pc.addCols("PROCEDIMIENTO:",0,1); 
		pc.addCols(" ["+cdoEnc.getColValue("cod_proc")+"] - "+cdoEnc.getColValue("procedimiento"),0,8);			
		pc.addCols(" ",0,2); 
		}
		pc.addCols("ESTADO:",0,1); 
		pc.addCols("  "+cdoEnc.getColValue("estadoDesc"),0,8);			
		pc.addCols(" ",0,2); 
		
		pc.addCols("OBSERVACIONES:",0,1); 
		pc.addCols(" "+cdoEnc.getColValue("observacion"),0,10);	 
		pc.addCols("  ",0,dHeader.size());
		
		
		pc.addBorderCols("DESCRIPCION",1,5);
		pc.addBorderCols("CANTIDAD",1,2);
		pc.addBorderCols("PRECIO",1,2); 
		pc.addBorderCols("TOTAL",1,2); 
		
	 if(cdoEnc.getColValue("reg_type").trim().equals("COT"))pc.setTableHeader(7);//create de table header
	 else pc.setTableHeader(4);//create de table header
	
	 
						
	//table body
 	double totalItbms = 0.00,totalDescuento =0.00,total = 0.00,totalr=0.00;
	double totalItbmsTot = 0.00,totalDescuentoTot =0.00,totalTot = 0.00;
 	String groupBy ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setVAlignment(0);
 		pc.setFont(contentFontSize,0);
		if(!groupBy.trim().equals(cdo.getColValue("renglon")))
		{
			
			if(i!=0)
			{
			  pc.addBorderCols(" SUB TOTAL  ",0,9,0.0f,0.5f,0.0f,0.0f);
			  pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",totalr),2,2,0.0f,0.5f,0.0f,0.0f); 
			  totalr=0.00;			 
			  pc.addCols("  ",0,dHeader.size()); 
			}
			
			pc.setFont(contentFontSize,0,Color.blue);pc.addCols(cdo.getColValue("descripcionR"),0,dHeader.size());
			pc.setFont(contentFontSize,0);
			
		} 
		pc.addCols(cdo.getColValue("descripcion"),0,5);
		pc.addCols(cdo.getColValue("cantidad"),2,2); 
		pc.addCols(cdo.getColValue("precio"),2,2); 
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("total")),2,2); 
		
		
		
		//pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("itbms")),2,1);
		 
		 
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		 
		totalTot += Double.parseDouble(cdo.getColValue("total")); 
		totalr   += Double.parseDouble(cdo.getColValue("total")); 
		groupBy  = cdo.getColValue("renglon");
		
	}
	if (al.size() == 0) pc.addCols("No existe Detalle",1,dHeader.size());
	else
	{
		
		pc.addBorderCols(" SUB TOTAL  ",0,9,0.0f,0.5f,0.0f,0.0f);
			  pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",totalr),2,2,0.0f,0.5f,0.0f,0.0f); 
			  totalr=0.00;
			  
			  
		pc.addCols(" ",1,dHeader.size());
		
		pc.setFont(groupFontSize,1,Color.blue);
		pc.addBorderCols(" TOTALES:  ",0,9,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",totalTot),2,2,0.0f,0.5f,0.0f,0.0f); 
	}
	
	
	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>