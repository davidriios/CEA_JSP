
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
<jsp:useBean id="iPension" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="vPension" scope="session" class="java.util.Vector" />

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
String sql="";
String tipoId=request.getParameter("tipoId");
String key="";
String id=request.getParameter("id");
String otro=request.getParameter("otro");
ArrayList al =new ArrayList();
String change = request.getParameter("change");
int sopLastLineNo = 0;

if (request.getParameter("sopLastLineNo") != null && !request.getParameter("sopLastLineNo").equals(""))
sopLastLineNo = Integer.parseInt(request.getParameter("sopLastLineNo"));
else sopLastLineNo = 0;

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "select codigo, descripcion   from tbl_cdc_tipo_cita where codigo="+tipoId;
cdo = SQLMgr.getData(sql);
System.out.println("iPension size="+iPension.size());

if (change == null)
{ iPension.clear();
	vPension.clear();

sql = "select up.cod_tipo, up.desde_horas, up.desde_minutos, up.hasta_horas, up.hasta_minutos, up.cod_uso,up.compania, up.frecuencia_cantidad, up.frecuencia_medida,u.descripcion from  tbl_cdc_tipo_cita_uso_pension up,tbl_sal_uso u where up.cod_tipo="+tipoId+" and up.compania ="+(String) session.getAttribute("_companyId")+" and up.cod_uso = u.codigo and up.compania = u.compania(+)";
al = SQLMgr.getDataList(sql);
System.out.println("al size="+al.size());
			sopLastLineNo = al.size();
			for(int x=0;x<al.size();x++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(x);

				if (x < 10) key = "00" + x;
				else if (x < 100) key = "0" + x;
				else key = "" + x;
				cdo2.addColValue("key",key);
				try
				{
					iPension.put(key,cdo2);
					vPension.add(cdo2.getColValue("cod_uso"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
}%>
<html>
<head>
<script type="text/javascript">
function verocultar(c)
{
 if(c.style.display == 'none')
 {
 c.style.display = 'inline';
 }
 else
 {
  c.style.display = 'none';
 }
 return false;
}
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">
function bcolor(bcol,d_name)
{
	if (document.all)
	{
	var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol;
	}
}
</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%//if (mode.equalsIgnoreCase("add")){%>
document.title="Uso de Anestesia - Agregar - "+document.title;
<%//}else if (mode.equalsIgnoreCase("edit")){%>
//document.title="Uso de Anestesia - Edición - "+document.title;
<%//}%>
</script>
<script language="javascript">
function adduso(codeField, descField)
{
abrir_ventana1('../inventario/list_uso_anestesia.jsp?codeField='+codeField+'&descField='+descField);
}

function tarifa(codeField, descField)
{
abrir_ventana1('../inventario/list_tarifa.jsp?codeField='+codeField+'&descField='+descField);
}
function doAction()
{
<%if(request.getParameter("type") != null && request.getParameter("type").trim().equals("1")){%>
abrir_ventana1('../common/check_uso.jsp?fp=SOP&sopLastLineNo=<%=sopLastLineNo%>&tipoId=<%=tipoId%>');
<%}%>
}



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Registro de Uso de pensión Por Tipo de Cirugia"></jsp:param>
</jsp:include>
<table width="99%" cellpadding="0" cellspacing="0" border="0">
<tr>
	<td>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<table align="center" width="99%" cellpadding="0" cellspacing="1">
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("sopLastLineNo",""+sopLastLineNo)%>
<%=fb.hidden("tipoId",tipoId)%>
<%=fb.hidden("keySize",""+iPension.size())%>
<%=fb.hidden("baction","")%>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr class="TextHeader">
		<td width="15%">&nbsp;Tipo de Cirug&iacute;a</td>
		<td width="75%">&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
		<td width="10%" align="right"><%//=fb.submit("brnagrega","Agregar",false,false)%>
		<%=fb.submit("agregar","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Uso")%>
		</td>
	</tr>
	<tr>
		<td colspan="3">
			<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="8%" align="center" colspan="2">Desde</td>
					<td width="8%" align="center" colspan="2">Hasta</td>
					<td width="40%" align="center" rowspan="2"> Tipo de Uso A Cargar</td>
					<td width="10%" align="center" rowspan="2">Frecuencia</td>
					<td width="10%" align="center" rowspan="2">Medida de la Frecuencia</td>
					<td width="5%" rowspan="2">&nbsp;</td>
				</tr>

			<tr class="TextHeader">
					<td align="center">Hora</td>
					<td align="center">Min</td>
					<td align="center"> Hora</td>
					<td align="center">Min</td>
			</tr>		<!---	--->
			<%if(iPension.size() >0)al=CmnMgr.reverseRecords(iPension);
					for(int a=0;a<al.size();a++)
				{
					key = al.get(a).toString();
					CommonDataObject cdos= (CommonDataObject) iPension.get(key);
				%>
				<%=fb.hidden("key"+a,key)%>
				<%=fb.hidden("remove"+a,"")%>
				<tr class="TextRow01">

				<td align="center">
				<%=fb.intBox("desde_horas"+a,cdos.getColValue("desde_horas"),true,false,false,1,2,"Text10",null,null)%></td>
				<td align="center">
				<%=fb.intBox("desde_minutos"+a,cdos.getColValue("desde_minutos"),true,false,false,1,2,"Text10",null,null)%></td>
				<td align="center">
				<%=fb.intBox("hasta_horas"+a,cdos.getColValue("hasta_horas"),true,false,false,1,2,"Text10",null,null)%></td>
				<td align="center">
				<%=fb.intBox("hasta_minutos"+a,cdos.getColValue("hasta_minutos"),true,false,false,1,2,"Text10",null,null)%></td>
				<td align="left">
				<%=fb.textBox("cod_uso"+a,cdos.getColValue("cod_uso"),true,false,true,5,"Text10",null,null)%>
				<%=fb.textBox("descripcion"+a,cdos.getColValue("descripcion"),false,false,true,60,"Text10",null,null)%></td>
				<td align="center">
				<%=fb.intBox("frecuencia_cantidad"+a,cdos.getColValue("frecuencia_cantidad"),false,false,false,2,2,"Text10",null,null)%></td>
				<td align="center">
				<%=fb.select("frecuencia_medida"+a,"MIN=MINUTOS, HRA=HORA",cdos.getColValue("frecuencia_medida"),false,false,0,"Text10",null,null)%></td>

				<td align="center">&nbsp;<%//=fb.submit("remover"+a,"X",false,false)%>
					<%=fb.submit("rem"+a,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+a+")\"","Eliminar")%>
				</td>
			</tr>
			<%}%>
			</table>
		</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="3" align="right"> <%//=fb.submit("save","Guardar",true,false)%>
		<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
	</tr>
		 <%=fb.formEnd(true)%>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	  </table>
<!--STYLE DOWN-->
<!--*************************************************************************************************************-->
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
 ArrayList list = new ArrayList();

tipoId = request.getParameter("tipoId");
String baction = request.getParameter("baction");

sopLastLineNo = Integer.parseInt(request.getParameter("sopLastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="",itemRemovedVector="";
for(int a=0;a<keySize;a++)
{
cdo=new CommonDataObject();
cdo.setTableName("tbl_cdc_tipo_cita_uso_pension");
cdo.addColValue("cod_tipo",tipoId);
cdo.addColValue("desde_horas",request.getParameter("desde_horas"+a));
cdo.addColValue("desde_minutos",request.getParameter("desde_minutos"+a));
cdo.addColValue("hasta_horas",request.getParameter("hasta_horas"+a));
cdo.addColValue("hasta_minutos",request.getParameter("hasta_minutos"+a));
cdo.addColValue("cod_uso",request.getParameter("cod_uso"+a));
cdo.addColValue("descripcion",request.getParameter("descripcion"+a));
cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
cdo.addColValue("frecuencia_medida",request.getParameter("frecuencia_medida"+a));
cdo.addColValue("frecuencia_cantidad",request.getParameter("frecuencia_cantidad"+a));
cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_tipo="+tipoId);
key= request.getParameter("key"+a);

	if (request.getParameter("remove"+a) != null && !request.getParameter("remove"+a).equals(""))
	{		itemRemoved = key;
			itemRemovedVector = cdo.getColValue("cod_uso");
	}
	else
	{
			try
			{
				list.add(cdo);
				iPension.put(key,cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//End else
	}//for


if (!itemRemoved.equals(""))//Elimina de la lista
{
vPension.remove(itemRemovedVector);
iPension.remove(itemRemoved);
response.sendRedirect("../inventario/pension_x_tipo_cita.jsp?change=1&sopLastLineNo="+sopLastLineNo+"&tipoId="+tipoId);
return;
}

if (baction.equals("+"))//Agrega la Lista
{

				/*cdo=new CommonDataObject();
				cdo.addColValue("descripcion","");
				cdo.addColValue("cod_uso","");
				sopLastLineNo++;
				if (sopLastLineNo < 10) key = "00" + sopLastLineNo;
				else if (sopLastLineNo < 100) key = "0" + sopLastLineNo;
				else key = "" + sopLastLineNo;

				try
				{
					iPension.put(key,cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}*/
				response.sendRedirect("../inventario/pension_x_tipo_cita.jsp?change=1&type=1&sopLastLineNo="+sopLastLineNo+"&tipoId="+tipoId);
				return;
}
if (baction.equalsIgnoreCase("Guardar"))
{
		if (list.size() == 0)
		{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_cdc_tipo_cita_uso_pension");
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_tipo="+tipoId);
			list.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(list);
		ConMgr.clearAppCtx(null);
}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/tipos_citas_list.jsp?fg=SOP"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/tipos_citas_list.jsp?fg=SOP")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/tipos_citas_list.jsp?fg=SOP';
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
