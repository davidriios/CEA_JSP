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
String fp = request.getParameter("fp");
String estado = request.getParameter("estado");
String all = request.getParameter("all");

String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if ( id == null ) id = "0";
if ( idOrden == null ) idOrden = "";
if ( tipoOrden == null ) tipoOrden = "";
if ( fg == null ) fg = "";
if ( fp == null ) fp = "";
if ( desc == null ) desc = "";
if ( estado == null ) estado = "";
if ( all == null ) all = "n";

sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_SHOW_COMPLETE_NAME'),'N') as show_complete_name,nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape,nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_ORM_ADD_OBSER'),'N') addObserv from dual");
CommonDataObject _cdo = SQLMgr.getData(sbSql.toString());
 

if (_cdo == null){
 _cdo = new CommonDataObject();
 _cdo.addColValue("show_complete_name","N");
 _cdo.addColValue("is_landscape","N");
 _cdo.addColValue("addObserv","N"); 
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
	if(fg.trim().equals("FAR"))sbFilter.append(" and a.codigo_orden_med in (");	
	else sbFilter.append(" and a.orden_med in (");
	sbFilter.append(idOrden);
	sbFilter.append(")");
}

if (fp.trim().equalsIgnoreCase("exp_kardex")) {
    // sbFilter.append(" and a.ejecutado = 'S'");
}
if ( !estado.equals("") ) {
	if (estado.equalsIgnoreCase("PP")) sbFilter.append(" and ((a.omitir_orden = 'N' and a.estado_orden = 'A') or (a.ejecutado = 'N' and a.estado_orden = 'S'))");
	else { sbFilter.append(" and a.estado_orden = '"); sbFilter.append(estado); sbFilter.append("'"); } 
}

sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(nvl(a.omitir_fecha,a.fecha_suspencion),'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario, decode(a.interfaz,'BDS','BANCO DE SANGRE',too.descripcion) as tipoOrden,a.observacion ");

sbSql.append(", case when a.omitir_fecha is not null then ' --> ANULADO EL '||to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am') when a.fecha_suspencion is not null then ' --> OMITIDO EL '||to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') else ' ' end as omitidoSuspendido,  decode(a.stat,'Y','STAT','C','AHORA', 'R','RUTINA',' ') stat ");

if (showCompleteName){
 sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");
}
sbSql.append(",(select descripcion from tbl_sal_via_admin where codigo=a.via) descVia,a.dosis_desc, a.frecuencia ,decode(a.tipo_orden,1,(select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio)||' / ', ' ') as cdsDesc ");

sbSql.append(" , (select (select '['||codigo||'] '||decode(sexo,'F','DRA. ','M','DR. ')||primer_nombre||decode(segundo_nombre,null,' ',segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ', segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',apellido_de_casada)) from tbl_adm_medico where codigo= x.medico) from tbl_sal_orden_medica x where x.pac_id=a.pac_id and x.secuencia=a.secuencia and x.codigo=a.orden_med ) as medico ");

sbSql.append(",(case when a.interfaz ='BDS' then decode( a.causa,'Y','  --> TRANSFUNDIR HOY(2-3 HR)','Z','  --> CRUZAR/RESERVAR PRN  ','X',' - TRANSFUNDIR URGENTE(1HR - 1:30MIN)  ','W','  --> PROCEDIMIENTO PROGRAMADO ','R','  --> RESERVAR ') else '' END) as causa,case when a.interfaz='BDS' then decode(a.cantidad,null,'',' CANTIDAD:'||a.cantidad)||decode(a.unidad_dosis,null,'',' UNIDAD DOSIS:'||a.unidad_dosis)||decode(a.motivo,null,'',' MOTIVO:'||(select descrip_motivo from  tbl_sal_motivo_sol_proc where codigo=motivo))||decode(a.observacion_enf,NULL,'',' OBSER. ADIC: '||a.observacion_enf)||decode(a.vol_pediatrico,null,'',' VOL. PEDIATRICO: '||a.vol_pediatrico)||decode(a.frecuencia,null,'',' FREC: '||a.frecuencia) else ' ' end as xtra,a.interfaz  ");

sbSql.append(" from tbl_sal_detalle_orden_med a, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z, tbl_sal_tipo_orden_med too where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root=");
sbSql.append(noAdmision); 
sbSql.append(sbFilter);
sbSql.append(" and a.tipo_orden=too.codigo(+) ");
sbSql.append(" /*and a.omitir_orden='N' and a.estado_orden<>'O' */ and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios ");

if (!id.equals("") && !id.equals("0")) {
  sbSql.append(" and a.orden_med=");
  sbSql.append(id); 
}

if (all.equalsIgnoreCase("y")) {
	sbSql.append(" order by coalesce(a.omitir_fecha,a.fecha_suspencion,a.fecha_creacion) desc");
} else {
	if (expVersion.equals("3")) sbSql.append(" order by a.fecha_creacion desc ");
	else sbSql.append(" order by a.fecha_creacion desc ");
}

System.out.println("------------------------------------ expVersion = "+expVersion);


al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

String subtitle ="", sqlTipo = "", sqlSubTipo="";

if(seccion == null||desc.trim().equals("")){
	subtitle = "LISTA DE ORDENES MEDICAS";
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
	if(_cdo.getColValue("addObserv","N").equalsIgnoreCase("S"))height = 72 * 14f;//
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
	String xtraSubtitle = (fg.trim().equals("")||fg.trim().equals("FAR"))?"ORDENES MEDICAS":desc;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

     
    if (_cdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || _cdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
        cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
	
		if(!_cdo.getColValue("addObserv","N").equalsIgnoreCase("S")){
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		if (showCompleteName)dHeader.addElement(".04");
		else dHeader.addElement(".08");
		
		if (showCompleteName)dHeader.addElement(".20");
		else dHeader.addElement(".16");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".22");
		dHeader.addElement(".06"); }
		else{
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		if (showCompleteName)dHeader.addElement(".04");
		else dHeader.addElement(".08");
		
		if (showCompleteName)dHeader.addElement(".15");
		else dHeader.addElement(".16");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".15");
		dHeader.addElement(".06"); 
		dHeader.addElement(".12"); 
		}
	 
 	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(dHeader);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();		 
		pc.addInnerTableToCols(dHeader.size());

		pc.setFont(7, 1);
		//pc.addBorderCols("Adm.",1);
		if(fg.trim().equals("OV"))pc.addBorderCols("Fecha",1,2);
		else {
		pc.addBorderCols("Fecha Prescripción",1);
		pc.addBorderCols("Fecha Omisión",1);}
        
        if (showCompleteName) pc.addBorderCols("Usuario Creac.", 1,2);
        else{
		pc.addBorderCols("Usuario Creac.",1);
		pc.addBorderCols("Usuario Ejec.",1);
        }
        pc.addBorderCols("M. Solicita",1);
		pc.addBorderCols("Tipo Orden",1);
		pc.addBorderCols("Sub Orden Varios",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Estado",1);
		if(_cdo.getColValue("addObserv","N").equalsIgnoreCase("S"))pc.addBorderCols("Observacion",1);
	pc.setTableHeader(3);//create de table header (3 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{

		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		//pc.addCols(cdo.getColValue("secuenciaCorte"),1,1);
		if(fg.trim().equals("OV"))pc.addCols(cdo.getColValue("fecha_inicio"),1,2);
		else{pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_fin"),1,1);}
        
        if (showCompleteName) pc.addCols(cdo.getColValue("complete_name"),0,2);
        else{
            pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
            pc.addCols(cdo.getColValue("ejecutado_usuario"),0,1);
        }
        pc.addCols(cdo.getColValue("medico"),0,1);
		pc.addCols(/*cdo.getColValue("tipo_ordenvarios")+" " +*/cdo.getColValue("tipoOrden"),0,1);
		pc.addCols(/*cdo.getColValue("subtipo_ordenvarios")+" " +*/cdo.getColValue("desc2"),0,1);
		
		if(cdo.getColValue("tipo_orden").trim().equals("2")) {
            String xtra = "        - Via Admin: "+cdo.getColValue("descVia"," ");
            
            if (expVersion.equals("3") && !cdo.getColValue("dosis_desc"," ").trim().equals("") ) xtra += "       - DOSIS:"+cdo.getColValue("dosis_desc");
            
            if (!cdo.getColValue("frecuencia"," ").trim().equals("")) xtra += "       - FREC.:"+cdo.getColValue("frecuencia");
            if (!cdo.getColValue("stat"," ").trim().equals("")) xtra += "  "+cdo.getColValue("stat");
            
            pc.addCols(cdo.getColValue("nombre"," ")+xtra+cdo.getColValue("omitidoSuspendido"),0,1);
        }
		else pc.addCols(cdo.getColValue("cdsDesc")+" "+cdo.getColValue("nombre")+cdo.getColValue("omitidoSuspendido"),0,1);
		
		pc.addCols(cdo.getColValue("estado_orden"),1,1);
		//if(_cdo.getColValue("addObserv","N").equalsIgnoreCase("S"))pc.addCols(cdo.getColValue("observacion"),0,1);
		if(_cdo.getColValue("addObserv","N").equalsIgnoreCase("S"))pc.addCols(cdo.getColValue("observacion")+" - "+cdo.getColValue("causa")+" "+cdo.getColValue("xtra"),0,1);
		//if(cdo.getColValue("interfaz","Z").equalsIgnoreCase("BDS"))pc.addCols(cdo.getColValue("causa")+" "+cdo.getColValue("xtra"),2,dHeader.size());

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(7, 0);
		pc.addCols("Total Registro(s) "+al.size(),0,dHeader.size());
		pc.addCols("  ",1,dHeader.size());
		
		pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f,25.0f);
		pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f,25.0f);
		pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Preparado Por",1,3,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Autorizado Por",1,1,0.0f,0.5f,0.0f,0.0f);
		
		if(_cdo.getColValue("addObserv","N").equalsIgnoreCase("S"))pc.addBorderCols(" ",1,2,0.0f,0.0f,0.0f,0.0f);
		else pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
	}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>