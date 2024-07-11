<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTS = new ArrayList();
ArrayList alDev = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String sql = "",desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String fg = request.getParameter("fg");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (codigo==null) codigo = "";

if(!codigo.trim().equals(""))
{
	if(fg.trim().equals("consulta"))
	{
		appendFilter+=" and  det.nota_ajuste = "+codigo;
	}
	else if (fg.trim().equals("paciente"))	appendFilter+=" and  f.codigo = "+codigo;
	else 	appendFilter+=" and  n.codigo = "+codigo;
}

if(fg.trim().equals("")){
sql="select decode(det.tipo,'C', decode(c.descripcion,'HONORARIOS',null,c.descripcion),'E',(select nombre from tbl_adm_empresa where codigo = det.empresa),'H',m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido,'P','CO-PAGO', 'M','PERDIEM') desccentro,decode(det.tipo,'C',to_char(det.centro),'E',to_char(det.empresa),'H',nvl(m.reg_medico,det.medico)) as v_codigo,det.lado_mov,decode(det.lado_mov,'D','DEBITO','C','CREDITO') lado_m, decode(det.lado_mov,'D',sum(nvl(det.monto,0)),'C',sum(nvl(det.monto,0))) monto,n.codigo,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_creacion),n.usuario_creacion) as usuario_creacion, to_char(n.fecha,'dd/mm/yyyy')as fecha,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_creacion),n.usuario_creacion) as usuario_aprob, to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am') as fecha_aprob, t.descripcion as nombreajuste,n.recibo, n.total, decode(c.descripcion,'HONORARIOS',null,c.descripcion) descripcion, m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido as nombremedico, f.facturar_a, nvl(decode(n.tipo_doc,'F',nvl((select nombre_paciente from vw_adm_paciente where pac_id = nvl(det.pac_id,f.pac_id)),f.nombre_cliente),'R',(select nvl(nombre,(select nombre_paciente from vw_adm_paciente where pac_id = nvl(ctp.pac_id,nvl(det.pac_id,f.pac_id)))) from tbl_cja_transaccion_pago ctp where  recibo = n.recibo and compania = n.compania )),'S/N') as  nombrepaciente, e.nombre as nombreempresa, det.secuencia, det.tipo, decode(det.centro,0,null,det.centro) as  nombrecentro, nvl(m.reg_medico,det.medico) as medico, det.factura, decode(det.empresa,0,null,det.empresa) as cod_empresa,n.explicacion,n.referencia from  tbl_fac_det_nota_ajuste det, tbl_cds_centro_servicio c, tbl_adm_medico m,tbl_fac_factura f,tbl_fac_nota_ajuste n,tbl_fac_tipo_ajuste t, tbl_adm_empresa e where  n.compania = "+compania+appendFilter+" and det.centro=c.codigo(+) and det.medico=m.codigo(+) and det.compania=f.compania(+) and det.factura=f.codigo(+) and det.compania=n.compania and det.nota_ajuste=n.codigo and n.compania =t.compania and n.tipo_ajuste=t.codigo and ((f.cod_empresa=e.codigo(+)) ) group by n.tipo_doc,det.descripcion ,decode(det.tipo,'C',to_char(det.centro),'E',to_char(det.empresa),'H',nvl(m.reg_medico,det.medico)),det.lado_mov, n.codigo, n.usuario_creacion, to_char(n.fecha,'dd/mm/yyyy'),  n.usuario_aprob, to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am'), to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am'), t.descripcion,n.recibo, n.total, decode(c.descripcion,'HONORARIOS',null,c.descripcion), m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido , f.facturar_a, det.pac_id,f.pac_id, n.recibo,n.compania,e.nombre, det.secuencia, det.tipo, decode(det.centro,0,null,det.centro), nvl(m.reg_medico,det.medico), det.factura, decode(det.empresa,0,null,det.empresa),n.explicacion,n.referencia,det.empresa,f.nombre_cliente order by n.codigo, det.secuencia asc ";
}

else if(fg.trim().equals("ajust")){
sql="select det.descripcion as desccentro,decode(det.tipo,'C',to_char(det.centro),'E',to_char(det.empresa),'H',nvl(m.reg_medico,det.medico))as v_codigo,det.lado_mov,decode(det.lado_mov,'D','DEBITO','C','CREDITO') lado_m, decode(det.lado_mov,'D',sum(nvl(det.monto,0)),'C',sum(nvl(det.monto,0))) monto,n.codigo,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_creacion),n.usuario_creacion) as usuario_creacion, to_char(n.fecha,'dd/mm/yyyy')as fecha,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_aprob),n.usuario_aprob) as usuario_aprob, to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am') as fecha_aprob, t.descripcion as nombreajuste,n.recibo, n.total, decode(c.descripcion,'HONORARIOS',null,c.descripcion) descripcion, m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido as nombremedico, f.facturar_a, nvl(decode(n.tipo_doc,'F',nvl((select nombre_paciente from vw_adm_paciente where pac_id = nvl(det.pac_id,f.pac_id)),f.nombre_cliente),'R',(select nvl(nombre,(select nombre_paciente from vw_adm_paciente where pac_id = nvl(ctp.pac_id,nvl(det.pac_id,f.pac_id)))) from tbl_cja_transaccion_pago ctp where  ctp.recibo = n.recibo and compania = det.compania )),'S/N') as nombrepaciente, e.nombre as nombreempresa, det.secuencia, det.tipo, decode(det.centro,0,null,det.centro) as  nombrecentro, nvl(m.reg_medico,det.medico) as medico, det.factura, decode(det.empresa,0,null,det.empresa) as cod_empresa,n.explicacion,n.referencia,/*(select descripcion from tbl_cds_centro_servicio where codigo =n.cds)*/ '' descCentroTramite from  tbl_con_adjustment_det det, tbl_cds_centro_servicio c, tbl_adm_medico m,tbl_fac_factura f,tbl_con_adjustment n,tbl_fac_tipo_ajuste t, tbl_adm_empresa e where n.compania = "+compania+appendFilter+" and det.centro=c.codigo(+) and det.medico=m.codigo(+) and det.compania=f.compania(+) and det.factura=f.codigo(+) and det.compania=n.compania and det.nota_ajuste=n.codigo and n.compania =t.compania and n.tipo_ajuste=t.codigo and f.cod_empresa=e.codigo(+) group by n.codigo, n.usuario_creacion,n.fecha, t.descripcion,n.recibo, n.total, c.descripcion, m.primer_nombre , m.primer_apellido,m.segundo_apellido, f.facturar_a, e.nombre,det.secuencia,det.tipo,det.centro,nvl(m.reg_medico,det.medico),det.factura,n.explicacion,det.lado_mov,det.empresa,n.referencia,det.descripcion,det.pac_id,n.usuario_creacion, to_char(n.fecha,'dd/mm/yyyy'),  n.usuario_aprob, to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am'), to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am'), n.tipo_doc, det.pac_id,f.pac_id,det.compania,f.nombre_cliente order by n.codigo, det.secuencia asc ";
}

else if(fg.trim().equals("paciente")){
sql="select det.descripcion as desccentro,decode(det.tipo,'C',to_char(det.centro),'E',to_char(det.empresa),'H',nvl(m.reg_medico,det.medico))as v_codigo,det.lado_mov,decode(det.lado_mov,'D','DEBITO','C','CREDITO') lado_m, decode(det.lado_mov,'D',sum(nvl(det.monto,0)),'C',sum(nvl(det.monto,0))) monto,n.codigo,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_creacion),n.usuario_creacion) as usuario_creacion, to_char(n.fecha,'dd/mm/yyyy')as fecha,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=n.usuario_aprob),n.usuario_aprob) as usuario_aprob, to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am') as fecha_aprob, t.descripcion as nombreajuste,n.recibo, n.total, decode(c.descripcion,'HONORARIOS',null,c.descripcion) descripcion, m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido as nombremedico, f.facturar_a,  nvl(decode(n.tipo_doc,'F',nvl((select nombre_paciente from vw_adm_paciente where pac_id = nvl(det.pac_id,f.pac_id)),f.nombre_cliente),'R',(select nvl(nombre,(select nombre_paciente from vw_adm_paciente where pac_id = nvl(ctp.pac_id,nvl(n.pac_id,f.pac_id)))) from tbl_cja_transaccion_pago ctp where  recibo = n.recibo and compania = n.compania )),'S/N')as  nombrepaciente, e.nombre as nombreempresa, det.secuencia, det.tipo, decode(det.centro,0,null,det.centro) as  nombrecentro, nvl(m.reg_medico,det.medico) as medico, det.factura, decode(det.empresa,0,null,det.empresa) as cod_empresa,n.explicacion,n.referencia from  vw_con_adjustment_det det, tbl_cds_centro_servicio c, tbl_adm_medico m,tbl_fac_factura f,vw_con_adjustment n,tbl_fac_tipo_ajuste t, tbl_adm_empresa e where  f.compania = "+compania+appendFilter+" and det.centro=c.codigo(+) and det.medico=m.codigo(+) and det.compania=f.compania(+) and det.factura=f.codigo(+) and det.compania=n.compania and det.nota_ajuste=n.codigo and det.data_refer = n.data_refer and n.compania =t.compania and n.tipo_ajuste=t.codigo and f.cod_empresa=e.codigo(+) group by n.codigo, n.usuario_creacion,n.fecha, t.descripcion,n.recibo, n.total, c.descripcion, m.primer_nombre , m.primer_apellido,m.segundo_apellido, f.facturar_a, e.nombre,det.secuencia,det.tipo, det.centro,nvl(m.reg_medico,det.medico),det.factura,n.explicacion,det.lado_mov,det.empresa,n.referencia,det.descripcion,f.pac_id, n.usuario_creacion, to_char(n.fecha,'dd/mm/yyyy'),  n.usuario_aprob, to_char(n.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am'), to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am'),f.nombre_cliente order by n.codigo, det.secuencia asc ";
}

else if(fg.trim().equals("consulta")){
sql="select c.descripcion as desccentro,decode(c.tipo,'C',to_char(c.centro),'E',to_char(c.empresa),'H',nvl(m.reg_medico,c.medico))as v_codigo,c.lado_mov,decode(c.lado_mov,'D','DEBITO','C','CREDITO') lado_m, decode(c.lado_mov,'D',sum(nvl(c.monto,0)),'C',sum(nvl(c.monto,0))) monto,c.nota_ajuste as codigo,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=c.usuario_creacion),c.usuario_creacion) as usuario_creacion, to_char(c.fecha,'dd/mm/yyyy')as fecha,  nvl((select name||' ('||user_name||') ' from tbl_sec_users where user_name=c.usuario_aprob),c.usuario_aprob) as usuario_aprob, to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(c.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am') as fecha_aprob, t.descripcion as nombreajuste,c.recibo, c.total, decode(cs.descripcion,'HONORARIOS',null,cs.descripcion) descripcion, m.primer_nombre||' '||m.primer_apellido||' '|| m.segundo_apellido as nombremedico, f.facturar_a,   nvl(decode(c.tipo_doc,'F',nvl((select nombre_paciente from vw_adm_paciente where pac_id = nvl(c.pac_id,f.pac_id)),f.nombre_cliente),'R',(select nvl(nombre,(select nombre_paciente from vw_adm_paciente where pac_id = nvl(ctp.pac_id,nvl(c.pac_id,f.pac_id)))) from tbl_cja_transaccion_pago ctp where  ctp.recibo = c.recibo and compania = c.compania )),'S/N') as  nombrepaciente, e.nombre as nombreempresa, c.secuencia, c.tipo, decode(c.centro,0,null,c.centro) as  nombrecentro, nvl(m.reg_medico,c.medico) as medico, c.factura, decode(c.empresa,0,null,c.empresa) as cod_empresa,c.explicacion,c.referencia,/*(select descripcion from tbl_cds_centro_servicio where codigo =c.cds)*/'' descCentroTramite from  vw_con_adjustment_all c, tbl_cds_centro_servicio cs, tbl_adm_medico m,tbl_fac_factura f, tbl_fac_tipo_ajuste t, tbl_adm_empresa e where c.compania ="+compania+appendFilter+" and c.centro=cs.codigo(+) and c.medico=m.codigo(+) and c.compania=f.compania(+) and c.factura=f.codigo(+)  and c.compania =t.compania and c.tipo_ajuste=t.codigo and t.compania=c.compania and f.cod_empresa=e.codigo(+) group by c.nota_ajuste, c.usuario_creacion,c.fecha, t.descripcion,c.recibo, c.total, cs.descripcion, m.primer_nombre , m.primer_apellido,m.segundo_apellido, f.facturar_a, e.nombre,c.secuencia,c.tipo, c.centro,nvl(m.reg_medico,c.medico),c.factura,c.explicacion,c.lado_mov,c.empresa,c.referencia,c.descripcion,f.pac_id, c.usuario_creacion, to_char(c.fecha,'dd/mm/yyyy'),  c.usuario_aprob, to_char(c.fecha_aprob,'dd/mm/yyyy hh12:mi:ss am'), to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am'),  c.tipo_doc, c.pac_id, c.compania, c.recibo,f.nombre_cliente  order by c.nota_ajuste, c.secuencia asc";
}


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	String title = "FACTURACION";
	String subtitle = "NOTAS DE AJUSTES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00;
	double res = 0.00;

	String descripcion = "";
	String v_codigo = "";
	String v_monto = "";
	String v_descripcion = "";
	String v_factura = "";
	String usuario_creacion="", usuario_aprob="", fecha_creacion="", fecha_aprob="";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!descripcion.equalsIgnoreCase(cdo.getColValue("codigo")))// || (cdo.getColValue("nombrePaciente") ==null  || cdo.getColValue("nombrePaciente").trim().equals("")))
		{
			if (i!=0)
			{
					pc.addCols(" ", 1,dHeader.size());
					pc.setFont(8, 1);
					pc.addCols("TOTAL DEBITO . . .", 2,4);
					pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb), 2,1);

					pc.addCols("TOTAL CREDITO . . .", 2,3);
					pc.addCols(""+CmnMgr.getFormattedDecimal(totalCr), 2,1);
					totalDb=0.00;
					totalCr=0.00;

					pc.addCols("",0,dHeader.size());
					pc.addCols("",0,dHeader.size());

					pc.setFont(8, 0);
					pc.addCols("Registrado por:",2,2);
					pc.addCols(""+usuario_creacion,0,4);
					pc.addCols("Fecha Registro:",2,1);
					pc.addCols(""+fecha_creacion,0,3);

					pc.addCols("Aprobado por:",2,2);
					pc.addCols(""+usuario_aprob,0,4);
					pc.addCols("Fecha aprobación:",2,1);
					pc.addCols(""+fecha_aprob,0,3);

					pc.addCols("",0,dHeader.size());
					pc.addCols("",0,dHeader.size());
					pc.addCols("",0,dHeader.size());
					pc.addCols("",0,dHeader.size());
					pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);


			}
			//if (descripcion.trim().equals(""))
			//{
								//Encabezado
									pc.setFont(8, 0);
									pc.addCols("Fecha:", 0,1);
									pc.addCols(""+cdo.getColValue("fecha"), 0,4);
									pc.addCols("No. Nota de Ajuste :", 2,2);
									pc.addCols(""+cdo.getColValue("codigo"), 0,2);

									pc.addCols("Recibo :", 0,1);
									pc.addCols(""+cdo.getColValue("recibo"), 0,4);
									pc.addCols("Referencia :", 2,2);
									pc.addCols(""+cdo.getColValue("referencia"), 0,2);

									pc.addCols("Descripción :", 0,1);
									pc.addCols(""+cdo.getColValue("nombreAjuste"), 0,4);
									pc.addCols("Total :$", 2,2);
									pc.setFont(8, 1);
									pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")), 0,2);

									pc.setFont(8, 0);
									pc.addCols("Pac./Cliente :", 0,1);
									pc.setFont(8, 1);
									pc.addCols(""+cdo.getColValue("nombrePaciente"), 0,8);

									pc.setFont(8, 0);
									pc.addCols("Empresa :", 0,1);
									pc.addCols(""+cdo.getColValue("nombreEmpresa"), 0,8);

									pc.setVAlignment(3);
									pc.addCols("Anotaciones :", 0,1);
									pc.resetVAlignment();
									pc.addCols(""+cdo.getColValue("explicacion"), 0,8);

									if(fg.trim().equals("ajust")){
									pc.addCols("Centro Tramitante :", 0,1);
									pc.addCols(""+cdo.getColValue("descCentroTramite"),0,8);}

									pc.addBorderCols("Código",1,1);
									pc.addBorderCols("Descripción",0,2);
									pc.addBorderCols("Factura",1);
									pc.addBorderCols("Débito",1);
									pc.addBorderCols("Código",1);
									pc.addBorderCols("Descripción",0);
									pc.addBorderCols("Factura",1);
									pc.addBorderCols("Crédito",1);
						//}
				}

					if(cdo.getColValue("lado_mov").trim().equals("D"))
					{
							pc.addCols(""+cdo.getColValue("v_codigo"), 1,1);
							pc.addCols(""+cdo.getColValue("descCentro"), 0,2);
							pc.addCols(""+cdo.getColValue("factura"), 1,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 2,1);
							pc.addCols("", 1,1);
							pc.addCols("", 0,1);
							pc.addCols("", 1,1);
							pc.addCols("", 2,1);
							totalDb += Double.parseDouble(cdo.getColValue("monto"));
					}
					else
					{
							pc.addCols("", 1,1);
							pc.addCols("", 0,2);
							pc.addCols("", 1,1);
							pc.addCols("", 2,1);
							pc.addCols(""+cdo.getColValue("v_codigo"), 1,1);
							pc.addCols(""+cdo.getColValue("descCentro"), 0,1);
							pc.addCols(""+cdo.getColValue("factura"), 1,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 2,1);
							totalCr += Double.parseDouble(cdo.getColValue("monto"));

					}


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		descripcion = cdo.getColValue("codigo");
		usuario_aprob = cdo.getColValue("usuario_aprob");
		usuario_creacion = cdo.getColValue("usuario_creacion");
		fecha_aprob = cdo.getColValue("fecha_aprob");
		fecha_creacion = cdo.getColValue("fecha_creacion");

}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{

			pc.addCols(" ", 1,dHeader.size());
			pc.setFont(8, 1);
			pc.addCols("TOTAL DEBITO . . .", 2,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb), 2,1);

			pc.addCols("TOTAL CREDITO . . .", 2,3);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCr), 2,1);

			pc.addCols("",0,dHeader.size());
			pc.addCols("",0,dHeader.size());

			pc.setFont(8, 0);
			pc.addCols("Registrado por:",2,2);
			pc.addCols(""+usuario_creacion,0,4);
			pc.addCols("Fecha Registro:",2,1);
			pc.addCols(""+fecha_creacion,0,3);

			pc.addCols("Aprobado por:",2,2);
			pc.addCols(""+usuario_aprob,0,4);
			pc.addCols("Fecha de aprobación:",2,1);
			pc.addCols(""+fecha_aprob,0,3);

			/*pc.addCols(" ", 1,dHeader.size());
			pc.addCols("Total Ajuste a  Factura", 1,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb- totalCr),0,4);*/
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>