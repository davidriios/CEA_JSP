<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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

ArrayList al = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String estado = request.getParameter("estado");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String fp = request.getParameter("fp");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String no = request.getParameter("no");
String clase = request.getParameter("clase");
String group_type = request.getParameter("group_type");
String fg = request.getParameter("fg");
String regType = request.getParameter("regType");
String tipo = request.getParameter("tipo");
String pMes13 = request.getParameter("pMes13");
String pRegManual = request.getParameter("pRegManual");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (estado == null) estado = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (no == null) no = "";
if (clase == null) clase = "";
if (group_type == null) group_type = "";
if (regType == null) regType = "";
if (tipo == null) tipo = "";
if (pMes13 == null) pMes13 = "";
if (pRegManual == null) pRegManual = "";

if (appendFilter == null) appendFilter = "";
sbFilter = new StringBuffer(appendFilter);

if (!anio.trim().equals("")&&fechaIni.trim().equals("")) { sbFilter.append(" and a.ea_ano = "); sbFilter.append(anio); }
if (!mes.trim().equals("")&&fechaIni.trim().equals("")) { sbFilter.append(" and a.mes = to_number("); sbFilter.append(mes); sbFilter.append(")"); }
if(!fp.trim().equals("listComp")){if (estado.trim().equals("")) { sbFilter.append(" and a.status not in ('DE')"); }
else { sbFilter.append(" and a.status = '"); sbFilter.append(estado); sbFilter.append("'"); }}
if (!fechaIni.trim().equals("")&&anio.trim().equals("")){sbFilter.append(" and trunc(a.fecha_comp) >= to_date('");sbFilter.append(fechaIni); sbFilter.append("','dd/mm/yyyy')"); }
if (!fechaFin.trim().equals("")&&anio.trim().equals("")){sbFilter.append(" and trunc(a.fecha_comp) <= to_date('");sbFilter.append(fechaFin); sbFilter.append("','dd/mm/yyyy')"); }
if (!no.trim().equals("")) { if(!fg.equals("PLA"))sbFilter.append(" and a.consecutivo = ");else sbFilter.append(" and a.consecutivo_comp = ");  sbFilter.append(no); }
if (!clase.trim().equals("")) { sbFilter.append(" and a.clase_comprob in ("); sbFilter.append(clase); sbFilter.append(")"); }
if (!group_type.trim().equals("")) { sbFilter.append(" and c.group_type ="); sbFilter.append(group_type);}
if(!fg.equals("PLA"))if (!regType.trim().equals("")) { sbFilter.append(" and a.reg_type ='"); sbFilter.append(regType);sbFilter.append("' ");}
if(!fg.equals("PLA"))if (!tipo.trim().equals("")){sbFilter.append(" and a.tipo =");sbFilter.append(tipo);}
if(pMes13.trim().equals("S"))
{  
	if(pRegManual.trim().equals("S")) sbFilter.append(" and a.creado_por = 'RCM' ");
}

String tableName = "";
if (fg.equalsIgnoreCase("CD")) tableName = "tbl_con_encab_comprob a,tbl_con_detalle_comprob b,";
else if(fg.equals("PLA")){ tableName = "tbl_pla_planilla_encabezado e,tbl_pla_pre_encab_comprob a , tbl_pla_pre_detalle_comprob b,";
 sbFilter.append(" and e.asconsecutivo(+) = a.consecutivo_comp and e.anio(+) = a.ea_ano and e.cod_compania(+) = a.compania ");}

sbSql.append("SELECT ALL 1 as ord,c.group_type as groupType,a.clase_comprob,a.ea_ano, a.mes,");
if(fg.equals("PLA"))sbSql.append("a.consecutivo_comp as consecutivo,");
else sbSql.append("a.consecutivo,");

if(fg.equals("PLA"))sbSql.append("1 ");else sbSql.append(" a.tipo ");
 sbSql.append(" as tipo,b.renglon, b.cta1||'-'||b.cta2||'-'||b.cta3||'-'||b.cta4||'-'||b.cta5||'-'||b.cta6 as cuenta,a.compania,to_char(a.fecha_comp,'dd/mm/yyyy') as fecha, nvl(a.total_db,0) as total_db, nvl(a.total_cr,0) as total_cr, a.usuario_creacion as usuario, to_char(a.fecha_sistema,'dd/mm/yyyy hh:mi:ss am') as fecha_sistema,");
if(!fg.equals("PLA"))sbSql.append(" a.tipo||");
sbSql.append(" a.ea_ano||a.mes||a.consecutivo as llave, a.descripcion as descencab, b.ano_cta,  b.comentario, nvl(DECODE(b.tipo_mov,'DB',b.valor),0) as db, nvl(DECODE(b.tipo_mov,'CR',b.valor),0) as cr, c.descripcion as descComprob, d.descripcion as cuentaDesc, decode(a.estado,'A','ACTIVO','I','INACTIVO')||' - '||decode(a.status,'AP','APROBADO','DE','DESAPROBADO','PE','PENDIENTE') as status,(select descripcion from tbl_con_group_comprob where id = c.group_type)as group_type FROM ");
sbSql.append(tableName);
sbSql.append(" tbl_con_clases_comprob c, tbl_con_catalogo_gral d WHERE a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(sbFilter); 
if (!fp.equalsIgnoreCase("listComp"))sbSql.append(" and a.estado = 'A' and a.tipo <> 2 "); 
sbSql.append(" and ((b.compania = a.compania AND b.ano = a.ea_ano  ");
if(!fg.equals("PLA"))sbSql.append("  AND b.consecutivo = a.consecutivo ");
else sbSql.append(" and b.consecutivo = a.consecutivo_comp ");
if(!fg.equals("PLA"))sbSql.append(" and a.tipo=b.tipo  and a.reg_type=b.reg_type");
sbSql.append("  )) and a.clase_comprob = c.codigo_comprob and c.tipo=");

if(!fg.equals("PLA"))sbSql.append(" 'C'");
else sbSql.append(" 'P'");
if(!fg.equals("PLA"))sbSql.append(" AND b.cta1 = d.cta1 AND b.cta2 = d.cta2 AND b.cta3 = d.cta3 AND b.cta4 = d.cta4 AND b.cta5 = d.cta5 AND b.cta6 = d.cta6 AND b.COMPANIA = d.COMPANIA");
else sbSql.append(" AND b.cta1 = d.cta1(+) AND b.cta2 = d.cta2(+) AND b.cta3 = d.cta3(+) AND b.cta4 = d.cta4(+) AND b.cta5 = d.cta5(+) AND b.cta6 = d.cta6(+) AND b.COMPANIA = d.COMPANIA(+)");
sbSql.append(" ORDER BY 1,2,3,4 desc,5,6,7,8,9 ");
al = SQLMgr.getDataList(sbSql.toString());

if (mes.trim().equals("")) mes = fecha.substring(3,5);
if (anio.trim().equals("")) anio = fecha.substring(6,10);

sbSql = new StringBuffer();
sbSql.append("select ");
if(!mes.trim().equals("13")){
if (!fechaIni.trim().equals("")) {

	sbSql.append("'DEL '||replace(to_char(to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy'),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')||");

}

if (!fechaFin.trim().equals("")) {

	sbSql.append("' AL '||replace(to_char(to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy'),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')");

} else {
	
	sbSql.append("' AL '||replace(to_char(last_day(to_date('");
	sbSql.append(mes);
	sbSql.append("/");
	sbSql.append(anio);
	sbSql.append("','mm/yyyy')),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')");
	}
}	
	else sbSql.append(" 'MES CIERRE '");
sbSql.append(" as fecha from dual");
cdoSI = SQLMgr.getData(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "CONTABILIDAD";
	String subtitle = "";
	if(fp.trim().equals("listComp")){if(fg.trim().equals("PLA"))subtitle +="PRE - COMPROBANTE DE PLANILLA";else {if(regType.equalsIgnoreCase("H"))subtitle +="COMPROBANTE HISTORICO";else subtitle +="COMPROBANTE DIARIO";}}
	else subtitle = "COMPROBANTES MENSUALES";
	
	String xtraSubtitle = ((fp.trim().equals("listComp"))?"":cdoSI.getColValue("fecha"));
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".07");
			dHeader.addElement(".05");
			dHeader.addElement(".17");
			dHeader.addElement(".29");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".22");


PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);
	pc.setTableHeader(1);//create de table header (1 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "",groupBy2 = "",sgroupBy = "", descTipo="", descGrupo="";
	String sw = "";
	String usuario = "";
	String fechaCr = "";
	double saldo = 0.00;
	double totalDb = 0.00,montoDb=0.00,montoCr=0.00;
	double totalCr = 0.00;
	double totalDbDet  =0.00,totalCrDet  =0.00, gCr = 0.0, gDb = 0.0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setFont(fontSize, 0);
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("llave")))
		{
			 if(i>0)
			 {
					pc.setFont(fontSize, 0,Color.blue);
					pc.addCols("Confeccionado por:  "+usuario,1,3);
					pc.addCols(" "+fechaCr,1,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDb),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCr),2,1);
					pc.addCols(" ",1,1);
					totalDb = 0.00;
					totalCr = 0.00;
					pc.setFont(fontSize, 0);
					pc.addCols(" ",1,dHeader.size());
					
					
				}
			
			if (!sgroupBy.equals(cdo.getColValue("group_type"))) {
			if (i != 0) {
				pc.setFont(fontSize+1,0,Color.blue);
				pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,4);
				pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);
				pc.addCols("  ",1,1);

				pc.setFont(fontSize+1,1,Color.blue);
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" TOTAL GRUPO:  "+descGrupo,0,4);
				pc.addCols(CmnMgr.getFormattedDecimal(gDb),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gCr),2,1);
				pc.addCols("  ",1,1);
				pc.addCols(" ",1,dHeader.size());
			}

			pc.setFont(fontSize+1,1,Color.blue);
			pc.addCols("GRUPO:    "+cdo.getColValue("group_type"),0,dHeader.size());
			pc.setFont(fontSize+1,0,Color.blue);
			pc.addCols(" ",1,dHeader.size());
			pc.addCols(" COMPROBANTE:    "+cdo.getColValue("descComprob"),2,dHeader.size()-2);
			pc.addCols(" ",1,2);
			totalDbDet  =0.00;
			totalCrDet  =0.00;
			gDb = 0.0;
			gCr = 0.0;
			pc.addCols(" ",1,dHeader.size());
		} else if (!groupBy2.equals(cdo.getColValue("clase_comprob"))) {
			pc.setFont(fontSize+1,0,Color.blue);
			if (i != 0) {
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,4);
				pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);
				pc.addCols("  ",1,1);
				pc.addCols(" ",1,dHeader.size());
			}

			pc.addCols(" COMPROBANTE:    "+cdo.getColValue("descComprob"),2,dHeader.size()-2);
			pc.addCols(" ",1,2);
			pc.addCols(" ",1,dHeader.size());
			totalDbDet  =0.00;
			totalCrDet  =0.00;
		}
			pc.setFont(fontSize, 0);		
 					pc.addCols("Fecha Comprob:",1,2);
					pc.addCols(""+cdo.getColValue("fecha"),1,1);

					pc.addCols(" Año: "+cdo.getColValue("ea_ano")+ "          Mes: "+cdo.getColValue("mes")+ "           No. "+cdo.getColValue("consecutivo"),1,3);
					pc.addCols("Estado:  "+cdo.getColValue("status"),1,1);

					//pc.addCols(""+cdo.getColValue("descComprob"),0,4);
					pc.addCols("Comprobante:   "+cdo.getColValue("consecutivo")+" - "+cdo.getColValue("descencab"),0,dHeader.size());

					pc.addCols("Cuenta",1,3);
					pc.addCols("",2,1);
					pc.addCols("Débitos",2,1);
					pc.addCols("Créditos",2,1);
					pc.addCols("Explicación",0,1);
		}

		totalDb += Double.parseDouble(cdo.getColValue("db"));
		totalCr += Double.parseDouble(cdo.getColValue("cr"));
		montoDb += Double.parseDouble(cdo.getColValue("db"));
		montoCr += Double.parseDouble(cdo.getColValue("cr"));

			pc.addCols(" "+cdo.getColValue("ea_ano")+"-"+cdo.getColValue("consecutivo")+"-"+cdo.getColValue("renglon"),0,2);
			pc.addCols(" "+cdo.getColValue("cuenta"),0,1);
			pc.addCols(" "+cdo.getColValue("cuentaDesc"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("db")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("cr")),2,1);
			pc.addCols(" "+cdo.getColValue("comentario"),0,1);


			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("llave");
		usuario = cdo.getColValue("usuario");
		fechaCr = cdo.getColValue("fecha_sistema");
		totalDbDet += Double.parseDouble(cdo.getColValue("db"));
		totalCrDet += Double.parseDouble(cdo.getColValue("cr"));
		descTipo = cdo.getColValue("descComprob");
		groupBy2 =cdo.getColValue("clase_comprob");

		gDb += Double.parseDouble(cdo.getColValue("db"));
		gCr += Double.parseDouble(cdo.getColValue("cr"));
		descGrupo = cdo.getColValue("group_type");
		sgroupBy = cdo.getColValue("group_type");
	}
	//pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(fontSize, 0,Color.blue);
		pc.addCols("Confeccionado por:  "+usuario,1,3);
		pc.addCols(" "+fechaCr,1,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDb),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCr),2,1);
		pc.addCols("",1,1);

		pc.addCols(" ",1,dHeader.size());
		
		pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,4);
		pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);
		pc.addCols("  ",1,1);

		pc.setFont(fontSize+1,1,Color.blue);
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" TOTAL GRUPO:  "+descGrupo,0,4);
		pc.addCols(CmnMgr.getFormattedDecimal(gDb),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(gCr),2,1);
		pc.addCols("  ",1,1);
		pc.addCols(" ",1,dHeader.size());

		pc.setFont(fontSize+2,1,Color.blue);
		pc.addCols(" GRAN TOTAL     ",2,4);
		pc.addCols(CmnMgr.getFormattedDecimal(montoDb),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(montoCr),2,1);
		pc.addCols("  ",1,1);
		
		

		pc.addCols(" ",1,dHeader.size());
			pc.addCols(" ",1,dHeader.size());
		pc.addCols("  ",1,1);
		pc.addBorderCols(" Revisado por :     ",1,2, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addCols("  ",1,1);
		pc.addBorderCols(" Contabilizado por :    ",1,2, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addCols("  ",1,1);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>