
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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania"); 
String fecha=request.getParameter("fecha");
String fp=request.getParameter("fp");

int cantidad = 0;
int i=1;

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");	

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Aumentos por Convención Colectiva- '+document.title;
function addArticulo()
{
}

function showReporte(value)
{

var msg = '';
var fecha = eval('document.form0.fecha').value ;
var fp = eval('document.form0.fp').value ;

if(msg == '')

{
	if(fp!="sob")
	{
	if(value=="1")
	abrir_ventana2('../rhplanilla/print_res_aumento.jsp?fecha='+fecha);
	else if(value=="2")
	abrir_ventana2('../rhplanilla/print_det_aumento.jsp?fecha='+fecha);
	else if(value=="3")
	abrir_ventana2('../rhplanilla/print_det_antiguedad.jsp?fecha='+fecha);
	} else
	{
	if(value=="1")
	abrir_ventana2('../rhplanilla/print_res_aumento.jsp?fp=sob&fecha='+fecha);
	else if(value=="2")
	abrir_ventana2('../rhplanilla/print_det_aumento.jsp?fp=sob&fecha='+fecha);
	else if(value=="3")
	abrir_ventana2('../rhplanilla/print_det_mensual.jsp?fp=sob&fecha='+fecha);
	}
	//else if(value=="6")
	//abrir_ventana2('../inventario/print_diferencia_sistema.jsp?fp=CFC&compania='+company+'&almacen='+almacen+'&anaquelx='+anaquelx+'&anaquely='+anaquely+'&anio=2009&consigna=N');
	
}
else alert('Seleccione '+msg);

//	abrir_ventana2('../caja/print_recibos_sin_adm.jsp?fp=reporte&caja='+caja+'&descCaja='+descCaja);

}
function addArticulo(index)

{
var famCode = eval('document.form0.familyCode').value ;
var claCode = eval('document.form0.classCode').value ;
var almacen = eval('document.form0.almacen').value ;
var msg='';
	if(almacen ==' ') msg=' Almacen';
	if(famCode =='')  msg+=' , Familia';
	if(claCode =='')  msg+=' ,Clase';
	if(msg=='')
	abrir_ventana('../common/search_articulo.jsp?id=2&fp=RA&familia='+famCode+'&clase='+claCode+'&almacen='+almacen);
	else alert('Seleccione '+msg);
   
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE AUMENTOS POR CC"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
<tr>  
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
			<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("fp",fp)%> 
			<%=fb.hidden("baction","")%>
			
<tr class="TextFilter">
			<td colspan="2">Fecha del Aumento :  
						<%=fb.textBox("fecha",fecha,false,true,false,10)%></td>
	</tr>
	
		</table>
</td></tr>
		
		<tr><td>&nbsp;</td></tr>

<tr>
 <td>		
   <table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				
				<tr class="TextHeader">
							<td colspan="2" align="center">Reportes</td>
				</tr>
				
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe Resumido</td>
				</tr>
				
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe Detallado</td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Informe por Antiguedad / Mensual</td>
				</tr>


			<tr class="TextPager">
				<td>&nbsp;</td>
			</tr>
			
			<tr class="TextPager">
				<td align="center">
				<%=fb.button("btnClose","...Salir...",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
        </td>
			</tr>
			
			<tr class="TextPager">
				<td>&nbsp;</td>
			</tr>
				
	<%fb.appendJsValidation("if(error>0)doAction();");%>		

<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
