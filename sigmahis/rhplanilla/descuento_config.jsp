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
REGISTRO DE DESCUENTO DE EMPLEADO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500011") || SecMgr.checkAccess(session.getId(),"500012"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();
ArrayList al2= new ArrayList(); // detalle de descuentos - historial
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id"); 			  // id del descuento
String empId= request.getParameter("empId");
String fecharec="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String tab = request.getParameter("tab");
boolean viewMode = false;
if (mode == null) mode = "add";
if (tab == null) tab = "0";
if(mode.trim().equals("view"))viewMode=true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		fecharec = cDateTime.substring(0,10);
	}
	else
	{
		if (empId == null || id == null) throw new Exception("Empleado o Descuento no es válido. Por favor intente nuevamente!");

		sql = "select b.nombre_empleado, b.cedula1, a.provincia, a.sigla, a.tomo, a.asiento, a.num_descuento , a.cod_grupo, a.cod_acreedor, a.estado, to_char(a.monto_total,'99999990.00') as monto_total, to_char(a.saldo,'99999990.00') as saldo, to_char(a.descontado,'99999990.00') as descontado,  to_char(a.descuento_mensual,'99,999,990.00') as descuento_mensual, to_char(a.descuento1,'99,999,990.00') as descuento1, to_char(a.descuento2,'99,999,990.00') as descuento2, to_char(a.fecha_inicial,'dd/mm/yyyy') as fecharec, a.num_documento, to_char(a.fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_mod,'dd/mm/yyyy') fecha_mod, a.usuario_mod,a.cod_compania, a.observaciones, a.num_cuenta, a.tipo_cuenta, a.autoriza_descto_cia, a.autoriza_descto_anio, a.autoriza_descto_codigo, a.emp_id, b.primer_nombre, b.primer_apellido, b.unidad_organi, c.descripcion as unidadName, b.salario_base, b.rata_hora, d.nombre as grupoaName,e.nombre as acredorName, b.emp_id from tbl_pla_descuento a, vw_pla_empleado b, tbl_pla_grupo_descuento d, tbl_pla_acreedor e, tbl_sec_unidad_ejec c where a.provincia=b.provincia and a.sigla=b.sigla and a.tomo=b.tomo and a.asiento=b.asiento and a.cod_compania=b.compania(+) and a.cod_grupo=d.cod_grupo(+) and a.cod_acreedor=e.cod_acreedor(+) and a.COD_COMPANIA=e.compania(+) and b.unidad_organi=c.codigo(+) and a.cod_compania = c.compania and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId+" and a.num_descuento="+id+" order by a.fecha_inicial desc ";;
		cdo = SQLMgr.getData(sql);
		fecharec = cdo.getColValue("fecharec");

		if(empId != null && id != null )
		{
			sql=" select (select pd.nombre from  tbl_pla_planilla pd where pd.compania = pa.cod_compania and pd.cod_planilla = pa.da_cod_planilla ) planilladescto, pe.fecha_pago, to_char(pe.fecha_pago,'dd/mm/yyyy') as fechaPagoDesc, to_char(da.monto,'99,990.00') as montoDesc, da.monto, pa.num_cheque   from   tbl_pla_descuento_aplicado da, tbl_pla_planilla_encabezado pe, tbl_pla_pago_acreedor pa where   pa.cod_acreedor= da.cod_acreedor  and    pa.da_anio = da.anio    and    pa.da_cod_planilla = da.cod_planilla and  pa.da_num_planilla = da.num_planilla   and    pa.cod_compania= da.cod_compania   and   pe.anio = pa.anio    and    pe.cod_planilla= pa.cod_planilla   and   pe.num_planilla= pa.num_planilla   and    pe.cod_compania = da.cod_compania  and da.emp_id= "+empId+"  and  da.num_descuento= "+id+" order by pe.fecha_pago ";
			al2 = SQLMgr.getDataList(sql);
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">

document.title="Descuento de Empleados - Agregar - "+document.title;

function showEmpleadoList(){ abrir_ventana1('../common/search_empleado.jsp?fp=descuento');}
function grup(){ abrir_ventana1('../common/search_grupo_descuento.jsp?fp=descuento'); }
function acred(){ abrir_ventana1('../common/search_acreedor.jsp?fp=descuento'); }
function printHist(){ abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_descuento_hist.rptdesign'); }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class ="dhtmlgoodies_aTab">

	<table align="center" width="99%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
	<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
	<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
	<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
	<%=fb.hidden("num_empleado",cdo.getColValue("num_empleado"))%>
	<%=fb.hidden("tab","0")%>
	<%=fb.hidden("baction","")%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>

			<tr class="TextHeader">
				<td colspan="4">&nbsp;Generales de Empleado</td>
			</tr>

			<tr class="TextRow01">
				<td width="15%">&nbsp;Nombre:</td>
				<td width="35%">&nbsp;<%=fb.textBox("nombre_empleado",cdo.getColValue("nombre_empleado"),false,false,true,40,45)%></td>
				<td width="15%">&nbsp;C&eacute;dula</td>
				<td width="35%">&nbsp;<%=fb.textBox("cedula",cdo.getColValue("cedula1"),true,false,true,20,25)%>
					<%=fb.button("btnEmpleado","...",true,viewMode,null,"Text10","onClick=\"javascript:showEmpleadoList()\"")%></td>
			</tr>

			<tr class="TextRow01">
				<td>&nbsp;Departamento:</td>
				<td>&nbsp;<%=fb.textBox("unidadName",cdo.getColValue("unidadName"),false,false,true,50,55)%></td>
				<td>&nbsp;Salario Base:</td>
				<td>&nbsp;<%=fb.textBox("salario",cdo.getColValue("salario_base"),false,false,true,10,15)%></td>
			</tr>

			<tr class="TextHeader">
				<td colspan="4">&nbsp;Generales de Descuento</td>
			</tr>

			<tr>
				<td colspan="4">
				<table width="100%">
					<tr class="TextHeader" align="center">
						<td width="10%">N&uacute;m.</td>
						<td align="center"  colspan="2">Grupo de Descuento</td>
						<td align="center" colspan="3">Acreedor</td>
						<td width="4%" >&nbsp;</td>
					</tr>

					<tr class="TextRow02">
						<td align="center"><%=fb.intBox("id",id,true,false,true,5,3,"Text10",null,null)%></td>
						<td colspan="2"><%=fb.intBox("cod_grupo",cdo.getColValue("cod_grupo"),true,false,true,5,2,"Text10",null,null)%>
							<%=fb.textBox("grupoaName",cdo.getColValue("grupoaName"),false,false,true,60,200,"Text10",null,null)%><%=fb.button("btngrupo","...",true,viewMode,"Text10", null,"onClick=\"javascript:grup();\"" )%>	</td>
						<td colspan="3"><%=fb.intBox("cod_acreedor",cdo.getColValue("cod_acreedor"),true,false,true,5,3,"Text10",null,null)%><%=fb.textBox("acredorName",cdo.getColValue("acredorName"),false,false,true,60,200,"Text10",null,null)%>
							<%=fb.button("btnacredor","...",true,viewMode,"Text10", null,"onClick=\"javascript:acred();\"" )%></td>
						<td align="center" rowspan="6">&nbsp;</td>
					</tr>

					<tr class="TextRow02">
						<td >Monto Total:</td>
						<td><%=fb.decBox("monto_total",cdo.getColValue("monto_total"),true,false,viewMode,15,15.2)%></td>
						<td>Descuento Mensual:</td>
						<td><%=fb.decBox("descuento_mensual",cdo.getColValue("descuento_mensual"),true,false,viewMode,15,10.2,"",null,null)%></td>
						<td>Estado:</td>
						<td><%=fb.select("estado","D=DESCONTAR,E=ELIMINAR, N=NO DESCONTAR, P=PENDIENTE", cdo.getColValue("estado"),false,viewMode,0,"",null,null)%></td>
					</tr>

					<tr class="TextRow02">
						<td>Saldo Desc.:</td>
						<td><%=fb.decBox("saldo",cdo.getColValue("saldo"),true,false,viewMode,15,15.2)%></td>
						<td>1ra. Quincena</td>
						<td><p><%=fb.decBox("descuento1",cdo.getColValue("descuento1"),true,false,viewMode,15,10.2,"",null,null)%></p> </td>
						<td>Fecha Inicial:</td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1"/>
											<jsp:param name="nameOfTBox1" value="fechaInicial"/>
											<jsp:param name="format" value="dd/mm/yyyy"/>
											<jsp:param name="valueOfTBox1" value="<%=fecharec%>" />
											</jsp:include></td>
					</tr>

					<tr class="TextRow02">
						<td>Descontado:</td>
						<td><%=fb.decBox("descontado",cdo.getColValue("descontado"),true,false,viewMode,15,15.2)%></td>
						<td>2da. Quincena</td>
						<td><%=fb.decBox("descuento2",cdo.getColValue("descuento2"),true,false,viewMode,15,10.2,"",null,null)%></td>
						<td>N&uacute;m. de Doc.:</td>
						<td><%=fb.textBox("num_documento",cdo.getColValue("num_documento"), false,false,viewMode,15,35,"",null,null)%></td>
					</tr>

					<tr class="TextRow02">
						<td rowspan="2">Observaciones:</td>
						<td colspan="3" rowspan="2"><%=fb.textarea("observaciones",cdo.getColValue("observaciones"),false,false,viewMode,60,3,2000,"",null,null)%></td>
						<td>No. de Cta:</td>
						<td><%=fb.textBox("num_cuenta", cdo.getColValue("num_cuenta"),false,false,viewMode,20,20,"",null,null)%> </td>
					</tr>

					<tr class="TextRow02">
						<td>Tipo de Cuenta:</td>
						<td><%=fb.select("tipo_cuenta","A=CTA AHORRO, C=CTA CORRIENTE", cdo.getColValue("tipo_cuenta"),false,viewMode,0,"Text10",null,null)%></td>
					</tr>

				</table>
			</tr>

			<tr>
				<td colspan="4">
					<jsp:include page="../common/bitacora.jsp" flush="true">
						<jsp:param name="audCollapsed" value="n"></jsp:param>
						<jsp:param name="audTable" value="tbl_pla_descuento"></jsp:param>
						<jsp:param name="audFilter" value="<%="emp_id="+empId+" and num_descuento="+id+" and cod_compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
					</jsp:include>
				</td>
			</tr>

			<tr class="TextRow02">
		        <td align="right" colspan="4"> Opciones de Guardar:
				<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
				<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
		    </tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
		  <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
</div>
<div class="dhtmlgoodies_aTab">
	<table align="center" width="99%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
	<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
	<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
	<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
	<%=fb.hidden("num_empleado",cdo.getColValue("num_empleado"))%>
	<%=fb.hidden("tab","0")%>
	<%=fb.hidden("baction","")%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>

			<tr class="TextHeader">
				<td colspan="4">&nbsp;Generales de Empleado</td>
			</tr>

			<tr class="TextRow01">
				<td width="15%">&nbsp;Nombre:</td>
				<td width="35%">&nbsp;<%=fb.textBox("nombre_empleado",cdo.getColValue("nombre_empleado"),false,false,true,40,45)%></td>
				<td width="15%">&nbsp;C&eacute;dula</td>
				<td width="35%">&nbsp;<%=fb.textBox("cedula",cdo.getColValue("cedula1"),false,false,true,20,25)%>
				&nbsp;&nbsp;&nbsp;ID:&nbsp;<%=fb.textBox("emp_id",empId,false,false,true,5,6)%>
				</td>
			</tr>

			<tr class="TextHeader">
				<td colspan="4">&nbsp;Generales de Descuento</td>
			</tr>

			<tr>
				<td colspan="4">
				<table width="100%">
					<tr class="TextHeader" align="center">
						<td width="10%">N&uacute;m.</td>
						<td align="center"  colspan="2">Grupo de Descuento</td>
						<td align="center" colspan="3">Acreedor</td>
					</tr>

					<tr class="TextRow02">
						<td align="center"><%=fb.intBox("id",cdo.getColValue("num_descuento"),false,false,true,5,3,"",null,null)%></td>
						<td colspan="2"><%=fb.intBox("cod_grupo",cdo.getColValue("cod_grupo"),false,false,true,5,2,"",null,null)%>
										<%=fb.textBox("grupoaName",cdo.getColValue("grupoaName"),false,false,true,55,200,"",null,null)%></td>
						<td colspan="3"><%=fb.intBox("cod_acreedor",cdo.getColValue("cod_acreedor"),false,false,true,5,3,"",null,null)%>
										<%=fb.textBox("acredorName",cdo.getColValue("acredorName"),false,false,true,55,200,"",null,null)%></td>
					</tr>

					<tr class="TextRow02">
						<td >Monto Total:</td>
						<td><%=fb.decBox("monto_total",cdo.getColValue("monto_total"),false,false,viewMode,15,15.2)%></td>
						<td>Descontado:</td>
						<td><%=fb.decBox("descontado",cdo.getColValue("descontado"),false,false,viewMode,15,15.2)%></td>
						<td>Saldo Pendiente:</td>
						<td><%=fb.decBox("saldo",cdo.getColValue("saldo"),false,false,viewMode,15,15.2)%></td>
					</tr>


					<tr class="TextRow02">
						<td>1ra. Quincena</td>
						<td><%=fb.decBox("descuento1",cdo.getColValue("descuento1"),false,false,viewMode,15,10.2,"",null,null)%></td>
						<td>2da. Quincena</td>
						<td><%=fb.decBox("descuento2",cdo.getColValue("descuento2"),false,false,viewMode,15,10.2,"",null,null)%></td>
						<td>Descuento Mensual:</td>
						<td><%=fb.decBox("descuento_mensual",cdo.getColValue("descuento_mensual"),false,false,viewMode,15,10.2,"",null,null)%></td>
					</tr>
				</table>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">&nbsp;Movimiento del Descuento</td>
			</tr>
			<tr>
				<td colspan="4"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="325" scrolling="yes" src="../rhplanilla/descuento_movim.jsp?empId=<%=empId%>&id=<%=id%>&mode=<%=mode%>"></iframe></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="center">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="center"><%=fb.button("btnPrintHist",">>> Reporte de Historial del descuento <<<",false,false,"", null,"onClick=\"javascript:printHist()\"" )%>
			</tr>

	<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>
</div>
     </td>
	</tr>
</table>
<script type="text/javascript">
<%
String tabLabel = "'Generales','Movimiento'";
String tabInactivo ="";

//S=Si el centro de servicio maneja admisiones
 if(mode.trim().equals("add"))   tabInactivo += "1";
 else tabInactivo += "";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  cdo = new CommonDataObject();

  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("monto_total",request.getParameter("monto_total").replaceAll(",",""));
  cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
  cdo.addColValue("saldo",request.getParameter("saldo").replaceAll(",",""));
  cdo.addColValue("descontado",request.getParameter("descontado").replaceAll(",",""));
  cdo.addColValue("descuento_mensual",request.getParameter("descuento_mensual"));
  cdo.addColValue("descuento1",request.getParameter("descuento1"));
  cdo.addColValue("descuento2",request.getParameter("descuento2"));
  cdo.addColValue("num_documento",request.getParameter("num_documento"));
  cdo.addColValue("observaciones",request.getParameter("observaciones"));
  cdo.addColValue("num_cuenta",request.getParameter("num_cuenta"));
  cdo.addColValue("tipo_cuenta",request.getParameter("tipo_cuenta"));
  cdo.addColValue("fecha_inicial", request.getParameter("fechaInicial"));
  //cdo.addColValue("fecharec", request.getParameter("fecharec"+a));
  //cdo.addColValue("num_descuento",request.getParameter("id"+a));

  cdo.setTableName("tbl_pla_descuento");
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("emp_id",empId);
	cdo.addColValue("provincia",request.getParameter("provincia"));
	cdo.addColValue("sigla",request.getParameter("sigla"));
	cdo.addColValue("tomo",request.getParameter("tomo"));
	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("emp_compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("cod_grupo",request.getParameter("cod_grupo"));
	//cdo.addColValue("grupoaName", request.getParameter("grupoaName"));
	cdo.addColValue("cod_acreedor",request.getParameter("cod_acreedor"));
	//cdo.addColValue("acredorName",request.getParameter("acredorName"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

	cdo.setAutoIncCol("num_descuento");
	cdo.setAutoIncWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+request.getParameter("empId"));
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id="+empId+" and num_descuento="+id);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/descuento_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/descuento_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/descuento_list.jsp';
<%
	}
%>

<%if (saveOption.equalsIgnoreCase("N")){%>
	setTimeout('addMode()',500);
<%} else if (saveOption.equalsIgnoreCase("O")){ %>
	setTimeout('editMode()',500);
<%} else if (saveOption.equalsIgnoreCase("C")){%>
	window.close();
<%}%>

<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>