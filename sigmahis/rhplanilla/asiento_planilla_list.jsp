<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList newal = new ArrayList();
int rowCount = 0;
String sql = "";
String newsql = "";
String appendFilter = "";
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");
String doc = request.getParameter("anio")+"-"+request.getParameter("cod")+"-"+request.getParameter("num");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	
	String cheque = "";        // variables para mantener el valor de los campos filtrados en la consulta
	String nombre = "";
	String depto  = "";
   
	if (request.getParameter("cheque") != null && !request.getParameter("cheque").trim().equals(""))
	{
	appendFilter += " and d.num_cheque like '%"+request.getParameter("cheque").toUpperCase()+"%' ";
		cheque     = request.getParameter("cheque");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
	appendFilter += " and upper(e.primer_nombre||' '||e.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre    = request.getParameter("nombre");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	if (request.getParameter("depto") != null && !request.getParameter("depto").trim().equals(""))
	{
	appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("depto").toUpperCase()+"%'";
	depto  = request.getParameter("depto");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}
	
sql = "select a.ea_ano, a.consecutivo_comp as consecutivo, a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE') as mes, a.clase_comprob, a.descripcion, nvl(a.total_cr,0) total_cr, nvl(a.total_db,0) total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario, b.tipo_mov, b.cta1||'-'||b.cta2||'-'||b.cta3||'-'||b.cta4||'-'||b.cta5||'-'||b.cta6 cuenta, b.concepto,decode(b.tipo_mov,'CR',nvl(b.valor,0),0) valorCr,decode(b.tipo_mov,'DB',nvl(b.valor,0),0) valorDb,  b.comentario, b.renglon from tbl_pla_pre_encab_comprob a, tbl_pla_pre_detalle_comprob b where a.status!='DE' and a.EA_ANO = b.ANO and a.COMPANIA = b.COMPANIA and a.consecutivo_comp = b.consecutivo and a.clase_comprob <> 99  and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.ea_ano = "+anio+" and a.n_doc = '"+doc+"' order by b.renglon";

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
<script language="javascript">
  document.title = 'Planilla - '+document.title;
  
function reporte(anio,doc){abrir_ventana1('../rhplanilla/print_list_asiento_planilla.jsp?anio='+anio+'&doc='+doc);}
var xHeight=0;
function doAction(){resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - ASIENTO DE PLANILLA "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
		
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("doc",doc)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="6%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="39%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("doc",doc)%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%> </td>
		<td  width="10%" align="right">&nbsp; </td>
		<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
			<tr>
			<td align="right" colspan="6"><authtype type='3'><a href="javascript:reporte('<%=anio%>','<%=doc%>')" class="Link00">[ Imprimir Asiento]</a></authtype></td>
	</tr>

		</table>
	</td>
</tr>


<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ===========   R E S U L T S   S T A R T   H E R E   ============== -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
			<tbody id="list">
		<tr class="TextHeader">
			
			<td width="10%"># Renglón.</td>
			<td width="40%" align="left">Descripci&oacute;n</td>
			<td width="20%" align="left">Cuenta</td>
			<td width="15%" align="right">Debito</td>
			<td width="15%" align="right">Credito</td>
		
		</tr>
<%
String nombrePla = "";
String lado="DB";
String tot_db="";
String tot_cr="";
double tot_dbPag=0.00,tot_crPag=0.00; 
double totalDb=0.00,totalCr=0.00; 

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
		 if (!nombrePla.equalsIgnoreCase(cdo.getColValue("descripcion")))
				 {
				%>
				  
		<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
               <td colspan="5" class="TitulosdeTablas"> <%=cdo.getColValue("descripcion")%></td>
        </tr>
				<%
				   }
				%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="left"><%=cdo.getColValue("renglon")%></td>
			<td><%=cdo.getColValue("comentario")%></td>
			<td><%=cdo.getColValue("cuenta")%></td>
			<td align="right"><%=(!cdo.getColValue("valorDb").trim().equals("0")?CmnMgr.getFormattedDecimal(cdo.getColValue("valorDb")):"")%></td>
			<td align="right"><%=(!cdo.getColValue("valorCr").trim().equals("0")?CmnMgr.getFormattedDecimal(cdo.getColValue("valorCr")):"")%></td>
		</tr>
<%
	nombrePla = cdo.getColValue("descripcion");
	tot_db = cdo.getColValue("total_db");
	tot_cr = cdo.getColValue("total_cr");
	tot_dbPag += Double.parseDouble(cdo.getColValue("valorDb"));
	tot_crPag += Double.parseDouble(cdo.getColValue("valorCr"));
	totalDb += Double.parseDouble(cdo.getColValue("valorDb"));
	totalCr += Double.parseDouble(cdo.getColValue("valorCr"));


}
%>

 </tbody>
		</table>
		</div>
	</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		
		<tr class="TextHeader">
			<td colspan="3" align="center">TOTALES POR PAGINA</td>
			<td width="15%" align="right">Total Débito</td>
			<td width="15%" align="right">Total Crédito</td>
			
		</tr>
<%
	String color1 = "TextRow02";
%>
		<tr class="<%=color1%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color1%>')">
			<td colspan="3" align="left">&nbsp;</td>
			<td align="right"><%=(tot_dbPag!=0.00?CmnMgr.getFormattedDecimal(tot_dbPag):"0")%></td>
			<td align="right"><%=(tot_crPag!=0.00?CmnMgr.getFormattedDecimal(tot_crPag):"0")%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="3" align="center">TOTALES FINAL POR PLANILLA</td>
			<td width="15%" align="right">&nbsp;</td>
			<td width="15%" align="right">&nbsp;</td>
		</tr>
		<tr class="<%=color1%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color1%>')">
			<td colspan="3" align="left">&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(Double.parseDouble(tot_db))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(Double.parseDouble(tot_cr))%></td>
		</tr>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("doc",doc)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="35%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<%=fb.hidden("doc",doc)%>
			<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
			<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
			<%=fb.hidden("searchOn",searchOn)%>
			<%=fb.hidden("searchVal",searchVal)%>
			<%=fb.hidden("searchValFromDate",searchValFromDate)%>
			<%=fb.hidden("searchValToDate",searchValToDate)%>
			<%=fb.hidden("searchType",searchType)%>
			<%=fb.hidden("searchDisp",searchDisp)%>
			<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<td  width="10%" align="right">&nbsp; </td>
			<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
			
			
		</table>
	</td>
</tr>
</table>
</html>
</body>
<%
}//POST
%>
