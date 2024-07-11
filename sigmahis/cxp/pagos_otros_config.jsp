<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();

String sql="";
String mode=request.getParameter("mode");
String codigo=request.getParameter("code");
String compId=request.getParameter("compId");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";
String replicar = "N";
String fp = request.getParameter("fp");
if(request.getParameter("replicar")!=null) replicar = request.getParameter("replicar");


if (mode == null) mode = "add";
if (fp == null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	cdo.addColValue("codigo","0");
	fechaCrea = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	userCrea  = UserDet.getUserName();
	fechaMod  = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	userMod   = UserDet.getUserName();	
	}
	else
	{ if (codigo == null) throw new Exception("Código no es válido. Por favor intente nuevamente!");
	   
		 fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		 userMod  = UserDet.getUserEmpId();
	
sql = "select a.codigo, nombre, decode(a.estado,'A','ACTIVO','I','INACTIVO') estadoDes, a.estado, a.ruc, a.digito_verificador, a.direccion, a.telefono, a.fax, a.apartado_postal, a.zona_postal, a.tipo_codigo, a.codigo_original medicoRefId, a.tipo_persona, a.ruta_transito ruta, a.cuenta_bancaria, a.tipo_cuenta, a.usuario_creacion userCrea, to_char(a.fecha_creacion,'dd/mm/yyyy') fechaCrea, a.usuario_modificacion userMod,  c.nombre_banco rutaname, to_char(a.fecha_modificacion,'dd/mm/yyyy') fechaMod, (case when a.tipo_codigo in ('M', 'E') then (select b.primer_nombre||' '||b.primer_apellido from tbl_adm_medico b where a.codigo_original = b.codigo) when a.tipo_codigo = 'P' then (select nombre_proveedor from tbl_com_proveedor p where to_char(p.cod_provedor) = a.codigo_original) end) medicoRefNombre, a.email from tbl_con_pagos_otros a, tbl_adm_ruta_transito c where a.compania = "+(String) session.getAttribute("_companyId")+" and a.ruta_transito = c.ruta(+) and a.codigo = "+codigo;
cdo = SQLMgr.getData(sql);
	}
	if(replicar.equals("S")){
	cdo = new CommonDataObject();
	cdo.addColValue("codigo","0");
	cdo.addColValue("nombre", request.getParameter("r_name"));
	cdo.addColValue("medicoRefNombre", request.getParameter("r_name"));
	cdo.addColValue("ruc", request.getParameter("r_ruc"));
	cdo.addColValue("digito_verificador", request.getParameter("r_dv"));
	cdo.addColValue("medicoRefId", request.getParameter("r_id"));
	cdo.addColValue("tipo_codigo", "P");
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
<%if(mode.equals("add")){%>
document.title="Pago Otros Agregar - "+document.title;
<%}else if(mode.equals("edit")){%>
document.title="Pago Otros Editar - "+document.title;
<%}%>
function medico()
{
var cod = document.form1.tipo_codigo.value;
if (cod=='M') abrir_ventana1('../common/search_medico.jsp?fp=resAdmision');
if (cod=='E') abrir_ventana1('../common/search_empresa.jsp?fp=pago_otro');
if (cod=='P') abrir_ventana1('../common/search_proveedor.jsp?fp=pago_otro');

}
function banco()
{
 abrir_ventana1('../rhplanilla/list_ruta.jsp');
}
function company()
{
abrir_ventana1('../rhplanilla/list_compania.jsp');
}
function checkRuc()
{
 	var ruc=document.form1.ruc.value; 
	var tipo = document.form1.tipo_codigo.value; 
	if(tipo=='')tipo='X';
 		if(ruc !='')
		{
			var v_msg = getDBData('<%=request.getContextPath()%>','getVerificaRucCliente(<%=(String) session.getAttribute("_companyId")%>,\''+ruc+'\',\''+tipo+'\',\'CXP\',<%=cdo.getColValue("codigo")%>)as msg','dual','');    	    if(v_msg!='-'){alert('Favor verificar mantenimiento ya que existen Registros con el mismo RUC y Tipo. \n '+v_msg.replace(';','\n'));
					   document.form1.ruc.blur(); document.form1.ruc.value='';
			}
		}
}
function doAction()
{
	document.form1.ruc.select(); 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PAGO OTROS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder" width="100%">
<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",codigo)%>
			<%=fb.hidden("userCrea",userCrea)%>
			<%=fb.hidden("userMod",userMod)%>
			<%=fb.hidden("fechaCrea",fechaCrea)%>
			<%=fb.hidden("fechaMod",fechaMod)%>
			<%=fb.hidden("medicoRefTel","")%>
			<%=fb.hidden("fp",fp)%>
	<tr>
		<td width="100%">&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr> 
		<td> 
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TGenerales" align="left" width="100%"  onClick="javascript:verocultar(panel0)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TGenerales');" onMouseout="bcolor('#8f9ba9','TGenerales');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;<cellbytelabel>Informaci&oacute;n General</cellbytelabel> </td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr> 
					<td> 	
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">							
						<tr class="TextHeader">
							<td width="20%">&nbsp;<cellbytelabel>Generales</cellbytelabel></td>
							<td width="30%">&nbsp;</td>
							<td width="20%">&nbsp;</td>
							<td width="30%">&nbsp;</td>
						</tr>								
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
							<td colspan="3"><%=fb.intBox("codigo",cdo.getColValue("codigo"),true,false,false,5,5)%>
							<%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,60,60)%></td>
							
						</tr>
						
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>R.U.C</cellbytelabel>./<cellbytelabel>Cédula/Pasaporte</cellbytelabel></td>
							<td><%=fb.textBox("ruc",cdo.getColValue("ruc"),false,false,false,10,30,null,null,"onBlur=\"javascript:checkRuc()\"")%></td>
							<td>&nbsp;<cellbytelabel>D&iacute;gito Verificador</cellbytelabel></td>
							<td><%=fb.intBox("digito_verificador",cdo.getColValue("digito_verificador"),false,false,false,5,2)%></td>
							
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Tipo Referencia</cellbytelabel></td>
							<td colspan="3"><%=fb.select("tipo_codigo","M=Médico,E=Empresa,P=Proveedor",cdo.getColValue("tipo_codigo"),false,false,0,"","","onChange=\"javascript:checkRuc()\"","","S")%> </td>
						</tr>	
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
							<td colspan="3"><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),"")%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
							<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,35,35)%></td>
							<td>&nbsp;<cellbytelabel>Correo Electr&oacute;nica</cellbytelabel></td>
							<td><%=fb.textBox("email",cdo.getColValue("email"),false,false,false,35,100)%></td>
						</tr>		
						
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Tel&iacute;fono</cellbytelabel></td>
							<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,10,10)%></td>
							<td>&nbsp;<cellbytelabel>Fax</cellbytelabel></td>
							<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,10,10)%></td>
							
						</tr>	
							<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Zona Postal</cellbytelabel></td>
							<td><%=fb.textBox("zona_postal",cdo.getColValue("zona_postal"),false,false,false,10,10)%></td>
							<td>&nbsp;<cellbytelabel>Apartado Postal</cellbytelabel></td>
							<td><%=fb.textBox("apartado_postal",cdo.getColValue("apartado_postal"),false,false,false,10,10)%></td>
							
						</tr>		
						<tr class="TextRow01">
							<td colspan="4">&nbsp;</td>
						</tr>													
				    </table>
				   	</div>
				  	</td>
				</tr>
			</table>			
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPatronales" align="left" width="100%" onClick="javascript:verocultar(panel3)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TPatronales');" onMouseout="bcolor('#8f9ba9','TPatronales');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;<cellbytelabel>Informaci&oacute;n para Pagos</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel3" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						<tr class="TextRow01">
							<td width="20%">&nbsp;</td>
							<td width="13%" align="center">&nbsp;</td>
							<td width="67%">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
							<td colspan="2"><%=fb.textBox("cuenta_bancaria",cdo.getColValue("cuenta_bancaria"),false,false,false,15,15)%>&nbsp;</td>					
						</tr>
		
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Ruta de Transito</cellbytelabel></td>
							<td colspan="2"><%=fb.textBox("ruta",cdo.getColValue("ruta"),false,false,true,15)%>&nbsp;<%=fb.textBox("rutaname",cdo.getColValue("rutaname"),false,false,true,29)%>
				                <%=fb.button("btnruta","...",false,false,null,null,"onClick=\"javascript:banco()\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;<cellbytelabel>Tipo de Cuenta</cellbytelabel></td>
							<td colspan="2"><%=fb.select("tipo_cuenta","03=CORRIENTE,04=AHORRO,07=PRESTAMO,43=TARJ.CREDITO",cdo.getColValue("tipo_cuenta"),"S")%></td>
						</tr>
						
						<tr class="TextRow01">
							<td colspan="3">&nbsp;</td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;</td>
							<td>&nbsp;<cellbytelabel>Tipo de Persona</cellbytelabel></td>
							<td><%=fb.select("tipo_persona","1=NATURAL,2=JURIDICO",cdo.getColValue("tipo_persona"),"S")%>&nbsp;</td>
						</tr>
						
						<tr class="TextRow01">
							<td colspan="3">&nbsp;</td>
						</tr>
						
						<tr class="TextRow01">
						  <td>&nbsp;</td>
							<td colspan="2">&nbsp; 
								<cellbytelabel>Nota:  en esta secci&oacute;n debe de capturarse la informaci&oacute;n bancaria para los pagos <br>por ACH  y tambien para los reportes del Ministerio de Econom&iacute;a y Finanzas. <br> Llenar si amerita el caso.</cellbytelabel></td>
						</tr>
						</table>						
					</div>
					</td>
				</tr>					
			</table>	
		</td>
	</tr>				
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TOtros" align="left" width="100%" onClick="javascript:verocultar(panel1)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TOtros');" onMouseout="bcolor('#8f9ba9','TOtros');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;<cellbytelabel>Informaci&oacute;n Liquidaciones</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel1" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="20%">&nbsp;</td>
								<td width="60%" align="center">&nbsp;</td>
								<td width="20%">&nbsp;</td>
							</tr>
							
							<tr class="TextRow01">
								<td>&nbsp;</td>
								<td colspan="2" align="left">&nbsp; &nbsp;&nbsp;<cellbytelabel>Nombres Referencial(Segun campo tipo  Referencia)</cellbytelabel></td>
								</tr>
							
							<tr class="TextRow01">	
							<td>&nbsp;</td>
								<td colspan="2" align="left">&nbsp;<%=fb.textBox("medicoRefId",cdo.getColValue("medicoRefId"),false,false,false,15)%>&nbsp;<%=fb.textBox("medicoRefNombre",cdo.getColValue("medicoRefNombre"),false,false,false,49)%>
				                <%=fb.button("btnmedico","...",false,false,null,null,"onClick=\"javascript:medico()\"")%></td>
							</tr>
							
							<tr class="TextRow01">
								<td colspan="3" align="left">&nbsp;</td>
							</tr>
							
							<tr class="TextRow01">
						  <td>&nbsp;</td>
							<td colspan="2">&nbsp; 
								<cellbytelabel>Nota:  en esta secci&oacute;n se amarra el c&oacute;digo utilizado para las liquidaciones autom&aacute;ticas <br>con el c&oacute;digo correspondiente en pagos otros. Generalmente es para empresa y m&eacute;dico. <br> Llenar si amerita el caso.</cellbytelabel></td>
						</tr>
							
							
						</table>						
					</div>
					</td>
				</tr>					
			</table>	
		</td>
	</tr>	
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TDescuentos" align="left" width="100%" onClick="javascript:verocultar(panel2)" style=" background-color:#8f9ba9;  border-bottom:1.5pt solid #808080;" onMouseover="bcolor('#5c7188','TDescuentos');" onMouseout="bcolor('#8f9ba9','TDescuentos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextHeader">
								<td width="98%">&nbsp;<cellbytelabel>Bit&aacute;cora</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
					<td>
					<div id="panel2" style="display:none">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextHeader">
								<td width="20%" align="center">&nbsp;</td>
								<td width="30%" align="center">&nbsp;</td>
								<td width="30%" align="center">&nbsp;</td>
								<td width="20%" align="center">&nbsp;</td>
								
							</tr>
							
							<tr class="TextRow01">
							<td>&nbsp; </td>
							<td colspan="2" align="center"> <cellbytelabel>Datos de Creaci&oacute;n del Registro</cellbytelabel> </td>
							<td>&nbsp; </td>
							</tr>
							
							<tr class="TextRow01">
								<td>&nbsp;</td>
								<td align="right"><%=fb.textBox("fechaCrea",cdo.getColValue("fechaCrea"),false,false,true,7,8)%></td>
							  <td>&nbsp;&nbsp;<%=fb.textBox("userCrea",cdo.getColValue("userCrea"),false,false,true,10,10)%></td>
								<td>&nbsp;</td>
							</tr>
							
							<tr class="TextRow01">
							<td>&nbsp; </td>
							<td colspan="2" align="center"> <cellbytelabel>Datos de Modificaci&oacute;n del Registro</cellbytelabel> </td>
							<td>&nbsp; </td>
							</tr>
							
							<tr class="TextRow01">
								<td>&nbsp;</td>
								<td align="right"><%=fb.textBox("fechaMod",cdo.getColValue("fechaMod"),false,false,true,7,8)%></td>
							  <td>&nbsp;&nbsp;<%=fb.textBox("userMod",cdo.getColValue("userMod"),false,false,true,10,10)%></td>
								<td>&nbsp;</td>
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
}//GET
else
{
    cdo = new CommonDataObject();
   cdo.setTableName("tbl_con_pagos_otros");
   //Parametros Param=new Parametros();
  
  cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("ruc",request.getParameter("ruc"));
	cdo.addColValue("digito_verificador",request.getParameter("digito_verificador"));
	cdo.addColValue("direccion",request.getParameter("direccion"));
  cdo.addColValue("telefono",request.getParameter("telefono"));
  cdo.addColValue("fax",request.getParameter("fax"));
  cdo.addColValue("apartado_postal",request.getParameter("apartado_postal"));
  cdo.addColValue("zona_postal",request.getParameter("zona_postal"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
	cdo.addColValue("tipo_codigo",request.getParameter("tipo_codigo"));
  cdo.addColValue("codigo_original",request.getParameter("medicoRefId"));
  cdo.addColValue("tipo_persona",request.getParameter("tipo_persona"));
	cdo.addColValue("ruta_transito",request.getParameter("ruta"));
	cdo.addColValue("cuenta_bancaria",request.getParameter("cuenta_bancaria"));
	cdo.addColValue("tipo_cuenta",request.getParameter("tipo_cuenta"));
	cdo.addColValue("email",request.getParameter("email"));
  
	
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));  	
		cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	  cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
	}
	else 
	{
		 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and codigo="+request.getParameter("codigo"));
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
	if (fp!=null && fp.equals("proveedor"))
	{
%>
	window.opener.location = '../compras/proveedor_list.jsp';
<%
	}
	else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxp/pagos_otros_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxp/pagos_otros_list.jsp")%>';
<%
	} else 
	{
%>
window.opener.location = '<%=request.getContextPath()%>/cxp/pagos_otros_list.jsp';
<%
	}
%>
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