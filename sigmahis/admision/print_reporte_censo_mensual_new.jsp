<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
	
	ArrayList al = new ArrayList();
	ArrayList alE = new ArrayList();
	CommonDataObject cdo = new CommonDataObject();
	CommonDataObject cdoT = new CommonDataObject();
	
	String sql = "", appendFilter = "";
	StringBuffer sbSql = new StringBuffer();
	StringBuffer sbTSql = new StringBuffer();
	
	String p_dia  	= "01";   //-- valor fijo para el primer día de cada mes.
	String p_mes  	= request.getParameter("mes");
	String p_anio 	= request.getParameter("anio");
	String empresa 	= request.getParameter("aseguradora");
	
	
	if (appendFilter == null) appendFilter = "";
	
	sbSql.append("select to_char(decode(to_char(sysdate,'yyyymm'),'");
	sbSql.append(p_anio);
	sbSql.append(p_mes);
	sbSql.append("',sysdate,last_day(to_date('");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("','mm/yyyy'))),'dd') as last_day, to_char(to_date('");
	sbSql.append(p_mes);
	sbSql.append("','mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') as mes_desc from dual");
	
	cdo = SQLMgr.getData(sbSql.toString());
	int dias = Integer.parseInt(cdo.getColValue("last_day"));
	String mesReporte = cdo.getColValue("mes_desc");
	sbSql = new StringBuffer();
	
	sbSql.append("select sc.descripcion");
	
	for(int i = 1; i <= dias; i++){
		sbSql.append(", nvl(sum((case when trunc(aca.fecha_inicio) <= to_date('");
		//to_char(10,'00')
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		
		sbSql.append("','dd/mm/yyyy') and ");
		if(i<(dias-3)){
		sbSql.append("(trunc(nvl(aca.fecha_final, sysdate)) > to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') or (aca.fecha_final is null and to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') <= trunc(sysdate)))");
		} else {
		sbSql.append("((trunc(nvl(aca.fecha_final, sysdate)) >= to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') and exists (select 'x' from tbl_adm_admision x where x.pac_id = aca.pac_id and x.corte_cta = aca.secuencia) and to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') = last_day(to_date('");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("', 'mm/yyyy'))) or (trunc(nvl(aca.fecha_final, sysdate)) > to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') or (aca.fecha_final is null and to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') <= trunc(sysdate)))) and aca.fecha_ingreso <= to_date('");
		sbSql.append(i);
		sbSql.append("/");
		sbSql.append(p_mes);
		sbSql.append("/");
		sbSql.append(p_anio);
		sbSql.append("','dd/mm/yyyy') ");
		}
		sbSql.append(" then 1 else 0 end)), 0) dia");
		sbSql.append(i);
	}
	sbSql.append(" from ( select distinct z.* from (select ca.pac_id,ca.admision secuencia , ca.habitacion, ca.cama, aa.fecha_egreso, aa.fecha_ingreso,ca.compania, ca.fecha_final, ca.fecha_inicio from tbl_adm_cama_admision ca, tbl_adm_admision aa, tbl_sal_habitacion sh, tbl_sal_cama sc, tbl_adm_beneficios_x_admision aba, tbl_cds_centro_servicio cds where (ca.admision = aa.secuencia and ca.pac_id = aa.pac_id) and (aba.pac_id = aa.pac_id and aba.admision = aa.secuencia) and (ca.cama = sc.codigo and ca.habitacion = sc.habitacion and ca.compania = sc.compania) and (sh.codigo = ca.habitacion) and sh.unidad_admin = cds.codigo and aa.categoria in (1) and aa.estado in ('A', 'E', 'I') and aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' ");
	if(empresa!=null && !empresa.equals("")){
	sbSql.append(" and aba.empresa = ");
	sbSql.append(empresa);
	}
	sbSql.append(" and ((aa.fecha_ingreso >= to_date('01/");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'dd/mm/yyyy') and aa.fecha_ingreso <= last_day(to_date('");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'mm/yyyy'))) or (aa.fecha_egreso  >= to_date('01/");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'dd/mm/yyyy') and aa.fecha_egreso  <= last_day(to_date('");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'mm/yyyy')))) ");
	
	sbSql.append(" union all ");
sbSql.append(" select ca.pac_id,ca.admision secuencia , ca.habitacion, ca.cama, aa.fecha_egreso, aa.fecha_ingreso,ca.compania, ca.fecha_final, ca.fecha_inicio from tbl_adm_cama_admision ca, tbl_adm_admision aa, tbl_sal_habitacion sh, tbl_sal_cama sc, tbl_adm_beneficios_x_admision aba, tbl_cds_centro_servicio cds where (ca.admision = aa.secuencia and ca.pac_id = aa.pac_id) and (aba.pac_id = aa.pac_id and aba.admision = aa.secuencia) and (ca.cama = sc.codigo and ca.habitacion = sc.habitacion and ca.compania = sc.compania) and (sh.codigo = ca.habitacion) and sh.unidad_admin = cds.codigo and aa.categoria in (1) and aa.estado in ('A','E','I') and aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A' ");

if(empresa!=null && !empresa.equals("")){
	sbSql.append(" and aba.empresa = ");
	sbSql.append(empresa);
	}
	sbSql.append(" and ( aa.fecha_ingreso <= last_day(to_date('");
    sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'mm/yyyy')-1) and ((aa.fecha_egreso  >= to_date('01/");
	sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'dd/mm/yyyy') and aa.fecha_egreso  <= last_day(to_date('");
    sbSql.append(p_mes);
	sbSql.append("/");
	sbSql.append(p_anio);
	sbSql.append("', 'mm/yyyy'))) or (aa.fecha_egreso is null and aa.estado in ('A')))) ");
	
	sbSql.append(")z ) aca,( select ca.codigo cama, ca.habitacion, ca.compania, cds.descripcion, cds.codigo centro from tbl_sal_habitacion sh, tbl_sal_cama ca, tbl_cds_centro_servicio cds where sh.codigo = ca.habitacion and sh.compania = ca.compania and sh.quirofano=1 and sh.unidad_admin = cds.codigo and cds.origen ='S') sc where aca.cama(+) = sc.cama and aca.habitacion(+) = sc.habitacion and aca.compania(+) = sc.compania group by sc.descripcion,sc.centro order by sc.centro ");
	al = SQLMgr.getDataList(sbSql.toString());
	System.out.println("THEBRAIN > ::::::::::::::::::::::::::::::::::::::"+sbSql.toString());

	sbTSql.append("select ");

	for(int i = 1; i <= dias; i++){
		if(i!=1) sbTSql.append(", ");
		sbTSql.append("nvl(sum(dia");
		sbTSql.append(i);
		sbTSql.append("), 0) dia");
		sbTSql.append(i);
	}	
	sbTSql.append(" from (");
	sbTSql.append(sbSql.toString());
	sbTSql.append(")");
	cdoT = SQLMgr.getData(sbTSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "CENSO MENSUAL DE "+mesReporte+" - "+p_anio;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".15");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".026");
		setDetail.addElement(".025");
		setDetail.addElement(".025");
		setDetail.addElement(".025");
		setDetail.addElement(".025");
		setDetail.addElement(".037");
		setDetail.addElement(".032");

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		//second row
	pc.useTable("main");
	pc.setNoColumnFixWidth(setDetail);
	//pc.createTable();
		pc.setFont(7, 1);

		pc.addBorderCols("SALA",1);
		for(int i=1; i<=31; i++){
			pc.addBorderCols(""+i,1);
		}
		pc.addBorderCols("Tot.",1);
		pc.addBorderCols("Prom.",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//pc.setNoInnerColumnFixWidth(setDetail);
	//pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
	//pc.createInnerTable(true);
	

	//table body
	
	pc.setVAlignment(0);
	int totDias = 0;
	double prom = 0.00;
	for (int i=0; i<al.size(); i++){
		totDias = 0;

		cdo = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1,cHeight);
			//Vector vtDias = CmnMgr.str2vector(cdo.getColValue("dias"),"|");
			for(int j=1;j<=dias;j++){
				pc.addBorderCols(cdo.getColValue("dia"+j),1,1,cHeight);
				totDias += Integer.parseInt(cdo.getColValue("dia"+j));
			}
			if(dias!=31){
				for(int x=0;x<(31-dias);x++){pc.addBorderCols("",1,1,cHeight);}
			}
			
			prom = Double.parseDouble(""+totDias)/Double.parseDouble(""+dias);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,##9.99", totDias),1,1,cHeight);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,##9.99", prom),1,1,cHeight);
	}
	if (al.size() == 0)
	{
		//pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		//pc.addTable();
	}
	else
	{
		pc.setFont(7, 1);
		totDias = 0;

		pc.addBorderCols("TOTAL",2,1,cHeight);
		for(int j=1;j<=dias;j++){
			pc.addBorderCols(cdoT.getColValue("dia"+j),1,1,cHeight);
			totDias += Integer.parseInt(cdoT.getColValue("dia"+j));
		}
		if(dias!=31){
			for(int x=0;x<(31-dias);x++){pc.addBorderCols("",1,1,cHeight);}
		}
		prom = Double.parseDouble(""+totDias)/Double.parseDouble(""+dias);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,##9.99", totDias),1,1,cHeight);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,##9.99", prom),1,1,cHeight);
		
		pc.addBorderCols("NOTA: REPORTE BASADO EN LAS HABITACIONES ASIGNADAS A PACIENTE DURANTE LAS ATENCIONES.",1,setDetail.size());

	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>