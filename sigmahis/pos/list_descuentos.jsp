<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0    SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
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

	String estado = "", descripcion = "";
	if(request.getParameter("estado") != null) estado = request.getParameter("estado");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");


	StringBuffer sbSql = new StringBuffer();
	StringBuffer sbFilter = new StringBuffer();

	sbSql.append("select id, codigo, descripcion, tipo, valor, estado, compania, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, observacion, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, decode(tipo, 'M', 'Monto', 'P', 'Porcentual', 'R', 'Regalia') tipo_desc from tbl_par_descuento where id is not null and compania = "+(String) session.getAttribute("_companyId"));

	if(!estado.equalsIgnoreCase("")){
		sbFilter.append(" and upper(estado) like '");
		sbFilter.append(estado);
		sbFilter.append("%'");
	}
	if(!descripcion.equalsIgnoreCase("")){
		sbFilter.append(" and upper(descripcion) like '");
		sbFilter.append(descripcion);
		sbFilter.append("%'");
	}

	sbSql.append(sbFilter.toString());

	sbSql.append(" order by id");
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
<script language="javascript">
document.title = 'Creación de Descuento - '+document.title;
function add(){
	abrir_ventana('../pos/reg_descuentos.jsp?mode=add');
}

function edit(id){
	abrir_ventana('../pos/reg_descuentos.jsp?mode=edit&id='+id);
}

function view(id){
	abrir_ventana('../pos/reg_descuentos.jsp?mode=view&tab=1&id='+id);
}

function printList(){
	abrir_ventana('../pos/print_list_descuentos.jsp?appendFilter=<%=issi.admin.IBIZEscapeChars.forURL(sbFilter.toString())%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Descuento ]</a></authtype></td>
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
				Nombre:
				<%=fb.textBox("descripcion", descripcion, false, false, false, 50, 500, "text12", "", "", "", false, "", "")%>
				Estdo:
				<%=fb.select("estado", "A=Activo, I=Inactivo", estado, false, false, 0, "text12", "", "", "", "", "", "", "")%>
				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("descripcion", descripcion)%>
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
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("descripcion", descripcion)%>
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
					<td>C&oacute;digo</td>
					<td>Descripci&oacute;n</td>
					<td>Tipo</td>
					<td>Valor</td>
					<td>Estado</td>
					<td width="3%">&nbsp;</td>
					<td width="3%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td align="center"><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("tipo_desc")%></td>
					<td align="center"><%=cdo.getColValue("valor")%></td>
					<td align="center"><%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					<authtype type='4'>
					<a href="javascript:edit('<%=cdo.getColValue("id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>
					</authtype>
					</td>					<td align="center">
					<authtype type='1'>
					<a href="javascript:view('<%=cdo.getColValue("id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a>
					</authtype>
					</td>
				</tr>
				<%
				}
				%>
			</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
