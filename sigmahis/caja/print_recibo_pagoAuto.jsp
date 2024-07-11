<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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
ArrayList alB= new ArrayList();
StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String showColor = request.getParameter("showColor")==null?"":request.getParameter("showColor");
float recCustomWidth = 0.83f;
try { recCustomWidth = Float.parseFloat(ResourceBundle.getBundle("issi").getString("recCustomWidth")); } catch(Exception e) { System.out.println("Unable to set WIDTH, using default "+recCustomWidth+"! Error: "+e); }

if (codigo == null || compania == null || anio == null) throw new Exception("El Recibo no es válido. Por favor intente nuevamente!");

sbSql = new StringBuffer();
sbSql.append("select to_char(a.pago_total,'9999990.00') as pago_total, a.descripcion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha_creacion, a.usuario_creacion, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.recibo||decode(a.rec_impreso,'S',' (COPIA)') as recibo, a.rec_status, a.rec_impreso, a.caja, a.turno, /*decode(a.tipo_cliente,'P',*/decode(a.nombre,a.nombre_adicional,a.nombre,a.nombre_adicional||chr(10)||chr(10)||decode(a.tipo_cliente,'P','Paciente: ','Cliente: ')||chr(10)||a.nombre) /*),a.nombre_adicional||'Clte: '||chr(10)||a.nombre)*/ as nombre_recibo, (select descripcion from tbl_cja_cajas where compania = a.compania and codigo = a.caja) as nombre_caja, (select (select nombre from tbl_cja_cajera where cod_cajera = z.cja_cajera_cod_cajera and compania = z.compania) from tbl_cja_turnos z where z.codigo = a.turno and z.compania = a.compania) as nombre_cajera, nvl(join(cursor(select distinct nvl(fac_codigo,decode(cod_rem,null,'','ND# '||cod_rem)) from tbl_cja_detalle_pago where compania = a.compania and codigo_transaccion = a.codigo and tran_anio = a.anio and anulada ='N'),', '),' ') as factura from tbl_cja_transaccion_pago a where a.codigo = ");
sbSql.append(codigo);
sbSql.append(" and a.compania = ");
sbSql.append(compania);
sbSql.append(" and a.anio = ");
sbSql.append(anio);
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
if (cdo.getColValue("rec_status").equalsIgnoreCase("I")) throw new Exception("No se permite imprimir recibos anulados. Por favor consulte con su Administrador!");

sbSql = new StringBuffer();
sbSql.append("select a.fp_codigo, sum(a.monto) as monto, a.no_referencia, a.banco, a.tipo_banco, (select descripcion from tbl_cja_forma_pago where codigo = a.fp_codigo)||(select ' - '||descripcion from tbl_cja_tipo_tarjeta where codigo = a.tipo_tarjeta)||decode(a.no_referencia,null,null,' ('||a.no_referencia||')') as forma_pago from tbl_cja_trans_forma_pagos a where compania = ");
sbSql.append(compania);
sbSql.append(" and a.tran_codigo = ");
sbSql.append(codigo);
sbSql.append(" and a.tran_anio = ");
sbSql.append(anio);
sbSql.append(" group by a.fp_codigo, a.banco, a.no_referencia, a.tipo_tarjeta, a.tipo_banco");
al = SQLMgr.getDataList(sbSql.toString());

// desglose numero de serie de billetes de alta denominacion recibidos
sbSql = new StringBuffer();
sbSql.append("select b.denominacion, b.serie from tbl_cja_billetes b where b.cia = ");
sbSql.append(compania);
sbSql.append(" and b.anio = ");
sbSql.append(anio);
sbSql.append(" and b.num_transac = ");
sbSql.append(codigo);
sbSql.append(" order by b.secuencia ");
alB = SQLMgr.getDataList(sbSql.toString());

CommonDataObject cdoP = SQLMgr.getData("select get_sec_comp_param("+compania+",'CJA_RECEIPT_PRINTED') as cjaReceiptPrinted, get_sec_comp_param("+compania+",'CJA_SHOW_REC_DISCLAIMER') as cjaShowRecDisclaimer, (select initcap(param_desc) from tbl_sec_comp_param where param_name = 'CJA_SHOW_REC_DISCLAIMER' and rownum = 1) as disclaimer from dual");
if (cdoP==null) cdoP = new CommonDataObject();

String cjaReceiptPrinted = cdoP.getColValue("cjaReceiptPrinted","N");
String cjaShowRecDisclaimer = cdoP.getColValue("cjaShowRecDisclaimer","N");
String disclaimer = cdoP.getColValue("disclaimer"," ");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+System.currentTimeMillis()+".pdf";

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

	float factor = recCustomWidth;//fue requerido reducir el tamaño de pdf para que se imprimiera correctamente en la impresora con cinta de 3" x N"
	float width = 72 * 3f; //216
	float height = 72 * 11f * factor; //792
	boolean isLandscape = false;
	float leftRightMargin = 0.0f;
	float topMargin = 0.0f * factor;
	float bottomMargin = 0.0f * factor;
	float headerFooterFont = 4f * factor;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECIBO DE PAGO";
	String subTitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	Vector dHeader = new Vector();
		/*
		//Courier9
		dHeader.addElement(".215");
		dHeader.addElement(".11");
		dHeader.addElement(".05");
		dHeader.addElement(".055");
		dHeader.addElement(".32");
		dHeader.addElement(".25");
		*/
		/*
		//Helvetica8
		dHeader.addElement(".17");
		dHeader.addElement(".10");
		dHeader.addElement(".055");
		dHeader.addElement(".025");
		dHeader.addElement(".40");
		dHeader.addElement(".25");
		*/
		//Helvetica9
		dHeader.addElement(".21");
		dHeader.addElement(".10");
		dHeader.addElement(".075");
		dHeader.addElement(".025");
		dHeader.addElement(".28");
		dHeader.addElement(".31");



	PdfCreator temp = new PdfCreator(width, height, leftRightMargin);
	temp.setNoColumnFixWidth(dHeader);
	temp.createTable();
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(_comp.getNombre(),1,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("R.U.C. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,dHeader.size());

		temp.addCols("Teléfono: "+_comp.getTelefono() + "  Fax: "+_comp.getFax(),1,dHeader.size());

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		if(showColor.equalsIgnoreCase("P"))temp.setFont(fontFamily,fontSize + 2,1,Color.red);
		else temp.setFont(fontFamily,fontSize + 2,1);
		temp.addCols("Recibo #"+cdo.getColValue("recibo"),1,dHeader.size());

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("Recibí de:",0,2);
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(" ",0,4);

		temp.addCols(cdo.getColValue("nombre_recibo"),0,dHeader.size());

		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("La suma de:",0,2);
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(" ",0,4);

		temp.addCols(CmnMgr.num2Word(cdo.getColValue("pago_total"),"BALBOA","","ES"),0,dHeader.size());

		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("En concepto de:",0,4);
		temp.setFont(fontFamily,fontSize,0);
		temp.addCols(cdo.getColValue("descripcion"),0,2);

		if ( cjaReceiptPrinted.trim().equals("N") && !cdo.getColValue("factura","").trim().equals(""))
		{
			temp.setFont(fontFamily,fontSize,0);
			temp.addCols("# Facturas:",0,2);
			temp.setFont(fontFamily,fontSize,0);
			temp.addCols(cdo.getColValue("factura"),0,4);
		}

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addBorderCols("F O R M A   D E   P A G O",0,5,0.1f,0.0f,0.0f,0.0f);
		temp.addBorderCols("M O N T O",2,1,0.1f,0.0f,0.0f,0.0f);

		temp.setFont(fontFamily,fontSize,0);
		double mTotal = 0.00;
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject fpgo = (CommonDataObject) al.get(i);
			mTotal += Double.parseDouble(fpgo.getColValue("monto"));

			temp.addCols(fpgo.getColValue("forma_pago"),0,5);
			temp.addCols(CmnMgr.getFormattedDecimal("#.##",fpgo.getColValue("monto")),2,1);
		}

		temp.addCols(" ",0,5);
		temp.addBorderCols(CmnMgr.getFormattedDecimal("$#.##",mTotal),2,1,0.0f,0.1f,0.0f,0.0f);

		// se incluye seccion para desglose de numero de serie de billetes
		if (alB.size()!=0)
		{
			temp.addCols(" ",0,6);

			temp.setFont(fontFamily,fontSize,0);
			temp.addBorderCols("Valor",0,1,0.1f,0.0f,0.0f,0.0f);
			temp.addBorderCols("Serie",0,5,0.1f,0.0f,0.0f,0.0f);

			temp.setFont(fontFamily,fontSize,0);
			for (int i=0; i<alB.size(); i++)
			{
				CommonDataObject billete = (CommonDataObject) alB.get(i);
				temp.addCols(billete.getColValue("denominacion"),0,1);
				temp.addCols(billete.getColValue("serie"),0,5);
			}

			temp.addBorderCols(" ",0,6,0.0f,0.1f,0.0f,0.0f);

			temp.addCols(" ",0,6);
		}

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("Caja:",0,1);
		temp.addCols(cdo.getColValue("nombre_caja"),0,5);

		temp.addCols("Cajer@:",0,1);
		temp.addCols(cdo.getColValue("nombre_cajera"),0,5);

		temp.addCols("Creado por: "+cdo.getColValue("usuario_creacion"),0,6);

		temp.addCols(cdo.getColValue("turno"),0,3);
		temp.addCols(cdo.getColValue("fecha_creacion"),2,3);

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		temp.setFont(fontFamily,fontSize,0);
		temp.addCols("Gracias por preferirnos",1,dHeader.size());

		temp.setFont(1,0);
		temp.addCols(" ",0,dHeader.size());

		if (cjaShowRecDisclaimer.equalsIgnoreCase("Y")){
			temp.setFont(fontFamily,fontSize,0);
			temp.addCols(" ",1,dHeader.size());

			temp.setFont(1,0);
			temp.addCols(" ",0,dHeader.size());
			temp.addCols(" ",0,dHeader.size());
		
			temp.setFont(fontFamily,fontSize,0);
			temp.addCols(disclaimer,1,dHeader.size(),35f);
		}

	int allowPrint = 1;
	boolean showUI = true;
	/*
	if (cdo.getColValue("rec_impreso").equalsIgnoreCase("S"))
	{
		allowPrint = 0;
		showUI = false;
	}
	*/
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, (temp.getTableHeight() + (topMargin / factor) + (bottomMargin / factor)), isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, allowPrint, false, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pc.setVAlignment(0);
		pc.addTableToCols(temp.getTable(),1,dHeader.size());
		pc.flushTableBody(true);
	pc.close();
	
	//
	if (cjaReceiptPrinted.trim().equals("Y")){
		  
	    sbSql = new StringBuffer();
		sbSql.append("select rec_impreso from tbl_cja_transaccion_pago where codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and compania = ");
		sbSql.append(compania);
		sbSql.append(" and anio = ");
		sbSql.append(anio);
		cdo = SQLMgr.getData(sbSql.toString());
		if (cdo==null) cdo = new CommonDataObject();
		if (cdo.getColValue("rec_impreso","N").equalsIgnoreCase("N")){
		   try{
			 cdo=new CommonDataObject();
			 cdo.setTableName("tbl_cja_transaccion_pago");
			 cdo.setWhereClause("codigo = "+codigo+" and compania = "+compania+" and anio = "+anio);
			 cdo.addColValue("rec_impreso","S");
			 SQLMgr.update(cdo);
		   }catch(Exception e){
			 System.out.println(":::::::::::::::::::::::::::::::::::::::: ERROR WHILE UPDATING REC_IMPRESO TO S "+e);
		     e.printStackTrace();
		   }
		}
	}
	//	
%>
<html>
<frameset rows="35,*" frameborder="NO" border="0" framespacing="0">
	<frame src="../common/is_printed_doc.jsp?docType=REC&docKey1=<%=codigo%>&docKey2=<%=compania%>&docKey3=<%=anio%>" name="actionFrame" scrolling="NO" noresize/>
	<frame src="<%=redirectFile%>" name="printFrame"/>
</frameset>
<noframes></noframes>
</html>
<%
}
%>