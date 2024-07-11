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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String fecha = request.getParameter("fecha");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    codigo = request.getParameter("codigo");
    appendFilter += " and upper(to_char(a.codigo)) like '"+request.getParameter("codigo")+"%'";
  }
  if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
  {
    fecha = request.getParameter("fecha");
    appendFilter += " and to_date(to_char(a.fecha,'DD/MM/YYYY'),'DD/MM/YYYY') = '"+request.getParameter("fecha")+"'";
  }
 /* else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
	}
  else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
  }*/

sql="select a.codigo,a.referencia,nvl(a.explicacion,'')as explicacion,a.total,to_char(a.fecha,'dd/mm/yyyy')as fecha , a.fecha fechaReg, a.recibo,  to_char(f.fecha_nacimiento,'dd-mm-yyyy') as fecha_nacimiento , f.paciente/*, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente*/ from tbl_fac_nota_ajuste a, tbl_fac_det_nota_ajuste f/*,tbl_adm_paciente b*/ where a.tipo_ajuste=59 and a.referencia=99 and f.compania = a.compania and f.nota_ajuste = a.codigo and f.lado_mov='D' and a.ref_reversion is null /*and b.codigo=f.paciente and to_date(to_char(b.fecha_nacimiento,'DD-MM-YYYY'),'DD-MM-YYYY') =  to_date(to_char(f.fecha_nacimiento,'DD-MM-YYYY'),'DD-MM-YYYY')*/ and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha desc ";
al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Listado de Ajustes- '+document.title;

function add()
{
	//abrir_ventana('../caja/registro_faltantes.jsp');
}

function edit(id,com)
{
	//abrir_ventana('../caja/registro_faltantes.jsp?mode=edit&consecutivo='+id+'&compania='+com);
}
function Revert(monto,k)
{


}

function Revertir(k)
{
if(confirm('¿Esta seguro de Realizar la Reversión de este Ajuste?'))
{
var t_monto = parseFloat(prompt("Monto Revertir:",""+eval('document.revertirMonto.monto'+k).value));
if(parseFloat(t_monto)) {
if(t_monto!="" && t_monto !="0")
{
var compania= '<%=(String) session.getAttribute("_companyId")%>';
var num_recibo = eval('document.revertirMonto.recibo'+k).value;
var codigo = eval('document.revertirMonto.codigo'+k).value;
var p_fecha_nacimiento=eval('document.revertirMonto.fecha_nacimiento'+k).value;
var p_codigo_paciente=eval('document.revertirMonto.paciente'+k).value;

		if(executeDB('<%=request.getContextPath()%>','call cja_revertir_ajuste(\''+compania+'\',\''+codigo+'\',\''+num_recibo+'\','+t_monto+',\''+p_fecha_nacimiento+'\',\''+p_codigo_paciente+'\',1,1)',''))
		{
			alert('Monto Revertido Correctamente');
			window.document.location.reload(true);
		}else alert('El Monto no ha Podido ser Revertido!');
}
}else alert('Monto a revertir Invalido');
}else alert('Reversión Cancelada');
}
function printList()
{
	//abrir_ventana('../caja/print_list_faltantes.jsp?appendFilter=<%//=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="LISTADO DE AJUSTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">&nbsp;
        <%
         // if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
        %>
   	    <%
		 //}
	    %>
</td>
</tr>
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<tr class="TextFilter">
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

	<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>
		<%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
	</td>
	<td width="50%"><cellbytelabel>Fecha Movimiento</cellbytelabel>
	<jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="fecha" />
												<jsp:param name="valueOfTBox1" value="" />
												</jsp:include><%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
		<%
          //if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
		%>
		  <a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
        <%
    //      }
        %>
		</td>
    </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
							<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
							<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
							<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
							<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>

							<%=fb.hidden("codigo",codigo)%>
							<%=fb.hidden("fecha",fecha)%>

							<%=fb.hidden("searchOn",searchOn)%>
							<%=fb.hidden("searchVal",searchVal)%>
							<%=fb.hidden("searchValFromDate",searchValFromDate)%>
							<%=fb.hidden("searchValToDate",searchValToDate)%>
							<%=fb.hidden("searchType",searchType)%>
							<%=fb.hidden("searchDisp",searchDisp)%>
							<%=fb.hidden("searchQuery","sQ")%>
							<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
						<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
						<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
						<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
						<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>

						<%=fb.hidden("codigo",codigo)%>
						<%=fb.hidden("fecha",fecha)%>

						<%=fb.hidden("searchOn",searchOn)%>
						<%=fb.hidden("searchVal",searchVal)%>
						<%=fb.hidden("searchValFromDate",searchValFromDate)%>
						<%=fb.hidden("searchValToDate",searchValToDate)%>
						<%=fb.hidden("searchType",searchType)%>
						<%=fb.hidden("searchDisp",searchDisp)%>
						<%=fb.hidden("searchQuery","sQ")%>
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
<%fb = new FormBean("revertirMonto",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr class="TextHeader">
<td width="5%" align="center"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
<td width="10%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
<td width="40%"><cellbytelabel>Explicación</cellbytelabel></td>
<td width="10%"><cellbytelabel>Recibo</cellbytelabel></td>
<td width="15%"><cellbytelabel>Referencia</cellbytelabel></td>
<td width="10%" align="right"><cellbytelabel>Monto</cellbytelabel></td>
<td width="10%">&nbsp;</td>
</tr>
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>

<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("paciente"+i,cdo.getColValue("paciente"))%>
<%=fb.hidden("monto"+i,cdo.getColValue("total"))%>
<%=fb.hidden("recibo"+i,cdo.getColValue("recibo"))%>
<%=fb.hidden("t_monto"+i,"")%>

<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=cdo.getColValue("codigo")%></td>
<td align="center"><%=cdo.getColValue("fecha")%></td>
<td><%=cdo.getColValue("explicacion")%></td>
<td><%=cdo.getColValue("recibo")%></td>
<td><%=cdo.getColValue("referencia")%></td>
<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%></td>
<td align="center">&nbsp;

<%=fb.button("addTurno","Reversion",true,false,null,null,"onClick=\"javascript:Revertir("+i+")\"","Revertir Ajuste")%>
<%
//	if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
//{
%>
<!--<a href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("compania")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>--->
<%
//}
%></td>
</tr>
<% } %>
</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	<%=fb.formEnd()%>
</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
						<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
						<%=fb.formStart()%>
							<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
									<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
									<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
									<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>

									<%=fb.hidden("codigo",codigo)%>
									<%=fb.hidden("fecha",fecha)%>

									<%=fb.hidden("searchOn",searchOn)%>
									<%=fb.hidden("searchVal",searchVal)%>
									<%=fb.hidden("searchValFromDate",searchValFromDate)%>
									<%=fb.hidden("searchValToDate",searchValToDate)%>
									<%=fb.hidden("searchType",searchType)%>
									<%=fb.hidden("searchDisp",searchDisp)%>
									<%=fb.hidden("searchQuery","sQ")%>
									<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
		 			 <%=fb.formEnd()%>

					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>

					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
							<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
							<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
							<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
							<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>

							<%=fb.hidden("codigo",codigo)%>
							<%=fb.hidden("fecha",fecha)%>

							<%=fb.hidden("searchOn",searchOn)%>
							<%=fb.hidden("searchVal",searchVal)%>
							<%=fb.hidden("searchValFromDate",searchValFromDate)%>
							<%=fb.hidden("searchValToDate",searchValToDate)%>
							<%=fb.hidden("searchType",searchType)%>
							<%=fb.hidden("searchDisp",searchDisp)%>
							<%=fb.hidden("searchQuery","sQ")%>
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