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
  
  response.setContentType("application/json");
  
  String company = request.getParameter("company_id");
  String family = request.getParameter("family_id");
  if (company == null) company = "";
  if (family == null) family = "";
  
  json.addProperty("date", System.currentTimeMillis());
  
  if (company.trim().equals("")) company = "2";
  
  if (!company.trim().equals("")) {
    String sql = "select a.cod_articulo code, a.descripcion name, nvl(a.tech_descripcion, a.descripcion) as description, a.cod_barra as barcode , f.cod_flia family_id, f.nombre family_name from tbl_inv_articulo a, tbl_inv_familia_articulo f where a.compania = ? and a.estado = 'A' and a.compania = f.compania and a.cod_flia = f.cod_flia ";
    
    if (!family.equals("")) sql += " and a.cod_flia = ?";
    
    sql += " order by a.cod_articulo ";
    
    cdo.setSql(sql);
    
    try {
    cdo.addInNumberStmtParam(1, company);
    if (!family.equals("")) cdo.addInNumberStmtParam(2, family);
    } catch(Exception e) {
      response.setStatus(500);
      json.addProperty("error", true);
      json.addProperty("msg", "Parámetros inválidos");
    } 
    
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
    } else {
      json.addProperty("data", "[]");
    }
    
  } else {
      response.setStatus(500);
      json.addProperty("error", true);
      json.addProperty("msg", "El filtro 'company_id' no está definido.");
  }
  
  out.print(gson.toJson(json));
  
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
%>
