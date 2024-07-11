<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================
800007	AGREGAR UNIDAD ADMINISTRATIVA
800008	MODIFICAR UNIDAD ADMINISTRATIVA
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800007") || SecMgr.checkAccess(session.getId(),"800008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");UserDet = SecMgr.getUserDetails(session.getId());

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String empid=request.getParameter("empid");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String accion = request.getParameter("accion");
String descaccion = "";
String key = "";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (mode.equalsIgnoreCase("add"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		cdo.addColValue("fechaefetiva",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("salario","");
		cdo.addColValue("cargo","");
		cdo.addColValue("comentario","");
		cdo.addColValue("horario","");
		cdo.addColValue("salario","");
		cdo.addColValue("gastorep","");
		cdo.addColValue("sigla","00");
		cdo.addColValue("accion","1");
		cdo.addColValue("descaccion","INGRESO");
	
       sql = "select primer_nombre||' '||primer_apellido as nombre, num_empleado as numempleado from tbl_pla_empleado ";

/*
		sql = "select a.compania, a.codigo, a.descripcion, a.direccion, a.corregimiento, a.distrito, a.provincia, a.pais, a.telefono, a.extension , a.fax, nvl(a.email,'CORREO@EMAIL.COM') as email, nvl(a.ue_codigo,'0') as reporte , a.ue_compania, nvl(a.nivel,'0') as nivel, a.area, a.depto_preelab as cPrelacion, b.codigo as cod, b.nombre as company,  g.codigo as cos, g.descripcion as nDescrip,c.CODIGO_PAIS, c.NOMBRE_PAIS as paNombre, c.CODIGO_PROVINCIA, c.NOMBRE_PROVINCIA as pNombre, c.CODIGO_DISTRITO, c.NOMBRE_DISTRITO as dNombre, c.CODIGO_CORREGIMIENTO, c.NOMBRE_CORREGIMIENTO as cNombre, h.CODIGO as cods, nvl(h.DESCRIPCION,'NA') as nom from tbl_sec_unidad_ejec a, tbl_sec_compania b, vw_sec_regional_location c, tbl_sec_nivel_unidadej g, tbl_sec_unidad_ejec h where a.compania=b.codigo and a.nivel=g.codigo(+) and a.pais= c.CODIGO_PAIS(+) and a.provincia=c.CODIGO_PROVINCIA(+) and a.distrito=c.CODIGO_DISTRITO(+) and a.corregimiento=c.CODIGO_CORREGIMIENTO(+) and a.codigo="+id;
		*/
		cdo = SQLMgr.getData(sql);
	}
	
		if (mode.equalsIgnoreCase("edit"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		cdo.addColValue("fechaefetiva",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("salario","");
		cdo.addColValue("cargo","");
		cdo.addColValue("comentario","");
		cdo.addColValue("horario","");
		cdo.addColValue("salario","");
		cdo.addColValue("gastorep","");
		cdo.addColValue("sigla","00");
		cdo.addColValue("accion","1");
		cdo.addColValue("descaccion","INGRESO");
	
       sql = "select a.primer_nombre||' '||a.primer_apellido as nombre, a.num_empleado as numempleado, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento cedula, b.denominacion from tbl_pla_empleado a, tbl_pla_cargo b where a.compania = b.compania and a.cargo = b.codigo and a.compania = "+session.getAttribute("_companyId")+" and a.emp_id = "+empid;
	cdo = SQLMgr.getData(sql);
	}
	
%>
<html> 
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Acción Ascenso Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Acción Ascenso Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function agregar()
{
abrir_ventana1('../admin/ubic_geografica_list.jsp?fp=unidadAdmin');
}

function cargos()
{
abrir_ventana1('../rhplanilla/list_cargos.jsp');
}

function horario()
{
abrir_ventana1('../rhplanilla/list_horarios.jsp');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>  
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>


 <tr> 
		<td> 
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
			
				<tr> 
					<td> 	
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">				
							 <tr class="TextHeader">
                    <td colspan="4">Datos del Empleado</td>
                  </tr>						
						<tr class="TextRow01">
							<td width="9%">Nombre</td>
							<td width="35%"><%=cdo.getColValue("nombre")%></td>				
							<td width="21%">N&uacute;mero de Empleado </td>
							<td width="35%"><%=cdo.getColValue("numempleado")%></td>
						</tr>	
						<tr class="TextRow01">
							<td width="9%">Cédula</td>
							<td width="35%"><%=cdo.getColValue("cedula")%></td>				
							<td width="21%">Cargo Actual </td>
							<td width="35%"><%=cdo.getColValue("denominacion")%></td>
						</tr>	
							 <tr class="TextHeader">
                    <td colspan="4">Tipo de Acción</td>
                  </tr>	
				  	<tr class="TextRow01">
							<td>Acci&oacute;n</td>
			                <td colspan=3><%=cdo.getColValue("accion")%><%=cdo.getColValue("desaccion")%></td>						
	
						</tr>
				  						 <tr class="TextHeader">
                    <td colspan="4">Detalle de la Acción</td>
                  </tr>					
						<tr class="TextRow01">
							<td>Cargo</td>
			                <td><%=fb.intBox("nivel",cdo.getColValue("nivel"),false,false,true,10)%><%=fb.textBox("nDescrip",cdo.getColValue("nDescrip"),false,false,true,25)%><%=fb.button("enviar","...",true,false,null,null,"onClick=\"javascript:cargos();\"")%></td>						
							<td>Horario</td>
							<td><%=fb.intBox("reporte",cdo.getColValue("reporte"),false,false,true,10)%><%=fb.textBox("nom",cdo.getColValue("nom"),false,false,true,25)%><%=fb.button("report","...",true,false,null,null,"onClick=\"javascript:horario();\"")%></td>	
						</tr>						
						<tr class="TextRow01" >
							<td>Salario</td>
							<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,30)%></td>				
							<td>Gasto de Representaci&oacute;n </td>
							<td><%=fb.textBox("extension",cdo.getColValue("extension"),false,false,false,10)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Comentario</td>
							<td><%=fb.intBox("area",cdo.getColValue("area"),false,false,false,40)%></td>				
							<td>Fecha Efectiva </td>
							<td><%=fb.textBox("email",cdo.getColValue("email"),false,false,false,30)%></td>
						</tr>
				    </table>
				   </div>
				  </td>
				</tr>
			</table>			
		</td>
	</tr>				

	<tr class="TextRow02">
		<td align="right"><%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	<tr>
<%=fb.formEnd(true)%>
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
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_pla_ap_accion_enc");
	cdo.addColValue("tipo_accion",request.getParameter("tipoAccion"));
	cdo.addColValue("sub_t_accion",request.getParameter("subAccion"));
	cdo.addColValue("fecha_doc",request.getParameter("fecha"));
	cdo.addColValue("estado",request.getParameter("estado"));	
	if (request.getParameter("documento") != null)
	cdo.addColValue("t_documento",request.getParameter("documento"));
	if (request.getParameter("numero") != null) 
	cdo.addColValue("num_documento",request.getParameter("numero"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	
	
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
        cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));	
		//cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		//cdo.setAutoIncCol("codigo");

		SQLMgr.insert(cdo);
	}
	else
	{
	    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and fecha_doc="+request.getParameter("fecha"));

		SQLMgr.update(cdo);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_accionmove.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_accionmove.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_accionmove.jsp';
<%
	}
%>
	//window.opener.location.reload(true);
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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