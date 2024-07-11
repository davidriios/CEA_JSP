<%@ page trimDirectiveWhitespaces="true"%> 
<%--<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<div class="list-group">
  <a href="#" class="list-group-item active">Primer resultado <span class="badge">12</span></a>
  <a href="#" class="list-group-item">Segundo resultado <span class="badge">2</span></a>
  <a href="#" class="list-group-item">Tercer resultado <span class="badge">4s</span></a>
</div>
--%>

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
  if (pacId == null) pacId = "";
  if (format == null) format = "";
  
  if (format.equalsIgnoreCase("json")) {
    json.addProperty("date", System.currentTimeMillis());
    response.setContentType("application/json");
  }
  
  if (!pacId.trim().equals("")) {
    cdo.setSql("SELECT DECODE(b.pasaporte,NULL,b.provincia|| '-'|| b.sigla|| '-'|| b.tomo|| '-'|| b.asiento|| '-'|| b.d_cedula,b.pasaporte) AS pid, b.nombre_paciente as pac_name, a.cod_procedimiento as cpt_code, DECODE(a.cod_procedimiento,NULL,DECODE(a.tipo_tubo,NULL,DECODE(a.cod_tipo_dieta,NULL,' ','DIETA '|| d.descripcion),DECODE(a.cod_tipo_dieta,NULL,DECODE(a.tipo_tubo,'G','DIETA POR GOTEO','N','DIETA POR BOLO'),'DIETA '|| d.descripcion|| ' - '|| DECODE(a.tipo_tubo,'G','POR GOTEO','N','POR BOLO') ) ),DECODE(c.observacion,NULL,c.descripcion,c.observacion) ) AS cpt_name ,f.primer_nombre|| ' '|| f.segundo_nombre|| ' '|| f.primer_apellido|| ' '|| f.segundo_apellido AS med_name, f.codigo AS med_code, a.estado as order_status, a.csxp_admi_secuencia as pac_admision_no, to_char(i.fecha_ingreso, 'dd/mm/yyyy') as admission_date, a.num_orden FROM tbl_cds_detalle_solicitud a, vw_adm_paciente b, tbl_cds_procedimiento c, tbl_cds_tipo_dieta d, tbl_cds_solicitud e, tbl_adm_medico f, tbl_adm_atencion_cu g, tbl_adm_admision i WHERE ( a.cod_centro_servicio IN (SELECT codigo FROM tbl_cds_centro_servicio WHERE interfaz = 'LIS' ) ) AND   a.estudio_dev = 'N' AND   a.estudio_realizado = 'N'  AND   a.estado != 'A'  AND a.expediente = 'S' AND a.pac_id = b.pac_id AND   a.cod_procedimiento = c.codigo (+) AND   a.cod_tipo_dieta = d.codigo (+) AND   a.cod_solicitud = e.codigo AND   a.csxp_admi_secuencia = e.admi_secuencia AND  a.pac_id = e.pac_id  AND   i.secuencia = e.admi_secuencia AND   i.pac_id = e.pac_id AND   e.med_codigo_resp = f.codigo (+) AND   e.admi_secuencia = g.secuencia (+) AND   e.pac_id = g.pac_id (+) and a.pac_id = ?");
  
    cdo.addInNumberStmtParam(1, pacId);
    
    al = SQLMgr.getDataList(cdo);
    
    if (format.equalsIgnoreCase("json")) {
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
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css" crossorigin="anonymous">
  
  <h2 class="sub-header">Laboratorios</h2>
  <hr>
  
  <div class="table-responsive">
  
    <table class="table table-hover table-sm" style="font-size:12px !important">
        <thead>
            <tr>
                <th>F.Ingreso</th>
                <th>Nombre</th>
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
               
            for (int i = 0; i < al.size(); i++){
              cdo = (issi.admin.CommonDataObject) al.get(i);
              
              json = new com.google.gson.JsonObject();
            
              com.google.gson.Gson gCredentials = new com.google.gson.Gson();
              com.google.gson.JsonObject jCredentials = new com.google.gson.JsonObject();
                            
              al2.clear();
              
              String cDateTime = CmnMgr.getCurrentDate("yyyyMMddHHmm");
              
              jCredentials.addProperty("login", "portalchsf");
              jCredentials.addProperty("password", "li$r3s");
              jCredentials.addProperty("token", cDateTime+";"+request.getRemoteAddr());
              jCredentials.addProperty("host", "chsf-srv-07:82");
              
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
              
              String baseResUrl = "http://192.168.119.23/resultados/index.htm?param=";
              
              json.addProperty("parametros", gCredentials.toJson(al2));
              
              String param = gCredentials.toJson(json);
              
              String paramB64 = new String(b64.encode(param.getBytes()));
              String paramB64Encoded = java.net.URLEncoder.encode(paramB64, "UTF-8");
              
              baseResUrl += paramB64Encoded;

            %>
            
            <tr data-param="<%=param%>">
                <td><%=cdo.getColValue("admission_date")%></td>
                <td><%=cdo.getColValue("pac_name")%></td>
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
