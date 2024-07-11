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
ArrayList alSOP = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoIO = new CommonDataObject();


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String sql = "select sum(decode(categoria,1,1,0)) as inp, sum(decode(categoria,1,0,1)) as outp,to_char(sysdate,'dd/mm/yyyy') today from tbl_adm_admision where estado in ('A','E')";
	cdoIO = SQLMgr.getData(sql);
	if(cdoIO==null){
		cdoIO = new CommonDataObject();
		cdoIO.addColValue("inp","0");
		cdoIO.addColValue("outp","0");
		cdoIO.addColValue("today"," ");
		cdoIO.addColValue("TOTHABITACION","0");
	}
	sql = "select (select unidad_admin from tbl_sal_habitacion where codigo = z.habitacion and compania = z.compania) as cds  , (select (select descripcion from tbl_cds_centro_servicio where codigo = a.unidad_admin) from tbl_sal_habitacion a where a.codigo = z.habitacion and a.compania = z.compania) as cds_desc , z.compania, z.habitacion , (select descripcion from tbl_sal_habitacion where codigo = z.habitacion and compania = z.compania) as habitacion_desc , z.cama, z.pac_id, z.admision  , (select to_char(fecha_ingreso,'dd/mm/yyyy')||' '||to_char(am_pm,'hh24:mi') from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admision) as ingreso , to_date((select to_char(fecha_ingreso,'dd/mm/yyyy')||' '||to_char(am_pm,'hh24:mi') from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admision),'dd/mm/yyyy hh24:mi') as ingreso_order    , (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as nombre_paciente , (select id_paciente from vw_adm_paciente where pac_id = z.pac_id) as id_paciente , to_char((select f_nac from vw_adm_paciente where pac_id = z.pac_id),'dd/mm/yyyy') as f_nac  from tbl_adm_cama_admision z where z.compania = 1 and z.fecha_final is null and exists (select null from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admision and categoria = 1 and estado in ('A','E')) and exists (select null from tbl_sal_habitacion where codigo = z.habitacion and compania = z.compania and quirofano <> 2) order by 1,2";
	al = SQLMgr.getDataList(sql);
	sql="select quirofano,(select descripcion from tbl_sal_habitacion zz where zz.codigo=x.quirofano and  zz.quirofano = 2) nomre_quirofano,pac_id,admision,cod_cita,fecha_cita,estado, (select nombre_paciente from vw_adm_paciente where pac_id=x.pac_id) as nombrePaciente, cds,decode(estado,'IN_OR','CURRENT','OUT_OR','ATTENDED','-') estadoDesc from tbl_cdc_io_log x where cds = get_sec_comp_param(x.compania,'CDC_CDS_IN') and trunc(fecha_in) = to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') and estado NOT IN('CAN') order by 2";
	alSOP = SQLMgr.getDataList(sql);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<jsp:include page="common/dash_header.jsp" />	
</head>

<body>

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
						Dashboard Ocupacion de Camas
					</a>
				</li>
				<li class="dropdown">
					<ul class="dropdown-menu">
						<li><a href="#"><i class="icon-list"></i> Dashboard SOP</a></li>
						<li><a href="#"><i class="icon-tasks"></i> Dashboard Hospitaliazacion</a></li>
					</ul>
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
						<a href="uso_cama_dashboard.jsp">
							<i class="icon-dashboard"></i>
							Dashboard Uso de Cama
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

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>Dashboard</h3>
						<span>Bienvenido!</span>
					</div>

					<!-- Page Stats -->
					<ul class="page-stats">
						<li>
							<div class="summary">
								<span>Out Patients</span>
								<h3><%=cdoIO.getColValue("outp")%></h3>
							</div>
							<!-- Use instead of sparkline e.g. this:
							<div id="sparkline-bar" class="graph sparkline hidden-xs">20,15,8,50,20,40,20,30,20,15,30,20,25,20</div>
							<div class="graph circular-chart" data-percent="73">73%</div>
							-->
						</li>
						<li>
							<div class="summary">
								<span>In Patients</span>
								<h3><%=cdoIO.getColValue("inp")%></h3>
							</div>
							<!-- Use instead of sparkline e.g. this:
							<div id="sparkline-bar2" class="graph sparkline hidden-xs">20,15,8,50,20,40,20,30,20,15,30,20,25,20</div>-->
						</li>
					</ul>
					<!-- /Page Stats -->
				</div>
				<!-- /Page Header -->

				<!--=== Page Content ===-->
				
				<!--Hospitalizados-->
				<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i> OCUPACION DE CAMA &nbsp;&nbsp;<span class="label label-danger"><%=al.size()%>&nbsp;&nbsp;</span></h4>
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
											<th>Area</th>
											<th>Habitacion</th>
											<th>Cama</th>
											<th><!--Paciente--></th>
											<th class="align-center">Expediente</th>
										</tr>
									</thead>
									<tbody>
									<% for(int i=0;i<al.size();i++){
										cdo = (CommonDataObject) al.get(i);
										%>
											<tr>
											<td ><%=cdo.getColValue("cds_desc")%></td>
											<td><%=cdo.getColValue("habitacion_desc")%></td>
											<td><%=cdo.getColValue("cama")%></td>
											<td><span class="label label-danger"><%//=cdo.getColValue("nombre_paciente")%></span></td>
											<td class="align-center"><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
										</tr>
									<% } %>
									</tbody>
								</table>
								
							</div> <!-- /.widget-content -->
						</div> <!-- /.widget -->
					</div> <!-- /.col-md-6 -->
					<!-- /Static Table -->
				</div> <!-- /.row -->
				<!--Hospitalizados End-->
				
				<!--SOP-->
				<div class="row">
					<!--=== Static Table ===-->
					<div class="col-md-12">
						<div class="widget box">
							<div class="widget-header">
								<h4><i class="icon-reorder"></i> Salon de Operacion&nbsp;&nbsp;<span class="label label-danger"><%=alSOP.size()%></span></h4>
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
											<th>Quirofano</th>
											<th>Paciente</th>
											<th>Expediente</th>
											<th>Status</th>
										</tr>
									</thead>
									<tbody>
									<% for(int i=0;i<alSOP.size();i++){
										cdo = (CommonDataObject) alSOP.get(i);
										%>
											<tr>
											<td ><%=cdo.getColValue("nomre_quirofano")%></td>
											<td><%=cdo.getColValue("nombrePaciente")%></td>
											<td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
											<td><span class="label label-danger"><%=cdo.getColValue("estadoDesc")%></span></td>
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