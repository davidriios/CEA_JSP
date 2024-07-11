<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Habitacion"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable" />
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList<Cama> al = new ArrayList();
Habitacion hab = new Habitacion();
String sql = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String fromList = (request.getParameter("fromList")==null?"":request.getParameter("fromList"));
String key = "";
int lastLineNo = 0;

if (mode == null) mode = "add";

boolean viewMode = mode.trim().equalsIgnoreCase("view");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iCama.clear();
		code = "-1";
	}
	else
	{
		if (code == null) throw new Exception("La Habitación no es válida. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("SELECT a.codigo, a.compania, a.unidad_admin as unidadAdmin, b.descripcion as unidadName, a.descripcion, a.estado_habitacion as estadoHab, a.accesorios, a.tipo_servicio as tipoServ, c.descripcion as tipoName,a.quirofano as quirofano, a.centro_servicio other2, a.comments FROM tbl_sal_habitacion a, tbl_cds_centro_servicio b, tbl_cds_tipo_servicio c WHERE a.unidad_admin = b.codigo and lpad(a.tipo_servicio,2,000) = c.codigo and a.codigo='");
		sbSql.append(code);
		sbSql.append("' and a.compania=");
		sbSql.append((String) session.getAttribute("_companyId"));

		hab = (Habitacion) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(), Habitacion.class);

		sbSql = new StringBuffer();
		sbSql.append("select rownum as key, 'U' as action, z.* from (");
		sbSql.append("select a.codigo as codigoOld, a.codigo, a.habitacion, a.compania, a.descripcion, a.estado_cama as estadoCam, a.tipo_hab as tipoHab, (select descripcion from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania) as tipoName, (select categoria_hab from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania) as catHab, a.usuario_creacion as userCrea, to_char(a.fecha_creacion,'dd/mm/yyyy hh24.mi:ss') as fechaCrea, nvl((select precio from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania),0) as precio, a.extension,(select count(*) from tbl_adm_cama_admision where cama = a.codigo and habitacion=a.habitacion and fecha_final is null ) as other1 from tbl_sal_cama a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.habitacion = '");
		sbSql.append(code);
		sbSql.append("' order by a.codigo");
		sbSql.append(") z");

System.out.println(" sql == "+sbSql.toString());
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Cama.class);
		iCama.clear();
		for (int i=1; i<=al.size(); i++)
		{
			iCama.put(al.get(i-1).getKey(), al.get(i-1));
		}
        
        if (hab.getEstadoHab() != null && hab.getEstadoHab().equalsIgnoreCase("U")) viewMode = true;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title=" Habitación - "+document.title;

function getCentroTipo(op){switch(op){case 1:abrir_ventana1('../admision/habitacion_centroservicio_list.jsp?id=1&fp=habitacion');break;case 2:abrir_ventana1('../admision/habitacion_tiposervicio_list.jsp?id=1');break;}}

function saveMethod()
{
	if (form1Validation())
	{
		setBAction('form1','Guardar');
		form1BlockButtons(true);
		window.frames['cama'].doSubmit();
	}
}

function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sal_habitacion','compania=<%=(String) session.getAttribute("_companyId")%> and codigo=\''+obj.value+'\'','<%=hab.getCodigo()%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1" align="center">

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(checkCode(document.form1.codigo))return false;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("errException","")%>
<%=fb.hidden("fromList",fromList)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="4"><cellbytelabel id="1">Generales Habitaci&oacute;n</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="10%"><cellbytelabel id="2">Habitaci&oacute;n</cellbytelabel></td>
			<td width="45%">
				<%=fb.textBox("codigo",hab.getCodigo(),true,false,(mode.equals("edit") && al.size() > 0),10,10,null,null,"onBlur=\"javascript:checkCode(this)\"")%>
				<!--<%//=fb.textBox("codigo",hab.getCodigo(),true,false,mode.equals("edit"),11,null,null,"onBlur=\"javascript:checkCode(this)\"")%>-->
				<%=fb.textBox("descripcion",hab.getDescripcion(),false,false,viewMode,42)%>
			</td>
			<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td width="35%"><%=fb.select("estadoHab","D=DISPONIBLE,U=EN USO,I=INACTIVA,M=MANTENIENTO,R=RESERVADO",hab.getEstadoHab(),false,viewMode,0)%></td>
			</tr>
			<tr class="TextRow01">
			<td><cellbytelabel id="4">Unidad Administrativo</cellbytelabel></td> 
			<td>
				<%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and codigo <> 0 order by descripcion","centroServCode",hab.getUnidadAdmin(),false,false,0,null,null,null,null,"S")%>
				<%=fb.textBox("centroServCode",hab.getUnidadAdmin(),true,false,true,11)%>
				<%=fb.textBox("centroServ",hab.getUnidadName(),true,false,true,42)%>
				<%=fb.button("btncentro","...",false,viewMode,null,null,"onClick=\"javascript:getCentroTipo(1)\"")%>
			</td>
			<td ><cellbytelabel id="5">Quirofano</cellbytelabel></td>
			<td ><%=fb.select("quirofano","1=SELECCIONAR,2=Quirofano",hab.getQuirofano(),false,viewMode,0)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="6">Tipo de Servicio</cellbytelabel></td>
			<td>
				<%=fb.textBox("tipoServCode",(hab.getTipoServ()!=null && !hab.getTipoServ().trim().equals(""))?hab.getTipoServ():"01",true,false,true,11)%>
				<%=fb.textBox("tipoServ",(hab.getTipoName()!=null && !hab.getTipoName().trim().equals(""))?hab.getTipoName():"HABITACION",true,false,true,42)%>
				<%=fb.button("btntipo","...",false,viewMode,null,null,"onClick=\"javascript:getCentroTipo(2)\"")%>
			</td>
			<td><cellbytelabel id="7">Centro de Servicio(CITA)</cellbytelabel></td>
			<td>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cds_centro_servicio where estado = 'A' and codigo <> 0 order by descripcion","centro_servicio",hab.getOther2(),false,viewMode,0,null,null,null,null,"S")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="8">Accesorios</cellbytelabel></td>
			<td><%=fb.textarea("accesorio",hab.getAccesorios(),false,false,false,45,4)%></td>
			<td><cellbytelabel id="9">Comentarios</cellbytelabel></td>
			<td><%=fb.textarea("comments",hab.getComments(),false,false,false,38,4)%></td>
		</tr>
		<tr class="TextPanel">
			<td colspan="4"><cellbytelabel id="10">Camas</cellbytelabel></td>
		</tr>
		<tr>
			<td colspan="4"><iframe name="cama" id="cama" frameborder="0" style="width:100%; height:90px;" src="../admision/cama_config.jsp?mode=<%=mode%>&code=<%=code%>&lastLineNo=<%=lastLineNo%>&fromList=<%=fromList%>" scrolling="no"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="11">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel id="12">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="13">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="14">Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,false,null, null, "onClick=\"javascript:saveMethod()\"")%>
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
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	String errException = request.getParameter("errException");

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (errCode.equals("1")) { %>
	alert('<%=errMsg%>');
	
<% if (fromList.trim().equals("")){ %>	
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/habitacion_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/habitacion_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/admision/habitacion_list.jsp';
<% } %>
<%}else{%>
     window.opener.location.href = window.opener.location.href;
<%}%>

<% if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } %>
<% } else throw new Exception(errException); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=add&code=<%=code%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&fromList=<%=request.getParameter("fromList")%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>