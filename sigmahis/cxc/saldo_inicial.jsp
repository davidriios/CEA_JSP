<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String tcOpt = "O=OTROS";
if(_comp.getHospital().trim().equals("S")){tcOpt = "P=PACIENTE,A=ASEGURADORA,O=OTROS";}
boolean viewMode = false;
if (mode == null) mode = "add";
if (id == null) id = "0";
if (fg == null) fg = "CXC";

if (mode.equalsIgnoreCase("view")) viewMode = true;

String compFar = "";
try { compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar"); } catch(Exception e) {}
if (compFar.equalsIgnoreCase((String) session.getAttribute("_companyId"))&&!_comp.getHospital().trim().equals("S")) tcOpt = "O=OTROS";
if (fg.equalsIgnoreCase("CXPH")) tcOpt = "M=MEDICOS,S=SOCIEDADES MEDICAS";//C=CENTROS,
else if (fg.equalsIgnoreCase("CXPP")) tcOpt = "E=PROVEEDORES";

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (mode.equalsIgnoreCase("add")) {

		sbSql.append("select '01/'||trim(to_char(a.mes,'00'))||'/'||b.anio fecha, a.mes,b.anio from (select mes, ano anio, cod_cia from tbl_con_estado_meses where estatus = 'ACT') a, (select ano anio, cod_cia from tbl_con_estado_anos where estado = 'ACT') b where a.anio = b.anio and a.cod_cia = b.cod_cia and b.cod_cia = ");
		sbSql.append(session.getAttribute("_companyId"));
		CommonDataObject cdoSi = SQLMgr.getData(sbSql);
		if (cdoSi == null) throw new Exception("No existe Año o Mes Contable activo!");

		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("saldo_actual","0");
		cdo.addColValue("fecha",cdoSi.getColValue("fecha"));
		cdo.addColValue("anio",cdoSi.getColValue("anio"));
		id = "0";

	} else {

		sbSql.append("select s.id, s.tipo_cliente, s.saldo_actual, s.compania, s.usuario_creacion, s.id_cliente, s.pac_id,(select pp.nombre_paciente from vw_adm_paciente pp where pp.pac_id = s.pac_id) as nombrePac");
		sbSql.append(", case when s.tipo_cliente in ('P') then (select nombre_paciente from vw_adm_paciente where pac_id = s.pac_id)");
		
		sbSql.append(" when s.tipo_cliente in ('A') then (select nombre from tbl_adm_empresa where codigo = s.id_cliente)");
		
			sbSql.append(" when s.tipo_cliente = 'C' then (select descripcion from tbl_cds_centro_servicio where to_char(codigo) = s.id_cliente)");
			sbSql.append(" when s.tipo_cliente = 'E' then (select nombre_proveedor from tbl_com_proveedor where to_char(cod_provedor) = s.id_cliente)");
			sbSql.append(" when s.tipo_cliente = 'M' then (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = s.id_cliente)");
			sbSql.append(" when s.tipo_cliente = 'S' then (select nombre from tbl_adm_empresa where to_char(codigo) = s.id_cliente)");
			sbSql.append(" when s.tipo_cliente = 'O' then s.nombre");
		sbSql.append(" else ' ' end as nombre");
		sbSql.append(", s.anio, to_char(s.fecha,'dd/mm/yyyy') as fecha, s.tipo_ref, s.adm_type, s.comentarios,decode(s.tipo_cliente , 'M',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =s.id_cliente ),s.id_cliente) id_cliente_view from tbl_cxc_saldo_inicial s where s.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and s.id = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql);

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function getCliente()
{
	var tipo = document.form1.tipo_cliente.value;
	var empresa = document.form1.id_cliente.value;

	if(tipo=='P')abrir_ventana1('../common/search_paciente.jsp?fp=cxc');
	else if(tipo=='A')abrir_ventana1('../common/search_empresa.jsp?fp=cxc');
	else if(tipo=='E')abrir_ventana1('../inventario/sel_proveedor.jsp?fp=cxc');
	else if(tipo=='C')abrir_ventana1('../common/search_centro_servicio.jsp?fp=saldoIni');
	else if(tipo=='S')abrir_ventana1('../common/search_empresa.jsp?fp=saldoIni');
	else if(tipo=='M')abrir_ventana1('../common/search_medico.jsp?fp=saldoIni');
	else if(tipo=='O'&&document.form1.tipo_ref.value!='')abrir_ventana1('../pos/sel_otros_cliente.jsp?fp=saldoIni&tipo_factura=&ref_id='+document.form1.tipo_ref.value+'&Refer_To='+getSelectedOptionTitle(document.form1.tipo_ref,'CXCO'));
	//showOtros(tipo);?fp=cargo_dev_oc&mode=<%=mode%>&tipo_factura='+tipo_factura+'&tipo_pos='+tipo_pos+'&ref_id='+ref_id+'&Refer_To='+refer_to
}
function getPaciente()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=cxc2');
}

function showOtros(tp,blankRefer){
if(tp==undefined||tp==null)tp='P';
if(blankRefer==undefined||blankRefer==null)blankRefer=true;
if(blankRefer){document.form1.id_cliente.value='';document.form1.nombre.value='';if(document.form1.pac_id)document.form1.pac_id.value='';if(document.form1.nombrePac)document.form1.nombrePac.value='';}
if(tp=='A'){if(document.form1.btnPaciente)document.form1.btnPaciente.disabled=false;}else{if(document.form1.btnPaciente)document.form1.btnPaciente.disabled=true;}
if(tp=='O'){document.getElementById('blkTipoRef').style.display='';document.form1.adm_type.value='T';document.form1.adm_type.disabled=true;}else{document.getElementById('blkTipoRef').style.display='none';document.form1.adm_type.value='';document.form1.adm_type.disabled=false;}
}

function checkCliente()
{
	var tipo_cliente = document.form1.tipo_cliente.value;
	var idCliente = document.form1.id_cliente.value;
	var tipoRef=(document.form1.tipo_ref)?document.form1.tipo_ref.value:'';
	var filter='tipo_cliente = \''+tipo_cliente+'\' and id_cliente = \''+idCliente+'\''+((tipoRef=='')?'':' and tipo_ref = '+tipoRef);
	var x=0;
	var ignoreDupMsg = false;
	
	if(tipo_cliente=='O'&&tipoRef==''){x++;alert('Seleccione el Tipo de Referencia!');}
	if(document.form1.fecha.value==''){x++;alert('Introduzca valor en campo fecha');}
	
	<% if (mode.equalsIgnoreCase("add")) { %>
	if(hasDBData('<%=request.getContextPath()%>','tbl_cxc_saldo_inicial',filter+((tipo_cliente=='A')?' and pac_id is null':''),''))x++;
	if(tipo_cliente=='A'){
		var pacId=document.form1.pac_id.value;
		if(pacId!=undefined&&pacId!=null&&pacId.trim()!=''){
			if(hasDBData('<%=request.getContextPath()%>','tbl_cxc_saldo_inicial',filter+' and pac_id = '+pacId,''))x++;
			else if ( hasDBData( "<%=request.getContextPath()%>","tbl_cxc_saldo_inicial", "id_cliente is not null and pac_id is null and tipo_cliente = 'A' and id_cliente = '"+idCliente+"'" )  ){
			  alert("Ya se registró un saldo inicial entre el paciente y la aseguradora!"); x++;
			  ignoreDupMsg = true;
			}
		}
		else{
		   if ( hasDBData( "<%=request.getContextPath()%>","tbl_cxc_saldo_inicial", "id_cliente is not null and pac_id is not null and tipo_cliente = 'A' and id_cliente = '"+idCliente+"'" )  ){
			  alert("Ya se registró un saldo inicial a la aseguradora!"); x++;
			  ignoreDupMsg = true;
			}
		}
	}
	if(x!=0 && ignoreDupMsg==false)alert('El Cliente ya existe. Verifique!');
	<% } %>
	
	if(x==0)return true;
	else return false;
}
function doAction(){showOtros(document.form1.tipo_cliente.value,false);}
</script>
<script language="javascript">
document.title="Saldo Inicial - "+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXC - SALDO - INICIAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" border="0" cellspacing="1" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("compania",cdo.getColValue("compania"))%>
<%=fb.hidden("fg",fg)%>
<%fb.appendJsValidation("if(!checkCliente())error++;");%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="25%"><cellbytelabel>Tipo Cliente</cellbytelabel></td>
			<td width="75%">
				<%=fb.select("tipo_cliente",tcOpt,cdo.getColValue("tipo_cliente"),false,viewMode,0,null,null,"onChange=\"javascript:showOtros(this.value)\"")%>
				<span id="blkTipoRef"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+session.getAttribute("_companyId")+" and activo_inactivo = 'A' order by 2","tipo_ref",cdo.getColValue("tipo_ref"),false,false,viewMode,0,null,null,"onChange=\"javascript:showOtros(document.form1.tipo_cliente.value)\"",null,"S")%></span>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td>
				<%=fb.hidden("id_cliente",cdo.getColValue("id_cliente"))%>
				<%=fb.textBox("id_cliente_view",cdo.getColValue("id_cliente_view"),true,false,true,10)%>				
				<%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,true,35)%>
				<%=fb.button("btncliente","...",false,viewMode,null,null,"onClick=\"javascript:getCliente()\"")%>
			</td>
		</tr>
		<% if (fg.equalsIgnoreCase("CXC")) {%>
		<tr class="TextRow01">
			<td><cellbytelabel>Paciente</cellbytelabel></td>
			<td>
				<%=fb.textBox("pac_id",cdo.getColValue("pac_id"),false,false,true,10)%>
				<%=fb.textBox("nombrePac",cdo.getColValue("nombrePac"),false,false,true,35)%>
				<%=fb.button("btnPaciente","...",false,true,null,null,"onClick=\"javascript:getPaciente()\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
			<td><%=fb.select("adm_type","T=GENERAL,I=IN-PATIENT (IP),O=OUT-PATIENT (OP)",cdo.getColValue("adm_type"),true,false,viewMode,0,null,null,null,"","S")%></td>
		</tr>
		<% } %>
		<tr class="TextRow01">
			<td><cellbytelabel>Saldo</cellbytelabel> </td>
			<td><%=fb.decBox("saldo_actual",cdo.getColValue("saldo_actual"),true,false,viewMode,20,18.2,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Año (Para Factura S.I.)</cellbytelabel> </td>
			<td><%=fb.intBox("anio",cdo.getColValue("anio"),true,false,viewMode,6,4,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Fecha (Para Factura S.I.)</cellbytelabel> </td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Comentarios</cellbytelabel></td>
			<td><%=fb.textarea("comentarios",cdo.getColValue("comentarios"),false,false,viewMode,80,4,1024)%></td>
		</tr>
		<tr class="TextRow02">
			<td  colspan="2" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel> <!----->
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	id = request.getParameter("id");

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_cxc_saldo_inicial");
	cdo.addColValue("compania",request.getParameter("compania"));
	cdo.addColValue("id",request.getParameter("id"));
	cdo.addColValue("saldo_actual",request.getParameter("saldo_actual"));
	cdo.addColValue("anio",request.getParameter("anio"));
	cdo.addColValue("fecha",request.getParameter("fecha"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion","sysdate");
	cdo.addColValue("tipo_cliente",request.getParameter("tipo_cliente"));
	if (cdo.getColValue("tipo_cliente").equalsIgnoreCase("O")) {
		cdo.addColValue("tipo_ref",request.getParameter("tipo_ref"));
		cdo.addColValue("adm_type","T");
	} else {
		System.out.println("....."+request.getParameter("tipo_ref"));
		cdo.addColValue("adm_type",request.getParameter("adm_type"));
	}
	cdo.addColValue("comentarios",request.getParameter("comentarios"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add")) {

		cdo.addColValue("id_cliente",request.getParameter("id_cliente"));
		if(request.getParameter("pac_id")!=null) cdo.addColValue("pac_id",request.getParameter("pac_id"));
		if(request.getParameter("tipo_cliente") != null && !request.getParameter("tipo_cliente").trim().equals("")&&request.getParameter("tipo_cliente").trim().equals("P"))
		cdo.addColValue("pac_id",request.getParameter("id_cliente"));

		cdo.addColValue("nombre",request.getParameter("nombre"));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		//cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("id");

		cdo.addPkColValue("id","");

		//SQLMgr.setErrCode("1");
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("id");

	} else {

		 cdo.setWhereClause("id = "+request.getParameter("id"));
		 SQLMgr.update(cdo);

	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/list_saldo_inicial.jsp?fg="+fg))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/list_saldo_inicial.jsp")%>?fg=<%=fg%>';
<%
	}
	else
	{
%>
window.location = '<%=request.getContextPath()%>/cxc/list_saldo_inicial.jsp?fg=<%=fg%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?&fg=<%=fg%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>