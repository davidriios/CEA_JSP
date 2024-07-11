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
<jsp:useBean id="tcDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vtcDet" scope="session" class="java.util.Vector"/>
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
String responsable = request.getParameter("responsable");
String change = request.getParameter("change");
String tipo_trx = request.getParameter("tipo_trx");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String contrato = request.getParameter("num_contrato");
String cDateTime = CmnMgr.getCurrentDate("mm/yyyy");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(mes == null) mes =cDateTime.substring(0, 2);
if(anio == null) anio = cDateTime.substring(3, 7);
if(id==null) id = "";
if(responsable==null) responsable = "";


if(contrato==null) contrato = "";
if(fg==null) fg = "";
if(fp==null) fp = "";
if(id==null) id = "0";
if(tipo_trx==null) tipo_trx = "ACH";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

  int recsPerPage = 1000;
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

	sbSql.append("select id id_contrato, id_cliente, (select nombre_paciente from vw_pm_cliente where codigo = c.id_cliente) nombre_cliente, decode(forma_pago, 1, 'TC', 2, 'ACH', 'M') tipo_trx, fecha_ini_plan, getPmMontoCuota(id) monto, id_corredor, 0 secuencia, estado, decode(estado, 'P', 'Pendiente', 'F', 'Finalizado', 'A', 'Activo') estado_desc, NVL((case '");
	sbSql.append(tipo_trx);
	sbSql.append("' when 'M' then 1 else (select periodo from tbl_pm_cta_tarjeta t where t.id_solicitud = c.id and t.estado = 'A') end), 1) periodo, ");
	if(tipo_trx.equals("M")){
	sbSql.append("nvl((select join(cursor(select distinct r.id from tbl_pm_regtran r, tbl_pm_regtran_det rd where r.id = rd.id and r.estado != 'I' and rd.estado = 'P' and rd.id_contrato = c.id and rd.id_cliente = c.id_cliente and r.anio = ");
	sbSql.append(anio);
	sbSql.append(" and r.mes = ");
	sbSql.append(mes);
	sbSql.append("), ',') from dual), '') listas ");
	} else {
	sbSql.append("nvl((select join(cursor(select distinct r.id from tbl_pm_regtran r, tbl_pm_regtran_det rd where r.id = rd.id and rd.estado not in ('R', 'I') and r.estado != 'I' and rd.id_contrato = c.id and rd.id_cliente = c.id_cliente and r.anio = ");
	sbSql.append(anio);
	sbSql.append(" and r.mes = ");
	sbSql.append(mes);
	sbSql.append(" and rd.tipo_trx in ('ACH', 'TC')), ',') from dual), '') listas ");
		
	}
	sbSql.append(" from tbl_pm_solicitud_contrato c where estado = 'A'");
	sbSql.append(" /*and trunc(c.fecha_ini_plan) <= to_date(to_char(sysdate, 'dd')||'/'||lpad(");
	sbSql.append(mes);
	sbSql.append(", 2, '0')||'/'||'");
	sbSql.append(anio);
	sbSql.append("', 'dd/mm/yyyy')*/");
	if(contrato!=null && !contrato.equals("")){
		sbSql.append(" and c.id = ");
		sbSql.append(contrato);
	}	
	if(responsable!=null && !responsable.equals("")){
		sbSql.append(" and exists (select null from vw_pm_cliente pc where pc.codigo = c.id_cliente and pc.nombre_paciente like '%");
		sbSql.append(responsable.toUpperCase());
		sbSql.append("%')");
	}
	if(!tipo_trx.equals("M")){
	sbSql.append(" and not exists (select null from tbl_pm_regtran r, tbl_pm_regtran_det rd where r.id = rd.id and rd.id_cliente = c.id_cliente and rd.id_contrato = c.id and r.estado != 'I' and r.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and trunc(c.fecha_ini_plan) >= to_date((case when  TO_CHAR (SYSDATE, 'dd') = '31' then to_char(last_day(to_date('");
	sbSql.append(mes);
	sbSql.append("/");
	sbSql.append(anio);
	sbSql.append("', 'mm/yyyy')), 'dd') else TO_CHAR (SYSDATE, 'dd') end)||'/'||'");
	sbSql.append(mes);
	sbSql.append("/");
	sbSql.append(anio);
	sbSql.append("', 'dd/mm/yyyy')");
	if(!anio.equals("")){ sbSql.append(" and r.anio = ");sbSql.append(anio);}
	if(!tipo_trx.equals("M")){
		if(!mes.equals("")){ sbSql.append(" and r.mes = ");sbSql.append(mes);}
		sbSql.append(" and r.estado in ('A', 'P')");
	}

	/*if(tipo_trx.equals("M")){
		//sbSql.append(" and r.estado = 'P'");
	} else {
		if(!mes.equals("")){ sbSql.append(" and r.mes = ");sbSql.append(mes);}
		sbSql.append(" and r.estado in ('A', 'P')");
	}*/
	
	sbSql.append(" and r.tipo_trx in ('ACH','TC'/*,'M'*/)");
	sbSql.append(")");
	}
	/*if(!tipo_trx.equals("M")) {
	sbSql.append(" and not exists (select null from tbl_pm_factura f where f.id_sol_contrato = c.id and f.anio = ");
	sbSql.append(anio);
	sbSql.append(" and f.mes = ");
	sbSql.append(mes);
	sbSql.append(" and f.id_regtran is not null)");
	}*/
	if(tipo_trx.equals("ACH")) {
		sbSql.append(" and exists (select null from tbl_pm_cta_tarjeta ct where ct.id_solicitud = c.id and ct.estado = 'A' and ct.tipo = 'C'");
		sbSql.append(" and to_date(to_char(ct.fecha_inicio,'mm/yyyy'), 'mm/yyyy') <= to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy'))");
	}
	else if(tipo_trx.equals("TC")){ 
		sbSql.append(" and exists (select null from tbl_pm_cta_tarjeta ct where ct.id_solicitud = c.id and ct.estado = 'A' and ct.tipo = 'T'");
		sbSql.append(" and to_date(to_char(ct.fecha_inicio,'mm/yyyy'), 'mm/yyyy') <= to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy'))");
	}
	else if(tipo_trx.equals("M")) {}
	else sbSql.append("  and exists (select null from tbl_pm_cta_tarjeta ct where ct.id_solicitud = c.id and ct.estado = 'A' and ct.tipo in ('C','T'))");
	sbSql.append(" order by c.id desc, id_cliente");
	boolean showList = true;
	if(tipo_trx.equals("M") && contrato.equals("") && responsable.equals("")) showList = false;
	if(showList){
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

function chkRB(i){checkRadioButton(document.contrato.rb, i);}
function calcT(i){
}

function setAll(){var size = document.detail.keySize.value;for(i=0;i<size;i++){if(eval('document.detail.generar'+i) && eval('document.detail.listas'+i).value=='')eval('document.detail.generar'+i).checked = document.detail.generar.checked;}}
function chkValue(i){
	<%//if(!tipo_trx.equals("M")){%>
	if(eval('document.detail.generar'+i).checked) if(eval('document.detail.listas'+i).value!=''){CBMSG.warning('El contrato ya se encuentra en otra lista!');eval('document.detail.generar'+i).checked=false;}
	<%//}%>
}

/*

*/
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
				<%fb = new FormBean("contrato",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<tr class="TextFilter">
					<td><cellbytelabel>REGISTRO TRANSACCIONES DE ACH/TARJETA DE CREDITO</cellbytelabel></td>
				</tr>
				<tr class="TextFilter">
					<td>
					<%
					String mes_desc = "";
					if(mes.equals("01")) mes_desc = "Enero";
					else if(mes.equals("02")) mes_desc = "Febrero";
					else if(mes.equals("03")) mes_desc = "Marzo";
					else if(mes.equals("04")) mes_desc = "Abril";
					else if(mes.equals("05")) mes_desc = "Mayo";
					else if(mes.equals("06")) mes_desc = "Junio";
					else if(mes.equals("07")) mes_desc = "Julio";
					else if(mes.equals("08")) mes_desc = "Agosto";
					else if(mes.equals("09")) mes_desc = "Septiembre";
					else if(mes.equals("10")) mes_desc = "Octubre";
					else if(mes.equals("11")) mes_desc = "Noviembre";
					else if(mes.equals("12")) mes_desc = "Diciembre";
					String tipo_desc = "";
					if(tipo_trx.equals("ACH")) tipo_desc = "ACH";
					else if(tipo_trx.equals("TC")) tipo_desc = "TARJETA DE CREDITO";
					else if(tipo_trx.equals("M")) tipo_desc = "MANUAL";
					%>
					<%if(tipo_trx.equals("M")){%>
					<%=fb.hidden("anio",cdo.getColValue("anio"))%>
					<%=fb.hidden("mes_desc",mes_desc)%>
					<%} else {%>
					A&ntilde;o: <%=fb.textBox("anio",cdo.getColValue("anio"),false,false,true,5,4,"Text12","","")%>
					Mes: 
					<%=fb.textBox("mes_desc",mes_desc,false,false,true,20,20,"Text12","","")%>
					<%}%>
					Tipo:
					<%=fb.textBox("tipo_desc",tipo_desc,false,false,true,20,20,"Text12","","")%>
					Num. Contrato:
					<%=fb.textBox("num_contrato",contrato,false,false,false,10,20,"Text12","","")%>
					Responsable:
					<%=fb.textBox("responsable",responsable,false,false,false,40,100,"Text12","","")%>
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
<%=fb.hidden("responsable",responsable)%>
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
<%=fb.hidden("responsable",responsable)%>
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
				<td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td align="center" width="48%"><cellbytelabel>Beneficiario</cellbytelabel></td>
				<td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
				<td align="center" width="10%"><cellbytelabel>Monto Total</cellbytelabel></td>
				<td align="center" width="10%"><cellbytelabel>Estado</cellbytelabel></td>
				<td align="center" width="10%"><cellbytelabel>Lista</cellbytelabel></td>
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
			<%=fb.hidden("id_cliente"+i,OP.getColValue("id_cliente"))%>
			<%=fb.hidden("id_corredor"+i,OP.getColValue("id_corredor"))%>
			<%=fb.hidden("id_contrato"+i,OP.getColValue("id_contrato"))%>
			<%=fb.hidden("tipo_trx"+i,OP.getColValue("tipo_trx"))%>
			<%=fb.hidden("secuencia"+i,OP.getColValue("secuencia"))%>
			<%=fb.hidden("nombre_cliente"+i,OP.getColValue("nombre_cliente"))%>
			<%=fb.hidden("periodo"+i,OP.getColValue("periodo"))%>
			<%=fb.hidden("listas"+i,OP.getColValue("listas"))%>

			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_contrato")%> </td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("id_cliente")%> </td>
				<td align="left" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("nombre_cliente")%> </td>
				<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("monto"+i,OP.getColValue("monto"),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Monto",false,"")%></td>
				<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal((Double.parseDouble(OP.getColValue("monto"))*Double.parseDouble(OP.getColValue("periodo")))),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Monto",false,"")%></td>
				<td align="center">
				<%if(mode.equals("edit")){%>
				<%=fb.select("estado"+i,"A=Activo,I=Inactivo",OP.getColValue("estado"),false,false,false,0,"Text10","","")%>
				<%} else {%>
				<%=OP.getColValue("estado_desc")%>
				<%}%>
				</td>
				<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("listas")%> </td>
				<td align="center">
				<%if (vtcDet.contains(OP.getColValue("id_contrato")+"_"+OP.getColValue("id_cliente"))){%>
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
<%=fb.hidden("responsable",responsable)%>
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
<%=fb.hidden("responsable",responsable)%>
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
	int lastLineNo = tcDet.size();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
			/*if(request.getParameter("estado"+i)==null || request.getParameter("estado"+i).equals("")) cdo.addColValue("estado", "P");
			else 
			*/
			cdo.addColValue("estado", "P");
			cdo.addColValue("id_contrato", request.getParameter("id_contrato"+i));
			cdo.addColValue("id_cliente", request.getParameter("id_cliente"+i));
			cdo.addColValue("id_corredor", request.getParameter("id_corredor"+i));
			cdo.addColValue("monto", request.getParameter("monto"+i));
			//if (tipo_trx.equalsIgnoreCase("M")) cdo.addColValue("monto_app","0.00");
			//else 
			cdo.addColValue("monto_app", request.getParameter("monto"+i));
			cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"));
			cdo.addColValue("nombre_cliente", request.getParameter("nombre_cliente"+i));
			cdo.addColValue("periodo", request.getParameter("periodo"+i));
			cdo.addColValue("num_cuotas", request.getParameter("periodo"+i));
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
				tcDet.put(key,cdo);
				vtcDet.addElement(cdo.getColValue("id_contrato")+"_"+cdo.getColValue("id_cliente"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			al.add(cdo);
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../planmedico/pm_sel_ach_tc.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&anio="+anio+"&mes="+mes+"&tipo_trx="+tipo_trx+"&contrato="+contrato);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow(){
	window.opener.location = '../planmedico/reg_tc_ach_det.jsp?change=1&mode=<%=mode%>&anio=<%=anio%>&mes=<%=mes%>&tipo_trx=<%=tipo_trx%>';
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
