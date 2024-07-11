<%@ page trimDirectiveWhitespaces="true"%> 
<%@include file="../config.jsp"%>
<%@include file="../portal_config.jsp"%>

<jsp:useBean id="ConMgr" scope="page" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

<%
  SQLMgr.setConnection(ConMgr);
  CmnMgr.setConnection(ConMgr);
  java.util.ArrayList al = new java.util.ArrayList();
  java.util.ArrayList al2 = new java.util.ArrayList();
  
  com.google.gson.Gson gson = new com.google.gson.Gson();
  com.google.gson.JsonObject json = new com.google.gson.JsonObject();
  
  String dateFilter = request.getParameter("_od"); // Date with timestamp sent from client for filter
  String refType = request.getParameter("refType");
  String format = "json";
  if (dateFilter == null) dateFilter = DATE_CUT_OFF+" 01:00:00";
  if (refType == null) refType = "";
  String filter=" and b.e_mail is not null and b.e_mail !='sincorreo@dominio.com'";
  if (!dateFilter.trim().equals("")) {
  filter += " and to_date(to_char(d.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy HH24:mi:ss') >= to_date('"+dateFilter+"','dd/mm/yyyy HH24:mi:ss')";
}

  if (format.equalsIgnoreCase("json")) {
    json.addProperty("date", System.currentTimeMillis());
    response.setContentType("application/json");
  }
  
  if (!dateFilter.trim().equals("")) {
	
    cdo.setSql("select distinct a.* from (select  b.pac_id as ref_id, b.primer_nombre||' '|| DECODE (b.segundo_nombre, NULL, '', ' ' || b.segundo_nombre) as first_name, DECODE (b.primer_apellido, NULL, '', ' ' || b.primer_apellido) || DECODE (b.segundo_apellido, NULL, '', ' ' || b.segundo_apellido)||DECODE (b.sexo,'F', DECODE (b.apellido_de_casada,NULL, '', ' DE ' || b.apellido_de_casada)) as last_name, b.nombre_paciente as full_name,lower(b.e_mail) as primary_email, b.id_paciente as ref_code, b.sexo as sex, to_char(b.fecha_nacimiento, 'yyyy-mm-dd') dob FROM tbl_fac_transaccion a, vw_adm_paciente b, tbl_cds_centro_servicio c ,tbl_fac_detalle_transaccion d where a.pac_id = b.pac_id and a.centro_servicio = c.codigo(+) and a.centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz in ('LIS','RIS')) and a.tipo_transaccion = 'C' and to_date(to_char(d.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+DATE_CUT_OFF+"','dd/mm/yyyy') and a.pac_id = d.pac_id and a.admi_secuencia = d.fac_secuencia and a.compania =d.compania and a.codigo = d.fac_codigo and d.art_familia is null and d.art_clase is null and d.inv_articulo is null "+filter+"  order by d.fecha_creacion asc) a ");
  
    //cdo.addInNumberStmtParam(1, pacId);
    
    al = SQLMgr.getDataList(cdo);
    
    if (format.equalsIgnoreCase("json")) {
      if (al.size() > 1 ) {
        for (int i = 0; i < al.size(); i++) {
          cdo = (issi.admin.CommonDataObject) al.get(i);
          al2.add(cdo.getColValues());
        }
      
        com.google.gson.JsonArray jsonArray2 = new com.google.gson.Gson().toJsonTree(al2).getAsJsonArray();
        json.add("data", jsonArray2);
      } else if (al.size() == 1) {
      
        al2.add( ((issi.admin.CommonDataObject) al.get(0)).getColValues() );
        com.google.gson.JsonArray jsonArray2 = new com.google.gson.Gson().toJsonTree(al2).getAsJsonArray();
        json.add("data", jsonArray2);
      }
    }
    
  } else {
      if (format.equalsIgnoreCase("json")) {
        response.setStatus(500);
        json.addProperty("error", true);
        json.addProperty("msg", "El filtro '_od' no está definido.");
      }
  }
  
  if (format.equalsIgnoreCase("json")) {
    out.print(gson.toJson(json));
  }
  
    
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
  CmnMgr.setConnection(ConMgr);
%>
