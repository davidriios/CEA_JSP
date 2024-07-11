<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="java.util.ArrayList" %>
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
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String fg = request.getParameter("fg");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaEntrega = request.getParameter("fechaEntrega");
String fechaEntregaFin = request.getParameter("fechaEntregaFin");

if(fg==null)fg="";
if(fDate==null)fDate="";
if(tDate==null)tDate="";
if(pacId==null)pacId="";
if(noAdmision==null)noAdmision="";
if(fechaEntrega==null)fechaEntrega="";
if(fechaEntregaFin==null)fechaEntregaFin="";
 
sbSql.append(" select to_char(s.fecha_entrega,'dd/mm/yyyy') fe,to_char(s.fecha_entrega,'hh12:mi:ss am') he, to_char(s.fecha_devolucion,'dd/mm/yyyy') fd,to_char(s.fecha_devolucion,'hh12:mi:ss am') hd, p.nombre_paciente, p.id_paciente, s.no_equipo,nvl((select nombre from tbl_inv_comodato_equipos where no_equipo = s.no_equipo  ),'SIN ASIGNAR')nombre,s.pac_id, s.admision");
if(fg.trim().equals("CARGO")){sbSql.append(",decode(ft.tipo_transaccion,'D',-1*(fdt.cantidad * nvl(fdt.monto,0)),(fdt.cantidad * nvl(fdt.monto,0))) monto_fac,to_char(fdt.fecha_cargo,'dd/mm/yyyy')fecha_cargo");
}
 sbSql.append(" ,s.fecha_entrega,s.usuario_entrega,s.usuario_devolucion as usuario_recibe,s.usuario_creacion,to_char(s.fecha_creacion,'dd/mm/yyyy')fecha_creacion,to_char(s.fecha_creacion,'hh12:mi:ss am')hora_creacion from tbl_inv_sol_equip_med s, vw_adm_paciente p,tbl_adm_admision a");
 if(fg.trim().equals("CARGO"))sbSql.append(",tbl_fac_transaccion ft,tbl_fac_detalle_transaccion fdt  ");
 
 sbSql.append(" where s.pac_id = p.pac_id and s.admision = a.secuencia and s.pac_id = a.pac_id and p.pac_id = a.pac_id and a.compania = s.compania ");
 if(!fDate.trim().equals(""))
 {
 	sbSql.append(" and trunc(s.fecha_creacion) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') ");
 }
 if(!tDate.trim().equals(""))
 {
 	sbSql.append(" and trunc(s.fecha_creacion) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') ");
 }
 if(!fechaEntrega.trim().equals(""))
 {
 	sbSql.append(" and trunc(s.fecha_entrega) >= to_date('");
	sbSql.append(fechaEntrega);
	sbSql.append("','dd/mm/yyyy') ");
 }
 if(!fechaEntregaFin.trim().equals(""))
 {
 	sbSql.append(" and trunc(s.fecha_entrega) <= to_date('");
	sbSql.append(fechaEntregaFin);
	sbSql.append("','dd/mm/yyyy') ");
 }
 if(!pacId.trim().equals(""))
 {
 	sbSql.append(" and s.pac_id=");
	sbSql.append(pacId);
 }
 if(!noAdmision.trim().equals(""))
 {
 	sbSql.append(" and s.admision_corte=");
	sbSql.append(noAdmision);
 }
  
 if(fg.trim().equals("CARGO")){
sbSql.append(" and s.pac_id = ft.pac_id and s.admision = ft.admi_secuencia and ft.ref_type ='EQUIP' and ft.num_solicitud = s.codigo  and ft.compania = fdt.compania   and ft.codigo =fdt.fac_codigo and ft.pac_id = fdt.pac_id  and ft.admi_secuencia = fdt.fac_secuencia  and ft.tipo_transaccion = fdt.tipo_transaccion ");
}
 sbSql.append(" order by s.no_equipo asc");
 if(!fg.trim().equals("EXP"))sbSql.append(",s.fecha_entrega desc");
 if(fg.trim().equals("CARGO"))sbSql.append(", ft.fecha_creacion desc");
 if(fg.trim().equals("EXP"))sbSql.append(", s.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (fg.trim().equals("EXP"))?"EXPEDIENTE":"INVENTARIO";
	String subtitle = "MONITOREO CARGOS EQUIPOS COMODATOS";
	if(fg.trim().equals("ENT")){subtitle="ENTREGA DE EQUIPOS COMODATOS";fDate=fechaEntrega; tDate=fechaEntregaFin;}
	else if(fg.trim().equals("EXP")){subtitle="SOLICITUD DE EQUIPOS MEDICOS";}
	String xtraSubtitle = ((!fg.trim().equals("EXP"))?"DEL "+fDate+" AL "+tDate:"");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".25");
	setDetail.addElement(".10");
	setDetail.addElement(".12");
	setDetail.addElement(".10");
	setDetail.addElement(".10");
	setDetail.addElement(".09");
	setDetail.addElement(".09");
	setDetail.addElement(".08");
	setDetail.addElement(".07");
	
	String grpByEq = "";
	int totSolByGr = 0, totSolFinal = 0;
	double totMfacByGr = 0.0, totMFfinal = 0.0;
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());
	pc.setTableHeader(1);//create de table header

		pc.setFont(7,1);
	
		pc.addBorderCols("Paciente",0,1);
		pc.addBorderCols("PID",1,1);
		pc.addBorderCols("Cédula",1,1);
		if(fg.trim().equals("EXP"))pc.addBorderCols("F.Solicitud",1,2);else pc.addBorderCols("F.Entrega",1,1);
		if(fg.trim().equals("EXP"))pc.addBorderCols("H.Solicitud",1,2);else pc.addBorderCols("H.Entrega",1,1);
		if(!fg.trim().equals("EXP"))pc.addBorderCols("F.Devolución",1,1);
		if(!fg.trim().equals("EXP"))pc.addBorderCols("H.Devolución",1,1);
		if(fg.trim().equals("CARGO")){
		pc.addBorderCols("M.Facturado",2,1);
		pc.addBorderCols("F. Cargo",2,1);}
		else if(fg.trim().equals("EXP"))pc.addBorderCols("Usuario Solicita",1,2);
		else pc.addBorderCols("Usuario Entrega/Recibe",2,2);
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		
		if (!grpByEq.equals(cdo1.getColValue("no_equipo"))){
		
		if(fg.trim().equals("CARGO")){
		    if (i > 0){
			   pc.addCols("Sub total ",2,6);
			   pc.addCols(""+totSolByGr,1,1);
			   pc.addCols(""+CmnMgr.getFormattedDecimal(""+totMfacByGr),2,1);
			   pc.addCols(" ",1,1);
			   totSolByGr = 0;
			   totMfacByGr = 0;
			}
		}
		    if (i > 0) pc.addCols(" ",1,setDetail.size());
			pc.setFont(7,1);
		    pc.addCols("EQUIPO: ["+cdo1.getColValue("no_equipo")+"] "+cdo1.getColValue("nombre"),0,setDetail.size());
			
			
		}
		
		pc.setFont(7,0);
		pc.addCols(""+cdo1.getColValue("nombre_paciente"),0,1);
		pc.addCols(""+cdo1.getColValue("pac_id")+"-"+cdo1.getColValue("admision"),1,1);
		pc.addCols(""+cdo1.getColValue("id_paciente"),1,1);
		if(fg.trim().equals("EXP"))pc.addCols(""+cdo1.getColValue("fecha_creacion"),1,2);else pc.addCols(""+cdo1.getColValue("fe"),1,1);
		if(fg.trim().equals("EXP"))pc.addCols(""+cdo1.getColValue("hora_creacion"),1,2);else pc.addCols(""+cdo1.getColValue("he"),1,1);
		if(!fg.trim().equals("EXP"))pc.addCols(""+cdo1.getColValue("fd"),1,1);
		if(!fg.trim().equals("EXP"))pc.addCols(""+cdo1.getColValue("fd"),1,1);
		if(fg.trim().equals("CARGO")){pc.addCols(""+cdo1.getColValue("monto_fac"),2,1);
		pc.addCols(""+cdo1.getColValue("fecha_cargo"),1,1);}
		else if(fg.trim().equals("ENT")){pc.addCols(""+cdo1.getColValue("usuario_entrega")+"/"+cdo1.getColValue("usuario_recibe"),1,2);}
		else if(fg.trim().equals("EXP")){pc.addCols(""+cdo1.getColValue("usuario_creacion"),1,2);}
		if(fg.trim().equals("CARGO")){
		totSolByGr++;
		totSolFinal++;
		totMfacByGr += Double.parseDouble(cdo1.getColValue("monto_fac"));
		totMFfinal += Double.parseDouble(cdo1.getColValue("monto_fac"));
		}
		grpByEq = cdo1.getColValue("no_equipo");
	}//for i
	
	pc.setFont(7,1);

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{ 
	   if(fg.trim().equals("CARGO")){
		pc.addCols("Sub total ",2,6);
		pc.addCols(""+totSolByGr,1,1);
	    pc.addCols(""+CmnMgr.getFormattedDecimal(""+totMfacByGr),2,1);
		pc.addCols(" ",1,1);
		pc.addCols("Gran total ",2,6);
		pc.addCols(""+totSolFinal,1,1);
	    pc.addCols(""+CmnMgr.getFormattedDecimal(""+totMFfinal),2,1);
		pc.addCols(" ",1,1);
		
		}
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>