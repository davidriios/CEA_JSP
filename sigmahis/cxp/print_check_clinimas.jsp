<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.cxp.OrdenPago"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="htCK" scope="page" class="java.util.Hashtable" />
<jsp:useBean id="iAnexo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

	String sql 						 = "", key = "";
	String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
	
	String cod_compania 			 = request.getParameter("cod_compania");
	String cod_banco 				 = request.getParameter("cod_banco");
	String cuenta_banco       = request.getParameter("cuenta_banco");
	String num_ck       = request.getParameter("num_ck");
	String fecha_emi       = request.getParameter("fecha_emi");
	String fp = request.getParameter("fp");
	String fg = request.getParameter("fg");
	String num_ckHasta = request.getParameter("num_ckHasta");
	String cheUser = request.getParameter("cheUser");
	if(fp==null) fp = "";
	if(fg==null) fg = "";
	if(cheUser==null) cheUser = "";	
	if(num_ckHasta==null) num_ckHasta = "";
	String tableH = "tbl_con_temp_cheque", tableD = "tbl_con_temp_detalle_cheque";
	if(fp.equals("cheque")){
		tableH = "tbl_con_cheque"; 
		tableD = "tbl_con_detalle_cheque";
	}
	String appendFilter = "";
	if(!cheUser.trim().equals(""))userName=cheUser;
	 appendFilter += " and ck.estado_cheque != 'A' ";
	if(cod_compania!=null) appendFilter += " and ck.cod_compania = " + cod_compania;
	if(cod_banco!=null) appendFilter += " and ck.cod_banco = '" + cod_banco + "'";
	if(cuenta_banco!=null) appendFilter += " and ck.cuenta_banco = '" + cuenta_banco + "'";
	if(fg.equals("solo") && num_ck!=null) appendFilter += " and ck.num_cheque = '" + num_ck +"'";
	if(fg.equals("") && num_ck!=null) appendFilter += " and decode(substr(ck.num_cheque,1,1), 'T', 0, 'A', 0, to_number(ck.num_cheque)) >= " + num_ck;
	if(fg.equals("") && !num_ckHasta.trim().equals("")) appendFilter += " and decode(substr(ck.num_cheque,1,1), 'T', 0, 'A', 0, to_number(ck.num_cheque)) <= " + num_ckHasta;
	if(fecha_emi!=null) appendFilter += " and trunc(ck.f_emision) >= to_date('" + fecha_emi + "', 'dd/mm/yyyy')";

	sql = "select to_char(ck.f_emision, 'dd/mm/yyyy') fecha_emision, to_char(ck.f_emision, 'dd') dia, '**' || upper(nvl(ck.beneficiario2,ck.beneficiario)) || '**' beneficiario, upper(ck.beneficiario) beneficiarioDet, ck.num_cheque, ck.cuenta_banco, ck.cod_banco, ck.cod_compania, '**'||trim(to_char(ck.monto_girado, '999,999,999.99'))||'**' monto_girado_formatted,ck.monto_girado, ck.che_user, '**' || upper(ck.monto_palabras) || '**' palabra /*, upper(ck.beneficiario2) beneficiario2*/, b.nombre, to_char(ck.f_emision,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes, to_char(ck.f_emision, 'yyyy') anio, to_char(sysdate, 'dd/mm/yyyy') current_date, (case when (select count(tdck.monto_renglon) from "+tableH+" tck, "+tableD+" tdck, tbl_con_banco b, tbl_con_cuenta_bancaria cb where tdck.cuenta_banco = tck.cuenta_banco and tdck.cod_banco = tck.cod_banco and tdck.compania = tck.cod_compania and tdck.num_cheque = tck.num_cheque and tck.cuenta_banco = cb.cuenta_banco and tck.cod_compania = cb.compania and tck.cod_banco = cb.cod_banco and cb.cod_banco = b.cod_banco and cb.compania = b.compania and cb.cod_banco = ck.cod_banco and cb.compania = ck.cod_compania and tck.cuenta_banco = ck.cuenta_banco and tck.num_cheque = ck.num_cheque) >= 10 then 'VER ANEXO' else ' ' end) ver_anexo, trim(to_char((select sum(nvl(monto_renglon, 0)) from "+tableD+" where imprimir = 'S' and num_cheque = ck.num_cheque and cod_banco = ck.cod_banco and compania = ck.cod_compania and cuenta_banco = ck.cuenta_banco), '999,999,999.99')) monto_anexo, nvl(c.num_id_beneficiario, ' ') cod_beneficiario, (case when ck.ruc is null then ' ' else 'RUC. /'|| ck.ruc || '/' || ck.dv end) ruc, cb.cg_1_cta1||cb.cg_1_cta2||cb.cg_1_cta3||cb.cg_1_cta4||cb.cg_1_cta5||cb.cg_1_cta6 cuentaBanco, ct.descripcion descBanco,decode(c.generado,'H',nvl(getBoletasOp(c.anio,c.num_orden_pago,c.cod_compania),' '),getckfacturas(ck.num_cheque, ck.cod_banco, ck.cuenta_banco, ck.cod_compania)) as factura ,decode(c.generado,'H','BOLETAS(S) NO. ','FACTURA(S) NO. ') label_fac,c.generado as tipoOp from "+tableH+" ck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_cxp_orden_de_pago c, tbl_con_catalogo_gral ct where ";
	if(!fg.trim().equals("solo"))sql +="ck.che_user = '"+userName+"' and ";
	sql += " ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and c.anio = ck.anio and c.num_orden_pago = ck.num_orden_pago and c.cod_compania = ck.cod_compania and ck.tipo_pago = 1"+appendFilter+" and cb.compania = ct.compania and cb.cg_1_cta1 = ct.cta1 and cb.cg_1_cta2 = ct.cta2 and cb.cg_1_cta3 = ct.cta3 and cb.cg_1_cta4 = ct.cta4 and cb.cg_1_cta5 = ct.cta5 and cb.cg_1_cta6 = ct.cta6 order by ck.num_cheque";
al = SQLMgr.getDataList(sql);
iAnexo.clear();
	for(int i=0;i<al.size();i++){
		CommonDataObject cdoDet = (CommonDataObject) al.get(i);
		OrdenPago OP = new OrdenPago();
		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);
		OP.setCdo(cdoDet);
		sql = "select dck.num_renglon, dck.monto_renglon, dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4 cuenta, dck.descripcion, ct.descripcion descCuenta from "+tableH+" ck, "+tableD+" dck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_con_catalogo_gral ct where dck.imprimir = 'N' ";
		if(!fg.trim().equals("solo"))sql +=" and ck.che_user = '"+userName+"'";
		sql +="  and dck.cuenta_banco = ck.cuenta_banco and dck.cod_banco = ck.cod_banco and dck.compania = ck.cod_compania and dck.num_cheque = ck.num_cheque and ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and dck.compania = ct.compania and dck.cuenta1 = ct.cta1 and dck.cuenta2 = ct.cta2 and dck.cuenta3 = ct.cta3 and dck.cuenta4 = ct.cta4 and dck.cuenta5 = ct.cta5 and dck.cuenta6 = ct.cta6 and ck.num_cheque = '"+cdoDet.getColValue("num_cheque")+"' and trunc(ck.f_emision) >= to_date('"+cdoDet.getColValue("fecha_emision")+"', 'dd/mm/yyyy') and ck.cod_banco = '"+cdoDet.getColValue("cod_banco")+"' and ck.cuenta_banco = '" + cdoDet.getColValue("cuenta_banco") + "' and ck.tipo_pago = 1 order by ck.num_cheque, dck.num_renglon";
		OP.setAlDet(SQLMgr.getDataList(sql));
	OP.getCdo().setSql(sql);

		try {
			htCK.put(key, OP);
		} catch (Exception e) {
			System.out.println("Unable to addget item "+key);
		}
	}



if (request.getMethod().equalsIgnoreCase("GET"))
{
		String fecha =cDateTime;
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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 7.323f;//612
	float height = 72 * 7.362f;//792
	boolean isLandscape = true;
	float leftRightMargin = 0.0f;
	float topMargin = 0.0f;
	float bottomMargin = 0.0f;
	float headerFooterFont = 0f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 14.0f;

	Vector dHeader = new Vector();
		dHeader.addElement("67");
		dHeader.addElement("255");
		dHeader.addElement("85");
		dHeader.addElement("17");
		dHeader.addElement("31");
		dHeader.addElement("55");

	Vector detail = new Vector();
		detail.addElement(".05");
		detail.addElement(".45");
		detail.addElement(".25");
		detail.addElement(".15");
		detail.addElement(".15");

	Vector anexo = new Vector();
		anexo.addElement("14");
		anexo.addElement("65");
		anexo.addElement("133");
		anexo.addElement("133");
		anexo.addElement("79");
		anexo.addElement("85");

	Vector detFinal = new Vector();
		detFinal.addElement("14");
		detFinal.addElement("122");
		detFinal.addElement("122");
		detFinal.addElement("167");
		detFinal.addElement("85");

	/*
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	*/
	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,null/*footer.getTable()*/);

	if (htCK.size() != 0) al = CmnMgr.reverseRecords(htCK);
	for (int i=0; i<htCK.size(); i++){
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
				key = al.get(i).toString();
				OrdenPago objOP = (OrdenPago) htCK.get(key);
				CommonDataObject cdoCK = (CommonDataObject) objOP.getCdo();

				pc.setFont(10, 1);
			
				pc.addCols(" ",0,dHeader.size(), 24.0f);

				pc.addCols(cdoCK.getColValue("num_cheque"),2,6);
				//pc.addCols(" ",0,1);

		
				pc.addCols(" ",0,2);
				pc.addCols(cdoCK.getColValue("dia")+" "+cdoCK.getColValue("mes")+" "+cdoCK.getColValue("anio"),0,4);
		
				pc.addCols(" ",0,dHeader.size(), 24.0f);
		
				pc.addCols(" ",0,1);
				pc.addCols("     "+cdoCK.getColValue("beneficiario"),0,2, 28.0F);
				pc.addCols(" ",0,1);
				pc.addCols(cdoCK.getColValue("monto_girado_formatted"),1,2);
		
				pc.addCols(" ",0,1);
				pc.addCols(cdoCK.getColValue("palabra"),1,4);
				pc.addCols(" ",0,3);
		
				pc.addCols(" ",0,1);
				pc.addCols(cdoCK.getColValue("beneficiario2"),0,2, 28.0F);
				pc.addCols(" ",0,3);
		
				pc.addCols(" ",0,dHeader.size(), 80.0F);
		
				//pc.addCols("Aptdo. 0834-00363  Pma, R de Pma",1,dHeader.size());
				pc.addCols(" ",1,dHeader.size());
		
				pc.addCols(" ",0, dHeader.size(), 50.0F);
				System.out.println(" SIZE TABLE   anexo ======="+pc.getTableSize("anexo")+"  main   ="+pc.getTableSize("main"));
				pc.setNoColumnFixWidth(anexo);
				pc.createTable("anexo",false);
				pc.setVAlignment(0);
				pc.setFont(7, 1);
				pc.addCols(" ",1,1);
				pc.addCols(cdoCK.getColValue("current_date"),1,1);
				pc.addCols(cdoCK.getColValue("ver_anexo"),1,1);
				pc.addCols(cdoCK.getColValue("monto_anexo"),1,1);
				pc.addCols("TOTAL",2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),1,1);
				
				Double ckAmt = Double.parseDouble(cdoCK.getColValue("monto_girado"));
				
				System.out.println(" SIZE TABLE   anexo ======="+pc.getTableSize("anexo")+"  main   ="+pc.getTableSize("main"));
				pc.setNoColumnFixWidth(detail);
				pc.createTable("detail",false);
				double amt = 0.00, tAmt = 0.00;
				String renglon = "";
		cdoCK.setSql(objOP.getCdo().getSql());
				for (int j=0; j<objOP.getAlDet().size(); j++)
				{
					cdo = (CommonDataObject) objOP.getAlDet().get(j);
					amt = Double.parseDouble(cdo.getColValue("monto_renglon"));
					System.out.println(" SIZE TABLE   =======  detail  en j== "+j+" - "+pc.getTableSize("detail")+" tipo op=="+cdoCK.getColValue("tipoOp"));
					if (j == 0) 
					{
						if(cdoCK.getColValue("tipoOp").trim().equals("H")){
						if(!cdoCK.getColValue("factura").trim().equals("")&&!cdoCK.getColValue("factura").trim().equals("0")&&!cdoCK.getColValue("factura").trim().equals("00")) 
						{
							pc.addCols(" ",0,1);
							pc.addCols("PARA CANCELAR "+cdoCK.getColValue("label_fac")+cdoCK.getColValue("factura"),0,4);
							pc.addCols(" ",0,1);
							if(!cdoCK.getColValue("beneficiarioDet").equals(cdoCK.getColValue("beneficiario")))
							pc.addCols("PAGO A FAVOR DE : "+cdoCK.getColValue("beneficiarioDet"),0,4);
							pc.addCols(" ",1,detail.size());
						}
						}
						if(!cdoCK.getColValue("tipoOp").trim().equals("H"))
						{
							pc.addCols(" ",0,1);
							pc.addCols(cdo.getColValue("descripcion"),0,4);
						}
					}
					pc.addCols(" ",0,1);
					pc.addCols(cdo.getColValue("descCuenta"),0,1);
					pc.addCols(cdo.getColValue("cuenta"),2,1);
					pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_renglon")),2,1);
					pc.addCols(" ",0,1);			
					tAmt += amt;
					renglon = cdo.getColValue("num_renglon");//start anexo after this row
					
				}//for j
				 System.out.println(" SIZE TABLE   =======  detail  "+pc.getTableSize("detail"));
					
					pc.addCols(" ",0,1);
					pc.addCols(cdoCK.getColValue("descBanco"),0,1);
					pc.addCols(cdoCK.getColValue("cuentaBanco"),2,1);
					pc.addCols(" ",0,1);
					pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),2,1);
				

				pc.addCols(" ");
				//pc.addCols("Nota: HPP reporta cada mes a la Direccion General de Ingresos los pagos efectuados segun el Nombre y RUC que aparece en este comprobante, por favor tome en cuenta esta informacion para sus Declaraciones Fiscales y para emitir el recibo correspondiente.",0,5, 40.0F);

				pc.addCols(" ",0,5, 40.0F);
				
				pc.useTable("main");
				pc.addTableToCols("detail",1,dHeader.size());	
				
				if (!cdoCK.getColValue("ver_anexo").trim().equals(""))
				{
					try
					{
						cdoCK.addColValue("renglon",renglon);//last printed row
						cdoCK.addColValue("total_printed",CmnMgr.getFormattedDecimal(tAmt));
						cdoCK.addColValue("anexo_amt",CmnMgr.getFormattedDecimal(ckAmt - tAmt));
						iAnexo.put(cdoCK.getColValue("num_cheque"),cdoCK);
					}
					catch(Exception e)
					{
						System.out.println("Unable to add Anexo!");
					}
				}
				
				pc.useTable("main");
				pc.addTableToCols("anexo",1,dHeader.size());
				System.out.println(" SIZE TABLE   =======  main  "+pc.getTableSize("main"));
				pc.setNoColumnFixWidth(detFinal);
				pc.createTable("detFinal",false);
				pc.setVAlignment(0);
				pc.setFont(7, 1);
				pc.addCols(" ",1,1);
				pc.addCols(userName,1,1);
				pc.addCols(cdoCK.getColValue("cod_beneficiario"),1,1);
				pc.addCols(cdoCK.getColValue("num_cheque"),0,1);
				pc.addCols(cdoCK.getColValue("ruc"),1,1);
				System.out.println(" SIZE TABLE   detFinal ======="+pc.getTableSize("detFinal")+"  main   ="+pc.getTableSize("main"));

				pc.useTable("main");
				pc.addTableToCols("detFinal",1,dHeader.size());
				System.out.println(" SIZE TABLE      main   ="+pc.getTableSize("main"));

				pc.useTable("main");
				
				pc.addNewPage();
		pc.addTable();
	}
	pc.close();
%>
<html>
<frameset rows="0,*" frameborder="NO" border="0" framespacing="0">
	<frame src="has_anexo.jsp?fp=<%=fp%>" name="actionFrame" scrolling="NO" noresize/>
	<frame src="<%=redirectFile%>" name="printFrame"/>
</frameset>
<noframes></noframes>
</html>
<%
}//get
%>

