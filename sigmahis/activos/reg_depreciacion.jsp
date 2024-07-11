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
	FORMA            REPORTE              FLAG                DESCRIPCION
	ACT0065.FMB      ACT0011_TMP             --               PROCESO PARA DEPRECIACION TEMPORAL
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
String sqlP ="";
String compania =  (String) session.getAttribute("_companyId");
String anio =  request.getParameter("anio");
String mes =  request.getParameter("mes");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String userName = UserDet.getUserName();


sqlP ="select to_char(to_date(c.mes||'/'||c.ano,'mm/yyyy'),'FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH') mes from tbl_con_control_depre c, (select max(to_number(to_char(to_date(e.ano||e.mes,'yyyymm'),'yyyymm'))) ultmes from tbl_con_control_depre e where e.compania ="+(String) session.getAttribute("_companyId")+" and e.estatus = 'CER')  d where c.compania ="+(String) session.getAttribute("_companyId")+" and c.estatus = 'CER' and to_number(to_char(to_date(c.ano||c.mes,'yyyymm'),'yyyymm')) = d.ultmes  ";
CommonDataObject cdoP = SQLMgr.getData(sqlP);
if(cdoP ==null){cdoP = new CommonDataObject();cdoP.addColValue("mes","");}
if(anio == null || anio == "") anio =cDateTime.substring(6,10);
if(mes == null) mes ="";

	CommonDataObject cdo = SQLMgr.getData("select 'Ultimo registro de Depreciación Generado hasta el mes de **'||mes_anio||'** generado por el usuario: '||upper(usuario_creacion)||' el día '||to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi am') msg from (SELECT fecha_creacion, usuario_creacion, to_char(to_date(cod_mes||'/'||cod_ano,'mm/yyyy'), 'Month', 'nls_date_language=spanish')||' del '||cod_ano mes_anio FROM tbl_con_temporal_depreciacion WHERE compania = "+(String)session.getAttribute("_companyId")+" and fecha_creacion is not null order by fecha_creacion desc) where rownum = 1 ");
        
	if(cdo ==null){cdo = new CommonDataObject(); cdo.addColValue("msg","");}
    
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - Depreciación Mensual '+document.title;
function doAction()
{
}
function showReporte(r)
{
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;
	var fg='';
	var msg='';
	if(anio =='')msg=' , anio';
	if(mes =='')msg=' ,Mes';

	if (r=='1') fg='t';
	else fg='d';

	if(msg=='')
	{
	abrir_ventana('../activos/list_resumen_depreciacion.jsp?mes='+mes+'&anio='+anio+'&fg='+fg);
	} else alert('Seleccione '+msg);
}


function validarPeriodo()
{
	var anio        = eval('document.form0.anio').value;
	var mes         = eval('document.form0.mes').value;

	var deprec=  getDBData('<%=request.getContextPath()%>',' nvl((select count(*) from tbl_con_deprec_mensual where compania =<%=(String) session.getAttribute("_companyId")%> and cd_ano='+anio+' and cd_mes='+mes+' ),0) reg  ','dual','','');

	if (deprec!=0)
	{
		alert('El Periodo seleccionado ya fue cerrado!');
		eval('document.form0.proceso').disabled = true;
		eval('document.form0.report1').disabled = true;
	} else {
		eval('document.form0.proceso').disabled = false;
		eval('document.form0.report1').disabled = false;
	}

}


function puProceso()
{
var msg='';
	var user = '<%=userName%>'
	var anio=document.form0.anio.value;
	var mes=document.form0.mes.value;


	if(anio =='') msg=' , anio';
	if(mes =='')  msg=' ,Mes';
	if(msg=='')
	{
		var fecha = '01/'+mes+'/'+anio; 

			if(confirm('¿Esta seguro de generar el comprobante?'))
			{ 
			 if(executeDB('<%=request.getContextPath()%>','call sp_con_deprecia_m_usr(<%=compania%>,\''+fecha+'\',\''+fecha+'\',\'' + user + '\')',''))
			 {
						alert('Proceso Terminado Satisfactoriamente..');
						window.location = '<%=request.getContextPath()%>/activos/reg_depreciacion.jsp?anio'+anio+'&mes='+mes;

			 }
			 else alert('Error al Insertar en Temporal.. Proceso Cancelado');
			 }else alert('Proceso Cancelado');
	 } else alert('Seleccione '+msg);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DEPRECIACION MENSUAL"></jsp:param>
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
            
            <tr class="TextRow02">
                <td colspan="3" class="Link05"><font size="+1"><%=cdo.getColValue("msg")%></font></td>
            </tr>

			<tr class="TextHeader">
				<td width="30%" align="right">Ultimo Mes Procesado:</td>
				<td width="70%" align="center"><%=cdoP.getColValue("mes")%></td>
			</tr>

			<tr class="TextHeader">
				<td colspan="2" align="center">Este Proceso Genera la Depreciación Mensual de los Activos de la Institución </td>
			</tr>
			<tr class="TextRow01">
				<td width="40%">&nbsp;</td>
				<td width="60%">&nbsp; </td>
			</tr>
			<tr class="TextRow01">
				<td align="right"> Año </td>
				<td> &nbsp;&nbsp;<%=fb.textBox("anio",anio,false,false,false,12,4,"","","onChange=\"javascript:validarPeriodo()\"")%> </td>
			</tr>

				<tr class="TextRow01">
				<td align="right"> Mes </td>
				<td> &nbsp;&nbsp;<%=fb.select("mes","01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",mes, false, false, 0, "", "", "onChange=\"javascript:validarPeriodo()\"", "", "S")%> </td>
			</tr>


			<tr class="TextRow01">
				<td colspan="2" align="center"> Despues de llenar los parámetros necesarios para generar la depreciación presione "[ EJECUTAR ]"</td>

			</tr>

			<tr class="TextRow01">
				<td colspan="2" align="center"><authtype type='50'><%=fb.button("proceso","<< EJECUTAR >>",true,false,null,null,"onClick=\"javascript:puProceso()\"")%></authtype></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td align="center"><authtype type='51'><%=fb.button("report1","Reporte Preeliminar",true,false,null,null,"onClick=\"javascript:showReporte(1)\"")%></authtype></td>
				<td align="center"><authtype type='52'><%=fb.button("report2","Reporte Depreciación",true,false,null,null,"onClick=\"javascript:showReporte(2)\"")%></authtype></td>
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