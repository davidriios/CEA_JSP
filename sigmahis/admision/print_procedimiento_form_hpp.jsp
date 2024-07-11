<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
/** REGISTRO DE ADMISON HSP
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
CommonDataObject cdo =new CommonDataObject();
CommonDataObject cdo2 =new CommonDataObject();
ArrayList al = new ArrayList();

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

CommonDataObject cdoPac = new CommonDataObject();

cdoPac = SQLMgr.getPacData(pacId, noAdmision);

String userName = UserDet.getUserName();

String sql = "", appendFilter = "";

 sql = "select nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id)),' ')as fechaingreso, decode(p.telefono,null,'N/A',p.telefono) telefono,r.descripcion, p.residencia_direccion as direc, decode(p.estado_civil,'CS',decode(p.sexo,'F','CASADA','CASADO'),'DV',decode(p.sexo,'F','DIVORCIADA','DIVORCIADO'),'SP',decode(p.sexo,'F','SEPARADA','SEPARADO'),'ST',decode(p.sexo,'F','SOLTERA','SOLTERO'),'UN',decode(p.sexo,'M','UNIDO','UNIDA'),'VD',decode(p.sexo,'M','VIUDO','VIUDA')) estado_civil, decode (p.nombre_jefe_inmediato,null,'N/A',p.nombre_jefe_inmediato) jefe_inmediato,nvl(p.lugar_trabajo,'N/A') empleador, nvl(p.puesto_que_ocupa,'N/A') puesto, nvl(p.trabajo_direccion,'S/A') direccion_trabajo , nvl(p.lugar_trabajo_conyugue,'N/A') lugarTrabajoConyugue, pro.nombre||'/'||pa.nombre ciudadestado ,decode(p.persona_de_urgencia,null,'N/A',p.persona_de_urgencia) contactourgencia, decode(p.telefono_urgencia,null,'N/A',p.telefono_urgencia) telefonourgencia, decode(p.telefono_trabajo,null,'N/A',p.telefono_trabajo) telefotrabajo, decode(p.direccion_de_urgencia,null,'N/A',p.direccion_de_urgencia) direcur, decode(a.responsabilidad, 'P','PACIENTE','O','OTRA', 'PERSONA','E','EMPRESA') responsabilidad,  decode(p.lugar_nacimiento,null,'N/A',p.lugar_nacimiento) lugarnaci, decode(p.nombre_conyugue,null,'N/A',p.nombre_conyugue) nombreconyuge, decode(p.telefono_trabajo_conyugue,null,'N/A',p.telefono_trabajo_conyugue) telefotrabajoconyuge,  decode(p.preferencia,null,'N/A',p.preferencia) preferencia, decode(p.deseo,null,'N/A',p.deseo) deseo, decode(p.nombre_madre,null,'N/A',p.nombre_madre) nombremadre, decode(p.nombre_padre,null,'N/A',p.nombre_padre) nombrepadre, nvl((select nacionalidad from tbl_sec_pais where p.nacionalidad = codigo ),'N/A') nacionalidad,(select nvl((select case when total >= 25 then 'Y' else 'N' end from tbl_sal_escalas  where pac_id = a.pac_id and admision = a.secuencia and tipo = 'MO' and rownum = 1),a.condicion_paciente) from dual) condicionPaciente from tbl_adm_paciente p, tbl_adm_religion r, tbl_sec_pais pa, tbl_sec_provincia pro, tbl_adm_admision a where p.religion=r.codigo(+) and p.pac_id = "+pacId+" and pa.codigo(+) = p.residencia_pais and pro.codigo(+) = p.residencia_provincia and a.pac_id = p.pac_id and a.secuencia = "+noAdmision+"";
 
 //Beneficios
al = SQLMgr.getDataList("SELECT  (select x.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y, tbl_adm_empresa x where z.empresa=b.empresa and z.convenio=b.convenio and z.secuencia=b.plan and z.empresa=y.empresa and z.convenio=y.secuencia and y.empresa=x.codigo) as nombreEmpresa, B.PRIORIDAD, B.POLIZA, B.CERTIFICADO, decode(B.CONVENIO_SOL_EMP,'S','DOBLE','SIMPLE') cobertura  from tbl_adm_beneficios_x_admision b where b.pac_id = "+pacId+" and B.ADMISION = "+noAdmision+" and b.estado='A' order by 2 asc"); 
 
cdo = SQLMgr.getData(sql);

if (cdo == null) cdo = new CommonDataObject();

cdoPac.addColValue("condicionPaciente",cdo.getColValue("condicionPaciente"));

if (appendFilter == null) appendFilter = "";

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String mes = "";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 10.0f;
	float topMargin = 5.5f;
	float bottomMargin = 5.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE DE ADMISIÓN HOSPITALARIA (HSP / AMB)";
	String subtitle = "";
	String xtraSubtitle = "";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 5.0f;
	
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector container = new Vector();
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	container.addElement(".10");
	
	Vector inf = new Vector();
	inf.addElement(".30");
	inf.addElement(".20");
	inf.addElement(".15"); //fa
	inf.addElement(".15"); //ha
	inf.addElement(".20"); //uc

	Vector pac = new Vector();
	pac.addElement(".20"); //ocupacion
	pac.addElement(".25"); //empleador
	pac.addElement(".35"); //direccion
	pac.addElement(".20"); //tel
	
	Vector garantia_seguro = new Vector();
	garantia_seguro.addElement(".24"); //
	garantia_seguro.addElement(".24"); //
	garantia_seguro.addElement(".20"); //
	garantia_seguro.addElement(".10"); //
	garantia_seguro.addElement(".10"); //
	garantia_seguro.addElement(".12"); //
	
	Vector result = new Vector();
	result.addElement(".10"); //Resultados
	result.addElement(".02");
	result.addElement(".10"); //Recuperado
	result.addElement(".02");
	result.addElement(".10"); //Mejorado
	result.addElement(".02");
	result.addElement(".10"); //No mejorado
	result.addElement(".02");
	result.addElement(".10"); //no tratado
	result.addElement(".02");
	result.addElement(".15"); // solo diago
	result.addElement(".02");
	result.addElement(".11"); //defuncíón
	result.addElement(".02");
	
	result.addElement(".02"); //si
	result.addElement(".02");
	result.addElement(".02");// space
	result.addElement(".02"); //no
	result.addElement(".02");
	
	pc.setNoColumnFixWidth(container); 
	pc.createTable();
	
	pdfHeader(pc, _comp, cdoPac, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, container.size());
	pc.setVAlignment(3);
	pc.setFont(7,0); 
	
	pc.addBorderCols("",1,container.size(),0.5f,0.0f,0.0f,0.0f,1f);
	pc.addBorderCols("Nueva fecha de Ingreso x Corte de Cuenta: "+cdo.getColValue("fechaIngreso"),0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Dirección Residencial: "+cdo.getColValue("direc"),0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Ciudad y Estado: "+(cdo.getColValue("ciudadEstado") !=null&& (cdo.getColValue("ciudadEstado")).length()<=1?"N/A":cdo.getColValue("ciudadEstado")),0,2,0.5f,0.5f,0.5f,0.5f);
	
	
	pc.addBorderCols("Estado Civil: "+cdo.getColValue("estado_civil"),0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Tel. Paciente: "+cdo.getColValue("telefono"), 0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Ocupación Paciente: "+cdo.getColValue("puesto"), 0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Empleador: "+cdo.getColValue("empleador"), 0,2,0.5f,0.5f,0.5f,0.5f);
	
	pc.addBorderCols("Tel. Empleador: "+cdo.getColValue("telefoTrabajo"), 0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Dirección Empleador: "+cdo.getColValue("direccion_trabajo"),0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Contacto Emergencia: "+cdo.getColValue("contactoUrgencia"), 0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Tel. Contacto: "+cdo.getColValue("telefonoUrgencia"), 0,2,0.5f,0.5f,0.5f,0.5f);
	
	//BTLR
	
	pc.addBorderCols("Responsable Cta: "+cdo.getColValue("responsabilidad"),0,3,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Tel. Responsable Cta: "+(cdo.getColValue("responsabilidad") != null && cdo.getColValue("responsabilidad").equals("PACIENTE")?cdo.getColValue("telefono"):"N/A"), 0,3,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Lugar Nac Pac.: "+cdo.getColValue("lugarnaci"), 0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Nacionalidad: "+cdo.getColValue("nacionalidad"), 0,2,0.5f,0.5f,0.5f,0.5f);
	
	pc.addBorderCols("Nombre, Apellido Padre: "+cdo.getColValue("nombrePadre"), 0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Nombre, Apellido Madre: "+cdo.getColValue("nombreMadre"), 0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols(" ", 1,2,0.5f,0.5f,0.5f,0.5f);
	
	pc.addBorderCols("Nombre Cónyuge: "+cdo.getColValue("nombreConyuge"), 0,4,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Tel. Cónyuge: "+cdo.getColValue("telefoTrabajoConyuge"), 0,2,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("Lugar Trabajo Cónyuge: "+cdo.getColValue("lugarTrabajoConyugue"), 0,4,0.5f,0.5f,0.5f,0.5f);
	
	pc.addCols(" ",1,container.size());
	
	pc.setFont(6,1);
		pc.addCols("PREFERENCIAS Y/O NECESIDADES",1,container.size());
		
		pc.setFont(7,0);
	
	pc.addBorderCols(""+cdo.getColValue("preferencia"),0,container.size(),0.5f,0.5f,0.5f,0.5f,20f);

	pc.addCols("",1,container.size());
	
	pc.setFont(7, 1,Color.white);
	pc.addCols("Aseguradora",1,6,Color.gray);
	pc.addCols("Prioridad",1,1,Color.gray);
	pc.addCols("No. Póliza",1,1,Color.gray);
	pc.addCols("Certificado",1,1,Color.gray);
	pc.addCols("Cobertura",1,1,Color.gray);
	
	pc.setFont(7,0);
	if ( al.size() == 0 ){
		for ( int p = 0; p<2; p++ ){
		    pc.addBorderCols(" ",0,6,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
			pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f);
		}
		pc.addBorderCols("",1,container.size(),0.5f,0.0f,0.0f,0.0f,1f);
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
		pc.addBorderCols("",1,container.size(),0.5f,0.0f,0.0f,0.0f,1f);
    }
	pc.addCols(" ",1,container.size());
	pc.setFont(7,0);
	pc.addBorderCols("Información Adicional: ",0,container.size(),0.5f,0.5f,0.5f,0.5f,25f);
	
	pc.setNoColumnFixWidth(garantia_seguro); 
	pc.createTable("diag_princ");
	
	pc.addBorderCols("Diagnóstico preliminar (A ser completado dentro de las 24 horas de haber hecho la admisión)                    No. Código ",0,3,0.5f,0.5f,0.5f,0.5f,18f);
	pc.addBorderCols("F. Egreso\n",0,1,0.5f,0.5f,0.5f,0.5f,18f);
	pc.addBorderCols("H. Egreso\n",0,1,0.5f,0.5f,0.5f,0.5f,18f);
	pc.addBorderCols("Estado\n",0,1,0.5f,0.5f,0.5f,0.5f,18f);
	
	pc.addBorderCols("Diagnóstico Principal (La condición que se establece dentro de las 24 horas de haber hecho la admisión",0,5,0.5f,0.5f,0.5f,0.5f);
	pc.addBorderCols("No. Código",0,1,0.5f,0.5f,0.5f,0.5f);

	pc.addBorderCols(" ",1,5,0.5f,0f,0f,0f);pc.addBorderCols(" ",1,1,0.5f,0f,0.5f,0f);
	pc.addBorderCols(" ",1,5,0.5f,0f,0f,0f);pc.addBorderCols(" ",1,1,0.5f,0f,0.5f,0f);
	
	pc.addBorderCols("Diagnóstico Secundario:",0,garantia_seguro.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	
	pc.addBorderCols("Procedimiento Principal:",0,garantia_seguro.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	
	pc.addBorderCols("Procedimiento(s) Secundario(s):",0,garantia_seguro.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	
	pc.addBorderCols("Interconsultas:",0,garantia_seguro.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);
	pc.addBorderCols(" ",1,garantia_seguro.size(),0.5f,0f,0f,0f);

	pc.useTable("main");
	pc.addTableToCols("diag_princ",1,container.size(),0,null,null,0.5f,0.5f,0.5f,0.5f);
	
	pc.setVAlignment(0);
	
	/**************** RESULT *************************/
	
	pc.setNoColumnFixWidth(result); 
	pc.createTable("result",false,0,0.0f,550f);
	
	pc.addCols(" ",0,result.size());
	
	pc.addCols("Resultados ",2,1);
	pc.addBorderCols(" ",2,1);
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
	pc.addCols("Defunción ",2,1);
	pc.addBorderCols(" ",2,1);
	
	pc.addCols("Si",2,1);
	pc.addCols(" ",2,1);
	pc.addBorderCols(" ",2,1);
	pc.addCols("No",0,2);
	
	pc.addCols("",0,result.size(),5f);

	pc.addCols("Causa de Defunción (Si aplica)",0,3);
	pc.addBorderCols("",0,8,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",2,1);
	pc.addCols("Autopsia",2,1);
	
	pc.addBorderCols(" ",2,1);
	pc.addCols("Si",2,1);
	pc.addCols(" ",2,1);
	pc.addBorderCols(" ",2,1);
	pc.addCols("No",0,2);
	
	pc.addCols("",0,result.size(),5f);
	
	pc.addCols("Falleció",2,1);
	pc.addBorderCols(" ",2,1);
	pc.addCols("Antes 48 HORAS  ",2,1);
	pc.addBorderCols(" ",2,1);
	pc.addCols("Después 48 HORAS",2,1);
    pc.addBorderCols(" ",2,1);
	pc.addCols(" ",2,(result.size()-6));
	
	pc.addCols("",0,result.size());
	pc.addCols("\"Yo certifico que la identificación del diagnóstico principal, secundario y procedimientos son precisos y completos según las mejores prácticas médicas\"",0,result.size());
	
	pc.addCols(" ",0,result.size());
	pc.addCols(" ",0,result.size());
	
	pc.setVAlignment(2);
	
	pc.addCols("Fecha: ",0,1);
	pc.addBorderCols(" ",0,5,0.5f,0f,0f,0f,0f);
	pc.addCols(" ",0,1);
	pc.addCols("Firmado por: ",1,2);
	pc.addBorderCols(" ",0,10,0.5f,0f,0f,0f,0f);
	

	
	pc.useTable("main");
	pc.addTableToCols("result",1,container.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	/************************ END RESULT *************************/
	
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);} 
//}//GET
%>