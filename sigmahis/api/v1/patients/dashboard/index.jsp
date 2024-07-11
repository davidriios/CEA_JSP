<%@ page trimDirectiveWhitespaces="true"%> 
<jsp:useBean id="ConMgr" scope="page" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

<%
  SQLMgr.setConnection(ConMgr);
  java.util.ArrayList al = new java.util.ArrayList();
  java.util.ArrayList al2 = new java.util.ArrayList();
  
  com.google.gson.Gson gson = new com.google.gson.Gson();
  com.google.gson.JsonObject json = new com.google.gson.JsonObject();
  
  String pacId = request.getParameter("pac_id");
  if (pacId == null) pacId = "";
  
  json.addProperty("date", System.currentTimeMillis());
  response.setContentType("application/json");
  
  if (!pacId.trim().equals("")) {
    cdo.setSql("select nvl(( select count(secuencia) from tbl_adm_admision where pac_id = ? and estado = 'A' ),0) as tot_admision, nvl((select count(z.codigo) from tbl_cds_detalle_solicitud z, tbl_adm_admision a where z.estado <> 'A' and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='LIS') AND   z.pac_id = ? AND   a.adm_root = ( select max(secuencia) from tbl_adm_admision where pac_id = ?  ) AND   a.pac_id = z.pac_id AND   z.csxp_admi_secuencia = a.secuencia),0) tot_lab,nvl((select count(z.codigo) from tbl_cds_detalle_solicitud z, tbl_adm_admision a where z.estado <> 'A' and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='RIS') AND   z.pac_id = ? AND   a.adm_root = ( select max(secuencia) from tbl_adm_admision where pac_id = ?  ) AND   a.pac_id = z.pac_id AND z.csxp_admi_secuencia = a.secuencia),0) tot_rad from dual");
    
    cdo.addInNumberStmtParam(1, pacId);
    cdo.addInNumberStmtParam(2, pacId);
    cdo.addInNumberStmtParam(3, pacId);
    cdo.addInNumberStmtParam(4, pacId);
    cdo.addInNumberStmtParam(5, pacId);
    
    al = SQLMgr.getDataList(cdo);
    
    if (al.size() > 1 ) {
      for (int i = 0; i < al.size(); i++) {
        cdo = (issi.admin.CommonDataObject) al.get(i);
        al2.add(cdo.getColValues());
      }
    
      json.addProperty("data", gson.toJson(al2));
    } else if (al.size() == 1) {
    
      al2.add( ((issi.admin.CommonDataObject) al.get(0)).getColValues() );
      json.addProperty("data", gson.toJson(al2));
    }
    
  } else {
      response.setStatus(500);
      json.addProperty("error", true);
      json.addProperty("msg", "El filtro 'pac_id' no está definido.");
  }
  
  out.print(gson.toJson(json));
  
  System.out.println(".............................................. size = "+al.size());
  
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
%>
