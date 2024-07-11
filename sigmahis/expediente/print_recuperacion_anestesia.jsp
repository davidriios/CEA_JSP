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
Reporte: RECUPERACION DE ANTESTESIA
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String codigo = request.getParameter("codigo");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
//if (fechaEscala== null) fechaEscala = fecha.substring(0,10);
if (codigo== null) codigo = "";
if (desc == null) desc = "";

if (request.getParameter("codigo") != null && !request.getParameter("codigo").equals("")) appendFilter += " and a.codigo = "+request.getParameter("codigo");

sql = "SELECT a.codigo AS codigo, TO_CHAR(a.fecha_registro, 'dd/mm/yyyy') AS fechaRegistro, NVL (TO_CHAR (a.hora_inicio, 'hh12:mi:ss am'), ' ') AS horaInicio, NVL (TO_CHAR (a.hora_final, 'hh12:mi:ss am'), ' ') AS horaFinal, a.tipo_cirugia AS tipoCirugia, a.procedimiento AS procedimiento, a.diagnostico AS diagnostico, a.observaciones AS observaciones, a.emp_provincia AS empProvincia, a.emp_sigla AS empSigla, a.emp_tomo AS empTomo, a.emp_asiento AS empAsiento, a.emp_compania AS empCompania, a.usuario_creacion AS usuarioCreacion, a.usuario_modif AS usuarioModif, TO_CHAR (a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') AS fechaCreacion, TO_CHAR (a.fecha_modif, 'dd/mm/yyyy hh12:mi:ss am') AS fechaModif, NVL (TO_CHAR (a.hora_anes, 'hh12:mi:ss am'), ' ') AS horaAnes, NVL (TO_CHAR (a.hora_anes_f, 'hh12:mi:ss am'), ' ') AS horAnesF, a.emp_id AS empId, DECODE (b.observacion, NULL, b.descripcion, b.observacion) AS descripcion  FROM tbl_sal_datos_cirugia a, tbl_cds_procedimiento b   WHERE  a.pac_id = "+pacId+" AND a.secuencia = "+noAdmision+appendFilter+"  AND a.procedimiento = b.codigo(+) order by a.codigo";
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
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
        
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


	Vector detCol = new Vector();
		detCol.addElement(".10");
		detCol.addElement(".10");
		detCol.addElement(".10");
		detCol.addElement(".10");
		detCol.addElement(".10");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");
		detCol.addElement(".05");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setVAlignment(0);
		String groupBy = "";
		int tHe	= 0, t15 = 0, t30 = 0, t60 = 0, t90 = 0, t120 = 0, tHs = 0;

		if(al.size()!=0){	
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);

 			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codigo")))
		  { // groupBy
		    if (i != 0)
				{
				  pc.flushTableBody(true);
				  pc.addNewPage();
				}

				pc.setFont(8, 1);
        pc.addCols("FECHA: ",0,1);
        pc.addCols(" "+cdo.getColValue("fechaRegistro"),0,6);
        pc.addCols("H.E.: "+cdo.getColValue("horaInicio"),0,4);
        pc.addCols("H.S.:   "+cdo.getColValue("horaFinal"),0,4);
				pc.addCols("OPERACION:   "+cdo.getColValue("procedimiento")+" - "+cdo.getColValue("descripcion"),0,15);
				pc.addCols("OBSERVACION:   "+cdo.getColValue("observaciones"),0,15);
				pc.addCols(" ",0,15);

				pc.addBorderCols("ESCALA DE RECUPERACION POST-ANESTESIA",1,8,0.0f,0.5f,0.5f,0.5f);
				pc.addBorderCols("HE",1,1);
				pc.addBorderCols("M I N U T O S",1,5);
				pc.addBorderCols("HS",1,1);

				pc.addBorderCols(" ",1,8,0.5f,0.0f,0.5f,0.5f);
				pc.addBorderCols(" ",1,1);
				pc.addBorderCols(" 15",1,1);
				pc.addBorderCols(" 30",1,1);
				pc.addBorderCols(" 60",1,1);
				pc.addBorderCols(" 90",1,1);
				pc.addBorderCols("120",1,1);
				pc.addBorderCols(" ",1,1);
			}

			groupBy = cdo.getColValue("codigo");

			pc.setVAlignment(1);
			pc.setFont(9, 0);
			//pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,8);

			//pc.addCols("",0,1);
			pc.setVAlignment(0);

			//sql = "select b.observacion,a.codigo,a.descripcion,a.secuencia,a.valor,nvl(b.valor,0) as escala, a.descripcion||'            '||nvl(b.valor,0) descEscala from tbl_sal_det_escala_norton b, tbl_sal_det_concepto_norton a where  a.codigo = b.COD_CONCEPTO(+) and a.secuencia = b.COD_SUBCONCEPTO(+) and a.codigo="+cdo.getColValue("codigo")+" and b.pac_id(+)="+pacId+" AND b.fecha(+)=to_date('"+fechaGroup+"','dd/mm/yyyy') ORDER BY /*b.fecha,*/ a.valor DESC ";
			sql = "select b.dat_cirugia as datCirugia, a.CODIGO as codigo, 0 as codAnestesia, a.descripcion as descripcion, -1 as codEscala,  b.minutos as minutos, nvl(b.escala_he,-1) as escalaHe, nvl(b.ESCALA_MIN15,-1) as escalaMin15, nvl(b.ESCALA_MIN30,-1) as escalaMin30, nvl(b.ESCALA_MIN60,-1) as escalaMin60, nvl(b.ESCALA_MIN90,-1) as escalaMin90, nvl(b.ESCALA_MIN120,-1) as escalaMin120, nvl(b.ESCALA_HS,-1) as escalaHs from TBL_SAL_RECUPERACION_ANESTESIA a, (SELECT dat_cirugia, RECUP_ANESTESIA, DETALLE_RECUP, MINUTOS, ESCALA_HE, ESCALA_MIN15, ESCALA_MIN30, ESCALA_MIN60, ESCALA_MIN90, ESCALA_MIN120, ESCALA_HS FROM TBL_SAL_RECUPERACION where pac_id="+pacId+" and secuencia= "+noAdmision+" and dat_cirugia= " +cdo.getColValue("codigo")+ " order by 2) b where a.codigo=b.RECUP_ANESTESIA(+) union select 0, a.RECUP_ANESTESIA, a.CODIGO, a.DESCRIPCION, a.ESCALA as escala, -1, -1, 00, 00, 00, 00, 00, 00 FROM TBL_SAL_DETALLE_RECUPERACION a order by 2, 3";
			al2 = SQLMgr.getDataList(sql);

			pc.setNoInnerColumnFixWidth(detCol);
			pc.setInnerTableWidth(267);
			pc.createInnerTable();

		
			for (int j=0; j<al2.size(); j++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al2.get(j);

				if (cdo2.getColValue("codAnestesia").equalsIgnoreCase("0"))
				{
			    pc.setFont(9, 1);
			    pc.addBorderCols(cdo2.getColValue("descripcion"),0,8);
			    //H.Entrada
			    if (cdo2.getColValue("escalaHe").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaHe"),1,1);
			    	tHe = tHe + Integer.parseInt(cdo2.getColValue("escalaHe"));
			    }
			    // 15 minutos
			    if (cdo2.getColValue("escalaMin15").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaMin15"),1,1);
			    	t15 = t15 + Integer.parseInt(cdo2.getColValue("escalaMin15"));
			    }
					// 30 minutos
			    if (cdo2.getColValue("escalaMin30").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaMin30"),1,1);
			    	t30 = t30 + Integer.parseInt(cdo2.getColValue("escalaMin30"));
			    }
					// 60 minutos
			    if (cdo2.getColValue("escalaMin60").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaMin60"),1,1);
			    	t60 = t60 + Integer.parseInt(cdo2.getColValue("escalaMin60"));
			    }
			    // 90 minutos
			    if (cdo2.getColValue("escalaMin90").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaMin90"),1,1);
			    	t90 = t90 + Integer.parseInt(cdo2.getColValue("escalaMin90"));
			    }
					// 120 minutos
			    if (cdo2.getColValue("escalaMin120").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaMin120"),1,1);
			    	t120 = t120 + Integer.parseInt(cdo2.getColValue("escalaMin120"));
			    }
					// H.Salida
			    if (cdo2.getColValue("escalaHs").equalsIgnoreCase("-1"))
			    {
			    	pc.addBorderCols(" ",1,1);
			    } else {
			    	pc.addBorderCols(cdo2.getColValue("escalaHs"),1,1);
			    	tHs = tHs + Integer.parseInt(cdo2.getColValue("escalaHs"));
			    }

				} else
				{
					pc.setFont(8, 0);
			    pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.0f);
			    pc.addBorderCols(cdo2.getColValue("descripcion"),0,6,0.5f,0.5f,0.0f,0.0f);
			    pc.addBorderCols("= "+cdo2.getColValue("codEscala"),1,1);
			    pc.addCols(" ",1,7);
				}

				pc.resetVAlignment();
				//pc.addInnerTableToCols(1);
				pc.setVAlignment(1);

				if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
  		}  // fin loop detalle

			pc.setFont(9, 1);
	    pc.addBorderCols(" TOTALES . . . ",2,8);
	    pc.addBorderCols(Integer.toString(tHe),1,1);
	    pc.addBorderCols(Integer.toString(t15),1,1);
	    pc.addBorderCols(Integer.toString(t30),1,1);
	    pc.addBorderCols(Integer.toString(t60),1,1);
	    pc.addBorderCols(Integer.toString(t90),1,1);
	    pc.addBorderCols(Integer.toString(t120),1,1);
	    pc.addBorderCols(Integer.toString(tHs),1,1);

			tHe	= 0;
			t15 = 0;
			t30 = 0;
			t60 = 0;
			t90 = 0;
			t120 = 0;
			tHs = 0;

  	} // fin loop enc. x. registro de rec.
}else pc.addBorderCols(" NO EXISTEN REGISTROS ",1,dHeader.size());
	if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>