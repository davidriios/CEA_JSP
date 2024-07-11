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
Reporte
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
ArrayList al2= new ArrayList();
ArrayList al3= new ArrayList();
ArrayList al4= new ArrayList();
ArrayList al5= new ArrayList();


CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEval = request.getParameter("fechaEval");
String cod_Historia = request.getParameter("cod_Historia");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String dia = "";
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaEval== null) fechaEval = fecha.substring(0,10);

if (!fechaEval.trim().equals(""))appendFilter +="  and to_date(to_char(b.fecha_up(+),'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+fechaEval+"','dd/mm/yyyy')  ";

dia = fechaEval.substring(0,2);


sql = "select  pad.dolencia_principal dolencia, pad.observacion enfermedad , (select join(cursor(select '  '||b.descripcion||':  '||a.resultado||' ' signo from tbl_sal_detalle_signo a,tbl_sal_signo_vital b, (select min(to_date(to_char(b.fecha_signo,'dd-mm-yyyy')||' '||to_char(b.hora,'hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am') ) fecha_hora, b.pac_id, b.secuencia  from tbl_sal_detalle_signo b   where b.pac_id = "+pacId+"  and  b.secuencia = "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = b.pac_id and secuencia = b.secuencia and fecha = b.fecha_signo and hora = b.hora and tipo_persona = b.tipo_persona and status = 'A')  group by b.pac_id, b.secuencia) c  where a.pac_id = "+pacId+" and   a.secuencia = "+noAdmision+"  /*and a.tipo_persona = 'T' */ and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo AND a.pac_id = c.pac_id  AND a.secuencia = c.secuencia  AND TO_DATE (TO_CHAR (a.fecha_signo, 'dd-mm-yyyy')|| ' '|| TO_CHAR (a.hora, 'hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am') = c.fecha_hora ),'; ') signos from dual ) signos   from tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca, tbl_sal_padecimiento_admision pad where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and aa.secuencia = pad.secuencia(+) and aa.pac_id = pad.pac_id(+)";

cdo1 = SQLMgr.getData(sql);//

	sql = "SELECT 'A' type, to_char(a.codigo) AS codigo, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion, '-' as dosis, '-' as frecuencia from TBL_SAL_DIAGNOSTICO_PERSONAL a, TBL_SAL_ANTECEDENTE_PERSONAL b where a.CODIGO=b.ANTECEDENTE(+) AND b.PAC_ID(+)="+pacId;
	sql += "  union select 'B','0','ANTECEDENTES GINECO - OBSTETRICO ', ' ',' ', '-' as dosis, '-' as frecuencia from dual union select 'C' type, to_char(a.fecha,'dd/mm/yyyy'),  decode(a.tipo_registro,'C', decode(a.diagnostico, null, (decode(b.observacion , null , b.descripcion, b.observacion)),coalesce(d.observacion,d.nombre) ),coalesce(d.observacion,d.nombre)) as diagnosticos, to_char(a.fecha,'dd/mm/yyyy') as fecha,a.observacion, '-' as dosis, '-' as frecuencia from tbl_sal_cirugia_paciente a, TBL_CDS_PROCEDIMIENTO b, tbl_SAL_TIPO_ANESTESIA c,tbl_cds_diagnostico d where a.procedimiento=b.CODIGO(+) and a.tipo_anestesia=c.codigo(+) and a.diagnostico = d.codigo(+) and pac_id= "+pacId;

	sql += "  union select 'A','0','ANTECEDENTES PERSONALES', ' ',' ',  '-' as dosis, '-' as frecuencia from dual    	union select 'C','0','HOZPITALIZACION Y CIRUGIAS', ' ',' ', '-' as dosis, '-' as frecuencia from dual  	union select 'F','0','ANTECEDENTES FAMILIARES', ' ',' ', '-' as dosis, '-' as frecuencia from dual 	union SELECT 'F',to_char(a.codigo) AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion, '-' as dosis, '-' as frecuencia from TBL_SAL_DIAGNOSTICO_FAMILIAR a, TBL_SAL_ANTECEDENTE_FAMILIAR b where a.CODIGO=b.ANTECEDENTE(+) AND b.PAC_ID(+)="+pacId+"   	union select 'D','0','ANTECEDENTES MEDICAMENTOS', ' ',' ', '-' as dosis,'-' as frecuencia from dual  union select 'D' type,'1', a.descripcion, a.dosis||'  '||c.descripcion||'  '||a.cada||'  '|| decode(a.tiempo,'SEG','SEGUNDOS', 'MIN','MINUTOS', 'HRS','HORAS', 'DIA','DIAS', 'SEM','SEMANAS', 'MES','MESES')||'  '|| a.frecuencia||'  via Admin. '||b.descripcion, a.observacion /*, a.via_admin, a.cod_grupo_dosis, a.cod_frecuencia, a.cada, decode(a.tiempo,'SEG','SEGUNDOS', 'MIN','MINUTOS', 'HRS','HORAS', 'DIA','DIAS', 'SEM','SEMANAS', 'MES','MESES') tiempo, a.frecuencia,b.descripcion  descAdmin,c.descripcion descGrupo */, a.dosis, a.frecuencia  from tbl_sal_antecedent_medicamento a, tbl_sal_via_admin b,tbl_sal_grupo_dosis c where a.pac_id=  "+pacId+" and a.via_admin = b.codigo(+) and a.cod_grupo_dosis = c.codigo(+) union select 'E','0','TRAUMATISMOS Y SECUELAS', ' ',' ', '-' as dosis, '-' as frecuencia from dual union select 'E' type,to_char(codigo), tipo_trauma, to_char(fecha,'dd/mm/yyyy') as fecha, observacion, '-' as dosis, '-' as frecuencia from tbl_sal_antecedente_trauma where pac_id= "+pacId+" 	order by 1,2 ";

al = SQLMgr.getDataList(sql);

	sql = "select * from (select c.sec_orden, a.codigo as codArea, 0 as codCarac, a.descripcion, decode(nvl(b.normal,' '),'A','ANORMAL','S','NORMAL','NO EVALUADO')/*nvl(b.normal,' ')*/ as status, nvl(b.observaciones,' ') as observacion from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c where a.codigo=b.cod_area(+) and a.codigo = c.cod_area  and c.centro_servicio ="+cds+" /*a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+")*/ and a.usado_por in('T','M') union select c.sec_orden, a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c   where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp = c.cod_area  and c.centro_servicio ="+cds+" /*a.cod_area_corp in (select distinct cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+")*/ and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+") and a.usado_por in('T','M') ) order by 1, 3";
//	sql = "select a.codigo as codArea, 0 as codCarac, a.descripcion, nvl(b.normal,' ') as status, nvl(b.observaciones,' ') as observacion from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.codigo=b.cod_area(+) and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") union select a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp in (select distinct cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+")";
	al2 = SQLMgr.getDataList(sql);


	sql  ="select codigo, gestacion, parto, aborto, cesarea, menarca, to_char(fum,'dd/mm/yyyy') as fum, ciclo, inicio_sexual ivsa, conyuges, to_char(fecha_pap,'dd/mm/yyyy') as fecha_pap, metodo, sustancias, otros, observacion, ectopico from tbl_sal_antecedente_ginecologo where pac_id="+pacId;

			cdo2 = SQLMgr.getData(sql);
		sql = "select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia(+) and b.pac_id(+)="+pacId+" ORDER BY a.DESCRIPCION ";
	al3 = SQLMgr.getDataList(sql);




if(cdo2 == null)
{
cdo2 = new CommonDataObject();
}
//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;
		PdfCreator footer = new PdfCreator();

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".03");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");

				CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(8, 1);
	pc.setVAlignment(0);
		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("DOLENCIA PRINCIPAL",0,13,cHeight,Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo1.getColValue("dolencia"),0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
		pc.addBorderCols(" ",0,dHeader.size());

		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("ENFERMEDAD ACTUAL",0,13,cHeight,Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo1.getColValue("enfermedad"),0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);

		pc.addBorderCols(" ",1,dHeader.size());
		pc.addBorderCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());

	//table body
	pc.setFont(7, 1);

	String groupBy = "", si="", no="";

		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("ANTECEDENTES ALERGICOS",0,13,cHeight,Color.gray);
		pc.setFont(8, 0);
		//pc.addBorderCols("ANTECEDENTES ALERGICOS:   ",0,dHeader.size());

		pc.addBorderCols("DESCRIPCION",0,2);
		pc.addBorderCols("SI",1,1);
		pc.addBorderCols("NO",1,1);
		pc.addBorderCols("EDAD",0,1);
		pc.addBorderCols("MESES",0,1);
		pc.addBorderCols("OBSERVACION",0,7);
	for (int i=0; i<al3.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al3.get(i);
		pc.addBorderCols(""+cdo.getColValue("descripcion"),0,2);
		if(cdo.getColValue("aplicar") != null && cdo.getColValue("aplicar").trim().equals("S")){
		 si = "x";
		 no = "";
		}else{
		si = "";
		no ="x";}
		 pc.addBorderCols(si,1,1);
		 pc.addBorderCols(no,1,1);
		//pc.addBorderCols(""+cdo.getColValue("aplicar"),0,1);
		pc.addBorderCols(""+cdo.getColValue("edad"),1,1);
		pc.addBorderCols(""+cdo.getColValue("meses"),1,1);
		pc.addBorderCols(""+cdo.getColValue("observacion"),0,8);
	}


	pc.addCols(" ",0,dHeader.size());
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(!groupBy.trim().equals(cdo.getColValue("type")))
		{
			pc.addCols(" ",0,dHeader.size());
			pc.setFont(8, 0,Color.WHITE);
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,13,cHeight,Color.gray);
			pc.setFont(8, 0);
//			pc.addBorderCols(""+cdo.getColValue("descripcion"),1,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
			if(!cdo.getColValue("type").trim().equals("B")  && !cdo.getColValue("type").trim().equals("C")&& !cdo.getColValue("type").trim().equals("D") && !cdo.getColValue("type").trim().equals("E"))
			{
				pc.addBorderCols("DIAGNOSTICOS",0,1);
				pc.addBorderCols("SI",0,1);
				pc.addBorderCols("NO",0,1);
				pc.addBorderCols("OBSERVACIONES",0,10);
			}
			else if(cdo.getColValue("type").trim().equals("C"))
			{
				pc.addBorderCols("DIAGNOSTICOS PROC.",0,1);
				pc.addBorderCols("FECHA",0,2);
				pc.addBorderCols("OBSERVACIONES",0,10);
			}
			else if(cdo.getColValue("type").trim().equals("B"))
			{
				if(cdo2.getColValue("gestacion") == null)
				pc.addBorderCols("G:  ",0,1);
				else pc.addBorderCols("G:  "+cdo2.getColValue("gestacion"),0,1);
				pc.addBorderCols("P:  ",2,2);
				pc.addBorderCols((cdo2.getColValue("parto")==null)?" ":cdo2.getColValue("parto"),0,1);
				pc.addBorderCols("A:  ",2,1);
				pc.addBorderCols((cdo2.getColValue("aborto")==null)?" ":cdo2.getColValue("aborto"),0,1);
				pc.addBorderCols("C_: ",2,1);
				pc.addBorderCols((cdo2.getColValue("cesarea")==null)?" ":cdo2.getColValue("cesarea"),0,1);
				pc.addBorderCols("E: ",2,1);
				pc.addBorderCols((cdo2.getColValue("ectopico")==null)?" ":cdo2.getColValue("ectopico"),0,1);

				pc.addBorderCols("Menarca: ",2,1);
				pc.addBorderCols((cdo2.getColValue("Menarca")==null)?" ":cdo2.getColValue("Menarca"),0,2);


				if(cdo2.getColValue("ivsa") == null)
				pc.addBorderCols("I.V.S.A:  ",0,1);
				else pc.addBorderCols("I.V.S.A :  "+cdo2.getColValue("ivsa"),0,1);
				pc.addBorderCols("FUM:  ",2,2);
				pc.addBorderCols((cdo2.getColValue("fum")==null)?" ":cdo2.getColValue("fum"),0,1);
				pc.addBorderCols("Ciclo",2,1);
				pc.addBorderCols((cdo2.getColValue("ciclo")==null)?" ":cdo2.getColValue("ciclo"),0,8);

				if(cdo2.getColValue("fecha_pap") == null)
				pc.addBorderCols("Ultimo Pap: ",0,1);
				else pc.addBorderCols("Ultimo Pap: "+cdo2.getColValue("fecha_pap"),0,1);


				pc.addBorderCols("Metodo Plan. ",0,3);
				pc.addBorderCols((cdo2.getColValue("metodo")==null)?" ":cdo2.getColValue("metodo"),0,10);


				if(cdo2.getColValue("otros") == null)
				pc.addBorderCols("Otros: ",0,1);
				else pc.addBorderCols("Otros: "+cdo2.getColValue("otros"),0,dHeader.size());
				pc.addBorderCols(" ",0,dHeader.size());
				pc.addBorderCols(" ",0,dHeader.size());


				pc.addBorderCols("Exposición a Tóxicos y Substancia Químicas o Radiaciones",0,1);

				pc.addBorderCols(" SI",2,2);
				if(cdo2.getColValue("sustancias") != null && cdo2.getColValue("sustancias").trim().equals("S"))
				pc.addBorderCols(" ",2,1,Color.BLACK);
				else pc.addBorderCols(" ",2,1);
				pc.addBorderCols(" NO",2,1);
				if(cdo2.getColValue("sustancias") != null && cdo2.getColValue("sustancias").trim().equals("N"))
				pc.addBorderCols(" ",2,1,Color.BLACK);
				else pc.addBorderCols(" ",2,1);
				pc.addBorderCols(" ",2,7);

				groupBy = "S";
				if(cdo2.getColValue("sustancias") != null)
				pc.addBorderCols("OBSERVACIONES:  "+cdo2.getColValue("observacion"),0,dHeader.size());
				else pc.addBorderCols("OBSERVACIONES:  ",0,dHeader.size());
				pc.addBorderCols(" ",0,dHeader.size());
				pc.addBorderCols(" ",0,dHeader.size());

			}
			else if(cdo.getColValue("type").trim().equals("D") )
			{
				pc.addBorderCols("NOMBRE DEL MEDICAMENTO",0,1);
				//pc.addBorderCols("DOSIS",0,2);
				//pc.addBorderCols("FRECUENCIA",0,2);
				//pc.addBorderCols("OBSERVACION",0,8);
			}
			else
			{
				if(cdo.getColValue("type").trim().equals("E"))
				pc.addBorderCols("TIPO DE TRAUMA",0,1);
				else
				pc.addBorderCols("DIAGNOSTICOS PROC.",0,1);

				pc.addBorderCols("FECHA",0,2);
				pc.addBorderCols("OBSERVACIONES",0,10);
			}

		}

		if(!cdo.getColValue("type").trim().equals("B") && !cdo.getColValue("codigo").trim().equals("0") )
		{
			pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
			//else pc.addBorderCols(" ",0,1);

			if(!cdo.getColValue("type").trim().equals("C") && !cdo.getColValue("type").trim().equals("E"))
			{
				if(cdo.getColValue("valor").trim().equals("S")){
					si = "x";
					no = "";
				}else{
					si = "";
					no = "x";
				}
				pc.addBorderCols(si,1,1);
				pc.addBorderCols(no,1,1);
				pc.addBorderCols(cdo.getColValue("observacion"),0,10);
			}
			else if(cdo.getColValue("type").trim().equals("D"))
			{
				 //pc.addBorderCols(cdo.getColValue("dosis"),0,3,0.0f,0.5f,0.5f,0.5f);
				 //pc.addBorderCols(cdo.getColValue("frecuencia"),0,2,0.0f,0.5f,0.5f,0.5f);
				 //pc.addBorderCols(cdo.getColValue("observacion"),0,6);
				 pc.addBorderCols(cdo.getColValue("valor"),0,5);
				 pc.addBorderCols(cdo.getColValue("observacion"),0,8,0.0f,0.5f,0.5f,0.5f);
			}
			else
			{
				pc.addBorderCols(cdo.getColValue("valor"),1,2);
					pc.addBorderCols(cdo.getColValue("observacion"),0,10);
			 }

		}else pc.addBorderCols(" ",0,dHeader.size());



		groupBy = cdo.getColValue("type");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	 //pc.addCols(" ",0,dHeader.size());
	 //pc.addBorderCols("EXAMEN FISICO ",1,dHeader.size());
	 //*******************************************************
	 //  EXAMAN FISICO
	 //*******************************************************
	 pc.setFont(8, 0,Color.WHITE);
		 pc.addBorderCols("EXAMEN FISICO",0,13,cHeight,Color.GRAY);
		 pc.setFont(8, 0);
	 pc.addCols(" ",0,dHeader.size());

	 pc.addBorderCols("TRIAGE SIGNOS VITALES:  "+cdo1.getColValue("signos"),1,dHeader.size());
	 pc.addCols(" ",0,dHeader.size());
	String area = "";
	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al2.get(i);

		if (cdo.getColValue("codCarac").trim().equals("0"))
		{
			pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(" "+cdo.getColValue("status"),0,6);
			pc.addBorderCols(" "+cdo.getColValue("observacion"),0,6);
		}
		else
		{
			pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("        - "+cdo.getColValue("descripcion"),0,6);
			pc.addBorderCols(" "+cdo.getColValue("observacion"),0,6);
		}

		area = cdo.getColValue("codCarac");

	}

	pc.addCols(" ",0,dHeader.size());

	 pc.setFont(8, 0,Color.WHITE);
	 pc.addBorderCols("EXAMENES DE LABORATORIO",0,13,cHeight,Color.GRAY);
	 pc.setFont(8, 0);
	//pc.addBorderCols(" ",0,dHeader.size());
	pc.addBorderCols("HB:   ",0,2,0.5f,0.0f,0.0f,0.0f);
	pc.addCols("  ",0,1);
	pc.addBorderCols("HCTO:   ",0,2,0.5f,0.0f,0.0f,0.0f);
	pc.addCols("  ",0,1);
	pc.addBorderCols("TIPAJE:   ",0,2,0.5f,0.0f,0.0f,0.0f);
	pc.addCols("  ",0,5);
	pc.addBorderCols("GLICEMIA:   ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols("URINALISIS:   ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols("OTROS:   ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);


	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());

	pc.addBorderCols("COMENTARIOS ADICIONALES ",0,dHeader.size());
	pc.addBorderCols(" ",0,dHeader.size());
	pc.addBorderCols("IMPRESION DIAGNOSTICA ",0,dHeader.size());
	pc.addBorderCols(" ",0,dHeader.size());

	pc.addCols(" ",0,dHeader.size());

	pc.addBorderCols("FIRMA:  ",0,3);
	pc.addBorderCols("FECHA:  ",0,10);
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("NOMBRE:  ",2,6);
	pc.addBorderCols(" ",0,7);

if ( al.size() == 0 ){
		pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>