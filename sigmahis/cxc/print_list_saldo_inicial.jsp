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
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String tipoCliente = request.getParameter("tipoCliente");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String compania =  compania = (String) session.getAttribute("_companyId");
if (fg == null) fg = "";
if (appendFilter == null) appendFilter = "";
if (tipoCliente == null) tipoCliente = "";
StringBuffer sbSql = new StringBuffer();

sbSql.append("select x.* from (select s.id, s.tipo_cliente, nvl(s.saldo_actual,0)saldo_actual, s.compania, s.usuario_creacion, s.id_cliente ");

if (tipoCliente.equals("A")){
  sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = s.pac_id) as nombre_paciente ");
  sbSql.append(", case when s.tipo_cliente in ('A') then (select nombre from tbl_adm_empresa where codigo = s.id_cliente)");
}else{
sbSql.append(", '' as nombre_paciente, case when s.tipo_cliente in ('P','A')  then   decode(s.pac_id,null,(select nombre from tbl_adm_empresa where codigo = s.id_cliente), (select nombre_paciente from vw_adm_paciente where pac_id = s.pac_id)) ");
}
 sbSql.append(" when s.tipo_cliente  = 'C' then (select descripcion from tbl_cds_centro_servicio where to_char(codigo) =s.id_cliente)  when s.tipo_cliente  = 'E' then (select nombre from tbl_com_proveedor where to_char(cod_provedor) = s.id_cliente) when s.tipo_cliente  = 'O' then s.nombre  when s.tipo_cliente  = 'M' then (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = s.id_cliente) when s.tipo_cliente  = 'S' then (select nombre from tbl_adm_empresa where to_char(codigo) = s.id_cliente) else ' ' end as nombre , decode(s.tipo_cliente,'P','PACIENTE','A','ASEGURADORA','E','PROVEEDORES','O','OTROS','S','SOCIEDADES MEDICAS','M','MEDICOS') tipo,decode(s.tipo_cliente,'O',(select descripcion from tbl_fac_tipo_cliente where codigo=s.tipo_ref and compania =s.compania),'E',(select tp.descripcion from tbl_com_tipo_proveedor tp,tbl_com_proveedor p where to_char(cod_provedor) = s.id_cliente and tp.tipo_proveedor=p.tipo_prove and p.compania =s.compania),' ') descTipoClt,decode(s.tipo_cliente,'E',(select tp.tipo_proveedor from tbl_com_tipo_proveedor tp,tbl_com_proveedor p where to_char(cod_provedor) = s.id_cliente and tp.tipo_proveedor=p.tipo_prove and p.compania =s.compania),'S',s.tipo_cliente,'M',s.tipo_cliente,'P',s.tipo_cliente,'A',s.tipo_cliente,s.tipo_ref)as tipo_ref,s.tipo_ref as tipoRef,decode(s.tipo_cliente,'E',(select tp.tipo_proveedor from tbl_com_tipo_proveedor tp,tbl_com_proveedor p where to_char(cod_provedor) = s.id_cliente and tp.tipo_proveedor=p.tipo_prove and p.compania =s.compania),' ') as tipo_prov, nvl(s.adm_type,' ') as adm_type, decode(s.adm_type,'T','GRAL','I','IP','O','OP',' ') as adm_type_desc, nvl(s.comentarios,' ') as comentarios from tbl_cxc_saldo_inicial s ) x where x.compania = ");
 sbSql.append((String) session.getAttribute("_companyId"));
 sbSql.append(" ");
 sbSql.append(appendFilter);
 sbSql.append(" order by 10,7 ASC ");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = ((fg.trim().equals("CXC"))?"CXC":"CXP");
	String subtitle = "SALDO INICIAL";
	String xtraSubtitle = "";
	if(fg.trim().equals("CXPP"))xtraSubtitle +="PROVEEDORES";
	else if(fg.trim().equals("CXPH")) xtraSubtitle +="HONORARIOS MEDICOS";
	else if(fg.trim().equals("CXPH")) xtraSubtitle +="HONORARIOS MEDICOS";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		
		if (tipoCliente.equals("A")){
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		}else{
		  dHeader.addElement(".30");
		}
		
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".15");
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
			//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("CODIGO",1);
		if (tipoCliente.equals("A")){
		  pc.addBorderCols("EMPRESA",1);
		  pc.addBorderCols("PACIENTE",1);
		}else{
		  pc.addBorderCols("NOMBRE",1);
		}
		pc.addBorderCols("TIPO",1);
		pc.addBorderCols("TIPO OTROS",1);
		pc.addBorderCols("SALDO",1);
		if (fg.equalsIgnoreCase("CXC")) pc.addBorderCols("CAT.",1);
		pc.addBorderCols("COMENTARIOS",1,(fg.equalsIgnoreCase("CXC")?1:2));

pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
    double total = 0.00,totalref=0.00;
	String groupBy="",tipoDesc=""; 
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if(i!=0)
		{
			if(!groupBy.trim().equals(cdo.getColValue("tipo_cliente")+"-"+cdo.getColValue("tipo_ref")))
			{
				pc.addCols("TOTAL POR : "+tipoDesc,2,4); 
				pc.addCols(""+CmnMgr.getFormattedDecimal(totalref), 2, 1);
				pc.addCols(" ",1,dHeader.size());
				totalref =0.00;
			}
		}

		pc.setFont(7, 0);
 		    pc.addCols(cdo.getColValue("id_cliente"),0,1,cHeight);
			if (tipoCliente.equals("A")){
				pc.addCols(cdo.getColValue("nombre"),0,1,cHeight);
				pc.addCols(cdo.getColValue("nombre_paciente"),0,1,cHeight);
			}else{
			    pc.addCols(cdo.getColValue("nombre"),0,1,cHeight);
			}
			pc.addCols(cdo.getColValue("tipo"),1,1,cHeight);
			pc.addCols(cdo.getColValue("descTipoClt"),0,1,cHeight);
				
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_actual")),2,1);
			if (fg.equalsIgnoreCase("CXC")) pc.addCols(cdo.getColValue("adm_type_desc"),1,1);
			pc.addCols(cdo.getColValue("comentarios"),0,(fg.equalsIgnoreCase("CXC")?1:2));
		total += Double.parseDouble(cdo.getColValue("saldo_actual"));
		totalref += Double.parseDouble(cdo.getColValue("saldo_actual"));
		groupBy = cdo.getColValue("tipo_cliente")+"-"+cdo.getColValue("tipo_ref");
		if(cdo.getColValue("descTipoClt")!= null && !cdo.getColValue("descTipoClt").trim().equals(""))tipoDesc = cdo.getColValue("descTipoClt");
		else tipoDesc = cdo.getColValue("tipo");
		
 			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
			if (tipoCliente.equals("A")){pc.addCols("TOTAL POR : "+tipoDesc,2,5);}else
			{pc.addCols("TOTAL POR : "+tipoDesc,2,4);}
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalref), 2, 1);
			pc.addCols(" ",1,dHeader.size());
				 
			if (tipoCliente.equals("A")){pc.addCols("TOTAL NUMERO DE REGISTRO EN SALDO INICIAL: "+al.size(),0,4);}else
			pc.addCols("TOTAL NUMERO DE REGISTRO EN SALDO INICIAL: "+al.size(),0,3);
			pc.addCols("TOTAL SALDO", 2, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total), 2, 1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>