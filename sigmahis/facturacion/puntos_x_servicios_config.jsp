<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.facturacion.Puntos"%>
<%@ page import="issi.facturacion.Servicios"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iServ" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

Puntos pto = new Puntos();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String modeServ = request.getParameter("modeServ");
String code = request.getParameter("code");
String codCat = "";
String change = request.getParameter("change");
int lastLineNo = 0;

if (mode == null) mode = "add";
if (modeServ == null) modeServ = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
if (request.getParameter("codCat") != null) codCat = request.getParameter("codCat");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
	    iServ.clear();
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");

		sql = "SELECT codigo, descripcion, valor, estado, cap_code as capCode FROM tbl_fac_serv_pto_hna WHERE codigo ="+code+" and compania ="+(String) session.getAttribute("_companyId")+" and cod_cat ="+codCat;
		pto = (Puntos) sbb.getSingleRowBean(ConMgr.getConnection(),sql, Puntos.class);		

		if (change == null)
		{
			sql = "SELECT a.cod_cat as codCat, a.cod_serv as codServ, a.secuencia, decode(a.centro_servicio,null,' ',a.centro_servicio) as centroServicio, nvl(a.tipo_servicio,' ') as tipoServicio, decode(a.cod_flia,null,' ',a.cod_flia) as codFlia, decode(a.cod_clase,null,' ',a.cod_clase) as codClase, decode(a.cod_articulo,null,' ',a.cod_articulo) as codArticulo, b.descripcion as codArticuloDesc, decode(a.cod_uso,null,' ',a.cod_uso) as codUso, nvl(a.cod_procedimiento,' ') as codProcedimiento, nvl(a.cod_habitacion,' ') as codHabitacion, decode(a.cantidad,null,' ',a.cantidad) as cantidad, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(a.usuario_creacion,' ') as usuarioCreacion FROM tbl_fac_def_serv_pto_hna a, tbl_inv_articulo b WHERE a.cod_flia=b.cod_flia(+) and a.cod_clase=b.cod_clase(+) and a.cod_articulo=b.cod_articulo(+) and a.compania=b.compania(+) and a.cod_cat ="+codCat+" and a.cod_serv ="+code+" and a.compania ="+(String) session.getAttribute("_companyId");
			
            al = sbb.getBeanList(ConMgr.getConnection(), sql, Servicios.class);
			 
			iServ.clear(); 
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  iServ.put(key, al.get(i-1));			
		    }  	 			
		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Puntos por Servicios - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Puntos por Servicios - Edición - "+document.title;
<%}%>

function adjustIFrameSize (iframeWindow) 
{
	if (iframeWindow.document.height) {
	var iframeElement = document.getElementById (iframeWindow.name);
	iframeElement.style.height = (parseInt(iframeWindow.document.height,10) + 16) + 'px';
//            iframeElement.style.width = iframeWindow.document.width + 'px';
	}
	else if (document.all) {
	var iframeElement = document.all[iframeWindow.name];
	if (iframeWindow.document.compatMode &&
	iframeWindow.document.compatMode != 'BackCompat')
	{
	iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
	}
	else {
	iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
	}
	}
}
function saveMethod()
{
  if (form0Validation())
  {  
     window.frames['itemFrame1'].formPuntos.baction.value = "Guardar";
     window.frames['itemFrame1'].doSubmit();
  }  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACION - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("codCat",codCat)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Puntos por Servicios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td><cellbytelabel>Puntos por Servicios</cellbytelabel></td>
							    <td colspan="5"><%=fb.intBox("codigo",code,true,false,true,15,3)%><%=fb.textBox("descripcion",pto.getDescripcion(),true,false,false,90,2000)%></td>							
							</tr>
							<tr class="TextRow01">
								<td width="15%"><cellbytelabel>Puntos</cellbytelabel></td>
							    <td width="25%"><%=fb.decBox("valor",pto.getValor(),false,false,false,15,4.2)%></td>														
								<td width="10%"><cellbytelabel>Cap.Code</cellbytelabel></td>
							    <td width="25%"><%=fb.textBox("capCode",pto.getCapCode(),false,false,false,20,10)%></td>
								<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
							    <td width="15%"><%=fb.select("estado","A=Activo,I=Inactivo",pto.getEstado())%></td>							
							</tr>														
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel>Servicios Relacionados</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="itemFrame1" id="itemFrame1" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../facturacion/serviciosrela_detail.jsp?mode=<%=mode%>&modeServ=<%=modeServ%>&lastLineNo=<%=lastLineNo%>&code=<%=code%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
  codCat = request.getParameter("codCat");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/puntos_x_servicios_list.jsp?codCat="+codCat))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/puntos_x_servicios_list.jsp?codCat="+codCat)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/puntos_x_servicios_list.jsp?codCat=<%=codCat%>';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&codCat=<%=codCat%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>