<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();

String change = request.getParameter("change");
String key = "";
String sql = "", appendFilter = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String cod_proveedor = request.getParameter("cod_proveedor");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin"); 
String noDoc = request.getParameter("noDoc"); 
String tipoFac = request.getParameter("tipoFac"); 
String doc_morosidad = request.getParameter("doc_morosidad");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = ""; 
if(noDoc == null) noDoc = ""; 
if(tipoFac == null) tipoFac = ""; 
boolean viewMode = false;
int lineNo = 0;
String compania = (String)session.getAttribute("_companyId");
CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
String vista ="vw_cxp_mov_proveedor";
if(fg.trim().equals("MG"))vista ="vw_cxp_mov_proveedor_mg";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	if(!fechaini.equals("") && !fechafin.equals("")) appendFilter = " and trunc(c.f_emision) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
	//if(!noDoc.equals("")) appendFilter += " and a.numero_factura ='"+noDoc+"'";
	
		
	cdoSI = SQLMgr.getData(sbSql.toString());
	sbSql = new StringBuffer();
	sbSql.append(" select c.cod_banco,c.cuenta_banco,c.num_cheque,c.beneficiario,c.monto_girado as debito,0 as credito ,c.num_orden_pago as numero_orden,c.anio,'PAGO' tipo_doc,c.num_cheque AS num_doc, to_char(c.f_emision,'dd/mm/yyyy')AS fecha,c.cod_banco||' - '||c.cuenta_banco as banco from tbl_cxp_orden_de_pago a,tbl_con_cheque c,tbl_com_proveedor p WHERE a.cod_tipo_orden_pago = 2 AND a.anio = c.anio AND a.num_orden_pago = c.num_orden_pago AND a.cod_compania = c.cod_compania_odp AND c.cod_proveedor = TO_CHAR (p.cod_provedor) AND c.cod_compania = p.compania and exists ( select null from tbl_cxp_orden_de_pago_fact b where  NVL (b.numero_factura, '0') NOT IN ('0', '00') AND a.cod_compania = b.cod_compania AND a.anio = b.anio AND a.num_orden_pago = b.num_orden_pago ) ");
	
	//and  c.anio_comprob=2019
//and c.consecutivo=3075

sbSql.append(" and exists( select null from tbl_con_detalle_cheque dc where dc.compania = c.cod_compania and dc.cod_banco = c.cod_banco AND c.cuenta_banco = c.cuenta_banco AND dc.num_cheque = c.num_cheque AND dc.cuenta1||'.'||dc.cuenta2||'.'||dc.cuenta3||'.'||dc.cuenta4||'.'||dc.cuenta5||'.'||dc.cuenta6 not in ( get_sec_comp_param(c.cod_compania,'CXP_CTA_PROV'))   ) ");
	 sbSql.append(" AND c.cod_compania = ");
	sbSql.append(compania);
	
	if(!cod_proveedor.trim().equals("")	){
	sbSql.append(" and a.cod_proveedor = '");
	sbSql.append(cod_proveedor);
	sbSql.append("' ");
	}
	sbSql.append(appendFilter);
	
	
	sql=sbSql.toString();
	sbSql.append(" order by 1,2,3 asc ");

	al = SQLMgr.getDataList(sbSql.toString());

	
	//cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sql+")");
		
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
function ver(no, anio){abrir_ventana('../cxp/cheque.jsp?mode=view&num_orden_pago='+no+'&anio='+anio+'&fg=CSOP');}
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="10%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="12%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		  <td align="center" width="12%"><cellbytelabel>Banco/Cuenta</cellbytelabel></td>
          <td align="center" width="15%"><cellbytelabel>No. Cheque</cellbytelabel>.</td> 
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="14%"><cellbytelabel>Monto</cellbytelabel></td> 
        </tr>
        
        <%
				double saldo = 0.00,totDbFg=0.00,totCrFg=0.00,saldoFg=0.00,totDbCre=0.00,totCrCre=0.00,saldoCre=0.00;
				String groupBy="",groupByDesc="";
				boolean printTotal =false, showRow = true;
				
		for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
					
		 
			totDbFg += Double.parseDouble(cdo.getColValue("debito"));
			totCrFg += Double.parseDouble(cdo.getColValue("credito"));	
			 
		%>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver('<%=cdo.getColValue("numero_orden")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("tipo_doc")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a>
          </td>
          <td align="left"><%=cdo.getColValue("beneficiario")%></td>
		  <td align="left"><%=cdo.getColValue("banco")%></td>		  
          <td align="center"><%=cdo.getColValue("num_doc")%></td>		   
          <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>       
        </tr>
       <%}%>		
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>TOTAL </cellbytelabel></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDbFg)%></td> 
        </tr>
		
		
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}%>