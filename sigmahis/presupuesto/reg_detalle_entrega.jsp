<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="issi.inventory.DeliveryItem"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr"/>
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
PresMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Delivery del = new Delivery();
ArrayList alTipo = new ArrayList();

String sql = "";
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String popWinFunction ="abrir_ventana1";
String unidad = request.getParameter("unidad");

if(fp == null) fp="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	alTipo = sbb.getBeanList(ConMgr.getConnection(),"select tipo_inv as optValueColumn, tipo_inv||' - '||descripcion as optLabelColumn, tipo_inv as optTitleColumn from tbl_con_tipo_inversion where compania ="+(String) session.getAttribute("_companyId")+" order by 2",CommonDataObject.class);

	if (anio == null || no == null) throw new Exception("La Entrega no es válida. Por favor intente nuevamente!");

	sql = "select nvl(a.observaciones,' ')observaciones, a.anio, a.no_entrega as noEntrega, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, a.unidad_administrativa as unidadAdministrativa, a.req_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as reqTipoSolicitudDesc, a.req_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen, b.descripcion as nombreAlmacen, /*decode('"+fg+"','EA',b.descripcion,c.descripcion) unidadAdminDesc*/                                                                                                                                                                         decode(sr.tipo_transferencia,'U',decode(a.unidad_administrativa,'7',decode(sr.codigo_centro,null,c.codigo||' '||c.descripcion,c.descripcion||' -- '||cs.codigo||' '||cs.descripcion),c.codigo||' '||c.descripcion ) ,'A', al.codigo_almacen||' '||al.descripcion,'C',c.codigo||' '||c.descripcion) as unidadAdminDesc, em.primer_nombre||decode(em.segundo_nombre,null,'',' '||em.segundo_nombre)||decode(em.primer_apellido,null,'',' '||em.primer_apellido)||decode(em.segundo_apellido,null,'',' '||em.segundo_apellido)||decode(em.sexo,'F',decode(em.apellido_casada,null,'',' '||em.apellido_casada)) as nombreEmpEntrega,sr.codigo_almacen reqCodAlmacen,a.compania from tbl_inv_entrega_material a, tbl_inv_almacen b, tbl_sec_unidad_ejec c,tbl_pla_empleado em,tbl_inv_almacen al, tbl_inv_solicitud_req sr ,tbl_cds_centro_servicio cs  where a.compania=b.compania and a.codigo_almacen=b.codigo_almacen and a.compania_sol=c.compania(+) and a.unidad_administrativa=c.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.anio="+anio+" and a.no_entrega="+no+" and a.emp_id_entrega = em.emp_id(+)  and al.codigo_almacen = sr.codigo_almacen and al.compania =  " + (fg.equals("EC")?" sr.compania_sol ":"sr.compania  ")+" and sr.solicitud_no = a.req_solicitud_no and sr.anio     = a.req_anio and sr.tipo_solicitud = a.req_tipo_solicitud " + (fg.equals("EC")?" and sr.compania_sol = a.compania ":"and sr.compania = a.compania  ")+" and cs.codigo(+) = sr.codigo_centro ";
	System.out.println("sql....="+sql);
	del = (Delivery) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Delivery.class);
	sql = "select  a.renglon,a.cod_familia  as familyCode, a.cod_clase  classCode,a.cod_articulo as itemCode, b.descripcion as description, b.cod_medida as unitCode, b.itbm as payTax, a.cantidad, nvl(a.precio,0) as lastCost from tbl_inv_detalle_entrega a, tbl_inv_articulo b where a.compania=b.compania and a.cod_familia=b.cod_flia and a.cod_clase=b.cod_clase and a.cod_articulo=b.cod_articulo and a.compania="+(String) session.getAttribute("_companyId")+" and a.anio="+anio+" and a.no_entrega="+no+"  and a.pi_anio is null and a.pi_tipo_inv is null and a.pi_compania is null and a.pi_codigo_ue is null and a.pi_consec is null and a.pi_extra is null order by a.renglon";

	System.out.println("sql DETAIL ....="+sql);
	al = sbb.getBeanList(ConMgr.getConnection(),sql,DeliveryItem.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Entrega - "+document.title;

function calc()
{
	var qty = 0,x=0;
	var lastCost = 0.00;
	var iTotal = 0.00;
	var total = 0.00;
	var msg='',msg2='';
<%
	for (int i=0; i<al.size(); i++)
	{
%>
	lastCost = parseFloat(document.form1.lastCost<%=i%>.value);
	qty = parseInt(document.form1.cantidad<%=i%>.value,10);

	iTotal = qty * lastCost;
	total += iTotal;

	document.form1.lastCost<%=i%>.value = lastCost.toFixed(2);
	document.form1.total<%=i%>.value = iTotal.toFixed(2);
	if(document.form1.checkExtr<%=i%>.checked)
	{
		document.form1.piAnio<%=i%>.value = document.form1.anio.value;
		if(document.form1.tipoInvExt<%=i%>.value ==''){if(msg !='')msg=', '; msg2 = ' Tipo ';x++;}
	}

<%
	}
%>
	document.form1.total.value = total.toFixed(2);

	if( x > 0 ){alert('Seleccione : '+msg+msg2+' de las inversiones Extraordinarias');return false;}
	else{ return true;}
}

function doAction()
{
	calc();
}
function showEntrega(anio,id)
{
var tr ='';
var fg='';
<%if(fg.equals("UA") || fg.equals("SM") || fg.equals("US")){%>
tr='U';
<%=popWinFunction%>('../inventario/print_entregas.jsp?fg='+fg+'&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);

<%}else if(fg.equals("EA")){%>
tr='A';
//<%=popWinFunction%>('../inventario/print_entregas_almacenes.jsp?fg='+fg+'&fp=<%=fp%>&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);
<%=popWinFunction%>('../inventario/print_entregas.jsp?fg='+fg+'&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);
<%}else if(fg.equals("EC")){%>
tr='A';
<%=popWinFunction%>('../inventario/print_entrega_companias.jsp?fg='+fg+'&fp=<%=fp%>&tr='+tr+'&anioEntrega='+anio+'&noEntrega='+id);
<%}%>


}
function showReq(anio,id,wh,tipo)
{
 <%if(fg.equals("UA")){%>
 <%=popWinFunction%>('../inventario/print_requisiciones_unidades_adm.jsp?fg=RUA&tr=RQ&anio='+anio+'&cod_req='+id+'&almacen='+wh+'&tipo='+tipo);
 <%}else if(fg.equals("EA")){%>
	var anio_ent = eval('document.form1.anio').value;
	var noEntrega = eval('document.form1.noEntrega').value;
	 <%=popWinFunction%>('../inventario/print_entregas.jsp?tr=A&anioEntrega='+anio_ent+'&noEntrega='+noEntrega);

 <%}%>
}
function selInversion(i){
	 abrir_ventana('../presupuesto/sel_inversiones.jsp?fg=EM&anio=<%=anio%>&unidad=<%=unidad%>&index='+i);
}

</script>
<style type="text/css">
<!--
.style2 {font-size: 16px; font-family: "Times New Roman", Times, serif;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ENTREGAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("size",""+al.size())%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("unidad",unidad)%>
			<%=fb.hidden("no",no)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("almacen",""+del.getCodigoAlmacen())%>
			<%=fb.hidden("compania",""+del.getCompania())%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel>No. Entrega</cellbytelabel></td>
					<td width="35%">
					<%=fb.textBox("anio",del.getAnio(),false,false,true,5)%>
					<%=fb.textBox("noEntrega",del.getNoEntrega(),false,false,true,10)%>
					</td>
					<td width="15%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("fechaEntrega",del.getFechaEntrega(),false,false,true,10)%></td>
				</tr>
				<tr>
					<td colspan="4">
						<table width="100%">
						<tr class="TextHeader" align="center">
							<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td><cellbytelabel>Cantidad</cellbytelabel></td>
							<td><cellbytelabel>Total</cellbytelabel></td>
							<td><cellbytelabel>A&ntilde;o</cellbytelabel></td>
							<td><cellbytelabel>Cod. Inversi&oacute;n</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Inv. Extraordinaria</cellbytelabel></td>
							<td><cellbytelabel>A&ntilde;o Ant</cellbytelabel>.??</td>
						</tr>
						<%
						for (int i=0; i<al.size(); i++)
						{
							DeliveryItem di = (DeliveryItem) al.get(i);

							String color = "";
							if (i%2 == 0) color = "TextRow02";
							else color = "TextRow01";
						%>
						<%=fb.hidden("renglon"+i,di.getRenglon())%>
						<%=fb.hidden("familyCode"+i,di.getFamilyCode())%>
						<%=fb.hidden("classCode"+i,di.getClassCode())%>
						<%=fb.hidden("itemCode"+i,di.getItemCode())%>
						<%=fb.hidden("description"+i,di.getDescription())%>
						<%=fb.hidden("unitCode"+i,di.getUnitCode())%>
						<%=fb.hidden("piTipoInv"+i,"")%>
						<%=fb.hidden("piCompania"+i,"")%>
						<%=fb.hidden("piCodigoUe"+i,"")%>
						<%=fb.hidden("piConsec"+i,"")%>
						<%=fb.hidden("lastCost"+i,""+di.getLastCost())%>
						<%=fb.hidden("descripcion"+i,"")%>

						<tr class="<%=color%>" align="center">
							<td align="left" width="28%"><%=di.getDescription()%></td>
							<td width="5%"><%=fb.intBox("cantidad"+i,di.getCantidad(),false,false,true,5)%></td>
							<td width="5%"><%=fb.decBox("total"+i,"",false,false,true,10)%></td>
							<td width="5%"><%=fb.intBox("piAnio"+i,"",false,false,false,5)%></td>
							<td width="27%"><%=fb.textBox("dsp_codigo_inversion"+i,"",false,false,true,15)%>
							<%=fb.textBox("descTipoInv"+i,"",false,false,true,20)%>
							<%=fb.button("buscar"+i,"...",false,false,"","","onClick=\"javascript:selInversion("+i+")\"")%></td>
							<td width="5%"><%=fb.checkbox("checkExtr"+i,"",false,false)%></td>
							<td width="20%">
							<%=fb.select("tipoInvExt"+i,alTipo,"",false,false,0,"Text10",null,null,null,"S")%></td>
							<%//=fb.select("entrada_codigo_con"+i,alTipo,act.getEntradaCodigo(),false,false,0,"Text10",null,null,null,"S")%>
							<td width="5%"><%=fb.checkbox("checkAnioAnt"+i,"",false,false)%></td>
						</tr>
						<%
						}
						%>
						<tr class="TextRow03">
							<td colspan="2" align="right"><cellbytelabel>Total Pendiente por Aplicar</cellbytelabel>:</td>
							<td align="center"><%=fb.decBox("total","",false,false,true,10)%></td>
							<td align="center" colspan="5">&nbsp;</td>

						</tr>
						<tr class="TextRowOver">
							<td colspan="8"><cellbytelabel>Verifique que haya aplicado el art&iacute;culo a la inversi&oacute;n correcta ya que una vez
							salvado el registro, el Presupuesto de Inversi&oacute;n ser&aacute; actualizado</cellbytelabel></td>

						</tr>

						</table>
					</td>
				</tr>


				<tr class="TextRow02">
					<td colspan="4" align="right"><authtype type='51'><%=fb.submit("save","Guardar",true,((al.size() >0)?false:true),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
						<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<%fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\terror++;\n\t}\n");%>
				<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
 ArrayList al1= new ArrayList();
 int size =Integer.parseInt(request.getParameter("size"));
 String baction = request.getParameter("baction");


 for(int i=0;i<size;i++)
 {
		if(request.getParameter("piAnio"+i)!= null && !request.getParameter("piAnio"+i).trim().equals(""))
		{
		CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("anio",request.getParameter("anio"));
			cdo.addColValue("compania",request.getParameter("compania"));
			cdo.addColValue("noEntrega",request.getParameter("no"));
			cdo.addColValue("almacen",request.getParameter("almacen"));
			cdo.addColValue("unidad",request.getParameter("unidad"));
			cdo.addColValue("fechaEntrega",request.getParameter("fechaEntrega"));


			cdo.addColValue("piAnio",request.getParameter("piAnio"+i));
			cdo.addColValue("piTipoInv",request.getParameter("piTipoInv"+i));
			cdo.addColValue("piCompania",request.getParameter("piCompania"+i));
			cdo.addColValue("piCodigoUe",request.getParameter("piCodigoUe"+i));
			cdo.addColValue("piConsec",request.getParameter("piConsec"+i));


			cdo.addColValue("tipoInvExt",request.getParameter("tipoInvExt"+i));

			if (request.getParameter("checkExtr"+i) != null){//inversion Extraordinaria
			cdo.addColValue("piExtra","S");
			cdo.addColValue("piTipoInv",request.getParameter("tipoInvExt"+i));
			cdo.addColValue("piCodigoUe",request.getParameter("unidad"));
			cdo.addColValue("piCompania",request.getParameter("compania"));
			}
			else cdo.addColValue("piExtra","N");

			if (request.getParameter("checkAnioAnt"+i) != null)//Año anterior
			cdo.addColValue("piAnioAnt","S");
			else cdo.addColValue("piAnioAnt","N");

			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("renglon",request.getParameter("renglon"+i));
			cdo.addColValue("codFamilia",request.getParameter("familyCode"+i));
			cdo.addColValue("codClase",request.getParameter("classCode"+i));
			cdo.addColValue("codArticulo",request.getParameter("itemCode"+i));

			al1.add(cdo);
			}

 }

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		PresMgr.updateEntregas(al1);
	}

	ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (PresMgr.getErrCode().equals("1"))
{
%>
	alert('<%=PresMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_entrega_equipos.jsp"))
	{

%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_entrega_equipos.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/presupuesto/list_entrega_equipos.jsp?fg=<%=fg%>&unidad=<%=unidad%>&anio=<%=anio%>';
<%
	}
%>
	window.close();
<%
} else throw new Exception(PresMgr.getErrMsg());
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
