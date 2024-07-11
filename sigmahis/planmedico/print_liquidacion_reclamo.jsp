<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String compania =(String) session.getAttribute("_companyId");
String userName =(String) session.getAttribute("_userName");

String codigo = request.getParameter("codigo")==null?"":request.getParameter("codigo");

Exception up = new Exception("No pudimos encontrar un código válido!!");
if (codigo.trim().equals("")) throw up;

StringBuffer sbSql = new StringBuffer();

sbSql.append("select l.descripcion as observacion, l.nombre_cliente nombreCliente, l.cedula_cliente cedulaPasaporte, l.empresa tipo_empresa, l.num_factura no_factura, get_age(l.admi_fecha_nacimiento,trunc(sysdate),'d') as edad, l.admi_codigo_paciente as codigo_paciente, to_char(l.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,  l.direccion_residencial, l.categoria, l.poliza, l.dias_hospitalizados, l.no_aprob, (select nvl(a.reg_medico,a.codigo) from tbl_adm_medico a where a.codigo = l.med_codigo) as medico, l.icd9, nvl(l.total,0.00) total,(select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = l.med_codigo ) medico_nombre, to_char(l.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, to_char(l.fecha_egreso,'dd/mm/yyyy') fecha_egreso, decode(l.pac_id,0,(select decode(sexo,'F','Femenino','Masculino') from vw_pm_cliente where codigo = admi_codigo_paciente ), (select decode(sexo,'F','Femenino','Masculino') from tbl_adm_paciente where pac_id = l.pac_id )) as sexo, decode(l.status,'A','Aprobado','Pendiente') status_dsp, nvl(l.sub_total,0.00) sub_total, nvl(l.monto_paciente,0.00) as monto_pcte, nvl(l.copago,0.00) copago, nvl(l.descuento,0.00) descuento, l.tipo_transaccion, decode(l.reembolso,'N','NO','SI') reembolso, decode(l.tipo_transaccion,'F','Factura','Nota de Crédito') as tipo_trx_dsp, (select nombre  from tbl_pm_centros_atencion where id = l.empresa) tipo_empresa_dsp, (select descripcion from tbl_adm_categoria_admision where codigo = l.categoria) categoria_dsp from tbl_pm_liquidacion_reclamo l where l.codigo = ");
sbSql.append(codigo);

CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append(" select d.reclamo_seq, d.descripcion,  (select descripcion from tbl_cds_centro_servicio where codigo = d.centro_servicio) centro_servicio, d.monto, d.cantidad,(select descripcion from tbl_cds_tipo_servicio where codigo=d.tipo_cargo) tipo_cargo, d.codigo_precio, nvl(d.monto,0)*nvl(d.cantidad,0) total_x_fila, d.medico medicoOrEmpre, decode(d.honorario_por,'M',(select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = d.medico),(select nombre from tbl_adm_empresa where codigo= d.empresa)) nombreMedicoOrEmpre , d.seq_trx, d.honorario_por, d.medico, d.empresa, decode(d.honorario_por,'M','N','Y') pagar_sociedad from tbl_pm_det_liq_reclamo d where d.compania = ");
sbSql.append(compania);
sbSql.append(" and d.secuencia = ");
sbSql.append(codigo);
sbSql.append(" order by 1 ");
   
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.id, a.codigo_reclamo, a.diagnostico, a.tipo, decode(a.tipo,'I','INGRESO','SALIDA') tipo_desc, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.prioridad, (select coalesce(observacion,nombre) from tbl_cds_diagnostico where codigo=a.diagnostico) as diagnosticoDesc from tbl_pm_liquidacion_diag a where a.codigo_reclamo=");
sbSql.append(codigo);

ArrayList alD = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.id, a.tipo, a.codigo_reclamo, to_char(a.fecha, 'dd/mm/yyyy hh12:mi am') fecha, substr(nota, 0, 90) || (case when length(nota) > 90 then '...' else '' end) nota, a.usuario, a.estado, (select name from tbl_sec_users u where u.user_name = a.usuario) user_name, decode(a.estado, 'A', 'Activo', 'I', 'Inactivo', a.estado) estado_desc from tbl_pm_liquidacion_notas a where a.codigo_reclamo = ");
sbSql.append(codigo);
sbSql.append(" and tipo = 'CLIENTE'");
sbSql.append(" order by fecha desc");

ArrayList alN = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")){

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+System.currentTimeMillis()+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLAN MEDICO";
	String subtitle = "LIQUIDACION DE RECLAMO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float ctblHeight = 0.0f;//current table height
	float stblHeight = ((height - (2 * (topMargin + bottomMargin))) / 2);//subtable height

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".037");
		dHeader.addElement(".04");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".153");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
        
     Vector tblDet = new Vector(); 
        tblDet.addElement("0.07");
        tblDet.addElement("0.07");
        tblDet.addElement("0.20");
        tblDet.addElement("0.15");
        tblDet.addElement("0.15");
        tblDet.addElement("0.20");
        tblDet.addElement("0.04");
        tblDet.addElement("0.06");
        tblDet.addElement("0.06");
       
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Código:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(codigo,0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Tipo Trx.",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("tipo_trx_dsp"),0,4,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Emprsa:",0,2);
		pc.addCols(cdoHeader.getColValue("tipo_empresa_dsp"),0,5);
		pc.addCols("Categoría:",0,1);
		pc.addCols(cdoHeader.getColValue("categoria_dsp"),0,4);
        
        pc.addCols("No. Doc.:",0,2);
		pc.addCols(cdoHeader.getColValue("no_factura"),0,5);
		pc.addCols("Beneficiario:",0,1);
		pc.addCols(cdoHeader.getColValue("cedulaPasaporte")+" - "+cdoHeader.getColValue("nombreCliente"),0,4);

		pc.addCols("Reembolsable",0,2);
		pc.addCols(cdoHeader.getColValue("reembolso"),0,5);
		pc.addCols("F.Nacimiento:",0,1);
		pc.addCols(cdoHeader.getColValue("fecha_nacimiento"),0,4);

		pc.addCols("Edad:",0,2);
		pc.addCols(cdoHeader.getColValue("edad"),0,5);
		pc.addCols("Sexo.:",0,1);
		pc.addCols(cdoHeader.getColValue("sexo"),0,4);
        
        pc.addCols("F.Ingreso:",0,2);
		pc.addCols(cdoHeader.getColValue("fecha_ingreso"),0,5);
		pc.addCols("F.Egreso:",0,1);
		pc.addCols(cdoHeader.getColValue("fecha_egreso"),0,4);
        
        pc.addCols("Dirección:",0,2);
		pc.addCols(cdoHeader.getColValue("direccion_residencial"),0,5);
		pc.addCols("Póliza:",0,1);
		pc.addCols(cdoHeader.getColValue("poliza"),0,4);
        
        pc.addCols("Días Hosp.:",0,2);
		pc.addCols(cdoHeader.getColValue("dias_hospitalizados"),0,5);
		pc.addCols("No. Reclamo:",0,1);
		pc.addCols(cdoHeader.getColValue("no_aprob"),0,4);
        
        pc.addCols("Méd. Cabecera:",0,2);
		pc.addCols(cdoHeader.getColValue("medico")+" - "+cdoHeader.getColValue("medico_nombre"),0,5);
		pc.addCols("Estado:",0,1);
		pc.addCols(cdoHeader.getColValue("status_dsp"),0,4);
        
        pc.addCols("Observación:",0,2);
		pc.addCols(cdoHeader.getColValue("observacion"),0,10);
        
        pc.addCols(" ",1,12);
	
        pc.setTableHeader(11);


     pc.setNoColumnFixWidth(tblDet);
     pc.createTable("det");
        
        pc.setFont(headerFontSize,1);
		pc.addBorderCols("ID",1,1);
		pc.addBorderCols("Código",1,1);
		pc.addBorderCols("Descripción",0,1);
		pc.addBorderCols("Centro Servicio",0,1);
		pc.addBorderCols("Tipo Servicio",0,1);
		pc.addBorderCols("Médico/Sociedad",0,1);
        
		pc.addBorderCols("Cant",1,1);
		pc.addBorderCols("Monto",2,1);
		pc.addBorderCols("Total",2,1);
        
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("reclamo_seq"),1,1);
		pc.addCols(cdo.getColValue("codigo_precio"),1,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("centro_servicio"),0,1);
		pc.addCols(cdo.getColValue("tipo_cargo"),0,1);
		pc.addCols(cdo.getColValue("nombreMedicoOrEmpre"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);

		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("total_x_fila")),2,1);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
    
      pc.addCols("Sub.Total:",2,tblDet.size()-1);
      pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("sub_total")),2,1);
      
      pc.addCols("Copago:",2,tblDet.size()-1);
      pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("Copago")),2,1);
      
      pc.addCols("M.Pcte:",2,tblDet.size()-1);
      pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("monto_pcte")),2,1);
      
      pc.addCols("Descuento:",2,tblDet.size()-1);
      pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("descuento")),2,1);
      
      pc.addCols("Total:",2,tblDet.size()-1);
      pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("total")),2,1);
    
      pc.useTable("main");
      pc.addTableToCols("det",0,dHeader.size());
    }
	
    pc.flushTableBody(true);
    pc.addNewPage();
    
    
    //diagnosticos y notas
    pc.setNoColumnFixWidth(tblDet);
     pc.createTable("diag");
        
        pc.addCols(" ",0,tblDet.size());
        pc.addCols("DIAGNOSTICOS",0,tblDet.size(),Color.lightGray);
        pc.setFont(headerFontSize,1);
		pc.addBorderCols("Código",1,1);
		pc.addBorderCols("Descripción",0,6);
		pc.addBorderCols("Priorid.",1,1);
		pc.addBorderCols("Tipo",1,1);
        
        for (int d=0; d<alD.size(); d++){
            CommonDataObject cdo = (CommonDataObject) alD.get(d);
            pc.setFont(headerFontSize,0);
            pc.addCols(cdo.getColValue("diagnostico"),1,1);
            pc.addCols(cdo.getColValue("diagnosticoDesc"),0,6);
            pc.addCols(cdo.getColValue("prioridad"),1,1);
            pc.addCols(cdo.getColValue("tipo_desc"),1,1);
        }
        
        pc.useTable("main");
      pc.addTableToCols("diag",0,dHeader.size());
      
      pc.addCols(" ",0,dHeader.size());
      pc.addCols("NOTAS",0,dHeader.size(),Color.lightGray);
      
      pc.setNoColumnFixWidth(tblDet);
     pc.createTable("notas");
        
        pc.setFont(headerFontSize,1);
		pc.addBorderCols("Fecha",1,2);
		pc.addBorderCols("Usuario",1,1);
		pc.addBorderCols("Descripción",0,5);
		pc.addBorderCols("Estado",1,1);
        
        for (int n=0; n<alN.size(); n++){
            CommonDataObject cdo = (CommonDataObject) alN.get(n);
            pc.setFont(headerFontSize,0);
            pc.addCols(cdo.getColValue("fecha"),1,2);
            pc.addCols(cdo.getColValue("usuario"),1,1);
            pc.addCols(cdo.getColValue("nota"),0,5);
            pc.addCols(cdo.getColValue("estado_desc"),1,1);
        }
        
        pc.useTable("main");
      pc.addTableToCols("notas",0,dHeader.size());
    
    pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>