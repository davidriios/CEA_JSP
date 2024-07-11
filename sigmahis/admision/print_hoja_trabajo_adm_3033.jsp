<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String codCat = request.getParameter("codCat");

if (appendFilter == null) appendFilter = "";

sql = "select sc.estado_cama,sc.codigo as cama,sc.habitacion, sh.unidad_admin as centro,sth.precio, sh.estado_habitacion, nvl(decode(sh.estado_habitacion,'M','EN MANTENIMIENTO',p.nombre) ,' ') as nombre, cs.descripcion as centro_desc ,nvl(p.vip,'N') as vip,nvl(p.sexo,' ') sexo,nvl(p.med_nombre,' ') med_nombre, nvl(p.aseguradora,' ')as aseguradora,nvl(p.fecha_ingreso,' ') as fecha_ingreso, nvl(p.corte_cta,0) corte_cta, p.pac_id, p.edad from (select ap.nombre_paciente as nombre , aca.cama,nvl(ap.vip,'N')as vip,ap.sexo,ap.pac_id,aa.fecha_creacion,am.primer_nombre||' '||am.primer_apellido||' '||am.apellido_de_casada as  med_nombre, nvl(decode(aba.empresa,null,decode(aa.tipo_cta,'J','JUBILADO','M','MEDICO','E','EMPLEADO','P','PARTICULAR',' '), emp.nombre),' ')as aseguradora,nvl(decode(aa.corte_cta,null,to_char(aa.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(aa.fecha_ingreso,'dd/mm/yyyy') ,aa.secuencia,aa.pac_id)),' ')as fecha_ingreso, nvl(aa.corte_cta,0) corte_cta,ap.f_nac ,ap.edad from tbl_adm_admision aa, vw_adm_paciente ap, tbl_adm_medico am,tbl_adm_empresa emp,tbl_adm_beneficios_x_admision aba, tbl_adm_cama_admision aca where aca.pac_id=aa.pac_id and aca.admision=aa.secuencia and aa.pac_id=ap.pac_id and aa.medico = am.codigo and aca.fecha_final is null and aa.estado = 'A' and aa.categoria in (1,5) and aba.pac_id(+)=aa.pac_id and aba.admision(+)=aa.secuencia and aba.prioridad(+)=1 and nvl(aba.estado,'A')='A' and emp.codigo(+)=aba.empresa)p, tbl_sal_habitacion sh, tbl_sal_cama sc, tbl_sal_tipo_habitacion sth, tbl_cds_centro_servicio cs where sc.compania = sh.compania and sc.habitacion = sh.codigo and sc.compania = sth.compania and sc.tipo_hab = sth.codigo and sc.estado_cama <> 'I' and sh.estado_habitacion <>'I' and sc.codigo= p.cama(+) and sh.unidad_admin = cs.codigo(+) order by sh.unidad_admin, sc.codigo " ;
al = SQLMgr.getDataList(sql);

sql = "select sh.unidad_admin, cs.descripcion, count(*) as nCamas, sum(decode(p.pac_id,null,0,1)) as inUse, sum(decode(p.pac_id,null,0,sth.precio)) as inUsePrice from (select ap.nombre_paciente nombre , aca.cama,nvl(ap.vip,'N')as vip,ap.sexo,ap.pac_id,aa.fecha_creacion,ap.f_nac as fecha_nacimiento , am.primer_nombre||' '||am.primer_apellido||' '||am.apellido_de_casada as  med_nombre, nvl(decode(aba.empresa,null,decode(aa.tipo_cta,'J','JUBILADO','M','MEDICO','E','EMPLEADO','P','PARTICULAR',' '), emp.nombre),' ')as aseguradora,nvl(decode(aa.corte_cta,null,to_char(aa.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(aa.fecha_ingreso,'dd/mm/yyyy') ,aa.secuencia,aa.pac_id)),' ')as fecha_ingreso, nvl(aa.corte_cta,0) corte_cta,ap.f_nac from tbl_adm_admision aa, vw_adm_paciente ap, tbl_adm_medico am,tbl_adm_empresa emp,tbl_adm_beneficios_x_admision aba, tbl_adm_cama_admision aca where aca.pac_id=aa.pac_id and aca.admision=aa.secuencia and aa.pac_id=ap.pac_id and aa.medico = am.codigo and aca.fecha_final is null and aa.estado = 'A' and aa.categoria in (1,5) and aba.pac_id(+)=aa.pac_id and aba.admision(+)=aa.secuencia and aba.prioridad(+)=1 and nvl(aba.estado,'A')='A' and emp.codigo(+)=aba.empresa)p, tbl_sal_habitacion sh, tbl_sal_cama sc, tbl_sal_tipo_habitacion sth, tbl_cds_centro_servicio cs where sc.compania = sh.compania and sc.habitacion = sh.codigo and sc.compania = sth.compania and sc.tipo_hab = sth.codigo and sc.estado_cama <> 'I' and sh.estado_habitacion <>'I' and sc.codigo= p.cama(+) and sh.unidad_admin = cs.codigo(+) group by sh.unidad_admin, cs.descripcion";
alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double price = 0.00;
	Hashtable htUse = new Hashtable();
	Hashtable htPrice = new Hashtable();
	int maxLines = 55; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);

		bed += Integer.parseInt(cdo.getColValue("inUse"));
		price += Double.parseDouble(cdo.getColValue("inUsePrice"));

		int nItems = Integer.parseInt(cdo.getColValue("nCamas"));
		int extraItems = nItems % maxLines;
		if (extraItems == 0) nPages += (nItems / maxLines);
		else nPages += (nItems / maxLines) + 1;

		htUse.put(cdo.getColValue("unidad_admin"),cdo.getColValue("inUse"));
		htPrice.put(cdo.getColValue("unidad_admin"),cdo.getColValue("inUsePrice"));
	}
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "admision";
	String fileNamePrefix = "print_hoja_trabajo_adm3033";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".08");
		setDetail.addElement(".06");
		setDetail.addElement(".22");
		setDetail.addElement(".05");
		setDetail.addElement(".05");
		setDetail.addElement(".05");
		setDetail.addElement(".22");
		setDetail.addElement(".07");
		setDetail.addElement(".20");
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "HOJA DE TRABAJO POR SECCIÓN PARA INGRESOS DIARIOS", "AL "+cDateTime.substring(0,10), userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("PRECIO",1);
		pc.addBorderCols("CAMA",1);
		pc.addBorderCols("PACIENTE",1);
		pc.addBorderCols("VIP",1);
		pc.addBorderCols("SEXO",1);
		pc.addBorderCols("EDAD",1);
		pc.addBorderCols("MEDICO",1);
		pc.addBorderCols("INGRESO",1);
		pc.addBorderCols("AGEGURADORA",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("centro")))
		{
			if (i != 0)
			{
				pc.createTable();
					pc.setFont(8, 1,Color.blue);
					pc.addCols("Camas En Uso: "+htUse.get(groupBy)+" por: "+CmnMgr.getFormattedDecimal((String) htPrice.get(groupBy)),0,setDetail.size());
				pc.addTable();

				lCounter = 0;
				pCounter++;
				pc.addNewPage();

				pdfHeader(pc, _comp, pCounter, nPages, "HOJA DE TRABAJO POR SECCIÓN PARA INGRESOS DIARIOS", "AL "+cDateTime.substring(0,10), userName, fecha);
			}
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				pc.addCols("[ "+cdo.getColValue("centro")+" ] "+cdo.getColValue("centro_desc"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
		}

		pc.setFont(6, 0);
		pc.createTable();
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cama"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("nombre"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("vip"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("sexo"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("edad"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("med_nombre"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fecha_ingreso"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("aseguradora"),0,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "HOJA DE TRABAJO POR SECCIÓN PARA INGRESOS DIARIOS", "AL "+cDateTime.substring(0,10), userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				pc.addCols("[ "+cdo.getColValue("centro")+" ] "+cdo.getColValue("centro_desc"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			//groupBy = "";//if this segment is uncommented then reset lCounter to 0 instead of the printed extra line (lCounter -  maxLines)
		}

		groupBy = cdo.getColValue("centro");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		pc.createTable();
			pc.setFont(8, 1,Color.blue);
			pc.addCols("Camas En Uso: "+htUse.get(groupBy)+" por: "+CmnMgr.getFormattedDecimal((String) htPrice.get(groupBy)),0,setDetail.size());
		pc.addTable();
		pc.createTable();
			pc.setFont(8, 1,Color.red);
			pc.addCols("TOTAL: "+bed+" POR:"+CmnMgr.getFormattedDecimal(price),0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>