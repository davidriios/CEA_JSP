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
<jsp:useBean id="iPaqUso" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqUso" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqInsumo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqInsumo" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqProc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iPaqCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqCds" scope="session" class="java.util.Vector" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String mode = request.getParameter("mode");
String comboId = request.getParameter("comboId");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String fp = request.getParameter("fp");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();
String comboStatusStr = "N=Nuevo";

ArrayList al = new ArrayList();

int paqUsoLastLineNo = 0;
int paqInsumoLastLineNo = 0;
int paqProcLastLineNo = 0;
int paqCdsLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (fp == null) fp = "profileCPT";
if (comboId==null) comboId = "";

if (request.getParameter("paqUsoLastLineNo") != null) paqUsoLastLineNo = Integer.parseInt(request.getParameter("paqUsoLastLineNo"));
if (request.getParameter("paqInsumoLastLineNo") != null) paqInsumoLastLineNo = Integer.parseInt(request.getParameter("paqInsumoLastLineNo"));
if (request.getParameter("paqProcLastLineNo") != null) paqProcLastLineNo = Integer.parseInt(request.getParameter("paqProcLastLineNo"));
if (request.getParameter("paqCdsLastLineNo") != null) paqCdsLastLineNo = Integer.parseInt(request.getParameter("paqCdsLastLineNo"));

CommonDataObject cdoPaq = new CommonDataObject();

//iPaqCds.clear(); 
//vPaqCds.clear();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdo = new CommonDataObject();

	if (mode.equalsIgnoreCase("add"))
	{
		comboId = "0";
		cdoPaq.addColValue("combo_id","0");

		iPaqUso.clear();
		vPaqUso.clear();
		iPaqInsumo.clear();
		vPaqInsumo.clear();
		iPaqProc.clear();
		vPaqProc.clear();
		iPaqCds.clear();
		vPaqCds.clear();
	}
	else
	{
		if (comboId.trim().equals("")) throw new Exception("El Perfil CPT no es válido. Por favor intente nuevamente!");

		sql = "select id combo_id, nombre combo_name, estado combo_status, observacion combo_observacion, usuario_creacion usuarioCreacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion from tbl_cds_combo_cargo where id="+comboId;

		cdoPaq = SQLMgr.getData(sql);

		if (change == null){
		
		   //USOS
		   sql = "select pd.id combo_id, pd.cod_cargo,pd.tipo_cargo,pd.descripcion,pd.cantidad,pd.observacion,pd.other1,pd.other2,pd.other3,pd.other4,pd.other5,pd.tipo_servicio, (select ts.descripcion from tbl_cds_tipo_servicio ts where codigo = pd.tipo_servicio and compania = "+compania+") as tipo_servicio_desc from tbl_cds_combo_cargo_det pd where pd.tipo_cargo = 'U' and pd.id = "+comboId;

		   al = SQLMgr.getDataList(sql);

		   iPaqUso.clear();
		   vPaqUso.clear();

		   paqUsoLastLineNo = al.size();

		   for (int i=1; i<=al.size(); i++){
				cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iPaqUso.put(key, cdo);
					vPaqUso.addElement(cdo.getColValue("combo_id")+"-"+cdo.getColValue("tipo_cargo")+"-"+cdo.getColValue("cod_cargo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
			
			
			//INSUMOS
			sql = "select pd.id combo_id, pd.cod_cargo,pd.tipo_cargo,pd.descripcion,pd.cantidad,pd.observacion,pd.other1,pd.other2,pd.other3,pd.other4,pd.other5,pd.tipo_servicio, (select ts.descripcion from tbl_cds_tipo_servicio ts where codigo = pd.tipo_servicio and compania = "+compania+") as tipo_servicio_desc from tbl_cds_combo_cargo_det pd where pd.tipo_cargo = 'I' and pd.id = "+comboId;

		    al = SQLMgr.getDataList(sql);

		    iPaqInsumo.clear();
		    vPaqInsumo.clear();

		    paqInsumoLastLineNo = al.size();

		    for (int i=1; i<=al.size(); i++){
				cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iPaqInsumo.put(key, cdo);
					vPaqInsumo.addElement(cdo.getColValue("combo_id")+"-"+cdo.getColValue("tipo_cargo")+"-"+cdo.getColValue("cod_cargo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
			
			//PROCEDIMIENTOS
			sql = "select pd.id combo_id, pd.cod_cargo,pd.tipo_cargo,pd.descripcion,pd.cantidad,pd.observacion,pd.other1,pd.other2,pd.other3,pd.other4,pd.other5,pd.tipo_servicio, (select ts.descripcion from tbl_cds_tipo_servicio ts where codigo = pd.tipo_servicio and compania = "+compania+") as tipo_servicio_desc from tbl_cds_combo_cargo_det pd where pd.tipo_cargo = 'P' and pd.id = "+comboId;

		    al = SQLMgr.getDataList(sql);

		    iPaqProc.clear();
		    vPaqProc.clear();

		    paqProcLastLineNo = al.size();

		    for (int i=1; i<=al.size(); i++){
				cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iPaqProc.put(key, cdo);
					vPaqProc.addElement(cdo.getColValue("combo_id")+"-"+cdo.getColValue("tipo_cargo")+"-"+cdo.getColValue("cod_cargo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
			
			
			//CENTRO DE SERVICIO
			
			sql = " select a.id as combo_id, a.cds, c.descripcion as centro_servicio_desc, a.status from tbl_cds_combo_cargo_x_cds a, tbl_cds_centro_servicio c where c.codigo = a.cds and a.id = "+comboId;
			al = SQLMgr.getDataList(sql);
			paqCdsLastLineNo = al.size();
			
			iPaqCds.clear();
			vPaqCds.clear();
			
			for (int i=1; i<=al.size(); i++)
			{
				cdo = (CommonDataObject) al.get(i-1);

			    if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try{
					iPaqCds.put(key, cdo);
					vPaqCds.addElement(cdo.getColValue("combo_id")+"-"+cdo.getColValue("cds"));
				}catch(Exception e){
				   System.err.println(e.getMessage());
				}
				
			}//for
			
			
			
		}// change == null

		comboStatusStr = "0=SELECCIONE,A=Aprobado,I=Inactivo";
	}

	if (cdoPaq == null) cdoPaq = new CommonDataObject();

	System.out.println(":::::::::::::::::::::::::::::::: MODE = "+mode);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function doAction(){
  <%if (request.getParameter("type") != null){%>
	<%if (tab.equals("1")){%>
	   showUsosList();
	<%}if (tab.equals("2")){%>
	   showInsumosList();
	<%}if (tab.equals("3")){%>
	   showProcedimientoList();
	<%}if (tab.equals("4")){%>
	  showCdsList();
	<%}%>
  <%}%>

}
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Paquete de Cargos - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Paquete de Cargos CPT - Edición - "+document.title;
<%}%>

function _doSubmit(fName){
  if (canSubmit()){
    document.forms[fName].submit();
  }else{
  	CBMSG.warning("Por favor ingrese el nombre del perfil!");
  }
}

function showCdsList(){
   abrir_ventana1('../common/check_centro_servicio.jsp?fp=paquete_cargos&mode=<%=mode%>&id=<%=comboId%>&paqCdsLastLineNo=<%=paqCdsLastLineNo%>');
}

function showProcedimientoList(){
	abrir_ventana1('../common/check_procedimiento.jsp?fp=paquete_cargos&mode=<%=mode%>&id=<%=comboId%>&paqProcLastLineNo=<%=paqProcLastLineNo%>&tab=<%=tab%>');
}

function showUsosList(){
	abrir_ventana1('../common/check_uso.jsp?fp=paquete_cargos&mode=<%=mode%>&id=<%=comboId%>&paqUsoLastLineNo=<%=paqUsoLastLineNo%>&tab=<%=tab%>');
}

function showInsumosList(){
	abrir_ventana1('../common/check_articulo.jsp?fp=paquete_cargos&mode=<%=mode%>&id=<%=comboId%>&paqInsumoLastLineNo=<%=paqInsumoLastLineNo%>&tab=<%=tab%>');
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function canSubmit(){
	return (document.form0.combo_name.value!="");
}

function printPackage(){
  abrir_ventana1("../admision/print_paquete_cargo_det.jsp?comboId=<%=comboId%>");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Paquete de Cargos"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<%if(mode.equals("edit")){%>
		<tr class="TextRow01"><td align="right"> <input type="button" value="Imprimir paquete" class="CellbyteBtn" onClick="javascript:printPackage()" /></td></tr>
	<%}%>	
	<tr>
		<td class="TableBorder">
			<!-- MAIN DIV STARTS HERE -->
			<div id = "dhtmlgoodies_tabView1">
		
			<!-- TAB0 DIV STARTS HERE-->
			<div class = "dhtmlgoodies_aTab">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("comboId",cdoPaq.getColValue("combo_id"))%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("paqUsoSize",""+iPaqUso.size())%>
			<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
			<%=fb.hidden("paqInsumoSize",""+iPaqInsumo.size())%>
			<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
			<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
			<%=fb.hidden("paqProcSize",""+iPaqProc.size())%>
			<%=fb.hidden("paqCdsSize",""+iPaqCds.size())%>
			<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
			<%=fb.hidden("fecha_creacion",cdoPaq.getColValue("fechaCreacion"))%>
			<%=fb.hidden("usuario_creacion",cdoPaq.getColValue("usuarioCreacion"))%>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel>Paquete de Cargos</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" >
					<td width="20%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="80%">&nbsp;<%=cdoPaq.getColValue("combo_id")%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Nombre</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("combo_name",cdoPaq.getColValue("combo_name"),true,false,false,98,500)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Estado</cellbytelabel></td>
					<td>&nbsp;<%=fb.select("combo_status",comboStatusStr,cdoPaq.getColValue("combo_status"),false,false,0,null,"","")%>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">Observaciones</cellbytelabel></td>
					<td>&nbsp;<%=fb.textarea("combo_observacion",cdoPaq.getColValue("combo_observacion"),false,false,false,100,2,1000,null,null,null)%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
					<% String form = "'"+fb.getFormName()+"'";%>
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value); _doSubmit("+form+")\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		   </div><!-- TAB0 DIV ENDS HERE -->
		   
		   <!-- TAB1 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">

				  <table align="center" width="100%" cellpadding="0" cellspacing="1">
				    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo","")%>
					<%=fb.hidden("tab","1")%>
					<%=fb.hidden("comboId",""+comboId)%>
					<%=fb.hidden("paqUsoSize",""+iPaqUso.size())%>
					<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
					<%=fb.hidden("paqInsumoSize",""+iPaqInsumo.size())%>
					<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
					<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
					<%=fb.hidden("paqProcSize",""+iPaqProc.size())%>
					<%=fb.hidden("paqCdsSize",""+iPaqCds.size())%>
					<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
					 <tr class="TextHeader">
						  <td colspan="6" align="left">&nbsp;Usos</td>
					 </tr>
					 <tr class="TextHeader01">
					 	<td colspan="6">[<%=comboId%>]<%=cdoPaq.getColValue("combo_name")%></td>
					 </tr>
					 <tr class="TextHeader02">
					 	<td width="10%">Id Uso</td>
						<td width="30%">Descripci&oacute;n</td>
						<td width="20%">Tipo Servicio</td>
						<td width="5%" align="center">Qty</td>
						<td width="30%">Observaciones</td>
						<td width="5%" align="center">
						<% form = "'"+fb.getFormName()+"'";%>
						<%=fb.submit("addUso","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Usos")%>
						</td>
					 </tr>

					<%
						al = CmnMgr.reverseRecords(iPaqUso);
						for (int i=1; i<=iPaqUso.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdoUso = (CommonDataObject) iPaqUso.get(key);
					%>
						<tr class="TextRow01">
							<td><%=cdoUso.getColValue("cod_cargo")%></td>
							<td><%=cdoUso.getColValue("descripcion")%></td>
							<td><%=cdoUso.getColValue("tipo_servicio_desc")%></td>
							<td align="center">
							<%=fb.intBox("cantidad"+i,cdoUso.getColValue("cantidad"),false,false,false,5,3,null,null,"")%>
							</td>
							<td><%=fb.textarea("observacion"+i,cdoUso.getColValue("observacion"),false,false,false,30,2)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Usos")%></td>
						</tr>
						<%=fb.hidden("key"+i,cdoUso.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("cod_cargo"+i,cdoUso.getColValue("cod_cargo"))%>
						<%=fb.hidden("tipo_cargo"+i,cdoUso.getColValue("tipo_cargo"))%>
						<%=fb.hidden("tipo_servicio"+i,cdoUso.getColValue("tipo_servicio"))%>					
						<%=fb.hidden("tipo_servicio_desc"+i,cdoUso.getColValue("tipo_servicio_desc"))%>					
						<%=fb.hidden("descripcion"+i,cdoUso.getColValue("descripcion"))%>					
					 <%}%>


				 <tr class="TextRow02">
					<td align="right" colspan="6">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>

		   </div><!-- TAB1 DIV ENDS HERE --> 
		   
		   
		   <!-- TAB2 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codigo","")%>
				<%=fb.hidden("tab","2")%>
				<%=fb.hidden("comboId",""+comboId)%>
				<%=fb.hidden("paqUsoSize",""+iPaqUso.size())%>
				<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
				<%=fb.hidden("paqInsumoSize",""+iPaqInsumo.size())%>
				<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
				<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
				<%=fb.hidden("paqProcSize",""+iPaqProc.size())%>
				<%=fb.hidden("paqCdsSize",""+iPaqCds.size())%>
				<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
				 <tr class="TextHeader">
					  <td colspan="6" align="left">&nbsp;Insumos</td>
				 </tr>
				 <tr class="TextHeader01">
					<td colspan="6">[<%=comboId%>]<%=cdoPaq.getColValue("combo_name")%></td>
				 </tr>
				 
				 <tr class="TextHeader02">
					<td width="10%">Id Insumo</td>
					<td width="30%">Descripci&oacute;n</td>
					<td width="20%">Tipo Servicio</td>
					<td width="5%" align="center">Qty</td>
					<td width="30%">Observaciones</td>
					<td width="5%" align="center">
					<% form = "'"+fb.getFormName()+"'";%>
					<%=fb.submit("addInsumo","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Insumos")%>
					</td>
				 </tr>
				 
				 <%
					al = CmnMgr.reverseRecords(iPaqInsumo);
					for (int i=1; i<=iPaqInsumo.size(); i++)
					{
						key = al.get(i - 1).toString();
						CommonDataObject cdoIns = (CommonDataObject) iPaqInsumo.get(key);
				%>
					<tr class="TextRow01">
						<td><%=cdoIns.getColValue("cod_cargo")%></td>
						<td><%=cdoIns.getColValue("descripcion")%></td>
						<td><%=cdoIns.getColValue("tipo_servicio_desc")%></td>
						<td align="center">
						<%=fb.intBox("cantidad"+i,cdoIns.getColValue("cantidad"),true,false,false,5,3,null,null,"")%>
						</td>
						<td><%=fb.textarea("observacion"+i,cdoIns.getColValue("observacion"),false,false,false,30,2)%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Insumo")%></td>
					</tr>
					<%=fb.hidden("key"+i,cdoIns.getColValue("key"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%=fb.hidden("cod_cargo"+i,cdoIns.getColValue("cod_cargo"))%>
					<%=fb.hidden("tipo_cargo"+i,cdoIns.getColValue("tipo_cargo"))%>
					<%=fb.hidden("tipo_servicio"+i,cdoIns.getColValue("tipo_servicio"))%>					
					<%=fb.hidden("tipo_servicio_desc"+i,cdoIns.getColValue("tipo_servicio_desc"))%>					
					<%=fb.hidden("descripcion"+i,cdoIns.getColValue("descripcion"))%>					
				 <%}%>
				 <tr class="TextRow02">
					<td align="right" colspan="6">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>
					 
		   </div><!-- TAB2 DIV ENDS HERE -->
		   
		   
		   <!-- TAB3 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codigo","")%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("comboId",""+comboId)%>
				<%=fb.hidden("paqUsoSize",""+iPaqUso.size())%>
				<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
				<%=fb.hidden("paqInsumoSize",""+iPaqInsumo.size())%>
				<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
				<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
				<%=fb.hidden("paqCdsSize",""+iPaqCds.size())%>
				<%=fb.hidden("paqProcSize",""+iPaqProc.size())%>
				<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
				 <tr class="TextHeader">
					  <td colspan="6" align="left">&nbsp;Procedimientos</td>
				 </tr>
				 <tr class="TextHeader01">
					<td colspan="6">[<%=comboId%>]<%=cdoPaq.getColValue("combo_name")%></td>
				 </tr>
				 
				 <tr class="TextHeader02">
					<td width="10%">Id Procedimiento</td>
					<td width="30%">Descripci&oacute;n</td>
					<td width="20%">Tipo Servicio</td>
					<td width="5%" align="center">Qty</td>
					<td width="30%">Observaciones</td>
					<td width="5%" align="center">
					<% form = "'"+fb.getFormName()+"'";%>
					<%=fb.submit("addProc","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Procedimientos")%>
					</td>
				 </tr>
				 
				 <%
					al = CmnMgr.reverseRecords(iPaqProc);
					for (int i=1; i<=iPaqProc.size(); i++)
					{
						key = al.get(i - 1).toString();
						CommonDataObject cdoProc = (CommonDataObject) iPaqProc.get(key);
				%>
					<tr class="TextRow01">
						<td><%=cdoProc.getColValue("cod_cargo")%></td>
						<td><%=cdoProc.getColValue("descripcion")%></td>
						<td><%=cdoProc.getColValue("tipo_servicio_desc")%></td>
						<td align="center">
						<%=fb.intBox("cantidad"+i,cdoProc.getColValue("cantidad"),true,false,false,5,3,null,null,"")%>
						</td>
						<td><%=fb.textarea("observacion"+i,cdoProc.getColValue("observacion"),false,false,false,30,2)%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Insumo")%></td>
					</tr>
					<%=fb.hidden("key"+i,cdoProc.getColValue("key"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%=fb.hidden("cod_cargo"+i,cdoProc.getColValue("cod_cargo"))%>
					<%=fb.hidden("tipo_cargo"+i,cdoProc.getColValue("tipo_cargo"))%>
					<%=fb.hidden("tipo_servicio"+i,cdoProc.getColValue("tipo_servicio"))%>					
					<%=fb.hidden("tipo_servicio_desc"+i,cdoProc.getColValue("tipo_servicio_desc"))%>					
					<%=fb.hidden("descripcion"+i,cdoProc.getColValue("descripcion"))%>					
				 <%}%>
				 <tr class="TextRow02">
					<td align="right" colspan="6">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>
					 
		   </div><!-- TAB3 DIV ENDS HERE -->
		   
		   
		   <!-- TAB4 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("codigo","")%>
				<%=fb.hidden("tab","4")%>
				<%=fb.hidden("comboId",""+comboId)%>
				<%=fb.hidden("paqUsoSize",""+iPaqUso.size())%>
				<%=fb.hidden("paqUsoLastLineNo",""+paqUsoLastLineNo)%>
				<%=fb.hidden("paqInsumoSize",""+iPaqInsumo.size())%>
				<%=fb.hidden("paqInsumoLastLineNo",""+paqInsumoLastLineNo)%>
				<%=fb.hidden("paqCdsLastLineNo",""+paqCdsLastLineNo)%>
				<%=fb.hidden("paqCdsSize",""+iPaqCds.size())%>
				<%=fb.hidden("paqProcSize",""+iPaqProc.size())%>
				<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
				 <tr class="TextHeader">
					  <td colspan="6" align="left">&nbsp;Centros de Servicio</td>
				 </tr>
				 <tr class="TextHeader01">
					<td colspan="6">[<%=comboId%>]<%=cdoPaq.getColValue("combo_name")%></td>
				 </tr>
				 
				 <tr class="TextHeader02">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="75%" align="left">Descripci&oacute;n</td>
					<td width="10%" align="center">Estado</td>
					<td width="5%" align="center">
					<% form = "'"+fb.getFormName()+"'";%>
					<%=fb.submit("addCds","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Centros de Servicio")%>
					</td>
				 </tr>
				 
				 <%
					al = CmnMgr.reverseRecords(iPaqCds);
					for (int i=1; i<=iPaqCds.size(); i++)
					{
						key = al.get(i - 1).toString();
						CommonDataObject cdoCds = (CommonDataObject) iPaqCds.get(key);
				%>
					<tr class="TextRow01">
						<td align="center"><%=cdoCds.getColValue("cds")%></td>
						<td><%=cdoCds.getColValue("centro_servicio_desc")%></td>
						<td align="center"><%=fb.select("status"+i,"A=Activo,I=Inactivo",cdoCds.getColValue("status"),false,false,0,null,"","")%></td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Insumo")%></td>
					</tr>
					<%=fb.hidden("key"+i,cdoCds.getColValue("key"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%=fb.hidden("centro_servicio"+i,cdoCds.getColValue("cds"))%>
					<%=fb.hidden("centro_servicio_desc"+i,cdoCds.getColValue("centro_servicio_desc"))%>					
				 <%}%>
				 <tr class="TextRow02">
					<td align="right" colspan="6">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>
					 
		   </div><!-- TAB4 DIV ENDS HERE -->
		   

		   </div><!-- MAIN DIV ENDS HERE -->
		</td>
	</tr>
</table>
<script type="text/javascript">
<%
String disabledTab = "";
String tabLabel = "'Paquete Cargos'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Uso','Insumo','Procedimiento','Centros de Servicio'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,null,[<%=disabledTab%>]);
</script>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");

	if (tab.equals("0")){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_cds_combo_cargo");
		cdo.addColValue("compania", compania);
		cdo.addColValue("nombre",request.getParameter("combo_name"));
		if(request.getParameter("combo_status")!=null&& !request.getParameter("combo_status").equals("0"))
			cdo.addColValue("estado",request.getParameter("combo_status"));
		cdo.addColValue("observacion",request.getParameter("combo_observacion"));
		cdo.addColValue("usuario_modificacion",cUserName);
		cdo.addColValue("fecha_modificacion",cDate);

	  if (mode.equalsIgnoreCase("add"))
	  {
		cdo.addColValue("usuario_creacion",cUserName);
		cdo.addColValue("fecha_creacion",cDate);
		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");
		
		SQLMgr.insert(cdo);
		comboId = SQLMgr.getPkColValue("id");
	  }
	  else
	  {
		cdo.setWhereClause("id="+comboId);
		SQLMgr.update(cdo);
	  }

    }
  	else if (tab.equals("1")||tab.equals("2")||tab.equals("3")) 
	{
		int size = 0;
		String xtraWhere = "";

		if (tab.equals("1")){
			if (request.getParameter("paqUsoSize") != null) size = Integer.parseInt(request.getParameter("paqUsoSize"));
			xtraWhere = " and tipo_cargo = 'U'";
		}
		if (tab.equals("2")){
			if (request.getParameter("paqInsumoSize") != null) size = Integer.parseInt(request.getParameter("paqInsumoSize"));
			xtraWhere = " and tipo_cargo = 'I'";
		}
		if (tab.equals("3")){
			if (request.getParameter("paqProcSize") != null) size = Integer.parseInt(request.getParameter("paqProcSize"));
			xtraWhere = " and tipo_cargo = 'P'";
		}

		String itemRemoved = "";
		al.clear();

		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_cds_combo_cargo_det");

			cdo.addColValue("id",comboId);
			cdo.addColValue("cod_cargo",request.getParameter("cod_cargo"+i));
			cdo.addColValue("tipo_cargo",request.getParameter("tipo_cargo"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+i));
			cdo.addColValue("tipo_servicio_desc",request.getParameter("tipo_servicio_desc"+i));
			
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("_usoCode",comboId+"-"+request.getParameter("tipo_cargo"+i)+"-"+request.getParameter("cod_cargo"+i));
			
			System.out.println("::::::::::::::::::::::::::::::::: xtraWhere = "+xtraWhere);
			cdo.setWhereClause("/*-----------------------------------------*/id="+comboId+xtraWhere);

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					if (tab.equals("1")){
						iPaqUso.put(cdo.getColValue("key"),cdo);
					}
					if (tab.equals("2")){
						iPaqInsumo.put(cdo.getColValue("key"),cdo);
					}
					if (tab.equals("3")){
						iPaqProc.put(cdo.getColValue("key"),cdo);
					}
	
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
		if (!itemRemoved.equals(""))
		{
			if (tab.equals("1")){
				vPaqUso.remove(((CommonDataObject) iPaqUso.get(itemRemoved)).getColValue("_usoCode"));	
				iPaqUso.remove(itemRemoved);
			}
			if (tab.equals("2")){
				vPaqInsumo.remove(((CommonDataObject) iPaqInsumo.get(itemRemoved)).getColValue("_usoCode"));	
				iPaqInsumo.remove(itemRemoved);
			}
			if (tab.equals("3")){
				vPaqProc.remove(((CommonDataObject) iPaqProc.get(itemRemoved)).getColValue("_usoCode"));	
				iPaqProc.remove(itemRemoved);
			}
			
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&comboId="+comboId+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&paqProcLastLineNo="+paqProcLastLineNo);
			return;
		}
		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&comboId="+comboId+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&paqProcLastLineNo="+paqProcLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			
			cdo.setTableName("tbl_cds_combo_cargo_det");
			cdo.setWhereClause("id="+comboId+xtraWhere);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}

	else if (tab.equals("4")){
	
	    int size = Integer.parseInt(request.getParameter("paqCdsSize"));
		String itemRemoved = "", lastRemCode = "";
	
		al.clear();
		
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_cds_combo_cargo_x_cds");
			cdo.setWhereClause("id = "+comboId);
			
			cdo.addColValue("key",request.getParameter("key"+i));
			
			cdo.addColValue("_usoCode",comboId+"-"+request.getParameter("centro_servicio"+i));
			cdo.addColValue("id",comboId);
			cdo.addColValue("cds",request.getParameter("centro_servicio"+i));
			cdo.addColValue("status",request.getParameter("status"+i));
			cdo.addColValue("centro_servicio_desc",request.getParameter("centro_servicio_desc"+i));

			
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
				itemRemoved = cdo.getColValue("key");
			} 
			else {
				try
				{
					iPaqCds.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vPaqCds.remove(((CommonDataObject) iPaqUso.get(itemRemoved)).getColValue("_usoCode"));	
			iPaqCds.remove(itemRemoved);
			
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&comboId="+comboId+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&paqProcLastLineNo="+paqProcLastLineNo+"&paqCdsLastLineNo="+paqCdsLastLineNo);
			return;
		}
	   
		if (baction != null && baction.equals("+"))
		{	
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab="+tab+"&mode="+mode+"&paqUsoLastLineNo="+paqUsoLastLineNo+"&comboId="+comboId+"&paqInsumoLastLineNo="+paqInsumoLastLineNo+"&paqProcLastLineNo="+paqProcLastLineNo+"&paqCdsLastLineNo="+paqCdsLastLineNo);
			return;
		}
		
		if(baction != null && baction.equals("Guardar"))
		{
			if (al.size() == 0)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.setTableName("tbl_cds_combo_cargo_x_cds");
				cdo.setWhereClause("id="+comboId);

				al.add(cdo);
			}
			
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertList(al);
			ConMgr.clearAppCtx(null);
		}
	
	}// cds

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
	window.opener.location = '<%=request.getContextPath()%>/admision/paquete_cargos_list.jsp';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.opener.location = '<%=request.getContextPath()%>/admision/paquete_cargos_list.jsp';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?comboId=<%=comboId%>&mode=edit&tab=<%=tab%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>