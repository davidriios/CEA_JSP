<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
if (request.getMethod().equalsIgnoreCase("GET"))
{
	SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);
	

	String listId = request.getParameter("listId");
	if(listId==null || listId.equals("")) throw new Exception("No. Lista no existe!");
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String userName = UserDet.getUserName();
	StringBuffer sbSql = new StringBuffer();
	String cat_egy = "";
	sbSql.append("select distinct categoria, (select descripcion from tbl_adm_categoria_admision where codigo = d.categoria) categoria_desc from tbl_fac_lista_envio_det d where d.id = ");
	sbSql.append(listId);
	
	ArrayList alCat = SQLMgr.getDataList(sbSql.toString());
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(-1, 'ANIO_FILE_AXA'), '0') anio, (select to_char(fecha_creacion, 'mm') from tbl_fac_lista_envio where id = ");
	sbSql.append(listId);
	sbSql.append(") mes, nvl(get_sec_comp_param(-1, 'CAT_EGY'), '') cat_egy, get_sec_comp_param (-1, 'COD_DOC_IMA') COD_DOC_IMA, get_sec_comp_param (-1, 'COD_DOC_LAB') COD_DOC_LAB, get_sec_comp_param (-1, 'COD_DOC_HDR') COD_DOC_HDR, get_sec_comp_param (-1, 'COD_DOC_OMA') COD_DOC_OMA, get_sec_comp_param (-1, 'COD_DOC_OMR') COD_DOC_OMR from dual");	
	
	CommonDataObject cd = new CommonDataObject();
	cd = SQLMgr.getData(sbSql.toString());
	cat_egy = cd.getColValue("cat_egy");
	
	sbSql = new StringBuffer();
	sbSql.append("select factura, (select descripcion from tbl_adm_categoria_admision where codigo = d.categoria) categoria_desc from tbl_fac_lista_envio_det d where id = ");
	sbSql.append(listId);
	ArrayList alFactToDel = SQLMgr.getDataList(sbSql.toString());
	
	sbSql = new StringBuffer();
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	month = cd.getColValue("mes");
	String day = fecha.substring(0, 2);
	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month += " february";
	else if (month.equals("03")) month += " march";
	else if (month.equals("04")) month += " april";
	else if (month.equals("05")) month += " may";
	else if (month.equals("06")) month += " june";
	else if (month.equals("07")) month += " july";
	else if (month.equals("08")) month += " august";
	else if (month.equals("09")) month += " september";
	else if (month.equals("10")) month += " october";
	else if (month.equals("11")) month += " november";
	else month += " december";
	
	if(!cd.getColValue("anio").equals("0")) year=cd.getColValue("anio");

	String servletPath = request.getServletPath();
	
	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("docs.files_axa")+"/";
	String dir_doc_scan = ResourceBundle.getBundle("path").getString("scanned")+"/";
	String folderName = "";
	String subFolderName = "archivos";
	String fileName = "";
	String source_path = "";
	String factFile = "";
	String expFile = "";
  String cargosFile = "";
  String doctFile = "";
	ArrayList al = new ArrayList();
	ArrayList alP = new ArrayList();
	ArrayList alD = new ArrayList();
	Hashtable htX = new Hashtable();
	String pathToDel = "";
	for(int i = 0; i < alFactToDel.size(); i++){
		CommonDataObject cdX = (CommonDataObject) alFactToDel.get(i);
		pathToDel = directory +cdX.getColValue("categoria_desc")+ "/" + year + "/" + month + "/";
		System.out.println("pathToDel........................................="+pathToDel+", factura = "+cdX.getColValue("factura")+"_");
		CmnMgr.searchDeleteFiles(pathToDel, cdX.getColValue("factura")+"_*");
	}
	
	for(int x = 0; x<alCat.size(); x++){
	CommonDataObject cdCat = (CommonDataObject) alCat.get(x);
	CommonDataObject cdX = new CommonDataObject();
	folderName = cdCat.getColValue("categoria_desc");
	cdX.addColValue("categoria", cdCat.getColValue("categoria_desc"));
	sbSql = new StringBuffer();
	sbSql.append("select le.compania, le.factura, f.admi_secuencia admision, f.pac_id, cu.cds, (case when a.categoria = get_sec_comp_param(");
	sbSql.append((String)session.getAttribute("_companyId"));
	sbSql.append(",'CAT_EGY') then 'S' else 'N' end) crea_expediente, (select nombre_paciente from vw_adm_paciente where pac_id = f.pac_id) nombre_paciente, (select id_paciente from vw_adm_paciente where pac_id = f.pac_id) identificacion, le.categoria from tbl_fac_lista_envio_det le, tbl_fac_factura f, tbl_adm_admision a, tbl_adm_atencion_cu cu where le.factura = f.codigo and le.compania = f.compania and f.pac_id = a.pac_id and f.admi_secuencia = a.secuencia and f.pac_id = cu.pac_id(+) and f.admi_secuencia = cu.secuencia(+) and id = ");
	sbSql.append(listId);
	sbSql.append(" and le.categoria = ");
	sbSql.append(cdCat.getColValue("categoria"));
	
	al = SQLMgr.getDataList(sbSql.toString());
	
	sbSql = new StringBuffer();
	sbSql.append("select codigo, docid, documentodesc, scanpath, title, file_name || row_number() OVER (PARTITION BY file_name ORDER BY file_name) file_name from (select  e.codigo, e.docid, d.nombre as documentodesc, decode(e.scanpath,null,' ',e.scanpath) as scanpath, nvl(e.scanpath,'') title, (case when e.docid in (");
	sbSql.append(cd.getColValue("COD_DOC_IMA"));
	sbSql.append(")");
	sbSql.append(" then f.codigo || '_IMA' when e.docid in (");
	sbSql.append(cd.getColValue("COD_DOC_LAB"));
	sbSql.append(")");
	sbSql.append(" then f.codigo || '_LAB' when e.docid in (");
	sbSql.append(cd.getColValue("COD_DOC_HDR"));
	sbSql.append(")");
	sbSql.append(" then f.codigo || '_HDR' when e.docid in (");
	sbSql.append(cd.getColValue("COD_DOC_OMA"));
	sbSql.append(")"); 
	sbSql.append(" then f.codigo || '_OMD' when e.docid in (");
	sbSql.append(cd.getColValue("COD_DOC_OMR"));
	sbSql.append(")");
	sbSql.append(" then f.codigo || '_OMD' else f.codigo||'_DOC' end) file_name from tbl_adm_doc_escaneado e, tbl_adm_documento d, tbl_fac_lista_envio_det le, tbl_fac_factura f where le.factura = f.codigo and le.compania = f.compania and e.pacid = f.pac_id and e.secuencia = f.admi_secuencia and le.categoria = d.categoria_adm and e.docid = d.codigo and le.categoria = ");
	sbSql.append(cdCat.getColValue("categoria"));
	sbSql.append(" and le.id = ");
	sbSql.append(listId);
	sbSql.append(" order by 6) order by file_name");
	alD = SQLMgr.getDataList(sbSql.toString());
	Hashtable htDoc = new Hashtable();
	
	for(int m=0;m<alD.size();m++){
		CommonDataObject cdD = (CommonDataObject) alD.get(m);
		System.out.println("file_name..............................="+cdD.getColValue("file_name")+ ", scanpath = "+cdD.getColValue("scanpath"));
		htDoc.put(cdD.getColValue("scanpath"), cdD);
	}
	
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
 
   for(int i=0;i<al.size();i++) { 
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		alP.add(cdo);
		try{
	    %>
			<jsp:include page="../facturacion/print_fact.jsp">
				<jsp:param name="pacId" value="<%=cdo.getColValue("pac_id")%>"></jsp:param>
				<jsp:param name="admision" value="<%=cdo.getColValue("admision")%>"></jsp:param>
				<jsp:param name="factura" value="<%=cdo.getColValue("factura")%>"></jsp:param>
				<jsp:param name="compania" value="<%=cdo.getColValue("compania")%>"></jsp:param>
				<jsp:param name="listId" value="<%=listId%>"></jsp:param>
				<jsp:param name="yearList" value="<%=year%>"></jsp:param>
				<jsp:param name="mesList" value="<%=month%>"></jsp:param>
				<jsp:param name="fp" value="lista_envio"></jsp:param>
				<jsp:param name="categoria" value="<%=cdo.getColValue("categoria")%>"></jsp:param>
				<jsp:param name="categoria_desc" value="<%=cdCat.getColValue("categoria_desc")%>"></jsp:param>
			</jsp:include>
	    <% 
	    }catch(Exception e){
	     e.printStackTrace();
		  } 
 } 
 source_path = (directory+folderName+"/"+year+"/"+month);
 System.out.println("source_path...........................xx="+source_path);
 //factFile = CmnMgr.zipFolder(source_path+"/facturas", source_path+"/FACTURAS_LISTA_"+listId+".zip");
 if(factFile==null)factFile="";
 cdX.addColValue("facturas",factFile);
 if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
 for(int i=0;i<al.size();i++) { 
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		fileName=cdo.getColValue("factura")+".pdf";
		try{
	    %>
			<jsp:include page="../facturacion/print_cargo_dev_neto.jsp">
				<jsp:param name="pacId" value="<%=cdo.getColValue("pac_id")%>"></jsp:param>
				<jsp:param name="noSecuencia" value="<%=cdo.getColValue("admision")%>"></jsp:param>
				<jsp:param name="factura" value="<%=cdo.getColValue("factura")%>"></jsp:param>
				<jsp:param name="listId" value="<%=listId%>"></jsp:param>
				<jsp:param name="fp" value="lista_envio"></jsp:param>
				<jsp:param name="yearList" value="<%=year%>"></jsp:param>
				<jsp:param name="mesList" value="<%=month%>"></jsp:param>
				<jsp:param name="categoria" value="<%=cdo.getColValue("categoria")%>"></jsp:param>
				<jsp:param name="categoria_desc" value="<%=cdCat.getColValue("categoria_desc")%>"></jsp:param>
			</jsp:include>
	    <% 
	    }catch(Exception e){
	     e.printStackTrace();
		  } 
 
 }
 //cargosFile = CmnMgr.zipFolder(source_path+"/cargos", source_path+"/CARGOS_LISTA_"+listId+".zip");
 if(cargosFile==null)cargosFile="";
 cdX.addColValue("cargos",cargosFile);
 if(cdCat.getColValue("categoria").equals(cat_egy)){
 if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
 boolean zip_folter = false;
 for(int i=0;i<al.size();i++) { 
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	fileName=cdo.getColValue("factura")+".pdf";
	if(cdo.getColValue("crea_expediente").equals("S")){
		try{
			%>
			<jsp:include page="../expediente/print_sal10010_cu.jsp">
				<jsp:param name="pacId" value="<%=cdo.getColValue("pac_id")%>"></jsp:param>
				<jsp:param name="noAdmision" value="<%=cdo.getColValue("admision")%>"></jsp:param>
				<jsp:param name="factura" value="<%=cdo.getColValue("factura")%>"></jsp:param>
				<jsp:param name="cds" value="<%=cdo.getColValue("cds")%>"></jsp:param>
				<jsp:param name="listId" value="<%=listId%>"></jsp:param>
				<jsp:param name="fp" value="lista_envio"></jsp:param>
				<jsp:param name="yearList" value="<%=year%>"></jsp:param>
				<jsp:param name="mesList" value="<%=month%>"></jsp:param>
				<jsp:param name="categoria" value="<%=cdo.getColValue("categoria")%>"></jsp:param>
				<jsp:param name="categoria_desc" value="<%=cdCat.getColValue("categoria_desc")%>"></jsp:param>
			</jsp:include>
			<% 
			}catch(Exception e){
			 e.printStackTrace();
		}
		zip_folter=true;
	}
 }
 expFile = "";
 //if(zip_folter) expFile=CmnMgr.zipFolder(source_path+"/expedientes", source_path+"/EXPEDIENTES_LISTA_"+listId+".zip");
 if(expFile==null)expFile="";
 cdX.addColValue("expedientes",expFile);
 }
if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
 
 doctFile = CmnMgr.zipFolder2(dir_doc_scan, source_path, source_path+"/DOCTOS_LISTA_"+listId+".zip", htDoc);
 if(doctFile==null) doctFile=""; 
 cdX.addColValue("documentos",doctFile);
 htX.put(cdX.getColValue("categoria"), cdX);
 }
	%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loaded=true;}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
	<td class="TableLeftBorder TableRightBorder TableTopBorder TableBottomBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<%
	for(int i=0; i<alCat.size();i++){
		CommonDataObject cdC = (CommonDataObject) alCat.get(i);
		System.out.println("categoria..............."+cdC.getColValue("categoria_desc"));
		CommonDataObject cdX = (CommonDataObject) htX.get(cdC.getColValue("categoria_desc"));
		factFile = cdX.getColValue("facturas");
		cargosFile = cdX.getColValue("cargos");
		if(cdX.getColValue("expedientes")!=null) expFile = cdX.getColValue("expedientes");
		doctFile = cdX.getColValue("documentos");
		
	%>
	<tr class="TextHeader02"><td colspan="4" align="center"><%=cdC.getColValue("categoria_desc")%></td></tr>
	<%if(!factFile.equals("")){%>
	<tr class="TextRow01" align="center">
    <td colspan="4"><a href="<%=request.getContextPath()%><%=factFile.replace(ResourceBundle.getBundle("path").getString("root"),"")%>" class="Link00"><cellbytelabel><font class="RedTextBold">FACTURAS</font> click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
	</tr>
	<%}%>
	<%if(!cargosFile.equals("")){%>
	<tr class="TextRow01" align="center">
    <td colspan="4"><a href="<%=request.getContextPath()%><%=cargosFile.replace(ResourceBundle.getBundle("path").getString("root"),"")%>" class="Link00"><cellbytelabel><font class="RedTextBold">CARGOS</font> click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
	</tr>
	<%}%>
	<%if(!expFile.equals("")){%>
	<tr class="TextRow01" align="center">
    <td colspan="4"><a href="<%=request.getContextPath()%><%=expFile.replace(ResourceBundle.getBundle("path").getString("root"),"")%>" class="Link00"><cellbytelabel><font class="RedTextBold">EXPEDIENTE</font> click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
	</tr>
	<%}%>	
	<%/*if(!doctFile.equals("")){%>
	<tr class="TextRow01" align="center">
    <td colspan="4"><a href="<%=request.getContextPath()%><%=doctFile.replace(ResourceBundle.getBundle("path").getString("root"),"")%>" class="Link00"><cellbytelabel><font class="RedTextBold">DOCUMENTOS</font> click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
	</tr>
	<%}*/
	}%>
	<tr class="TextHeader" align="center">
		<td width="70%" colspan="2">Paciente</td>
		<td width="20%">Factura</td>
		<td width="10%">Admisi&oacute;n</td>
	</tr>
<%
				for (int i=0; i<alP.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) alP.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("identificacion")%></td> 
					<td align="center">&nbsp;<%=cdo.getColValue("factura")%></td> 
					<td align="center">&nbsp;<%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td> 
				</tr>
				<%
				}
				%>

</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
</body>
</html>
<%
     
   // got to remove flush=true, because this causes the response to be commited and therefore, screws my redirect. This pissed me off!
}
%>