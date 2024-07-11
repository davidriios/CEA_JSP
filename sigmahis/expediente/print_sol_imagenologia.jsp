<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
StringBuffer sql = new StringBuffer();
CommonDataObject cdo1,cdoPacData = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codSolicitud = request.getParameter("codSolicitud");
String codSolicitudDet = request.getParameter("codSolicitudDet");
String area = request.getParameter("area");
String fg = request.getParameter("fg");
String sql2="";
String fechaSol = request.getParameter("fecha");
String interfaz = request.getParameter("interfaz");
String estado = request.getParameter("estado");
String fechaHasta = request.getParameter("fechaHasta");
String cdsSel = request.getParameter("cdsSel");

if (appendFilter == null) appendFilter = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (codSolicitud == null) codSolicitud = "";
if (codSolicitudDet == null) codSolicitudDet = "";
if (fechaSol == null) fechaSol = "";
if (fechaHasta == null) fechaHasta = "";
if (cdsSel == null) cdsSel = "";

if (area == null) area = "";
if (fg == null) fg = "";
if (interfaz == null) interfaz = "";
if (estado == null) estado = "";

if(!pacId.trim().equals(""))cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

 sql.append(" select x.* from (select decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente,b.edad, decode(i.tipo_admision,1,nvl(j.abreviatura,j.descripcion)) as dsp_admitido, a.cod_procedimiento, decode(c.observacion,null,c.descripcion,c.observacion) as nombre_procedimiento, c.precio, f.primer_nombre||' '||f.segundo_nombre||' '||f.primer_apellido||' '||f.segundo_apellido as nombre_medico, f.codigo as medico_codigo, nvl(g.cama,' ') as cama, decode(a.estado,'S','PENDIENTE','T','TRAMITE','F','APROBADO','A','ANULADO','')as estado, nvl(a.comentario,' ') as comentario, nvl(a.observacion, ' ') as observacion, a.prioridad, a.usuario_creac as usuario_creacion, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.codigo, a.csxp_admi_secuencia as admision, a.cod_solicitud, b.codigo as cod_paciente, b.pac_id, e.cod_centro_servicio, i.categoria, i.embarazada,a.cod_solicitud||' - '||a.codigo codSolicitud,get_admCorte(b.pac_id,i.adm_root) as admCorte");

 sql.append(" , case when a.interfaz='BDS' then (  select  decode( om.causa,'Y','  --> TRANSFUNDIR HOY(2-3 HR)','Z','  --> CRUZAR/RESERVAR PRN  ','X',' - TRANSFUNDIR URGENTE(1HR - 1:30MIN)  ','W','  --> PROCEDIMIENTO PROGRAMADO ','R','  --> RESERVAR ') ||' '||decode(unidad_dosis,null,'',' UNIDAD DOSIS:'||nvl(unidad_dosis,cantidad))||decode(motivo,null,'',' MOTIVO:'||(select descrip_motivo from  tbl_sal_motivo_sol_proc where codigo=motivo))||decode(observacion_enf,NULL,'',' OBSER. ADIC: '||observacion_enf)||decode(vol_pediatrico,null,'','  VOL. PEDIATRICO: '||vol_pediatrico)||decode(om.frecuencia,null,'',' FREC: '||om.frecuencia) as observacion     from tbl_sal_detalle_orden_med om where om.pac_id= a.pac_id and om.secuencia=a.csxp_admi_secuencia and om.interfaz='BDS' and om.orden_med = a.orden_med and  om.procedimiento=a.cod_procedimiento and rownum=1  ) else ' ' end as causa ");
 sql.append(" from tbl_cds_detalle_solicitud a, vw_adm_paciente b,tbl_cds_procedimiento c, /*tbl_cds_tipo_dieta d, */ tbl_cds_solicitud e, tbl_adm_medico f, tbl_adm_atencion_cu g, tbl_adm_admision i, tbl_cds_centro_servicio j/*,tbl_cds_procedimiento_x_cds k*/ where (a.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz in(");
  if(interfaz.trim().equals("LIS"))sql.append("'LIS','BDS'");
  else{sql.append("'");  sql.append(interfaz);sql.append("'"); }  
  sql.append("))) and a.estudio_dev='N' and a.pac_id=b.pac_id and a.cod_procedimiento=c.codigo(+) and a.cod_solicitud=e.codigo and a.csxp_admi_secuencia=e.admi_secuencia and a.pac_id=e.pac_id and e.med_codigo_resp=f.codigo and e.admi_secuencia=g.secuencia(+) and e.pac_id=g.pac_id(+) and a.csxp_admi_secuencia=i.secuencia and a.pac_id=i.pac_id and i.centro_servicio=j.codigo /* and i.estado in ('A','E')*/ ");
 
 
 if(!fechaSol.trim().equals(""))
 {
	sql.append(" and trunc(a.fecha_solicitud)>=to_date('");
	sql.append(fechaSol);
	sql.append("','dd/mm/yyyy')");
 } 
 if(!fechaHasta.trim().equals(""))
 {
	sql.append(" and trunc(a.fecha_solicitud)<=to_date('");
	sql.append(fechaHasta);
	sql.append("','dd/mm/yyyy')");
 }

 if(!pacId.trim().equals(""))
 {
	sql.append(" and e.pac_id =");
	sql.append(pacId);
 }
 if(!noAdmision.trim().equals(""))
 {
	sql.append(" and e.admi_secuencia =");
	sql.append(noAdmision);
 }
 if(!codSolicitud.trim().equals(""))
 {
	sql.append(" and a.cod_solicitud =");
	sql.append(codSolicitud);
 }
 if(!codSolicitudDet.trim().equals(""))
 {
	sql.append(" and a.codigo =");
	sql.append(codSolicitudDet);
 }
 if(!area.trim().equals(""))
 {
	sql.append(" and a.cod_centro_servicio =");
	sql.append(area);
 }
 if(!cdsSel.trim().equals(""))
 {
	sql.append(" and a.cod_sala =");
	sql.append(cdsSel);
 }

 if(!estado.trim().equals(""))
 {
	sql.append(" and a.estado ='");
	sql.append(estado);
	sql.append("'");
 }else sql.append(" and a.estado = 'S' ");
// if(fg.trim().equals("Area"))
 //{
	sql.append(" and a.estudio_realizado = 'N' ");
 //}

 sql.append(" ) x where exists (select null from tbl_adm_admision where pac_id=x.pac_id and secuencia =admCorte and  estado in ('A','E') ) order by x.pac_id, x.admision,x.cod_solicitud,x.codigo asc ");

 al = SQLMgr.getDataList(sql.toString());

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
	boolean isLandscape = true;
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
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "SOLICITUDES DE "+((fg.trim().equals("LAB"))?"LABORATORIOS":" IMAGENOLOGÍA");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".20");
		dHeader.addElement(".05");
		dHeader.addElement(".25");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		if(!pacId.trim().equals("")) pdfHeader(pc, _comp, cdoPacData,xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		else pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		
		pc.addCols(" "+((fg.trim().equals("Area"))?"Datos Generales del Paciente":"EXAMENES SOLICITADOS"),1,dHeader.size());	
		
		if(!pacId.trim().equals("")){
		pc.addBorderCols("NO. SOL.",0,1);
			pc.addBorderCols("CPT",0,1);
			pc.addBorderCols("PROCEDIMIENTO",0,2);
			pc.addBorderCols(""+((fg.trim().equals("LAB"))?"OBSERVACION":"SOSPECHA"),0,3);
			pc.addBorderCols("ESTADO",0,1);
		pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	
	}else pc.setTableHeader(2);
	//table body
	String groupBy ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize, 0);
		if(pacId.trim().equals(""))
		{
			if(!groupBy.trim().equals(cdo.getColValue("pac_id")))
			{
			//04FE3054347  PASCAL ACCARD 56 733-1  SALA 7-A 
			pc.addCols(" ",0,dHeader.size());
			pc.setFont(contentFontSize, 0,Color.blue);
			pc.addCols("Ced/Pas. "+cdo.getColValue("identificacion"),0,2);
			pc.addCols("Nombre. "+cdo.getColValue("nombre_paciente"),0,2);
			pc.addCols("Edad "+cdo.getColValue("edad"),0,1);
			pc.addCols("Cama "+cdo.getColValue("cama"),0,2);
			pc.addCols("Admitido:"+cdo.getColValue("dsp_admitido"),0,1);
			pc.setFont(contentFontSize, 0);
			pc.addBorderCols("NO. SOL.",0,1);
			pc.addBorderCols("CPT",0,1);
			pc.addBorderCols("PROCEDIMIENTO",0,2);
			pc.addBorderCols(""+((fg.trim().equals("LAB"))?"OBSERVACION":"SOSPECHA"),0,3);
			pc.addBorderCols("ESTADO",0,1);
			pc.addCols(" ",0,dHeader.size());
			}
		}
		
		pc.addCols(" "+cdo.getColValue("codSolicitud"),0,1);
		pc.addCols(" "+cdo.getColValue("cod_procedimiento"),0,1);
		pc.addCols(" "+cdo.getColValue("nombre_procedimiento"),0,2);
		pc.addCols(" "+cdo.getColValue("comentario"),0,3);
		pc.addCols(" "+cdo.getColValue("estado"),0,1);
		if(!cdo.getColValue("causa").trim().equals(""))pc.addCols(" "+cdo.getColValue("causa") ,2,dHeader.size());
		
		
		groupBy = cdo.getColValue("pac_id");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
		//pc.addCols(" ",0,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		//pc.addCols(" ",0,1);
		
	if (al.size() == 0){ if(!fg.trim().equals("Area"))pc.addCols("No existen registros",1,dHeader.size());}
	else 
	{
		
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("DATOS ESPECIALES",0,dHeader.size());
		
		pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.5f,0.5f,0.5f,50);
		
		pc.addCols(" ",0,1);
		pc.addBorderCols(" ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);
		pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);
		pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,1);
		pc.addCols("TECNICO ",1,2);
		pc.addCols(" ",0,1);
		
		pc.addCols("ENFERMERA ",1,1);
		pc.addCols(" ",0,1);
				
		pc.addCols("MEDICO",1,1);
		pc.addCols(" ",0,1);
		if(!fg.trim().equals("LAB")){
		pc.addCols("NUM. DE PLACAS:___________________",0,2);
		pc.addCols(" ",0,6);}
		
		
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>