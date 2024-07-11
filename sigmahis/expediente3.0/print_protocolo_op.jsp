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
REPORTE:  PROTOCOLO OPERATORIO
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
CommonDataObject cdoPacData = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (fg == null) fg = "PO";
if (desc == null ) desc = "";
if (code == null ) code = "0";

if (!code.equals("0")) sbFilter.append(" and a.codigo = ").append(code);

	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_PROT_OPE_SHOW_CIR'),'-') as showCir,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_PROT_OPE_SHOW_INS'),'-') as showIns from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());

	//PROTOCOLO OPERATORIO
	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.diag_pre_operatorio as codDiagPre, a.diag_pre_operatorio_desc, a.diag_post_operatorio as diagPost, a.diag_post_operatorio_desc, a.procedimiento as codProc, a.procedimiento_desc, a.cirujano, a.asistente, a.anestesia, a.anestesiologo, a.profilaxis_antibiotica as profilaxis, a.tiempo_profilaxis as tiempoProfilaxis, a.limpieza, a.incision, a.especimen_patologia as especimen, a.patologo, a.hallazgos, a.observacion, a.complicacion, a.transfusiones, a.medicamentos,(select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.cirujano) as cirujanoName, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.asistente),' ') as nombre_asistente, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.anestesiologo),' ') as nombre_anestesiologo, nvl(a.suturas,' ') as suturas, nvl(a.drenaje,' ') as drenaje, to_char(a.hora_inicio,'hh12:mi am') as hora_inicio, to_char(a.hora_fin,'hh12:mi am') as hora_fin, nvl(a.instrumentador,' ') as instrumentador, nvl(a.circulador,' ') as circulador, nvl(a.protocolo,' ') as protocolo, a.implantes, a.implantes_observ, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = a.instrumentador),a.instrumentador_nombre,' ') as instrumentador_nombre, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = a.circulador),a.circulador_nombre,' ') as circulador_nombre, a.sangrado, a.sangrado_desc, a.dispo_implantables, a.dispo_implantables_desc, a.muestras_histo, a.tot_muestras, a.tot_muestras_desc, a.transfusiones_desc, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||'      '||nvl(reg_medico, codigo) from tbl_adm_medico where codigo = (select ref_code from tbl_sec_users where user_name = a.usuario_creacion)),' ') as nombre_firma, a.drenaje_desc, a.complicacion_desc, (select descripcion from tbl_sal_tipo_anestesia where codigo = a.anestesia) as tipo_anestesia, get_idoneidad(a.usuario_creacion, 1) usuario_creacion, get_idoneidad(a.usuario_modificacion, 1) usuario_modificacion, to_char(a.FECHA_modificacion,'dd/mm/yyyy hh12:mi am') as FECHA_modificacion, to_char(a.FECHA_creacion, 'dd/mm/yyyy hh12:mi am') as FECHA_creacion from tbl_sal_protocolo_operatorio a where a.pac_id = ").append(pacId).append(" and a.admision = ").append(noAdmision).append(sbFilter);
	al = SQLMgr.getDataList(sbSql.toString());

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	int fontSize = 8;
	float cHeight = 12.0f;

		CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdoPacData.addColValue("is_landscape",""+isLandscape);
		}

		PdfCreator pc = null;
		boolean isUnifiedExp=false;
		pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		if(pc == null){
				pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
				isUnifiedExp=true;
		}

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".25");
		dHeader.addElement(".25");
		dHeader.addElement(".15");
		dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		if(al.size()==0){
			 pc.addCols("No Hay registros",1, dHeader.size());
		}else{

		pc.setFont(fontSize, 1);
		String groupBy  = "";

				for (int a=0; a<al.size(); a++) {

			CommonDataObject cdo0 = (CommonDataObject) al.get(a);

			if (!groupBy.trim().equalsIgnoreCase(cdo0.getColValue("codigo"))) {
								if (a != 0){
										// pc.flushTableBody(true);
										// pc.addNewPage();
				}
			}

			pc.setFont(fontSize, 1);
			pc.addCols("Fecha Creac.: "+cdo0.getColValue("FECHA_creacion", " "), 0, 2);
			pc.addCols("Usuario Creac.: "+cdo0.getColValue("usuario_creacion"," "),1,3);
			
			if (!cdo0.getColValue("usuario_modificacion"," ").trim().equals("")) {
				pc.addCols("Fecha Modif.: "+cdo0.getColValue("FECHA_modificacion"," "), 0, 2);
				pc.addCols("Usuario Modif.: "+cdo0.getColValue("usuario_modificacion"," "),1,3);
			}
			
			pc.addCols(" ", 0, dHeader.size());
			
			pc.addBorderCols("FECHA OPERACION: ",0,1,0.1f,0.1f,0.1f,0.1f);
						pc.setFont(fontSize, 0);
			pc.addBorderCols(cdo0.getColValue("fecha"),0,4,0.1f,0.1f,0.1f,0.1f);

						if(!fg.trim().equals("IP")) {

								pc.setFont(fontSize, 1);
								pc.addBorderCols("CIRUJANO: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("cirujanoname"),0,4,0.1f,0.1f,0.1f,0.1f);


								pc.setFont(fontSize, 1);
								pc.addBorderCols("MEDICO ASISTENTE: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("nombre_asistente"),0,4,0.1f,0.1f,0.1f,0.1f);

								pc.setFont(fontSize, 1);
								pc.addBorderCols("ANESTESIOLOGO: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("nombre_anestesiologo"),0,4,0.1f,0.1f,0.1f,0.1f);

				pc.setFont(fontSize, 1);
								pc.addBorderCols("TIPO DE ANESTESIA: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("tipo_anestesia"),0,4,0.1f,0.1f,0.1f,0.1f);

							if (!p.getColValue("showIns").equalsIgnoreCase("N")) {
								pc.setFont(fontSize, 1);
								pc.addBorderCols("INSTRUMENTADOR (A): ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("instrumentador_nombre"),0,4,0.1f,0.1f,0.1f,0.1f);
							}

							if (!p.getColValue("showCir").equalsIgnoreCase("N")) {
								pc.setFont(fontSize, 1);
								pc.addBorderCols("CIRCULADOR (A): ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("circulador_nombre"),0,4,0.1f,0.1f,0.1f,0.1f);
							}

								pc.setFont(fontSize, 1);
								pc.addBorderCols("HORA: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols("INICIO:   "+cdo0.getColValue("hora_inicio"," "),0,1,0.1f,0.1f,0.1f,0.1f);

								pc.setFont(fontSize, 1);
								pc.addBorderCols("FIN: ",1,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("hora_fin"),0,2,0.1f,0.1f,0.1f,0.1f);

				pc.setFont(fontSize, 1);
								pc.addBorderCols("HALLAZGOS TRANSOPERATORIOS: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("hallazgos"),0,4,0.1f,0.1f,0.1f,0.1f);

				pc.setFont(fontSize, 1);
								pc.addBorderCols("PROTOCOLO OPERATORIO: ",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("protocolo"),0,4,0.1f,0.1f,0.1f,0.1f);

								//DIAGNOSTICOS PREOPERATORIOS
								pc.setFont(12, 1,Color.black);
								pc.addBorderCols(" *** DIAGNOSTICO PRE-OPERATORIO ***",1,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 1);
								pc.addBorderCols("CODIGO",1,1,0.1f,0.1f,0.1f,0.1f);
								pc.addBorderCols("NOMBRE",1,4,0.1f,0.1f,0.1f,0.1f);

								pc.setVAlignment(0);

				pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("codDiagPre"),1,1,0.1f,0.1f,0.1f,0.1f);
								pc.addBorderCols(cdo0.getColValue("diag_pre_operatorio_desc"),0,4,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols(" ",1,dHeader.size(),0.1f,0.1f,0.1f,0.1f);


								//DIAGNOSTICOS POSTOPERATORIOS
								pc.setFont(12, 1,Color.black);
								pc.addBorderCols("*** DIAGNOSTICOS POST-OPERATORIO ***",1,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 1);
								pc.addBorderCols("CODIGO",1,1,0.1f,0.1f,0.1f,0.1f);
								pc.addBorderCols("NOMBRE",1,4,0.1f,0.1f,0.1f,0.1f);

								pc.setVAlignment(0);
				pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo0.getColValue("diagPost"),1,1,0.1f,0.1f,0.1f,0.1f);
								pc.addBorderCols(cdo0.getColValue("diag_post_operatorio_desc"),0,4,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols(" ",1,dHeader.size(),0.1f,0.1f,0.1f,0.1f);

								//PROCEDIMIENTOS REALIZADOS
								pc.setFont(12, 1,Color.black);
								pc.addBorderCols("*** OPERACIONES ***",1,dHeader.size(),0.1f,0.1f,0.1f,0.1f);

								pc.setFont(fontSize, 1);
								pc.addBorderCols("CODIGO",1,1,0.1f,0.1f,0.1f,0.1f);
								pc.addBorderCols("NOMBRE DEL PROCEDIMIENTO",1,4,0.1f,0.1f,0.1f,0.1f);

				pc.setFont(fontSize, 0);
				pc.addBorderCols(cdo0.getColValue("codProc"),1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols(cdo0.getColValue("procedimiento_desc"),0,4,0.1f,0.1f,0.1f,0.1f);

				String drenaje = "";
								if(cdo0.getColValue("drenaje")!=null&&cdo0.getColValue("drenaje").equalsIgnoreCase("S")) drenaje = "[ x ] SI            [    ] NO                  DETALLAR:    "+cdo0.getColValue("drenaje_desc");
								else if(cdo0.getColValue("drenaje")!=null&&cdo0.getColValue("drenaje").equalsIgnoreCase("N")) drenaje = "[    ] SI            [ x ] NO";
								else  drenaje = "[    ] SI            [    ] NO";

								pc.setFont(fontSize, 1);
								pc.addBorderCols("DRENAJES:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(drenaje,0,4,0.1f,0.1f,0.1f,0.1f);

								String reg = "";
								if(cdo0.getColValue("dispo_implantables")!=null&&cdo0.getColValue("dispo_implantables").equalsIgnoreCase("S")) reg = "[ x ] SI            [    ] NO                  DETALLAR:    "+cdo0.getColValue("dispo_implantables_desc");
								else if(cdo0.getColValue("dispo_implantables")!=null&&cdo0.getColValue("dispo_implantables").equalsIgnoreCase("N")) reg = "[    ] SI            [ x ] NO";
								else  reg = "[    ] SI            [    ] NO";

								pc.setFont(fontSize, 1);
								pc.addBorderCols("REGISTRO DE DISPOSITIVOS IMPLANTABLES:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(reg,0,4,0.1f,0.1f,0.1f,0.1f);

				String complicacion = "";
								if(cdo0.getColValue("complicacion")!=null&&cdo0.getColValue("complicacion").equalsIgnoreCase("S")) complicacion = "[ x ] SI            [    ] NO                  DETALLAR:    "+cdo0.getColValue("complicacion_desc");
								else if(cdo0.getColValue("complicacion")!=null&&cdo0.getColValue("complicacion").equalsIgnoreCase("N")) complicacion = "[    ] SI            [ x ] NO";
								else  complicacion = "[    ] SI            [    ] NO";

								pc.setFont(fontSize, 1);
								pc.addBorderCols("COMPLICACIONES PERIOPERATORIAS:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(complicacion,0,4,0.1f,0.1f,0.1f,0.1f);

								String muestra = "";
								if(cdo0.getColValue("muestras_histo")!=null&&cdo0.getColValue("muestras_histo").equalsIgnoreCase("S")) muestra = "[ x ] SI            [    ] NO                      Número de muestras: "+cdo0.getColValue("tot_muestras"," ")+"                      ESPECIFIQUE: "+cdo0.getColValue("tot_muestras_desc"," ");
								else if(cdo0.getColValue("muestras_histo")!=null&&cdo0.getColValue("muestras_histo").equalsIgnoreCase("N")) muestra = "[    ] SI            [ x ] NO                      Número de muestras: "+cdo0.getColValue("tot_muestras"," ")+"                      ESPECIFIQUE: "+cdo0.getColValue("tot_muestras_desc"," ");
								else  muestra = "[    ] SI            [    ] NO                      Número de muestras: "+cdo0.getColValue("tot_muestras"," ")+"                      ESPECIFIQUE: "+cdo0.getColValue("tot_muestras_desc"," ");

								pc.setFont(fontSize, 1);
								pc.addBorderCols("NÚMERO DE MUESTRAS HISTOPATOLÓGICAS:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(muestra,0,4,0.1f,0.1f,0.1f,0.1f);

				String sangrado = "";
								if(cdo0.getColValue("sangrado")!=null&&cdo0.getColValue("sangrado").equalsIgnoreCase("S")) sangrado = "[ x ] SI            [    ] NO                      DETALLAR: "+cdo0.getColValue("sangrado_desc"," ");
								else if(cdo0.getColValue("sangrado")!=null&&cdo0.getColValue("sangrado").equalsIgnoreCase("N")) sangrado = "[    ] SI            [ x ] NO";
								else  sangrado = "[    ] SI            [    ] NO";

								pc.setFont(fontSize, 1);
								pc.addBorderCols("PERDIDA SANGUINEA:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(sangrado,0,4,0.1f,0.1f,0.1f,0.1f);

				String transfusiones = "";
								if(cdo0.getColValue("transfusiones")!=null&&cdo0.getColValue("transfusiones").equalsIgnoreCase("S")) transfusiones = "[ x ] SI            [    ] NO                      DETALLAR: "+cdo0.getColValue("transfusiones_desc"," ");
								else if(cdo0.getColValue("transfusiones")!=null&&cdo0.getColValue("transfusiones").equalsIgnoreCase("N")) transfusiones = "[    ] SI            [ x ] NO";
								else  transfusiones = "[    ] SI            [    ] NO";

								pc.setFont(fontSize, 1);
								pc.addBorderCols("TRANSFUSIONES:",0,1,0.1f,0.1f,0.1f,0.1f);
								pc.setFont(fontSize, 0);
								pc.addBorderCols(transfusiones,0,4,0.1f,0.1f,0.1f,0.1f);
						}

						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());
						pc.addCols(" ",0,dHeader.size());

						if(!fg.trim().equals("IP")) {
								pc.addCols("Firmal del cirujano: ",0,1);
								pc.addBorderCols(cdo0.getColValue("nombre_firma"),0,2,0.10f,0.0f,0.0f,0.0f);
								pc.addCols(" ",0,2);
						}

				} // for
		}

pc.addTable();
if(isUnifiedExp){
		pc.close();
		response.sendRedirect(redirectFile);
}
%>