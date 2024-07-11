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
Reporte sal10030   fg=NE
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
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo2, cdoPacData = new CommonDataObject();

String sql = "", sqlTitle;
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String cds = request.getParameter("cds");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (desc == null) desc = "";
if (fg == null) fg = "";
if (fp == null) fp = "TD";
if (cds == null) cds = "0";


sql = "select pa.dolencia_principal, pa.observacion historia from tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca, tbl_sal_padecimiento_admision pa where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and aa.pac_id =pa.pac_id(+) and aa.secuencia = pa.secuencia(+) ";
cdo1 = SQLMgr.getData(sql);

//sql="SELECT distinct m.primer_nombre||decode(m.segundo_nombre,'','',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,'','',' '||m.apellido_de_casada)) as nombre_medico, to_char(a.FECHA,'dd/mm/yyyy') as FECHA, to_char(a.HORA,'hh12:mi') AS HORA,to_char(a.HORA,'am') AS amHora, a.ESTADO, a.TIPO_AUTORIDAD, a.NOM_AUTORIDAD, a.RANGO_AUTORIDAD, a.CIP_PLACA, a.FORMULARIO_VINTRA, a.TIPO_EVIDENCIA, a.EVIDENCIA_ENTREGA, to_char(a.FECHA_ENTREGA,'dd/mm/yyyy') as FECHA_ENTREGA, to_char(a.HORA_ENTREGA,'hh12:mi') AS HORA_ENTREGA, to_char(a.HORA_ENTREGA,'am') AS amHoraEntrega, a.CIP_ENTREGA, a.NOMBRE_ENTREGA, a.NOMBRE_TESTIGO, a.CIP_TESTIGO, a.COD_MEDICO, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFICACION, a.COD_TIPO_CASO, a.COD_TRANSPORTE,nvl(sg.signos,' ')signos, (select join(cursor(select  a.descripcion||': '||decode(b.normal,'A','Anormal','N','Normal','') ||'  '||busca_caract("+pacId+","+noAdmision+", 10,a.codigo)||'  ' descripcion  from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.codigo=b.cod_area and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio=10) ),';') signos from dual) areas FROM (select join(cursor(select b.descripcion||': '||a.resultado||' ' signo from tbl_sal_detalle_signo a,tbl_sal_signo_vital b where a.pac_id = "+pacId+" and    a.secuencia = "+noAdmision+" and    a.tipo_persona = 'T' and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo ),'; ') signos from dual) sg , TBL_SAL_PRUEBA_FISICA_POLIC a, tbl_adm_medico m where m.codigo=a.cod_medico and a.pac_id= "+pacId+" and a.secuencia="+noAdmision;


sql = " SELECT distinct m.primer_nombre||decode(m.segundo_nombre,'','',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,'','',' '||m.apellido_de_casada)) as nombre_medico, to_char(a.FECHA,'dd/mm/yyyy') as FECHA, to_char(a.HORA,'hh12:mi') AS HORA,to_char(a.HORA,'am') AS amHora, a.ESTADO, a.TIPO_AUTORIDAD, a.NOM_AUTORIDAD, a.RANGO_AUTORIDAD, a.CIP_PLACA, a.FORMULARIO_VINTRA, a.TIPO_EVIDENCIA, a.EVIDENCIA_ENTREGA, to_char(a.FECHA_ENTREGA,'dd/mm/yyyy') as FECHA_ENTREGA, to_char(a.HORA_ENTREGA,'hh12:mi') AS HORA_ENTREGA, to_char(a.HORA_ENTREGA,'am') AS amHoraEntrega, a.CIP_ENTREGA, a.NOMBRE_ENTREGA, a.NOMBRE_TESTIGO, a.CIP_TESTIGO, a.COD_MEDICO, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFICACION, a.COD_TIPO_CASO, a.COD_TRANSPORTE,  (select join(cursor(select  a.descripcion||': '||decode(b.normal,'A','Anormal','N','Normal','') ||'  '||busca_caract("+pacId+","+noAdmision+", "+cds+",a.codigo)||'  ' descripcion  from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.codigo=b.cod_area and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") ),';') from dual) areas   ,(   select listagg(signo,';') within group(order by signo) signo from (select all b.descripcion||': '||a.resultado||' ' signo from tbl_sal_detalle_signo a, tbl_sal_signo_vital b where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+"  and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo and a.hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and status = 'A'))  ) signos  FROM TBL_SAL_PRUEBA_FISICA_POLIC a, tbl_adm_medico m where m.codigo=a.cod_medico and a.pac_id= "+pacId+" and a.secuencia="+noAdmision;

cdo = SQLMgr.getData(sql);

sql = "select a.codigo, a.descripcion , nvl(b.cod_tipo_caso,0) cod_caso from tbl_sal_tipo_caso a,tbl_sal_prueba_fisica_polic b where b.pac_id(+) = "+pacId+" and b.secuencia(+) = "+noAdmision+" and a.codigo = b.cod_tipo_caso(+)  order  by 1";
al = SQLMgr.getDataList(sql);
sql = "select a.codigo, a.descripcion , nvl(b.cod_transporte,0) cod_transporte FROM tbl_sal_forma_transporte a,	tbl_sal_prueba_fisica_polic b where b.pac_id(+) = "+pacId+" and b.secuencia(+) = "+noAdmision+" and a.codigo = b.cod_transporte(+)  order  by 1";

al2 = SQLMgr.getDataList(sql);

if(cdo == null )
{cdo = new CommonDataObject();

cdo.addColValue("fecha","");
cdo.addColValue("hora","");

}
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "INFORME DE CASO POLICIVO ATENDIDO EN EL CUARTO DE URGENCIAS";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

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

			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".08");
			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".10");
			dHeader.addElement(".20");
			dHeader.addElement(".20");


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	Vector listCol = new Vector();
		listCol.addElement(".03");
		listCol.addElement(".47");
		listCol.addElement(".03");
		listCol.addElement(".47");

		Vector listCol2 = new Vector();
		listCol2.addElement(".03");
		listCol2.addElement(".03");
		listCol2.addElement(".03");
		listCol2.addElement(".91");

		Vector detCol = new Vector();
		detCol.addElement(".03");
		detCol.addElement(".11");
		detCol.addElement(".03");
		detCol.addElement(".11");
		detCol.addElement(".03");
		detCol.addElement(".11");
		detCol.addElement(".03");
		detCol.addElement(".55");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
			pc.setFont(5, 0);
			pc.resetVAlignment();
		pc.addInnerTableToCols(dHeader.size());

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	//pc.setVAlignment(0);
	int size = al.size();
	if(al.size() <= al2.size())
	size = al2.size();

	pc.setFont(7, 0);
	pc.addBorderCols("           TIPO DE CASO",0,7,Color.lightGray);
	pc.addBorderCols("           FORMA DE LLEGAR AL CU",0,3,Color.lightGray);

	pc.setNoInnerColumnFixWidth(listCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();

	for (int i=0; i<size; i++)
	{
		if(i < al.size())
		{
			CommonDataObject cdo3 = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			if(!cdo3.getColValue("cod_caso").trim().equals("0"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols(cdo3.getColValue("descripcion"),0,1);
		}else
		{
			pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols(" ",0,1);
		}

		if(i < al2.size())
		{
			CommonDataObject cdo3 = (CommonDataObject) al2.get(i);

			pc.setFont(7, 0);
			if(!cdo3.getColValue("cod_transporte").trim().equals("0"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols(cdo3.getColValue("descripcion"),0,1);
		}else
		{
			pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols(" ",0,1);
		}

	}

		pc.addInnerTableToCols(dHeader.size());

		pc.addCols(" ",1,dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("HISTORIA CLINICA",1,dHeader.size(),Color.lightGray);
		pc.setFont(7, 0);
		pc.addBorderCols("DOLENCIA PRINCIPAL:   "+cdo1.getColValue("dolencia_principal"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("OBSERVACION:  "+cdo1.getColValue("historia"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" ",1,dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("EXAMEN FISICO",1,dHeader.size(),Color.lightGray);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("FECHA: ",0,1);
		pc.addBorderCols(" "+cdo.getColValue("fecha"),0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("HORA: ",0,1);
		pc.addBorderCols(" "+cdo.getColValue("hora"),0,2,0.5f,0.0f,0.0f,0.0f);//agregar am,  pm
		pc.addCols(" ",0,1);
		pc.setVAlignment(1);
			pc.setNoInnerColumnFixWidth(listCol2);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
			if(cdo.getColValue("amHora") != null && cdo.getColValue("amHora").trim().toUpperCase().equals("AM"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("AM ",0,1);
			if(cdo.getColValue("amHora") != null && cdo.getColValue("amHora").trim().toUpperCase().equals("PM"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols("PM ",0,1);

			pc.resetVAlignment();
		pc.addInnerTableToCols(3);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("ESTADO DEL PACIENTE",0,3);

		pc.setVAlignment(1);
			pc.setNoInnerColumnFixWidth(detCol);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();

			if(cdo.getColValue("estado") != null && cdo.getColValue("estado").trim().equals("B"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("BUENO ",0,1);
			if(cdo.getColValue("estado") != null && cdo.getColValue("estado").trim().equals("R"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("REGULAR ",0,1);

			if(cdo.getColValue("estado") != null && cdo.getColValue("estado").trim().equals("G"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("GRAVE ",0,1);

			if(cdo.getColValue("estado") != null && cdo.getColValue("estado").trim().equals("M"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("MUERTO ",0,1);

			pc.resetVAlignment();
		pc.addInnerTableToCols(7);

		pc.addCols("SIGNOS VITALES",0,3);
		pc.addBorderCols(" "+((cdo.getColValue("signos") != null)?cdo.getColValue("signos"):""),0,7,0.5f,0.0f,0.0f,0.0f);

		pc.addCols("EXAMEN FISICO",0,3);
		pc.addBorderCols(" "+((cdo.getColValue("areas") != null)?cdo.getColValue("areas"):""),0,7,0.5f,0.0f,0.0f,0.0f);

		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("Se Informó a: ",0,2);
		pc.addBorderCols(" "+cdo.getColValue("tipo_autoridad"),0,8,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("Nombre de la Autoridad informada: ",0,3);
		pc.addBorderCols(" "+((cdo.getColValue("nom_autoridad")!= null)?cdo.getColValue("nom_autoridad"):""),0,3,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Rango: ",2,1);
		pc.addBorderCols(" "+((cdo.getColValue("rango_autoridad") != null)?cdo.getColValue("rango_autoridad"):""),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("CIP/Placa: ",2,1);
		pc.addBorderCols(" "+((cdo.getColValue("cip_placa")!= null)?cdo.getColValue("cip_placa"):""),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("Se llenó el formulario de Violencia Intrafamiliar/Maltrato al Menor:",0,7);

		pc.setVAlignment(1);
			pc.setNoInnerColumnFixWidth(listCol2);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();

			if(cdo.getColValue("formulario_vintra") != null && cdo.getColValue("formulario_vintra").trim().equals("S"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",1,1);
			pc.addInnerTableCols("SI ",0,1);

			if(cdo.getColValue("formulario_vintra") != null && cdo.getColValue("formulario_vintra").trim().equals("N"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",1,1);
			pc.addInnerTableCols("NO ",0,1);

			pc.resetVAlignment();
		pc.addInnerTableToCols(3);

		pc.addCols("Tipo de evidencia legal (Bala, arma, ropas, etc.):",0,4);
		pc.addBorderCols(" "+((cdo.getColValue("tipo_evidencia") != null )?cdo.getColValue("tipo_evidencia"):""),0,6,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("Se entregó la evidencia legal a:",0,4);
		pc.addBorderCols(" "+((cdo.getColValue("evidencia_entrega") != null)?cdo.getColValue("evidencia_entrega"):""),0,6,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(3, 0);
		pc.addCols(" ",1,dHeader.size() );
		pc.setFont(7, 0);
		pc.addCols("FECHA: ",0,1);
		pc.addBorderCols(" "+((cdo.getColValue("fecha_entrega") != null)?cdo.getColValue("fecha_entrega"):""),0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("HORA: ",0,1);
		pc.addBorderCols(" "+((cdo.getColValue("hora_entrega") != null)?cdo.getColValue("hora_entrega"):""),0,1,0.5f,0.0f,0.0f,0.0f);//agregar am,  pm
		pc.addCols(" ",0,1);
		pc.setVAlignment(1);
			pc.setNoInnerColumnFixWidth(listCol2);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();

			if(cdo.getColValue("amHoraEntrega") != null && cdo.getColValue("amHoraEntrega").trim().toUpperCase().equals("AM"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("AM ",0,1);
			if(cdo.getColValue("amHoraEntrega") != null && cdo.getColValue("amHoraEntrega").trim().toUpperCase().equals("PM"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols("PM ",0,1);

			pc.resetVAlignment();
		pc.addInnerTableToCols(1);

		pc.addCols("CIP: ",2,1);
		pc.addBorderCols(" "+((cdo.getColValue("cip_entrega") != null)?cdo.getColValue("cip_entrega"):""),0,4,0.5f,0.0f,0.0f,0.0f);

		pc.addCols(" ",1,dHeader.size());
		pc.addCols("Nombre / Firma: ",0,2);
		pc.addBorderCols(" "+((cdo.getColValue("nombre_entrega") != null)?cdo.getColValue("nombre_entrega"):""),0,8,0.5f,0.0f,0.0f,0.0f);

		pc.addCols(" ",1,dHeader.size());
		pc.addCols("Testigos: ",0,2);
		pc.addBorderCols(" "+((cdo.getColValue("nombre_testigo") != null)?cdo.getColValue("nombre_testigo"):""),0,5,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("CIP: ",2,1);
		pc.addBorderCols(" "+((cdo.getColValue("cip_testigo") != null)?cdo.getColValue("cip_testigo"):""),0,2,0.5f,0.0f,0.0f,0.0f);

		pc.addCols(" ",1,dHeader.size());
		pc.addCols("Nombre y Sello del Médico del CU: ",0,3);
		pc.addBorderCols(" "+((cdo.getColValue("nombre_medico") != null)?cdo.getColValue("nombre_medico"):""),0,7,0.5f,0.0f,0.0f,0.0f);

		pc.addCols(" ",1,dHeader.size());
		pc.addCols("Firma: ",0,1);
		pc.addBorderCols(" ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Registro: ",0,1);
		pc.addBorderCols(" "+((cdo.getColValue("cod_medico")!=null)?cdo.getColValue("cod_medico"):""),0,4,0.5f,0.0f,0.0f,0.0f);

		pc.addCols(" ",1,dHeader.size());


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
%>