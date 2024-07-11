
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
	FORMA              REPORTE              FLAG                DESCRIPCION
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

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");	
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();

CommonDataObject cdo = new CommonDataObject();
StringBuffer sql = new StringBuffer();
sql.append("select (select max(anio) anio from tbl_inv_cierre_mes where compania = ");
sql.append((String) session.getAttribute("_companyId"));
sql.append(") anio, (select max(mes) from tbl_inv_cierre_mes where compania = ");
sql.append((String) session.getAttribute("_companyId"));
sql.append(" and anio = (select max(anio) anio from tbl_inv_cierre_mes where compania = ");
sql.append((String) session.getAttribute("_companyId"));
sql.append(")) mes from dual");
cdo = SQLMgr.getData(sql);
if(cdo==null) cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Inventario - Cierre de Existencia _ '+document.title;
function doAction()
{
}
function showReporte()
{
	var almacen=document.form0.almacen.value;
	abrir_ventana('../inventario/param_reporte_articulos.jsp?fg=CM&almacen='+almacen);
}
function puBackup()
{
	var msg='';
	var user = '<%=userName%>'
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;
	var almacen=document.form0.almacen.value;
	if(anio =='')msg='Anio';
	if(mes =='')msg=', Mes';
	if(msg=='')
	{
	 if(hasDBData('<%=request.getContextPath()%>','tbl_inv_cierre_mes',' compania=<%=compania%> '+(almacen==''?'':'and almacen='+almacen)+' and mes='+mes+' and anio='+anio,''))
     {
		 		alert('Ya existe Registrado un Cierre de Existencias para este Mes, Proceso Cancelado');
		 }
		 else 
		 {
				 showPopWin('../process/inv_cierre_mes.jsp?anio='+anio+'&mes='+mes+'&almacen='+almacen,winWidth*.65,_contentHeight*.75,null,null,'');
		  }
	}else alert('Seleccione '+msg);	 
}

function reporte(){
	var msg='';
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;
	var almacen=document.form0.almacen.value||'ALL';
	var mesDesc = getSelectedOptionLabel(document.form0.mes,'');
	var almacenDesc = getSelectedOptionLabel(document.form0.almacen,'');
	if(anio =='')msg='Anio';
	if(mes =='')msg=', Mes';
	if(msg==''){
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_cierre_mes.rptdesign&anioParam='+anio+'&mesParam='+mes+'&almacenParam='+almacen+'&mesNameParam='+mesDesc);
	} else alert('Seleccione '+msg);	 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CIERRE DE EXISTENCIA POR MES"></jsp:param>
	</jsp:include>

	

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			
			<tr class="TextHeader">
				<td colspan="2">Proceso Para Existencia y Costo promedio Mensual. </td>
			</tr>
			<%if(cdo.getColValue("anio")!=null && !cdo.getColValue("anio").equals("")){%>
			<tr class="TextHeader">
				<td colspan="2" align="center">Ultimo cierre <%=fb.select("mes_des","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("mes"),false,false,false,0,"Text12","","")%> <%=cdo.getColValue("anio")%></td>
			</tr>
			<%}%>
			<tr class="TextRow01">
				<td>Introduzca Mes y Año a Cerrar</td>
				<td><%=fb.select("mes","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",cdo.getColValue("mes"),false,false,false,0,"Text12","","")%>
						<%=fb.textBox("anio",cdo.getColValue("anio"),false,false,false,12,null,null,"")%> 
				</td>
			</tr>
			
			<tr class="TextRow01">
				<td>Almacen</td>
				<td><%=fb.select(ConMgr.getConnection(),"SELECT codigo_almacen, codigo_almacen ||'-'||descripcion descripcion FROM TBL_INV_ALMACEN a WHERE compania = "+session.getAttribute("_companyId") +" ORDER BY descripcion","almacen","",false,false,0,"text10",null,"","","S")%> 
				<%=fb.button("Ejecutar","Ejecutar",true,false,null,null,"onClick=\"javascript:puBackup()\"")%><%=fb.button("report","Reporte",true,false,null,null,"onClick=\"javascript:reporte()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
	
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
		
</td></tr>
		

</table>
</body>
</html>
<%
}//GET
%>
