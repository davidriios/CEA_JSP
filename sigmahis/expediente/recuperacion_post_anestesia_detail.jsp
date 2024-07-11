<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DetalleRecuperacionAnestesia"%>
<%@ page import="issi.expediente.RecuperacionAnestesia"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TescMgr" scope="page" class="issi.expediente.RecuperacionAnestesiaMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TescMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
int lastLineNo = 0;

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Recuperacion Anestesia - '+document.title;

function doSubmit()
{
	document.formDetalle.baction.value = parent.document.form1.baction.value;
	if (formDetalleValidation())
	{
		document.formDetalle.codigo.value = parent.document.form1.id.value;
		document.formDetalle.descripcion.value = parent.document.form1.descripcion.value;
		document.formDetalle.orden.value = parent.document.form1.orden.value;
		document.formDetalle.submit();
	}
	else
	{
		parent.form1BlockButtons(false)
	}
}

function verifyRemove(formName,k)
{
	var id = parent.document.form1.id.value;
	var code = eval('document.formDetalle.codigo'+k).value;
	if(hasDBData('<%=request.getContextPath()%>','tbl_sal_recuperacion','detalle_recup='+code+' and recup_anestesia='+id,''))alert('No se puede eliminar el detalle del índice ya que está siendo utilizado por algun Expediente!');
	else
	{
		removeItem(formName,k);
		formDetalleBlockButtons(true);
		document.formDetalle.submit();
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("keySize",""+HashDet.size())%>
<%=fb.hidden("codigo", "")%>
<%=fb.hidden("descripcion", "")%>
<%=fb.hidden("orden", "")%>
<tr class="TextHeader" align="center">
	<td width="15%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
	<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
	<td width="25%"><cellbytelabel id="3">Escala</cellbytelabel></td>
	<td width="10%"><%=fb.submit("addCol","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(HashDet);
for (int i = 1; i <= HashDet.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleRecuperacionAnestesia co = (DetalleRecuperacionAnestesia) HashDet.get(key);
	String displayDetalle = "";
	if (co.getStatus() != null && co.getStatus().equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
<%=fb.hidden("key"+i,co.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,co.getStatus())%>
<%=fb.hidden("codigo"+i,co.getCodigo())%>
<tr class="TextRow01" align="center"<%=displayDetalle%>>
	<td><%=co.getCodigo()%></td>
	<td><%=fb.textBox("descripcion"+i, co.getDescripcion(),true,viewMode,false,50)%></td>
	<td><%=fb.intBox("escala"+i, co.getEscala(),true,viewMode,false,20,1)%></td>
	<td><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:verifyRemove('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
else
{
	int keySize=Integer.parseInt(request.getParameter("keySize"));
	ArrayList list = new ArrayList();
	String itemRemoved = "";
	String id = "";

	for (int i=1; i<=keySize; i++)
	{
		DetalleRecuperacionAnestesia te = new DetalleRecuperacionAnestesia();

		// te.setTipoEscala(request.getParameter("secuencia"+i));
		te.setCodigo(request.getParameter("codigo"+i));
		te.setDescripcion(request.getParameter("descripcion"+i));
		te.setEscala(request.getParameter("escala"+i));
		te.setKey(request.getParameter("key"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = te.getKey();
			te.setStatus("D");//D=Delete action in RecuperacionAnestesiaMgr
		}
		else te.setStatus(request.getParameter("status"+i));

		try
		{
			HashDet.put(te.getKey(),te);
			list.add(te);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect("../expediente/recuperacion_post_anestesia_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	}

	if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("+"))
	{
		DetalleRecuperacionAnestesia te = new DetalleRecuperacionAnestesia();

		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;

		te.setKey(key);
		te.setCodigo("0");

		try
		{
			HashDet.put(key, te);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect("../expediente/recuperacion_post_anestesia_detail.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	}

	RecuperacionAnestesia dte = new RecuperacionAnestesia();
	dte.setCodigo(request.getParameter("codigo"));
	dte.setDescripcion(request.getParameter("descripcion"));
	dte.setOrden(request.getParameter("orden"));
	dte.setMatrizRecuperacionAnestesia(list); // guarda la matriz ya cargada

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		TescMgr.add(dte);
		id = TescMgr.getPkColValue("codigo");
	}
	else if (mode.equalsIgnoreCase("edit"))
	{
		TescMgr.update(dte);
		id = dte.getCodigo();
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	parent.document.form1.errCode.value = '<%=TescMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=TescMgr.getErrMsg()%>';
	parent.document.form1.id.value = '<%=id%>';
	parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>