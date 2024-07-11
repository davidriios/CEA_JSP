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
Reporte sal10050
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

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "", sqlTitle="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEscala = request.getParameter("fechaEscala");
String id = request.getParameter("id");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
//if (fechaEscala== null) fechaEscala = fecha.substring(0,10);
if (fechaEscala== null) fechaEscala = "";
if (fg== null) fg = "NO";
if (desc ==  null) desc = "";

 if (request.getParameter("id") != null && !request.getParameter("id").equals("")&& !request.getParameter("id").equals("0"))
	{
//appendFilter +="and to_date(to_char(en.fecha, 'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+request.getParameter("fechaEscala")+"','dd/mm/yyyy') ";
		appendFilter +="  and id = "+id;
	}

sql="select nvl(a.id,0) id,nvl(a.total,0)total,nvl(to_char(a.fecha,'dd/mm/yyyy'),' ') fecha,nvl(to_char(a.fecha_creacion,'hh12:mi:ss am'),' ') as hora,nvl(a.observacion,'') observacion,a.usuario_creacion||'/'||a.usuario_modificacion usuario,b.name nombre_usuario from tbl_sal_escala_norton a,tbl_sec_users b where a.pac_id = "+pacId+" and a.secuencia="+noAdmision+" and a.tipo='"+fg+"' and b.user_name=a.usuario_creacion "+appendFilter+" order by a.id asc ";
al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

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
	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".45");
		dHeader.addElement(".35");
        
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


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	Vector detCol = new Vector();
		detCol.addElement(".04");
		detCol.addElement(".37");
		detCol.addElement(".04");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(2);//create de table header (3 rows) and add header to the table

	pc.setVAlignment(0);
	String groupBy = "";
	String nombre = "";
	int imgSize = 7;
	for (int i=0; i<al.size(); i++)
	{
		String iconDisplay = "";
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		nombre = cdo.getColValue("nombre_usuario");
		
 		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("id")))
		{ // groupBy
			    if (i != 0)
			     {
				      pc.flushTableBody(true);
				      pc.addNewPage();
			     }

				//pc.setFont(9, 1,Color.white);
				pc.addCols("FECHA: "+cdo.getColValue("fecha"),0,1);
				pc.addCols("HORA: "+cdo.getColValue("hora"),0,1);
				
				pc.addCols("Usuario: "+cdo.getColValue("usuario"),0,2);
				
				pc.addCols("Puntaje Total:   "+cdo.getColValue("total"),0,2);
				pc.addCols("OBSERVACION:   "+cdo.getColValue("observacion"),0,dHeader.size());

				//pc.addCols("Puntaje Total:   "+cdo.getColValue("total"),0,dHeader.size());
				if(!fg.trim().equals("SG"))pc.addCols("Menos de 12 es paciente de alto riesgo  ",0,dHeader.size());
				else if(fg.trim().equals("SG"))pc.addCols("Mayor de 0-5 control del dolor adecuado ",0,dHeader.size());

				pc.addBorderCols("FACTORES",1);
				pc.addBorderCols("ESCALA",1);
				pc.addBorderCols("OBSERVACION",1);
				if(fg.trim().equals("SG"))
				pc.addBorderCols("SIGNOS CONDUCTUALES",0,dHeader.size(),Color.gray);
				
		  }

		//pc.addCols(" ",0,dHeader.size());
		pc.setVAlignment(1);
		pc.setFont(9, 0);
		//pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,1);

		//pc.addCols("",0,1);
		pc.setVAlignment(0);

		sql = "select * from (select 'A' type,b.codigo,0 codeDetalle,nvl(a.valor,-1)valor,0 valorDetalle, b.descripcion ,nvl(a.observacion,'') observacion from tbl_sal_det_escala_norton a,tbl_sal_concepto_norton b where a.id(+) = "+cdo.getColValue("id")+" and a.cod_concepto(+) = b.codigo and b.tipo ='"+fg+"' union select 'B' type,b.codigo,b.secuencia,0,nvl(b.valor,0)valorDetalle, b.descripcion,' ' observacion from tbl_sal_det_escala_norton a,tbl_sal_det_concepto_norton b where a.id(+) = "+cdo.getColValue("id")+" and a.cod_concepto(+) = b.codigo and b.tipo ='"+fg+"' order by 2,1 ) order by codigo,type,valor,valorDetalle desc "; 
		
		al2 = SQLMgr.getDataList(sql);

		/*pc.setNoInnerColumnFixWidth(detCol);
		pc.setInnerTableWidth(267);
		pc.createInnerTable();
			pc.setFont(9, 0);*/
			String observacion ="",valor="";
			int jj =0,total=0;
			for (int j=0; j<al2.size(); j++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al2.get(j);

				
				
				if(cdo2.getColValue("codeDetalle").equalsIgnoreCase("0"))
				{jj++;
					valor = cdo2.getColValue("valor");
					if(valor.trim().equals("-1"))valor="0";
					if(j!=0)
					{
						pc.resetVAlignment();
						pc.addInnerTableToBorderCols(1);
						pc.setVAlignment(1);
						
						pc.addBorderCols(""+observacion,0,1);

						pc.resetVAlignment();
						pc.setVAlignment(2);
					}
					pc.setVAlignment(1);
					//pc.setFont(9, 0,Color.white);
					if(fg.trim().equals("SG")&&jj==6)
					pc.addBorderCols("SIGNOS FISIOLÓGICOS",0,dHeader.size(),Color.gray);/* */
					
					pc.addBorderCols(""+cdo2.getColValue("descripcion"),0,1);
					pc.setVAlignment(0);
					
					pc.setNoInnerColumnFixWidth(detCol);
					pc.setInnerTableWidth(267);
					pc.createInnerTable();
					pc.setFont(9, 0);
					observacion = cdo2.getColValue("observacion");
					
				}
				else
				{
					if(cdo2.getColValue("valorDetalle").equalsIgnoreCase(valor) && !valor.equalsIgnoreCase("0"))
					{
						iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
					}
					else
					{
						iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
					}
					pc.setVAlignment(1);
					pc.addInnerTableImageCols(iconDisplay,imgSize,1);
					pc.setVAlignment(0);
					pc.addInnerTableBorderCols(""+cdo2.getColValue("descripcion"),0,1);
					pc.addInnerTableBorderCols(""+cdo2.getColValue("valorDetalle"),2,1);
					
				}
				total += Integer.parseInt(cdo2.getColValue("valor"));
			
				if(j==al2.size()-1)
				{
					pc.resetVAlignment();
					pc.addInnerTableToCols(1);
					pc.setVAlignment(1);
					
					pc.addBorderCols(" "+observacion,0,1);
					pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
					pc.setFont(8,1);
					
					pc.addCols("TOTAL: ",2,1);
					pc.addCols(" "+total,2,1);
					
				if (fg.trim().equals("NO")){	
					if (total >= 0 &&total<=12)pc.addCols("ALTO RIESGO ",0,1,Color.red);
					else if (total>=13&&total<=15) pc.addCols("PRECAUCION",0,1,Color.orange);
					else if (total>=16) pc.addCols("NORMAL",0,1,Color.green);
					
				 }
				 else if (fg.trim().equals("SG")){	
					if (total >= 0 &&total<=5)pc.addCols("NORMAL",0,1,Color.blue);
					else if (total>=6) pc.addCols("PRECAUCION",0,1,Color.orange);
					
				 }
				 else if (fg.trim().equals("BR")){	
					if (total <= 12 )pc.addCols("ELEVADO RIESGO",0,1,Color.red);
					else if (total>=13&&total<=14) pc.addCols("MODERADO RIESGO",0,1,Color.orange);
					else if (total>=15&&total<=16) pc.addCols("BAJO RIESGO",0,1,Color.green);
					else if (total>=16) pc.addCols("NORMAL",0,1,Color.blue);
				 }
	 			else pc.addCols(" ",0,1);
					
					pc.addBorderCols("Evaluado por:  "+nombre,0,2);
					pc.addBorderCols("Firma: ",0,2);
					pc.resetVAlignment();
					pc.setVAlignment(2);
					
				}
			}
			
		groupBy = cdo.getColValue("id");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	
	
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>