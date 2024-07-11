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
REPORTE:		CDC400050.RDF
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
CommonDataObject cdoParam = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fechaCita = request.getParameter("fechaCita");
String hideQuirSinCita = request.getParameter("hideQuirSinCita");
if (hideQuirSinCita == null) hideQuirSinCita = "N";
if (appendFilter == null) appendFilter = "";
if (fechaCita == null) throw new Exception("La fecha no es válida. Por favor intente nuevamete!");

sbSql = new StringBuffer();
sbSql.append("select get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_OCULTAR_CAMPOS') as ocultarCampo, get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_OCULTAR_HORA') as ocultarHora, get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_TIPO_LABEL') as tipoLabel, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_FORZAR_CPT'),'N') as onlyCPT, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_VER_SEXO'),'N') as verSexo , nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_VER_COD_PROC'),'N') as verCodProc");

sbSql.append(" from dual");

cdoParam = SQLMgr.getData(sbSql.toString());
boolean onlyCPT = (cdoParam.getColValue("onlyCPT").equalsIgnoreCase("Y") || cdoParam.getColValue("onlyCPT").equalsIgnoreCase("S"));

sbSql = new StringBuffer();
sbSql.append("select distinct '0' as codigo, cc.descripcion as etiqueta, cc.codigo as qx_orden,to_date('");
sbSql.append(fechaCita);
sbSql.append("','dd/mm/yyyy') as hora_cita, ' ' as cuarto, ' ' as fechacita,' ' as hora_inicio, ' ' as hora_fin, ' ' as fec_nacimiento, 0 as cod_pac, 0 as pac_id, ' ' as nombre_paciente, ' ' as cedula, 0 as cita, ' ' as anestesia, ' ' as observacion, ' ' as clave, 0 as aseguradora, ' ' as hosp_ambul, ' ' as cirujano, ' ' as anestesiologo, ' ' as circulador, ' ' as instrumentista, ' ' as desc_procedimiento, ' ' as empresa_nombre, ' ' as cama, ' ' as fechaHora,' ' probable_hospitalizacion, '' as edad,'' as sexo from  tbl_sal_habitacion cc where cc.quirofano = 2 and compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and nvl(centro_servicio,unidad_admin) in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO'))");
if(hideQuirSinCita.equals("S")){
sbSql.append(" and exists (select null from tbl_cdc_cita c ");
sbSql.append(" where to_date(to_char( c.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
sbSql.append(fechaCita);
sbSql.append("','dd/mm/yyyy') and c.centro_servicio in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO')) and c.estado_cita in ('R','E') and c.habitacion = cc.codigo)");
}
sbSql.append("  union all ");
sbSql.append(" select cc.habitacion as qx ,(select descripcion from tbl_sal_habitacion where codigo=cc.habitacion and compania=cc.compania_hab) as etiqueta, cc.habitacion as orden,cc.hora_cita, nvl(cc.cuarto,' ') as cuarto, to_char(cc.fecha_cita,'dd/mm/yyyy') as fechaCita, to_char(cc.hora_cita,'hh12:mi am') as hora_inicio, to_char(cc.hora_cita + (nvl(cc.hora_est,0) / 24) + (nvl(cc.min_est,0) / (24 * 60)),'hh12:mi am') as hora_fin");
sbSql.append(", to_char(nvl((select f_nac from vw_adm_paciente where pac_id = cc.pac_id),cc.fec_nacimiento),'dd/mm/yyyy') as fec_nacimiento");
sbSql.append(", cc.cod_paciente as cod_pac, cc.pac_id");
sbSql.append(", nvl((select nombre_paciente from vw_adm_paciente where pac_id = cc.pac_id),cc.nombre_paciente) as nombre_paciente");
sbSql.append(", nvl((select decode(tipo_id_paciente,'P',pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento) from vw_adm_paciente where pac_id = cc.pac_id),(case when cc.pasaporte is null and cc.provincia is null then ' ' else decode(cc.pasaporte,null,DECODE (cc.provincia, 0, '', 00, '', cc.provincia)|| DECODE (cc.sigla, '00', '', '0', '',cc.sigla)|| '-'||cc.tomo|| '-'||cc.asiento,cc.pasaporte)||'-'||cc.d_cedula end )) as cedula");
sbSql.append(", cc.codigo as cita,cc.anestesia as anestesia, nvl(cc.observacion,' ') as observacion, to_char(cc.fecha_registro,'dd/mm/yyyy')||cc.codigo as clave, nvl(cc.empresa,0) as aseguradora, nvl(cc.hosp_amb,' ') as hosp_ambul, nvl(get_nombremedico(cc.compania,'COD_FUNC_CIRUJANO',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))), nvl((select 'Dr. '||substr(primer_nombre,1,1)||'. '||primer_apellido from tbl_adm_medico where codigo=cc.cod_medico and rownum = 1), ' ')) as cirujano,nvl(get_nombremedico(cc.compania,'COD_FUNC_ANEST',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),'')||nvl(get_nombremedico(cc.compania,'COD_FUNC_ANEST_SOC',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),'') as anestesiologo, nvl(getcirculador('COD_FUNC_CIRC',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),' ') as circulador, nvl(getcirculador('COD_FUNC_INTRUMEN',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),' ') as instrumentista");

if (!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) {
	if (onlyCPT){ sbSql.append(",");if (cdoParam.getColValue("verCodProc").equalsIgnoreCase("S"))sbSql.append("cp.codigo||'-'||"); sbSql.append(" coalesce(cp.nombre_corto,cp.observacion,cp.descripcion) as desc_procedimiento");}
	else {sbSql.append(",");if (cdoParam.getColValue("verCodProc").equalsIgnoreCase("S"))sbSql.append("cp.codigo||'-'||"); sbSql.append("substr(decode(cc.observacion,null, COALESCE (cp.nombre_corto, cp.observacion, cp.descripcion),cc.observacion),1,400) as desc_procedimiento");}
} else{ sbSql.append(", join(cursor(select (select '- '||");
if (cdoParam.getColValue("verCodProc").equalsIgnoreCase("S"))sbSql.append(" codigo||'-'||");
sbSql.append(" coalesce(nombre_corto,observacion,descripcion) from tbl_cds_procedimiento where codigo = z.procedimiento) from tbl_cdc_cita_procedimiento z where cod_cita = cc.codigo and fecha_cita = cc.fecha_registro),chr(10)) as desc_procedimiento");}

sbSql.append(", nvl((select nvl(abreviado,nombre) from tbl_adm_empresa where codigo = decode(cc.admision,null,cc.empresa,(select empresa from tbl_adm_beneficios_x_admision where pac_id = cc.pac_id and admision = cc.admision and nvl(estado,'A') = 'A' and prioridad = 1 and rownum = 1))),' ') as empresa_nombre, getcama(cc.pac_id,cc.hosp_amb,cc.admision,cc.cuarto) as cama, to_char(cc.fecha_cita,'dd/mm/yyyy')||' '||to_char(cc.hora_cita,'hh24:mi:ss') as fechahora, nvl(cc.probable_hospitalizacion,'N') probable_hospitalizacion,case when pac_id is not null then (select edad||' A '||edad_mes||' M '||edad_dias ||' D ' from vw_adm_paciente where pac_id=cc.pac_id ) else nvl(trunc(months_between(sysdate, trunc(fec_nacimiento))/12),0) ||' A ' || nvl(mod(trunc(months_between(sysdate,trunc(fec_nacimiento))),12),0) ||' M ' || trunc(sysdate-add_months(trunc(fec_nacimiento),(nvl(trunc(months_between(sysdate,trunc(fec_nacimiento))/12),0)*12+nvl(mod(trunc(months_between(sysdate,trunc(fec_nacimiento))),12),0)))) || ' D' end as edad ,case when pac_id is not null then (select sexo from vw_adm_paciente where pac_id=cc.pac_id ) else ' ' end as sexo   from tbl_cdc_cita cc ");
if (!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) sbSql.append(",  tbl_cds_procedimiento cp ,tbl_cdc_cita_procedimiento ccp");
sbSql.append(" where to_date(to_char( cc.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
sbSql.append(fechaCita);
sbSql.append("','dd/mm/yyyy') and cc.centro_servicio in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO')) and cc.estado_cita in ('R','E') ");
if (!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) sbSql.append(" and cc.codigo = ccp.cod_cita(+) and ccp.procedimiento = cp.codigo(+) and cc.fecha_registro = ccp.fecha_cita(+)");
sbSql.append(" order by 3,4 ");
al = SQLMgr.getDataList(sbSql.toString());

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

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//11-792 14-1008
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 9;
	int groupFontSize = 10;
	int contentFontSize = 6;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PROGRAMA QUIRURGICO";
	String subtitle = CmnMgr.getFormattedDate(fechaCita,"FMDAY dd, MONTH yyyy");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		if(!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y"))
		{
			dHeader.addElement(".04");
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))dHeader.addElement(".18");
			else dHeader.addElement(".22");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".03");
			dHeader.addElement(".10");
			dHeader.addElement(".06");
			dHeader.addElement(".05");
			dHeader.addElement(".05");
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))dHeader.addElement(".03");
			dHeader.addElement(".09");
		}
		else
		{
		  dHeader.addElement(".04");
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))dHeader.addElement(".15");
			else dHeader.addElement(".18");
			dHeader.addElement(".15");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".03");
			dHeader.addElement(".13");
			dHeader.addElement(".06");
			dHeader.addElement(".05");
			dHeader.addElement(".05");
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))dHeader.addElement(".03");
			dHeader.addElement(".13");
		}


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);//create de table header

	//table body
	String groupBy = "";
	int iHab = 0,citas=0;
	int maxHabRows = 5;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("etiqueta")))
		{
			if (i != 0)
			{
				pc.setFont(contentFontSize,0);
				pc.setVAlignment(0);
				for (int j=iHab; j<=maxHabRows; j++)
				{
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.5f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					if (!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
					
					
				}
				iHab = 0;
				if(citas>0 &&cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))pc.addCols("****** TOTAL POR AREA ******: "+citas,0,dHeader.size());
				citas=0;
				pc.useTable("main");
				pc.addTableToCols(groupBy,1,dHeader.size());
				pc.flushTableBody(true);
			}
			pc.setNoColumnFixWidth(dHeader);
			pc.createTable(cdo.getColValue("etiqueta"),false,0,topMargin+bottomMargin,height);
				pc.setFont(groupFontSize,1);
				pc.addBorderCols(cdo.getColValue("etiqueta"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

				pc.setFont(headerFontSize,0);
				if(cdoParam.getColValue("ocultarHora").equalsIgnoreCase("N")) pc.addBorderCols("HORA",1);
				else pc.addBorderCols(" ",1);
				pc.addBorderCols("OPERACION",1,1);
				if (cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) pc.addBorderCols("OBSERVACION",1);

				pc.addBorderCols("CIRUJANO",1);
				pc.addBorderCols("ANESTESIOLOGO",1);
				if(!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")){
				pc.addBorderCols("INSTRUMENTISTA",1);
				pc.addBorderCols("CIRCULADOR",1);}

				pc.addBorderCols("SALA",1);
				pc.addBorderCols("PACIENTE",1);
				pc.addBorderCols("CEDULA",1);
				pc.addBorderCols("F. NAC.",1);
				pc.addBorderCols("EDAD",1);
				if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S")) pc.addBorderCols("SEXO",1);
				pc.addBorderCols("ASEGURADORA",1,1);
			pc.setTableHeader(2);//set first header with hab
		}//diff hab

		if (!cdo.getColValue("cita").equals("0"))
		{
			pc.setFont(contentFontSize,0);
			pc.setVAlignment(0);
			if(cdoParam.getColValue("ocultarHora").equalsIgnoreCase("N")) pc.addBorderCols(cdo.getColValue("hora_inicio")+((cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y"))?" - "+cdo.getColValue("hora_fin"):""),1,1,0.5f,0.0f,0.5f,0.5f);
			else pc.addBorderCols(" ",1,1,0.5f,0.0f,0.5f,0.5f);
			pc.addBorderCols(cdo.getColValue("desc_procedimiento"),0,1,0.5f,0.0f,0.0f,0.5f);
			if (cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) pc.addBorderCols(cdo.getColValue("observacion"),0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("cirujano"),0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("anestesiologo"),0,1,0.5f,0.0f,0.0f,0.5f);
			if(!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")){
			pc.addBorderCols(cdo.getColValue("instrumentista"),0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("circulador"),0,1,0.5f,0.0f,0.0f,0.5f);}
			pc.addBorderCols(cdo.getColValue("cama"),1,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("nombre_paciente"),0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("cedula"),0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("fec_nacimiento"),1,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("edad"),0,1,0.5f,0.0f,0.0f,0.5f);
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))pc.addBorderCols(cdo.getColValue("sexo"),1,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(cdo.getColValue("empresa_nombre"),0,1,0.5f,0.0f,0.0f,0.5f);
			citas ++;
		}

		//if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("etiqueta");
		iHab++;
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		for (int j=iHab; j<=maxHabRows; j++)
		{
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.5f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			if(!cdoParam.getColValue("ocultarCampo").equalsIgnoreCase("Y")) pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			if(cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.5f);
		}
		
		if(citas>0 &&cdoParam.getColValue("verSexo").equalsIgnoreCase("S"))pc.addCols("****** TOTAL POR AREA ******: "+citas,0,dHeader.size());
				citas=0;
		pc.useTable("main");
		pc.addTableToCols(groupBy,1,dHeader.size());
		//pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
		
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>