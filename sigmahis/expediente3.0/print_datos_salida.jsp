<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.Properties"%>
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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();

CommonDataObject cdo1, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String codigo = request.getParameter("codigo");
String toBeMailed = request.getParameter("toBeMailed")==null?"":request.getParameter("toBeMailed");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if (desc == null ) desc = "SUMARIO DE EGRESO MEDICO";
if (codigo == null ) codigo = "0";

sql = "select  nvl(aa.medico,' ') as medico,m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, nvl(aa.contacto,' ')contacto ,nvl(aa.parentezco_contacto,' ')parentezco_contacto ,nvl(aa.telefono_contacto,' ') telefono_contacto,nvl(em.descripcion,' ') especialidad,nvl(m.telefono_trabajo,' ') telefonoMedico,nvl(m.lugar_de_trabajo,' ')direccionTrabajo, to_char(aa.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, aa.usuario_creacion  from tbl_adm_especialidad_medica em,tbl_adm_medico_especialidad me ,tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and m.codigo = me.medico(+) and me.secuencia(+) =1 and me.especialidad=em.codigo(+)  and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null";

cdo1 = SQLMgr.getData(sql);
if (cdo1 == null) cdo1 = new CommonDataObject();

	// DIAGNOSTICOS DE SALIDA.
	sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, to_char(a.fecha_modificacion,'hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
	al = SQLMgr.getDataList(sql);
	//MEDICAMENTOS RECETADOS
	sql="select pac_id, admision, secuencia,medicamento, indicacion, dosis, duracion, to_char(fecha_creacion,'dd/mm/yyyy') as fecha_creacion, usuario_creacion from tbl_sal_salida_medicamento where pac_id = "+pacId+" and admision = "+noAdmision;
	al1 = SQLMgr.getDataList(sql);

	//DIETAS
	sql= "select a.tipo_dieta ,a.subtipo_dieta, a.observacion, b.descripcion descSubTipo,b.observacion obserSubDieta,c.descripcion descDieta, a.restrict_nutri, a.restrict_nutri_obs from tbl_sal_salida_dieta a,tbl_cds_subtipo_dieta b,tbl_cds_tipo_dieta c where a.tipo_dieta = b.cod_tipo_dieta and a.subtipo_dieta = b.codigo and b.cod_tipo_dieta = c.codigo and a.pac_id = "+pacId+" and a.admision = "+noAdmision;
	al2 = SQLMgr.getDataList(sql);

	//CUIDADOS EN CASA
	sql= " select a.pac_id, a.admision, a.guia_id, decode(a.guia_id,-1,a.guia_desc,b.nombre) as descGuia, a.observacion from tbl_sal_salida_cuidado a, tbl_sal_guia b where a.guia_id = b.id(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.status = 'A' order by a.codigo";
	al3 = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	String fecha2 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String fecha = fecha2.substring(0,10);
	String date = fecha2.substring(10);
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

	PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".25");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha2, dHeader.size());

				pc.setTableHeader(1);

		pc.setFont(11, 1);
		pc.addBorderCols("MOTIVOS DE INGRESO",0,dHeader.size(),Color.lightGray);

				CommonDataObject cdoM = SQLMgr.getData("select dolencia_principal, observacion motivo_hospitalizacion from tbl_sal_padecimiento_admision where pac_id = "+pacId+" and secuencia = "+noAdmision);
				if (cdoM == null) cdoM = new CommonDataObject();

				pc.setFont(fontSize,1);
		pc.addCols("DOLENCIA PRINCIPAL [MOTIVO DE CONSULTA]",0,dHeader.size());
				pc.setFont(fontSize,0);
				pc.addCols(cdoM.getColValue("dolencia_principal"," "),0,dHeader.size());

				pc.addCols("",0,dHeader.size());

				pc.setFont(fontSize,1);
		pc.addCols("HISTORIA DE LA ENFERMEDAD ACTUAL (INICIO, SINTOMAS, ASISTENCIA MEDICA Y OTROS)",0,dHeader.size());
				pc.setFont(fontSize,0);
				pc.addCols(cdoM.getColValue("motivo_hospitalizacion"," "),0,dHeader.size());

				pc.addCols(" ",0,dHeader.size());

		pc.setFont(11, 1);
		pc.addBorderCols("DIAGNOSTICOS DE SALIDA",0,dHeader.size(),Color.lightGray);
		pc.addBorderCols("CODIGO",0,1);
		pc.addBorderCols("USER - FECHA",1,1);
		pc.addBorderCols("NOMBRE",1,2);
		pc.addBorderCols("PRIORIDAD",1,1);

				pc.setFont(fontSize, 0);
				pc.setVAlignment(0);
				for (int i=0; i<al.size(); i++) {
						CommonDataObject cdo = (CommonDataObject) al.get(i);

						pc.setFont(fontSize, 0);
						pc.addBorderCols("     "+cdo.getColValue("diagnostico"),0,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdo.getColValue("usuario_creacion")+" - "+cdo.getColValue("fecha_creacion"),0,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdo.getColValue("diagnosticoDesc"),0,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdo.getColValue("orden_diag"),1,1,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols(" ",1,dHeader.size());

				pc.setFont(12, 1);
		pc.addBorderCols("EVOLUCION MEDICA",0,dHeader.size(),Color.lightGray);
				pc.addCols("",1,dHeader.size());

				ArrayList alEM = SQLMgr.getDataList("select a.progreso_id, a.pac_id, a.admision,to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.fecha,'hh12:mi am') hora, a.medico, a.observacion, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido|| decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(am.sexo,'f', decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico, a.otros from tbl_sal_progreso_clinico a,tbl_adm_medico am where a.pac_id(+)= "+pacId+" and a.admision="+noAdmision+" and a.medico=am.codigo order by a.fecha desc");

				String groupBy = "";

				for (int i=0; i<alEM.size(); i++){
			if(i==1) break;
						CommonDataObject cdo = (CommonDataObject) alEM.get(i);

						if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha")+"-"+cdo.getColValue("medico"))){
					if (i != 0){
										pc.addCols(" ",0,dHeader.size());
										pc.addCols("#"+i,0,dHeader.size());
								}
								pc.setFont(fontSize, 1);
								pc.addBorderCols("Médico: "+cdo.getColValue("nombre_medico"),0,3);
								pc.addBorderCols("Fecha: "+cdo.getColValue("fecha"),1,2);
			}
						pc.setFont(fontSize, 1);
						pc.addCols("OBSERVACION DEL MEDICO",0,3);
						pc.setFont(fontSize, 3);
						pc.addCols(cdo.getColValue("hora"),1,2);

						pc.addCols(" ",0,dHeader.size(),cHeight);
						pc.setFont(fontSize, 0);
						pc.addBorderCols("     "+cdo.getColValue("observacion"," "),0,5,0.5f,0.0f,0.0f,0.0f);

						pc.addCols(" ",1,dHeader.size());
										pc.setFont(fontSize, 1);
										pc.addCols("PLAN DE CUIDADO MÉDICO (SOAP)",0,dHeader.size(),Color.lightGray);

										ArrayList alSOAP = SQLMgr.getDataList("select h.codigo, h.descripcion, d.soap_id, d.seleccionar from tbl_sal_progreso_clinico_soap h, tbl_sal_progreso_clinico_det d where h.codigo = d.soap_id(+) and h.status = 'A' and d.pac_id(+) = "+pacId+" and admision(+) = "+noAdmision+" and d.progreso_id(+) = "+cdo.getColValue("progreso_id","0")+" order by h.orden");

										Vector tblSOAP = new Vector();
										tblSOAP.addElement("76");
										tblSOAP.addElement("9");
										tblSOAP.addElement("3");
										tblSOAP.addElement("9");
										tblSOAP.addElement("3");

										pc.setNoColumnFixWidth(tblSOAP);
										pc.createTable("tblSOAP",false);

										pc.setFont(fontSize, 0);
										for (int d = 0; d < alSOAP.size(); d++){
											 CommonDataObject cdoD = (CommonDataObject) alSOAP.get(d);
											 pc.addBorderCols(cdoD.getColValue("descripcion"),0,1);
											 pc.addBorderCols("SI",1,1);
											 pc.addImageCols( (cdoD.getColValue("seleccionar")!=null && cdoD.getColValue("seleccionar").equalsIgnoreCase("S"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);

											 pc.addBorderCols("NO",1,1);
											 pc.addImageCols( (cdoD.getColValue("seleccionar")!=null && cdoD.getColValue("seleccionar").equalsIgnoreCase("N"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
										}

										pc.useTable("main");
										pc.addTableToCols("tblSOAP",0,dHeader.size(),0);

						pc.addCols(" ",1,dHeader.size());
						pc.setFont(fontSize, 1);
						pc.addCols("OTROS PLANES DE CUIDADO",0,dHeader.size());

						pc.setFont(fontSize, 0);
						pc.addCols(cdo.getColValue("otros"),0,dHeader.size());

						groupBy = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
				}

				pc.addCols(" ",1,dHeader.size());

				pc.setFont(11, 1);
				pc.addBorderCols("MEDICAMENTOS",0,dHeader.size(),Color.lightGray);
				pc.addCols("",0,dHeader.size());

				Vector tblM = new Vector();
				tblM.addElement("5"); // orden
				tblM.addElement("15"); // Fecha Hora
				tblM.addElement("30"); // Medicamento
				tblM.addElement("10"); // Via
				tblM.addElement("5"); // Frec.
				tblM.addElement("10"); // Ordenado por
				tblM.addElement("24"); // Observación

				ArrayList alM = SQLMgr.getDataList("select a.orden_med, to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica, a.nombre as medicamento, a.dosis, (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia, a.frecuencia as descfrecuencia, a.observacion, a.estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'O',to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'O',a.omitir_usuario,'--') usuario_omit, /*a.usuario_creacion*/'['||a.usuario_creacion||'] - '||b.name  as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha_creacion, a.codigo,nvl(a.ejecutado,'N')ejecutado,nvl(a.relevante,'N')relevante,a.codigo_orden_med as noOrden from tbl_sal_detalle_orden_med a, tbl_sec_users b  where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and b.user_name(+) = a.usuario_creacion and a.tipo_orden=2 and a.estado_orden='A' and nvl(a.omitir_orden,'N') = 'N' and relevante = 'Y' order by a.fecha_orden desc,a.codigo_orden_med desc,a.orden_med desc");

				pc.setNoColumnFixWidth(tblM);
				pc.createTable("tblM",false);

				pc.setFont(fontSize, 1);
				pc.addBorderCols("ORD.",1,1);
				pc.addBorderCols("FECHA-HORA",1,1);
				pc.addBorderCols("MEDICAMENTO",0,1);
				pc.addBorderCols("VIA",1,1);
				pc.addBorderCols("FREC.",1,1);
				pc.addBorderCols("ORDENADO POR",1,1);
				pc.addBorderCols("OBSERVACION",0,1);

				pc.setFont(fontSize, 0);
				for (int m = 0; m < alM.size(); m++) {
					CommonDataObject cdoMed = (CommonDataObject) alM.get(m);
					pc.addBorderCols(cdoMed.getColValue("noOrden"),1,1);
					pc.addBorderCols(cdoMed.getColValue("fecha_creacion"),1,1);
					pc.addBorderCols(cdoMed.getColValue("medicamento"),0,1);
					pc.addBorderCols(cdoMed.getColValue("descVia"),1,1);
					pc.addBorderCols(cdoMed.getColValue("descFrecuencia"),1,1);
					pc.addBorderCols(cdoMed.getColValue("usuario_crea"),1,1);
					pc.addBorderCols(cdoMed.getColValue("observacion"),0,1);
				}
				
				CommonDataObject cdoMedRel = SQLMgr.getData("select medicamentos from tbl_sal_med_rel_omitidos where pac_id = "+pacId+" and no_admision = "+noAdmision);
				if (cdoMedRel == null) {
				  cdoMedRel = new CommonDataObject();
			    }
				
				if (!cdoMedRel.getColValue("medicamentos", " ").trim().equals("")) {
					pc.addCols("",1,tblM.size());

					pc.setFont(fontSize, 1);
					pc.addBorderCols("OTROS MEDICAMENTOS RELEVANTES",0,tblM.size(),Color.lightGray);
					pc.addCols("",0,tblM.size());
					pc.setFont(fontSize, 0);
					pc.addCols(cdoMedRel.getColValue("medicamentos"),0,tblM.size());
				}

				pc.useTable("main");
				pc.addTableToCols("tblM",0,dHeader.size(),0);

				pc.addCols(" ",1,dHeader.size());

				pc.setFont(11,1);
				pc.addBorderCols("DIETAS A SEGUIR",0,dHeader.size(),Color.lightGray);

				pc.setFont(fontSize, 1);
				pc.addBorderCols("     CODIGO",0,1);
				pc.addBorderCols("DIETA",1,1);
				pc.addBorderCols("OBSERVACION",1,3);

				pc.setFont(fontSize, 0);
				for (int i=0; i<al2.size(); i++){
						CommonDataObject cdo = (CommonDataObject) al2.get(i);

						pc.setFont(fontSize, 0);
						pc.addBorderCols("     "+cdo.getColValue("descDieta"),0,1);
						pc.addBorderCols(cdo.getColValue("descSubTipo"),0,1);
						pc.addBorderCols(cdo.getColValue("observacion"),0,3);

						if (cdo.getColValue("restrict_nutri","N").equalsIgnoreCase("S") && (i+1) == al2.size() ) {
								pc.addCols(" ",0,dHeader.size());
								pc.setFont(fontSize, 1);
								pc.addCols("RESTRICCIÓN NUTRICIONAL:",0,dHeader.size());
								pc.setFont(fontSize, 0);
								pc.addCols(cdo.getColValue("restrict_nutri_obs"),0,dHeader.size());
						}
				}
				pc.addCols(" ",1,dHeader.size());

				pc.setFont(11, 1);
				pc.addBorderCols("CUIDADOS EN CASA ",0,dHeader.size(),Color.lightGray);

				pc.setFont(fontSize, 1);
				pc.addBorderCols("     CODIGO",0,1);
				pc.addBorderCols("DESCRIPCION",1,2);
				pc.addBorderCols("OBSERVACION",1,2);

				pc.setFont(fontSize, 0);
				for (int i=0; i<al3.size(); i++){
						CommonDataObject cdo = (CommonDataObject) al3.get(i);

						pc.setFont(fontSize, 0);
						pc.addBorderCols("     "+cdo.getColValue("guia_id"),0,1,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdo.getColValue("descGuia"),0,2,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(cdo.getColValue("observacion"),0,2,0.5f,0.0f,0.0f,0.0f);
				}

				pc.addCols(" ",1,dHeader.size());

				CommonDataObject cdoN = SQLMgr.getData("select (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'R' and rownum = 1) codigo_r, (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'O' and rownum = 1) codigo_o, (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+") and tipo = 'I' and rownum = 1) codigo_i from dual");
				if (cdoN == null) cdoN = new CommonDataObject();

				Properties prop = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'R' and codigo = "+cdoN.getColValue("codigo_r","0"));
				if (prop == null)prop = new Properties();

				Properties prop2 = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'O' and codigo = "+cdoN.getColValue("codigo_o","0"));
				if (prop2 == null)prop2 = new Properties();

				Properties prop3 = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'I' and codigo = "+cdoN.getColValue("codigo_i","0"));
				if (prop3 == null)prop3 = new Properties();

				Vector tblR = new Vector();
				tblR.addElement("30");
				tblR.addElement("3");
				tblR.addElement("10");
				tblR.addElement("3");
				tblR.addElement("10");
				tblR.addElement("10");
				tblR.addElement("37");

				Vector tblO = new Vector();
				tblO.addElement("3");
				tblO.addElement("10");
				tblO.addElement("3");
				tblO.addElement("10");
				tblO.addElement("3");
				tblO.addElement("10");
				tblO.addElement("10");
				tblO.addElement("51");

				Vector tblC = new Vector();
				tblC.addElement("20");
				tblC.addElement("3");
				tblC.addElement("10");
				tblC.addElement("3");
				tblC.addElement("10");
				tblC.addElement("20");
				tblC.addElement("34");

				pc.setFont(11, 1);
				pc.addBorderCols("RELEVANTES ",0,dHeader.size(),Color.lightGray);

				pc.setNoColumnFixWidth(tblR);
				pc.createTable("tblR",false);
						pc.setFont(fontSize, 0);

						pc.addCols("LABORATORIOS RELEVANTES:",0,1);
						pc.addImageCols( (prop.getProperty("extra0")!=null&&prop.getProperty("extra0").equals("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("NO",0,1);
						pc.addImageCols( (prop.getProperty("extra0")!=null&&prop.getProperty("extra0").equals("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("SI",0,1);
						pc.addCols("Cuáles?",1,1);
						pc.addCols(prop.getProperty("xtra_observ0"),0,1);

						pc.addCols("PRUEBAS DE GABINETE:",0,1);
						pc.addImageCols( (prop.getProperty("extra32")!=null&&prop.getProperty("extra32").equals("32"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("NO",0,1);
						pc.addImageCols( (prop.getProperty("extra32")!=null&&prop.getProperty("extra32").equals("33"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("SI",0,1);
						pc.addCols("Cuáles?",1,1);
						pc.addCols(prop.getProperty("xtra_observ32"),0,1);

						pc.addCols("PROCEDIMIENTOS ESPECIALES INTRAHOSPITALARIOS:",0,1);
						pc.addImageCols( (prop.getProperty("extra1")!=null&&prop.getProperty("extra1").equals("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("NO",0,1);
						pc.addImageCols( (prop.getProperty("extra1")!=null&&prop.getProperty("extra1").equals("3"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("SI",0,1);
						pc.addCols("Cuáles?",1,1);
						pc.addCols(prop.getProperty("xtra_observ1"),0,1);

						pc.useTable("main");
						pc.addTableToCols("tblR",0,dHeader.size(),0);

						ArrayList alAl = SQLMgr.getDataList("select b.admision, a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo = b.tipo_alergia and b.pac_id = "+pacId);

						Vector tblAl = new Vector();
						tblAl.addElement(".17");
						tblAl.addElement(".03");
						tblAl.addElement(".06");
						tblAl.addElement(".10");
						tblAl.addElement(".29");
						tblAl.addElement(".12");
						tblAl.addElement(".10");

						pc.addCols(" ", 0, dHeader.size());
						pc.setFont(fontSize,1);
						pc.addCols("ANTECEDENTES ALERGICOS", 0, dHeader.size());
						pc.addCols("", 0, dHeader.size());

						pc.setNoColumnFixWidth(tblAl);
						pc.createTable("tblAl",false);

								pc.addBorderCols("Tipo de Alergia",1 ,1);
								pc.addBorderCols("SI",1 ,1);
								pc.addBorderCols("Edad",1 ,1);
								pc.addBorderCols("Meses",1 ,1);
								pc.addBorderCols("Observación",1 ,1);
								pc.addBorderCols("Fecha",1 ,1);
								pc.addBorderCols("Usuario",1 ,1);

								pc.setFont(fontSize,0);

						String gAdm = "",si = "",no = "";
						for(int i = 0; i<alAl.size(); i++){
								CommonDataObject cdo = (CommonDataObject) alAl.get(i);
								if(cdo.getColValue("aplicar"," ").trim().equalsIgnoreCase("S")){
										si = "x";
										no = "";
								}else{
									 no = "x";
									 si = "";
								}

								if (!gAdm.trim().equals(cdo.getColValue("admision"," ").trim())) {
										pc.setFont(fontSize, 1);
										pc.addBorderCols("ADM.# "+cdo.getColValue("admision"," "),0,tblAl.size());
								}
								pc.setFont(fontSize, 0);
								pc.addBorderCols(cdo.getColValue("descripcion"),0,1,15.2f);

								pc.addBorderCols(si,1,1);
								pc.addBorderCols(cdo.getColValue("edad"),1,1,15.2f);
								pc.addBorderCols(cdo.getColValue("meses"),1,1,15.2f);
								pc.addBorderCols(cdo.getColValue("observacion"),0,1);
								pc.addBorderCols(cdo.getColValue("fecha"),1,1);
								pc.addBorderCols(cdo.getColValue("usuario_creacion"),1,1);

								gAdm = cdo.getColValue("admision"," ");
						}

						pc.useTable("main");
						pc.addTableToCols("tblAl",0,dHeader.size(),0);

						pc.addCols(" ",1,dHeader.size());

						// condicion
						pc.setFont(11, 1);
						pc.addBorderCols("CONDICIÓN ",0,dHeader.size(),Color.lightGray);
						pc.addCols("",1,dHeader.size());

						pc.setNoColumnFixWidth(tblO);
						pc.createTable("tblO",false);
						pc.setFont(fontSize, 0);

						pc.addImageCols( (prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("4"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("Recuperado",0,1);

						pc.addImageCols( (prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("5"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("Convaleciente",0,1);

						pc.addImageCols( (prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("6"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("Defunción",0,3);

						pc.addCols("Uso equipo especial",0,2);
						pc.addImageCols( (prop2.getProperty("extra3")!=null&&prop2.getProperty("extra3").equals("7"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("NO",0,1);

						pc.addImageCols( (prop2.getProperty("extra3")!=null&&prop2.getProperty("extra3").equals("8"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("SI",0,1);
						pc.addCols("¿Cuáles?",1,1);

						pc.addCols(prop2.getProperty("xtra_observ3"),0,1);

						pc.addImageCols( (prop2.getProperty("extra12")!=null&&prop2.getProperty("extra12").equals("30"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("Febril",0,1);

						pc.addImageCols( (prop2.getProperty("extra12")!=null&&prop2.getProperty("extra12").equals("31"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
						pc.addCols("Afebril",0,tblO.size()-3);

						/*pc.setFont(fontSize,1);
						pc.addCols("EVOLUCION MEDICA",0,tblO.size());
						pc.setFont(fontSize,0);
						pc.addCols(prop2.getProperty("xtra_observ30"),0,tblO.size());*/


						pc.useTable("main");
						pc.addTableToCols("tblO",0,dHeader.size(),0);

						pc.addCols(" ",1,dHeader.size());

						// Citas
						pc.setFont(11, 1);
						pc.addBorderCols("CITAS ",0,dHeader.size(),Color.lightGray);

						pc.setNoColumnFixWidth(tblC);
								pc.createTable("tblC",false);
								pc.setFont(fontSize, 0);

								pc.addCols("Fecha:",0,1);
								pc.addCols(prop3.getProperty("extra4"),0,tblC.size() - 1);
								pc.addCols("Teléfono:",0,1);
								pc.addCols(prop3.getProperty("extra5"),0,tblC.size() - 1);

								pc.addCols("Especialista:",0,1);
								pc.addCols("["+prop3.getProperty("extra6")+"] "+prop3.getProperty("extra7"),0,tblC.size() - 1);

								pc.addCols("Se educa al paciente por parte del médico tratante:",0,1);
								pc.addImageCols( (prop3.getProperty("extra9")!=null&&prop3.getProperty("extra9").equals("9"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("NO",0,1);
								pc.addImageCols( (prop3.getProperty("extra9")!=null&&prop3.getProperty("extra9").equals("10"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("SI",0,1);

								pc.addCols("¿Quién realiza educación?",1,1);
								pc.addCols(prop3.getProperty("xtra_observ4"),0,1);

								pc.addCols("Se entrega Care Notes:",0,1);
								pc.addImageCols( (prop3.getProperty("extra10")!=null&&prop3.getProperty("extra10").equals("11"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("SI",0,1);
								pc.addImageCols( (prop3.getProperty("extra10")!=null&&prop3.getProperty("extra10").equals("12"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("NO",0,1);

								pc.addCols("razón ",1,1);
								pc.addCols(prop3.getProperty("xtra_observ5"),0,1);

								//nivel educativo
								pc.addCols("Material Educativo",0,1);
								pc.addImageCols( (prop3.getProperty("extra11")!=null&&prop3.getProperty("extra11").equals("13"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("Verbal",0,1);
								pc.addImageCols( (prop3.getProperty("extra11")!=null&&prop3.getProperty("extra11").equals("14"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("Escrito",0,tblC.size()-4);



								pc.addCols("¿Paciente Comprendió la Educación?",0,1);
								pc.addImageCols( (prop3.getProperty("extra28")!=null&&prop3.getProperty("extra28").equals("28"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("SI",0,1);
								pc.addImageCols( (prop3.getProperty("extra28")!=null&&prop3.getProperty("extra28").equals("29"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
								pc.addCols("NO",0,1);

								pc.addCols("razón ",1,1);
								pc.addCols(prop3.getProperty("xtra_observ28"),0,1);




						pc.useTable("main");
						pc.addTableToCols("tblC",0,dHeader.size(),0);

				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());

				pc.addCols("NOMBRE DEL MEDICO: ",0,1);
				pc.addBorderCols(" "+cdo1.getColValue("nombre_medico"),0,2,0.10f,0.0f,0.0f,0.0f);
				pc.addCols("ESPECIALIDAD: ",0,1);
				pc.addBorderCols(" "+cdo1.getColValue("especialidad"),0,1,0.10f,0.0f,0.0f,0.0f);

				pc.addCols("DIRECCION DEL CONSULTORIO: ",0,1);
				pc.addBorderCols(" "+cdo1.getColValue("direccionTrabajo"),0,4,0.10f,0.0f,0.0f,0.0f);
				pc.addCols("TELEFONO: ",0,1);
				pc.addBorderCols(" "+cdo1.getColValue("telefonoMedico"),0,1,0.10f,0.0f,0.0f,0.0f);
				pc.addCols(" ",0,3);
				pc.addCols("FIRMA DEL PACIENTE O RESPONSABLE: ________________________________________",0,3);
				pc.addCols("FECHA: _______________________",0,2);
				pc.addCols("FIRMA DE LA ENFERMERA ORIENTADORA: ______________________________________________",0,dHeader.size());


pc.addTable();
if(toBeMailed.trim().equalsIgnoreCase("Y")) {
		pc.close();
		out.print(directory+folderName+"/"+year+"/"+month+"/"+fileName);
		isUnifiedExp = false;
}else
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>