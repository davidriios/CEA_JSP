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
<!-- Desarrollado por: Tirza Monteza               -->
<!-- Reporte: Listado de Pacientes Activos x Aseg.  -->
<!-- Reporte: ADM100160                           -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 09/07/2010                            -->

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
String aseguradora = request.getParameter("aseguradora");
String compania = (String) session.getAttribute("_companyId");
StringBuffer sbSql = new StringBuffer();

if (sala == null) sala = "";
if (aseguradora == null) aseguradora = "";
if (appendFilter == null) appendFilter = "";

if(!compania.equals(""))
{
 appendFilter += " and ad.compania = "+compania;
}

if (!aseguradora.equals(""))
{
 appendFilter += " and aba.empresa =  "+aseguradora;
}

CommonDataObject cdoH = SQLMgr.getData("select get_sec_comp_param("+compania+",'ADM_VER_MONTO_CONSUMO') as ver_consumo  from dual");
if(cdoH==null) {cdoH = new CommonDataObject();cdoH.addColValue("ver_consumo","N");}

sbSql.append("select decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre nombre, decode(p.f_nac,null,to_char(p.fecha_nacimiento,'dd/mm/yyyy'),to_char(p.f_nac,'dd/mm/yyyy'))||' ('||ad.codigo_paciente||' - '||ad.secuencia||')' as admision, ad.pac_id,ad.secuencia, nvl(ad.corte_cta,0)as corte_cta, decode(p.provincia||p.sigla||p.tomo||p.asiento||p.d_cedula, null, p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||' '||p.d_cedula) cedula, decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip ,  getfingreso_pactivos(to_char(ad.fecha_ingreso,'dd/mm/yyyy'),ad.secuencia,ad.pac_id,aca.cama) as fecha_ingreso, aba.empresa, decode(ae.nombre,null,decode(ad.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO'),ae.nombre) e_nombre,  sh.unidad_admin as centro,sc.estado_cama ,nvl(aca.cama,'POR ASIGNAR') as v_cama,cs.descripcion as centro_desc, initcap(DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO,m.APELLIDO_DE_CASADA)||' '||m.PRIMER_NOMBRE)  medico, aba.poliza, aba.certificado, GetDiasEstimados(ad.pac_id,ad.secuencia,ad.corte_cta,aba.empresa, ad.dias_estimados) as fecha_estimada, (select ax.fecha_ingreso from tbl_adm_admision ax where ax.pac_id = ad.pac_id and ax.secuencia = ad.adm_root ) as fingreso, ad.dias_hospitalizados as dias_hospitalizado,  GetPorVencer(ad.pac_id,ad.secuencia,to_char((select ax.fecha_ingreso from tbl_adm_admision ax where ax.pac_id = ad.pac_id and ax.secuencia = ad.adm_root ))) porVencer");

if(cdoH.getColValue("ver_consumo").trim().equals("S")){ sbSql.append(",case when ad.estado in ('A','E') then nvl((select sum((decode(z.tipo_transaccion,'D',-z.cantidad,z.cantidad)) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania = ad.compania and z.pac_id = ad.pac_id and z.fac_secuencia = ad.secuencia),0) else (select sum(grang_total) from tbl_fac_factura where pac_id=ad.pac_id and admi_secuencia =ad.secuencia and estatus <> 'A' ) end as consumo "); }

sbSql.append("   from tbl_adm_admision ad, tbl_adm_paciente p ,tbl_sal_cama sc,tbl_sal_habitacion sh,tbl_adm_cama_admision aca,tbl_cds_centro_servicio cs, tbl_adm_beneficios_x_admision aba ,tbl_adm_empresa ae, tbl_adm_medico m where ad.estado='A' and ad.categoria in (1,5) and ad.pac_id=p.pac_id and aca.compania=sc.compania and aca.pac_id=ad.pac_id and aca.admision=ad.secuencia and aca.fecha_final is null and aca.habitacion=sc.habitacion and aca.cama=sc.codigo and sc.compania=sh.compania and sc.habitacion=sh.codigo and cs.codigo=sh.unidad_admin(+) and  (ad.pac_id = aba.pac_id(+) and ad.secuencia = aba.admision(+) and aba.prioridad(+) = 1 and  nvl(aba.estado(+),'A') = 'A' /*and aba.secuencia(+) = 1*/ and aba.empresa = ae.codigo(+)) and m.codigo = ad.medico ");
sbSql.append(appendFilter);
sbSql.append(" order by aba.empresa, cs.descripcion, decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre ");

al = SQLMgr.getDataList(sbSql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String mon = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
    String month = null;
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	boolean isLandscape = ((cdoH.getColValue("ver_consumo").trim().equals("S"))?true:false);
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "PACIENTES ACTIVOS POR ASEGURADORA   AL   "+fecha;
	String xtraSubtitle = "(*) 48 Horas antes del vencimiento de los días autorizados";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		if(cdoH.getColValue("ver_consumo").trim().equals("S"))dHeader.addElement(".16");else dHeader.addElement(".19");
		dHeader.addElement(".04");
		dHeader.addElement(".09");
		if(cdoH.getColValue("ver_consumo").trim().equals("S"))dHeader.addElement(".04");else dHeader.addElement(".05");
		dHeader.addElement(".06");
		if(cdoH.getColValue("ver_consumo").trim().equals("S"))dHeader.addElement(".09");else dHeader.addElement(".10");
 		dHeader.addElement(".06");
		dHeader.addElement(".03");
		if(cdoH.getColValue("ver_consumo").trim().equals("S"))dHeader.addElement(".10");else dHeader.addElement(".11");
		dHeader.addElement(".06");
		dHeader.addElement(".04");
		dHeader.addElement(".02");
		if(cdoH.getColValue("ver_consumo").trim().equals("S"))dHeader.addElement(".06");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(5, 0);
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
	pc.setTableHeader(2);
	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	String groupByAseg = "", groupBySala = ""; // agrupar por Aseg, sala
	int	tAseg = 0, tSala = 0;   // totales por aseg, sala, general
	double cdsTotal = 0.00; 
	double total = 0.00,asegTotal= 0.00;
	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);
		//Inicio --Agrupamiento por Aseg
		if (!groupByAseg.equalsIgnoreCase(cdo.getColValue("e_nombre")))
		{ // groupBy
					if (i != 0)
					{//i-1
						// totales por sala
			    	pc.setFont(8, 1, Color.BLUE);
						pc.addCols("Total de pacientes en "+groupBySala+" . . . " +tSala,0,dHeader.size(),cHeight);
						tSala = 0;
			    	// totales por aseg.
			    	pc.setFont(8, 1);
						pc.addCols("TOTAL DE PACIENTES DE "+groupByAseg+" . . . " +tAseg,0,dHeader.size(),cHeight);
						tAseg = 0;
						groupBySala ="";

					}//i-1

					pc.setFont(8, 1);
					pc.addCols(" ",0,dHeader.size(),cHeight);
					pc.addCols("Aseguradora:   "+cdo.getColValue("e_nombre"),0,dHeader.size(),cHeight);
		}//Final --Agrupamiento por Aseg


		if (!groupBySala.equalsIgnoreCase(cdo.getColValue("centro_desc")))
		{ // groupBy
				if (i != 0 && tSala != 0)
				{//i-1
						// totales por sala
			    	pc.setFont(8, 1);
						pc.setFont(8, 1, Color.BLUE);
						pc.addCols("Total de pacientes en "+groupBySala+" . . . " +tSala,0,dHeader.size(),cHeight);
						tSala = 0;
				}//i-1

			tSala = 0;
			pc.setFont(8, 1, Color.BLUE);
			pc.addCols("Sala o Sección:   "+cdo.getColValue("centro_desc"),0,dHeader.size(),cHeight);
			pc.setFont(7, 1);
			pc.addBorderCols("Nombre del Paciente",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("PID",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Cédula",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Cama",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Ingreso",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Admisión",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Fecha Estimada",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Días Hos.",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Médico",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Póliza",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols("Certif.",1,1,cHeight * 2,Color.lightGray);
			pc.addBorderCols(" .",1,1,cHeight * 2,Color.lightGray);
			if(cdoH.getColValue("ver_consumo").trim().equals("S"))pc.addBorderCols("Consumo",1,1,cHeight * 2,Color.lightGray);
		}//Final --Agrupamiento por Aseg


		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("nombre"),0,1,cHeight);
		pc.addCols(cdo.getColValue("pac_id"),1,1,cHeight);
		pc.addCols(cdo.getColValue("cedula"),1,1,cHeight);
		pc.addCols(cdo.getColValue("v_cama"),1,1,cHeight);
		pc.addCols(cdo.getColValue("fingreso"),1,1,cHeight);
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("secuencia")),1,1,cHeight);
		pc.addCols(cdo.getColValue("fecha_estimada"),1,1,cHeight);
		pc.addCols(cdo.getColValue("dias_hospitalizado"),1,1,cHeight);
		pc.addCols(cdo.getColValue("medico"),0,1,cHeight);
		pc.addCols(cdo.getColValue("poliza"),1,1,cHeight);
		pc.addCols(cdo.getColValue("certificado"),1,1,cHeight);
		pc.addCols(cdo.getColValue("porVencer"),1,1,cHeight);
		if(cdoH.getColValue("ver_consumo").trim().equals("S")){pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("consumo")),2,1);
		cdsTotal += Double.parseDouble(cdo.getColValue("consumo")); 
		asegTotal += Double.parseDouble(cdo.getColValue("consumo")); 
		total += Double.parseDouble(cdo.getColValue("consumo"));
		}
		tAseg++;
		tSala++;
		

		groupByAseg = cdo.getColValue("e_nombre");
		groupBySala = cdo.getColValue("centro_desc");
	}//for i

	if (al.size() == 0)
	{
	  pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
	  pc.setFont(8, 1, Color.BLUE);
		pc.addCols("Total de pacientes en "+groupBySala+" . . . " +tSala,0,dHeader.size(),cHeight);
	  pc.addCols(" ",0,dHeader.size(),cHeight);

		pc.addCols("TOTAL DE PACIENTES DE "+groupByAseg+" . . . " +tAseg,0,dHeader.size(),cHeight);
	  pc.addCols(" ",0,dHeader.size(),cHeight);

	  pc.setFont(8, 1);
	  pc.addCols("TOTAL DE PACIENTES ACTIVOS: "+al.size(),0,dHeader.size());
	}

  pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
