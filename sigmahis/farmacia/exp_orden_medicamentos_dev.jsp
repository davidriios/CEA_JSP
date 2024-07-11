<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="OFarmMgr" scope="session" class="issi.farmacia.OrdenFarmMgr"/>
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
OFarmMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();

String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String noOrden = request.getParameter("noOrden");
String tipo = request.getParameter("tipo");
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String idArticulo = request.getParameter("idArticulo");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String noDev = request.getParameter("noDev");
String admCargo = request.getParameter("admCargo");
String companiaRef = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");
if(companiaRef == null || companiaRef.trim().equals("")) companiaRef = "";
String whFar = java.util.ResourceBundle.getBundle("farmacia").getString("whFar");
if(whFar == null || whFar.trim().equals("")) whFar = "null";
String whHosp = java.util.ResourceBundle.getBundle("farmacia").getString("whHosp");
if(whHosp == null || whHosp.trim().equals("")) whHosp = "null";

if(mode==null) mode="despachar";
if(idArticulo==null) idArticulo="";
if(fg==null) fg="";
if(fp==null) fp="";
if(id==null) id="";
if(noDev==null) noDev="";
if (noOrden == null) noOrden = "";
if (admCargo == null) admCargo = "";

boolean viewMode = false;
if(!mode.equals("despachar")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
	if (tipo == null) tipo = "";
	if (tipo.trim().equalsIgnoreCase("A")) appendFilter += " and a.estado_orden='A'";
	else appendFilter += " and a.estado_orden!='A'";
	//if(!id.trim().equals(""))appendFilter += " and f.id="+id;
	
	
	if (!((issi.admin.Compania) session.getAttribute("_comp")).getHospital().equalsIgnoreCase("S")) throw new Exception("Solo para Compañía Hospital!!");
	String compFar = "";
	try { compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar"); } catch (Exception e) { System.out.println("La Interfaz de Farmacia no está configurada!"); }
	CommonDataObject cdoInt = new CommonDataObject();
	if (!compFar.trim().equals("")) {
	
		sbSql = new StringBuffer();
		sbSql.append("select '['||z.codigo||'] '||z.nombre as intComp, nvl((select '['||codigo||'] '||descripcion from tbl_cds_centro_servicio where codigo = get_sec_comp_param(z.codigo,'CDS_FAR')),'Parámetro CDS_FAR no definido para la Compañía Interfaz') as intCds from tbl_sec_compania z where z.codigo = ");
		sbSql.append(compFar);
		cdoInt = SQLMgr.getData(sbSql.toString());
		
	}

	if(mode.equals("aprobar") || mode.equals("recibir")||mode.equals("rechazar")){sbSql = new StringBuffer();

sbSql.append(" select x.*, (nvl(x.cantidad,0)+nvl(cargos_dev,0)-nvl(x.dev,0)) cantidadNeta,to_char(sysdate,'dd/mm/yyyy')fec_cargo,nvl(x.cantidad,0) -nvl(x.dev_far,0)  cargos_far from (  select f.cod_paciente,to_char(f.fec_nacimiento, 'dd/mm/yyyy')fecha_nacimiento,f.admision,f.pac_id,sum(f.cantidad)as cantidad ,f.codigo_articulo,f.descripcion,f.precio_unitario,f.compania_ref,f.cds_cargo,f.costo,b.nombre_paciente,b.id_paciente as identificacion,z.fecha_ingreso,b.sexo,z.adm_root,f.compania,nvl((select sum(cantidad) from tbl_int_dev_farmacia dev where /* dev.orden_med =f.codigo_orden_med and dev.id_orden=f.orden_med and dev.tipo_orden=f.tipo_orden and*/ dev.pac_id =f.pac_id and dev.adm_cargo=f.adm_cargo and dev.codigo_articulo =f.codigo_articulo and dev.other1 =1 and dev.costo_cargo=f.costo_cargo and dev.cds_hosp=f.cds_hosp /*and dev.estado='D'*/ ),0) dev,nvl((select sum(decode(fdt.tipo_transaccion,'D',decode(fdt.ref_type,null,(fdt.cantidad*-1),0),decode(fdt.ref_type,null,cantidad,0))) from tbl_fac_detalle_transaccion fdt where fdt.pac_id =f.pac_id and fdt.fac_secuencia=f.adm_cargo and f.cod_art_ref =fdt.inv_articulo and fdt.compania =  f.compania_ref  and fdt.centro_servicio=f.cds_hosp and fdt.tipo_cargo=f.tipo_servicio and fdt.costo_art=f.costo_cargo),0) cargos_dev,f.almacen,f.familia,f.clase,f.fg,f.cod_art_ref,f.cod_flia_ref,f.cod_clase_ref,f.tipo_servicio,nvl(f.facturado,'N') as facturado,nvl(f.recargo,0)as recargo /*,f.orden_med as id_orden,f.tipo_orden,f.codigo_orden_med noOrden*/ ,nvl((select sum(cantidad) from tbl_int_dev_farmacia dev where /* dev.orden_med =f.codigo_orden_med and dev.id_orden=f.orden_medand dev.tipo_orden=f.tipo_orden and*/ dev.pac_id =f.pac_id and dev.adm_cargo=f.adm_cargo and dev.codigo_articulo =f.codigo_articulo and dev.other1 =1 and dev.costo_CARGO=f.costo_cargo and dev.cds_hosp=f.cds_hosp ),0) dev_far,f.precio_venta,f.costo_cargo,f.porc_itbm,round((f.tot_itbm/f.cantidad),4) as tot_itbm,f.tipo_cargo_pos, f.cds_hosp,f.adm_cargo,f.wh_hosp from tbl_int_orden_farmacia f ,vw_adm_paciente b,tbl_adm_admision z where   f.fg ='ME' and f.no_cargo is not null   ");

//and f.fecha_cargo >= to_date('30/09/2012','dd/mm/yyyy')  and f.fecha_cargo <= to_date('30/09/2013','dd/mm/yyyy')
	sbSql.append(" and f.pac_id="); 
	sbSql.append(pacId);
	if (!admCargo.trim().equals("")){ sbSql.append(" and f.adm_cargo=");sbSql.append(admCargo);
	}
	else{sbSql.append(" and f.admision=");
	sbSql.append(noAdmision);
	
	}
	//sbSql.append(" and f.admision=z.secuencia ");
	
	if(!noOrden.trim().equals("")&&fg.trim().equals("MEEXP")){sbSql.append(" and f.codigo_orden_med = ");
	sbSql.append(noOrden);}
	sbSql.append(" and f.adm_cargo=z.secuencia ");
sbSql.append(" and z.estado not in ('I','N') and f.pac_id =b.pac_id  and f.pac_id =z.pac_id having sum(f.cantidad) <> 0 group by f.adm_cargo, f.precio_venta,f.costo_cargo,f.porc_itbm,round((f.tot_itbm/f.cantidad),4),f.cod_paciente,to_char(f.fec_nacimiento, 'dd/mm/yyyy'), f.admision,f.pac_id,f.codigo_articulo, f.precio_unitario,f.compania_ref,f.cds_cargo,f.costo,f.tipo_cargo_pos ,b.nombre_paciente,b.id_paciente, z.fecha_ingreso,b.sexo,z.adm_root, f.compania,f.almacen,f.wh_hosp,f.familia,f.clase, f.fg,f.cod_art_ref,f.cod_flia_ref,f.cod_clase_ref,f.tipo_servicio,f.facturado,f.descripcion,nvl(f.recargo,0) /*,f.orden_med,f.tipo_orden,f.codigo_orden_med*/, f.cds_hosp) x  where (nvl(cantidad,0)+nvl(cargos_dev,0)-nvl(dev,0))>0 order by codigo_articulo desc");

	al = SQLMgr.getDataList(sbSql.toString());
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Medicamentos Activos - '+document.title;
function doAction(){}
function selArticle(i){abrir_ventana2('../inventario/sel_articles_farmacia.jsp?fp=medicamentos&index='+i+'&idArticulo=<%=idArticulo%>');}
function chkCant(){var afecta_inv ='';var size = <%=al.size()%>;var cant = 0;var err = 0;var art = '';
var cantCk=0;

for(i=0;i<size;i++){

cant = eval('document.form1.cantidad'+i).value;
art = eval('document.form1.codigo_articulo'+i).value;
afecta_inv = eval('document.form1.afecta_inv'+i).value;


if(cant!=0 && art == ''){alert('Seleccione artículo!');err++;break;}
if(cant<0){alert('Cantidad Invalida');err++;break;}
if(eval('document.form1.chk'+i).checked ==true){
if(cant==''){alert('Introduzca Cantidad!');err++;break;}
if(cant==0 && (eval('document.form1.observacion'+i).value).trim()==''){alert('Introduzca Observacion');err++;break;}
if(err==0)cantCk ++;
}
var wh=''
 
wh =eval('document.form1.codigoAlmacen'+i).value
if(wh.trim()==''){alert('Almacen Invalido');err++;break;}
if(cant!=0 && art == ''){alert('Seleccione artículo!');err++;break;}
}
if(err==0){if(cantCk!=0)return true;else{alert('No hay registros seleccionados'); return false;}}else return false;
}

function checkDespachar(k)
{<%if(mode.trim().equals("despachar")){%>
if(eval('document.form1.chk'+k).checked ==true)
{
 eval('document.form1.cantidad'+k).className = "FormDataObjectRequired";
 
}else {eval('document.form1.cantidad'+k).className = "FormDataObjectDesabled";}
<%}%>	
}
function checkCantidad(k)
{ 
 	var cantidad = eval('document.form1.cantidad'+k).value;
	var cantidadFar = eval('document.form1.cantidadFar'+k).value;
	var cantidadNeta = eval('document.form1.cantidadNeta'+k).value;
	if(cantidad!='0' && cantidad!='' && parseInt(cantidad)>0)
	{
	  if((parseInt(cantidad)> parseInt(cantidadNeta)) || (parseInt(cantidad)> parseInt(cantidadFar))){eval('document.form1.chk'+k).checked =false;alert('La cantidad a devolver no puede ser mayor a la cantidad Recibida. Favor Verifique!!!!');eval('document.form1.cantidad'+k).value="";}
	  else {eval('document.form1.chk'+k).checked =true;}
	}
	else{ alert('Introduzca cantidad valida. Verifique!!!');eval('document.form1.chk'+k).checked =false;}
 }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MEDICAMENTOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
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
		<tr class="TextRowWhite">
			<td colspan="4" width="100%">
			<jsp:include page="../common/ialert.jsp" flush="true">
			<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="displayArea" value="expediente"></jsp:param>
			<jsp:param name="admision" value="<%=noAdmision%>"></jsp:param>
			</jsp:include>
			</td>
		</tr>
		</table>
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");
String colspan = "10";
if(mode.equals("despachar")) colspan = "10";
%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size", ""+al.size())%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("idArticulo",idArticulo)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>

		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<% if (cdoInt != null) { %>
		<tr class="TextHeader">
			<td colspan="5"><cellbytelabel>CIA. INTERFAZ</cellbytelabel>: <%=cdoInt.getColValue("intComp")%></td>
			<td colspan="2" align="right"><cellbytelabel>CDS INTERFAZ</cellbytelabel>: <%=cdoInt.getColValue("intCds")%></td>
		</tr>
		<% } %>
		<tr class="TextHeader">
			<td colspan="7" align="center"><cellbytelabel id="1">Listado de Medicamentos Entregados</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="4%"><cellbytelabel id="2">Adm. Cargo</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Cant. Neta</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Cantidad</cellbytelabel></td>
			<td width="37%"><cellbytelabel id="3">Medicamento</cellbytelabel></td>
			<td width="37%"><cellbytelabel id="8">Observaci&oacute;n</cellbytelabel></td>
			<td width="2%">&nbsp;</td> 
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("nombre"+i, cdo.getColValue("nombre"))%>
	<%=fb.hidden("pac_id"+i, cdo.getColValue("pac_id"))%>
	<%=fb.hidden("cod_paciente"+i, cdo.getColValue("cod_paciente"))%>
	<%=fb.hidden("fec_nacimiento"+i, cdo.getColValue("fecha_nacimiento"))%>
	<%=fb.hidden("admision"+i, cdo.getColValue("admision"))%>
	<%=fb.hidden("adm_cargo"+i, cdo.getColValue("adm_cargo"))%>	
	<%=fb.hidden("noOrden"+i, cdo.getColValue("noOrden"))%>
	<%=fb.hidden("precio_unitario"+i, cdo.getColValue("precio_unitario"))%>
	<%=fb.hidden("precio_subtotal"+i, cdo.getColValue("precio_subtotal"))%>
	<%=fb.hidden("afecta_inv"+i, cdo.getColValue("afecta_inv"))%>
	<%=fb.hidden("cds_cargo"+i, cdo.getColValue("cds_cargo"))%>
	<%=fb.hidden("cds_hosp"+i, cdo.getColValue("cds_hosp"))%>
	<%=fb.hidden("almacen"+i, cdo.getColValue("almacen"))%>
	<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
	<%=fb.hidden("idDev"+i, cdo.getColValue("idDev"))%>
	<%=fb.hidden("costo"+i, cdo.getColValue("costo"))%>
	<%//=fb.hidden("fecha_cargo"+i, cdo.getColValue("fec_cargo"))%>
	<%=fb.hidden("cantidadNeta"+i, cdo.getColValue("cantidadNeta"))%>
	<%=fb.hidden("familia"+i, cdo.getColValue("familia"))%>
	<%=fb.hidden("clase"+i, cdo.getColValue("clase"))%>
	<%=fb.hidden("fg"+i, cdo.getColValue("fg"))%>
	<%=fb.hidden("cod_art_ref"+i, cdo.getColValue("cod_art_ref"))%>
	<%=fb.hidden("cod_flia_ref"+i, cdo.getColValue("cod_flia_ref"))%>
	<%=fb.hidden("cod_clase_ref"+i, cdo.getColValue("cod_clase_ref"))%>
	<%=fb.hidden("tipo_servicio"+i, cdo.getColValue("tipo_servicio"))%>
	<%=fb.hidden("facturado"+i, cdo.getColValue("facturado"))%>
	<%=fb.hidden("compania"+i, cdo.getColValue("compania"))%>
	<%=fb.hidden("compania_ref"+i, cdo.getColValue("compania_ref"))%>
	<%=fb.hidden("itbm"+i, cdo.getColValue("itbm"))%>
	<%=fb.hidden("recargo"+i, cdo.getColValue("recargo"))%>
	<%=fb.hidden("id_orden"+i, cdo.getColValue("id_orden"))%>
	<%=fb.hidden("tipo_orden"+i, cdo.getColValue("tipo_orden"))%>
	<%=fb.hidden("cantidadFar"+i, cdo.getColValue("cantidad"))%>
	<%=fb.hidden("precio_venta"+i, cdo.getColValue("precio_venta"))%>
	<%=fb.hidden("costo_cargo"+i, cdo.getColValue("costo_cargo"))%>
	<%=fb.hidden("porc_itbm"+i, cdo.getColValue("porc_itbm"))%>
	<%=fb.hidden("tot_itbm"+i, cdo.getColValue("tot_itbm"))%>
	<%=fb.hidden("tipo_cargo_pos"+i, cdo.getColValue("tipo_cargo_pos"))%>	
	<%=fb.hidden("wh_hosp"+i, cdo.getColValue("wh_hosp"))%>
 		<tr class="<%=color%>">
			<td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="<%="fecha_cargo"+i%>" />
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fec_cargo")%>" />
									</jsp:include></td>
									
			<td align="center"><%=cdo.getColValue("adm_cargo")%></td>
			<td align="right"><%=cdo.getColValue("cantidadNeta")%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,"",false,false,false,10,"text10",null,"onChange=\"javascript:checkCantidad("+i+")\"")%></td>
			<td><%=fb.intBox("codigo_articulo"+i,cdo.getColValue("codigo_articulo"),false,false,true,12,"text10",null,"")%>
			<%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,50,"text10",null,"")%>
			<%=fb.button("buscar","...",false,true,"","","onClick=\"javascript:selArticle("+i+")\"")%>
			</td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,60,3,"text10",null,"")%></td>
			<td><%=fb.checkbox("chk"+i,""+i,(mode.equals("aprobar"))?false:true,false,"text10",null,"onClick=\"javascript:checkCantidad("+i+")\"")%></td>
	</tr>
<%
}	fb.appendJsValidation("if(!chkCant())error++;");

%>
	<tr class="TextRow02">
			<td colspan="6" align="right">
				<%//=fb.submit("save","Guardar",true,false,null,null,"")%>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
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

	int size = Integer.parseInt(request.getParameter("size"));
	al.clear();
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("id", request.getParameter("id"+i));
		cdo.addColValue("pac_id", request.getParameter("pac_id"+i));
		cdo.addColValue("cod_paciente", request.getParameter("cod_paciente"+i));
		cdo.addColValue("fec_nacimiento", request.getParameter("fec_nacimiento"+i));
		cdo.addColValue("admision", request.getParameter("admision"+i));
		cdo.addColValue("orden_med", request.getParameter("noOrden"+i));
		cdo.addColValue("nombre", request.getParameter("nombre"+i));
		cdo.addColValue("cds_cargo", request.getParameter("cds_cargo"+i));
		cdo.addColValue("cds_hosp", request.getParameter("cds_hosp"+i));
		cdo.addColValue("costo", request.getParameter("costo"+i));
		cdo.addColValue("fecha_cargo", request.getParameter("fecha_cargo"+i));
		cdo.addColValue("familia", request.getParameter("familia"+i));
		cdo.addColValue("clase", request.getParameter("clase"+i));
		cdo.addColValue("fg", request.getParameter("fg"+i));
		cdo.addColValue("cod_art_ref", request.getParameter("cod_art_ref"+i));
		cdo.addColValue("cod_flia_ref", request.getParameter("cod_flia_ref"+i));
		cdo.addColValue("cod_clase_ref", request.getParameter("cod_clase_ref"+i));
		cdo.addColValue("tipo_servicio", request.getParameter("tipo_servicio"+i));
		cdo.addColValue("facturado", request.getParameter("facturado"+i));
		//cdo.addColValue("codigo_orden_med", request.getParameter("codigo_orden_med"+i));
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", request.getParameter("compania"+i));
		cdo.addColValue("compania_ref",request.getParameter("compania_ref"+i));
		//cdo.addColValue("itbm",request.getParameter("itbm"+i));
		cdo.addColValue("recargo",request.getParameter("recargo"+i));
		cdo.addColValue("id_orden",request.getParameter("id_orden"+i));
		cdo.addColValue("tipo_orden",request.getParameter("tipo_orden"+i)); 
		cdo.addColValue("precio_venta",request.getParameter("precio_venta"+i)); 
		cdo.addColValue("costo_cargo",request.getParameter("costo_cargo"+i)); 
		cdo.addColValue("porc_itbm",request.getParameter("porc_itbm"+i)); 
		cdo.addColValue("tot_itbm",request.getParameter("tot_itbm"+i));
		cdo.addColValue("tipo_cargo_pos",request.getParameter("tipo_cargo_pos"+i));
		cdo.addColValue("adm_cargo",request.getParameter("adm_cargo"+i));

		if(request.getParameter("almacen"+i)!=null && !request.getParameter("almacen"+i).trim().equals(""))
		cdo.addColValue("wh_far",request.getParameter("almacen"+i));
		if(request.getParameter("wh_hosp"+i)!=null && !request.getParameter("wh_hosp"+i).trim().equals(""))
		cdo.addColValue("wh_hosp",request.getParameter("wh_hosp"+i));
		else cdo.addColValue("wh_hosp",whHosp);

		cdo.addColValue("mode",mode);
		if(request.getParameter("fp")==null||request.getParameter("fp").trim().equals(""))cdo.addColValue("fp","");
		else cdo.addColValue("fp",request.getParameter("fp"));
 
			if(request.getParameter("codigo_articulo"+i)!=null && !request.getParameter("codigo_articulo"+i).equals("")) cdo.addColValue("codigo_articulo", request.getParameter("codigo_articulo"+i));
			if(request.getParameter("descripcion"+i)!=null && !request.getParameter("descripcion"+i).equals("")) cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
			if(request.getParameter("precio_unitario"+i)!=null && !request.getParameter("precio_unitario"+i).equals("")) cdo.addColValue("precio_unitario", request.getParameter("precio_unitario"+i));
			if(request.getParameter("precio_subtotal"+i)!=null && !request.getParameter("precio_subtotal"+i).equals("")) cdo.addColValue("precio_subtotal", ""+(Double.parseDouble(request.getParameter("precio_unitario"+i)) * Double.parseDouble(request.getParameter("cantidad"+i))));
 
		if(mode.equals("aprobar"))
		{
			cdo.addColValue("estado", "D");
			if(request.getParameter("observacion"+i)!=null && !request.getParameter("observacion"+i).equals("")) cdo.addColValue("observacion", request.getParameter("observacion"+i));
			//cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			//if(request.getParameter("chk"+i)!=null){ cdo.addColValue("estado", "A");}//
			//cdo.addColValue("gen_cargo", "S");}
			//else{ cdo.addColValue("estado", "P");cdo.addColValue("gen_cargo", "N");}
						
			if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).trim().equals("")&& request.getParameter("cantidad"+i).trim().equals("0")){
			cdo.addColValue("estado", "R");
			cdo.addColValue("other1", "0");cdo.addColValue("gen_cargo", "N");}
			
		} else if(mode.equals("rechazar")){
			//cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			if(request.getParameter("chk"+i)!=null)cdo.addColValue("estado", "I");
			else cdo.addColValue("estado", "P");
		}else if(mode.equals("recibir")){
			//cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			cdo.addColValue("cds_recibido_user", (String) session.getAttribute("_userName"));
			cdo.addColValue("cds_recibido_cantidad", request.getParameter("cantidad"+i));
			cdo.addColValue("cds_observacion", request.getParameter("observacion"+i));
			if(request.getParameter("chk"+i)!=null){
				cdo.addColValue("estado", "R");
				cdo.addColValue("cds_recibido", "S");
			} else {
				cdo.addColValue("estado", "A");
				cdo.addColValue("cds_recibido", "N");
			}
		}
		if(mode.equals("aprobar")||mode.equals("recibir")){if(request.getParameter("chk"+i)!=null)al.add(cdo);}
		else al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"session company id = "+session.getAttribute("_companyId"));
   if(mode.equals("aprobar")){
	OFarmMgr.devolver(al);
	noDev = OFarmMgr.getPkColValue("no_dev");
	} else if(mode.equals("recibir")){
		//OFarmMgr.recibir(al);
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
closeChild=false;
function closeWindow()
{
	<%
	if (OFarmMgr.getErrCode().equals("1")){
	%>
	alert('<%=OFarmMgr.getErrMsg()%>');
abrir_ventana2('../farmacia/print_dev_medicamentos.jsp?fg=FAR&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&docId=<%=noDev%>&admCargo=<%=admCargo%>');
	window.close();
<%} else throw new Exception(OFarmMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>