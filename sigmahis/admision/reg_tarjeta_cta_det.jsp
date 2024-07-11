<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.StringEncrypter"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htNot" scope="session" class="java.util.Hashtable"/>
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	SQLMgr.setConnection(ConMgr);
	CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
	StringEncrypter se = new StringEncrypter();

	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);
	CommonDataObject cdo = new CommonDataObject();

	String creatorId = UserDet.getUserEmpId();
	
	ArrayList alTipo = new ArrayList();
	ArrayList alBanco = new ArrayList();
	alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cja_tipo_tarjeta order by 2",CommonDataObject.class);
	alBanco = sbb.getBeanList(ConMgr.getConnection(),"select ruta as optValueColumn, nombre_banco as optLabelColumn, ruta as optTitleColumn from tbl_adm_ruta_transito order by 2",CommonDataObject.class);

	String mode=request.getParameter("mode");
	String change=request.getParameter("change");
	String tipo=request.getParameter("tipo");
	String compId=(String) session.getAttribute("_companyId");
	String pac_id = request.getParameter("pac_id");
	String id = request.getParameter("id");
	String fg = request.getParameter("fg");
	String tab = request.getParameter("tab");
	String title = "";
	String key = "";
	boolean viewMode = false;
	ArrayList al = new ArrayList();
	StringBuffer sbSql = new StringBuffer();

	if(mode==null) mode="add";
	if(mode.equals("view")) viewMode=true;
	if(fg==null) fg="";
	if (tipo == null) tipo = "";

	if(request.getMethod().equalsIgnoreCase("GET")){
		if ((mode.equals("edit") || mode.equals("view")) && id != null && !id.equals("")){
			sbSql.append("select pac_id, id, num_tarjeta_cta, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, estado, observacion, tipo, cod_banco, tipo_tarjeta, periodo, to_char(fecha_vence, 'dd/mm/yyyy') fecha_vence, nvl(num_pagos, 0) num_pagos from tbl_adm_cta_tarjeta a where a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" and a.id = ");
			sbSql.append(id);

			if (pac_id == null) throw new Exception("El Parametro no es válido. Por favor intente nuevamente!");
			cdo = SQLMgr.getData(sbSql.toString());
		} else {
			cdo = new CommonDataObject();
			String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
			cdo.addColValue("fecha_inicio", fecha);
			cdo.addColValue("fecha_vence", "");
			cdo.addColValue("estado", "A");
		}
		if(mode.equals("edit") && (id == null || id.equals(""))) mode = "add";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){if (parent.parent.adjustIFrameSize) parent.parent.adjustIFrameSize(window);}

function doSubmit(valor){
	document.formTarjetaDet.baction.value = valor;
	document.formTarjetaDet.pac_id.value = parent.document.formTarjeta.pac_id.value;
	document.formTarjetaDet.tab.value = parent.document.formTarjeta.tab.value;
	var fecha = document.formTarjetaDet.fecha_vence.value;
	var fecha_val = 'N';
	if(fecha!=''){
		fecha_val = getDBData('<%=request.getContextPath()%>','\'S\'','dual','to_date(\''+fecha+'\', \'dd/mm/yyyy\')> trunc(sysdate) and to_date(\''+fecha+'\', \'dd/mm/yyyy\')>(trunc(sysdate)+30)')||'N';
	}
	if(document.formTarjetaDet.tipo.value=='') alert('Seleccione Tipo!');
	else if(document.formTarjetaDet.tipo.value=='C' && document.formTarjetaDet.tipo_cuenta.value=='') alert('Seleccione Tipo Cuenta!');	
	else if((document.formTarjetaDet.tipo.value=='T' || document.formTarjetaDet.tipo.value=='C') && document.formTarjetaDet.cod_banco.value=='') alert('Seleccione Banco!');	
	else if(document.formTarjetaDet.tipo.value=='T' && document.formTarjetaDet.fecha_vence.value=='') alert('Introduzca Fecha Vencimiento!');	
	else if(document.formTarjetaDet.tipo.value=='T' && fecha_val=='N') alert('La tarjeta vence antes del tiempo permitido!');	
	else if('<%=mode%>'=='add' && isNaN(document.formTarjetaDet.num_tarjeta_cta.value)) alert('No. Documento debe ser numerico!');
	else if('<%=mode%>'=='add' && document.formTarjetaDet.num_tarjeta_cta.value=='' && !document.formTarjetaDet.tipo.value=='V') alert('Introduzca No. Documento!');
	else document.formTarjetaDet.submit();
}

function showHideTT(){
	if(document.formTarjetaDet.tipo.value=='C'){
		document.getElementById("tipoTarjeta").style.display='none';
		document.getElementById("tipoCta").style.display='';
		document.getElementById("lblBancoL").style.display='';
		document.getElementById("lblBancoV").style.display='';
		document.getElementById("lblNoDocLabel").style.display='';
		document.getElementById("lblNoDoc").style.display='';
	}	else if(document.formTarjetaDet.tipo.value=='V'){
		document.getElementById("tipoTarjeta").style.display='none';
		document.getElementById("tipoCta").style.display='none';
		document.getElementById("lblBancoL").style.display='none';
		document.getElementById("lblBancoV").style.display='none';
		document.getElementById("lblNoDocLabel").style.display='none';
		document.getElementById("lblNoDoc").style.display='none';
	}	else {
		document.getElementById("tipoTarjeta").style.display='';
		document.getElementById("tipoCta").style.display='none';
		document.getElementById("lblBancoL").style.display='';
		document.getElementById("lblBancoV").style.display='';
		document.getElementById("lblNoDocLabel").style.display='';
		document.getElementById("lblNoDoc").style.display='';
	}
}

function lookType(){
	if('<%=mode%>'=='edit') document.formTarjetaDet.tipo.value = document.formTarjetaDet._tipo.value;
}
function setMaxLen(){
	var tipo = document.formTarjetaDet.tipo.value;
	var len_val = (document.getElementById('num_tarjeta_cta').value).length;
	if(tipo=='T') {
		document.getElementById('num_tarjeta_cta').setAttribute('maxlength',16);
		alert('El Numero de Tarjeta no puede tener mas de 16 caracteres!');
		document.getElementById('num_tarjeta_cta').value = '';
	} else if(tipo=='C') document.getElementById('num_tarjeta_cta').setAttribute('maxlength',17);
	else document.getElementById('num_tarjeta_cta').setAttribute('maxlength',16);
}
</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("formTarjetaDet",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab",tab)%>

  <table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
			<td class="TableBorder">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr>
						<td colspan="4" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<%=(mode.equals("add")?"Agregar":(mode.equals("edit")?"Editar":"Ver"))%> Tarjeta/Cuenta</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel0">
						<td colspan="4">
							<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextRow01">
									<td class="TextLabel" align="right" width="20%"><label id="lblNoDocLabel" style="display:''">No. Documento:</label></td>
									<td width="25%"><label id="lblNoDoc" style="display:''"><%=fb.textarea("num_tarjeta_cta", ""/*cdo.getColValue("num_tarjeta_cta")*/,true,false,false,20,1, 16)%></label></td>
									<td align="right" width="10%">Tipo:</td>
									<td width="45%">
									<%=fb.hidden("_tipo", cdo.getColValue("tipo"))%>
									<%=fb.select("tipo", "T=Tarjeta, C=ACH", cdo.getColValue("tipo"), false, false, 0, "text12 FormDataObjectRequired", "", "onChange=\"javascript:lookType();showHideTT();setMaxLen();\"", "", "S")%>
									<label id="tipoTarjeta" style="display:<%=(cdo.getColValue("tipo")!=null?(cdo.getColValue("tipo").equals("T")?"":"none"):"")%>">
									Tipo Tarjeta:
									<%=fb.select("tipo_tarjeta",alTipo,cdo.getColValue("tipo_tarjeta"),false,false,0,"Text10",null,null,null,"S")%>
									Fecha Vence:
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fecha_vence" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_vence")%>" />
									<jsp:param name="fieldClass" value="text10" />
									<jsp:param name="buttonClass" value="text10" />
									</jsp:include>
									</label>
									<label id="tipoCta" style="display:<%=(cdo.getColValue("tipo")!=null?(cdo.getColValue("tipo").equals("C")?"":"none"):"none")%>">
									Tipo Cuenta:
									<%=fb.select("tipo_cuenta","27=CUENTA CORRIENTE,37=CUENTA DE AHORRO",cdo.getColValue("tipo_tarjeta"),false,false,0,"Text10 FormDataObjectRequired",null,null,null,"S")%>
									</label>
									</td>
								</tr>
								<tr class="TextRow01">
									<td class="TextLabel" align="right">Fecha Inicio:</td>
									<td>
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fecha_inicio" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
									<jsp:param name="fieldClass" value="text10" />
									<jsp:param name="buttonClass" value="text10" />
									</jsp:include>
									</td>
									<td align="right"><label id="lblBancoL">Banco:</label></td>
									<td><label id="lblBancoV"><%=fb.select("cod_banco",alBanco,cdo.getColValue("cod_banco"),false,false,0,"Text10 FormDataObjectRequired",null,null,null,"S")%></label></td>
								</tr>
								<tr class="TextRow01">
									<td class="TextLabel" align="right">&nbsp;<!--Periodo:--></td>
									<td>&nbsp;<%//=fb.select("periodo", "1=1, 2=2, 3=3, 4=4, 5=5, 6=6, 7=7, 8=8, 9=9, 10=10, 11=11, 12=12", cdo.getColValue("periodo"), false, false, 0, "text12", "", "", "", "", "", "", "")%></td>
									<td align="right">Estado:</td>
									<td>
									<%=fb.hidden("estado", cdo.getColValue("estado"))%>
									<%=(cdo.getColValue("estado")!=null && cdo.getColValue("estado").equals("A")?"Activo":(cdo.getColValue("estado").equals("I")?"Inactivo":"Reemplazado"))%>
									<%//=fb.select("estado", "A=Activo, I=Inactivo", cdo.getColValue("estado"), false, false, 0, "text12", "", "", "", "", "", "", "")%>
									<authtype type='50'>
									
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<!--Cuotas Pagas:-->
									<%//=fb.intBox("num_pagos",cdo.getColValue("num_pagos"),false,false,false,6,null,null,"")%>
									</authtype>
									</td>
								</tr>
								<tr class="TextRow02">
									<td colspan="4" align="right">
									Opciones de Guardar: 
									<%=fb.radio("saveOption","N",true,false,false)%>Crear Otro 
									<%=fb.radio("saveOption","O",false,false,false)%>Mantener Abierto 
									<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
									<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.parent.window.close()\"")%>
									</td>
								</tr>
							</table>
            </td>
					</tr>
				</table>
			</td>
    </tr>
  </table>
<%=fb.hidden("size", ""+htNot.size())%>	
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
	String returnId = "";
	cdo.setTableName("tbl_adm_cta_tarjeta");
	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("pac_id")!=null) cdo.addColValue("pac_id", request.getParameter("pac_id"));
	if(request.getParameter("num_tarjeta_cta")!=null && !request.getParameter("num_tarjeta_cta").equals("")) cdo.addColValue("num_tarjeta_cta", request.getParameter("num_tarjeta_cta"));//se.encrypt()
	if(request.getParameter("fecha_inicio")!=null) cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"));
	if(request.getParameter("fecha_vence")!=null) cdo.addColValue("fecha_vence", request.getParameter("fecha_vence"));
	if(request.getParameter("cod_banco")!=null) cdo.addColValue("cod_banco", request.getParameter("cod_banco"));
	if(request.getParameter("num_pagos")!=null) cdo.addColValue("num_pagos", request.getParameter("num_pagos"));
	if(request.getParameter("tipo")!=null){ 
		cdo.addColValue("tipo", request.getParameter("tipo"));
		if(request.getParameter("tipo").equals("T")){
			if(request.getParameter("tipo_tarjeta")!=null) cdo.addColValue("tipo_tarjeta", request.getParameter("tipo_tarjeta"));
		} else if(request.getParameter("tipo").equals("C")){
			if(request.getParameter("tipo_cuenta")!=null) cdo.addColValue("tipo_tarjeta", request.getParameter("tipo_cuenta"));
		} else if(request.getParameter("tipo").equals("V")){
			cdo.addColValue("tipo_tarjeta","");
			cdo.addColValue("tipo_cuenta","");
			cdo.addColValue("cod_banco","");
			cdo.addColValue("fecha_vence","");
			cdo.addColValue("num_tarjeta_cta","");
			
		}
		
	}	
	
	if(mode.equals("add")) cdo.addColValue("estado", "A");
	else cdo.addColValue("estado", request.getParameter("estado"));
	
	//if(request.getParameter("tipo_tarjeta")!=null) cdo.addColValue("tipo_tarjeta", request.getParameter("tipo_tarjeta"));
	if(request.getParameter("periodo")!=null) cdo.addColValue("periodo", request.getParameter("periodo"));
	if(mode.equals("add")) cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	else if(mode.equals("edit")) cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		if(mode.equals("add")){
			cdo.addColValue("id", "(SELECT nvl(max(id),0)+1 FROM tbl_adm_cta_tarjeta)");
			cdo.addPkColValue("id","");
			SQLMgr.insert(cdo,true,true,true);
			returnId = SQLMgr.getPkColValue("id");
		} else if(mode.equals("edit")){
			returnId = request.getParameter("id");
			cdo.setWhereClause("pac_id="+request.getParameter("pac_id")+" and id = "+request.getParameter("id"));
			SQLMgr.update(cdo);
		}
		if(SQLMgr.getErrCode().equals("1")){
			sbSql = new StringBuffer();
			sbSql.append("call sp_adm_ctas_tarjetas(");
			sbSql.append(request.getParameter("pac_id"));
			sbSql.append(", ");
			sbSql.append(returnId);
			sbSql.append(")");
			SQLMgr.execute(sbSql.toString());
		}
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%
if(SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('editMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}	
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	parent.parent.showInfo(<%=tab%>, <%=returnId%>, 'add');
}

function editMode()
{
	parent.parent.showInfo(<%=tab%>, <%=returnId%>, 'edit');
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>
