<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.EvolucionParametros"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EPMgr" scope="page" class="issi.expediente.EvolucionParametrosMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EPMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String groupId = request.getParameter("groupId");
String desc = request.getParameter("desc");
String key ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String cds = request.getParameter("cds");

if (groupId == null) groupId = "0";
if (modeSec == null||modeSec.trim().equals(""))modeSec = "add";
if (mode == null||mode.trim().equals(""))mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	sql="select distinct  a.grupo_id, to_char(a.fecha,'dd/mm/yyyy hh12:mi am') fecha from tbl_sal_evolucion_respiratorio a  where a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and  a.ref_type ='HEM' order by a.grupo_id desc";

	al2 = SQLMgr.getDataList(sql);

	sql = "select a.grupo_id, a.pac_id,a.admision, to_char(a.fecha,'dd/mm/yyyy')fecha ,to_char(a.fecha,'hh12:mi am')hora, a.valor,b.id,  b.descripcion,decode(a.parametro_id,null,'I','U') as action,a.parametro_id as id_param,a.estado from tbl_sal_evolucion_respiratorio a, tbl_sal_evolucion_parametro b where b.id = a.parametro_id(+) and b.tipo = 'HD' and a.pac_id(+) = "+pacId+" and a.admision(+) = "+noAdmision+(!groupId.trim().equals("")?" and a.grupo_id(+) = "+groupId:" ")+" and  a.ref_type(+) ='HEM' order by b.orden";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - Evolucion  Hemodinamica - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();checkViewMode();}
function setEvaluacion(id){window.location = '../expediente/exp_parametros_hemodinamicos.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId='+id;}
function add(){window.location = '../expediente/exp_parametros_hemodinamicos.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId=0';}
function verEvol(){abrir_ventana1('../expediente/exp_parametros_hemo_resp_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=HD');}
function imprimir(){abrir_ventana1('../expediente/print_exp_seccion_61.jsp?refType=HEM&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&groupId=<%=groupId%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextRow01">
					<td  colspan="3">
					<div id="proc" width="100%" class="exp h100">
					<div id="proced" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
				 <%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
                 <%=fb.hidden("desc",desc)%>
				 <tr class="TextRow02">
					<td colspan="3" align="right">&nbsp;</td>
				 </tr>
						<tr class="TextRow02">
							<td width="30%">&nbsp;<cellbytelabel id="1">Listado de Evaluaciones</cellbytelabel></td>
							<td width="70%" align="right">
							<%if(!mode.trim().equals("view")){%>
							<a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%>&nbsp;<a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="3">Imprimir</cellbytelabel> ]</a></td>
						</tr>

						<tr class="TextHeader">
							<td width="15%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
							<td width="70%"><cellbytelabel id="5">Fecha / Hora</cellbytelabel></td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEvaluacion(<%=cdo1.getColValue("grupo_id")%>)" style="text-decoration:none; cursor:pointer">
				<td><%=i%></td>
				<td><%=cdo1.getColValue("fecha")%></td>
		</tr>
<%
}%>

			<%=fb.formEnd(true)%>
			</table>
		</div>
		</div>
					</td>
				</tr>


<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("groupId",""+groupId)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cds",cds)%>
		<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
		</tr>

<%

for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

		if(i==0)
		{
		%>

		<tr class="TextRow01">
			<td width="60%"><cellbytelabel id="6">Fecha</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;

						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha") == null || cdo.getColValue("fecha").trim().equals("")?cDateTime.substring(0,10):cdo.getColValue("fecha"))%>" />
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						</jsp:include>  </td>
			<td width="40%"><cellbytelabel id="7">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi am"/>
						<jsp:param name="nameOfTBox1" value="hora" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("hora") == null || cdo.getColValue("hora").trim().equals("")?cDateTime.substring(11):cdo.getColValue("hora"))%>" />
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						</jsp:include>


			</td>
		</tr>
		<tr class="TextHeader">
			<td width="60%"><cellbytelabel id="8">Descripci&oacute;n</cellbytelabel></td>
			<td width="40%" align="center"><cellbytelabel id="9">Valor</cellbytelabel></td>
		</tr>
		<%
		}

		%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("id_param"+i,cdo.getColValue("id_param"))%>		
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=fb.textBox("valor"+i,cdo.getColValue("valor"),false,false,viewMode,10,10,"Text10","","")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
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
	int size= Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		if (request.getParameter("valor"+i) != null && !request.getParameter("valor"+i).trim().equals(""))
		{
			EvolucionParametros eph = new EvolucionParametros();

			eph.setGrupoId(request.getParameter("groupId"));
			eph.setParametroId(request.getParameter("id"+i));
			eph.setPacId(request.getParameter("pacId"));
			eph.setAdmision(request.getParameter("noAdmision"));
			eph.setValor(request.getParameter("valor"+i));
			eph.setFecha(request.getParameter("fecha"));
			eph.setHora(request.getParameter("hora"));
			eph.setAction(request.getParameter("action"+i));
			
			eph.setRefType("HEM");
			//if(paramRespDet.trim().equals("S"))eph.setGenerarCargo("S");else
			eph.setGenerarCargo("N");
			eph.setCds(cds);
			eph.setCompania((String)session.getAttribute("_companyId"));
			eph.setUsuarioModifica((String) session.getAttribute("_userName"));

			if(request.getParameter("id_param"+i)==null||request.getParameter("id_param"+i).trim().equals(""))
			{
				eph.setEstado("T");
				eph.setUsuarioCreacion((String) session.getAttribute("_userName"));
			}else{ eph.setEstado(request.getParameter("estado"+i));}
			eph.setCodeDet("null");
			
			al.add(eph);
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (!modeSec.equalsIgnoreCase("edit"))
    {
		EPMgr.addParam(al,modeSec);
		groupId = EPMgr.getPkColValue("grupoId");
	}else EPMgr.addParam(al,modeSec);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (EPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=EPMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(EPMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&groupId=<%=groupId%>&desc=<%=desc%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
