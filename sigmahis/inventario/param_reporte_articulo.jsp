
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
		llamado a reporte inv0075.rdf
		
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


String wh = "";
String compania =  (String) session.getAttribute("_companyId");	
String familyCode = "";
String classCode = "";
String venta = "";
String tipo = "";
String estado = "";


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}
function getMain(formX)
{
	formX.wh.value = document.form0.wh.value;
	formX.estado.value = document.form0.estado.value;
	formX.tipo.value = document.form0.tipo.value;
	formX.venta.value = document.form0.venta.value;
	formX.familyCode.value = document.form0.familyCode.value;
	formX.classCode.value = document.form0.classCode.value;
	formX.estado.value = document.form0.estado.value;
	formX.compania.value = document.form0.compania.value;
	return true;
}
function showReporte()
{
	var wh = eval('document.form0.wh').value;
	var compania = eval('document.form0.compania').value;
	var venta = eval('document.form0.venta').value;
	var tipo = eval('document.form0.tipo').value;
	var familyCode = eval('document.form0.familyCode').value;
	var classCode = eval('document.form0.classCode').value;
	var estado = eval('document.form0.estado').value;
	var msg = '';
	var fp ='';
	var subclase = '';
	if(eval('document.form0.subclassCode').value) subclase = eval('document.form0.subclassCode').value;

if(msg == '')
{abrir_ventana('../inventario/print_list_articulo_precio.jsp?compania='+compania+'&almacen='+wh+'&familia='+familyCode+'&clase='+classCode+'&estado='+estado+'&tipo='+tipo+'&venta='+venta+'&subclase='+subclase);
}

else alert('Seleccione '+msg);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE ARTICULOS POR PRECIO, ESTADO Y TIPO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
		<tr class="TextFilter">
		<td width="50%">Compañia<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania /*where codigo = "+(String) session.getAttribute("_companyId")+"*/ ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','wh','"+wh+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>
	
		</td>
		<td width="50%">											
										
			Almacen
			<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen","wh",wh,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/familyCode.xml','familyCode','"+familyCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form0.familyCode.value,'KEY_COL','T')\"")%>
		  </td>
		</tr>		
	<tr class="TextFilter">
		<td>
			Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">loadXML('../xml/familyCode.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(wh != null && !wh.equals(""))?wh:"document.form0.wh.value"%>,'KEY_COL','T');</script>
		  </td>
			<td>
			Clase
			<%=fb.select("classCode","","",false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.form0.familyCode.value+'-'+this.value,'KEY_COL','T')\"")%>
      <script language="javascript">
			loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.form0.familyCode.value"%>,'KEY_COL','T');
			</script>
      Subclase: <%=fb.select("subclassCode","","",false,false,0,"text10",null,"")%>
      <script language="javascript">
			loadXML('../xml/subclase.xml','subclassCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-<%=(familyCode != null && !familyCode.equals(""))?familyCode:"document.form0.familyCode.value"%>-<%=(classCode != null && !classCode.equals(""))?classCode:"document.form0.classCode.value"%>','KEY_COL','T');
    </script>
		 </td>
		</tr>
		
<tr class="TextFilter">
	<td> Artículo de Venta
	<%=fb.select("venta","S=Si, N=No",venta,false,false,0,"Text10",null,null,"","T")%>
	</td>
	<td>
		Tipo de Artículo
		<%=fb.select("tipo","N=NORMAL, A=ACTIVO, B=BANDEJA, K=KIT",tipo,false,false,0,"Text10",null,null,"","T")%>
	 </td>
</tr>
	
<tr id="detail1"  class="TextFilter">
	<td colspan="2" align="center"> Estado del Artículo
	<%=fb.select("estado","A=ACTIVO, I=INACTIVO",estado,false,false,0,"Text10",null,null,"","T")%></td>
</tr>

<tr class="TextFilter">
    <td colspan="2" align="center"><%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>											
	</td>
</tr>
		
	
		</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
