<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.rhplanilla.TipoTransac"%>
<%@ page import="issi.rhplanilla.SubTipoTransac"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTrans" scope="session" class="java.util.Hashtable" />
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

TipoTransac tip = new TipoTransac();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
int lastLineNo = 0;
if (mode == null) mode = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	    iTrans.clear();
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Transacciones no es válido. Por favor intente nuevamente!");

		sql = "SELECT codigo, nvl(descripcion,' ') as descripcion, FACTOR_MULTI as factorMulti,clase_trx as claseTrx FROM tbl_pla_tipo_transaccion WHERE codigo="+id+" and compania="+(String) session.getAttribute("_companyId")+" ORDER BY descripcion";
	System.out.println(""+sql);
		tip = (TipoTransac) sbb.getSingleRowBean(ConMgr.getConnection(),sql, TipoTransac.class);

		if (change == null)
		{
			sql = "SELECT transaccion, sub_tipo as subTipo, nvl(descripcion,' ') as descripcion, decode(monto,null,'0.00',monto) as monto, nvl(to_char(fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(usuario_modificacion,' ') as usuarioModificacion FROM tbl_pla_sub_tipo_transaccion WHERE transaccion="+id+" ORDER BY sub_tipo, descripcion";
            al = sbb.getBeanList(ConMgr.getConnection(), sql, SubTipoTransac.class);

            iTrans.clear();
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  iTrans.put(key, al.get(i-1));
		    }
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipos de Transacciones - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipos de Transacciones - Edición - "+document.title;
<%}%>

function saveMethod()
{
	 window.frames['itemFrame'].formSub.baction.value = "Guardar";
	 window.frames['itemFrame'].doSubmit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - MANTENIMIENTO"></jsp:param>
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
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Tipos de Transacciones</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							    <td width="30%"><%=fb.intBox("codigo",id,false,false,true,30,2)%></td>
								<td width="15%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							    <td width="45%"><%=fb.textBox("descripcion",tip.getDescripcion(),false,false,false,50,30)%></td>
							</tr>
							<tr class="TextRow01">
								<td width="10%"><cellbytelabel>Factor Multi</cellbytelabel></td>
							    <td width="30%"><%=fb.textBox("factorMulti",tip.getFactorMulti(),false,false,false,30,30)%>
								<td width="15%">Clase Transacción</td>
							    <td width="45%"><%=fb.select(ConMgr.getConnection(),"select a.clase,  a.descripcion||' - '||a.clase, a.clase from tbl_pla_clase_trx a where compania="+(String) session.getAttribute("_companyId"),"clase_trx",tip.getClaseTrx(),true,false,false,0,"Text10",null,null,"","S")%></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;</td>
								<td width="5%" align="right"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../rhplanilla/subtipo_transacciones_detail.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>&id=<%=id%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto </cellbytelabel>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/tipotransacciones_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/tipotransacciones_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/tipotransacciones_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>