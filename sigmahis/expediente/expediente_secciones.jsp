<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
String appendFilter = "";
String mode = request.getParameter("mode");
String docId = request.getParameter("docId");
String defaultClass = "TextRow02";
String highlightClass = "TextRow03 Text12Bold";
String estado = request.getParameter("estado");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String sec = request.getParameter("sec");
String fg = request.getParameter("fg");

String _section = request.getParameter("section")==null?"":request.getParameter("section");
String _sectionDesc = request.getParameter("sectionDesc")==null?"":request.getParameter("sectionDesc");
String _path = request.getParameter("path")==null?"":request.getParameter("path");
String fp = request.getParameter("fp")==null?"":request.getParameter("fp");

if (mode == null) mode = "add";
if (docId == null || docId.equals("0")) throw new Exception("Los Documentos del Expediente no están definidos. Por favor consulte con su Administrador!");
if (estado == null) estado = "";
if (sec == null) sec = "";
if (fg==null) fg = "";

String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

String _whereClause = "";

if (fp.equals("history")){
	_whereClause = " replace(replace(replace(replace(a.where_clause,'@@PACID',"+pacId+"),'@@ADMISION',"+noAdmision+"),'@@FCF','trunc(sysdate - (interval ''50'' year))'),'@@FCT','trunc(sysdate)') ";
}

if (UserDet.getUserProfile().contains("0")){
	sbSql.append("select a.codigo, a.descripcion, '");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	else sbSql.append(mode);
	sbSql.append("' as actionMode, ");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("1");
	sbSql.append(" as editable, nvl(a.path||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path from tbl_sal_expediente_secciones a ");
	
	if (!fp.equals("history")){
	   sbSql.append(" , tbl_sal_exp_docs_secc b where ");
	}
	
	if (fg.trim().equals("FLUJO_ATENCION")){
	   sbSql.append(" 1=1 ");
	}else{
		if (!fp.equals("history")){
			sbSql.append(" b.doc_id=");
			sbSql.append(docId);
		}
	}
	sbSql.append(appendFilter);
	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
	if (!_whereClause.equals("")) sbSql.append(" where get_sec_tot_data(a.table_name,"+_whereClause+") > 0 ");
	if (!fp.equals("history")){
		sbSql.append(" and a.codigo=b.secc_code order by b.display_order"); 
	}else sbSql.append(" order by 2"); 
} else {
	sbSql.append("select distinct a.* from (select a.codigo, a.descripcion, nvl(a.path||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path , decode(c.editable,1,decode(a.status,'A','");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	sbSql.append(mode);
	sbSql.append("','I','view'),'view') as actionMode, ");
	
	sbSql.append(" decode(a.status,'A',");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("c.editable");
	
	sbSql.append(",'I',0) as editable ");
	
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
	
	if (fg.trim().equals("FLUJO_ATENCION")){
	   sbSql.append(" 1=1 ");
	}else{
		if (!fp.equals("history")){
			sbSql.append(" b.doc_id=");
			sbSql.append(docId);
		}else sbSql.append(" 1=1 ");
	}

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
	
	if (!_whereClause.equals("")) sbSql.append(" and get_sec_tot_data(a.table_name,"+_whereClause+") > 0 ");
	
	if (!fp.equals("history")) sbSql.append("	order by b.display_order ) a order by display_order");
	else sbSql.append("	) a order by display_order");
}

al = SQLMgr.getDataList(sbSql.toString());
String company = (String) session.getAttribute("_companyId");
CommonDataObject cdoX = SQLMgr.getData("select nvl(get_sec_comp_param("+company+", 'CHK_ANT_ALERGIA'), 'N') chk_ant_alergia, nvl(get_sec_comp_param("+company+", 'ANT_ALERGIA_ID'), 5) ant_alergia_id from dual ");
if (cdoX == null) {
    cdoX = new CommonDataObject();
    cdoX.addColValue("chk_ant_alergia","N");
    cdoX.addColValue("ant_alergia_id","5");
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Expediente - "+document.title;

// +path
function doRedirect(secDesc,secId,mode,editable, path)
{
	if(checkAntAler(secId)) parent.doRedirect(secDesc,secId,mode,editable, path); 
	executeDB('<%=request.getContextPath()%>','call sp_sec_user_log_exp(<%=UserDet.getUserId()%>,<%=pacId%>,<%=noAdmision%>,'+secId+',null,\'<%=session.getId()%>\',\'<%=request.getRemoteAddr()%>\',\''+secDesc+'\',\''+path+'\')')
	if(document.form0.section.value!='')document.getElementById('section'+document.form0.section.value).className='<%=defaultClass%>';
	document.form0.section.value=secId;
	document.getElementById('section'+secId).className='<%=highlightClass%>';
}

function doAction(){}
function setOnTheFly(){
    var section = "<%=_section%>";
    var sectionDesc = "<%=_sectionDesc%>";
    var path = "<%=_path%>";
	doRedirect(sectionDesc, section, 'view',0,path);
}
function checkAntAler(secId){
  var chkAntAlergia = ("<%=cdoX.getColValue("chk_ant_alergia","N")%>" == "Y" || "<%=cdoX.getColValue("chk_ant_alergia","N")%>" == "S");
  var antAlergia = "<%=cdoX.getColValue("ant_alergia_id","5")%>";
  if ("<%=estado%>" !="F" && chkAntAlergia && secId == antAlergia) { 
    var c = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_alergia_paciente'," pac_id = <%=pacId%> and admision = <%=noAdmision%>",'');
    if (!parseInt(c,10)) {
        parent.CBMSG.warning("El paciente no tiene Antecedentes Alérgicos registrados. Por politicas del Hospital es necesario registrar Antecedentes Alérgicos antes de Solicitar MEDICAMENTOS !!!");
        return false;
    }
  }
<% if (!estado.equalsIgnoreCase("F")) { %>
  if(secId==75){
    var x= getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b',' a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med and b.pac_id = <%=pacId%> and b.secuencia = <%=noAdmision%> and b.forma_solicitud=\'T\' and nvl(b.validada,\'N\') =\'N\' and ((b.omitir_orden=\'N\' and b.estado_orden=\'A\') or (b.ejecutado=\'N\' and b.estado_orden=\'S\' )) ',''); 	
	if(parseInt(x,10)){parent.CBMSG.warning("El paciente tiene ordenes medicas telefonicas pendiente por refrendar. Por politicas del Hospital es necesario que refrende las ordenes antes de darle salida!!!");return false;}
  }
<%}%>
  return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()" class="TextRow01">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextHeader">
	<td class="TableBorder">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table width="100%" border="0" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("defaultClass",defaultClass)%>
<%=fb.hidden("highlightClass",highlightClass)%>
<%=fb.hidden("estado",estado)%>
<%if (fp.equalsIgnoreCase("secciones_guardadas")){%>
<%=fb.hidden("section",_section)%>
<%}else{%>
<%=fb.hidden("section","")%>
<%}%>
<%=fb.hidden("sectionDesc",_sectionDesc)%>
<%=fb.hidden("path",_path)%>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	///if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=defaultClass%>" onClick="javascript:doRedirect('<%=cdo.getColValue("descripcion")%>',<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("actionMode")%>',<%=cdo.getColValue("editable")%>, '<%=cdo.getColValue("path")%>')" style="cursor:pointer" onMouseOver="setoverc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'TextRowOver Text12Bold':'TextRowOver')" onMouseOut="setoutc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'<%=highlightClass%>':'<%=defaultClass%>')" id="section<%=cdo.getColValue("codigo")%>">
			<td><%=cdo.getColValue("descripcion")%></td>
		</tr>
		<%=fb.hidden("path"+i,cdo.getColValue("path"))%>
<%
}
%>
<%=fb.formEnd(true)%>
		</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>