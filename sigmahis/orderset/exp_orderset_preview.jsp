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

ArrayList al2 = new ArrayList();
String key = "";
String sql = "";
String compania = ((String) session.getAttribute("_companyId"));

String change = request.getParameter("change");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String idOsetH1 = request.getParameter("id_oset_h1");
String idOsetH2 = request.getParameter("id_oset_h2");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (idOsetH1 == null) idOsetH1 = "0";
if (idOsetH2 == null) idOsetH2 = "0";
if (tab == null) tab = "0";
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {
		
	CommonDataObject cdoHd1 = SQLMgr.getData("select h.oset_desc, (select count(*) from TBL_EXP_OSET_ACTIVOXMRN where pac_id = "+pacId+" and admision = "+noAdmision+" and oset_id = h.id_oset) as activo from TBL_OSET_HEADER1 h where h.ID_OSET = "+idOsetH1);
	if (cdoHd1 == null) cdoHd1 = new CommonDataObject();
  
  al2 = SQLMgr.getDataList("select id_oset_h2, nvl(display_text, desc_header2) desc_header2, extra_info, tipo from TBL_OSET_HEADER2 where id_oset = "+idOsetH1+" order by oder_no");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<link rel="stylesheet" href="../css/Font-Awesome-4.7.0/css/font-awesome.min.css" type="text/css"/>
<script>
document.title = 'Vista previa de OrderSet - '+document.title;
function doAction(){}

$(function() {
  $("#btn-print").click(function(){
    abrir_ventana1('../orderset/print_orderset.jsp?id_oset=<%=idOsetH1%>');
  });
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="1">    
    <tr class="TextPanel02">
      <td>
        <span style="font-size: 15px">
        &nbsp;&nbsp;
          <%=cdoHd1.getColValue("oset_desc")%>
          
          <%if ( !cdoHd1.getColValue("activo","0").equals("0") ) {%>
             &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="color:red">activo</span>
          <%}%>
        </span>
        
        <span style="float:right; margin-right: 10px">
            <button id="btn-print" type="button" class="CellbyteBtn">Imprimir</button>
         </span>
         
      </td>
      
    </tr>

    <%if(al2.size() > 0){%>
    <tr>
      <td>
          <ul style="list-style-type: none;">
            <%
              for (int h2 = 0; h2<al2.size(); h2++) {
                CommonDataObject cdo2 = (CommonDataObject) al2.get(h2);
            %>
              <%if(cdo2.getColValue("tipo"," ").trim().equals("1")){%>
                  <li>
                  <h3><%=cdo2.getColValue("desc_header2")%>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                  <%}%>
                  </h3>
                  </li>
              <%}%>
              
              <%if(cdo2.getColValue("tipo"," ").trim().equals("2")){%>
                  <li style="margin-bottom: 5px; margin-left: 20px;">
                  <%=cdo2.getColValue("desc_header2")%>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                  <%}%>
                  </li>
              <%}%>
              
              <%if(cdo2.getColValue("tipo"," ").trim().equals("3")){%>
                  <li style="margin-bottom: 5px; margin-left: 20px;">
                  <b><%=cdo2.getColValue("desc_header2")%></b>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                  <%}%>
                  </li>
              <%}%>

                  <%if(cdo2.getColValue("tipo"," ").trim().equals("3")){
                    ArrayList alDet = SQLMgr.getDataList("select nvl(ref_name, '') ref_name,nvl(display_text,  '') display_text, ref_code, frecuencia, dosis, nvl(add_info_text,' ') add_info_text, (select descripcion from TBL_OSET_TIPO_OM_CONFIG where id = om_type) tipo_om from TBL_OSET_HEADER2_DET where oset_header1 = "+idOsetH1+" and oset_header2 = "+cdo2.getColValue("id_oset_h2")+" order by disp_order");
                  %>
                    <li>
                    <ul>
                      <%for(int d = 0; d<alDet.size(); d++){
                        CommonDataObject cdoD = (CommonDataObject) alDet.get(d);
                      %>
                        <li>
                          <%=cdoD.getColValue("display_text")+" / "+cdoD.getColValue("ref_name")%>
                          
                          <%if(!cdoD.getColValue("add_info_text"," ").trim().equals("")){%>
                            <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdoD.getColValue("add_info_text"," ")%>">
                              <i class="fa fa-info-circle"></i>
                            </a>
                          <%}%>
                          <b>(<%=cdoD.getColValue("tipo_om")%>)</b>
                        </li>
                      <%}%>
                    </ul>
                  <%}%>
              </li>
            <%    
              }
            %>
          </ul>
      </td>
    </tr>
    <%}%>
   
</table>
</body>
</html>
<%}%>