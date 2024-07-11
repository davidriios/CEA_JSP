<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "Listado de Pacientes Activos x Sección"  -->
<!-- Reporte: ADM_10010                           -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 15/03/2010                            -->

<%

/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");
String compania = (String) session.getAttribute("_companyId");
String time = CmnMgr.getCurrentDate("ddmmyyyyhh12mmissam");

if (sala == null) sala = "";
if (appendFilter == null) appendFilter = "";

if(!compania.equals(""))
{
 appendFilter += " and a.compania = "+compania;
}
if (!sala.equals(""))
{
 //appendFilter += "and sh.unidad_admin like "+sala;
 appendFilter += " and a.centro_servicio like "+sala;
}

sql = "select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.pac_id, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as pasaporte, decode(b.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte)  cedulaPamd, a.compania, a.pac_id as pacId, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode (b.estado_civil, 'CS', ' ' || nvl(b.apellido_de_casada, ' '), '')) as nombrePaciente, c.nombre_corto as categoriaDesc, a.centro_servicio as centroServicio, d.descripcion as centroServicioDesc,(select nombre from tbl_adm_empresa where codigo =  a.aseguradora) aseguradora, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cdsCama,a.centro_servicio) else a.centro_servicio end as area/*es el cds para expediente*/, case when a.categoria=1 and a.hosp_directa='N' then nvl(x.cama,' ') else ' ' end as cama, a.medico, nvl(trunc(months_between(sysdate,a.fecha_nacimiento)/12),0) as key from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d, (select distinct g.pac_id, g.admision, g.cama, f.unidad_admin as cdsCama from tbl_adm_cama_admision g, tbl_sal_cama e, tbl_sal_habitacion f where g.compania=e.compania and g.cama=e.codigo and g.habitacion=e.habitacion and e.habitacion=f.codigo and e.compania=f.compania and g.fecha_final is null and g.hora_final is null) x where a.pac_id=b.pac_id and a.categoria=c.codigo and a.centro_servicio=d.codigo and a.compania=1 and a.pac_id=x.pac_id(+) and a.secuencia=x.admision(+) and a.estado='A' "+appendFilter+" order by centroservicio, nvl(a.fecha_ingreso,a.fecha_creacion) desc, nombrePaciente, a.secuencia";


/*sql = "select decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre nombre, decode(p.f_nac,null,to_char(p.fecha_nacimiento,'dd/mm/yyyy'),to_char(p.f_nac,'dd/mm/yyyy')) fecha_nacimiento, ad.codigo_paciente as codpac,ad.pac_id,ad.secuencia, nvl(ad.corte_cta,0)as corte_cta, decode(p.provincia||p.sigla||p.tomo||p.asiento||p.d_cedula, null, p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||' '||p.d_cedula) cedula, decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip ,  getfingreso_pactivos(to_char(ad.fecha_ingreso,'dd/mm/yyyy'),ad.secuencia,ad.pac_id,aca.cama) as fecha_ingreso, decode(ae.nombre,null,decode(ad.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO'),ae.nombre) e_nombre,  sh.unidad_admin as centro,sc.estado_cama ,nvl(aca.cama,'POR ASIGNAR') as v_cama,cs.descripcion as centro_desc  from tbl_adm_admision ad, tbl_adm_paciente p ,tbl_sal_cama sc,tbl_sal_habitacion sh,tbl_adm_cama_admision aca,tbl_cds_centro_servicio cs, tbl_adm_beneficios_x_admision aba ,tbl_adm_empresa ae where ad.estado='A' and ad.categoria in (1,5) and ad.pac_id=p.pac_id and aca.compania=sc.compania and aca.pac_id=ad.pac_id and aca.admision=ad.secuencia and aca.fecha_final is null and aca.habitacion=sc.habitacion and aca.cama=sc.codigo and sc.compania=sh.compania and sc.habitacion=sh.codigo and cs.codigo=sh.unidad_admin(+) and  (ad.pac_id = aba.pac_id(+) and ad.secuencia = aba.admision(+) and aba.prioridad(+) = 1 and  nvl(aba.estado(+),'A') = 'A' and aba.secuencia(+) = 1 and aba.empresa = ae.codigo(+))"+appendFilter+" order by sh.unidad_admin, 1, 9 " ;*/

/*System.out.println("::::::::::::::::::::::::::::::::::::::::::::");
System.out.println(sql);
System.out.println("::::::::::::::::::::::::::::::::::::::::::::");*/

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String mon = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
    String month = null;
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

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
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "PACIENTES ACTIVOS POR SECCION";
	String xtraSubtitle = "AL "+fecha;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".26");
		dHeader.addElement(".06");
		dHeader.addElement(".29");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".09");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".05");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

     PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("Nombre del Paciente",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("VIP/ D / N",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("Aseguradora",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("Ingreso",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("Cama",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("Cédula",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. Nac.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("Adm.",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	int pxs = 0;
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);
		//Inicio --Agrupamiento por Sala / Sección
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("centroservicio")+" ] "+cdo.getColValue("centroserviciodesc")))
		{ // groupBy
			if (i != 0)
			{//i-1
		    	pc.setFont(8, 1,Color.red);
				pc.addCols("TOTAL DE PACIENTES X SALA O SECCION: "+pxs,0,dHeader.size(),cHeight);
				pxs = 0;
			}//i-1
			pc.setFont(8, 1,Color.blue);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols("[ "+cdo.getColValue("centroservicio")+" ] "+cdo.getColValue("centroserviciodesc"),0,dHeader.size(),cHeight);
		}//Final --Agrupamiento por Sala / Sección

		pc.setFont(7, 0);
			pc.addBorderCols(""+cdo.getColValue("nombrePaciente"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("vip"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("aseguradora"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fechaIngreso"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cama"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("pasaporte"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fechaNacimiento"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("pac_id"),1,1,cHeight);
			pc.addBorderCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("noAdmision")),0,1);
		pxs++;

		groupBy = "[ "+cdo.getColValue("centroservicio")+" ] "+cdo.getColValue("centroserviciodesc");
	}//for i

	if (al.size() == 0)
	{
	  pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
	  pc.setFont(8, 1,Color.red);
	  pc.addCols("TOTAL DE PACIENTES X SALA O SECCION: "+pxs,0,dHeader.size());
	  pc.addCols(" ",0,dHeader.size(),cHeight);
	  pc.setFont(8, 1,Color.black);
	  pc.addCols("TOTAL DE PACIENTES ACTIVOS: "+al.size(),0,dHeader.size());
	}
    pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
