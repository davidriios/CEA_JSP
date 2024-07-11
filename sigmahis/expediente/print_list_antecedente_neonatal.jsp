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
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

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
	    Company com= new Company();


		   sql = "select codigo, descripcion,orden, es_default, decode(valor,'A','ALFANUMERICO','N','NUMERICO') as fvalor from tbl_sal_factor_neonatal"+appendFilter;
al = SQLMgr.getDataList(sql);

 	if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 40; //max lines of items
		int nItems = al.size(); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		if (extraItems == 0) nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;

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

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else
		{
			String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			

			int headerFooterFont = 4;

			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;

			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);


int no2 = 0;
			for (int j=1; j<=nPages; j++)
			{
				Vector setHeader0=new Vector();
				   setHeader0.addElement(".2");
				   setHeader0.addElement(".8");
				   setHeader0.addElement(".2");
				pc.setNoColumnFixWidth(setHeader0);

				Vector setValD=new Vector();

					setValD.addElement(".10");
					setValD.addElement(".50");
					setValD.addElement(".20");
					setValD.addElement(".10");
					setValD.addElement(".10");


				pc.createTable();
				pc.setFont(12, 1);
				pc.addImageCols(""+logoPath,30.0f,0);
				pc.setVAlignment(2);
				pc.addCols(_comp.getNombre(),1, 1,15.0f);
				pc.addCols("",1,1,15.0f);
				pc.addTable();

				Vector setHeader1 = new Vector();
				setHeader1.addElement(".1000");
				pc.setNoColumnFixWidth(setHeader1);

				pc.createTable();
				pc.addBorderCols("1",0,1,1.5f,0.0f,0.0f,0.0f,5.0f);
				pc.addTable();

				Vector setHeader9=new Vector();
				setHeader9.addElement(".100");
				pc.setNoColumnFixWidth(setHeader9);

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("RUC."+" "+_comp.getRuc(),1,1);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("Apdo."+" "+_comp.getApartadoPostal()+" "+" "+" "+" "+" "+" "+" "+" Tels."+_comp.getTelefono(),1,1);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("EXPEDIENTE",1,2);
					pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("ANTECEDENTES NEONATALES",1,2);
					pc.addTable();
				pc.createTable();
			        pc.setFont(7, 1);
			        pc.addCols("Por: "+userName+"                        Fecha :  "+fecha, 0, 2);
			        pc.addCols("Página: "+j+" de "+nPages, 2, 2);
			    pc.addTable();

				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(7, 1);
					pc.addBorderCols("Código",1);
					pc.addBorderCols("Descripción",0);
					pc.addBorderCols("Valor",0);
					pc.addBorderCols("Orden",1);
					pc.addBorderCols("Por defecto",1);

				pc.addTable();
				pc.createTable();
					pc.addCols("", 0,5);
				pc.addTable();

					if(al.size()==0)
					{
					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("No Existen Antecedentes Neonatales Registrados.",1,2);
					pc.addTable();

				  }//End If
					else
					for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
					{
							CommonDataObject cdo1 = (CommonDataObject) al.get(i);
							no2 += 1;
							pc.createTable();
							pc.setFont(7, 1);
								pc.addCols(" "+cdo1.getColValue("codigo"), 1,1);
								pc.addCols(" "+cdo1.getColValue("descripcion"), 0,1);
							pc.addCols(" "+cdo1.getColValue("fValor"), 0,1);
							pc.addCols(" "+cdo1.getColValue("orden"), 1,1);
							pc.addCols(" "+cdo1.getColValue("es_default"), 1,1);
							pc.addTable();

							if ((i + 1) == nItems)
							{
		   						pc.createTable();
									pc.addCols(al.size()+" Registros en total",0,5);
								pc.addTable();
								break;
							 }
					}//End For

					if((no2+2)<=maxLines)
					{
					}
					else
					{
						pc.addNewPage();
					}
				}//end for j
				pc.close();
				response.sendRedirect(redirectFile);
			}//folder created
		}//get
	//}else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//}else throw new Exception("Usted no está logiado en este momento. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>




