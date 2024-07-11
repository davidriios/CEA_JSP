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
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
REPORTE:  INFORME PATOLOGICO
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
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

CommonDataObject cdo1, cdoPacData, cdoTitle = new CommonDataObject();

String sql = "", sqlTitle= "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";

if (request.getParameter("code") != null && !request.getParameter("code").equals("") && !request.getParameter("code").equals("0")) appendFilter += " and a.codigo = "+request.getParameter("code");

	//INFORME PATOLOGICO
	//sql= " select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_operatorio codDiagPre, a.diag_post_operatorio diagPost, a.procedimiento codProc, a.cirujano, a.asistente,  a.anestesia, a.anestesiologo, a.profilaxis_antibiotica profilaxis,decode(a.tiempo_profilaxis,-1,'NO PROFILAXIS',15,'15 MINUTOS ANTES',30,'30 MINUTOS ANTES',60,'60 MINUTOS ANTES',0,'INMEDIATAMENTE DESPUES DE LA INCISION',a.tiempo_profilaxis) tiempoProfilaxis, a.limpieza, a.incision, a.especimen_patologia especimen, a.patologo, a.hallazgos,   a.observacion, a.complicacion,  b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as cirujanoName,   decode(a.asistente,null,a.nombre_asistente,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada))) as asistenteName,   decode(a.anestesiologo,null,a.nombre_anestesiologo,d.primer_nombre||decode(d.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada))) as  anestesiologonombre, decode(a.patologo,null,a.nombre_patologo,e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada))) as patologoName,i.descripcion descAnestesia ,nvl(a.suturas,'') suturas,nvl(a.drenaje,'')drenaje, to_char(a.hora_inicio,'hh12:mi am')hora_inicio,to_char(a.hora_fin,'hh12:mi am')hora_fin,nvl(a.instrumentador,'')instrumentador,nvl(a.circulador,'')circulador from tbl_sal_protocolo_operatorio a,  tbl_adm_medico b,tbl_adm_medico c,tbl_adm_medico d, tbl_adm_medico e,tbl_sal_tipo_anestesia i where  a.cirujano = b.codigo and a.asistente = c.codigo(+) and a.anestesiologo = d.codigo(+) and a.patologo = e.codigo(+) and a.anestesia = i.codigo  and a.pac_id = "+pacId+" and  admision = "+noAdmision+appendFilter+" order by 1 ";
	
		sql = "select a.codigo,decode(a.patologo, null, a.nombre_patologo, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada))) as nombre_patologo,a.patologo,a.observacion, to_char(a.fecha,'dd/mm/yyyy') fecha,a.nombre_cirujano from tbl_sal_informe_patologico a , tbl_adm_medico e where a.pac_id="+pacId+" and a.admision ="+noAdmision+appendFilter+" and a.patologo = e.codigo(+) ";

	al2 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
sqlTitle = "SELECT codigo, descripcion FROM tbl_sal_expediente_secciones WHERE codigo = "+seccion;
cdoTitle =  SQLMgr.getData(sqlTitle);

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = cdoTitle.getColValue("descripcion");
	String xtraSubtitle = "SALON DE OPERACIONES";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".40");
			dHeader.addElement(".25");
			dHeader.addElement(".10");
			dHeader.addElement(".15");


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();			
		pc.addInnerTableToCols(dHeader.size());


			pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
		//table body

		pc.setFont(fontSize, 1);
		String groupBy  = "";
		for (int a=0; a<al2.size(); a++)
		{

			CommonDataObject cdo0 = (CommonDataObject) al2.get(a);

 			if (!groupBy.trim().equalsIgnoreCase(cdo0.getColValue("codigo")))
		  	{ // groupBy
		    	if (a != 0)
				{
				  pc.flushTableBody(true);
				  pc.addNewPage();
				}
			}
			
			sql = "select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiag,a.observacion from tbl_sal_diag_patologico a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_informe = "+cdo0.getColValue("codigo")+"  order by a.codigo desc";
				al = SQLMgr.getDataList(sql);

sql = "select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiag ,a.observacion from tbl_sal_diag_patologico a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_informe = "+cdo0.getColValue("codigo")+"  order by a.codigo desc";
				al1 = SQLMgr.getDataList(sql);
				//query
				
sql="select  a.codigo,nvl(a.especimen ,'') especimen from tbl_sal_especimen_patologico a where a.cod_informe = "+cdo0.getColValue("codigo")+" order by a.codigo desc ";
	al5 = SQLMgr.getDataList(sql);


			pc.setFont(fontSize, 1);
			pc.addBorderCols("FECHA DEL PROCEDIMIENTO:    "+cdo0.getColValue("fecha"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			
			/*pc.setFont(fontSize, 0);
			pc.addBorderCols("OBSERVACION DE PATOLOGIA: ",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo0.getColValue("especimen"),0,4,0.0f,0.0f,0.0f,0.0f);
			*/
			
			//**********************************************************************************
			//DIAGNOSTICOS PREOPERATORIOS
				pc.setFont(fontSize, 1,Color.gray);
				pc.addBorderCols("DIAGNOSTICO PRE-OPERATORIO",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.setFont(fontSize, 1);
				pc.addBorderCols("CODIGO",1,1);
				pc.addBorderCols("NOMBRE",1,1);
				pc.addBorderCols("OBSERVACION",1,3);

				pc.setVAlignment(0);
				
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("diagnostico"),1,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("descDiag"),0,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("observacion"),0,3,0.0f,0.0f,0.0f,0.0f);
				}
				pc.addCols(" ",1,dHeader.size());

				//DIAGNOSTICOS POSTOPERATORIOS
				pc.setFont(fontSize, 1,Color.gray);
				pc.addBorderCols("DIAGNOSTICOS POST-OPERATORIO",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.setFont(fontSize, 1);
				pc.addBorderCols("CODIGO",1,1);
				pc.addBorderCols("NOMBRE",1,1);
				pc.addBorderCols("OBSERVACION",1,3);

				pc.setVAlignment(0);
				

				for (int i=0; i<al1.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al1.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("diagnostico"),1,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("descDiag"),0,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("observacion"),0,3,0.0f,0.0f,0.0f,0.0f);
				}
				pc.addCols(" ",1,dHeader.size());
	
			  //pc.setFont(fontSize, 0);
			  pc.setFont(fontSize, 1,Color.gray);
			  pc.addBorderCols("ESPECIMEN PARA PATOLOGIA: ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
			  
			  pc.setFont(fontSize, 1);
			  pc.addBorderCols("OBSERVACIÓN",0,dHeader.size());
			  pc.setVAlignment(0);
				//pc.addBorderCols(cdo0.getColValue("especimen"),0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				
				for (int i=0; i<al5.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al5.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(""+(i+1)+". "+cdo.getColValue("especimen"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

				}
				
				for (int i=1; i<5; i++)
				{
					pc.addBorderCols(""+(al5.size()+i)+". ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
		  	pc.addCols(" ",0,dHeader.size());
			
            pc.setFont(fontSize, 0);
		  	pc.addBorderCols("HISTORIA PATOLÓGICA: ",0,1,0.0f,0.0f,0.0f,0.0f);
		  	pc.addBorderCols(" "+cdo0.getColValue("observacion"),0,4,0.5f,0.0f,0.0f,0.0f);
            pc.addCols(" ",0,5);

			pc.setFont(fontSize, 0);
		  	pc.addBorderCols("CIRUJANO: ",0,1,0.0f,0.0f,0.0f,0.0f);
		  	pc.addBorderCols(" "+cdo0.getColValue("nombre_cirujano"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(" REG.:",0,3,0.5f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,5);

			pc.setFont(fontSize, 0);
			pc.addBorderCols("PATOLOGO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(" "+cdo0.getColValue("nombre_patologo"),0,2,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("ENTIDAD:",0,2,0.5f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,5);
			
	}
	
	pc.addBorderCols("FECHA DE ENTREGA: ",0,3,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);
	
/*
	pc.addCols("FIRMA: ",0,1);
	pc.addBorderCols(" ",0,3,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,2);

	pc.addCols("REGISTRO: ",0,1);
	pc.addBorderCols(" ",0,1,0.10f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,3);
	pc.addCols("",0,dHeader.size());*/
	
	pc.addCols(" ",0,dHeader.size());
	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>