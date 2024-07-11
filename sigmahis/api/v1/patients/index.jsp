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
  
  String pacName = request.getParameter("pac_name");
  if (pacName == null) pacName = "";
  
  json.addProperty("date", System.currentTimeMillis());
  response.setContentType("application/json");
  
  if (!pacName.trim().equals("")) {
    cdo.setSql("select pac_id as ref_id, primer_nombre||' '|| DECODE (segundo_nombre, NULL, '', ' ' || segundo_nombre) as first_name, DECODE (primer_apellido, NULL, '', ' ' || primer_apellido) || DECODE (segundo_apellido, NULL, '', ' ' || segundo_apellido)||DECODE (sexo,'F', DECODE (apellido_de_casada,NULL, '', ' DE ' || apellido_de_casada)) as last_name, nombre_paciente as full_name,lower(e_mail) as primary_email, id_paciente as ref_code, sexo as sex, to_char(fecha_nacimiento, 'yyyy-mm-dd') dob from development.vw_adm_paciente where estatus = 'A' and lower(nombre_paciente) like ? order by pac_id");
    
    cdo.addInStringStmtParam(1, "%"+pacName.toLowerCase()+"%");
    
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
      json.addProperty("msg", "El filtro 'pac_name' no está definido.");
  }
  
  out.print(gson.toJson(json));
  
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
%>
