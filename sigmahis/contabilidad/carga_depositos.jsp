
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
	SB1007.FMB      -------              --                  PROCESO PARA CARGAR DEPOSITOS (SALDO BANCARIO)
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
document.title = 'Saldo Bancario - Carga de Depósitos _ '+document.title;
function doAction()
{
}
function getBanco()
{	
abrir_ventana1('../common/search_cuentabanco.jsp?fp=cierre');
}
function showProceso()
{
	var banco=document.form0.banco.value;
	var cuenta=document.form0.cuenta.value;
	var fecha=document.form0.fecha.value;
	var nombre=document.form0.nombre.value;
	var user = '<%=userName%>';
	var cont = 0;
	var dep = 0;
	var msg = '';
	
	if(banco == ''|| fecha =='')  msg = ' Banco / Fecha ';
	if (msg == '')
	{
	
	 if(hasDBData('<%=request.getContextPath()%>','tbl_con_saldo_bancario_f',' compania='+<%=compania%>+' and banco='+banco+' and tipo_documento=1 and cuenta_banco='+cuenta+' and to_date(to_char(f_movimiento,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\')',''))
     {
		 if(executeDB('<%=request.getContextPath()%>','delete from tbl_con_saldo_bancario_f where compania=<%=compania%> and to_date(to_char(f_movimiento,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\') and tipo_documento=1 and banco='+banco+' and cuenta=\''+cuenta+'\'','tbl_con_saldo_bancario_f'))
     	{
		
		cont++;
	 	}	
	}
	
	if(executeDB('<%=request.getContextPath()%>','call sp_con_saldo_bancario(<%=compania%>,\''+fecha+'\','+banco+',\''+cuenta+'\',\''+user+'\')','tbl_con_movim_bancario,tbl_con_saldo_bancario_f'))
	{
	document.form0.banco.value = '';
	document.form0.cuenta.value= '';
	document.form0.nombre.value= '';
	document.form0.fecha.value= '';
		alert('*** P R O C E S O  F I N A L I Z A D O ***!    ');
	} else alert('*** PROCESO NO ENCONTRO REGISTROS ***!    '+dep+' Depósitos Registrados..');
	} else alert('Seleccione '+msg);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGA DE DEPOSITOS - SALDO BANCARIO"></jsp:param>
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
				<td colspan="2">Proceso: Movimiento de Saldos Bancarios </td>
			</tr>
			<tr class="TextRow01">
				<td width="20%">Banco</td>
				<td width="80%"><%=fb.intBox("banco","",false,false,false,5,5)%>
				<%=fb.textBox("nombre","",false,false,false,65)%>
			    <%=fb.button("cta","..Ir..",true,false,null,null,"onClick=\"javascript:getBanco()\"","Seleccionar Cuenta Bancaria")%>
                </td>
			</tr>
				
			<tr class="TextRow01">
				<td>Cuenta de Banco</td>
				<td><%=fb.textBox("cuenta","",false,false,false,40,"Text10",null,"")%> </td>
			</tr>
            
            <tr class="TextRow01">
				<td width="20%">Fecha de Cierre</td>
				<td width="80%"><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value=" " />
				</jsp:include> </td>
			</tr>
            
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2" align="center"> <%=fb.button("report1","Procesar",true,false,null,null,"onClick=\"javascript:showProceso()\"")%></td>
			</tr>
			
	
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
		
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
