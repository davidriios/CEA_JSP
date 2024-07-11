<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alTot = new ArrayList();

String userName = UserDet.getUserName();
String sql = "";
String empId = request.getParameter("empId");
String mesIni = request.getParameter("mes_ini");
String anioIni = request.getParameter("anio_ini");
String mesFin = request.getParameter("mes_fin");
String anioFin = request.getParameter("anio_fin");
String printOption = request.getParameter("opt");
String titulo = "";

if ( anioIni == null || anioIni.equals("") || anioFin == null || anioFin.equals("") || mesIni == null || mesIni.equals("") || mesFin == null || mesFin.equals("") ) throw new Exception ("El añio o el mes es inválido");

if ( printOption == null || printOption.equals("") ) printOption = "eXc";

Hashtable iMes = new Hashtable();
iMes.put("01","Enero");
iMes.put("02","Febrero");
iMes.put("03","Marzo");
iMes.put("04","Abril");
iMes.put("05","Mayo");
iMes.put("06","Junio");
iMes.put("07","Julio");
iMes.put("08","Agosto");
iMes.put("09","Septiembre");
iMes.put("10","Octubre");
iMes.put("11","Noviembre");
iMes.put("12","Diciembre");

Hashtable iTot = new Hashtable();

if ( printOption.equals("eXc") ){

//REPORTE EGRESOS POR CARGO
sql = "SELECT TO_CHAR(TO_DATE(TO_CHAR(A.FECHA_EFECTIVA,'MM'),'mm'),'fMMon','NLS_DATE_LANGUAGE=SPANISH')||' '||TO_CHAR(A.FECHA_EFECTIVA,'YYYY') mesAnio, DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)|| RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0') EGR_CEDULA, E.PRIMER_NOMBRE||' '||E.PRIMER_APELLIDO EGR_NOMBRE, E.NUM_EMPLEADO EGR_NUM_EMPLEADO,S.DESCRIPCION  EGR_MOTIVO,CA.DENOMINACION  NOMBRE_CARGO,A.CARGO, TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM')) PERIODO FROM TBL_PLA_AP_ACCION_PER A, TBL_PLA_AP_SUB_TIPO  S, TBL_PLA_EMPLEADO E, TBL_SEC_UNIDAD_EJEC U, TBL_PLA_CARGO CA WHERE ( e.emp_id = a.emp_id AND E.COMPANIA = A.COMPANIA) AND (   CA.CODIGO  =  A.CARGO AND CA.COMPANIA  =  A.COMPANIA ) AND(S.TIPO_ACCION = A.TIPO_ACCION AND S.CODIGO = A.SUB_T_ACCION) AND E.COMPANIA = "+(String) session.getAttribute("_companyId")+" AND U.COMPANIA = E.COMPANIA AND E.COMPANIA_UNIORG = U.COMPANIA AND  E.UNIDAD_ORGANI = U.CODIGO AND A.TIPO_ACCION = 3 AND  A.ESTADO = 'P' AND TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM'))  >= "+anioIni+mesIni+" AND   TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM'))  <= "+anioFin+mesFin+" ORDER BY TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM')) ASC , CA.DENOMINACION";
}// egresos por cargo

if ( printOption.equals("tPl") ) {

sql = "SELECT TO_CHAR(TO_DATE(TO_CHAR(A.FECHA_EFECTIVA,'MM'),'mm'),'fMMon','NLS_DATE_LANGUAGE=SPANISH')||' '||TO_CHAR(A.FECHA_EFECTIVA,'YYYY') mesAnio, DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)||RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'||LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||LPAD(TO_CHAR(E.ASIENTO),5,'0')EGR_CEDULA, E.PRIMER_NOMBRE||' '||E.PRIMER_APELLIDO EGR_NOMBRE, E.NUM_EMPLEADO  EGR_NUM_EMPLEADO, S.DESCRIPCION EGR_MOTIVO, TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM')) PERIODO, SUM(NVL(pa.sal_neto,0)+NVL(pa.total_ded,0))  total_pagado FROM   TBL_PLA_AP_ACCION_PER A, TBL_PLA_AP_SUB_TIPO  S, TBL_PLA_EMPLEADO E, TBL_SEC_UNIDAD_EJEC U, TBL_PLA_pago_ajuste pa WHERE   (e.emp_id = a.emp_id AND E.COMPANIA = A.COMPANIA) AND (S.TIPO_ACCION = A.TIPO_ACCION AND S.CODIGO = A.SUB_T_ACCION) AND pa.COD_COMPANIA = a.compania AND pa.COD_PLANILLA = 8 AND pa.emp_id = a.emp_id AND pa.estado = 'AC' AND pa.VoBo_estado  = 'S' AND E.COMPANIA = "+(String) session.getAttribute("_companyId")+" AND U.COMPANIA = E.COMPANIA AND E.COMPANIA_UNIORG = U.COMPANIA AND E.UNIDAD_ORGANI = U.CODIGO AND A.TIPO_ACCION = 3 AND  A.ESTADO = 'P' AND TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM'))  >= "+anioIni+mesIni+" AND TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM'))  <= "+anioFin+mesFin+" GROUP BY TO_CHAR(TO_DATE(TO_CHAR(A.FECHA_EFECTIVA,'MM'),'mm'),'fMMon','NLS_DATE_LANGUAGE=SPANISH')||' '||TO_CHAR(A.FECHA_EFECTIVA,'YYYY'), DECODE(E.PROVINCIA,0,' ',00,' ',11,'B',12,'C',E.PROVINCIA)|| RPAD(DECODE(E.SIGLA,'00','  ','0','  ',E.SIGLA),2,' ')||'-'|| LPAD(TO_CHAR(E.TOMO),3,'0')||'-'||  LPAD(TO_CHAR(E.ASIENTO),5,'0'),E.PRIMER_NOMBRE||' '||E.PRIMER_APELLIDO, E.NUM_EMPLEADO, S.DESCRIPCION, TO_NUMBER(TO_CHAR(A.FECHA_EFECTIVA,'YYYYMM')) ORDER BY  1";

cdoTot = SQLMgr.getData("SELECT SUM(x.total_pagado) tot FROM( (" +sql+ ") x )");

}//total pago por liquidaciones segun motivo de terminacion de contrato

al = SQLMgr.getDataList(sql);

if ( printOption.equals("eXc") ){
	alTot = SQLMgr.getDataList("SELECT x.periodo,x.cargo||x.periodo cargoPeriodo, COUNT(x.cargo) tot FROM  ( (" +sql+") x ) GROUP BY x.periodo, x.cargo||x.periodo ORDER BY x.periodo ASC");
	
	for ( int t = 0; t<alTot.size(); t++ ){
	   cdoTot = (CommonDataObject)alTot.get(t);
	   iTot.put(cdoTot.getColValue("cargoPeriodo"),cdoTot.getColValue("tot"));
	}//for t
	
	titulo = "Cantidad Mensual de personal que ha dejado de laborar por Cargo";
}


if ( printOption.equals("tPl") ) titulo = "Total Mensual pagado en liquidaciones según motivo de terminación de contrato";


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "PLANILLA";
	String subtitle = titulo;
	String xtraSubtitle = "Desde "+iMes.get(mesIni)+" "+anioIni+" hasta "+iMes.get(mesFin)+" "+anioFin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	
	String groupByPeriodo = "";
	String cargoPeriodo = "";
	String motivoPerio = "";
	
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	pc.addCols(" ",0,dHeader.size(),20f);
	
	if ( al.size() == 0 ) {
	   pc.addCols(" ",0,dHeader.size());
	   pc.setFont(8,1);
	   pc.addCols("******* No hemos encontrado datos! *******",1,dHeader.size());
	}else{
	    pc.setFont(8,0);
		
	if ( printOption.equals("eXc") ){	
		
		for ( int i = 0; i<al.size(); i++ ){
		
		    cdo = (CommonDataObject)al.get(i);
		 
			if ( !groupByPeriodo.equals(cdo.getColValue("periodo")) ){
					pc.setVAlignment(1);
					pc.setFont(8,1);
					pc.addBorderCols("Código",0,1,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols("Nombre del Cargo",0,5,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(cdo.getColValue("mesAnio"),1,2,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols("Totales",1,2,0.1f,0.1f,0.0f,0.1f,20f);
			}//groupByPeriodo
		
		    if ( !cargoPeriodo.equals(cdo.getColValue("cargo")+cdo.getColValue("periodo")) ){
					pc.setFont(8,0);
					pc.addBorderCols(cdo.getColValue("cargo"),0,1,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(cdo.getColValue("nombre_cargo"),0,5,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(" "+iTot.get(cdo.getColValue("cargo")+cdo.getColValue("periodo")),1,2,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(" "+iTot.get(cdo.getColValue("cargo")+cdo.getColValue("periodo")),1,2,0.1f,0.1f,0.1f,0.1f,20f);
			}//cargoPeriodo
		
		    groupByPeriodo = cdo.getColValue("periodo");
		    cargoPeriodo = cdo.getColValue("cargo")+cdo.getColValue("periodo");
		}//for i
	
		pc.setFont(9,1);
		pc.addCols(" ",2,dHeader.size(),20f);	
	    pc.addBorderCols("Totales finales...        ",2,6);
		pc.addBorderCols(" "+al.size(),1,2);
		pc.addBorderCols(" "+al.size(),1,2);
		
	 } //egresos por cargos	
	 
	 if ( printOption.equals("tPl") ){
	 
	    for ( int i = 0; i<al.size(); i++ ){
		
		    cdo = (CommonDataObject)al.get(i);
	 
	       if ( !groupByPeriodo.equals(cdo.getColValue("periodo")) ){ 
		   			pc.setVAlignment(1);
					pc.setFont(8,1);
					pc.addBorderCols("Motivo",0,6,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(cdo.getColValue("mesAnio"),1,2,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols("Totales",1,2,0.1f,0.1f,0.0f,0.1f,20f);
		   }//groupByPeriodo
		   
	     			pc.setFont(8,0);
					pc.addBorderCols(cdo.getColValue("egr_motivo"),0,6,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(cdo.getColValue("total_pagado"),1,2,0.1f,0.1f,0.1f,0.1f,20f);
					pc.addBorderCols(cdo.getColValue("total_pagado"),1,2,0.1f,0.1f,0.1f,0.1f,20f);
	 
	    groupByPeriodo = cdo.getColValue("periodo");
	    }//for
		
		pc.setFont(9,1);
		pc.addCols(" ",2,dHeader.size(),20f);	
	    pc.addBorderCols("Totales finales...        ",2,6);
		pc.addBorderCols(" "+cdoTot.getColValue("tot"),1,2);
		pc.addBorderCols(" "+cdoTot.getColValue("tot"),1,2);
		
	 }//total pagado en liquidaciones
		
	}// al.size() >= 0
	
	  
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>