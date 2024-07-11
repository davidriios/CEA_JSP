<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String appendFilter = (request.getParameter("appendFilter")==null?"":request.getParameter("appendFilter"));
String selId = (request.getParameter("selId")==null?"":request.getParameter("selId"));
String fp = (request.getParameter("fp")==null?"":request.getParameter("fp"));

StringBuffer sbSql = new StringBuffer();

sbSql.append("select ");
if (fp.equalsIgnoreCase("por_edad")){
  sbSql.append(" distinct ");
}
sbSql.append(" lpad(s.id, 10, '0') id_sol_plan, s.afiliados as tipo_plan, t.tipo forma_pago,  decode(s.estado,'A',to_char(s.fecha_modificacion,'dd/mm/yyyy')) as fecha_aprobacion, c.codigo id_cliente,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) ||' '|| c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_cliente, nvl((select sum(costo_mensual) from tbl_pm_sol_contrato_det where id_cliente = s.id_cliente and id_solicitud = s.id), 0) costo_mensual, decode(s.afiliados,1,'Plan Familiar','Plan Tercera Edad') tipo_plan_desc, s.estado, decode(s.estado,'A','Aprobado','I','Inactivo','P','Pendiente') as estado_desc, get_age(c.fecha_nacimiento,sysdate,'d') as edad, s.id, decode(t.tipo, 'V', 'Voluntario', 'T', 'Tarjeta Credito', 'C', 'ACH') forma_pago_desc, to_char(c.fecha_nacimiento,'dd/mm/yyyy') as fn, (select nombre_banco banco from tbl_adm_ruta_transito r where r.ruta = t.cod_banco) banco, t.num_tarjeta_cta, c.id_paciente, c.telefono||'/'||c.telefono_movil telefonos, to_char(s.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan from vw_pm_cliente c , tbl_pm_solicitud_contrato s, tbl_pm_cta_tarjeta t  ");

if (fp.equalsIgnoreCase("por_edad")){
    sbSql.append(" , tbl_pm_sol_contrato_det dc ");
}   

sbSql.append(" where s.fecha_ini_plan is not null ");
if (!fp.equalsIgnoreCase("por_edad")){
    sbSql.append(" and c.codigo = s.id_cliente  ");
} else{
    sbSql.append(" and s.estado in ('A') and s.id = dc.id_solicitud  and (s.id_cliente = c.codigo or dc.id_cliente = c.codigo) and c.codigo is not null ");
}

if (!selId.equals("")) sbSql.append(" and s.id = "+selId);

		sbSql.append(" and s.id = t.id_solicitud and t.estado = 'A'");
sbSql.append(appendFilter);

if (fp.equalsIgnoreCase("forma_pago")) sbSql.append(" order by 3, s.id ");
else if (fp.equalsIgnoreCase("por_edad")) sbSql.append(" order by 2, 14");
else sbSql.append(" order by 2, s.fecha_modificacion desc ");

al = SQLMgr.getDataList(sbSql.toString());

if(request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = cDateTime;
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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "MIEMBROS Y DEPENDIENTES";
    
    if (fp.equalsIgnoreCase("forma_pago")) subtitle = "MIEMBROS X FORMAS DE PAGO";
    else if (fp.equalsIgnoreCase("por_edad")) subtitle = "MIEMBROS X EDAD";
   
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector tblContent = new Vector();
	tblContent.addElement(".10"); //Contrato 10
	tblContent.addElement(".19"); //Cliente
	tblContent.addElement(".08"); //Edad
	tblContent.addElement(".08"); //F.Aprob
    if(!fp.equalsIgnoreCase("por_edad")){
        tblContent.addElement(".08"); //Cuota
    }
		
	tblContent.addElement(".08"); //Estado
	tblContent.addElement(".12"); //F.Aprob
	//tblContent.addElement(".08"); //F.Aprob
	tblContent.addElement(".08"); //F.Aprob
	tblContent.addElement(".08"); //F.Aprob
	tblContent.addElement(".08"); //F.Aprob

	pc.setNoColumnFixWidth(tblContent);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, tblContent.size());

	pc.setFont(8, 1);
	pc.addCols("", 0,tblContent.size());

	pc.addBorderCols("#Contrato",1,1);
	pc.addBorderCols("Cliente",0,1);
    if(!fp.equalsIgnoreCase("forma_pago")){
        pc.addBorderCols("Edad",1,1);
        pc.addBorderCols("F."+(fp.equalsIgnoreCase("por_edad")?"Nac.":"Aprob."),1,1);
    }else{
        pc.addBorderCols("No Cuenta",1,1);
        pc.addBorderCols("Banco",0,1);
    }
    if(!fp.equalsIgnoreCase("por_edad")){
        pc.addBorderCols("Cuota",2,1);
    }
	pc.addBorderCols("Estado",1,1);
	pc.addBorderCols("Identificacion",1,1);
	//pc.addBorderCols("Fecha Nac.",1,1);
	pc.addBorderCols("Fecha Ing.",1,1);
	pc.addBorderCols("Fecha Sal.",1,1);
	pc.addBorderCols("Telefonos",1,1);

	pc.setTableHeader(3);
    
    String groupBy1 = "";
    String grpHdr = fp.equalsIgnoreCase("forma_pago") ? "forma_pago" : "tipo_plan";
    String grpHdrDesc = fp.equalsIgnoreCase("forma_pago") ? "forma_pago_desc" : "tipo_plan_desc";

	if (al.size()==0) {
		pc.addCols("No existen datos a cerca de planes!",1,tblContent.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);
            
            if (!groupBy1.equals(cdo1.getColValue(grpHdr))){
                pc.setFont(9, 1,Color.black);
                pc.addCols("["+cdo1.getColValue(grpHdr)+"] "+ cdo1.getColValue(grpHdrDesc),0,tblContent.size(), Color.lightGray);
			}

            pc.setFont(8, 0);
            pc.addCols(cdo1.getColValue("id_sol_plan"),1,1);
            pc.addCols(cdo1.getColValue("nombre_cliente"),0,1);
            if(!fp.equalsIgnoreCase("forma_pago")){
            pc.addCols(cdo1.getColValue("edad"),1,1) ;
            pc.addCols(fp.equalsIgnoreCase("por_edad")?cdo1.getColValue("fn"):cdo1.getColValue("fecha_aprobacion"),1,1);
            }else{
              pc.addCols((!cdo1.getColValue("num_tarjeta_cta").equals("")?CmnMgr.getDecryptToShow(cdo1.getColValue("num_tarjeta_cta")):""),1,1) ;
              pc.addCols(cdo1.getColValue("banco"),1,1);
            }
            if(!fp.equalsIgnoreCase("por_edad")){
                pc.addCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("costo_mensual")),2,1) ;
            }
            pc.addCols(cdo1.getColValue("estado_desc"),1,1) ;
            pc.addCols(cdo1.getColValue("id_paciente"),1,1) ;
            if(fp.equalsIgnoreCase("por_edad"))pc.addCols(cdo1.getColValue("fecha_ini_plan"),1,1) ;
            else pc.addCols(cdo1.getColValue("fn"),1,1) ;
            pc.addCols("",1,1) ;
            pc.addCols(cdo1.getColValue("telefonos"),1,1) ;
            
            groupBy1 = cdo1.getColValue(grpHdr);

		}//End For

		pc.setFont(10,1);
		pc.addCols(al.size()+" Registro"+(al.size()>1?"s":"")+" en total",0,tblContent.size());

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>