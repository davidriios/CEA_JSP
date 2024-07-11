<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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

//  listado de activos

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String orden ="1";
String fecha_hasta ="";
String fecha_desde ="";
 
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos",
	searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String codigo  = ""; // variables para mantener el valor de los campos filtrados en la consulta
	String descripcion = "";
	String estatus = "", factura = "", orden__compra = "", departamento = "", clasificacion="";
	if (request.getParameter("orden") != null && !request.getParameter("orden").trim().equals(""))
	{orden = request.getParameter("orden");
	}
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(a.secuencia) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo     = request.getParameter("codigo");  // utilizada para mantener el código por el cual se filtró
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(a.observacion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion    = request.getParameter("descripcion"); // utilizada para mantener la descripción del activo por el cual se filtró
	}
	if (request.getParameter("estatus") != null && !request.getParameter("estatus").trim().equals(""))
	{
		appendFilter += " and a.estatus like '%"+request.getParameter("estatus").toUpperCase()+"%'";
		estatus     = request.getParameter("estatus");  // utilizada para mantener el código por el cual se filtró
	} else {
		appendFilter += " and a.estatus like '%ACTI%'";
	}
	if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals(""))
	{
		appendFilter += " and a.factura like '"+request.getParameter("factura")+"%'";
		factura     = request.getParameter("factura");  // utilizada para mantener el código por el cual se filtró
	}
	if (request.getParameter("orden__compra") != null && !request.getParameter("orden__compra").trim().equals(""))
	{
		appendFilter += " and a.orden__compra like '"+request.getParameter("orden__compra")+"%'";
		orden__compra     = request.getParameter("orden__compra");  // utilizada para mantener el código por el cual se filtró
	}
	if (request.getParameter("departamento") != null && !request.getParameter("departamento").trim().equals(""))
	{
		appendFilter += " and c.descripcion like '"+request.getParameter("departamento")+"%'";
		departamento     = request.getParameter("departamento");  // utilizada para mantener el código por el cual se filtró
	}
	if (request.getParameter("clasificacion") != null && !request.getParameter("clasificacion").trim().equals(""))
	{
		appendFilter += " and b.descripcion like '"+request.getParameter("clasificacion")+"%'";
		clasificacion     = request.getParameter("clasificacion");  // utilizada para mantener el código por el cual se filtró
	}
	if (request.getParameter("fecha_desde") != null && !request.getParameter("fecha_desde").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_de_entrada) >= to_date('"+request.getParameter("fecha_desde")+"','dd/mm/yyyy')";
		fecha_desde     = request.getParameter("fecha_desde");
	}
	if (request.getParameter("fecha_hasta") != null && !request.getParameter("fecha_hasta").trim().equals(""))
	{
		appendFilter += " and trunc(a.fecha_de_entrada) <= to_date('"+request.getParameter("fecha_hasta")+"','dd/mm/yyyy')";
		fecha_hasta     = request.getParameter("fecha_hasta");
	}



	sql = "select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, a.estatus, decode(a.estatus,'ACTI','ACTIVO','RETIR','INACTIVO') estatusDsp, a.tipo_activo, a.cod_provee, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placa, c.descripcion unidad, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo,(select count(*) from tbl_con_salida_activos sa where compania=a.compania and sa.sec_activo=a.secuencia) salida from tbl_con_activos a, tbl_con_detalle_otro b, tbl_sec_unidad_ejec c where a.compania="+(String)session.getAttribute("_companyId")+appendFilter+" and a.compania = b.cod_compania(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = c.compania(+) and a.ue_codigo = c.codigo(+) order by ";
	if(orden.trim().equals("1"))sql +=" a.fecha_de_entrada, to_number(a.secuencia)";
	else if(orden.trim().equals("3"))sql +=" a.fecha_de_entrada desc, to_number(a.secuencia) desc";
	else if(orden.trim().equals("2"))sql +=" a.observacion asc ";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'ACTIVO FIJO - '+document.title;

function add(){abrir_ventana('../activos/activo_fijo_config.jsp?mode=add');}
function edit(id,k){var estatus = eval('document.form0.estatus'+k).value;var mode = 'edit';if (estatus=='RETIR')  mode ='view';abrir_ventana('../activos/activo_fijo_config.jsp?mode='+mode+'&secuencia='+id);}
function ver(id,k){var mode = 'view';abrir_ventana('../activos/activo_fijo_config.jsp?mode='+mode+'&secuencia='+id);}

function salidaActivos(id,k)
{var salida = eval('document.form0.salida'+k).value;
var estatus = eval('document.form0.estatus'+k).value;
var mode ='';

	 if(salida=='0' && estatus=='ACTI')mode ='add'; 
	 else if(salida!='0' && estatus=='RETIR')mode ='view';
	 else mode ='edit';

	if(salida != '0' || estatus != 'RETIR') {
		abrir_ventana('../activos/salida_activos.jsp?mode='+mode+'&secuencia='+id);
	}
	else {
		alert('El activo está en estado INACTIVO');
	}
}

function mejorasActivos(id)
{
 abrir_ventana('../activos/mejora_activos.jsp?mode=add&secuencia='+id);
}

function printList()
{
	var orden=document.search01.orden.value;
	abrir_ventana('../activos/print_list_activos_fijos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&orden='+orden);
}
function printListExcel()
{
	var orden=document.search01.orden.value;
	var pCtrlHeader = "false";
		//if (document.getElementById("pCtrlHeader").checked==true) pCtrlHeader = "true";
	//abrir_ventana('../activos/print_list_activos_fijos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&orden='+orden);
	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=activos/rpt_print_list_activos.rptdesign&pAppendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&pOrden="+orden+"&pCtrlHeader="+pCtrlHeader);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ACTIVO FIJO - TRANSACCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr>
				<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Activo Fijo ]</a></authtype></td>
		</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<tr class="TextFilter">
							<td width="100%">C&oacute;digo:
								<%=fb.textBox("codigo",codigo,false,false,false,10,null,null,null)%>
							&nbsp;Estado:
								<%=fb.select("estatus","ACTI=ACTIVO,RETIR=INACTIVO",estatus,false,false,0,"",null,"")%>
							&nbsp;Descripci&oacute;n:
								<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
							<%=fb.textBox("factura",factura,false,false,false,10,null,null,null)%>
							&nbsp;O/C#:
								<%=fb.textBox("orden__compra",orden__compra,false,false,false,10,null,null,null)%>
							&nbsp&nbspFecha Entrada: 
							<jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fecha_desde" />
                            <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
                            <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                            <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include>
								
							</td>
					</tr>
					<tr class="TextFilter">
							<td>&nbsp;Departamento:
								<%=fb.textBox("departamento",departamento,false,false,false,40,null,null,null)%>
							&nbsp;Clasificaci&oacute;n:
								<%=fb.textBox("clasificacion",clasificacion,false,false,false,30,null,null,null)%>
								Orden: <%=fb.select("orden","1=Fecha de Entrada,2=Nombre ASC,3=Fecha de Entrada Desc",orden,false,false,0,"",null,"")%>
								<%=fb.submit("go","Ir")%>
							</td>
					</tr>
				 <%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
		<tr>
				<td align="right">&nbsp;
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>&nbsp;<authtype type='0'><a href="javascript:printListExcel()" class="Link00">[ Imprimir Lista Excel ]</a></authtype></td>
		</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("estatus",estatus)%>
					<%=fb.hidden("orden",orden)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("estatus",estatus)%>
					<%=fb.hidden("orden",orden)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list" >
				<tr class="TextHeader">
					<td width="5%">C&oacute;digo</td>
					<td width="35%">Descripción</td>
					<td width="8%" align="center">Estado</td>
					<td width="9%" align="center">Fecha de Entrada</td>
					<td width="21%" align="center">Pertenece a</td>
					<td width="6%">&nbsp;</td>
					<td width="7%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
					<td width="4%">&nbsp;</td>
				</tr>
			<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
				<%for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";

				%>
				<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
				<%=fb.hidden("salida"+i,cdo.getColValue("salida"))%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("secuencia")%></td>
					<td><%=cdo.getColValue("observacion")%></td>
					<td align="center"><%=cdo.getColValue("estatusDsp")%></td>
					<td align="center"><%=cdo.getColValue("fecha_entrada")%></td>
					<td><%=cdo.getColValue("unidad")%></td>
					<td align="center">&nbsp;
					<%if(cdo.getColValue("estatus").trim().equals("ACTI")||!cdo.getColValue("salida").trim().equals("0")){%>					
					<authtype type='50'><a href="javascript:salidaActivos(<%=cdo.getColValue("secuencia")%>,<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Salidas</a></authtype>
					<%}%>
					</td>

					<td align="center">&nbsp;
					<authtype type='51'><a href="javascript:mejorasActivos(<%=cdo.getColValue("secuencia")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Mejoras&nbsp;</a></authtype></td>

					<td align="center">&nbsp;
					<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("secuencia")%>,<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
					
					<td align="center">&nbsp;
					<authtype type='1'><a href="javascript:ver(<%=cdo.getColValue("secuencia")%>,<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype></td>
				</tr>
				<%
				}
				%>
			<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("estatus",estatus)%>
					<%=fb.hidden("orden",orden)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("estatus",estatus)%>
					<%=fb.hidden("orden",orden)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>