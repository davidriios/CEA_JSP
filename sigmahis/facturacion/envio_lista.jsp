<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.Factura"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="FACMgr" scope="session" class="issi.facturacion.FacturaMgr" />
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
FACMgr.setConnection(ConMgr);
Factura fact = new Factura();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String fg=request.getParameter("fg");
String empresa=request.getParameter("empresa");
String fecha=request.getParameter("fecha");
String lista=request.getParameter("lista");
String categoria=request.getParameter("categoria");
String facturar=request.getParameter("tipo");
String existe=request.getParameter("existe");

if(empresa == null)empresa ="";
if(fecha == null)fecha ="";
if(lista == null)lista ="";
if(categoria == null)categoria ="";
if(facturar == null)facturar ="";
if(existe == null)existe ="N";


if(fg == null)fg ="FAC";
String dep = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(fg.trim().equals("FAC")) dep = "FACTURACIÓN";

if(!empresa.trim().equals("") && !fecha.trim().equals("")&& !lista.trim().equals("")&& !categoria.trim().equals("")&& !facturar.trim().equals(""))
{

	 sql="select compania,to_char(fecha_envio,'dd/mm/yyyy') fechaEnvio,facturar_a facturarA,aseguradora codEmpresa, categoria categoriaAdmi, lista, comentario, enviado_por enviado,usuario_creacion usuarioCreacion, fecha_creacion fechaCreacion,(select nombre from tbl_adm_empresa where codigo ="+empresa+")empresa from tbl_fac_lista where trunc(fecha_envio)= to_date('"+fecha+"','dd/mm/yyyy') and aseguradora = "+empresa+"  and categoria = "+categoria+" and facturar_a = '"+facturar+"'";
	System.out.println("SQL=== "+sql);
	 fact = (Factura) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Factura.class);


}else
{
	fact = new Factura();
	fact.setFechaEnvio("");
	fact.setEnviado(""+(String) session.getAttribute("_userName"));
	fact.setFacturadoPor("FACTURACION");
	fact.setUsuarioCreacion(""+(String) session.getAttribute("_userName"));
	fact.setFechaCreacion(cDateTime);
}
fact.setFacturadoPor("FACTURACION");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Envio de Lista- "+document.title;
function showEmpresa()
{
 var fecha = document.form0.fecha.value;
 if(fecha=='')CBMSG.warning('Seleccione fecha de Envío');
 else abrir_ventana1('../common/search_empresa.jsp?fp=listaEnvio&fEnvio='+fecha);
}
function showLista()
{
 var fecha = document.form0.fecha.value;
 var categoria = document.form0.categoria.value;
 var facturado_a = document.form0.tipo.value;
 var empresa = document.form0.empresa.value;
 var fp ='';

 if(fecha=='')CBMSG.warning('Seleccione fecha de Envío');
 else{
 if(categoria=='1')fp='listaEnvioH';
  else fp='listaEnvioA';

  abrir_ventana1('../facturacion/sel_list_envio.jsp?fp='+fp+'&fEnvio='+fecha+'&categoria='+categoria+'&facturado_a='+facturado_a+'&empresa='+empresa);

  }
}
function validateLista(value)
{//CBMSG.warning();

	 var categoria = document.form0.categoria.value;
	 var facturado_a = document.form0.tipo.value;
	 var empresa = document.form0.empresa.value;
	 var comentario='',sql='';
	 var fecha = document.form0.fecha.value;
	 var msg ='';
	if(empresa =='')msg +=' Empresa\n'
	if(fecha =='')msg +='          Fecha de Envio\n'
	if(msg!=''){CBMSG.warning('Seleccione :  '+msg);}
	else
	{
	if(value != null && value !='')
	{
		if(categoria =='1')
		{
				sql=' and b.categoria in (1,5) and facturar_a=\''+facturado_a+'\'';
		}
		else
		{
				sql=' and b.categoria = \''+categoria+'\'';
		}


		if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura a,tbl_adm_admision b','a.cod_empresa='+empresa+' and to_date(to_char(a.fecha_envio,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\') and a.pac_id = b.pac_id and a.admi_secuencia = b.secuencia and a.lista= '+value+' '+sql))
		{
			//CBMSG.warning();

			var comentario = getDBData('<%=request.getContextPath()%>','distinct comentario','tbl_fac_lista','compania=<%=(String) session.getAttribute("_companyId")%> and trunc(fecha_envio)=to_date(\''+fecha+'\',\'dd/mm/yyyy\') and aseguradora='+empresa+' and categoria='+categoria+' and lista='+value+'','');
			document.form0.observacion.value=comentario;
			document.form0.existe.value='S';


		}
		else
		{
		 	CBMSG.warning('Número de lista no existe, Verifique');
			//document.form0.lista.value='';
			document.form0.existe.value='N';
		}

	}
	else{ CBMSG.warning('Escoja una categoria de admisión o no existen listas para la categoria seleccionada ');}
}

}

function showInactivar()
{
  abrir_ventana1('../facturacion/list_inactivar_lista.jsp');
 // abrir_ventana1('../facturacion/print_lista_envio.jsp?fg=<%=fg%>&empresa=<%=empresa%>&fecha=<%=fecha%>&lista=<%=lista%>&categoria=<%=categoria%>&tipo=<%=facturar%>&existe=<%=existe%>');


}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ENVIO DE LISTA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("existe",""+existe)%>
			<%=fb.hidden("usuarioCrea",""+fact.getUsuarioCreacion())%>
			<%=fb.hidden("fechaCrea",""+fact.getFechaCreacion())%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".existe.value=='N'){CBMSG.warning('El numero de lista No existe Verifique!');}");%>

			<tr class="TextHeader">
				<td colspan="4"><cellbytelabel>Lista de Env&iacute;o</cellbytelabel></td>
			</tr>

			<tr class="TextRow01" >
				<td width="20%"><cellbytelabel>Departamento</cellbytelabel>: </td>
				<td width="85%" colspan="3"><%=fb.textBox("departamento",fact.getFacturadoPor(),false,false,true,50)%></td>

			</tr>
			<tr class="TextRow01" >
				<td width="20%"><cellbytelabel>Fecha de Env&iacute;o</cellbytelabel>: </td>
				<td width="30%">

					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="format" value="dd/mm/yyyy"/>
					<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
					<jsp:param name="clearOption" value="true" />

					<jsp:param name="valueOfTBox1" value="<%=fact.getFechaEnvio()%>" />
					</jsp:include>

					</td>
				<td width="20%"><cellbytelabel>Facturas A</cellbytelabel>: </td>
				<td width="30%"><%=fb.select("tipo","E=EMPRESA,P=PACIENTE",fact.getFacturarA())%></td>
			</tr>
			<tr class="TextRow01" >
				<td><cellbytelabel>Compa&ntilde;&iacute;a de Seguros</cellbytelabel>: </td>
				<td colspan="3"><%=fb.textBox("empresa",fact.getCodEmpresa(),true,false,true,5)%>
					<%=fb.textBox("nombreEmpresa",fact.getEmpresa(),false,false,true,30)%>
					<%=fb.button("btnEmpresa","...",true,false,null,null,"onClick=\"javascript:showEmpresa();\"")%></td>
			</tr>



			<tr class="TextRow01" >
				<td><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
				<td colspan="3"><%=fb.select("categoria","1=PACIENTES HOSPITALIZADOS,2=PACIENTES AMBULATORIOS,3=ESPECIAL,4=GERIATRIA",fact.getCategoriaAdmi())%></td>
			</tr>

			<tr class="TextRow01" >
				<td><cellbytelabel>Lista</cellbytelabel></td>
				<td colspan="3"><%=fb.textBox("lista",fact.getLista(),true,false,false,5,10,null,null,"onBlur=\"javascript:validateLista(this.value)\"")%>

					<%//=fb.textBox("descEmpresa",cdo.getColValue("descEmpresa"),false,false,false,30)%>
					<%=fb.button("btnLista","...",true,false,null,null,"onClick=\"javascript:showLista();\"")%></td>
			</tr>

			<tr class="TextRow01">
				<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
				<td colspan="3">
				<%=fb.textarea("observacion",fact.getComentario(),false,false,false,70,7,2000,null,null,null)%>
				<%//=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,(!cdo.getColValue("valor").equalsIgnoreCase("S")),viewMode,50,2,2000,null,"width='100%'",null)%>
				</td>

			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Enviado por</cellbytelabel>: </td>
				<td colspan="2"><%=fb.textBox("enviado_por",fact.getEnviado(),false,false,true,50,100)%></td>
				<td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("btnInactivar","Inactivar Lista",true,false,null,null,"onClick=\"javascript:showInactivar();\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
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
else
{

   existe = request.getParameter("existe");
  String baction = request.getParameter("baction");
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

  Factura fc = new Factura();

  fc.setCompania((String) session.getAttribute("_companyId"));
  fc.setFechaEnvio(request.getParameter("fecha"));
  fc.setFacturarA(request.getParameter("tipo"));
  fc.setCodEmpresa(request.getParameter("empresa"));
  fc.setCategoriaAdmi(request.getParameter("categoria"));
  fc.setLista(request.getParameter("lista"));
  fc.setComentario(request.getParameter("observacion"));
  fc.setEnviado(request.getParameter("enviado_por"));
  fc.setUsuarioModificacion((String) session.getAttribute("_userName"));
  fc.setUsuarioCreacion((String) session.getAttribute("_userName"));

	//FACMgr.enviarLista(fc,existe);


%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (FACMgr.getErrCode().equals("1"))
{
%>
	alert('<%=FACMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/analista_cobranza_list.jsp"))
	{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/analista_cobranza_list.jsp")%>';
<%
	}
	else
	{
%>
	//window.opener.location = '<%=request.getContextPath()%>/facturacion/analista_cobranza_list.jsp';
<%
	}
%>
abrir_ventana1('../facturacion/print_lista_envio.jsp?fg=<%=fg%>&empresa=<%=empresa%>&fecha=<%=fecha%>&lista=<%=lista%>&categoria=<%=categoria%>&tipo=<%=facturar%>&existe=<%=existe%>');
<%

if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(FACMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{


window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&empresa=<%=empresa%>&fecha=<%=fecha%>&lista=<%=lista%>&categoria=<%=categoria%>&tipo=<%=facturar%>&existe=<%=existe%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
