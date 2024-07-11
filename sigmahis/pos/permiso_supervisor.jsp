<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="TrMgr" scope="page" class="issi.caja.TurnosMgr"/>
<%
/**
==========================================================================================
FORMA CK_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TrMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String tipo_desc = request.getParameter("tipo_desc");
boolean viewMode = false;
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cod_caja = request.getParameter("cod_caja");
String compania_caja = request.getParameter("compania_caja");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

if(fg==null) fg = "";
if(fp==null) fp = "";
if(tipo_desc==null) tipo_desc = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
if(cod_caja==null) throw new Exception("No existe numero de caja!");
else if(index ==null) throw new Exception("No existe registro a eliminar!");
%>
<!DOCTYPE html>
<html>
<head>
<%@ include file="../common/header_param_nocaps_min.jsp"%>
<script language="javascript">
document.title = 'Borrar Artículo '+document.title;
function doAction(){
}

function doSubmit(){
	return true;
}

function inicio(accion){
	if(accion=='N') {
		parent.hidePopWin(false);
	} else{
		if (!inicio_cajaValidation()){
		 inicio_cajaValidation(false);
		 return false;
		} else document.inicio_caja.submit();
	}
}

$(document).ready(function(){
  $("#user, #pass").click(function(e){
    $(this).val("");
  })
});
</script>
<% if(touch.trim().equalsIgnoreCase("Y")){%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
    display:none; 
    margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>

<script>
$(document).ready(function(){
  <%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
      var opts ={
        keypadOnly: false, 
        layout: [
        '1234567890-', 
        'qwertyuiop' + $.keypad.CLOSE, 
        'asdfghjkl' + $.keypad.CLEAR, 
        'zxcvbnm' + 
        $.keypad.SPACE_BAR + $.keypad.BACK]
      };
      $('#user, #pass').keypad(opts);
      
      $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('#user, #pass').keypad("hide");
        }
      });
  <%}%>
});
</script>

<%}%>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"7":"0"%>" cellspacing="1">
						<%
						fb = new FormBean("inicio_caja","","post");
						%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
              <%=fb.hidden("saveOption","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <%=fb.hidden("cod_caja",cod_caja)%>
              <%=fb.hidden("index",index)%>
              <%=fb.hidden("useKeypad",useKeypad)%>
                <%=fb.hidden("touch",touch)%>
                <%=fb.hidden("tipo_desc",tipo_desc)%>
          
              <tr class="TextHeader02">
                <td align="center" colspan="2"><cellbytelabel>Supervisor</cellbytelabel></td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><font class="RedTextBold">
                <cellbytelabel>Usuario</cellbytelabel>:</font>
                </td>
                <td>
                <%=fb.textBox("user","",true,false,false,20,30,"FormDataObject",null,"",null,false,"autocomplete=off")%>
                </td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><font class="RedTextBold">
                <cellbytelabel>Contrase&ntilde;a</cellbytelabel>:</font>
                </td>
                <td>
                <%=fb.passwordBox("pass","",true,false,false,20,"FormDataObject",null,null)%>
                </td>
              </tr>
              <tr class="TextHeader02">
                <td align="center" colspan="2">
                <%=fb.button("aceptar","Aceptar",false, viewMode,"","","onClick=\"javascript:inicio('S')\"")%>
                <%=fb.button("cancel","Cancelar",false, viewMode,"","","onClick=\"javascript:inicio('N');\"")%>
                </td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</body>
</html>
<%
} else {
	CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("cod_caja", request.getParameter("cod_caja"));
	cdo.addColValue("compania_caja", request.getParameter("compania_caja"));
	cdo.addColValue("user_name", request.getParameter("user"));
	cdo.addColValue("user_password", request.getParameter("pass"));
	String cod_supervisor = TrMgr.checkSupervisor(cdo);
%>
<html>
<head>
<script>
function closeWindow(cod_supervisor)
{
	if(cod_supervisor!='_NO_EXISTE'){
		<%
		if(fp.equals("POS")){
			if(fg.equals("DEL")){%>
				parent.borra(<%=request.getParameter("index")%>);
				parent.hidePopWin(false);
		<%} else if(fg.equals("DES")){%>
			parent.descuenta(<%=request.getParameter("index")%>);
			//parent.hidePopWin(false);
		<%} else if(fg.equals("DESG")){%>
			parent.setDescAuto('<%=request.getParameter("tipo_desc")%>');
		<%
			}
		}%>
	} else {
		alert('Usted no esta registrado como supervisor para esta caja!');
		parent.hidePopWin(false);
	}
}
</script>
</head>
<body onLoad="closeWindow('<%=cod_supervisor%>')">
</body>
</html>
<%
}
%>