<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);



ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String appendFilter = "";

String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String estado = request.getParameter("estado");

if (estado == null) estado = "";
if (pacId == null) pacId = "0";
if (admision == null) admision = "0";

if ( !estado.equals("") ) {
    if (estado.equalsIgnoreCase("PP")) appendFilter +=  " and ((a.omitir_orden = 'N' and a.estado_orden = 'A') or (a.ejecutado = 'N' and a.estado_orden = 'S'))";
    
    appendFilter += " and a.estado_orden = '"+estado+"'"; 
}


String sql = "select a.secuencia as secuenciaCorte, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaSolicitud, t.descripcion as tipoOrden, decode(a.tipo_orden,3,'DIETA - '||x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre), 1, a.nombre||decode(a.prioridad,'H','  --> HOY  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'M','  --> MAÑANA '||to_char(a.fecha_orden,'dd-mm-yyyy'),'O','  --> '||to_char(a.fecha_orden,'dd-mm-yyyy')),  7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.estado_orden, a.omitir_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),' ') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida, a.frecuencia, (select descripcion from tbl_sal_via_admin where codigo=a.via) descVia,a.dosis_desc, (select descripcion from tbl_cds_ordenmedica_varios where codigo = a.tipo_ordenvarios) tipo_orden_varios,(select descripcion from tbl_cds_om_varios_subtipo where codigo = a.subtipo_ordenvarios and cod_tipo_ordenvarios = a.tipo_ordenvarios) sub_tipo_ordenvarios,  (select '<b>ACCION:</b> '|| m.accion||'<br><b>INTERACCION:</b>'||m.interaccion from tbl_sal_medicamentos m where m.compania = "+((String) session.getAttribute("_companyId"))+" and m.status = 'A' and antibio_ctrl = 'S' and m.medicamento = substr(a.nombre,0, instr(a.nombre,'/')-2 )and a.tipo_orden = 2 and rownum = 1)||'<br><b>Observación:</b> <br>'|| decode(a.tipo_orden, 3, nvl(a.nombre, a.observacion), a.observacion) ||'<br><b>Despachado:</b>'||(select f.descripcion from tbl_int_orden_farmacia f where a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1 and f.estado in('A','R') and rownum = 1) control ";

sql += ", (select descripcion from tbl_cds_tipo_dieta where codigo = a.tipo_dieta and rownum = 1) dietas_desc, (select join( cursor( select descripcion from tbl_cds_subtipo_dieta where cod_tipo_dieta = a.tipo_dieta and descripcion in (select column_value from table( select split(a.observacion,',') from dual ))), '**' ) sub_dietas from dual ) sub_dietas_desc ";

sql += " ,decode(a.tipo_orden,1,(select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio)||' / ', ' ') as cdsDesc,a.usuario_creacion as usuario,(select (select '['||codigo||'] '||decode(sexo,'F','DRA. ','M','DR. ')||primer_nombre||decode(segundo_nombre,null,' ',segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ', segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',apellido_de_casada)) from tbl_adm_medico where codigo= x.medico) from tbl_sal_orden_medica x where x.pac_id=a.pac_id and x.secuencia=a.secuencia and x.codigo=a.orden_med ) as medico,case when a.forma_solicitud='T' and  nvl(a.validada,'N') ='N' then 'N' else 'S' end as validada from tbl_sal_detalle_orden_med a, tbl_sal_tipo_orden_med t, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id="+pacId+" and z.adm_root="+admision+" and a.tipo_orden=t.codigo(+) and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) "+appendFilter;


sql += " and a.estado_orden = 'A' order by a.fecha_creacion desc ";
al = SQLMgr.getDataList(sql);
%>

<!--SOP-->
				<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box widget-closed">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i>Ordenes m&eacute;dicas&nbsp;&nbsp;<span class="label label-danger"><%=al.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-om"><i class="icon-angle-up"></i></span>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/ordenes_medicas.jsp?pacId=<%=pacId%>&admision=<%=admision%>" data-container="#om-container" data-expander="#expander-om"><i class="icon-refresh"></i></span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
								<table class="table table-hover table-condensed">
									<thead>
										<tr>
											<th>F.Solicitud</th>
											<th>Tipo</th>
											<th>Descripci&oacute;n</th>
											<th>Solicitante</th>
										</tr>
									</thead>
									<tbody>
									<% for(int i=0;i<al.size();i++){
										cdo = (CommonDataObject) al.get(i);
										
										if (cdo.getColValue("tipo_orden"," ").equals("1") && cdo.getColValue("ejecutado"," ").equals("S")  ) {%>
										<%} else {%>
											<tr>
                        <td><%=cdo.getColValue("fechaSolicitud")%></td>
                        <td><%=cdo.getColValue("tipoOrden")%></td>
                        <td><%=cdo.getColValue("cdsDesc")%> <%=cdo.getColValue("nombre")%></td>
                        <td><%=cdo.getColValue("medico")%></td>
											</tr>
									<% } } %>
									</tbody>
								</table>
								</div>
								
							</div> <!-- /.widget-content -->
						</div> <!-- /.widget -->
					</div> <!-- /.col-md-6 -->
					<!-- /Static Table -->
				</div> <!-- /.row -->
				<!--SOP End-->