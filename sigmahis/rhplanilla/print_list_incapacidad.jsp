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
		String id   = request.getParameter("empId");
		String desde = request.getParameter("evDesde");
        String hasta = request.getParameter("evHasta");
        //String area  = request.getParameter("area");
	    String grupo = request.getParameter("grupo");
	    String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
	    ArrayList alIncap = new ArrayList();
		ArrayList list   = new ArrayList();
	           Company com= new Company();


		sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");

com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);


		sql= "select ce.provincia as provincia, ce.sigla as sigla, ce.tomo as tomo, ce.asiento as asiento, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as nombre, ce.num_empleado as numEmpleado, e.emp_id as empId, ce.grupo as grupo, ce.ubicacion_fisica as ubicFisisca, cg.descripcion as nombreGrupo, ag.nombre as nombreArea, to_char(i.fecha,'dd/mm/yyyy') as fecha, mf.descripcion as descripcion, i.motivo as comentarios, to_char(i.hora_salida,'HH12:MI AM') as ini, to_char(i.hora_entrada,'HH12:MI AM') fin, i.tiempo_horas as tiempoHoras, nvl(i.tiempo_minutos,0) as tiempoMinutos from tbl_pla_ct_empleado ce, tbl_pla_empleado e, tbl_pla_ct_grupo cg, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf where e.provincia = ce.provincia and e.sigla=ce.sigla and e.tomo=ce.tomo and e.asiento=ce.asiento and e.compania=ce.compania and i.provincia = ce.provincia and i.sigla=ce.sigla and i.tomo=ce.tomo and i.asiento=ce.asiento and i.compania=ce.compania and i.num_empleado=ce.num_empleado and mf.codigo= i.mfalta and cg.codigo=ce.grupo and cg.compania=ce.compania and ag.grupo=cg.codigo and ag.compania = ce.compania and ag.codigo=ce.ubicacion_fisica and i.ue_codigo = ce.grupo and e.emp_id = "+id+" and ce.compania = "+(String) session.getAttribute("_companyId");

	alIncap = SQLMgr.getDataList(sql);

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
		String fileNamePrefix = "print_incap";
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
					setValD.addElement(".15");
					setValD.addElement(".15");
					setValD.addElement(".15");
					setValD.addElement(".15");
					setValD.addElement(".30");

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
					pc.addCols("RECURSOS HUMANOS",1,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("INFORME DE INCAPACIDADES",1,2);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("del "+desde+" al "+hasta,1,2);
				pc.addTable();

			    pc.createTable();
			       pc.setFont(7, 0);
			       pc.addCols("Por: "+userName+"  Fecha: "+cDateTime, 0, 2);
			       pc.addCols("Página: "+1+" de "+nPages, 2, 2);
			    pc.addTable();

				  pc.createTable();
			          pc.setFont(10, 1);
			          pc.addCols("Grupo:  ", 0, 2);
			          pc.addTable();

				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(8, 1);
					pc.addBorderCols("Fecha", 1);
					pc.addBorderCols("Desde", 1);
					pc.addBorderCols("Hasta", 1);
					pc.addBorderCols("Horas", 1);
					pc.addBorderCols("Minutos", 1);
					pc.addBorderCols("Motivo / Comentarios", 1);
				pc.addTable();


					if(alIncap.size()==0)
					{

					pc.createTable();
						pc.setFont(7, 1);
						pc.addCols("No Existen Incapacidades Registrados.",1,2);
					pc.addTable();

				  }//End If
					else
					{
					if (alIncap.size() > 0)
					{
					for (int z=0; z<alIncap.size(); z++)
					{


					CommonDataObject incap = (CommonDataObject) alIncap.get(z);
						no2 += 1;

					  pc.createTable();
			          pc.setFont(10, 1);
			          pc.addCols("Grupo:  ", 0, 2);
			          pc.addTable();

							pc.createTable();
							pc.setFont(7, 1);
							pc.addCols(" "+incap.getColValue("Fecha"), 0,1);
							pc.addCols(" "+incap.getColValue("Ini"), 1,1);
							pc.addCols(" "+incap.getColValue("Fin"), 1,1);
							pc.addCols(" "+incap.getColValue("TiempoHoras"), 1,1);
							pc.addCols(" "+incap.getColValue("TiempoMinutos"), 1,1);
							pc.addCols(" "+incap.getColValue("Descripcion")+" / "+incap.getColValue("Comentarios"), 0,1);
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




