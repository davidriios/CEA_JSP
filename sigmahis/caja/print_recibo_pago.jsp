<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetallePago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList alFP= new ArrayList();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pac_id = request.getParameter("pac_id");
String recibo = request.getParameter("recibo");
String tipoCliente = request.getParameter("tipoCliente");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");

String compania = (String) session.getAttribute("_companyId");

if (request.getMethod().equalsIgnoreCase("GET"))
{


	if (codigo == null || compania == null || anio == null) throw new Exception("El Recibo no es válido. Por favor intente nuevamente!");

sbSql = new StringBuffer();
sbSql.append("select a.recibo, a.pago_total, a.descripcion, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo_cliente, a.codigo, a.anio, a.recibo, a.caja, decode(a.nombre_adicional,null,decode(a.nombre,null,decode(a.tipo_cliente,'P',(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),'E',(select nombre from tbl_adm_empresa where codigo = a.codigo_empresa),'S/N'),a.nombre),a.nombre_adicional) as nombreCliente, decode(a.tipo_cliente,'P',(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),'E',(select nombre from tbl_adm_empresa where codigo = a.codigo_empresa), 'O', a.nombre, 'S/N') as nombre_adicional, c.codigo as codCaja, c.descripcion as nomCaja, a.descripcion as comentario, (select cc.nombre from tbl_cja_cajera cc where exists (select null from tbl_cja_turnos ct where ct.cja_cajera_cod_cajera = cc.cod_cajera and ct.compania = cc.compania and ct.codigo = a.turno and ct.compania = a.compania)) as cajero, nvl(get_sec_comp_param(a.compania,'CJA_RECEIPT_TOP_MARGIN'),'13.5') as top_margin, nvl(get_sec_comp_param(a.compania,'CJA_RECEIPT_DUPLICATE'),'Y') as duplicado, nvl(get_sec_comp_param(a.compania,'CJA_RECEIPT_HEIGHT'),'11') as height, nvl(get_sec_comp_param(a.compania,'CJA_RECEIPT_WIDTH'),'8.5') as width from tbl_cja_transaccion_pago a, tbl_cja_cajas c where a.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and a.codigo = ");
sbSql.append(codigo);
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and c.codigo = a.caja");

			cdo = SQLMgr.getData(sbSql.toString());
 sbSql = new StringBuffer();

 sbSql.append(" select pago_por,nvl(fac_codigo,decode(cod_rem,null,'','ND# '||cod_rem))faccodigo,sum(nvl(monto,0)) monto1,sum(nvl(monto,0))monto,admi_secuencia admiSecuencia from tbl_cja_detalle_pago where compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and codigo_transaccion =");
sbSql.append(codigo);
sbSql.append(" and tran_anio =");
sbSql.append(anio);
sbSql.append(" group by nvl(fac_codigo,decode(cod_rem,null,'','ND# '||cod_rem)),admi_secuencia,pago_por ");
		System.out.println("SQL DET  :"+sbSql.toString());
		al = sbb.getBeanList(ConMgr.getConnection(), sbSql.toString(), DetallePago.class);

		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, a.descripcion, ");
		if ("YS".contains(cdo.getColValue("duplicado").toUpperCase())) sbSql.append("substr(");
		sbSql.append("decode (b.usa_ck_ref, 'S', c.no_referencia) || decode (b.usa_banco, 'S', ' ' || c.descripcion_banco) || decode(b.usa_tipo_tarjeta, 'S', ' ' || (select descripcion from tbl_cja_tipo_tarjeta tt where tt.codigo = c.tipo_tarjeta))");
		if ("YS".contains(cdo.getColValue("duplicado").toUpperCase())) sbSql.append(",1,17)");
		sbSql.append(" as detalle, sum(c.monto) as monto from tbl_cja_forma_pago a, tbl_cja_forma_pago_det b, tbl_cja_trans_forma_pagos c where a.codigo = b.id_forma_pago and a.codigo = c.fp_codigo and c.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and c.tran_anio = ");
		sbSql.append(anio);
		sbSql.append(" and c.tran_codigo = ");
		sbSql.append(codigo);
		sbSql.append(" group by a.codigo, a.descripcion, b.usa_ck_ref, b.usa_banco, b.usa_tipo_tarjeta, c.no_referencia, c.descripcion_banco, c.tipo_tarjeta");
		alFP = SQLMgr.getDataList(sbSql.toString());

	 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f; //612
	float height = 72 * 11f; //792
	if (!"YS".contains(cdo.getColValue("duplicado").toUpperCase())) {
		try { height = new Float(cdo.getColValue("height")).floatValue(); if (height < 5.5f) height = 5.5f; height *= 72; } catch (Exception ex) {}
		try { width = new Float(cdo.getColValue("width")).floatValue(); if (width < 5.5f) width = 5.5f; width *= 72; } catch (Exception ex) {}
	}
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	try { topMargin = new Float(cdo.getColValue("top_margin")).floatValue(); } catch (Exception ex) {}
	float bottomMargin = 13.5f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECIBO DE PAGO";
	String subTitle = "";
	String xtraSubtitle = "";
	float tWidth = width - (2 * leftRightMargin);

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 50;
	float cHeight = 11.0f;

	double totalMonto = 0.00;
	double totalMontoRest = 0.00;

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		Vector dHeader = new Vector();

		dHeader.addElement(".11");
		dHeader.addElement(".06");
		dHeader.addElement(".18");
		dHeader.addElement(".25");
		dHeader.addElement(".05");
		dHeader.addElement(".09");
		dHeader.addElement(".26");

		Vector header = new Vector();
		header.addElement("30");
		header.addElement("40");
		header.addElement("30");

		Vector vFP = new Vector();
		vFP.addElement("18");
		vFP.addElement("3");
		vFP.addElement("10");
		vFP.addElement("17");
		vFP.addElement("4");
		vFP.addElement("18");
		vFP.addElement("3");
		vFP.addElement("10");
		vFP.addElement("17");

	//table para el header
	pc.setVAlignment(0);
	pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		pc.setNoColumnFixWidth(header);
		pc.createTable("header",false,0,0.0f,tWidth);

		pc.addCols("",1,1);
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),45.0f,1);
		pc.addCols("",1,1);

		pc.setFont(12, 1);
		pc.addCols(_comp.getNombre(),1,header.size(),16.0f);

		pc.setFont(7,0);
		pc.addCols("  RUC. "+_comp.getRuc()+((_comp.getDigitoVerificador().trim().equals(""))?"":" D.V. "+_comp.getDigitoVerificador()),1,header.size());

		pc.setFont(7,0);
		pc.addCols("["+cdo.getColValue("codCaja")+" - "+cdo.getColValue("cajero")+"] - "+cDateTime,1,0);
		pc.addCols("Telefono: "+_comp.getTelefono() + "  Fax: "+_comp.getFax(),1,1);

		pc.setFont(15,1,Color.red);
		pc.addCols("No. "+cdo.getColValue("recibo"),2,1);

		pc.setFont(9,1);
		pc.addCols("RECIBO DE PAGO",1,dHeader.size(),15f);
		pc.addCols("",1,dHeader.size());

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("factura",false,0,0.0f,tWidth);

		pc.useTable("factura");
		pc.addTableToCols("header",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

		pc.setVAlignment(2);
			pc.setFont(12, 1);
	pc.addCols("Fecha:",0,1);
		pc.addBorderCols(cdo.getColValue("fecha"),0,2,0.1f,0.0f,0.0f,0.0f);
	//pc.addCols("",0,1,15f);
	pc.addCols("",0,1,15f);
	pc.addCols("B./",2,1,15f);
	pc.addBorderCols(""+CmnMgr.getFormattedDecimal("#.##",cdo.getColValue("pago_total")),0,2,0.1f,0.0f,0.0f,0.0f);
	pc.addCols("",0,dHeader.size(),5f);
		pc.setFont(8, 0);
	pc.addCols("Hemos  recibido  de:",0,2,15f);

	pc.addBorderCols(cdo.getColValue("nombreCliente"),0,5,0.1f,0.0f,0.0f,0.0f,15f);
	if(!cdo.getColValue("nombre_adicional").equals("") ){
		pc.addCols("Nombre  adicional:",0,2,15f);
		pc.addBorderCols(cdo.getColValue("nombre_adicional"),0,5,0.1f,0.0f,0.0f,0.0f,15f);
		pc.addCols("",0,dHeader.size(),5f);
	}

	pc.addCols("La suma de:",0,2,15f);
	pc.setFont(11, 1);
	pc.addBorderCols(CmnMgr.num2Word(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")).replace(",",""),"BALBOA","","ES"),0,5,0.1f,0.0f,0.0f,0.0f,15f);
	pc.addCols("",0,dHeader.size(),5f);
	pc.setFont(8, 0);
	pc.addCols("En Concepto de:",0,2,15f);
	pc.addBorderCols(cdo.getColValue("comentario"),0,5,0.1f,0.0f,0.0f,0.0f,15f);
	pc.addCols("",0,dHeader.size(),5f);

	pc.setNoColumnFixWidth(vFP);
	pc.createTable("forma_pago",false,0,0.0f,tWidth);
	pc.setFont(7,0);
	for(int i=0;i<alFP.size();i++){
		CommonDataObject cfp = (CommonDataObject) alFP.get(i);
		pc.addCols(cfp.getColValue("descripcion"),0,1);
		pc.addCols("B/.",2,1);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("#.##",cfp.getColValue("monto")),2,1,0.1f,0.0f,0.0f,0.0f);
		pc.addCols(cfp.getColValue("detalle"),0,1);
		if((i%2)==0)pc.addCols(" ",0,1);
	}//end for
	if((alFP.size()%2)!=0){
		pc.addCols(" ",1,4);
	}



		for(int i=1;i<=al.size();i++){

		DetallePago dp = (DetallePago) al.get(i-1);

		totalMonto += Double.parseDouble(dp.getMonto());
		if(dp.getPagoPor() != null  && !dp.getPagoPor().trim().equals("") && !dp.getPagoPor().trim().equals("D")){
		if(i == 1){
				pc.setFont(8, 0);
						pc.addCols("En  concepto  de  cancelacion  Facturas  No."+dp.getFacCodigo(),0,3,15f);
		}else{
			 pc.addCols("",0,3);
		}

				 pc.setFont(8,1);
			 pc.addBorderCols(dp.getFacCodigo()+" "+((dp.getAdmiSecuencia()== null || dp.getAdmiSecuencia().trim().equals("")||dp.getAdmiSecuencia().trim().equals("0"))?" ** SALDO AL 31/12/2010 ":""),0,1,0.1f,0.0f,0.0f,0.0f,15f);

			 //pc.setFont(8,0);
			 pc.addCols("B/. ",2,1,15f);
			 pc.addBorderCols(CmnMgr.getFormattedDecimal("#.##",dp.getMonto1()),0,2,0.1f,0.0f,0.0f,0.0f,15f);
			 pc.addCols("",0,dHeader.size(),5f);

		if(i >= 6){
			pc.setNoColumnFixWidth(dHeader);
				pc.createTable("otros",false,0,0.0f,tWidth);

			if(i >= 7){
						totalMontoRest = totalMontoRest + Double.parseDouble(dp.getMonto1());
					pc.addCols("Otros",0,1,15f);
					//pc.setFont(8,0);
					pc.addBorderCols("",0,3,0.1f,0.0f,0.0f,0.0f,15f);
					pc.addCols("B/. ",2,1,15f);
						pc.addBorderCols(CmnMgr.getFormattedDecimal("#.##",totalMontoRest),0,2,0.1f,0.0f,0.0f,0.0f,15f);
					pc.addCols("",0,dHeader.size(),5f);
			}
			}
		}

		}//end for



		pc.setVAlignment(0);
		pc.useTable("factura");
		pc.addTableToCols("forma_pago",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
		pc.addTableToCols("otros",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	//20131220 Jacinto: Se comenta este segmento ya que al cliente no le interesa lo aplicado y tiende a confundir.
	//pc.setFont(8,1);
	//pc.addCols("Total Aplicado",2,4,15f);
	pc.addCols(" ",2,dHeader.size(),15f);

	/*if(al.size() < 1){
		pc.setFont(8,1);
		pc.addCols("B/.",2,1,15f);
			pc.addCols(CmnMgr.getFormattedDecimal("#.##",cdo.getColValue("pago_total")),0,2,15f);
		//pc.addCols("",0,dHeader.size(),5f);
	}else{
		 pc.setFont(8,1);
		 pc.addCols("B/.",2,1,15f);
		 pc.addCols(CmnMgr.getFormattedDecimal("#.##",totalMonto),0,2,15f);
		// pc.addCols("",0,dHeader.size(),5f);
	}*/

	//pc.setFont(8, 0);
	pc.addCols("Cuenta No. _______________ Saldo B./_________________",0,dHeader.size(),15f);
	pc.addCols("",0,dHeader.size(),3f);
	/*
	pc.addCols("Efectivo B/. _______________ Cheque No. ______________",0,dHeader.size(),15f);
	pc.addCols("Banco ___________________ Fecha  ___________________",0,4,15f);
	*/

	//pc.setFont(8, 0);
		pc.addBorderCols(" Recibido "+_comp.getNombre(),1,3,0.0f,0.1f,0.0f,0.0f,15f);

	pc.useTable("main");
	pc.addTableToCols("factura",1,dHeader.size(),(height / (("YS".contains(cdo.getColValue("duplicado").toUpperCase()))?2:1)) - topMargin - bottomMargin,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.useTable("main");

	if ("YS".contains(cdo.getColValue("duplicado").toUpperCase())) {
		pc.addCols("......................................................................................................................................................................................................................................................",1,dHeader.size(),15f);

		pc.addCols(" ",1,dHeader.size(),topMargin);
		pc.useTable("main");
		pc.addTableToCols("factura",1,dHeader.size(),367.5f - topMargin,null,null,0.0f,0.0f,0.0f,0.0f);

	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>