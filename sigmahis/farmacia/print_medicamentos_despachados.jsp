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
CommonDataObject cdo1  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String noOrden = request.getParameter("noOrden");
String codigoOrdenMed = request.getParameter("codigo_orden_med");
String fg = request.getParameter("fg");
String categoriaAdm = request.getParameter("categoria_adm");
String printOF = request.getParameter("print_of")==null?"":request.getParameter("print_of");
String id = request.getParameter("id")==null?"":request.getParameter("id");
String mode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
String fDesde = request.getParameter("fDesde") == null ? "" : request.getParameter("fDesde");
String fHasta = request.getParameter("fHasta") == null ? "" : request.getParameter("fHasta");
String idFar = request.getParameter("idFar") == null ? "" : request.getParameter("idFar");
boolean isLandscape = true;
if ( desc == null ) desc = "";
if ( noOrden == null ) noOrden = "";
if ( codigoOrdenMed == null ) codigoOrdenMed = "";
if ( fg == null ) fg = "";
if ( categoriaAdm == null ) categoriaAdm = "";
if ( idFar == null ) idFar = "";

String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (appendFilter == null) appendFilter = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape,nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_ADD_NO_ORDEN'),'N') as addOrden ,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad,nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'FAR_GENERAR_TRX_POS'),'N') as v_far_generar_pos from dual ");


		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdop.addColValue("is_landscape",""+isLandscape);
		}
sql.append(" select f.cantidad, a.concentracion, to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica,  nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') FECHA_FIN,  a.nombre as medicamento, f.codigo_articulo||' - '||f.descripcion as desp_med_nombre, a.dosis,  (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia,   a.frecuencia as descfrecuencia, a.observacion, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'--') usuario_omit, '['||nvl(f.usuario_modificacion,f.usuario_creacion)||'] - '||(select b.name from tbl_sec_users b where b.user_name = nvl(f.usuario_modificacion,f.usuario_creacion)) as usuario_desp, '['||a.usuario_creacion||'] - '||(select b.name from tbl_sec_users b where b.user_name = a.usuario_creacion) as usuario_crea_orden, to_char(decode(f.estado,'A',f.fecha_modificacion,f.fecha_creacion),'dd/mm/yyyy hh12:mi am') as fecha_crea, a.codigo ,a.estado_orden as status ,nvl(f.observacion_ap,f.observacion) as observacion, ' ' as observacion_ap,a.dosis_desc,a.cantidad as cant,f.precio_venta_pos  as precioVentaPos from tbl_sal_detalle_orden_med a, tbl_int_orden_farmacia f where a.pac_id = ");
sql.append(pacId);
sql.append(" and a.secuencia = ");
sql.append(noAdmision);
sql.append(" and a.tipo_orden = 2 ");


if (!fDesde.equals("") && !fHasta.equals("")) {
	sql.append(" and f.fecha_creacion between ");
	sql.append(" to_date('");
	sql.append(fDesde);
	sql.append("','dd/mm/yyyy hh12:mi:ss am')");
	sql.append(" and ");
	sql.append(" to_date('");
	sql.append(fHasta);
	sql.append("','dd/mm/yyyy hh12:mi:ss am')");
}


//if(!fg.trim().equals("CS")){sql.append(" and nvl(a.omitir_orden,'N')='N' ");if (printOF.trim().equals(""))sql.append("  and a.estado_orden='A' ");}

if ( !codigoOrdenMed.equals("") ) {
	sql.append(" and a.codigo_orden_med = ");
	sql.append(codigoOrdenMed);
}

if (!printOF.trim().equals("")) {

	//sql.append(" and to_date(to_char(f.fecha_creacion,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = (select max (to_date(to_char(ff.fecha_creacion,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am')) from tbl_int_orden_farmacia ff where  a.pac_id = ff.pac_id and a.secuencia = ff.admision and a.tipo_orden = ff.tipo_orden and a.orden_med = ff.orden_med and a.codigo = ff.codigo and ff.other1 = 1 and ff.fg = 'ME' /*and ff.seguir_despachando = 'S'*/) ");
	if (!id.trim().equals("")) {
		sql.append(" and f.id >= ");
		sql.append(id);
	}
	if (!idFar.trim().equals("")) {
		sql.append(" and f.id in(");
		sql.append(idFar.replace("~",","));
		sql.append(" ) ");
	}

}

sql.append(" and a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1");
if (fg.equalsIgnoreCase("BM")) sql.append(" and f.fg = 'BM'");
else sql.append(" and f.fg = 'ME'");
sql.append(" and f.estado in('A','R') order by f.fecha_creacion desc ");
System.out.println("------------------fg="+fg+" > "+sql);
al = SQLMgr.getDataList(sql.toString());

CommonDataObject cdoP = new CommonDataObject();
boolean showDiagWeight = false;

			StringBuffer sbSql = new StringBuffer();
			sbSql.append("select (select '['||codigo||'] '||nvl(observacion,nombre) from tbl_cds_diagnostico where codigo = (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and admision = ");
			sbSql.append(noAdmision);
			sbSql.append(" and tipo = 'I' and orden_diag = 1 and rownum = 1)) diag_desc, nvl ( (select peso from ( select * from (select peso, max(fecha_nota) from tbl_sal_resultado_nota where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and peso <> '0' group by peso order by max(fecha_nota) desc ) where rownum = 1  )) , decode (");
			sbSql.append(categoriaAdm);
			sbSql.append(" , 2, ( select resultado from (select * from (select resultado, max(fecha_signo) from tbl_sal_detalle_signo z where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and signo_vital = 8 group by resultado order by max(fecha_signo) desc) where rownum = 1 )), 'N/A')) as peso");

sbSql.append(", (select join(cursor( (select  (select other3 from tbl_fac_trx where doc_id=f.doc_id ) as factura from tbl_sal_detalle_orden_med a, tbl_int_orden_farmacia f where a.pac_id = ");
sbSql.append(pacId);
sbSql.append("and a.secuencia = ");
sbSql.append(noAdmision);

sbSql.append(" and a.tipo_orden = 2 ");
 if ( !codigoOrdenMed.equals("") ) {
sbSql.append(" and a.codigo_orden_med = ");
sbSql.append(codigoOrdenMed);}
if (fg.equalsIgnoreCase("BM")) sql.append(" and f.fg = 'BM'");
else sql.append(" and f.fg = 'ME'");

sbSql.append(" and a.pac_id = f.pac_id and a.secuencia =f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1 and f.estado in('A','R')  ) ),';') from dual ) ");



		sbSql.append(" as factura from dual ");





		 CommonDataObject cdoPacXtra = SQLMgr.getData(sbSql.toString());

		 if (cdoPacXtra == null) cdoPacXtra = new CommonDataObject();

		 sql = new StringBuffer();
		 ArrayList alIns = new ArrayList();
		 sql.append("select d.descripcion, decode(d.tipo_transaccion,'D', -1*d.cantidad, d.cantidad) cantidad, substr(fac.descripcion, instr(fac.descripcion,'-',1)+1) as cod_ord, to_char(d.fecha_hora_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha, decode(d.tipo_transaccion,'D','Devolución','Cargo') tipo_transaccion_desc, d.tipo_transaccion from tbl_fac_detalle_transaccion d, tbl_fac_transaccion fac  where d.ref_type = 'FARINSUMOS' and d.compania = fac.compania and d.fac_codigo = fac.codigo and d.fac_secuencia = fac.admi_secuencia and d.pac_id = fac.pac_id and d.tipo_transaccion = fac.tipo_transaccion and d.compania = ");
		sql.append(_comp.getCodigo());
		sql.append(" and d.fac_secuencia = ");
		sql.append(noAdmision);
		sql.append(" and d.pac_id = ");
		sql.append(pacId);

		if (!mode.trim().equals("recibir") && !id.trim().equals("")) {
			sql.append(" and d.ref_id = '");
			sql.append(id);
		sql.append("' ");
		}

		sql.append(" order  by d.fecha_hora_creacion desc ");

		if(!codigoOrdenMed.trim().equals("")){
	alIns = SQLMgr.getDataList("select aa.* from ("+sql.toString()+") aa where substr(aa.cod_ord, 0, instr(aa.cod_ord,'-',1)-1) = "+codigoOrdenMed+" order by aa.descripcion, aa.fecha");}

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
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FARMACIA";
	String subtitle = "MEDICAMENTOS DESPACHADOS";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();

		dHeader.addElement(".40"); // Med
		dHeader.addElement(".10"); // Via
		dHeader.addElement(".10"); // Qty
		dHeader.addElement(".15"); // Fecha Desp.
		dHeader.addElement(".25"); // Usuario

			 PdfCreator pc=null;
		 boolean isUnifiedExp=false;
			 pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		 if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);

				if (cdoPacXtra.getColValue("diag_desc","N/A")!=null){
						pc.addCols("Diagnóstico: "+cdoPacXtra.getColValue("diag_desc","N/A"),0,dHeader.size());
						pc.addCols("Peso: "+cdoPacXtra.getColValue("peso","N/A"),0,dHeader.size());
				}

		 if (paramCdo.getColValue("addOrden","N").equalsIgnoreCase("S"))
		 {
			 if (!codigoOrdenMed.equals(""))
			 pc.addCols("NO. ORDEN MEDICA : "+codigoOrdenMed,1,2);
			 else  pc.addCols(" ",1,2);
			pc.addCols("NO. FACTURA(S) : "+cdoPacXtra.getColValue("factura"),1,3);

		 }

		pc.addBorderCols("MEDICAMENTOS",0,1);
		pc.addBorderCols("VIA",0,1);
		pc.addBorderCols("CANTIDAD",1,1);
		pc.addBorderCols("PEDIDO POR",1,1);
		pc.addBorderCols("DESPACHADO POR",1,1);

	pc.setTableHeader(2);
	pc.setVAlignment(0);

	String forma = "";
	String observ = "";
		String gFechaCrea = "";
		int totByG = 0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


				if (!gFechaCrea.equalsIgnoreCase(cdo.getColValue("fecha_crea"))){
					pc.setFont(10,1,Color.black);
					if (i != 0){
						pc.addCols("Total", 2 ,2);
						pc.addCols(""+totByG, 1,1);
						pc.addCols("", 0,2);
						totByG = 0;
					}
					pc.addCols("Despacho "+cdo.getColValue("fecha_crea"), 0 ,dHeader.size(), Color.lightGray);
				}

				pc.setFont(8,0);
				pc.addCols("[ MEDICAMENTO SOLICITADO: ]"+cdo.getColValue("medicamento"),0,3);
		pc.setFont(8,0,Color.blue);
		pc.addCols(" OBSER:"+cdo.getColValue("observacion")+" - "+cdo.getColValue("observacion_ap"), 0 ,2);
		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("desp_med_nombre"),0,1);
				pc.addCols(cdo.getColValue("descvia"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("usuario_crea_orden"),1,1);
		pc.addCols(cdo.getColValue("usuario_desp"),1,1);
		if(expVersion.equals("3")){
		pc.setFont(8,0);
		pc.addCols("DOSIS:"+cdo.getColValue("dosis_desc"),0,3);
		if(paramCdo.getColValue("addCantidad").trim().equals("S")){pc.setFont(8,0,Color.red);pc.addCols("CANTIDAD SOLICITADA:"+cdo.getColValue("cant"),0,2);}
		else pc.addCols(" ",0,2);

			 }
		 else{pc.setFont(8,0,Color.red);if(paramCdo.getColValue("addCantidad").trim().equals("S"))

		 pc.addCols("CANTIDAD SOLICITADA:"+cdo.getColValue("cant")+" "+(paramCdo.getColValue("v_far_generar_pos","S").trim().equals("S")?" ":" Precio:  "+cdo.getColValue("precioVentaPos")),0,5);


		 }
				totByG += Integer.parseInt(cdo.getColValue("cantidad","0"));
				gFechaCrea = cdo.getColValue("fecha_crea");
		pc.setFont(8,0);

	}//for

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else {
			pc.setFont(9,1);
			pc.addCols("Total", 2 ,2);
			pc.addCols(""+totByG, 1,1);
			pc.addCols("", 0,2);
		}

		if (alIns.size() > 0){
					pc.addBorderCols(" ",0,dHeader.size(),0.5f,0f,0f,0f);

					pc.setFont(8,1);
					pc.addCols("INSUMOS",0,dHeader.size(), Color.lightGray);

					String gItem = "";
					for (int i=0; i<alIns.size(); i++){
						CommonDataObject cdo = (CommonDataObject) alIns.get(i);

						int cantidad = Integer.parseInt(cdo.getColValue("cantidad"));

						 if (!gItem.equals(cdo.getColValue("descripcion"))){
						 if (i != 0) pc.addCols(" ",0,dHeader.size());
						 pc.setFont(8,1);
							pc.addBorderCols(cdo.getColValue("descripcion"),0,dHeader.size(),0.5f,0f,0f,0f);
							pc.addBorderCols("FECHA",1,2);
							pc.addBorderCols("CANTIDAD",1,1);
							pc.addBorderCols("TIPO TRANX",0,1);
							pc.addBorderCols("",1,2);
						}


						pc.setFont(8,0);
						pc.addCols(cdo.getColValue("fecha"),1,2);
						if(cantidad<1) {
						pc.setFont(8,1,Color.red);
							pc.addCols(cdo.getColValue("cantidad"),1,1);
							pc.setFont(8,0);
						}
						else pc.addCols(cdo.getColValue("cantidad"),1,1);
						pc.addCols(cdo.getColValue("tipo_transaccion_desc"),0,1);
						pc.addCols("",1,2);

						gItem = cdo.getColValue("descripcion");
					}
			}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>