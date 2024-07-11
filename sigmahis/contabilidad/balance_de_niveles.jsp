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
<jsp:useBean id="_companyId" scope="session" class="java.lang.String" />
<%
/*
==========================================================================================
fg = RE --> registro y edicion de cuentas.
fg = CS --> Consulta de movimiento de Cuentas.
==========================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlAll = new StringBuffer();
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String filtrado_por = request.getParameter("filtrado_por");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
int nivel = 1;
if(request.getParameter("nivel")!=null) nivel = Integer.parseInt(request.getParameter("nivel"));
if(fg == null) fg = "RE";
if(filtrado_por == null) filtrado_por = "M";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta, to_char(sysdate,'mm') mes, to_char(sysdate,'yyyy') anio from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
	if(mes == null) mes = cdoF.getColValue("mes");
	if(anio == null) anio = cdoF.getColValue("anio");
  int recsPerPage = 1000;
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
	
	String descripcion = "",num_cuenta="";

  sbSql.append("select a.*, getsaldoinicial(a.compania, a.anio, a.mes, a.dsp_cuenta) saldo_inicial from (select a.compania, a.nivel, cuentas as ctaFinanciera, a.descripcion, num_cuenta dsp_cuenta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.lado_movim, nvl(sum(b.debito), 0) debito, nvl(sum(b.credito), 0) credito,");
	if(filtrado_por.equals("M")){
	sbSql.append(anio);
	sbSql.append(" anio, ");
	sbSql.append(mes);
	sbSql.append(" mes");
	} else {
	sbSql.append(" to_number(to_char(to_date('");
	sbSql.append(fecha_desde);
	sbSql.append("','dd/mm/yyyy'),'yyyy')) anio, to_number(to_char(to_date('");
	sbSql.append(fecha_desde);
	sbSql.append("','dd/mm/yyyy'), 'mm')) mes");
	}
	
	sbSql.append(" from vw_con_catalogo_gral a, (select cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 cuenta, a.fecha_comp, decode(b.tipo_mov, 'DB', valor, 0) debito, decode(b.tipo_mov, 'CR', valor, 0) credito from tbl_con_encab_comprob a, tbl_con_detalle_comprob b where a.consecutivo = b.consecutivo and a.ea_ano = b.ano and a.compania = b.compania and a.tipo=b.tipo and a.reg_type =b.reg_type and a.status = 'AP' and a.estado = 'A' and a.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	if(filtrado_por.equals("M")){
	sbSql.append(" and a.ea_ano = ");
	sbSql.append(anio);
	sbSql.append(" and a.mes = ");
	sbSql.append(mes);
	} else {
	sbSql.append(" and trunc(a.fecha_comp) between to_date('");
	sbSql.append(fecha_desde);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_hasta);
	sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(") b where a.compania=");
	sbSql.append((String) session.getAttribute("_companyId"));
  if (request.getParameter("num_cuenta") != null && !request.getParameter("num_cuenta").trim().equals(""))
  {
		sbSql.append(" and a.num_cuenta like '");
		sbSql.append(request.getParameter("num_cuenta").toUpperCase());
		sbSql.append("%'");
    num_cuenta = request.getParameter("num_cuenta");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
		sbSql.append(" and upper(a.descripcion) like '%");
		sbSql.append(request.getParameter("descripcion").toUpperCase());
		sbSql.append("%'");
    descripcion = request.getParameter("descripcion");
  }

	sbSql.append(" and nivel <= ");
	sbSql.append(nivel);	
	sbSql.append(" and b.cuenta(+) like a.num_cuenta || '%' group by a.compania, a.nivel, a.cuentas, a.descripcion, a.num_cuenta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.lado_movim order by a.num_cuenta) a");
	//sql = "SELECT a.nivel, cuentas as ctaFinanciera, cta1, cta2, cta3, cta4, cta5, cta6, a.descripcion, compania, lado_movim, recibe_mov, a.status, num_cuenta dsp_cuenta, balance from vw_con_catalogo_gral_bal a where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by cuentas";
  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");

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
document.title = 'Cuenta Principal - '+document.title;

function printList()
{	
	abrir_ventana('print_list_catalogo_general.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function mayorGeneral(cta1, cta2, cta3, cta4, cta5, cta6, num_cta)
{	
	abrir_ventana('../contabilidad/ver_mayor.jsp?cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&num_cta='+num_cta+'&anio=<%=anio%>&mes=<%=mes%>&filtrado_por=<%=filtrado_por%>');
}
function printRpt(){
  var pCtrlHeader = document.getElementById("ctrlHeader").checked;
  var pDesc = (document.getElementById("descripcion").value==""?"0":document.getElementById("descripcion").value.trim());
  var pNumCta = (document.getElementById("num_cuenta").value==""?"0":document.getElementById("num_cuenta").value.trim());
  var pNivel = document.getElementById("nivel").value;
  var pFiltradoPor  = document.getElementById("filtrado_por").value;
  var pAnio  = document.getElementById("anio").value;
  var pMonthCode  = document.getElementById("mes").value;
  var fd = document.getElementById("fecha_desde").value.split("/");
  var fh = document.getElementById("fecha_hasta").value.split("/");
  var fDesde = fd[2]+"-"+fd[1]+"-"+fd[0];
  var fHasta = fh[2]+"-"+fh[1]+"-"+fh[0];
  abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_balance_de_desniveles.rptdesign&pCtrlHeader="+pCtrlHeader+"&pDesc="+pDesc+"&pNumCta="+pNumCta+"&pNivel="+pNivel+"&pFiltradoPor="+pFiltradoPor+"&pAnio="+pAnio+"&pMonthCode="+pMonthCode+"&fDesde="+fDesde+"&fHasta="+fHasta);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr class="TextFilter">
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="10">
        <tr class="TextFilter">
			  <%
						  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
						%>
			  <%=fb.formStart()%> 
						<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
						<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
						<%=fb.hidden("fg",fg)%>
			  <td> 
			      Cta: <%=fb.textBox("num_cuenta",num_cuenta,false,false,false,20,"Text10",null,"")%> &nbsp;&nbsp;
			      Desc. <%=fb.textBox("descripcion",descripcion,false,false,false,40,"Text10",null,"")%> &nbsp;&nbsp;
			      Hasta Nivel: <%=fb.select("nivel","1=1,2=2,3=3,4=4,5=5,6=6",""+nivel,false,false,0,"Text10",null,"")%>&nbsp;&nbsp;
			      Filtro por: <%=fb.select("filtrado_por","M=AÑO/MES,RF=RANGO FECHA",filtrado_por,false,false,0,"Text10",null,"")%>&nbsp;&nbsp;
			      A&ntilde;o: <%=fb.textBox("anio",anio,false,false,false,4,"Text10",null,"")%> 
			  </td>
		  </tr>
		  <tr class="TextFilter">
			  <td> Mes: <%=fb.select("mes","01=Ene,02=Feb,03=Mar,04=Abr,05=May,06=Jun,07=Jul,08=Ago,09=Sep,10=Oct,11=Nov,12=Dic",mes,false,false,0,"Text10",null,"")%>&nbsp;&nbsp;
			  Fecha: 
			  <jsp:include page="../common/calendar.jsp" flush="true">
			  <jsp:param name="noOfDateTBox" value="2" />
			  <jsp:param name="clearOption" value="true" />
			  <jsp:param name="nameOfTBox1" value="fecha_desde" />
			  <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
			  <jsp:param name="nameOfTBox2" value="fecha_hasta" />
			  <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
			  </jsp:include> &nbsp;&nbsp;&nbsp;&nbsp;<%=fb.submit("go","Ir")%> 
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  <%=fb.button("btpPrint","Excel",false,false,null,null,"onClick=\"printRpt()\"")%>
			  <%=fb.checkbox("ctrlHeader","")%>Sin Cabacera
			  </td>

			  <%=fb.formEnd()%>
			  </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("descripcion",descripcion)%> 
					<%=fb.hidden("num_cuenta",num_cuenta)%> 
					<%=fb.hidden("filtrado_por",filtrado_por)%> 
					<%=fb.hidden("nivel",""+nivel)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("descripcion",descripcion)%> 
					<%=fb.hidden("num_cuenta",num_cuenta)%> 
					<%=fb.hidden("filtrado_por",filtrado_por)%> 
					<%=fb.hidden("nivel",""+nivel)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
          <!--<td width="22%">Clasificacion</td>-->
          <td>C&oacute;digo</td>
          <td>Descripci&oacute;n</td>
          <td>Lado Movimiento</td>
          <td>Saldo Inicial</td>
          <td>D&eacute;bito</td>
          <td>Cr&eacute;dito</td>
          <td>Saldo Final</td>
          <%//for(int i=1;i<=nivel;i++){%>
          <!--<td>Nivel <%//=i%></td>-->
          <%//}%>
        </tr>
        <%
				Double saldo_final = 0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 saldo_final = Double.parseDouble(cdo.getColValue("saldo_inicial"))+Double.parseDouble(cdo.getColValue("debito"))-Double.parseDouble(cdo.getColValue("credito"));
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="left">&nbsp;&nbsp;&nbsp; <a href="javascript:mayorGeneral('<%=cdo.getColValue("cta1")%>','<%=cdo.getColValue("cta2")%>','<%=cdo.getColValue("cta3")%>','<%=cdo.getColValue("cta4")%>','<%=cdo.getColValue("cta5")%>','<%=cdo.getColValue("cta6")%>','<%=cdo.getColValue("dsp_cuenta")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("dsp_cuenta")%></a></td>
          <td><%=cdo.getColValue("descripcion")%></td>
          <td align="center"><%=cdo.getColValue("lado_movim")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <%//for(int j=1;j<=nivel;j++){%>
          <!--<td align="right"><%//=cdo.getColValue("nivel").equals((""+j))?CmnMgr.getFormattedDecimal(cdo.getColValue("balance")):""%>&nbsp;&nbsp;&nbsp;</td>-->
          <%//}%>
					<td align="right"><%=CmnMgr.getFormattedDecimal(saldo_final)%>&nbsp;&nbsp;&nbsp;</td>
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
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("descripcion",descripcion)%> 
					<%=fb.hidden("num_cuenta",num_cuenta)%> 
					<%=fb.hidden("filtrado_por",filtrado_por)%> 
					<%=fb.hidden("nivel",""+nivel)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("descripcion",descripcion)%> 
					<%=fb.hidden("num_cuenta",num_cuenta)%> 
					<%=fb.hidden("filtrado_por",filtrado_por)%> 
					<%=fb.hidden("nivel",""+nivel)%> 
					<%=fb.hidden("anio",anio)%> 
					<%=fb.hidden("mes",mes)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
