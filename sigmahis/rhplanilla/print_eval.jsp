<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.rhplanilla.EvalEmpleado"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />


<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
		UserDet=SecMgr.getUserDetails(session.getId());
		session.setAttribute("UserDet",UserDet);
		issi.admin.ISSILogger.setSession(session);

		CmnMgr.setConnection(ConMgr);
		SQLMgr.setConnection(ConMgr);
	    AdmMgr.setConnection(ConMgr);

		SQL2BeanBuilder sbb = new SQL2BeanBuilder();

	String empId = request.getParameter("empId");
	String evDesde = request.getParameter("evDesde");
	String evHasta = request.getParameter("evHasta");
	String sql = "";
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
	Admision adm = new Admision();
	Company com = new Company();
    ArrayList list   = new ArrayList();
	ArrayList eval   = new ArrayList();
	ArrayList al = new ArrayList();



//	if(request.getParameter("noAdmision")!=null	{	noAdmision=request.getParameter("noAdmision");}
//if (request.getParameter("pacId")!=null){	pacId= request.getParameter("pacId"); }

//------------------     Company      -------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from tbl_sec_compania where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

//------------------    Tab General   -------------------------
sql="select ev.codigo as codigo, ev.compania as compania, ev.provincia||'-'||ev.sigla||'-'||ev.tomo||'-'||ev.asiento as dCedula, em.primer_nombre||'  '||decode(em.sexo,'F', decode(em.apellido_casada,null,em.primer_apellido, decode(em.usar_apellido_casada,'S','DE '||em.apellido_casada, em.primer_apellido)), em.primer_apellido) as nombreEmpleado, em.num_empleado as numEmpleado, ca.denominacion as puestoQueOcupa, nvl(initcap(ued.descripcion),'Depto. Sin Definir') as lugarDeTrabajo, nvl(initcap(ueg.descripcion),'Gerencia Sin Definir') as direccionTrabajo, 'Del    '||to_char(ev.periodo_evdesde,'dd  FMMonth yyyy','NLS_DATE_LANGUAGE=SPANISH')||'    al    '||  to_char(ev.periodo_evhasta,'dd  FMMonth yyyy','NLS_DATE_LANGUAGE=SPANISH') as secuencia, to_char(em.fecha_ingreso,'dd-mm-yyyy') as fechaIni, nvl(to_char(em.fecha_puestoact,'dd-mm-yyyy'),' ') as fechaFin from tbl_pla_evaluacion ev, tbl_pla_empleado em, tbl_pla_cargo ca, tbl_sec_unidad_ejec ued, tbl_sec_unidad_ejec ueg where em.provincia = ev.provincia and em.sigla = ev.sigla and em.tomo = ev.tomo and em.asiento = ev.asiento and em.compania = ev.compania and em.cargo = ca.codigo and em.compania = ca.compania and  ued.compania = ev.compania and ued.codigo = ev.unidad_adm and ueg.compania(+) = ev.compania and ueg.codigo(+) = ev.unidad_direc and ev.compania="+(String) session.getAttribute("_companyId")+" and em.emp_id="+empId;
 //(and em.emp_id="+empId+" and ev.periodo_evdesde="+evDesde+" and ev.periodo_evhasta="+evHasta;)
System.out.println("SQL:\n"+sql);
adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Admision.class);


sql="select ev.codigo as codigo, ev.compania as compania, ev.provincia||'-'||ev.sigla||'-'||ev.tomo||'-'||ev.asiento as cedula, em.primer_nombre||'  '||decode(em.sexo,'F', decode(em.apellido_casada,null,em.primer_apellido, decode(em.usar_apellido_casada,'S','DE '||em.apellido_casada, em.primer_apellido)), em.primer_apellido) as nombre, 'Del    '||to_char(ev.periodo_evdesde,'dd  FMMonth yyyy','NLS_DATE_LANGUAGE=SPANISH')||'    al    '||  to_char(ev.periodo_evhasta,'dd  FMMonth yyyy','NLS_DATE_LANGUAGE=SPANISH') as periodo, to_char(ev.periodo_evdesde,'dd-mm-yyyy') as periodoEvdesde, to_char(ev.periodo_evhasta,'dd-mm-yyyy') as periodoEvhasta, ev.tipo_evaluacion as tipoEvaluacion, ev.puntaje_total as puntajeTotal, ev.unidad_adm as unidadAdm, ev.unidad_direc as unidadDirec, fe.factor as factor, fe.valor as valor, initcap(f.descripcion) as descripcionFactor, f.definicion as definicionFactor, initcap(ued.descripcion) as unidadNombre, initcap(ueg.descripcion) as direcNombre, tae.descripcion as accionRecomendada, ev.accion_comentario as accionComentario, ev.acepto_empleado as aceptoEmpleado, ev.comentario_Empleado as comentarioEmpleado, ev.observaciones_evaluador as observacionesEvaluador, em.fecha_ingreso as fechaIngreso, em.fecha_puestoact as fechaPuestoact, f.codigo as codigoFactor, te.descripcion as tipoEvaluacionDesc, em.num_empleado as numEmpleado, ca.denominacion as cargo from tbl_pla_evaluacion ev, tbl_pla_factores_ev fe, tbl_pla_factores f, tbl_pla_empleado em, tbl_pla_cargo ca, tbl_pla_tipo_evaluacion te, tbl_sec_unidad_ejec ued, tbl_sec_unidad_ejec ueg, tbl_pla_tipo_accion_evaluacion tae WHERE ev.compania = fe.compania and ev.provincia = fe.provincia and ev.sigla = fe.sigla and ev.tomo = fe.tomo and ev.asiento = fe.asiento and ev.codigo = fe.evaluacion and ued.compania = ev.compania and ued.codigo = ev.unidad_adm and ueg.compania(+) = ev.compania and ueg.codigo(+) = ev.unidad_direc and tae.codigo(+) = ev.accion_recomendada and te.codigo = ev.tipo_Evaluacion and fe.factor = f.codigo and em.provincia = ev.provincia and em.sigla = ev.sigla and em.tomo = ev.tomo and em.asiento = ev.asiento and em.compania = ev.compania and ca.compania = em.compania and ca.codigo = em.cargo and ev.compania="+(String) session.getAttribute("_companyId")+" and em.emp_id="+empId+" order by fe.factor";
//and ev.periodo_evdesde='"+evDesde+"' and ev.periodo_evhasta='"+evHasta+"' order by fe.factor"';
System.out.println("SQL:\n"+sql);
//al = sbb.getBeanList(ConMgr.getConnection(),sql,EvalEmpleado.class);
al=SQLMgr.getDataList(sql);



if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 60; //max lines of items
		int nItems = list.size(); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		if (extraItems == 0) nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
		String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String cubo = java.util.ResourceBundle.getBundle("path").getString("images")+"/"+"cuboS.JPG";
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
		//String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

		String folderName = "rhplanilla";
		String fileNamePrefix = "print_evaluacion";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
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
		String day=fecha.substring(0, 2);
		//System.out.println("Year is: "+year+" Month is: "+month+" Day is: "+day);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {

			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

			int headerFooterFont = 4;

			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;


			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);



//***************//GENERAL HEADER BEGIN HERE //******************//
			Vector setHeader0=new Vector();
			setHeader0.addElement(".2");
			setHeader0.addElement(".8");
			setHeader0.addElement(".2");
			pc.setNoColumnFixWidth(setHeader0);

			pc.createTable();
			pc.setFont(12, 1);
			pc.addImageCols(""+logoPath,30.0f,0);
			pc.setVAlignment(2);
			pc.addCols(com.getCompLegalName(),1, 1,15.0f);
			pc.addCols("",1,1,15.0f);
			pc.addTable();

			Vector setHeader9=new Vector();
			setHeader9.addElement(".100");
			pc.setNoColumnFixWidth(setHeader9);

			pc.createTable();
			pc.setFont(12, 1);
			pc.addCols("Formulario de Evaluación ", 2, 1);
			pc.addTable();

		    pc.createTable();
			pc.setFont(12, 1);
			pc.addCols("de Desempeño Laboral ", 2, 1);
			pc.addTable();

			pc.createTable();
			pc.addCols(" ", 0,4,5f);
			pc.addTable();

			Vector setHeader2=new Vector();
			setHeader2.addElement(".15");
			setHeader2.addElement(".55");
			setHeader2.addElement(".10");
			setHeader2.addElement(".20");
			pc.setNoColumnFixWidth(setHeader2);

			pc.createTable();
			pc.setFont(7, 1);
			pc.addCols("", 0,4);
			pc.addTable();

			pc.createTable();
			pc.setFont(7, 1);
			pc.addCols("", 0,4);
			pc.addTable();

			pc.createTable();
			pc.setFont(7, 0);
			pc.addCols("Por: "+userName, 0, 2);
			pc.addCols("Página: "+1+" de "+nPages, 2, 2);
			pc.addTable();
			Vector setHeader1 = new Vector();
			setHeader1.addElement(".1000");
			pc.setNoColumnFixWidth(setHeader1);

			pc.createTable();
			pc.addBorderCols("1",0,1,4.5f,0.0f,0.0f,0.0f,5.0f);
			pc.addTable();
//End Beneficios
//OPERACIONES
	    	Vector setHeader5=new Vector();
		 	setHeader5.addElement(".20");
			setHeader5.addElement(".60");
		  	setHeader5.addElement(".20");
	      	pc.setNoColumnFixWidth(setHeader5);

			pc.resetFont();
			setHeader5=new Vector();
			setHeader5.addElement(".20");
			setHeader5.addElement(".60");
			setHeader5.addElement(".20");
			pc.setNoColumnFixWidth(setHeader5);


			pc.createTable();
			pc.setFont(7,1);
			pc.addCols("",0,3);
			pc.addTable();

			pc.createTable();
			pc.setFont(7,1);
			pc.addCols("",0,3);
			pc.addTable();

			pc.createTable();
			pc.addCols(" ", 0,3);
			pc.addTable();

			pc.createTable();
			pc.addCols(" ", 0,4,5f);
			pc.addTable();


	   		pc.createTable();
			pc.setFont(9,1);
			pc.addBorderCols("I. DATOS GENERALES"+" "+" "+" "+" ", 0,9);
			pc.addTable();

	    	pc.resetFont();
	    	setHeader5=new Vector();
			setHeader5.addElement(".15");
			setHeader5.addElement(".30");
			setHeader5.addElement(".15");
			setHeader5.addElement(".30");
			setHeader5.addElement(".10");
        	pc.setNoColumnFixWidth(setHeader5);

			pc.createTable();
			pc.setFont(8,1);
			pc.setVAlignment(0);
			pc.addBorderCols("Nombre: "+"                     "+"Cargo: "+"                   "+"Depto.: ",0,1,40.0f);
			//pc.addCols(""+adm.getCategoriaDesc(),0,1);
			pc.addBorderCols(""+adm.getNombreEmpleado()+"                                    "+adm.getPuestoQueOcupa()+"                             "+adm.getLugarDeTrabajo(), 0,1);
			pc.addBorderCols("No.Emp: " +  "                     "+"Cédula: "+"                   "+"Gerencia: ",0,1,40.0f);
			pc.addBorderCols("     "+adm.getNumEmpleado()+ "                                       "+"                                   "+adm.getDCedula()+"                                                         "+adm.getDireccionTrabajo(), 0,1);


			///pc.addCols("Motivo de Evaluación",0,1,1.5f,0.0f,0.0f,0.0f,5.0f);

			pc.addCols(" Motivo de Evaluacion ",1,1,40.0f);

	//	pc.addBorderCols("Fecha de Ingreso a la Empresa: "+"           "+" "+" "+" "+" "+"            "+"                         "+"                                              "+"Fecha de Ingreso al Cargo Actual: "+ "                                             "+"                         ",0,1,30.0f);
	//	pc.addBorderCols("Periodo de Evaluación: "+" del 1 de enero 2008 al 31 de julio de 2008",0,1,30.0f);
	  //  pc.addCols(" ",0,0,30.0f);
//		pc.addCols("",0,1);
	    pc.addTable();

		Vector setHeader6=new Vector();
		 	setHeader6.addElement(".15");
			setHeader6.addElement(".30");
		  	setHeader6.addElement(".15");
			setHeader6.addElement(".30");
		  	setHeader6.addElement(".10");
	      	pc.setNoColumnFixWidth(setHeader6);

		pc.resetFont();
	    	setHeader6=new Vector();
			setHeader6.addElement(".30");
			setHeader6.addElement(".15");
			setHeader6.addElement(".30");
			setHeader6.addElement(".15");
			setHeader6.addElement(".10");
        	pc.setNoColumnFixWidth(setHeader6);

			pc.createTable();
			pc.setFont(8,1);
			pc.setVAlignment(0);
			pc.addCols("Fecha de Ingreso a la Empresa: "+"                     "+"Fecha de Ingreso al Cargo Actual: ",0,1,30.0f);
			//pc.addCols(""+adm.getCategoriaDesc(),0,1);
			pc.addCols(""+adm.getFechaIni()+"                                    "+"                       "+adm.getFechaFin(), 0,1);
			pc.addCols("   Periodo de Evaluación: "+"                                     "+"               "+adm.getSecuencia(),0,1,30.0f);
			pc.addCols("", 1,1);
			pc.addCols("", 0,1);
			pc.addTable();


		pc.resetFont();
	    setHeader5=new Vector();
		setHeader5.addElement(".45");
		setHeader5.addElement(".55");

        pc.setNoColumnFixWidth(setHeader5);

		pc.createTable();
		pc.addCols(" ", 0,4,5f);
		pc.addTable();

	    pc.createTable();
		pc.setFont(9,1);
		pc.addBorderCols("II. ESCALA DE EVALUACION: "+" "+"                                                  "+" Puntúe con la escala A, los criterios de evaluación y con la escala B obtenga la puntuación total del desempeño del Empleado", 0,1,40.0f);
		pc.addBorderCols("III. CRITERIOS DE EVALUACION: "+"                                                                         "+" Anote la puntuación que obtuvo en los criterios descritos", 0,1,10.0f);
		pc.addTable();



	    pc.resetFont();
	    setHeader5=new Vector();
		setHeader5.addElement(".15");
		setHeader5.addElement(".10");
		setHeader5.addElement(".20");
		setHeader5.addElement(".45");
		setHeader5.addElement(".10");
        pc.setNoColumnFixWidth(setHeader5);


		 pc.createTable();
		pc.setFont(9,1);
		pc.addBorderCols("ESCALA                     A ", 1,1,25.0f);
		pc.addBorderCols("ESCALA                     B ", 1,1,25.0f);
		pc.addBorderCols("RESULTADOS ", 0,1,25.0f);
		pc.addBorderCols("Criterios Evaluados ", 0,1,25.0f);
		pc.addBorderCols("Puntaje ", 1,1,25.0f);
		pc.addTable();





		pc.createTable();
		pc.setFont(8,1);
		pc.addBorderCols("5                    Sobrsaliente ", 1,1,40.0f);
		pc.addBorderCols("FINAL                90 - 100                    puntos ", 1,1,40.0f);
		pc.addBorderCols("Cumple con todas las  expectativas y frecuentemente  excede la mayoria de ellas ", 0,1,40.0f);

		   String eval1 = "";String eval2 = "";String eval3 = "";String eval4 = "";
           String fact1 = "";String fact2 = "";String fact3 = "";String fact4 = "";
           String total = "";
for (int i=0; i<4; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

if(cdo.getColValue("factor").equals("1"))
{
 eval1 = cdo.getColValue("valor");fact1 = cdo.getColValue("descripcionFactor");
}		else if(cdo.getColValue("factor").equals("2"))
{
eval2 = cdo.getColValue("valor");fact2 = cdo.getColValue("descripcionFactor");
}
		else if(cdo.getColValue("factor").equals("3"))
		{
		eval3 = cdo.getColValue("valor");fact3 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("4"))
		{
		eval4 = cdo.getColValue("valor"); fact4 = cdo.getColValue("descripcionFactor");
		}
		}
		pc.addBorderCols(fact1+"                                                                              "+fact2+"                                                                                                       "+fact3+"                                                                                                    "+fact4, 0,1,40.0f);
		 pc.addBorderCols(eval1+"                                                  "+eval2+"                                                 "+eval3+"                                        "+eval4, 1,1);
	pc.addTable();



		 pc.createTable();
		pc.setFont(8,1);
		pc.addBorderCols("4                                   Bueno       ", 1,1,40.0f);
		pc.addBorderCols("FINAL                80 - 89                     puntos ", 1,1,40.0f);

		for (int i=4; i<8; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("factor").equals("5"))
		{
		eval1 = cdo.getColValue("valor"); fact1 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("6"))
		{
		 eval2 = cdo.getColValue("valor");fact2 = cdo.getColValue("descripcionFactor");
		 }
		else if(cdo.getColValue("factor").equals("7"))
		{
		eval3 = cdo.getColValue("valor");fact3 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("8"))
		{
		eval4 = cdo.getColValue("valor");fact4 = cdo.getColValue("descripcionFactor");
		}}

		pc.addBorderCols("Cumple con todas las  expectativas y en ocaciones  excede algunas de ellas ", 0,1,40.0f);

		pc.addBorderCols(fact1+"                                                                              "+fact2+"                                                                                                       "+fact3+"                                                                                                    "+fact4, 0,1,40.0f);
		 pc.addBorderCols(eval1+"                                               "+eval2+"                                                 "+eval3+"                                        "+eval4, 1,1);

		pc.addTable();


		 pc.createTable();
		pc.setFont(8,1);
		pc.addBorderCols("3                    Promedio ", 1,1,40.0f);
		pc.addBorderCols("FINAL                70 - 79                     puntos ", 1,1,40.0f);
		pc.addBorderCols("Desempeño normal de acuerdo    a los estándares requeridos     para el puesto ", 0,1,40.0f);

	for (int i=8; i<12; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("factor").equals("9"))
		{
		 eval1 = cdo.getColValue("valor");fact1 = cdo.getColValue("descripcionFactor");
		 }
		else if(cdo.getColValue("factor").equals("10"))
		{
		eval2 = cdo.getColValue("valor");fact2 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("11"))
		{
		eval3 = cdo.getColValue("valor");fact3 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("12"))
		{
		eval4 = cdo.getColValue("valor");fact4 = cdo.getColValue("descripcionFactor");
		}}
        pc.addBorderCols(fact1+"                                                                              "+fact2+"                                                                                                       "+fact3+"                                                                                                    "+fact4, 0,1,40.0f);

		 pc.addBorderCols(eval1+"                                               "+eval2+"                                                 "+eval3+"                                        "+eval4, 1,1);

		pc.addTable();

	     pc.createTable();
		pc.setFont(8,1);
		pc.addBorderCols("2                    Deficiente ", 1,1,40.0f);
		pc.addBorderCols("FINAL                60 - 69                     puntos ", 1,1,40.0f);
		pc.addBorderCols("Desempeño deficiente de acuerdo    a los estándares requeridos  para el puesto ", 0,1,40.0f);

			for (int i=12; i<16; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("factor").equals("13"))
		{
		eval1 = cdo.getColValue("valor");fact1 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("14"))
		{
		eval2 = cdo.getColValue("valor");fact2 = cdo.getColValue("descripcionFactor");
		}
		else if(cdo.getColValue("factor").equals("15"))
		{
		 eval3 = cdo.getColValue("valor");fact3 = cdo.getColValue("descripcionFactor");
		 }
		else if(cdo.getColValue("factor").equals("16"))
		{
		eval4 = cdo.getColValue("valor");fact4 = cdo.getColValue("descripcionFactor");
		}}
	 pc.addBorderCols(fact1+"                                                                                   "+fact2+"                                                                                                       "+fact3+"                                                                                                    "+fact4, 0,1,40.0f);
		 pc.addBorderCols(eval1+"                                               "+eval2+"                                                 "+eval3+"                                        "+eval4, 1,1);
		pc.addTable();

		 pc.createTable();
		pc.setFont(8,1);
		pc.addBorderCols("1                    Inaceptable ", 1,1,50.0f);
		pc.addBorderCols("FINAL                0  - 59                    puntos ", 1,1,50.0f);
		pc.addBorderCols("Desempeño inadecuado e inferior  a los estándares requeridos  para el puesto ", 0,1,50.0f);
		pc.addBorderCols("Presentación Personal                                                                            Puntualidad y Asistencia                                                                                                                      Confidencialidad                                                                             Seguridad e Higiene                                                                                                             Puntuación Total  ", 0,1,40.0f);
		for (int i=16; i<20; i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("factor").equals("17")) eval1 = cdo.getColValue("valor");
		else if(cdo.getColValue("factor").equals("18")) eval2 = cdo.getColValue("valor");
		else if(cdo.getColValue("factor").equals("19")) eval3 = cdo.getColValue("valor");
		else if(cdo.getColValue("factor").equals("20")) eval4 = cdo.getColValue("valor");
		total= cdo.getColValue("puntajeTotal");
		}
		 pc.addBorderCols(eval1+"                                               "+eval2+"                                                 "+eval3+"                                        "+eval4+"                                  "+total, 1,1);
		pc.addTable();



		pc.resetFont();
	    setHeader5=new Vector();
		setHeader5.addElement(".50");
		setHeader5.addElement(".50");
        pc.setNoColumnFixWidth(setHeader5);
			pc.createTable();
	    pc.addCols(" ", 0,4,5f);
		pc.addTable();

	    pc.createTable();
		pc.setFont(9,1);
		pc.addBorderCols("IV. EVALUACION GLOBAL ", 0,1,15.0f);
		pc.addBorderCols("V. COMENTARIOS DEL EVALUADOR", 0,1,15.0f);

		pc.addTable();


		pc.createTable();
		pc.setFont(7,1);
		pc.setVAlignment(0);
		pc.addBorderCols("Resumen del Desempeño Global(Justifique su evaluación abajo) ",0,1,140.0f);
		pc.addBorderCols(" ",1,1,140.0f);
		pc.addCols("",0,1);
	    pc.addTable();

		pc.createTable();
	    pc.addCols(" ", 0,4,5f);
		pc.addTable();


	    pc.createTable();
		pc.setFont(9,1);
		pc.addBorderCols("VI. ACCIONES RECOMENDADAS"+" "+" "+" "+" ", 0,9);
		pc.addTable();

		pc.resetFont();
	    setHeader5=new Vector();
		setHeader5.addElement(".50");
		setHeader5.addElement(".50");
        pc.setNoColumnFixWidth(setHeader5);

		pc.createTable();
		pc.setFont(7,1);
		pc.setVAlignment(0);
		pc.addBorderCols("Acción Recomendada:",0,1,25.0f);
		pc.addBorderCols("Observación:",0,1,25.0f);
		pc.addCols("",0,1);
	    pc.addTable();

	    pc.createTable();
		pc.addCols(" ", 0,4,5f);
		pc.addTable();


	    pc.createTable();
		pc.setFont(9,1);
		pc.addBorderCols("VII. FIRMAS"+" "+" "+" "+" ", 0,9);
		pc.addTable();

		pc.resetFont();
	    setHeader5=new Vector();
		setHeader5.addElement(".30");
		setHeader5.addElement(".40");
		setHeader5.addElement(".30");
	    pc.setNoColumnFixWidth(setHeader5);

		pc.createTable();
		pc.setFont(7,1);
		pc.setVAlignment(0);
		pc.addBorderCols("Gerente, Jefe o Supervisor",1,1,35.0f);
		pc.addBorderCols("Colaborador(a)",1,1,35.0f);
		pc.addBorderCols("Gerencia de Recursos Humanos",1,1,35.0f);
		pc.addCols("",0,1);
		pc.addTable();

		pc.createTable();
		pc.setFont(7,1);
		pc.setVAlignment(0);
		pc.addBorderCols("Firma : Fecha",0,1,25.0f);
		pc.addBorderCols("Firma : Fecha",0,1,25.0f);
		pc.addBorderCols("Firma : Fecha",0,1,25.0f);
		pc.addCols("",0,1);
		pc.addTable();



		// ******** MAIN FOOTER END HERE *******//

				pc.close();

				response.sendRedirect(redirectFile);

			}//folder created
		}//get


//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>