<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Delivery"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

ArrayList al = new ArrayList();
ArrayList alUnd = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String wh = request.getParameter("wh");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fp==null) fp = "";
if(fg==null) fg = "UA";
String popWinFunction = "abrir_ventana";
if(fp.trim().equals("EA")) popWinFunction = "abrir_ventana2";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

/*====================================================================================*/
/*====================================================================================*/
/*  fg = TIPO DE ENTREGA  */
/*
  fg = UA - Materiales y Equipos para Unidades Administrativas
*/
/*====================================================================================*/

String entrega = "", fechaini ="",anio="",fechafin="",unidad="";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_sec_unidad_ejec where nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  )) /*  and codigo <100 */ and compania=");
sbSql.append(session.getAttribute("_companyId"));


/*  se omite el join  **and codigo in(**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

/*
if(!UserDet.getUserProfile().contains("0")){
	if(session.getAttribute("_ua")!=null){
	sbSql.append(" and codigo in (");
	sbSql.append(CmnMgr.vector2numSqlInClause((Vector)session.getAttribute("_ua")));
	sbSql.append(")");}
	else sbSql.append(" and codigo in (-1)");
}

*/
sbSql.append(" order by descripcion,codigo");
alUnd = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(), CommonDataObject.class);

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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
  if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
  {
    appendFilter += " and a.anio ="+request.getParameter("anio");
	anio=request.getParameter("anio");
  }
  if (request.getParameter("entrega") != null && !request.getParameter("entrega").trim().equals(""))
  {
	appendFilter += " and a.no_entrega = "+request.getParameter("entrega");
	entrega = request.getParameter("entrega");
  }
  if (request.getParameter("fechaini") != null && !request.getParameter("fechaini").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha_entrega) >= to_date('"+request.getParameter("fechaini")+"','dd/mm/yyyy')";
	fechaini = request.getParameter("fechaini");
  }
   if (request.getParameter("fechafin") != null && !request.getParameter("fechafin").trim().equals(""))
  {
    appendFilter += " and trunc(a.fecha_entrega) <= to_date('"+request.getParameter("fechafin")+"','dd/mm/yyyy')";
    fechafin = request.getParameter("fechafin");
  }
  if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals(""))
  {
    appendFilter += " and a.unidad_administrativa ="+request.getParameter("unidad");
    unidad = request.getParameter("unidad");
  }

  if(request.getParameter("unidad") != null)
  {
  	sql = "select distinct a.anio, a.no_entrega as noEntrega,a.compania,a.observaciones, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, a.unidad_administrativa as unidadAdministrativa, a.req_anio as reqAnio, a.req_tipo_solicitud as reqTipoSolicitud, decode(a.req_tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') as reqTipoSolicitudDesc, a.req_solicitud_no as reqSolicitudNo, a.codigo_almacen as codigoAlmacen,c.descripcion as unidadAdminDesc  from tbl_inv_entrega_material a, tbl_sec_unidad_ejec c,tbl_inv_detalle_entrega b where a.pac_anio is null and a.pac_solicitud_no is null  and a.unidad_administrativa=c.codigo(+) and  a.compania_sol = c.compania and a.compania_sol="+(String) session.getAttribute("_companyId")+appendFilter+" and a.anio = b.anio and a.no_entrega = b.no_entrega and a.compania = b.compania and   b.pi_anio is null and b.pi_tipo_inv is null and b.pi_compania is null and b.pi_codigo_ue is null and b.pi_consec is null and b.cod_familia in ( select param_value from tbl_sec_comp_param where  compania in(-1,a.compania) and param_name='FLIA_ACTIVO') order by a.codigo_almacen asc, a.anio desc,a.no_entrega desc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  //al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Delivery.class);
  rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
  }


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
document.title = 'Inventario - Entrega - '+document.title;
function view(anio, no){<%=popWinFunction%>('../inventario/vw_delivery.jsp?fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&no='+no);}
function showReq(anio,id,wh,tipo){<%=popWinFunction%>('../inventario/print_requisiciones_unidades_adm.jsp?fg=UA&tr=RQ&fp=<%=fp%>&anio='+anio+'&cod_req='+id+'&tipo='+tipo);}
function edit(anio, no,unidad){<%=popWinFunction%>('../presupuesto/reg_detalle_entrega.jsp?fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&no='+no+'&unidad='+unidad);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%if(!fp.trim().equals("EA")){%>
<%@ include file="../common/menu_base.jsp"%>
<%}%>
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="INVENTARIO - TRANSACCIONES - ENTREGAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td colspan="4" align="right">&nbsp;</td>
  </tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
    <%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
      <%=fb.formStart()%>
      <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
      <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
      <%=fb.hidden("fg",fg)%>
	  <%=fb.hidden("fp",fp)%>
   	<tr class="TextFilter">
	   	<td width="10%"><cellbytelabel>A&ntilde;o</cellbytelabel> <%=fb.textBox("anio","",false,false,false,6,null,null,null)%></td>
		<td width="10%"><cellbytelabel>Entrega</cellbytelabel> <%=fb.textBox("entrega","",false,false,false,6,null,null,null)%></td>
		<td width="30%"><cellbytelabel>Fecha</cellbytelabel>:&nbsp;
	    	<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaini" />
				<jsp:param name="valueOfTBox1" value="" />
				<jsp:param name="nameOfTBox2" value="fechafin" />
				<jsp:param name="valueOfTBox2" value="" />
			</jsp:include>
		</td>
		<td width="50%"><cellbytelabel>Unidad</cellbytelabel>:<%=fb.select("unidad",alUnd,unidad,"S")%><%=fb.submit("go","Ir")%></td>
   </tr>

  <%=fb.formEnd()%>

<!------>
  <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
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
        <%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("unidad",unidad)%>
		<%=fb.hidden("fechaini",fechaini)%>
		<%=fb.hidden("fechafin",fechafin)%>
		<%=fb.hidden("entrega",entrega)%>
		<%=fb.hidden("anio",anio)%>

	 	 <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
          <%=fb.hidden("fg",fg)%>
		  <%=fb.hidden("fp",fp)%>
		  <%=fb.hidden("unidad",unidad)%>
		  <%=fb.hidden("fechaini",fechaini)%>
		  <%=fb.hidden("fechafin",fechafin)%>
		  <%=fb.hidden("entrega",entrega)%>
		  <%=fb.hidden("anio",anio)%>          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("unidad",unidad)%>
	    <%=fb.hidden("fechaini",fechaini)%>
	    <%=fb.hidden("fechafin",fechafin)%>
	    <%=fb.hidden("entrega",entrega)%>
	    <%=fb.hidden("anio",anio)%>
		<%=fb.hidden("baction","")%>


<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow02">
          <td align="right" colspan="10"><authtype type='51'><%=fb.submit("save","Guardar",true,((al.size() >0)?false:true),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		</tr>

  <tr class="TextHeader02" align="center">
    <td colspan="10"><cellbytelabel>E N T R E  G A      D E      A C T I V O S</cellbytelabel></td>
  </tr>
  <tr class="TextHeader" align="center">
  	<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
    <td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
    <td width="5%"><cellbytelabel>No.Entrega</cellbytelabel></td>
    <td width="20%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
    <td width="20%"><cellbytelabel>Observaciones</cellbytelabel></td>
    <td width="10%"><cellbytelabel>A&ntilde;o Req</cellbytelabel>.</td>
    <td width="10%"><cellbytelabel>No.Req</cellbytelabel>.</td>
    <td width="10%"><cellbytelabel>Tipo Req</cellbytelabel>.</td>
	<td width="5%">&nbsp;</td>
	<td width="5%">&nbsp;</td>
  </tr>

  	<% if ((appendFilter == null || appendFilter.trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="10">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="10"> <font color="#FF0000"> <cellbytelabel>I N T R O D U Z C A</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>P A R &Aacute; M E T R O S</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>B &Uacute; S Q U E D A</cellbytelabel></font></td>
		</tr>
		<%}%>


        <%
        for (int i=0; i<al.size(); i++)
        {
          CommonDataObject  cdo = (CommonDataObject) al.get(i);
          String color = "TextRow02";
          if (i % 2 == 0) color = "TextRow01";

          %>

		<%=fb.hidden("noEntrega"+i,cdo.getColValue("noEntrega"))%>
	    <%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>

        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo.getColValue("fechaEntrega")%></td>
          <td align="center"><%=cdo.getColValue("anio")%></td>
          <td align="center"><%=cdo.getColValue("noEntrega")%></td>
		  <td align="center"><%=cdo.getColValue("unidadAdminDesc")%></td>
		  <td align="center"><%=fb.textarea("observaciones"+i,cdo.getColValue("observaciones"),false,false,false,50,2,2000)%></td>
		  <td align="center">
		  <authtype type='2'><a href="javascript:showReq(<%=cdo.getColValue("reqAnio")%>,<%=cdo.getColValue("reqSolicitudNo")%>,'<%=cdo.getColValue("reqCodAlmacen")%>','<%=cdo.getColValue("reqTipoSolicitud")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><%=cdo.getColValue("reqAnio")%></a></authtype> </td>

		  <td align="center"><authtype type='2'><a href="javascript:showReq(<%=cdo.getColValue("reqAnio")%>,<%=cdo.getColValue("reqSolicitudNo")%>,'<%=cdo.getColValue("reqCodAlmacen")%>','<%=cdo.getColValue("reqTipoSolicitud")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><%=cdo.getColValue("reqSolicitudNo")%></a> </authtype></td>

          <td><%=cdo.getColValue("reqTipoSolicitudDesc")%></td>
          <td align="center">
          <authtype type='1'><a href="javascript:view(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("noEntrega")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>

          </td>
		  <td align="center">
          <authtype type='51'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("noEntrega")%>,<%=cdo.getColValue("unidadAdministrativa")%> )" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><cellbytelabel>detalle</cellbytelabel></a></authtype>

          </td>
        </tr>
        <%
        }
        %>
<tr class="TextRow02">
          <td align="right" colspan="10"><authtype type='51'><%=fb.submit("save2","Guardar",true,((al.size() >0)?false:true),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		</tr>
</table>
        <%=fb.formEnd(true)%>

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
        <%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("unidad",unidad)%>
	    <%=fb.hidden("fechaini",fechaini)%>
	    <%=fb.hidden("fechafin",fechafin)%>
	    <%=fb.hidden("entrega",entrega)%>
	    <%=fb.hidden("anio",anio)%>            <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
          <%=fb.hidden("fg",fg)%>
		  <%=fb.hidden("fp",fp)%>
		  <%=fb.hidden("unidad",unidad)%>
	      <%=fb.hidden("fechaini",fechaini)%>
	      <%=fb.hidden("fechafin",fechafin)%>
	      <%=fb.hidden("entrega",entrega)%>
	      <%=fb.hidden("anio",anio)%>            <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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
}//GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
 ArrayList al1= new ArrayList();
 int size =Integer.parseInt(request.getParameter("size"));
 String baction = request.getParameter("baction");


 for(int i=0;i<size;i++)
 {

		if(request.getParameter("observaciones"+i) != null && !request.getParameter("observaciones"+i).trim().equals("")) 	{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_inv_entrega_material");
 			cdo.setWhereClause("anio="+request.getParameter("anio"+i)+" and no_entrega="+request.getParameter("noEntrega"+i)+" and compania="+request.getParameter("compania"+i));

			//cdo.addColValue("anio",request.getParameter("anio"+i));
			//cdo.addColValue("compania",request.getParameter("compania"+i));
			//cdo.addColValue("no_entrega",request.getParameter("noEntrega"+i));
			cdo.addColValue("observaciones",request.getParameter("observaciones"+i));

			cdo.addColValue("fecha_mod",cDateTime);
			cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));

			al1.add(cdo);}

 }

	if(al1.size() == 0)
	{
		 CommonDataObject cdo = new CommonDataObject();
		 cdo.setTableName("tbl_inv_entrega_material");
		 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and no_entrega=-1");
		 al1.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		SQLMgr.updateList(al1);
	}

	ConMgr.clearAppCtx(null);


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_entrega_equipos.jsp"))
	{

%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_entrega_equipos.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/presupuesto/list_entrega_equipos.jsp?fg=<%=fg%>&unidad=<%=unidad%>&anio=<%=anio%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>