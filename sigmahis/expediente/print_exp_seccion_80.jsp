<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.Escalas"%>
<%@ page import="issi.expediente.DetalleEscala"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaMgr" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
Reporte   fg=WB
Reporte   fg=MO
Reporte   fg=CR
Reporte   fg=NI
Reporte   fg=AN
Reporte   fg=DO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Escalas escala = new Escalas();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();
ArrayList  arr1 = new ArrayList();
ArrayList  arr2= new ArrayList();
ArrayList  arr3 = new ArrayList();
ArrayList  arr4 = new ArrayList();
ArrayList  arr5= new ArrayList();
ArrayList  arr6 = new ArrayList();

Vector v1 =null;
Vector v2 = null;

CommonDataObject cdo, cdo2, cdoPacData = new CommonDataObject();

String sql = "", sqlTitle = "", sqlobserva = "", sqlescal= "", sqlDesc= "", sqlWB="";
String mode = request.getParameter("mode");
String appendFilter = request.getParameter("appendFilter");
String appendFilter0 = request.getParameter("appendFilter0");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaReporte = request.getParameter("fecha");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "WB";
if (desc == null) desc = "";

boolean checkDefault = false;
int rowCount = 0;
String fecha_eval = request.getParameter("fecha_eval");
String hora_eval = request.getParameter("hora_eval");
int escLastLineNo = 0;
String op = "";
String key = "",titulo="";
int eTotal=0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int lc=0 ,De=0 ;
		String codE = "", observ = "";
		String codAnt = "";//al = CmnMgr.reverseRecords(HashDet);
		String detalleCod = "";
		boolean codDetSig = false;
		String x="";
				
String showRiesgo = "SIN PRECAUCION";
try{showRiesgo=java.util.ResourceBundle.getBundle("issi").getString("showRiesgo");}catch(Exception e){}		
if (showRiesgo.equals("Y")) showRiesgo = "SIN RIESGO";

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora , total ,id from tbl_sal_escalas  where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo ='"+fg+"' and id="+id+" order by 1,2 desc";
al2= SQLMgr.getDataList(sql);

CommonDataObject cdoInt = new CommonDataObject();
boolean showInterv = true;

String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (expVersion.equals("2")) {
	cdoInt = SQLMgr.getData("select habilitar_intervencion from tbl_sal_concepto_norton where tipo = '"+fg+"' and rownum = 1");
	if (cdoInt == null) cdoInt = new CommonDataObject();
	showInterv = cdoInt.getColValue("habilitar_intervencion","N").equalsIgnoreCase("Y");
}

if(!fg.trim().equals("MO"))
{
	sql = "select codigo, descripcion from tbl_sal_dolor where estado ='A' and (tipo = '"+fg+"' or nvl(tipo, 'AN') = 'AN') order by codigo";
	al3= SQLMgr.getDataList(sql);

	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'ME' order by  tipo asc";
	al4= SQLMgr.getDataList(sql);
	sql = "select codigo, descripcion from tbl_sal_intervencion_dolor where estado ='A' and tipo= 'NF' order by  tipo asc";
	al5= SQLMgr.getDataList(sql);
}
if(!id.trim().equals("0"))
{
			sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, observacion,total,dolor,intervencion,localizacion, usuario from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id+" and tipo ='"+fg+"'";

		escala = (Escalas) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Escalas.class);
		}
if(!fg.trim().equals("MO"))
{
	v1 = CmnMgr.str2vector(escala.getDolor(),"|");
	v2 = CmnMgr.str2vector(escala.getIntervencion(),"|");
}

CommonDataObject cdoC = new CommonDataObject();
String compania = (String) session.getAttribute("_companyId");
int total = Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
String _color = "", colorClass = "", level = "";
Color low = Color.white;
Color medium = Color.white;
Color high = Color.white;
java.util.Hashtable iCol = new java.util.Hashtable();

if (fg.equals("DO")||fg.equals("AN")||fg.equals("CR")||fg.equals("NI")||fg.equals("WB")){
  
  if (fg.trim().equals("DO")) cdoC = SQLMgr.getData("select get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS_DO') as color from dual");
  else cdoC = SQLMgr.getData("select get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS') as color from dual");
  
  if (cdoC==null) cdoC = new CommonDataObject();
   _color = cdoC.getColValue("color","");  //0-3:green,4-6:yellow,7-10:red
   colorClass = "";
   level = "";
   
   try{
	String[] c1 = _color.split(","); //0-3:green
	for (int a=0;a<c1.length;a++){
	  String[] c2 = c1[a].split(":"); //0-3,green,bajo
	  String[] c3 = c2[0].split("-"); //0,3
	  int from = Integer.parseInt(c3[0]);
	  int to = Integer.parseInt(c3[1]);
	  if (total >= from && total <= to){
	    colorClass=c2[1].toLowerCase();
		level =c2[2].toLowerCase(); 
		break;
	  }
	}
	String[] c2 = _color.split(",");
  }catch(Exception e){System.out.println("::::::::::::::::::::::::::::: Error al buscar los colores de la cabecera de la intervención");e.printStackTrace();}
  
  iCol.put("green",Color.green);
  iCol.put("yellow",Color.yellow);
  iCol.put("red",Color.red);
  
  
  if (level.equalsIgnoreCase("bajo")) low = (Color)iCol.get(colorClass.trim());
  else if (level.equalsIgnoreCase("medio")) medium = (Color)iCol.get(colorClass.trim());
  else if (level.equalsIgnoreCase("alto")) high = (Color)iCol.get(colorClass.trim());
}

sql = "select a.tipo, a.secuencia, a.descripcion as desc1 , b.tipo, b.descripcion as desc2, c.tipo, c.observacion as obser, c.id from tbl_sal_det_concepto_norton a, tbl_sal_concepto_norton b, tbl_sal_detalle_esc c where a.codigo=b.codigo and b.codigo=c.cod_escala and a.tipo=B.TIPO and a.tipo=c.tipo and a.secuencia=C.CODIGO and c.id="+id ;

sqlWB="select nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM tbl_sal_concepto_norton a, ( select nvl(cod_escala ,0)as tipo_escala, nvl(detalle,0)as detalle, OBSERVACION, VALOR, APLICAR FROM tbl_sal_detalle_esc  where id ="+id+" and tipo = '"+fg+"' order by 1,2 ) b where a.codigo=b.tipo_escala(+)  and a.tipo='"+fg+"' and a.estado='A'  union select a.codigo,a.secuencia, 0, a.descripcion, a.valor,null,0, '' from tbl_sal_det_concepto_norton a,tbl_sal_concepto_norton c,  ( select nvl(cod_escala,0) as tipo_escala  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo = '"+fg+"' and a.estado='A' and c.codigo =a.codigo(+) and a.estado(+)=c.estado ORDER BY 1,2 ";

		al = SQLMgr.getDataList(sqlWB);

	String fecha = cDateTime;
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
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();

		dHeader.addElement(".20");
		dHeader.addElement(".40");
		dHeader.addElement(".40");

		Vector detCol = new Vector();
		detCol.addElement(".05");
		detCol.addElement(".24");
		detCol.addElement(".05");
		detCol.addElement(".06");
		
		Vector tblInterv = new Vector();
		tblInterv.addElement("33");
		tblInterv.addElement("34");
		tblInterv.addElement("33");
		
		Vector tblIntervDo = new Vector();
		tblIntervDo.addElement("50");
		tblIntervDo.addElement("50");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();


		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		String marcado = "";

		int totCr=0;
		pc.setVAlignment(0);
if (al2.size()<1){
      pc.setFont(8,1);
      pc.addCols("No hay datos registrado!",1,dHeader.size());

}else{

        pc.setFont(8, 1);
		pc.addCols("Fecha: "+escala.getFecha(), 0, 1);
		pc.addCols("Hora: "+escala.getHora(), 0, 1);
		pc.addCols(" Usuario: "+escala.getUsuario(),0,1);
		
		if (showInterv) {

	if(!fg.trim().equals("MO") &&!fg.trim().equals("DO") &&!fg.trim().equals("RAM")){

		pc.setFont(9,1,Color.white);
	    pc.addCols("Descripcion de los Codigos",0,dHeader.size(), Color.gray);
		pc.addCols(" ",1,dHeader.size(),8f);


		pc.setFont(9,1,Color.white);
		pc.addBorderCols("Descripcion Del Dolor",0,1,Color.gray);
		pc.addBorderCols("Intervencion Médica",0,1,Color.gray);
		pc.addBorderCols("Intervencion No-Farmacológica",0,1, Color.gray);


			for (int i=1; i<=al3.size(); i++){

			cdo = (CommonDataObject) al3.get(i-1);

			String val1 = cdo.getColValue("descripcion");

			pc.setFont(7,0);

			if((CmnMgr.vectorContains(v1,cdo.getColValue("codigo")))){
			marcado = ">>  ";
			}else{
			marcado = "     ";
			}
			arr1.add(marcado+val1);
			}//end for*/


			for (int i=1; i<=al4.size(); i++){

			cdo = (CommonDataObject) al4.get(i-1);

			String val2 = cdo.getColValue("descripcion");

			pc.setFont(7,0);

			if(CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))){
			 marcado = ">>   ";
			 }else{
			   marcado = "     ";
			}
			arr2.add(i-1,marcado+val2);
			}//end for



		   for (int i=1; i<=al5.size(); i++){

		      cdo = (CommonDataObject) al5.get(i-1);

			  String val3 = cdo.getColValue("descripcion");

			  pc.setFont(7,0);

              if (CmnMgr.vectorContains(v2,cdo.getColValue("codigo"))){
		          marcado = ">>   ";
		      }else{
		          marcado = "     ";
		      }
			  arr3.add(i-1,marcado+val3);
		    }//end for*/


		pc.setFont(7,0);
		pc.addCols(arr1.toString().replace("[","").replace("]","").replace(",","\n\n"),0,1);
		pc.addCols(arr2.toString().replace("[","").replace("]","").replace(",","\n\n"),0,1);
		pc.addCols(arr3.toString().replace("[","").replace("]","").replace(",","\n\n"),0,1);

		pc.addCols("",1,dHeader.size(),8f);
		pc.setFont(9,1);
		pc.addCols("Localizacion del Dolor",1,1);
		pc.setFont(8,0);
		pc.addCols(escala.getLocalizacion(),0,2);

	 	}// if not MO
		else{
			if (!fg.trim().equals("RAM")) {
				pc.addCols("Intervención",2,1);
				pc.setFont(8,0);
				pc.addCols(escala.getIntervencion(),0,2);
			}
		}
		}

		pc.addCols("",1,6,20f);
		pc.setFont(9,1,Color.white);
		pc.addCols("Evaluacion",1,dHeader.size(),Color.gray);
		pc.setFont(7,0);

		if (fg.trim().equals("WB")||fg.trim().equals("CR")||fg.trim().equals("AN")||fg.trim().equals("NI")||fg.trim().equals("MO")||fg.trim().equals("DO")){ // WONG BAKER //CRIES

		pc.addBorderCols("Descripcion",1,1);
		pc.addBorderCols("Escala",1,1);
		pc.addBorderCols("Observacion",1,1);
		}

		if (fg.trim().equals("WB")||fg.trim().equals("CR")||fg.trim().equals("AN")||fg.trim().equals("NI")||fg.trim().equals("MO")||fg.trim().equals("DO")||fg.trim().equals("RAM")){ // WONG BAKER
		String aplicar = "S";
		String img  ="";
		int imgSize = 10;
		observ="";
		String iconDisplay = "",descrip = "",detalle="";
		for (int i=0; i<al.size(); i++)
		{

		  cdo2 = (CommonDataObject) al.get(i);
		pc.setVAlignment(1);
		pc.setFont(8, 0);

		if(cdo2.getColValue("cod_escala").equals("0"))
		{
			if(cdo2.getColValue("cod_escala").equals("0")&& i != 0)
			{
					pc.setVAlignment(1);
					pc.addBorderCols(" "+descrip,0,1);
					pc.resetVAlignment();
					pc.addInnerTableToBorderCols(1);
					pc.setVAlignment(1);
					pc.addBorderCols(" "+observ,0,1);
					pc.resetVAlignment();
					pc.setVAlignment(2);
			}

		detalle = cdo2.getColValue("detalle");
		descrip = cdo2.getColValue("descripcion");
		observ = cdo2.getColValue("observacion");

		pc.setVAlignment(0);

		pc.setNoInnerColumnFixWidth(detCol);
		pc.setInnerTableWidth(237);
		pc.createInnerTable();
			pc.setFont(9, 0);
		}else
		{

			pc.setFont(8, 0);
				if(detalle.trim().equals(cdo2.getColValue("cod_escala")))iconDisplay = "[ X ]"; //ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
				else iconDisplay = "[    ]";//ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";

				pc.setVAlignment(0);
				//pc.addInnerTableImageCols(iconDisplay,imgSize,1);
				pc.addInnerTableCols(iconDisplay,imgSize,1);
				pc.setVAlignment(0);


				img = ResourceBundle.getBundle("path").getString("images")+"/dolor"+cdo2.getColValue("cod_escala")+".gif";
				pc.setVAlignment(0);
				if (fg.trim().equals("WB"))pc.addInnerTableBorderCols(cdo2.getColValue("descripcion"),0,1);
				else pc.addInnerTableBorderCols(cdo2.getColValue("descripcion"),0,2);
				pc.setVAlignment(0);
				if (fg.trim().equals("WB"))pc.addInnerTableImageCols(img,imgSize,1);

				pc.setVAlignment(0);
				pc.addInnerTableBorderCols(cdo2.getColValue("escala"),2,1);

			}
		if(al.size()-1==i)
		{
			pc.setFont(8, 0);
		pc.setVAlignment(1);
		pc.addBorderCols(" "+descrip,0,1);
		pc.resetVAlignment();
		pc.addInnerTableToCols(1);
		pc.setVAlignment(1);
		pc.addBorderCols(" "+observ,0,1);
		pc.addBorderCols(" ",0,3,0.0f,0.5f,0.0f,0.0f);

		pc.resetVAlignment();
		pc.setVAlignment(2);
		}
		totCr += Integer.parseInt(cdo2.getColValue("valor"));
		
		if (((i + 1) == al.size())) {
			if (fg.trim().equals("DO")){
				pc.setFont(8,1);
				pc.addCols("TOTAL:",2,1);
				pc.addCols(" "+totCr,2,1);
				pc.addCols(" ",0,1);
			}
		}
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
	 }
  }
	pc.setFont(8,1);
		pc.addCols("TOTAL: ",2,1);
		pc.addCols(" "+totCr,2,1);

	if (fg.trim().equals("MO")){
		if (totCr >= 0 &&totCr<=24)pc.addCols(showRiesgo+" ",0,1,Color.green);
		else if (totCr>=25&&totCr<=50) pc.addCols("PRECAUCION",0,1,Color.orange);
		else if (totCr>=50) pc.addCols("ALTO RIESGO",0,1,Color.red);

	 }
	 else pc.addCols(" ",0,1);

//// ----------------------------------

   pc.setFont(13,0);
   pc.setVAlignment(0);

	if (fg.trim().equals("AN")||fg.equals("CR")||fg.equals("NI")||fg.equals("WB")){
		//pc.addNewPage();

		pc.setNoColumnFixWidth(tblInterv);
		pc.createTable("tblInterv");
		  pc.addCols(" ",1,tblInterv.size());
		  pc.addBorderCols("ESCALA DE 0-3",1,1,low);
		  pc.addBorderCols("ESCALA DE 4-6",1,1, medium);
		  pc.addBorderCols("ESCALA DE 7-10",1,1, high);
		  
		  pc.setVAlignment(0);
		  pc.addBorderCols("1. Se ofrece asistencia en sus necesidades, apoyo y orientación.\n\n2 Se procura  comodidad y confort Posicionamiento\n\n3. Se evitara esfuerzos innecesarios.\n\n4. Se coloca almohadas sobre el área adolorida si fuese necesario.\n\n5. Se Orienta  sobre ejercicios de relajación.\n\n6. Masaje dorsal si fuese necesario.\n\n7. Se Administra medicamentos analgésicos indicados.\n\n8. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.\n\n9. Compresas frías/calientes",3,1);
		  
		  pc.addBorderCols("1. Ofrece los cuidados de la escala del 0 al 3.\n\n2. Aplicar medicamentos para el dolor PRN indicados.\n\n3. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.\n\n4. Procurar un ambiente tranquilo.",3,1);
		  
		  pc.addBorderCols("1. Aplicar medicamentos para el dolor PRN indicados.\n\n2. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.\n\n3. Llamar al médico Hospitalista y/o su médico tratante.",3,1);
		  
		  pc.useTable("main");
		  pc.addTableToCols("tblInterv",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

		  
		  
	  }else if (fg.trim().equals("DO")){
	  
	     pc.addNewPage();

		  pc.setNoColumnFixWidth(tblIntervDo);
		  pc.createTable("tblIntervDo");
		 		  
		  pc.addBorderCols("0-2 (Bajo Riesgo)",1,1,low);
		  pc.addBorderCols("Mayor De 2 (Alto Riesgo)",1,1, high);
		  
		  pc.setVAlignment(0);
		  pc.addBorderCols("1. Medidas preventivas generales:\n\u2022Realizar evaluación de caída a todos los pacientes ambulatorios y hospitalizados. Al detectar el Riesgo de caída Colocar señales que alerten al personal  (rotulo en la puerta de RIESGO BAJO).\n\u2022Orientación sobre prevención de caídas y entrega de información y folletos de orientación\n\u2022Colocar los objetos al alcance del paciente\n\u2022Utilizar barandales altos, Colocar la cama en la posición más baja\n\u2022Proporcionar al paciente dependiente medios de solicitud de ayuda (timbre) cuando el cuidador esté ausente\n\u2022Responder al timbre y luz de llamada inmediatamente.\n\u2022Mantener los dispositivos de ayuda en buen estado.\n\n2. Manejo del entorno:\n\u2022Bloquear las ruedas de las sillas, camas u otros dispositivos.\n\u2022Disponer sillas de altura adecuada, con respaldo y apoyabrazos.\n\u2022Utilizar la técnica adecuada para colocar y levantar al paciente de la silla de ruedas, cama, baño, etc. (camillas...)\n\u2022Educar a los miembros de la familia sobre los factores de riesgo que contribuyen a las caídas y cómo disminuirlos.\n\n3. Corregir los factores de riesgo si son corregibles:\n\u2022Riesgos ambientales generales. Iluminación inadecuada, suelos resbaladizos, superficies irregulares, barreras arquitectónicas. Espacios reducidos, mobiliario inadecuado.\n\u2022Riesgos del entorno: unidad asistencial. Altura de las camillas/camas y ausencia de dispositivos  de anclaje, altura y tamaño de las barandillas, espacios reducidos, dispositivos y mobiliario que se comportan como obstáculos, ausencia y   mal funcionamiento de dispositivos de apoyo.\n\u2022Riesgo del entorno: paciente. Calzado o ropa inadecuada, carencia inadecuada de ayudas técnicas para caminar  o desplazarse.\n\u2022Riesgo del entorno: evacuación / transferencia. Vía y medio de evacuación, inmovilización, formación de los profesionales, efectos del  transporte sobre la persona / proceso de salud / enfermedad.\n\u2022Factor de tipo social. Ausencia y capacitación de red de apoyo: Cuidador / Agente de autonomía asistida.\n\n4. Enseñanza del proceso/enfermedad",3,1);
		  
		  pc.addBorderCols("1. Iguales medidas preventivas generales\n\u2022Al detectar el Riesgo de caída Colocar señales que alerten al personal  (rotulo en la puerta de RIESGO ALTO).\n\n2. Intervenciones especificas según el riesgo:\n\u2022Factores propios del paciente. Revisar historias de caídas con el paciente y la familia,  déficit cognitivos o físicos Controlar la marcha, el equilibrio y el cansancio en la deambulación, Ayudar a la deambulación de la persona inestable, Ayuda al autocuidado, Entrenamiento del hábito urinario, Estimulación cognitiva, Orientación de la realidad, Actuación ante la demencia, Manejo de la conducta, Fomento de la comunicación verbal/auditiva.\n\u2022Factores ambientales Manejo ambiental: Seguridad: Rondas cada hora o cada 2 horas\n\u2022Factores propios de la enfermedad. Manejo del dolor, Terapia ejercicio deambulación, de control muscular, de  movilidad articular, de  equilibrio,  Enseñanza habilidad psicomotora, Actuación ante la sensibilidad periférica alterada, Manejo de la  energía. Establecer un programa de ejercicios físicos de rutina que incluya el andar, Determinar con el paciente / cuidador los objetivos de los cuidados, Explorar con el paciente / cuidador las mejores formas de conseguir los objetivos,  a desarrollar un plan para cumplir con los objetivos.\n\u2022Factores derivados del régimen terapéutico Enseñar al paciente / cuidador utilizar un bastón, un andador, muletas, Colaborar con otros miembros del equipo de cuidados sanitarios para minimizar los efectos secundaros, Manejo de la medicación.\n\u2022Factores derivados de la respuesta del paciente frente a la enfermedad. Instruir al paciente / cuidador para que pida ayuda al moverse, si lo precisa, Ayudar al paciente / cuidador a identificar las practicas sobre la salud que desee cambiar.\n\u2022Riesgos del entorno: evacuación/transferencia. Ayuda con los autocuidados: transferencia, Transporte, Derivación, Vigilancia: seguridad.\n\u2022Factores de tipo social  Fomento la implicación familiar, Apoyo al cuidador principal.\n\n3. Implementación de medidas especiales como restricción y medicamentos debe estar con una orden médica.",3,1);
		 
	  }
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
