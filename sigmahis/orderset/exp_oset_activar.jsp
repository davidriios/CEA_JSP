<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

boolean viewMode = false;
String sql = "", sqlTitle="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (desc == null) desc = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{	
	sql = "select a.id_oset, a.oset_desc, nvl(b.observacion,' ') as observacion, b.medico_usuario med_code, nvl(medico_nombre, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = b.medico_usuario)) as med_name, decode(b.oset_id,null,'I','U') action,to_char(b.created_date,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.created_by usuario_creacion, decode(b.oset_id,null,'N','S') valor, b.estado from TBL_OSET_HEADER1 a, TBL_EXP_OSET_ACTIVOXMRN b where a.id_oset = b.oset_id(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.estatus = 'C' order by a.id_oset, b.observacion desc nulls last";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'EXPEDIENTE - Activar Orderset - '+document.title;
function doAction(){newHeight();}
function isChecked(k){
  eval('document.form0.observacion'+k).disabled = !eval('document.form0.valor'+k).checked;
  
  if (eval('document.form0.valor'+k).checked) {
    eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';
    
    $("#med_name"+k).prop('readonly', false).removeClass('FormDataObjectDisabled');
    $("#btn_search_med"+k).prop('disabled', false);
  }
  else {
    eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';
    eval('document.form0.observacion'+k).value = ''
    
    $("#med_code"+k).val('');
    $("#med_name"+k).val('').prop('readonly', true).addClass('FormDataObjectDisabled');
    $("#btn_search_med"+k).prop('disabled', true);
  }
}

function ver(idOset) {
  abrir_ventana("../orderset/oset_activos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_oset_h1="+idOset);
}

function printExp(){abrir_ventana("../expediente/print_exp_seccion_7.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}

$(function(){

  $(".btn_search_med").click(function() {
      var self = $(this);
      var i = self.data('i');
      var medNameOrCode = $.trim( $("#med_name"+i).val() );
      
      if (medNameOrCode) {
          self.prop('disabled',true);
          
          var url = '../orderset/sel_extras.jsp?fp=medico&index='+i + '&descripcion=' + medNameOrCode + '&context=preventPopupFrame';
          $("#preventPopupFrame").show(0).attr('src', url);
          self.prop('disabled',false);
          $("#med_name").val(""); 
      }
    });
    
    $("#btn_search_med_all").click(function() {
        var self = $(this);
        var medNameOrCode = $.trim( $("#med_name").val() );
        if (medNameOrCode) {
            self.prop('disabled',true);
            var url = '../orderset/sel_extras.jsp?fp=medico&index=&descripcion=' + medNameOrCode + '&context=preventPopupFrame&al_size=<%=al.size()%>';
            $("#preventPopupFrame").show(0).attr('src', url);
            self.prop('disabled',false);
            $("#med_name").val(""); 
        }
    });
  });
  
function openActive(idOset){
  abrir_ventana("../orderset/oset_activos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&id_oset_h1="+idOset);
}

function notValidForm() {
  for(i = 0; i<<%=al.size()%>;i++) {
    if ( $("#valor"+i).is(":checked") && !$("#med_code"+i).val()) {
      alert("Médico inválido!");
      return true;
    }
  }
  
  return false;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%fb.appendJsValidation("if(notValidForm()) error++;");%>
		<tr class="TextRow02">
			<td colspan="5" align="right">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <!--<a href="javascript:printExp();" class="Link00">[<cellbytelabel>Imprimir</cellbytelabel>]</a>
          &nbsp;&nbsp;&nbsp;&nbsp;
          <a href="javascript:openActive();" class="Link00">[<cellbytelabel>Activos</cellbytelabel>]</a>-->
      </td>
		</tr>
		
		<tr><td colspan="5">
    <iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="100" src="" scroll="no" style="display:none;"></iframe>
    </td></tr>
    
    <tr>
        <td colspan="5">
            M&eacute;dico
            <%=fb.textBox("med_name", UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getName() : "",false,false,viewMode,40,500,"",null,null,null,false,"")%>
            <button type="button" class="CellbyteBtn" id="btn_search_med_all" <%=viewMode ? " disabled" : ""%>>...</button>
        </td>
    </tr>
		
		<tr align="center" class="TextHeader">
			<td width="5%"></td>
			<td width="40%"><cellbytelabel id="2">Orderset</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="2">M&eacute;dico</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="4">Observaci&oacute;n</cellbytelabel></td>
		</tr>
    <% for (int i=0; i<al.size(); i++) {
        cdo = (CommonDataObject) al.get(i);
        String color = "TextRow02";
        if (i % 2 == 0) color = "TextRow01";
    %>
        <%=fb.hidden("id_oset"+i,cdo.getColValue("id_oset"))%>
        <%=fb.hidden("action"+i,cdo.getColValue("action"))%>
        <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
        <%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
        <%=fb.hidden("med_code"+i, cdo.getColValue("med_code", UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getRefCode() : "") )%>
        <%=fb.hidden("oset_desc"+i, cdo.getColValue("oset_desc") )%>
        <tr class="<%=color%>">
          <td align="center"><%=fb.checkbox("valor"+i,"S",(cdo.getColValue("valor").equalsIgnoreCase("S")),viewMode||cdo.getColValue("valor").equalsIgnoreCase("S"),null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>
          <td>
              <%if(cdo.getColValue("valor").equalsIgnoreCase("S")){%>
                <a class="Link00" href="javascript:openActive(<%=cdo.getColValue("id_oset")%>)"><%=cdo.getColValue("oset_desc")%></a>
              <%} else {%>
                <%=cdo.getColValue("oset_desc")%>
              <%} %>
          </td>
          <td> 
              <%=fb.textBox("med_name"+i, cdo.getColValue("med_name") ,false,false,viewMode||cdo.getColValue("med_name"," ").trim().equals("")||cdo.getColValue("valor").equalsIgnoreCase("S"),40,500,"",null,null,null,false,"")%>
              <button type="button" class="CellbyteBtn btn_search_med" id="btn_search_med<%=i%>"<%=viewMode||cdo.getColValue("med_name"," ").trim().equals("")||cdo.getColValue("valor").equalsIgnoreCase("S")? " disabled" : ""%> data-i="<%=i%>">...</button>
          </td>
          
          <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,(!cdo.getColValue("valor").equalsIgnoreCase("S")),viewMode||cdo.getColValue("valor").equalsIgnoreCase("S"),30,1,300,null,"width='100%'",null)%></td>
        </tr>
    <%}%>
		<tr class="TextRow02">
			<td colspan="5" align="right">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="7">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size= Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("TBL_EXP_OSET_ACTIVOXMRN");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and oset_id ="+request.getParameter("id_oset"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
			
		if (request.getParameter("valor"+i) != null && request.getParameter("valor"+i).equalsIgnoreCase("S"))
		{
			cdo.addColValue("pac_id",request.getParameter("pacId"));
			cdo.addColValue("admision",request.getParameter("noAdmision"));
			cdo.addColValue("oset_id",request.getParameter("id_oset"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("oset_desc",request.getParameter("oset_desc"+i));
			cdo.addColValue("estado","A");
			cdo.addColValue("medico_usuario",request.getParameter("med_code"+i));
			cdo.addColValue("medico_nombre",request.getParameter("med_name"+i));
			
			if(request.getParameter("usuario_creacion"+i) == null ||request.getParameter("usuario_creacion"+i).trim().equals(""))
        cdo.addColValue("created_by",(String) session.getAttribute("_userName"));
			if(request.getParameter("fecha_creacion"+i) == null ||request.getParameter("fecha_creacion"+i).trim().equals(""))
        cdo.addColValue("created_date",cDateTime);
			
			cdo.addColValue("modified_date",cDateTime);
			cdo.addColValue("modified_by",(String) session.getAttribute("_userName"));
			cdo.setAction(request.getParameter("action"+i));

			al.add(cdo);
		}
		else if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U"))
		{
			cdo.setAction("D");
			al.add(cdo);
		}
	}

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("TBL_EXP_OSET_ACTIVOXMRN");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
