
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.DevolucionPaciente"%>
<%@ page import="issi.inventory.DevDetSolPac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDevMateriales" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DevMgr" scope="page" class="issi.inventory.DevolucionPacienteMgr" />
<jsp:useBean id="vDetMat" scope="session" class="java.util.Vector" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
DevMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String wh = request.getParameter("wh");

String centro = request.getParameter("centro");
String empresa = request.getParameter("empresa");

String id = "";
String key = "";
String sql = "";

boolean op =true, dev = true;
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = request.getParameter("anio");
int nDev = 0;

int devLastLineNo= 0;
if(empresa == null) empresa = "";
if(mode.trim().equals("view")) viewMode = true;
if (request.getParameter("id") != null && !request.getParameter("id").equals("")) id = request.getParameter("id");
if (request.getParameter("devLastLineNo") != null && !request.getParameter("devLastLineNo").equals("")) devLastLineNo= Integer.parseInt(request.getParameter("devLastLineNo"));
else devLastLineNo= 0;
if (request.getMethod().equalsIgnoreCase("GET"))
{
if (change == null && !mode.trim().equals("add"))
		{
				iDevMateriales.clear();
				vDetMat.clear();
			String estado="";
			if(fg.trim().equals("DM"))
			estado = " <> 'A' ";
			else estado = " = 'A' ";


			sql="select '"+centro+"' as centro,dp.compania, dp.anio_devolucion as anioDevolucion, dp.num_devolucion numDevolucion,   dp.cod_familia codFamilia, dp.cod_clase codClase, dp.cod_articulo codArticulo, dp.renglon, dp.cantidad, dp.precio, nvl(dp.costo,0) costo,nvl(y.entregas,0) entregas, decode('"+fg+"','DMA',nvl(dp.cantidad_sol,0), nvl(y.entregas,0)) cantidadSol, a.descripcion ,nvl(a.cod_medida,' ') Medida ,/*decode(d.estado,'R',nvl(sum(NVL(dp.cantidad,0)),0)*/ nvl(z.cantidad_dev,0) as cantDev ,nvl(pa.precio,0) precio1,nvl(pa.precio2,0)precio2 , fa.tipo_servicio as tipoServicio from tbl_inv_detalle_paciente dp, tbl_inv_articulo a,tbl_inv_devolucion_pac d,tbl_fac_precio_x_aseg pa, tbl_inv_familia_articulo fa, ( select sum(de.cantidad)  entregas ,de.cod_articulo from  tbl_inv_articulo ar, tbl_inv_entrega_material  em,tbl_inv_detalle_entrega  de,tbl_inv_solicitud_pac sp,tbl_cds_centro_servicio  cs where de.cod_articulo = ar.cod_articulo and de.compania = ar.compania and em.compania = sp.compania and em.pac_anio = sp.anio and   em.pac_solicitud_no = sp.solicitud_no and   cs.compania_unorg = sp.compania and   cs.codigo = sp.centro_servicio and   de.compania = em.compania and   de.no_entrega = em.no_entrega and   de.anio = em.anio and   em.compania = "+(String) session.getAttribute("_companyId")+" and   em.pac_id = "+pacId+" and   em.adm_secuencia     = "+noAdmision+" and   em.codigo_almacen    = "+wh+" and   cs.codigo    =  "+centro+" group by de.cod_articulo )y, ( select sum(de.cantidad) cantidad_dev,de.cod_articulo from tbl_inv_devolucion_pac dp,  tbl_inv_detalle_paciente de where (de.compania = dp.compania and  de.num_devolucion  = dp.num_devolucion and  de.anio_devolucion = dp.anio) and  dp.compania          = "+(String) session.getAttribute("_companyId")+" and  dp.pac_id = "+pacId+" and  dp.adm_secuencia = "+noAdmision+" and  dp.codigo_almacen    ="+wh+" and  dp.sala_cod =  "+centro+" and  dp.estado "+estado+" group by de.cod_articulo )z 	where  dp.compania = "+(String) session.getAttribute("_companyId")+" and a.compania= dp.compania and dp.anio_devolucion = "+anio+" and dp.num_devolucion = "+id+"  and d.anio = "+anio+" and d.num_devolucion = "+id+" and dp.cod_articulo = a.cod_articulo and dp.cod_familia = fa.cod_flia and    fa.compania = "+(String) session.getAttribute("_companyId")+" and pa.codigo_empresa (+) = nvl('"+empresa+"',0) and pa.compania (+) = dp.compania and pa.cod_articulo (+) = dp.cod_articulo and y.cod_articulo(+)   = dp.cod_articulo and z.cod_articulo(+)   = dp.cod_articulo group by '"+centro+"',dp.compania, dp.anio_devolucion, dp.num_devolucion ,dp.cod_familia , dp.cod_clase , dp.cod_articulo , dp.renglon, dp.cantidad, dp.precio, nvl(dp.costo,0) , nvl(dp.cantidad_sol,0) , a.descripcion ,nvl(a.cod_medida,' ') ,d.estado ,pa.precio,pa.precio2 , fa.tipo_servicio, nvl(z.cantidad_dev,0) ,decode('DMA','DMA',nvl(dp.cantidad_sol,0),nvl(y.entregas,0)) ,nvl(y.entregas,0)  ";
          System.out.println("SQL:\n"+sql);
					al = sbb.getBeanList(ConMgr.getConnection(), sql, DevDetSolPac.class);

          			iDevMateriales.clear();
					devLastLineNo = al.size();
					for (int i = 1; i <= al.size(); i++)
					{
							if (i < 10) key = "00" + i;
							else if (i < 100) key = "0" + i;
							else key = "" + i;
							try
							{
									 iDevMateriales.put(key, al.get(i-1));
									 //vDetMat.add();//e.cod_familia||'-'||e.cod_clase||'-'||e.cod_articulo as codigo
							}
							catch(Exception e)
							{
							 System.err.println(e.getMessage());
							}
		    	}
		}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Devolucion de materiales - '+document.title;


function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	formSubBlockButtons(false);
	parent.devolucionBlockButtons(false);
	<%
	if (request.getParameter("type") != null && request.getParameter("type").trim().equals("1"))
	{ %>
		showArticulosList();
	<%}	%>

		calValues(0);
}
function showArticulosList()
{
	var pac_id = parent.document.devolucion.pacId.value ;
	var admision = parent.document.devolucion.noAdmision.value ;
	var cda = parent.document.devolucion.codigo_almacen.value ;
	var sala = parent.document.devolucion.codigo_sala.value ;
	var empresa = parent.document.devolucion.empresa.value ;

	abrir_ventana1('../common/sel_materiales_paciente.jsp?fg=<%=fg%>&fp=<%=fp%>&pacId='+pac_id+'&noAdmision='+admision+'&codAlmacen='+cda+'&sala='+sala+'&devLastLineNo=<%=devLastLineNo%>&empresa='+empresa);
}
function doSubmit()
{
	if (document.formSub.baction.value == '')
	document.formSub.baction.value = parent.document.devolucion.baction.value;
	document.formSub.saveOption.value    = parent.document.devolucion.saveOption.value;

	document.formSub.sigla.value = parent.document.devolucion.sigla.value;
	document.formSub.tomo.value = parent.document.devolucion.tomo.value;
	document.formSub.anio.value = parent.document.devolucion.anio.value;
	document.formSub.num_devolucion.value = parent.document.devolucion.num_dev.value;
	document.formSub.compania.value = parent.document.devolucion.compania.value;
	document.formSub.fecha.value = parent.document.devolucion.fecha.value;
	document.formSub.provincia_env.value = parent.document.devolucion.empProvincia.value;
	document.formSub.sigla_env.value = parent.document.devolucion.empSigla.value;
	document.formSub.tomo_env.value = parent.document.devolucion.empTomo.value;
	document.formSub.asiento_env.value = parent.document.devolucion.empAsiento.value;

	document.formSub.provincia_rec.value = parent.document.devolucion.provincia_rec.value;
	document.formSub.sigla_rec.value = parent.document.devolucion.sigla_rec.value;
	document.formSub.tomo_rec.value = parent.document.devolucion.tomo_rec.value;
	document.formSub.asiento_rec.value = parent.document.devolucion.asiento_rec.value;
	document.formSub.monto.value = parent.document.devolucion.monto.value;
	//document.formSub.subtotal.value = parent.document.devolucion.subtotal.value;
	document.formSub.itbm.value = parent.document.devolucion.itbm.value;
	document.formSub.usuario_creacion.value = parent.document.devolucion.usuario_creacion.value;
	document.formSub.fecha_creacion.value = parent.document.devolucion.fecha_creacion.value;
	document.formSub.usuario_modif.value = parent.document.devolucion.usuario_modif.value;
	document.formSub.fecha_modif.value = parent.document.devolucion.fecha_modif.value;
	document.formSub.fecha_nacimiento.value = parent.document.devolucion.fechaNacimiento.value;
	document.formSub.paciente.value = parent.document.devolucion.codigoPaciente.value;
	document.formSub.codigo_almacen.value = parent.document.devolucion.codigo_almacen.value;
	document.formSub.anio_entrega.value = parent.document.devolucion.anio_entrega.value;
	document.formSub.no_entrega.value = parent.document.devolucion.no_entrega.value;
	document.formSub.noAdmision.value = parent.document.devolucion.noAdmision.value;
	document.formSub.asiento_sino.value = parent.document.devolucion.asiento_sino.value;
	document.formSub.estado.value = parent.document.devolucion.estado.value;
	//document.formSub.sala.value = parent.document.devolucion.desc_codigo_sala.value;
	document.formSub.observacion.value = parent.document.devolucion.observacion.value;
	document.formSub.cod_medico.value = parent.document.devolucion.cod_medico.value;
	document.formSub.sala_cod.value = parent.document.devolucion.codigo_sala.value;
	document.formSub.no_receta.value = parent.document.devolucion.no_receta.value;
	document.formSub.solicitud_pac_pamd.value = parent.document.devolucion.solicitud_pac_pamd.value;
	document.formSub.anio_solic_pac_pamd.value = parent.document.devolucion.anio_solic_pac_pamd.value;
	document.formSub.emp_id_env.value = parent.document.devolucion.emp_id.value;
	document.formSub.emp_id_rec.value = parent.document.devolucion.emp_id_rec.value;
	document.formSub.pacId.value = parent.document.devolucion.pacId.value;

	document.formSub.empresa.value = parent.document.devolucion.empresa.value;
	document.formSub.edad.value = parent.document.devolucion.edad.value;
	document.formSub.tipo_incremento.value = parent.document.devolucion.tipo_incremento.value;
	document.formSub.incremento.value = parent.document.devolucion.incremento.value;
	document.formSub.clasificacion.value = parent.document.devolucion.clasificacion.value;
	document.formSub.fecha_egreso.value = parent.document.devolucion.fecha_egreso.value;
	document.formSub.flag_cds.value = parent.document.devolucion.flag_cds.value;

	if (document.formSub.baction.value == 'Guardar' && !formSubValidation())
	{
		formSubBlockButtons(false);
		parent.devolucionBlockButtons(false);
		return false;
	}
	document.formSub.submit();
}
function addCob()
{

	setBAction('formSub','+');
	parent.devolucionBlockButtons(true);
	formSubBlockButtons(true);
	if(parent.devolucionValidation())
			document.formSub.submit();
}
function removeArticle(k)

{
			removeItem('formSub',k);
			parent.devolucionBlockButtons(true);
			formSubBlockButtons(true);
			document.formSub.submit();
}
function verCantEnt(j){
	var cantidad		= eval('document.formSub.devolver'+j).value;
	var cant_entrega		= eval('document.formSub.cantidad_sol'+j).value;
	var cant_dev		= eval('document.formSub.cantDev'+j).value;
	var entregas		= eval('document.formSub.entregas'+j).value;
	var x =0;
	if(cantidad =='' || isNaN(cantidad) || isNaN(cant_entrega)|| isNaN(entregas))
	{
	 alert('Introduzca valores numéricos!');

	}
	else {
	if(parseInt(cantidad) < 0 )
	{
		alert('La cantidad a Devolver no puede ser menor a Cero!');
		eval('document.formSub.devolver'+j).focus();
	}
	else{	cantidad = parseInt(cantidad);
		cant_dev = parseInt(cant_dev);
		cant_entrega = parseFloat(cant_entrega);
		entregas = parseFloat(entregas);
		
		if(cantidad != 0)
		{
		  <%if(fg.trim().equals("DMA")){%>
			if((parseFloat(cantidad)>parseFloat(cant_entrega))){
			
			alert('La cantidad a devolver excede la cantidad de la Solicitud...');
			x++;
			}
			<%}else{%>
			if((cantidad  > (entregas - cant_dev))){
			alert('La cantidad a devolver excede la totalidad de las entregas...');
			x++;
			}
			<%}%>
		

		//if((cantidad  > (entregas - cant_dev)) ||( cantidad  > cant_entrega ) && cantidad != 0){
		
				<%//if(fg.trim().equals("DMA")){%>
			//alert('La cantidad a devolver excede la cantidad de la Solicitud...');
			<%//}else{%>
			//alert('La cantidad a devolver excede la totalidad de las entregas...');
			<%//}%>
		}
		
		if(x>0){	
			eval('document.formSub.total'+j).value = (0).toFixed(2);
			eval('document.formSub.devolver'+j).value = '0';
			eval('document.formSub.devolver'+j).focus();
			eval('document.formSub.devolver'+j).select();
		} else {
			calValues();
		}
	 }
	}
}
function calValues(){

	var size = document.formSub.devSize.value;
	var monto = 0.00, sub_total = 0.00;
	var cantidad = 0;
	var cant_entrega =0;
	var cant_dev =0;
	var entregas =0;

	for(i=0;i<size;i++)
	{
		cant_entrega		= eval('document.formSub.cantidad_sol'+i).value;
	    cant_dev		= eval('document.formSub.cantDev'+i).value;
		cantidad	= eval('document.formSub.devolver'+i).value;
		_precio 	= eval('document.formSub.precio'+i).value;
		entregas	= eval('document.formSub.entregas'+i).value;

//var cantidad		= eval('document.formSub.devolver'+j).value;
//	var cant_entrega		= eval('document.formSub.cantidad_sol'+j).value;
	//var cant_dev		= eval('document.formSub.cantDev'+j).value;
	//var entregas		= eval('document.formSub.entregas'+j).value;


		if(!isNaN(cantidad) || !cantidad<=0)
		{
		sub_total	+= (cantidad*_precio);
		eval('document.formSub.total'+i).value = (cantidad * _precio).toFixed(2);

		<%if(mode != null && !mode.trim().equals("view")){%>

		if(cantidad != 0){
		
			<%if(fg.trim().equals("DMA")){%>
			if((parseFloat(cantidad)  > parseFloat(cant_entrega))){
			alert('cantida ='+cant_entrega);
			alert('La cantidad a devolver excede la cantidad de la Solicitud...');
			eval('document.formSub.devolver'+i).select();
			return false;
			break;
			
			}
			<%}else{%>
			
			if((cantidad  > (entregas - cant_dev))){
			alert('La cantidad a devolver excede la totalidad de las entregas...');
			eval('document.formSub.devolver'+i).select();
			return false;
			break;
			
			}
			<%}%>
			
			
		
		}
		<%}%>
		}
		else
		{
		    alert('Introduzca Valores validos ...');
			//eval('document.formSub.devolver'+i).focus();
			break;
		}

	}
	eval('document.formSub.subtotal').value  =  (sub_total).toFixed(2);
	//parent.document.devolucion.subtotal.value = (sub_total).toFixed(2);

}
function chkCeroValues(){
	var size = document.formSub.devSize.value;
	var x = 0,y=0;
	if(document.formSub.baction.value == "Guardar")
	{
		for(i=0;i<size;i++)
		{
			if(eval('document.formSub.devolver'+i).value<=0)
			{
				//alert('La cantidad no puede ser menor o igual a 0!');
				//eval('document.formSub.devolver'+i).focus();
				x++;
				y++;
				//break;
			}
		}
	}
	if(x==0 || y < size)
	{
		calValues(1);
		return true;
	}	else { alert('La devoluciòn no tiene Detalle!');return false;}
}
function chkCeroRegisters(){
	var size = document.formSub.devSize.value;
	var sala = parent.document.devolucion.codigo_sala.value;
	var wh = parent.document.devolucion.codigo_almacen.value;

	if(size>0) return true;
	else
	{
		if(document.formSub.baction.value!='Guardar') return true;
		else
		{
			alert('Seleccione al menos un (1) articulo!');
			document.formSub.baction.value = '';
			return false;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formSub",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("devLastLineNo",""+devLastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("fp", fp)%>
			<%=fb.hidden("fg", fg)%>
			<%=fb.hidden("id", id)%>
			<%=fb.hidden("devSize",""+iDevMateriales.size())%>
			<%=fb.hidden("saveOption","")%>
			<%=fb.hidden("sigla","")%>
			<%=fb.hidden("tomo","")%>
			<%=fb.hidden("anio","")%>
			<%=fb.hidden("num_devolucion","")%>
			<%=fb.hidden("compania","")%>
			<%=fb.hidden("fecha","")%>
			<%=fb.hidden("provincia_env","")%>
			<%=fb.hidden("sigla_env","")%>
			<%=fb.hidden("tomo_env","")%>
			<%=fb.hidden("asiento_env","")%>
			<%=fb.hidden("provincia_rec","")%>
			<%=fb.hidden("sigla_rec","")%>
			<%=fb.hidden("tomo_rec","")%>
			<%=fb.hidden("asiento_rec","")%>
			<%=fb.hidden("monto","")%>
			<%//=fb.hidden("subtotal","")%>
			<%=fb.hidden("itbm","")%>
			<%=fb.hidden("usuario_creacion","")%>
			<%=fb.hidden("fecha_creacion","")%>
			<%=fb.hidden("usuario_modif","")%>
			<%=fb.hidden("fecha_modif","")%>
			<%=fb.hidden("fecha_nacimiento","")%>
			<%=fb.hidden("paciente","")%>
			<%=fb.hidden("codigo_almacen","")%>
			<%=fb.hidden("anio_entrega","")%>
			<%=fb.hidden("no_entrega","")%>
			<%=fb.hidden("noAdmision","")%>
			<%=fb.hidden("asiento_sino","")%>
			<%=fb.hidden("estado","")%>
			<%=fb.hidden("sala","")%>
			<%=fb.hidden("observacion","")%>
			<%=fb.hidden("cod_medico","")%>
	 		<%=fb.hidden("sala_cod","")%>
			<%=fb.hidden("no_receta","")%>
			<%=fb.hidden("solicitud_pac_pamd","")%>
			<%=fb.hidden("anio_solic_pac_pamd","")%>
			<%=fb.hidden("emp_id_env","")%>
			<%=fb.hidden("emp_id_rec","")%>
			<%=fb.hidden("pacId","")%>

			<%=fb.hidden("empresa","")%>
			<%=fb.hidden("edad","")%>
			<%=fb.hidden("tipo_incremento","")%>
			<%=fb.hidden("incremento","")%>
			<%=fb.hidden("clasificacion","")%>
			<%=fb.hidden("fecha_egreso","")%>
			<%=fb.hidden("flag_cds","")%>

					<tr class="TextHeader" align="center">
							<td width="8%">Familia</td>
							<td width="7%">Clase</td>
							<td width="9%">Articulo</td>
							<td width="38%">Descripcion</td>
							<td width="8%">Unidad</td>
							<%if(!fg.trim().equals("CDM")){%>
							<td width="6%">Devuelto</td>

							<%if(fg.trim().equals("DMA")){%>

							<td width="7%">Sol. Dev</td>
							<%}else{%>
							<td width="7%">Entregado</td>
							<%}
							} if(fg.trim().equals("DM")){%>

							<td width="6%">Devolver</td>
							<%}else if(fg.trim().equals("CDM")){%>
							<td width="6%">Cantidad</td>
							<%}else{%>
							<td width="6%">Ok</td>
							<%}%>
							<td width="5%">Precio</td>
							<td width="6%">Total</td>
						  <td width="10%"><%=fb.button("addCol","+",false,(viewMode || fg.trim().equals("DMA")),null,null,"onClick=\"javascript:addCob()\"","Agregar Articulos")%></td>


				</tr>
				<%

				    al = CmnMgr.reverseRecords(iDevMateriales);
				    for (int i=0; i<al.size(); i++)
				    {
					  key = al.get(i).toString();

				   	  DevDetSolPac detDev = (DevDetSolPac) iDevMateriales.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow01";

					%>
					<%=fb.hidden("descripcion"+i,detDev.getDescripcion())%>
					<%=fb.hidden("costo"+i,detDev.getCosto())%>
					<%=fb.hidden("no_entrega"+i,detDev.getNoEntrega())%>
					<%=fb.hidden("anio_entrega"+i,detDev.getAnioEntrega())%>
					<%=fb.hidden("centro"+i,detDev.getCentro())%>
					<%=fb.hidden("tipo_servicio"+i,detDev.getTipoServicio())%>
					<%=fb.hidden("v_precioL"+i,detDev.getPrecio1())%>
					<%=fb.hidden("v_precioT"+i,detDev.getPrecio2())%>
					<%=fb.hidden("entregas"+i,detDev.getEntregas())%>
					<%=fb.hidden("key"+i,key)%>
					<%=fb.hidden("remove"+i,"")%>
				 	<tr class="<%=color%>" align="center">
						<td><%=fb.intBox("familia"+i,detDev.getCodFamilia(),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("clase"+i,detDev.getCodClase(),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.intBox("articulo"+i,detDev.getCodArticulo(),false,viewMode,true,5,"Text10",null,null)%></td>
						<td align="left" class="Text10"><%=detDev.getDescripcion()%></td>
						<td><%=fb.textBox("medida"+i,detDev.getMedida(),false,viewMode,true,5,"Text10",null,null)%></td>
						<%if(!fg.trim().equals("CDM")){%>
						<td><%=fb.intBox("cantDev"+i,detDev.getCantDev(),false,viewMode,true,5,"Text10",null,null)%></td>
						<td><%=fb.decBox("cantidad_sol"+i,detDev.getCantidadSol(),false,viewMode,true,5,10,null,null,"")%></td>
						<td><%=fb.intBox("devolver"+i,detDev.getCantidad(),true,(viewMode),false,5,8,null,null,"onBlur=\"javascript:verCantEnt('"+i+"')\"")%></td>

						<%}else{%>
						<%=fb.hidden("cantDev"+i,detDev.getCantDev())%>
						<%=fb.hidden("cantidad_sol"+i,detDev.getCantidadSol())%>
						<td><%=fb.intBox("devolver"+i,detDev.getCantidad(),false,(viewMode),false,5,8,null,null,"onBlur=\"javascript:verCantEnt('"+i+"')\"")%></td>

						<%}%>

						<td><%=fb.decBox("precio"+i,(detDev.getPrecio()!=null)?detDev.getPrecio():"",false,viewMode,true,5,15.4)%></td>
						<td><%=fb.decBox("total"+i,"",false,viewMode,true,5,15.4)%></td>


						<td align="center"><%=fb.button("rem"+i,"X",false,(viewMode),null,null,"onClick=\"javascript:removeArticle('"+i+"')\"","Eliminar Articulo")%></td>


				<%
					}
					fb.appendJsValidation("if(error>0)newHeight();");
					fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
					fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");

				%>

				</tr>
				<tr class="TextRow01" align="center">

					<%if(fg.trim().equals("CDM")){%>
					<td colspan="7" align="right">Total</td>
					 <%}else{%>

					 <td colspan="9" align="right">SubTotal</td>
					 <%}%>
					<td><%=fb.decBox("subtotal","",false,viewMode,true,5)%></td>
					<td>&nbsp;</td>



					</tr>
            <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	 		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
			String baction = request.getParameter("baction");
			String itemRemoved = "";
			String flag_cds = "";
			if(request.getParameter("flag_cds")!=null && !request.getParameter("flag_cds").equals("")) flag_cds = request.getParameter("flag_cds");
			fp = request.getParameter("fp");
			fg = request.getParameter("fg");
			int size = 0;
			noAdmision = request.getParameter("noAdmision");
			pacId      = request.getParameter("pacId");

	if (request.getParameter("devSize")!= null)	size = Integer.parseInt(request.getParameter("devSize"));

			DevolucionPaciente devPac = new DevolucionPaciente();

			devPac.setCompania(request.getParameter("compania"));
			devPac.setAnio(request.getParameter("anio"));
			devPac.setNumDevolucion(request.getParameter("num_devolucion"));
			devPac.setFecha(request.getParameter("fecha"));
			devPac.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
			devPac.setPaciente(request.getParameter("paciente"));
			devPac.setAdmSecuencia(request.getParameter("noAdmision"));
			devPac.setPacId(request.getParameter("pacId"));
			devPac.setMonto("");

			if(fg.trim().equals("DMA") || flag_cds.trim().equals("CU") || flag_cds.trim().equals("DIET"))
			{
				if(request.getParameter("fecha_egreso")!=null && !request.getParameter("fecha_egreso").equals("")) devPac.setFechaEgreso(request.getParameter("fecha_egreso"));
				if(request.getParameter("subtotal")!=null && !request.getParameter("subtotal").equals("")) devPac.setSubtotal(request.getParameter("subtotal"));
			}

			devPac.setItbm("");
			devPac.setCodigoAlmacen(request.getParameter("codigo_almacen"));
			devPac.setUsuarioCreacion(request.getParameter("usuario_creacion"));
			devPac.setFechaCreacion(request.getParameter("fecha_creacion"));
			devPac.setUsuarioModif((String) session.getAttribute("_userName"));
			devPac.setFechaModif(cDateTime);
			devPac.setSala(request.getParameter("sala"));
			if(flag_cds.equals("DIET")) devPac.setEstado("R");
			else devPac.setEstado(request.getParameter("estado"));

			devPac.setSalaCod(request.getParameter("sala_cod"));
			devPac.setProvinciaEnv(request.getParameter("provincia_env"));
			devPac.setSiglaEnv(request.getParameter("sigla_env"));
			devPac.setTomoEnv(request.getParameter("tomo_env"));
			devPac.setAsientoEnv(request.getParameter("asiento_env"));
			devPac.setProvinciaRec(request.getParameter("provincia_rec"));
			devPac.setSiglaRec(request.getParameter("sigla_rec"));
			devPac.setTomoRec(request.getParameter("tomo_rec"));
			devPac.setAsientoRec(request.getParameter("asiento_rec"));
			devPac.setAnioEntrega(request.getParameter("anio_entrega"));
			devPac.setNoEntrega(request.getParameter("no_entrega"));
			devPac.setAsientoSino(request.getParameter("asiento_sino"));
			devPac.setObservacion(request.getParameter("observacion"));
			devPac.setCodMedico(request.getParameter("cod_medico"));
			devPac.setNoReceta(request.getParameter("no_receta"));
			devPac.setSolicitudPacPamd(request.getParameter("solicitud_pac_pamd"));
			devPac.setAnioSolicPacPamd(request.getParameter("anio_solic_pac_pamd"));
			devPac.setEmpIdEnv(request.getParameter("emp_id_env"));
			devPac.setEmpIdRec(request.getParameter("emp_id_rec"));
		  for (int i=0; i<size; i++)
			{
					DevDetSolPac detDev  = new DevDetSolPac();
					detDev.setCompania(request.getParameter("compania"));
					detDev.setAnioDevolucion(request.getParameter("anio"));

					detDev.setNumDevolucion("0");
					detDev.setCodFamilia(request.getParameter("familia"+i));
					detDev.setCodClase(request.getParameter("clase"+i));
					detDev.setCodArticulo(request.getParameter("articulo"+i));
					detDev.setRenglon("0");
					detDev.setCantidad(request.getParameter("devolver"+i));
					detDev.setCantDev(request.getParameter("cantDev"+i));
					detDev.setPrecio(request.getParameter("precio"+i));
					detDev.setCosto(request.getParameter("costo"+i));
					if(fg.trim().equals("DM"))
					detDev.setCantidadSol(request.getParameter("devolver"+i));
					else
					detDev.setCantidadSol(request.getParameter("cantidad_sol"+i));

					detDev.setMedida(request.getParameter("medida"+i));
					detDev.setDescripcion(request.getParameter("descripcion"+i));
					detDev.setNoEntrega(request.getParameter("no_entrega"+i));
					detDev.setAnioEntrega(request.getParameter("anio_entrega"+i));
					detDev.setTipoServicio(request.getParameter("tipo_servicio"+i));
					detDev.setPrecio1(request.getParameter("v_precioL"+i));
					detDev.setPrecio2(request.getParameter("v_precioT"+i));
					detDev.setEntregas(request.getParameter("entregas"+i));

					key = request.getParameter("key"+i);

					if ((request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")))
					itemRemoved = key;
					else
					{
						try
						{
							 if ((request.getParameter("devolver"+i) != null && !request.getParameter("devolver"+i).equals("") && !request.getParameter("devolver"+i).equals("0") ) && ( baction.equalsIgnoreCase("Guardar") &&  !fg.trim().equals("DMA") )){

							if(devPac.getSalaCod().trim().equals(request.getParameter("centro"+i)))
							{

								iDevMateriales.put(key,detDev);
								vDetMat.add(request.getParameter("familia"+i)+"-"+request.getParameter("clase"+i)+"-"+request.getParameter("articulo"+i));
								devPac.addDetalle(detDev);
								al.add(detDev);
								//System.out.println(" agregando registro al hastable para guardar cantidad distinta de 0");
							}
							}
							else if (!fg.trim().equals("DM") )
							{
							if(devPac.getSalaCod().trim().equals(request.getParameter("centro"+i)))
							{
								iDevMateriales.put(key,detDev);
								vDetMat.add(request.getParameter("familia"+i)+"-"+request.getParameter("clase"+i)+"-"+request.getParameter("articulo"+i));
								devPac.addDetalle(detDev);
								al.add(detDev);
								//System.out.println(" agregando registro al hastable sin cantidad ");
							}
							}
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
					}


		}//end For

		if (!itemRemoved.equals(""))
		{
			vDetMat.remove(((DevDetSolPac) iDevMateriales.get(itemRemoved)).getKey());
			iDevMateriales.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&devLastLineNo="+devLastLineNo+"&fp="+fp+"&fg="+fg);
			return;
		}
		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&devLastLineNo="+devLastLineNo+"&fp="+fp+"&fg="+fg);
			return;
		}

if (baction.equalsIgnoreCase("Guardar"))
{
		 	if(fg.trim().equals("DM"))
			{
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				if(flag_cds.trim().equals("DIET")) DevMgr.add(devPac,"D");
				else if(flag_cds.trim().equals("CU")) DevMgr.add(devPac,"U");
				else DevMgr.add(devPac,"O");
				id = DevMgr.getPkColValue("num_devolucion");
				ConMgr.clearAppCtx(null);
			}
			else if(fg.trim().equals("DMA"))
			{
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				devPac.setFecha(request.getParameter("fecha_egreso"));
				DevMgr.update(devPac);
				id = request.getParameter("num_devolucion");
				ConMgr.clearAppCtx(null);
				mode="view";
			}
}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
 	<%if (DevMgr.getErrCode().equals("1")){%>
			parent.document.devolucion.errCode.value = '<%=DevMgr.getErrCode()%>';
			parent.document.devolucion.errMsg.value = '<%=DevMgr.getErrMsg()%>';
			parent.document.devolucion.id.value = '<%=id%>';
			parent.document.devolucion.anio.value = '<%=anio%>';
			parent.document.devolucion.pacId.value = '<%=pacId%>';
			parent.document.devolucion.noAdmision.value = '<%=noAdmision%>';
			parent.document.devolucion.fp.value = '<%=fp%>';
			parent.document.devolucion.fg.value = '<%=fg%>';
			parent.document.devolucion.mode.value = '<%=mode%>';
			parent.document.devolucion.submit();
	<%} else throw new Exception(DevMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
