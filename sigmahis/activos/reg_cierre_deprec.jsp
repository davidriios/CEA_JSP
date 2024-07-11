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
	ACT0070.FMB      							            --               PROCESO PARA CIERRE MENSUAL
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sqlP ="";
String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();

String anio =  request.getParameter("anio");
String mes =  request.getParameter("mes");

if(anio == null || anio == "") anio =cDateTime.substring(6,10);
if(mes == null) mes ="";

sqlP ="select (select  max(ano) from tbl_con_control_depre where compania ="+(String) session.getAttribute("_companyId")+" and estatus = 'ACT' ) anio, to_char(to_date(c.mes||'/'||c.ano,'mm/yyyy'),'FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH') mes from tbl_con_control_depre c, (select max(to_number(to_char(to_date(e.ano||e.mes,'yyyymm'),'yyyymm'))) ultmes from tbl_con_control_depre e where e.compania ="+(String) session.getAttribute("_companyId")+" and e.estatus = 'CER')  d where c.compania ="+(String) session.getAttribute("_companyId")+" and c.estatus = 'CER' and to_number(to_char(to_date(c.ano||c.mes,'yyyymm'),'yyyymm')) = d.ultmes  ";
CommonDataObject cdoP = SQLMgr.getData(sqlP);
if(cdoP ==null){cdoP = new CommonDataObject();cdoP.addColValue("mes","");}
anio=cdoP.getColValue("anio","");
if(anio == null || anio == "") anio =cDateTime.substring(6,10);
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - Cierre Mensual '+document.title;
function doAction()
{
}

function validarPeriodo()
{
	var anio        = eval('document.form0.anio').value;
	var mes         = eval('document.form0.mes').value;

	var deprec=  getDBData('<%=request.getContextPath()%>',' (select count(*) from tbl_con_temporal_depreciacion where compania =<%=(String) session.getAttribute("_companyId")%> and cod_ano='+anio+' and cod_mes='+mes+' ) reg  ','dual','','');

	if (deprec==0)
	{
		alert('El Periodo seleccionado no corresponde al periodo calculado!');
		eval('document.form0.proceso').disabled = true;
	} else {
		eval('document.form0.proceso').disabled = false;
	}

}


function puProceso()
{
var msg='';
	var v_user = '<%=(String) session.getAttribute("_userName")%>';
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

	if(anio =='')msg=' , anio';
	if(mes =='')msg=' ,Mes';
	if(msg=='')
	{
	 	if(confirm('¿Esta seguro de generar el comprobante?'))
		{
			 if(executeDB('<%=request.getContextPath()%>','call sp_con_depre('+anio+','+mes+',<%=compania%>,\'' + v_user + '\')',''))
			 {
				 var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				 if(msg!='')alert(msg);else alert('Proceso Ejecutado');
			 }
			 else
			 {
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				if(msg!='')alert(msg);else alert('Error en el Proceso de Cierre Mensual de Depreciacion');
			 }
	  	 }else alert('Proceso Cancelado');
	 }else alert('Seleccione '+msg);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CIERRE MENSUAL"></jsp:param>
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
				<td width="30%"  align="right">Ultimo Mes Procesado:</td>
				<td width="70%"  align="center"><%=cdoP.getColValue("mes")%></td>
			</tr>

			<tr class="TextHeader">
				<td colspan="2">Este Proceso Genera el Cierre Mensual de los Activos de la Institución </td>
			</tr>

			<tr class="TextRow01">
				<td align="center"> Año </td>
				<td> <%=fb.textBox("anio",anio,false,false,false,12,4,"","","onChange=\"javascript:validarPeriodo()\"")%> </td>
			</tr>

				<tr class="TextRow01">
				<td align="center"> Mes </td>
				<td><%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes, false, false, 0, "", "", "onChange=\"javascript:validarPeriodo()\"", "", "S")%> </td>
			</tr>


			<tr class="TextRow01">
				<td colspan="2" align="center"> Despues de llenar los parámetros necesarios para generar el Cierre Mensual presione "[ EJECUTAR ]"</td>

			</tr>

			<tr class="TextRow01">
				<td colspan="2" align="center"><authtype type='50'><%=fb.button("proceso","<< EJECUTAR >>",true,false,null,null,"onClick=\"javascript:puProceso()\"")%></authtype></td>
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