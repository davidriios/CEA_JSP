<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%

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
String mode = request.getParameter("mode");
String docId = request.getParameter("docId")==null?"":request.getParameter("docId");
String imagesFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

if (docId.equals("")||docId.equals("0")) throw new Exception("Los Documentos del Expediente no están definidos. Por favor consulte con su Administrador!");

String estado = request.getParameter("estado");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String sec = request.getParameter("sec");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

if (mode == null) mode = "add";
if (estado == null) estado = "";
if (sec == null) sec = "";
if (fg==null) fg = "";
if (fp==null) fp = "";

String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

CommonDataObject pCdo = new CommonDataObject();

sbSql.append("select z.exp_id, to_char(nvl(z.f_nac, z.fecha_nacimiento),'dd/mm/yyyy') as dob, decode(z.provincia,null,' ',z.provincia) as provincia, nvl(z.sigla,' ') as sigla, decode(z.tomo,null,' ',z.tomo) as tomo, decode(z.asiento,null,' ',z.asiento) as asiento, nvl(z.d_cedula,' ') as dCedula, nvl(z.pasaporte,' ') as pasaporte, z.nombre_paciente as nombrePaciente, get_age(z.f_nac,(select nvl(fecha_ingreso,fecha_creacion) from tbl_adm_admision where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append("),null) as edad, get_age(z.f_nac,(select nvl(fecha_ingreso,fecha_creacion) from tbl_adm_admision where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append("),'mm') as edad_mes, z.sexo, (select (select '['||codigo||'] '||descripcion from tbl_cds_centro_servicio where codigo = y.cds) from tbl_adm_atencion_cu y where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(") as cds, (select (select '['||codigo||'] '||descripcion from tbl_adm_categoria_admision where codigo = y.categoria) from tbl_adm_admision y where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(") as categoria, nvl((SELECT tipo_sangre FROM tbl_bds_tipo_sangre where to_char(sangre_id) = z.tipo_sangre), nvl(z.tipo_sangre,'N/A')) tipo_sangre from vw_adm_paciente z where z.pac_id = ");
sbSql.append(pacId);
pCdo = SQLMgr.getData(sbSql.toString());
if (pCdo == null) pCdo = new CommonDataObject();

String _whereClause = "";

sbSql = new StringBuffer();

if (fp.equals("history")){
	_whereClause = " replace(replace(replace(replace(a.where_clause,'@@PACID',"+pacId+"),'@@ADMISION',"+noAdmision+"),'@@FCF','trunc(sysdate - (interval ''50'' year))'),'@@FCT','trunc(sysdate)') ";
}

if (UserDet.getUserProfile().contains("0")){
	sbSql.append("select a.codigo, nvl(a.nombre_corto, a.descripcion) as descripcion, '");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	else sbSql.append(mode);
	sbSql.append("' as actionMode, ");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("1");
	sbSql.append(" as editable, nvl(a.path||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path,  decode(a.icon_path,null,' ','"+imagesFolder.replaceAll(rootFolder,"..")+"/'||a.icon_path) icon_path from tbl_sal_expediente_secciones a ");
	
	if (!fp.equals("history")){
	   sbSql.append(" , tbl_sal_exp_docs_secc b where ");
	}
	
	if (!fp.equals("history")){
		sbSql.append(" b.doc_id=");
		sbSql.append(docId);
	}

	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
	
	sbSql.append(" and (a.sexo = '");
  sbSql.append(pCdo.getColValue("sexo","A"));
  sbSql.append("' or a.sexo = 'A')");
  
  sbSql.append(" and ");
  sbSql.append(pCdo.getColValue("edad","0"));
  sbSql.append(" between a.edad_from and a.edad_to ");
  	
	if (!_whereClause.equals("")) sbSql.append(" where get_sec_tot_data(a.table_name,"+_whereClause+") > 0 ");
	if (!fp.equals("history")){
		sbSql.append(" and a.codigo=b.secc_code order by b.display_order");
	}else sbSql.append(" order by 2");	
} else {
	sbSql.append("select distinct a.* from (select a.codigo, nvl(a.nombre_corto, a.descripcion) as descripcion, nvl(a.path||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path , decode(a.icon_path,null,' ','"+imagesFolder.replaceAll(rootFolder,"..")+"/'||a.icon_path) icon_path, decode(c.editable,1,decode(a.status,'A','");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	sbSql.append(mode);
	sbSql.append("','I','view'),'view') as actionMode, ");
	
	sbSql.append(" decode(a.status,'A',");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("c.editable");
	sbSql.append(",'I',0) as editable");
	
	if (!fp.equals("history")){
		sbSql.append(", b.display_order ");
	}else sbSql.append(", a.descripcion as display_order ");
	
	sbSql.append(" from tbl_sal_expediente_secciones a ");
	
	if (!fp.equals("history")){
		sbSql.append(", tbl_sal_exp_docs_secc b ");
	}
	
	sbSql.append(", (select secc_id, max(editable) as editable from tbl_sal_exp_secc_profile where profile_id in (");
	sbSql.append(profiles);
	sbSql.append(") group by secc_id) c, tbl_sal_exp_secc_centro d where ");
	
	if (!fp.equals("history")){
		sbSql.append(" b.doc_id=");
		sbSql.append(docId);
	} else sbSql.append(" 1=1 ");
	
	if (!fp.equals("history")) sbSql.append(" and a.codigo=b.secc_code ");

	sbSql.append(" and a.status = 'A' and a.codigo=c.secc_id and a.codigo=d.cod_sec and d.centro_servicio in (select cds from tbl_adm_atencion_cu where pac_id=");
	sbSql.append(pacId);
	if(noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0")){
		sbSql.append(" and secuencia=");
		sbSql.append(noAdmision);
	}
	sbSql.append(")");
	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
	
	sbSql.append(" and (a.sexo = '");
  sbSql.append(pCdo.getColValue("sexo","A"));
  sbSql.append("' or a.sexo = 'A')");
  
  sbSql.append(" and ");
  sbSql.append(pCdo.getColValue("edad","0"));
  sbSql.append(" between a.edad_from and a.edad_to ");
	
	if (!_whereClause.equals("")) sbSql.append(" and get_sec_tot_data(a.table_name,"+_whereClause+") > 0 ");
		
	if (!fp.equals("history")) sbSql.append("	order by b.display_order ) a order by display_order");
	else sbSql.append("	) a order by display_order");
}
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")){%>
<%for (int i=0; i<al.size(); i++){
  cdo = (CommonDataObject) al.get(i);%>
    <div class="sec-container hint hint--bottom" data-hint="<%=cdo.getColValue("descripcion")%>" onClick="javascript:doRedirect('<%=cdo.getColValue("descripcion")%>',<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("actionMode")%>',<%=cdo.getColValue("editable")%>, '<%=cdo.getColValue("path")%>')">
	<span id="observContSec<%=i%>" class="observContSec" title="" data-i="<%=i%>" data-cont="<%=cdo.getColValue("descripcion")%>">
	<div id="" style="display:table;width:100%;">
	<div id="" class="sec-img-container" data-sec_id="<%=cdo.getColValue("codigo")%>">
		<img src="<%=cdo.getColValue("icon_path")%>" style="max-height: 50px; height:50px;"/>
	 </div>
	<div class="descrip" style="cursor:pointer" id="section<%=cdo.getColValue("codigo")%>">
	   <%=cdo.getColValue("descripcion")%>
	</div>
	</div>
	</span>
	</div>
<%}%>
<div style="clear:both"></div>
<%}%>