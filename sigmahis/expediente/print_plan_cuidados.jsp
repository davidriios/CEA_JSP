<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
Reporte sal10080
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
ArrayList al1 = new ArrayList();
ArrayList al2= new ArrayList();
ArrayList al3= new ArrayList();
ArrayList al4= new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String cds = request.getParameter("cds");

String descSala ="",filter="";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

filter= " and to_date(to_char(a.fecha_orden,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fecha.substring(0,10)+"','dd/mm/yyyy')";
if (appendFilter == null) appendFilter = "";
if (cds == null) cds = "";

if (pacId != null && !pacId.trim().equals("")&& !(pacId.toUpperCase()).trim().equals("UNDEFINED")) appendFilter += " and a.pac_id = "+pacId;
if (noAdmision != null && !noAdmision.trim().equals("") && !(noAdmision.toUpperCase()).trim().equals("UNDEFINED")) appendFilter += " and a.secuencia = "+noAdmision;
sql="select descripcion from tbl_cds_centro_servicio where codigo = "+cds;
cdo1 = SQLMgr.getData(sql);

descSala = cdo1.getColValue("descripcion");
if (cds.trim().equals("")) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
//else appendFilter += " and i.unidad_admin = "+cds;

CommonDataObject cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

 sql="select to_char(b.f_nac,'dd/mm/yyyy') as fecha_nacimiento, a.codigo_paciente,a.secuencia admision, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am') as fecha_ingreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, nvl(a.medico,' ')medico, a.pac_id as pacId, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombre_paciente, a.estado, nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),a.fecha_nacimiento)/12),0) as edad,g.habitacion||decode(g.habitacion,null,'','/'||g.cama) cama, i.unidad_admin as cds ,nvl(j.nombre,' ') as nombreEmpresa, m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico,cds.descripcion descCds,nvl(k.descDiagnostico,' ') descDiagnostico from tbl_adm_admision a, vw_adm_paciente b/*, tbl_adm_atencion_cu d, tbl_sal_signo_paciente e*/,  tbl_adm_cama_admision g, tbl_sal_cama h, tbl_sal_habitacion i ,(select   a.empresa codigo, e.nombre,a.pac_id, a.admision from tbl_adm_beneficios_x_admision a, tbl_adm_empresa e  where (a.empresa = e.codigo) and a.prioridad = 1 and a.estado ='A') j, tbl_adm_medico m , tbl_cds_centro_servicio cds, (select da.diagnostico,da.pac_id, da.admision,decode(observacion,null, d.nombre,d.observacion)descDiagnostico from tbl_adm_diagnostico_x_admision da, tbl_cds_diagnostico d where da.diagnostico = d.codigo and da.tipo = 'I' and da.orden_diag=1) k where a.compania="+(String) session.getAttribute("_companyId")+" and a.estado in ('A') and a.categoria=1  and a.pac_id=g.pac_id and a.secuencia=g.admision and g.compania=h.compania and g.cama=h.codigo and g.habitacion=h.habitacion and h.habitacion=i.codigo and h.compania=i.compania  and g.fecha_final is null and g.hora_final is null and a.pac_id=b.pac_id and a.medico=m.codigo(+) and a.pac_id = j.pac_id(+) and a.secuencia = j.admision(+) and i.unidad_admin = cds.codigo(+) and a.pac_id = k.pac_id(+) and a.secuencia = k.admision(+) "+appendFilter+" order by to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc ";
al1 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String title = "PLAN DE CUIDADOS DE PACIENTES EN SALA  -  "+descSala;
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	Vector dHeader = new Vector();
		dHeader.addElement(".49");
		dHeader.addElement(".02");
		dHeader.addElement(".49"); //
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
        if (paramCdo == null) {
          paramCdo = new CommonDataObject();
          paramCdo.addColValue("is_landscape","N");
        }
        if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
            cdoPacData.addColValue("is_landscape",""+isLandscape);
        }
        
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	Vector detCol = new Vector();
		detCol.addElement(".04");
		detCol.addElement(".32");
		detCol.addElement(".04");
	Vector detCol1 = new Vector();
		detCol1.addElement(".40");
	Vector detCol2 = new Vector();
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");

Vector infoCol2 = new Vector();
		infoCol2.addElement(".15");
		infoCol2.addElement(".35");
		infoCol2.addElement(".25");
		infoCol2.addElement(".25");

		Vector infoCol3 = new Vector();
		infoCol3.addElement(".80");
		infoCol3.addElement(".20");
		
		



		for (int i=0; i<al1.size(); i++)
		{
				cdo1 = (CommonDataObject) al1.get(i);
				//System.out.println(" paciente == ----------   "+cdo1.getColValue("nombre_paciente"));
				pc.setNoColumnFixWidth(infoCol);
				pc.createTable("paciente"+i,false);
				pc.setVAlignment(0);


				pc.setNoInnerColumnFixWidth(infoCol);

				pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));

				pc.createInnerTable();
					pc.setFont(5, 0);
					pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.10f,0.0f,0.0f,0.0f);

					pc.setFont(9, 0);
					pc.addInnerTableCols("Nombre del Paciente:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("nombre_paciente"),0,3);
					pc.addInnerTableCols("Nombre Medico:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("nombre_medico"),0,1);

					pc.addInnerTableCols("No. de Identificación:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("identificacion"),0,1);
					pc.addInnerTableCols("Fecha Nac.:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("fecha_nacimiento"),0,1);
					pc.addInnerTableCols("Fecha Ingreso:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("fecha_ingreso"),0,1);

					pc.addInnerTableCols("Codigo Paciente:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("codigo_paciente"),0,1);
					pc.addInnerTableCols("No. Admision:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("admision"),0,1);
					pc.addInnerTableCols("Habitacion/Cama:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("cama"),0,1);

					pc.addInnerTableCols("Edad:",0,1);
					pc.addInnerTableCols(cdo1.getColValue("edad"),0,1);
					pc.addInnerTableCols("Diagnostico",0,1);
					pc.addInnerTableCols(cdo1.getColValue("descDiagnostico"),0,3);


					pc.setFont(3, 0);
					pc.addInnerTableCols(" ",0,infoCol.size());
					pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.0f,0.10f,0.0f,0.0f);
					pc.resetVAlignment();
				pc.addInnerTableToCols(dHeader.size());


				//System.out.println("agregando paciente == "+i);
				
				String _pacId = cdo1.getColValue("pacId");
				String _noAdmision = "2";//cdo1.getColValue("admision");



		sql="select a.pac_id,a.secuencia ,a.orden_med,a.codigo, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy'),' ') fechaM,nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, nvl(a.dosis,' ')dosis, nvl(a.frecuencia,' ')frecuencia,nvl(a.nombre,' ')nombre,nvl(a.observacion,' ')observacion,nvl(to_char(a.via),' ') via,nvl(b.descripcion,' ')descripcion, a.fecha_creacion from TBL_SAL_DETALLE_ORDEN_MED a, tbl_sal_via_admin b where a.tipo_orden = 2 and a.via = b.codigo(+) and a.pac_id = "+_pacId+"   and a.secuencia = "+_noAdmision+" union  select 0,0 ,0,0, ' ',' ', ' ', ' ',' ',' ',' ',' ', null  from dual order by 13 desc";
		al = SQLMgr.getDataList(sql);

		sql = "select a.pac_id,a.secuencia,a.orden_med,a.codigo, a.nombre,  nvl(to_char(a.fecha_inicio,'dd/mm/yyyy'),' ')fechaInicio,nvl(to_char(a.fecha_inicio,'dd/mm/yyyy hh12:mi am'),' ')fechaD, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFinal, a.observacion observD, decode(a.tipo_tubo,'G','GOTEO', 'N','BOLO',' ') tipoTubo,b.descripcion descDieta, a.fecha_creacion from tbl_sal_detalle_orden_med a, TBL_CDS_TIPO_DIETA b where a.tipo_orden = 3 and a.cod_tipo_dieta = b.codigo(+) and a.pac_id = "+_pacId+"  and a.secuencia = "+_noAdmision+" and a.estado_orden = 'A'  union select 0,0,0,0, ' ',  ' ',' ', ' ', ' ', ' ',' ', null from dual order by 12 desc";

		al2 = SQLMgr.getDataList(sql);


		sql = "select a.pac_id,a.secuencia ,a.orden_med,a.codigo, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy'),' ') fechaInicio,nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, a.nombre,a.observacion, b.descripcion, a.fecha_creacion from TBL_SAL_DETALLE_ORDEN_MED a, tbl_sal_tratamiento b where a.tipo_orden = 4 and a.cod_tratamiento = b.codigo(+) and a.pac_id = "+_pacId+"  and a.secuencia = "+_noAdmision+"  and a.estado_orden = 'A' /* "+filter+" */ union select 0,0 ,0,0, ' ',' ', ' ',' ', ' ', null from dual order by 10 desc   ";

		al3 = SQLMgr.getDataList(sql);

		sql="select a.pac_id,a.secuencia ,a.orden_med,a.codigo,nvl(to_char(a.fecha_orden,'dd/mm/yyyy'),' ') fechaOrden, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy') ,' ') fechaInicio,nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, a.nombre,a.observacion, decode(b.observacion,null,b.descripcion,b.observacion)descripcion from TBL_cds_detalle_solicitud a, tbl_cds_procedimiento b where a.tipo_orden = 1 and a.procedimiento = b.codigo(+) and a.pac_id = "+_pacId+"  and a.secuencia = "+_noAdmision +" and a.estado_orden = 'A' "+filter+ " union select 0,0 ,0,0, ' ',' ', ' ',' ', ' ',' ' from dual  ";

		System.out.println("========================================================================================================");
		sql="select a.pac_id,a.csxp_admi_secuencia ,a.cod_solicitud orden_med,a.codigo,nvl(to_char(a.fecha_solicitud,'dd/mm/yyyy'),' ') fechaOrden, nvl(to_char(a.fecha_creac,'dd/mm/yyyy') ,' ') fechaInicio,nvl(to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, nvl(a.comentario,' ') nombre, ' ' observacion, decode(b.observacion,null,b.descripcion,b.observacion)descripcion, a.fecha_creac from TBL_cds_detalle_solicitud a, tbl_cds_procedimiento b where a.cod_procedimiento = b.codigo(+) /*and a.pac_id =  "+_pacId+" and a.csxp_admi_secuencia = "+_noAdmision+"*/ and a.estado in('S','T')   union ";

		sql +="select a.pac_id,a.secuencia ,a.orden_med,a.codigo,nvl(to_char(a.fecha_orden,'dd/mm/yyyy'),' ') fechaOrden, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy') ,' ') fechaInicio,nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin, a.nombre,a.observacion, decode(b.observacion,null,b.descripcion,b.observacion)descripcion, a.fecha_creacion from TBL_SAL_DETALLE_ORDEN_MED a, tbl_cds_procedimiento b where a.tipo_orden = 1 and a.procedimiento = b.codigo(+) and a.pac_id = "+_pacId+"  and a.secuencia = "+_noAdmision +" and a.estado_orden = 'A' "+filter+ " union select 0,0 ,0,0, ' ',' ', ' ',' ', ' ',' ', null from dual order by 11 desc ";
		al4 = SQLMgr.getDataList(sql);
		System.out.println("========================================================================================================");

	pc.setFont(9, 0);
	pc.resetVAlignment();
	pc.setNoColumnFixWidth(infoCol2);
	pc.createTable("medicamento"+i,false,0,400);
	pc.addBorderCols("MEDICAMENTOS",1,4,Color.gray);
		pc.addBorderCols("Fecha",1,1);
		pc.addBorderCols("Medicamento",1,1);
		pc.addBorderCols("via",1,1);
		pc.addBorderCols("Frec.",1,1);

		for (int j=0; j<al.size(); j++)
		{
				pc.setFont(9, 0);
				CommonDataObject cdo = (CommonDataObject) al.get(j);
				pc.addBorderCols(""+cdo.getColValue("fechaM"),1,1);
				pc.addBorderCols(""+cdo.getColValue("nombre"),0,1);
				pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1);
				pc.addBorderCols(""+cdo.getColValue("frecuencia"),0,1);
		}
		pc.setFont(9, 0);
		pc.addBorderCols(" ",1,4);
		pc.addBorderCols(" ",1,4);
		pc.addBorderCols(" ",1,4);

		pc.setFont(9, 0);
		pc.resetVAlignment();
		pc.setNoColumnFixWidth(infoCol3);

		pc.createTable("tratamientos"+i,false,0,414);
		pc.addBorderCols("TRATAMIENTOS",1,2,Color.gray);
		pc.addBorderCols("Descripcion",0,1);
		pc.addBorderCols("Fecha",1,1);

		for (int j=0; j<al3.size(); j++)
		{
				pc.setFont(9, 0);
				CommonDataObject cdo = (CommonDataObject) al3.get(j);
				pc.addBorderCols(""+cdo.getColValue("nombre"),0,1);
				pc.addBorderCols(""+cdo.getColValue("fechaInicio"),1,1);
		}
		pc.setFont(9, 0);
		pc.addBorderCols(" ",1,3);
		pc.addBorderCols(" ",1,3);
		pc.addBorderCols(" ",1,3);
		pc.setFont(9, 0);
		pc.resetVAlignment();
		pc.setNoColumnFixWidth(infoCol3);

		pc.createTable("dietas"+i,false,0,400);
		pc.addBorderCols("DIETAS",1,2,Color.gray);
		pc.addBorderCols("Descripcion",0,1);
		pc.addBorderCols("Fecha",1,1);

		for (int j=0; j<al2.size(); j++)
		{
				pc.setFont(9, 0);
				CommonDataObject cdo = (CommonDataObject) al2.get(j);
				pc.addBorderCols(""+cdo.getColValue("nombre"),0,1);
				pc.addBorderCols(""+cdo.getColValue("fechaInicio"),1,1);
		}

		pc.setFont(9, 0);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",1,2);

		pc.setFont(9, 0);
		pc.resetVAlignment();
		pc.setNoColumnFixWidth(infoCol3);

		pc.createTable("otros"+i,false,0,414);
		pc.addBorderCols("PROC. PENDIENTES / OTROS",1,2,Color.gray);
		pc.addBorderCols("Descripcion",0,1);
		pc.addBorderCols("Fecha",1,1);

		for (int j=0; j<al4.size(); j++)
		{
				pc.setFont(9, 0);
				CommonDataObject cdo = (CommonDataObject) al4.get(j);
				pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1);
				pc.addBorderCols(""+cdo.getColValue("fechaInicio"),1,1);
		}

		pc.setFont(9, 0);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",1,2);
		pc.addBorderCols(" ",1,2);


			/*	pc.setFont(9, 1);
				pc.addTableToCols("medicamento",0,1);
				pc.addCols(" ",0,1);
				pc.addTableToCols("tratamientos",0,1);
				pc.addCols(" ",0,3);
				pc.addTableToCols("dietas",0,1);
				pc.addCols(" ",0,1);
				pc.addTableToCols("otros",0,1);
				pc.setVAlignment(0);*/


		}
        
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

		for (int k=0; k<al1.size(); k++)
		{



				pc.addCols(" ",0,3);
				if(k!=0) pc.addCols(" ",0,3,Color.gray);
					pc.addCols(" ",0,3);
					pc.resetVAlignment();
					pc.setFont(9, 1);
					pc.addTableToCols("paciente"+k,0,3);
					pc.addTableToCols("medicamento"+k,0,1);
					pc.addCols(" ",0,1);
					pc.addTableToCols("tratamientos"+k,0,1);
					pc.addCols(" ",0,3);

					pc.addTableToCols("dietas"+k,0,1);
					pc.addCols(" ",0,1);
					pc.addTableToCols("otros"+k,0,1);
					pc.setVAlignment(0);

		}
 
  if (al.size()<1 && al1.size() <1 && al2.size()<1 && al3.size()<1 && al4.size()<1)
		pc.addCols(" NO HAY DATA ",1,dHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>