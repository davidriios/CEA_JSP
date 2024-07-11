<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%@ include file ="../common/pdf_header.jsp" %>
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
		UserDet=SecMgr.getUserDetails(session.getId());
		session.setAttribute("UserDet",UserDet);
		issi.admin.ISSILogger.setSession(session);

		CmnMgr.setConnection(ConMgr);
		SQLMgr.setConnection(ConMgr);

		SQL2BeanBuilder sbb = new SQL2BeanBuilder();
    	String strCondicion = "";
		String sql = "";
		String appendFilter = request.getParameter("appendFilter");
		if(appendFilter== null)appendFilter="";
		String tipoCode = request.getParameter("tipoCode");
	    String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		String userName = UserDet.getUserName();
	    ArrayList alTipo = new ArrayList();
		ArrayList list   = new ArrayList();
		ArrayList al   = new ArrayList();

		  sql = "select codigo, descripcion, decode(tipo_liquido,'I','INGRESO','E','EGRESO','M','MEDICAMENTO') as tliquido from tbl_sal_via_admin "+(!appendFilter.equals("")?" where "+appendFilter:appendFilter) +" order by tliquido";
			al = SQLMgr.getDataList(sql);

 	if(request.getMethod().equalsIgnoreCase("GET")) {

		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
		String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String statusPath = "";
		boolean logoMark = false;
		boolean statusMark = false;

		String fecha = cDateTime;
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = mon;
		String servletPath = request.getServletPath();
		String day=fecha.substring(0, 2);
		String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";		
		
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
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";		
		String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
		String create = CmnMgr.createFolder(directory, folderName, year, month);
		
		String xtraCompanyInfo = "";
	    String title = "EXPEDIENTE";
	    String subtitle = "VIAS DE INGRESO - EGRESO";
	    String xtraSubtitle = "";
		boolean displayPageNo = true;
	    float pageNoFontSize = 0.0f;//between 7 and 10
        String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	    String pageNoPoxX = null;//L=Left, R=Right
	    String pageNoPosY = null;//T=Top, B=Bottom

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else
		{
			String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			//

			int headerFooterFont = 4;

			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;

			//issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);
			
			PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector setValD=new Vector();

					setValD.addElement(".15");
					setValD.addElement(".65");
					setValD.addElement(".20");

				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
				
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setValD.size());
				
					pc.setFont(9, 1);
					pc.addBorderCols("Codigo",1);
					pc.addBorderCols("Descripcion",0,2);
					
					pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
					
					String tipoLiquido = "";

					if(al.size()==0)
					{
						pc.setFont(7, 1);
						pc.addCols("No Existen Factores Personales Registrados.",1,setValD.size());

				     }//End If
					else
					for ( int i=0; i<al.size(); i++ )
					{
							CommonDataObject cdo1 = (CommonDataObject) al.get(i);
							
						    if ( !cdo1.getColValue("tliquido").equals(tipoLiquido) ) {
							     pc.setFont(8,1,java.awt.Color.white);
					             pc.addBorderCols("Tipo Líquido: "+cdo1.getColValue("tliquido"),0,setValD.size(),java.awt.Color.lightGray);
							}
							
							pc.setFont(7,1);
							pc.addCols(" "+cdo1.getColValue("codigo"), 1,1);
							pc.addCols(" "+cdo1.getColValue("descripcion"), 0,2);
							
							
							tipoLiquido = cdo1.getColValue("tliquido");

					}//End For
				pc.addTable();
				pc.close();
				response.sendRedirect(redirectFile);
			}//folder created
		}//get
	//}else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//}else throw new Exception("Usted no está logiado en este momento. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>




