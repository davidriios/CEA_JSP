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
Reporte
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
CommonDataObject cdop = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String interfaz =  request.getParameter("interfaz");
String fechaInicio =  request.getParameter("fechaInicio");
String fechaFin =  request.getParameter("fechaFin");
String fg =  request.getParameter("fg");

if (appendFilter == null) appendFilter = "";
if (interfaz == null) interfaz = "";
if (fp == null) fp = "";
if (fechaInicio == null) fechaInicio = "";
if (fechaFin == null) fechaFin = "";
if (cds == null) cds = "";
if (fg == null) fg = "";

if(!fp.trim().equals("CS"))cdop = SQLMgr.getPacData(pacId, noAdmision);
 
	sbSql.append("select b.unidad_admin as centroServicio,a.habitacion, a.cama,a.codigo, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicio, to_char(a.hora_inicio,'hh12:mi am') as horaInicio, nvl(a.precio_alt,'N') as precioAlt, a.precio_alterno as precioAlterno,a.usuario_creacion as usuarioCreacion,a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion,to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, (select y.descripcion from tbl_cds_centro_servicio y where y.codigo=b.unidad_admin) as centroServicioDesc, (select y.precio from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as precio, (select y.descripcion||' - '||decode(y.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as habitacionDesc,to_char(a.fecha_final,'dd/mm/yyyy') as fechaFinal, a.hora_final horaFinal,a.pac_id||' - '|| a.admision||' - '||(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)nombre_paciente");
	if(fp.trim().equals("CS"))sbSql.append(",decode(aa.estado,'A','ACTIVA','P','PRE ADMISIONES','S','ESPECIAL','E','ESPERA','I','INACTIVO','N','ANULADA')estado_adm ");
	
	sbSql.append(" from ");
	
	if(!fp.trim().equals("CS"))
	{
		sbSql.append(" tbl_adm_cama_admision a,tbl_sal_habitacion b where a.compania=");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.compania=b.compania and a.habitacion = b.codigo ");
	}
	else
	{
	sbSql.append(" tbl_adm_cama_admision a, tbl_adm_admision aa, tbl_sal_habitacion b, tbl_sal_cama sc, tbl_adm_beneficios_x_admision aba ");
	sbSql.append(" where (a.admision = aa.secuencia and a.pac_id = aa.pac_id) and (aba.pac_id = aa.pac_id and aba.admision = aa.secuencia) and (a.cama = sc.codigo and a.habitacion = sc.habitacion and a.compania = sc.compania) and (b.codigo = a.habitacion) and aa.categoria in (1) and aa.estado in ('A', 'E', 'I', 'P') and aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' ");
	
	}
	
	
		if(fp.trim().equals("CS"))
		{
		  if(!fechaInicio.trim().equals("") && !fechaFin.trim().equals(""))
		  {
			
			if(!fechaInicio.trim().equals(""))
			{
				sbSql.append(" and (( trunc(aa.fecha_ingreso) >= to_date('");
				sbSql.append(fechaInicio);
				sbSql.append("','dd/mm/yyyy')");
			}
			if(!fechaFin.trim().equals(""))
			{
				sbSql.append(" and trunc(aa.fecha_ingreso) <= to_date('");
				sbSql.append(fechaFin);
				sbSql.append("','dd/mm/yyyy')");
			}
			
			 
			sbSql.append(" ) or  (aa.fecha_egreso  >= to_date('");
			sbSql.append(fechaInicio);
			sbSql.append("', 'dd/mm/yyyy') and aa.fecha_egreso  <= to_date('");
			 sbSql.append(fechaFin);
			sbSql.append("', 'dd/mm/yyyy')  ) "); 
			//ADmisiones de mes anterior activas. 
			/*sbSql.append(" or ( aa.fecha_ingreso <= last_day(to_date('");
			sbSql.append(fechaInicio.substring(3));
			sbSql.append("', 'mm/yyyy')-1) and ((aa.fecha_egreso  >= to_date('");
			sbSql.append(fechaInicio);
			sbSql.append("', 'dd/mm/yyyy') and aa.fecha_egreso  <= last_day(to_date('");
			sbSql.append(fechaInicio.substring(3));
			sbSql.append("', 'mm/yyyy'))) or (aa.fecha_egreso is null and aa.estado in ('A')))) ");
			*/
			sbSql.append(")  ");
			
		 }	
			if(!cds.trim().equals(""))
			{
				sbSql.append(" and b.unidad_admin=");
				sbSql.append(cds);
			}
			else if(fg.trim().equals("ADM"))
			{
				
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and b.unidad_admin in(");
					sbSql.append(" ");
						if(session.getAttribute("_cds")!=null)
							sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
						else sbSql.append("-1");
					sbSql.append(")");
				}
				
			}
		}
		else 
		{	
			sbSql.append(" and a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
		}
		
   	sbSql.append(" order by 1,2,3,a.fecha_inicio ");
	if(fp.trim().equals("CS"))sbSql.append(",a.pac_id,a.admision ");
	sbSql.append(" asc ");	
	
	al = SQLMgr.getDataList(sbSql.toString()); 
	
//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	String title = "ADMISION";
	String subtitle = (!fp.trim().equals("CS"))?"CAMAS ASIGNADAS A PACIENTES DURANTE SU ATENCION":"HABITACIONES POR CENTRO DE SERVICIOS ASIGNADAS A PACIENTES";
	String xtraSubtitle = (fp.trim().equals("CS"))?" DESDE  "+fechaInicio+" HASTA "+fechaFin:"";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	
	
		PdfCreator footer = new PdfCreator();
	    Vector dHeader = new Vector();
		
		if(fp.trim().equals("CS")){
		
		
		dHeader.addElement(".15");
		dHeader.addElement(".24");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".15");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		}
		else
		{
		dHeader.addElement(".32");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		}
		
		PdfCreator pc=null;
		 pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		if(!fp.trim().equals("CS"))pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		else pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("SALA O SECCION",1,1);
		if(fp.trim().equals("CS"))pc.addBorderCols("PACIENTE",1);
		pc.addBorderCols("HABITACION",1);
		pc.addBorderCols("CAMA",0);
		pc.addBorderCols("CATEGORIA",0);
		pc.addBorderCols("FECHA INICIO",1);
		pc.addBorderCols("HORA INICIO",1);
		pc.addBorderCols("FECHA FINAL",1);
		pc.addBorderCols("HORA FINAL",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy ="",cdsDesc ="";
	int totalCds=0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
        if(fp.trim().equals("CS"))
		{
			if(i!=0)
			{	if(!groupBy.trim().equals(cdo.getColValue("centroServicio")))
				{
					pc.setFont(7, 0,Color.blue);
					pc.addCols("TOTAL POR CENTRO DE SERVICIO  ==============="+cdsDesc+"=============="+totalCds,0,dHeader.size());
					totalCds=0;
					cdsDesc="";
					pc.addCols(" ",1,dHeader.size());
					pc.setFont(7, 0);
				}
			}
		}
		
		if(fp.trim().equals("CS"))
		{if(!groupBy.trim().equals(cdo.getColValue("centroServicio"))){
			pc.setFont(7, 0,Color.blue);
			pc.addCols(cdo.getColValue("centroServicioDesc"),0,1);}
		else pc.addCols(" ",0,1);
		pc.setFont(7, 0);
			pc.addCols(cdo.getColValue("nombre_paciente")+" ( "+cdo.getColValue("estado_adm")+" )",0,1);
			
		}else pc.addCols(cdo.getColValue("centroServicioDesc"),0,1);
		
		pc.addCols(cdo.getColValue("habitacion"),1,1);
		pc.addCols(cdo.getColValue("cama"),1,1);
		pc.addCols(cdo.getColValue("habitacionDesc"),0,1);
		pc.addCols(cdo.getColValue("fechaInicio"),1,1);
		pc.addCols(cdo.getColValue("horaInicio"),1,1);
		pc.addCols(cdo.getColValue("fechafinal"),1,1);
		pc.addCols(cdo.getColValue("horaFinal"),1,1);
		groupBy=cdo.getColValue("centroServicio");
		cdsDesc = cdo.getColValue("centroServicioDesc");
		totalCds ++;

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{if(fp.trim().equals("CS")){pc.setFont(7, 0,Color.blue);pc.addCols("TOTAL POR CENTRO DE SERVICIO  ==============="+cdsDesc+"=============="+totalCds,0,dHeader.size());}}
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
//}GET
%>