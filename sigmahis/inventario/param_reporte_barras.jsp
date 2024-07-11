
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
======================================================================================================
		FORMA              REPORTE              FLAG                DESCRIPCION
		ACT0002            INV00141.RDF         CB                  REPORTE DE CODIGO DE BARRA Y ACTIVOS FIJOS
		-------            INV00129.RDF         ND                  REPORTE DE NOTAS DE DEBITO   
						           FAC10037.RDF			    CO					        REPORTE DE CONSUMO DE OXIGENO
                       INV00137.RDF         PL                  REQUISICIONES DE  MATERIALES NUTRICION
		FAC96054					 FAC_80096.RDF        CA                  COMIDAS ACOMPAÑANTES
						           INV00125.RDF		    	CP					        REPORTE DE CARGOS A LOS PACIENTES 
		
								
================================================================================================

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
boolean viewMode = true;
String compania =  (String) session.getAttribute("_companyId");	
String fg = request.getParameter("fg");
String displayDetail = "";
String anio = request.getParameter("anio");
String noRecep = request.getParameter("noDoc");

if(fg == null ) fg = "CB";
if(anio == null ) anio = "";
if(noRecep == null ) noRecep = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - '+document.title;

function doAction(valor)
{
//if(valor=="2") viewMode=false; else viewMode = true; 
///alert('Valor view'+viewMode);
}
function showDetail(status)
{
	var obj=document.getElementById('detail1');
	var obj2=document.getElementById('detail2');
	if(status=='2')
	{
		eval('document.form0.secini').readOnly=false;
		eval('document.form0.secini').className='FormDataObjectEnabled';
		eval('document.form0.secfin').readOnly=false;
		eval('document.form0.secfin').className='FormDataObjectEnabled';
		eval('document.form0.fechaini').value='';
		eval('document.form0.fechafin').value='';
		
		obj.style.display='none';
		obj2.style.display='';
		
	}
	else if(status=='1')
	{
		eval('document.form0.secini').readOnly=true;
		eval('document.form0.secini').className='FormDataObjectDisabled';
		eval('document.form0.secini').value='';
		eval('document.form0.secfin').readOnly=true;
		eval('document.form0.secfin').className='FormDataObjectDisabled';
		eval('document.form0.secfin').value='';
		
		obj.style.display='';
		obj2.style.display='none';
	}
}
function showPacienteList(){document.form0.pacId.value='';document.form0.noAdmision.value='';document.form0.nombre.value='';  abrir_ventana1('../common/sel_paciente.jsp?fp=req');}
function showReporte2(id)
{
		var msg='';
		<%if(!fg.trim().equals("PL"))
		{%>
					var fechaini = eval('document.form0.fechaini').value;
					var fechafin = eval('document.form0.fechafin').value;
					var wh = '',cds='';
					var pacId='';
					var noAdmision =''
					if(document.form0.wh) wh=eval('document.form0.wh').value;	
					if(document.form0.area) cds=eval('document.form0.area').value;	
					if(document.form0.pacId) pacId=eval('document.form0.pacId').value;
					if(document.form0.noAdmision) noAdmision=eval('document.form0.noAdmision').value;
					
						<%if(fg.trim().equals("ND")){%>
						
						if(wh == '' ) msg =' Almacen';
						<%}else if(fg.trim().equals("CB")){%>
						var secini   = eval('document.form0.secini').value;
						var secfin   = eval('document.form0.secfin').value;
						var familyCode   = eval('document.form0.familyCode').value;
						var clase   = eval('document.form0.classCode').value;
						var subClase   = eval('document.form0.subclase').value;
						var barCode   = eval('document.form0.barCode').value;
						var anioRecep   = eval('document.form0.anioRecep').value;
						var noRecep   = eval('document.form0.noRecep').value;
						var qtyToPrint =1;
						if(document.form0.qtyToPrint)qtyToPrint =document.form0.qtyToPrint.value;
						<%}%>
						
						<%if(!fg.trim().equals("CB")){%>
						<%if(!fg.trim().equals("IS")){%>if(fechaini == '' && fechafin == '' ) msg +=' , Rango de Fechas  ';<%}%>
						<%}%>
						if(msg != '')	alert('Seleccione '+msg+' !!');
						else 
						{
						<%if(fg.trim().equals("EE")){%>
						abrir_ventana('../inventario/print_list_equipos_entregados.jsp?fDate='+fechaini+'&tDate='+fechafin);
						<%}else if(fg.trim().equals("IS")){%>
						abrir_ventana('../inventario/print_insumos_solicitados.jsp?fDate='+fechaini+'&tDate='+fechafin+'&wh='+wh+'&cds='+cds+'&pacId='+pacId+'&noAdmision='+noAdmision);
						<%}else if(fg.trim().equals("CA")){%>
						 abrir_ventana('../inventario/print_comidas_paciente.jsp?compania=1&fDate='+fechaini+'&tDate='+fechafin);
						<%}else if(fg.trim().equals("CO")){%>
						 abrir_ventana('../inventario/print_list_consumo_oxigeno.jsp?fDate='+fechaini+'&tDate='+fechafin);
						<%}else if(fg.trim().equals("CP")){%>
						 if(id=="1")
							abrir_ventana('../inventario/print_list_detalle_cargo.jsp?fg=CP&fDate='+fechaini+'&tDate='+fechafin);
						 else if (id=="2")
							abrir_ventana('../inventario/print_list_detalle_cargo.jsp?fg=CD&fDate='+fechaini+'&tDate='+fechafin);
						<%}else if(fg.trim().equals("ND")){%>
							abrir_ventana('../inventario/print_notas_debito.jsp?fDate='+fechaini+'&tDate='+fechafin+'&almacen='+wh);
						<%}else if(fg.trim().equals("CB")){%>
							if(id=="3")
							abrir_ventana('../inventario/print_rep_placa.jsp?fp=activos&fechaIni='+fechaini+'&fechaFin='+fechafin+'&secini='+secini+'&secfin='+secfin+'&familyCode='+familyCode+'&clase='+clase+'&subClase='+subClase+'&qtyToPrint='+qtyToPrint);
							else if(id=="5"){
							    //barCode = encodeURIComponent(Aes.Ctr.encrypt(barCode,'barCode',256));
							    if(barCode.trim()!="")barCode = Aes.Ctr.encrypt(barCode,'barCode',256);
								abrir_ventana('../inventario/print_rep_placa.jsp?fp=articulos&fechaIni='+fechaini+'&fechaFin='+fechafin+'&secini='+secini+'&secfin='+secfin+'&familyCode='+familyCode+'&clase='+clase+'&barCode='+encodeURIComponent(barCode)+'&subClase='+subClase+'&qtyToPrint='+qtyToPrint+'&anioRecep='+anioRecep+'&noRecep='+noRecep);
							}
						  else if (id=="4")
							abrir_ventana('../inventario/print_codigo_barra_art.jsp?fp=bar&fechaIni='+fechaini+'&fechaFin='+fechafin+'&secini='+secini+'&secfin='+secfin);
						  
						<%}%>
							}
		<%}else if(fg.trim().equals("PL")){%>
						var tipo = eval('document.form0.tipo').value;
						var semana = eval('document.form0.semana').value;
						if(tipo == '' || semana == '')
						alert('Seleccione valor en todos los campos!');
						else 
						abrir_ventana('../inventario/print_plantilla_solicitud.jsp?tipo='+tipo+'&semana='+semana+'&almacen=4');
		<%}%>
	
}

</script>
<style type="text/css">
<!--
.style1 {color: #000000}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<%if(fg.trim().equals("CB")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE CODIGO DE BARRAS ."></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("ND")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE NOTAS DE DEBITO."></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("CO")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE CONSUMO DE OXIGENO."></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("CP")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE CARGO A LOS PACIENTES."></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("EE")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE EQUIPOS ENTREGADOS(ACTIVOS)."></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("CA")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE COMIDAS ACOMPAÑANTES"></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("PL")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE PLANTILLA PARA REQUISICION SEMANAL"></jsp:param>
	</jsp:include>
<%}else if(fg.trim().equals("IS")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE INSUMOS SOLICITADOS VS ENTREGADOS"></jsp:param>
	</jsp:include>
<%}%>


<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
  <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
  <%=fb.formStart(true)%>
  <%=fb.hidden("compania",compania)%>
  
  <%if(fg.trim().equals("ND")||fg.trim().equals("IS")){%>
	<tr class="TextHeader">
    <td colspan="2">ALMACEN</td>
  </tr>
	<tr class="TextFilter">
		<td width="20%">Almacen</td>					
		<td width="80%">	<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+compania+" order by codigo_almacen","wh","","S")%>
		</td>
	</tr>		
	
	<%}%>
	 <%if(!fg.trim().equals("PL")){%>
	 	<%if(fg.trim().equals("CB")){%>
	<tr class="TextRow01">
			<td colspan="1"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%>Reporte por Fecha 
			</td>
			<td colspan="1"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showDetail(this.value)\"")%>Reporte por Secuencia 
			</td>
		</tr>
	<%}%>
	<tr class="TextHeader">
    <td colspan="2">REPORTE POR RANGO DE FECHAS</td>
  </tr>
 <tr id="detail1" style="display:<%=displayDetail%>" class="TextFilter">
    <td>Fecha</td>
    <td>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="2" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="fechaini" />
      <jsp:param name="valueOfTBox1" value="" />
      <jsp:param name="nameOfTBox2" value="fechafin" />
      <jsp:param name="valueOfTBox2" value="" />
      <jsp:param name="valueOfTBox2" value="" />
      </jsp:include>
    </td>
  </tr>
  <%if(fg.trim().equals("IS")){%>
   <tr class="TextFilter">
    <td>Centro Servicio </td>
    <td><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by 2","area","","T")%></td>
  </tr>
   <tr class="TextFilter">
    <td><cellbytelabel>Paciente</cellbytelabel></td>
    <td>
				<%=fb.intBox("pacId","",false,false,true,15,"Text10",null,null)%>
				<%=fb.intBox("noAdmision","",false,false,true,10,"Text10",null,null)%>
				<%=fb.textBox("nombre","",false,false,true,40,"Text10",null,null)%>
				<%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%></td>
  </tr>
  <%}%>
  <tr id="detail2" style="display:none" class="TextFilter">
    <td>Fecha</td>
    <td> Desde <%=fb.textBox("fecha1","",false,false,true,10,null,null,"")%><%=fb.button("regfi","...",true,true,null,null,"")%>  Hasta <%=fb.textBox("fecha2","",false,false,true,10,null,null,"")%><%=fb.button("regff","...",true,true,null,null,"")%>
     
    </td>
  </tr>
	<%}%>
	<%if(fg.trim().equals("CB")){%>
  <tr class="TextHeader">
    <td colspan="2">REPORTE POR RANGO DE SECUENCIAS</td>
  </tr>
  <tr class="TextFilter">
    <td>Secuencia</td>
    <td>Inicial <%=fb.intBox("secini","",false,false,viewMode,5,null,null,"")%> Final &nbsp;&nbsp;<%=fb.intBox("secfin","",false,false,viewMode,5,null,null,"")%></td>
  </tr>
  <tr class="TextFilter">
  <td colspan="2">
		Familia
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?"":"document.form0.familyCode.value"%>,'KEY_COL','T');
		</script>&nbsp;
		Cod Subclase
		<%=fb.intBox("subclase","",false,false,false,30,null,null,null)%>&nbsp;&nbsp;<br>
		Codigo de Barra <%=fb.textBox("barCode","",false,false,false,30,30,null,null,"","Codigo de Barra",false)%>&nbsp;&nbsp;
		No. Copia(s)?   <%=fb.textBox("qtyToPrint","1",false,false,false,4,4,null,null,"","Cantidad de copia",false)%>
	</td>
  </tr>	
  <tr class="TextFilter">
    <td colspan="2">Año Recepcion: <%=fb.intBox("anioRecep",anio,false,false,false,5,null,null,"")%>  &nbsp;&nbsp;No. Recepcion <%=fb.intBox("noRecep",noRecep,false,false,false,5,null,null,"")%></td>
  </tr>
  <tr class="TextFilter">
    <td colspan="2" align="center"><%=fb.button("report2","Codigo de Barras(No Activos Fijos)",true,false,null,null,"onClick=\"javascript:showReporte2(5)\"")%>
	<%=fb.button("report1","Codigo de Barras(Activo Fijos)",true,false,null,null,"onClick=\"javascript:showReporte2(3)\"")%>	
	<%=fb.button("report3","Activos con Placa",true,false,null,null,"onClick=\"javascript:showReporte2(4)\"")%></td>
  </tr>
  
	<%} else if(fg.trim().equals("PL")){%>
	
	<tr class="TextFilter">
		<td align="center">Tipo</td>
    <td><%=fb.select(ConMgr.getConnection(),"select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from solicitud_semanal_tipo where compania="+compania+" and codigo_almacen = 4 order by codigo ","tipo","")%></td>
  </tr>
	<tr class="TextFilter">
		<td align="center">Semana</td>
    <td><%=fb.select(ConMgr.getConnection(),"select distinct semana as optValueColumn,'SEMANA:'||semana as optLabelColumn from solicitud_semanal_plantilla where compania="+compania+" and codigo_almacen = 4 order by semana ","semana","")%></td>
  </tr>
	<%}if(fg.trim().equals("CA") || fg.trim().equals("EE")|| fg.trim().equals("IS")|| fg.trim().equals("CO")|| fg.trim().equals("PL")|| fg.trim().equals("ND")){%>
	<tr class="TextFilter">
    <td colspan="2" align="center"><%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte2(0)\"")%></td>
  </tr>
  <%} else if(fg.trim().equals("CP")){%>
	<tr class="TextFilter">
    <td colspan="2" align="center"><%=fb.button("report","Reporte de Cargos",true,false,null,null,"onClick=\"javascript:showReporte2(1)\"")%><%=fb.button("report","Reporte Detallado",true,false,null,null,"onClick=\"javascript:showReporte2(2)\"")%></td>
  </tr>
	<%}%>

  <%=fb.formEnd(true)%>
  <!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table></td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
