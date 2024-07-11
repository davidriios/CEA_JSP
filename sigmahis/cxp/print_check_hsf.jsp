<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.cxp.OrdenPago"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="htCK" scope="page" class="java.util.Hashtable"/>
<jsp:useBean id="iAnexo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String cod_compania = request.getParameter("cod_compania");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String num_ck = request.getParameter("num_ck");
String fecha_emi = request.getParameter("fecha_emi");
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

if (!cheUser.trim().equals("")) userName = cheUser;
sbFilter.append(" and ck.estado_cheque != 'A' ");
if (cod_compania != null) { sbFilter.append(" and ck.cod_compania = "); sbFilter.append(cod_compania); }
if (cod_banco != null) { sbFilter.append(" and ck.cod_banco = '"); sbFilter.append(cod_banco); sbFilter.append("'"); }
if (cuenta_banco != null) { sbFilter.append(" and ck.cuenta_banco = '"); sbFilter.append(cuenta_banco); sbFilter.append("'"); }
if (fg.equalsIgnoreCase("solo") && num_ck != null) { sbFilter.append(" and ck.num_cheque = '"); sbFilter.append(num_ck); sbFilter.append("'"); }
if (fg.trim().equals("") && num_ck != null) { sbFilter.append(" and decode(substr(ck.num_cheque,1,1),'T',0,'A',0,to_number(ck.num_cheque)) >= "); sbFilter.append(num_ck); }
if (fg.trim().equals("") && !num_ckHasta.trim().equals("")) { sbFilter.append(" and decode(substr(ck.num_cheque,1,1),'T',0,'A',0,to_number(ck.num_cheque)) <= "); sbFilter.append(num_ckHasta); }
if (fecha_emi != null) { sbFilter.append(" and trunc(ck.f_emision) >= to_date('"); sbFilter.append(fecha_emi); sbFilter.append("', 'dd/mm/yyyy')"); }

sbSql.append("select to_char(ck.f_emision, 'dd/mm/yyyy') fecha_emision, to_char(ck.f_emision, 'dd') dia, '**' || upper(nvl(ck.beneficiario2,ck.beneficiario)) || '**' beneficiario, upper(ck.beneficiario) beneficiarioDet, ck.num_cheque, ck.cuenta_banco, ck.cod_banco, ck.cod_compania, '**'||trim(to_char(ck.monto_girado, '999,999,999.99'))||'**' monto_girado_formatted, ck.monto_girado, ck.che_user, '**' || upper(ck.monto_palabras) || '**' palabra/*, upper(ck.beneficiario2) beneficiario2*/, b.nombre, to_char(ck.f_emision,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes, to_char(ck.f_emision, 'yyyy') anio, to_char(sysdate, 'dd/mm/yyyy') current_date");
/*sbSql.append(", (case when (select count(tdck.monto_renglon) from ");
sbSql.append(tableH);
sbSql.append(" tck, ");
sbSql.append(tableD);
sbSql.append(" tdck, tbl_con_banco b, tbl_con_cuenta_bancaria cb where tdck.cuenta_banco = tck.cuenta_banco and tdck.cod_banco = tck.cod_banco and tdck.compania = tck.cod_compania and tdck.num_cheque = tck.num_cheque and tck.cuenta_banco = cb.cuenta_banco and tck.cod_compania = cb.compania and tck.cod_banco = cb.cod_banco and cb.cod_banco = b.cod_banco and cb.compania = b.compania and cb.cod_banco = ck.cod_banco and cb.compania = ck.cod_compania and tck.cuenta_banco = ck.cuenta_banco and tck.num_cheque = ck.num_cheque) >= 10 then 'VER ANEXO' else ' ' end) ver_anexo");
sbSql.append(", trim(to_char((select sum(nvl(monto_renglon, 0)) from ");
sbSql.append(tableD);
sbSql.append(" where imprimir = 'S' and num_cheque = ck.num_cheque and cod_banco = ck.cod_banco and compania = ck.cod_compania and cuenta_banco = ck.cuenta_banco), '999,999,999.99')) monto_anexo");*/
sbSql.append(", nvl(c.num_id_beneficiario, ' ') cod_beneficiario, (case when ck.ruc is null then ' ' else 'RUC. /'|| ck.ruc || '/' || ck.dv end) ruc, cb.cg_1_cta1||cb.cg_1_cta2||cb.cg_1_cta3||cb.cg_1_cta4||cb.cg_1_cta5||cb.cg_1_cta6 cuentaBanco, ct.descripcion descBanco, getckfacturas(ck.num_cheque, ck.cod_banco, ck.cuenta_banco, ck.cod_compania) as factura, nvl(ck.observacion, ' ') observacion, ck.tipo_orden from ");
sbSql.append(tableH);
sbSql.append(" ck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_cxp_orden_de_pago c, tbl_con_catalogo_gral ct where /*ck.che_user = '");
sbSql.append(userName);
sbSql.append("' and /*Se activa filtro el mismo es util cuando varios usuarios generan cheques.*/ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and c.anio = ck.anio and c.num_orden_pago = ck.num_orden_pago and c.cod_compania = ck.cod_compania and ck.tipo_pago = 1");
sbSql.append(sbFilter);
sbSql.append(" and cb.compania = ct.compania and cb.cg_1_cta1 = ct.cta1 and cb.cg_1_cta2 = ct.cta2 and cb.cg_1_cta3 = ct.cta3 and cb.cg_1_cta4 = ct.cta4 and cb.cg_1_cta5 = ct.cta5 and cb.cg_1_cta6 = ct.cta6 order by ck.num_cheque");
al = SQLMgr.getDataList(sbSql.toString());

iAnexo.clear();
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdoDet = (CommonDataObject) al.get(i);
	if (!UserDet.getUserProfile().contains("0") && !cdoDet.getColValue("che_user").equals(userName)) throw new Exception("El Cheque no puede ser re-impresó por otro usuario!");
	OrdenPago OP = new OrdenPago();
	if ((i+1) < 10) key = "00"+(i+1);
	else if ((i+1) < 100) key = "0"+(i+1);
	else key = ""+(i+1);
	OP.setCdo(cdoDet);
	sbSql = new StringBuffer();
	sbSql.append("select a.*, rownum num_renglon from (select /*dck.num_renglon,*/ ck.num_cheque, sum(dck.monto_renglon) monto_renglon, dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4 cuenta, dck.descripcion, nvl(dck.descripcion, ct.descripcion)||(select (select ' - '||nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) from tbl_fac_factura z where codigo = dck.num_factura and compania = ck.cod_compania and ck.tipo_orden = 1) descCuenta, dck.num_factura from ");
	sbSql.append(tableH);
	sbSql.append(" ck, ");
	sbSql.append(tableD);
	sbSql.append(" dck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_con_catalogo_gral ct where /*dck.imprimir = 'N' and ck.che_user = '");
	sbSql.append(userName);
	sbSql.append("' and*/ dck.cuenta_banco = ck.cuenta_banco and dck.cod_banco = ck.cod_banco and dck.compania = ck.cod_compania and dck.num_cheque = ck.num_cheque and ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and dck.compania = ct.compania and dck.cuenta1 = ct.cta1 and dck.cuenta2 = ct.cta2 and dck.cuenta3 = ct.cta3 and dck.cuenta4 = ct.cta4 and dck.cuenta5 = ct.cta5 and dck.cuenta6 = ct.cta6 and ck.num_cheque = '");
	sbSql.append(cdoDet.getColValue("num_cheque"));
	sbSql.append("' and trunc(ck.f_emision) >= to_date('");
	sbSql.append(cdoDet.getColValue("fecha_emision"));
	sbSql.append("', 'dd/mm/yyyy') and ck.cod_banco = '");
	sbSql.append(cdoDet.getColValue("cod_banco"));
	sbSql.append("' and ck.cuenta_banco = '");
	sbSql.append(cdoDet.getColValue("cuenta_banco"));
	sbSql.append("' and ck.tipo_pago = 1 group by ck.num_cheque, dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4, dck.descripcion, nvl(dck.descripcion, ct.descripcion), ck.cod_compania, ck.tipo_orden, dck.num_factura");
	if(!cdoDet.getColValue("tipo_orden").equals("4")) sbSql.append(" having sum(dck.monto_renglon) > 0");
	sbSql.append(" order by ck.num_cheque, dck.num_factura /*, dck.num_renglon*/) a");
	OP.setAlDet(SQLMgr.getDataList(sbSql.toString()));
	OP.getCdo().setSql(sbSql.toString());

	try {
		htCK.put(key, OP);
	} catch (Exception e) {
		System.out.println("Unable to addget item "+key);
	}
}



if (request.getMethod().equalsIgnoreCase("GET"))
{
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

	float width = 72 * 7.25f;//522 //7.323f;//527.256
	float height = 72 * 8.4f;//604.8
	boolean isLandscape = false;
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
	int fontSize = 10;
	int dFontSize = 8;
	float cHeight = 14.0f;
	float cdHeight = 12.0f;
	float ckHeight = 72 * 3.6875f;//265.5
	float ckdHeight = 72 * 4.8125f;//346.5

	Vector dHeader = new Vector();
		dHeader.addElement("36");
		dHeader.addElement("210");
		dHeader.addElement("100");
		dHeader.addElement("35");
		dHeader.addElement("53");
		dHeader.addElement("88");

	Vector detail = new Vector();
		detail.addElement(".03");
		detail.addElement(".50");
		detail.addElement(".24");
		detail.addElement(".10");
		detail.addElement(".10");
		detail.addElement(".03");

	Vector anexo = new Vector();
		anexo.addElement(".03");
		anexo.addElement(".20");
		anexo.addElement(".20");
		anexo.addElement(".20");
		anexo.addElement(".14");
		anexo.addElement(".20");
		anexo.addElement(".03");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,null);

	if (htCK.size() != 0) al = CmnMgr.reverseRecords(htCK);
	for (int i=0; i<htCK.size(); i++) {
		key = al.get(i).toString();
		OrdenPago objOP = (OrdenPago) htCK.get(key);
		CommonDataObject cdoCK = (CommonDataObject) objOP.getCdo();

		pc.setVAlignment(0);
		pc.setFont(fontSize,1);
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable(true);

			//- - - - - - - - - - - - - - - - - - - -   C H E C K   - - - - - - - - - - - - - - - - - - - -
			//-----> top space
			pc.addCols(" ",0,dHeader.size(),27.0f);

			//-----> check number
			//pc.addCols(cdoCK.getColValue("num_cheque"),2,4,cHeight);
			//pc.addCols(" ",0,2);
			pc.addCols(" ",2,dHeader.size(),cHeight);

			//-----> date
			pc.addCols(" ",0,2,cHeight);
			pc.addCols(cdoCK.getColValue("dia")+" "+cdoCK.getColValue("mes"),2,1);
			pc.addCols(" ",0,1);
			pc.addCols(cdoCK.getColValue("anio"),0,1);
			pc.addCols(" ",0,1);

			//-----> space between date and name/amount
			pc.addCols(" ",0,dHeader.size(),35.0f);

			//-----> name/amount
			pc.addCols(cdoCK.getColValue("beneficiario"),0,2,32.0f);
			pc.addCols(cdoCK.getColValue("monto_girado_formatted"),0,4);

			//-----> space between name/amount and amount in words
			pc.addCols(" ",0,dHeader.size(),26.0f);

			//-----> amount in words
			pc.addCols(" ",0,1,cHeight * 2);
			pc.addCols(cdoCK.getColValue("palabra"),0,4);
			pc.addCols(" ",0,1);

			//-----> additional name
			pc.addCols(" ",0,1,32.0f);
			pc.addCols(cdoCK.getColValue("beneficiario2"),0,2);
			pc.addCols(" ",0,3);

			//-----> bottom space
			pc.addCols(" ",0,dHeader.size(),ckHeight - pc.getTableHeight());
			//System.out.println("******************************************************************** chk "+pc.getTableHeight());
			//- - - - - - - - - - - - - - - - - - - -   C H E C K   - - - - - - - - - - - - - - - - - - - -


		float availHeight = ckdHeight;
		//System.out.println("******************************************************************** initial availHeight "+availHeight);


		//- - - - - - - - - - - - - -   C H E C K   F O O T E R   N O T E   - - - - - - - - - - - - - -
		pc.setVAlignment(0);
		pc.setFont(dFontSize,1);
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detFinal",true);

		if (!cdoCK.getColValue("observacion").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("Nota: "+cdoCK.getColValue("observacion"),0,detail.size() - 2);
			pc.addCols(" ",0,1);
			availHeight -= pc.getTableHeight();
			//System.out.println("******************************************************************** - note "+pc.getTableHeight());

		}
		//- - - - - - - - - - - - - -   C H E C K   F O O T E R   N O T E   - - - - - - - - - - - - - -


		//- - - - - - - - - - - - - - - -   C H E C K   D E T A I L S   - - - - - - - - - - - - - - - -
		pc.setVAlignment(0);
		pc.setFont(dFontSize,1);
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detail",true);
			//-----> detail's header space
			pc.addCols(" ",0,1,0.0f,null,0.0f,0.1f,0.0f,0.0f);
			pc.addCols(" ",0,dHeader.size() - 2);
			pc.addCols(" ",0,1,null,0.0f,0.1f,0.0f,0.0f);

		if (!cdoCK.getColValue("factura").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PARA CANCELAR FACTURA(S) NO. "+cdoCK.getColValue("factura"),0,detail.size() - 2);
			pc.addCols(" ",0,1);

		}

		if (!cdoCK.getColValue("beneficiarioDet").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PAGO A FAVOR DE: "+cdoCK.getColValue("beneficiarioDet"),0,detail.size() - 2);
			pc.addCols(" ",0,1);

		}

			pc.addCols(" ",1,dHeader.size());
			//System.out.println("******************************************************************** det0 "+pc.getTableHeight());

		float dHeight = pc.getTableHeight();

		pc.setNoColumnFixWidth(detail);
		pc.createTable("detailBnk",false);
			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(cdoCK.getColValue("descBanco"),0,1);
			pc.addCols(cdoCK.getColValue("cuentaBanco"),2,1);
			pc.addCols(" ",0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),2,1);
			pc.addCols(" ",0,1);
			availHeight -= pc.getTableHeight();
			//System.out.println("******************************************************************** - bank "+pc.getTableHeight());

		float bnkHeight = pc.getTableHeight();
		availHeight -= (cdHeight * 2) + 72;// 2 lines from footer and blank space for signing
		//System.out.println("******************************************************************** availHeight "+availHeight);

		double amt = 0.00, tAmt = 0.00;
		String renglon = "";
		cdoCK.setSql(objOP.getCdo().getSql());
		for (int j=0; j<objOP.getAlDet().size(); j++) {
			cdo = (CommonDataObject) objOP.getAlDet().get(j);
			amt = Double.parseDouble(cdo.getColValue("monto_renglon"));

			pc.setNoColumnFixWidth(detail);
			pc.createTable("detailTmp",false);
				pc.addCols(" ",0,1);
				pc.addCols(cdo.getColValue("descCuenta"),0,1);
				pc.addCols(cdo.getColValue("cuenta"),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_renglon")),2,1);
				pc.addCols(" ",0,2);

			if (availHeight < (dHeight + pc.getTableHeight() + bnkHeight)) {

				if (j == 0) renglon = "0";
				break;

			} else {

				pc.useTable("detail");
					pc.addTableToCols("detailTmp",1,detail.size());
					//System.out.println("******************************************************************** det loop "+pc.getTableHeight());

				tAmt += amt;
				renglon = cdo.getColValue("num_renglon");//start anexo after this row
				dHeight = pc.getTableHeight();//last detail table height

			}
		}//for j

		pc.useTable("detail");
			pc.addTableToCols("detailBnk",1,detail.size());
			//System.out.println("******************************************************************** det bank "+pc.getTableHeight()+" avail "+availHeight);

			if ((availHeight - pc.getTableHeight()) > 0) pc.addCols(" ",0,detail.size(),availHeight - pc.getTableHeight());
			//System.out.println("******************************************************************** det filled "+pc.getTableHeight());
		//- - - - - - - - - - - - - - - -   C H E C K   D E T A I L S   - - - - - - - - - - - - - - - -


		//- - - - - - - - - - - - -   C H E C K   D E T A I L   F O O T E R   - - - - - - - - - - - - -
		pc.setVAlignment(0);
		pc.setFont(dFontSize,1);
		pc.setNoColumnFixWidth(anexo);
		pc.createTable("anexo",true);

			pc.addCols(" ",0,1);
			pc.addCols(cdoCK.getColValue("current_date"),0,1);
			Double ckAmt = Double.parseDouble(cdoCK.getColValue("monto_girado"));
			if (renglon.trim().equals("") || (ckAmt - tAmt) == 0) pc.addCols(" ",0,2);
			else {

				try {
					cdoCK.addColValue("renglon",renglon);//last printed row
					cdoCK.addColValue("total_printed",CmnMgr.getFormattedDecimal(tAmt));
					cdoCK.addColValue("anexo_amt",CmnMgr.getFormattedDecimal(ckAmt - tAmt));
					iAnexo.put(cdoCK.getColValue("num_cheque"),cdoCK);
				} catch(Exception e) {
					System.out.println("Unable to add Anexo!");
				}
				pc.addCols("VER ANEXO",1,1);
				pc.addCols(CmnMgr.getFormattedDecimal(ckAmt - tAmt),1,1);

			}
			pc.addCols("TOTAL",2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),1,1);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,1);
			pc.addCols(userName,0,1);
			pc.addCols(cdoCK.getColValue("cod_beneficiario"),1,1);
			pc.addCols(cdoCK.getColValue("num_cheque"),1,1);
			pc.addCols(cdoCK.getColValue("ruc"),0,2);
			pc.addCols(" ",0,1);
			//System.out.println("******************************************************************** det footer "+pc.getTableHeight());
		//- - - - - - - - - - - - -   C H E C K   D E T A I L   F O O T E R   - - - - - - - - - - - - -


		pc.useTable("main");
			pc.addTableToCols("detail",1,dHeader.size());
			pc.addTableToCols("anexo",1,dHeader.size());
			pc.addTableToCols("detFinal",1,dHeader.size());

		pc.addNewPage();
		pc.addTable();
	}
	pc.close();
%>
<html>
<frameset rows="0,*" frameborder="NO" border="0" framespacing="0">
	<frame src="../cxp/has_anexo.jsp?fp=<%=fp%>" name="actionFrame" scrolling="NO" noresize/>
	<frame src="<%=redirectFile%>" name="printFrame"/>
</frameset>
<noframes></noframes>
</html>
<%
}//get
%>
