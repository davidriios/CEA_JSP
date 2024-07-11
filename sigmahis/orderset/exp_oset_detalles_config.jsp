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

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (idOset1 == null) idOset1 = "0";
boolean viewMode = false;

if (request.getMethod().equalsIgnoreCase("GET")) {

sql = "select id_oset, oset_desc, estatus, oset_abrev, cat_admision, id_oset_param from TBL_OSET_HEADER1 where id_oset = "+idOset1;
CommonDataObject cdoHd1 = SQLMgr.getData(sql);
if (cdoHd1 == null) cdoHd1 = new CommonDataObject();

if (idOset1.equals("0")) {
  mode = "add";
} else {
    
  // if (cdoHd1.getColValue("estatus"," ").equalsIgnoreCase("C")) viewMode = true;  
  
  if (change == null){
      
      iNivel2.clear();
      vNivel2.clear();
      
      sql = "select id_oset,id_oset_h2,oder_no,desc_header2,tipo,estado,display_text,extra_info from TBL_OSET_HEADER2 where id_oset = "+idOset1+" order by oder_no";
      al = SQLMgr.getDataList(sql);
              
      for (int i = 0; i < al.size(); i++) {
        CommonDataObject cdo = (CommonDataObject) al.get(i);
        cdo.setKey(i);
        cdo.setAction("U");
        try {
          iNivel2.put(cdo.getKey(), cdo);
        }
        catch(Exception e) {
          System.err.println(e.getMessage());
        }
      } // for i
          
      if (al.size() == 0) {
        CommonDataObject cdo = new CommonDataObject();
        cdo.addColValue("id_oset_h2","0");
        cdo.setKey(iNivel2.size() + 1);
        cdo.setAction("I");
        try {
          iNivel2.put(cdo.getKey(), cdo);
        }
        catch(Exception e){
          System.err.println(e.getMessage());
        }
      } // add line

  } // change null
}
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

function displayDetailNivel2(i, idOset2,  mode){
  if (!idOset2) return;
  var tipo = $("#tipo"+i).val();
  
  if (tipo != 3) return;
  
  var $detContainer = $("#detail-container-"+i);
  $('.imgs').css('transform', 'rotate(180deg)');
  var $cImg = $("#img-"+i);
  $cImg.css('transform', 'initial');
  
  $(".detail-container").hide();
  $detContainer.show(true);
  var $currentIframe = $("#idetail-"+i);
  $currentIframe.attr('src', '../orderset/exp_nivel2_detalles.jsp?tab=1&mode='+mode+'&id_oset_h1=<%=idOset1%>&id_oset_h2='+idOset2)  
}

$(function(){
  
  $("#tabTabdhtmlgoodies_tabView1_2").click(function(e) {
      var $iframe = $("#ipreview");
       $iframe.attr('src', '../orderset/exp_orderset_preview.jsp?id_oset_h1=<%=idOset1%>') 
  });
  //
  
  $("select[name*='tipo']").change(function(e) {
    var self = $(this);
    var i = self.data('i');
    var oldTipo = $("#old_tipo"+i).val();
    var idOset2 = $("#id_oset_h2"+i).val();
    
    if (this.value == 3) {
      $("#del_om_det").val("");
      $("#del_id_oset_h2").val("");
    }
    
    if (oldTipo && this.value != oldTipo && oldTipo == 3) {
      if (confirm("Al cambiar de tipo, es posible que se borren las órdenes médicas guardadas. Continuar")) {
         $("#detail-container-"+i).hide(true);
         $("#del_om_det").val("Y");
         $("#del_id_oset_h2").val(idOset2);
      } else {
        self.val(oldTipo).prop("checked", true);
        $("#del_om_det").val("");
        $("#del_id_oset_h2").val("");
      }
    }
  });

  //
  $("#status").change(function(){
    if (this.value == 'C') $("#warning-cerrar").show(true);
    else $("#warning-cerrar").hide(true);
  });
  //

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
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>C&oacute;digo </cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("id_oset_h1",idOset1,false,false,true,5)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Descripci&oacute;n </cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("oset_desc",cdoHd1.getColValue("oset_desc"),true,false,viewMode,80,200)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Abreviatura </cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("oset_abrev",cdoHd1.getColValue("oset_abrev"),false,false,viewMode,80,20)%>
							</td>
						</tr>
						
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Categor&iacute;a </cellbytelabel></td>
							<td colspan="3"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","cat_admision",cdoHd1.getColValue("cat_admision"),false,viewMode,0,"",null,null,null,"S")%></td>
						</tr>
						
						<tr class="TextRow01">
							<td align="right">Grupo </td>
							<td colspan="3">
							<%=fb.select(ConMgr.getConnection(),"select id_oset_param, descripcion from tbl_oset_param order by 1","id_oset_param",cdoHd1.getColValue("id_oset_param"),true,false, false,0,"S")%></td>
						</tr>
						
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Estado </cellbytelabel></td>
							<td colspan="3"><%=fb.select("status","A=Activo, I=Inactivo,C=Cerrado",cdoHd1.getColValue("estatus"),"")%>
							<%if(!viewMode){%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <span style="color:red;font-weight:bold;display:none;" id="warning-cerrar">Al cerrar ya quedar&aacute; bloqueado la modificaci&oacute;n</span>
							<%}%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				
				
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N", false, viewMode, false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O", true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C", false, viewMode, false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>

<%
 if (!cdoHd1.getColValue("estatus"," ").trim().equals("") && !cdoHd1.getColValue("estatus"," ").equalsIgnoreCase("A")) viewMode = true;  
%>

<!-- TAB DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("nivel2Size",""+iNivel2.size())%>
<%=fb.hidden("id_oset_h1", idOset1)%>
<%=fb.hidden("del_om_det", "")%>
<%=fb.hidden("del_id_oset_h2", "")%>

<tr class="TextPanel01">
  <td>&nbsp;OrderSet</td>
</tr>

<tr class="TextRow01">
  <td>&nbsp;[<%=idOset1%>] <%=cdoHd1.getColValue("oset_desc")%></td>
</tr>

<tr class="TextPanel">
  <td>&nbsp;Configuraciones OrderSet</td>
</tr>
<tr>
  <td>
    <div id="nivel2" style="overflow:scroll; position:static; height:135">
      <table width="100%" cellpadding="1" cellspacing="1">
          
          <tr class="TextHeader" align="center">
            <td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
            <td width="5%"><cellbytelabel>Ord</cellbytelabel>.</td>
            <td width="20%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
            <td width="10%"><cellbytelabel>Tipo</cellbytelabel></td>
            <td width="25%"><cellbytelabel>Texto display</cellbytelabel></td>
            <td width="25%"><cellbytelabel>Exta Info.</cellbytelabel></td>
            <td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
            <td width="2%"></td>
            <td width="2%"><%=fb.submit("addNivel2","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Nivel 2")%></td>
          </tr>
          <%
            al = CmnMgr.reverseRecords(iNivel2);
            boolean flagModify = false;
            for (int i=0; i<iNivel2.size(); i++) {
               key = al.get(i).toString();
               CommonDataObject cdo = (CommonDataObject) iNivel2.get(key);
               String color = "TextRow02";
               if (i % 2 == 0) color = "TextRow01";
               String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
            %>
            
            <%=fb.hidden("remove"+i,"")%>
            <%=fb.hidden("action"+i,cdo.getAction())%>
            <%=fb.hidden("key"+i,cdo.getKey())%>
            
            <%if(cdo.getAction().equalsIgnoreCase("D")){%>
                <%=fb.hidden("id_oset_h2"+i, cdo.getColValue("id_oset_h2"))%>
                <%=fb.hidden("oder_no"+i, cdo.getColValue("oder_no"))%>
                <%=fb.hidden("desc_header2"+i, cdo.getColValue("desc_header2"))%>
                <%=fb.hidden("tipo"+i, cdo.getColValue("tipo"))%>
                <%=fb.hidden("display_text"+i, cdo.getColValue("display_text"))%>
                <%=fb.hidden("extra_info"+i, cdo.getColValue("extra_info"))%>
                <%=fb.hidden("status"+i, cdo.getColValue("status"))%>
            <%}else{%>
            
                <%=fb.hidden("old_tipo"+i, cdo.getColValue("tipo"))%>
            
                <tr class="<%=color%>" align="center" <%=style%>>
                  <td><%=fb.textBox("id_oset_h2"+i,cdo.getColValue("id_oset_h2"),false,false,true,5,"Text10",null,null)%></td>
                  <td><%=fb.textBox("oder_no"+i,cdo.getColValue("oder_no"),true,false,viewMode,5,"Text10",null,null)%></td>
                  <td><%=fb.textarea("desc_header2"+i, cdo.getColValue("desc_header2"), true, false, viewMode, 0, 1,200, "ignore", "width:90%", "")%></td>
                  <td><%=fb.select("tipo"+i,"1=Cabecera,2=Texto display,3=Generar OM",cdo.getColValue("tipo"),false,viewMode,0,"tipo",null,null,null,null,"data-i="+i)%></td>
                  <td><%=fb.textarea("display_text"+i, cdo.getColValue("display_text"), true, false, viewMode, 0, 2,1024, "ignore", "width:90%", "")%></td> 
                  <td><%=fb.textarea("extra_info"+i, cdo.getColValue("extra_info"), true, false, viewMode, 0, 2,1024, "ignore", "width:90%", "")%></td> 
                  <td><%=fb.select("status"+i,"A=Activo, I=Inactivo",cdo.getColValue("status"),"")%></td>
                  <td align="center" onClick="javascript:displayDetailNivel2(<%=i%>,<%=cdo.getColValue("id_oset_h2")%>, '<%=viewMode?"view":""%>')" style="cursor:pointer">
                    <img style="transform: rotate(180deg);" class="imgs" id="img-<%=i%>" src="../images/dwn.gif" alt="Ver / Editar Nivel 2">
                  </td>
                  <td><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
               </tr>
               <tr style="display:none" class="detail-container" id="detail-container-<%=i%>">
                  <td colspan="9">
                      <iframe id="idetail-<%=i%>" name="idetail-<%=i%>" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
                  </td>
                </tr>
           <%}}
            fb.appendJsValidation("if(error>0)doAction();");
            %>
       </table>
     </div>
     
  </td>
</tr>

<tr class="TextRow02">
  <td colspan="9" align="right">
    <cellbytelabel>Opciones de Guardar</cellbytelabel>:
    <%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
    <%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
    <%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
    <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
  </td>
</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
  <table align="center" width="100%" cellpadding="0" cellspacing="1">   
    <tr class="TextRow02">
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>
        <iframe id="ipreview" name="ipreview" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
      </td>
    </tr>
  </table>
</div>
<!-- TAB1 DIV END HERE-->

<!-- MAIN DIV END HERE -->
</div>

<script>
<%
String tabLabel = "'OrderSet'";

if (!idOset1.equals("0")) tabLabel += ",'Detalles','Vista previa'";
%>
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
        
    if (tab.equals("0")) {
        CommonDataObject cdo = new CommonDataObject();
        cdo.setTableName("TBL_OSET_HEADER1");
        
        if (idOset1.equals("0")) {
            cdo.setAutoIncCol("id_oset");
            cdo.addPkColValue("id_oset","");
            cdo.addColValue("CREATED_BY",(String) session.getAttribute("_userName"));
            cdo.addColValue("DATE_CREATED","sysdate");
        } else {
          cdo.setWhereClause("id_oset = "+idOset1);
          cdo.addColValue("MODIFIED_BY",(String) session.getAttribute("_userName"));
          cdo.addColValue("DATE_MODIFIED","sysdate");
        }
        
        cdo.addColValue("oset_desc", request.getParameter("oset_desc"));
        cdo.addColValue("estatus", request.getParameter("status"));
        cdo.addColValue("oset_abrev", request.getParameter("oset_abrev"));
        cdo.addColValue("cat_admision", request.getParameter("cat_admision"));
        cdo.addColValue("id_oset_param", request.getParameter("id_oset_param"));
        
        if (baction.equalsIgnoreCase("Guardar")) {
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            
            if (mode.equalsIgnoreCase("add")) {
                SQLMgr.insert(cdo);
                idOset1 = SQLMgr.getPkColValue("id_oset");
            }
            else SQLMgr.update(cdo);
            
            ConMgr.clearAppCtx(null);
        }
    
    } else if (tab.equals("1")) {
    
        int size = Integer.parseInt(request.getParameter("nivel2Size"));
       
        String itemRemoved = "";
        al.clear();
        iNivel2.clear();
        
        for (int i=0; i<size; i++) {
          CommonDataObject cdo = new CommonDataObject();
          cdo.setTableName("TBL_OSET_HEADER2");
         
          if (request.getParameter("id_oset_h2"+i).equals("0")||request.getParameter("id_oset_h2"+i).trim().equals("")) {
              cdo.setAutoIncCol("id_oset_h2");
              cdo.addColValue("CREATED_BY",(String) session.getAttribute("_userName"));
              cdo.addColValue("DATE_CREATED","sysdate");
          } else {
              cdo.setWhereClause("id_oset = "+idOset1+" and id_oset_h2 = "+request.getParameter("id_oset_h2"+i));
              cdo.addColValue("MODIFIED_BY",(String) session.getAttribute("_userName"));
              cdo.addColValue("DATE_MODIFIED","sysdate");
          }
          
          cdo.addColValue("id_oset", idOset1);
          cdo.addColValue("id_oset_h2", request.getParameter("id_oset_h2"+i));
          cdo.addColValue("oder_no", request.getParameter("oder_no"+i));
          cdo.addColValue("desc_header2", request.getParameter("desc_header2"+i));
          cdo.addColValue("tipo", request.getParameter("tipo"+i));
          cdo.addColValue("estado", request.getParameter("estado"+i));
          cdo.addColValue("display_text", request.getParameter("display_text"+i));
          cdo.addColValue("extra_info", request.getParameter("extra_info"+i));
		  
          cdo.setKey(i);
          cdo.setAction(request.getParameter("action"+i));
		
          if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
            itemRemoved = cdo.getKey();
            if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
            else cdo.setAction("D");
          }	
      
          if (!cdo.getAction().equalsIgnoreCase("X")) {
            try {
              al.add(cdo);
              iNivel2.put(cdo.getKey(),cdo);
            } catch(Exception e) {
              System.err.println(e.getMessage());
            }
            
          }//End else
      }//for
	
      if (!itemRemoved.equals("")) {
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id_oset_h1="+idOset1);
        return;
      }
	
      if (baction.equals("+")) {
        CommonDataObject cdo = new CommonDataObject();
        cdo.addColValue("id_oset_h2","0");
              
        cdo.setAction("I");
        cdo.setKey(iNivel2.size() + 1);
        try {
          iNivel2.put(cdo.getKey(),cdo);
        }
        catch(Exception e){
          System.err.println(e.getMessage());
        }
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id_oset_h1="+idOset1);
        return;
      }
	
      if (baction.equalsIgnoreCase("Guardar")) {
        if (al.size() == 0){
          CommonDataObject cdo = new CommonDataObject();
          cdo.setTableName("TBL_OSET_HEADER2");
          cdo.setWhereClause("id_oset_h2 = 0");
          cdo.setAction("I");
          al.add(cdo);
        }
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
         SQLMgr.saveList(al, true);
        ConMgr.clearAppCtx(null);
        
        if (SQLMgr.getErrCode().equals("1") && request.getParameter("del_om_det") != null && request.getParameter("del_om_det").equals("Y")) {
          SQLMgr.execute("delete from TBL_OSET_HEADER2_DET where oset_header1 = "+idOset1+" and oset_header2 = "+request.getParameter("del_id_oset_h2"));
        }
        
      }
} // tab 1
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