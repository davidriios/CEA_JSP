<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr" />
<%@ page import="java.util.Hashtable" %>
<%@ include file="../common/pdf_header.jsp"%>

<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SPMgr.setConnection(ConMgr);

ArrayList al, alDet = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
//Hashtable det = new Hashtable();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String exp = request.getParameter("exp");
if (exp == null) exp = "";
String opt = request.getParameter("opt");
if (opt == null) opt = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if(desc == null) desc = "";

sql = "select a.tipo_persona as tipoPersona, nvl(a.observacion,' ') as observacion, nvl(a.accion,' ') as accion, decode(a.categoria,'1','I','2','II','3','III',a.categoria) as categoria, decode(a.evacuacion,'S','[ X ]','[__]') as evacuacion, decode(a.miccion,'S','[ X ]','[__]') as miccion, decode(a.vomito,'S','[ X ]','[__]') as vomito, nvl(a.miccion_obs,' ') as miccionObs, nvl(a.vomito_obs,' ') as vomitoObs, nvl(a.evacuacion_obs,' ') as evacuacionObs , to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif,decode(a.dolor,'S','SI','NO') as dolor,a.escala, decode(a.preocupacion,'S', '[ X ]','[__]') preocupacion, nvl(preocupacion_obs,' ') preocupacionObs, nivel_conciencia nivelConciencia, dificultad_resp dificultadResp, loquios, proteinuria, liq_amnio liqAmnio, nvl(padecimiento_actual,' ') as padecimientoActual, decode(a.status,'I','INVALIDO','VALIDO') as status from tbl_sal_signo_paciente a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision;
if (!opt.equalsIgnoreCase("all")) sql += " and a.status = 'A'";
if (exp.trim().equals("")) {
		sql += " and a.tipo_persona <> 'T' ";
}
sql += " order by a.fecha_registro desc, a.hora_registro desc";

al = sbb.getBeanList(ConMgr.getConnection(), sql, SignoPaciente.class);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 82 * 8.5f;//612
	float height = 62 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 5;
	float cHeight = 90.0f;

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

		CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdoPacData.addColValue("is_landscape",""+isLandscape);}


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

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);


		if(al.size() < 1){
			pc.setFont(8,1);
			pc.addCols("No encontramos registros!", 1, dHeader.size());
		}else{

		for(int i = 0; i<al.size(); i++){

			SignoPaciente sp = (SignoPaciente) al.get(i);

			sql = "select a.signo_vital as signoVital, a.tipo_persona as tipoPersona, nvl(a.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.signo_vital=b.codigo and a.signo_vital=c.cod_signo(+) and c.valor_default(+)='S' and a.tipo_persona = '"+sp.getTipoPersona()+"' and to_date(to_char(a.fecha_signo,'dd/mm/yyyy'),'dd/mm/yyyy')  =  to_date('"+sp.getFecha()+"','dd/mm/yyyy') and to_date(to_char(a.hora,'dd/mm/yyyy hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') =  to_date('"+sp.getFecha()+" "+sp.getHora()+"','dd/mm/yyyy hh12:mi:ss am') order by b.orden, a.fecha_signo, a.hora, a.signo_vital desc";//depends on header's status
	//System.out.println("sql = "+sql);
	alDet = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleSignoPaciente.class);

	for (int j=0; j<alDet.size(); j++)
		{
			DetalleSignoPaciente spd = (DetalleSignoPaciente) alDet.get(j);
			if (sp.getTipoPersona().equals(spd.getTipoPersona())) sp.addDetalleSignoPaciente(spd);
		} //end for j

		al.set(i,sp);
		}//end for i

	String tipoPersona = "";

	for (int i = 0; i<al.size(); i++){

		SignoPaciente sp = (SignoPaciente) al.get(i);
	if (sp.getTipoPersona().equalsIgnoreCase("T")) tipoPersona = "TRIAGE";
	else if (sp.getTipoPersona().equalsIgnoreCase("M")) tipoPersona = "MEDICO";
	else if (sp.getTipoPersona().equalsIgnoreCase("E")) tipoPersona = "ENFERMERA";
	else if (sp.getTipoPersona().equalsIgnoreCase("A")) tipoPersona = "AUXILIAR";
	else tipoPersona = 	sp.getTipoPersona();

	pc.setFont(9,1);
	pc.addBorderCols("No.: "+(1+i),0,dHeader.size() - 1,2f,0f,0f,0f,15.2f);
	pc.addBorderCols((opt.equalsIgnoreCase("all"))?sp.getStatus():"",2,1,2f,0f,0f,0f,15.2f);

	pc.setFont();

		pc.addCols("Fecha/Hora Toma: ", 0,2);
	pc.addCols(sp.getFechaRegistro()+ " "+sp.getHoraRegistro(), 0, 2);
	pc.addCols("", 0, 2);
	pc.addCols("Registrado Por: ", 2, 2);
	pc.addCols(tipoPersona +" - "+ sp.getUsuarioCreacion(),0,2);

	pc.addCols("Evacuación: ",2,1);
	pc.addCols(sp.getEvacuacion(),0,1);
	pc.addCols("Observación: ",2,1);
	pc.addCols(sp.getEvacuacionObs(),0,7);

	pc.addCols("Micción: ",2,1);
	pc.addCols(sp.getMiccion(),0,1);
	pc.addCols("Observación:",2,1);
	pc.addCols(sp.getMiccionObs(),0,7);

		if(exp.trim().equals("3")){
				pc.addCols("Existe preocupación: ",2,1);
				pc.addCols(sp.getPreocupacion(),0,1);
				pc.addCols("Observación:",2,1);
				pc.addCols(sp.getPreocupacionObs(),0,7);
		}

	pc.addCols("Vómito: ",2,1);
	pc.addCols(sp.getVomito(),0,1);
	pc.addCols("Observación:",2,1);
	pc.addCols(sp.getVomitoObs(),0,7);

	pc.addCols("Dolor: ",2,1);
	pc.addCols(sp.getDolor(),0,1);
	pc.addCols(" Valor:",2,1);
	pc.addCols(sp.getEscala(),0,7);

	pc.addCols("Padecimiento Actual: ",2,1);
	pc.addCols(sp.getPadecimientoActual(),0,9);

		if(exp.equals("3")){
				if(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("0") ) pc.addCols("Nivel de conciencia:  [ X ] Normal       [___] Disminuido",0,10);
				else if(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("1") ) pc.addCols("Nivel de conciencia:  [___] Normal       [ X ] Disminuido",0,10);
				else  pc.addCols("Nivel de conciencia:  [___] Normal       [___] Disminuido",0,10);

				if(sp.getDificultadResp() != null && sp.getDificultadResp().equals("1") ) pc.addCols("Dificultad respiratoria:  [ X ] Severa/Moderada       [___] Leve/Ninguna",0,10);
				else if(sp.getDificultadResp() != null && sp.getDificultadResp().equals("0") ) pc.addCols("Dificultad respiratoria:  [___] Severa/Moderada       [ X ] Leve/Ninguna",0,10);
				else  pc.addCols("Dificultad respiratoria:  [___] Severa/Moderada       [___] Leve/Ninguna",0,10);

				if(sp.getLoquios() != null && sp.getLoquios().equals("0") ) pc.addCols("Loquios:  [ X ] Normal       [___] Aumentado / Falta",0,10);
				else if(sp.getLoquios() != null && sp.getLoquios().equals("3") ) pc.addCols("Loquios:  [___] Normal       [ X ] Aumentado / Falta",0,10);
				else  pc.addCols("Loquios:  [___] Normal       [___] Aumentado / Falta",0,10);

				if (sp.getProteinuria() == null) sp.setProteinuria("");

				pc.addCols("Proteinuria: "+sp.getProteinuria(),0,10);

				if(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("0") ) pc.addCols("Líquido amniótico:  [ X ] Claro / Rosa       [___] Verde",0,10);
				else if(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("3") ) pc.addCols("Líquido amniótico:  [___] Claro / Rosa       [ X ] Verde",0,10);
				else  pc.addCols("Líquido amniótico:  [___] Claro / Rosa       [___] Verde",0,10);


		}

		pc.setFont(7,1,Color.white);
	pc.addBorderCols("Signo Vital",1,3, Color.gray);
	pc.addBorderCols("Valor",1,1, Color.gray);
	pc.addBorderCols("",1,1, Color.gray);

	pc.addBorderCols((alDet.size()>1)?"Signo Vital":"  ",1,3, Color.gray);
	pc.addBorderCols((alDet.size()>1)?"Valor":"  ",1,1, Color.gray);
	pc.addBorderCols("",1,1, Color.gray);
	pc.setFont(7,0);


	for (int j=0; j<sp.getDetalleSignoPaciente().size(); j++)
	{
		DetalleSignoPaciente spd = sp.getDetalleSignoPaciente(j);

		pc.addCols(spd.getSignoDesc(),0,3);
		pc.addCols(spd.getResultado(),1,1);
		pc.addCols(spd.getSignoUnit(),0,1);
	} //end for
	if (sp.getDetalleSignoPaciente().size()%2 != 0) {
		pc.addCols("",0,3);
		pc.addCols("",1,1);
		pc.addCols("",0,1);
	}

	pc.addCols(" ",1,dHeader.size(),7.2f);

	 } //end for 2nd i

}//end else

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>