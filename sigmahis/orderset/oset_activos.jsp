<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNivel2" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNivel2" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String compania = ((String) session.getAttribute("_companyId"));

String change = request.getParameter("change");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String idOset1 = request.getParameter("id_oset_h1");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String estado = request.getParameter("estado");

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (idOset1 == null) idOset1 = "0";
if (pacId == null) pacId = "0";
if (noAdmision == null) noAdmision = "0";
boolean viewMode = false;

if (request.getMethod().equalsIgnoreCase("GET")) {

sql = "select id_oset, oset_desc, estatus, oset_abrev, cat_admision, id_oset_param from TBL_OSET_HEADER1 where id_oset = "+idOset1;
CommonDataObject cdoHd1 = SQLMgr.getData(sql);
if (cdoHd1 == null) cdoHd1 = new CommonDataObject();

CommonDataObject cdoP = SQLMgr.getData("select p.nombre_paciente, p.id_paciente, p.sexo, p.edad, coalesce(d.cama,decode(a.categoria,1,'SIN ASIGNAR',' ')) as cama from tbl_adm_admision a, tbl_adm_atencion_cu d, vw_adm_paciente p where a.pac_id = d.pac_id and a.secuencia = d.secuencia and a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.pac_id = p.pac_id");
if (cdoP == null) cdoP = new CommonDataObject();

CommonDataObject cdoM = SQLMgr.getData("select medico_usuario med_code, nvl(medico_nombre, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = b.medico_usuario)) as med_name from TBL_EXP_OSET_ACTIVOXMRN b where pac_id = "+pacId+" and admision = "+noAdmision+" and oset_id = "+idOset1);
if (cdoM == null) cdoM = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<style>.hide{display:none}</style>
<script>
document.title = 'Registros de OrderSet - '+document.title;

function doAction(){}

$(function(){

  $("#tabTabdhtmlgoodies_tabView1_0").click(function(e) {
      var $iframe = $("#iomorderset");
      $iframe.attr('src', '../orderset/exp_oset_orden_medicas.jsp?id_oset_h1=<%=idOset1%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
  });
  
  $("#tabTabdhtmlgoodies_tabView1_1").click(function(e) {
       var $iframe = $("#om_ejecutadas");
       $iframe.attr('src', '../orderset/exp_oset_orden_medicas_ejecutadas.jsp?id_oset_h1=<%=idOset1%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
  });
  
  $("#tabTabdhtmlgoodies_tabView1_2").click(function(e) {
       var $iframe = $("#revision");
       $iframe.attr('src', '../expediente/expediente_ordenes_medicas.jsp?pacId=<%=pacId%>&secuencia=<%=noAdmision%>&orderset=Y&nombre=<%=IBIZEscapeChars.forURL(cdoP.getColValue("nombre_paciente"))%>&cedula=<%=IBIZEscapeChars.forURL(cdoP.getColValue("id_paciente"))%>&cama=<%=IBIZEscapeChars.forURL(cdoP.getColValue("cama"))%>&edad=<%=cdoP.getColValue("edad")%>&sexo=<%=cdoP.getColValue("sexo")%>');
  });
  
  $("#tabTabdhtmlgoodies_tabView1_3").click(function(e) {
      var $iframe = $("#ipreview");
      $iframe.attr('src', '../orderset/exp_orderset_preview.jsp?id_oset_h1=<%=idOset1%>');
  });
  //
  
   $("#btn_search_med").click(function() {
        var self = $(this);
        var medNameOrCode = $.trim( $("#med_name").val() );
        if (medNameOrCode) {
            $("#med_code").val("");
            self.prop('disabled',true);
            var url = '../orderset/sel_extras.jsp?fp=medico&fg=oset_activos&index=&descripcion=' + medNameOrCode + '&context=preventPopupFrame';
            $("#preventPopupFrame").show(0).attr('src', url);
            self.prop('disabled',false);
        }
    });
    
     $("#med_name").click(function(e){
        this.select();
     });

  $('iframe').iFrameResize({
    log: false
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE DETALLES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		
        <tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>							
							<td width="5%" align="right">
                [<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;
              </td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=""%>"></jsp:param>
							<jsp:param name="tr" value="<%=""%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				
				<tr class="TextPanel02">
          <td>
            <span style="font-size: 15px">
            &nbsp;&nbsp;
              <%=cdoHd1.getColValue("oset_desc")%>
          </td>
        </tr>
        
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <tr class="TextRow02">
            <td>
              <!--Tipo:
              <%//=fb.select(ConMgr.getConnection(),"select id, descripcion, subtipo from TBL_OSET_TIPO_OM_CONFIG order by 1","om_type","",false,viewMode,0,"",null,"",null,"S")%>
              &nbsp;&nbsp;&nbsp;&nbsp;
              -->
              M&eacute;dico:
              <%=fb.textBox("med_name", UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getName() : cdoM.getColValue("med_name"),false,false,viewMode,40,500,"",null,null,null,false,"")%>
              <button type="button" class="CellbyteBtn" id="btn_search_med" <%=viewMode ? " disabled" : ""%>>...</button>
              <%=fb.hidden("med_code",  UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getRefCode() : cdoM.getColValue("med_code"))%>
			  <!--Sexo:-->
			  <%//=fb.textBox("pac_sexo", "",false,false,viewMode,1,500,"",null,null,null,false,"")%>
			  Peso (Kg):
			  <%=fb.decBox("pac_peso", "",false,false,viewMode,10,500,"",null,null,null,false,"")%>
            </td>
        </tr>
        <tr>
          <td>
            <iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
          </td>
        </tr>
        <%=fb.formEnd(true)%>

        <tr>
          <td>
              <!-- MAIN DIV START HERE -->
              <div id="dhtmlgoodies_tabView1">

                  <!-- TAB1 DIV START HERE-->
                  <div class="dhtmlgoodies_aTab">

                      <table align="center" width="100%" cellpadding="0" cellspacing="1">
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                          </tr>
                          
                          <tr>
                              <td>
                                  <iframe id="iomorderset" name="iomorderset" width="100%" height="0" scrolling="no" frameborder="0" src="../orderset/exp_oset_orden_medicas.jsp?id_oset_h1=<%=idOset1%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>"></iframe>
                              </td>
                          </tr>
                      </table>

                  </div>
                  <!-- TAB1 DIV END HERE-->
                  
                  <!-- TAB2 DIV START HERE-->
                  <div class="dhtmlgoodies_aTab">

                      <table align="center" width="100%" cellpadding="0" cellspacing="1">
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                          </tr>
                          
                          <tr>
                            <td>
                                <iframe id="om_ejecutadas" name="om_ejecutadas" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
                            </td>
                          </tr>
                       </table>   
                  </div>
                  <!-- TAB2 END HERE-->
                  
                  <!-- TAB3 DIV START HERE-->
                  <div class="dhtmlgoodies_aTab">

                      <table align="center" width="100%" cellpadding="0" cellspacing="1">
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                          </tr>
                          
                          <tr>
                            <td>
                                <iframe id="revision" name="revision" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
                            </td>
                          </tr>
                       </table>   
                  </div>
                  <!-- TAB3 END HERE-->
                  
                  <!-- TAB4 DIV START HERE-->
                  <div class="dhtmlgoodies_aTab">

                      <table align="center" width="100%" cellpadding="0" cellspacing="1">
                          <tr class="TextRow02">
                            <td>&nbsp;</td>
                          </tr>
                          
                          <tr>
                              <td style="">
                                  <iframe id="ipreview" name="ipreview" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
                              </td>
                          </tr>
                      </table>

                  </div>
                  <!-- TAB4 DIV END HERE-->


                </div>
                <!-- MAIN DIV END HERE -->
          </td>
        </tr>
        
        
        <!--
        <tr>
          <td>
              <div style="height: 200px; background-color:#eee">
                DIV
              </div>
          </td>
        </tr>
        -->
        
<script>
<%String tabLabel = "'OM de OrderSet', 'OM Generadas', 'Revisión', 'OrderSet'";%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

			</td>
		</tr>
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
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
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
	window.close();
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id_oset_h1=<%=idOset1%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>