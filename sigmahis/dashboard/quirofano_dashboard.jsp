<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoIO = new CommonDataObject();


if (request.getMethod().equalsIgnoreCase("GET")) {
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select to_char(sysdate,'dd/mm/yyyy') as today from dual");
	cdoIO = SQLMgr.getData(sbSql.toString());
	if (cdoIO == null) {
		cdoIO = new CommonDataObject();
		cdoIO.addColValue("today","");
	}
	sbSql = new StringBuffer();
	sbSql.append("select z.pac_id, z.admision, z.nombre_paciente, replace(translate(initcap(nvl(nombre_paciente,(select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id))),' abcdefghijklmnopqrstuvwxyz',' '),' ') as iniciales, coalesce(z.nombre_medico,z.nombre_medico_externo,(select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||case when sexo = 'F' and apellido_de_casada is not null then ' '||apellido_de_casada else decode(segundo_apellido,null,'',' '||segundo_apellido) end from tbl_adm_medico where codigo = nvl(z.cod_medico,(select medico from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admision)))) as medico, (select habitacion||' / '||cama from tbl_adm_cama_admision where pac_id = z.pac_id and admision = z.admision and fecha_final is null) as habitacion, (select descripcion from tbl_sal_habitacion where codigo = z.habitacion and compania = z.compania_hab) as quirofano");
	sbSql.append(", nvl((select decode(estado,'IN_AN','EN ATENCION','OUT_AN','ATENDIDO','-') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_AN') from dual)),' ') as status_preparacion, nvl((select decode(estado,'IN_AN','danger','OUT_AN','success','default') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_AN') from dual)),' ') as color_preparacion");
	sbSql.append(", nvl((select decode(estado,'IN_OR','EN ATENCION','OUT_OR','ATENDIDO','-') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_IN') from dual)),' ') as status_quirofano, nvl((select decode(estado,'IN_OR','danger','OUT_OR','success','default') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_IN') from dual)),' ') as color_quirofano");
	sbSql.append(", nvl((select decode(estado,'IN_REC','EN ATENCION','OUT_REC','ATENDIDO','-') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_OUT') from dual)),' ') as status_recobro, nvl((select decode(estado,'IN_REC','danger','OUT_REC','success','default') from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_OUT') from dual)),' ') as color_recobro");
	
	sbSql.append(",(select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_AN') from dual))  fecha_out_an ,(select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_IN') from dual))  fecha_out_sop ,(select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_OUT') from dual))  fecha_out_rec,case when (select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_OUT') from dual)) is not null then  5 when (select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_IN') from dual)) is not null  then 4 when (select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_AN') from dual)) is not null  then 3 else 2 end as  ord , z.hora_cita,(select fecha_in from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(1,'CDC_CDS_AN') from dual) ) fecha_in_an");
	
	sbSql.append(" from tbl_cdc_cita z where trunc(z.fecha_cita) = trunc(sysdate) and z.estado_cita in ('R','E','X') and z.pac_id is not null and z.admision is not null and exists (select null from tbl_sal_habitacion where compania = z.compania_hab and codigo = z.habitacion and quirofano = 2) and exists (select null from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro)");
	//Para paciente cuyo tiempo de salida de recobros es mayor a 1 hora desaparezacan del dashboard
	sbSql.append("  and nvl((select fecha_out from tbl_cdc_io_log where pac_id = z.pac_id and admision = z.admision and cod_cita = z.codigo and fecha_registro = z.fecha_registro and cds = (select get_sec_comp_param(z.compania,'CDC_CDS_OUT') from dual)),sysdate) > sysdate - (nvl((select get_sec_comp_param(z.compania,'CDC_TIEMPO_VIEW_DASBOARD') from dual),1)*0.0417) ");
	
	sbSql.append("  order by  17 asc ,16 desc,15 desc ,14 desc,19 desc");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="common/dash_header.jsp" />
<script language="javascript">
function doAction(){setTimeout('reloadPage()',120000);}
function reloadPage(){window.location.reload(true);}
</script>
</head>
<body onLoad="javascript:doAction();">

	<!-- Header -->
	<header class="header navbar navbar-fixed-top" role="banner">
		<!-- Top Navigation Bar -->
		<div class="container">

			<!-- Only visible on smartphones, menu toggle -->
			<ul class="nav navbar-nav">
				<li class="nav-toggle"><a href="javascript:void(0);" title=""><i class="icon-reorder"></i></a></li>
			</ul>

			<!-- Logo -->
			<a class="navbar-brand">
			<img src="assets/img/logo.png" alt="logo" />
				<strong>CELLBYTE</strong>
			</a>
			<!-- /logo -->

			<!-- Sidebar Toggler -->
			<a href="#" class="toggle-sidebar bs-tooltip" data-placement="bottom" data-original-title="Toggle navigation">
				<i class="icon-reorder"></i>
			</a>
			<!-- /Sidebar Toggler -->

			<!-- Top Left Menu -->
			<ul class="nav navbar-nav navbar-left hidden-xs hidden-sm">
				<li>
					<a href="#">
						Dashboard Quir&oacute;fanos
					</a>
				</li>
			</ul>
			<!-- /Top Left Menu -->

			<!-- Top Right Menu -->
			<ul class="nav navbar-nav navbar-right">
				<!-- Notifications -->
				<!-- .row .row-bg Toggler 
				<li>
					<a href="#" class="dropdown-toggle row-bg-toggle">
						<i class="icon-resize-vertical"></i>
					</a>
				</li>
				<!-- User Company Dropdown -->
				<!--<li class="dropdown user">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown">
						<!--<img alt="" src="assets/img/avatar1_small.jpg" />
						<i class="icon-star-empty"></i>
						<span class="username">Company</span>
						<i class="icon-caret-down small"></i>
					</a>
					<ul class="dropdown-menu">
						<li><a href="pages_user_profile.html"><i class="icon-user"></i> Company Selected</a></li>
					</ul>
				</li>-->
				<!-- /user company dropdown -->
				<!-- User Login Dropdown -->
				<li class="dropdown user">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown">
						<!--<img alt="" src="assets/img/avatar1_small.jpg" />-->
						<i class="icon-male"></i>
						<span class="username"><%=session.getAttribute("_userCompleteName")%></span>
						<i class="icon-caret-down small"></i>
					</a>
					<ul class="dropdown-menu">
						<!--<li><a href="pages_user_profile.html"><i class="icon-user"></i> Company</a></li>
						<li class="divider"></li>-->
						<li><a href="../logout.jsp"><i class="icon-key"></i> Log Out</a></li>
					</ul>
				</li>
				<!-- /user login dropdown -->
			</ul>
			<!-- /Top Right Menu -->
		</div>
		<!-- /top navigation bar -->

		
	</header> <!-- /.header -->

	<div id="container">
		<div id="sidebar" class="sidebar-fixed">
			<div id="sidebar-content">

				<!--=== Navigation ===-->
				<ul id="nav">
					<li class="current">
						<a href="quirofano_dashboard.jsp">
							<i class="icon-dashboard"></i>
							Dashboard Quir&oacute;fanos
						</a>
					</li>
					<!--<li>
						<a href="javascript:void(0);">
							<span class="icon-stack">
							<i class="icon-check-empty icon-stack-base"></i>
							<i class="icon-user-md"></i>
							</span>
							SOP 
						</a>
					</li>	
					<li>
						<a href="javascript:void(0);">
							<span class="icon-stack">
							<i class="icon-check-empty icon-stack-base"></i>
							<i class="icon-h-sign"></i>
							</span>
							SALAS
						</a>
					</li>-->					
					
				</ul>
				
				

			</div>
			<div id="divider" class="resizeable"></div>
		</div>
		<!-- /Sidebar -->
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li>
							<i class="icon-home"></i>
							<a href="#">Dashboard</a>
						</li>
				</ul>
					
					<ul class="crumb-buttons">
						<li class="datepicker" data-date-format="mm/dd/yyyy"><a href="#">
							<i class="icon-calendar"></i>
							<span><input class="input-sm" data-provide="datepicker" value='<%=cdoIO.getColValue("today")%>'></input></span>
							<!--<i class="icon-angle-down"></i>-->
						</a></li>
					</ul>
				</div>
				<!-- /Breadcrumbs line -->


				<!--=== Page Content ===-->
				
				<!--SOP-->
				<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i> Salon de Operacion&nbsp;&nbsp;<span class="label label-danger"><%=al.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse"><i class="icon-angle-down"></i></span>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
								<table class="table table-hover">
									<thead>
										<tr>
											<th><!--Paciente--></th>
											<th>Expediente</th>
											<th>M&eacute;dico</th>
											<th>Hab. / Cama</th>
											<th>Preparaci&oacute;n</th>
											<th>Sal&oacute;n</th>
											<th>Recobro</th>
										</tr>
									</thead>
									<tbody>
									<% for(int i=0;i<al.size();i++){
										cdo = (CommonDataObject) al.get(i);
										%>
											<tr>
											<td><%//=cdo.getColValue("iniciales")%></td>
											<td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
											<td><%=cdo.getColValue("medico")%></td>
											<td><span class="label <%=(cdo.getColValue("color_recobro").equalsIgnoreCase("success"))?"label-danger":""%>"><%=cdo.getColValue("habitacion")%></span></td>
											<td><span class="label label-<%=cdo.getColValue("color_preparacion")%>"><%=cdo.getColValue("status_preparacion")%></span></td>
											<td><span class="label label-<%=cdo.getColValue("color_quirofano")%>"><%=cdo.getColValue("quirofano")%></span></td>
											<td><span class="label label-<%=cdo.getColValue("color_recobro")%>"><%=cdo.getColValue("status_recobro")%></span></td>
											</tr>
									<% } %>
									</tbody>
								</table>
								
							</div> <!-- /.widget-content -->
						</div> <!-- /.widget -->
					</div> <!-- /.col-md-6 -->
					<!-- /Static Table -->
				</div> <!-- /.row -->
				<!--SOP End-->
				
				<!-- /Page Content -->
			</div>
			<!-- /.container -->

		</div>
	</div>

</body>
</html>
<%}%>