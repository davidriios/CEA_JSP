<%@ page errorPage="../error.jsp"%>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String periodo = request.getParameter("periodo");
String anio = request.getParameter("anio");
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (appendFilter == null) appendFilter = "";

if ( !empId.equals("") ){ appendFilter += " AND ce.emp_id = "+empId;}




sql = "select all primer_nombre||' '||decode(sexo,'F',decode(apellido_casada,null,primer_apellido,decode(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido) nombre_emp, em.num_empleado, to_char(stde.fecha,'dd/mm/yyyy') fecha_emp, stde.ta_a, stde.ta_hent, stde.ta_hsal, decode(stde.ta_a,'n', stde.ta_libre,'N',stde.ta_libre, stde.ta_a) as ta_libre, stde.tp_a, stde.tp_hent, stde.tp_hsal, stde.tp_libre, stdt.te_a, to_char(stdt.te_hent,'hh12:mi') te_hent, to_char(stdt.te_hsal,'hh12:mi') te_hsal, to_char(stdt.te_hent,'am') t_he, to_char(stdt.te_hsal,'am') t_hs, stde.codigo_asignado_programa, TO_NUMBER(TO_CHAR(stde.ta_hent,'HH12')) ||' / '||TO_NUMBER(TO_CHAR(stde.ta_hsal,'HH12')) codigo_turno_asignado, stde.codigo_posterior_programa, TO_NUMBER(TO_CHAR(stde.tp_hent,'HH12')) ||' / '||TO_NUMBER(TO_CHAR(stde.tp_hsal,'HH12')) codigo_turno_posterior, stdt.observaciones observaciones_extra, ue.descripcion nombre_unidad, ue.codigo ue_codigo, to_char(ca.trans_desde,'dd/mm/yyyy') trans_desde, to_char(ca.trans_hasta,'dd/mm/yyyy') trans_hasta, decode(mod(ca.periodo,2),'0','2da QUINCENA DEL MES DE ','1ra QUINCENA DEL MES DE ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' AÑO '||to_char(ca.fecha_inicial,'yyyy') quincena, 'PERIODO DEL '||'"+desde+"'|| ' AL '||'"+hasta+"' as titulo, to_char(to_date(TO_CHAR(stde.fecha,'DD/MM/YYYY'),'dd/mm/yyyy'),'DY','NLS_DATE_LANGUAGE=SPANISH') dia from tbl_pla_empleado em, tbl_pla_ct_empleado ce, tbl_pla_st_det_empleado stde, tbl_pla_st_det_turext stdt, tbl_pla_ct_grupo ue, tbl_pla_calendario ca where ((ce.emp_id = stde.emp_id) and (ce.compania = stde.compania) and (ce.num_empleado = em.num_empleado) and (ce.grupo = stde.ue_codigo) and (stde.compania = em.compania and stde.emp_id = em.emp_id)  and (stde.compania = ue.compania and stde.ue_codigo = ue.codigo) and (stde.compania = stdt.compania) and (stde.ue_codigo = stdt.ue_codigo) and (stde.anio = stdt.anio) and (stde.periodo = stdt.periodo) and (stde.emp_id = stdt.emp_id) and (to_date(to_char(stde.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date(to_char(stdt.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and (ca.tipopla = 1) and (ca.periodo =  "+periodo+") and (stde.ue_codigo = "+grupo+") and (stde.compania = "+session.getAttribute("_companyId")+")  and stdt.anio_pago = "+anio+" and stdt.periodo_pago = "+periodo+" and (stdt.aprobado = 'S')) "+appendFilter+" order by em.num_empleado, em.primer_nombre, em.primer_apellido, em.apellido_casada, stde.fecha";

///(ce.ubicacion_fisica like "+area+") and
 al = SQLMgr.getDataList(sql);
 	System.err.println(sql);

 sql = "select ue.descripcion nombre_unidad, ue.codigo ue_codigo, decode(mod(ca.periodo,2),'0','2da QUINCENA DEL MES DE ','1ra QUINCENA DEL MES DE ')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') ||' AÑO '||to_char(ca.fecha_inicial,'yyyy') quincena, 'PERIODO DEL '||'"+desde+"'|| ' AL '||'"+hasta+"' as titulo from tbl_pla_calendario ca, tbl_pla_ct_grupo ue where ue.codigo="+grupo+" and ue.compania = "+session.getAttribute("_companyId")+" and ca.tipopla = 1 and ca.periodo =  "+periodo;
cdo1 = SQLMgr.getData(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECURSOS HUMANOS";
	String subtitle = " REPORTE DE SOBRETIEMPO ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".06");
		dHeader.addElement(".20");
		dHeader.addElement(".04");
		dHeader.addElement(".10");
		dHeader.addElement(".03");
		dHeader.addElement(".10");
		dHeader.addElement(".03");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".03");
		dHeader.addElement(".10");
		dHeader.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(6, 1);
		pc.addCols(" [ A ] ",2,11);
		pc.addCols("a) am - am    b) am - pm",0,1);
		pc.addCols(" ",2,11);
	  pc.addCols("c) pm - pm    d) pm - am",0,1);

			pc.setFont(7, 4);
			pc.addCols("UNIDAD ADMINISTRATIVA : [ "+cdo1.getColValue("ue_codigo")+" ] "+cdo1.getColValue("nombre_unidad"),0,dHeader.size());


			pc.setFont(7, 1);
			pc.addCols(" "+cdo1.getColValue("quincena"),0,dHeader.size());
			pc.addCols(" "+cdo1.getColValue("titulo"),0,dHeader.size());

		pc.setFont(6, 1);
		pc.addCols("No.EMP.",0,1);
		pc.addCols("NOMBRE DEL EMPLEADO",1,1);
		pc.addCols("TURNOS ASIGNADOS",1,4);
		pc.addCols("TURNOS EXTRAS",1,3);
		pc.addCols("POSTERIOR",1,2);
		pc.addCols("OBSERVACIONES",1,1);


		pc.addCols(" ",0,3);
		pc.addCols("FECHA",1,1);
		pc.addCols("A",1,1);
		pc.addCols("HORARIO",1,1);
		pc.addCols("A",1,1);
		pc.addCols("HORARIO",1,2);
		pc.addCols("A",1,1);
		pc.addCols("HORARIO",1,1);
		pc.addCols(" ",0,1);


	pc.setTableHeader(8);//create de table header (2 rows) and add header to the table

		  int no = 0;
	    String  tipo = "";
			String  sub = "";
			String  emp = "";
			String  motivo = "";
			String  t_he = "";
			String  t_hs = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
   		if (!emp.equalsIgnoreCase(cdo.getColValue("nombre_emp")))
			{
			pc.setFont(7, 1);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols("   [ "+cdo.getColValue("num_empleado")+" ]  "+cdo.getColValue("nombre_emp"),0,dHeader.size());
			}
		pc.setFont(6, 0);
		pc.setVAlignment(0);

			pc.addCols(" ",0,2);
			pc.addCols(" "+cdo.getColValue("dia"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha_emp"),1,1);
			pc.addCols(" "+cdo.getColValue("ta_a"),0,1);
			pc.addCols(" "+cdo.getColValue("codigo_turno_asignado"),1,1);

			t_he = cdo.getColValue("t_he");
			t_hs = cdo.getColValue("t_hs");
			 if(t_he.equals("AM") && t_hs.equals("AM"))  pc.addCols(" a ",1,1);
      else if(t_he.equals("AM") && t_hs.equals("PM"))  pc.addCols(" b ",1,1);
			else if(t_he.equals("PM") && t_hs.equals("PM"))  pc.addCols(" c ",1,1);
			else if(t_he.equals("PM") && t_hs.equals("AM"))  pc.addCols(" d ",1,1);
			else pc.addCols(" - ",1,1);

			pc.addCols(" "+cdo.getColValue("te_hent"),2,1);
			pc.addCols("  /  "+cdo.getColValue("te_hsal"),0,1);
			pc.addCols(" "+cdo.getColValue("tp_a"),1,1);
			pc.addCols(" "+cdo.getColValue("codigo_turno_posterior"),1,1);
			pc.addCols(" "+cdo.getColValue("observaciones_extra"),0,1);


	  tipo=cdo.getColValue("nombre_unidad");
		sub=cdo.getColValue("quincena");
		emp=cdo.getColValue("nombre_emp");

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {

	 	pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());

	pc.addCols(" ",0,1);
	pc.addBorderCols("FIRMA JEFE INMEDIATO",1,2,0.0f,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);
	pc.addBorderCols("JEFE DE DEPARTAMENTO Vo. Bo.",1,3,0.0f,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);
	pc.addBorderCols("CONFECCIONADO POR",1,2,0.0f,0.5f,0.0f,0.0f,0.0f);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>