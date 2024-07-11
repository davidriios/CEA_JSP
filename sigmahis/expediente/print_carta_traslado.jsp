<%@ page errorPage="../error.jsp"%>
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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdoPacData  = new CommonDataObject();
CommonDataObject cdo  = new CommonDataObject();
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String appendFilter = request.getParameter("appendFilter");
String fg = request.getParameter("fg");
String transfTo = request.getParameter("to")==null?"":request.getParameter("to");
String idTransf = request.getParameter("idTransf")==null?"0":request.getParameter("idTransf");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "N";
if (desc == null) desc = "";

	sql.append("select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_solicitud, d.descripcion||decode(es_otro,'Y',' : '||otras_condiciones) as cond , c.nombre transferido_a, c.telefonos, c.direccion, t.acompaniante_transf, p.descripcion as parentesco, t.coordinador, t.personal_translado, t.proveedor, to_char(t.fecha_seguimiento,'dd/mm/yyyy') fecha_seguimiento, to_char(t.hora_seguimiento,'hh12:mi:ss am') hora_seguimiento, t.condicion_seguimiento, (select descripcion from tbl_cds_centro_servicio where codigo = t.area_coordinador and rownum = 1) area_coordinador from tbl_sal_adm_salida_datos a , tbl_sal_cons_incap_transf t,tbl_sal_transferencia_params d, tbl_pla_parentesco p, tbl_sal_centros_tranf c where a.pac_id= t.pac_id and a.secuencia=t.admision and t.cond_transf = d.id and t.tipo = 'T' and parentesco_acompaniante = p.codigo(+) and c.id = t.transferido_a and a.pac_id= ");
	sql.append(pacId);
	sql.append(" and secuencia=");
	sql.append(noAdmision);
		sql.append("and c.compania = ");
		sql.append(compania);
	cdo = SQLMgr.getData(sql.toString());
	if(cdo==null){cdo = new CommonDataObject();

		cdo.addColValue("nombre_diagnostico","");
		cdo.addColValue("cod_diag_sal","");
		cdo.addColValue("hora_salida","");
		cdo.addColValue("finaliza_fecha","");
		cdo.addColValue("transf","");
		cdo.addColValue("observacion","");
		cdo.addColValue("hora_transf","");
		cdo.addColValue("cond","");
		cdo.addColValue("parentesco","");
		cdo.addColValue("fecha_solicitud","");
		cdo.addColValue("transferido_a","");
		cdo.addColValue("acompaniante_transf","");
		cdo.addColValue("telefonos","");
		cdo.addColValue("direccion","");
	}

	sql = new StringBuffer();

	//SIGNOS VITALES for printing
	sql.append("select nvl(a.resultado,' ') resultado, b.descripcion as signoDesc from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital=b.codigo and a.signo_vital=c.cod_signo(+) and c.valor_default(+) = 'S' and a.fecha_creacion = (select max(fecha_creacion) from tbl_sal_detalle_signo z where pac_id = "+pacId+" and secuencia = "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A'))order by b.orden, a.fecha_signo, a.hora, a.signo_vital");

	ArrayList alS = SQLMgr.getDataList(sql);

	ArrayList alD = SQLMgr.getDataList("select d.codigo,d.nombre from tbl_adm_diagnostico_x_admision da, tbl_cds_diagnostico d where da.diagnostico = d.codigo and da.pac_id = "+pacId+" and da.admision = "+noAdmision+"");

	ArrayList alRM = SQLMgr.getDataList("select p.tipo, decode(p.tipo,2,'REQUERIMIENTO DEL TRASLADO',3,'MOTIVO DEL TRASLADO', 4, 'DOCUMENTOS') as tipoDesc, p.descripcion, d.observacion from tbl_sal_transf_det d, tbl_sal_transferencia_params p where  d.tipo = 'T' and p.tipo in(2,3,4) and p.tipo = d.tipo_transf_params and d.id_trans_params = p.id and d.id_transf = "+idTransf+" order by 1");


if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String title = "FORMULARIO DE TRASLADO DE PACIENTE";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

		CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdoPacData.addColValue("is_landscape",""+isLandscape);
		}

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row


		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

	//table body
		pc.setFont(9, 0);
		pc.setVAlignment(0);

		pc.addCols("",0,dHeader.size());
		pc.addCols("FECHA DE SOLICITUD: "+cdo.getColValue("fecha_solicitud"," "),0,dHeader.size());

		pc.addBorderCols("Acompañante para el traslado: "+cdo.getColValue("acompaniante_transf"," "),0,7,0.1f,0.0f,0.1f,0.1f);
		pc.addBorderCols("Parentezco: "+cdo.getColValue("parentesco"," "),0,3,0.1f,0.0f,0.1f,0.1f);

		pc.addBorderCols("Condición del paciente durante el traslado: ",0,3,0.1f,0.0f,0.1f,0.1f);
		if (cdo.getColValue("cond")==null && cdo.getColValue("cond").equals(""))
			pc.addBorderCols("Especifique: ",0,7,0.1f,0.0f,0.1f,0.1f);
		else pc.addBorderCols(cdo.getColValue("cond"),0,7,0.1f,0.0f,0.1f,0.1f);

				pc.addCols("",0,dHeader.size());
		pc.addCols("Coordinador del Traslado: "+cdo.getColValue("coordinador"," "),0,dHeader.size());
		pc.addCols("Área del Coordinador: "+cdo.getColValue("area_coordinador"," "),0,dHeader.size());
		pc.addCols("Personal del Traslado: "+cdo.getColValue("personal_translado"," "),0,dHeader.size());
		pc.addCols("Proveedor: "+cdo.getColValue("proveedor"," "),0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());

				pc.setFont(9,1);
		pc.addCols("Seguimiento al centro de traslado",0,dHeader.size());
				pc.setFont(9,0);
				pc.addCols("Fecha: "+cdo.getColValue("fecha_seguimiento"," ")+"      Hora: "+cdo.getColValue("hora_seguimiento"," "),0,dHeader.size());
				pc.addCols("Condición: "+cdo.getColValue("condicion_seguimiento"," "),0,dHeader.size());

				pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("INSTITUCION QUE RECIBE EL PACIENTE: ",0,dHeader.size());
		pc.setFont(9, 0);

				pc.addBorderCols("Nombre: "+cdo.getColValue("transferido_a"),0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("Telefonos: "+cdo.getColValue("telefonos"),0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("Dirección: "+cdo.getColValue("direccion"),0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);

		pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("SIGNOS VITALES AL MOMENTO DEL TRASLADO (JUSTO ANTES DE ABANDONAR LA SALA): ",0,dHeader.size());
		pc.setFont(9, 0);

		pc.addBorderCols("SIGNO",0,4);
		pc.addBorderCols("VALOR",1,1);
		pc.addCols("",1,5);

			CommonDataObject cdoX = new CommonDataObject();
		for (int sv = 0; sv<alS.size(); sv++){
			 cdoX = (CommonDataObject)alS.get(sv);
				pc.addBorderCols(cdoX.getColValue("signodesc"),0,4);
			pc.addBorderCols(cdoX.getColValue("resultado"),1,1);
			pc.addCols("",1,5);
		}

		pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("DIAGNOSTICOS: ",0,dHeader.size());
		pc.setFont(9, 0);

		cdoX = new CommonDataObject();
		pc.addBorderCols("CÓDIGO",1,2);
		pc.addBorderCols("DESCRIPCIÓN",0,8);
		for (int d = 0; d<alD.size(); d++){
			cdoX = (CommonDataObject)alD.get(d);
			pc.addCols(cdoX.getColValue("codigo"),1,2);
			pc.addCols(cdoX.getColValue("nombre"),0,8);
		}

		String gTipo = "";
		for (int r = 0; r<alRM.size(); r++){
			cdoX = (CommonDataObject)alRM.get(r);
			if (!gTipo.equals(cdoX.getColValue("tipo"))){
				 pc.setFont(9,1);
			 pc.addCols(" ",0,dHeader.size());
				 pc.addCols(cdoX.getColValue("tipoDesc"),0,dHeader.size());
			 pc.setFont(9, 0);
			 pc.addBorderCols(cdoX.getColValue("tipo").equals("2")?"REQUERIMIENTO":"MOTIVO",0,5);
			 pc.addBorderCols("OBSERVACION",0,5);
			 pc.setFont(9, 0);
			}
			pc.addCols(cdoX.getColValue("descripcion"),0,5);
			pc.addCols(cdoX.getColValue("observacion"),0,5);
			gTipo = cdoX.getColValue("tipo");
		}

		pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("DOCUMENTOS QUE SE ENVIAN CON EL PACIENTE (MANUAL)",0,dHeader.size());
		pc.setFont(9, 0);
		pc.addBorderCols(" ",0,dHeader.size(), 40.0f);

		pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("Nombre del personal que realiza el traslado",0,4);
		pc.addBorderCols(" ",0,6,0.1f,0.0f, 0.0f, 0.0f);

				pc.setFont(9,1);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("Nombre del proveedor del servicio",0,4);
		pc.addBorderCols(" ",0,6,0.1f,0.0f, 0.0f, 0.0f);

		pc.addCols(" ",0,dHeader.size());
		pc.addCols("Nombre del personal encargado que recibe al paciente",0,5);
		pc.addBorderCols(" ",0,5,0.1f,0.0f, 0.0f, 0.0f);




	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>