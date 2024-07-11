<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed"/>
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

ArrayList al, al2 = new ArrayList();
CommonDataObject cdoPacData = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String tipoOrden = request.getParameter("tipoOrden");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String id = request.getParameter("id");
String idOrden = request.getParameter("idOrden");
String fg = request.getParameter("fg");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if ( id == null ) id = "0";
if ( idOrden == null ) idOrden = "";
if ( tipoOrden == null ) tipoOrden = "";
if ( fg == null ) fg = "";
if ( desc == null ) desc = "";

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_SHOW_COMPLETE_NAME'),'N') as show_complete_name from dual");
CommonDataObject _cdo = SQLMgr.getData(sbSql.toString());

if (_cdo == null){
 _cdo = new CommonDataObject();
 _cdo.addColValue("show_complete_name","N");
}
boolean showCompleteName = (_cdo.getColValue("show_complete_name","N").equalsIgnoreCase("Y") || _cdo.getColValue("show_complete_name","N").equalsIgnoreCase("S"));
    
sbSql = new StringBuffer();

if (pacId.trim().equals("")) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
if (noAdmision.trim().equals("")) {

	sbSql.append("select nvl(max(secuencia),0) as noAdmision from tbl_adm_admision where pac_id = ");
	sbSql.append(pacId);
	//sbSql.append(" and estado in ('A','E')");
	CommonDataObject cdo = SQLMgr.getData(sbSql);
	noAdmision = cdo.getColValue("noAdmision");
	if (noAdmision.equals("0")) throw new Exception("El Paciente no tiene Admisión!");

}

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if ( cdoPacData ==  null ) cdoPacData = new CommonDataObject();


if ( !tipoOrden.trim().equals(""))
{
	sbFilter.append(" and a.tipo_orden=");
	sbFilter.append(tipoOrden);
}

if ( !idOrden.equals("") ){
	sbFilter.append(" and a.orden_med in (");
	sbFilter.append(idOrden);
	sbFilter.append(")");
}

sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, a.tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario ");

if (showCompleteName){
 sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");
}

sbSql.append(" ,nvl(a.confirmado,'N') as confirmado,nvl(f.observacion,f.observacion_ap)||' - CONFIRM. POR: '||a.usuario_conf||' EL: '||nvl(to_char(a.fecha_conf,'dd/mm/yyyy hh12:mi am'),' ') as comentario from tbl_sal_detalle_orden_med a, tbl_int_orden_farmacia f, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root=");
sbSql.append(noAdmision);
sbSql.append(sbFilter);
sbSql.append(" /*and a.omitir_orden='N' and a.estado_orden<>'O' */ and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios and a.pac_id = f.pac_id and a.secuencia = nvl(f.adm_cargo,f.admision)/*admision*/ and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.seguir_despachando='N' and  f.other1 = 0  order by a.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

String subtitle ="", sqlTipo = "", sqlSubTipo="";

if(seccion == null||desc.trim().equals("")){
	subtitle = "LISTA DE ORDENES MEDICAS RECHAZADAS";
	 //System.out.println("------------- The seccion is not there -----------------------");
}else{
	 subtitle = desc;
	// System.out.println("------------- The seccion is there -----------------------");
}
//System.out.println("::::::::::::::::::::::::::::SECCION:::::::::::::::::::::::::::::::::::::::::");
//System.out.println(seccion);
//System.out.println("::::::::::::::::::::::::::::SECCION:::::::::::::::::::::::::::::::::::::::::");
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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String xtraSubtitle = (fg.trim().equals(""))?"ORDENES MEDICAS":desc;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
      paramCdo = new CommonDataObject();
      paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
        cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
		//dHeader.addElement(".10");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".30");
		dHeader.addElement(".30");
		
		//dHeader.addElement(".09");
	 Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();		 
		pc.addInnerTableToCols(dHeader.size());

		pc.setFont(7, 1);
		
		pc.addBorderCols("Desde",1);
		pc.addBorderCols("Hasta",1);
        
        if (showCompleteName) pc.addBorderCols("Usuario", 1,2);
        else{
		pc.addBorderCols("Usuario",1);
		pc.addBorderCols("Usuario Ejec.",1);
        }
        
		pc.addBorderCols("Descripción",1); 
		pc.addBorderCols("Datos de Confirmacion",1); 
	pc.setTableHeader(3);//create de table header (3 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{

		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_fin"),1,1);
        
        if (showCompleteName) pc.addCols(cdo.getColValue("complete_name"),0,2);
        else{
            pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
            pc.addCols(cdo.getColValue("ejecutado_usuario"),0,1);
        }
        pc.addCols(cdo.getColValue("nombre"),0,1); 
		pc.setFont(7, 0,Color.red);
		pc.addCols(cdo.getColValue("comentario"),0,1); 
		pc.setFont(7, 0);
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>