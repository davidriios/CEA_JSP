	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0" />
	<title>Dashboard | Cellbyte Gerencia</title>

	<!--=== CSS ===-->

	<!-- Bootstrap -->
	<link href="<%=request.getContextPath()%>/dashboard/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

	<!-- jQuery UI -->
	<!--<link href="<%=request.getContextPath()%>/dashboard/plugins/jquery-ui/jquery-ui-1.10.2.custom.css" rel="stylesheet" type="text/css" />-->
	<!--[if lt IE 9]>
		<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/dashboard/plugins/jquery-ui/jquery.ui.1.10.2.ie.css"/>
	<![endif]-->

	<!-- Theme -->
	<link href="<%=request.getContextPath()%>/dashboard/assets/css/main.css" rel="stylesheet" type="text/css" />
	<link href="<%=request.getContextPath()%>/dashboard/assets/css/plugins.css" rel="stylesheet" type="text/css" />
	<link href="<%=request.getContextPath()%>/dashboard/assets/css/responsive.css" rel="stylesheet" type="text/css" />
	<link href="<%=request.getContextPath()%>/dashboard/assets/css/icons.css" rel="stylesheet" type="text/css" />

	<link rel="stylesheet" href="<%=request.getContextPath()%>/dashboard/assets/css/fontawesome/font-awesome.min.css">
	<!--[if IE 7]>
		<link rel="stylesheet" href="<%=request.getContextPath()%>/dashboard/assets/css/fontawesome/font-awesome-ie7.min.css">
	<![endif]-->

	<!--[if IE 8]>
		<link href="<%=request.getContextPath()%>/dashboard/assets/css/ie8.css" rel="stylesheet" type="text/css" />
	<![endif]-->
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,600,700' rel='stylesheet' type='text/css'>

	<!--=== JavaScript ===-->

	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/libs/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/jquery-ui/jquery-ui-1.10.2.custom.min.js"></script>

	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/libs/lodash.compat.min.js"></script>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
		<script src="<%=request.getContextPath()%>/dashboard/assets/js/libs/html5shiv.js"></script>
	<![endif]-->

	<!-- Smartphone Touch Events -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/touchpunch/jquery.ui.touch-punch.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/event.swipe/jquery.event.move.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/event.swipe/jquery.event.swipe.js"></script>

	<!-- General -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/libs/breakpoints.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/respond/respond.min.js"></script> <!-- Polyfill for min/max-width CSS3 Media Queries (only for IE8) -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/cookie/jquery.cookie.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/slimscroll/jquery.slimscroll.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/slimscroll/jquery.slimscroll.horizontal.min.js"></script>

	<!-- Page specific plugins -->
	<!-- Charts -->
	<!--[if lt IE 9]>
		<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/excanvas.min.js"></script>
	<![endif]-->
<!--	
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/sparkline/jquery.sparkline.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/jquery.flot.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/jquery.flot.tooltip.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/jquery.flot.resize.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/jquery.flot.time.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/flot/jquery.flot.growraf.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/easy-pie-chart/jquery.easy-pie-chart.min.js"></script>
	-->

	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/daterangepicker/moment.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/daterangepicker/daterangepicker.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/blockui/jquery.blockUI.min.js"></script>

	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/fullcalendar/fullcalendar.min.js"></script>

	<!-- Noty -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/noty/jquery.noty.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/noty/layouts/top.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/noty/themes/default.js"></script>

	<!-- Forms -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/uniform/jquery.uniform.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/plugins/select2/select2.min.js"></script>

	<!-- App -->
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/app.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/plugins.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/dashboard/assets/js/plugins.form-components.js"></script>

	<script>
	$(document).ready(function(){
		"use strict";

		App.init(); // Init layout and core plugins
		Plugins.init(); // Init all plugins
		FormComponents.init(); // Init all form-specific plugins
	});
	</script>
