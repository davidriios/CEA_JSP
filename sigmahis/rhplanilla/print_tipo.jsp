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
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />

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
	    String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
	    ArrayList alTipo = new ArrayList();
		ArrayList list   = new ArrayList();
	           Company com= new Company();


		sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");

com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);


		sql= "select codigo as codigo, descripcion as documento, horas_tiempoext as horaInicio, nvl(minutos_contar,0) as horaFinal, nvl(minimo_minutos,0) as secuencia, nvl(dias_enfermedad,0) as certificado from tbl_pla_tipo_empleado order by codigo";

	alTipo  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

 	if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 60; //max lines of items
		int nItems = list.size(); //number of items
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

		String folderName = "rhplanilla";
		String fileNamePrefix = "print_tipo";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
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
		String day=fecha.substring(0, 2);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else
		{
			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

			int headerFooterFont = 4;

			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;

			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);


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
					setValD.addElement(".25");
					setValD.addElement(".15");
					setValD.addElement(".15");
					setValD.addElement(".15");
					setValD.addElement(".20");

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
					pc.addCols("Tipos de Empleados",0,2);
					pc.addTable();


				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(7, 1);
					pc.addBorderCols("Código", 1);
					pc.addBorderCols("Descripción", 1);
					pc.addBorderCols("Tiempo Extra", 1);
					pc.addBorderCols("Minutos a Contar", 1);
					pc.addBorderCols("Mínimo Minutos", 1);
					pc.addBorderCols("Días de Enfermedad", 1);
				pc.addTable();


					if(alTipo.size()==0)
					{

					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("No Existen Tipos Registrados.",1,2);
					pc.addTable();

				  }//End If
					else
					{
					if (alTipo.size() > 0)
					{
					for (int z=0; z<alTipo.size(); z++)
					{	Admision tip = (Admision) alTipo.get(z);
						no2 += 1;

										pc.createTable();
							pc.setFont(7, 1);
							pc.addCols(" "+tip.getCodigo(), 0,1);
							pc.addCols(" "+tip.getDocumento(), 0,1);
							pc.addCols(" "+tip.getHoraInicio(), 1,1);
							pc.addCols(" "+tip.getHoraFinal(), 1,1);
							pc.addCols(" "+tip.getSecuencia(), 1,1);
							pc.addCols(" "+tip.getCertificado(), 1,1);
						pc.addTable();

						if ((z + 1) == nItems) break;
						}//End For
					}//End If
					}//End else
					}

				pc.close();
				response.sendRedirect(redirectFile);
			}//folder created
		}//get
	//}else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//}else throw new Exception("Usted no está logiado en este momento. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>




