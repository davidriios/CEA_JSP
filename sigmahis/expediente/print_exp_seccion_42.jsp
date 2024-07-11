<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String code = request.getParameter("id_cirugia");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(code == null ) code = "";
if(desc == null) desc = "";

sql = "select a.codigo, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, nvl(to_char(a.hora_inicio,'hh12:mi:ss am'),' ') as horaInicio, nvl(to_char(a.hora_final,'hh12:mi:ss am'),' ') as horaFinal, a.tipo_cirugia as tipoCirugia, a.procedimiento, diagnostico, observaciones, emp_provincia as empProvincia, emp_sigla as empSigla, a.emp_tomo as empTomo, a.emp_asiento as empAsiento, a.emp_compania as empCompania, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif, nvl(to_char(a.hora_anes,'hh12:mi:ss am'),' ') as horaAnes, nvl(to_char(a.hora_anes_f,'hh12:mi:ss am'),' ') as horAnesF, a.emp_id as empId, a.procedimiento_desc as procedimientoDesc from tbl_sal_datos_cirugia a where a.pac_id="+pacId+" and a.secuencia="+noAdmision;

if(!code.equals("")) sql+=" and a.codigo="+code;

cdo = SQLMgr.getData(sql);
if ( cdo == null ) cdo = new CommonDataObject();

sql = "select b.dat_cirugia as datCirugia, a.codigo, 0 as codAnestesia, a.descripcion, -1 as codEscala,  b.minutos, nvl(b.escala_he,-1) as escalaHe, nvl(b.escala_min15,-1) as escalamin15, nvl(b.escala_min30,-1) as escalamin30, nvl(b.escala_min60,-1) as escalamin60, nvl(b.escala_min90,-1) as escalamin90, nvl(b.escala_min120,-1) as escalamin120, nvl(b.escala_hs,-1) as escalaHs from TBL_SAL_RECUPERACION_ANESTESIA a, (select dat_cirugia, recup_anestesia, detalle_recup, minutos, escala_he, escala_min15, escala_min30, escala_min60, escala_min90, escala_min120, escala_hs from TBL_SAL_RECUPERACION where pac_id="+pacId+" and secuencia="+noAdmision+"and dat_cirugia="+code+" order by 2) b where a.codigo=b.recup_anestesia(+) union select 0, a.recup_anestesia, a.codigo, a.descripcion, a.escala as escala, -1, -1, 00, 00, 00, 00, 00, 00 FROM TBL_SAL_DETALLE_RECUPERACION a order by 2, 3";

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 82 * 8.5f;//612
	float height = 62 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 5;
	float cHeight = 90.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;

		boolean isUnifiedExp=false;

	//------------------------------------------------------------------------------------
      pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
        dHeader.addElement("10");
		dHeader.addElement("5");
        dHeader.addElement("5");
		dHeader.addElement("5");
        dHeader.addElement("5");
		dHeader.addElement("5");
        dHeader.addElement("5");
		dHeader.addElement("5");
        dHeader.addElement("5");


		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//pc.setTableHeader(1);

		String cod = "";
		String codAnt = "";
		int lc = 0;
		int tHe=0, tM15=0, tM30=0, tM60=0, tM90=0, tM120=0, tHs=0, ld=0;
        
        pc.setFont(9,1);
		pc.addCols("Fecha Creación: "+cdo.getColValue("fechaCreacion"," "),0,6);
		pc.addCols("Creado por: "+cdo.getColValue("usuarioCreacion"," "),0,8);
        
		pc.addCols("Fecha Modificación.: "+cdo.getColValue("fechaModif"," "),0,6);
		pc.addCols("Modificado por: "+cdo.getColValue("usuarioModif"," "),0,8);
        pc.addCols(" ", 0, dHeader.size());

		pc.setFont(8,1);
		pc.addCols("Fecha:",0,1);
		pc.setFont(8,0);
		pc.addCols(""+(cdo.getColValue("fecharegistro")!=null?cdo.getColValue("fecharegistro"):""),0,1);

		pc.setFont(8,1);
		pc.addCols("H. Entrada:",0,1);
		pc.setFont(8,0);
		pc.addCols(""+(cdo.getColValue("horainicio")!=null?cdo.getColValue("horainicio"):""),0,1);

		pc.setFont(8,1);
		pc.addCols("H. Salida:",0,1);
		pc.setFont(8,0);
		pc.addCols(""+(cdo.getColValue("horafinal")!=null?cdo.getColValue("horafinal"):""),0,1);

		pc.addCols(" ",0,8);

		pc.setFont(8,1);
		pc.addCols("Operación: ",0,2);
		pc.setFont(8,0);
		pc.addCols(""+(cdo.getColValue("procedimientodesc")!=null?cdo.getColValue("procedimientodesc"):""),0,dHeader.size()-2);
		pc.setFont(8,1);
		pc.addCols("Observaciones: ",0,2);
		pc.setFont(8,0);
		pc.addCols(""+(cdo.getColValue("observaciones")!=null?cdo.getColValue("observaciones"):""),0,dHeader.size()-2);
		pc.addCols(" ",0,dHeader.size());

		pc.setFont(8,1,Color.white);
		pc.addCols("Escala de Recuperación Post - Anestesica",0,dHeader.size(),Color.gray);
		pc.addCols("",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size()-7,Color.gray);
		pc.addBorderCols("HE",1,1,Color.gray,Color.green);
		pc.addBorderCols("15",1,1,Color.gray,Color.white);
		pc.addBorderCols("30",1,1,Color.gray,Color.white);
		pc.addBorderCols("60",1,1,Color.gray,Color.white);
		pc.addBorderCols("90",1,1,Color.gray,Color.white);
		pc.addBorderCols("120",1,1,Color.gray,Color.white);
		pc.addBorderCols("HS",1,1,Color.gray,Color.white);

		pc.setFont(8,0);

		for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			cod = cdo.getColValue("codigo");

			if(cdo.getColValue("escalaHe").equals("-1"))
			cdo.addColValue("escalaHe","");
			else tHe += (Integer.parseInt(cdo.getColValue("escalaHe")));
			if(cdo.getColValue("escalaMin15").equals("-1")) cdo.addColValue("escalaMin15","");
			else tM15 += Integer.parseInt(cdo.getColValue("escalaMin15"));
			if(cdo.getColValue("escalaMin30").equals("-1")) cdo.addColValue("escalaMin30","");
			else tM30 += Integer.parseInt(cdo.getColValue("escalaMin30"));
			if(cdo.getColValue("escalaMin60").equals("-1")) cdo.addColValue("escalaMin60","");
			else tM60 += Integer.parseInt(cdo.getColValue("escalaMin60"));
			if(cdo.getColValue("escalaMin90").equals("-1")) cdo.addColValue("escalaMin90","");
			else tM90 += Integer.parseInt(cdo.getColValue("escalaMin90"));
			if(cdo.getColValue("escalaMin120").equals("-1")) cdo.addColValue("escalaMin120","");
			else tM120 += Integer.parseInt(cdo.getColValue("escalaMin120"));
			if(cdo.getColValue("escalaHs").equals("-1")) cdo.addColValue("escalaHs","");
			else tHs += Integer.parseInt(cdo.getColValue("escalaHs"));

			if(cdo.getColValue("codAnestesia").equals("0")){
				ld++;

				if ( i != 0 ){
				   pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);
				}

				pc.addCols(cdo.getColValue("descripcion"),0,dHeader.size()-7);

				pc.addCols(cdo.getColValue("escalahe"),2,1);
				pc.addCols(cdo.getColValue("escalaMin15"),2,1);
				pc.addCols(cdo.getColValue("escalaMin30"),2,1);
				pc.addCols(cdo.getColValue("escalaMin60"),2,1);
				pc.addCols(cdo.getColValue("escalaMin90"),2,1);
				pc.addCols(cdo.getColValue("escalaMin120"),2,1);
				pc.addCols(cdo.getColValue("escalahs"),2,1);

				pc.addCols("",0,dHeader.size());
				pc.setFont(8,1,Color.white);
				pc.addCols("",0,2,Color.lightGray);
				pc.addCols("Descripción",0,6,Color.lightGray);
				pc.addCols("Escala",0,6,Color.lightGray);

			}// if 	cdo.getColValue("codAnestesia").equals("0")
			else{
		       if(!cdo.getColValue("codEscala").equals("-1")){
			       lc++;

				   pc.setFont(8,0);
				   pc.addCols("",0,2);
				   pc.addCols(""+cdo.getColValue("descripcion"),0,6);
				   pc.addCols(""+cdo.getColValue("codEscala"),0,6);

			   }//if
			}//else

			if(i<al.size()-1){
		        cdo = (CommonDataObject) al.get(i+1);
		        codAnt = cdo.getColValue("codigo");
	        }

		}//for i

		pc.setFont(8,1,Color.white);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size()-7,Color.gray);
		pc.addBorderCols("HE",1,1,Color.gray,Color.white);
		pc.addBorderCols("15",1,1,Color.gray,Color.white);
		pc.addBorderCols("30",1,1,Color.gray,Color.white);
		pc.addBorderCols("60",1,1,Color.gray,Color.white);
		pc.addBorderCols("90",1,1,Color.gray,Color.white);
		pc.addBorderCols("120",1,1,Color.gray,Color.white);
		pc.addBorderCols("HS",1,1,Color.gray,Color.white);

		pc.setFont(8,1);
		pc.addCols("Total:",0,dHeader.size()-7);
		pc.addCols(""+tHe,2,1);
		pc.addCols(""+tM15,2,1);
		pc.addCols(""+tM30,2,1);
		pc.addCols(""+tM30,2,1);
		pc.addCols(""+tM90,2,1);
		pc.addCols(""+tM120,2,1);
		pc.addCols(""+tHs,2,1);





	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>