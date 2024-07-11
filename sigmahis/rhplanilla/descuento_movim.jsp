<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String finicio = request.getParameter("finicio");
String empId = request.getParameter("empId");
String id = request.getParameter("id");
String appendFilter = "";
double totDesc=0.00;
StringBuffer sbSql = new StringBuffer();

boolean viewMode = false;
int lineNo = 0;
//System.out.println("grp="+grupo);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(finicio==null) finicio="";
if(mode.equals("view")) viewMode = true;
if(empId==null) empId="";
if(id==null) id="";

if (request.getMethod().equalsIgnoreCase("GET"))
{

  if (!empId.trim().equals("") && !id.trim().equals("")){
	if (!finicio.trim().equals(""))appendFilter += " and trunc(pe.fecha_pago) >= to_date('"+finicio+"','dd/mm/yyyy')";
	sbSql = new StringBuffer();
	sbSql.append("select (select pd.nombre from  tbl_pla_planilla pd where pd.compania = pa.cod_compania and pd.cod_planilla = pa.da_cod_planilla ) planilladescto, pe.fecha_pago, to_char(pe.fecha_pago,'dd/mm/yyyy') as fechaPagoDesc, to_char(da.monto,'99,990.00') as montoDesc, da.monto, pa.num_cheque   from   tbl_pla_descuento_aplicado da, tbl_pla_planilla_encabezado pe, tbl_pla_pago_acreedor pa where   pa.cod_acreedor= da.cod_acreedor  and    pa.da_anio = da.anio    and    pa.da_cod_planilla = da.cod_planilla and  pa.da_num_planilla = da.num_planilla   and    pa.cod_compania= da.cod_compania   and   pe.anio = pa.anio    and    pe.cod_planilla= pa.cod_planilla   and   pe.num_planilla= pa.num_planilla   and    pe.cod_compania = da.cod_compania  and da.emp_id= ");
	sbSql.append(empId);
	sbSql.append(" and da.num_descuento=");
	sbSql.append(id);
	sbSql.append(" and da.cod_compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" order by  pe.fecha_pago ");
	alTPR = SQLMgr.getDataList(sbSql.toString());
  }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("finicio",finicio)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("id",id)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
			<td width="60%" align="center">Planilla</td>
			<td width="10%" align="center">Fecha Pago</td>
			<td width="15%" align="center">Descontado</td>
			<td width="15%" align="center">No. Cheque/ACH</td>
        </tr>
        <%
		  for (int i=0; i<alTPR.size(); i++){
			key = alTPR.get(i).toString();
          	CommonDataObject cdo = (CommonDataObject) alTPR.get(i);

	        String color = "";
	        if (i%2 == 0) color = "TextRow02";
	        else color = "TextRow01";
	        boolean readonly = true;
			totDesc+=Double.parseDouble(cdo.getColValue("monto")) ;
		%>
        <tr class="<%=color%>" align="center">
				<td width="60%" align="left"><%=cdo.getColValue("planilladescto")%></td>
				<td width="10%" align="center"><%=cdo.getColValue("fechaPagoDesc")%></td>
				<td width="15%" align="right"><%=cdo.getColValue("montoDesc")%></td>
				<td width="15%" align="center"><%=cdo.getColValue("num_cheque")%></td>

        </tr>

        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="center" colspan="2">Total de registros:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDesc)%></td>
          <td>&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
%>