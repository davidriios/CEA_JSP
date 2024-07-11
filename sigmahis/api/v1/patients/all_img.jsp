<%@ page trimDirectiveWhitespaces="true"%> 
<%@include file="../config.jsp"%>
<%@include file="../portal_config.jsp"%>

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
  String format = request.getParameter("_format");
  if (pacId == null) pacId = "";
  if (format == null) format = "";
  
  if (format.equalsIgnoreCase("json")) {
    json.addProperty("date", System.currentTimeMillis());
    response.setContentType("application/json");
  }
  
  if (!pacId.trim().equals("")) {
    cdo.setSql("select (select xx.nombre_paciente from vw_adm_paciente xx where xx.pac_id=z.pac_id) as pac_name,z.codigo, z.cod_solicitud,z.num_orden as num_orden, z.csxp_admi_secuencia, z.csxp_admi_pac_codigo, to_char(z.csxp_admi_pac_fec_nac,'dd/mm/yyyy') dob, z.cod_centro_servicio,   z.pac_id,nvl(to_char(z.fecha_realizo,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_realizo, nvl(to_char(z.fecha_solicitud,'dd/mm/yyyy'),' ') as admission_date, nvl(z.codigo_muestra,' ') as codigo_muestra, to_char(z.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creac, nvl(z.cod_procedimiento,' ') as cpt_code, nvl(y.observacion,y.descripcion) as cpt_name, x.codigo as cds, x.descripcion as cds_desc, nvl(z.comentario_pre,' ') as comentario_pre, z.estado as order_status,to_char(z.csxp_admi_pac_fec_nac,'ddmmyyy') fecha_nac,z.csxp_admi_secuencia admision, z.csxp_admi_pac_codigo pac_codigo, '"+RIS_PATH+"'||nvl(z.responseurl,'#') as responseurl,nvl(a.medico,'-') as medico,decode(A.ADM_TYPE,'I','Hospitalizacion','O','Urg. / Amb.') as admtype from tbl_cds_detalle_solicitud z, tbl_cds_procedimiento y, tbl_cds_centro_servicio x ,tbl_adm_admision a where z.cod_procedimiento=y.codigo(+) and z.cod_centro_servicio=x.codigo and z.pac_id=?  and z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz='RIS') and z.estado <> 'A' and  a.pac_id=z.pac_id and z.csxp_admi_secuencia=a.secuencia order by z.fecha_solicitud desc");
  
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
 
  <h2 class="sub-header">Radiologías</h2>
  <hr>
  <div class="table-responsive">
  
    <table class="table table-hover table-sm" style="font-size:12px !important">
        <thead>
            <tr>
                <th>F.Ingreso<%//=validIp%></th>
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
			
			for (int i = 0; i < al.size(); i++){
              cdo = (issi.admin.CommonDataObject) al.get(i);
			  
			  String baseResUrl = cdo.getColValue("responseurl");
		      //String baseResUrl = "http://192.168.0.225:8888/dev?mode=proxy&titlebar=on&lights=on#View&ris_pat_id=@@pat_pid_number@@&ris_exam_id=@@accession_number@@&un=PORTALCHSF&pw=BPgUQJuq8tk82rQJCISKSO5JgQ%2fhduqGun5qz55BuPRBycl%2bQzCGLiu5kFEHdbtT";
						  			  
            %>
            <tr>
                <td><%=cdo.getColValue("admission_date")%></td>
                <td><%=cdo.getColValue("pac_name")%></td>
                <td><%=cdo.getColValue("cpt_code")%></td>
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
%>
