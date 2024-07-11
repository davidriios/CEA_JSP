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
CommonDataObject cdo;
boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");

if (pacId == null) pacId = "0";
if (admision == null) admision = "0";

sql = "select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, area_desc, area, decode(estado,'V','VALIDA','INVALIDA') estado from tbl_sal_notas_del_soapier where pac_id="+pacId+" and secuencia="+admision+" and nvl(tipo, 'S')='S' and estado <> 'I' order by fecha_creac";

al = SQLMgr.getDataList(sql);
if (al == null) al = new ArrayList();
%>

<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box widget-closed">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i>Nota de Enfermeria Sala<span class="label label-danger"><%=al.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-enf-actual"><i class="icon-angle-up"></i></span>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/nota_sopier_enfermera.jsp?pacId=<%=pacId%>&admision=<%=admision%>" data-container="#enf-actual-container" data-expander="#expander-enf-actual"><i class="icon-refresh"></i></span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
								<table class="table table-hover table-condensed">
									<thead>
										<tr>
											<th>Nota</th>
											<th>Fecha Creacion</th>
											<th>Creado Por</th>
											<th>Estado</th>
										</tr>
									</thead>
									<tbody>
							<% for(int i=0;i<al.size();i++){
										cdo = (CommonDataObject) al.get(i);										
										%>		
									<tr>
                    <td><%=cdo.getColValue("DESCRIPCION")%></td>
                    <td><%=cdo.getColValue("FECHA_CREAC")%></td>
                    <td><%=cdo.getColValue("USUARIO_CREAC"," ")+" / "+cdo.getColValue("USUARIO_MODIF"," ")%></td>
					<td><%=cdo.getColValue("ESTADO")%></td>
                  </tr>
				  <% } %>
</tbody>
      </table>
      </div>
      
    </div> <!-- /.widget-content -->
  </div> <!-- /.widget -->
</div> <!-- /.col-md-6 -->
<!-- /Static Table -->
</div> <!-- /.row -->
