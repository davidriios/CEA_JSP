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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
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

sql =   "SELECT a.tipo_servicio as tipoServCode, a.centro_servicio as centroServCode, b.descripcion as tipoServ, c.descripcion as centroServ, a.cg_cta1||'-'||a.cg_cta2||'-'||a.cg_cta3||'-'||a.cg_cta4||'-'||a.cg_cta5||'-'||a.cg_cta6 as ctaFinanciera, d.descripcion as cuentaIngre "
+ " FROM tbl_cds_ts_x_centro a, tbl_cds_tipo_servicio b, tbl_cds_centro_servicio c, tbl_con_catalogo_gral d "
+ " WHERE a.tipo_servicio=b.codigo and a.centro_servicio=c.codigo and a.cg_cta1=d.cta1(+) and a.cg_cta2=d.cta2(+) and "
+ " a.cg_cta3=d.cta3(+) and a.cg_cta4=d.cta4(+) and a.cg_cta5=d.cta5(+) and a.cg_cta6=d.cta6(+) "
+ " and a.cg_compania=d.compania(+)"+appendFilter;

System.out.println("\n\n ddddddddddddddddddsql="+sql+"\n\n");
al = SQLMgr.getDataList(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 20; //max lines of items
		int nItems = al.size(); //number of items
		System.out.print("\n\n Items "+nItems+"\n\n");
		int extraItems = nItems % maxLines;
		System.out.print("\n\n extraItems "+extraItems+"\n\n");
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page

		//****************************************************
		// Calcular el n�mero de p�ginas que tendr� el reporte
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
		//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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
					pc.addCols("CENTROS DE SERVICIO POR TIPO Y CUENTA", 1, 1);
				pc.addTable();

			    pc.createTable();
			        pc.setFont(7, 0);
			        pc.addCols("Por: "+userName+"                        Fecha :  "+fecha, 0, 1);
			        pc.addCols("P�gina: "+j+" de "+nPages, 2, 1);
			    pc.addTable();

//				pc.createTable();
//					pc.addCols(" ", 0,4,5f);
//				pc.addTable();

				Vector setHeader2=new Vector();
					setHeader2.addElement(".23");
					setHeader2.addElement(".25");
					setHeader2.addElement(".15");
					setHeader2.addElement(".37");
				pc.setNoColumnFixWidth(setHeader2);

				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols("", 0,4);
				pc.addTable();

				pc.createTable();
					pc.addBorderCols("Tipo Servicio",0);
					pc.addBorderCols("Centro Servicio",0);
					pc.addBorderCols("Cuenta Ingreso",0);
					pc.addBorderCols("Nombre Cuenta",0);
				pc.addTable();

			//	 pc.createTable();
			//		pc.setFont(7, 1);
			//		pc.addCols("�rea: "+grupoCode,0,1);
					//pc.addCols("Operativo: "+operativo+" - Inversi�n: "+inversion,0,1);
			//	  pc.addCols("",0,1);
			//	pc.addTable();


				if (al.size()==0) {
						pc.createTable();
							pc.addCols("No existe el Servicio seleccionado",1,5);
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
									pc.addCols(" "+cdo1.getColValue("tipoServ"),0,1);
									pc.addCols(" "+cdo1.getColValue("centroServ"),0,1);
									pc.addCols(" "+cdo1.getColValue("ctaFinanciera"),0,1);
									pc.addCols(" "+cdo1.getColValue("cuentaIngre"),0,1);
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



