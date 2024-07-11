<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Contrato"%>
<%@ page import="issi.contabilidad.DetalleContrato"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="ContrMgr" scope="page" class="issi.contabilidad.ContratoMgr" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096") || SecMgr.checkAccess(session.getId(),"900097") || SecMgr.checkAccess(session.getId(),"900098") || SecMgr.checkAccess(session.getId(),"900099") || SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
ContrMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String key = "";
int lastLineNo = 0;
Contrato contr = new Contrato();

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (mode.equalsIgnoreCase("add"))
  { 
	   HashDet.clear(); 
	   code = "0";		 	 
  }else{
		  if (code == null) throw new Exception("El Contrato no es válido. Por favor intente nuevamente!");
		  
		  sql = "SELECT a.contrato, a.tipo_cliente as tipoClteCode, b.descripcion as tipoClte, a.estado, a.particular as clienteCode, c.descripcion as cliente, a.tipo_contrato as tipoContr, a.morosidad, a.tipo_morosidad as tipoMoroso, to_char(a.fecha_inicio,'dd/mm/yyyy hh24.mi:ss') as fechaIni, to_char(a.fecha_expiracion,'dd/mm/yyyy hh24.mi:ss') as fechaExp FROM tbl_cxc_contrato_alq a, tbl_fac_tipo_cliente b, tbl_cxc_cliente_particular c WHERE a.tipo_cliente=b.codigo and a.compania=b.compania and a.particular=c.codigo and a.contrato="+code+" and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId");
		  contr = (Contrato) sbb.getSingleRowBean(ConMgr.getConnection(),sql, Contrato.class);
			
		  sql = "SELECT a.secuencia, a.cod_tipo_alq as tipoAlqCode, b.descripcion as tipoAlq, a.cod_alquiler as alquilerCode, c.descripcion as alquiler, a.precio, a.estatus FROM tbl_cxc_det_contrato_alq a, tbl_cxc_tipo_alquiler b, tbl_cxc_alquileres c WHERE a.cod_tipo_alq=b.cod_tipo_alq and a.compania=b.compania and a.cod_alquiler=c.cod_alquiler and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.contrato="+code+" order by a.secuencia";
		  al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleContrato.class);                   
		  	
		  HashDet.clear(); 
		 			
		  for (int i = 1; i <= al.size(); i++)
		  {
		    if (i < 10) key = "00" + i;
		    else if (i < 100) key = "0" + i;
		    else key = "" + i;

		    HashDet.put(key, al.get(i-1));
		    lastLineNo = i;
		  }  	  			
      }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Contrato Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Contrato Edición - "+document.title;
<%}%>

function addTipoClte()
{
  abrir_ventana1('contrato_tipocliente_list.jsp');
}

function addCliente()
{
  abrir_ventana1('contrato_cliente_list.jsp');
}

function saveMethod()
{
   window.frames['detalle'].formDetalle.baction.value = "Guardar";
   window.frames['detalle'].doSubmit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ALQUILER - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">   

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

                <tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Contrato Alquiler</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr> 
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="15%">Contrato</td>
								<td width="45%"><%=fb.textBox("contrato",code,false,false,true,10)%></td>
								<td width="18%">Estado</td> 
								<td width="22%"><%=fb.select("estado","A=Activo,I=Inactivo",contr.getEstado())%></td>							
							</tr>
							<tr class="TextRow01"> 
							    <td>Tipo de Cliente</td>
								<td><%=fb.textBox("tipoClteCode",contr.getTipoClteCode(),false,false,true,5)%><%=fb.textBox("tipoClte",contr.getTipoClte(),false,false,true,40)%><%=fb.button("btntipoclte","...",true,false,null,null,"onClick=\"javascript:addTipoClte()\"")%></td>	
								<td>Tipo de Contrato</td> 
								<td><%=fb.select("tipo","1=Otros Cargos,2=Solo Cargos",contr.getTipoContr())%></td>							
							</tr>
							<tr class="TextRow01"> 
							    <td>Tipo Morosidad</td> 
								<td><%=fb.select("tipoMoroso","1=Consultorio,2=Apartamento",contr.getTipoMoroso())%></td>
								<td>No Aplica Morosidad</td> 
								<td><%=fb.select("morosidad","S=Si,N=No",contr.getMorosidad())%></td>
							</tr>	
							<tr class="TextRow01"> 
								<td>Cliente</td><%//=fb.hidden("prov",contr.getProvEmp())%><%//=fb.hidden("sigla",contr.getSiglaEmp())%><%//=fb.hidden("tomo",contr.getTomoEmp())%><%//=fb.hidden("asiento",contr.getAsientoEmp())%><%//=fb.hidden("noEmp",contr.getEmpCode())%>
								<td><%=fb.textBox("clienteCode",contr.getClienteCode(),false,false,true,5)%><%=fb.textBox("cliente",contr.getCliente(),false,false,true,40)%><%=fb.button("btncliente","...",true,false,null,null,"onClick=\"javascript:addCliente()\"")%></td> 
								<td>Fecha Inicio</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fechaIni" />
									<jsp:param name="valueOfTBox1" value="<%=contr.getFechaIni()%>" />
									</jsp:include>
								</td> 								
							</tr>							
							<tr class="TextRow01"> 
							    <td>Tel&eacute;fono</td> 
								<td><%=fb.textBox("telefono","",false,false,false,50)%></td> 
								<td>Fecha Expiraci&oacute;n</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fechaExp" />
									<jsp:param name="valueOfTBox1" value="<%=contr.getFechaExp()%>" />
									</jsp:include>
								</td> 								
							</tr>	
							<tr class="TextRow01"> 
							    <td>Direcci&oacute;n</td> 
								<td colspan="3"><%=fb.textBox("direccion","",false,false,false,50)%></td> 								
							</tr>														
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Detalle del Contrato</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="detalle" id="detalle" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../contabilidad/detallecontrato_config.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>				 				  
	
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
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
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/contratoalquiler_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/contratoalquiler_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/contratoalquiler_list.jsp';
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>