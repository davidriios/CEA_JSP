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
CommonDataObject cdo2 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cod_solicitud = request.getParameter("cod_solicitud");
String codigo = request.getParameter("codigo");


if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fp == null) fp = "imagenologia";


sql = "select  to_char(ds.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am')fecha_resultado,ds.codigo_muestra, ap.telefono,ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada) as nombre_paciente, decode(ap.pasaporte, null,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento||'-'||ap.d_cedula,ap.pasaporte) as identificacion, to_char(aa.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(aa.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, nvl(aa.medico,' ') as medico, to_char(ap.f_nac,'dd/mm/yyyy') as f_nac, ap.codigo as codigo_paciente, aa.secuencia as admision, m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, aca.habitacion||decode(aca.habitacion,null,'','/'||aca.cama) as cama,pa.dolencia_principal, pa.observacion historia , ap.edad||' Año(s) '|| ap.edad_mes||' Mes(es) '|| ap.edad_dias||' Dia (s)' as edad, ap.sexo  from vw_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca, tbl_sal_padecimiento_admision pa , tbl_cds_solicitud s,tbl_cds_detalle_solicitud ds  where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and aa.pac_id =pa.pac_id(+) and aa.secuencia = pa.secuencia(+) and  ds.cod_solicitud = "+cod_solicitud+" and   ds.codigo = nvl("+codigo+", ds.codigo) and   ds.pac_id = s.pac_id  and ds.csxp_admi_secuencia = s.admi_secuencia and ds.cod_solicitud = s.codigo   and  s.pac_id = aa.pac_id and s.admi_secuencia = aa.secuencia and s.pac_id = aa.pac_id 	 ";
cdo1 = SQLMgr.getData(sql);

if (fp.trim().equalsIgnoreCase("laboratorio"))
	{
		sql = "select decode(pr.observacion ,null,pr.descripcion,pr.observacion) descproc, z.solicitud, z.detalle_solic, z.admi_secuencia, z.admi_pac_fec_nac, z.admi_pac_codigo, z.secuencia, z.resultado, nvl(z.unidad_medida,' ') as unidad_medida, decode(is_varchar_valid_number(z.resultado),null,z.resultado,to_char(to_number(z.resultado),'999,999.99')||decode(z.unidad_medida,null,'',' '||z.unidad_medida)) as resultado_display, decode(z.valor_referencia_min,null,' ',z.valor_referencia_min) as valor_referencia_min, decode(z.valor_referencia_max,null,' ',z.valor_referencia_max) as valor_referencia_max, z.pac_id, coalesce(y.descripcion,z.observacion,' ') as observacion from tbl_cds_estructura_resultado z, tbl_cds_prueba y,tbl_cds_procedimiento pr  where z.pac_id="+pacId+" and z.admi_secuencia="+noAdmision+" and z.solicitud="+cod_solicitud+" and z.detalle_solic="+codigo+" and z.estado='A' and z.observacion=y.codigo_alfa(+) and pr.codigo = z.procedimiento ";
		al = SQLMgr.getDataList(sql);
	}
	else if (fp.trim().equalsIgnoreCase("imagenologia"))
	{
		sql = "select adenda as resultado from tbl_cds_resultado_adenda where pac_id="+pacId+" and admi_secuencia="+noAdmision+" and solicitud="+cod_solicitud+" and detalle_solic="+codigo+" and estado='A' and rownum=1 order by secuencia desc";
		al = SQLMgr.getDataList(sql);
		if (al.size() == 0)
		{
			sql = "select resultado from tbl_cds_estructura_resultado where pac_id="+pacId+" and admi_secuencia="+noAdmision+" and solicitud="+cod_solicitud+" and detalle_solic="+codigo+" and estado='A'";
			al = SQLMgr.getDataList(sql);
		}
	}



if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String title = "LABORATORIO CLINICO SAN FERNANDO";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
			dHeader.addElement(".40");
			dHeader.addElement(".30");
			dHeader.addElement(".15");
			dHeader.addElement(".15");
			
		


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
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
			pc.setFont(5, 0);
			pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.10f,0.0f,0.0f,0.0f);

			pc.setFont(9, 0);
			pc.addInnerTableCols("Nombre del Paciente:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("nombre_paciente"),0,3);
			pc.addInnerTableCols("Edad:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("edad")+"      Sexo:  "+((cdo1.getColValue("sexo") != null)?cdo1.getColValue("sexo"):"") ,0,1);
			pc.addInnerTableCols("No. de Identificación:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("identificacion"),0,1);
			pc.addInnerTableCols("Fecha Nac.:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("f_nac"),0,1);
			pc.addInnerTableCols("Telefono ",0,1);
			pc.addInnerTableCols(cdo1.getColValue("telefono"),0,1);
			//pc.addInnerTableCols("sexo:",0,1);
			
			//pc.setVAlignment(0);
		/*	pc.setNoInnerColumnFixWidth(listCol2);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
			if(cdo.getColValue("sexo") != null && cdo.getColValue("sexo").trim().toLowerCase().equals("M"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols("  ",0,1);
			pc.addInnerTableCols("M",0,1);
			if(cdo.getColValue("sexo") != null && cdo.getColValue("sexo").trim().toLowerCase().equals("F"))
			pc.addInnerTableBorderCols(" X ",1,1);
			else pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols("F ",0,1);
		
			//pc.resetVAlignment();
		pc.addInnerTableToCols(1);
		*/
			pc.addInnerTableCols("Codigo Paciente:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("codigo_paciente"),0,1);
			pc.addInnerTableCols("No. Admision:",0,1);
			pc.addInnerTableCols(cdo1.getColValue("admision"),0,1);
			pc.addInnerTableCols("Codigo de la Muestra ",0,1);
			pc.addInnerTableCols(" "+cdo1.getColValue("codigo_muestra"),0,1);
			
		
			pc.addInnerTableCols("Fecha / Hora Resultados    "+cdo1.getColValue("fecha_resultado"),2,6);

			pc.setFont(3, 0);
			pc.addInnerTableCols(" ",0,infoCol.size());
			pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.0f,0.10f,0.0f,0.0f);
			pc.resetVAlignment();
		pc.addInnerTableToCols(dHeader.size());
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	//pc.setVAlignment(0);
	String descProc ="";
	for (int i=0; i<al.size(); i++)
	{
		
			CommonDataObject cdo3 = (CommonDataObject) al.get(i);
			
			
			if (fp.trim().equalsIgnoreCase("laboratorio"))
			{
				if (!descProc.trim().equalsIgnoreCase(cdo3.getColValue("descproc")))
				{
					pc.setFont(7, 0);
					pc.addCols(cdo3.getColValue("descproc"),0,4);
					
					pc.addBorderCols("PRUEBA",0,1);
					pc.addBorderCols("RESULTADO (UNIDADES)",0,1);
					pc.addBorderCols("VALOR REFERENCIA",1,2);

				}
				pc.setFont(7, 0);
				pc.addCols(cdo3.getColValue("observacion"),0,1);
				pc.addCols(cdo3.getColValue("resultado_display"),0,1);
				pc.addCols(cdo3.getColValue("valor_referencia_min"),1,1);
				pc.addCols(cdo3.getColValue("valor_referencia_max"),1,1);
				
			}
			else
			{
					/*if (!descProc.trim().equalsIgnoreCase(cdo3.getColValue("descproc")))
					{
						pc.setFont(7, 0);
						pc.addCols(cdo3.getColValue("descproc"),0,4);
						
						pc.addBorderCols("RESULTADO",0,1);

					}*/
					pc.addCols(cdo3.getColValue("resultado"),0,4);
			}
			descProc = cdo3.getColValue("descproc");
			
	}
		
		pc.setFont(7, 0);
		pc.addCols(" ",1,dHeader.size());
		
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>