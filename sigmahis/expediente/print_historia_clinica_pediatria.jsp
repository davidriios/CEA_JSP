<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
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
String cds = "10";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaEval== null) fechaEval = fecha.substring(0,10);

if (!fechaEval.trim().equals(""))appendFilter +="  and to_date(to_char(b.fecha_up(+),'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+fechaEval+"','dd/mm/yyyy')  ";

dia = fechaEval.substring(0,2);

sql = "select pad.dolencia_principal dolencia, pad.observacion enfermedad, nvl(pad.alergico_a,' ') alergico , (select join(cursor(select b.descripcion||': '||a.resultado||' ' signo from tbl_sal_detalle_signo a,tbl_sal_signo_vital b where a.pac_id = "+pacId+" and    a.secuencia = "+noAdmision+" and a.tipo_persona = 'T' and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo ),'; ') signos from dual ) signos   from tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca, tbl_sal_padecimiento_admision pad where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and aa.secuencia = pad.secuencia(+) and aa.pac_id = pad.pac_id(+) ";

cdo1 = SQLMgr.getData(sql);//

	sql = "SELECT 'A' type, to_char(a.codigo) AS codigo, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion from TBL_SAL_DIAGNOSTICO_PERSONAL a, TBL_SAL_ANTECEDENTE_PERSONAL b where a.CODIGO=b.ANTECEDENTE(+) AND b.PAC_ID(+)="+pacId;
	sql += "  union select 'B','0','ANTECEDENTES GINECO - OBSTETRICO ', ' ',' ' from dual union select 'C' type, to_char(a.fecha,'dd/mm/yyyy'),  decode(b.observacion , null , b.descripcion, b.observacion) as diagnosticos, to_char(a.fecha,'dd/mm/yyyy') as fecha,a.observacion from tbl_sal_cirugia_paciente a, TBL_CDS_PROCEDIMIENTO b, tbl_SAL_TIPO_ANESTESIA c where a.procedimiento=b.CODIGO(+) and a.tipo_anestesia=c.codigo(+) and pac_id= "+pacId;

	sql += "  union select 'A','0','ANTECEDENTES PERSONALES', ' ',' ' from dual    	union select 'C','0','HOZPITALIZACION Y CIRUGIAS', ' ',' ' from dual  	union select 'F','0','ANTECEDENTES FAMILIARES', ' ',' ' from dual 	union SELECT 'F',to_char(a.codigo) AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion from TBL_SAL_DIAGNOSTICO_FAMILIAR a, TBL_SAL_ANTECEDENTE_FAMILIAR b where a.CODIGO=b.ANTECEDENTE(+) AND b.PAC_ID(+)="+pacId+"   	union select 'D','0','ANTECEDENTES MEDICAMENTOS', ' ',' ' from dual  union select 'D' type,'1', a.descripcion, a.dosis||'  '||c.descripcion||'  '||a.cada||'  '|| decode(a.tiempo,'SEG','SEGUNDOS', 'MIN','MINUTOS', 'HRS','HORAS', 'DIA','DIAS', 'SEM','SEMANAS', 'MES','MESES')||'  '|| a.frecuencia||'  via Admin. '||b.descripcion, a.observacion /*, a.via_admin, a.cod_grupo_dosis, a.cod_frecuencia, a.cada, decode(a.tiempo,'SEG','SEGUNDOS', 'MIN','MINUTOS', 'HRS','HORAS', 'DIA','DIAS', 'SEM','SEMANAS', 'MES','MESES') tiempo, a.frecuencia,b.descripcion  descAdmin,c.descripcion descGrupo */  from tbl_sal_antecedent_medicamento a, tbl_sal_via_admin b,tbl_sal_grupo_dosis c where a.pac_id=  "+pacId+" and a.via_admin = b.codigo(+) and a.cod_grupo_dosis = c.codigo(+) union select 'E','0','TRAUMATISMOS Y SECUELAS', ' ',' ' from dual union select 'E' type,to_char(codigo), tipo_trauma, to_char(fecha,'dd/mm/yyyy') as fecha, observacion from tbl_sal_antecedente_trauma where pac_id= "+pacId+" 	order by 1,2 ";

al = SQLMgr.getDataList(sql);

	sql = "select a.codigo as codArea, 0 as codCarac, a.descripcion, nvl(b.normal,' ') as status, nvl(b.observaciones,' ') as observacion from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.codigo=b.cod_area(+) and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") union select a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp in (select distinct cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+")";
	al2 = SQLMgr.getDataList(sql);


	sql  ="select codigo, gestacion, parto, aborto, cesarea, menarca, to_char(fum,'dd/mm/yyyy') as fum, ciclo, inicio_sexual ivsa, conyuges, to_char(fecha_pap,'dd/mm/yyyy') as fecha_pap, metodo, sustancias, otros, observacion, ectopico from tbl_sal_antecedente_ginecologo where pac_id="+pacId;

			cdo2 = SQLMgr.getData(sql);
		sql = "select  'A' type, a.codigo, a.descripcion, b.observacion,'0' meses,0 edad,0 cod,'N' aplicar from tbl_sal_factor_prenatal a, tbl_sal_antecedente_prenatal b where a.codigo=b.factor_prenatal(+) and b.pac_id(+)="+pacId+" union select 'A' type, 0, 'ANTECEDENTES PRENATAL',' ', '0',0,0,'N'   from dual union select distinct 'B' type,  a.codigo, a.descripcion,b.observacion, b.valor_numero as valornum,0,0,nvl(b.cod_medida,' ') as medida from tbl_sal_factor_neonatal a, tbl_sal_antecedente_neonatal b where a.codigo=b.cod_neonatal(+) and b.pac_id(+)="+pacId+" union select 'B' type, 0, 'ANTECEDENTES NEONATALES',' ', '0',0,0,'N'   from dual union select 'C' type, a.codigo, a.descripcion,' ', decode(b.meses,1,'2 MESES',2,'4 MESES',3,'6 MESES',4,'9 MESES',5,'12 MESES',6,'18 MESES',7,'2 AÑOS',8,'3 AÑOS',9,'5 AÑOS',10,'OTRAS') meses,0,0,'N'  FROM  TBL_SAL_CRECIMIENTO_DESARROLLO a, tbl_sal_crecimiento_paciente b where a.codigo=b.crecimiento(+) and b.pac_id(+)="+pacId+ " union select 'C' type, 0, 'CRECIMIENTO Y DESARROLLO',' ', '0',0,0,'N'   from dual union select 'D' type, 0, 'EXAMEN FISICO',' ', '0',0,0,'N'   from dual union select 'E' type, a.codigo, a.descripcion , nvl(b.observacion,' ') as observacion,to_char(b.meses) meses,b.anio,0, b.aplicar from tbl_sal_vacuna a, tbl_sal_vacuna_paciente b where a.codigo=b.vacuna(+) and b.pac_id(+)="+pacId+" union select 'E' type, 0, 'INMUNIZACIONES',' ', '0',0,0,'N'   from dual union select'F' type, b.id,b.descripcion,a.observacion,'0',0,0,nvl(a.seleccionado,'N') from tbl_sal_enfermedad_operacion a, tbl_sal_parametro b where a.pac_id(+) = "+pacId+"  and a.parametro_id(+) = b.id union select 'F' type, 0, 'ENFERMEDADES Y OPERACIONES',' ', '0',0,0,'N'   from dual union select 'G' type, a.codigo, a.descripcion,nvl(b.observacion,' '),'0',0,0,nvl(b.valor,' ') from tbl_sal_diagnostico_personal a, tbl_sal_antecedente_personal b where a.codigo=b.antecedente(+) and b.pac_id(+)="+pacId+" union select 'G' type, 0, 'ANTECEDENTE PERSONAL',' ', '0',0,0,'N'   from dual  union select 'H' type,  a.codigo, a.descripcion, b.observacion, to_char(b.meses)meses, b.edad, nvl(b.codigo,0) as cod, b.aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia(+) and b.pac_id(+)="+pacId+" union select 'H' type, 0, 'ANTECEDENTES ALERGICOS',' ', '0',0,0,'N'   from dual union select 'I' type, 0, 'ANTECEDENTES TRAUMATICOS',' ', '0',0,0,'N'   from dual union select 'I' type,a.codigo, a.descripcion, b.observacion, '0',0,0, nvl(b.aplicar,' ')  from tbl_sal_factor_trauma a, tbl_sal_antecedente_trauma_ped b where a.codigo=b.cod_trauma(+) and b.pac_id(+)="+pacId+" union select 'J' type, 0, 'ANTECEDENTES EPIDEMIOLOGICOS',' ', '0',0,0,'N'   from dual union select 'J' type, a.codigo, a.descripcion,b.observacion,'0',0,0,nvl(b.aplicar,' ') as aplicar from tbl_sal_factor_epidemiologico a, tbl_sal_antecedente_epidem b where a.codigo=b.cod_epidem(+) and b.pac_id(+)="+pacId+" order by 1 asc, 2 asc,3 asc ";
	al3 = SQLMgr.getDataList(sql);


if(cdo2 == null)
{
cdo2 = new CommonDataObject();
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	String title = "HISTORIA CLINICA";
	String subtitle = " ";
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
		dHeader.addElement(".06");
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

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

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

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
		pc.addInnerTableToCols(dHeader.size());
	pc.setTableHeader(2);//create de table header (3 rows) and add header to the table
	pc.setFont(7, 1);
	pc.setVAlignment(0);

	pc.addBorderCols("ALERGICO A:  "+cdo1.getColValue("alergico"),0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());


		pc.addBorderCols("DOLENCIA PRINCIPAL:  "+cdo1.getColValue("dolencia"),0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
		pc.addBorderCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addBorderCols("ENFERMEDAD ACTUAL:   "+cdo1.getColValue("enfermedad"),0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);

		pc.addBorderCols(" ",1,dHeader.size());
		pc.addBorderCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());

	//table body

	String groupBy = "";
	int count =0;



	for (int i=0; i<al3.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al3.get(i);

		if(cdo.getColValue("codigo").trim().equals("0"))
		{
			if(count !=0)
			{
					pc.addBorderCols(" ",0,8);
					count =0;
			}
			if(i!=0)pc.addCols(" ",0,dHeader.size());
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,dHeader.size(),Color.lightGray);
		}

		if(cdo.getColValue("type").trim().equals("A")||cdo.getColValue("type").trim().equals("B"))
		{
			if(cdo.getColValue("codigo").trim().equals("0"))
			{
				pc.addBorderCols("DESCRIPCION",0,4);
				pc.addBorderCols("OBSERVACION",0,9);
			}
			else {
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,4);
			pc.addBorderCols(""+cdo.getColValue("observacion"),0,9);
			}

		}
		else if(cdo.getColValue("type").trim().equals("C") ||cdo.getColValue("type").trim().equals("F")/*||cdo.getColValue("type").trim().equals("G")*/)
		{
			if(cdo.getColValue("codigo").trim().equals("0"))
			{
				if(cdo.getColValue("type").trim().equals("C"))
				pc.addBorderCols("DESARROLLO PSICOMOTOR",0,dHeader.size(),Color.lightGray);

				//pc.addBorderCols("DESCRIPCION",0,4);
				if(cdo.getColValue("type").trim().equals("C"))
				{
					pc.addBorderCols("DESCRIPCION",0,4);
					pc.addBorderCols("EDAD",0,1);
					pc.addBorderCols("DESCRIPCION",0,6);
					pc.addBorderCols("EDAD",0,2);

				}
				/*else if(cdo.getColValue("type").trim().equals("G"))
				{
					pc.addBorderCols("DESCRIPCION",0,4);
					pc.addBorderCols("OBSERVACION",0,9);
				}*/
				else if(cdo.getColValue("type").trim().equals("F"))
				{
					pc.addBorderCols(" ",0,13); pc.addBorderCols(" ",0,13);
					pc.addBorderCols("DESCRIPCION",0,1);
					pc.addBorderCols("OBSERVACION",0,4);
					pc.addBorderCols("DESCRIPCION",0,5);
					pc.addBorderCols("OBSERVACION",0,3);
				}
			}
			else {
				if(count ==0)
				{
					count +=5;
					////System.out.println("**************** En las ds primeras columnas *****************");

					if(cdo.getColValue("type").trim().equals("C"))
					{
							pc.addBorderCols(""+cdo.getColValue("descripcion"),0,4);
							pc.addBorderCols(""+cdo.getColValue("meses"),0,1);
					}
					else
					{
							pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1);
							pc.addBorderCols(""+cdo.getColValue("observacion"),0,4);

					}
				}
				else
				{
					//pc.addBorderCols(""+cdo.getColValue("descripcion"),0,6);
					if(cdo.getColValue("type").trim().equals("C"))
					{
						pc.addBorderCols(""+cdo.getColValue("descripcion"),0,6);
						pc.addBorderCols(""+cdo.getColValue("meses"),0,2);
					}
					else
					{
						pc.addBorderCols(""+cdo.getColValue("descripcion"),0,5);
						pc.addBorderCols(""+cdo.getColValue("observacion"),0,3);

					}
					count =0;
				}

			}

		}
		else if(cdo.getColValue("type").trim().equals("G") || cdo.getColValue("type").trim().equals("I")||cdo.getColValue("type").trim().equals("J"))
		{
				if(cdo.getColValue("codigo").trim().equals("0"))
				{
					pc.addBorderCols("DESCRIPCION",0,4);
					pc.addBorderCols("OBSERVACION",0,9);
				}
				else
				{
					pc.addBorderCols(""+cdo.getColValue("descripcion"),0,4);
					pc.addBorderCols(""+cdo.getColValue("observacion"),0,9);
				}
		}
		else if(cdo.getColValue("type").trim().equals("D"))
		{
				//pc.addCols(" ",0,dHeader.size());
	 //pc.addBorderCols("EXAMEN FISICO ",1,dHeader.size());
	 pc.addCols(" ",0,dHeader.size());


	 pc.addBorderCols("TRIAGE SIGNOS VITALES:  "+cdo1.getColValue("signos"),1,dHeader.size());
	 pc.addCols(" ",0,dHeader.size());
				String area = "";
				for (int j=0; j<al2.size(); j++)
				{
					CommonDataObject cdo3 = (CommonDataObject) al2.get(j);

					if (cdo3.getColValue("codCarac").trim().equals("0"))
					{

						pc.addBorderCols(" "+cdo3.getColValue("descripcion"),0,1);
						pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,12);

					}
					else
					{
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" "+cdo3.getColValue("descripcion"),0,6);
						pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,6);
					}

					area = cdo3.getColValue("codCarac");

				}

		}
		else if(cdo.getColValue("type").trim().equals("E"))
		{
			if(cdo.getColValue("codigo").trim().equals("0"))
			{
				pc.addBorderCols("DESCRIPCION",0,2);
				pc.addBorderCols("AÑO",0,2);
				pc.addBorderCols("MESES",0,2);
				pc.addBorderCols("OBSERVACION",0,7);
			}else{
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,2);
			pc.addBorderCols(""+cdo.getColValue("edad"),1,2);
			pc.addBorderCols(""+cdo.getColValue("meses"),1,2);
			pc.addBorderCols(""+cdo.getColValue("observacion"),0,7);
			}
		}
		else if(cdo.getColValue("type").trim().equals("H"))
		{
			if(cdo.getColValue("codigo").trim().equals("0"))
			{
				pc.addBorderCols("DESCRIPCION",0,2);
				pc.addBorderCols("EDAD",0,2);
				pc.addBorderCols("MESES",0,2);
				pc.addBorderCols("OBSERVACION",0,7);
			}else{
			pc.addBorderCols(""+cdo.getColValue("descripcion"),0,2);
			pc.addBorderCols(""+cdo.getColValue("edad"),1,2);
			pc.addBorderCols(""+cdo.getColValue("meses"),1,2);
			pc.addBorderCols(""+cdo.getColValue("observacion"),0,7);
			}
		}


	}


	pc.addCols(" ",0,dHeader.size());

	pc.addCols(" ",0,dHeader.size());

	pc.addBorderCols("FIRMA:  ",0,3);
	pc.addBorderCols("FECHA:  ",0,10);
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("NOMBRE:  ",2,6);
	pc.addBorderCols(" ",0,7);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>