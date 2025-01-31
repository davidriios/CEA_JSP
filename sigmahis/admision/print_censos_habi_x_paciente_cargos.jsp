<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Reporte: "Censo de Habitaciones por cargo"  -->

<!-- Fecha: 12/03/2010                            -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");
String habitacion = request.getParameter("habitacion");
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (habitacion == null) habitacion     = "";
if (sala == null) sala     = "";

String appendFilter1 = "";
//--------------Par�metros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania;
  }
if (!habitacion.equals(""))
  {
   appendFilter1 += " and salh.codigo like nvl('"+habitacion+"',salh.codigo)";
  }
  if (!sala.equals(""))
  {
   appendFilter1 += " and salh.unidad_admin ="+sala;
  }

  
//-----------------------------------------------------------------------------------------------//

//------------Query para obtener datos del Censo de Pacientes Hosp. x Habitacion--------------//

sql ="select p.pac_id,p.primer_nombre||' '||p.primer_apellido as nombrePaciente,  decode(med.apellido_de_casada,null,med.primer_apellido,med.apellido_de_casada)||' '||med.primer_nombre as medico,a.codigo_paciente as cod_pac, a.secuencia as noAdmision,  decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip,  decode(salc.estado_cama,'U','EN USO','D','DISPONIBLE') estadoCama,  decode(saltipoh.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','E','ECONOMICA','T','SUITE','V','VIP') categoriaHabit, nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id)),' ')as fechaIngreso,  salc.codigo as cama, salh.codigo as habitacion, salh.descripcion as deschabit,  a.categoria, categ.descripcion as descCat, cds.descripcion as centro, ae.nombre,ae.codigo,(select  sum(decode(d.tipo_transaccion,'C',d.cantidad*(d.monto+nvl(d.recargo,0)),'D',-1*d.cantidad*(d.monto+nvl(d.recargo,0)),'H',(d.monto+nvl(d.recargo,0)))) as monto from tbl_fac_transaccion c, tbl_fac_detalle_transaccion d where d.compania = c.compania and d.pac_id = c.pac_id and d.fac_secuencia = c.admi_secuencia and c.codigo=d.fac_codigo and c.tipo_transaccion=d.tipo_transaccion and c.pac_id=a.pac_id and c.admi_secuencia=a.secuencia) as monto,(SELECT SUM (NVL (f.monto, 0)) FROM   tbl_cja_transaccion_pago e, TBL_CJA_DETALLE_PAGO f WHERE   e.codigo = f.codigo_transaccion AND f.tipo_transaccion = '2' AND f.pago_por = 'D' AND e.pac_id = a.pac_id and e.rec_status <> 'I') AS abono from tbl_adm_admision a, tbl_adm_paciente p, tbl_adm_medico med,  tbl_adm_cama_admision cama, tbl_sal_cama salc, tbl_sal_habitacion salh, tbl_sal_tipo_habitacion saltipoh, tbl_cds_centro_servicio cds, tbl_adm_categoria_admision categ, tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae  where a.pac_id = p.pac_id(+) and  (a.compania = cama.compania(+) and a.pac_id = cama.pac_id(+) and a.secuencia = cama.admision(+) and  cama.fecha_final(+) is null) and a.estado = 'A' and a.categoria in (1,5) and  (cama.compania = salc.compania(+) and cama.habitacion = salc.habitacion(+) and cama.cama = salc.codigo(+)) and (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and  nvl(aba.estado(+),'A') = 'A' and aba.prioridad(+) = 1 and aba.empresa = ae.codigo(+)) AND a.estado = 'A'  and (salc.compania = salh.compania and salc.habitacion = salh.codigo) and  (salc.compania = saltipoh.compania and salc.tipo_hab = saltipoh.codigo)  and  (a.medico = med.codigo(+)) and (cds.codigo = salh.unidad_admin) and (a.categoria = categ.codigo) "+appendFilter1+" order by salc.codigo";

al = SQLMgr.getDataList(sql);

//+" to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, "
//+" getfingreso_pactivos(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id,cama.cama) as fechaIngreso, "

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = mon;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "ADMISION";
	String subtitle = "CENSO DE PACIENTES HOSPITALIZADO POR HABITACI�N Y CARGOS ";
	String xtraSubtitle = "DEL D�A: "+fecha;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
	    dHeader.addElement(".08");
		dHeader.addElement(".18"); //
		dHeader.addElement(".07");
		dHeader.addElement(".16");
	//	dHeader.addElement(".11");
		dHeader.addElement(".22");
		dHeader.addElement(".08");
		dHeader.addElement(".21");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
	footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelizaci�n al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);

		pc.addBorderCols("CAMA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID/ADM",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);
//		pc.addBorderCols("TIPO HAB.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ASEGURADORA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F.INGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CARGO - ABONO ",0,1,cHeight * 2,Color.lightGray);


	pc.setTableHeader(2);

	String groupBy = "";
	int pxs = 0, pxcath = 0;
	for (int i=0; i<al.size(); i++)
	{
      cdo = (CommonDataObject) al.get(i);

	    ////Inicio --- Agrupamiento por Habitaci�n
////      if(!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("habitacion")+" ] "))
//	//    {
//		  if (i != 0)
//		   {//i-1
//		     pc.setFont(8, 1,Color.red);
//			 pc.addCols(" ",0,dHeader.size(),cHeight);
//		   }//i-1
//		   pc.setFont(8, 1,Color.blue);
//		   pc.addCols("HABITACI�N:",0,1,cHeight);
//		   pc.addCols("[ "+cdo.getColValue("habitacion")+" ] ",0,dHeader.size(),cHeight);
//		}//Fin --- Agrupamiento por Habitaci�n

		pc.setFont(7, 0);
		pc.addCols(" "+cdo.getColValue("cama"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("pac_id")+" - "+cdo.getColValue("noAdmision"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("medico"),0,1,cHeight);
	//	pc.addCols(" "+cdo.getColValue("categoriaHabit"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombre"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
		pc.addCols("   "+cdo.getColValue("monto")+"    -    "+cdo.getColValue("abono"),0,1,cHeight);
		pxcath++;

//	     groupBy  = "[ "+cdo.getColValue("habitacion")+" ] ";
	  }//for i

	if (al.size() == 0)
	{
	   pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
	  pc.setFont(8, 1,Color.black);
	  pc.addCols(" ",0,dHeader.size(),cHeight);
      pc.addCols(" GRAN TOTAL DE PACIENTES:   "+ al.size(),0,dHeader.size(),Color.lightGray);
	}
	 pc.addTable();
	 pc.close();
	response.sendRedirect(redirectFile);
}//get
%>


