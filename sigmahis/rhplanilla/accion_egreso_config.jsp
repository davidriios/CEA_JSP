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
String desaccion = "";
String key = "";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("edit"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("salario","");
		cdo.addColValue("cargo","");
		cdo.addColValue("comentario","");
		cdo.addColValue("horario","");
		cdo.addColValue("salario","");
		cdo.addColValue("gastorep","");
		cdo.addColValue("sigla","00");
		cdo.addColValue("accion","1");
		cdo.addColValue("estado","T");
		cdo.addColValue("descaccion","EGRESO");
	
       sql = "select a.primer_nombre||' '||a.primer_apellido as nombre, a.num_empleado as numempleado, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento cedula, b.denominacion, a.gasto_rep as gastoRep, a.salario_base as salario, decode(a.estado,null,' ','EGRESO') as desaccion from tbl_pla_empleado a, tbl_pla_cargo b where a.compania = b.compania and a.cargo = b.codigo and a.compania = "+session.getAttribute("_companyId")+" and a.emp_id = "+empid;
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Acción Egreso Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Acción Egreso Edición - "+document.title;
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
	<jsp:param name="title" value="RECURSOS HUMANOS - TRANSACCION - ACCION - EGRESO"></jsp:param>
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
							<td width="20%">Nombre</td>
						  <td width="30%"><%=cdo.getColValue("nombre")%></td>				
							<td width="20%">N&uacute;mero de Empleado </td>
							<td width="30%"><%=cdo.getColValue("numempleado")%></td>
						</tr>	
						<tr class="TextRow01">
							<td width="20%">Cédula</td>
						  <td width="30%"><%=cdo.getColValue("cedula")%></td>				
							<td width="20%">Cargo Actual </td>
							<td width="30%"><%=cdo.getColValue("denominacion")%></td>
						</tr>	
							 <tr class="TextHeader">
                    <td colspan="4">Tipo de Acción</td>
                  </tr>	
				  	<tr class="TextRow01">
							<td>Acci&oacute;n</td>
			                <td colspan=3><%=fb.textBox("desaccion",cdo.getColValue("desaccion"),false,false,true,25)%></td>						
	
						</tr>
				  <tr class="TextHeader">
                    <td colspan="4">Detalle de la Acción </td>
                  </tr>					
				  <tr class="TextRow01">
					<td>Sub-Tipo </td>
			        <td>  <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_ap_sub_tipo  where tipo_accion = 3 order by codigo ","planilla",cdo.getColValue("codigo"))%></td>						
				    <td>Fecha del Egreso </td>
				    <td><jsp:include page="../common/calendar.jsp" flush="true">
					  <jsp:param name="noOfDateTBox" value="1" />
					  <jsp:param name="nameOfTBox1" value="fecha" />
					  <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
					  </jsp:include></td>	
				  </tr>						
						<tr class="TextRow01" >
							<td>Causal del Hecho </td>
							<td><%=fb.textarea("causal",cdo.getColValue("causal"),false,false,false,30,4)%></td>				
							<td>Comentarios </td>
							<td><%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,false,30,4)%></td>
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
	cdo.setTableName("tbl_pla_ap_accion_per");
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