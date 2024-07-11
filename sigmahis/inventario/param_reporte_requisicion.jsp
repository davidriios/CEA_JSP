
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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
String compania =  compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");

if(fg == null ) fg = "RUA";

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
function doAction()
{
}
function showArea()
{
		var fg = '';
		<%if(fg.trim().equals("RP")){%>
		fg='RP';
		<%}else{%> fg='RUA';<%}%>
		abrir_ventana1('../inventario/sel_unid_ejec.jsp?fg='+fg);
}
function clearText()
{
 document.form0.codArea.value="";
 document.form0.descArea.value="";
}
function showReporte2(value)
{
	var titulo = eval('document.form0.titulo').value;
	var area = eval('document.form0.codArea').value;
	var fecha_f = eval('document.form0.fechafin').value;
	var fechaini = eval('document.form0.fechaini').value;
	
	var user = eval('document.form0.user').value;
	
	 abrir_ventana('../inventario/print_requisiciones_pendientes.jsp?titulo='+titulo+'&fDate='+fecha_f+'&tDate='+fechaini+'&user='+user+'&area='+area);

}
function showReporte(option, bi)
{
	var codReq = eval('document.form0.codReq').value;
	var anio = eval('document.form0.anio').value;
	var fecha_i = eval('document.form0.fechaini').value;
	var fecha_f = eval('document.form0.fechafin').value;
	var estado = eval('document.form0.estado').value;

<%if(!fg.trim().equals("REC")){%>
	var almacen = eval('document.form0.almacen').value;
	<%if(fg.trim().equals("RUA")){%>
	if(almacen == ''){alert('Seleccione Almacen '); return false;}
<%}
}%>
<%if(fg.trim().equals("AJ")||fg.trim().equals("AJ2")){%>
	var tipo = eval('document.form0.tipo_ajuste').value;
	var ajuste2 = eval('document.form0.ajuste2').value;
	var titulo = eval('document.form0.titulo').value;
	var consignacion = eval('document.form0.consignacion').value;
	var depto = eval('document.form0.depto').value;
	
	if(bi === undefined)
    abrir_ventana('../inventario/print_inv_ajustes_aprobados.jsp?titulo='+titulo+'&fp=AJ&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&codigo_ajuste='+tipo+'&numero_ajuste1='+codReq+'&numero_ajuste2='+ajuste2+'&anio='+anio+'&consignacion='+consignacion+'&depto='+depto);
  else {
    estado = estado || 'ALL';
    almacen = almacen || 'ALL';
    fecha_i = fecha_i || 'ALL';
    fecha_f = fecha_f || 'ALL';
    codigo_ajuste = tipo || 'ALL';
    codReq = codReq || 'ALL';
    ajuste2 = ajuste2 || 'ALL';
    consignacion = consignacion || 'ALL';
    depto = depto || 'ALL';
    anio = anio || 'ALL';
	var repConta = '';
	var pCosto = 'ALL';
	var afectaInv = 'ALL';
	var afectaConta = 'ALL';
	if(eval('document.form0.tipoCosto'))pCosto=eval('document.form0.tipoCosto').value;
	if(eval('document.form0.tipoCosto'))repConta='S';
	else repConta='N';
	if(eval('document.form0.afectaInv'))afectaInv=eval('document.form0.afectaInv').value|| 'ALL';
	if(eval('document.form0.afectaConta'))afectaConta=eval('document.form0.afectaConta').value|| 'ALL';
	
   if(repConta=='N') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_inv_ajustes_aprobados.rptdesign&pCtrlHeader=true&titulo='+titulo+'&fp=AJ&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&codigo_ajuste='+tipo+'&numero_ajuste1='+codReq+'&numero_ajuste2='+ajuste2+'&anio='+anio+'&consignacion='+consignacion+'&depto='+depto);
   else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_ajustes_aprobados.rptdesign&pCtrlHeader=true&titulo='+titulo+'&fp=AJ&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&codigo_ajuste='+codigo_ajuste+'&numero_ajuste1='+codReq+'&numero_ajuste2='+ajuste2+'&anio='+anio+'&consignacion='+consignacion+'&depto='+depto+'&pCosto='+pCosto+'&pAfectaInv='+afectaInv+'&pAfectaConta='+afectaConta);
  }
<%}else if(fg.trim().equals("RUA")){%>
	var depto = eval('document.form0.codArea').value;
	if(option=="1")abrir_ventana('../inventario/print_requisiciones_unidades_adm.jsp?fg=RUA&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+depto+'&anio='+anio+'&cod_req='+codReq);
	else abrir_ventana('../inventario/print_list_requisiciones.jsp?fg=RUA&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+depto+'&anio='+anio+'&cod_req='+codReq);
<%}else if(fg.trim().equals("REA")){%>
	var titulo = eval('document.form0.titulo').value;
	var depto = eval('document.form0.depto').value;
	var almacen_dev = eval('document.form0.almacen_dev').value;
	var tipoSol     = eval('document.form0.tipoSol').value;
	var descEstado  = '';
	var indice = document.form0.estado.selectedIndex ;
	var descEst= document.form0.estado.options[indice].text;
	if(estado =='') descEstado ='TODOS';
	else  descEstado= descEst.substr(0);

	if(option=="1")abrir_ventana('../inventario/print_sol_req_almacenes.jsp?fg=REA&almacen_dev='+almacen+'&estado='+estado+'&almacen='+almacen_dev+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+depto+'&anio='+anio+'&cod_req='+codReq+'&titulo='+titulo+'&tipo='+tipoSol);
	else abrir_ventana('../inventario/print_list_requisiciones.jsp?fg=REA&almacen_dev='+almacen_dev+'&estado='+estado+'&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+depto+'&titulo='+titulo+'&descEstado='+descEstado);
<%}else{%>
	var titulo = eval('document.form0.titulo').value;
	var depto = eval('document.form0.depto').value;
	var tipoSol     = eval('document.form0.tipoSol').value;
	var compania1     = eval('document.form0.compania').value;
	if(option=="1")abrir_ventana('../inventario/print_req_companias.jsp?fg=REC&estado='+estado+'&fDate='+fecha_i+'&tDate='+fecha_f+'&anio='+anio+'&cod_req='+codReq+'&tipo='+tipoSol+'&compania='+compania1);
	else abrir_ventana('../inventario/print_list_requisiciones.jsp?fg=REC&estado='+estado+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+depto+'&titulo='+titulo+'&anio='+anio+'&cod_req='+codReq+'&tipo='+tipoSol+'&compania1='+compania1);
<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("RUA")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE REQUISICION DE UNIDADES ADM."></jsp:param>
	</jsp:include>

	<%}else if(fg.trim().equals("REA")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE REQUISICION ENTRE ALMACEN"></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("AJ")||fg.trim().equals("AJ2")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="SOLICITUD DE AJUSTES DE INVENTARIO"></jsp:param>
	</jsp:include>

	<%}else if(fg.trim().equals("REC")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE REQUISICION ENTRE COMPAÑIAS"></jsp:param>
	</jsp:include>

	<%}else if(fg.trim().equals("RP")){%>

		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE REQUISICIONES PENDIENTES"></jsp:param>
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
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%if(fg.trim().equals("RP")){%>
			<tr class="TextFilter">
				<td>Usuario</td>
				<td colspan="2"><%=fb.textBox("user","",false,false,false,25)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Titulo</td>
				<td colspan="2"><%=fb.textBox("titulo","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
			<td>Area que Solicita </td>
				<td colspan="2">
					<%=fb.textBox("codArea","",false,false,false,5)%>
				 <%=fb.textBox("descArea","",false,false,true,50)%>
				 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>
			 </td>
			</tr>
			<tr class="TextFilter">
			<td>Fecha</td>
			<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include>
											</td>

		</tr>
		<tr class="TextFilter">
			<td colspan="3" align="center"> <%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte2()\"")%>	</td>
		</tr>
			<%} if(!fg.trim().equals("RUA")&& !fg.trim().equals("RP") ){%>
			<tr class="TextFilter">
				<td>Departamento</td>
				<td colspan="2"><%=fb.textBox("depto",(fg.trim().equals("AJ")||fg.trim().equals("AJ2"))?"INVENTARIO":"",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>Titulo</td>
				<td colspan="2"><%=fb.textBox("titulo",(fg.trim().equals("AJ")||fg.trim().equals("AJ2"))?"AJUSTES APROBADOS AL INVENTARIO":"",false,false,false,60)%> </td>
			</tr>
		<%}
		if(fg.trim().equals("AJ")||fg.trim().equals("AJ2")){%>
		<tr class="TextFilter">
				<td>Tipo De Ajuste</td>
				<td colspan="2">
					<%=fb.select(ConMgr.getConnection(),"select codigo_ajuste, descripcion from tbl_inv_tipo_ajustes","tipo_ajuste","",false,false,0, "text10", "", "","","T")%>
				<%//=fb.select("tipo_ajuste","2=DESCARTE DE MERCANCIA POR OBSOLECENCIA,4=AJUSTE AL INVENTARIO PARA CORRECCION,6=DESCARTE DE MERCANCIA POR VENCIMIENTO,7=DESCARTE DE MERCANCIA POR DETERIORO O ACCIDENTE","")%></td>
			</tr>

			<tr class="TextFilter">
				<td>Almacen</td>
				<td colspan="2"><%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script></td>
			</tr>

		<%}%>

			<%if(fg.trim().equals("REA")){%>
		<tr class="TextFilter">
		<td width="15%">Almacen que Solicita</td>
		<td width="35%">
			<%=fb.select("almacen_dev","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen_dev','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>
			</td>
			<td>Almacen que Entrega
			<%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>

			</td>

		</tr>

		<%}if(fg.trim().equals("RUA")){%>
		<tr class="TextFilter">
		<td width="15%">Compañia</td>
		<td width="35%">
		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>
		</td>

		<td width="50%">
			Almacen
			<%=fb.select("almacen","","")%>
      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>
			</td>
			</tr>
		<tr class="TextFilter">
		<td>Area que Solicita </td>
			<td colspan="2">
				<%=fb.textBox("codArea","",false,false,false,5,null,null,"onFocus=\"javascript:clearText()\"")%>
			 <%=fb.textBox("descArea","",false,false,true,50)%>
			 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>
		 </td>
		</tr>
	<%}%>
	<%if(fg.trim().equals("REC")){%>
	<tr class="TextFilter">
		<td>Compañia</td>
		<td colspan="2">
		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania where codigo <> "+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>
		</td>
		</tr>
	<%}%>
	<%String label ="" ;

			if(fg.trim().equals("RUA") )
			label ="A=APROBADAS,P=PENDIENTES,N=ANULADAS,R=PROCESADAS,T=TRAMITE,E=ENTREGADAS";
			else if(fg.trim().equals("REA") ||fg.trim().equals("REC")  )
			label ="A=APROBADAS,P=PENDIENTES,N=ANULADAS,R=PROCESADAS";
			else if(fg.trim().equals("AJ") )
			label ="A=APROBADOS,T=TRAMITE";
			else if(fg.trim().equals("AJ2") )
			label ="A=APROBADOS";

		if(!fg.trim().equals("RP")){	%>

		<tr class="TextFilter">
			<td>Estado</td>
			<td colspan="2">	<%=fb.select("estado",label,(fg.trim().equals("AJ2")?"A":""),"T")%></td>
		</tr>
		<%if(fg.trim().equals("AJ")||fg.trim().equals("AJ2")){	%>
		<tr class="TextFilter">
			<td>Consignaci&oacute;n</td>
			<td colspan="2"><%=fb.select("consignacion","S=SI,N=NO","",false,false,0,"",null,null,null,"T")%></td>
		</tr>
		<%}%>
		<%if(fg.trim().equals("AJ2")){	%>
		<tr class="TextFilter">
			<td>Tipo de Costo</td>
			<td colspan="2"><%=fb.select("tipoCosto","CP=COSTO PROMEDIO,CC=COSTO CIERRE MES","",false,false,0,"",null,null,null,"")%></td>
		</tr>
		<tr class="TextFilter">
			<td>Afecta inventario</td>
			<td colspan="2"><%=fb.select("afectaInv","Y=SI,N=NO","",false,false,0,"",null,null,null,"T")%></td>
		</tr>
		<tr class="TextFilter">
			<td>Afecta Contabilidad</td>
			<td colspan="2"><%=fb.select("afectaConta","Y=SI,N=NO","",false,false,0,"",null,null,null,"T")%></td>
		</tr>
		<%}%>
		<tr class="TextFilter">
			<td>Fecha</td>
			<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fechafin" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include>
											</td>

		</tr>
		<%if(!fg.trim().equals("AJ")&&!fg.trim().equals("AJ2")){%>
		<tr class="TextFilter">
			<td >REQUISICION </td>
			<td colspan="2">Año <%=fb.textBox("anio","",false,false,false,5)%> &nbsp;&nbsp;# <%=fb.textBox("codReq","",false,false,false,5)%>

		<%if(fg.trim().equals("REA") || fg.trim().equals("REC") ){%>Tipo <%=fb.textBox("tipoSol","",false,false,false,5)%><%}%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="3">Reportes</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Requisici&oacute;n Detallada
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Requisici&oacute;n Resumida
			</td>
		</tr>
		<%}
		}%>
		<%if(fg.trim().equals("AJ")||fg.trim().equals("AJ2")){%>
		<tr class="TextFilter">
			<td>Por No. Ajuste</td>
			<td colspan="2"> Año <%=fb.textBox("anio","",false,false,false,5)%>DEL &nbsp;&nbsp;
											<%=fb.textBox("codReq","",false,false,false,5)%>
											 AL   <%=fb.textBox("ajuste2","",false,false,false,5)%>
											</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="3" align="center">
        <%=(!fg.trim().equals("AJ2")?fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte(0)\""):"")%>
        <%=fb.button("report","Excel",true,false,null,null,"onClick=\"javascript:showReporte(0, 0)\"")%>
			</td>
		</tr>
		<%}%>
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
