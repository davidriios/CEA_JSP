<%@ page errorPage="../error.jsp"%>
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
REPORTE:  PROTOCOLO OPERATORIO
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

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "PO";
if (desc == null ) desc = "";
if (code == null ) code = "0";

if (!code.equals("0")) appendFilter += " and a.codigo = "+request.getParameter("code");

	//PROTOCOLO OPERATORIO
	sql= " select  a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.diag_pre_operatorio codDiagPre, a.diag_post_operatorio diagPost, a.procedimiento codProc, a.cirujano, a.asistente,  a.anestesia, a.anestesiologo, a.profilaxis_antibiotica profilaxis,decode(a.tiempo_profilaxis,-1,'NO PROFILAXIS',15,'15 MINUTOS ANTES',30,'30 MINUTOS ANTES',60,'60 MINUTOS ANTES',0,'INMEDIATAMENTE DESPUES DE LA INCISION',a.tiempo_profilaxis) tiempoProfilaxis, a.limpieza, a.incision, a.especimen_patologia especimen, a.patologo, a.hallazgos,   a.observacion, a.complicacion,  b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as cirujanoName,   decode(a.asistente,null,a.asistente,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada))) as asistenteName,   decode(a.anestesiologo,null,a.anestesiologo,d.primer_nombre||decode(d.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||d.primer_apellido||decode(d.segundo_apellido,null,'',' '||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_de_casada,null,'',' '||d.apellido_de_casada))) as  anestesiologonombre, decode(a.patologo,null,a.patologo,e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada))) as patologoName,i.descripcion descAnestesia ,nvl(a.suturas,'') suturas,nvl(a.drenaje,'')drenaje, to_char(a.hora_inicio,'hh12:mi am')hora_inicio,to_char(a.hora_fin,'hh12:mi am')hora_fin,nvl(a.instrumentador,'')instrumentador,nvl(a.circulador,'')circulador, a.sangrado, a.protocolo, a.transfusiones, a.medicamentos from tbl_sal_protocolo_operatorio a,  tbl_adm_medico b,tbl_adm_medico c,tbl_adm_medico d, tbl_adm_medico e,tbl_sal_tipo_anestesia i where  a.cirujano = b.codigo and a.asistente = c.codigo(+) and a.anestesiologo = d.codigo(+) and a.patologo = e.codigo(+) and a.anestesia = i.codigo  and a.pac_id = "+pacId+" and  admision = "+noAdmision+appendFilter+" order by 1 ";
	al2 = SQLMgr.getDataList(sql);
	
	System.out.println("::::::::::::::::::::::::::::::::::"+sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

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
	String subtitle = desc;
	String xtraSubtitle = "";
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
	
PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

	Vector dHeader = new Vector();
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");
			
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		if(al2.size()==0){
	       pc.addCols("No Hay registros",1, dHeader.size());
        }else{

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
			
	sql="select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_proc_protocolo a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.cod_protocolo = "+cdo0.getColValue("codigo")+" order by a.codigo desc ";
	al3 = SQLMgr.getDataList(sql);

	sql="select  a.codigo,nvl(a.especimen ,'') especimen from tbl_sal_especimen_protocolo a where a.cod_protocolo = "+cdo0.getColValue("codigo")+" order by a.codigo desc ";
	al5 = SQLMgr.getDataList(sql);
	sql = "select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiag from tbl_sal_diag_protocolo a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_protocolo = "+cdo0.getColValue("codigo")+"  order by a.codigo desc";
	al = SQLMgr.getDataList(sql);
				
	sql = "select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiag from tbl_sal_diag_protocolo a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_protocolo = "+cdo0.getColValue("codigo")+"  order by a.codigo desc";
	al1 = SQLMgr.getDataList(sql);
					
			pc.setFont(fontSize, 1);
			pc.addCols("FECHA DEL PROCEDIMIENTO: ",0,1);
			pc.addBorderCols(cdo0.getColValue("fecha"),0,4,0.0f,0.0f,0.0f,0.0f);
			pc.addCols(" ",1,dHeader.size());
			if(fg.trim().equals("IP"))
			{
				pc.setFont(fontSize, 0);
				pc.addBorderCols("OBSERVACION DE PATOLOGIA: ",0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo0.getColValue("especimen"),0,4,0.0f,0.0f,0.0f,0.0f);
			}

			//DIAGNOSTICOS PREOPERATORIOS
				pc.setFont(fontSize, 1,Color.gray);
				pc.addBorderCols("DIAGNOSTICO PRE-OPERATORIO",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.setFont(fontSize, 1);
				pc.addBorderCols("CODIGO",1,1);
				pc.addBorderCols("NOMBRE",1,4);

				pc.setVAlignment(0);
				

				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("diagnostico"),1,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("descDiag"),0,4,0.0f,0.0f,0.0f,0.0f);
				}
					pc.addCols(" ",1,dHeader.size());

			//DIAGNOSTICOS POSTOPERATORIOS
				pc.setFont(fontSize, 1,Color.gray);
				pc.addBorderCols("DIAGNOSTICOS POST-OPERATORIO",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.setFont(fontSize, 1);
				pc.addBorderCols("CODIGO",1,1);
				pc.addBorderCols("NOMBRE",1,4);

				pc.setVAlignment(0);
				
				for (int i=0; i<al1.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al1.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("diagnostico"),1,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("descDiag"),0,4,0.0f,0.0f,0.0f,0.0f);
				}
					pc.addCols(" ",1,dHeader.size());

				if(!fg.trim().equals("IP"))
				{
				//**********************************************************************************
				//PROCEDIMIENTOS REALIZADOS
				pc.setFont(fontSize, 1,Color.gray);
				pc.addBorderCols("PROCEDIMIENTO:",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);

				pc.setFont(fontSize, 1);
				pc.addBorderCols("CODIGO",1,1);
				pc.addBorderCols("NOMBRE DEL PROCEDIMIENTO",1,4);

				for (int i=0; i<al3.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al3.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("procedimiento"),1,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols(cdo.getColValue("descProc"),0,4,0.0f,0.0f,0.0f,0.0f);

				}

					pc.addCols(" ",1,dHeader.size());

			  pc.addBorderCols("HORA INICIO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("hora_inicio"),0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols("HORA FIN: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("hora_fin"),0,2,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);
			  
			  pc.addBorderCols("CIRUJANO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("cirujanoname"),0,4,0.0f,0.0f,0.0f,0.0f);
 			  pc.addCols(" ",0,5);

			  pc.addBorderCols("ASISTENTE: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("asistentename"),0,4,0.0f,0.0f,0.0f,0.0f);
     		  pc.addCols(" ",0,5);

			  pc.addBorderCols("ANESTESIA: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("descanestesia"),0,4,0.0f,0.0f,0.0f,0.0f);
     		  pc.addCols(" ",0,5);

			  pc.addBorderCols("ANESTESIOLOGO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("anestesiologonombre"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);
			  
			  pc.addBorderCols("CIRCULADOR: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("circulador"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);
			  
			  pc.addBorderCols("INSTRUMENTADOR: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("instrumentador"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);

			  pc.addBorderCols("PROFILAXIS ANTIBIOTICA: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("profilaxis"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);

			  pc.addBorderCols("TIEMPO DE LA PROFILAXIS (min): ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("tiempoprofilaxis"),0,4,0.0f,0.0f,0.0f,0.0f);
 		  	  pc.addCols(" ",0,5);

			  pc.setFont(fontSize, 0);
			  pc.addBorderCols("LIMPIEZA DEL AREA: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("limpieza"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);

			  pc.setFont(fontSize, 0);
			  pc.addBorderCols("INCISION: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("incision"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);
              
              pc.addBorderCols("PROTOCOLO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("protocolo"),0,4,0.0f,0.0f,0.0f,0.0f);
              pc.addCols(" ",0,5);
              
              pc.addBorderCols("HALLAZGOS TRANSOPERATORIOS: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("hallazgos"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	  pc.addCols(" ",0,5);
              
              pc.addBorderCols("DRENAJE: ",0,1,0.0f,0.0f,0.0f,0.0f);
			 pc.addBorderCols(cdo0.getColValue("drenaje"),0,4,0.0f,0.0f,0.0f,0.0f);
             pc.addCols(" ",0,5);
             
             pc.addBorderCols("SANGRADO: ",0,1,0.0f,0.0f,0.0f,0.0f);
                pc.addBorderCols(cdo0.getColValue("sangrado"),0,4,0.0f,0.0f,0.0f,0.0f);
                pc.addCols(" ",0,5);
                
                pc.addBorderCols("SUTURAS: ",0,1,0.0f,0.0f,0.0f,0.0f);
                pc.addBorderCols(cdo0.getColValue("suturas"),0,4,0.0f,0.0f,0.0f,0.0f);
                pc.addCols(" ",0,5);

                pc.addBorderCols("COMPLICACIONES: ",0,1,0.0f,0.0f,0.0f,0.0f);
                pc.addBorderCols(cdo0.getColValue("complicacion"),0,4,0.0f,0.0f,0.0f,0.0f);
                pc.addCols(" ",1,dHeader.size());

                pc.addBorderCols("TRANSFUSIONES O INFUSIONES: ",0,1,0.0f,0.0f,0.0f,0.0f);
                pc.addBorderCols(cdo0.getColValue("transfusiones"),0,4,0.0f,0.0f,0.0f,0.0f);
                pc.addCols(" ",1,dHeader.size());
                
                pc.addBorderCols("MEDICAMENTOS: ",0,1,0.0f,0.0f,0.0f,0.0f);
                pc.addBorderCols(cdo0.getColValue("medicamentos"),0,4,0.0f,0.0f,0.0f,0.0f);
                pc.addCols(" ",1,dHeader.size());

	}
			  pc.setFont(fontSize, 0);
			  pc.addBorderCols("ESPÉCIMEN(ES) PARA PATOLOGÍA: ",0,1,0.0f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(cdo0.getColValue("especimen"),0,4,0.0f,0.0f,0.0f,0.0f);
				
				for (int i=0; i<al5.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al5.get(i);

					pc.setFont(fontSize, 0);
					pc.addBorderCols(""+(i+1)+". "+cdo.getColValue("especimen"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
		  			pc.addCols(" ",0,5);
		if(!fg.trim().equals("IP"))
		{
			pc.addBorderCols("PATOLOGO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo0.getColValue("patologoname"),0,4,0.0f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,5);

			

			 
			 
			 /*pc.addBorderCols("SUTURAS: ",0,1,0.0f,0.0f,0.0f,0.0f);
			 pc.addBorderCols(cdo0.getColValue("suturas"),0,4,0.0f,0.0f,0.0f,0.0f);
             pc.addCols(" ",0,5);*/
			
			 
			
			 pc.addBorderCols("OBSERVACIÒN: ",0,1,0.0f,0.0f,0.0f,0.0f);
			 pc.addBorderCols(cdo0.getColValue("observacion"),0,4,0.0f,0.0f,0.0f,0.0f);

		  	 pc.addCols(" ",0,5);

			 /*pc.addBorderCols("COMPLICACIONES: ",0,1,0.0f,0.0f,0.0f,0.0f);
			 pc.addBorderCols(cdo0.getColValue("complicacion"),0,4,0.0f,0.0f,0.0f,0.0f);
      		 pc.addCols(" ",1,dHeader.size());
             */
		}
		if(fg.trim().equals("IP"))
		{
			for (int i=1; i<5; i++)
				{
					pc.addBorderCols(""+(al5.size()+i)+". ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
		  	pc.addCols(" ",0,dHeader.size());
			
			pc.setFont(fontSize, 0);
		  	pc.addBorderCols("CIRUJANO: ",0,1,0.0f,0.0f,0.0f,0.0f);
		  	pc.addBorderCols(" "+cdo0.getColValue("cirujanoname")+"         REG.:",0,4,0.0f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,5);

			pc.setFont(fontSize, 0);
			pc.addBorderCols("PATOLOGO: ",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(" "+cdo0.getColValue("patologoname"),0,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("ENTIDAD:",0,2,0.0f,0.0f,0.0f,0.0f);
		  	pc.addCols(" ",0,5);
			
			pc.addBorderCols("FECHA DE ENTREGA: ",0,3,0.10f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,2);
		}
		if(!fg.trim().equals("IP"))
	{
		pc.addCols("FIRMA: ",0,1);
		pc.addBorderCols(" ",0,3,0.10f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,2);
	
		pc.addCols("REGISTRO: ",0,1);
		pc.addBorderCols(" ",0,1,0.10f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,3);
		
		
	}
	if(al2.size()<a)
	pc.addNewPage();

	}
	
	
		pc.addCols("",0,dHeader.size());
		
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>