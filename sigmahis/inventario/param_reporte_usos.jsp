
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
	PARAMETROS PARA	REPORTE:		
	FG 				REPORTE          DESCRIPCION 
	RU   			INV00122.RDF     REPORTE DE USOS.
	RCS				FAC10018       	 REPORTE DE CARGOS DE USOS A PACIENTES EN SALON DE OPERACIONES
	RVG       INV00120				 REPORTE DE VALOR DEL PORCENTAJE DE GANANCIA ENTRE EL PRECIO Y EL COSTO
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
String fg = request.getParameter("fg");
String colSpan ="1";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Inventario - '+document.title;
function doAction()
{
}
function showUso()
{
	abrir_ventana1('../inventario/sel_usos.jsp?fg=RCS');
}
function showReporte(option)
{
	
	<%if(fg != null && fg.trim().equals("RU")){%>
			var tipo_precio = eval('document.form0.precio').value;
			abrir_ventana('../inventario/print_list_usos.jsp?tipo_precio='+tipo_precio);
			
	<%} else if(fg != null && fg.trim().equals("VC")){%>var porcentaje =eval('document.form0.rango_i').value;var condicion =eval('document.form0.condicion').value;
	if(porcentaje =='' )alert('Introduzca Porcentaje para el Calculo de Variación');
		else abrir_ventana('../inventario/print_list_varianza.jsp?porcentaje='+porcentaje+'&condicion='+condicion);
			
	<%}else if(fg != null && fg.trim().equals("RCS")){%>
			var fecha_i = eval('document.form0.fechaini').value;
			var fecha_f = eval('document.form0.fechafin').value;
			var uso = eval('document.form0.uso').value;
			var msg ='';
			if(fecha_i =='') msg ='  Fecha Inicial ';
			if(fecha_f =='') msg +=' , Fecha Final ';
			//if(uso =='')     msg +=' , Uso ';
			if(msg =='')
			abrir_ventana('../inventario/print_cargos_salon.jsp?uso='+uso+'&tDate='+fecha_i+'&fDate='+fecha_f);
			else alert('seleccione '+msg);
	<%}else if(fg != null && fg.trim().equals("RVG")){%>
			var almacen = eval('document.form0.wh').value;
			var familia = eval('document.form0.familia').value;
			var titulo = eval('document.form0.titulo').value;
			var rango_ini = eval('document.form0.rango_i').value;
			var rango_fin = eval('document.form0.rango_f').value;
			if((rango_ini != '' && rango_fin=='') || (rango_ini == '' && rango_fin !=''))alert('Complete valores en los Rangos de Porcentaje');
			else{
				if((rango_ini !='' && isNaN(rango_ini)) || (rango_fin !='' && isNaN(rango_fin))){ 
					alert('Valores Incorrectos en Rangos de Fecha');
					eval('document.form0.rango_i').value='';
					eval('document.form0.rango_f').value='';
				}
				else {
					if (!option) abrir_ventana('../inventario/print_valor_porcentaje.jsp?almacen='+almacen+'&familia='+familia+'&titulo='+titulo+'&rango_ini='+rango_ini+'&rango_fin='+rango_fin);
					else {
						var pCtrlHeader = $('#pCtrlHeader').get(0).checked;
						almacen = almacen || 0;
						familia = familia || 0;
						titulo = titulo || ' ';
						rango_ini = rango_ini || -1;
						rango_fin = rango_fin || -1;
						abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_valor_porcentaje.rptdesign&almacen='+almacen+'&familia='+familia+'&titulo='+titulo+'&rango_ini='+rango_ini+'&rango_fin='+rango_fin+'&pCtrlHeader='+pCtrlHeader);
					}
				}
			}
	<%}%>
	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg != null && fg.trim().equals("RU")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE USOS"></jsp:param>
</jsp:include>
<%} else if(fg != null && fg.trim().equals("VC")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE VARIANZA EN COMPRA DE ARTICULOS"></jsp:param>
</jsp:include>
	<%} else if(fg != null && fg.trim().equals("RCS")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE CARGOS DE USOS A PACIENTES EN SALON DE OPERACIONES"></jsp:param>
</jsp:include>
<%} else if(fg != null && fg.trim().equals("RVG")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE VALOR DEL PORCENTAJE DE GANANCIA ENTRE EL PRECIO Y EL COSTO"></jsp:param>
</jsp:include>
	<%}%>
	

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
	<%if(fg != null && fg.trim().equals("RU")){%>
		
<tr class="TextFilter">
	<td align="center">TIPO DE PRECIO	<%=fb.select("precio","L=LOCAL, I=INTERNACIONAL","",false,false,0,"",null,null,"","")%></td>
</tr>
	<%} else if(fg != null && fg.trim().equals("RCS")){%>
			
<tr class="TextFilter">
	<td align="center">RANGO DE FECHA	<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include></td>
</tr>
<tr class="TextFilter">
	<td align="center">Cargos <%=fb.textBox("uso","",false,false,false,5)%>
			 <%=fb.textBox("descUso","",false,false,true,50)%>
			 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showUso()\"")%> </td>
</tr>	
<%} else if(fg != null && fg.trim().equals("RVG")){%>
<tr class="TextFilter">
	<td align="right" width="20%">Almacen</td>
	<td align="left" width="80%">
<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen","wh","",false,false,0,"",null,null,"","T")%>
</td>
</tr>
<tr class="TextFilter">
	<td align="right">Familia</td>
	<td align="left"><%=fb.select(ConMgr.getConnection(),"select cod_flia as optValueColumn, cod_flia||' - '||nombre as optLabelColumn from tbl_inv_familia_articulo where compania = "+(String) session.getAttribute("_companyId")+" and cod_flia  in (1,2,5,6) order by cod_flia","familia","",false,false,0,"",null,null,"","T")%>
</td>
</tr>
<tr class="TextFilter">
	<td align="right">Titulo</td>
	<td align="left"><%=fb.textBox("titulo","",false,false,false,40)%></td>
</tr>	

<tr class="TextFilter">
	<td align="right">Porcentaje   Desde</td>
	<td align="left"><%=fb.decBox("rango_i","",false,false,false,10)%> &nbsp;&nbsp;Hasta <%=fb.textBox("rango_f","",false,false,false,10)%>
	
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">
	<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">
	Esconder Cabecera (Excel)
	</label>
	</td>
</tr>	
<%colSpan ="2";%>
	<%}else if(fg != null && fg.trim().equals("VC")){%>
	<tr class="TextFilter">
		<td align="center">Condiciones:<%=fb.select("condicion","M = MAYOR O IGUAL,N = MENOR O IGUAL,A = TODAS","", false,false,0,"S")%> Porcentaje:<%=fb.decBox("rango_i","50",false,false,false,10)%></td>
	</tr>
<%}%>
<tr class="TextFilter">
    <td align="center" colspan="<%=colSpan%>"><%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
	
	<%=fb.button("reporte_xls1","Excel",true,false,null,null,"onClick=\"javascript:showReporte(1)\"")%>											
	</td>
</tr>
	<%=fb.formEnd(true)%>
		</table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
