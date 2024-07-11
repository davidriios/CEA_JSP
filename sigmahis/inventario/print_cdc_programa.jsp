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
		REPORTE:		CDC400050.RDF
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

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anioEntrega = request.getParameter("anioEntrega");
String anioReq = request.getParameter("anioReq");
String noReq = request.getParameter("noReq");
String noEntrega = request.getParameter("noEntrega");
String articulo = request.getParameter("articulo");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");
String fecha1 = request.getParameter("fecha");



if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(depto== null) depto = "";
if(anioEntrega== null) anioEntrega = "";
if(anioReq== null) anioReq = "";
if(noReq== null) noReq = "";
if(noEntrega== null) noEntrega = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";
if(fecha1== null) fecha1 = "";//"04/03/2009";


String descFecha = CmnMgr.getFormattedDate(fecha1,"FMDAY dd, MONTH yyyy");


if (appendFilter == null) appendFilter = "";

sql = "select distinct '0' as codigo, cc.descripcion as qx, cc.codigo as qx_orden, ' ' as cuarto, ' ' as fechacita,' ' as hora, ' ' as fecha_nac, 0 as cod_pac, 0 as pac_id, ' ' as paciente, ' ' as cedula, ' ' as anestesia, ' ' as observacion, ' ' as clave, 0 as aseguradora, ' ' as hosp_ambul, ' ' as cirujano, ' ' as anestesiologo, ' ' as circulador, ' ' as instrumentista, ' ' as descproc, ' ' as descaseg, ' ' as cama, ' ' as fechaHora,' ' prob_hosp from  tbl_sal_habitacion cc where cc.quirofano = 2 and compania="+compania;
sql += " union ";
sql += " select cc.habitacion as qx ,' ' as qxs, cc.habitacion as orden, nvl(cc.cuarto,' ') as cuarto, to_char(cc.fecha_cita,'dd/mm/yyyy') as fechaCita, to_char(cc.hora_cita,'hh12:mi am') as hora, to_char(cc.fec_nacimiento,'dd/mm/yyyy') as fecha_nac, cc.cod_paciente as cod_pac, cc.pac_id, decode(pa.primer_apellido||pa.segundo_apellido||pa.primer_nombre||pa.segundo_nombre,null,cc.nombre_paciente,decode(pa.apellido_de_casada,null,pa.primer_apellido,pa.apellido_de_casada)||', '||pa.primer_nombre) as nombrepaciente, decode(pa.tipo_id_paciente,'P',pa.pasaporte,'C',(decode(pa.provincia,0,' ',00,' ',10,'0',11,'B',12,'C',pa.provincia)||rpad(decode(pa.sigla,'00','','0','',pa.sigla),2,' ')||'-'||lpad(to_char(pa.tomo),3,'0')||'-'||lpad(to_char(pa.asiento),5,'0')),'---') as cedula, cc.anestesia as anestesia, nvl(cc.observacion,' ') as observacion, to_char(cc.fecha_registro,'dd/mm/yyyy')||cc.codigo as clave, nvl(cc.empresa,0) as aseguradora, nvl(cc.hosp_amb,' ') as hosp_ambul, nvl(get_nombremedico(1,to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),'') as cirujano, nvl(get_nombremedico(2,to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),'') as anestesiologo, nvl(getcirculador('7',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),' ') as circulador, nvl(getcirculador('6,8',to_char( cc.fecha_registro,'dd/mm/yyyy')||(to_char(cc.codigo))),' ') as instrumentista, substr(decode(cc.observacion,null, cp.descripcion,cc.observacion),1,400) as proc, nvl(nvl(e.nombre_abreviado,e.nombre),' ') as aseg, getcama(cc.pac_id,cc.hosp_amb,cc.cuarto) as sala, to_char(cc.fecha_cita,'dd/mm/yyyy')||' '||to_char(cc.hora_cita,'hh24:mi:ss') as fechahora, nvl(cc.probable_hospitalizacion,'N') prob_hosp  from tbl_cdc_cita cc, tbl_adm_empresa e,tbl_adm_paciente pa,  tbl_cds_procedimiento cp ,tbl_cdc_cita_procedimiento ccp where to_date(to_char( cc.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+fecha1+"','dd/mm/yyyy') and cc.centro_servicio in (select codigo from tbl_cds_centro_servicio where flag_cds = 'SOP') and cc.estado_cita in ('R','E') and cc.empresa=e.codigo(+) and cc.pac_id=pa.pac_id(+) and cc.codigo=ccp.cod_cita(+) and ccp.procedimiento=cp.codigo(+) and to_date(to_char(cc.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date(to_char(ccp.fecha_cita(+),'dd/mm/yyyy'),'dd/mm/yyyy') order by 3, 24";
al = SQLMgr.getDataList(sql);

sql= "select count(*) from (select distinct '0' as codigo, cc.codigo as qx, cc.codigo as qx_orden, ' ' as cuarto, ' ' as fechacita,' ' as hora, ' ' as fecha_nac, 0 as cod_pac, 0 as pac_id, ' ' as paciente, ' ' as cedula, ' ' as anestesia, ' ' as observacion, ' ' as clave, 0 as aseguradora, ' ' as hosp_ambul, ' ' as cirujano, ' ' as anestesiologo, ' ' as circulador, ' ' as instrumentista, ' ' as descproc, ' ' as descaseg, ' ' as cama, ' ' as fechaHora from  tbl_sal_habitacion cc where cc.quirofano = 2 and compania="+compania+")";
int nGroup = CmnMgr.getCount(sql);
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 36; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	int nLine =  al.size() - (nGroup * 7);

	int nItems = (nGroup * 7) ;
	if( nLine >0 )
	 nItems += nLine;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "cdc";
	String fileNamePrefix = "print_prograna_quirurgico";
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
	int height = 1008;
	boolean isLandscape = true;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".04");
		setDetail.addElement(".29");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".04");
		setDetail.addElement(".10");
		setDetail.addElement(".06");
		setDetail.addElement(".04");
		setDetail.addElement(".07");
		
	Vector setDetail1 = new Vector();
		setDetail1.addElement(".67");
		setDetail1.addElement(".03");
		setDetail1.addElement(".30");
			
	String groupBy = "",subGroupBy = "0",observ ="";
	int x = 0;
 	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	String title = " PROGRAMA QUIRURGICO ";
	String subtitle = ""+descFecha;
	String qx ="";
	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
	pc.setNoColumnFixWidth(setDetail1);
	pc.createTable();
		pc.setFont(7, 1,Color.white);
		pc.addCols(" ",2,1,cHeight);
		pc.addCols("HORA ",1,1,cHeight,Color.black);//addCols(String val, int align, int colSpan, float height,Color color)
		pc.setFont(7, 1);
		pc.addCols(" Los renglones con fondo negro indican HOSPITALIZACION ",0,1,cHeight);
	pc.addTable();
	pc.copyTable("detailHeader2");
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("HORA",1);
		pc.addBorderCols("OPERACION",0);
		pc.addBorderCols("CIRUJANO",0);
		pc.addBorderCols("ANESTESIOLOGO",0);
		pc.addBorderCols("INSTRUMENTISTA",0);
		pc.addBorderCols("CIRCULADOR",0);
		pc.addBorderCols("SALA",0);
		pc.addBorderCols("PACIENTE",0);
		pc.addBorderCols("CEDULA",0);
		pc.addBorderCols("FEC. NAC.",0);
		pc.addBorderCols("ASEGURADORA",0);
	pc.addTable();
	pc.copyTable("detailHeader");
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			//if (subGroupBy.equalsIgnoreCase("0")  )

			if (i != 0 && cdo.getColValue("codigo").equalsIgnoreCase("0") && !cdo.getColValue("qx").trim().equals("0"))
			{
					if(x <7)
					{
						for (int z=x; z<7; z++)
						{
							pc.setFont(6, 1);
							pc.createTable();
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
								pc.addBorderCols(" ",0,1);
							pc.addTable();
							lCounter++;
						}

				}
				x=0;
			}
			if (cdo.getColValue("codigo").equalsIgnoreCase("0"))
			{
					pc.setFont(7, 1);
					
					qx = cdo.getColValue("qx");
					pc.createTable();
						pc.addBorderCols(" "+qx,0,setDetail.size());
					pc.addTable();
					lCounter++;
					

			}
			else{


		pc.setFont(6, 0);
		pc.createTable();
			pc.addBorderCols(""+cdo.getColValue("hora"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("descProc"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cirujano"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("anestesiologo"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("instrumentista"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("circulador"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cama"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("paciente"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cedula"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fecha_nac"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("descAseg"),0,1,cHeight);

		pc.addTable();
		lCounter++;
		x++;
		}


		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
			pc.setNoColumnFixWidth(setDetail1);
			pc.addCopiedTable("detailHeader2");
	
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
					pc.setFont(7, 1);
					pc.createTable();
						pc.addBorderCols(" "+qx,0,setDetail.size());
					pc.addTable();
		}


		subGroupBy = cdo.getColValue("codigo");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{		if(x <7)
			{
				for (int z=x; z<7; z++)
				{
					pc.setFont(6, 1);
					pc.createTable();
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
						pc.addBorderCols(" ",0,1);
					pc.addTable();
					lCounter++;
				}
			}
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>