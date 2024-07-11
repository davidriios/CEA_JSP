<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="htPM" scope="session" class="java.util.Hashtable"/>
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
ArrayList alBK = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fp = request.getParameter("fp");
String key = "";
String companyId = (String)session.getAttribute("_companyId");
int qtyToPrint = Integer.parseInt((request.getParameter("qtyToPrint")==null || request.getParameter("qtyToPrint").equals(""))?"1":request.getParameter("qtyToPrint"));
String idDoc = request.getParameter("idDoc")==null?"":request.getParameter("idDoc");

CommonDataObject cdoBC = SQLMgr.getData("select get_sec_comp_param("+companyId+", 'PRINT_COD_BARRA_MARBETE') as show_bc from dual");
if (cdoBC == null) {
  cdoBC = new CommonDataObject();
  cdoBC.addColValue("show_bc","N");
}
boolean showBC = cdoBC.getColValue("show_bc")!=null && (cdoBC.getColValue("show_bc").equals("S")||cdoBC.getColValue("show_bc").equals("Y"));

System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "+request.getParameter("qtyToPrint"));

if (qtyToPrint < 1) qtyToPrint = 1;
if (fp == null) fp = "";
int headerFontSize = 8, bodyFontSize = 7;
if(fp.equals("POS")){
	CommonDataObject cd = SQLMgr.getData("select 'TEL.  '||nvl(telefono,'____ - ______') || ' RUC. ' || ruc as company_telephone, nombre_corto as company_name from tbl_sec_compania where codigo = "+companyId);
	if (htPM.size() > 0) alBK = CmnMgr.reverseRecords(htPM, false);
	for (int i=0; i<htPM.size(); i++){
		key = alBK.get(i).toString();
		CommonDataObject _cdo = (CommonDataObject) htPM.get(key);
		CommonDataObject _cd = new CommonDataObject();
		if(_cdo.getColValue("dosis")==null || _cdo.getColValue("dosis").equals("")) continue;
		_cd.addColValue("company_telephone", cd.getColValue("company_telephone"));
		_cd.addColValue("company_name", cd.getColValue("company_name"));
		_cd.addColValue("pacient_name", "NOMBRE:   "+_cdo.getColValue("nombre_cliente"));
		_cd.addColValue("doctor_name", "DOCTOR:   "+_cdo.getColValue("doctor"));
				
		_cd.addColValue("expiration_date", "F.EXP: "+(_cdo.getColValue("fecha_expira")==null?"":_cdo.getColValue("fecha_expira")));
				
		_cd.addColValue("currrent_date", "FECHA: "+cDateTime);
		_cd.addColValue("drug_name", "Rx.  "+_cdo.getColValue("descripcion"));
		_cd.addColValue("dose", "DOSIS:   "+_cdo.getColValue("dosis"));
		_cd.addColValue("cod_barra", _cdo.getColValue("cod_barra"));
		_cd.addColValue("cod_articulo", _cdo.getColValue("codigo"));
		_cd.addColValue("notes", "NB.:   ");
		_cd.addColValue("created_by", (String) session.getAttribute("_userName"));
		_cd.addColValue("sala", "");
		al.add(_cd);
		System.out.println("loadding to marbete> .... "+_cdo.getKey());
		}
} else {

if (idDoc.trim().equals("")) throw new Exception("El número del documento es inválido!");

/*sbSql.append("select 'TEL.  '||nvl(c.telefono,'____ - ______') || ' RUC. ' || ruc as company_telephone, c.nombre_corto as company_name,'NOMBRE:   '||m.nombre_cliente as pacient_name, 'DOCTOR:   '||m.doctor as doctor_name, 'F-VENC:   '||to_char(d.fecha_expira,'ddmmyy') expiration_date, 'FECHA:    '||to_char(sysdate,'ddmmyy') as currrent_date, 'Rx.  '|| (case when get_sec_comp_param(d.compania, 'PRINT_COD_BARRA_MARBETE') = 'S' then (select a.tech_descripcion from tbl_inv_articulo a where a.compania = d.compania and a.cod_articulo = d.codigo) else '' end)||d.descripcion as drug_name, 'DOSIS:   '||nvl(d.dosis,' ') as dose, 'NB.:   '||d.observacion as notes, m.usuario_creacion as created_by, nvl(m.sala, '') sala, a.cod_barra from tbl_fac_marbete m, tbl_fac_marbete_det d, tbl_sec_compania c where m.compania = d.compania and m.id = d.id and m.doc_id = d.doc_id and m.compania = c.codigo and m.estado = 'A' and m.doc_id = ");
sbSql.append(idDoc);
sbSql.append(" and c.codigo = ");
sbSql.append(companyId);*/


sbSql.append("select distinct 'TEL.  '||nvl(c.telefono,'____ - ______') || ' RUC. ' || ruc as company_telephone, c.nombre_corto as company_name,'NOMBRE:   '||m.nombre_cliente as pacient_name, 'DOCTOR:   '||m.doctor as doctor_name, 'F.EXP: '||to_char(d.fecha_expira,'dd/mm/yy') expiration_date, 'FECHA: '||to_char(sysdate,'dd/mm/yy') as currrent_date, 'Rx. '|| /*(case when get_sec_comp_param(d.compania, 'PRINT_COD_BARRA_MARBETE') = 'S' then a.tech_descripcion else '' end)||'-'||d.descripcion,*/ decode(a.tech_descripcion,null,d.descripcion, a.tech_descripcion||'-'||a.descripcion) as drug_name, 'DOSIS:   '||nvl(d.dosis,' ') as dose, 'NB.:   '||d.observacion as notes, m.usuario_creacion as created_by, nvl(m.sala, '') sala , a.cod_barra, d.dosis from tbl_fac_marbete m, tbl_fac_marbete_det d, tbl_sec_compania c ,tbl_inv_articulo a where m.compania = d.compania and m.id = d.id and m.doc_id = d.doc_id and m.compania = c.codigo and m.estado = 'A' /**/ and m.doc_id = ");
sbSql.append(idDoc);
sbSql.append(" and c.codigo = ");
sbSql.append(companyId);
sbSql.append(" and a.compania = d.compania and a.cod_articulo = d.codigo and trim(d.dosis) is not null ");
if(fp.equals("FAR")) sbSql.append(" and m.tipo = 'OM'");
else sbSql.append(" and m.tipo = 'FAC'");

al = SQLMgr.getDataList(sbSql.toString());
}
if (request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String logoPath = null;
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	int width  = (int) (72 * 2.9);
	int height = (int) (72 * 1.9);
	//int width  = (int) (72 * 3.41);
	//int height = (int) (72 * 2.2);
	boolean isLandscape = false;
	float leftRightMargin = 7f;
	float topMargin = 5f;
	float bottomMargin = 0.1f;
	float headerFooterFont = 4f;
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
	float cHeight = 11.0f;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector vTblMain = new Vector();
	vTblMain.addElement("100");
	
	Vector vTblDet = new Vector();
	vTblDet.addElement("35");
	vTblDet.addElement("35");
	vTblDet.addElement("30");
	
	pc.setNoColumnFixWidth(vTblMain);
	pc.createTable();
	
	String companyName = "", pacientName="", drugName="", dose= "", notes ="", doctorName="", createdBy="", sala="";
	int cn = 0, pn = 0, dn = 0, dosis=0, nb=0, docn= 0, cb = 0, sl=0;
	float hH = 0.0f, pH=0.0f, dH=0.0f, dosisH = 0.0f, nbH=0.0f, docnH=0.0f,cbH=0.0f, slH=0.0f;
	
    for (int i = 0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject)al.get(i);
		
		companyName = cdo.getColValue("company_name");
		pacientName = cdo.getColValue("pacient_name");
		drugName = cdo.getColValue("drug_name");
		dose = cdo.getColValue("dose");
		notes = cdo.getColValue("notes"); // 
		doctorName = cdo.getColValue("doctor_name");
		createdBy = cdo.getColValue("created_by");
		sala = cdo.getColValue("sala");

		headerFontSize=8;
		bodyFontSize=7;
		
		pc.setNoColumnFixWidth(vTblDet);
		pc.createTable("det");
			pc.setFont(headerFontSize,1); 
			pc.addCols(companyName,1,vTblDet.size(),headerFontSize+4f);
			pc.addCols(cdo.getColValue("company_telephone"),1,vTblDet.size(),headerFontSize+4f);
			
			pc.setFont(bodyFontSize,0);
			pc.addCols(pacientName,0,vTblDet.size(),bodyFontSize+4f);
						
			if(sala!=null && !sala.equals("")){
				pc.addCols(sala,0,vTblDet.size(),bodyFontSize+4f);
			}
			pc.addCols(cdo.getColValue("expiration_date"),0,1);
			pc.addCols(cdo.getColValue("currrent_date"),1,1);
			pc.addCols(createdBy,1,1,bodyFontSize+4f);
			
			pc.addCols(drugName,0,vTblDet.size(),bodyFontSize*2+4f);
			pc.addCols(cdo.getColValue("dose"),0,vTblDet.size(),bodyFontSize*2+4f);
			pc.addCols(doctorName,0,vTblDet.size(),bodyFontSize+4f);
			
			if (showBC && cdo.getColValue("cod_barra")!=null && !cdo.getColValue("cod_barra").trim().equals("")){
			    
				pc.setNoColumn(1);
				pc.createTable("cb");
				pc.addImageCols(pc.getBarCode128(cdo.getColValue("cod_barra"),6.0f, 12.0f),20.0f,1);
			}
					
			pc.resetVAlignment();
			pc.useTable("main");
			for (int q = 0; q<qtyToPrint; q++) {
				pc.addTableToCols("det",0,1);
				if (showBC && cdo.getColValue("cod_barra")!=null && !cdo.getColValue("cod_barra").trim().equals("")) pc.addTableToCols("cb",1,vTblDet.size());
				pc.flushTableBody(true);
				pc.addNewPage();
			} //for q
			
    }
	
	if(al.size()< 1){
	    pc.setVAlignment(1);
		pc.setFont(9,1);
     	pc.addCols("No hay registros! ",1,vTblMain.size(),130f);
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>