<%@ page errorPage="../error.jsp"%>
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
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania = (String) session.getAttribute("_companyId");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  sql = "select a.codigo as cod_antecedente, a.descripcion, nvl(b.valor,' ') as valor, nvl(b.observacion,' ') as observacion,b.antecedente,decode(b.antecedente,null,'I','U') action,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.usuario_creacion, '' history, decode(a.grupo,1,'PATOLOGICO','NO PATOLOGICO') as grupo_desc, a.grupo, a.es_default, (select count(*) from tbl_sal_antecedente_personal b, tbl_sal_diagnostico_personal a where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.antecedente and a.es_default <> 'S') tot_saved from tbl_sal_diagnostico_personal a, tbl_sal_antecedente_personal b where a.codigo=b.antecedente(+) and b.pac_id(+)="+pacId+" and b.admision(+) = "+noAdmision+" and a.status = 'A' order by a.grupo, a.orden";	
  al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - Antecedente Personal - '+document.title;

function doAction(){newHeight();}
function isChecked(k){
/*var color_string='#FFFF99';var color_string1='#CCCCCC';eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;if  (eval('document.form0.aplicar'+k).checked){eval('document.form0.observacion'+k).enabled = true;eval('document.form0.observacion'+k).style.backgroundColor  = color_string;}else{eval('document.form0.observacion'+k).disabled = true;eval('document.form0.observacion'+k).style.backgroundColor  = color_string1;}if( eval('document.form0.observacion'+k).length < 0){
alert('Campo Requerido o Valor Inválido!!');eval('document.form0.observacion'+k).focus();return false;}else return true;*/}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_2.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}

$(function(){
  $(".history").tooltip({
    content: function () {
      var $i = $(this).data("i");
      var $title = $($(this).prop('title'));
      var $content = $("#historyCont"+$i).val();
      var $cleanContent = $($content).text();
      if (!$cleanContent) $content = "";
      return $content;
    }
  });
  
  $(".grupo-2").not(".default-2").click(function(e){
        var _default = $("input:checkbox[data-default-2='S']");
        if (_default.is(":checked")) {
           e.preventDefault();
           return false;
        } else {
            var self = $(this);
            var i = self.data('i');
            ctrlFields(i, self.is(":checked"));
        }
    });
        
      $(".grupo-1").not(".default-1").click(function(e){
          var _default = $("input:checkbox[data-default-1='S']");
          if (_default.is(":checked")) {
             e.preventDefault();
             return false;
          } else {
              var self = $(this);
              var i = self.data('i');
              ctrlFields(i, self.is(":checked"));
          }
      });
        
        $(".default-1, .default-2").click(function(){
            var self = $(this);
            var i = self.data('i');
            var grupo = self.data('grupo');
            if (this.checked) {
                $(".grupo-"+grupo).not(self).prop("checked", false).each(function(){
                    ctrlFields($(this).data('i'), $(this).is(":checked"));
                });
                $(".field-"+grupo).not(self).prop("readOnly", true).val("");
                ctrlFields(i, true)
            } else ctrlFields(i, false)
        });
  
});

function ctrlFields(i, isChecked) {
      var action = $("#action_tmp"+i).val();
      if (isChecked) {
          $("#observacion"+i).prop("readOnly", false).removeClass('FormDataObjectDisabled');
          $("#action"+i).val(action);
      } else {
          $("#observacion"+i).prop("readOnly", true).val("").addClass('FormDataObjectDisabled');;
          if (action == 'U') $("#action"+i).val("D");
      }
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
		<tr class="TextRow02" >
			<td colspan="4" align="right"><a href="javascript:printExp()"  class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td>
		</tr>
		<tr align="center"  class="TextHeader">
			<td width="35%"><cellbytelabel id="2">Diagn&oacute;sticos</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="3">S&iacute;</cellbytelabel></td>
			<td width="50%"><cellbytelabel id="4">Observaci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">&nbsp;</cellbytelabel></td>
		</tr>
<%
String group = "";
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String history = cdo.getColValue("history").equals("")?"":"Historial";
	
	if (!group.equals(cdo.getColValue("grupo"))){
        %>
            <tr class="TextHeader02">
                <td colspan="4"><%=cdo.getColValue("grupo_desc")%></td>
            </tr>
        <%
            }
        %>
		<%=fb.hidden("antecedente"+i,cdo.getColValue("cod_antecedente"))%>
		<%=fb.hidden("antecedentePac"+i,cdo.getColValue("antecedente"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("action_tmp"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		
		<%=fb.hidden("historyCont"+i,"<label class='historyCont' style='font-size:11px'>"+(cdo.getColValue("history")==null?"":cdo.getColValue("history"))+"</label>")%>
		
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("descripcion")%></td>
			
			<td align="center">
			
			<%//=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("valor").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%>
			
			<%=fb.checkbox("aplicar"+i,"S",(cdo.getColValue("valor").equalsIgnoreCase("S")|| (cdo.getColValue("es_default").equalsIgnoreCase("S")&&cdo.getColValue("tot_saved","0").equals("0"))),viewMode,"grupo-"+cdo.getColValue("grupo"," ")+(cdo.getColValue("es_default"," ").equalsIgnoreCase("S")?" default-"+cdo.getColValue("grupo"," "):""),null,"onClick=\"javascript:isChecked("+i+")\"",null," data-default-"+cdo.getColValue("grupo")+"='"+cdo.getColValue("es_default")+"' data-i="+i+" data-grupo="+cdo.getColValue("grupo"," "))%>
			
			</td>
			
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||(!cdo.getColValue("valor").equalsIgnoreCase("S")),50,1,2000,"form-control input-sm field-"+cdo.getColValue("grupo"," "),null,null)%></td>
			<td align="center">
			  <span class="history" title="" data-i="<%=i%>"><span class="Link00 pointer"><%=history%></span></span>
			</td>
		</tr>
<%
group = cdo.getColValue("grupo");
}
%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	al.clear();
	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_antecedente_personal");

		if (request.getParameter("aplicar"+i) != null && request.getParameter("aplicar"+i).equalsIgnoreCase("S")) {
			if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U")){
                cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and antecedente ="+request.getParameter("antecedente"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
                cdo.setAction("U");
                cdo.addColValue("fecha_modificacion",cDateTime);
                cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
            }
            else {
                cdo.setAction("I");
                cdo.addColValue("fec_nacimiento",request.getParameter("dob"));
                cdo.addColValue("cod_paciente",request.getParameter("codPac"));
                cdo.addColValue("pac_id",request.getParameter("pacId"));
                cdo.addColValue("admision",request.getParameter("noAdmision"));
                cdo.addColValue("fecha_creacion",cDateTime);
                cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
            }
            
			cdo.addColValue("antecedente",request.getParameter("antecedente"+i));
			cdo.addColValue("valor","S");
			cdo.addColValue("observacion",request.getParameter("observacion"+i));

			al.add(cdo);
		} else {
            if (request.getParameter("action"+i).trim().equalsIgnoreCase("D")){
                cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and antecedente ="+request.getParameter("antecedente"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
                cdo.setAction("D");
                al.add(cdo);
            }
        }
	}
	if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_antecedente_personal");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId"));
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
