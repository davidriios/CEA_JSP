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

sql = "select a.progreso_id, a.pac_id, a.admision, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha,'hh12:mi am') as hora, a.medico, a.observacion, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido||decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(upper(am.sexo),'F',decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico from tbl_sal_progreso_clinico a, tbl_adm_medico am where a.pac_id(+)="+pacId+" and a.admision="+admision+" and a.medico=am.codigo order by a.fecha desc, a.progreso_id desc";
al = SQLMgr.getDataList(sql);
%>

<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box widget-closed">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i>Progreso Cl&iacute;nicos&nbsp;&nbsp;<span class="label label-danger"><%=al.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-pgc"><i class="icon-angle-up"></i></span>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/progreso_clinico.jsp?pacId=<%=pacId%>&admision=<%=admision%>" data-container="#pgc-container" data-expander="#expander-pgc" data-type="full"><i class="icon-refresh"></i></span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
								<table class="table table-hover table-condensed">
									
									<tbody>

<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!fecha.trim().equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("medico")))
	{
%>
		<tr>
			<th colspan="2"><cellbytelabel id="1">M&eacute;dico</cellbytelabel>: <%=cdo.getColValue("nombre_medico")%></th>
			<th width="50%" align="right"><cellbytelabel id="2">Fecha</cellbytelabel>: <%=cdo.getColValue("fecha")%></th>
		</tr>
		<tr>
			<th width="10%"><cellbytelabel id="3">Hora</cellbytelabel></th>
			<th colspan="2"><cellbytelabel id="4">Observaciones del M&eacute;dico</cellbytelabel></th>
		</tr>
<%}%>
		<tr>
			<td align="center"><%=cdo.getColValue("hora")%></td>
			<td colspan="2"><%=cdo.getColValue("observacion")%></td>
		</tr>
<%
	fecha = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
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
