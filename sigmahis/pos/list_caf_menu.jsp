<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
  int recsPerPage = 200;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

	String tipo = "", estado = "", es_menu_dia = "", precio1 = "", precio3 = "", precio2 = "", codigo = "", descripcion = "", familia = "", tipo_pos = "";
	if(request.getParameter("tipo") != null) tipo = request.getParameter("tipo");
	if(request.getParameter("estado") != null) estado = request.getParameter("estado");
	if(request.getParameter("es_menu_dia") != null) es_menu_dia = request.getParameter("es_menu_dia");
	if(request.getParameter("precio1") != null) precio1 = request.getParameter("precio1");
	if(request.getParameter("precio3") != null) precio3 = request.getParameter("precio3");
	if(request.getParameter("precio2") != null) precio2 = request.getParameter("precio2");
	if(request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("familia") != null) familia = request.getParameter("familia");
	if(request.getParameter("tipo_pos") != null) tipo_pos = request.getParameter("tipo_pos");


	StringBuffer sbSql = new StringBuffer();
	StringBuffer sbFilter = new StringBuffer();

	sbSql.append("select precio4, precio5, precio6, precio7, precio8, tipo, es_menu_dia, id, codigo, descripcion, id_familia, estado, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, nvl(precio1, 0) precio1, nvl(precio2, 0) precio2, nvl(precio3, 0) precio3, decode(tipo, 'D', 'Desayuno', 'A', 'Almuerzo', 'C', 'Cena', 'B', 'Almuerzo y Cena') tipo_desc, decode(es_menu_dia, 'Y', 'Si', 'N', 'No') es_menu_dia_desc, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc from TBL_CAF_MENU where id is not null ");
	sbSql.append(" and compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));

	if(!UserDet.getUserProfile().contains("0")){
		sbFilter.append(" and id_familia in (");
			if(session.getAttribute("_familia")!=null)
				sbFilter.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_familia")));
			else sbFilter.append("-2");
		sbFilter.append(")");
	}

	if(!codigo.equalsIgnoreCase("")){
		sbFilter.append(" and upper(codigo) like '");
		sbFilter.append(codigo);
		sbFilter.append("%'");
	}
	if(!descripcion.equalsIgnoreCase("")){
		sbFilter.append(" and upper(descripcion) like '");
		sbFilter.append(descripcion);
		sbFilter.append("%'");
	}
	if(!es_menu_dia.equalsIgnoreCase("")){
		sbFilter.append(" and upper(es_menu_dia) like '");
		sbFilter.append(es_menu_dia);
		sbFilter.append("%'");
	}
	if(!estado.equalsIgnoreCase("")){
		sbFilter.append(" and upper(estado) like '");
		sbFilter.append(estado);
		sbFilter.append("%'");
	}
	if(!precio1.equalsIgnoreCase("")){
		sbFilter.append(" and precio1 = ");
		sbFilter.append(precio1);
	}
	if(!precio2.equalsIgnoreCase("")){
		sbFilter.append(" and precio2 = ");
		sbFilter.append(precio2);
	}
	if(!familia.equalsIgnoreCase("")){
		sbFilter.append(" and id_familia = ");
		sbFilter.append(familia);
	}
	if(!precio3.equalsIgnoreCase("")){
		sbFilter.append(" and precio3 = ");
		sbFilter.append(precio3);
	}
	if(!tipo.equalsIgnoreCase("")){
		sbFilter.append(" and upper(tipo) like '");
		sbFilter.append(tipo);
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
document.title = 'Creación de Formularios - '+document.title;
function add(){
	abrir_ventana('../pos/reg_caf_menu.jsp?mode=add&tipo_pos=<%=tipo_pos%>');
}
function edit(id){
	abrir_ventana('../pos/reg_caf_menu.jsp?mode=edit&tipo_pos=<%=tipo_pos%>&id='+id);
}
function printListMenu(){
	abrir_ventana('../pos/print_list_menu.jsp?appendFilter=<%=issi.admin.IBIZEscapeChars.forURL(sbFilter.toString())%>&tipo_pos=<%=tipo_pos%>');
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
    <td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo ]</a></authtype>
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
					<%=fb.hidden("tipo_pos", tipo_pos)%>
					<td>
					Familia:
					<%
					sbSql= new StringBuffer();
					if(!UserDet.getUserProfile().contains("0")){
						sbSql.append(" and cod_flia in (");
							if(session.getAttribute("_familia")!=null)
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_familia")));
							else sbSql.append("-2");
						sbSql.append(")");
					}
					%>
					<%=fb.select(ConMgr.getConnection(),"select cod_flia, nombre from tbl_inv_familia_articulo where compania = "+(String) session.getAttribute("_companyId")+sbSql.toString()+" order by nombre","familia",familia,false,false,0, "text10", "", "", "", "T")%>
					C&oacute;digo:
					<%=fb.textBox("codigo", codigo, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					Descripci&oacute;n:
					<%=fb.textBox("descripcion", descripcion, false, false, false, 50, 200, "text12", "", "", "", false, "", "")%>
					<%if(tipo_pos.equals("CAF")){%>
					Es men&uacute; del d&iacute;a:
					<%=fb.select("es_menu_dia", "Y=Si,N=No", es_menu_dia, false, false, 0, "text12", "", "", "", "T", "", "", "")%>
					Tipo:
					<%=fb.select("tipo", "D=Desayuno,A=Almuerzo,C=Cena,B=Almuerzo y Cena", tipo, false, false, 0, "text12", "", "", "", "T", "", "", "")%>
					<%}%>
					Estado
					<%=fb.select("estado", "A=Activo,I=Inactivo", estado, false, false, 0, "text12", "", "", "", "T", "", "", "")%>

					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printListMenu()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("es_menu_dia", es_menu_dia)%>
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("precio1", precio1)%>
					<%=fb.hidden("precio2", precio2)%>
					<%=fb.hidden("precio3", precio3)%>
					<%=fb.hidden("tipo", tipo)%>
					<%=fb.hidden("familia", familia)%>
					<%=fb.hidden("tipo_pos", tipo_pos)%>
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
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("es_menu_dia", es_menu_dia)%>
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("precio1", precio1)%>
					<%=fb.hidden("precio2", precio2)%>
					<%=fb.hidden("precio3", precio3)%>
					<%=fb.hidden("tipo", tipo)%>
					<%=fb.hidden("familia", familia)%>
					<%=fb.hidden("tipo_pos", tipo_pos)%>
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
					<td width="6%">C&oacute;digo</td>
					<td width="20%">Descripci&oacute;n</td>
					<td width="8%">Fecha Crea.</td>
					<%if(tipo_pos.equals("CAF")){%>
					<td width="9%">Tipo</td>
					<td width="5%">Es men&uacute; del d&iacute;a</td>
					<%}%>
					<td width="7%">Estado</td>
					<td width="10%">Precio Normal</td>
					<td width="10%">Precio Ejecutivo</td>
					<td width="10%">Precio Colaborador</td>
					<td width="10%">Usuario Crea.</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="left"><%=cdo.getColValue("codigo")%></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
					<%if(tipo_pos.equals("CAF")){%>
					<td align="left"><%=cdo.getColValue("tipo_desc")%></td>
					<td align="center"><%=cdo.getColValue("es_menu_dia_desc")%></td>
					<%}%>
					<td align="center"><%=cdo.getColValue("estado_desc")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio1"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio2"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio3"))%></td>
					<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Editar</a></authtype></td>
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
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("es_menu_dia", es_menu_dia)%>
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("precio1", precio1)%>
					<%=fb.hidden("precio2", precio2)%>
					<%=fb.hidden("precio3", precio3)%>
					<%=fb.hidden("tipo", tipo)%>
					<%=fb.hidden("familia", familia)%>
					<%=fb.hidden("tipo_pos", tipo_pos)%>
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
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("es_menu_dia", es_menu_dia)%>
					<%=fb.hidden("estado", estado)%>
					<%=fb.hidden("precio1", precio1)%>
					<%=fb.hidden("precio2", precio2)%>
					<%=fb.hidden("precio3", precio3)%>
					<%=fb.hidden("tipo", tipo)%>
					<%=fb.hidden("familia", familia)%>
					<%=fb.hidden("tipo_pos", tipo_pos)%>
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
