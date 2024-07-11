<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
Company com= new Company ();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
System.out.println("\n\n appendFilter="+appendFilter+"\n\n");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String repCode    = request.getParameter("repCode"); // para determinar el Area a la que pertenece la Unidad Administrativa
String grupoCode  = request.getParameter("grupoCode");
//String operativo = request.getParameter("operativo");
//String inversion = request.getParameter("inversion");


//----------------------------------------------- Company ---------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

if (appendFilter == null) appendFilter = "";

sql =   "SELECT secuen, a.cta1||' - '||a.cta2||' - '||a.cta3||' - '||a.cta4||' - '||a.cta5||' - '||a.cta6 as cuenta, b.descripcion FROM tbl_con_detalle_rep a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.cia_cta=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.cod_rep="+repCode+" and a.cod_grupo="+grupoCode+appendFilter+" order by a.secuen";

System.out.println("\n\n ddddddddddddddddddsql="+sql+"\n\n");
al = SQLMgr.getDataList(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 50; //max lines of items
		int nItems = al.size(); //number of items
		System.out.print("\n\n Items "+nItems+"\n\n");
		int extraItems = nItems % maxLines;
		System.out.print("\n\n extraItems "+extraItems+"\n\n");
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page

		//****************************************************
		// Calcular el número de páginas que tendrá el reporte
		//****************************************************
		if (extraItems == 0)
		   nPages = (nItems / maxLines);
			//System.out.print("\n\n nPages "+nPages+"\n\n");
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;

		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	    String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
		//String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

		String fecha = cDateTime;
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = mon;
		String servletPath = request.getServletPath();
		String day=fecha.substring(0, 2);
		String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
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
//System.out.println("******* directory="+directory);
		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {

			String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			

			int headerFooterFont = 4;
			//System.out.println("******* else");
			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;


			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont,      logoMark, logoPath, statusMark, statusPath);

	//Verificar
		int no = 0;

for (int j=1; j<=nPages; j++)
{
			Vector setHeader0=new Vector();
					   setHeader0.addElement(".2");
					   setHeader0.addElement(".8");
					   setHeader0.addElement(".2");
				pc.setNoColumnFixWidth(setHeader0);

				pc.createTable();
				pc.setFont(12, 1);
				pc.addImageCols(""+logoPath,30.0f,0);
				pc.setVAlignment(2);
				pc.addCols(com.getCompLegalName(),1, 1,15.0f);
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
					pc.addCols("RUC."+" "+com.getCompRUCNo(),1,1);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("Apdo."+" "+com.getCompPAddress()+" "+" "+" "+" "+" "+" "+" "+" Tels."+com.getCompTel1(),1,1);
				pc.addTable();

				pc.createTable();
				pc.setFont(9, 1);
				  pc.addCols("Contabilidad",1,1);
					pc.addCols("MANTENIMIENTO DETALLE DE REPORTES", 1, 1);
				pc.addTable();

			    pc.createTable();
			        pc.setFont(7, 0);
			        pc.addCols("Por: "+userName+"                        Fecha :  "+fecha, 0, 1);
			        pc.addCols("Página: "+j+" de "+nPages, 2, 1);
			    pc.addTable();

//				pc.createTable();
//					pc.addCols(" ", 0,4,5f);
//				pc.addTable();

				Vector setHeader2=new Vector();
					setHeader2.addElement(".10");
					setHeader2.addElement(".45");
					setHeader2.addElement(".45");
				pc.setNoColumnFixWidth(setHeader2);

				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols("", 0,4);
				pc.addTable();

				pc.createTable();
					pc.addBorderCols("Secuencia",0);
					pc.addBorderCols("Cuenta Financiera",0);
					pc.addBorderCols("Descripción",0);
				pc.addTable();

			//	 pc.createTable();
			//		pc.setFont(7, 1);
			//		pc.addCols("Área: "+grupoCode,0,1);
					//pc.addCols("Operativo: "+operativo+" - Inversión: "+inversion,0,1);
			//	  pc.addCols("",0,1);
			//	pc.addTable();


				if (al.size()==0) {
						pc.createTable();
							pc.addCols("No existe la secuencia seleccionada",1,5);
						pc.addTable();

						}
				else{
					if (al.size() > 0)
					{
						//for(int i=0;i<maxLines;i++)
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
						    CommonDataObject cdo1 = (CommonDataObject) al.get(i);
								no += 1;

								pc.createTable();
								pc.setFont(7, 0);
									pc.addCols(" "+cdo1.getColValue("secuen"),0,1);
									pc.addCols(" "+cdo1.getColValue("cuenta"),0,1);
									pc.addCols(" "+cdo1.getColValue("descripcion"),0,1);
								pc.addTable();

									if ((i + 1) == nItems) break;
						}//End For

						 pc.createTable();
							 pc.addCols(al.size()+" Registros en total",0,5);
						 pc.addTable();

						}//End If
						if((no+2)<=maxLines){
				}else{
					pc.addNewPage();
				}
				}


			}//End For




	pc.close();
				response.sendRedirect(redirectFile);
		}
		}

%>


