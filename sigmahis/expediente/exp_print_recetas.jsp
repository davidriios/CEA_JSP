<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>  
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
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
ArrayList al2 = new ArrayList();
CommonDataObject cdo, cdo2 = new CommonDataObject();
String sql = "", sql2 = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String noOrden = request.getParameter("noOrden");
String tipoComida = request.getParameter("tipoComida");
String compania = (String) session.getAttribute("_companyId");
String ctime = request.getParameter("cTime");
String idRec = request.getParameter("idRec")==null?"":request.getParameter("idRec");
String toBeMailed = request.getParameter("toBeMailed")==null?"":request.getParameter("toBeMailed");

if(idRec.trim().equals("")) throw new Exception("El número de recetas es inválido. Por favor contacte un administrador!");

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
issi.admin.Compania _comp = (issi.admin.Compania) sbb.getSingleRowBean(ConMgr.getConnection(),"select * from tbl_sec_compania where codigo = nvl(get_sec_comp_param(-1,'COMP_HOSPITAL'), 1)", issi.admin.Compania.class);

sql = "select m.no_receta, (select comp_id_receta from tbl_sal_recetas where pac_id = m.pac_id and admision = m.admision and id_recetas = m.no_receta and rownum = 1) as comp_id_receta, (select status from tbl_sal_recetas where pac_id = m.pac_id and admision = m.admision and id_recetas = m.no_receta and rownum = 1) as status, (select to_char(fecha_creacion, 'dd/mm/yyyy') from tbl_sal_recetas where pac_id = m.pac_id and admision = m.admision and id_recetas = m.no_receta and rownum = 1) as fecha_elaboracion, m.medicamento,m.indicacion, m.dosis, m.duracion, m.cantidad, m.frecuencia, p.nombre_paciente as pac_nombre,p.edad||' año(s) '||p.edad_mes||' mes(es)'||' '||p.edad_dias||' día(s)' as edad, nvl(p.seguro_social,'N/A') as ss, p.id_paciente_f3, decode(e.sexo,'F','DRA. ','DR. ')||e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' DE '||e.apellido_de_casada)) as nombre_medico, e.codigo as registro_medico, '   - '||e.especialidad especialidad, (SELECT SUM(CANTIDAD) FROM TBL_SAL_MED_RECETAS_DESPACH WHERE PAC_ID = m.pac_id AND ADMISION = m.admision AND SECUENCIA_MED = m.secuencia AND NO_RECETA = m.no_receta) as tot_despachado from tbl_sal_salida_medicamento m, vw_adm_paciente p, tbl_adm_admision a  ,(select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e where p.pac_id = m.pac_id and nvl((select cod_medico_turno from tbl_sal_adm_salida_datos where pac_id = m.pac_id and secuencia = m.admision and rownum = 1), a.medico) = e.codigo and a.pac_id = m.pac_id and a.secuencia = m.admision and m.pac_id = "+pacId+" and m.admision = "+noAdmision+" and m.no_receta in("+idRec+") and nvl(m.invalido,'N') = 'N' order by m.no_receta";

al = SQLMgr.getDataList(sql);

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

CommonDataObject cdoAddr = new CommonDataObject();
if (_comp.getPais()!=null &&_comp.getProvincia()!=null){
  cdoAddr = SQLMgr.getData("select pr.nombre||', '||decode(upper(pa.nombre),'PANAMA','REPÚBLICA DE PANAMÁ','PANAMÁ','REPÚBLICA DE PANAMÁ',pa.nombre) as addr_xtra from tbl_sec_pais pa, tbl_sec_provincia pr where pr.pais = pa.codigo and pa.codigo = "+_comp.getPais()+" and pr.codigo ="+_comp.getProvincia());
}

if (cdoAddr==null){
   cdoAddr = new CommonDataObject();
   cdoAddr.addColValue("addr_xtra"," ");
}

int printCount = CmnMgr.getCount("SELECT count(*) FROM tbl_sal_recetas  WHERE pac_id = "+pacId+" and admision = "+noAdmision+" and status = 'P' and id_recetas in("+idRec+")");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	//String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String logoPath = "";
	String statusPath = "";
	if(printCount > 0) logoPath = companyImageDir+"/watermark_prescription.png";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 4.196850388888889f; //10.66cm 
	float height = 72 * 6.342519680555556f;//16.11cm
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 1.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 1f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECETARIO";
	String subTitle = "";
	String xtraSubtitle = "";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin * 2);
	footer.setFont(6,1);
	footer.setNoColumn(1);
	footer.createTable("footer");
	if(al.size()>0)
	  footer.addBorderCols("["+cdo.getColValue("registro_medico", " ")+"] "+cdo.getColValue("nombre_medico", " ") + "    "+cdo.getColValue("especialidad", " "),1,1,0.0f,0.3f,0.0f,0.0f);
	else footer.addBorderCols("Médico:",1,1,0.0f,0.3f,0.0f,0.0f);  
	
	//------------------------------------------------------------------------------------
 PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());	
	
	
	Vector main = new Vector();   		
	main.addElement("1");
	
	Vector header = new Vector();
	header.addElement("20");
	header.addElement("60");
	header.addElement("20");
	
	Vector det = new Vector();
	det.addElement("12");
	det.addElement("44");
	det.addElement("10");
	det.addElement("34");
	
	pc.setVAlignment(0);
	pc.setNoColumnFixWidth(header);
	pc.createTable("header");
	    pc.addCols("",1,1);
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),25.0f,1);
		pc.addCols("",1,1);
		
		pc.setFont(13,1);
		pc.addCols(_comp.getNombre(),1,header.size());
		pc.resetFont();
		pc.addCols("RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,header.size());
		
		pc.addCols(_comp.getDireccion(),1,header.size());
		pc.addCols(cdoAddr.getColValue("addr_xtra"),1,header.size());
		pc.addCols("Tels. "+_comp.getTelefono()+(_comp.getFax()!=null && !_comp.getFax().equals("")?" / Fax: "+_comp.getFax():"" ),1,header.size());
		pc.addCols("RECETAS",1,header.size());
		
	pc.setVAlignment(0);		
	pc.setNoColumnFixWidth(main);
	pc.createTable();	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, userName+" / "+fecha, main.size());
			
	String recetaGroup = "";
	int totXGroup = 0;
	
	pc.setNoColumnFixWidth(det);
	pc.createTable("det",false,0,0.0f,(width-leftRightMargin));
	
	int alM = al.size()==0?1:al.size();
	String compIdReceta = ""; 
		
	for (int r = 0; r<alM; r++){
		try{
			cdo = (CommonDataObject)al.get(r);
		}catch(Exception e){
		   System.out.println("ERROR: :::::::::::::::::::::::::::::::"+e);
		   cdo = new CommonDataObject();
		   cdo.addColValue("no_receta","1");
		}
		
		if (!cdo.getColValue("no_receta").equals(recetaGroup)){
		
				if (r!=0){
					pc.flushTableBody(true,false);
					pc.addNewPage();
					totXGroup = 0;
				}
				pc.setFont(12,1);
				pc.setVAlignment(0);
				pc.useTable("det");
				pc.addTableToCols("header",1,det.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
				
				compIdReceta += cdo.getColValue("comp_id_receta")+((r+1)==alM?"":",");
				System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>> r = "+(r+1)+" alM = "+alM);
				
				String status = cdo.getColValue("status", " ").equalsIgnoreCase("P") ? "              (Copia)" : "";
				
				pc.setFont(7,1,Color.red);
				pc.addCols("No.:",0,1);
				pc.addCols(cdo.getColValue("comp_id_receta", " "),0,1);
				
				pc.addCols("Fecha:",1,1);
				pc.addCols(cdo.getColValue("fecha_elaboracion"," "),0,1);
				
				pc.setFont(7,0);
				pc.addCols("Paciente:",0,1);
				pc.addBorderCols("[ "+pacId+"-"+noAdmision+" ] "+cdo.getColValue("pac_nombre", " "),0,3,0.1f,0.0f,0.0f,0.0f);
				
				pc.addCols("Edad:",0,1);
				pc.addBorderCols(cdo.getColValue("edad"),0,1,0.1f,0.0f,0.0f,0.0f);
				
				pc.addCols("Céd.:",1,1);
				pc.addBorderCols(cdo.getColValue("id_paciente_f3"),0,1,0.1f,0.0f,0.0f,0.0f);
				
				pc.setFont(20,1);
				pc.addCols("",0,det.size());
				pc.addCols("Rx",0,det.size(),30f);
				
				pc.setFont(7,0);

		}//grouping
		totXGroup++;
		
		if (al.size()>0)
		pc.addCols(totXGroup+") "+cdo.getColValue("medicamento"," ")+(!cdo.getColValue("cantidad"," ").trim().equals("")?"   ##"+cdo.getColValue("tot_despachado","0")+"/"+cdo.getColValue("cantidad"):"")+" ** "+cdo.getColValue("indicacion"," ")+" ** "+cdo.getColValue("dosis"," ")+" ** "+cdo.getColValue("frecuencia"," ")+" ** "+cdo.getColValue("duracion"," "),0,det.size());
		else pc.addCols(" ",0,det.size());
		
		recetaGroup = cdo.getColValue("no_receta");	
	}//for r
	
	
		pc.setVAlignment(0);
		pc.useTable("main");
		pc.addTableToCols("det",1,main.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
			    
	try{
	  	  if(compIdReceta.contains(",")) compIdReceta = compIdReceta.replaceAll(",$", "");
		  al.clear();
		  cdo = new CommonDataObject();
		  cdo.setTableName("tbl_sal_recetas");
		  cdo.addColValue("STATUS","P");
		  cdo.addColValue("USUARIO_MODIFICACION",userName);
		  cdo.addColValue("FECHA_MODIFICACION",fecha);
		  cdo.setAction("U");
		  cdo.setWhereClause(" pac_id = "+pacId+" and admision = "+noAdmision+" and comp_id_receta in ("+compIdReceta+") and id_recetas in("+idRec+")");
		  al.add(cdo);
		  
		  
		  System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SAVING FOR :::::::::::::::::::::::::::::::::::::::::::::::::::::: "+compIdReceta);
		  
		  SQLMgr.saveList(al,true);
		  
		  if (SQLMgr.getErrCode().equals("1")){  
			  pc.addTable();  
			  pc.close();
			  if (toBeMailed.trim().equals("Y"))out.print(directory+folderName+"/"+year+"/"+month+"/"+fileName);
			  else response.sendRedirect(redirectFile);
		  }else throw new Exception(SQLMgr.getErrMsg());
	  	  
	}catch(Exception e){
	   throw new Exception("No pudimos generar la receta. Por favor contacte a su administrador(a)! "+e);
	}
}//get
%>