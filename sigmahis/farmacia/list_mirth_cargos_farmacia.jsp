<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
ArrayList al = new ArrayList();
int rowCount = 0;

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String pacId = "", admision = "", descripcion = "", fDate = "", tDate = "", codArticulo = "", codRef = "",tipoCuenta = "";
	String actualizado = request.getParameter("actualizado");
	if (actualizado == null) actualizado = "N";

	if(request.getParameter("pacId") != null) pacId = request.getParameter("pacId");
	if(request.getParameter("admision") != null) admision = request.getParameter("admision");
	if(request.getParameter("codArticulo") != null) codArticulo = request.getParameter("codArticulo");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("fDate") != null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate") != null) tDate = request.getParameter("tDate");
	if(request.getParameter("codRef") != null) codRef = request.getParameter("codRef");
	if(request.getParameter("tipoCuenta") != null) tipoCuenta = request.getParameter("tipoCuenta");


	StringBuffer sbSql = new StringBuffer();

	sbSql.append("select a.facturapk, a.factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.esdevolucion,0,'C','D') as esdevolucion, a.direccion, a.serie, a.secuenciafiscal, a.facturadetallepk, a.cantidad, a.precio, a.descripcion, a.renglon, a.codigo, a.codigobarra, trim(a.cliente) as cliente, a.cuentanombre, a.pac_id, a.admision, a.patient_name, nvl(a.actualizado,'N') actualizado, a.fecha_mod, a.seq_trx, a.cod_articulo, a.mrnno, nvl(to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi pm'),' ') as fecha_trx, nvl(to_char(a.sync_date,'dd/mm/yyyy hh12:mi pm'),' ') as fecha_sync");
	sbSql.append(", (select monto from tbl_fac_detalle_transaccion where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and pac_id = a.pac_id and fac_secuencia = a.admision and fac_codigo = a.seq_trx and tipo_transaccion = decode(a.esdevolucion,0,'C','D') and cod_articulo = a.cod_articulo) as precio_venta");
	sbSql.append(" from tbl_int_mirth_far_factura a where 1=1 ");
	if(!pacId.equalsIgnoreCase("")){
			sbSql.append(" and a.pac_id="+pacId);
			sbSql.append(" ");
	}
	if(!descripcion.equalsIgnoreCase("")){
		sbSql.append(" and upper(a.direccion) like '%");
		sbSql.append(descripcion);
		sbSql.append("%'");
	}
	if(!admision.equalsIgnoreCase("")){
		sbSql.append(" and a.admision = ");
		sbSql.append(admision);
	}

	if(!fDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(a.fecha) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!tDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(a.fecha) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}

	if(!codArticulo.equals("")){
		sbSql.append(" and a.codigo = '");
		sbSql.append(codArticulo);
		sbSql.append("'");
	}
	if(!codRef.equals("")){
		sbSql.append(" and a.factura = ");
		sbSql.append(codRef);
	}
	if (!actualizado.trim().equals("")) sbSql.append(" and upper(nvl(a.actualizado,'N'))='"+actualizado+"'");
	if (!tipoCuenta.trim().equals("")) sbSql.append(" and trim(a.cliente)='"+tipoCuenta+"'");

		sbSql.append(" order by a.factura desc,a.renglon");
		StringBuffer sbSqlT = new StringBuffer();
		sbSqlT.append("select * from (select rownum as rn, z.* from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(") z) where rn between ");
		sbSqlT.append(previousVal);
		sbSqlT.append(" and ");
		sbSqlT.append(nextVal);
		al = SQLMgr.getDataList(sbSqlT.toString());
		sbSqlT = new StringBuffer();
		sbSqlT.append("select count(*) as count from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(")");
		rowCount = CmnMgr.getCount(sbSqlT.toString());




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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Interfaz Mirth Farmacia Cargos- '+document.title;
function doAction(){}
function procesar(fact,renglon,index,tipotrx){
	var pacId= document.getElementById("pacId"+index).value;
	var admision= document.getElementById("admision"+index).value;
if(pacId==null || pacId=='' || admision==null || admision=='') { alert('Numero de paciente o admision no es valido'); }
else{
	//alert(pacId);
 $.post("ajax_mirth_update.jsp",
	{
		facturaPK: fact,
	pacId: pacId,
	noAdmision: admision,
	tipoTrx: tipotrx,
		renglon: renglon
	},
	function(data, status){
		alert(data.trim() + "\nStatus: " + status);
	$('form#search01').submit();
	});
}
}
function showReport(){
var pCtrlHeader = $("#pCtrlHeader").is(":checked");
var factura = document.search01.codRef.value||'ALL';
var cliente = document.search01.tipoCuenta.value||'ALL';
var direccion = document.search01.descripcion.value||'ALL';
var fechai = document.search01.fDate.value||'ALL';
var fechaf = document.search01.tDate.value||'ALL';
var actualizado = document.search01.actualizado.value||'ALL';
var pacId = document.search01.pacId.value||'ALL';
var admision = document.search01.admision.value||'ALL';
abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=farmacia/rpt_mirth_cargos_farmacia.rptdesign&pFactura='+factura+'&pCliente='+cliente+'&pDireccion='+direccion+'&pFechai='+fechai+'&pFechaf='+fechaf+'&pActualizado='+actualizado+'&pPacId='+pacId+'&pAdmision='+admision+'&pCtrlHeader='+pCtrlHeader);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='3'><!--<a href="javascript:add()" class="Link00">[ Registrar Nuevo ]</a>--></authtype>
		</td>
	</tr>
	<tr>
		<td>
		<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td>
					Factura No. Farmacia:
					<%=fb.textBox("codRef",codRef, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					PacId:
					<%=fb.textBox("pacId",pacId, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					Admision:
					<%=fb.textBox("admision", admision, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					Detalle Cuenta:
					<%=fb.textBox("descripcion", descripcion, false, false, false, 50, 200, "text12", "", "", "", false, "", "")%>
					Tipo Cuenta:
					<%=fb.textBox("tipoCuenta", tipoCuenta, false, false, false, 6, 10, "text12", "", "", "", false, "", "")%>
					Estado:
					<%=fb.select("actualizado","S=Cargos Generado,N=Pendiente",actualizado,false,false,0,"T")%>
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fDate"/>
					<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
					<jsp:param name="nameOfTBox2" value="tDate"/>
					<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
					</jsp:include>
					<%=fb.submit("go","Ir")%>
					<input type="checkbox" id="pCtrlHeader" name="pCtrlHeader">
					<label for="pCtrlHeader">Esconder cabecera (Excel)</label>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
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
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("pacId", pacId)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("admision", admision)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("codArticulo", codArticulo)%>
					<%=fb.hidden("tipoCuenta", tipoCuenta)%>
					<%=fb.hidden("codRef",""+codRef)%>
					<%=fb.hidden("actualizado",""+actualizado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("pacId", pacId)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("admision", admision)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("codArticulo", codArticulo)%>
					<%=fb.hidden("tipoCuenta", tipoCuenta)%>
					<%=fb.hidden("codRef",""+codRef)%>
					<%=fb.hidden("actualizado",""+actualizado)%>
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
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="8%">No. Factura</td>
					<td width="6%">Tipo Cuenta</td>
					<td>Detalle Cuenta</td>
					<td width="6%">Fecha FAR</td>
					<td width="6%">Fecha Sync</td>
					<td width="3%">Cargo</td>
					<td width="6%">Fecha Cargo</td>
					<td width="5%">PacId</td>
					<td width="3%">Adm.</td>
					<td width="8%">C&oacute;digo Art.</td>
					<td width="15%">Nombre Art.</td>
					<td width="3%">Qty</td>
					<td width="4%">Precio</td>
					<td width="4%">Precio Venta</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if(cdo.getColValue("esdevolucion").equals("D")) color = "RedText";
				 %>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("factura")%></td>
					<td><%=cdo.getColValue("cliente")%></td>
					<td><%=cdo.getColValue("direccion")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("fecha_sync")%></td>
					<td align="center"><%=cdo.getColValue("actualizado")%></td>
					<td align="center"><%=cdo.getColValue("fecha_trx")%></td>
					<td align="center"><%=(cdo.getColValue("actualizado").equals("N")) ? fb.textBox("pacId"+i, cdo.getColValue("pac_id"), false, false, false, 10, 10, "text12", "", "", "", false, "", ""):cdo.getColValue("pac_id")%></td>
					<td align="center"><%=(cdo.getColValue("actualizado").equals("N")) ? fb.textBox("admision"+i, cdo.getColValue("admision"), false, false, false, 4, 4, "text12", "", "", "", false, "", ""):cdo.getColValue("admision")%></td>
					<td align="center"><%=cdo.getColValue("cod_articulo")%> / <%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="right"><%=cdo.getColValue("cantidad")%></td>
					<td align="right"><%=cdo.getColValue("precio")%></td>
					<td align="right"><%=cdo.getColValue("precio_venta")%></td>
					<%
					if(cdo.getColValue("actualizado").equals("N")){
					%>
					<td align="center"><authtype type='4'><a href="javascript:procesar('<%=cdo.getColValue("facturapk")%>','<%=cdo.getColValue("renglon")%>','<%=i%>','<%=cdo.getColValue("esdevolucion")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Procesar</a></authtype></td>
					<%
					}else{
					%>
					<td align="center">&nbsp;</td>
					<%
					}
					%>
				</tr>
				<%
				 }
				 %>
			</table>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("pacId", pacId)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("admision", admision)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("codArticulo", codArticulo)%>
					<%=fb.hidden("tipoCuenta", tipoCuenta)%>
					<%=fb.hidden("codRef",""+codRef)%>
					<%=fb.hidden("actualizado",""+actualizado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("pacId", pacId)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("admision", admision)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("codArticulo", codArticulo)%>
					<%=fb.hidden("tipoCuenta", tipoCuenta)%>
					<%=fb.hidden("codRef",""+codRef)%>
					<%=fb.hidden("actualizado",""+actualizado)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
