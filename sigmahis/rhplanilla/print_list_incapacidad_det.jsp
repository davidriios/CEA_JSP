<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
		String nombreGrupo = "";
		String id   = request.getParameter("empId");
		String fechaInc = request.getParameter("fecha");
		String desde = request.getParameter("evDesde");
    String hasta = request.getParameter("evHasta");
    String grupo = request.getParameter("grupo");
	  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		String userName = UserDet.getUserName();
    ArrayList alIncap = new ArrayList();
    ArrayList totIncap = new ArrayList();
		ArrayList list   = new ArrayList();
	           Company com= new Company();


		sql="select a.codigo as compCode, a.nombre as compLegalName,nvl(a.ruc,'') as compRUCNo, nvl(a.apartado_postal,'') as compPAddress, a.zona_postal as compAddress, nvl(a.telefono,'') as compTel1, b.descripcion as compClave, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as other2, e.num_empleado as other1, e.emp_id as empId from tbl_sec_compania a, tbl_pla_ct_grupo b , tbl_pla_empleado e where a.codigo = b.compania and b.codigo = "+grupo+" and e.emp_id = "+id+" and a.codigo = e.compania and a.codigo="+(String) session.getAttribute("_companyId");

com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);



		sql = "select ce.provincia as provincia, ce.sigla as sigla, ce.tomo as tomo, ce.asiento as asiento, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as nombre, ce.num_empleado as numEmpleado, e.emp_id as empId, ce.grupo as grupo, ce.ubicacion_fisica as ubicFisisca, cg.descripcion as nombreGrupo,ag.nombre as nombreArea, to_char(i.fecha,'dd/mm/yyyy') as fecha, mf.descripcion as descripcion, i.motivo as comentarios, to_char(i.hora_salida,'HH12:MI AM') as ini, to_char(i.hora_entrada,'HH12:MI AM') fin, i.tiempo_horas as tiempoHoras, nvl(i.tiempo_minutos,0) as tiempoMinutos , (nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60) totHoras, trunc((nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60)/ h.cant_horas,0) tiempoDias, h.cant_horas from tbl_pla_ct_empleado ce, tbl_pla_empleado e, tbl_pla_ct_grupo cg, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h where e.provincia = ce.provincia and e.sigla=ce.sigla and e.tomo=ce.tomo and e.asiento=ce.asiento  and h.CODIGO = E.HORARIO AND  h.COMPANIA = E.COMPANIA and e.compania=ce.compania and i.provincia = ce.provincia and i.sigla=ce.sigla and i.tomo=ce.tomo and i.asiento=ce.asiento and i.compania=ce.compania and i.num_empleado=ce.num_empleado and mf.codigo= i.mfalta and cg.codigo=ce.grupo and cg.compania=ce.compania and ag.grupo=cg.codigo and ag.compania = ce.compania and ag.codigo=ce.ubicacion_fisica and i.ue_codigo = ce.grupo and e.emp_id = "+id+" and trunc(i.fecha) = to_date('"+fechaInc+"','dd/mm/yyyy') and ce.compania = "+(String) session.getAttribute("_companyId");

	alIncap = SQLMgr.getDataList(sql);


	sql = "select e.emp_id as totempId, ce.grupo as totgrupo, sum(i.tiempo_horas) as tottiempoHoras, sum(nvl(i.tiempo_minutos,0)) as tottiempoMinutos , sum(nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60) totHoras, trunc((nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60)/ h.cant_horas,0) tottiempoDias, sum(h.cant_horas) totcant_horas from tbl_pla_ct_empleado ce, tbl_pla_empleado e, tbl_pla_ct_grupo cg, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h where e.provincia = ce.provincia and e.sigla=ce.sigla and e.tomo=ce.tomo and e.asiento=ce.asiento  and h.CODIGO = E.HORARIO AND  h.COMPANIA = E.COMPANIA and e.compania=ce.compania and i.provincia = ce.provincia and i.sigla=ce.sigla and i.tomo=ce.tomo and i.asiento=ce.asiento and i.compania=ce.compania and i.num_empleado=ce.num_empleado and mf.codigo= i.mfalta and cg.codigo=ce.grupo and cg.compania=ce.compania and ag.grupo=cg.codigo and ag.compania = ce.compania and ag.codigo=ce.ubicacion_fisica and i.ue_codigo = ce.grupo and e.emp_id = "+id+" and trunc(i.fecha) = to_date('"+fechaInc+"','dd/mm/yyyy') and ce.compania = "+(String) session.getAttribute("_companyId")+" group by e.emp_id, ce.grupo, trunc((nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60)/ h.cant_horas,0)";

	totIncap = SQLMgr.getDataList(sql);



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

		String logoPath = java.util.ResourceBundle.getBundle("path").getString("images")+"/"+"lgc.jpg";
		String statusPath = "";
		boolean logoMark = false;
		boolean statusMark = false;
		float cHeight = 12.0f;

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
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+request.getParameter("__ct")+".pdf";
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
int totHoras = 0, totMin = 0;
int tiempoDias = 0, tiempoMin = 0;
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
					setValD.addElement(".10");
					setValD.addElement(".10");
					setValD.addElement(".30");
					setValD.addElement(".25");

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
					pc.addCols("del "+fechaInc+" al "+fechaInc,1,2);
				pc.addTable();

			    pc.createTable();
			       pc.setFont(7, 0);
			       pc.addCols("Por: "+userName+"  Fecha: "+cDateTime, 0, 2);
			       pc.addCols("Página: "+1+" de "+nPages, 2, 2);
			    pc.addTable();

			   pc.createTable();
						pc.setFont(10, 1);
						pc.addCols("  "+com.getOther1()+ "    "+com.getOther2(), 0, 2);
			   pc.addTable();

				 pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(8, 1);
					pc.addBorderCols("Fecha", 1);
					pc.addBorderCols("Turno Asignado", 1);
					pc.addBorderCols("Horas", 1);
					pc.addBorderCols("Minutos", 1);
					pc.addBorderCols("Motivo", 1);
					pc.addBorderCols("Grupo", 1);
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
					String emp = "";

					for (int z=0; z<alIncap.size(); z++)
					{

					CommonDataObject incap = (CommonDataObject) alIncap.get(z);
						no2 += 1;

							pc.createTable();
							pc.setFont(7, 1);
							pc.addCols(" "+incap.getColValue("Fecha"), 0,1);
							pc.addCols(" "+incap.getColValue("Ini")+ " / "+incap.getColValue("Fin") , 1,1);
							pc.addCols(" "+incap.getColValue("TiempoHoras"), 1,1);
							pc.addCols(" "+incap.getColValue("TiempoMinutos"), 1,1);
							pc.addCols(" "+incap.getColValue("Descripcion"), 0,1);
							pc.addCols(" "+incap.getColValue("nombreGrupo"), 0,1);
						pc.addTable();
						emp = incap.getColValue("numEmpleado");
						totHoras += Integer.parseInt(incap.getColValue("TiempoHoras"));
						totMin += Integer.parseInt(incap.getColValue("TiempoMinutos"));

						tiempoDias += Integer.parseInt(incap.getColValue("tiempoDias"));
						tiempoMin += Integer.parseInt(incap.getColValue("totHoras")) - (Integer.parseInt(incap.getColValue("totHoras")) / Integer.parseInt(incap.getColValue("cant_horas")) * Integer.parseInt(incap.getColValue("cant_horas")));
						if ((z + 1) == nItems) break;
						}//End For
					}//End If
					}//End else
					}
					pc.createTable();
						pc.setFont(8, 1);
						pc.addCols(" TIEMPO TOTAL TOMADO ---->    ", 2, 2);
						pc.addCols(" "+totHoras, 1, 1);
						pc.addCols(" "+totMin  , 1, 1);
						pc.addCols(" TIEMPO TOTAL TOMADO ---->    ", 2, 1);
						pc.addCols("  "+tiempoDias+ " día(s) con  "+tiempoMin + " hora(s)" , 1, 1);

					pc.addTable();


		for (int i=1; i<=3; i++)
			{
pc.createTable();
					pc.addCols(" ", 0, 6);
pc.addTable();
}

					pc.createTable();
						pc.setFont(8, 1);
						pc.addCols(" ", 0, 1);
						pc.addBorderCols(""+com.getOther2(),1,4,cHeight*2,Color.lightGray);
						pc.addCols("  ", 1, 1);
				pc.addTable();


					pc.createTable();
						pc.setFont(8, 1);
						pc.addCols(" ", 0, 1);
						pc.addBorderCols("GRUPO",1,3,cHeight*2,Color.lightGray);
						pc.addBorderCols("      HRS  /  MIN      DIAS  /  HRS  ",1,1,cHeight*2,Color.lightGray);
						pc.addCols("  ", 1, 1);

					pc.addTable();

						pc.createTable();
											pc.setFont(8, 1);
											pc.addCols(" ", 0, 1);
											pc.addBorderCols(" "+com.getCompClave(),1,3,0.5f,0.5f,0.5f,0.0f,0.0f);
											pc.addBorderCols(" "+totHoras+"       "+totMin+"                "+tiempoDias+"      " +tiempoMin+"       ",1,1,0.5f,0.5f,0.5f,0.5f,0.0f);

											pc.addCols("  ", 1, 1);

					pc.addTable();


				pc.close();
				response.sendRedirect(redirectFile);
			}//folder created
		}//get
	//}else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//}else throw new Exception("Usted no está logiado en este momento. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>




