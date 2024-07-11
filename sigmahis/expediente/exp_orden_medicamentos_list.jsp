<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="gson" scope="page" class="com.google.gson.Gson" />
<jsp:useBean id="json" scope="page" class="com.google.gson.JsonObject" />
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
String sql = "";
String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipo = request.getParameter("tipo");
String exp = request.getParameter("exp");
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tipo == null) tipo = "";
if (exp == null) exp = "";
if (fp == null) fp = "";
if (mode == null) mode = "";

boolean viewMode = mode.equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (tipo.trim().equalsIgnoreCase("A")) appendFilter += " and a.estado_orden='A' and nvl(a.omitir_orden,'N')='N'";
	else appendFilter += " and ((a.estado_orden!='A' and nvl(a.omitir_orden,'N')='S' ) or a.estado_orden='S' ) ";
    
	sql = "select a.orden_med, to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica, a.nombre as medicamento, a.dosis, (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia, a.frecuencia as descfrecuencia, a.observacion, a.estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'O',to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'O',a.omitir_usuario,'--') usuario_omit, /*a.usuario_creacion*/'['||a.usuario_creacion||'] - '||b.name  as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, a.codigo,nvl(a.ejecutado,'N')ejecutado,nvl(a.relevante,'N') as relevante,a.codigo_orden_med as noOrden,a.dosis_desc, a.cantidad,(select '<b>ACCION:</b> '|| m.accion||'<br><b>INTERACCION:</b>'||m.interaccion from tbl_sal_medicamentos m where m.compania = "+((String) session.getAttribute("_companyId"))+" and m.status = 'A' and antibio_ctrl = 'S' and m.medicamento = substr(a.nombre,0, instr(a.nombre,'/')-2 )and a.tipo_orden = 2 and rownum = 1) control, nvl(a.encasa,'N') as encasa from tbl_sal_detalle_orden_med a, tbl_sec_users b  where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and b.user_name(+) = a.usuario_creacion and a.tipo_orden=2 "+appendFilter+" order by a.fecha_orden desc,a.codigo_orden_med desc,a.orden_med desc";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Medicamentos Activos - '+document.title;

function doAction(){
}
function omitirOrden(){
  var idOrden = new Array();
  for ( i = 0; i<<%=al.size()%>; i++ ){
       if ( document.getElementById("omitirOrden"+i) && document.getElementById("omitirOrden"+i).checked == true ){
	       idOrden.push(document.getElementById("omitirOrden"+i).value);
	   }
  }
  if ( idOrden.length > 0 ){
       showPopWin('../expediente/expediente_ordenes_medicas.jsp?pacId=<%=pacId%>&secuencia=<%=noAdmision%>&idOrden='+idOrden+'&tipoOrden=2',winWidth*.85,winHeight*.70,null,null,'');
  }else{alert("Por favor escoge al menos un medicamento!");}
}

function marcarRelevante(){
  var totError = 0;
  var proceed = false;
  $("#proceed").prop("disabled", true);
  for ( i = 0; i<<%=al.size()%>; i++ ){
       var ordenMed = document.getElementById("relevantes"+i).value;
       var ordenCod = document.getElementById("codigo"+i).value;
       var enCasa ='N';
	   if(document.getElementById("encasa"+i).checked == true)enCasa ='Y';
	   
	   var relev ='N';
	   if(document.getElementById("relevantes"+i).checked == true)relev ='Y';
	    
	   
       if ((document.getElementById("relevantes"+i) && document.getElementById("relevantes"+i).checked == true)||(document.getElementById("encasa"+i) && document.getElementById("encasa"+i).checked == true)){
            var executed = executeDB('<%=request.getContextPath()%>',"update tbl_sal_detalle_orden_med set relevante = '"+relev+"',encasa='"+enCasa+"', fecha_relevante = decode('"+relev+"','Y',sysdate,null), fecha_modificacion = sysdate, usuario_modificacion = '<%=(String)session.getAttribute("_userName")%>' where pac_id = <%=pacId%> and secuencia = <%=noAdmision%> and tipo_orden = 2 and nvl(omitir_orden,'N') = 'N' and orden_med = "+ordenMed+" and codigo = "+ordenCod, '');
            if (!executed) totError++;
	   } else { 
            executeDB('<%=request.getContextPath()%>',"update tbl_sal_detalle_orden_med set relevante = '"+relev+"',encasa='"+enCasa+"', fecha_relevante = decode('"+relev+"','Y',sysdate,null), fecha_modificacion = sysdate, usuario_modificacion = '<%=(String)session.getAttribute("_userName")%>' where pac_id = <%=pacId%> and secuencia = <%=noAdmision%> and tipo_orden = 2 and nvl(omitir_orden,'N') = 'N' and fecha_relevante is not null and orden_med = "+ordenMed+" and codigo = "+ordenCod, '');
          
       }
  }
  
  proceed = !totError;
  
  if (proceed) {
      if (totError) {
        alert("Error tratando de marcar la orden como relevante.");
      } else {
        alert("Las órdenes se marcaron como relevantes satisfactoriamente.");
        reloadPage();
      }
  }
  $("#proceed").prop("disabled", false);
}

function saveMedRelevantesOmitidos() {
	var $btn = $("#save_med_relevantes_omitidos");
	var textareaValue = $.trim($("#med_relevantes_omitidos").val())
	
	if (textareaValue) {
		$btn.prop("disabled", true).val('Guard...')
		
		$.ajax({
			method: 'POST',
			url: '<%=request.getContextPath()+request.getServletPath()%>',
			data: {
				medicamentos: textareaValue,
				pacId: <%=pacId%>,
				noAdmision: <%=noAdmision%>,
				codigo: $("#codigo_med_rel_omi").val(),
			}
		}).done(function(response) {
			if (response.msg) alert(response.msg)
				
			if (response.force_reload) window.location.reload(true)
			else $btn.prop("disabled", false).val('Guardar')
		}).fail(function(error) {
			if (error.responseJSON && error.responseJSON.msg) alert(error.responseJSON.msg)
			console.log(error)
		    $btn.prop("disabled", false).val('Guardar')	
		})
	}
}

function reloadPage(){
   window.location = "../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=tipo%>&fp=<%=fp%>&exp=<%=exp%>&mode=<%=mode%>";
}
function printOrden(noOrden){abrir_ventana('../expediente/print_exp_seccion_5.jsp?fg=CS&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&noOrden='+noOrden+'&desc=O/M MEDICAMENTOS&exp=<%=exp%>');}

$(function(){
  $(".control-launcher").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#controlCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(!fp.equalsIgnoreCase("plan_salida")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MEDICAMENTOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("exp", exp)%>
<%=fb.hidden("mode", mode)%>

<tr>
	<td class="TableBorder">
		<%if(!fp.equalsIgnoreCase("plan_salida")){%>
        <table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
        <%}%>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextHeader">
			<td colspan="<%=exp.equals("3")?"11":"9"%>" align="center"><cellbytelabel id="1">Listado de Medicamentos Ordenados</cellbytelabel> - <%=(tipo.trim().equalsIgnoreCase("A"))?"ACTIVOS":"OMITIDOS"%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="4%"><cellbytelabel id="2">No. Orden</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="<%=exp.equals("3")?"18%":"22%"%>"><cellbytelabel id="3">Medicamento</cellbytelabel></td>
		<!--	<td width="8%">Dosis</td>-->
			<td width="8%"><cellbytelabel id="4">V&iacute;a</cellbytelabel></td>
			<td width="<%=exp.equals("3")?"15%":"16%"%>"><cellbytelabel id="5">Frecuencia</cellbytelabel></td>
			<%if(exp.equals("3")){%><td width="5%"><cellbytelabel>Dosis</cellbytelabel></td><%}%>
			<td width="21%"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel></td>
			<td width="10%"><%=(tipo.trim().equalsIgnoreCase("A"))?"Ordenado":"Omitido"%> <cellbytelabel id="7">por</cellbytelabel></td>
			<td width="11%"><cellbytelabel id="8">Fec.-Hora</cellbytelabel></td>
			<td width="3%">
                <%if(!fp.equalsIgnoreCase("plan_salida")){%>
                <cellbytelabel>Omitir</cellbytelabel>
                <%}else{%>
                    <cellbytelabel>Relevante</cellbytelabel>
					<%=fb.checkbox("relevantes","",false,(!UserDet.getRefType().trim().equalsIgnoreCase("M")),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','relevantes',"+al.size()+",this,0)\"","Seleccionar todos los Medicamentos listados!")%>
                <%}%>
            </td>
			<%if(fp.equalsIgnoreCase("plan_salida")){%>
			<td width="3%">
			<cellbytelabel>Continuar en casa</cellbytelabel>
					<%=fb.checkbox("encasa","",false,(!UserDet.getRefType().trim().equalsIgnoreCase("M")),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','encasa',"+al.size()+",this,0)\"","Seleccionar todos los registros listados!")%>
			</td>		
			<%}%>
		</tr>
<%
String observ = "",noOrden="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	observ = (cdo.getColValue("observacion")==null?"":cdo.getColValue("observacion"));
%>
		<%=fb.hidden("controlCont"+i,"<label class='controlCont' style='font-size:11px'>"+(cdo.getColValue("control")==null?"":cdo.getColValue("control"))+"</label>")%>
		<tr class="<%=color%>">
			<td align="center">
			<%if(!noOrden.trim().equals(cdo.getColValue("noOrden"))){%>
			<a href="javascript:printOrden(<%=cdo.getColValue("noOrden")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link05"><%=cdo.getColValue("noOrden")%></font></a> <%}%></td>
			<td align="center"><%=cdo.getColValue("fechamedica")%></td>
			<td><%=cdo.getColValue("medicamento")%>
            <%if(!cdo.getColValue("cantidad"," ").trim().equals("")){%>
            &nbsp;<b>##<%=cdo.getColValue("cantidad")%></b>
            <%}%>
			
			<img src="../images/info.png" width="24px" height="24px" class="control-launcher" title="" data-i="<%=i%>" style="vertical-align:middle">
            </td>
			<!--<td width="8%" align="center"><%//=cdo.getColValue("dosis")%></td>-->
			<td align="center"><%=cdo.getColValue("descVia")%></td>
			<td align="center"><%=cdo.getColValue("descFrecuencia")%></td>
			<%if(exp.equals("3")){%><td><%=cdo.getColValue("dosis_desc")%></td><%}%>
			<td>
				<%
				    if ( observ.indexOf("<>") >= 1 ){%>
						<%=observ.substring(observ.indexOf("<>")+2)%>
				<%  }else{ %>
						<%=observ%>
				 <%}%>
		    </td>
<% if (tipo.trim().equalsIgnoreCase("A")) { %>
			<td align="center"><%=cdo.getColValue("usuario_crea")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
			<td align="center">
            <%if(!fp.equalsIgnoreCase("plan_salida")){%>
                <%=fb.checkbox("omitirOrden"+i,cdo.getColValue("orden_med"),false,(!UserDet.getRefType().trim().equalsIgnoreCase("M")&&!UserDet.getXtra5().trim().equalsIgnoreCase("S")),"",null,"","Omitir Medicamento")%>
            <%}else{%>
                <input type="hidden" name="codigo<%=i%>" id="codigo<%=i%>" value="<%=cdo.getColValue("codigo")%>">
                <input type="hidden" name="relevante<%=i%>" id="relevante<%=i%>" value="<%=cdo.getColValue("relevante")%>">
               <%=fb.checkbox("relevantes"+i,cdo.getColValue("orden_med"),cdo.getColValue("relevante"," ").equalsIgnoreCase("Y"),(!UserDet.getRefType().trim().equalsIgnoreCase("M")),"",null,"","Marcar como relevantes")%>
			    <%//=fb.checkbox("relevantesz"+i,cdo.getColValue("orden_med"),cdo.getColValue("relevante"," ").equalsIgnoreCase("Y"),false,"",null,"","Marcar como relevantes")%>
			   
            <%}%>
            </td>
			
			<%if(fp.equalsIgnoreCase("plan_salida")){%>
			<td align="center">
			 <%=fb.checkbox("encasa"+i,cdo.getColValue("orden_med"),cdo.getColValue("encasa"," ").equalsIgnoreCase("Y"),(!UserDet.getRefType().trim().equalsIgnoreCase("M")),"",null,"","Marcar Continuar en Casa")%>
			</td>
			<%}%>
			
<% } else { %>
			<td align="center"><%=cdo.getColValue("usuario_omit")%></td>
			<td align="center"><%=cdo.getColValue("hasta")%></td>
			<td align="center">&nbsp;</td>
<% }%>
		</tr>
<%noOrden = cdo.getColValue("noOrden");
}
%>

		<tr>
			<td colspan="<%=exp.equals("3")?"10":"9"%>" align="right">
                <%if(!fp.equalsIgnoreCase("plan_salida")){%>
				<%=fb.button("proceed","Proceder",true,(tipo.trim().equalsIgnoreCase("A"))?false:true,null,null,"onClick=\"javascript:omitirOrden()\"")%>
				<%=fb.button("close","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
                <%} else {%>
                    <%=fb.button("proceed","Proceder",true,(tipo.trim().equalsIgnoreCase("A"))?false:true,null,null,"onClick=\"javascript:marcarRelevante()\"")%>
                <%}%>
			</td>
		</tr>
		
		<%if(exp.equals("3")){
		 CommonDataObject cdo = SQLMgr.getData("select codigo, medicamentos from tbl_sal_med_rel_omitidos where pac_id = "+pacId+" and no_admision = "+noAdmision);
		 if (cdo == null) {
			 cdo = new CommonDataObject();
			 cdo.addColValue("codigo", "0");
		 }
	    %>
		<tr class="TextHeader">
			<td colspan="10" align="center"><cellbytelabel id="1">Otros Medicamentos Relevantes</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="9" align="center">
				<textarea id="med_relevantes_omitidos" cols="30" rows="5" class="form-control input-sm bg-warning" style="width:80%" maxlength="2000"><%=cdo.getColValue("medicamentos"," ")%></textarea>
			</td>
			<td>
				<%=fb.button("save_med_relevantes_omitidos","Guardar",true,viewMode,null,null,"onClick=\"javascript:saveMedRelevantesOmitidos()\"")%>
			</td>
		</tr>
		<%=fb.hidden("codigo_med_rel_omi", cdo.getColValue("codigo"))%>
		<%}%>
		
		
		
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else {
	response.setContentType("application/json");
	
	gson = new Gson();
	json = new JsonObject();
	String errCode = "";
	String errMsg = "";
	
	json.addProperty("date", System.currentTimeMillis());
	
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_med_rel_omitidos");
	
	boolean update = false;
	
	if (request.getParameter("codigo").equals("0")) {
		cdo.addColValue("codigo", "(select coalesce(max(codigo),0)+1 from tbl_sal_med_rel_omitidos )");
		cdo.addColValue("pac_id", request.getParameter("pacId"));
	    cdo.addColValue("no_admision", request.getParameter("noAdmision"));	
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion", "sysdate");
	} else {
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and no_admision = "+request.getParameter("noAdmision")+" and codigo = "+request.getParameter("codigo"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modificacion", "sysdate");
		update = true;
	}
	
	cdo.addColValue("medicamentos", request.getParameter("medicamentos"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(update) SQLMgr.update(cdo);
		else SQLMgr.insert(cdo);
		
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();

		if (errCode.equals("1")) {
		  json.addProperty("error", false);
		  json.addProperty("msg", "Los medicamentos relevantes omitidos han sido guardados");
		  if(!update) json.addProperty("force_reload", true);

		} else {
		  response.setStatus(500);
		  json.addProperty("error", true);
		  json.addProperty("msg", errMsg);
		}
	
	ConMgr.clearAppCtx(null);

	out.print(gson.toJson(json));
}
%>