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
String referencia = request.getParameter("referencia");

if(referencia==null) referencia = "";	
if(fp==null) fp = "";
if(fg==null) fg = "";
if(cheUser==null) cheUser = "";
if(num_ckHasta==null) num_ckHasta = "";
String tableH = "tbl_con_temp_cheque", tableD = "tbl_con_temp_detalle_cheque";
if(fp.equals("cheque")){
	tableH = "tbl_con_cheque";
	tableD = "tbl_con_detalle_cheque";
}

String showAnexoFact = "0";
float pHeight = 7.375f;
float pWidth = 7.375f;
String ckAlign = "C";
float ckTopSpace = 35.0f;
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(cod_compania);
sbSql.append(",'CXP_CHECK_ANSIX97_HEIGHT'),'-') as height, nvl(get_sec_comp_param(");
sbSql.append(cod_compania);
sbSql.append(",'CXP_CHECK_ANSIX97_WIDTH'),'-') as width, nvl(get_sec_comp_param(");
sbSql.append(cod_compania);
sbSql.append(",'CXP_CHECK_ANSIX97_ALIGN'),'-') as align, nvl(get_sec_comp_param(");
sbSql.append(cod_compania);
sbSql.append(",'CXP_CHECK_ANSIX97_TOP_SPACE'),'-') as top_space, nvl(get_sec_comp_param(");
sbSql.append(cod_compania);
sbSql.append(",'CXP_CHECK_FONT'),'COURIER') as check_font from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p != null) {

	if (!p.getColValue("height").equals("-")) {
		try { pHeight = Float.parseFloat(p.getColValue("height")); } catch(Exception ex) { }
		if (pHeight < 7.375f) pHeight = 7.375f;
	}
	if (!p.getColValue("width").equals("-")) {
		try { pWidth = Float.parseFloat(p.getColValue("width")); } catch(Exception ex) { }
		if (pWidth < 7.375f) pWidth = 7.375f;
	}
	if (!p.getColValue("align").equals("-")) ckAlign = p.getColValue("align");
	if (!p.getColValue("top_space").equals("-")) {
		try { ckTopSpace = Float.parseFloat(p.getColValue("top_space")); } catch(Exception ex) { }
	}

}

if (!cheUser.trim().equals("")) userName = cheUser;
sbFilter.append(" and ck.estado_cheque != 'A' ");
if (cod_compania != null) { sbFilter.append(" and ck.cod_compania = "); sbFilter.append(cod_compania); }
if (cod_banco != null) { sbFilter.append(" and ck.cod_banco = '"); sbFilter.append(cod_banco); sbFilter.append("'"); }
if (cuenta_banco != null) { sbFilter.append(" and ck.cuenta_banco = '"); sbFilter.append(cuenta_banco); sbFilter.append("'"); }
if (fg.equalsIgnoreCase("solo") && num_ck != null) { sbFilter.append(" and ck.num_cheque = '"); sbFilter.append(num_ck); sbFilter.append("'"); }
if (fg.trim().equals("") && num_ck != null) { sbFilter.append(" and decode(substr(ck.num_cheque,1,1),'-',0,'T',0,'A',0,to_number(ck.num_cheque)) >= "); sbFilter.append(num_ck); }
if (fg.trim().equals("") && !num_ckHasta.trim().equals("")) { sbFilter.append(" and decode(substr(ck.num_cheque,1,1),'-',0,'T',0,'A',0,to_number(ck.num_cheque)) <= "); sbFilter.append(num_ckHasta); }
if (fecha_emi != null) { sbFilter.append(" and trunc(ck.f_emision) >= to_date('"); sbFilter.append(fecha_emi); sbFilter.append("', 'dd/mm/yyyy')"); }
if(referencia!=null&& !referencia.trim().equals("")){ sbFilter.append(" and ck.referencia = '");sbFilter.append(referencia);sbFilter.append("'");}

sbSql = new StringBuffer();
sbSql.append("select to_char(ck.f_emision, 'ddmmyyyy') fecha_emision, to_char(ck.f_emision, 'dd') dia, '**' || upper(nvl(ck.beneficiario2,ck.beneficiario)) || '**' beneficiario, upper(ck.beneficiario) beneficiarioDet, ck.num_cheque, ck.cuenta_banco, ck.cod_banco, ck.cod_compania, '**'||trim(to_char(ck.monto_girado, '999,999,999.99'))||'**' monto_girado_formatted, ck.monto_girado, ck.che_user, '**' || upper(ck.monto_palabras) || '**' palabra/*, upper(ck.beneficiario2) beneficiario2*/, b.nombre, to_char(ck.f_emision,'mm') mes, to_char(ck.f_emision, 'yyyy') anio, to_char(sysdate, 'dd/mm/yyyy') current_date");
/*sbSql.append(", (case when (select count(tdck.monto_renglon) from ");
sbSql.append(tableH);
sbSql.append(" tck, ");
sbSql.append(tableD);
sbSql.append(" tdck, tbl_con_banco b, tbl_con_cuenta_bancaria cb where tdck.cuenta_banco = tck.cuenta_banco and tdck.cod_banco = tck.cod_banco and tdck.compania = tck.cod_compania and tdck.num_cheque = tck.num_cheque and tck.cuenta_banco = cb.cuenta_banco and tck.cod_compania = cb.compania and tck.cod_banco = cb.cod_banco and cb.cod_banco = b.cod_banco and cb.compania = b.compania and cb.cod_banco = ck.cod_banco and cb.compania = ck.cod_compania and tck.cuenta_banco = ck.cuenta_banco and tck.num_cheque = ck.num_cheque) >= 10 then 'VER ANEXO' else ' ' end) ver_anexo");
sbSql.append(", trim(to_char((select sum(nvl(monto_renglon, 0)) from ");
sbSql.append(tableD);
sbSql.append(" where imprimir = 'S' and num_cheque = ck.num_cheque and cod_banco = ck.cod_banco and compania = ck.cod_compania and cuenta_banco = ck.cuenta_banco), '999,999,999.99')) monto_anexo");*/
sbSql.append(", decode(c.generado,'H',nvl((select reg_medico from tbl_adm_medico where codigo=c.cod_medico),c.num_id_beneficiario),nvl(c.num_id_beneficiario, ' ')) as cod_beneficiario, (case when ck.ruc is null then ' ' else 'RUC. /'|| ck.ruc || '/' || ck.dv end) ruc, cb.cg_1_cta1||cb.cg_1_cta2||cb.cg_1_cta3||cb.cg_1_cta4||cb.cg_1_cta5||cb.cg_1_cta6 cuentaBanco, ct.descripcion descBanco, join(cursor(select distinct num_factura from ");
sbSql.append(tableD);
sbSql.append(" where num_cheque = ck.num_cheque and cod_banco = ck.cod_banco and compania = ck.cod_compania and cuenta_banco = ck.cuenta_banco),', ') as factura, nvl(ck.observacion, ' ') observacion,c.generado as tipoOp from ");
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
	sbSql.append("select a.*, rownum num_renglon from (select /*dck.num_renglon,*/ ck.num_cheque, sum(dck.monto_renglon) monto_renglon, dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4 cuenta, dck.descripcion, nvl(dck.descripcion, ct.descripcion)||decode('");
	sbSql.append(cdoDet.getColValue("tipoOp"));
	sbSql.append("','H', (select (select ' - '||nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) from tbl_fac_factura z where codigo = dck.num_factura and compania = ck.cod_compania),' ') descCuenta, dck.num_factura from ");
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
	sbSql.append("' and ck.tipo_pago = 1 group by ck.num_cheque, dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4, dck.descripcion, nvl(dck.descripcion, ct.descripcion), ck.cod_compania, ck.tipo_orden, dck.num_factura having sum(dck.monto_renglon) > 0 order by ck.num_cheque, dck.num_factura, 3) a");
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

	float ckWidth = 7.375f;//check standart width size
	float pCk = 1f;
	float pCkL = 0f;
	float pCkR = 0f;
	if (pWidth > ckWidth) {
		pCk = ckWidth / pWidth;
System.out.println("-------------------->pCk="+pCk);
		float tmp = Math.round(pCk * 1000);
System.out.println("-------------------->tmp="+tmp);
		pCk = tmp / 1000;
System.out.println("-------------------->pCk="+pCk);
		if (ckAlign.equalsIgnoreCase("R")) pCkL = 1 - pCk;
		else if (ckAlign.equalsIgnoreCase("L")) pCkR = 1 - pCk;
		else {
			pCkL = (1 - pCk) / 2;
			pCkR = (1 - pCk) / 2;
		}
	}
	float width = 72 * ((pWidth > ckWidth)?pWidth:ckWidth);
	float height = 72 * pHeight;
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
	int fontSize = 11;
	int dFontSize = 9;
	float cHeight = fontSize + 4.0f;
	float cdHeight = dFontSize + 4.0f;
	float ckHeight = 265.5f;
	float ckdHeight = height - ckHeight;

	Vector dMain = new Vector();
		dMain.addElement(""+pCkL);
		dMain.addElement(""+pCk);
		dMain.addElement(""+pCkR);

	Vector dHeader = new Vector();
		dHeader.addElement("6.75");
		dHeader.addElement("63");
		dHeader.addElement("117");
		dHeader.addElement("171");
		dHeader.addElement("29.9");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("17.15");
		dHeader.addElement("6.15");

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
		pc.setFont(p.getColValue("check_font"),fontSize,0);
		pc.setNoColumnFixWidth(dMain);
		pc.createTable(true);

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("check",true,0,0f,ckWidth * 72);//,15,0f

			//- - - - - - - - - - - - - - - - - - - -   C H E C K   - - - - - - - - - - - - - - - - - - - -
			//-----> top space
			if (ckHeight < (ckTopSpace + (5 * cHeight) + 40.0f)) ckTopSpace = 35.0f;
			pc.addCols(" ",0,dHeader.size(),ckTopSpace);

			//-----> check number
			//pc.addCols(" ",0,5);
			//pc.addCols(cdoCK.getColValue("num_cheque"),2,8,cHeight);
			//pc.addCols(" ",0,1);
			pc.addCols(" ",2,dHeader.size(),cHeight);

			//-----> date
			pc.addCols("",0,5,cHeight);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(0,1),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(1,2),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(2,3),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(3,4),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(4,5),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(5,6),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(6,7),1,1);
			pc.addCols(cdoCK.getColValue("fecha_emision").substring(7,8),1,1);
			pc.addCols("",0,1);

			//-----> space between date and name/amount
			pc.addCols(" ",0,dHeader.size(),30.0f);

			//-----> name/amount
			pc.addCols(" ",0,2,cHeight);
			pc.addCols(cdoCK.getColValue("beneficiario"),0,3);
			pc.addCols(" ",0,2);
			pc.addCols(cdoCK.getColValue("monto_girado_formatted"),0,6);
			pc.addCols(" ",0,1);

			//-----> space between name/amount and amount in words
			pc.addCols(" ",0,dHeader.size(),10.0f);

			//-----> amount in words
			pc.addCols(" ",0,2,cHeight);
			pc.addCols(cdoCK.getColValue("palabra"),0,8);
			pc.addCols(" ",0,4);

			//-----> additional name
			pc.addCols(" ",0,3,cHeight);
			pc.addCols(cdoCK.getColValue("beneficiario2"),0,10);
			pc.addCols(" ",0,1);

			//-----> bottom space
			pc.setVAlignment(2);
			pc.addCols("_",0,dHeader.size() - 1,ckHeight - pc.getTableHeight());//
			pc.addCols("_",2,1);
			pc.setVAlignment(0);
			//System.out.println("******************************************************************** chk "+pc.getTableHeight());
			//- - - - - - - - - - - - - - - - - - - -   C H E C K   - - - - - - - - - - - - - - - - - - - -


		float availHeight = ckdHeight;
		availHeight -= 72 + (cdHeight * 2);//blank space for signing and anexo
		//System.out.println("******************************************************************** ckdHeight "+ckdHeight+" initial availHeight "+availHeight);


		//- - - - - - - - - - - - - -   C H E C K   F O O T E R   N O T E   - - - - - - - - - - - - - -
		pc.setVAlignment(0);
		pc.setFont(dFontSize,0);
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

		float fHeight = 0f;
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detailFac",false);
		if (!cdoCK.getColValue("factura").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PARA CANCELAR FACTURA(S) NO. "+cdoCK.getColValue("factura")
//+" FKLASFKAS KHFASFKHSKFH KASHFKASHDKFHAKSHFKASHKDFHAS KF DFHAKLSHDFKAHSKLDFHSKLFHK  LFLSJFLASJLFFJ LASJFLSJSJFL JASFLSJ LS  LSJ FLASJ FLASJLFJASÑLFJ ASLJFLASJFL ASLFJ ASLFJ LASJFKL ASJFLAJ LÑLSFJ LAJFKL ASLDF AÑLS FLAÑSHFLSAHFKLASFDL ASFKLJADSLFJ ASÑLDFJ ASÑLDFJAÑLSFJLASKJF LÑSDÑF JLASJFLASJFLÑ AJSÑDFLASÑLDJFL SKDJ FLKSJFLJSL FJSLJ FLSJF LSJF DSLKFJ KLDSJ FLSÑJLSJF LJLDSJ KL S L S  DSJLF JSLFKJ ASÑLFJASLFJ KLASFJ LADSJ KLASDJ FSLAJFL AKSJDFKLSADJ KLASJ FÑLKDSJAF KLASJDFLÑASJFÑLASJF LJASKL FJ ASKLASJ LASJF LASKJÑLASJ LFÑJASÑLJFKÑL ADSJFÑ LSDKFJDSKÑLJ FKÑLSAJ FLÑDSJ ENNNNNDDDDD"
//+" SFJALSDF SF ASJKLDF ASKLFLS FLJASLDFJ LASÑJ FÑLAJSDLFJ LASJ DLJASLFJLSJL FJASÑLJ ÑLFJÑLJ LÑJFÑJ ASLDFJ ÑLSJ LFÑJASÑLJ FLAJ SLFLAS END"
			,0,detail.size() - 2);
			pc.addCols(" ",0,1);
			fHeight = pc.getTableHeight();

		}

		pc.setNoColumnFixWidth(detail);
		pc.createTable("detailBenef",false);
		if (!cdoCK.getColValue("beneficiarioDet").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PAGO A FAVOR DE: "+cdoCK.getColValue("beneficiarioDet"),0,detail.size() - 2);
			pc.addCols(" ",0,1);
			availHeight -= pc.getTableHeight();
			//System.out.println("******************************************************************** - note "+pc.getTableHeight());

		}


		//- - - - - - - - - - - - - - - -   C H E C K   D E T A I L S   - - - - - - - - - - - - - - - -
		float reserved = dFontSize + 4;
		pc.setVAlignment(0);
		pc.setFont(dFontSize,0);
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detail",false);
			//-----> detail's header space
			pc.addCols(" ",0,1,40.5f,null,0.0f,0.1f,0.0f,0.0f);
			pc.addCols(" ",0,detail.size() - 2);
			pc.addCols(" ",0,1,null,0.0f,0.1f,0.0f,0.0f);
			availHeight -= pc.getTableHeight();

			if (fHeight <= (availHeight - reserved)) {

				pc.addTableToCols("detailFac",1,detail.size());
				availHeight -= fHeight;

			} else {

				pc.addTableToCols("detailFac",1,detail.size(),(availHeight - (reserved * 2)));

				pc.addCols(" ",0,1);
				pc.addCols("* * * VER LISTADO COMPLETO DE FACTURAS EN EL ANEXO * * *",1,detail.size() - 2);//reserved
				pc.addCols(" ",0,1);

				availHeight = 0;
				showAnexoFact = "1";

			}

			pc.addTableToCols("detailBenef",1,detail.size());

			pc.addCols(" ",1,detail.size());//reserved
			availHeight -= reserved;
			//System.out.println("******************************************************************** det0 "+pc.getTableHeight());


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
			float tmpHeight = pc.getTableHeight();

			if (tmpHeight > availHeight) {

				if (j == 0) renglon = "0";
				break;

			}

			pc.useTable("detail");
			pc.addTableToCols("detailTmp",1,detail.size());
			//System.out.println("******************************************************************** tmpHeight "+tmpHeight+" det loop "+pc.getTableHeight());
			availHeight -= tmpHeight;

			tAmt += amt;
			renglon = cdo.getColValue("num_renglon");//start anexo after this row

		}//for j
		double tmp = Math.round(tAmt * 100);
		tAmt = tmp / 100;

		pc.useTable("detail");
		pc.addTableToCols("detailBnk",1,detail.size());
		//System.out.println("******************************************************************** det bank "+pc.getTableHeight()+" avail "+availHeight);

		if (availHeight > 0) pc.addCols(" ",0,detail.size(),availHeight);
		//System.out.println("******************************************************************** det filled "+pc.getTableHeight());
		//- - - - - - - - - - - - - - - -   C H E C K   D E T A I L S   - - - - - - - - - - - - - - - -


		//- - - - - - - - - - - - -   C H E C K   D E T A I L   F O O T E R   - - - - - - - - - - - - -
		pc.setVAlignment(0);
		pc.setFont(dFontSize,0);
		pc.setNoColumnFixWidth(anexo);
		pc.createTable("anexo",true);

			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(cdoCK.getColValue("current_date"),0,1);
			Double ckAmt = Double.parseDouble(cdoCK.getColValue("monto_girado"));
			//System.out.println("------------------------->"+ckAmt+" - "+tAmt);
			if ((renglon.trim().equals("") || (ckAmt - tAmt) == 0) && showAnexoFact.equals("0")) pc.addCols(" ",0,2);
			else {

				try {
					cdoCK.addColValue("renglon",renglon);//last printed row
					cdoCK.addColValue("total_printed",CmnMgr.getFormattedDecimal(tAmt));
					cdoCK.addColValue("anexo_amt",CmnMgr.getFormattedDecimal(ckAmt - tAmt));
					cdoCK.addColValue("show_fact",showAnexoFact);
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

			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(userName,0,1);
			pc.addCols(cdoCK.getColValue("cod_beneficiario"),1,1);
			pc.addCols(cdoCK.getColValue("num_cheque"),1,1);
			pc.addCols(cdoCK.getColValue("ruc"),0,2);
			pc.addCols(" ",0,1);
			//System.out.println("******************************************************************** det footer "+pc.getTableHeight());
		//- - - - - - - - - - - - -   C H E C K   D E T A I L   F O O T E R   - - - - - - - - - - - - -


		pc.useTable("main");
			pc.addCols(" ",0,1);
			pc.addTableToCols("check",0,1);
			pc.addCols(" ",0,1);
			pc.addTableToCols("detail",1,dMain.size());
			pc.addTableToCols("anexo",1,dMain.size());
			pc.addTableToCols("detFinal",1,dMain.size());

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
