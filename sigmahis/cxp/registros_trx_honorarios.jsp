<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" /> 
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
 
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String key = "";
StringBuffer sbSql =new StringBuffer();
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String documento = request.getParameter("documento");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String fechaDesde = request.getParameter("fechaDesde");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String hora = "";
String codigo = request.getParameter("codigo");
String tipo = request.getParameter("tipo");
String pagar = request.getParameter("pagar");
String boleta = request.getParameter("boleta");
String nombre = request.getParameter("nombre");
String cta_cancelada = request.getParameter("cta_cancelada");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(fecha == null) fecha ="";
if(fechaDesde == null) fechaDesde = "";
if(documento==null) documento = "";
if(tipo==null) tipo = "";
if(codigo==null) codigo = "";
if(pagar==null) pagar = "";
if(boleta==null) boleta = "";
if(nombre==null) nombre = "";
if(fg==null) fg = "";
if(fp==null) fp = "";
if(cta_cancelada==null)cta_cancelada="";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){

	sbSql.append("select tipo, codigo, nombre, tipo_persona, monto, ajuste, totales, retencion, totales - nvl(retencion, 0) total, ach, medico, (case when medico is null and empresa = 'S' then 'S' end) empresa, centro, (case when centro = 'S' then (select ruc from tbl_cds_centro_servicio where codigo = b.codigo) when empresa = 'S' and medico is null then (select ruc from tbl_adm_empresa where codigo = b.codigo) when medico = 'S' then (select identificacion from tbl_adm_medico where codigo = b.codigo) end) ruc, (case when centro = 'S' then (select dv from tbl_cds_centro_servicio where codigo = b.codigo) when empresa = 'S' and medico is null then (select digito_verificador from tbl_adm_empresa where codigo = b.codigo) when medico = 'S' then (select digito_verificador from tbl_adm_medico where codigo = b.codigo) end) dv,nvl(getSaldoHon(b.compania, '");
	sbSql.append(fecha);
	sbSql.append("', b.codigo, b.tipo),0) as saldoFinal, coalesce(cod_real_med_bk, codigo) cod_real_med_bk, coalesce(nombre_2, nombre) nombre_cargo,pagar,boleta,id ,id_det,odp_tipo,odp_numero,odp_anio from (select a.*, (case when tipo in ('H') and exists (select 1 from tbl_adm_medico where codigo = a.codigo) then 'S' end) medico, (case when tipo in ('E') and exists (select 1 from tbl_adm_empresa where to_char(codigo) = a.codigo) then 'S' end) empresa, (case when tipo in ('C') and exists (select 1 from tbl_cds_centro_servicio where codigo = a.codigo) then 'S' end) centro from (select   tipo , h.cod_medico as codigo,nvl(getNombreHon(h.cod_medico,h.tipo,'','HON'),' ') as nombre, h.cod_real_med_bk, getNombreHon (decode(h.cod_medico, h.cod_real_med_bk, h.cod_medico, h.cod_real_med_bk), decode(h.cod_medico, h.cod_real_med_bk, h.tipo, 'H'), '', 'HON') AS nombre_2, tipo_persona,  (nvl (monto, 0)) monto,  (nvl (monto_ajuste, 0)) ajuste,  (nvl (monto, 0)) +  (nvl (monto_ajuste, 0)) totales, (nvl (retencion, 0)) retencion, null as ach,h.compania,nvl(h.pagar,'S') as pagar, h.boleta,h.id ,h.id_det,h.odp_tipo,h.odp_numero,h.odp_anio  from tbl_cxp_hon_det h where compania = ");
	
	sbSql.append(session.getAttribute("_companyId"));
	if(!codigo.trim().equals("")){sbSql.append(" and h.cod_medico='");sbSql.append(codigo);sbSql.append("'");}
	if(!tipo.trim().equals("")){sbSql.append(" and h.tipo='");sbSql.append(tipo);sbSql.append("'");}
	if(!fecha.trim().equals("")){sbSql.append(" and trunc(h.fecha) <= to_date('");sbSql.append(fecha);sbSql.append("', 'dd/mm/yyyy')");}
	if(!fechaDesde.trim().equals("")){sbSql.append(" and trunc(h.fecha) >= to_date('");sbSql.append(fechaDesde);sbSql.append("', 'dd/mm/yyyy')");}
	if(!pagar.trim().equals("")){if(!pagar.trim().equals("X")){sbSql.append(" and h.pagar ='");sbSql.append(pagar); sbSql.append("' ");}else{ sbSql.append(" and h.odp_tipo='M'  "); }}
	if(!boleta.trim().equals("")){sbSql.append(" and h.boleta ='");sbSql.append(boleta); sbSql.append("' ");}
	if(cta_cancelada.equals("S")/*||cta_cancelada.equals("N")*/){
		sbSql.append(" and exists (select null from tbl_fac_factura f where f.compania = h.compania and f.codigo = h.factura AND NVL(fn_cja_saldo_fact(f.facturar_a, f.compania, f.codigo, f.grang_total), -1) ");
		if(cta_cancelada.equals("S"))sbSql.append(" = 0 ");
		else if(cta_cancelada.equals("N"))sbSql.append(" <> 0 ");
		sbSql.append(" ) ");
	}
	
 sbSql.append(" and decode(monto_ajuste, null, 0, codigo_paciente) = 0 ");
 if(!pagar.trim().equals("X"))sbSql.append(" and h.odp_numero is null ");
 sbSql.append(" /*group by h.odp_numero,h.odp_anio,h.odp_tipo, nvl(h.pagar,'S'),h.boleta,h.id,h.id_det,h.cod_medico,h.cod_real_med_bk, tipo, tipo_persona, compania having sum (nvl (monto, 0)) + sum (nvl (monto_ajuste, 0)) > 0 */ ) a) b");
 	if(!nombre.trim().equals("")){sbSql.append(" where nombre like '%");sbSql.append(nombre); sbSql.append("%' ");}

  sbSql.append(" order by nombre asc");

	if(request.getParameter("codigo") !=null){
	al = SQLMgr.getDataList(sbSql.toString());
	
	}
 
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doSubmit(value){document.orden_pago.action.value = value;document.orden_pago.submit();}
function reloadPage(){var fecha = '';if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value;
var pagar ='';if(document.orden_pago.pagar)pagar=document.orden_pago.pagar.value;
var nombre ='';if(document.orden_pago.nombre)nombre=document.orden_pago.nombre.value;
window.location = '../cxp/registros_trx_honorarios.jsp?fg=<%=fg%>&fecha='+fecha+'&fechaDesde='+fechaDesde+'&codigo='+document.orden_pago.codigo.value+'&pagar='+pagar+'&boleta='+document.orden_pago.boleta.value+'&tipo='+document.orden_pago.tipo.value+'&nombre='+nombre;}
function setAll(){var size = document.orden_pago.keySize.value;for(i=0;i<size;i++){


if(eval('document.orden_pago.codigo'+i).value!=eval('document.orden_pago.cod_real_med_bk'+i).value){if(eval('document.orden_pago.medicoCargo'+i))eval('document.orden_pago.medicoCargo'+i).checked = document.orden_pago.medicoCargo.checked;}}}
 </script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="HONORARIOS MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0"  id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("orden_pago",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("hora",""+hora)%>
		<tr class="TextPanel">
			<td colspan="8"><cellbytelabel>HONORARIOS MEDICOS</cellbytelabel></td>
		</tr>
		<tr class="TextFilter">
			<td align="right" colspan="8"> 
			<%if(!fg.trim().equals("ORD")){%>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fechaDesde" />
				<jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
				<jsp:param name="nameOfTBox2" value="fecha" />
				<jsp:param name="valueOfTBox2" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				Tipo <%=fb.select("tipo","H=MEDICO,E=SOCIEDAD",tipo)%>
				Cod. Hon. <%=fb.textBox("codigo",codigo,false,false,false,10)%>
				Nombre <%=fb.textBox("nombre",nombre,false,false,false,10)%>								
				Pagar
				<%=fb.select("pagar","S=SI,N=NO,X=CORREGIR NO. ORDEN",pagar,"S")%>&nbsp;&nbsp;   																
			<%}else{%>								
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("pagar","")%>
				<%=fb.hidden("fechaDesde",fechaDesde)%>
				<%=fb.hidden("fecha",fecha)%>
			<%}%>
				Boleta <%=fb.textBox("boleta",boleta,false,false,false,10)%>&nbsp;&nbsp;&nbsp;</br>
				<%=fb.button("consultar","Consultar",true,viewMode,"","","onClick=\"javascript:reloadPage();\"")%>
				<authtype type='6'><%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%></authtype>
				<%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
		<tr>
			<td colspan="8">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!--<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
<div id="list_op" width="100%" style="overflow;position:absolute">-->
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader02" >
					<td align="center" width="2%"><%=fb.checkbox("chk_All","", false, false, "", "", "onClick=\"javascript:checkAll('"+fb.getFormName()+"','generar',"+al.size()+",this);\"")%></td>
					<td align="center" width="9%"><cellbytelabel>C&oacute;d. Medico</cellbytelabel></td>
					<td align="center" width="25%"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td align="center" width="25%"><cellbytelabel>Med. Cargo</cellbytelabel></td>
					<td align="center" width="10%"><cellbytelabel>Boleta</cellbytelabel></td>
					<td align="center" width="9%"><cellbytelabel>Monto</cellbytelabel></td>  
					<td align="center" width="8%"><cellbytelabel>Año Ord Pago</cellbytelabel></td>
					<td align="center" width="10%"><cellbytelabel>No. Ord Pago</cellbytelabel></td>  
					<td align="center" width="2%"><%=fb.checkbox("medicoCargo","", false, false, "", "", "onClick=\"javascript:setAll();\"","CAMBIAR BENEFICIARIO A MEDICO DEL CARGO")%></td>
				</tr>
<%
double total =0.00;
for (int i=0; i<al.size(); i++){
CommonDataObject OP = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("boleta"+i,OP.getColValue("boleta"))%>
<%=fb.hidden("id"+i,OP.getColValue("id"))%> 
<%=fb.hidden("id_det"+i,OP.getColValue("id_det"))%> 
<%=fb.hidden("codigo"+i,OP.getColValue("codigo"))%>
<%=fb.hidden("nombre"+i,OP.getColValue("nombre"))%>
<%=fb.hidden("monto"+i,OP.getColValue("monto"))%> 
<%=fb.hidden("tipo"+i,OP.getColValue("tipo"))%>
<%=fb.hidden("pagarOld"+i,OP.getColValue("pagar"))%> 
<%=fb.hidden("cod_real_med_bk"+i,OP.getColValue("cod_real_med_bk"))%>
<%=fb.hidden("odp_tipo"+i,OP.getColValue("odp_tipo"))%>  
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
					<td align="center"><%=fb.checkbox("generar"+i,""+i,(OP.getColValue("pagar").equalsIgnoreCase("S")),false,null,null,"","EXCLUIR REGISTRO DEL LISTADO DE BOLETAS A PAGAR")%></td>
					<td align="center"><%=OP.getColValue("codigo")%> </td>
					<td align="left"><%=OP.getColValue("nombre")%></td> 
					<td align="left"><%if(!OP.getColValue("cod_real_med_bk").equals(OP.getColValue("codigo"))){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold"><%}%>&nbsp;&nbsp;[<%=OP.getColValue("cod_real_med_bk")%>]&nbsp;-&nbsp;<%=OP.getColValue("nombre_cargo")%>&nbsp;&nbsp;<%if(OP.getColValue("cod_real_med_bk").equals(OP.getColValue("codigo"))){%></label></label><%}%>&nbsp;</td> 
					<td align="center"><%=OP.getColValue("boleta")%></td>
					<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(OP.getColValue("total"))%>&nbsp;&nbsp;</td>
					<td align="right"><authtype type='50'><%=fb.intBox("odp_anio"+i,(pagar.trim().equals("X"))?OP.getColValue("odp_anio"):"",false,false,false,4,4,"text10",null,"","",false,"")%></authtype></td>
					<td align="right"><authtype type='50'><%=fb.intBox("odp_numero"+i,(pagar.trim().equals("X"))?OP.getColValue("odp_numero"):"",false,false,false,6,6,"text10",null,"","",false,"")%></authtype></td>
					<td align="center"><%if(!OP.getColValue("cod_real_med_bk").equals(OP.getColValue("codigo"))){%><%=fb.checkbox("medicoCargo"+i,""+i,false,false,null,null,"","CAMBIAR BENEFICIARIO A MEDICO DEL CARGO")%><%}%></td>
				</tr>
<%
total += Double.parseDouble(OP.getColValue("total"));
}%>
<%=fb.hidden("keySize",""+al.size())%>
				<tr class="TextHeader02" >
					<td colspan="5" align="right">&nbsp;TOTAL: </td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>  
					<td colspan="3">&nbsp;</td>
				</tr>
				</table>
</div>
</div>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	al = new ArrayList();
	String fecha_solicitud = CmnMgr.getCurrentDate("dd/mm/yyyy"); 
	for(int i=0;i<keySize;i++){ 
 		//if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_cxp_hon_det");
            cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and id="+request.getParameter("id"+i)+" and id_det="+request.getParameter("id_det"+i));

			//cdo.addColValue("compania", (String) session.getAttribute("_companyId")); 
			
			//cdo.addColValue("id", request.getParameter("id"+i));
			if((request.getParameter("odp_anio"+i)!=null && !request.getParameter("odp_anio"+i).trim().equals("")&&request.getParameter("odp_numero"+i)!=null && !request.getParameter("odp_numero"+i).trim().equals(""))|| request.getParameter("pagar").trim().equals("X"))
			{
				cdo.addColValue("odp_anio", request.getParameter("odp_anio"+i));
				cdo.addColValue("odp_numero", request.getParameter("odp_numero"+i));
				if(request.getParameter("odp_anio"+i)!=null && !request.getParameter("odp_anio"+i).trim().equals(""))cdo.addColValue("odp_compania",(String) session.getAttribute("_companyId"));
				else cdo.addColValue("odp_compania","");
				if(request.getParameter("odp_tipo"+i)!=null && !request.getParameter("odp_tipo"+i).trim().equals(""))
				cdo.addColValue("odp_tipo", request.getParameter("odp_tipo"+i));
				else cdo.addColValue("odp_tipo","M");
			}
			
			if(request.getParameter("generar"+i)==null)cdo.addColValue("pagar","N");
			else cdo.addColValue("pagar","S");
			
			if(request.getParameter("medicoCargo"+i)!=null)
			{
				if(!request.getParameter("cod_real_med_bk"+i).trim().equals(request.getParameter("codigo"+i)))
				{
			 	cdo.addColValue("cod_medico",request.getParameter("cod_real_med_bk"+i));
				cdo.addColValue("comentario","SE CAMBIA HONORARIO BENEFICIARIO : "+request.getParameter("codigo"+i)+" POR EL MEDICO DEL CARGO "+request.getParameter("cod_real_med_bk"+i));		
				cdo.addColValue("tipo","H");
				}	
			}
			//cdo.addColValue("id_det", request.getParameter("id_det"+i));
			cdo.addColValue("usuario_mod", (String) session.getAttribute("_userName")); 
			cdo.addColValue("fecha_mod","sysdate"); 
			cdo.setAction("U"); 
			
			al.add(cdo);
 	}
	if (request.getParameter("action").equals("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	<%if(fg.trim().equals("ORD")){%>parent.hidePopWin(false);
	parent.window.location.reload(true);<%}else{%>
	window.location = '<%=request.getContextPath()%>/cxp/registros_trx_honorarios.jsp?fecha=<%=request.getParameter("fecha")%>&fechaDesde=<%=request.getParameter("fechaDesde")%>&pagar=<%=pagar%>&fg=<%=fg%>';
<%}
} else throw new Exception(SQLMgr.getErrException());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
