<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";

boolean viewMode = false;
String displayCob = " style=\"display:none\"";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mode = request.getParameter("mode");
String consecutivo = request.getParameter("consecutivo");
String compania =(String)session.getAttribute("_companyId");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode=true;

if (request.getMethod().equalsIgnoreCase("GET"))
{


if (mode.equalsIgnoreCase("add"))
{
consecutivo = "0";
cdo = new CommonDataObject();
cdo.addColValue("fecha",cDateTime.substring(0,10));
cdo.addColValue("usuario",(String) session.getAttribute("_userName"));
if (!viewMode) mode = "add";
}
else
{
			if (consecutivo == null || compania == null) throw new Exception("Los datos del Depósito no son válido. Por favor intente nuevamente!");

sql="SELECT f.COMPANIA,f.codigo, to_char(f.F_MOVIMIENTO,'dd/mm/yyyy')as fecha, nvl(f.MONTO,'')as monto,f.TURNO, f.CAJA, f.OBSERVACION, f.USUARIO,ca.descripcion as  nombrecaja FROM TBL_CON_MOVIM_FALTANTE f, tbl_cja_cajas ca  where f.codigo="+consecutivo+"  and ca.codigo=f.caja(+) and f.compania= "+compania;

cdo = SQLMgr.getData(sql);

if (!viewMode) mode = "edit";

}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Captura de Faltantes - '+document.title;
function doAction(){<%if(!mode.trim().equals("view")){%>setTurno();<%}%>}
function CheckFecha()
{
		var x=0;
		var com = eval('document.form0.compania').value;
		var fecha = '<%=cDateTime.substring(0,10)%>';
		var com = getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+com+' and  nvl(comprobante,\'A\')= \'S\' and trunc(fecha)>=to_date(\''+fecha+'\',\'dd/mm/yyyy\') and trunc(fecha)<=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');
		if(com !="0")
		{
			alert('Esta fecha ya esta Procesada en el Departamento de Contabilidad...');
			x++;
		}
		if(x>0)	return false;
			else return true;
}
function setTurno(){
	var caja = document.form0.caja.value;
	var turno = getDBData('<%=request.getContextPath()%>', 'cod_turno', 'tbl_cja_turnos_x_cajas', 'estatus in(\'A\',\'T\') and cod_caja = '+caja+' and compania = <%=(String) session.getAttribute("_companyId")%> and cod_turno in (select codigo from tbl_cja_turnos where cja_cajera_cod_cajera in (select cod_cajera from tbl_cja_cajera where compania = <%=(String) session.getAttribute("_companyId")%> and usuario = \'<%=(String) session.getAttribute("_userName")%>\'))');
	if(turno==''){
		alert('Esta Caja/Usuario no tiene Turno!');
		form0BlockButtons(true);
	} else {
		document.form0.turno.value = turno;
		form0BlockButtons(false);
	}
}
function checkEstado(){var fecha = document.form0.fecha.value;var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.form0.fecha.value='';return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAPTURA DE FALTANTES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("consecutivo",consecutivo)%>
			<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
				<tr class="TextHeader">
							<td colspan="4">&nbsp;</td>
				</tr>

				<!--
				<tr class="TextRow01">
					<td width="20%">Compañia</td>
					<td width="40%">
					<%//=fb.textBox("name_compania",cdo.getColValue("nombrecompania"),false,false,true,30)%>
					<%//=fb.button("addCompania","...",true,false,null,null,"onClick=\"javascript:showCompania()\"","Agregar Compañia")%></td>
					<td width="20%">&nbsp;</td>
  				<td width="20%"><%//=fb.intBox("consecutivo","",false,false,true,15,4)%></td>
				</tr>
				-->

				<tr class="TextRow01">
					<td><cellbytelabel>Caja</cellbytelabel></td>
					<td colspan="3">
					<%StringBuffer sbSql = new StringBuffer();
						sbSql.append(" and codigo in (");
							if(session.getAttribute("_codCaja")!=null)
								sbSql.append(session.getAttribute("_codCaja"));
							else sbSql.append("-1");
						sbSql.append(")");%>

					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+((!viewMode)?sbSql.toString():"")+" order by descripcion asc","caja",cdo.getColValue("caja"),false,viewMode,0,null,null,"onChange=\"javascript:setTurno();\"")%>

  				<%//=fb.textBox("caja",cdo.getColValue("caja"),true,false,true,10)%>
					<%//=fb.textBox("name_caja",cdo.getColValue("nombrecaja"),false,false,true,30)%>
				</tr>
				<!--
				<tr class="TextRow01">
					<td><cellbytelabel>Banco</cellbytelabel></td>
					<td><%//=fb.textBox("banco",cdo.getColValue("banco"),true,false,true,10)%>
					<%//=fb.textBox("name_banco",cdo.getColValue("nombrebanco"),false,false,true,30)%>
					<%//=fb.button("addBanco","...",true,false,null,null,"onClick=\"javascript:showBanco()\"","Agregar Banco")%></td>
					<td>&nbsp;</td><td>&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td colspan="3">
  				<%//=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,10)%>
					<%//=fb.textBox("name_cuenta",cdo.getColValue("nombrecuenta"),false,false,true,30)%>
				</tr>-->
				<tr class="TextRow01">
					<td><cellbytelabel>Turno</cellbytelabel></td>
					<td><%=fb.intBox("turno",cdo.getColValue("turno"),false,viewMode,true,20,12)%></td>
					<td><cellbytelabel>Cajero</cellbytelabel></td>
					<td><%=fb.textBox("cajero",cdo.getColValue("usuario"),false,viewMode,true,20,15)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Monto del Faltante</cellbytelabel></td>
					<td><%=fb.decBox("monto",cdo.getColValue("monto"),false,viewMode,false,20,8.2)%></td>
					<td>&nbsp;</td><td>&nbsp;</td>
				</tr>
				<tr class="TextRow01">
						<td align="right"><cellbytelabel>Observación</cellbytelabel></td>
						<td colspan="2"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,viewMode,false,60,3,200,"","width:100%","")%></td>
						<td>
						<%String checkEstado = "javascript:checkEstado();newHeight();";%>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="jsEvent" value="<%=checkEstado%>" />
						<jsp:param name="onChange" value="<%=checkEstado%>" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"N"%>" />
						</jsp:include></td>

				</tr>



	<%//fb.appendJsValidation("if(error>0)doAction();");%>

		<%fb.appendJsValidation("\n\tif (!CheckFecha()) error++;\n");%>

	<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!-----><%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>
<%fb.appendJsValidation("if(!checkEstado()){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");%>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	compania = request.getParameter("compania");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_CON_MOVIM_FALTANTE");
					if(request.getParameter("observacion") !=null && !request.getParameter("observacion").trim().equals(""))
					cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
					else
					{
							cdo.addColValue("OBSERVACION","REGISTRO DE FALTANTES");
					}
					//cdo.addColValue("BANCO",request.getParameter("banco"));
					//cdo.addColValue("CUENTA_BANCO",request.getParameter("cuenta"));
					cdo.addColValue("CAJA",request.getParameter("caja"));
					cdo.addColValue("turno",request.getParameter("turno"));
					cdo.addColValue("MONTO",request.getParameter("monto"));
					cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
					cdo.addColValue("FECHA_MODIFICACION",cDateTime);

					if (mode.equalsIgnoreCase("add"))
					{
							cdo.addColValue("COMPANIA",request.getParameter("compania"));
							cdo.addColValue("F_MOVIMIENTO",request.getParameter("fecha"));
							cdo.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName"));
							cdo.addColValue("FECHA_CREACION",cDateTime);
							if(request.getParameter("cajero") !=null && !request.getParameter("cajero").trim().equals(""))
							cdo.addColValue("USUARIO",request.getParameter("cajero"));
							else cdo.addColValue("USUARIO",(String) session.getAttribute("_userName"));
							cdo.setAutoIncWhereClause("compania="+request.getParameter("compania"));
							cdo.setAutoIncCol("codigo");
							cdo.addPkColValue("codigo","");
							ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							SQLMgr.insert(cdo);
							consecutivo = SQLMgr.getPkColValue("codigo");
							ConMgr.clearAppCtx(null);
					}
					else if (mode.equalsIgnoreCase("edit"))
					{
						 consecutivo = request.getParameter("consecutivo");
						 cdo.setWhereClause("compania="+request.getParameter("compania")+" and codigo="+consecutivo);
						 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						 SQLMgr.update(cdo);
						 ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/registro_faltantes_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/registro_faltantes_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/registro_faltantes_list.jsp';
<%
		}

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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&compania=<%=compania%>&consecutivo=<%=consecutivo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>