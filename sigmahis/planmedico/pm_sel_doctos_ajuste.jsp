<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vClt" scope="session" class="java.util.Vector"/>
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql =new StringBuffer();
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String id = request.getParameter("id");
String change = request.getParameter("change");
String tipo_trx = request.getParameter("tipo_trx");
String tipo_aju = request.getParameter("tipo_aju");
String id_solicitud = request.getParameter("id_solicitud");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String cDateTime = CmnMgr.getCurrentDate("mm/yyyy");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(id==null) id = "";


if(id_solicitud==null) id_solicitud = "";
if(anio==null) anio = "";
if(mes==null) mes = "";
if(fg==null) fg = "";
if(fp==null) fp = "";
if(id==null) id = "0";
if(tipo_aju==null) tipo_aju = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
	cdo.addColValue("mes", mes);
	cdo.addColValue("anio", anio);
	cdo.addColValue("id", id);
	cdo.addColValue("tipo_trx", tipo_trx);
	if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){
		sbSql.append("select a.*, to_char(to_date(a.mes, 'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes_desc, round((saldo_sin_desc-nvl(descuento, 0)), 2) saldo, nvl(b.descuento, 0) descuento from (select id_sol_contrato, anio, mes, sum((monto)) monto, sum(nvl(monto_apl_regtran, 0)) monto_apl, sum((monto)- (case when nvl(cancela_saldo_ini, 'N') = 'S' then monto else NVL (monto_apl_regtran, 0) end)) saldo_sin_desc, numero_factura id_ref, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion from tbl_pm_factura f where estado = 'A' and id_sol_contrato = ");
		sbSql.append(id_solicitud);
		sbSql.append(" and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" /*and not exists (select null from tbl_pm_ajuste_det a where a.id_ref = f.numero_factura  and a.estado = 'A' and exists (select null from tbl_pm_ajuste aj where aj.id = a.id and aj.compania = a.compania and aj.id_solicitud = ");
		sbSql.append(id_solicitud);
		sbSql.append(" and aj.estado = 'A'))*/ group by id_sol_contrato, anio, mes, numero_factura, to_char(fecha_creacion, 'dd/mm/yyyy') /*having sum(monto)>sum(monto_apl_regtran)*/) a, (select id_solicitud, d.id_ref, sum(decode(a.tipo_aju, 5, -monto, monto)) descuento from tbl_pm_ajuste a, tbl_pm_ajuste_det d where a.compania = d.compania and a.id = d.id and a.tipo_aju in (1, 3, 5) and a.tipo_ben = 1 and a.estado = 'A' and d.estado = 'A' and a.id_solicitud = ");
		sbSql.append(id_solicitud);
		sbSql.append(" and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" group by id_solicitud, d.id_ref) b where a.id_sol_contrato = b.id_solicitud(+) and a.id_ref = b.id_ref(+) /*and a.saldo_sin_desc - nvl(b.descuento, 0) > 0*/");
	} else if(fg.equals("cxc") && tipo_aju.equals("2")){
		sbSql.append("select b.id_contrato id_sol_contrato, a.id id_ref, a.anio, a.mes, b.monto_app saldo, TO_CHAR (TO_DATE (a.mes, 'mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') mes_desc, a.tipo_trx, decode(a.tipo_trx, 'M', 'MANUAL', 'ACH', 'ACH', 'TC', 'TARJETA CREDITO') tipo_trx_desc, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion from tbl_pm_regtran a, tbl_pm_regtran_det b where a.id = b.id and a.compania = b.compania and a.estado = 'A' and b.estado = 'A' and a.tipo_trx in ('ACH', 'TC', 'M') and b.id_contrato = ");
		sbSql.append(id_solicitud);
		sbSql.append(" and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
	}
	if(!anio.equals("")){sbSql.append(" and anio = ");sbSql.append(anio);
	if(!mes.equals("")){sbSql.append(" and mes = ");sbSql.append(mes);}
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	}

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
document.title = 'Cuentas x Pagar- '+document.title;
var xHeight=0;
function doAction(){}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="HONORARIOS MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="1" cellspacing="0"  id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>

	<tr>
		<td>
		<table width="100%" cellpadding="1" cellspacing="0">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td colspan="6" align="right"><authtype type='2'><!--<a href="javascript:printReport()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a>--></authtype>
					</td>
				</tr>
				<%fb = new FormBean("form_docto",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%//=fb.hidden("mes",mes)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<%=fb.hidden("tipo_aju",tipo_aju)%>
				<%=fb.hidden("id_solicitud",id_solicitud)%>
				<tr class="TextFilter">
					<td>
					A&ntilde;o: 
					<%=fb.textBox("anio",anio,true,false,(mode.equals("edit")),5,4,"Text12","","")%>
					Mes: <%=fb.select("mes","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",mes,false,false,false,0,"Text12","","")%>
					<%=fb.submit("go","Ir")%>
					</td>
				</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
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
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("tipo_trx",tipo_trx)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("tipo_trx",tipo_trx)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>

<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String onSubmit = "";
fb = new FormBean("detail","","post",onSubmit);
%>
	<%=fb.formStart()%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("mode",mode)%>
      <tr>
        <td align="right" colspan="7"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
      </tr>
			<tr class="TextHeader" >
				<td align="center" width="10%"><cellbytelabel>Contrato</cellbytelabel></td>
				<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
				<td align="center" width="10%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
				<td align="center" width="30%"><cellbytelabel>Mes</cellbytelabel></td>
				<td align="center" width="40%"><cellbytelabel>No. Factura</cellbytelabel></td>
				<%} else if(fg.equals("cxc") && tipo_aju.equals("2")){%>
				<td align="center" width="10%"><cellbytelabel>No. TRX</cellbytelabel></td>
				<td align="center" width="30%"><cellbytelabel>Tipo TRX</cellbytelabel></td>
				<td align="center" width="40%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
				<%} %>
				<td align="center" width="18%"><cellbytelabel>Saldo</cellbytelabel></td>
				<td align="center" width="2%"><%=fb.checkbox("generar","", false, false, "", "", "onClick=\"javascript:setAll();\"")%></td>
			</tr>
			<%
			String onCheck = "";
			for (int i=0; i<al.size(); i++){
				CommonDataObject OP = (CommonDataObject) al.get(i);
				String color = "TextRow03";
				if (i % 2 == 0) color = "TextRow04";
				onCheck = "onClick=\"javascript:chkValue("+i+");\"";
			%>
			<%=fb.hidden("anio"+i,OP.getColValue("anio"))%>
			<%=fb.hidden("mes"+i,OP.getColValue("mes"))%>
			<%=fb.hidden("mes_desc"+i,OP.getColValue("mes_desc"))%>
			<%=fb.hidden("id_sol_contrato"+i,OP.getColValue("id_sol_contrato"))%>
			<%=fb.hidden("monto"+i,OP.getColValue("saldo"))%>
			<%=fb.hidden("id_ref"+i,OP.getColValue("id_ref"))%>
			<%=fb.hidden("tipo_trx"+i,OP.getColValue("tipo_trx"))%>
			<%=fb.hidden("tipo_trx_desc"+i,OP.getColValue("tipo_trx_desc"))%>
			<%=fb.hidden("fecha_creacion"+i,OP.getColValue("fecha_creacion"))%>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_sol_contrato")%> </td>
				<%if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))){%>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("anio")%> </td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("mes_desc")%> </td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_ref")%> </td>
				<%} else if(fg.equals("cxc") && tipo_aju.equals("2")){%>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_ref")%> </td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("tipo_trx_desc")%> </td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha_creacion")%> </td>
				<%}%>
				<td onClick="javascript:chkRB(<%=i%>);" align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(OP.getColValue("saldo"))%></td>
				<td align="center">
				<%if (vClt.contains(OP.getColValue("id_sol_contrato")+"_"+OP.getColValue("anio")+"_"+OP.getColValue("mes"))){%>
				elegido
				<%} else {%>
					<%=fb.checkbox("generar"+i,""+i,false, false, "", "", onCheck)%>
				<%}%>
				</td>
			</tr>
			<%}%>
			<%=fb.hidden("keySize",""+al.size())%>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("tipo_trx",tipo_trx)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("tipo_trx",tipo_trx)%>
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
}//GET
else
{
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	Solicitud sol = new Solicitud();
	CommonDataObject cd = new CommonDataObject();
	al = new ArrayList();
	String key = "";
	int lastLineNo = htClt.size();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
			/*if(request.getParameter("estado"+i)==null || request.getParameter("estado"+i).equals("")) cdo.addColValue("estado", "P");
			else 
			*/
			cdo.addColValue("estado", "P");
			cdo.addColValue("id_sol_contrato", request.getParameter("id_sol_contrato"+i));
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("mes", request.getParameter("mes"+i));
			cdo.addColValue("mes_desc", request.getParameter("mes_desc"+i));
			cdo.addColValue("id_ref", request.getParameter("id_ref"+i));
			if(fg.equals("cxc") && (tipo_aju.equals("0") || tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))) cdo.addColValue("saldo", request.getParameter("monto"+i));
			if(fg.equals("cxc") && tipo_aju.equals("0"))cdo.addColValue("monto", request.getParameter("monto"+i));
			else if(fg.equals("cxc") && (tipo_aju.equals("1") || tipo_aju.equals("3") || tipo_aju.equals("5"))) cdo.addColValue("monto", "0");			
			else if(fg.equals("cxc") && tipo_aju.equals("2")){ 
				cdo.addColValue("monto", request.getParameter("monto"+i));
				cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"+i));
				cdo.addColValue("tipo_trx_desc", request.getParameter("tipo_trx_desc"+i));
			}	
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			else cdo.addColValue("secuencia", "0");
			
			if(mode.equals("add")){
				cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion","sysdate");
			} else {
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion","sysdate");
			}
			
			lastLineNo++;
			if (lastLineNo < 10) key = "00" + lastLineNo;
			else if (lastLineNo < 100) key = "0" + lastLineNo;
			else key = "" + lastLineNo;

			try
			{
				htClt.put(key,cdo);
				vClt.addElement(cdo.getColValue("id_sol_contrato")+"_"+cdo.getColValue("anio")+"_"+cdo.getColValue("mes"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			al.add(cdo);
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../planmedico/pm_sel_doctos_ajuste.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&anio="+anio+"&mes="+mes+"&tipo_aju="+tipo_aju+"&id_solicitud="+id_solicitud);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow(){
	window.opener.location = '../planmedico/reg_pm_ajuste_det.jsp?change=1&mode=<%=mode%>&tipo_aju=<%=tipo_aju%>&id_solicitud=<%=id_solicitud%>&fg=<%=fg%>&fp=<%=fp%>';
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
