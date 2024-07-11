<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ include file="../common/pdf_header.jsp"%>


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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
CommonDataObject cdoT = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sala = request.getParameter("sala");
String compania = request.getParameter("compania");
String aseguradora = request.getParameter("aseguradora");
String fecha = request.getParameter("fecha");
String categoria = request.getParameter("categoria");
String tipo_cta = request.getParameter("tipo_cta");
String pacId = request.getParameter("pacId");


String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
if (appendFilter == null) appendFilter = "";

if (compania == null ) compania = (String) session.getAttribute("_companyId");
if (aseguradora == null ) aseguradora = "";
if (categoria == null ) categoria = "";
if (tipo_cta == null ) tipo_cta = "";
if(sala == null) sala ="";

sbSql.append("select decode(zz.empresa,0,1,0) as ord, nvl((select nombre from tbl_adm_empresa where codigo = zz.empresa),'SIN BENEFICIO') as nombre_empresa, sum((case when zz.diff <= 30 then nvl(zz.total,0) else 0 end)) as corriente, sum((case when zz.diff > 30 and zz.diff <= 60 then nvl(zz.total,0) else 0 end)) as saldo_30, sum((case when zz.diff > 60 and zz.diff <= 90 then nvl(zz.total,0) else 0 end)) as saldo_60, sum((case when zz.diff > 90 and zz.diff <= 120 then nvl(zz.total,0) else 0 end)) as saldo_90, sum((case when zz.diff > 120 and zz.diff <= 150 then nvl(zz.total,0) else 0 end)) as saldo_120, sum((case when zz.diff > 150 then nvl(zz.total,0) else 0 end)) as saldo_150, sum(nvl(zz.total,0)) as total, zz.poliza as poliza, (select '['||pac_id||' - '||zz.admision||'] - '||nombre_paciente from vw_adm_paciente where pac_id = zz.pac_id) as nombre, (select id_paciente from vw_adm_paciente where pac_id = zz.pac_id) as id_pac, to_char(zz.fecha_ingreso,'dd/mm/yyyy') as fecha_adm, (select descripcion from tbl_adm_categoria_admision where codigo = zz.categoria) as categoria, zz.fecha_ingreso, zz.admision from (");
	sbSql.append("select z.pac_id, z.fac_secuencia as admision, sum(decode(z.tipo_transaccion,'D',-z.cantidad,z.cantidad) * (z.monto + nvl(z.recargo,0))) as total, (select categoria from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as categoria, (select fecha_ingreso from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as fecha_ingreso, trunc(to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')) - (select fecha_ingreso from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as diff, nvl((select empresa from tbl_adm_beneficios_x_admision where pac_id = z.pac_id and admision = z.fac_secuencia and prioridad = 1 and estado = 'A' and rownum=1),0) as empresa, nvl((select poliza from tbl_adm_beneficios_x_admision where pac_id = z.pac_id and admision = z.fac_secuencia and prioridad = 1 and estado = 'A' and rownum=1),' ') as poliza from tbl_fac_detalle_transaccion z where z.compania = ");
	sbSql.append(compania);
	sbSql.append(" and z.fecha_creacion  <= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy') and exists (select null from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia and trunc(fecha_ingreso) <= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')");
	if (!tipo_cta.trim().equals("")) { sbSql.append(" and tipo_cta = '"); sbSql.append(tipo_cta); sbSql.append("'"); }
	if (!categoria.trim().equals("")){ sbSql.append(" and categoria = "); sbSql.append(categoria); }
	sbSql.append(") and not exists (select null from tbl_fac_factura where pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and ((estatus != 'A' and fecha <= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')) or ( estatus  = 'A' and fecha_anulacion > to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')  ) ) )");
	
	if (!aseguradora.trim().equals("")) {sbSql.append(" and exists (select null from tbl_adm_beneficios_x_admision where pac_id = z.pac_id and admision = z.fac_secuencia and prioridad = 1 and estado = 'A'"); sbSql.append(" and empresa = "); sbSql.append(aseguradora); sbSql.append(" and rownum=1)");}
	
	sbSql.append(" group by pac_id, fac_secuencia");
sbSql.append(") zz group by zz.pac_id, zz.admision, zz.fecha_ingreso, zz.categoria, zz.empresa, zz.poliza");
/*
sbSql.append(" union all ");

sbSql.append("select 2 as ord, 'SIN BENEFICIO' as nombre_empresa, sum((case when zz.diff <= 30 then nvl(zz.total,0) else 0 end)) as corriente, sum((case when zz.diff > 30 and zz.diff <= 60 then nvl(zz.total,0) else 0 end)) as saldo_30, sum((case when zz.diff > 60 and zz.diff <= 90 then nvl(zz.total,0) else 0 end)) as saldo_60, sum((case when zz.diff > 90 and zz.diff <= 120 then nvl(zz.total,0) else 0 end)) as saldo_90, sum((case when zz.diff > 120 and zz.diff <= 150 then nvl(zz.total,0) else 0 end)) as saldo_120, sum((case when zz.diff > 150 then nvl(zz.total,0) else 0 end)) as saldo_150, sum(nvl(zz.total,0)) as total, ' ' as poliza, (select '['||pac_id||' - '||zz.admision||'] - '||nombre_paciente from vw_adm_paciente where pac_id = zz.pac_id) as nombre, (select id_paciente from vw_adm_paciente where pac_id = zz.pac_id) as id_pac, to_char(zz.fecha_ingreso,'dd/mm/yyyy') as fecha_adm, (select descripcion from tbl_adm_categoria_admision where codigo = zz.categoria) as categoria, zz.fecha_ingreso, zz.admision from (");
	sbSql.append("select z.pac_id, z.fac_secuencia as admision, sum(decode(z.tipo_transaccion,'D',-z.cantidad,z.cantidad) * (z.monto + nvl(z.recargo,0))) as total, (select categoria from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as categoria, (select fecha_ingreso from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as fecha_ingreso, trunc(to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')) - (select fecha_ingreso from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia) as diff from tbl_fac_detalle_transaccion z where z.compania = ");
	sbSql.append(compania);
	sbSql.append(" and trunc(z.fecha_creacion) <= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy') and exists (select null from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.fac_secuencia and trunc(fecha_ingreso) <= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')");
	if (!tipo_cta.trim().equals("")) { sbSql.append(" and tipo_cta = '"); sbSql.append(tipo_cta); sbSql.append("'"); }
	if (!categoria.trim().equals("")){ sbSql.append(" and categoria = "); sbSql.append(categoria); }
	sbSql.append(") and not exists (select null from tbl_fac_factura where pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and estatus != 'A') and not exists (select null from tbl_adm_beneficios_x_admision where pac_id = z.pac_id and admision = z.fac_secuencia and prioridad = 1 and estado = 'A') group by pac_id, fac_secuencia");
sbSql.append(") zz group by zz.pac_id, zz.admision, zz.fecha_ingreso, zz.categoria");
*/
sbSql.append(" order by 1,2,14,15,16");

al = SQLMgr.getDataList(sbSql.toString());
 
if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha_x = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha_x.substring(6, 10);
	String month = fecha_x.substring(3, 5);
	String day = fecha_x.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE NO FACTURADAS DETALLADO";
	String subtitle = " AL "+fecha;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
  
		

				Vector dHeader=new Vector();
				    dHeader.addElement(".26");
					dHeader.addElement(".10");
					dHeader.addElement(".06");
					dHeader.addElement(".09");
					dHeader.addElement(".08");
					dHeader.addElement(".07");
					dHeader.addElement(".06");
					dHeader.addElement(".06");
					dHeader.addElement(".07");
					dHeader.addElement(".07");
					dHeader.addElement(".08");
					//dHeader.addElement(".08");



				pc.setNoColumnFixWidth(dHeader);
				pc.createTable();
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha_x, dHeader.size());

				pc.setFont(headerFontSize,1);
				pc.addBorderCols("ID/Nombre del paciente",0);
				pc.addBorderCols("Cédula/Ruc",0);
				pc.addBorderCols("F. Adm.",1); 
				pc.addBorderCols("Póliza",0); 
				pc.addBorderCols("S. Actual",2); 
				pc.addBorderCols("Corriente",2);
				pc.addBorderCols("A 30 días",2);
				pc.addBorderCols("A 60 días",2);
				pc.addBorderCols("A 90 días",2);
				pc.addBorderCols("A 120 días",2);
				pc.addBorderCols("A 150 días",2);
				//pc.addBorderCols("Total por Cía.",2);
				
				pc.setTableHeader(2);//create de table header

			//table body
			String groupBy = "",groupBy2 = "",groupBy3="";
			String groupTitle = "",groupTitle2 = "",groupTitle3="";
			String tipo="";
			double actual = 0,corriente = 0,saldo_30 = 0,saldo_60 = 0,saldo_90 = 0,saldo_120 = 0,saldo_150 = 0,total = 0;
			double actual_f = 0,corriente_f = 0,saldo_30_f = 0,saldo_60_f = 0,saldo_90_f = 0,saldo_120_f = 0,saldo_150_f = 0,total_f = 0;
			double actual_cat = 0,corriente_cat = 0,saldo_30_cat = 0,saldo_60_cat = 0,saldo_90_cat = 0,saldo_120_cat = 0,saldo_150_cat= 0,total_cat = 0;
			
			
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		
				pc.setFont(8, 1,Color.blue);
				if(!groupBy2.trim().equals(cdo1.getColValue("nombre_empresa")+"-"+cdo1.getColValue("categoria")))
				{
				 	if(i!=0)
					{
						pc.addBorderCols("TOTALES POR "+groupTitle2, 0,4, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(actual_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(corriente_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_30_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_60_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_90_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_120_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_150_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						actual_cat = 0;corriente_cat = 0;saldo_30_cat = 0;saldo_60_cat = 0;
						saldo_90_cat = 0;saldo_120_cat = 0;saldo_150_cat = 0;total_cat = 0;
						pc.addCols("  ",1,dHeader.size());
					}
					
					//pc.addBorderCols("CATEGORIA: "+cdo1.getColValue("categoria"),0,dHeader.size());
				}
				if(!groupBy.trim().equals(cdo1.getColValue("nombre_empresa")))
				{
				 	if(i!=0)
					{
						pc.addBorderCols("TOTALES POR "+groupTitle, 0,4, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(actual),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(corriente),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_30),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_60),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_90),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_120),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_150),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
						actual = 0;corriente = 0;saldo_30 = 0;saldo_60 = 0;
						saldo_90 = 0;saldo_120 = 0;saldo_150 = 0;total = 0;
						pc.addCols("  ",1,dHeader.size());
					}
					
					pc.addBorderCols("ASEGURADORA: "+cdo1.getColValue("nombre_empresa"),0,dHeader.size());
				}
				if(!groupBy2.trim().equals(cdo1.getColValue("nombre_empresa")+"-"+cdo1.getColValue("categoria")))
				{
					pc.addBorderCols("CATEGORIA: "+cdo1.getColValue("categoria"),0,dHeader.size());
				}
				
				  pc.setFont(8, 0);
				    pc.addBorderCols(""+cdo1.getColValue("nombre"),0,1);
					pc.addBorderCols(""+cdo1.getColValue("id_pac"),0,1);
					pc.addBorderCols(""+cdo1.getColValue("fecha_adm"),1,1);
					pc.addBorderCols(""+cdo1.getColValue("poliza"),0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("total")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("corriente")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_30")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_60")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_90")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_120")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_150")),2,1);
					//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("total")),2,1);
					
				groupBy    = cdo1.getColValue("nombre_empresa");
				groupTitle = cdo1.getColValue("nombre_empresa");
				groupBy2    = cdo1.getColValue("nombre_empresa")+"-"+cdo1.getColValue("categoria");
				groupTitle2 = cdo1.getColValue("categoria");
				
					actual  	  += Double.parseDouble(cdo1.getColValue("total"));
					corriente  	  += Double.parseDouble(cdo1.getColValue("corriente"));
					saldo_30	  += Double.parseDouble(cdo1.getColValue("saldo_30"));
					saldo_60	  += Double.parseDouble(cdo1.getColValue("saldo_60"));
					saldo_90	  += Double.parseDouble(cdo1.getColValue("saldo_90"));
					saldo_120	  += Double.parseDouble(cdo1.getColValue("saldo_120"));
					saldo_150	  += Double.parseDouble(cdo1.getColValue("saldo_150"));
					total     	  += Double.parseDouble(cdo1.getColValue("total"));
					
					actual_cat  	  += Double.parseDouble(cdo1.getColValue("total"));
					corriente_cat     += Double.parseDouble(cdo1.getColValue("corriente"));
					saldo_30_cat	  += Double.parseDouble(cdo1.getColValue("saldo_30"));
					saldo_60_cat	  += Double.parseDouble(cdo1.getColValue("saldo_60"));
					saldo_90_cat	  += Double.parseDouble(cdo1.getColValue("saldo_90"));
					saldo_120_cat	  += Double.parseDouble(cdo1.getColValue("saldo_120"));
					saldo_150_cat	  += Double.parseDouble(cdo1.getColValue("saldo_150"));
					total_cat         += Double.parseDouble(cdo1.getColValue("total"));
					
					actual_f  	  += Double.parseDouble(cdo1.getColValue("total"));
					corriente_f   += Double.parseDouble(cdo1.getColValue("corriente"));
					saldo_30_f	  += Double.parseDouble(cdo1.getColValue("saldo_30"));
					saldo_60_f	  += Double.parseDouble(cdo1.getColValue("saldo_60"));
					saldo_90_f	  += Double.parseDouble(cdo1.getColValue("saldo_90"));
					saldo_120_f	  += Double.parseDouble(cdo1.getColValue("saldo_120"));
					saldo_150_f	  += Double.parseDouble(cdo1.getColValue("saldo_150"));
					total_f       += Double.parseDouble(cdo1.getColValue("total"));
		}		
		
		if (al.size()==0)pc.addCols("No existe Registros para este Reporte ",1,dHeader.size());
		else
		{
				
				pc.addCols("  ",1,dHeader.size());
				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("TOTALES POR "+groupTitle2, 0,4, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(actual_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(corriente_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_30_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_60_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_90_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_120_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_150_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total_cat),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addCols("  ",1,dHeader.size());
				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("TOTALES POR "+groupTitle, 0,4, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(actual),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(corriente),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_30),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_60),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_90),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_120),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_150),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addCols("  ",1,dHeader.size());
				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("TOTALES FINAL ", 0,4, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(actual_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(corriente_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_30_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_60_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_90_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_120_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(saldo_150_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				//pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total_f),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
		
		
		}



pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>				

