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
<jsp:useBean id="iNivel2Det" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNivel2Det" scope="session" class="java.util.Vector" />
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
String idOsetH1 = request.getParameter("id_oset_h1");
String idOsetH2 = request.getParameter("id_oset_h2");

if (idOsetH1 == null) idOsetH1 = "0";
if (idOsetH2 == null) idOsetH2 = "0";
if (tab == null) tab = "0";
if (mode == null) mode = "add";

boolean viewMode = mode.equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET")) {
		
	CommonDataObject cdoHd2 = SQLMgr.getData("select DESC_HEADER2, tipo from TBL_OSET_HEADER2 where ID_OSET = "+idOsetH1);
	if (cdoHd2 == null) cdoHd2 = new CommonDataObject();
		
if (change == null){
        
    iNivel2Det.clear();
    vNivel2Det.clear();
    
    sql = "select oset_header1, oset_header2, oset_det_id, disp_order, display_text, ref_name, om_type, ref_code, add_info_text, status , can_change from TBL_OSET_HEADER2_DET where oset_header1 = "+idOsetH1+" and oset_header2 = "+idOsetH2+" order by om_type desc";
    
    al = SQLMgr.getDataList(sql);
        
    for (int i = 0; i < al.size(); i++) {
      CommonDataObject cdo = (CommonDataObject) al.get(i);
      cdo.setKey(i);
      cdo.setAction("U");
      try {
        iNivel2Det.put(cdo.getKey(), cdo);
      }
      catch(Exception e) {
        System.err.println(e.getMessage());
      }
    } // for i
    
    if (al.size() == 0) {
      CommonDataObject cdo = new CommonDataObject();
      cdo.addColValue("OSET_DET_ID","0");
      cdo.setKey(iNivel2Det.size() + 1);
      cdo.setAction("I");
      try {
        iNivel2Det.put(cdo.getKey(), cdo);
      }
      catch(Exception e){
        System.err.println(e.getMessage());
      }
    } // add line
        
} // change null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'Registros de OrderSet - '+document.title;
function doAction(){}
$(function() {
  
  $("select[name*='om_type']").change(function(){
      var i = this.id.replace ( /[^\d.]/g, '' );

      if (this.value == "") {
        $(".ctrl"+i).val('').prop({readonly:true, disabled:true}).addClass("FormDataObjectDisabled");
        $("#can_change"+i).prop({checked: false, disabled: true})
      } else {
        $(".ctrl"+i).prop({readonly:false, disabled:false}).removeClass("FormDataObjectDisabled");
        $("#can_change"+i).prop({disabled: false})
      }
  });
  
  $(".btn-extra").click(function() {
    var self = $(this);
    var i = self.data('i');
	var refCode = $("#ref_code"+i).val() || ''
    var type = $("#om_type"+i+" option:selected").prop('title') || $("#_om_type"+i+"Dsp option:selected").prop('title');
    var types = type.split("@@");
    var reqExtra = types[1];
    type = types[0];
		        
    if (reqExtra == 'Y' || reqExtra == 'S') {
      var osetDetId = $("#oset_det_id"+i).val();
      parent.showPopWin('../orderset/extra_config.jsp?oset_det_id='+osetDetId+'&oset_header1=<%=idOsetH1%>&oset_header2=<%=idOsetH2%>&mode=<%=viewMode?"view":"edit"%>&type='+type+'&procedimiento='+refCode,winWidth*.50,winHeight*.45,null,null,'');
    }
    
  });
  
  $(".btn_search_extra").click(function() {
    var self = $(this);
    var i = self.data('i');
    var id = self.attr('id');
    var type = $("#om_type"+i+" option:selected").prop('title') || $("#_om_type"+i+"Dsp option:selected").prop('title');
    var displayText = $.trim( $("#display_text"+i).val() );
    
    type = type.split("@@")[0];
    
    if (type && displayText) {
        self.prop('disabled',true);
        
        var baseUrls = {
          MED: '../orderset/sel_extras.jsp?fp=MED&index='+i,
          LIS: '../orderset/sel_extras.jsp?fp=LIS&index='+i,
          RIS: '../orderset/sel_extras.jsp?fp=RIS&index='+i,
          VAR: '../orderset/sel_extras.jsp?fp=VAR&index='+i,
          NUT: '../orderset/sel_extras.jsp?fp=NUT&index='+i,
          TRA: '../orderset/sel_extras.jsp?fp=TRA&index='+i,
          BDS: '../orderset/sel_extras.jsp?fp=BDS&index='+i,
          INT: '../orderset/sel_extras.jsp?fp=INT&index='+i,
        };
        
        var searchParams = {
          MED: "descripcion",
          LIS: "descripcion",
          RIS: "descripcion",
          VAR: "descripcion",
          NUT: "descripcion",
          TRA: "descripcion",
          BDS: "descripcion",
          INT: "descripcion",
        };
       
        var url = baseUrls[type] + '&' + searchParams[type] + '=' + displayText + '&context=preventPopupFrame';
        $("#preventPopupFrame").show(0).attr('src', url);
        self.prop('disabled',false);
    }
  });
  
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("id_oset_h1", idOsetH1)%>
<%=fb.hidden("id_oset_h2", idOsetH2)%>
<%=fb.hidden("detSize",""+iNivel2Det.size())%>

    <tr><td colspan="9">&nbsp;</td></tr>
    <tr><td colspan="9">
    <iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
    </td></tr>
    
    <tr class="TextPanel02">
      <td colspan="9">OM de OrderSet</td>
    </tr>

    <tr class="TextHeader" align="center">
      <td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
      <td width="17%"><cellbytelabel>Ref.Tipo</cellbytelabel></td>
      <td width="5%"><cellbytelabel>Ord.</cellbytelabel></td>
      <td width="26%"><cellbytelabel>Disp.Txt</cellbytelabel></td>
      <td width="18%"><cellbytelabel>Ref.Nombre</cellbytelabel></td>
      <td width="10%"><cellbytelabel>Ref.C&oacute;d.</cellbytelabel></td>
      <td width="16%"><cellbytelabel>--</cellbytelabel></td>
      <td width="2%"><%=fb.submit("addDet","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Nivel 2")%></td>
    </tr>
    <%
    al = CmnMgr.reverseRecords(iNivel2Det);
    boolean flagModify = false;
    //for (int i=0; i<iNivel2Det.size(); i++) {
    for (int i=(iNivel2Det.size()-1); i>=0; i--) {
       key = al.get(i).toString();
       CommonDataObject cdo = (CommonDataObject) iNivel2Det.get(key);
       String color = "TextRow02";
       if (i % 2 == 0) color = "TextRow01";
       String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
    %>
                      
    <%=fb.hidden("remove"+i,"")%>
    <%=fb.hidden("action"+i,cdo.getAction())%>
    <%=fb.hidden("key"+i,cdo.getKey())%>
     
    <%if(cdo.getAction().equalsIgnoreCase("D")){%>
        <%=fb.hidden("oset_det_id"+i, cdo.getColValue("oset_det_id"))%>
        <%=fb.hidden("disp_order"+i, cdo.getColValue("disp_order"))%>
        <%=fb.hidden("display_text"+i, cdo.getColValue("display_text"))%>
        <%=fb.hidden("ref_name"+i, cdo.getColValue("ref_name"))%>
        <%=fb.hidden("om_type"+i, cdo.getColValue("om_type"))%>
        <%=fb.hidden("ref_code"+i, cdo.getColValue("ref_code"))%>
        <%=fb.hidden("add_info_text"+i, cdo.getColValue("add_info_text"))%>
        <%=fb.hidden("status"+i, cdo.getColValue("status"))%>
        <%=fb.hidden("can_change"+i, cdo.getColValue("can_change"))%>
    <%}else{%>
        <tr class="<%=color%>" align="center" <%=style%>>
            <td><%=fb.textBox("oset_det_id"+i,cdo.getColValue("oset_det_id"),false,false,true,5,"Text10",null,null)%></td>
            <td>
            <%=fb.select(ConMgr.getConnection(),"select id, descripcion, subtipo||'@@'||require_extra_info from TBL_OSET_TIPO_OM_CONFIG order by 1","om_type"+i,cdo.getColValue("om_type"),false,viewMode,0,"",null,"",null,"S")%>
            </td>
            <td><%=fb.textBox("disp_order"+i,cdo.getColValue("disp_order"),true,false,viewMode||cdo.getColValue("display_text"," ").trim().equals(""),5,2,"Text10 ctrl"+i,null,null,null, false, "")%></td>
            <td>
              <%=fb.textBox("display_text"+i,cdo.getColValue("display_text"),true,false,viewMode||cdo.getColValue("display_text"," ").trim().equals(""),50,500,"Text10 ignore display_text ctrl"+i,null,null,null,false,"data-i="+i)%>
              <button type="button" class="CellbyteBtn btn_search_extra ctrl<%=i%>" id="btn_search_extra<%=i%>"<%=viewMode||cdo.getColValue("display_text"," ").trim().equals("")? " disabled" : ""%> data-i="<%=i%>">...</button>
            </td>
            <td><%=fb.textBox("ref_name"+i,cdo.getColValue("ref_name"),false,false,viewMode||cdo.getColValue("display_text"," ").trim().equals(""),35,"Text10 ctrl"+i,null,null)%></td>
            <td><%=fb.textBox("ref_code"+i,cdo.getColValue("ref_code"),false,false,viewMode||cdo.getColValue("display_text"," ").trim().equals(""),15,"Text10 ctrl"+i,null,null)%></td>
            <td>
            <label><input title="Permitir cambios" type="checkbox" name="can_change<%=i%>"  id="can_change<%=i%>" value="<%=cdo.getColValue("can_change", "Y")%>"<%=cdo.getColValue("can_change", " ").trim().equals("") || cdo.getColValue("can_change", " ").equalsIgnoreCase("Y") ? " checked" : ""%> <%=viewMode?" disabled":""%>>Modificable?</label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            
            <%if(!cdo.getColValue("oset_det_id", "0").equals("0")){%>
            <button type="button" class="CellbyteBtn btn-extra" data-i="<%=i%>" id="btn-extra-<%=i%>"<%=viewMode?" disabledsss":""%>>Extra</button>
            <%}%>
  
            </td>
            <td><%=fb.submit("rem"+i,"X",false,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
         </tr> 
         <%=fb.hidden("status"+i, cdo.getColValue("status", "A"))%>
         
      <%}%>
                      
      <%}
      fb.appendJsValidation("if(error>0)doAction();");
      %>
				<tr class="TextRow02"><td colspan="10">&nbsp;</td></tr>
				<tr class="TextRow02">
					<td colspan="10" align="right">
						<%=fb.hidden("saveOption","O")%>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value);\"")%>
					</td>
				</tr>
				
				<tr class="TextRow02"><td colspan="10">&nbsp;</td></tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");
    String baction = request.getParameter("baction");
    int size = Integer.parseInt(request.getParameter("detSize"));
    
    String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	  String itemRemoved = "";
    al.clear();
    iNivel2Det.clear();
    
    for (int i=0; i<size; i++) {
      CommonDataObject cdo = new CommonDataObject();

      cdo.setTableName("TBL_OSET_HEADER2_DET");

      if (request.getParameter("oset_det_id"+i).equals("0")||request.getParameter("oset_det_id"+i).trim().equals("")) {
        cdo.setAutoIncCol("oset_det_id");
        // cdo.setAutoIncWhereClause("id_oset = "+idOsetH1);
        cdo.addColValue("CREATED_BY",(String) session.getAttribute("_userName"));
        cdo.addColValue("DATE_CREATED", cDateTime);
        
      } else {
        cdo.setWhereClause("oset_det_id = "+request.getParameter("oset_det_id"+i)+" and oset_header1 = "+idOsetH1+" and oset_header2 = "+idOsetH2);
			  cdo.addColValue("MODIFIED_BY",(String) session.getAttribute("_userName"));
        cdo.addColValue("DATE_MODIFIED", cDateTime);
		  }

      cdo.addColValue("oset_header1", idOsetH1);
      cdo.addColValue("oset_header2", idOsetH2);
      cdo.addColValue("disp_order", request.getParameter("disp_order"+i));
      cdo.addColValue("ref_name", request.getParameter("ref_name"+i));
      cdo.addColValue("om_type", request.getParameter("om_type"+i));
      cdo.addColValue("ref_code", request.getParameter("ref_code"+i));
      cdo.addColValue("status", request.getParameter("status"+i));
      cdo.addColValue("add_info_text", request.getParameter("add_info_text"+i));
      cdo.addColValue("display_text", request.getParameter("display_text"+i));
      cdo.addColValue("oset_det_id", request.getParameter("oset_det_id"+i));
      
      if (request.getParameter("can_change"+i)!=null) cdo.addColValue("can_change", "Y");
      else cdo.addColValue("can_change", "N");
            
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
          iNivel2Det.put(cdo.getKey(),cdo);
        } catch(Exception e) {
          System.err.println(e.getMessage());
        }
        
		}//End else
		
	}//for
	
	if (!itemRemoved.equals("")) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&id_oset_param_code="+request.getParameter("id_oset_param_code")+"&id_oset_param_desc="+request.getParameter("id_oset_param_desc")+"&id_oset_h1="+request.getParameter("id_oset_h1")+"&id_oset_h2="+request.getParameter("id_oset_h2"));
		return;
	}
	
	if (baction.equals("+")) {
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("oset_det_id","0");
          
		cdo.setAction("I");
		cdo.setKey(iNivel2Det.size() + 1);
		try {
			iNivel2Det.put(cdo.getKey(),cdo);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&id_oset_param_code="+request.getParameter("id_oset_param_code")+"&id_oset_param_desc="+request.getParameter("id_oset_param_desc")+"&id_oset_h1="+request.getParameter("id_oset_h1")+"&id_oset_h2="+request.getParameter("id_oset_h2"));
		return;
	}
	
	if (baction.equalsIgnoreCase("Guardar")) {
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_OSET_HEADER2_DET");
			cdo.setWhereClause("oset_header1 = "+idOsetH1+" and oset_header2 = "+idOsetH2);
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		 SQLMgr.saveList(al, true);
		ConMgr.clearAppCtx(null);
	}
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
	// alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id_oset_h1=<%=idOsetH1%>&id_oset_h2=<%=idOsetH2%>';
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>