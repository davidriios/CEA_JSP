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
  
  String docName = request.getParameter("doc_name");
  if (docName == null) docName = "";
  
  json.addProperty("date", System.currentTimeMillis());
  response.setContentType("application/json");
  
  if (!docName.trim().equals("")) {
    cdo.setSql("select aa.*, aa.first_name || ' ' || aa.last_name as full_name from (SELECT codigo AS ref_id, primer_nombre|| ' '|| DECODE(segundo_nombre,NULL,'',' '|| segundo_nombre) AS first_name,DECODE(primer_apellido,NULL,'',' '|| primer_apellido)|| DECODE(segundo_apellido,NULL,'',' '|| segundo_apellido)|| DECODE(sexo,'F',DECODE(apellido_de_casada,NULL,'',' DE '|| apellido_de_casada) ) AS last_name,lower(e_mail) AS primary_email, reg_medico AS ref_code, sexo as sex, to_char(fecha_de_nacimiento, 'yyyy-mm-dd') dob  FROM tbl_adm_medico WHERE estado = 'A') aa where lower(aa.first_name || ' ' || aa.last_name) like ? ORDER BY aa.ref_id");
    
    cdo.addInStringStmtParam(1, "%"+docName.toLowerCase()+"%");
    
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
      json.addProperty("msg", "El filtro 'doc_name' no está definido.");
  }
  
  out.print(gson.toJson(json));
  
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
%>
