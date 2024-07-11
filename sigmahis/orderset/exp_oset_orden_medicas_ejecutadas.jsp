<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");


if (request.getMethod().equalsIgnoreCase("GET")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al2 = new ArrayList();
String key = "";
String sql = "";
String compania = ((String) session.getAttribute("_companyId"));
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
boolean viewMode = false;

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
if (pacId == null) pacId = "0";
if (noAdmision == null) noAdmision = "0";
if (mode == null) mode = "add";

ArrayList alDosis = new ArrayList();
ArrayList alViaAd = new ArrayList();
		
	CommonDataObject cdoHd1 = SQLMgr.getData("select h.oset_desc, estatus, (select count(*) from TBL_EXP_OSET_ACTIVOXMRN where pac_id = "+pacId+" and admision = "+noAdmision+" and oset_id = h.id_oset) as activo from TBL_OSET_HEADER1 h where h.ID_OSET = "+idOsetH1);
	if (cdoHd1 == null) cdoHd1 = new CommonDataObject();
    
  al2 = SQLMgr.getDataList("select  nvl(a.display_text,  a.ref_name) display_text, a.ref_code, a.frecuencia, a.dosis, nvl(a.add_info_text,' ') add_info_text, (select descripcion from TBL_OSET_TIPO_OM_CONFIG where id = om_type) tipo_om, (select subtipo from TBL_OSET_TIPO_OM_CONFIG where id = a.om_type) subtipo, nvl(can_change,'Y') can_change,b.id_oset_h2, nvl(b.display_text, b.desc_header2) desc_header2, b.extra_info, b.tipo, a.prioridad, a.concentracion, a.forma, a.cantidad, a.via, a.generar_om, nvl(a.status, 'N') status, a.oset_det_id, a.observacion from TBL_OSET_ORDEN_MEDICAS a,(select * from TBL_OSET_HEADER2 where id_oset="+idOsetH1+")b where a.pac_id(+) = "+pacId+" and a.admision(+) = "+noAdmision+" and a.oset_header1(+) = "+idOsetH1+" and a.generar_om = 'Y' and a.oset_header1(+) = b.id_oset and a.oset_header2(+) = b.id_oset_h2 order by b.oder_no, a.disp_order");
  
  alDosis = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_grupo_dosis order by descripcion",CommonDataObject.class);
	alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='M' order by descripcion",CommonDataObject.class);
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
    
    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
    <%=fb.formStart(true)%>
    <%=fb.hidden("alSize", ""+al2.size())%>
    <%=fb.hidden("pacId", pacId)%>
    <%=fb.hidden("noAdmision", noAdmision)%>
    <%=fb.hidden("id_oset_h1", idOsetH1)%>
	<%=fb.hidden("medico", "")%>
	<%=fb.hidden("peso", "")%>
	<%=fb.hidden("sexo", "")%>
    <%if(al2.size() > 0){%>
    <tr>
      <td>
          <ul style="list-style-type: none;">
            <%
              String group3 = "";
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
              <%if(!group3.equalsIgnoreCase(cdo2.getColValue("desc_header2"))){%>
                  <li style="margin-bottom: 5px; margin-left: 20px;">
                  <b><%=cdo2.getColValue("desc_header2")%></b>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    
                  <%}%>
                  </li>
              <%}%>
              <%}%>

                  <%if(cdo2.getColValue("tipo"," ").trim().equals("3")){
                  %>
                    <%=fb.hidden("generar_om"+h2, cdo2.getColValue("generar_om"))%>
                    <%=fb.hidden("oset_det_id"+h2, cdo2.getColValue("oset_det_id"))%>
                    <li>
                    <ul style="list-style-type: none;">
                        <li style="margin-bottom: 5px">
                                                    
                          <%=cdo2.getColValue("display_text")%>
                          
                          <%if(!cdo2.getColValue("add_info_text"," ").trim().equals("")){%>
                            <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("add_info_text"," ")%>">
                              <i class="fa fa-info-circle"></i>
                            </a>
                          <%}%>
                          <b>(<%=cdo2.getColValue("tipo_om")%>)</b>
                          
                              <%if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("LIS") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("RIS")){%>
                                <p style="display:none" id="extra-data-<%=h2%>">
                                  <b>Prioridad</b>:                        
                                  <label><input class="extra-field" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="H"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("H")?" checked":""%>>Hoy</label>
                                  <label><input class="extra-field" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="M"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("M")?" checked":""%>>Mañana</label>
                                  <label><input class="extra-field" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="U"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("U")?" checked":""%>>Urgente</label>
                                  <label><input class="extra-field" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="O"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("O")?" checked":""%>>Otros</label>
                                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Observ.:</b>
                                  <input class="extra-field" type="textbox" name="observacion<%=h2%>" id="observacion<%=h2%>" style="width:40%" value="<%=cdo2.getColValue("observacion"," ")%>">
                                </p>
                              
                              <%} else if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("MED")){%>
                                  <div style="display:none" id="extra-data-<%=h2%>">
                                      <p></p>  
                                      <b>Concent.:</b>&nbsp;<input class="extra-field" type="textbox" name="concentracion<%=h2%>" id="concentracion<%=h2%>" value="<%=cdo2.getColValue("concentracion"," ")%>">
                                      <b>Frec.:</b>&nbsp;<input class="extra-field" type="textbox" name="frecuencia<%=h2%>" id="frecuencia<%=h2%>" value="<%=cdo2.getColValue("frecuencia"," ")%>">
                                      <b>Dosis.:</b>&nbsp;<input class="extra-field" type="textbox" name="dosis<%=h2%>" id="dosis<%=h2%>" value="<%=cdo2.getColValue("dosis"," ")%>">
                                      <b>Cant.:</b>&nbsp;<input class="extra-field" type="textbox" name="cantidad<%=h2%>" id="cantidad<%=h2%>" value="<%=cdo2.getColValue("cantidad"," ")%>">
                                      
                                      <p>
                                        <b>Forma:</b>&nbsp;<%=fb.select("forma"+h2,alDosis,cdo2.getColValue("forma"),false,false,viewMode,0,"Text10",null,null,"","S","")%>
                                        <b>V&iacute;a:</b>&nbsp;<%=fb.select("via"+h2,alViaAd,cdo2.getColValue("via"),false,false,viewMode,0,"Text10",null,null,"","S","")%>
                                      </p>
                                  </div>
                              <%}%>
                        </li>
                      
                    </ul>
                  <%}%>
              </li>
            <%
            
              group3 = cdo2.getColValue("desc_header2");
              }
            %>
          </ul>
      </td>
    </tr>
    <%}%>
    <%=fb.formEnd(true)%>
   
</table>
</body>
</html>
<%}%>