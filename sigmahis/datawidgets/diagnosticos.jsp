<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");

if (pacId == null) pacId = "0";
if (admision == null) admision = "0";

sql = "select decode(a.tipo,'I', 'INGRESO', 'EGRESO') tipo, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fecha, a.orden_diag,  '[' || a.diagnostico || '] ' || coalesce(b.observacion, b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico = b.codigo and a.admision = "+admision+" and a.pac_id = "+pacId+" order by a.tipo, a.orden_diag";
al = SQLMgr.getDataList(sql);
%>

<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box widget-closed">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i>Diagn&oacute;sticos&nbsp;&nbsp;<span class="label label-danger"><%=al.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-diag"><i class="icon-angle-up"></i></span>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/diagnosticos.jsp?pacId=<%=pacId%>&admision=<%=admision%>" data-container="#diag-container" data-expander="#expander-diag">
                        <i class="icon-refresh"></i>
                    </span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
								<table class="table table-hover table-condensed">
									
									<tbody>

<%
String tipo = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!tipo.trim().equals(cdo.getColValue("tipo")))
	{
%>
		<tr>
			<th><%=cdo.getColValue("tipo")%></th>
			<th><%=cdo.getColValue("fecha")%></th>
		</tr>
<%}%>
		<tr>
			<td><%=cdo.getColValue("diagnosticoDesc")%></td>
			<td>Prioridad: <%=cdo.getColValue("orden_diag")%></td>
		</tr>
<%
	tipo = cdo.getColValue("tipo");
}
%>
</tbody>
      </table>
      </div>
      
    </div> <!-- /.widget-content -->
  </div> <!-- /.widget -->
</div> <!-- /.col-md-6 -->
<!-- /Static Table -->
</div> <!-- /.row -->
