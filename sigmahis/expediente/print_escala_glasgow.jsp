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
ArrayList al2= new ArrayList();

CommonDataObject cdo1, cdoTitle, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEscala = request.getParameter("fechaEscala");
String horaEscala = request.getParameter("horaEscala");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaEscala== null) fechaEscala = "";
if (horaEscala== null) horaEscala = "";
if (fg== null) fg = "A";
if (desc == null) desc = "";

sql = "select to_char(eg.fecha,'dd/mm/yyyy') as fecha, to_char(eg.hora,'hh12:mi:ss am') as hora, decode(eg.evaluacion_derecha,null,0,eg.evaluacion_derecha) as evaluacionDerecha, decode(eg.evaluacion_izquierda,null,0,eg.evaluacion_izquierda) as evaluacionIzquierda, nvl(eg.total,0) as total, eg.usuario_creacion||'/'||eg.usuario_modificacion usuario from tbl_sal_escala_coma eg where eg.pac_id = "+pacId+" and eg.secuencia = "+noAdmision+" and tipo = '"+fg+"'";

if (!fechaEscala.trim().equals("") && !horaEscala.trim().equals("")) {
  sql += " and to_date(to_char(eg.fecha(+),'dd/mm/yyyy'),'dd/mm/yyyy')  = to_date('"+fechaEscala+"','dd/mm/yyyy') and to_date(to_char(eg.hora(+),'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEscala+"','hh12:mi:ss am') ";
}

ArrayList al0 = SQLMgr.getDataList(sql);

/*
sql = "select to_char(eg.fecha,'dd/mm/yyyy') as fecha, to_char(eg.hora,'hh12:mi:ss am') as hora, decode(eg.evaluacion_derecha,null,0,eg.evaluacion_derecha) as evaluacionDerecha, decode(eg.evaluacion_izquierda,null,0,eg.evaluacion_izquierda) as evaluacionIzquierda, nvl(eg.total,0) as total, eg.usuario_creacion||'/'||eg.usuario_modificacion usuario from tbl_sal_escala_coma eg,vw_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and eg.pac_id(+) = aa.pac_id and eg.secuencia (+)= aa.secuencia  and to_date(to_char(eg.fecha(+),'dd/mm/yyyy'),'dd/mm/yyyy')  = to_date('"+fechaEscala+"','dd/mm/yyyy') and to_date(to_char(eg.hora(+),'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEscala+"','hh12:mi:ss am') ";
cdo1 = SQLMgr.getData(sql);
if (cdo1 == null) cdo1 = new CommonDataObject();
*/

//if (request.getMethod().equalsIgnoreCase("GET")) {

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
	float cHeight = 11.0f;
	Vector main = new Vector();
		main.addElement(".20");
		main.addElement(".40");
		main.addElement(".40");
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
    
  PdfCreator pc = null;
  boolean isUnifiedExp = false;
  pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
			
	if(pc == null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);
	isUnifiedExp = true;
	}
	
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
		
		Vector header = new Vector();
		header.addElement(".20");
		header.addElement(".40");
		header.addElement(".40");
		
		Vector pupila = new Vector();
		pupila.addElement("0.19");
		pupila.addElement("0.05");
		pupila.addElement("0.06");
		pupila.addElement("0.07");
		pupila.addElement("0.08");
		pupila.addElement("0.09");
		pupila.addElement("0.10");
		pupila.addElement("0.11");
		pupila.addElement("0.12");
		pupila.addElement("0.13");
		
	pc.setNoColumnFixWidth(main);
	pc.createTable();
  pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, main.size());
	pc.setTableHeader(1);

String groupBy = "";
int iconImgSize = 9;
	int imgSize = 10;
for (int x = 0; x < al0.size(); x++) {
  cdo1 = (CommonDataObject) al0.get(x);

	
	String escalaDer =cdo1.getColValue("evaluacionDerecha");

  	String escalaIzq = cdo1.getColValue("evaluacionIzquierda");
	String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
	String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	String iconImg = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";

	//pc.setNoColumn(1);
	
if (!groupBy.trim().equalsIgnoreCase(cdo1.getColValue("fecha") + " " + cdo1.getColValue("hora")  )){
	  
	  if (x != 0){
        pc.flushTableBody(true);
        pc.addNewPage();
     }
     
	  pc.setNoColumnFixWidth(header);
	  pc.createTable("header_"+x);
	
	  pc.setFont(9, 1);
		pc.setVAlignment(1);
		pc.addBorderCols("FECHA:    "+cdo1.getColValue("fecha")+"     HORA:   "+cdo1.getColValue("hora")+"             EVALUACION PUPILAR\nUsuario: "+cdo1.getColValue("usuario"),0,2);
		
		pc.setNoColumnFixWidth(pupila);
    pc.createTable("pupila_"+x,false,0,400);
    
    pc.addBorderCols(" ",1,1);
		for (int j=1; j<=9; j++) pc.addBorderCols(""+j,1,1);
    
    pc.addCols(" ",0,1); 
    for( int j=1; j<=9; j++){
		   pc.addImageCols(iconImg,iconImgSize,1);
		   iconImgSize += 2;
	  }
	  
	  pc.addBorderCols("Der.",1,1);
		for (int j=1; j<=9; j++) pc.addImageCols((escalaDer.trim().equals(""+j)) ? iconChecked : iconUnchecked ,imgSize,1);

		pc.addBorderCols("Izq.",1,1);
		for (int j=1; j<=9; j++) pc.addImageCols((escalaIzq.trim().equals(""+j)) ? iconChecked : iconUnchecked ,imgSize,1);
		pc.resetVAlignment();
	  
		pc.setVAlignment(0);
	  pc.useTable("header_"+x);
	  pc.addTableToCols("pupila_"+x,1,1,0,null,null,0.0f,0.0f,0.0f,0.0f); 
	  
	  pc.setVAlignment(0);
	  pc.useTable("main");
	  pc.addTableToCols("header_"+x,1,main.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

		pc.addBorderCols("FACTORES",1);
		pc.addBorderCols("ESCALA",1);
		pc.addBorderCols("OBSERVACION",1);
	
	}
	
	pc.setVAlignment(0);
	
	String descrip = "",observ="",detalle="";
	
	sql = "SELECT nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle, a.descripcion as descripcion , 0 as escala ,b.FECHA_ESCALA, b.HORA_ESCALA , b.OBSERVACION as observacion, nvl(b.VALOR,0) as valor, b.APLICAR  FROM TBL_SAL_TIPO_ESCALA a, (SELECT nvl(TIPO_ESCALA ,0)as tipo_escala, nvl(DETALLE,0)as detalle, FECHA_ESCALA, HORA_ESCALA, OBSERVACION, VALOR, APLICAR FROM TBL_SAL_RESULTADO_ESCALA  where pac_id = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+cdo1.getColValue("fecha")+"','dd/mm/yyyy') and  to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+cdo1.getColValue("hora")+"','hh12:mi:ss pm') order by 1,2) b where a.codigo=b.tipo_escala(+) and a.tipo = '"+fg+"'	union SELECT a.tipo_escala,a.codigo, 0, a.descripcion, a.escala,null, null, null ,0, '' FROM TBL_SAL_DETALLE_ESCALA a,(select nvl(TIPO_ESCALA,0) as tipo_escala  from TBL_SAL_RESULTADO_ESCALA a where pac_id = "+pacId+" and secuencia = "+noAdmision+" order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo='"+fg+"' ORDER BY 1,2";

  al = SQLMgr.getDataList(sql);
  
  for (int i=0; i<al.size(); i++)
	{
		String iconDisplay = "";
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		//pc.addCols(" ",0,dHeader.size());
		
		pc.setVAlignment(1);
		pc.setFont(9, 0);
		
		if(cdo.getColValue("cod_escala").equals("0"))
		{
		if(cdo.getColValue("cod_escala").equals("0")&& i != 0)
		{
		
				pc.setVAlignment(1);
				pc.addBorderCols(" "+descrip,0,1);
				pc.resetVAlignment();
				pc.addInnerTableToBorderCols(1);
				pc.setVAlignment(1);
				pc.addBorderCols(" "+observ,0,1);
				//pc.addBorderCols(" "+cdo.getColValue("observacion"),0,1);
				
				pc.resetVAlignment();
				pc.setVAlignment(2);
		}
		
		//pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,1);
		detalle = cdo.getColValue("detalle");
		descrip = cdo.getColValue("descripcion");
		observ = cdo.getColValue("observacion");
		
		pc.setVAlignment(0);
		
		pc.setNoInnerColumnFixWidth(detCol);
		pc.setInnerTableWidth(237);
		pc.createInnerTable();
			pc.setFont(9, 0);
		//pc.addCols("",0,1);
		}else
		{

				if(detalle.trim().equals(cdo.getColValue("cod_escala")))
				{
				//pc.addInnerTableBorderCols(" ",0,1);
				iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
				
				}
				else 
				{
				//pc.addInnerTableBorderCols(" ",0,1);
					iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
				}
				//iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
				pc.setVAlignment(0);
				pc.addInnerTableImageCols(iconDisplay,imgSize,1);
				pc.setVAlignment(0);	
				pc.addInnerTableBorderCols(cdo.getColValue("descripcion"),0,1);
				pc.addInnerTableBorderCols(cdo.getColValue("escala"),2,1);
			
			}
		if(al.size()-1==i)	
		{
			
		pc.setVAlignment(1);
		pc.addBorderCols(" "+descrip,0,1);
		pc.resetVAlignment();
		pc.addInnerTableToBorderCols(1);
		pc.setVAlignment(1);
		pc.addBorderCols(" "+observ,0,1);
		//pc.addBorderCols(" "+cdo.getColValue("observacion"),0,1);
		
		pc.resetVAlignment();
		pc.setVAlignment(2);
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	
	
	
	
	pc.addCols("Puntaje Total:   "+cdo1.getColValue("total"),0,main.size());
	
	groupBy = cdo1.getColValue("fecha") + " " + cdo1.getColValue("hora");
	}	// x
		
	pc.addTable();
	if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
	}
//}GET
%>