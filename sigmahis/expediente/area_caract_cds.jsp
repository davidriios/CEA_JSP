<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="iDetCds" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDetCds" scope="session" class="java.util.Vector" />
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

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String id = request.getParameter("id");
String caract = request.getParameter("caract");
String change = request.getParameter("change");
int detCdsLastLineNo = 0;

if (request.getParameter("detCdsLastLineNo") != null) detCdsLastLineNo = Integer.parseInt(request.getParameter("detCdsLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (id == null || caract == null) throw new Exception("El Característica no es válida. Por favor intente nuevamente!");

	sql = "select a.codigo as caractCode, a.descripcion as caractDesc, b.codigo as areaCode, b.descripcion as areaDesc from tbl_sal_caract_areas_corp a, tbl_sal_examen_areas_corp b where a.cod_area_corp="+id+" and a.codigo="+caract+" and a.cod_area_corp=b.codigo";
	cdo = SQLMgr.getData(sql);

	if (change == null)
	{
		iDetCds.clear();
		vDetCds.clear();

		sql = "select a.centro_servicio, a.observacion, a.sec_orden, b.descripcion from tbl_sal_caract_area_corp_x_cds a, tbl_cds_centro_servicio b where a.cod_area="+id+" and a.cod_caract="+caract+" and a.centro_servicio=b.codigo order by 1";
		al = SQLMgr.getDataList(sql);

		detCdsLastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			CommonDataObject det = (CommonDataObject) al.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			det.addColValue("key",key);

			iDetCds.put(key,det);
			vDetCds.addElement(det.getColValue("centro_servicio"));
		}
	}//change is null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Característica x Centros de Servicios - "+document.title;

function doAction()
{
<%
if (request.getParameter("type") != null)
{
%>
	 showCdsList();
<%
}
%>
}

function showCdsList()
{
  abrir_ventana2('../common/check_cds.jsp?fp=areaDetalle&id=<%=id%>&caract=<%=caract%>&detCdsLastLineNo=<%=detCdsLastLineNo%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("caract",caract)%>
<%=fb.hidden("detCdsLastLineNo",""+detCdsLastLineNo)%>
<%=fb.hidden("size",""+iDetCds.size())%>

		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="1">&Aacute;rea</cellbytelabel>: [<%=id%>] <%=cdo.getColValue("areaDesc")%></td>
			<td colspan="3"><cellbytelabel id="2">Caracter&iacute;stica</cellbytelabel>: [<%=caract%>] <%=cdo.getColValue("caractDesc")%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="6">Orden</cellbytelabel></td>
			<td width="3%"><%=fb.submit("addCds","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Centro de Servicios")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iDetCds);
for (int i=1; i<=iDetCds.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject det = (CommonDataObject) iDetCds.get(key);
%>
<%=fb.hidden("key"+i,det.getColValue("key"))%>
<%=fb.hidden("centro_servicio"+i,det.getColValue("centro_servicio"))%>
<%=fb.hidden("descripcion"+i,det.getColValue("descripcion"))%>
<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01">
			<td align="center"><%=det.getColValue("centro_servicio")%></td>
			<td><%=det.getColValue("descripcion")%></td>
			<td align="center"><%=fb.textBox("observacion"+i,det.getColValue("observacion"),false,false,false,50)%></td>
			<td align="center"><%=fb.intBox("sec_orden"+i,det.getColValue("sec_orden"),false,false,false,5,5)%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="5">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N")%>Crear Otro -->
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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

	int size = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";

	for (int i=1; i<=size; i++)
	{
		CommonDataObject det = new CommonDataObject();

  	det.setTableName("tbl_sal_caract_area_corp_x_cds");
		det.setWhereClause("cod_area="+id+" and cod_caract="+caract);

		det.addColValue("cod_area",id);
		det.addColValue("cod_caract",caract);
		det.addColValue("centro_servicio",request.getParameter("centro_servicio"+i));
		det.addColValue("descripcion",request.getParameter("descripcion"+i));
		det.addColValue("observacion",request.getParameter("observacion"+i));
		det.addColValue("sec_orden",request.getParameter("sec_orden"+i));
		det.addColValue("key",request.getParameter("key"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			itemRemoved = det.getColValue("key");
		else
		{
			try
			{
				iDetCds.put(det.getColValue("key"),det);
				al.add(det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		vDetCds.remove(((CommonDataObject) iDetCds.get(itemRemoved)).getColValue("centro_servicio"));
		iDetCds.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&caract="+caract+"&detCdsLastLineNo="+detCdsLastLineNo);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&id="+id+"&caract="+caract+"&detCdsLastLineNo="+detCdsLastLineNo);
		return;
	}

	if (al.size() == 0)
	{
		CommonDataObject det = new CommonDataObject();

  	det.setTableName("tbl_sal_caract_area_corp_x_cds");
		det.setWhereClause("cod_area="+id+" and cod_caract="+caract);

		al.add(det);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.insertList(al);
	ConMgr.clearAppCtx(null);
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
	parent.hidePopWin(false);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>&caract=<%=caract%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>