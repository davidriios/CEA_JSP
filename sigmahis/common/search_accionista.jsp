<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
 
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String tab = request.getParameter("tab");
String userId = request.getParameter("userId");
String cedula=request.getParameter("cedula");
String referencia=request.getParameter("referencia");
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if(fg==null) fg = "";
if (index==null) index= "";
if (cedula==null) cedula= "";
if (referencia==null) referencia= "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	StringBuffer sbField = new StringBuffer();
	StringBuffer sbTable = new StringBuffer();
	StringBuffer sbFilter = new StringBuffer();
	StringBuffer sbOrder = new StringBuffer(); 
	 
	if(fp.equalsIgnoreCase("paciente"))//Admision creacion de paciente
	{
		sbField.append(" ,a.tipo_id,a.provincia,a.sigla,a.tomo,a.asiento,a.primer_nombre,a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.apellido_de_casada,a.estado_civil, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.religion, a.direccion, a.comunidad, a.corregimiento, a.distrito, a.provincia_dir, a.pais, a.zona_postal, a.apartado_postal, a.celular, a.telefono_trabajo, a.lugar_de_trabajo,  a.correo as e_mail, a.fax  ,(select nacionalidad from tbl_sec_pais b  where  b.codigo = a.nacionalidad  )nacionalidadDesc,(select nvl(d.nombre_comunidad, ' ')     from vw_sec_regional_location d where d.codigo_comunidad=a.comunidad and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and d.codigo_distrito=a.distrito and d.codigo_corregimiento=a.corregimiento and nivel=4) as comunidadNombre,(select nvl(d.nombre_corregimiento, ' ') from vw_sec_regional_location d where d.codigo_corregimiento=a.corregimiento  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and d.codigo_distrito=a.distrito and nivel=3 ) as corregimientoNombre, (select nvl(d.nombre_distrito, ' ')      from vw_sec_regional_location d where d.codigo_distrito=a.distrito  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia_dir and nivel=2) as distritoNombre, (select nvl(d.nombre_provincia, ' ')     from vw_sec_regional_location d where d.codigo_provincia=a.provincia_dir  and d.codigo_pais=a.pais and  nivel =1)  as provincianombre, (select nvl(d.nombre_pais, ' ')          from vw_sec_regional_location d where d.codigo_pais=a.pais and nivel =0) as paisnombre  ");
	}		
	
	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	String apellido = request.getParameter("apellido");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (apellido == null) apellido = "";
	if (!codigo.trim().equals("")) {sbFilter.append(" and upper(a.codigo) like '%");sbFilter.append(codigo.toUpperCase());sbFilter.append("%'");}
	if (!cedula.trim().equals("")) {sbFilter.append(" and upper(a.identificacion) like '%");sbFilter.append(cedula.toUpperCase());sbFilter.append("%'");}	
	if (!nombre.trim().equals("")) {sbFilter.append(" and upper(a.primer_nombre||decode(a.primer_apellido,null,'',' '||a.primer_apellido)) like '%");  
      sbFilter.append(nombre.toUpperCase());sbFilter.append("%'");      
     }
	if (!apellido.trim().equals("")) {sbFilter.append(" and upper(a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))) like '%");sbFilter.append(apellido.toUpperCase());sbFilter.append("%'");}
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select a.codigo, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as apellido, a.estado, a.ruc as identificacion, a.nacionalidad, a.sexo, a.telefono ");
	sbSql.append(sbField);
	sbSql.append(" from tbl_cxc_cliente_particular a where tipo_cliente in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania =a.compania and param_name='POS_TIPO_CLTE_");
	sbSql.append(fg);
	sbSql.append("'),',') from dual  ))  and compania = "); 
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.estado ='A'");
	sbSql.append(sbTable);
	sbSql.append(sbFilter);
	sbSql.append(sbOrder);

		
		
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;
    
    String jsContext = "window.opener.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Accionistas / J. Directiva - '+document.title;
function add(){abrir_ventana2('../admin/accionista_config.jsp?fg=<%=fg%>');}
function edit(id){abrir_ventana2('../admin/accionista_config.jsp?mode=edit&id='+id+'&fg=<%=fg%>');}
function doAction(){}
function setMedico(k)
{
	if (eval('document.medico.estado'+k).value.toUpperCase() == 'I')
	{
		alert('No está permitido seleccionar médicos inactivos!!');
	}
	else
	{
<% if (fp.equalsIgnoreCase("paciente")){%>
    if(window.opener.document.form0.nacionalCode)window.opener.document.form0.nacionalCode.value = eval('document.medico.nacionalidad'+k).value;
	if(window.opener.document.form0.nacional)window.opener.document.form0.nacional.value = eval('document.medico.nacionalidadDesc'+k).value;
	if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.medico.sexo'+k).value;
	if(window.opener.document.form0.telefono)window.opener.document.form0.telefono.value = eval('document.medico.telefono'+k).value;
	if(window.opener.document.form0.primerNom)window.opener.document.form0.primerNom.value = eval('document.medico.primer_nombre'+k).value;	
	if(window.opener.document.form0.segundoNom)window.opener.document.form0.segundoNom.value = eval('document.medico.segundo_nombre'+k).value;
	if(window.opener.document.form0.primerApell)window.opener.document.form0.primerApell.value = eval('document.medico.primer_apellido'+k).value;	
	if(window.opener.document.form0.segundoApell)window.opener.document.form0.segundoApell.value = eval('document.medico.segundo_apellido'+k).value;
	if(window.opener.document.form0.casadaApell)window.opener.document.form0.casadaApell.value = eval('document.medico.apellido_de_casada'+k).value;
	if(window.opener.document.form0.fechaCorrec)window.opener.document.form0.fechaCorrec.value = eval('document.medico.fecha_de_nacimiento'+k).value;
	if(window.opener.document.form0.fechaNaci)window.opener.document.form0.fechaNaci.value = eval('document.medico.fecha_de_nacimiento'+k).value;
	if(window.opener.document.form0.religionCode)window.opener.document.form0.religionCode.value = eval('document.medico.religion'+k).value;
	if(window.opener.document.form0.direccion)window.opener.document.form0.direccion.value = eval('document.medico.direccion'+k).value;
	
	if(window.opener.document.form0.comunidadCode)window.opener.document.form0.comunidadCode.value = eval('document.medico.comunidad'+k).value;
	if(window.opener.document.form0.corregiCode)window.opener.document.form0.corregiCode.value = eval('document.medico.corregimiento'+k).value;
	if(window.opener.document.form0.distritoCode)window.opener.document.form0.distritoCode.value = eval('document.medico.distrito'+k).value;
	if(window.opener.document.form0.provCode)window.opener.document.form0.provCode.value = eval('document.medico.provincia_dir'+k).value;
	if(window.opener.document.form0.paisCode)window.opener.document.form0.paisCode.value = eval('document.medico.pais'+k).value;
	
	if(window.opener.document.form0.comunidad)window.opener.document.form0.comunidad.value = eval('document.medico.comunidadNombre'+k).value;
	if(window.opener.document.form0.corregi)window.opener.document.form0.corregi.value = eval('document.medico.corregimientoNombre'+k).value;
	if(window.opener.document.form0.distrito)window.opener.document.form0.distrito.value = eval('document.medico.distritoNombre'+k).value;
	if(window.opener.document.form0.prov)window.opener.document.form0.prov.value = eval('document.medico.provincianombre'+k).value;
	if(window.opener.document.form0.pais)window.opener.document.form0.pais.value = eval('document.medico.paisnombre'+k).value;
	
	
	if(window.opener.document.form0.zonaPostal)window.opener.document.form0.zonaPostal.value = eval('document.medico.zona_postal'+k).value;
	if(window.opener.document.form0.aptdoPostal)window.opener.document.form0.aptdoPostal.value = eval('document.medico.apartado_postal'+k).value;
	
	//if(window.opener.document.form0.telefono_movil)window.opener.document.form0.telefono_movil.value = eval('document.medico.celular'+k).value;
	if(window.opener.document.form2.telTrabajo)window.opener.document.form2.telTrabajo.value = eval('document.medico.telefono_trabajo'+k).value;
	if(window.opener.document.form2.lugarTrab)window.opener.document.form2.lugarTrab.value = eval('document.medico.lugar_de_trabajo'+k).value;
	if(window.opener.document.form0.e_mail)window.opener.document.form0.e_mail.value = eval('document.medico.e_mail'+k).value;
	if(window.opener.document.form0.fax)window.opener.document.form0.fax.value = eval('document.medico.fax'+k).value;
	if(window.opener.document.form0.ref_id)window.opener.document.form0.ref_id.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.estadoCivil)window.opener.document.form0.estadoCivil.value = eval('document.medico.estado_civil'+k).value;

	window.opener.CalculateAge();
	
	//if(window.opener.document.form0.tipoSangre)window.opener.document.form0.tipoSangre.value = '';
	if(window.opener.document.form0.tipoId)window.opener.document.form0.tipoId.value = eval('document.medico.tipo_id'+k).value;
	window.opener.setId(true);
	if(eval('document.medico.tipo_id'+k).value=='C')
	{
		if(window.opener.document.form0.provincia)window.opener.document.form0.provincia.value = eval('document.medico.provincia'+k).value;
		if(window.opener.document.form0.sigla)window.opener.document.form0.sigla.value = eval('document.medico.sigla'+k).value;
		if(window.opener.document.form0.tomo)window.opener.document.form0.tomo.value = eval('document.medico.tomo'+k).value;
		if(window.opener.document.form0.asiento)window.opener.document.form0.asiento.value = eval('document.medico.asiento'+k).value;
		
	  
  }else
  {
    if(window.opener.document.form0.pasaporte)window.opener.document.form0.pasaporte.value = eval('document.medico.identificacion'+k).value;
  }
  window.opener.isValidId();
	       
<%	
}
%> 
        window.close(); 
}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MEDICO"></jsp:param>
</jsp:include>
 <table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("tab",tab)%> 
		<tr class="TextFilter">	
			<td colspan="3">
				<cellbytelabel id="4">Identificacion</cellbytelabel>
				<%=fb.textBox("cedula",cedula,false,false,false,15,"Text10",null,null)%> 
				<cellbytelabel id="4">Codigo</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,15,"Text10",null,null)%>
			 
				<cellbytelabel id="5">Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40,"Text10",null,null)%> 
				<cellbytelabel id="6">Apellido</cellbytelabel>
				<%=fb.textBox("apellido","",false,false,false,40,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				</td>
		</tr>
 <%=fb.formEnd()%>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
 <table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("cedula",cedula)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("cedula",cedula)%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("medico","", "post","");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cedula",cedula)%>
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel id="5">Nombre</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="6">Apellido</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="6">Identificacion</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String especial = "";
int cont = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre")+" "+cdo.getColValue("apellido"))%>
		<%=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
		
		<%=fb.hidden("nacionalidadDesc"+i,cdo.getColValue("nacionalidadDesc"))%>
		<%=fb.hidden("nacionalidad"+i,cdo.getColValue("nacionalidad"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>

		<%if(fp.equalsIgnoreCase("paciente")){%>		
		
		<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
		<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
		<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
		<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
		<%=fb.hidden("apellido_de_casada"+i,cdo.getColValue("apellido_de_casada"))%>
		<%=fb.hidden("estado_civil"+i,cdo.getColValue("estado_civil"))%>
		<%=fb.hidden("fecha_de_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("religion"+i,cdo.getColValue("religion"))%>
		<%=fb.hidden("direccion"+i,cdo.getColValue("direccion"))%>
		<%=fb.hidden("comunidad"+i,cdo.getColValue("comunidad"))%>
		<%=fb.hidden("corregimiento"+i,cdo.getColValue("corregimiento"))%>
		<%=fb.hidden("distrito"+i,cdo.getColValue("distrito"))%>
		
		<%=fb.hidden("provincia_dir"+i,cdo.getColValue("provincia_dir"))%>
		<%=fb.hidden("pais"+i,cdo.getColValue("pais"))%>
		<%=fb.hidden("zona_postal"+i,cdo.getColValue("zona_postal"))%>
		<%=fb.hidden("apartado_postal"+i,cdo.getColValue("apartado_postal"))%>
		<%=fb.hidden("celular"+i,cdo.getColValue("celular"))%>
		<%=fb.hidden("telefono_trabajo"+i,cdo.getColValue("telefono_trabajo"))%>
		<%=fb.hidden("lugar_de_trabajo"+i,cdo.getColValue("lugar_de_trabajo"))%>
		<%=fb.hidden("e_mail"+i,cdo.getColValue("e_mail"))%>
		<%=fb.hidden("fax"+i,cdo.getColValue("fax"))%>
		<%=fb.hidden("comunidadNombre"+i,cdo.getColValue("comunidadNombre"))%>
		<%=fb.hidden("corregimientoNombre"+i,cdo.getColValue("corregimientoNombre"))%>
		<%=fb.hidden("distritoNombre"+i,cdo.getColValue("distritoNombre"))%>
		<%=fb.hidden("provincianombre"+i,cdo.getColValue("provincianombre"))%>
		<%=fb.hidden("paisnombre"+i,cdo.getColValue("paisnombre"))%> 
		
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%> 
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%> 
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%> 
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%> 
		<%=fb.hidden("tipo_id"+i,cdo.getColValue("tipo_id"))%> 
   
		
<%}%>
		<%if(!fp.equalsIgnoreCase("edit_cita")){%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setMedico(<%=i%>)" style="text-decoration:none; cursor:pointer">
		<%} else {%>
		<tr class="<%=color%>">
		<%}%>
			<td><%=cdo.getColValue("nombre")%> - <%=cdo.getColValue("nacionalidadDesc")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td align="center">&nbsp;</td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("cont",""+cont)%>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("cedula",cedula)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("cedula",cedula)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>