<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.StringTokenizer" %>
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
CommonDataObject cdoP = new CommonDataObject();

String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String admCargo = request.getParameter("admCargo");
String noOrden = request.getParameter("noOrden");
String tipo = request.getParameter("tipo");
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String idArticulo = request.getParameter("idArticulo");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String noDev = request.getParameter("noDev");
String validaCja = request.getParameter("validaCja");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
String docId="";
String docNo ="";
String trxId="";
String ruc="";
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
if(admCargo==null) admCargo="";

if(turno==null) turno="";
if(validaCja==null) validaCja="N";
if(caja==null) caja="";
boolean viewMode = false;
if(!mode.equals("despachar")) viewMode = true;
sbSql = new StringBuffer();
	sbSql.append("select  nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_GENERAR_TRX_POS'),'N') as v_far_generar_pos  from dual");
	cdoP = SQLMgr.getData(sbSql.toString());
	if (cdoP == null) {
		cdoP = new CommonDataObject();
		cdoP.addColValue("v_far_generar_pos","S");
	}
	sbSql = new StringBuffer();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
	if(mode.trim().equals("aprobar") && validaCja.trim().equals("S") && turno.trim().equals(""))throw new Exception("No ha Definido Caja O No tiene turno Creado. Por Favor Consulte con su administrador !");
	if (tipo == null) tipo = "";
	if(mode.equals("aprobar") || mode.equals("recibir")||mode.equals("rechazar")){sbSql = new StringBuffer();

sbSql.append(" select f.id,f.cod_paciente,to_char(f.fec_nacimiento, 'dd/mm/yyyy')fecha_nacimiento,f.admision,f.pac_id,f.cantidad,f.codigo_articulo,f.descripcion,f.precio_unitario,f.orden_med,f.orden_med  as noOrden,f.compania_ref,f.cds_cargo,f.costo, to_char(f.fecha_cargo,'dd/mm/yyyy')as fec_cargo,trunc(f.fecha_cargo)as fecha_cargo,b.nombre_paciente,b.id_paciente as identificacion,z.fecha_ingreso,b.sexo,z.adm_root,f.compania,f.almacen,f.observacion,f.estado,f.other1,f.fg,f.recargo,decode(f.estado,'D','DEVOLVER','R','RECIBIDO','I','RECHAZADO')descEstado ,nvl(( select nvl(sum(decode(fdt.tipo_transaccion,'D',(cantidad*-1),cantidad)),0)  cargos_neto from tbl_fac_detalle_transaccion fdt where fdt.pac_id = f.pac_id and fdt.fac_secuencia = f.admision and fdt.inv_articulo = f.cod_art_ref and fdt.compania = f.compania_ref and fdt.tipo_cargo = f.tipo_servicio and fdt.centro_servicio = f.cds_hosp),0)cantidadNeta ,nvl((select cod_barra from tbl_inv_articulo where cod_articulo =f.codigo_articulo and compania=f.compania),'') as cod_barra,nvl(f.facturado,'N') as facturado,f.no_dev from tbl_int_dev_farmacia f ,vw_adm_paciente b,tbl_adm_admision z where ");
	sbSql.append(" f.pac_id=");
	sbSql.append(pacId);
	if(!admCargo.trim().equals("")){sbSql.append(" and f.adm_cargo=");
	sbSql.append(admCargo);}
	else{
	sbSql.append(" and f.admision=");
	sbSql.append(noAdmision);
	}

if(mode.equals("aprobar")){sbSql.append(" and f.estado ='D' and z.estado not in ('I','N') ");}
if(!noDev.trim().equals("")){sbSql.append(" and f.no_dev =");sbSql.append(noDev);}

/*if(!noOrden.trim().equals("")){sbSql.append(" and f.orden_med = ");
	sbSql.append(noOrden);}*/

sbSql.append(" and f.pac_id =b.pac_id  and f.pac_id =z.pac_id and nvl(f.adm_cargo,f.admision)=z.secuencia  order by f.id");

	al = SQLMgr.getDataList(sbSql.toString());
	}



%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Medicamentos Activos - '+document.title;
function doAction(){}
function selArticle(i){abrir_ventana2('../inventario/sel_articles_farmacia.jsp?fp=medicamentosDev&index='+i+'&idArticulo=<%=idArticulo%>');}
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

wh =eval('document.form1.codigoAlmacen'+i).value;
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
		var cantidadOld = eval('document.form1.cantidadSol'+k).value;
		var cantidadNeta= eval('document.form1.cantidadNeta'+k).value;
		if (parseInt(cantidad) > parseInt(cantidadNeta) ){ alert('No puede devolver mas de la Cantidad Cargada en la Cuenta del Paciente');eval('document.form1.cantidad'+k).value="";}
		if (parseInt(cantidad) > parseInt(cantidadOld) ){ alert('No puede devolver mas de la Cantidad Solicitada');eval('document.form1.cantidad'+k).value="";}
}
function printDe(){
window.opener.parent.document.form1.facturar.value='S';
window.opener.parent.document.form1.printDgi.value='N';
	window.opener.parent.document.form1.noDev.value='<%=noDev%>';
	window.opener.parent.document.form1.docId.value='';
	window.opener.parent.document.form1.pacId.value='<%=pacId%>';
	window.opener.parent.document.form1.noAdmision.value='<%=noAdmision%>';

window.opener.parent.doSubmit();

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
<%=fb.hidden("noDev",noDev)%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("validaCja",validaCja)%>
<%=fb.hidden("admCargo",admCargo)%>

		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextHeader">
			<td colspan="6" align="center"><cellbytelabel id="1">Listado de Medicamentos Entregados</cellbytelabel>&nbsp;-&nbsp;<cellbytelabel id="12">ORDEN No</cellbytelabel>.<%=noOrden%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel id="2">No. DEV</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Cantidad</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="3">Medicamento</cellbytelabel></td>
			<td width="35%"><cellbytelabel id="8">Observaci&oacute;n</cellbytelabel></td>
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
	<%=fb.hidden("noOrden"+i, cdo.getColValue("noOrden"))%>
	<%=fb.hidden("precio_unitario"+i, cdo.getColValue("precio_unitario"))%>
	<%=fb.hidden("precio_subtotal"+i, cdo.getColValue("precio_subtotal"))%>
	<%=fb.hidden("afecta_inv"+i, cdo.getColValue("afecta_inv"))%>
	<%=fb.hidden("cds_cargo"+i, cdo.getColValue("cds_cargo"))%>
	<%=fb.hidden("almacen"+i, cdo.getColValue("almacen"))%>
	<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
	<%=fb.hidden("idDev"+i, cdo.getColValue("idDev"))%>
	<%=fb.hidden("costo"+i, cdo.getColValue("costo"))%>
	<%=fb.hidden("fecha_cargo"+i, cdo.getColValue("fec_cargo"))%>
	<%=fb.hidden("cantidadSol"+i, cdo.getColValue("cantidad"))%>
	<%=fb.hidden("cantidadNeta"+i, cdo.getColValue("cantidadNeta"))%>
	<%=fb.hidden("estado"+i, cdo.getColValue("estado"))%>
	<%=fb.hidden("other1"+i, cdo.getColValue("other1"))%>
	<%=fb.hidden("compania"+i, cdo.getColValue("compania"))%>
	<%=fb.hidden("compania_ref"+i, cdo.getColValue("compania_ref"))%>
	<%=fb.hidden("fg"+i, cdo.getColValue("fg"))%>
	<%=fb.hidden("recargo"+i, cdo.getColValue("recargo"))%>
	<%=fb.hidden("facturado"+i, cdo.getColValue("facturado"))%>

		<tr class="<%=color%>">
			<td align="center"><%=cdo.getColValue("no_dev")%></td>
			<td align="center"><%=cdo.getColValue("fec_cargo")%></td>
			<td align="center"><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,false,10,"text10",null,"onChange=\"javascript:checkCantidad("+i+")\"")%><font class="RedTextBold" size="2">Ingrese CERO (0) para Rechazar</font></td>
			<td>Cod. Barra</br>
			<%=fb.textBox("cod_barra"+i,cdo.getColValue("cod_barra"),false,false,true,15,"text10",null,"")%>
			<%=fb.intBox("codigo_articulo"+i,cdo.getColValue("codigo_articulo"),false,false,true,8,"text10",null,"")%>
			<%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,40,"text10",null,"")%>
			<%=fb.button("buscar","...",false,true,"","","onClick=\"javascript:selArticle("+i+")\"")%>
			</td>
			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,45,3,"text10",null,"")%></td>
			<td><%=fb.checkbox("chk"+i,""+i,(mode.equals("aprobar"))?false:true,false,"text10",null,"onClick=\"javascript:checkCantidad("+i+")\"")%></td>
	</tr>
<%
}	fb.appendJsValidation("if(!chkCant())error++;");

%>
	<tr class="TextRow02">
			<td colspan="6" align="right"><%=fb.checkbox("chkRep","",true,false,"text10",null,"")%><cellbytelabel id="1">Imprimir Al Guardar </cellbytelabel>
				<%//=fb.submit("save","Guardar",true,false,null,null,"")%>
				<%=fb.button("btnc","IMRIMIR",true,false,null,null,"onClick=\"javascript:printDe()\"")%>
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
	String idDgi ="";
	int count =0,dgiDocto=0;
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("id", request.getParameter("id"+i));

		cdo.addColValue("codigo", request.getParameter("id"+i));
		cdo.addColValue("pac_id", request.getParameter("pac_id"+i));
		cdo.addColValue("cod_paciente", request.getParameter("cod_paciente"+i));
		cdo.addColValue("fec_nacimiento", request.getParameter("fec_nacimiento"+i));
		cdo.addColValue("admision", request.getParameter("admision"+i));
		if(request.getParameter("noOrden"+i)!=null && !request.getParameter("noOrden"+i).trim().equals(""))
		cdo.addColValue("orden_med", request.getParameter("noOrden"+i));
		else cdo.addColValue("orden_med","null");
		cdo.addColValue("nombre", request.getParameter("nombre"+i));
		cdo.addColValue("cds_cargo", request.getParameter("cds_cargo"+i));
		cdo.addColValue("costo", request.getParameter("costo"+i));
		cdo.addColValue("fecha_cargo", request.getParameter("fecha_cargo"+i));
		cdo.addColValue("docType", "NCR");
		cdo.addColValue("compania", request.getParameter("compania"+i));
		cdo.addColValue("compania_ref",request.getParameter("compania_ref"+i));
		cdo.addColValue("recargo",request.getParameter("recargo"+i));

		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		//cdo.addColValue("compania", (String) session.getAttribute("_companyId"));

		if(request.getParameter("almacen"+i)!=null && !request.getParameter("almacen"+i).trim().equals(""))
		cdo.addColValue("wh_far",request.getParameter("almacen"+i));

		cdo.addColValue("mode",mode);
		if(request.getParameter("fp")==null||request.getParameter("fp").trim().equals(""))cdo.addColValue("fp","");
		else cdo.addColValue("fp",request.getParameter("fp"));

			if(request.getParameter("codigo_articulo"+i)!=null && !request.getParameter("codigo_articulo"+i).equals("")) cdo.addColValue("codigo_articulo", request.getParameter("codigo_articulo"+i));
			if(request.getParameter("descripcion"+i)!=null && !request.getParameter("descripcion"+i).equals("")) cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
			if(request.getParameter("precio_unitario"+i)!=null && !request.getParameter("precio_unitario"+i).equals("")) cdo.addColValue("precio_unitario", request.getParameter("precio_unitario"+i));
			if(request.getParameter("precio_subtotal"+i)!=null && !request.getParameter("precio_subtotal"+i).equals("")) cdo.addColValue("precio_subtotal", ""+(Double.parseDouble(request.getParameter("precio_unitario"+i)) * Double.parseDouble(request.getParameter("cantidad"+i))));
			if(request.getParameter("observacion"+i)!=null && !request.getParameter("observacion"+i).equals(""))cdo.addColValue("observacion",request.getParameter("observacion"+i));
			if (validaCja.equalsIgnoreCase("S") && caja != null && !caja.trim().equals("")) {
				if (caja.contains(",")) cdo.addColValue("other4",caja.substring(0,caja.indexOf(",")));//if multiple then select the first one
				else cdo.addColValue("other4",caja);
			} else cdo.addColValue("other4","0");

			if(request.getParameter("turno")!=null && !request.getParameter("turno").equals("")) cdo.addColValue("other5", request.getParameter("turno"));
			else cdo.addColValue("other5","0");

			cdo.addColValue("v_far_generar_pos",cdoP.getColValue("v_far_generar_pos"));


		if(mode.equals("aprobar"))
		{
			if(request.getParameter("chk"+i)!=null)cdo.addColValue("estado", "R");
			else cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("gen_cargo", "S");
			cdo.addColValue("other1",request.getParameter("other1"+i));

			cdo.addColValue("fp","ME");
			if(request.getParameter("fg"+i).trim().equals("ME")){ cdo.addColValue("fp","FACT");
			if(cdoP.getColValue("v_far_generar_pos").trim().equals("S")&&request.getParameter("facturado"+i).trim().equals("S")) dgiDocto++;

			}
			else{ cdo.addColValue("fp","NOFACT"); }

			if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).trim().equals("")&& request.getParameter("cantidad"+i).trim().equals("0")){
			cdo.addColValue("estado", "I");
			cdo.addColValue("other1", "0");cdo.addColValue("gen_cargo", "N");}else count++;


		}

System.out.println(" v_far_generar_pos========= "+cdo.getColValue("v_far_generar_pos")+" cdoP === "+cdoP.getColValue("v_far_generar_pos"));
		if(mode.equals("aprobar")||mode.equals("recibir")||mode.equals("update")){if(request.getParameter("chk"+i)!=null)al.add(cdo);}
		else al.add(cdo);
	}
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"session company id = "+session.getAttribute("_companyId")+" mode="+mode);
	if(mode.equals("aprobar")){
		OFarmMgr.aprobDevolucion(al);
	if(cdoP.getColValue("v_far_generar_pos").trim().equals("S")){
	if(count >0&& dgiDocto >0 )
	{
		idDgi = OFarmMgr.getPkColValue("dgi_id");
		System.out.println("------------------------------>idDgi="+idDgi);
		try{
			StringTokenizer st = new StringTokenizer(idDgi,"|");
			 docId = st.nextToken();
			 docNo = st.nextToken();
			 trxId=st.nextToken();
			 ruc=st.nextToken();
		}catch(Exception e){System.out.println("Error while processing the DGI ID ["+idDgi+"]. Caused by: "+e.toString());e.printStackTrace();}
	}
		}
	} else if(mode.equals("recibir")){
		//OFarmMgr.recibir(al);
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
	<%
	if (OFarmMgr.getErrCode().equals("1")){
	%>
	alert('<%=OFarmMgr.getErrMsg()%>');


	<%if(mode.equals("aprobar") && count > 0 && dgiDocto >0 ){%>

	window.opener.parent.document.form1.pacId.value='<%=pacId%>';
	window.opener.parent.document.form1.noAdmision.value='<%=noAdmision%>';

	window.opener.parent.document.form1.facturar.value='S';

	window.opener.parent.document.form1.docId.value='<%=docId%>';
	window.opener.parent.document.form1.docNo.value='<%=docNo%>';
	window.opener.parent.document.form1.trxId.value='<%=trxId%>';
	window.opener.parent.document.form1.ruc.value='<%=ruc%>';

	<%if(cdoP.getColValue("v_far_generar_pos").trim().equals("S")){%>
	window.opener.parent.document.form1.printDgi.value='S';
	<%}else{%>
	window.opener.parent.document.form1.printDgi.value='N';
	window.opener.parent.document.form1.noDev.value='<%=noDev%>';
	window.opener.parent.document.form1.docId.value='';
	window.opener.parent.document.form1.docNo.value='';
	<%}%>
	<%}%>
	window.opener.parent.doSubmit();
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