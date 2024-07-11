
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
	INV950121.FMB      -------              --                  PROCESO PARA GRABAR EXISTENCIAS MENSUALES AL CIERRE MENSUAL DE INVENTARIO
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
function puBackup(obj)
{
	var msg='';
	var user = '<%=userName%>'
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;
	var almacen=document.form0.almacen.value;
	if(almacen =='')msg=' Almacen';
	if(anio =='')msg=' , anio';
	if(mes =='')msg=' ,Mes';
	if(msg=='')
	{
	 if(hasDBData('<%=request.getContextPath()%>','tbl_inv_inventario_hist',' compania='+<%=compania%>+' and codigo_almacen='+almacen+' and mes='+mes+' and anio='+anio,''))
     {
		 		alert('Ya existe Registrado un Cierre de Existencias para este Mes, Proceso Cancelado');
		 }
		 else 
		 {
				 if(executeDB('<%=request.getContextPath()%>','call sp_inv_cierre_mens_existencia(<%=compania%>,'+almacen+','+mes+','+anio+',\''+user+'\')','tbl_inv_inventario,tbl_inv_inventario_hist'))
				 {
					alert('Backup Terminado Satisfactoriamente..');
					abrir_ventana('../inventario/param_reporte_articulos.jsp?fg=CM&almacen='+almacen);
         }
         else alert('Error al Insertar.. Proceso Cancelado');
		  }
	}else alert('Seleccione '+msg);	 
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
				<td colspan="2">Proceso Para Grabar Existensias Mensuales al Cierre Mensual de Inventario </td>
			</tr>
			<tr class="TextRow01">
				<td width="40%">Fecha de Cierre</td>
				<td width="60%"><%=fb.textBox("fecha",cDateTime,false,false,true,12)%> </td>
			</tr>
			<tr class="TextRow01">
				<td>Introduzca Mes y Año a Copiar</td>
				<td><%=fb.textBox("mes",cDateTime.substring(3,5),false,false,false,12)%> 
						<%=fb.textBox("anio",cDateTime.substring(6,10),false,false,false,12,null,null,"onBlur=\"javascript:puBackup(this)\"")%> 
				</td>
			</tr>
			
			<tr class="TextRow01">
				<td>Almacen</td>
				<td><%=fb.select("almacen","","",false,false,0,"Text10",null,"")%>
					
      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:""%>','KEY_COL','S');
				</script><%=fb.button("Ejecutar","Ejecutar",true,false,null,null,"onClick=\"javascript:puBackup(this)\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td>Nota: Solo se podrà hacer una copia por mes , asi que este 
            proceso debe correrlo a fin de mes,  al momento en que  
            ya le va a entregar a Contabilidad su reporte de cierre de  
           existencia con el objetivo de que el reporte concuerde con esta data.</td>
				<td> <%=fb.button("report1","Reporte de Existencias (al Dia,Historico)",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
				<br> <%//=fb.button("report2","Reporte de Existencias Historico",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>	</td>
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
