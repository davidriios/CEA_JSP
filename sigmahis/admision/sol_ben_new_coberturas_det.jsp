<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
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

ArrayList al = new ArrayList();
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");

String id = request.getParameter("id");
String pacId = request.getParameter("pac_id");
String noAdmsion = request.getParameter("admision");
String compania = (String) session.getAttribute("_companyId");
String cUserName = (String) session.getAttribute("_userName");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (id == null) id = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{

		sql.append("select tipo_detalle,ref_type,refer,monto_cli,monto_pac,monto_emp,tipo_val_cli,tipo_val_pac,tipo_val_emp,tipo_cob_cli,tipo_cob_pac,tipo_cob_emp, cds, ts ");

		sql.append(", decode(ref_type, ");
		sql.append("'PROC',(select decode(observacion , null , descripcion,observacion) as descripcion FROM tbl_cds_procedimiento where estado = 'A' and codigo = d.refer) ");
		sql.append(",'DIAG', (select coalesce(observacion,nombre) as nombre from tbl_cds_diagnostico where comun='S' and codigo = d.refer) ");
		sql.append(",'ART', (select descripcion from tbl_inv_articulo where compania = d.compania and cod_flia||'-'||cod_clase||'-'||cod_articulo||'-'||cod_subclase like d.refer) ");

		sql.append(") refer_desc ");

		sql.append(", decode(d.tipo_detalle,'C','COBERTURA','E','EXCLUSION','N','NO CUBIERTOS') as tipo_detalle_desc ");

		sql.append(" from tbl_ase_convenio_det d where d.tipo_detalle in('C','E','N') and d.id = ");
		sql.append(id);
		sql.append(" and compania = ");
		sql.append(compania);
		sql.append(" order by d.tipo_detalle ");

		al = SQLMgr.getDataList(sql);

		boolean viewMode = mode.equalsIgnoreCase("view");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script src="../js/noty/packaged/jquery.noty.packaged.min.js"></script>
<link rel="stylesheet" href="../css/animatecss.css">
<script>
document.title = 'Solicitud de Beneficio - '+document.title;

$(document).ready(function(){

	$(".btn_proc_diag_rem").click(function(c){
		c.preventDefault();
	});

	//Removing
	$(".btn_proc_diag_rem").click(function(e){
		e.preventDefault();
		var $that = $(this);
		var i = $that.data("index");
		var refType = $that.data("ref_type");
		var refer = $("#refer"+i).val();
		var tipo = $("#tipo"+i).val();
		var cds = $that.data("cds");
		var ts = $that.data("ts");

		var data = {
				"tipo_detalle": tipo,
				"ref_type": refType,
				"refer": refer,
				"cds": cds,
				"ts": ts,
				"id": "<%=id%>",
				"baction":"Delete",
				"mode":"edit"
		};

		if (tipo || refer || cds ){
				if (!$that.hasClass("deleting")){
						$that.addClass("deleting");
						$.ajax({
							url: '../admision/sol_ben_new_coberturas_det.jsp?id=<%=id%>',
							data: data,
							type: "POST"
						}).done(function(d){
							var d = $.trim(d);
							$that.removeClass("deleting");
							if (d=="SUCCESS") {
								$("#det_row"+i).remove();
							}
							else showNoty("No se actualizó correctamente!", "error");
						}).fail(function(r,x,m){
								showNoty(m, "error");
								$that.removeClass("deleting");
						});
				}
		}


	});

	<%if(!viewMode){%>
	$('.lnk_edit').click(function(){
			var $that = $(this);
			var i = $that.data("index");
			var refType = $that.data("ref_type");
			var cds = $that.data("cds");
			var ts = $that.data("ts");
			var refer = $("#refer"+i).val();
			var tipo = $("#tipo"+i).val();
			var data = {
				"tipo_detalle": tipo,
				"ref_type": refType,
				"refer": refer,
				"cds": cds,
				"ts": ts,
				"monto_cli": $("#monto_cli"+i).val(),
				"monto_pac":$("#monto_pac"+i).val(),
				"monto_emp":$("#monto_emp"+i).val(),
				"tipo_val_cli":$("#tipo_val_cli"+i).val(),
				"tipo_val_pac":$("#tipo_val_pac"+i).val(),
				"tipo_val_emp":$("#tipo_val_emp"+i).val(),
				"tipo_cob_cli":$("#tipo_cob_cli"+i).val(),
				"tipo_cob_emp":$("#tipo_cob_emp"+i).val(),
				"id": "<%=id%>",
				"baction":"Guardar",
				"mode":"edit"
			};

			if (tipo || refer || cds ){
				if (!$that.hasClass("updating")){
						$that.addClass("updating");
						$.ajax({
							url: '../admision/sol_ben_new_coberturas_det.jsp?id=<%=id%>',
							data: data,
							type: "POST"
						}).done(function(d){
							var d = $.trim(d);
							$that.removeClass("updating");
							if (d=="SUCCESS") showNoty("Actualizado!", "success");
							else showNoty("No se actualizó correctamente!", "error");
						}).fail(function(r,x,m){
								showNoty(m, "error");
								$that.removeClass("updating");
						});
				}
			}
	 });
	 <%}%>

	$(".sel_cds").prop("disabled", true);




	var _index = 0;
	$("span").on("click", function(){
				_index = $("#curId").val();
				var panel = $('.panel'+_index);
				var labelPlusMinus = $('.plus_minus'+_index);
				if (panel.css('display') != "none"){
						panel.hide();
						labelPlusMinus.html("[+]");
				}
				else {
						panel.show();
						labelPlusMinus.html("[-]");
				}
		});
});

function showNoty(msg, type){
		var type = type || 'success';
		noty({
				type: type,
				text: msg,
				killer: true,
				timeout:1000,
				animation: {
						open: 'animated bounceInLeft',
						close: 'animated bounceOutLeft',
				}
		});
}
function printList(){
	abrir_ventana("../print_sol_ben_new_coberturas.jsp?id=<%=id%>&pacId=<%=pacId%>&noAdmsion=<%=noAdmsion%>");
}
function setIndex(id){document.getElementById("curId").value = id;}
</script>
<style>
.lnk_edit{cursor:pointer; width:20px; height:20px; background:url(../images/edit.png) no-repeat; background-size: 20px 20px;}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

								<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
								<%=fb.formStart(false)%>
								<%=fb.hidden("tab","0")%>
								<%=fb.hidden("mode",mode)%>
								<%=fb.hidden("pac_id",pacId)%>
								<%=fb.hidden("admision",noAdmsion)%>
								<%=fb.hidden("curId","")%>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1" id="tbl_cnt">
												<tr class="TextHeader">
													 <td width="10%">CDS</td>
													 <td width="10%">TS</td>
													 <td width="25%">Descripci&oacute;n</td>
													 <td width="15%">Cl&iacute;nica</td>
													 <td width="15%">Paciente</td>
													 <td width="15%">Empresa</td>
													 <td width="5%"><a href="javascript:printList()" class="Link04Bold">Imprimir</a></td>
													 <td width="5%">&nbsp;</td>
												</tr>
												<tbody>

												<%
													String gTipoDet = "";
													int totByG = 0;

													for (int i = 0; i<al.size(); i++){
													CommonDataObject cdo = (CommonDataObject)al.get(i);
													String color = "TextRow02";
													if (i % 2 == 0) color = "TextRow01";

													if (!gTipoDet.equals(cdo.getColValue("tipo_detalle"))){
												%>
														<tr class="TextPanel">
															<td colspan="7"><%=cdo.getColValue("tipo_detalle_desc")%></td>
															<td align="center">
																<span id="plus<%=cdo.getColValue("tipo_detalle")%>" style="cursor:pointer" onClick="javascript:setIndex('<%=cdo.getColValue("tipo_detalle")%>')"> <label style="cursor:pointer" class="plus_minus<%=cdo.getColValue("tipo_detalle")%>">[+]</label></span>
																</td>
														</tr>

												<%}%>

												<tr class="panel<%=cdo.getColValue("tipo_detalle")%>" style="display:none;">
												<td colspan="8">
												<table width="100%" cellpadding="0" cellspacing="0">

												<tr style="line-height:0px;">
													 <td width="10%"></td>
													 <td width="10%"></td>
													 <td width="25%"></td>
													 <td width="15%"></td>
													 <td width="15%"></td>
													 <td width="15%"></td>
													 <td width="5%"></td>
													 <td width="5%"></td>
												</tr>

												<tr id="det_row<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
													<td><%=fb.select("cds"+i,xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds"))),cdo.getColValue("cds"),false,false,0,"Text10 sel_cds","width:120px","",null,"S","data-index=-INDEX")%>
													<%=fb.hidden("tipo"+i, cdo.getColValue("tipo_detalle"))%>
													 </td>
														<td>
														<%=fb.hidden("refer"+i,cdo.getColValue("refer"))%>
														<%=fb.select("ts"+i,xmlRdr.read("sol_ben_new_tipo_serv_x_cds_"+UserDet.getUserId()+".xml"),cdo.getColValue("ts"),false,false,0,"Text10 sel_cds","width:120px","",null,"S","data-index=-INDEX")%>
														</td>
														<td>
														<%=fb.textBox("refer_desc"+i,cdo.getColValue("refer_desc"),false,false,viewMode,38)%>
														</td>
														<td><%=fb.select("tipo_val_cli"+i,"M=$,P=%",cdo.getColValue("tipo_val_cli"))%>
														<%=fb.decBox("monto_cli"+i,cdo.getColValue("monto_cli"),false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_cli"+i,"E=Evento,D=Diario",cdo.getColValue("tipo_cob_cli"))%></td>

														<td><%=fb.select("tipo_val_pac"+i,"M=$,P=%",cdo.getColValue("tipo_val_pac"))%>
														<%=fb.decBox("monto_pac"+i,cdo.getColValue("monto_pac"),false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_pac"+i,"E=Evento,D=Diario",cdo.getColValue("tipo_cob_pac"))%></td>

														<td><%=fb.select("tipo_val_emp"+i,"M=$,P=%",cdo.getColValue("tipo_val_emp"))%>
														<%=fb.decBox("monto_emp"+i,cdo.getColValue("monto_emp"),false,false,viewMode,3,5.2)%>
														&nbsp;<%=fb.select("tipo_cob_emp"+i,"E=Evento,D=Diario",cdo.getColValue("tipo_cob_emp"))%></td>

														<td align="center"><authtype type='4'><div class="lnk_edit" id="lnk_edit<%=i%>" data-index="<%=i%>" data-ref_type="<%=cdo.getColValue("ref_type")%>" data-cds="<%=cdo.getColValue("cds")%>" data-ts="<%=cdo.getColValue("ts")%>"></div></authtype></td>
														<td align="center"><authtype type='4'><button <%=viewMode?"disabled":""%> id="btn_proc_diag_rem<%=i%>" class="CellbyteBtn btn_proc_diag_rem" data-index="<%=i%>" data-ref_type="<%=cdo.getColValue("ref_type")%>" data-cds="<%=cdo.getColValue("cds")%>" data-ts="<%=cdo.getColValue("ts")%>">X</button></authtype></td>
												</tr>

												</table>
												</td>

												</tr>

												<%
												gTipoDet = cdo.getColValue("tipo_detalle");
												}%>
												</tbody>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">&nbsp;</td>
				</tr>
								<%=fb.formEnd(true)%>


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
	String baction = request.getParameter("baction");
	mode = request.getParameter("mode")==null?"add":request.getParameter("mode");

		StringBuffer sbWhere = new StringBuffer();
		if (request.getParameter("cds").trim() !=null && !request.getParameter("cds").trim().equals("")) {
			sbWhere.append(" and cds = "+request.getParameter("cds"));
		}else sbWhere.append(" and cds is null ");

		if (request.getParameter("ts").trim() !=null && !request.getParameter("ts").trim().equals("")) {
			sbWhere.append(" and ts = '"+request.getParameter("ts"));
			sbWhere.append("'");
		}else sbWhere.append(" and ts is null ");

		if (request.getParameter("ref_type").trim() !=null && !request.getParameter("ref_type").trim().equals("")) {
			sbWhere.append(" and ref_type = '"+request.getParameter("ref_type"));
			sbWhere.append("'");
		}else sbWhere.append(" and ref_type is null ");

		if (request.getParameter("refer").trim() !=null && !request.getParameter("refer").trim().equals("")) {
			sbWhere.append(" and refer = '"+request.getParameter("refer"));
			sbWhere.append("'");
		}else sbWhere.append(" and refer is null ");

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && baction.equalsIgnoreCase("Guardar")){
		CommonDataObject cdo = new CommonDataObject();

				cdo.setTableName("tbl_ase_convenio_det");
				cdo.addColValue("monto_cli",request.getParameter("monto_cli"));
				cdo.addColValue("monto_pac",request.getParameter("monto_pac"));
				cdo.addColValue("monto_emp",request.getParameter("monto_emp"));
				cdo.addColValue("tipo_val_cli",request.getParameter("tipo_val_cli"));
				cdo.addColValue("tipo_val_pac",request.getParameter("tipo_val_pac"));
				cdo.addColValue("tipo_val_emp",request.getParameter("tipo_val_emp"));
				cdo.addColValue("tipo_cob_cli",request.getParameter("tipo_cob_cli"));
				cdo.addColValue("tipo_cob_emp",request.getParameter("tipo_cob_emp"));
				cdo.addColValue("tipo_pago_pac",request.getParameter("tipo_pago_pac"));
				cdo.addColValue("tipo_pago_emp",request.getParameter("tipo_pago_emp"));

				if (mode.equalsIgnoreCase("add")){

						cdo.addColValue("id",request.getParameter("id"));
						cdo.addColValue("tipo_detalle",request.getParameter("tipo_detalle"));
						cdo.addColValue("ref_type",request.getParameter("ref_type"));
						cdo.addColValue("refer",request.getParameter("refer"));
						cdo.addColValue("cds",request.getParameter("cds"));
						cdo.addColValue("ts",request.getParameter("ts"));
						cdo.addColValue("compania",compania);
						cdo.addColValue("sol_benef","S");

						cdo.addColValue("fecha_creacion", cDateTime);
						cdo.addColValue("usuario_creacion",cUserName);
				cdo.addColValue("fecha_modificacion", cDateTime);
						cdo.addColValue("usuario_modificacion",cUserName);
						SQLMgr.insert(cdo);

				}else{
						cdo.addColValue("fecha_modificacion", cDateTime);
						cdo.addColValue("usuario_modificacion",cUserName);

						cdo.setWhereClause("id="+id+" and tipo_detalle = '"+request.getParameter("tipo_detalle")+"' and compania = "+compania+sbWhere.toString());
						SQLMgr.update(cdo);
				}

	}else if (baction != null && baction.equalsIgnoreCase("Delete")){
			 al.clear();
			 CommonDataObject cdo = new CommonDataObject();
			 cdo.setTableName("tbl_ase_convenio_det");
			 cdo.setAction("D");
			 cdo.setWhereClause("id="+id+" and tipo_detalle = '"+request.getParameter("tipo_detalle")+"' and compania = "+compania+sbWhere.toString());
			 al.add(cdo);
			 SQLMgr.saveList(al,true);
		}
	ConMgr.clearAppCtx(null);

		if (SQLMgr.getErrCode().equals("1")) out.print("SUCCESS");
		else out.print(SQLMgr.getErrMsg());

}//POST
%>