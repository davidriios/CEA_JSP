<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
	CommonDataObject cdo=new CommonDataObject();
	CommonDataObject cdo1=new CommonDataObject();
	ArrayList al = new ArrayList();

	
	String sql = "", appendFilter = "",appendFilter1="", sql1 = "";	
	String p_mes  	= request.getParameter("mes9");
	String p_anio 	= request.getParameter("anio");
	

if (p_anio == null) p_anio = "";

if ((p_mes == null) || p_mes.equalsIgnoreCase(""))  appendFilter="";
else  appendFilter += "and to_number(to_char(a.fecha_cargo,'mm')) = "+p_mes;

if ((p_mes == null) || p_mes.equalsIgnoreCase(""))  appendFilter1="";
else   appendFilter1 += "and to_number(to_char(fecha,'mm')) = "+p_mes ;


sql="select sum(nvl(cargos,0)) cargosTot,nvl(sum(b.monto_total),0) montoFac,c.descripcion descripcion from (select c.pac_id,C.SECUENCIA,C.MEDICO,C.COMPANIA, sum(DECODE (a.tipo_transaccion, 'D', (a.cantidad*a.monto) * -1, (a.cantidad*a.monto))) cargos from tbl_fac_detalle_transaccion a,tbl_adm_admision c where A.COMPANIA=C.COMPANIA and a.pac_id=c.pac_id and a.fac_secuencia =C.SECUENCIA  and C.ESTADO<>'N' and a.tipo_cargo not in ('15') "+appendFilter+" AND to_number(to_char(a.fecha_cargo, 'yyyy')) ="+p_anio+"  group by c.pac_id,C.SECUENCIA,C.MEDICO,C.COMPANIA) a,(select admi_secuencia,pac_id,sum(monto_total) monto_total from tbl_fac_factura where ESTATUS<>'A' "+appendFilter1+" and to_number(to_char(fecha, 'yyyy')) ="+p_anio+"  group by admi_secuencia,pac_id) b,(select bb.codigo,nvl(aa.descripcion,'MEDICO PRIVADO') descripcion from (select mes.medico,es.descripcion,min(secuencia) secuencia from tbl_adm_medico_especialidad mes, tbl_adm_especialidad_medica es where MES.ESPECIALIDAD=ES.CODIGO(+) and secuencia=1 group by mes.medico,es.descripcion)  aa,tbl_adm_medico bb where bb.codigo=aa.medico(+)) c where A.PAC_ID=B.PAC_ID(+) and A.SECUENCIA=B.admi_SECUENCIA(+) and a.medico=c.codigo group by c.descripcion ORDER BY descripcion asc";

al = SQLMgr.getDataList(sql);
/*
sql1="select sum(cargosTot) totalcargos,sum(montoFac) totalFacturado from ("+sql+")";
cdo1 = SQLMgr.getData(sql1);*/

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String month1 = fecha.substring(3, 5);
	String mes = "";
	
   if (p_mes.trim().equals("01")) month1 = "ENERO";
	else if (p_mes.trim().equals("02")) month1 = "FEBRERO";
	else if (p_mes.trim().equals("03")) month1 = "MARZO";
	else if (p_mes.trim().equals("04")) month1 = "ABRIL";
	else if (p_mes.trim().equals("05")) month1 = "MAYO";
	else if (p_mes.trim().equals("06")) month1 = "JUNIO";
	else if (p_mes.trim().equals("07")) month1 = "JULIO";
	else if (p_mes.trim().equals("08")) month1 = "AGOSTO";
	else if (p_mes.trim().equals("09")) month1 = "SEPTIEMBRE";
	else if (p_mes.trim().equals("10")) month1 = "OCTUBRE";
	else if (p_mes.trim().equals("11")) month1 = "NOVIEMBRE";
	else if (p_mes.trim().equals("12")) month1 = "DICIEMBRE";

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "REPORTE DE CARGOS POR ESPECILAIDAD";
	String xtraSubtitle="";
	if ((p_mes == null) || p_mes.equalsIgnoreCase("")) {
	 xtraSubtitle ="AL AÑO "+p_anio;
	}else{
	 xtraSubtitle ="MES" +"  "+month1+"  "+ "AL AÑO "+p_anio;
	}
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".25");
		setDetail.addElement(".25");
		setDetail.addElement(".25");
		setDetail.addElement(".25");

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	//second row
	pc.setFont(10, 1);
	//	pc.addCols("MES   "+month1 ,0,4);
		pc.addBorderCols("Especialidad",1,2);	
		pc.addBorderCols("Cargos ",1,1);	
		pc.addBorderCols("CargoFacturado ",1,1);
		
	
	//table body	
double totalcargos = 0.00,totalFacturado = 0.00;		
for (int i=0; i<al.size(); i++){ 
cdo=(CommonDataObject)al.get(i);
	pc.setFont(8, 0);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,2);
			pc.addCols(" "+cdo.getColValue("cargosTot"),2,1);
			pc.addCols(" "+cdo.getColValue("montoFac"),2,1);
			
			totalcargos  +=Double.parseDouble(cdo.getColValue("cargosTot"));
			totalFacturado +=Double.parseDouble(cdo.getColValue("montoFac"));
			
} 
         	pc.addBorderCols(" TOTAL : ",0,1);
	  		pc.addBorderCols(" ",1,1);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalcargos),2,1);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalFacturado),2,1);			
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>