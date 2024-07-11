<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codigo = request.getParameter("codigo");
String medSol = request.getParameter("medSol");
String medico = request.getParameter("medico");
String mode = request.getParameter("mode");

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alResp = new ArrayList();

String sql = "";
if (fg == null) fg = "EXP";
if (fp == null) fp = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (medSol == null) medSol = "";
if (medico == null) medico = "";
if (mode == null) mode = "";

boolean viewMode = mode.equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String xtra = "";
	if (fp.equals("RESP")) xtra = " and i.codigo = "+codigo;
	if (!pacId.equals("")) xtra += " and i.pac_id = "+pacId;
	if (!noAdmision.equals("")) xtra += " and i.secuencia = "+noAdmision;
	
	sql = "select i.pac_id, i.secuencia as admision, i.codigo, i.medico_solicitante, i.medico, to_char(i.fecha,'dd/mm/yyyy') as fecha_c, i.observacion, i.cod_especialidad, i.pac_id||'-'||i.secuencia||' '||p.primer_nombre||' '||p.primer_apellido as nombre_paciente, m.primer_nombre||' '||m.primer_apellido as nombre_medico, (select count(*) from tbl_sal_interconsultor_resp r where r.codigo_preg = i.codigo and r.pac_id = i.pac_id and r.admision = i.secuencia and r.medico = i.medico ) as tot_resp from tbl_sal_interconsultor i, tbl_adm_paciente p, tbl_adm_medico m where i.medico = '"+UserDet.getRefCode()+"' "+xtra+" and i.pac_id = p.pac_id and m.codigo(+) = i.medico_solicitante order by i.fecha desc";
	al = SQLMgr.getDataList(sql);
	
	if (fp.equals("RESP")){
	  sql = "select r.codigo, r.respuesta, to_char(r.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha_respuesta from tbl_sal_interconsultor_resp r where r.codigo_preg = "+codigo+" and r.pac_id = "+pacId+" and r.admision = "+noAdmision+" and r.medico = '"+medico+"' order by 1, r.fecha_creacion desc";
	  alResp = SQLMgr.getDataList(sql);
	}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Triage - '+document.title;
function doAction(){}
$(function(){
   $(".row").click(function(c){
	 var i = $(this).data("i");
	 var pacId = $(this).data("pacid");
	 var noAdmision = $(this).data("noadmision");
	 var codigo = $(this).data("codigo");
	 var medSol = $(this).data("medsol");
	 var medico = $(this).data("medico");
	 
	 window.location = "../expediente/exp_interconsulta_resp.jsp?fg=<%=fg%>&fp=RESP&pacId="+pacId+"&noAdmision="+noAdmision+"&codigo="+codigo+"&medSol="+medSol+"&medico="+medico;
	 
   });
   
   $("#add-resp").click(function(c){
      $("#resp-container").show(0);
   });
   
   $("#btnSave").click(function(c){
      $(this).prop({disabled:true}).val("Guardando...");
	  var cols = "codigo,codigo_preg, pac_id, admision, medico, respuesta, fecha_creacion, fecha_modificacion, usuario_creacion, usuario_modificacion";
	  var vals = "(select nvl(max(codigo),0)+1 from tbl_sal_interconsultor_resp where pac_id=<%=pacId%> and admision=<%=noAdmision%>),<%=codigo%>,<%=pacId%>,<%=noAdmision%>,'<%=medico%>','"+$("#respuesta").val()+"',sysdate,sysdate,'<%=UserDet.getUserName()%>','<%=UserDet.getUserName()%>'";
	  var saved = executeDB('<%=request.getContextPath()%>',"INSERT INTO tbl_sal_interconsultor_resp ("+cols+") VALUES ("+vals+")",'');
	  
	  if (!saved) {
	     $(this).prop({disabled:false}).val("Guardar");
		 alert("Hubó un error al tratar de guardar la resuesta. Por favor contacte un admnistrador!");
	  } 	 
	  else {
		 window.location = "../expediente/exp_interconsulta_resp.jsp?fg=<%=fg%>&fp=RESP&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo=<%=codigo%>&medSol=<%=medSol%>&medico=<%=medico%>";
	  }
   });
   
   $("#consultas-list").click(function(c){
      window.location = "../expediente/exp_interconsulta_resp.jsp?fg=<%=fg%>";
   });
});
</script>
<style>
  textarea{vertical-align:middle}
  input.button{vertical-align:middle}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<table align="center" width="99%" cellpadding="5" cellspacing="0">
		<tr>
			<td class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
					<tr class="TextHeader">
						<td colspan="4">INTERCONSULTAS</td>
						<td align="center" colspan="2">
							<%if(fp.equalsIgnoreCase("RESP") && !viewMode){%>
								<span id="consultas-list" class="Link04Bold pointer">Consultas</span>
							<%}%>
						</td>
					</tr>
				    <tr class="TextHeader">
						<td align="center" width="3%">ID</td>
						<td align="center" width="7%">Fecha</td>
						<td width="40%">Consulta</td>
						<td width="25%">M&eacute;dico Solicitante</td>
						<td width="20%">Paciente</td>
						<td width="5%" align="center">Resp.</td>
					</tr>
					
					<%for (int i=0; i<al.size(); i++){
						String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
						CommonDataObject cdo = (CommonDataObject)al.get(i);
					%>
						<tr class="<%=color%> row" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" data-i="<%=i%>" data-codigo="<%=cdo.getColValue("codigo")%>" data-pacid="<%=cdo.getColValue("pac_id")%>" data-noadmision="<%=cdo.getColValue("admision")%>"data-medsol="<%=cdo.getColValue("medico_solicitante")%>" data-medico="<%=cdo.getColValue("medico")%>">
							<td align="center"><%=cdo.getColValue("codigo")%></td>
							<td align="center"><%=cdo.getColValue("fecha_c")%></td>
							<td><%=cdo.getColValue("observacion")%></td>
							<td><%=cdo.getColValue("nombre_medico")%></td>
							<td><%=cdo.getColValue("nombre_paciente")%></td>
							<td align="center"><%=cdo.getColValue("tot_resp")%></td>
						</tr>
				   <%}%>
				   
				   <%if(fp.equals("RESP")){%>
					    <tr class="TextHeader">
							<td colspan="4">RESPUESTAS</td>
							<td align="center" colspan="2"><%if(!viewMode){%><span id="add-resp" class="Link04Bold pointer">Agregar una respuesta</span><%}%></td>
						</tr>

						<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
						<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
						<%=fb.formStart(true)%>
						
						<tr class="TextHeader" id="resp-container" style="display:none">
							<td colspan="6" align="center">
							  <textarea name="respuesta" id="respuesta" style="width:80%; height:40px" maxlength="1000"></textarea>
							  <input type="button" name="btnSave" id="btnSave" value="Guardar" class="CellbyteBtn"/>
							</td>
						</tr>
						
					    <%for (int i=0; i<alResp.size(); i++){
							CommonDataObject cdo = (CommonDataObject)alResp.get(i);
						%>
							<tr class="TextRow02">
								<td align="center"><%=cdo.getColValue("codigo")%></td>
								<td colspan="3" class="Text10"><%=cdo.getColValue("respuesta")%></td>
								<td align="center" colspan="2" ><%=cdo.getColValue("fecha_respuesta")%></td>
							</tr>
					   <%}%>
					   <%=fb.formEnd()%>
				   <%}%>

			   </table>
			</td>
		</tr>
	</table>
</body>
</html>
<%
}//GET
%>