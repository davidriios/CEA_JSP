<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String curUserName = (String)session.getAttribute("_userName");
String sel = request.getParameter("sel")==null?"":request.getParameter("sel");
String cTime = request.getParameter("__ct");
String from = request.getParameter("from");
String exp = request.getParameter("exp");
String fp = request.getParameter("fp");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";
if (from == null) from = "";
if (exp == null) exp = "";
if (fp == null) fp = "";

String iWidth = "14.40", iHeight = "21.80";

try{iWidth =java.util.ResourceBundle.getBundle("issi").getString("recWidth"); }catch(Exception e){}
try{iHeight =java.util.ResourceBundle.getBundle("issi").getString("recHeight"); }catch(Exception e){}

sql = "select zz.*, nvl(zz.cantidad, 0) - nvl(zz.tot_despachado, 0) as tot_pendiente from(select m.no_receta, nvl(m.invalido, 'N') invalido, nvl(m.despachado, 'N') despachado, (select comp_id_receta from tbl_sal_recetas where pac_id = m.pac_id and admision = m.admision and id_recetas = m.no_receta and rownum = 1) as comp_id_receta, m.secuencia as id_medicamento, m.medicamento||decode(m.cantidad, null,null,' ##'||m.cantidad) medicamento,m.indicacion, m.dosis, m.duracion, m.cantidad, m.frecuencia, p.primer_nombre||' '||p.segundo_apellido as pac_nombre,trunc(months_between(sysdate,p.fecha_nacimiento)/12)||' año(s) '||trunc(mod(months_between(sysdate,p.fecha_nacimiento),12))||' mes(es)'||' '||trunc(sysdate-add_months(p.fecha_nacimiento,trunc(months_between(sysdate,p.fecha_nacimiento)/12)*12+trunc(mod(months_between(sysdate,p.fecha_nacimiento),12))))||' día(s)' as edad, nvl(p.seguro_social,'N/A') as ss, decode(e.sexo,'F','DRA. ','DR. ')||e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada)) as nombre_medico, e.codigo as registro_medico, (select count(*) from tbl_sal_recetas r where r.pac_id = m.pac_id and r.admision =  m.admision and r.id_recetas = m.no_receta and r.status = 'P') as printed, nvl(m.despachado_comentario,' ') as despachado_comentario, (SELECT SUM(CANTIDAD) FROM TBL_SAL_MED_RECETAS_DESPACH WHERE PAC_ID = m.pac_id AND ADMISION = m.admision AND SECUENCIA_MED = m.secuencia AND NO_RECETA = m.no_receta) as tot_despachado from tbl_sal_salida_medicamento m, tbl_adm_paciente p, tbl_adm_admision a  ,(select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e where p.pac_id = m.pac_id and a.medico = e.codigo and a.pac_id = m.pac_id and a.secuencia = m.admision and m.pac_id = "+pacId+" and m.admision = "+noAdmision+" order by m.no_receta) zz where zz.comp_id_receta is not null";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET")){

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<style>
.cantidad_adespachar { width: 43px;}
</style>
<script>
window.history.forward();
document.title = 'EXPEDIENTE-PLAN DE SALIDA '+document.title;
function doAction(){
	<%if (request.getParameter("canBePrinted")!=null){%>
	//doPrint();
	<%}%>
}


$(document).ready(function(){
	$("#print, #printC").on("click",function(){
		 var tot = $("#size").val();
		 var sel = [];
			for (f = 0; f<tot; f++){

			if ($("#chk"+f).prop("checked")==true) {sel.push($("#chk"+f).val());}
		}
		if (sel.length>0){
			 $("#sel").val(sel);
			 $("#baction").val("Guardar");
			 if ($(this).attr("name")=="print") $("#sub_baction").val("Normal Printing");
			 else $("#sub_baction").val("Custom Printing");
			 $("#form0").submit();
		}
		else {CBMSG.error("Por favor escoge por lo menos una receta!");}

	});

	$("#despachar").on("click",function(){
		if ($(".chk-despachar:checked").length) {
			var proceed = true;
			$(".chk-despachar:checked").each(function(index, el) {
				var i = $(el).data('i');
				//if (!$.trim($("#despachado_comentario"+i).val()) || !$.trim($("#cantidad_adespachar"+i).val())) {
				if (!$.trim($("#cantidad_adespachar"+i).val())) {
					proceed = false;
				}
			});

			if (proceed) {
				$("#baction").val("despachar");
				$("#form0").submit();
			} else {
				//alert("Por favor agregar comentarios y cantidad a los medicamentos a despachar!");
				alert("Por favor agregar cantidad a los medicamentos a despachar!");
			}
		}
	});

	$(".despachado-comment").addClass("FormDataObjectDisabled");
	$(".cantidad_adespachar").addClass("FormDataObjectDisabled");
	$(".chk-despachar").click(function(e) {
		var self = $(this);
		var i = self.data('i');
		var $textarea = $("#despachado_comentario"+i);
		var $cantAdespachar = $("#cantidad_adespachar"+i);
		var comentarioTemp = $("#despachado_comentario_temp"+i).val() || '';

		if (!self.is(':checked')) {
			$textarea.removeClass("FormDataObjectRequired");
			$textarea.prop('readonly', true).val(comentarioTemp).addClass("FormDataObjectDisabled");
			
			$cantAdespachar.removeClass("FormDataObjectRequired");
			$cantAdespachar.prop('readonly', true).val("").addClass("FormDataObjectDisabled");
		} else {
			$textarea.prop('readonly', false).removeClass("FormDataObjectDisabled");
			//$textarea.addClass("FormDataObjectRequired");
			
			$cantAdespachar.prop('readonly', false).removeClass("FormDataObjectDisabled");
			$cantAdespachar.addClass("FormDataObjectRequired");
		}
	});

});

function doPrint(){
	abrir_ventana1("../expediente/exp_print_recetas.jsp?idRec=<%=sel%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>");
}

/*function imprimir(){
	abrir_ventana1("../expediente/exp_print_recetas.jsp?idRec=<%=sel%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>");
}
*/


function invalidate(i) {
  var $btn = $("#inv"+i)
  var $textarea = $("#despachado_comentario"+i);
  var $cantAdespachar = $("#cantidad_adespachar"+i);
  var medicamento = $("#medicamento"+i).val()
  var idMedicamento = $("#id_medicamento"+i).val()
  $btn.prop('disabled',  true)
  
  if (confirm('Confirmar que quieres invalidar " '+medicamento+' " ')) {
	$("#despachar"+i).prop({disabled: true, checked: false})
	
	$textarea.removeClass("FormDataObjectRequired");
	$textarea.prop('readonly', true).val("").addClass("FormDataObjectDisabled");
	
	$cantAdespachar.removeClass("FormDataObjectRequired");
	$cantAdespachar.prop('readonly', true).val("").addClass("FormDataObjectDisabled");
	
    $.ajax({
      url: '<%=request.getContextPath()+request.getServletPath()%>', 
      method: 'POST',
      data: {
        id_medicamento: idMedicamento,
        seccion: '<%=seccion%>',
        pacId: '<%=pacId%>',
        noAdmision: '<%=noAdmision%>',
        fp: '<%=fp%>',
        baction: 'invalidating',
      }
    }).done(function(response) {
	  $("#invalid_indicator"+i).show()
    }).fail(function(response) {
      alert(response.responseJSON.msg || 'Error tratando de invalidar el medicamento')
    })
  } else {
    $btn.prop('disabled',  false)
  }
}
function regMarbete(doc_id){
	showPopWin('../pos/reg_marbete.jsp?fp=RECETA&pac_id=<%=pacId%>&admision=<%=noAdmision%>&doc_id='+doc_id,winWidth*.85,_contentHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
		<td colspan="4">
			<jsp:include page="../common/paciente.jsp" flush="true">
			<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="mode" value="view"></jsp:param>
			<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
		 </jsp:include>
		</td>
	</tr>
	<tr class="TextRow01">
		<!--td colspan="4" align="right"> <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td-->
		<td colspan="4" align="right">&nbsp; </td>
	</tr>
	<tr>
		<td>
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("sub_baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
				 <%=fb.hidden("cds",""+cds)%>
				 <%=fb.hidden("desc",""+desc)%>
				 <%=fb.hidden("size",""+al.size())%>
				 <%=fb.hidden("sel","")%>
				 <%=fb.hidden("cTime",cTime)%>
				 <%=fb.hidden("from",from)%>
				 <%=fb.hidden("exp",exp)%>
				 <%=fb.hidden("fp",fp)%>
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel id="2">MEDICAMENTOS RECETADOS</cellbytelabel></td>
				</tr>

				<tr>
					<td colspan="6">
						<div style="border: red solid 1px; width:10.55cm; height:16.11cm;display:none">
						HL
						</div>
					</td>
				</tr>

				<tr>
					<td>
						<table colspan="2" width="100%" cellpadding="1" cellspacing="1" >
						<tr class="TextHeader">
						<td width="25%" class="Text10">MEDICAMENTO</td>
						<td width="14%" class="Text10">&nbsp;</td>
						<td width="11%" class="Text10">INDICACION</td>
						<td width="5%" class="Text10">CANTIDAD</td>
						<td width="11%" class="Text10">DOSIS</td>
						<td width="15%" class="Text10">FRECUENCIA</td>
						<td width="15%" class="Text10">DURACION</td>
							<td width="4%" align="center">
						<%//=fb.checkbox("chk","",false,false,"class='aa'","class='bb'","")%>
						<input type="checkbox" class="chkAll" name="chkAll" id="chkAll" value="" checked="" onclick="jqCheckAll('form0','chk',this)" />
						</td>
						</tr>
							<%
						String recetaGroup = "";
						int tot = 0, totP = 0, totPendiente = 0;
						for (int m = 0; m<al.size(); m++){
							cdo = (CommonDataObject)al.get(m);
							String color = m%2==0?"TextRow02":"TextRow01";

							//totP += Integer.parseInt(cdo.getColValue("printed")==null || "".equals(cdo.getColValue("printed"))?"0":cdo.getColValue("printed"));

							if (cdo.getColValue("printed")!=null && !cdo.getColValue("printed").equals("0") && Integer.parseInt(cdo.getColValue("printed")) > 0 ) totP++;
							
							totPendiente = Integer.parseInt(cdo.getColValue("tot_pendiente", "0"));

							if (!cdo.getColValue("no_receta").equals(recetaGroup)){
								tot++;
						%>
						<tr class="TextHeader01">
						<td colspan="<%=fp.equals("farmacia")?"6":"7"%>">Receta# <%=cdo.getColValue("no_receta")%></td>
						<%if(fp.equals("farmacia")){%>
						<td align="center">
						<a href="javascript:regMarbete(<%=cdo.getColValue("no_receta")%>)" style="color: white; font-weight: bold;">Marbete</a>
						</td>
						<%}%>
						<td align="center">						
						<% //if (cdo.getColValue("printed") != null && cdo.getColValue("printed").equals("0")){%>
						<input type="checkbox" class="chk" name="chk<%=m%>" id="chk<%=m%>" value="<%=cdo.getColValue("no_receta")%>" checked="checked" />
						<% //}else{%>Imp.<%//}%>
						</td>
						</tr>
						<%=fb.hidden("no_receta"+m,cdo.getColValue("no_receta"))%>
						<%=fb.hidden("comp_id_receta"+m,cdo.getColValue("comp_id_receta"))%>
						<%=fb.hidden("invalido"+m,cdo.getColValue("invalido"))%>
						<%}%>
						<%=fb.hidden("id_medicamento"+m,cdo.getColValue("id_medicamento"))%>
						<%=fb.hidden("trx_no_receta"+m,cdo.getColValue("no_receta"))%>
							<tr class="<%=color%>">
								<td>
									<%=fb.textarea("medicamento"+m,cdo.getColValue("medicamento"),false,false,true,40,2,0,null,"",null)%>
								</td>
								<td>
									<%//if(fp.equalsIgnoreCase("farmacia") && cdo.getColValue("invalido", "N").equalsIgnoreCase("N") && !cdo.getColValue("despachado", "N").equalsIgnoreCase("Y")){%>
									<%if(fp.equalsIgnoreCase("farmacia") && cdo.getColValue("invalido", "N").equalsIgnoreCase("N") && totPendiente > 0){%>
										<label>
											<input type="checkbox" class="chk-despachar" name="despachar<%=m%>" id="despachar<%=m%>" value="<%=cdo.getColValue("no_receta")%>" data-i="<%=m%>" />Despachar<br>
										</label>
										<%=fb.textarea("despachado_comentario"+m,cdo.getColValue("despachado_comentario"),false,false,false,20,2,250,"despachado-comment","","")%>
										<%=fb.hidden("despachado_comentario_temp"+m, cdo.getColValue("despachado_comentario"))%>
									<%} else if(fp.equalsIgnoreCase("farmacia") && cdo.getColValue("despachado", "N").equalsIgnoreCase("Y")){%>
									<span style="margin-left:10px; color: green; font-weight: bold; vertical-align:center">
										DESPACHADO<br>
										<%=fb.textarea("despachado_comentario"+m,cdo.getColValue("despachado_comentario"),false,false,true,20,2,0,"","","")%>
										
									</span>
									<%}%>

								</td>
								<td><%=fb.textarea("indicacion"+m,cdo.getColValue("indicacion"),false,false,true,15,2,0,null,"",null)%></td>
								<td>
									<%=fb.textBox("cantidad"+m,cdo.getColValue("cantidad"),false,false,true,2,null,"",null)%>
									<%if(fp.equalsIgnoreCase("farmacia") && cdo.getColValue("invalido", "N").equalsIgnoreCase("N")){%>
										<%if(fp.equalsIgnoreCase("farmacia")){%>/
											 <%if(totPendiente > 0){%>
												<%=totPendiente%>
											 <%}%>
											 <%//if(cdo.getColValue("despachado", "N").equalsIgnoreCase("N")){%>
											 <%if(totPendiente > 0){%>
												<input type="number" maxlength="2" min="0" max="<%=totPendiente%>" name="cantidad_adespachar<%=m%>" id="cantidad_adespachar<%=m%>" value="" class="cantidad_adespachar" readonly>
											 <%} else {%>
												<%=cdo.getColValue("tot_despachado")%>
											 <%}%>
																		
										<%}%>
									<%}%>
								</td>
								<td><%=fb.textarea("dosis"+m,cdo.getColValue("dosis"),false,false,true,15,2,0,null,"",null)%></td>
								<td><%=fb.textarea("frecuencia"+m,cdo.getColValue("frecuencia"),false,false,true,15,2,0,null,"",null)%></td>
								<td>
									<%=fb.textarea("duracion"+m,cdo.getColValue("duracion"),false,false,true,15,2,0,null,"",null)%>
									<%if(cdo.getColValue("invalido", "N").equalsIgnoreCase("Y")){%>
									
									<%}%>
									
									<span id="invalid_indicator<%=m%>" style="margin-left:10px; color: red; font-weight: bold; vertical-align:center;display:<%=cdo.getColValue("invalido", "N").equalsIgnoreCase("Y")?"block":"none"%>">
										INV&Aacute;LIDO
									</span>
								</td>
								
								<td align="center">
									<%if(fp.equalsIgnoreCase("farmacia")){%>
										<%=fb.button("inv"+m,"X",true,(viewMode||cdo.getColValue("invalido", "N").equalsIgnoreCase("Y")||cdo.getColValue("despachado", "N").equalsIgnoreCase("Y")),null,null,"onClick=invalidate("+m+")","Invalidar")%>
									<%}%>
								</td>
							</tr>
							<%//=fb.hidden("indicacion"+m,cdo.getColValue("indicacion"))%>
						<%
							recetaGroup = cdo.getColValue("no_receta");
						} //for m%>
						<%=fb.hidden("tot",""+tot)%>
						<%=fb.hidden("totP", ""+totP)%>
						</table>
					</td>
				</tr>


				<tr class="TextRow02">
					<td colspan="2" align="right">
					<%if(fp.equalsIgnoreCase("farmacia")){%>
						<%=fb.button("despachar","Despachar",true,false,null,null,"")%>
					<%}%>

				<%=fb.button("print","Imprimir",true,viewMode,null,null,"")%>

				<%//if (UserDet.getUserProfile().contains("0")) {%>
					<%//=fb.button("printC","Tamaño definido",true,viewMode,null,null,"")%>
				<%//}%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=javascript:window.close()")%>
					</td>
				</tr>
					<%//fb.appendJsValidation("if(error>0)doAction();");%>
					<%=fb.formEnd(true)%>
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
	int size = Integer.parseInt(request.getParameter("size")==null?"0":request.getParameter("size"));
	String baction = request.getParameter("baction");
	String subBaction = request.getParameter("sub_baction");
	al.clear();
	
	CommonDataObject cdoD = new CommonDataObject();
	ArrayList alD = new ArrayList();
	
	System.out.println(".................................................... baction = "+baction);
	
	if (baction.equalsIgnoreCase("invalidating") && fp.equalsIgnoreCase("farmacia")) {
		response.setContentType("application/json");

		com.google.gson.Gson gson = new com.google.gson.Gson();
		com.google.gson.JsonObject json = new com.google.gson.JsonObject();

		json.addProperty("date", System.currentTimeMillis());

		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_salida_medicamento");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("id_medicamento"));
		cdo2.addColValue("invalido", "Y");
		cdo2.addColValue("usuario_invalida", (String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_invalida", curDate);

		SQLMgr.update(cdo2);

		if (SQLMgr.getErrCode().equals("1")) {
			json.addProperty("error", false);
			json.addProperty("msg", "SecMgr inactivó satifactoriamente");
		} else {
			response.setStatus(500);
			json.addProperty("error", true);
			json.addProperty("msg", SQLMgr.getErrMsg());
		}

		out.print(gson.toJson(json));
		return;
	}
	else if (baction.equalsIgnoreCase("despachar") && fp.equalsIgnoreCase("farmacia")) {
			for (int t = 0; t<size; t++){
				if (request.getParameter("despachar"+t) != null){
					cdo = new CommonDataObject();
					cdo.setTableName("tbl_sal_salida_medicamento");
					cdo.setAction("U");
					cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and secuencia = "+request.getParameter("id_medicamento"+t));
					cdo.addColValue("despachado", "Y");
					cdo.addColValue("usuario_despacha",(String) session.getAttribute("_userName"));
					cdo.addColValue("fecha_despacha", curDate);
					cdo.addColValue("despachado_comentario", request.getParameter("despachado_comentario"+t));
					al.add(cdo);
					
					if ( request.getParameter("cantidad_adespachar"+t) != null ) {
						cdoD = new CommonDataObject();
						cdoD.setTableName("tbl_sal_med_recetas_despach");
						cdoD.addColValue("codigo","(select nvl(max(codigo), 0) + 1 from tbl_sal_med_recetas_despach where pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+")");
						cdoD.setAction("I");
						
						cdoD.addColValue("PAC_ID",request.getParameter("pacId"));
						cdoD.addColValue("ADMISION",request.getParameter("noAdmision"));
						cdoD.addColValue("secuencia_med", request.getParameter("id_medicamento"+t));
						cdoD.addColValue("cantidad", request.getParameter("cantidad_adespachar"+t));
						cdoD.addColValue("no_receta",request.getParameter("trx_no_receta"+t));
						cdoD.addColValue("USUARIO_CREACION",curUserName);
						cdoD.addColValue("FECHA_CREACION",curDate);
						cdoD.addColValue("USUARIO_MODIFICACION",curUserName);
						cdoD.addColValue("FECHA_MODIFICACION",curDate);
						
						alD.add(cdoD);
					}
				}
			}

			if (al.size() == 0) {
				CommonDataObject cdo3 = new CommonDataObject();

				cdo3.setTableName("tbl_sal_salida_medicamento");
				cdo3.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
				al.add(cdo3);
			}
			SQLMgr.saveList(al,true);
			
			if (SQLMgr.getErrCode().equals("1")) {
				if (alD.size() == 0) {
					CommonDataObject cdo3 = new CommonDataObject();

					cdo3.setTableName("tbl_sal_med_recetas_despach");
					cdo3.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
					alD.add(cdo3);
				}
				SQLMgr.saveList(alD,true);
			}

	} else {

		for (int t = 0; t<size; t++){
			if (request.getParameter("chk"+t) != null && request.getParameter("invalido"+t) != null && request.getParameter("invalido"+t).equalsIgnoreCase("Y")){

				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_recetas");
				cdo.addColValue("PAC_ID",request.getParameter("pacId"));
				cdo.addColValue("ADMISION",request.getParameter("noAdmision"));
				cdo.addColValue("USUARIO_CREACION",curUserName);
				cdo.addColValue("FECHA_CREACION",curDate);
				cdo.addColValue("USUARIO_MODIFICACION",curUserName);
				cdo.addColValue("FECHA_MODIFICACION",curDate);
				cdo.addColValue("STATUS","A");

				if (request.getParameter("comp_id_receta"+t)!=null && !request.getParameter("comp_id_receta"+t).trim().equals("")){
					cdo.setAction("U");

					// just in case we need updating...

					cdo.setWhereClause("1=2 and pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and comp_id_receta = "+request.getParameter("comp_id_receta"+t));

				}else{
					cdo.setAction("I");
					cdo.addColValue("ID_RECETAS",request.getParameter("no_receta"+t));
					cdo.addColValue("COMP_ID_RECETA","(select nvl( max (comp_id_receta) , get_sec_comp_param(-1,'SAL_SEQ_RECETA'))+1 from tbl_sal_recetas)");
				}

				// al.add(cdo);
			}
		}//for t


		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				CommonDataObject cdo3 = new CommonDataObject();

				cdo3.setTableName("tbl_sal_recetas");
				cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
				al.add(cdo3);
			}
			SQLMgr.saveList(al,true);
		}
	}
%>
<html>
<head>
<script language="javascript">
	function closeWindow(){
		<%if (SQLMgr.getErrCode().equals("1")){
			if (subBaction.equals("Normal Printing")){
		%>
		window.open("../expediente/exp_print_recetas.jsp?idRec=<%=sel%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cTime=<%=request.getParameter("cTime")%>&exp=<%=exp%>&fp=<%=fp%>");
		window.location = "../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&fp=<%=fp%>";
		<%
		} else if (baction.equalsIgnoreCase("despachar") && fp.equalsIgnoreCase("farmacia")) { %>
		alert("<%=SQLMgr.getErrMsg()%>");
		window.location = "../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&fp=<%=fp%>";
		<%} else{%>
		window.open("../expediente/exp_print_recetas_x_x_x.jsp?idRec=<%=sel%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cTime=<%=request.getParameter("cTime")%>&iWidth=<%=iWidth%>&iHeight=<%=iHeight%>&exp=<%=exp%>&fp=<%=fp%>");
	 <% }
		}else throw new Exception(SQLMgr.getErrMsg());%>
	}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>