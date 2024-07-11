<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String estadoConvenio = "";  //variable para el estado del A=activo I=inactivo

if (appendFilter == null) appendFilter = "";

sql = "select a.empresa, a.secuencia, a.nombre, a.contacto, to_char(a.fecha_inicial,'dd/mm/yyyy') as fechaInicial,"
+ " nvl(to_char(a.fecha_final,'dd/mm/yyyy'),'---') as fechaFinal, a.estatus, b.nombre as empresaNombre"
+ " from tbl_adm_convenio a, tbl_adm_empresa b"
+ " where a.empresa=b.codigo and a.tipo_convenio='C'"+appendFilter+" order by b.nombre,a.secuencia desc";

//System.out.println("\n\n ddddddddddddddddddsql="+sql+"\n\n");
al = SQLMgr.getDataList(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {

		String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONVENIO";
	String subtitle = "LISTADO DE CONVENIOS POR EMPRESA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setHeader2=new Vector();
	setHeader2.addElement(".04");//--10
	setHeader2.addElement(".31");//--40
	setHeader2.addElement(".03");//--10
	setHeader2.addElement(".19");//--
	setHeader2.addElement(".19");//--80
	setHeader2.addElement(".07");//
	setHeader2.addElement(".07");
	setHeader2.addElement(".10");//--

	pc.setNoColumnFixWidth(setHeader2);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setHeader2.size());

	pc.setFont(8, 1);
	pc.addCols(" ", 0,setHeader2.size());

	pc.addBorderCols("Cód.",0);
	pc.addBorderCols("Empresa",0);
	pc.addBorderCols("No.",0);
	pc.addBorderCols("Convenio",0);
	pc.addBorderCols("Contacto",0);
	pc.addBorderCols("F. Inicial",1);
	pc.addBorderCols("F. Final",1);
	pc.addBorderCols("Estado",0);

	pc.setTableHeader(3);

	if (al.size()==0) {
		pc.addCols("No existe el Convenio seleccionado",1,setHeader2.size());
	}
	else{

		for (int i=0; i<al.size(); i++)
		{
		    CommonDataObject cdo1 = (CommonDataObject) al.get(i);

			if (cdo1.getColValue("estatus").equals("A"))
			   estadoConvenio = "ACTIVO";
			else
			   estadoConvenio = "INACTIVO";

			pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("empresa"),0,1);
			pc.addCols(" "+cdo1.getColValue("empresaNombre"),0,1);
			pc.addCols(" "+cdo1.getColValue("secuencia"),0,1) ;
			pc.addCols(" "+cdo1.getColValue("nombre"),0,1) ;
			pc.addCols(" "+cdo1.getColValue("contacto"),0,1);
			pc.addCols(" "+cdo1.getColValue("fechaInicial"),1,1) ;
			pc.addCols(" "+cdo1.getColValue("fechaFinal"),1,1) ;
			pc.addCols(" "+estadoConvenio,0,1) ;

		}//End For

		pc.setFont(10,1);
		pc.addCols(al.size()+" Registro"+(al.size()>1?"s":"")+" en total",0,setHeader2.size());

    }//else
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);

}//GET
%>