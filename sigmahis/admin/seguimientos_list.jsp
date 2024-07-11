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

String refType = request.getParameter("ref_type");
String refId = request.getParameter("ref_id");
String cajaText = request.getParameter("caja_text");
String compania = (String) session.getAttribute("_companyId");
String userName = (String) session.getAttribute("_userName");

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

String sql = "";
if (refType == null) refType = "";
if (refId == null) refId = "";
if (cajaText == null) cajaText = ":::";

String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

Exception up = new Exception("No pudimos encontrar la referencia asociada con los comentarios!");

if (refType.trim().equals("") || refId.trim().equals("")) throw up;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select s.id, s.comentario, s.usuario_creacion, s.usuario_modificacion, to_char(s.fecha_creacion,'dd/mm/yyyy') fecha_creacion , to_char(s.fecha_modificacion,'dd/mm/yyyy') fecha_modificacion, s.other1, s.other2, s.other3, s.other4, s.other5, decode(s.estado,'A','ACTIVO','INACTIVO') as estado from tbl_admin_seguimientos s where s.compania = "+compania+" and s.ref_type = '"+refType+"' and s.ref_id = '"+refId+"' order by s.fecha_creacion desc";
    
	al = SQLMgr.getDataList(sql);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Administración - Seguimientos - '+document.title;
function doAction(){}

function add(){
  $("#new-form").toggle();
  $("#ml").toggle();
}

$(document).ready(function(){

  $("#save").click(function(e){
    e.preventDefault();
    var $btn = $(this);
    var prevBntTxt = $btn.val();
    
    if (!$.trim( $("#comentario").val() )) CBMSG.error("Por favor ingrese el comentario!");
    else {
      $btn.prop("disabled",true).val(prevBntTxt+"...");
      
      $.post('../admin/seguimientos_list.jsp',$("#seg").serialize())
      .done(function(data){
         var d = $.trim(data);
         var _d = d ? d.split("@@") : [];
         if (_d[0] && _d[0] == "1")
            window.location = "../admin/seguimientos_list.jsp?ref_type=<%=refType%>&ref_id=<%=refId%>&caja_text=<%=cajaText%>&useKeypad=<%=useKeypad%>&touch=<%=touch%>"
         else if (_d[0] && _d[0] == "2") {
           CBMSG.error(_d[1]);
           $btn.prop("disabled",false).val(prevBntTxt);
         }
      })
      .fail(function(jqXHR, textStatus, errorThrown){
           $btn.prop("disabled",false).val(prevBntTxt);
           if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
              alert('Hubo un error 404, por favor contacte un administrador!'); 
           }else{
              alert('Encontramos este error: '+errorThrown);
           }
       });
      
    }
  });
 
});

function imprimir(){
  var id = $("#c_id").val();
  abrir_ventana("../admin/print_seguimientos_list.jsp?ref_type=<%=refType%>&ref_id=<%=refId%>&caja_text=<%=cajaText%>&id="+id);
}

function setId(id){return $("#c_id").val(id);}
</script>
<style>
  textarea{vertical-align:middle}
  input.button{vertical-align:middle}
</style>

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
      $('#comentario').keypad(opts);
      
      $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('#comentario').keypad("hide");
        }
      });
  <%}%>
});
</script>

<%}%>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<table align="center" width="99%" cellpadding="5" cellspacing="0">
		<tr>
			<td class="TableBorder">
				<table width="100%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"4":"0"%>" cellspacing="1" class="TableBorderLightGray">
					<tr class="TextHeader">
						<td colspan="4">COMENTARIOS</td>
						<td align="center" colspan="2">
                        <a href="javascript:imprimir()" class="Link04Bold">Impr.</a>&nbsp;|&nbsp;<a href="javascript:add()" class="Link04Bold">Agregar</a>
                        </td>
					</tr>
				    <tr class="TextHeader" align="center">
						<td width="7%">ID</td>
						<td width="7%">Fecha</td>
						<td width="59%" align="left">Comentario<span style="display:none" id="ml">&nbsp;(512)</span></td>
						<td width="10%">Usuario</td>
						<td width="10%">Estado</td>
						<td width="7%">&nbsp;</td>
					</tr>
                    
                    <form id="seg" name="seg" action="../admin/seguimientos_list.jsp">
                        <input type="hidden" id="ref_type" name="ref_type" value="<%=refType%>">
                        <input type="hidden" id="ref_id" name="ref_id" value="<%=refId%>">
                        <input type="hidden" id="caja_text" name="caja_text" value="<%=cajaText%>">
                        <input type="hidden" id="c_id" name="c_id" value="">
                        <input type="hidden" id="useKeypad" name="useKeypad" value="<%=useKeypad%>">
                        <input type="hidden" id="touch" name="touch" value="<%=touch%>">
                        <tr class="TextHeader" align="center" id="new-form" style="display:none">
                            <td width="7%">0</td>
                            <td width="7%">-</td>
                            <td width="59%" align="left">
                              <textarea name="comentario" id="comentario" cols="40" rows="2" class="text10" style="width: 97%;" maxlength="512"></textarea>
                            </td>
                            <td width="10%"><input name="usuario" id="usuario" value="<%=userName%>" style="width:70%" readonly></td>
                            <td width="10%">
                              <select id="estado" name="estado">
                                <option value="A">Activo</option>
                              </select>
                            </td>
                            <td width="7%"><input type="button" id="save" name="save" value="Guardar" class="CellbyteBtn"></td>
                        </tr>
                                     
					
					<%for (int i=0; i<al.size(); i++){
						String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
						CommonDataObject cdo = (CommonDataObject)al.get(i);
					%>
						<tr class="<%=color%> row" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" data-i="<%=i%>">
							<td align="center"><%=cdo.getColValue("id")%></td>
							<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
							<td><div style="width:695px; word-wrap: break-word;"><%=cdo.getColValue("comentario")%></div></td>
							<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
							<td align="center"><%=cdo.getColValue("estado")%></td>
							<td align="center">
                            <input type="radio" id="unit-<%=i%>" name="unit" data-i="<%=i%>" class="unit" onclick="setId(<%=cdo.getColValue("id")%>)">
                            </td>
						</tr>
				   <%}%>
                     </form>  
			   </table>
			</td>
		</tr>
	</table>
</body>
</html>
<%
}//GET
else {

  if (request.getParameter("comentario") != null && !request.getParameter("comentario").equals("")){
    
    CommonDataObject cdo = new CommonDataObject();
    cdo.setTableName("tbl_admin_seguimientos");
    cdo.setAutoIncCol("id");
    cdo.addColValue("compania", compania);
    cdo.addColValue("ref_type", request.getParameter("ref_type"));
    cdo.addColValue("ref_id", request.getParameter("ref_id"));
    cdo.addColValue("comentario", request.getParameter("comentario")); 
    cdo.addColValue("usuario_creacion", userName); 
    cdo.addColValue("usuario_modificacion", userName);
    cdo.addColValue("fecha_creacion", cDateTime);
    cdo.addColValue("fecha_modificacion", cDateTime); 
    cdo.addColValue("estado", request.getParameter("estado")); 
        
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.insert(cdo);
    ConMgr.clearAppCtx(null);
    
    out.print(SQLMgr.getErrCode()+"@@"+SQLMgr.getErrMsg());  
  }
}
%>