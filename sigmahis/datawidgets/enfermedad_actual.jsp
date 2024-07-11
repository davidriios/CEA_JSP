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

sql = "select to_char(FECHA,'dd/mm/yyyy') as FECHA, to_char(HORA, 'hh12:mi:ss am') as HORA, OBSERVACION, DOLENCIA_PRINCIPAL, MOTIVO_HOSPITALIZACION, ALERGICO_A, usuario_creacion, usuario_modificacion from TBL_SAL_PADECIMIENTO_ADMISION where pac_id="+pacId+" and secuencia="+admision;

CommonDataObject cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();
%>

<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box widget-closed">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i>Enfermedad Actual&nbsp;&nbsp;<span class="label label-danger"><%=!cdo.getColValue("fecha"," ").equals("") ? "1" : "0"%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-enf-actual"><i class="icon-angle-up"></i></span>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/enfermedad_actual.jsp?pacId=<%=pacId%>&admision=<%=admision%>" data-container="#enf-actual-container" data-expander="#expander-enf-actual"><i class="icon-refresh"></i></span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
								<table class="table table-hover table-condensed">
									
									<tbody>
									<!--select to_char(FECHA,'dd/mm/yyyy') as FECHA, to_char(HORA, 'hh12:mi:ss am') as HORA, OBSERVACION, DOLENCIA_PRINCIPAL, MOTIVO_HOSPITALIZACION, ALERGICO_A, usuario_creacion, usuario_modificacion from TBL_SAL_PADECIMIENTO_ADMISION where pac_id="+pacId+" and secuencia="+admision;-->
									<tr>
                    <td><%=cdo.getColValue("fecha")%> <%=cdo.getColValue("hora")%></td>
                    <td><%=cdo.getColValue("DOLENCIA_PRINCIPAL")%></td>
                    <td><%=cdo.getColValue("OBSERVACION")%></td>
                  </tr>
</tbody>
      </table>
      </div>
      
    </div> <!-- /.widget-content -->
  </div> <!-- /.widget -->
</div> <!-- /.col-md-6 -->
<!-- /Static Table -->
</div> <!-- /.row -->
