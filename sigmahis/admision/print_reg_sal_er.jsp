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
<%@ include file="../common/pdf_header_consentimiento2.jsp"%>
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String pacId  = request.getParameter("pacId");

cdop = SQLMgr.getPacData(pacId, noAdmision);

 sql = "select decode(p.telefono,null,'N/A',p.telefono) telefono,r.descripcion, p.residencia_direccion as direc, decode(p.estado_civil,'CS',decode(p.sexo,'F','CASADA','CASADO'),'DV',decode(p.sexo,'F','DIVORCIADA','DIVORCIADO'),'SP',decode(p.sexo,'F','SEPARADA','SEPARADO'),'ST',decode(p.sexo,'F','SOLTERA','SOLTERO'),'UN',decode(p.sexo,'M','UNIDO','UNIDA'),'VD',decode(p.sexo,'M','VIUDO','VIUDA')) estado_civil, decode(p.lugar_nacimiento,null,'N/A',p.lugar_nacimiento) lugarnaci, decode(P.NOMBRE_JEFE_INMEDIATO,null,'N/A',P.NOMBRE_JEFE_INMEDIATO) empleador, pro.nombre||'/'||pa.nombre ciudadEstado ,decode(P.PERSONA_DE_URGENCIA,null,'N/A',P.PERSONA_DE_URGENCIA) contactoUrgencia, decode(p.telefono_urgencia,null,'N/A',p.telefono_urgencia) telefonoUrgencia, decode(p.direccion_de_urgencia,null,'N/A',p.direccion_de_urgencia) direcUr, decode(A.RESPONSABILIDAD, 'P','PACIENTE','O','OTRA', 'PERSONA','E','EMPRESA') responsabilidad, decode(P.PREFERENCIA,null,'N/A',P.PREFERENCIA) PREFERENCIA, decode(P.DESEO,null,'N/A',P.DESEO) DESEO,  nvl((select nacionalidad from tbl_sec_pais where p.nacionalidad = codigo ),'N/A') nacionalidad,(select nvl((select case when total >= 25 then 'Y' else 'N' end from tbl_sal_escalas  where pac_id = a.pac_id and admision = a.secuencia and tipo = 'MO' and rownum = 1),a.condicion_paciente) from dual) condicionPaciente from tbl_adm_paciente p, tbl_adm_religion r, tbl_sec_pais pa, tbl_sec_provincia pro, tbl_adm_admision a Where p.religion=r.codigo and p.pac_id ="+pacId+" and PA.CODIGO(+) = P.RESIDENCIA_PAIS and PRO.CODIGO(+) = P.RESIDENCIA_PROVINCIA and A.PAC_ID = P.PAC_ID and A.SECUENCIA = "+noAdmision;

cdo = SQLMgr.getData(sql);

if (cdo == null) cdo = new CommonDataObject();
cdop.addColValue("condicionPaciente",cdo.getColValue("condicionPaciente"));

//Beneficios
al = SQLMgr.getDataList("SELECT  (select x.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y, tbl_adm_empresa x where z.empresa=b.empresa and z.convenio=b.convenio and z.secuencia=b.plan and z.empresa=y.empresa and z.convenio=y.secuencia and y.empresa=x.codigo) as nombreEmpresa, B.PRIORIDAD, B.POLIZA, B.CERTIFICADO, decode(B.CONVENIO_SOL_EMP,'S','DOBLE','SIMPLE') cobertura  from tbl_adm_beneficios_x_admision b where b.pac_id = "+pacId+" and B.ADMISION = "+noAdmision+" and estado='A' order by 2 asc"); 

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
		
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
	boolean passRequired = false;
	boolean showUI = false;
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REGISTRO DE ADMISIÓN (ER)";
	String subtitle = "";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
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
																									Vector innertTable1 = new Vector();
    innertTable1.addElement(".25");
    innertTable1.addElement(".10");
    innertTable1.addElement(".65");
		
	Vector condicion = new Vector();
	condicion.addElement(".10");
	condicion.addElement(".02");
	condicion.addElement(".10");
	condicion.addElement(".02");
	condicion.addElement(".10");
	condicion.addElement(".02");
	condicion.addElement(".10");
	condicion.addElement(".02");
	condicion.addElement(".10");
	condicion.addElement(".02");
	condicion.addElement(".40"); //Temperatura
		
		// huge vector theBra!n :)
	Vector examenFis = new Vector();
	examenFis.addElement(".06");
	examenFis.addElement(".02");
	examenFis.addElement(".06");
	examenFis.addElement(".02");
	examenFis.addElement(".06");
	examenFis.addElement(".02");
	examenFis.addElement(".14");
	examenFis.addElement(".02");
	examenFis.addElement(".08");
	examenFis.addElement(".02");
	examenFis.addElement(".08");
	examenFis.addElement(".02");
	examenFis.addElement(".14");
	examenFis.addElement(".02");
	examenFis.addElement(".08");
	examenFis.addElement(".02");
	examenFis.addElement(".04");
	examenFis.addElement(".02");
	examenFis.addElement(".06");
	examenFis.addElement(".02");
	
	Vector tratamiento = new Vector();
	tratamiento.addElement(".10");
	tratamiento.addElement(".02");
	tratamiento.addElement(".10");
	tratamiento.addElement(".02");
	tratamiento.addElement(".10");
	tratamiento.addElement(".02");
	tratamiento.addElement(".10");
	tratamiento.addElement(".02");
	tratamiento.addElement(".10");
	tratamiento.addElement(".02");
	tratamiento.addElement(".40");
		
	Vector result = new Vector();
	result.addElement(".12"); //Recuperado
	result.addElement(".02");
	result.addElement(".10"); //Mejorado
	result.addElement(".02");
	result.addElement(".12"); //No mejorado
	result.addElement(".02");
	result.addElement(".12"); //no tratado
	result.addElement(".02");
	result.addElement(".20"); // solo diago
	result.addElement(".02");
	result.addElement(".20"); //defuncíón
	result.addElement(".04"); //si
	result.addElement(".02");
	result.addElement(".04"); //No
	result.addElement(".02");
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}
	
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

    pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
    pc.setTableHeader(1);
	pc.setFont(7, 0);
	          
	pc.addBorderCols("Empleador: "+cdo.getColValue("empleador"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f);	
	pc.addBorderCols("Direccion Empleador: N/A",0,2,0.0f,0.5f,0.5f,0.5f,24f);	
	pc.addBorderCols("Direc. Pac.: "+cdo.getColValue("direc"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f);
	pc.addBorderCols("Ciudad/Estado: "+(cdo.getColValue("ciudadEstado") != null && (cdo.getColValue("ciudadEstado")).length()<=1?"N/A":cdo.getColValue("ciudadEstado")),0,2,0.5f,0.5f,0.5f,0.5f,24f);
	pc.addBorderCols("Estado Civil:   "+cdo.getColValue("estado_civil"," "),0,2,0.5f,0.5f,0.5f,0.5f);
		
	pc.addBorderCols("Contacto ER: "+cdo.getColValue("contactoUrgencia"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Teléfono ER: "+cdo.getColValue("telefonoUrgencia"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Dir. ER: "+cdo.getColValue("direcUr"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Resp. Cta.: "+cdo.getColValue("responsabilidad"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Tel. Resp. Cta.: "+(cdo.getColValue("responsabilidad") != null && cdo.getColValue("responsabilidad").equals("PACIENTE")?cdo.getColValue("telefono"):"N/A"),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
		
	pc.addBorderCols("Dir. Resp. Cta.: ",0,4,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Tel. Pac.: "+cdo.getColValue("telefono"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Lug. de Nac.: "+cdo.getColValue("lugarnaci"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 
	pc.addBorderCols("Nacionalidad: "+cdo.getColValue("nacionalidad"," "),0,2,0.5f,0.5f,0.5f,0.5f,24f); 

	pc.addCols("",1,dHeader.size());
	pc.setFont(7, 1,Color.white);
	pc.addCols("Aseguradora",1,6,Color.gray);
	pc.addCols("Prioridad",1,1,Color.gray);
	pc.addCols("No. Póliza",1,1,Color.gray);
	pc.addCols("Certificado",1,1,Color.gray);
	pc.addCols("Cobertura",1,1,Color.gray);
		   
    pc.setFont(7, 0);
		   
	if ( al.size() == 0 ){
		for ( int p = 0; p<2; p++ ){
		    pc.addBorderCols(" ",0,6,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
		}
		pc.addBorderCols("",1,dHeader.size(),0.5f,0.0f,0.0f,0.0f,1f);
	}else{
		   
		for ( int a = 0; a<al.size(); a++ ){
	        cdo2 = (CommonDataObject)al.get(a);
			pc.addBorderCols(cdo2.getColValue("nombreEmpresa"),0,6,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(cdo2.getColValue("prioridad"),1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(cdo2.getColValue("poliza"),1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(cdo2.getColValue("certificado"),1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(cdo2.getColValue("cobertura"),1,1,0.5f,0.5f,0.5f,0.5f);
			if ( (a+1) >= 2 ) break;
	    }
		pc.addBorderCols("",1,dHeader.size(),0.5f,0.0f,0.0f,0.0f,1f);
    }
		pc.addCols("",1,dHeader.size());
		
		pc.setFont(6,1);
		pc.addCols("PREFERENCIAS Y/O NECESIDADES",1,dHeader.size(),15f);
		
		pc.setFont(7,0);
		
		pc.addBorderCols(cdo.getColValue("preferencia"," "),0,dHeader.size(),0.5f,0.5f,0.5f,0.5f,30f);
		
		pc.addCols("",1,dHeader.size());
		
		pc.setFont(7,1);
		pc.addCols("Condición al Momento de Arribo:",0,dHeader.size());
	
		pc.setNoColumnFixWidth(condicion); 
    	pc.createTable("condicion",false,0,0.0f,600f);
	    pc.setFont(7, 0);
     	pc.addCols("Buena",2,1);
		pc.addBorderCols("",2,1);  
		pc.addCols("Estable",2,1);
		pc.addBorderCols("",2,1);
		pc.addCols("Delicada",2,1);  
		pc.addBorderCols("",2,1);
		pc.addCols("Grave",2,1);  
		pc.addBorderCols("",2,1);
		pc.addCols("Coma",2,1);
		pc.addBorderCols("",2,1);

		pc.addCols("      Temperatura:           P:           R:           TA:           Peso:       ",0,1);
		
		pc.useTable("main");
	    pc.addTableToCols("condicion",0,dHeader.size(),12f,null,null,0.0f,0.0f,0.0f,0.0f);
		
		//B T L R
		pc.setVAlignment(1);
		pc.setFont(7,1);
		pc.addCols("",0,dHeader.size());
		pc.addBorderCols("Quejas Principales y Breve Historia:",0,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		
		pc.setFont(7,1);
		pc.addCols("",0,dHeader.size());
		pc.addBorderCols("Exámenes Físicos:",0,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		
		pc.addCols("",1,dHeader.size());
		
		pc.setNoColumnFixWidth(examenFis); 
    	pc.createTable("examenFis",false,0,0.0f,550f);
	    pc.setFont(7, 0);
		pc.addCols("Labs",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("BHC",2,1); 
        pc.addBorderCols(" ",0,1);		
		pc.addCols("U/A",2,1);
		pc.addBorderCols(" ",0,1);		
		pc.addCols("Quim. Sanguinea",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Otros",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("EKG",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Rayos x pecho",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Abdom.",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Ext",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Otros",2,1);
		pc.addBorderCols(" ",0,1);
		
		pc.useTable("main");
	    pc.addTableToCols("examenFis",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("",1,dHeader.size());
		pc.setVAlignment(1);
		pc.setFont(7,1);
		
		pc.addCols("",0,dHeader.size());
		pc.addBorderCols("Diagnóstico Preliminar:",0,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		
		pc.addCols("",1,dHeader.size());
		pc.setVAlignment(1);
		pc.setFont(7,1);
		
		pc.addBorderCols("Tratamientos:",0,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		
		pc.addCols("",1,dHeader.size());
		pc.setNoColumnFixWidth(tratamiento);
    	pc.createTable("tratamiento",false,0,0.0f,600f);
	    pc.setFont(7, 0);
     	pc.addCols("Disposición",2,1);
		pc.addBorderCols(" ",2,1);  
		pc.addCols("Admisión",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols("Alta",2,1);  
		pc.addBorderCols(" ",0,1);
		pc.addCols("APVP",2,1);  
		pc.addBorderCols(" ",0,1);
		pc.addCols("Transferencia",2,1);
		pc.addBorderCols(" ",0,1);
		pc.addCols(" Referido a: _______________________________________",0,1,15f);
		pc.useTable("main");
	    pc.addTableToCols("tratamiento",0,dHeader.size(),12f,null,null,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("",1,dHeader.size());
		pc.setFont(7,1);
		pc.addCols("Condiciones al Momento de Egreso o Transferencia:",0,dHeader.size());
		
		pc.setFont(7,0);
		pc.setNoColumnFixWidth(result); 
		pc.createTable("result",false,0,0.0f,550f);
		
		pc.addCols("Recuperado ",2,1);
		pc.addBorderCols(" ",2,1);
		pc.addCols("Mejorado ",2,1);
		pc.addBorderCols(" ",2,1);
		pc.addCols("No Mejorado ",2,1);
		pc.addBorderCols(" ",2,1);
		pc.addCols("No Tratado ",2,1);
		pc.addBorderCols(" ",2,1);
		pc.addCols("Solo Diagnóstico ",2,1);
		pc.addBorderCols(" ",2,1);
		pc.setFont(7,1);
		pc.addCols("Defunción:",2,1);
		pc.setFont(7,0);
		pc.addCols("SI",2,1);
		pc.addBorderCols(" ",2,1);
		pc.addCols("NO",2,1);
		pc.addBorderCols(" ",2,1);
	
		pc.useTable("main");
	    pc.addTableToCols("result",0,dHeader.size(),12f,null,null,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("",1,dHeader.size());
		pc.setVAlignment(1);
		pc.setFont(7,1);
		pc.addCols("",0,dHeader.size());
		
		pc.addBorderCols("Instrucciones a Paciente o Familiar:",0,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		pc.addBorderCols(" ",1,dHeader.size(),0.5f,0f,0f,0f);
		
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());
		pc.addBorderCols("Firma",1,3,0.0f,0.5f,0.0f,0.0f);
		pc.addCols(" ",1,1);
		pc.addBorderCols("Fecha",1,2,0.0f,0.5f,0.0f,0.0f);
		pc.addCols(" ",1,1);
		pc.addBorderCols("Firma del Médico",1,3,0.0f,0.5f,0.0f,0.0f);
		
	pc.addTable();  
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>

