<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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

String almacen = "";
String compania = (String) session.getAttribute("_companyId") ;
String fg = request.getParameter("fg");

if(fg == null ) fg = "EUA";

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
function doAction(){}
function showArea(){abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=EUA');}
function showReporte(bi)
{
	var fecha_i = eval('document.form0.fechaini').value;
	var fecha_f = eval('document.form0.fechafin').value;
	var codEnt = ''
	var anio ='';
	var descDepto = '';
	var titulo  ='';
	var almacen ='';
	var area = '';
	var articulo = '';
	var codReq = '';
	var anioReq = '';
	var com ='';
	var compania2 ='';var familia ='';var clase ='';
	if(eval('document.form0.codEnt'))codEnt=eval('document.form0.codEnt').value;
	if(eval('document.form0.anio'))anio = eval('document.form0.anio').value;
	if(eval('document.form0.depto'))descDepto=eval('document.form0.depto').value;
	if(eval('document.form0.titulo'))titulo=document.form0.titulo.value;
		if(eval('document.form0.almacen'))almacen = eval('document.form0.almacen').value;
	if(eval('document.form0.codArea')) area = eval('document.form0.codArea').value;
	if(eval('document.form0.articulo')) articulo = eval('document.form0.articulo').value;
	if(eval('document.form0.codReq')) codReq = eval('document.form0.codReq').value;
	if(eval('document.form0.anioReq')) anioReq = eval('document.form0.anioReq').value;
	if(eval('document.form0.compania'))com = eval('document.form0.compania').value;
	if(eval('document.form0.compania2'))compania2 = eval('document.form0.compania2').value;
	if(eval('document.form0.familyCode'))familia = eval('document.form0.familyCode').value;
	if(eval('document.form0.classCode'))clase = eval('document.form0.classCode').value;

<%if(fg.trim().equals("EUA")){%>
	//unidades
	if(!bi) abrir_ventana('../inventario/print_entregas_und_adm.jsp?fg=EUA&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+area+'&titulo='+titulo+'&anioEntrega='+anio+'&noEntrega='+codEnt+'&articulo='+articulo+'&descDepto='+descDepto+'&noReq='+codReq+'&anioReq='+anioReq);
	else {
		almacen = almacen || 'ALL';
		fecha_i = fecha_i || 'ALL';
		fecha_f = fecha_f || 'ALL';
		area = area || 'ALL';
		anio = anio || 'ALL';
		codEnt = codEnt || 'ALL';
		titulo = titulo || 'INVENTARIO';
		articulo = articulo || 'ALL';
		descDepto = descDepto || 'ALL';
		codReq = codReq || 'ALL';
		anioReq = anioReq || 'ALL';

		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_entregas_und_adm.rptdesign&pCtrlHeader=true&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+area+'&titulo='+titulo+'&anioEntrega='+anio+'&noEntrega='+codEnt+'&articulo='+articulo+'&descDepto='+descDepto+'&noReq='+codReq+'&anioReq='+anioReq);
	}



<%} else if(fg.trim().equals("EEA")){%>
	abrir_ventana('../inventario/print_entregas_almacenes.jsp?fg=EEA&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+area+'&titulo='+titulo+'&anioEntrega='+anio+'&noEntrega='+codEnt+'&descDepto='+descDepto);
<%} else if(fg.trim().equals("EEC")){%>
	abrir_ventana('../inventario/print_entrega_companias.jsp?fg=EEC&fDate='+fecha_i+'&tDate='+fecha_f+'&titulo='+titulo+'&anioEntrega='+anio+'&noEntrega='+codEnt+'&descDepto='+descDepto+'&compania1='+com);
<%} else if(fg.trim().equals("EA")){%>
	abrir_ventana('../inventario/print_gastos_x_depto.jsp?fg=EA&fechaI='+fecha_i+'&fechaF='+fecha_f+'&compania='+com+'&almacen='+almacen);
<%} else if(fg.trim().equals("EAF")){%>
	abrir_ventana('../inventario/print_trxs_entre_almacenes.jsp?fg=EAF&fechaI='+fecha_i+'&fechaF='+fecha_f+'&compania='+com+'&almacen='+almacen);
<%} else if(fg.trim().equals("EUA2")){%>
	var verActivo  ="S";
	if(document.form0.verActivo.checked!=true) verActivo = "N";
	if(!bi)abrir_ventana('../inventario/print_entregas_und_x_flias.jsp?titulo='+titulo+'&unidad='+area+'&fDate='+fecha_i+'&tDate='+fecha_f+'&compania_sol='+com+'&almacen='+almacen+'&compania2='+compania2+"&verActivo="+verActivo);
	else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/print_entregas_und_x_flias.rptdesign&pCtrlHeader=true&unidad='+area+'&fDate='+fecha_i+'&tDate='+fecha_f+'&companiaSol='+com+'&almacen='+almacen+'&companiaEnt='+compania2+'&verActivo='+verActivo);
<%} else if(fg.trim().equals("EUAA")){%>

	var fdArray = '', fhArray = '', fDesde = '',fHasta = '';
	if(fecha_i!=''&&fecha_i!=''){
	if(fecha_i!='') fdArray = fecha_i.split("/");
	if(fecha_f!='') fhArray = fecha_f.split("/");
	if(fecha_i!='') fDesde = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	if(fecha_f!='') fHasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];

	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_entregas_und_x_art.rptdesign&pWh='+almacen+'&pFlia='+familia+'&pClase='+clase+'&pArticulo='+articulo+'&fDesde='+fDesde+'&fHasta='+fHasta+'&titulo='+titulo+'&pArea='+area+'&noReq='+codReq+'&anioReq='+anioReq+'&anioEntrega='+anio+'&noEntrega='+codEnt);
	//https://fernandocasanova.org/metodo-para-memorizar-textos-biblicos/
}else alert('Introduzca rango de Fecha');
<%}%>
}
function getReport(){
	var fecha_i = eval('document.form0.fechaini').value;
	var fecha_f = eval('document.form0.fechafin').value;
	var codEnt = ''
	var anio ='';
	var descDepto = '';
	var titulo  ='';
	var almacen ='';
	var area = '';
	if(eval('document.form0.codEnt'))codEnt=eval('document.form0.codEnt').value;
	if(eval('document.form0.anio'))anio = eval('document.form0.anio').value;
	if(eval('document.form0.depto'))descDepto=eval('document.form0.depto').value;
	if(eval('document.form0.titulo'))titulo=document.form0.titulo.value;
		if(eval('document.form0.almacen'))almacen = eval('document.form0.almacen').value;
	if(eval('document.form0.codArea')) area = eval('document.form0.codArea').value;
	if(eval('document.form0.articulo')) articulo = eval('document.form0.articulo').value;
	<%if(fg.trim().equals("EEA")){%>
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_inv_entrega_almacen.rptdesign&almacen='+almacen+'&fDate='+fecha_i+'&tDate='+fecha_f+'&depto='+area+'&titulo='+titulo+'&anioEntrega='+anio+'&noEntrega='+codEnt+'&descDepto='+descDepto);
	<%}%>
}
function buscaArticulo()
{
	var msg ='';
	var almacen     = eval('document.form0.almacen').value;
	var familia     = '',clase       ='';
	if(eval('document.form0.familyCode'))familia=eval('document.form0.familyCode').value;
	if(eval('document.form0.classCode'))clase= eval('document.form0.classCode').value;

	if(almacen ==' ') msg=' Almacen';
	if(msg==''){
	 abrir_ventana('../common/search_articulo.jsp?id=13&fp=EUAA&almacen='+almacen+'&familia='+familia+'&clase='+clase);
	}else alert('Seleccione '+msg);
}
function cargarClase()
{
var clase = eval('document.form0.classCode').value;
var flia = eval('document.form0.familyCode').value;
loadXML('../xml/itemClass.xml','classCode',clase,'VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+flia,'KEY_COL','S');
 }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("EUA")||fg.trim().equals("EUA2")||fg.trim().equals("EUAA")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE ENTREGAS DE MATERIALES A UNIDADES ADM."></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("EEA")){%>
		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE ENTREGAS ENTRE ALMACENES"></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("EEC")){%>
		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="REPORTE DE ENTREGAS ENTRE COMPAÑIAS"></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("EA")){%>
		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="CARGOS POR UNIDAD ADMINISTRATIVA"></jsp:param>
	</jsp:include>
	<%}else if(fg.trim().equals("EAF")){%>
		<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TRANSFERENCIA ENTRE ALMACENES"></jsp:param>
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
			<%if(!fg.equals("EA") && !fg.equals("EAF") && !fg.equals("EUA2")){%>
			<tr class="TextFilter">
				<td width="15%">DEPARTAMENTO</td>
				<td colspan="2"><%=fb.textBox("depto","",false,false,false,60)%> </td>
			</tr>
			<tr class="TextFilter">
				<td>TITULO</td>
				<td colspan="2"><%=fb.textBox("titulo","",false,false,false,60)%> </td>
			</tr>
			<%}else{%>

		<%=fb.hidden("titulo","")%>
		<%=fb.hidden("depto","")%>

		<%}%>
			<%if(fg.trim().equals("EEA") || fg.trim().equals("EUA") || fg.trim().equals("EA") || fg.trim().equals("EAF")|| fg.trim().equals("EUAA")){%>
		<tr class="TextFilter">
		<td>ALMACEN</td>
			<td colspan="2">
			<%=fb.select("almacen","","")%>
			<script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:""%>','KEY_COL','S');
			</script>
			</td>
		</tr>
		<%if(fg.trim().equals("EUAA")){%>
		<tr class="TextFilter">
		<td>Familia</td>
		<td colspan="2">
		<%=fb.select("familyCode","","",false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familyCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		</td>
		</tr>

		<tr class="TextFilter">
		<td>Clase</td>
		<td colspan="2">
		<%=fb.select("classCode","","")%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','classCode','','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%="document.form0.familyCode.value"%>,'KEY_COL','T');
		</script>
		</td>
		</tr>

		<%}} %>
		<%if(fg.trim().equals("EUA2")){%>

		<!--<tr class="TextFilter">
				<td>TITULO xx </td>
				<td colspan="2"><%=fb.textBox("titulo1","",false,false,false,60)%> </td>
		</tr>-->
		<tr class="TextHeader">
			<td colspan="3">
			SOLICITANTE
			</td>
		</tr>

		<tr class="TextFilter">
		<td>COMPAÑIA</td>
			<td colspan="2">
			<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania  ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>AREA QUE SOLICITA</td>
			<td colspan="2">
				<%=fb.textBox("codArea","",false,false,false,5)%><%=fb.textBox("descArea","",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>	</td>
		</tr>

		<tr class="TextHeader">
			<td colspan="3">ENTREGA</td>
		</tr>


		<tr class="TextFilter">
		<td>COMPAÑIA</td>
			<td colspan="2">
			<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania  ORDER BY 1","compania2",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>ALMACEN</td>
			<td colspan="2">
			<%=fb.select("almacen","","")%>
			<script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania2.value"%>','KEY_COL','S');
			</script>
			</td>
		</tr>
		<%}if(fg.trim().equals("EUA")||fg.trim().equals("EUAA") ){%>
		<tr class="TextFilter">
			<td>AREA QUE SOLICITA</td>
			<td colspan="2">
				<%=fb.textBox("codArea","",false,false,false,5)%><%=fb.textBox("descArea","",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>	</td>
		</tr>
	<%}%>
		<%if(fg.trim().equals("EEA") ){%>
		<tr class="TextFilter">
			<td>ALMACEN QUE SOLICITA</td>
			<td colspan="2">
			<%=fb.select("codArea","","")%>
			<script language="javascript">
			loadXML('../xml/almacenes.xml','codArea','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania2.value"%>','KEY_COL','S');
			</script>
			</td>
		</tr>
	<%}%>
	<%if(fg.trim().equals("EEC") || fg.trim().equals("EA") || fg.trim().equals("EAF")){%>
	<tr class="TextFilter">
		<td>COMPAÑIA</td>
		<td colspan="2">
		<%if(fg.equals("EA") || fg.trim().equals("EAF")){%>
		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,"S")%>
		<%} else {%>
		<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania where codigo <> "+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,"S")%>
		<%}%>
		</td>
		</tr>
	<%}%>




		<tr class="TextFilter">
			<td>FECHA</td>
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
		<%if(fg.trim().equals("EUA2")){%>
		<tr class="TextFilter">
			<td>Ocultar Activos</td>
			<td colspan="2"> <%=fb.checkbox("verActivo","true",true,false)%>
											 </td>

		</tr>
		<%}%>
		<%if(fg.trim().equals("EUA")|| fg.trim().equals("EUAA")){%>
		<tr class="TextFilter">
			<td>ARTICULO</td>
			<td colspan="2"> <%=fb.textBox("articulo","",false,false,false,5)%>
			<%=fb.textBox("name","",false,false,true,50,"Text10",null,null)%> <%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaArticulo()\"")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td >REQUISICION </td>
			<td colspan="2">Año <%=fb.textBox("anioReq","",false,false,false,5)%>  &nbsp;&nbsp;# <%=fb.textBox("codReq","",false,false,false,5)%></td>
		</tr>
		<%}%>
		<%if(!fg.trim().equals("EA") && !fg.trim().equals("EAF") && !fg.trim().equals("EUA2")){%>
		<%if(!fg.trim().equals("EUA2")){%>
		<tr class="TextFilter">
			<td >ENTREGA </td>
			<td colspan="2">AÑO <%=fb.textBox("anio","",false,false,false,5)%>	 &nbsp;&nbsp;# <%=fb.textBox("codEnt","",false,false,false,5)%></td>
		</tr>
		<%}} else {%>
		<%=fb.hidden("anio","")%>
		<%=fb.hidden("codEnt","")%>
		<%}%>
		<tr class="TextFilter">
			<td colspan="3" align="center">
				<%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
				<%=(fg.equalsIgnoreCase("EUA")||fg.equalsIgnoreCase("EUA2"))?fb.button("reportbi","Excel",true,false,null,null,"onClick=\"javascript:showReporte(1)\""):""%>
				<%=(fg.equalsIgnoreCase("EEA"))?fb.button("reportbi","Excel",true,false,null,null,"onClick=\"javascript:getReport()\""):""%>
			</td>
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
