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
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String noOrden = request.getParameter("noOrden");
String fg = request.getParameter("fg");
String exp = request.getParameter("exp");

if ( desc == null ) desc = "";
if ( noOrden == null ) noOrden = "";
if ( fg == null ) fg = "";
if ( exp == null ) exp = "";

if (appendFilter == null) appendFilter = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

sql.append(" select a.concentracion, to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica,  nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') FECHA_FIN,  a.nombre as medicamento, a.dosis, a.dosis_desc,  (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia,   a.frecuencia as descfrecuencia, a.observacion, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'--') usuario_omit, /*a.usuario_creacion*/'['||get_idoneidad(a.usuario_creacion, 1)||'] - '||b.name as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, a.codigo, decode(nvl(a.omitir_orden,'N'),'S',(select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden)||' - Por:'||omitir_usuario||' - '||to_char(omitir_fecha,'dd/mm/yyyy hh12:mi:ss am'),' ')|| nvl((select case when f.other1 = 0  then 'RECHAZADA - '||f.usuario_modificacion else case when f.other1 = 1 and f.no_cargo is null then 'APROBADA' else 'DESPACHADA' end end  as descEsctado from  tbl_int_orden_farmacia f where  a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.seguir_despachando='N' ),'POR APROBAR') descEstado,a.estado_orden as status, decode(a.stat,'Y','STAT','C','AHORA', 'R','RUTINA','NO') stat, decode(a.primer_orden,'Y','SI','NO') primer_orden,nvl(( select descripcion from tbl_sal_grupo_dosis where codigo=a.cod_grupo_dosis),' ') as descForma,a.cantidad ,nvl(get_sec_comp_param(");
sql.append(session.getAttribute("_companyId"));
sql.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad from tbl_sal_detalle_orden_med a, tbl_sec_users b where a.pac_id = ");
sql.append(pacId);
sql.append(" and a.secuencia = ");
sql.append(noAdmision);
if(!noOrden.trim().equals("")){sql.append(" and a.codigo_orden_med=");sql.append(noOrden);}
sql.append(" and b.user_name(+) = a.usuario_creacion and a.tipo_orden = 2");

if(!fg.trim().equals("CS")){ if(!fg.trim().equals("FAR"))sql.append(" and nvl(a.omitir_orden,'N')='N'"); if(!fg.trim().equals("FAR"))sql.append(" and a.estado_orden='A' ");}

sql.append(" order by a.fecha_creacion desc,a.orden_med desc");

al = SQLMgr.getDataList(sql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();

		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15");
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }

       PdfCreator pc=null;
	   boolean isUnifiedExp=false;
       pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	   if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		if(!noOrden.trim().equals("")){pc.addCols("NO. ORDEN MEDICA  -  "+noOrden,1,dHeader.size());}
		if(!fg.trim().equals("FAR"))pc.addBorderCols("MEDICAMENTOS",1,4);
		else pc.addBorderCols("MEDICAMENTOS",1,3);
		if(fg.trim().equals("FAR"))pc.addBorderCols("ESTADO",1,1);
		pc.addBorderCols("CONCENTRACIÓN",1,1); //5
        if (exp.equals("3")){
            pc.addBorderCols("DOSIS",1,1);
            pc.addBorderCols("FORMA",1,2);
        } else pc.addBorderCols("FORMA",1,3);
		pc.addBorderCols("FRECUENCIAS",1,1); // 2
		pc.addBorderCols("F. CREACIÓN",1,1);

		//pc.addBorderCols("OBSERVACIÓN",1,1); //5

	if(!noOrden.trim().equals(""))pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	else pc.setTableHeader(2);
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);
	String forma = "";
	String observ = "";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setFont(8,0);

		if(!fg.trim().equals("FAR")){if(cdo.getColValue("status").trim().equals("O") )pc.setFont(8, 1,Color.red);pc.addCols(cdo.getColValue("medicamento")+(!cdo.getColValue("status").trim().equals("A")?" *["+cdo.getColValue("estado_orden")+"]* ":""),0,4);pc.setFont(8,0);}
		else pc.addCols(cdo.getColValue("medicamento"),0,3);
		if(fg.trim().equals("FAR")){pc.setFont(8, 1,Color.blue);pc.addCols(cdo.getColValue("descEstado"),1,1);pc.setFont(8,0);}
		pc.addCols(cdo.getColValue("concentracion"),1,1);

		observ = cdo.getColValue("observacion");
		if ( observ.indexOf("<>") >= 1 ){
			forma = observ.substring(0,observ.indexOf("<>"));
		}else{forma = ""+cdo.getColValue("descForma");}
        
        if (exp.equals("3")){
            pc.addCols(cdo.getColValue("dosis_desc"),1,1);
            pc.addCols(forma,1,2);
        }else pc.addCols(forma,1,3);
		
		pc.addCols(cdo.getColValue("descfrecuencia"),0,1);
		pc.addCols(cdo.getColValue("fecha_creacion"),0,1);

		pc.setFont(8,2);
		pc.addCols("Vía:",0,1);
		pc.addCols(cdo.getColValue("descvia"),0,2);
		pc.addCols("F.Suspensión:",0,1);
		pc.addCols(cdo.getColValue("fecha_fin"),0,2);
		pc.addCols("Solicitado por:",0,1);
        pc.addCols(cdo.getColValue("usuario_crea"),0,3);
        
        pc.setFont(8,2);
        if (exp.equals("3")) {
            pc.addCols("STAT:",0,1,Color.red);
            pc.addCols(cdo.getColValue("stat"),0,1,Color.red);
            pc.addCols("Primer Orden?",1,2);
            pc.addCols(cdo.getColValue("primer_orden"),0,6);
        }
        

		if ( observ.indexOf("<>") >= 1 ){
			 pc.addCols("Obser.:"+(observ.substring(observ.indexOf("<>")+2)),0,dHeader.size());
		}else{
			pc.addCols("Obser.:"+observ,0,dHeader.size());
		}
		
		if(cdo.getColValue("addCantidad").equals("S") ){pc.addCols("Cantidad a Despachar.:__________________________________________",0,6);
		pc.setFont(9,0,Color.red);pc.addCols("Cantidad Solicitada: "+cdo.getColValue("cantidad"),0,4);
		pc.setFont(8,0);
		}		
		else pc.addCols("Cantidad a Despachar.:__________________________________________",0,dHeader.size());


		pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}//form

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>