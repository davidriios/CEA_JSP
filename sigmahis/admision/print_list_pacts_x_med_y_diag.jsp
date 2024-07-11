<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
CommonDataObject cdo = new CommonDataObject();
String sql = "";
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String categoriaDiag   = request.getParameter("categoriaDiag");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String horaini        = request.getParameter("horaini");
String horafin        = request.getParameter("horafin");
String medico        = request.getParameter("medico");

if (categoria == null) categoria       = "";
if (centroServicio 	== null) centroServicio  = "";
if (codAseguradora 	== null) codAseguradora  = "";
if (categoriaDiag 	== null) categoriaDiag   = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (horaini == null) horaini = "";
if (horafin == null) horafin = "";
if (medico == null) medico = "";


sbFilter.append(" and aa.compania = ");
sbFilter.append(compania);
if (!categoria.trim().equals("")) {
  sbFilter.append(" and aa.categoria = "); sbFilter.append(categoria);
}
if (!centroServicio.trim().equals("")) {
    sbFilter.append(" and  aa.centro_servicio = "); sbFilter.append(centroServicio); 
}
if (!categoriaDiag.trim().equals("")) {
 sbFilter.append(" and d.categoria = "); sbFilter.append(categoriaDiag);
}
if (!codAseguradora.trim().equals("")) {
  sbFilter.append(" and ab.empresa = "); sbFilter.append(codAseguradora);
}
if (!fechaini.trim().equals("")) {
  sbFilter.append(" and trunc(aa.fecha_ingreso) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("', 'dd/mm/yyyy')");
}
if (!fechafin.trim().equals("")) {
  sbFilter.append(" and trunc(aa.fecha_ingreso) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("', 'dd/mm/yyyy')");
}
if (!horaini.trim().equals("")) {
  sbFilter.append(" and to_date(to_char(aa.am_pm,'hh12:mi pm'),'hh12:mi pm') >= to_date('"); sbFilter.append(horaini); sbFilter.append("','hh12:mi pm')");
}
if (!horafin.trim().equals("")) {
  sbFilter.append(" and to_date(to_char(aa.am_pm,'hh12:mi pm'),'hh12:mi pm') <= to_date('"); sbFilter.append(horafin); sbFilter.append("','hh12:mi pm')");
}

if (!medico.trim().equals("")){
  sbFilter.append(" and aa.medico = '");
  sbFilter.append(medico);
  sbFilter.append("'");
}

sql =
" select (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')') as codigoPaciente,  pac.primer_apellido||' '||pac.segundo_apellido||' '||pac.apellido_de_casada||' '||pac.primer_nombre||' '||pac.segundo_nombre as nombrePaciente, pac.sexo as sexo, aa.medico codMedico,  med.primer_nombre||' '||med.primer_apellido nombreMedico, pac.pac_id as pacId,  nvl(trunc(months_between(sysdate,nvl(pac.f_nac,aa.fecha_nacimiento))/12),0) as edadPac,  getHabitacion(aa.compania, aa.pac_id, aa.secuencia) habitacion, diag.diagnostico, decode(diag.tipo,'I','INGRESO: '||diag.diagnostico||' - '||decode(d.observacion,null,d.nombre,d.observacion) ,'S','SALIDA: '||diag.diagnostico||' - '||decode(d.observacion,null,d.nombre,d.observacion)) as diagnostico_desc, diag.orden_diag as ordenDiag,  aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia as secuenciaAdmision, aa.usuario_creacion as usuarioCrea, aa.categoria as codCategoria, aca.descripcion as descripcionCategoria,  ab.empresa as codAseguradora, emp.nombre as descAseguradora, aa.estado,  aa.centro_servicio as areaAtencion, cds.descripcion as descripcionCentro,  aa.fecha_creacion, aa.compania, to_char(aa.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(aa.am_pm,'hh12:mi pm') as fechaIngreso, trunc(nvl(aa.fecha_egreso,sysdate))-trunc(aa.fecha_ingreso) as diasEst from tbl_adm_admision aa, tbl_adm_paciente pac, tbl_adm_beneficios_x_admision ab, tbl_adm_tipo_admision_cia t,  tbl_adm_categoria_admision aca, tbl_adm_empresa emp, tbl_cds_centro_servicio cds, tbl_adm_medico med  ,tbl_adm_diagnostico_x_admision diag, tbl_cds_diagnostico d  where  (aa.fecha_nacimiento = pac.fecha_nacimiento and aa.codigo_paciente = pac.codigo) and  (aa.categoria = t.categoria and aa.tipo_admision = t.codigo)   and  (aa.centro_servicio = cds.codigo) and (aa.medico = med.codigo) and  (aa.pac_id = ab.pac_id(+) and aa.secuencia = ab.admision(+) and  ab.prioridad(+) = 1 and nvl(ab.estado(+),'A') = 'A' and  ab.empresa = emp.codigo(+)) and  t.categoria = aca.codigo and aa.estado  in ('A','E','I') "+sbFilter.toString()+" and(diag.pac_id = aa.pac_id and diag.admision = aa.secuencia and d.codigo = diag.diagnostico) order by aa.medico, med.primer_nombre||' '||med.primer_apellido, diag.diagnostico,ordenDiag, pac.primer_apellido||' '||pac.segundo_apellido||' '||pac.apellido_de_casada||' '||pac.primer_nombre||' '||pac.segundo_nombre";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month =  fecha.substring(3, 5);;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//792
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
	String subtitle = "PACIENTES POR MEDICOS Y DIAGNOSTICOS";
	String xtraSubtitle = "DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".05");

	String groupByMed = "", groupByDiag = "";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EDAD",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("HABIT.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID/ ADMISION.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EMPRESA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F.INGRESO",1,1,cHeight * 2,Color.lightGray);
    	pc.addBorderCols("DIAS EST.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("USER",1,1,cHeight * 2,Color.lightGray);

	pc.setTableHeader(2);
    
    int totXmed = 0, totXdiag = 0, fCounter = 0;

	for (int i=0; i<al.size(); i++){
        
        cdo = (CommonDataObject) al.get(i);

        if (!groupByMed.equalsIgnoreCase("[ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico"))){
        
           if (i != 0){
                pc.setFont(8, 1);
                pc.addCols("TOTAL DE PACIENTES X DIAGNOSTICO: "+totXdiag,0,dHeader.size(),cHeight);
                pc.addCols("TOTAL DE PACIENTES X MEDICO: "+totXmed,0,dHeader.size(),cHeight);
                pc.addCols(" ",0,dHeader.size(),cHeight);
                totXdiag = 0;
                totXmed = 0;
            }
            pc.setFont(8, 1,Color.blue);
            pc.addCols("MED: [ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico"),0,dHeader.size(),cHeight);
            
            groupByDiag = "";
            groupByMed = "";
        }
        
        if (!groupByDiag.equalsIgnoreCase(cdo.getColValue("diagnostico"))){
        
           if (i != 0){
                if(totXdiag>0){pc.setFont(8, 1);
                pc.addCols("TOTAL DE PACIENTES X DIAGNOSTICO: "+totXdiag,0,dHeader.size(),cHeight);
                pc.addCols(" ",0,dHeader.size(),cHeight);
                totXdiag = 0;}
            }
            pc.setFont(8, 1,Color.red);
            pc.addCols(cdo.getColValue("diagnostico_desc"),0,dHeader.size(),cHeight);
        }
        
        pc.setFont(8, 0);
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("sexo"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("edadPac"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);
		pc.addCols(cdo.getColValue("pacId")+"-"+(cdo.getColValue("secuenciaAdmision")),0,1);
        pc.addCols("["+cdo.getColValue("codAseguradora")+"] "+cdo.getColValue("descAseguradora"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(" "+cdo.getColValue("diasEst"),1,1);
		pc.addCols(" "+cdo.getColValue("usuarioCrea"),0,1,cHeight);
		
        totXmed++;
        totXdiag++;
        fCounter++;

        groupByMed = "[ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico");
        groupByDiag = cdo.getColValue("diagnostico");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else{
        pc.addCols("TOTAL DE PACIENTES X DIAGNOSTICO: "+totXdiag,0,dHeader.size(),cHeight);
        pc.addCols("TOTAL DE PACIENTES X MEDICO: "+totXmed,0,dHeader.size(),cHeight);
        
        pc.setFont(8, 1,Color.red);
        pc.addCols(" ",0,dHeader.size(),cHeight);
        pc.addCols(" ",0,dHeader.size(),cHeight);
        pc.addCols("TOTAL DE PACIENTES: "+fCounter,0,dHeader.size(),cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

