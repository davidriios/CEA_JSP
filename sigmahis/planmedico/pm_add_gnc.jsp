<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.convenio.Convenio"%>
<%@ page import="issi.convenio.GastoNoCubierto"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ConvMgr" scope="page" class="issi.convenio.ConvenioMgr" />
<jsp:useBean id="iGNC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vGNC" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ConvMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String change = request.getParameter("change");
int planLastLineNo = 0;
int gncLastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (empresa == null || secuencia == null) throw new Exception("El Convenio no es válido. Por favor intente nuevamente!");
if (request.getParameter("planLastLineNo") != null) planLastLineNo = Integer.parseInt(request.getParameter("planLastLineNo"));
if (request.getParameter("gncLastLineNo") != null) gncLastLineNo = Integer.parseInt(request.getParameter("gncLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Agregar Gasto No Cubierto';

function loadDetails()
{
	var tipoServicio=document.form1.tipoServicio.value;
	var tipoCds=document.form1.tipoCds.value;
	var inventarioSino=document.form1.inventarioSino.checked?'S':'N';
	var codigo=document.form1.codigo.value;
	var ok=true;
	var retVal='';

	if (tipoServicio == '02' || tipoServicio == '03' || tipoServicio == '04')
	{
		if (inventarioSino == 'S' && tipoCds == 'I') retVal=getArticulo(codigo,tipoServicio);
		else if (inventarioSino == 'N' && tipoCds == 'I') retVal=getUso(codigo,tipoServicio);
		//else if (inventarioSino == 'N' && tipoCds == 'T') retVal=getProductoCds(codigo,tipoServicio,centroServicio);
		else ok=false;
	}
	else if (tipoServicio == '05' || tipoServicio == '06' || tipoServicio == '09' || tipoServicio == '10')
	{
		if (tipoCds == 'I') retVal=getUso(codigo,tipoServicio);
		//else if (tipoCds == 'T' || tipoCds == 'E') retVal=getProductoCds(codigo,tipoServicio,centroServicio);
		else ok=false;
	}
	else if (tipoServicio == '07')
	{
		if (tipoCds == 'I') retVal=getProcedimiento(codigo);
		//else if (tipoCds == 'T' || tipoCds == 'E') retVal=getProductoCds(codigo,tipoServicio,centroServicio);
		else ok=false;
	}
	else if (tipoServicio == '11' || tipoServicio == '12' || tipoServicio == '13' || tipoServicio == '14') retVal=getUso(codigo,tipoServicio);
	else if (tipoServicio == '30') retVal=getOtrosCargos(codigo);
	else if (tipoServicio == '08') retVal=getArticulo(codigo);
	else ok=false;

	if (!ok)
	{
		alert('No Aplica');
		return false;
	}
	else if (retVal == '') return false;

	return true;
}

function getArticulo(codigo,tipoServicio)
{

	var retVal=splitCols(getDBData('<%=request.getContextPath()%>','c.descripcion,trim(to_char(nvl(c.precio_venta,0),\'99999990.00\'))','tbl_inv_familia_articulo a, tbl_inv_clase_articulo b, tbl_inv_articulo c','a.compania=b.compania and a.cod_flia=b.cod_flia and b.compania=c.compania and b.cod_flia=c.cod_flia and b.cod_clase=c.cod_clase and c.compania=<%=session.getAttribute("_companyId")%> and a.tipo_servicio=\''+tipoServicio+'\' and c.cod_articulo=\''+codigo+'\'',''));
	
//	alert(retVal);
	if (retVal != null)
	{
		var obj = document.form1.tipoServicio;
		document.form1.tipoServicioDesc.value=obj.options[obj.selectedIndex].text;
		obj = document.form1.tipoCds;
		if (obj.value == '') document.form1.tipoCdsDesc.value='---';
		else document.form1.tipoCdsDesc.value=obj.options[obj.selectedIndex].text;
		document.form1.compania.value='<%=(String) session.getAttribute("_companyId")%>';
		document.form1.artFamilia.value=codigo.substring(0,codigo.indexOf('-'));
		document.form1.artClase.value=codigo.substring(codigo.indexOf('-')+1,codigo.lastIndexOf('-'));
		document.form1.invArticulo.value=codigo.substring(codigo.lastIndexOf('-')+1);
		document.form1.descripcion.value=retVal[0];
		document.form1.precio.value=retVal[1];
		document.form1.iType.value='A';
	}
	else alert('El Artículo no existe!');
	return retVal;
}

function getUso(codigo,tipoServicio)
{
	var retVal=splitCols(getDBData('<%=request.getContextPath()%>','descripcion,trim(to_char(nvl(precio_venta,0),\'99999990.00\'))','tbl_sal_uso','codigo='+codigo+' and tipo_servicio=\''+tipoServicio+'\' and compania=<%=session.getAttribute("_companyId")%>',''));
	if (retVal != null)
	{
		var obj = document.form1.tipoServicio;
		document.form1.tipoServicioDesc.value=obj.options[obj.selectedIndex].text;
		obj = document.form1.tipoCds;
		if (obj.value == '') document.form1.tipoCdsDesc.value='---';
		else document.form1.tipoCdsDesc.value=obj.options[obj.selectedIndex].text;
		document.form1.compania.value='<%=(String) session.getAttribute("_companyId")%>';
		document.form1.codUso.value=codigo;
		document.form1.descripcion.value=retVal[0];
		document.form1.precio.value=retVal[1];
		document.form1.iType.value='U';
	}
	else alert('El Uso no existe!');
}

function getProcedimiento(codigo)
{
	var retVal=splitCols(getDBData('<%=request.getContextPath()%>','coalesce(observacion,descripcion),trim(to_char(nvl(precio,0),\'99999990.00\'))','tbl_cds_procedimiento','codigo=\''+codigo+'\'',''));
	if (retVal != null)
	{
		var obj = document.form1.tipoServicio;
		document.form1.tipoServicioDesc.value=obj.options[obj.selectedIndex].text;
		obj = document.form1.tipoCds;
		if (obj.value == '') document.form1.tipoCdsDesc.value='---';
		else document.form1.tipoCdsDesc.value=obj.options[obj.selectedIndex].text;
		document.form1.procedimiento.value=codigo;
		document.form1.descripcion.value=retVal[0];
		document.form1.precio.value=retVal[1];
		document.form1.iType.value='P';
	}
	else alert('El Procedimiento no existe!');
}

function getOtrosCargos(codigo)
{
	var retVal=splitCols(getDBData('<%=request.getContextPath()%>','descripcion,trim(to_char(nvl(precio,0),\'99999990.00\'))','tbl_fac_otros_cargos','codigo='+codigo+' and compania=<%=session.getAttribute("_companyId")%>',''));
	if (retVal != null)
	{
		var obj = document.form1.tipoServicio;
		document.form1.tipoServicioDesc.value=obj.options[obj.selectedIndex].text;
		obj = document.form1.tipoCds;
		if (obj.value == '') document.form1.tipoCdsDesc.value='---';
		else document.form1.tipoCdsDesc.value=obj.options[obj.selectedIndex].text;
		document.form1.compania.value='<%=(String) session.getAttribute("_companyId")%>';
		document.form1.otrosCargos.value=codigo;
		document.form1.descripcion.value=retVal[0];
		document.form1.precio.value=retVal[1];
		document.form1.iType.value='O';
	}
	else alert('El Cargo no existe!');
}

function isValid()
{
	var error = 0;
	if (document.form1.codigo.value == '') error++;
	else if (document.form1.descripcion.value == '') error++;
	else if (document.form1.precio.value == '') error++;

	if (error > 0)
	{
		alert('Por favor introduzca un Gasto No Cubierto válido!');
		return false;
	}
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="1" cellspacing="0">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST,"onSubmit=\"javascript:return(isValid())\"");%>
<%=fb.formStart()%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("planLastLineNo",""+planLastLineNo)%>
<%=fb.hidden("gncLastLineNo",""+gncLastLineNo)%>
<%=fb.hidden("compania","")%>
<%=fb.hidden("artFamilia","")%>
<%=fb.hidden("artClase","")%>
<%=fb.hidden("invArticulo","")%>
<%=fb.hidden("codUso","")%>
<%=fb.hidden("procedimiento","")%>
<%=fb.hidden("otrosCargos","")%>
<%=fb.hidden("cdsProducto","")%>
<%=fb.hidden("tipoServicioDesc","")%>
<%=fb.hidden("tipoCdsDesc","")%>
<%=fb.hidden("iType","")%>
<tr class="TextHeader" align="center">
	<td width="15%"><%=fb.select(ConMgr.getConnection(),"select codigo, '['||codigo||'] '||descripcion, descripcion from tbl_cds_tipo_servicio order by codigo asc","tipoServicio","",false,false,0,"Text10","width:95%",null)%></td>
	<td width="10%"><%=fb.select("tipoCds","I=INTERNO,T=TERCERO,E=EXTERNO","",false,false,0,"Text10","width:95%",null,null,"S")%></td>
	<td width="8%"><%=fb.checkbox("inventarioSino","S",false,false)%></td>
	<td width="15%">
		<%=fb.textBox("codigo","",false,false,false,15,"Text10",null,"onChange=\"javascript:loadDetails()\"")%>
		<%=fb.button("getDetails",">",true,false,"Text10",null,"onClick=\"javascript:loadDetails()\"","Verificar detalles")%>
	</td>
	<td width="37%"><%=fb.textBox("descripcion","",false,false,true,60,"Text10",null,null)%></td>
	<td width="12%"><%=fb.decBox("precio","",false,false,true,13,11.2,"Text10",null,null)%></td>
	<td width="3%"><%=fb.submit("addGNC","+",true,false,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Gasto No Cubierto")%></td>
</tr>
<%=fb.formEnd()%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>
</body>
</html>
<%
}//GET
else
{
	GastoNoCubierto gnc = new GastoNoCubierto();

	gnc.setSecuencia("0");
	gnc.setCompania(request.getParameter("compania"));
	gnc.setArtFamilia(request.getParameter("artFamilia"));
	gnc.setArtClase(request.getParameter("artClase"));
	gnc.setInvArticulo(request.getParameter("invArticulo"));
	gnc.setCodUso(request.getParameter("codUso"));
	gnc.setProcedimiento(request.getParameter("procedimiento"));
	gnc.setOtrosCargos(request.getParameter("otrosCargos"));
	gnc.setCdsProducto(request.getParameter("cdsProducto"));
	gnc.setTipoServicio(request.getParameter("tipoServicio"));
	gnc.setTipoServicioDesc(request.getParameter("tipoServicioDesc"));
	gnc.setTipoCds(request.getParameter("tipoCds"));
	gnc.setTipoCdsDesc(request.getParameter("tipoCdsDesc"));
	System.out.print("*************************"+request.getParameter("inventarioSino"));
	gnc.setInventarioSino(request.getParameter("inventarioSino"));
	gnc.setCodigo(request.getParameter("codigo"));
	gnc.setDescripcion(request.getParameter("descripcion"));
	gnc.setPrecio(request.getParameter("precio"));
	gnc.setCodigo(request.getParameter("codigo"));
	gnc.setDescripcion(request.getParameter("descripcion"));

	String iType = "";
	if (gnc.getProcedimiento() != null && !gnc.getProcedimiento().trim().equals("")) iType = "P";
	else if (gnc.getOtrosCargos() != null && !gnc.getOtrosCargos().trim().equals("")) iType = "O";
	else if (gnc.getCdsProducto() != null && !gnc.getCdsProducto().trim().equals("")) iType = "C";
	else if (gnc.getCodUso() != null && !gnc.getCodUso().trim().equals("")) iType = "U";
	else if (gnc.getHabitacion() != null && !gnc.getHabitacion().trim().equals("")) iType = "H";
	else if (gnc.getInvArticulo() != null && !gnc.getInvArticulo().trim().equals("")) iType = "A";
	if (!vGNC.contains(iType+"-"+gnc.getCodigo()))
	{
		gncLastLineNo++;
		if (gncLastLineNo < 10) key = "00"+gncLastLineNo;
		else if (gncLastLineNo < 100) key = "0"+gncLastLineNo;
		else key = ""+gncLastLineNo;
		gnc.setKey(key);

		try
		{
			iGNC.put(gnc.getKey(),gnc); 
			vGNC.addElement(iType+"-"+gnc.getCodigo());
		}
		catch(Exception ex)
		{
		System.err.println(ex.getMessage());
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	parent.window.location = '../convenio/convenio_config.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&planLastLineNo=<%=planLastLineNo%>&gncLastLineNo=<%=gncLastLineNo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>