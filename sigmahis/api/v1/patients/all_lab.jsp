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
  
  String pacId = request.getParameter("pac_id");
  String format = request.getParameter("_format");
  String pacName = request.getParameter("pac_name");
  String cedula = request.getParameter("pid");
  String fechaOrden = request.getParameter("fecha_orden");
  String descCpt = request.getParameter("desc_cpt");
  String refType = request.getParameter("refType");
  if (pacId == null) pacId = "";
  if (format == null) format = "";
  if (pacName == null) pacName = "";
  if (cedula == null) cedula = "";
  if (fechaOrden == null) fechaOrden = "";
  if (descCpt == null) descCpt = "";
  if (refType == null) refType = "";
  String filter="";
  if (!pacName.trim().equals("")) {
  filter += "pac_name="+pacName+"&";
}

if (!cedula.trim().equals("")) {
  filter += "id_paciente="+cedula+"&";
}

if (!fechaOrden.trim().equals("")) {
  filter += "fechaOrden="+fechaOrden+"&";
}

if (!descCpt.trim().equals("")) {
  filter += "descCpt="+descCpt+"&";
}
  if (format.equalsIgnoreCase("json")) {
    json.addProperty("date", System.currentTimeMillis());
    response.setContentType("application/json");
  }
  
  if (!pacId.trim().equals("")) {
	
    cdo.setSql("select (select xx.nombre_paciente from vw_adm_paciente xx where xx.pac_id=z.pac_id) as pac_name,'"+LIS_PATH+"'||nvl((select obx_segment from tbl_int_result_det where order_no = x.seq_trx and obx_file_type is not null and rownum = 1),z.pac_id||'_'||z.csxp_admi_secuencia||'_'||lpad(x.seq_trx,10,'0')||'.pdf') as responseurl, (select count(*) from tbl_int_result_det where order_no = x.seq_trx and obx_file_type is null) as nresults, x.seq_trx as order_no, z.num_orden, z.codigo, z.cod_solicitud, z.csxp_admi_secuencia, z.csxp_admi_pac_codigo, to_char(z.csxp_admi_pac_fec_nac,'dd/mm/yyyy') dob, z.cod_centro_servicio, z.pac_id, nvl(to_char(z.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_realizo, nvl(to_char(nvl(z.fecha_solicitud,z.fecha_creac),'dd/mm/yyyy'),' ') as admission_date, nvl(z.codigo_muestra,' ') as codigo_muestra, to_char(z.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, nvl(z.cod_procedimiento,' ') as cpt_code, nvl(y.observacion,y.descripcion) as cpt_name, nvl(z.comentario_pre,' ') as comentario_pre, z.estado as order_status,to_char(z.csxp_admi_pac_fec_nac,'ddmmyyyy') fecha_nac,z.csxp_admi_secuencia admision, z.csxp_admi_pac_codigo pac_codigo,nvl(a.medico,'-') as medico,decode(A.ADM_TYPE,'I','Hospitalizacion','O','Urg. / Amb.') as admtype from tbl_cds_detalle_solicitud z, tbl_cds_procedimiento y,tbl_adm_admision a,tbl_cds_solicitud x where z.cod_procedimiento=y.codigo(+) and z.pac_id=? and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='LIS') and z.pac_id=x.pac_id and z.csxp_admi_secuencia=x.admi_secuencia and Z.COD_SOLICITUD=x.codigo and z.estado <> 'A' and a.pac_id=z.pac_id and z.csxp_admi_secuencia=a.secuencia order by nvl(z.fecha_solicitud,z.fecha_creac) desc, x.seq_trx, z.num_orden");
  
    cdo.addInNumberStmtParam(1, pacId);
    
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
        json.addProperty("msg", "El filtro 'pac_id' no está definido.");
      }
  }
  
  if (format.equalsIgnoreCase("json")) {
    out.print(gson.toJson(json));
  }
  
  if (format.equalsIgnoreCase("html")) {
  %>
 
  <h2 class="sub-header">Laboratorios</h2>
  <hr>
  
  <div class="table-responsive" id="results-container">
  
    <table class="table table-hover table-sm" style="font-size:12px !important">
        <thead>
            <tr>
                <th>F.Ingreso</th>
  <%   if(refType.equals("MED")){  %><th>Nombre</th> <%  }%>
                <th>CPT</th>
                <th>Nombre CPT</th>
                <th>#Orden</th>
                <th>Estado</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <% 
            org.apache.commons.codec.binary.Base64 b64 = new org.apache.commons.codec.binary.Base64();
            String cDateTime = CmnMgr.getCurrentDate("yyyyMMddHHmm");
            for (int i = 0; i < al.size(); i++){
              cdo = (issi.admin.CommonDataObject) al.get(i);
			  String baseResUrl = LIS_PATH+cdo.getColValue("result");
              
              json = new com.google.gson.JsonObject();
            
              com.google.gson.Gson gCredentials = new com.google.gson.Gson();
              com.google.gson.JsonObject jCredentials = new com.google.gson.JsonObject();
                            
              al2.clear();
              
              jCredentials.addProperty("token", cDateTime+";"+request.getRemoteAddr());
              
              json.addProperty("usuario", gCredentials.toJson(jCredentials));
              
              issi.admin.CommonDataObject cdoNoD = new issi.admin.CommonDataObject();
              issi.admin.CommonDataObject cdoTipoD = new issi.admin.CommonDataObject();
              issi.admin.CommonDataObject cdoEpisodio = new issi.admin.CommonDataObject();
              
              cdoNoD.addColValue("campo", "numeroDocumento");
              cdoNoD.addColValue("value", cdo.getColValue("pid"));
              
              cdoTipoD.addColValue("campo", "tipoDocumento");
              cdoTipoD.addColValue("value", "CC");
              
              cdoEpisodio.addColValue("campo", "episodio");
              cdoEpisodio.addColValue("value", cdo.getColValue("num_orden"));
              
              al2.add(cdoNoD.getColValues());
              al2.add(cdoTipoD.getColValues());
              al2.add(cdoEpisodio.getColValues());
              
               
              json.addProperty("parametros", gCredentials.toJson(al2));
              
              String param = "";//gCredentials.toJson(json);
              
              String paramB64 = new String(b64.encode(param.getBytes()));
              String paramB64Encoded = java.net.URLEncoder.encode(paramB64, "UTF-8");
              
              //baseResUrl += paramB64Encoded;

            %>
            
            <tr data-param="<%=param%>">
                <td><%=cdo.getColValue("admission_date")%></td>
               <%   if(refType.equals("MED")){  %> <td><%=cdo.getColValue("pac_name")%></td><%   } %>
                <td><span class="label label-warning"><%=cdo.getColValue("cpt_code")%></span></td>
                <td><%=cdo.getColValue("cpt_name")%></td>
                <td><%=cdo.getColValue("num_orden")%></td>
                <td><%=cdo.getColValue("order_status")%></td>
                <td>
                  <a href="<%=baseResUrl%>" class="btn btn-success btn-sm btn-results-test"><i class="fa fa-eye"></i> Resultado</a>
                 </td>
            </tr>
            
            <%}%>
        </tbody>
    </table>
  
  </div>
  
  <%
  }
  
  ConMgr = null;
  SQLMgr.setConnection(ConMgr);
  CmnMgr.setConnection(ConMgr);
%>
