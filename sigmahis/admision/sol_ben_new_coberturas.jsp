 <%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
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

String pacId = request.getParameter("pac_id");
String noAdmision = request.getParameter("admision");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (id == null) id = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	XMLCreator xml = new XMLCreator(ConMgr);

	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"sol_ben_new_tipo_serv_x_cds_"+UserDet.getUserId()+".xml","select distinct a.tipo_servicio as value_col, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as label_col, a.centro_servicio as key_col, (select ruta_detalle from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as title_col from tbl_cds_servicios_x_centros a where a.visible_centro ='S' and exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio and ruta_detalle is not null) order by 3");

	 boolean viewMode = mode.equalsIgnoreCase("view");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Solicitud de Beneficio - '+document.title;

function doAction(){}

$(document).ready(function(){

		var index = -1;
		$(".add_new_row").click(function(e){
			e.preventDefault();
			index++;

			var self = $(this);
			var tipoDetalle = self.data('type');

			var $original = $("#cds_wrapper");
			var $clone = $original.clone();
			var initContent = $clone.show().html().replace(/-INDEX/g, index);

			//jQuery("#tbl_cnt tr:last").after("<tr id='added_cds_row"+index+"' class='TextRow01 added_cds_row' data-index='"+index+"'>"+initContent+"</tr>");

			//$("#wrapper_"+tipoDetalle).

			$("<tr id='added_cds_row"+index+"' class='TextRow01 added_cds_row' data-index='"+index+"'>"+initContent+"</tr>").insertAfter($("#wrapper_"+tipoDetalle).show(0));

			$("#tipo_detalle"+index).val(tipoDetalle);
		});

		$(document).on('mouseenter','.added_cds_row',function(){
			var $that = $(this);
			var i = $that.data("index");
			$("#btn_cds_rem_row"+i).show();
		});

		$(document).on('mouseleave','.added_cds_row',function(){
			var $that = $(this);
			var i = $that.data("index");
			$("#btn_cds_rem_row"+i).hide();
		});

		$(document).on('click','.btn_cds_rem_row',function(){
			var $that = $(this);
			var i = $that.data("index");
			$("#added_cds_row"+i).remove()
		});

		$(document).on("change",".sel_cds", function(){
			var $that = $(this);
			var i = $that.data("index");
			loadXML('../xml/sol_ben_new_tipo_serv_x_cds_<%=UserDet.getUserId()%>.xml','tipo_servicio'+i,'','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S');
		});

		//Saving into DB
		$(document).on('click','.btn_save',function(){
			var $that = $(this);
			var i = $that.data("index");
			var cds = $("#cds"+i).val();
			var tipoServ = $("#tipo_servicio"+i).val();
			var code = $("#codigo_detalle"+i).val();
			var tipoDetalle = $("#tipo_detalle"+i).val();
			var refType = "";

			var toPath = $("#tipo_servicio"+i).find("option:selected").attr("title") || '';
			toPath = toPath.split("@@");
			if (toPath[1]) refType = toPath[1];

			var data = {
				"tipo_detalle": tipoDetalle,
				"ref_type": refType,
				"refer": code,
				"monto_cli": $("#monto_cli"+i).val(),
				"monto_pac":$("#monto_pac"+i).val(),
				"monto_emp":$("#monto_emp"+i).val(),
				"tipo_val_cli":$("#tipo_val_cli"+i).val(),
				"tipo_val_pac":$("#tipo_val_pac"+i).val(),
				"tipo_val_emp":$("#tipo_val_emp"+i).val(),
				"tipo_cob_cli":$("#tipo_cob_cli"+i).val(),
				"tipo_cob_emp":$("#tipo_cob_emp"+i).val(),
				"id": "<%=id%>",
				"cds": cds,
				"ts": tipoServ,
				"pac_id": "<%=pacId%>",
				"admision": "<%=noAdmision%>",
				"baction":$that.text()
			};

			if ($.trim(cds) || $.trim(tipoServ)){
				$.ajax({
					url: '../admision/sol_ben_new_coberturas_det.jsp?id=<%=id%>&pac_id=<%=pacId%>&admsion=<%=noAdmision%>',
					data: data,
					type: "POST"
				}).done(function(d){
					var d = $.trim(d);
					var cIFUrl = $("#ifSolBenCoberturasDet").attr("src");
					if (d=="SUCCESS") $("#ifSolBenCoberturasDet").attr("src", cIFUrl);
					else parent.CBMSG.error(d);
				}).fail(function(r,x,m){
						parent.CBMSG.error(m);
				});
			}

		});

		$(document).on("change", ".sel_ts", function(){
			 var $that = $(this);
			 var i = $that.data("index");
			 var val = $that.val();
			 var _inputs = "#codigo_detalle"+i+", #desc_detalle"+i;
			 var _sp = {};
			 var _spFinal = {};
			 var urls = {};
			 var toPath = $that.find("option:selected").attr("title");
			 toPath = toPath.split("@@")[0];

			 if (toPath == "../common/check_uso.jsp" || toPath == "../common/check_articulo.jsp" || toPath == "../common/check_otroscargos.jsp"){
				 _sp["codigo_detalle"+i] = "codigo";
				 _sp["desc_detalle"+i] = "descripcion";
				 _spFinal[toPath] = _sp;
			 }else if (toPath == "../expediente/listado_procedimiento.jsp"){
				 _sp["codigo_detalle"+i] = "code";
				 _sp["desc_detalle"+i] = "name";
				 _spFinal[toPath] = _sp;
			 }

			 urls["codigo_detalle"+i] = toPath+"?fp=convenio_beneficio_new&index="+i+"&curIndex="+i+"&tipoServicio="+val;
			 urls["desc_detalle"+i] = toPath+"?fp=convenio_beneficio_new&index="+i+"&curIndex="+i+"&tipoServicio="+val;

			 allowWriting({
				inputs: _inputs,
				listener: "keydown",
				keycode: 9,
				keyboard: true,
				iframe: "#preventPopupFrame",
				searchParams: _spFinal[toPath],
				baseUrls: urls
			});

		});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

								<tr class="TextRow02">
					<td>
										<jsp:include page="../common/paciente.jsp" flush="true">
												<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
												<jsp:param name="mode" value="view"></jsp:param>
												<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
										</jsp:include>
										</td>
				</tr>

								<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

								<tr class="TextRow02">
					<td><iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe></td>
				</tr>


								<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
								<%=fb.formStart(false)%>
								<%=fb.hidden("tab","0")%>
								<%=fb.hidden("mode",mode)%>
								<%=fb.hidden("baction","")%>
								<%=fb.hidden("pac_id",pacId)%>
								<%=fb.hidden("admision",noAdmision)%>

				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1" id="tbl_cnt">
												<tbody>
												<tr class="TextRow01">
													<td align="right" colspan="2">
														 <%String disabled = viewMode?"disabled='disabled'":"";%>
														 <button <%=disabled%> data-type="C" class="CellbyteBtn add_new_row">+Coberturas</button>
														 <button <%=disabled%> data-type="E" class="CellbyteBtn add_new_row">+Exclusi&oacute;n</button>
														 <button <%=disabled%> data-type="N" class="CellbyteBtn add_new_row">+No Cubiertos</button>
													</td>
												</td>

												<!--TEMPLATE-->
												<tr class="TextRow01" id="cds_wrapper" style="display:none">
													<td align="right">CDS</td>
													<td>
													<%=fb.hidden("tipo_detalle-INDEX","")%>

													<%=fb.select("cds-INDEX",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds"))),"",false,false,0,"Text10 sel_cds","width:100px","",null,"S","data-index=-INDEX")%>

														TS
														<%=fb.select("tipo_servicio-INDEX","","",false,false,0,"Text10 sel_ts","width:100px",null,null,"S","data-index=-INDEX")%>

														<%=fb.textBox("codigo_detalle-INDEX","",false,false,false,4)%>
														<%=fb.textBox("desc_detalle-INDEX","",false,false,false,15)%>
														<%=fb.button("btn_add_detalle-INDEX","...",true,viewMode,null,null,"","Agregar Coberturas")%>


														&nbsp;&nbsp;Cl&iacute;nica&nbsp;<%=fb.select("tipo_val_cli-INDEX","M=$,P=%","")%>
														<%=fb.decBox("monto_cli-INDEX","",false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_cli-INDEX","E=Evento,D=Diario","")%>

														&nbsp;&nbsp;Pac.&nbsp;<%=fb.select("tipo_val_pac-INDEX","M=$,P=%","")%>
														<%=fb.decBox("monto_pac-INDEX","",false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_pac-INDEX","E=Evento,D=Diario","")%>

														&nbsp;&nbsp;Emp.&nbsp;<%=fb.select("tipo_val_emp-INDEX","M=$,P=%","")%>
														<%=fb.decBox("monto_emp-INDEX","",false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_emp-INDEX","E=Evento,D=Diario","")%>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<span style="">
														<button id="btn_save-INDEX" class="CellbyteBtn btn_save" data-index="-INDEX">Guardar</button>&nbsp;&nbsp;
														<button <%=viewMode?"disabled":""%> id="btn_cds_rem_row-INDEX" class="CellbyteBtn btn_cds_rem_row" style="display:none;" data-index="-INDEX">X</button></span>
													</td>
												</tr>
												<!--/TEMPLATE-->

												<tr class="TextHeader02" id="wrapper_C" style="display:none">
													<td colspan="2">Coberturas</td>
												</tr>
												<tr class="TextHeader02" id="wrapper_E" style="display:none">
													<td colspan="2">Exclusiones</td>
												</tr>
												<tr class="TextHeader02" id="wrapper_N" style="display:none">
													<td colspan="2">No Cubiertos</td>
												</tr>

												</tbody>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">&nbsp;</td>
				</tr>
								<%=fb.formEnd(true)%>

								<tr class="TextRow02">
					<td>
											<iframe id="ifSolBenCoberturasDet" name="ifSolBenCoberturasDet" width="100%" height="330" scrolling="yes" frameborder="0" src="../admision/sol_ben_new_coberturas_det.jsp?id=<%=id%>&mode=<%=mode%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>"></iframe>
										</td>
				</tr>


				</table>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
}//POST
%>