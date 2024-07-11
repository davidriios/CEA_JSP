<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String id = request.getParameter("id");
String codigo = request.getParameter("codigo");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String ref_id = request.getParameter("ref_id");
String refer_to = request.getParameter("refer_to");
String title = "";

ArrayList alRefType = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
if(mode==null) mode="add";
if(fp==null) fp="";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";

boolean read_only = false;

String key = "";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'POS_TIPO_CLTE_JJ') as juntaD, get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'POS_TIPO_CLTE_ACC') as accionista, get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'COD_TIPO_OC_EMP_POS') as cod_tipo_oc_empl, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'INT_POS_SHOW_CLIENT_DISC'),'-') as int_pos_show_client_disc, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'EDIT_CAMPOS_CLIENTE_PART_POS'),'S') as edit_campos_cliente_part_pos,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'TP_CLIENTE_CXC_OTROS'),'S') as cxc_otros  from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if(p.getColValue("edit_campos_cliente_part_pos").equals("N") && mode.equals("add")&&fp.equals("proforma")) read_only = true;

if(request.getMethod().equalsIgnoreCase("GET")){
alRefType = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and resp_pos='S' order by 2",CommonDataObject.class);

if(fp.equals("list_otros_clientes")){
	if(mode.equals("edit") || mode.equals("view")){
		sbSql = new StringBuffer();
		sbSql.append("select forma_pago, tipo_cliente, dias_cr_limite, monto_cr_limite, codigo, descripcion, cliente_alquiler, compania, aplica_descuento, dv, ruc, colaborador, facturar_al_costo, estado, ref_type_resp, ref_id_resp, case when ref_id_resp is not null then (select  getNombreCliente(compania,ref_type_resp,ref_id_resp) from dual) else ' ' end as nombreResp, int_disc_perc from tbl_cxc_cliente_particular where codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());
	}else{
		cdo = new CommonDataObject();
		cdo.addColValue("codigo", "-1");
		
	}
	 
}
if(p.getColValue("edit_campos_cliente_part_pos").equals("N") && mode.equals("add")&&fp.equals("proforma")) cdo.addColValue("monto_cr_limite", "1000");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){}

function doSubmit(valor){
	document.form1.baction.value=valor;
	if(document.form1.forma_pago.value=='CR' && document.form1.dias_cr_limite.value=='') alert('Seleccione días de crédito!');
	else if(document.form1.forma_pago.value=='CR' && document.form1.monto_cr_limite.value=='') alert('Agregue monto de crédito!');
	else document.form1.submit();
}
function checkRuc()
{
 	var ruc=document.form1.ruc.value; 
	var tipo = document.form1.tipo_cliente.value; 
	if(tipo=='')tipo='-100';
 		if(ruc !='')
		{ 
			var v_msg = getDBData('<%=request.getContextPath()%>','getVerificaRucCliente(<%=(String) session.getAttribute("_companyId")%>,\''+ruc+'\',\''+tipo+'\',\'CXC\',<%=cdo.getColValue("codigo","-1")%>)as msg','dual','');
			 if(v_msg!='-')alert('Favor verificar mantenimiento ya que existen Registros con el mismo RUC. \n '+v_msg.replace(';','\n'));
			 //return true;
			// if(v_msg!='-')alert('Favor verificar mantenimiento ya que existen Registros con el mismo RUC. '+v_msg);	
		}
		//return false;
}

function chkTipoClte(){
	var tipo = document.form1.tipo_cliente.value; 
	var cod_tipo_oc_emp_pos = document.form1.cod_tipo_oc_emp_pos.value; 
	if(tipo==-4 || tipo == cod_tipo_oc_emp_pos) document.form1.aplica_descuento.value='Y';
}


function setDesc(){
	var tipo = document.form1.tipo_cliente.value; 
	var cod_tipo_oc_emp_pos = document.form1.cod_tipo_oc_emp_pos.value; 
	if(tipo==-4) document.form1.aplica_descuento.value='Y';
}
function clearRef(){eval('document.form1.ref_id_resp').value="";eval('document.form1.nombreResp').value="";}
function getClient(){var referTo=getSelectedOptionTitle(eval('document.form1.ref_type_resp'),eval('document.form1.ref_type_resp').value);

var ref_id = eval('document.form1.ref_type_resp').value;  if(ref_id!='')
{

abrir_ventana('../pos/sel_otros_cliente.jsp?fp=addCliente&mode=<%=mode%>&Refer_To='+referTo+'&ref_id='+ref_id); 

}else{CBMSG.warning('Seleccione Tipo Cliente');

}}

$(document).ready(function() {
<%if(read_only){%>
$("#colaborador").on("change", function(){$(this).val("N");});
//$("#aplica_descuento").on("change", function(){$(this).val("N");});
$("#forma_pago").on("change", function(){$(this).val("CO");});
$("#dias_cr_limite").on("change", function(){$(this).val("0");});
$("#facturar_al_costo").on("change", function(){$(this).val("N");});
$("#ref_type_resp").on("change", function(){$(this).val("");});

<%}%>
});
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("change", change)%>
<%=fb.hidden("baction", "")%>
<%=fb.hidden("fp", fp)%>
<%=fb.hidden("fg", fg)%>
<%=fb.hidden("ref_id", ref_id)%>
<%=fb.hidden("refer_to", refer_to)%>
<%=fb.hidden("codigo", codigo)%>
<%=fb.hidden("cod_tipo_oc_emp_pos", p.getColValue("cod_tipo_oc_empl"))%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow06">
				<td colspan="4" align="center">CREACION DE CLIENTE PARTICULAR</td>
			</tr>
			<tr class="TextRow01"> 
				<td align="right">Tipo de Cliente:</td>
				<td colspan="3"><%=fb.select(ConMgr.getConnection(), "select id, descripcion from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId")+" and estado = 'A' "+((p.getColValue("edit_campos_cliente_part_pos").equals("N")&&fp.equals("proforma"))?" and id in ("+p.getColValue("cxc_otros")+")":""), "tipo_cliente", cdo.getColValue("tipo_cliente"), false, false, false, 0,"","text12","onChange=\"javascript:checkRuc();chkTipoClte();\"")%>
				</td>
			</tr>
			
			<tr class="TextRow01">
				<td align="right">Nombre:</td>
				<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,100,200,"Text10",null,null)%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">RUC:</td>
				<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),true,false,false,30,50,"Text10",null,"onBlur=\"javascript:checkRuc()\"")%>
				</td>
				<td align="right">DV:</td>
				<td><%=fb.textBox("dv",cdo.getColValue("dv"),!read_only,false,read_only,4,2,"Text10 ",null,null)%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Es Colaborador?:</td>
				<td><%=fb.select("colaborador","N=No, S=Si",cdo.getColValue("colaborador"))%>
				</td>
				<% if ("YS".contains(p.getColValue("int_pos_show_client_disc").toUpperCase())) { %>
				<td align="right">% Descuento INTERFAZ</td>
				<td><%=fb.decBox("int_disc_perc",cdo.getColValue("int_disc_perc"),false,false,read_only,5,3.1,"Text10","","","",false,"","")%></td>
				<% } else { %>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
				<% } %>
			</tr>
			<tr class="TextRow01">
				<td align="right">Aplica Descuento?:</td>
				<td><%=fb.select("aplica_descuento","N=No, Y=Si",cdo.getColValue("aplica_descuento"))%>
				</td>
				<td align="right">Forma de Pago:</td>
				<td><%=fb.select("forma_pago","CO=Contado, CR=Credito",cdo.getColValue("forma_pago"))%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td align="right">D&iacute;as Cr&eacute;dito:</td>
				<td><%=fb.select("dias_cr_limite","0=-SELECCIONE-,1=15 Dias,2=30 Dias,3=45 Dias,4=60 Dias,5=90 Dias,6=120 Dias",cdo.getColValue("dias_cr_limite"),false,false,0,"Text10",null,null,"","")%>
				</td>
				<td align="right">Monto L&iacute;mite:</td>
				<td><%=fb.decBox("monto_cr_limite", cdo.getColValue("monto_cr_limite"), false, false, read_only, 12, 12.4, "text10", "", "", "", false, "", "")%>
				</td>
			</tr>		
			<authtype type='50'>
			<tr class="TextRow01">
				<td align="right">Facturar al Costo:</td>
				<td><%=fb.select("facturar_al_costo","N=No,S=Si",cdo.getColValue("facturar_al_costo"),false,false,0,"Text10",null,null,"","")%>
				</td>
				<td align="right">Estado:</td>
				<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"Text10",null,null,"","")%></td>
			</tr>
			</authtype>
			<authtype type='55'>
			<tr class="TextRow01">
				<td align="right">Responsable</td>
				<td>Tipo Cliente:<%=fb.select("ref_type_resp",alRefType,cdo.getColValue("ref_type_resp"),false,false,0,"Text10",null,"onChange=\"javascript:clearRef()\"",null,"S")%></td>
				<td colspan="2"><%=fb.textBox("ref_id_resp",( cdo.getColValue("ref_type_resp")==null||"".equals(cdo.getColValue("ref_type_resp"))?"":cdo.getColValue("ref_id_resp")),false,false,true,20,30,"Text10",null,null)%>
				<%=fb.textBox("nombreResp",cdo.getColValue("nombreResp"),false,false,true,60,100,"Text10",null,null)%>
				<%=fb.button("btnRef","...",true,read_only,"Text10", null,"onClick=\"javascript:getClient();\"" )%>				
				</td>
			</tr>
			</authtype>
			<tr class="TextRow02">
				<td colspan="4" align="right">
				<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
} else if(request.getMethod().equalsIgnoreCase("post")) {
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();
  cdo.setTableName("tbl_cxc_cliente_particular");  
	if(request.getParameter("descripcion")!=null) cdo.addColValue("descripcion", request.getParameter("descripcion"));
	if(request.getParameter("ruc")!=null) cdo.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("dv")!=null) cdo.addColValue("dv", request.getParameter("dv"));
	if(request.getParameter("colaborador")!=null) cdo.addColValue("colaborador", request.getParameter("colaborador"));
	if(request.getParameter("tipo_cliente")!=null) cdo.addColValue("tipo_cliente", request.getParameter("tipo_cliente"));
	if(request.getParameter("aplica_descuento")!=null) cdo.addColValue("aplica_descuento", request.getParameter("aplica_descuento"));
	if(request.getParameter("facturar_al_costo")!=null) cdo.addColValue("facturar_al_costo", request.getParameter("facturar_al_costo"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("ref_type_resp")!=null) cdo.addColValue("ref_type_resp", request.getParameter("ref_type_resp"));
	if(request.getParameter("ref_id_resp")!=null) cdo.addColValue("ref_id_resp", request.getParameter("ref_id_resp"));
	if(request.getParameter("int_disc_perc")!=null) cdo.addColValue("int_disc_perc",request.getParameter("int_disc_perc"));
	
	if(request.getParameter("forma_pago")!=null){
		cdo.addColValue("forma_pago", request.getParameter("forma_pago"));
		if(cdo.getColValue("forma_pago").equals("CR")){
			cdo.addColValue("dias_cr_limite", request.getParameter("dias_cr_limite"));
			cdo.addColValue("monto_cr_limite", request.getParameter("monto_cr_limite"));
		} else {
			cdo.addColValue("dias_cr_limite", "null");
			cdo.addColValue("monto_cr_limite", "null");
		}
	}
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	String returnId = "";
	System.out.println("baction="+request.getParameter("baction"));
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.setAutoIncCol("codigo");
			SQLMgr.insert(cdo);
			returnId = SQLMgr.getPkColValue("codigo");
		} else if (mode.equalsIgnoreCase("edit")){
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.setWhereClause(" compania = "+(String) session.getAttribute("_companyId")+" and codigo = "+request.getParameter("codigo"));
			SQLMgr.update(cdo);
			returnId = request.getParameter("codigo");
		}
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if(SQLMgr.getErrCode().equals("1")){
%>
    alert('<%=SQLMgr.getErrMsg()%>');
		<%if(fp.equals("cargo_dev_oc")||fp.equals("proforma")){%>
    parent.add('<%=ref_id%>', '<%=refer_to%>', '<%=returnId%>', '<%=request.getParameter("descripcion")%>', '<%=request.getParameter("ruc")%>', '<%=request.getParameter("dv")%>', 0);
		<%} else if(fp.equals("lista_precio")){%>
		parent.reloadPage(<%=ref_id%>, '<%=refer_to%>');
		<%} else if(fp.equals("list_otros_clientes")){%>
		parent.window.location='../pos/list_otros_clientes.jsp'
		<%}%>
		parent.hidePopWin(false);
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
}//post
%>
